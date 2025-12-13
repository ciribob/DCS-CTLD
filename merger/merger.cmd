@echo off
setlocal enabledelayedexpansion

@REM merges all the files listed in "listToMerge.txt" coming from ../source into a single file
@REM --------------------------------------------------------------------

@REM dossier du script /merger
set "MERGER_DIR=%~dp0"

@REM dossier parent
for %%A in ("%MERGER_DIR%..") do set "PARENT_DIR=%%~fA"

@REM dossier source (frère de merger)
set "SOURCE_DIR=%PARENT_DIR%\source"

@REM chemins de la liste et du fichier de sortie
set "LIST=%MERGER_DIR%listToMerge.txt"
set "OUT=%PARENT_DIR%\CTLD.lua"

if not exist "%LIST%" (
    echo [ERREUR] %LIST% introuvable.
    pause
    exit /b
)

echo. > "%OUT%"

for /f "usebackq delims=" %%F in ("%LIST%") do (
    set "FILE=%SOURCE_DIR%\%%F"
    if not exist "!FILE!" (
        echo [AVERTISSEMENT] Fichier %%F introuvable dans %SOURCE_DIR%.
    ) else (
        echo -- ==================================================================================================== >> "%OUT%"
        echo -- Start : %%F >> "%OUT%"
        type "!FILE!" >> "%OUT%"
        @REM echo.>>"%OUT%"
        echo -- End : %%F >> "%OUT%"
        @REM  echo -- ==================================================================================================== >> "%OUT%"
        @REM echo.>>"%OUT%"
    )
)

echo Fichier fusionne genere : "%OUT%"
pause
