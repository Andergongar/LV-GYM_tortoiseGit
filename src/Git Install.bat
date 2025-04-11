@ECHO OFF

REM cspell:ignore SETLOCAL
SETLOCAL EnableDelayedExpansion
REM Ingresar Usuario.
SET /P ^
  "User=Ingresa tu usuario: "
SET /P ^
  "Email=Ingresa tu correo: "
ECHO.

ECHO Downloading pre-requisite script...
SET RefreshEnvURL=https://raw.githubusercontent.com/chocolatey/choco/2.4.3/src/chocolatey.resources/redirects/RefreshEnv.cmd
powershell ^
  -command ^
  "Invoke-WebRequest "%RefreshEnvURL%" -OutFile $env:TEMP/RefreshEnv.cmd"
ECHO.

REM Instalar Git
ECHO Instalando Git
CALL :WingetInstall Git.Git
ECHO Preparando Git...
git config --global user.name %User%
git config --global user.email %Email%

REM Installar Git
ECHO Instalando GitHub CLI...
CALL :WingetInstall GitHub.cli
gh auth login --git-protocol https --web
ECHO.

SET /P Choice=Instalar GIT? (Y/N): 
SET Choice=%Choice:~0,1%
SET Choice=%Choice: =%
IF /I "%Choice%"=="Y" (
    GOTO TortoiseGit
    
) ELSE (
    ECHO Tortoise no fue instalado.
    GOTO ALIR
)

:TortoiseGit
:TortoiseGit

REM Instalar y preparar tortoise.
ECHO Instalando tortoise
CALL :WingetInstall TortoiseGit.TortoiseGit
ECHO preparando tortoise...
SET "LVCompare=C:\Program Files (x86)\National Instruments\Shared\LabVIEW Compare\LVCompare.exe"
SET "LVCompare64=C:\Program Files\National Instruments\Shared\LabVIEW Compare\LVCompare.exe"
SET "LVMerge=C:\Program Files (x86)\National Instruments\Shared\LabVIEW Merge\LVMerge.exe"
SET "LVMerge64=C:\Program Files\National Instruments\Shared\LabVIEW Merge\LVMerge.exe"

IF EXIST "%LVCompare%" (
    ECHO Setting LV DIFF Tools for 32 Bits
) ELSE (
    IF EXIST "%LVCompare64%" (
        ECHO Setting LV DIFF Tools for 64 Bits
        SET "LVCompare=%LVCompare64%"
        SET "LVMerge=%LVMerge64%"
    ) ELSE (
        ECHO NO LabVIEW DIFF Tools detected 
        GOTO SALIR
    )
)

ECHO Configurando .vi .vitt .vit .ctt...
SET "DiffArgs=%%base %%mine -nobdcosm -nobdpos"
SET "MergeArgs=%%base %%theirs %%mine %%merged"
REG ADD "HKEY_CURRENT_USER\SOFTWARE\TortoiseGit\DiffTools" /V .vi /t REG_SZ /D "\"%LVCompare%\" %DiffArgs%" /F
REG ADD "HKEY_CURRENT_USER\SOFTWARE\TortoiseGit\DiffTools" /V .vit /t REG_SZ /D "\"%LVCompare%\" %DiffArgs%" /F
REG ADD "HKEY_CURRENT_USER\SOFTWARE\TortoiseGit\DiffTools" /V .ctl /t REG_SZ /D "\"%LVCompare%\" %DiffArgs%" /F
REG ADD "HKEY_CURRENT_USER\SOFTWARE\TortoiseGit\DiffTools" /V .ctt /t REG_SZ /D "\"%LVCompare%\" %DiffArgs%" /F
REG ADD "HKEY_CURRENT_USER\SOFTWARE\TortoiseGit\MergeTools" /V .vi /t REG_SZ /D "\"%LVMerge%\" %MergeArgs%" /F
REG ADD "HKEY_CURRENT_USER\SOFTWARE\TortoiseGit\MergeTools" /V .vit /t REG_SZ /D "\"%LVMerge%\" %MergeArgs%" /F
REG ADD "HKEY_CURRENT_USER\SOFTWARE\TortoiseGit\MergeTools" /V .ctl /t REG_SZ /D "\"%LVMerge%\" %MergeArgs%" /F
REG ADD "HKEY_CURRENT_USER\SOFTWARE\TortoiseGit\MergeTools" /V .ctt /t REG_SZ /D "\"%LVMerge%\" %MergeArgs%" /F
ECHO.

:WingetInstall
:WingetInstall
winget install ^
  --disable-interactivity ^
  --accept-package-agreements ^
  --accept-source-agreements ^
  --exact ^
  --id %~1
CALL "%TEMP%/RefreshEnv.cmd"
ECHO.

:SALIR
:SALIR
EXIT /B 0
