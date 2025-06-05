  GNU nano 7.2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           /usr/local/bin/optimizar-seguro.sh                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     #!/bin/bash

OUTPUT="/var/log/optimizar.html"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Iniciar HTML
cat <<EOF > "$OUTPUT"
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Informe de Mantenimiento Avanzado - $DATE</title>
  <style>
    body { font-family: monospace; background: #f4f4f4; padding: 20px; }
    h1, h2 { color: #444; margin-top: 1em; }
    pre { background: #fff; border: 1px solid #ccc; padding: 10px; overflow-x: auto; }
  </style>
</head>
<body>
<h1>Mantenimiento automático de Debian + Docker (avanzado)</h1>
<p><strong>Fecha:</strong> $DATE</p>
EOF

## 1. Actualización de paquetes
echo "<h2>1. Actualización del sistema</h2><pre>" >> "$OUTPUT"
apt update && apt upgrade -y >> "$OUTPUT" 2>&1
echo "</pre>" >> "$OUTPUT"

## 2. Limpieza de paquetes y eliminación de kernels antiguos
echo "<h2>2. Limpieza de paquetes y kernels</h2><pre>" >> "$OUTPUT"
apt autoremove -y --purge >> "$OUTPUT" 2>&1
apt clean >> "$OUTPUT" 2>&1
# Eliminar kernels antiguos (mantener solo el actual)
CURRENT_KERNEL=$(uname -r)
dpkg --list 'linux-image-[0-9]*' | awk '{ print $2 }' | grep -v "$CURRENT_KERNEL" | xargs -r apt-get -y purge >> "$OUTPUT" 2>&1
echo "</pre>" >> "$OUTPUT"

## 3. Vaciar listas de APT (para ahorrar espacio en /var/lib/apt/lists)
echo "<h2>3. Vaciar listas de APT</h2><pre>" >> "$OUTPUT"
rm -rf /var/lib/apt/lists/* >> "$OUTPUT" 2>&1
echo "</pre>" >> "$OUTPUT"

## 4. Limpieza de cachés de lenguajes y gestores
echo "<h2>4. Cachés de Python, Node y Composer</h2><pre>" >> "$OUTPUT"
if command -v pip &> /dev/null; then
  pip cache purge >> "$OUTPUT" 2>&1
else
  echo "pip no instalado" >> "$OUTPUT"
fi
if command -v npm &> /dev/null; then
  npm cache clean --force >> "$OUTPUT" 2>&1
else
  echo "npm no instalado" >> "$OUTPUT"
fi
if command -v yarn &> /dev/null; then
  yarn cache clean >> "$OUTPUT" 2>&1
else
  echo "yarn no instalado" >> "$OUTPUT"
fi
if command -v composer &> /dev/null; then
  composer clear-cache >> "$OUTPUT" 2>&1
else
  echo "composer no instalado" >> "$OUTPUT"
fi
echo "</pre>" >> "$OUTPUT"

## 5. Archivos temporales y logs
echo "<h2>5. Limpieza de temporales y logs</h2><pre>" >> "$OUTPUT"
rm -rf /tmp/* /var/tmp/* >> "$OUTPUT" 2>&1
rm -rf /var/cache/apt/archives/* >> "$OUTPUT" 2>&1
journalctl --vacuum-time=7d >> "$OUTPUT" 2>&1
find /var/log -type f -name "*.log" -size +20M -exec truncate -s 0 {} \; >> "$OUTPUT" 2>&1
# Rotar logs con logrotate
logrotate --force /etc/logrotate.conf >> "$OUTPUT" 2>&1
echo "</pre>" >> "$OUTPUT"

## 6. Cachés y papeleras de usuarios (incluyendo snap/flatpak)
echo "<h2>6. Cachés de usuario y papelera</h2><pre>" >> "$OUTPUT"
for user in $(ls /home); do
  USER_HOME="/home/$user"
  rm -rf "$USER_HOME/.cache/thumbnails/"* >> "$OUTPUT" 2>&1
  rm -rf "$USER_HOME/.local/share/Trash/"* >> "$OUTPUT" 2>&1
  # Snap (si existe)
  if [ -d "$USER_HOME/snap" ]; then
    rm -rf "$USER_HOME/snap"/* >> "$OUTPUT" 2>&1
  fi
  # Flatpak (si existe)
  if [ -d "$USER_HOME/.var/app" ]; then
    flatpak uninstall --unused -y >> "$OUTPUT" 2>&1
  fi
done
rm -rf /root/.cache/thumbnails/* >> "$OUTPUT" 2>&1
rm -rf /root/.local/share/Trash/* >> "$OUTPUT" 2>&1
echo "</pre>" >> "$OUTPUT"

## 7. Espacio en disco y ficheros grandes
echo "<h2>7. Espacio en disco y ficheros grandes</h2><pre>" >> "$OUTPUT"
df -h >> "$OUTPUT"
echo -e "\nArchivos >500MB:" >> "$OUTPUT"
find / -xdev -type f -size +500M -exec ls -lh {} \; | awk '{ print $NF \" (\" $5 \")\" }' >> "$OUTPUT" 2>&1
echo "</pre>" >> "$OUTPUT"

## 8. Servicios activos y fallidos
echo "<h2>8. Servicios activos y fallidos</h2><pre>" >> "$OUTPUT"
systemctl list-units --type=service --state=running >> "$OUTPUT" 2>&1
echo -e "\nServicios fallidos:" >> "$OUTPUT"
systemctl --failed >> "$OUTPUT" 2>&1
echo "</pre>" >> "$OUTPUT"

## 9. Limpieza y análisis de Docker
echo "<h2>9. Docker - Limpieza profunda</h2><pre>" >> "$OUTPUT"
if command -v docker &> /dev/null; then
  echo "Contenedores detenidos (y borrados):" >> "$OUTPUT"
  docker ps -a --filter "status=exited" --format "{{.ID}} {{.Names}}" | xargs -r docker rm >> "$OUTPUT" 2>&1

  echo -e "\nVolúmenes no utilizados (y borrados):" >> "$OUTPUT"
  docker volume prune -f >> "$OUTPUT" 2>&1

  echo -e "\nRedes no utilizadas (y borradas):" >> "$OUTPUT"
  docker network prune -f >> "$OUTPUT" 2>&1

  echo -e "\nImágenes colgantes <none> (y borradas):" >> "$OUTPUT"
  docker images --filter "dangling=true" -q | xargs -r docker rmi >> "$OUTPUT" 2>&1

  echo -e "\nImágenes no usadas (y borradas):" >> "$OUTPUT"
  docker image prune -af >> "$OUTPUT" 2>&1

  echo -e "\nBuild cache >24h (y depurado):" >> "$OUTPUT"
  docker buildx prune -a --filter until=24h --force >> "$OUTPUT" 2>&1

  echo -e "\nVolúmenes huérfanos (adicional revisión):" >> "$OUTPUT"
  docker volume ls -qf dangling=true | xargs -r docker volume rm >> "$OUTPUT" 2>&1

  echo -e "\nEspacio usado por Docker:" >> "$OUTPUT"
  docker system df >> "$OUTPUT" 2>&1
else
  echo "Docker no está instalado" >> "$OUTPUT"
fi
echo "</pre>" >> "$OUTPUT"

## 10. Sysctl y parámetros del kernel
echo "<h2>10. Parámetros de sysctl y swappiness</h2><pre>" >> "$OUTPUT"
# Ajustar swappiness (si no está ya en 10)
SYSWAP=$(sysctl -n vm.swappiness)
echo "Swappiness actual: $SYSWAP" >> "$OUTPUT"
if [ "$SYSWAP" -ne 10 ]; then
  sysctl vm.swappiness=10 >> "$OUTPUT" 2>&1
  sed -i '/vm.swappiness/d' /etc/sysctl.conf
  echo "vm.swappiness=10" >> /etc/sysctl.conf
  echo "Swappiness ajustado a 10" >> "$OUTPUT"
else
  echo "Swappiness ya en 10" >> "$OUTPUT"
fi
# Ejemplo: aumentar file-max (opcional)
echo "fs.file-max=$(sysctl -n fs.file-max)" >> "$OUTPUT"
echo "</pre>" >> "$OUTPUT"

## 11. Rotar logs inmediatamente (en caso de que falte)
echo "<h2>11. Forzar rotación de logs</h2><pre>" >> "$OUTPUT"
logrotate --force /etc/logrotate.conf >> "$OUTPUT" 2>&1
echo "</pre>" >> "$OUTPUT"

## 12. Comprobación de integridad de servicios críticos (ejemplo: SSH)
echo "<h2>12. Verificación servicios críticos</h2><pre>" >> "$OUTPUT"
if systemctl is-active ssh &> /dev/null; then
  echo "SSH activo" >> "$OUTPUT"
else
  echo "SSH NO está activo" >> "$OUTPUT"
fi
echo "</pre>" >> "$OUTPUT"

## 13. Sincronización horaria
echo "<h2>13. Sincronización horaria</h2><pre>" >> "$OUTPUT"
timedatectl set-ntp true >> "$OUTPUT" 2>&1
echo "</pre>" >> "$OUTPUT"

## Cierre del HTML
echo "</body></html>" >> "$OUTPUT"



