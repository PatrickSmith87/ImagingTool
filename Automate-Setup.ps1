##############################################################################
##############################################################################
###                                                                        ###
###                          -=[ Script Setup ]=-                          ###
###                                                                        ###
##############################################################################
##############################################################################
#region Initialize
Import-Module Automate-Setup -WarningAction SilentlyContinue -Force
Import-Module Configure-PC -WarningAction SilentlyContinue -Force
Import-Module Install-Software -WarningAction SilentlyContinue -Force
#Clear-Host

$TechTool = New-TechTool
$USB = New-ImagingUSB
$ComputerName = Hostname
$ClientSettings = $null
$Automated_Setup = $true
  
#endregion Initialize

#region Functions
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
    Install-Windows_Updates -RebootAllowed

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
    Install-Windows_Updates -RebootAllowed
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
# Make sure Automated-Setup script continues on next log-on
Start-AutomatedSetup_AtLogon
# If Exists, remove Start-AutomatedSetup-RAA.bat from Public Desktop
Remove-StartAutomatedSetup_BatchFile
Write-Host "Computername: " -NoNewline; Write-Host "$ComputerName" -ForegroundColor Cyan
Write-Host ">Starting Automated Setup...`n" -ForegroundColor Yellow
# -=[ Update Automated Setup Scripts ]=-
$script:TechTool.Update()
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
Pause
# -=[ Set Profile Default Settings ]=-
Set-ProfileDefaultSettings
# -=[ Determine if tech is setting up a single PC or building an image for capture ]=-
Determine-SetupType
# -=[ Rename PC\Image ]=-
Rename-PC -PreImage
# -=[ Start Updates In Background ]
Start-Process powershell -ArgumentList '-command Install-Updates_In_Background' -WindowStyle Minimized

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

OLD PC Checklist:
    1. STOP, sign into OneDrive, Enable Backup, Verify sync has started, Monitor progress (OneDrive Sync tends to get stuck if a large number of files are syncing and\or Files are being moved around at the same time).
    2. Sign into browsers? or not needed?
    3. Take screenshot of taskbar icons, printers, mapped drives, desktop icons, quick access in file explorer > save to desktop
New PC Profile Setup:
    Login-User
        Check for complete file
            If not already noted, should take note of the currently logged on user. 
            When script runs again (After loging in as new user [ideally], or if just signs into same account), it will compare usernames again and if it is different, continues to next step
                log completion
    enable RDP and add user\group to allowed list?
    make user a local admin...
    Configure redirected profiles?
    STOP, sign into Word (launch word) and sign in to license Office
    STOP, sign into OneDrive, Enable Backup, Verify sync has started, Monitor progress (OneDrive Sync tends to get stuck if a large number of files are syncing and\or Files are being moved around at the same time).
    STOP, sign into Outlook (or should we transfer the profile data first?)
    Migrate-User_Profile_Data
        check for complete file
        Should run the migrate user script
        log completion
    Install-Profile_Specific_Software
        Install profile specific softwares located under 
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