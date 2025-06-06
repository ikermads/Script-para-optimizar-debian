# 🛠️ Mantenimiento y Optimización de Debian + Docker

Este proyecto incluye dos scripts de mantenimiento para sistemas Debian, pensados para ejecutarse:

* Uno **mensualmente** para mantenimiento avanzado.
* Otro **una única vez** para **optimización de rendimiento** del sistema.

Ambos scripts generan un informe en **formato HTML** accesible desde `/var/log/optimizar.html`.

---

## 📦 Script 1: `optimizar-seguro.sh` – *Mantenimiento mensual avanzado*

**Ubicación recomendada:** `/usr/local/bin/optimizar-seguro.sh`
**Ejecución recomendada:** con `cron` una vez al mes como root.

### Funciones principales:

1. **🧱 Actualización del sistema** (`apt update && upgrade`)
2. **🧹 Limpieza avanzada de paquetes y kernels antiguos**
3. **📂 Eliminación de listas APT obsoletas**
4. **🌐 Limpieza de cachés de lenguajes**: Python (`pip`), Node (`npm`, `yarn`), Composer
5. **🧼 Limpieza de temporales, logs pesados y truncado de `.log` > 20MB**
6. **👥 Limpieza de cachés y papeleras de usuarios**, incluyendo Snap y Flatpak
7. **💽 Revisión de espacio y archivos mayores a 500MB**
8. **⚙️ Estado de servicios activos y fallidos**
9. **🐳 Limpieza profunda de Docker**: contenedores, volúmenes, redes, imágenes sin uso y build cache
10. **🧠 Ajustes de `sysctl` (ej: swappiness a 10)**
11. **📑 Forzado de rotación de logs con `logrotate`**
12. **🔐 Verificación de servicios críticos (ej: SSH activo)**
13. **🕒 Sincronización horaria activada con `timedatectl`**

> **Resultado:** Genera un archivo `/var/log/optimizar.html` con todos los resultados formateados.

---

## 🚀 Script 2: `script-optimizar-rendimiento.sh` – *Optimización de rendimiento única*

**Uso recomendado:** Ejecutar **una sola vez** tras la instalación del sistema o en equipos de escritorio/laptops donde se desea mejorar el rendimiento.

### Funciones clave:

1. **🧠 Ajustes de memoria virtual**:

   * `vm.swappiness=10` para menos uso de swap
   * `vm.vfs_cache_pressure=50` para preservar caché de directorios

2. **⚡ Optimización de CPU (governor "performance")**

   * Uso de `cpufrequtils` para fijar el escalado de CPU a máximo rendimiento.

3. **📉 Desactivación de servicios innecesarios**:

   * Incluye `avahi-daemon`, `cups`, `bluetooth`, `ModemManager`, `postfix`, `whoopsie`, etc.

4. **🎨 Desactivación de animaciones gráficas**:

   * Compatible con GNOME, XFCE, KDE Plasma, MATE y Cinnamon.

5. **🚫 Desactivación de splash screen (Plymouth) en GRUB**

6. **🖥️ Ajustes del gestor de pantalla**:

   * LightDM: ocultar usuarios
   * SDDM: fijar tema estático

7. **📈 Ajustes extra del kernel**:

   * `inotify.max_user_watches=524288`
   * `fs.file-max=200000`

8. **🐋 Limpieza básica de Docker** (contenedores detenidos, imágenes `<none>`, volúmenes y redes sin uso)

> **Resultado:** También se añade al HTML `/var/log/optimizar.html` si se combina o se adapta la ejecución.

---

## ✅ Recomendaciones

* **Automatización mensual**: añade a `cron` el script mensual:

  ```bash
  sudo crontab -e
  ```

  Añade:

  ```cron
  0 2 1 * * /usr/local/bin/optimizar-seguro.sh
  ```

* **Ejecución inicial del script de rendimiento**:

  ```bash
  sudo bash script-optimizar-rendimiento.sh
  ```

* **Ver resultados**:
  Abre en navegador local:

  ```
  file:///var/log/optimizar.html
  ```

---

## ⚠️ Advertencias

* Los scripts deben ejecutarse como **root**.
* Se recomienda revisarlos antes de usarlos en entornos de producción.
* Algunos ajustes de rendimiento (como desactivar servicios o el splash) pueden no ser adecuados para todos los entornos.
