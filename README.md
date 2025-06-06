# 🛠️ Script de Mantenimiento y Optimización para Linux

Este script automatiza tareas de limpieza, mantenimiento y ajuste de rendimiento en sistemas Linux, organizadas en bloques temáticos claros y funcionales. Ideal para mantener tu equipo rápido, ordenado y eficiente.

---

## 🧼 Mantenimiento del Sistema

### 1. 🔄 Actualización del sistema

Actualiza todos los paquetes mediante `apt update` y `apt upgrade -y` para garantizar que el sistema esté al día.

### 2. 🧹 Limpieza de paquetes obsoletos y kernels antiguos

* Elimina dependencias no utilizadas con `apt autoremove` y `apt clean`.
* Elimina kernels antiguos, conservando solo el actualmente en uso.

### 3. 🧾 Limpieza de listas de paquetes APT

Elimina listas descargadas en `/var/lib/apt/lists/` para liberar espacio.

### 4. 🧠 Limpieza de cachés de entornos de desarrollo

Elimina cachés de herramientas comunes si están instaladas:

* `pip` (Python)
* `npm` y `yarn` (Node.js)
* `composer` (PHP)

### 5. 🗑️ Limpieza de temporales y logs

* Borra archivos en `/tmp`, `/var/tmp`, y logs grandes.
* Ejecuta `logrotate` para forzar la rotación de logs del sistema.

### 6. 👤 Limpieza de usuarios

Para cada usuario en `/home` y `root`, elimina:

* Cachés de miniaturas
* Archivos de la papelera
* Archivos obsoletos de Snap y Flatpak

### 7. 💽 Análisis del uso del disco

* Muestra el uso de disco con `df -h`.
* Lista archivos mayores a 500 MB en todo el sistema, facilitando su identificación y eliminación.

### 8. 🧯 Revisión de servicios

Enumera servicios activos y fallidos con `systemctl`.

### 9. 🐳 Limpieza profunda de Docker (si está instalado)

* Elimina contenedores detenidos, volúmenes, redes no usadas e imágenes obsoletas.
* Limpia la caché de builds.
* Muestra el uso de espacio por parte de Docker.

### 10. 🧬 Ajustes del sistema

* Ajusta `vm.swappiness` a 10 para priorizar RAM sobre swap.
* Muestra `fs.file-max` (límite de descriptores de archivos).

### 11. 🔁 Segunda rotación de logs

Ejecuta nuevamente `logrotate` para garantizar la rotación de todos los archivos.

### 12. 🔐 Verificación de SSH

Verifica que el servicio `ssh` esté activo e informa si no lo está.

### 13. ⏰ Sincronización horaria

Activa la sincronización automática mediante `timedatectl set-ntp true`.

---

## 🚀 Optimización del Rendimiento

### 1. 🧠 Ajustes de memoria virtual

* Reduce `vm.swappiness` a 10.
* Establece `vm.vfs_cache_pressure` en 50.

### 2. ⚡ Modo CPU "performance"

* Instala `cpufrequtils` si es necesario.
* Configura todos los núcleos para usar el modo "performance".
* Persiste la configuración en `/etc/default/cpufrequtils`.

### 3. ❌ Desactivación de servicios innecesarios

Desactiva servicios como:
`avahi-daemon`, `bluetooth`, `cups`, `postfix`, `ModemManager`, `whoopsie`, `rsync`, `apport`

### 4. 🎨 Desactivación de animaciones gráficas

Reduce el consumo visual en entornos como:
GNOME, XFCE, KDE Plasma, MATE, Cinnamon.

### 5. 🖥️ Desactivación del splash gráfico (Plymouth)

* Reemplaza `quiet splash` por `text` en GRUB.
* Aplica los cambios con `update-grub`.

### 6. 🔐 Ajustes en gestores de pantalla

* En LightDM: oculta la lista de usuarios.
* En SDDM: fuerza el tema `breeze`.

### 7. 🧬 Ajustes adicionales del kernel

* Aumenta `fs.inotify.max_user_watches` a `524288`.
* Establece `fs.file-max` en `200000`.

### 8. 🐳 Limpieza básica de Docker

Elimina:

* Contenedores detenidos
* Imágenes *dangling*
* Volúmenes huérfanos
* Redes no utilizadas

### 9. 🧹 Limpieza temporal general

* Borra `/tmp`, `/var/tmp`, y cachés APT.
* Ejecuta `apt autoclean`.

### 10. 🔍 Verificación de servicios críticos

Comprueba que `ssh` esté activo y genera un log si no lo está.

### 11. ⏰ Sincronización horaria

Habilita `NTP` con `timedatectl set-ntp true`.

### 12. 💽 Resumen del uso de disco

Ejecuta `df -h` para mostrar espacio disponible en los sistemas de archivos.

### 13. 🔁 Ejecución de mantenimiento mensual

Si existe `/usr/local/bin/optimizar-seguro.sh` y es ejecutable, lo lanza para consolidar tareas.

---

## ✅ Requisitos y compatibilidad

Este script está diseñado para sistemas basados en Debian/Ubuntu y puede adaptarse fácilmente a otros entornos Linux. Es ideal para:

* Servidores
* Equipos de escritorio con pocos recursos
* Máquinas virtuales
