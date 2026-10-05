@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_android_local.ps1" %*
endlocal
