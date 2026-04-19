@echo off
setlocal enabledelayedexpansion

REM *******************************************************************
REM   Script de mise a jour de repertoires v7 (Correction finale)
REM *******************************************************************

REM --- Verification des arguments ---
if "%~1"=="" goto usage
if "%~2"=="" goto usage
goto start

:usage
echo.
echo Utilisation : %~nx0 "chemin_du_repertoire_modele" "chemin_de_l_arborescence_a_parcourir"
echo.
goto :eof

:start
REM --- Assignation et validation des chemins ---
set "source_dir=%~f1"
set "root_dir=%~f2"

if not exist "%source_dir%\" (
    echo ERREUR: Le repertoire modele "%source_dir%" n'existe pas.
    goto :eof
)
if not exist "%root_dir%\" (
    echo ERREUR: Le repertoire racine de recherche "%root_dir%" n'existe pas.
    goto :eof
)

REM --- Extraction du nom du repertoire a chercher ---
for %%I in ("%source_dir%") do set "target_name=%%~nxI"

echo.
echo =============================================================
echo Mise a jour des repertoires nommes : "!target_name!"
echo Dans l'arborescence de : "!root_dir!"
echo En utilisant le modele : "!source_dir!"
echo =============================================================
echo.

REM --- Boucle principale (Version Robuste avec DIR et FINDSTR) ---
for /f "delims=" %%D in ('dir /s /b /ad "!root_dir!" ^| findstr /i /e /c:"\\!target_name!"') do (
    set "full_path=%%~fD"
    if /I not "!full_path!"=="!source_dir!" (
        echo Traitement de "!full_path!"
        
        if exist "!full_path!.bak\" (
            REM LA CORRECTION EST ICI : Le ')' est echappe avec un '^'
            echo  - Suppression de l'ancienne sauvegarde (.bak^)...
            rmdir /s /q "!full_path!.bak"
        )
        
        echo  - Sauvegarde de l'ancien repertoire en ".bak"...
        ren "!full_path!" "%%~nxD.bak"
        
        echo  - Copie du nouveau contenu depuis le modele...
        xcopy "!source_dir!" "!full_path!\" /E /I /Y /Q >nul
        echo.
    ) else (
        echo Le repertoire trouve est le modele lui-meme, il est ignore.
        echo.
    )
)

echo Mise a jour terminee.
endlocal
goto :eof