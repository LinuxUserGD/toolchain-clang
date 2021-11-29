subarch: amd64
target: stage1
version_stamp: clang-musl-@TIMESTAMP@
rel_type: clang-musl
profile: toolchain-clang:linux/amd64/bootstrap/musl
snapshot: @TIMESTAMP@
source_subpath: musl/stage3-amd64-musl-@TIMESTAMP@
chost: x86_64-gentoo-linux-musl
portage_prefix: releng
portage_overlay: /var/db/repos/musl /var/db/repos/toolchain-clang
portage_confdir: /var/db/repos/toolchain-clang/releng/releases/portage/stages
update_seed: yes
update_seed_command: --update --deep --newuse @world
compression_mode: pixz

