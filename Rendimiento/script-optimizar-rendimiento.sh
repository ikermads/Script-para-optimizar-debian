## 1. Ajustar vm.swappiness y vm.vfs_cache_pressure
echo "<h2>1. Ajuste de parámetros de memoria virtual</h2><pre>" >> "$OUTPUT"
echo "- swappiness actual: $(sysctl -n vm.swappiness)" >> "$OUTPUT"
sysctl vm.swappiness=10 >> "$OUTPUT" 2>&1
grep -q "^vm.swappiness" /etc/sysctl.conf \
  && sed -i 's/^vm\.swappiness=.*/vm.swappiness=10/' /etc/sysctl.conf \
  || echo "vm.swappiness=10" >> /etc/sysctl.conf

echo "- vfs_cache_pressure actual: $(sysctl -n vm.vfs_cache_pressure)" >> "$OUTPUT"
sysctl vm.vfs_cache_pressure=50 >> "$OUTPUT" 2>&1
grep -q "^vm.vfs_cache_pressure" /etc/sysctl.conf \
  && sed -i 's/^vm\.vfs_cache_pressure=.*/vm.vfs_cache_pressure=50/' /etc/sysctl.conf \
  || echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf
echo "</pre>" >> "$OUTPUT"

## 2. Ajustar governor de CPU a “performance”
echo "<h2>2. Ajuste del governor de CPU a ‘performance’</h2><pre>" >> "$OUTPUT"
if ! command -v cpufreq-info &> /dev/null; then
  echo "- Instalando cpufrequtils…" >> "$OUTPUT"
  apt update && apt install -y cpufrequtils >> "$OUTPUT" 2>&1
fi
echo "- Estableciendo scaling_governor=performance en todos los núcleos:" >> "$OUTPUT"
for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*; do
  if echo performance > "$cpu_dir/cpufreq/scaling_governor" 2>/dev/null; then
    echo "  • $(basename "$cpu_dir"): performance" >> "$OUTPUT"
  fi
done
if [ -f /etc/default/cpufrequtils ]; then
  sed -i 's/^GOVERNOR=.*/GOVERNOR="performance"/' /etc/default/cpufrequtils 2>/dev/null \
    && echo "- /etc/default/cpufrequtils actualizado." >> "$OUTPUT"
else
  echo 'GOVERNOR="performance"' > /etc/default/cpufrequtils
  echo "- Creado /etc/default/cpufrequtils con GOVERNOR=\"performance\"." >> "$OUTPUT"
fi
echo "</pre>" >> "$OUTPUT"

## 3. Desactivar servicios innecesarios
SERVICIOS_CANCELAR=(
  avahi-daemon
  bluetooth
  cups
  postfix
  ModemManager
  whoopsie
  rsync
  apport
)
echo "<h2>3. Desactivación de servicios innecesarios</h2><pre>" >> "$OUTPUT"
for svc in "${SERVICIOS_CANCELAR[@]}"; do
  if systemctl list-unit-files | grep -q "^$svc"; then
    systemctl disable "$svc" >> "$OUTPUT" 2>&1
    systemctl stop    "$svc" >> "$OUTPUT" 2>&1
    echo "  • $svc: deshabilitado y detenido" >> "$OUTPUT"
  else
    echo "  • $svc: no instalado" >> "$OUTPUT"
  fi
done
echo "</pre>" >> "$OUTPUT"

## 4. Desactivar animaciones en entorno gráfico
echo "<h2>4. Desactivación de animaciones en entornos gráficos</h2><pre>" >> "$OUTPUT"

# GNOME
if sudo -u "$REAL_USER" which gsettings &> /dev/null; then
  echo "- GNOME: desactivando animaciones…" >> "$OUTPUT"
  sudo -u "$REAL_USER" gsettings set org.gnome.desktop.interface enable-animations false >> "$OUTPUT" 2>&1 || true
  sudo -u "$REAL_USER" gsettings set org.gnome.desktop.interface enable-smooth-scrolling false >> "$OUTPUT" 2>&1 || true
