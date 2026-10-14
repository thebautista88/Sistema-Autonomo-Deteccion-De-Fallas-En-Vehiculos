@echo off
title Sistema Experto de Diagnóstico Automotriz - CLIPS Puro
chcp 65001 >nul
echo ======================================================================
echo    PROYECTO 7: DIAGNÓSTICO DE PROBLEMAS DE UN AUTOMÓVIL (CLIPS PURO)
echo ======================================================================
echo.
echo Seleccione el modo de ejecución:
echo   [1] Iniciar Diagnóstico Asistido Interactivo (CLIPS)
echo   [2] Ejecutar Suite de 6 Casos de Prueba Automatizados (CLIPS)
echo   [3] Abrir Consola Oficial de CLIPS (Prompt libre)
echo   [4] Salir
echo.
set /p modo="Elija una opción (1-4): "

if "%modo%"=="1" (
    echo.
    echo ======================================================================
    echo Iniciando Asistente de Diagnóstico en CLIPS...
    echo ======================================================================
    echo.
    clips -f iniciar_consola.clips
) else if "%modo%"=="2" (
    echo.
    echo ======================================================================
    echo Ejecutando Casos de Prueba Automatizados en CLIPS...
    echo ======================================================================
    echo.
    clips -f ejecutar_pruebas.clips
    pause
) else if "%modo%"=="3" (
    echo Iniciando consola de CLIPS...
    clips
) else if "%modo%"=="4" (
    exit /b
) else (
    echo Opción inválida.
    pause
)
