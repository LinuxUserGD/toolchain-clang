subarch: ppc
target: stage2
version_stamp: clang-musl-@TIMESTAMP@
rel_type: clang-musl
profile: toolchain-clang:linux/ppc/clang/musl
snapshot: @TIMESTAMP@
source_subpath: clang-musl/stage1-ppc-clang-musl-@TIMESTAMP@
chost: x86_64-gentoo-linux-musl
portage_prefix: releng
portage_overlay: /var/db/repos/musl /var/db/repos/toolchain-clang
portage_confdir: /var/db/repos/toolchain-clang/releng/releases/portage/stages
compression_mode: pixz_x
