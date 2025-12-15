@echo off
setlocal enabledelayedexpansion

REM ***********************************************************
REM   Script de mise à jour de fichiers
REM   Permettre la mise à jour de tous les fichiers du même nom
REM   à partir d'un fichier modèle
REM ***********************************************************


REM Vérifier que deux paramètres sont fournis :
REM   1. Le chemin complet du fichier source.
REM   2. Le chemin de l'arborescence (répertoire racine) à parcourir.
if "%~1"=="" (
    echo Utilisation : %~nx0 "chemin_complet_du_fichier_source" "chemin_de_l_arborescence"
    goto :eof
)
if "%~2"=="" (
    echo Utilisation : %~nx0 "chemin_complet_du_fichier_source" "chemin_de_l_arborescence"
    goto :eof
)

set "source=%~1"
set "root=%~2"

REM Vérifier que le fichier source existe
if not exist "%source%" (
    echo Le fichier source "%source%" n'existe pas.
    goto :eof
)

REM Extraire le nom du fichier (nom + extension)
for %%F in ("%source%") do set "filename=%%~nxF"

echo Mise à jour de tous les fichiers "%filename%" existants dans l'arborescence "%root%"
echo.

REM Parcourir récursivement l'arborescence pour traiter uniquement les fichiers existants
for /R "%root%" %%F in ("%filename%") do (
    REM Éviter de traiter le fichier source lui-même
    if /I not "%%~fF"=="%source%" (
        REM Vérifier que le fichier existe réellement (sinon, for /R peut renvoyer un nom construit à partir de la racine du sous-répertoire)
        if exist "%%~fF" (
            echo Traitement de "%%~fF"
            REM Créer une copie de sauvegarde de l'ancienne version en ajoutant .bak
            copy /Y "%%~fF" "%%~fF.bak" >nul
            REM Mettre à jour le fichier avec la version source
            copy /Y "%source%" "%%~fF" >nul
        )
    )
)

echo.
echo Mise à jour terminee.
endlocal
