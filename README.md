# Script-para-optimizar-debian

# 🧹 Script de Optimización para Linux (Fácil y Paso a Paso)

Este script ayuda a mejorar el rendimiento de tu sistema Linux **automáticamente**. Apaga animaciones, limpia archivos temporales y hace algunos ajustes para que tu computadora funcione más rápido.

---

## ✅ ¿Qué hace este script?

- Apaga animaciones innecesarias (en escritorios como GNOME, KDE, XFCE, etc.)
- Quita la pantalla de inicio (splash) para arrancar más rápido.
- Limpia archivos temporales y basura.
- Elimina contenedores de Docker que ya no usas (si tienes Docker).
- Aumenta algunos límites del sistema para mejorar el rendimiento.
- Verifica servicios importantes como SSH.
- Ajusta la hora del sistema.
- Muestra un resumen del uso de disco.
- Llama a otro script de mantenimiento (si lo tienes).

---

## 🧾 Requisitos

- Tener una computadora con **Linux** (como Ubuntu, Debian, Linux Mint, etc.).
- Tener permisos de **administrador** (sudo).
- Tener el script en tu sistema, por ejemplo en:  
  `/usr/local/bin/optimizar-rendimiento.sh`

---

## 🧰 ¿Cómo usarlo? (Paso a Paso)

### 1. Abre la terminal.

Puedes buscar "Terminal" en tu sistema.

### 2. Dale permiso de ejecución al script:

```bash
sudo chmod +x /usr/local/bin/optimizar-rendimiento.sh
