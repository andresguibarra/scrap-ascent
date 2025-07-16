@echo off
echo.
echo ========================================
echo   SCRAP ASCENT - BUILD SCRIPT
echo ========================================
echo.

:: Configuracion
set PROJECT_PATH=%~dp0
set EXPORT_PATH=%PROJECT_PATH%export
set WEB_EXPORT_PATH=%EXPORT_PATH%\web
set ZIP_PATH=%EXPORT_PATH%\scrap-ascent-web.zip

:: Limpiar directorio de export
echo Limpiando directorio de export...
if exist "%EXPORT_PATH%" rmdir /s /q "%EXPORT_PATH%"
mkdir "%EXPORT_PATH%"
mkdir "%WEB_EXPORT_PATH%"

:: Verificar si Godot esta disponible
echo Verificando Godot...

:: Primero intentar desde PATH
godot --version >nul 2>&1
if %errorlevel% equ 0 (
    set GODOT_CMD=godot
    goto :godot_found
)

:: Buscar en el directorio del proyecto
if exist "%PROJECT_PATH%godot.exe" (
    set GODOT_CMD="%PROJECT_PATH%godot.exe"
    goto :godot_found
)

:: Buscar en el escritorio
if exist "%USERPROFILE%\Desktop\godot.exe" (
    set GODOT_CMD="%USERPROFILE%\Desktop\godot.exe"
    goto :godot_found
)

:: Buscar en el escritorio con diferentes nombres
if exist "%USERPROFILE%\Desktop\Godot.exe" (
    set GODOT_CMD="%USERPROFILE%\Desktop\Godot.exe"
    goto :godot_found
)

if exist "%USERPROFILE%\Desktop\Godot_v4.4-stable_win64.exe" (
    set GODOT_CMD="%USERPROFILE%\Desktop\Godot_v4.4-stable_win64.exe"
    goto :godot_found
)

:: Buscar archivos que empiecen con "Godot" en el escritorio
for %%f in ("%USERPROFILE%\Desktop\Godot*.exe") do (
    if exist "%%f" (
        set GODOT_CMD="%%f"
        goto :godot_found
    )
)

:: Si no se encuentra Godot
echo ERROR: Godot no encontrado
echo Busque en las siguientes ubicaciones:
echo - En PATH del sistema
echo - En el directorio del proyecto: %PROJECT_PATH%
echo - En el escritorio: %USERPROFILE%\Desktop\
echo.
echo Solucion:
echo 1. Copia godot.exe a este directorio: %PROJECT_PATH%
echo 2. O agrega Godot al PATH del sistema
echo 3. O asegurate de que este en el escritorio
pause
exit /b 1

:godot_found
echo Godot encontrado: %GODOT_CMD%

:: Exportar el juego
echo.
echo Compilando juego para Web...
%GODOT_CMD% --headless --export-release "Web" "%WEB_EXPORT_PATH%\index.html"

if %errorlevel% neq 0 (
    echo ERROR: Fallo la compilacion
    pause
    exit /b 1
)

:: Verificar archivos exportados
echo.
echo Verificando archivos exportados...
set FILES_OK=1

if not exist "%WEB_EXPORT_PATH%\index.html" (
    echo ERROR: index.html no encontrado
    set FILES_OK=0
)

if not exist "%WEB_EXPORT_PATH%\index.js" (
    echo ERROR: index.js no encontrado
    set FILES_OK=0
)

if not exist "%WEB_EXPORT_PATH%\index.wasm" (
    echo ERROR: index.wasm no encontrado
    set FILES_OK=0
)

if not exist "%WEB_EXPORT_PATH%\index.pck" (
    echo ERROR: index.pck no encontrado
    set FILES_OK=0
)

if %FILES_OK% equ 0 (
    echo ERROR: Faltan archivos necesarios
    pause
    exit /b 1
)

:: Crear ZIP usando PowerShell
echo.
echo Creando archivo ZIP...
powershell -Command "Compress-Archive -Path '%WEB_EXPORT_PATH%\*' -DestinationPath '%ZIP_PATH%' -Force"

if %errorlevel% neq 0 (
    echo ERROR: Fallo la creacion del ZIP
    pause
    exit /b 1
)

:: Mostrar resumen
echo.
echo ========================================
echo   BUILD COMPLETADO EXITOSAMENTE
echo ========================================
echo.
echo Archivos exportados en: %WEB_EXPORT_PATH%
echo Archivo ZIP creado: %ZIP_PATH%
echo.
echo Para subir a itch.io:
echo 1. Ve a tu pagina de juego en itch.io
echo 2. Sube el contenido de la carpeta: %WEB_EXPORT_PATH%
echo 3. O sube el archivo ZIP: %ZIP_PATH%
echo 4. Asegurate de que index.html este en la raiz
echo.
echo ========================================

:: Abrir carpeta de export
echo Abriendo carpeta de export...
start "" "%EXPORT_PATH%"

pause
