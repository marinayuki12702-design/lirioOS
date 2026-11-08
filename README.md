# LirioOS 0.1 — Foundation

LirioOS es un sistema operativo experimental e independiente para x86_64. Este repositorio contiene el primer hito: un kernel freestanding escrito en C que arranca mediante el protocolo Limine, inicializa una salida serie COM1 y dibuja una pantalla de bienvenida usando el framebuffer UEFI.

**Limine es solamente el cargador de arranque. El kernel que se carga es código propio de LirioOS.** No se utiliza un kernel Linux, Debian ni componentes de Windows como núcleo.

## Estado real de esta versión

- [x] Código inicial de kernel x86_64 en C freestanding.
- [x] Solicitud de framebuffer mediante Limine.
- [x] Salida serie COM1 para diagnóstico temprano.
- [x] Pantalla gráfica inicial con identidad LirioOS.
- [x] Script de construcción de ISO BIOS/UEFI.
- [x] GitHub Actions para compilar y publicar la ISO como artefacto.
- [ ] Gestión propia de memoria física y virtual.
- [ ] IDT, excepciones e interrupciones.
- [ ] Planificador, procesos, hilos y llamadas al sistema.
- [ ] LirioFS.
- [ ] Cargador PE y APIs Win32.
- [ ] Escritorio y controladores completos.

La pantalla inicial **no significa que ya exista un escritorio funcional**. El kernel termina detenido de forma segura después de dibujarla. Todavía no ejecuta programas `.exe`.

## Arquitectura prevista

- Arquitectura: x86_64.
- Kernel: híbrido, propio, escrito principalmente en C y Assembly.
- Arranque: UEFI/BIOS mediante Limine.
- Sistema de archivos futuro: LirioFS (a diseñar e implementar).
- Compatibilidad futura: ejecutables Windows PE32 y PE32+, mediante cargador PE y subsistema Win32 propio.

`.exe` es un formato de ejecutable (PE), no un sistema de archivos. La compatibilidad Windows necesitará implementar formatos, ABI, llamadas al sistema, DLL y APIs Win32; no basta con reconocer la extensión del archivo.

## Construir desde Windows 11

La vía más sencilla para esta primera versión es GitHub Actions: sube esta carpeta a un repositorio de GitHub, abre **Actions**, selecciona **Build LirioOS ISO** y pulsa **Run workflow**. Al terminar, descarga el artefacto `LirioOS-0.1-x86_64`.

También puedes compilar localmente desde Ubuntu en WSL2. Instala las herramientas:

```bash
sudo apt update
sudo apt install -y clang lld make git xorriso
```

Desde la carpeta del proyecto:

```bash
chmod +x build-iso.sh
./build-iso.sh
```

El script descarga el código de Limine en una carpeta local `limine/`, compila el kernel y genera `build/LirioOS-0.1-x86_64.iso`.

## Pruebas

Con QEMU y OVMF instalados:

```bash
qemu-system-x86_64 -machine q35 -m 512M \
  -drive if=pflash,format=raw,readonly=on,file=/ruta/OVMF_CODE.fd \
  -cdrom build/LirioOS-0.1-x86_64.iso
```

Para depuración serie, puedes añadir `-serial stdio`. El kernel escribe sus mensajes en COM1.

## Seguridad y limitaciones

Es software experimental. Pruébalo primero en una máquina virtual, nunca sobre un disco con datos importantes. No lo instales como sistema principal. El script de construcción requiere conexión a Internet para descargar Limine.
