@echo off
setlocal

rem Resolve script directory without trailing backslash
for %%I in ("%~dp0.") do set "SCRIPT_DIR=%%~fI"
set "TARGET=%SCRIPT_DIR%\git+manegment.bat"

if not exist "%TARGET%" (
  echo Error: Missing upgraded manager: %TARGET%
  echo Please make sure git+manegment.bat is located in the same folder as git.bat.
  pause
  exit /b 1
)

call "%TARGET%" %*
set "EXIT_CODE=%ERRORLEVEL%"
if "%~1"=="" if %EXIT_CODE% neq 0 (
  echo.
  echo Process exited with code %EXIT_CODE%.
  pause
)
exit /b %EXIT_CODE%
