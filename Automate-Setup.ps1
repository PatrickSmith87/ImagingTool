##############################################################################
##############################################################################
###                                                                        ###
###                          -=[ Script Setup ]=-                          ###
###                                                                        ###
##############################################################################
##############################################################################
#region Initialize
#Import-Module Automate-Setup -WarningAction SilentlyContinue -Force
#Import-Module Configure-PC -WarningAction SilentlyContinue -Force
#Import-Module Install-Software -WarningAction SilentlyContinue -Force
#Clear-Host

$ComputerName = Hostname
$ClientSettings = $null
$Automated_Setup = $true
$string = "string at script"
#endregion Initialize

#region Functions
function Start-Build_Image {
############################################
##     -=[ SOFTWARE INSTALLATIONS ]=-     ##
############################################
    Install-Image_Softwares

#####################################
##     -=[ PRE-Image Tasks ]=-     ##
#####################################
    Standard-Checks
    Transfer-RMM_Agent
    Transfer-Sophos_Agent
    Sign-Into_VPN

#############################
##     -=[ UPDATES ]=-     ##
#############################
    Update-PC -RebootAllowed

###################################
##     -=[ Capture Image ]=-     ##
###################################
    CheckPoint-Capture_Image
    
######################################
##     -=[ POST-Image Tasks ]=-     ##
######################################
    Write-Host "`n-=[ POST-Image Tasks ]=-" -ForegroundColor DarkGray
    Set-ClockTimeZone
    Reset-Clock
    Rename-PC -PostImage
    Install-RMM_Agent
    Install-AV_Agent
    CheckPoint-Bitlocker_Device
    Activate-Windows
    ReUpdate-PC -RebootAllowed
    Join-Domain
}

function Start-Single_Setup {
############################################
##     -=[ SOFTWARE INSTALLATIONS ]=-     ##
############################################    
    Transfer-RMM_Agent
    Transfer-Sophos_Agent
    Install-RMM_Agent
    Install-AV_Agent #CheckPoint-Client_AV # Moved to start of Start-Single_Setup because installation issues happen if AV is pushed through RMM agent while PC is busy installing other softwares or reboots while AV is still trying to install
    Install-Image_Softwares

#####################################
##     -=[ Standard Checks ]=-     ##
#####################################
    Standard-Checks
    CheckPoint-Bitlocker_Device
    Activate-Windows # NOT YET TESTED.. Does NOT seem to work on my PC but that may be because it is already activated...

#############################
##     -=[ UPDATES ]=-     ##
#############################
    Update-PC -RebootAllowed
}
#endregion Functions

#region Script Body
#############################################################################
#############################################################################
###                                                                       ###
###                          -=[ Script Body ]=-                          ###
###                                                                       ###
#############################################################################
#############################################################################
Write-Host "-=[ INITIALIZING SCRIPT ]=-" -ForegroundColor DarkGray
Write-Host "Computername: " -NoNewline; Write-Host "$ComputerName" -ForegroundColor Cyan
Write-Host "Manufacturer: " -NoNewline; Write-Host (Get-Manufacturer) -ForegroundColor Cyan
Write-Host "Model: " -NoNewline; Write-Host (Get-Model) -ForegroundColor Cyan
Write-Host ">Starting Automated Setup...`n" -ForegroundColor Yellow

# Make sure Automated-Setup script continues on next log-on
Start-AutomatedSetup_AtLogon
# If Exists, remove Start-AutomatedSetup-RAA.bat from Public Desktop
Remove-StartAutomatedSetup_BatchFile
# -=[ Update Automated Setup Scripts ]=-
Update-TechTool
# -=[ LOAD CLIENT SETTINGS ]=-
Write-Host "`n-=[ LOAD CLIENT SETTINGS ]=-" -ForegroundColor DarkGray
Get-ClientSettings
#####################################
##     -=[ SYSTEM SETTINGS ]=-     ##
#####################################
Write-Host "-=[ INITIALIZE DEFAULT SYSTEM SETTINGS ]=-" -ForegroundColor DarkGray
# -=[ Set PC Default Settings ]=-
Set-PCDefaultSettings
# -=[ Setup Local Admin ]=-
Setup-LocalAdmin
# -=[ Determine if tech is setting up a single PC or building an image for capture ]=-
Determine-SetupType
# -=[ Set Profile Default Settings ]=-
Set-ProfileDefaultSettings -AdminProfile
# -=[ Rename PC\Image ]=-
Rename-PC -PreImage
# -=[ Start Updates In Background ]
Start-Process powershell -ArgumentList '-command Update-PC' -WindowStyle Minimized

If ($ClientSettings.SetupType -eq "BuildImage") {
    Start-Build_Image
} elseif ($ClientSettings.SetupType -eq "SingleSetup") {
    Start-Single_Setup
}


########################################
##     -=[ User Profile Setup ]=-     ##
########################################
Start-UserProfileSetup

#############################
##     -=[ Cleanup ]=-     ##
#############################
Cleanup-AutomatedSetup

####################################
##     -=[ Exiting Script ]=-     ##
####################################
Write-Host "`nEnd of Script" -ForegroundColor Red
Write-Host "Close this window at will" -ForegroundColor Yellow
PAUSE
EXIT

<#
These need to be added to the script
    Install-Skype (Not Skype for Business)
    Install-VLC Media Player
#>

#endregion Script Body