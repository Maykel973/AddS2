@echo off
setlocal enabledelayedexpansion
title Desbloqueador de Seguridad - Z1

echo ============================================
echo    DESBLOQUEADOR DE SEGURIDAD (Z1)
echo ============================================
echo.

:: Verificar permisos de Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] ERROR: Debes ejecutar este script como ADMINISTRADOR.
    echo Haz clic derecho y selecciona "Ejecutar como administrador".
    pause
    exit /b
)

:: Buscar ruta de Steam
set "STEAM_PATH="
for /f "tokens=2*" %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam" /v "InstallPath" 2^>nul') do set "STEAM_PATH=%%B"
if not defined STEAM_PATH (
    for /f "tokens=2*" %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Valve\Steam" /v "InstallPath" 2^>nul') do set "STEAM_PATH=%%B"
)

if not defined STEAM_PATH (
    echo [X] No se pudo encontrar Steam en el registro.
    set /p "STEAM_PATH=Introduce la ruta manual de Steam (ej: C:\Steam): "
)

if not exist "!STEAM_PATH!" (
    echo [X] La ruta no es valida.
    pause
    exit /b
)

set "DEPOTCACHE=!STEAM_PATH!\depotcache"

echo [*] Steam detectado en: !STEAM_PATH!
echo [*] Desbloqueando carpeta: !DEPOTCACHE!
echo.

:: 1. Quitar atributo de Solo Lectura a todos los archivos
echo [+] Quitando atributos de Solo Lectura...
attrib -r "!DEPOTCACHE!\*.*" /s /d >nul 2>&1

:: 2. Quitar bloqueos de icacls (Deny Everyone)
echo [+] Eliminando candados de seguridad (icacls)...
icacls "!DEPOTCACHE!" /remove:d *S-1-1-0 /t /c >nul 2>&1

:: 3. Dar control total al usuario actual para borrar
echo [+] Restaurando permisos de acceso...
icacls "!DEPOTCACHE!" /grant %username%:(F) /t /c >nul 2>&1

echo.
echo ============================================
echo    ¡LISTO! La carpeta ha sido desbloqueada.
echo    Ya puedes borrarla manualmente.
echo ============================================
pause
