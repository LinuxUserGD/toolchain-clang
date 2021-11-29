# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

LICENSE="GPL-2+"
DESCRIPTION="Virtual for system C/C++ toolchain"
HOMEPAGE="https://github.com/2b57/toolchain-clang"

SLOT="0"
KEYWORDS="*"
RDEPEND="|| (
        sys-devel/clang
        sys-devel/gcc
)"
