# MSI Keyboard RGB — plugin de Noctalia

Controla el teclado RGB SteelSeries per-key de laptops MSI (Stealth 16, etc.)
desde la barra de Noctalia, usando `msi-perkeyrgb`.

## Requisitos
- `msi-perkeyrgb` instalado (AUR).
- Permiso sudo sin password para el binario:
  ```
  echo "TU_USUARIO ALL=(root) NOPASSWD: /usr/bin/msi-perkeyrgb" | sudo tee /etc/sudoers.d/msi-rgb
  sudo chmod 440 /etc/sudoers.d/msi-rgb
  ```
  (Este plugin llama a `msi-perkeyrgb` directamente; si tu setup exige sudo,
  ajustar Main.qml para anteponer `sudo`.)

## Uso
- **Icono en la barra**: click izquierdo abre Configuracion (color picker + efectos).
- **Click derecho**: menu rapido de efectos y apagar.
- **IPC** (para atajos de Niri):
  - `qs -c noctalia-shell ipc call plugin:msi-rgb setColorHex "#ff0000"`
  - `qs -c noctalia-shell ipc call plugin:msi-rgb setEffect rainbow-split`
  - `qs -c noctalia-shell ipc call plugin:msi-rgb off`

## Modelo
Por defecto usa el modelo `GS65` de msi-perkeyrgb (funciona en MSI Stealth 16
AI Studio). Cambiar en el manifest si tu teclado necesita otro.
