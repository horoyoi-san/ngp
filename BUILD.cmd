@echo off
setlocal EnableExtensions
cd /d "%~dp0"

if not defined ProgramFiles set "ProgramFiles=C:\Program Files"
if not defined "ProgramFiles(x86)" set "ProgramFiles(x86)=C:\Program Files (x86)"
if not defined CommonProgramFiles set "CommonProgramFiles=C:\Program Files\Common Files"
if not defined "CommonProgramFiles(x86)" set "CommonProgramFiles(x86)=C:\Program Files (x86)\Common Files"
if not defined APPDATA set "APPDATA=%USERPROFILE%\AppData\Roaming"

set "NUGET_PACKAGES=%USERPROFILE%\.nuget\packages"

echo [1/2] restore ...
dotnet restore "%~dp0Ananta.Server\Ananta.App\Ananta.App.csproj" --nologo
if errorlevel 1 goto :fail

echo [2/2] build ...
dotnet build "%~dp0Ananta.Server\Ananta.App\Ananta.App.csproj" --no-restore -v q --nologo
if errorlevel 1 goto :fail

echo [OK] build succeeded
exit /b 0

:fail
echo [ERROR] build failed
exit /b 1
