## Mantenimiento 

El script está organizado por bloques de tareas, y cada una genera su sección correspondiente dentro del informe HTML. A continuación te explico cada bloque de forma clara:

1. 🔄 Actualización del sistema
Actualiza todos los paquetes disponibles mediante apt update y apt upgrade -y.

2. 🧹 Limpieza de paquetes obsoletos y kernels antiguos
Elimina paquetes que ya no se usan (apt autoremove, apt clean) y borra kernels antiguos, dejando únicamente el que está en uso.

3. 🧾 Limpieza de listas APT
Elimina las listas de paquetes descargadas para ahorrar espacio.

4. 🧠 Limpieza de cachés de herramientas de desarrollo
Limpia cachés de los siguientes entornos si están instalados:

pip (Python)

npm y yarn (Node.js)

composer (PHP)

5. 🗑️ Limpieza de temporales y logs
Elimina archivos de carpetas como /tmp, /var/tmp, limpia archivos .log muy grandes y fuerza una rotación de logs con logrotate.

6. 👤 Limpieza de cachés y papelera de usuarios
Para cada usuario de /home (y también root), borra:

Cachés de miniaturas.

Archivos en la papelera.

Archivos Snap y Flatpak no usados.

7. 💽 Análisis del espacio en disco
Muestra el uso actual del disco (df -h) y lista todos los archivos del sistema que ocupan más de 500MB, ideal para detectar ficheros olvidados.

8. 🧯 Revisión de servicios
Muestra qué servicios están corriendo y cuáles han fallado (systemctl).

9. 🐳 Limpieza profunda de Docker
Si tienes Docker instalado, el script realiza una limpieza completa:

Borra contenedores detenidos.

Borra volúmenes y redes no usadas.

Borra imágenes obsoletas o "colgantes".

Limpia cachés de builds.

Muestra el uso actual de espacio por Docker.

10. 🧬 Ajustes del kernel y sistema
Revisa y, si es necesario, ajusta el valor de swappiness a 10, que mejora el rendimiento del sistema en muchos casos. También muestra el valor actual de fs.file-max.

11. 🔁 Fuerza una rotación de logs
Ejecuta nuevamente logrotate para asegurarse de que todos los logs del sistema se roten correctamente.

12. 🔐 Verificación de servicios críticos
Revisa si el servicio SSH está corriendo y muestra un aviso si no es así.

13. ⏰ Sincronización horaria
Habilita la sincronización horaria automática mediante timedatectl set-ntp true.




--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Optimizar rendimiento

1. 🧠 Ajustes de memoria virtual (swappiness y vfs_cache_pressure)
Reduce el valor de vm.swappiness a 10, priorizando la RAM sobre el intercambio a disco.

Ajusta vm.vfs_cache_pressure a 50, equilibrando la limpieza de cachés del sistema de archivos.

2. ⚡ Establecer el modo de CPU a "performance"
Instala cpufrequtils si no está disponible.

Configura todos los núcleos de CPU para que usen el gobernador "performance", priorizando la velocidad máxima constante.

Persiste este cambio en /etc/default/cpufrequtils.

3. ❌ Desactivación de servicios innecesarios
Deshabilita y detiene los siguientes servicios si están presentes:

avahi-daemon, bluetooth, cups, postfix, ModemManager, whoopsie, rsync, apport

Reduce el consumo de recursos y el número de servicios escuchando en red.

4. 🎨 Desactivación de animaciones gráficas
Desactiva efectos visuales que consumen CPU/GPU en los entornos:

GNOME

XFCE

KDE Plasma

MATE

Cinnamon

Esto mejora el rendimiento en equipos con pocos recursos.

5. 🖥️ Desactivación de Plymouth (splash gráfico de arranque)
Elimina la pantalla de arranque gráfica (quiet splash) reemplazándola por modo texto (text).

Aplica los cambios con update-grub.

6. 🔐 Ajustes en gestores de pantalla (login)
Si se detecta LightDM, se activa la opción de ocultar lista de usuarios.

Si se detecta SDDM, se fuerza el uso del tema breeze para mayor estabilidad.

7. 🧬 Ajustes adicionales del kernel
Aumenta el número máximo de inotify watches a 524288 para aplicaciones que monitorean archivos (como editores de código).

Establece fs.file-max en 200000 para permitir más descriptores de archivos simultáneos.

8. 🐳 Limpieza básica de Docker
Si Docker está instalado:

Elimina contenedores detenidos.

Elimina imágenes dangling (sin nombre).

Borra volúmenes huérfanos y redes no utilizadas.

Esto recupera espacio y evita acumulación de residuos.

9. 🧹 Limpieza de archivos temporales
Borra contenido de /tmp, /var/tmp, y cachés APT.

Ejecuta apt autoclean para borrar paquetes ya descargados que no se pueden instalar.

10. 🔍 Verificación de servicios críticos
Comprueba si el servicio SSH está activo e informa en el log si no lo está.

11. ⏰ Sincronización horaria
Activa NTP (timedatectl set-ntp true) para mantener la hora del sistema sincronizada.

12. 💽 Resumen de uso de disco
Ejecuta df -h para mostrar el uso actual de todos los sistemas de archivos montados.

13. 🔁 Invoca el script mensual de mantenimiento
Llama a /usr/local/bin/optimizar-seguro.sh si existe y es ejecutable, para integrar ambos scripts en una única rutina.
