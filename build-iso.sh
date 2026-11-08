#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
LIMINE_DIR="${LIMINE_DIR:-$ROOT/limine}"
BUILD="$ROOT/build"
ISO_ROOT="$BUILD/iso-root"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Falta la herramienta: $1" >&2; exit 1; }; }
for tool in git make clang ld.lld xorriso; do need "$tool"; done

if [[ ! -d "$LIMINE_DIR/.git" ]]; then
  git clone https://github.com/limine-bootloader/limine.git \
    --branch=v8.x-binary --depth=1 "$LIMINE_DIR"
fi

make -C "$LIMINE_DIR"
make LIMINE_DIR="$LIMINE_DIR" all

rm -rf "$ISO_ROOT"
mkdir -p "$ISO_ROOT/boot/limine" "$ISO_ROOT/EFI/BOOT"
cp "$BUILD/kernel.elf" "$ISO_ROOT/boot/kernel.elf"
cp "$ROOT/boot/limine.conf" "$ISO_ROOT/boot/limine/limine.conf"
cp "$LIMINE_DIR/limine-bios.sys" "$ISO_ROOT/boot/limine/"
cp "$LIMINE_DIR/limine-bios-cd.bin" "$ISO_ROOT/boot/limine/"
cp "$LIMINE_DIR/limine-uefi-cd.bin" "$ISO_ROOT/boot/limine/"
cp "$LIMINE_DIR/BOOTX64.EFI" "$ISO_ROOT/EFI/BOOT/"

xorriso -as mkisofs \
  -b boot/limine/limine-bios-cd.bin \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  --efi-boot boot/limine/limine-uefi-cd.bin \
  -efi-boot-part --efi-boot-image --protective-msdos-label \
  "$ISO_ROOT" -o "$BUILD/LirioOS-0.1-x86_64.iso"

"$LIMINE_DIR/limine" bios-install "$BUILD/LirioOS-0.1-x86_64.iso"
sha256sum "$BUILD/LirioOS-0.1-x86_64.iso" > "$BUILD/SHA256SUMS"
echo "ISO creada: $BUILD/LirioOS-0.1-x86_64.iso"
echo "Hash: $(cut -d' ' -f1 "$BUILD/SHA256SUMS")"
