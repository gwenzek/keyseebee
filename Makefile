# PKG="apt-get"
# PKG="dnf"
PKG="port"
# This doesn't really work, cargo still puts a lot of stuff in ~/.cargo
CARGO_HOME=~/.config/cargo
CARGO_BIN=${CARGO_HOME}/bin

build: firmware/keyseebee.bin

flash: firmware/keyseebee.bin
	echo "Don't forget to reboot the board in flash mode"
	sudo dfu-util -d 0483:df11 -a 0 -s 0x08000000:leave -D $<

clean:
	rm firmware/keyseebee.bin

install_deps: rustup_install.sh
	RUSTUP_HOME=~/.config/rustup CARGO_HOME=${CARGO_HOME} sh $< --no-modify-path -y
	${CARGO_BIN}/rustup default stable
	${CARGO_BIN}/rustup target add thumbv6m-none-eabi
	${CARGO_BIN}/rustup component add llvm-tools-preview
	${CARGO_BIN}/cargo install cargo-binutils
	sudo ${PKG} install dfu-util

firmware/keyseebee.bin: firmware/src/*.rs
	cd $(@D) && cargo objcopy --bin keyseebee --release -- -O binary $(@F)

debug:
	cd firmware && cargo build --verbose

rustup_install.sh:
	curl https://sh.rustup.rs -sSf -o $@
