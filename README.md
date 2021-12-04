# Clang/LLVM as a main toolchain for Gentoo Linux!
### WARNING: Alpha quality!

This is Gentoo Linux overlay experiment allowing to have your stage3 completely _GCC-free_. You can either grab a release and process with installation as per Gentoo Handbook, or try to switch your current system profile and rebuild world.

# Available profiles
### amd64
- `clang` based on `default/linux/amd64/17.1`;
- `clang/lto` same, but with LTO;
- `clang/musl` based on `default/linux/amd64/17.0/musl`;
- `clang/musl/lto` same, but with LTO.

### NOTE
`bootstrap` profile is used by catalyst only and shouldn't be selected.

# HOWTO
## Add this overlay
```
eselect repository add toolchain-clang git https://github.com/2b57/toolchain-clang.git
emaint sync -r toolchain-clang
```

## How to use it
This is your default stage3 + `git` + `eselect-repository` packages for overlay management. You'll get warnings that your profile symlink is invalid, so after chrooting inside be sure to add this overlay (see above) and select right profile:
```
# eselect profile list | grep toolchain-clang:linux/amd64/clang/musl
  [43]  toolchain-clang:linux/amd64/clang/musl (exp)
  [44]  toolchain-clang:linux/amd64/clang/musl/lto (exp)
# eselect profile set --force 43
# eselect profile list | grep toolchain-clang:linux/amd64/clang/musl
  [43]  toolchain-clang:linux/amd64/clang/musl (exp) *
  [44]
```

# I want to build stage3 myself
## Overview
Apart from custom spec files, some modifications to `scripts/bootstrap.sh` are required. In order to execute right file, provided build script creates OverlayFS mount which will be used as Gentoo Portage tree for catalyst; contents of `/var/db/repos/gentoo` (main tree) is combined with `assets/baserepo_overlay` folder. Catalyst envscripts (`catalystrc`) are created as needed during the process.

### bootstrap profile
`bootstrap` profile is used for building `stage1` with GCC if there are no seed `clang` stages available and should not be explicitly chosen. In this case, catalyst build order is `bootstrap-stage1` -> `clang-stage2` -> `clang-stage3`. If `clang` seed stage is present, you'll need to edit spec files accordingly.

### musl
If you want to go with anything `musl`-related, you'll need to clone RelEng repo as well, since `musl` stages require some of the tweaks from there:
```
cd /var/db/repos/toolchain-clang
git clone https://github.com/gentoo/releng.git
```


## Building
- Add this overlay to your system (see above)
- Install deps: `catalyst` and `pixz`
- Pick a profile, but don't `eselect` it
- Run `stage-builder.sh` script against corresponding `spec` file:

```
cd /var/db/repos/toolchain-clang
./assets/scripts/stage-builder.sh specs/clang/musl/stage1.spec
./assets/scripts/stage-builder.sh specs/clang/musl/stage2.spec
./assets/scripts/stage-builder.sh specs/clang/musl/stage3.spec
```