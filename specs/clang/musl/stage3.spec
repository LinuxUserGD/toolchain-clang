subarch: amd64
target: stage3
version_stamp: clang-musl-@TIMESTAMP@
rel_type: clang-musl
profile: toolchain-clang:linux/amd64/clang/musl
snapshot: @TIMESTAMP@
source_subpath: clang-musl/stage2-amd64-clang-musl-@TIMESTAMP@
portage_prefix: releng
portage_confdir: /var/db/repos/toolchain-clang/releng/releases/portage/stages
portage_overlay: /var/db/repos/musl /var/db/repos/toolchain-clang
compression_mode: pixz_x