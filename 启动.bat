@echo off
setlocal
cd /d "%~dp0"
set "URL=http://127.0.0.1:8813/particles.html"

rem -- already running? just open the browser --
powershell -NoProfile -ExecutionPolicy Bypass -Command "try{Invoke-WebRequest '%URL%' -UseBasicParsing -TimeoutSec 2 | Out-Null; exit 0}catch{exit 1}"
if not errorlevel 1 (
  start "" "%URL%"
  exit /b 0
)

rem -- locate Node.js: PATH -> common install dirs -> DSH runtime --
set "NODE_EXE="
for %%I in (node.exe) do if not "%%~$PATH:I"=="" set "NODE_EXE=%%~$PATH:I"
if not defined NODE_EXE if exist "%ProgramFiles%\nodejs\node.exe" set "NODE_EXE=%ProgramFiles%\nodejs\node.exe"
if not defined NODE_EXE if exist "%ProgramFiles(x86)%\nodejs\node.exe" set "NODE_EXE=%ProgramFiles(x86)%\nodejs\node.exe"
if not defined NODE_EXE if exist "%LOCALAPPDATA%\Programs\nodejs\node.exe" set "NODE_EXE=%LOCALAPPDATA%\Programs\nodejs\node.exe"
if not defined NODE_EXE if exist "%USERPROFILE%\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\node\bin\node.exe" set "NODE_EXE=%USERPROFILE%\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\node\bin\node.exe"
if not defined NODE_EXE if exist "C:\Users\Administrator\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\node\bin\node.exe" set "NODE_EXE=C:\Users\Administrator\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\node\bin\node.exe"

if not defined NODE_EXE (
  echo [X] Node.js not found.
  echo     Install Node.js, or open particles.html directly ^(gestures then use the online model^).
  pause
  exit /b 1
)

echo Starting Particle Starfire local server...
start "Particle Starfire Server" /min "%NODE_EXE%" "%~dp0server.js"

for /l %%i in (1,1,15) do (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "try{Invoke-WebRequest '%URL%' -UseBasicParsing -TimeoutSec 1 | Out-Null; exit 0}catch{exit 1}"
  if not errorlevel 1 goto :open
  timeout /t 1 >nul
)

echo [X] Server did not start within 15s. Port 8813 may be in use.
echo     Try running "node server.js" in this folder to see the error.
pause
exit /b 1

:open
start "" "%URL%"
exit /b 0
