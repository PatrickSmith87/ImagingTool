##############################################################################
##############################################################################
###                                                                        ###
###                          -=[ Script Setup ]=-                          ###
###                                                                        ###
##############################################################################
##############################################################################
using module Configure-PC
using module Automate-Setup
Import-Module Automate-Setup -WarningAction SilentlyContinue -Force
Import-Module Configure-PC -WarningAction SilentlyContinue -Force
Import-Module Install-Software -WarningAction SilentlyContinue -Force
Clear-Host

######################################
##  STATIC Variables - Do not edit  ##
######################################
  $RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" # This is the registry key that points to what script(s) to run when a user logs in
  $FilePath_Local_AutomateSetup_Script = "C:\Setup\_Automated_Setup\Automate-Setup.ps1"
  $ComputerName = Hostname
  $ClientSettings = $null

################################################
##  CUSTOMIZABLE Variables - Edit as desired  ##
################################################
  # These variables should be set to $null normally
  # They are defined in the modules and will default to those values unless specified here
  # NOTE that if the Automated-Setup script is 

# -=[ Configure-PC related variables ]=-
  $Target_TimeZone     = $null # Default is "Central Standard Time"
  # Hibernate & Hiberboot settings: 0=disabled, 1=enabled
  $Hibernate_Setting   = $null # Default is 0
  $Hiberboot_Setting   = $null # Default is 0
  # Power Settings
  $AC_Monitor_Timeout  = $null # Default is 15
                     # = 20 # HGA
  $AC_Standby_Timeout  = $null # Default is 0
  $DC_Monitor_Timeout  = $null # Default is 10
                     # = 20 # HGA
  $DC_Standby_Timeout  = $null # Default is 20
                     # = 30 # HGA
  # Close lid actions... 0=Do Nothing, 1=Sleep, 2=Hibernate, 3=Shut Down.
  $AC_Close_Lid_Action = $null # Default is 0
  $DC_Close_Lid_Action = $null # Default is 1

function Build-Image {
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
    CheckPoint-DriverUpdates
    Install-Windows_Updates

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
    Reinstall-SupportAssistant
    Install-AV_Agent
    CheckPoint-Bitlocker_Device
    Activate-Windows
    Join-Domain
}

function Single-Setup {
############################################
##     -=[ SOFTWARE INSTALLATIONS ]=-     ##
############################################    
    Transfer-RMM_Agent
    Transfer-Sophos_Agent
    Install-RMM_Agent
    Install-AV_Agent #CheckPoint-Client_AV # Moved to start of Single-Setup because installation issues happen if AV is pushed through RMM agent while PC is busy installing other softwares or reboots while AV is still trying to install
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
    CheckPoint-DriverUpdates
    Install-Windows_Updates
}

#############################################################################
#############################################################################
###                                                                       ###
###                          -=[ Script Body ]=-                          ###
###                                                                       ###
#############################################################################
#############################################################################
Write-Host "-=[ INITIALIZING SCRIPT ]=-" -ForegroundColor DarkGray
# Make sure Automated-Setup script continues on next log-on
Start-AutomatedSetup_AtLogon
# If Exists, remove Start-AutomatedSetup-RAA.bat from Public Desktop
Remove-StartAutomatedSetup_BatchFile
Write-Host "Computername: " -NoNewline; Write-Host "$ComputerName" -ForegroundColor Cyan
Write-Host ">Starting Automated Setup...`n" -ForegroundColor Yellow
# -=[ LOAD CLIENT SETTINGS ]=-
Write-Host "-=[ LOAD CLIENT SETTINGS ]=-" -ForegroundColor DarkGray
Get-ClientSettings
#####################################
##     -=[ SYSTEM SETTINGS ]=-     ##
#####################################
Write-Host "-=[ INITIALIZE DEFAULT SYSTEM SETTINGS ]=-" -ForegroundColor DarkGray
# -=[ Set PC Default Settings ]=-
Set-PCDefaultSettings
# -=[ Setup Local Admin ]=-
Setup-LocalAdmin
# -=[ Set Profile Default Settings ]=-
Set-ProfileDefaultSettings
# -=[ Update Automated Setup Scripts ]=-
$Update = [Update]::new(); $Update.Scripts()
# -=[ Determine if tech is setting up a single PC or building an image for capture ]=-
Determine-SetupType
# -=[ Rename PC\Image ]=-
Rename-PC -PreImage

If ($ClientSettings.SetupType -eq "BuildImage") {
    Build-Image
} elseif ($ClientSettings.SetupType -eq "SingleSetup") {
    Single-Setup
}

########################################
##     -=[ User Profile Setup ]=-     ##
########################################
<#

# -=[ User Profile Setup ]=-
Write-Host "-=[ User Profile Setup ]=-" -ForegroundColor DarkGray

Login-User
    check for complete file
        If not already noted, should take note of the currently logged on user. 
        When script runs again (After loging in as new user [ideally], or if just signs into same account), it will compare usernames again and if it is different, continues to next step
            log completion

Migrate-User_Profile_Data
    check for complete file
        Should run the migrate user script
            log completion

Configure-Profile
    This will likely call several other functions to:
        enable RDP and add user\group to allowed list?
        make user a local admin...
        Configure redirected profiles?

Install-Profile_Specific_Software
    This will likely call several other functions to:
        Install-DropBox
        Install-OneNote (Is this actually profile specific? If not, needs added to script during PC Imaging)

#>

#############################
##     -=[ Cleanup ]=-     ##
#############################
Cleanup-AutomatedSetup

####################################
##     -=[ Exiting Script ]=-     ##
####################################
Write-Host ""
Write-Host "End of Script" -ForegroundColor Red
Write-Host "Close this window at will" -ForegroundColor Yellow
PAUSE
EXIT

<#

These need to be added to the script
    Install-Skype (Not Skype for Business)
    Install-VLC Media Player
    Install-Citrix ShareFile
#>