else
  echo "- GNOME: gsettings no disponible o no hay sesión GNOME" >> "$OUTPUT"
fi

# XFCE
if command -v xfconf-query &> /dev/null; then
  echo "- XFCE: desactivando compositing…" >> "$OUTPUT"
  sudo -u "$REAL_USER" xfconf-query -c xfwm4 -p /general/use_compositing -s false >> "$OUTPUT" 2>&1 || true
else
  echo "- XFCE: xfconf-query no disponible" >> "$OUTPUT"
fi

# KDE Plasma
if command -v kwriteconfig5 &> /dev/null; then
  echo "- KDE Plasma: desactivando compositor…" >> "$OUTPUT"
  sudo -u "$REAL_USER" kwriteconfig5 --file kwinrc --group Compositing --key Enabled false >> "$OUTPUT" 2>&1 || true
  sudo -u "$REAL_USER" qdbus org.kde.KWin /Compositor suspend >> "$OUTPUT" 2>&1  || true
else
  echo "- KDE: kwriteconfig5 no disponible" >> "$OUTPUT"
fi

# MATE
if command -v dconf &> /dev/null; then
.  echo "- MATE: desactivando animaciones…" >> "$OUTPUT"
  sudo -u "$REAL_USER" dconf write /org/mate/interface/enable-animations false >> "$OUTPUT" 2>&1 || true
else
  echo "- MATE: dconf no disponible" >> "$OUTPUT"
fi

# Cinnamon
if sudo -u "$REAL_USER" gsettings list-schemas | grep -q org.cinnamon.desktop.interface; then
  echo "- Cinnamon: desactivando animaciones…" >> "$OUTPUT"
  sudo -u "$REAL_USER" gsettings set org.cinnamon.desktop.interface enable-animations false >> "$OUTPUT" 2>&1 || true
else
  echo "- Cinnamon: GSettings schema no encontrado" >> "$OUTPUT"
fi

echo "</pre>" >> "$OUTPUT"

## 5. Desactivar Plymouth (splash al arrancar)
echo "<h2>5. Desactivación de Plymouth (splash)</h2><pre>" >> "$OUTPUT"
if grep -q "quiet" /etc/default/grub; then
  sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 quiet splash"/' /etc/default/grub
  echo "- Añadido ‘quiet splash’ a GRUB_CMDLINE_LINUX_DEFAULT (se reemplaza a modo texto luego)." >> "$OUTPUT"
fi
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="text"/' /etc/default/grub 2>/dev/null || true
update-grub >> "$OUTPUT" 2>&1
echo "</pre>" >> "$OUTPUT"

## 6. Ajustes de Xorg / LightDM / SDDM (si aplica)
echo "<h2>6. Ajustes de gestor de pantalla</h2><pre>" >> "$OUTPUT"
# LightDM
if [ -f /etc/lightdm/lightdm.conf ]; then
  echo "- LightDM: desactivando sesión animada…" >> "$OUTPUT"
  sed -i 's/^#greeter-hide-users.*/greeter-hide-users=true/' /etc/lightdm/lightdm.conf || true
else
  echo "- LightDM: no encontrado" >> "$OUTPUT"
fi
# SDDM
if [ -f /etc/sddm.conf ]; then
  echo "- SDDM: fijando tema estático ‘breeze’…" >> "$OUTPUT"
  sed -i 's/^Current=.*/Current=breeze/' /etc/sddm.conf || true
else
  echo "- SDDM: no encontrado" >> "$OUTPUT"
fi
echo "</pre>" >> "$OUTPUT"

## 7. Ajustes extra de kernel (inotify, file-max)
echo "<h2>7. Ajustes extra de kernel</h2><pre>" >> "$OUTPUT"
echo "- inotify.max_user_watches actual: $(sysctl -n fs.inotify.max_user_watches)" >> "$OUTPUT"
sysctl fs.inotify.max_user_watches=524288 >> "$OUTPUT" 2>&1
grep -q "^fs.inotify.max_user_watches" /etc/sysctl.conf \
  && sed -i 's/^fs\.inotify\.max_user_watches=.*/fs.inotify.max_user_watches=524288/' /etc/sysctl.conf \
  || echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf

