# noctalia-msi-rgb

Registro de plugins de Noctalia con el plugin **MSI Keyboard RGB**.

Controla el teclado RGB SteelSeries per-key de laptops MSI (Stealth 16, etc.)
desde la barra de Noctalia, usando `msi-perkeyrgb`.

## Instalar en Noctalia

1. Settings -> Plugins -> Sources -> agregar este repo:
   `https://github.com/blackbirdsr71/noctalia-msi-rgb`
2. Buscar "MSI Keyboard RGB" en la lista de plugins e instalarlo.
3. Activarlo y agregar su widget a la barra.

## Requisitos
- `msi-perkeyrgb` instalado (AUR). Funciona sin sudo si las reglas udev del
  paquete estan activas.

Ver `msi-rgb/README.md` para detalles del plugin.
