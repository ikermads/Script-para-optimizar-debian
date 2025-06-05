# 🚀 Script de Optimización de Rendimiento en Linux

Este proyecto contiene un script llamado `optimizar-rendimiento.sh`, diseñado para **mejorar el rendimiento general de sistemas Linux** (especialmente Debian, Ubuntu y derivados), tanto en equipos personales como en máquinas virtuales o servidores de escritorio ligeros.

---

## 📌 Objetivo del Script

El objetivo principal es **hacer que el sistema funcione más rápido y ligero**, mediante:

- Desactivación de animaciones gráficas.
- Limpieza de archivos innecesarios.
- Ajustes del kernel y servicios del sistema.
- Eliminación de recursos sin uso en Docker.
- Verificación del estado del sistema.
- Generación de un informe detallado en HTML.

---

## 🧰 ¿Qué realiza específicamente?

### 1. **Desactivación de animaciones del entorno gráfico**

El script detecta entornos de escritorio comunes y desactiva sus animaciones para acelerar la interfaz gráfica:

- **GNOME**
- **XFCE**
- **KDE Plasma**
- **MATE**
- **Cinnamon**

También se desactiva la composición en caso de que esté habilitada.

---

### 2. **Desactivar Plymouth (pantalla de carga)**

Reemplaza la línea `GRUB_CMDLINE_LINUX_DEFAULT` para eliminar efectos gráficos durante el arranque.

---

### 3. **Ajustes en gestores de pantalla**

Realiza configuraciones específicas para los siguientes *display managers*:

- **LightDM**: evita mostrar usuarios animadamente.
- **SDDM**: establece el tema `breeze`, más liviano.

---

### 4. **Ajustes del kernel**

Se ajustan parámetros importantes para mejorar el rendimiento:

- `fs.inotify.max_user_watches`: útil para editores y herramientas como VSCode.
- `fs.file-max`: permite más archivos abiertos.

---

### 5. **Limpieza básica de Docker**

Si Docker está instalado, se eliminan:

- Contenedores detenidos.
- Imágenes colgantes (`<none>`).
- Volúmenes huérfanos.
- Redes no usadas.

---

### 6. **Eliminación de archivos temporales del sistema**

Borra:

- `/tmp/*`, `/var/tmp/*`
- Caché de `apt`
- Ejecuta `apt autoclean`

---

### 7. **Verificación de servicios críticos**

Ejemplo: verifica si el servicio `ssh` está activo.

---

### 8. **Sincronización horaria**

Habilita `systemd-timesyncd` para tener la hora actualizada automáticamente con `timedatectl`.

---

### 9. **Resumen de uso de disco**

Muestra el uso actual del disco (`df -h`), útil al final para saber cuánta basura fue eliminada.

---

### 10. **Ejecución opcional de script mensual**

Si existe `/usr/local/bin/optimizar-seguro.sh`, lo ejecuta al final como complemento.

---

## 📄 Salida del Script

El script genera un archivo HTML con todo el detalle de la ejecución:

```bash
/var/log/optimizar.html
