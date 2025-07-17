#!/bin/bash

echo ""
echo "========================================"
echo "   SCRAP ASCENT - BUILD SCRIPT"
echo "========================================"
echo ""

# Configuracion
PROJECT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_PATH="$PROJECT_PATH/export"
WEB_EXPORT_PATH="$EXPORT_PATH/web"
ZIP_PATH="$EXPORT_PATH/scrap-ascent-web.zip"

# Limpiar directorio de export
echo "Limpiando directorio de export..."
if [ -d "$EXPORT_PATH" ]; then
    rm -rf "$EXPORT_PATH"
fi
mkdir -p "$EXPORT_PATH"
mkdir -p "$WEB_EXPORT_PATH"

# Verificar si Godot esta disponible
echo "Verificando Godot..."

GODOT_CMD=""

# Primero intentar desde PATH
if command -v godot &> /dev/null; then
    GODOT_CMD="godot"
elif command -v Godot &> /dev/null; then
    GODOT_CMD="Godot"
# Buscar en el directorio del proyecto
elif [ -f "$PROJECT_PATH/godot" ]; then
    GODOT_CMD="$PROJECT_PATH/godot"
elif [ -f "$PROJECT_PATH/Godot" ]; then
    GODOT_CMD="$PROJECT_PATH/Godot"
# Buscar en Applications
elif [ -f "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT_CMD="/Applications/Godot.app/Contents/MacOS/Godot"
# Buscar en Downloads
elif [ -f "$HOME/Downloads/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT_CMD="$HOME/Downloads/Godot.app/Contents/MacOS/Godot"
# Buscar en el escritorio
elif [ -f "$HOME/Desktop/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT_CMD="$HOME/Desktop/Godot.app/Contents/MacOS/Godot"
# Buscar archivos que empiecen con "Godot" en el escritorio
elif ls "$HOME/Desktop/Godot"*.app/Contents/MacOS/Godot 2>/dev/null | head -1; then
    GODOT_CMD=$(ls "$HOME/Desktop/Godot"*.app/Contents/MacOS/Godot 2>/dev/null | head -1)
fi

# Si no se encuentra Godot
if [ -z "$GODOT_CMD" ]; then
    echo "ERROR: Godot no encontrado"
    echo "Busque en las siguientes ubicaciones:"
    echo "- En PATH del sistema"
    echo "- En el directorio del proyecto: $PROJECT_PATH"
    echo "- En Applications: /Applications/Godot.app"
    echo "- En Downloads: $HOME/Downloads/"
    echo "- En el escritorio: $HOME/Desktop/"
    echo ""
    echo "Solucion:"
    echo "1. Copia godot a este directorio: $PROJECT_PATH"
    echo "2. O agrega Godot al PATH del sistema"
    echo "3. O asegurate de que este en Applications o el escritorio"
    echo ""
    read -p "Presiona Enter para continuar..."
    exit 1
fi

echo "Godot encontrado: $GODOT_CMD"

# Exportar el juego
echo ""
echo "Compilando juego para Web..."
"$GODOT_CMD" --headless --export-release "Web" "$WEB_EXPORT_PATH/index.html"

if [ $? -ne 0 ]; then
    echo "ERROR: Fallo la compilacion"
    read -p "Presiona Enter para continuar..."
    exit 1
fi

# Verificar archivos exportados
echo ""
echo "Verificando archivos exportados..."
FILES_OK=1

if [ ! -f "$WEB_EXPORT_PATH/index.html" ]; then
    echo "ERROR: index.html no encontrado"
    FILES_OK=0
fi

if [ ! -f "$WEB_EXPORT_PATH/index.js" ]; then
    echo "ERROR: index.js no encontrado"
    FILES_OK=0
fi

if [ ! -f "$WEB_EXPORT_PATH/index.wasm" ]; then
    echo "ERROR: index.wasm no encontrado"
    FILES_OK=0
fi

if [ ! -f "$WEB_EXPORT_PATH/index.pck" ]; then
    echo "ERROR: index.pck no encontrado"
    FILES_OK=0
fi

if [ $FILES_OK -eq 0 ]; then
    echo "ERROR: Faltan archivos necesarios"
    read -p "Presiona Enter para continuar..."
    exit 1
fi

# Crear ZIP
echo ""
echo "Creando archivo ZIP..."
cd "$WEB_EXPORT_PATH"
zip -r "$ZIP_PATH" *
cd "$PROJECT_PATH"

if [ $? -ne 0 ]; then
    echo "ERROR: Fallo la creacion del ZIP"
    read -p "Presiona Enter para continuar..."
    exit 1
fi

# Mostrar resumen
echo ""
echo "========================================"
echo "   BUILD COMPLETADO EXITOSAMENTE"
echo "========================================"
echo ""
echo "Archivos exportados en: $WEB_EXPORT_PATH"
echo "Archivo ZIP creado: $ZIP_PATH"
echo ""
echo "Para subir a itch.io:"
echo "1. Ve a tu pagina de juego en itch.io"
echo "2. Sube el contenido de la carpeta: $WEB_EXPORT_PATH"
echo "3. O sube el archivo ZIP: $ZIP_PATH"
echo "4. Asegurate de que index.html este en la raiz"
echo ""
echo "========================================"

# Abrir carpeta de export
echo "Abriendo carpeta de export..."
open "$EXPORT_PATH"

read -p "Presiona Enter para continuar..."
