# Clang/LLVM as a main toolchain for Gentoo Linux!

This is Gentoo Linux overlay experiment allowing to have your stage3 completely _gccfree_. In the future, fully usable stage3 files will be provided. As of now, you can either try to assemble stage yourself, by using provided script, or add profile to your system and rebuild world.

### WARNING: Alpha quality!

## Building stage3 by hand

As of now, there are profiles for `amd64` only. Once PoC will be done, other archs will be added.

1. Add this overlay to your system as per wiki:

```
eselect repository add toolchain-clang git https://github.com/2b57/toolchain-clang.git
emaint sync -r toolchain-clang
```

2. Pick a profile (but don't `eselect` it). There are 3 main profiles available:

- `clang` – based on `default/linux/amd64/17.1`;
- `clang/lto` – same, but with LTO;
- `clang/musl` – based on `default/linux/amd64/17.0/musl`;
- `clang/musl/lto` – same, but with LTO. 

`bootstrap` profile is used for building `stage1` and should not be explicitly chosen.

**NOTE:** if you're using anything `musl`-related, you'll need to clone RelEng repo as well, since `musl` stages require some of the tweaks from there:
```
cd /var/db/repos/toolchain-clang
git clone https://github.com/gentoo/releng.git
```

3. Run `stage-builder.sh` script against corresponding `spec` file:

```
cd /var/db/repos/toolchain-clang
./scripts/stage-builder.sh specs/clang/musl/stage1.spec
./scripts/stage-builder.sh specs/clang/musl/stage2.spec
./scripts/stage-builder.sh specs/clang/musl/stage3.spec
```

3. Cross fingers...