echo "- file-max actual: $(sysctl -n fs.file-max)" >> "$OUTPUT"
sysctl fs.file-max=200000 >> "$OUTPUT" 2>&1
grep -q "^fs.file-max" /etc/sysctl.conf \
  && sed -i 's/^fs\.file-max=.*/fs.file-max=200000/' /etc/sysctl.conf \
  || echo "fs.file-max=200000" >> /etc/sysctl.conf
echo "</pre>" >> "$OUTPUT"

## 8. Limpieza básica de Docker (solo contenedores detenidos, imágenes dangling, volúmenes huérfanos)
echo "<h2>8. Limpieza básica de Docker</h2><pre>" >> "$OUTPUT"
if command -v docker &> /dev/null; then
  echo "- Eliminando contenedores detenidos…" >> "$OUTPUT"
  docker ps -a --filter "status=exited" --format "{{.ID}}" | xargs -r docker rm >> "$OUTPUT" 2>&1

  echo "- Eliminando imágenes dangling (<none>)…" >> "$OUTPUT"
  docker images --filter "dangling=true" -q | xargs -r docker rmi >> "$OUTPUT" 2>&1

  echo "- Eliminando volúmenes huérfanos…" >> "$OUTPUT"
  docker volume ls -qf dangling=true | xargs -r docker volume rm >> "$OUTPUT" 2>&1

  echo "- Eliminando redes no utilizadas…" >> "$OUTPUT"
  docker network prune -f >> "$OUTPUT" 2>&1
else
  echo "Docker no está instalado o no está en PATH." >> "$OUTPUT"
fi
echo "</pre>" >> "$OUTPUT"

## 9. Limpieza de temporales del sistema
echo "<h2>9. Limpieza de archivos temporales</h2><pre>" >> "$OUTPUT"
rm -rf /tmp/* /var/tmp/* >> "$OUTPUT" 2>&1
rm -rf /var/cache/apt/archives/* >> "$OUTPUT" 2>&1
apt autoclean >> "$OUTPUT" 2>&1
echo "</pre>" >> "$OUTPUT"

## 10. Verificación de servicios críticos
echo "<h2>10. Verificación de servicios críticos</h2><pre>" >> "$OUTPUT"
if systemctl is-active ssh &> /dev/null; then
  echo "- SSH está activo." >> "$OUTPUT"
else
  echo "- SSH NO está activo." >> "$OUTPUT"
fi
echo "</pre>" >> "$OUTPUT"

## 11. Sincronización horaria
echo "<h2>11. Sincronización horaria</h2><pre>" >> "$OUTPUT"
timedatectl set-ntp true >> "$OUTPUT" 2>&1
echo "</pre>" >> "$OUTPUT"

## 12. Resumen final de uso de disco
echo "<h2>12. Resumen de uso de disco</h2><pre>" >> "$OUTPUT"
df -h >> "$OUTPUT"
echo "</pre>" >> "$OUTPUT"

## 13. LLAMAR AL SCRIPT DE MANTENIMIENTO MENSUAL
if [ -x /usr/local/bin/optimizar-seguro.sh ]; then
  echo "<h2>13. Invocación del mantenimiento mensual</h2><pre>" >> "$OUTPUT"
  /usr/local/bin/optimizar-seguro.sh >> "$OUTPUT" 2>&1
  echo "</pre>" >> "$OUTPUT"
else
  echo "<h2>13. Mantenimiento mensual no encontrado</h2><pre>[/usr/local/bin/optimizar-seguro.sh no existe o no es ejecutable]</pre>" >> "$OUTPUT"
fi

# Cierre del HTML
echo "</body></html>" >> "$OUTPUT"
