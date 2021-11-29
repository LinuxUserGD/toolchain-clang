#!/bin/bash
# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# This script attempts to be a universal stage builder
#

source /lib/gentoo/functions.sh

if [ "$#" -lt 1 ]; then
	eerror "Usage: stage-builder.sh <spec.file> [<catalyst.config>]"
	exit 1
fi

if [ ! -f "$1" ]; then
	eerror "Provided specfile does not exist"
	exit 1
fi

if [[ "$2" != "" && ! -f "$2" ]]; then
	eerror "Provided catalyst config does not exist"
	exit 1
fi

# helper func to extract particular key from a spec file
function get_from_spec() {
	grep "$1" "$SPECFILE" | cut -d ':' -f2 | tr -d '[:space:]'
}

SPECFILE="$1"
CATALYST="$2"
CONFTEMP=$(mktemp -d)
TIMESTAMP=$(date +%Y.%m.%d)
REPO_BASEDIR="/var/db/repos"
SNAPSHOT_BASE="/var/tmp/catalyst/snapshots"
SEEDFILE_BASE="/var/tmp/catalyst/builds"

# extract & prepare some params
ARCH=$(get_from_spec "subarch")
PREFIX=$(get_from_spec source_subpath | cut -d '/' -f1)
FLAVOUR=$(get_from_spec profile | cut -d ':' -f1 || "gentoo")
SNAPSHOT_FILE="$SNAPSHOT_BASE/$FLAVOUR-$TIMESTAMP.tar.bz2"
BASEURL="https://bouncer.gentoo.org/fetch/root/all/releases/$ARCH/autobuilds"

# let's go
einfo "Current @TIMESTAMP@ value is $TIMESTAMP"

# workaround for a bug in catalyst: "snapcache" feature
# will look for this directory and crash if it doesn't exist
mkdir -p "/var/tmp/catalyst/snapshot_cache/$TIMESTAMP"

# create portage overlay
THIS_OVERLAY_DIR="$REPO_BASEDIR/toolchain-clang"
DEFAULT_REPO_DIR="$REPO_BASEDIR/gentoo"
MOUNT_JUNKDIR=$(mktemp -d)
MOUNT_REPODIR="$MOUNT_JUNKDIR/toolchain-clang-overlay"
MOUNT_OVERLAY="$MOUNT_JUNKDIR/portage-union"
MOUNT_WORKDIR="$MOUNT_OVERLAY-workdir"

einfo "Preparing custom portage overlay"

# unmount overlay and remove temp stuff 
trap 'umount -f "$MOUNT_OVERLAY"; rm -rf "$MOUNT_JUNKDIR" "$CONFTEMP"' SIGINT SIGTERM ERR EXIT

if [ $(grep -q "$MOUNT_OVERLAY" /proc/mounts; echo $?) -eq 0 ]; then
	einfo "Unmounting old mountpoint"
	umount -f "$MOUNT_OVERLAY" || exit 1
fi

eval "rm -rf $MOUNT_OVERLAY $MOUNT_WORKDIR && mkdir -p $MOUNT_OVERLAY $MOUNT_WORKDIR" || exit 1
eval "mkdir -p $MOUNT_OVERLAY/scripts && cp -f $THIS_OVERLAY_DIR/scripts/bootstrap.sh $MOUNT_OVERLAY/scripts/bootstrap.sh" || exit 1
eval "mount -t overlay overlay -o lowerdir=\"$DEFAULT_REPO_DIR\",upperdir=\"$MOUNT_REPODIR\",workdir=\"$MOUNT_WORKDIR\" $MOUNT_OVERLAY" || exit 1

einfo "Portage overlay is located at $MOUNT_OVERLAY"

# at this point is safe to assume that there's no external catalyst config
# available, so stick to the bundled one
if [ -z "$CATALYST" ]; then
	einfo "Tweaking catalyst config to use just created portage overlay"
	cp -f "$THIS_OVERLAY_DIR/scripts/catalyst.conf" "$CONFTEMP/catalyst.conf" || exit 1
	sed -i "s/@PORTDIR@/$MOUNT_OVERLAY/g" "$CONFTEMP/catalyst.conf" || exit 1
	CATALYST="$CONFTEMP/catalyst.conf"
fi

# check for base dir
if [ ! -d "$SNAPSHOT_BASE" ]; then
	einfo "Making catalyst snapshot directory"
	mkdir -p "$SNAPSHOT_BASE"
fi

# check for snapshot
if [ ! -f "$SNAPSHOT_FILE" ]; then
	einfo "Getting current snapshot..."

	CMD="catalyst -s $TIMESTAMP"

	if [[ -n "$CATALYST" && -f "$CATALYST" ]]; then
		CMD="$CMD -c $CATALYST"
	fi

	eval "$CMD" || exit 1
fi

# assemble seedfile candidates
REQUIRED_SEEDFILE="latest-stage3-$ARCH-$PREFIX"
SEEDFILE_NICENAME=$(get_from_spec source_subpath | cut -d '/' -f2 | sed "s/@TIMESTAMP@/$TIMESTAMP/")

# check for the actual seedfile
SOMEFILES=$(find "$SEEDFILE_BASE/$PREFIX" -type f -name "$SEEDFILE_NICENAME*")

if [ -z "$SOMEFILES" ]; then
	einfo "Getting latest available build data for $ARCH/$PREFIX..."
	mkdir -p "$SEEDFILE_BASE/$PREFIX"
	URL_SUFFIX=$(wget -qO- "$BASEURL/$REQUIRED_SEEDFILE.txt" | grep -v '#' | cut -d ' ' -f 1)
	FILETYPE=$(echo "$URL_SUFFIX" | cut -d '.' -f2,3) # will break on too many dots
	einfo "Getting latest stage3..."
	einfo "Downloading $BASEURL/$URL_SUFFIX"
	wget -O "$SEEDFILE_BASE/$PREFIX/$SEEDFILE_NICENAME.$FILETYPE" "$BASEURL/$URL_SUFFIX" || exit 1
else
	einfo "Seed stages found: $SOMEFILES"
fi

# copy seedfile and update timestamp
einfo "Updating specfile"
SPECBASE=$(basename "$SPECFILE")
NEWSPEC="$CONFTEMP/$SPECBASE"
cp -f "$SPECFILE" "$NEWSPEC" || exit 1
sed -i "s/@TIMESTAMP@/$TIMESTAMP/g" "$NEWSPEC" || exit 1

# ready to proceed with catalyst
einfo "Created specfile $NEWSPEC, invoking catalyst..."
CMD="catalyst -f $NEWSPEC"

if [[ -n "$CATALYST" && -f "$CATALYST" ]]; then
	CMD="$CMD -c $CATALYST"
fi

eval "$CMD"
