BUILD := build
LIMINE_DIR ?= limine
CC := clang
LD := ld.lld
CFLAGS := --target=x86_64-unknown-none-elf -std=gnu11 -O2 -Wall -Wextra -Werror \
          -ffreestanding -fno-stack-protector -fno-pic -fno-pie \
          -fno-asynchronous-unwind-tables -fno-unwind-tables \
          -mno-red-zone -mcmodel=kernel -m64 -I$(LIMINE_DIR)
LDFLAGS := -nostdlib -static -T linker.ld -z max-page-size=0x1000

.PHONY: all clean iso
all: $(BUILD)/kernel.elf

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/kernel.o: src/kernel.c | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/kernel.elf: $(BUILD)/kernel.o linker.ld
	$(LD) $(LDFLAGS) $< -o $@

iso:
	bash ./build-iso.sh

clean:
	rm -rf $(BUILD)
