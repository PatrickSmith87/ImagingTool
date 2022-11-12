@ECHO Off
ECHO[
ECHO Loading Tech Tool...
ECHO[
powershell -command "& {Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force}"
PowerShell.exe -command "%~dp0sources\TechTool.ps1"
powershell -command "& {Set-ExecutionPolicy -ExecutionPolicy Undefined -Force}"