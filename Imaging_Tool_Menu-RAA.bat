@ECHO Off
ECHO[
ECHO Loading Imaging Tool...
ECHO[
powershell -command "& {Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force}"
PowerShell.exe -command "%~dp0sources\Menu.ps1"
powershell -command "& {Set-ExecutionPolicy -ExecutionPolicy Undefined -Force}"