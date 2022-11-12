#############################################################################
#############################################################################
###                                                                       ###
###                          -=[ Script Body ]=-                          ###
###                                                                       ###
#############################################################################
#############################################################################
#region Script Setup
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

#region Configure the UI settings
$Host.UI.RawUI.BackgroundColor = 'Black'
if ($psversiontable.PSversion.build -ne 17763) {
    #do not manipulate the window size in 1809 because MS broke powershell for that build
    [console]::WindowWidth=90
    [console]::BufferWidth=[console]::WindowWidth
    [console]::WindowHeight=40
}
Clear-Host
#endregion Configure the UI settings

#region Prompt to restart as administrator if not currently
$CurrentSessionAdmin=([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))
if (!$CurrentSessionAdmin) {
    Write-Host "`nScript is not being run as an Administrator." -ForegroundColor Red
    Write-Host "`nRe-launch as Admin or exit"
    Write-Host "[ENTER]" -NoNewline -ForegroundColor Green; Write-Host " Re-launch, " -NoNewline; Write-Host "[N]" -NoNewline -ForegroundColor Red; Write-Host " Exit:" -NoNewline
    $choiceInput = Read-Host
    switch -Regex ($choiceInput) {
        default {
            $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
            $newProcess.Arguments = "-executionpolicy bypass &'" + $script:MyInvocation.MyCommand.Path + "'"
            $newProcess.Verb = "runas";
            [System.Diagnostics.Process]::Start($newProcess);
            Exit
        }
        'N|n|x|X' {
            Exit
        }
    }
} else {
    #congratulate the user
    write-host "`nAdministrative permissions confirmed." -ForegroundColor Cyan
}
#endregion Prompt to restart as administrator if not currently

#region Initialize TechTool Library
[string]$FilePath_Local_TechTool_Module = "C:\Program Files\WindowsPowerShell\Modules\TechTool\TechTool.psm1"
if (!(Test-Path $FilePath_Local_TechTool_Module)) {
    [string]$Name                           = "ImagingTool"
    [string]$Author                         = "PatrickSmith87"
    [string]$Branch                         = "master"
    [string]$Location                       = "C:\temp"

    #region Download GitHub Repo
    # Create the Zip file
    $ZipFile = "$Location\$Name.zip"
    New-Item $ZipFile -ItemType File -Force

    # Download the Zip file
    $ZipUrl = "https://github.com/$Author/$Name/archive/$Branch.zip"
    Invoke-RestMethod -Uri $ZipUrl -OutFile $ZipFile

    # Extract the Zip file
    Expand-Archive -Path $ZipFile -DestinationPath "$Location" -Force
 
    # Remove the Zip file
    Remove-Item -Path $ZipFile -Force

    Write-Host "Download GitHub Repo (to $Location): " -NoNewline; Write-Host "Complete" -BackgroundColor Green
    #endregion Download GitHub Repo

    #region Update Local Code (Only what is needed!)
    Copy-Item -Path "$Location\$Name-main\TechTool.psm1" -Destination $FilePath_Local_TechTool_Module -Force
    #endregion Update Local Code (Only what is needed!)

    #region Import Modules
    Import-Module TechTool -WarningAction SilentlyContinue -Force | Out-Null
    #endregion Import Modules
}
#endregion Initialize TechTool Library

#endregion Script Setup

#region Variables?
# Get USB Drive
foreach ($Drive_Letter in (Get-PSDrive -PSProvider FileSystem).Name) {
    $Test_Path = "$Drive_Letter" + ":\PC_Setup"
    If (Test-Path $Test_Path -ErrorAction SilentlyContinue) {
        $USB_Drive = "$Drive_Letter" + ":"
    }
}

# VARIABLES
# -=[ IMAGE MAINTENANCE ]=-
  $FilePath_ImageMaintenance_DOWNLOAD_Latest_ESD_File = "$USB_Drive\sources\Image-Maintenance\1. Download Latest ESD File.ps1"
  $FilePath_ImageMaintenance_EXTRACT_WIM_from_ESD     = "$USB_Drive\sources\Image-Maintenance\2. Extract WIM from ESD.ps1"
  $FilePath_ImageMaintenance_CREATE_Modded_WIM        = "$USB_Drive\sources\Image-Maintenance\3. Create Modded WIM.ps1"

# -=[ PC MAINTENANCE ]=-
# Modules
  $FolderPath_USB_Modules                             = "$USB_Drive\sources\PC-Maintenance\_modules"
  $FilePath_USB_AutomateSetup_Module                  = "$USB_Drive\sources\PC-Maintenance\_modules\Automate-Setup\Automate-Setup.psm1"
  $FilePath_USB_ConfigurePC_Module                    = "$USB_Drive\sources\PC-Maintenance\_modules\Configure-PC\Configure-PC.psm1"
  $FilePath_USB_InstallSoftware_Module                = "$USB_Drive\sources\PC-Maintenance\_modules\Install-Software\Install-Software.psm1"
  $FilePath_USB_TuneUpPC_Module                       = "$USB_Drive\sources\PC-Maintenance\_modules\TuneUp-PC\TuneUp-PC.psm1"
  $FolderPath_Local_Modules                           = "C:\Program Files\WindowsPowerShell\Modules"
  $FilePath_Local_AutomateSetup_Module                = "C:\Program Files\WindowsPowerShell\Modules\Automate-Setup\Automate-Setup.psm1"
  $FilePath_Local_ConfigurePC_Module                  = "C:\Program Files\WindowsPowerShell\Modules\Configure-PC\Configure-PC.psm1"
  $FilePath_Local_InstallSoftware_Module              = "C:\Program Files\WindowsPowerShell\Modules\Install-Software\Install-Software.psm1"
  $FilePath_Local_TuneUpPC_Module                     = "C:\Program Files\WindowsPowerShell\Modules\TuneUp-PC\TuneUp-PC.psm1"
# 1. Automated Setup
  $FilePath_USB_Automated_Setup_INJECT_Scripts_Script = "$USB_Drive\sources\PC-Maintenance\1. Automated Setup\1. INJECT-AutomatedSetupScripts.bat"
  $FilePath_Local_AutomateSetup_Script                = "C:\Setup\_Automated_Setup\Automate-Setup.ps1"
  $RunOnceKey                                         = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
# 2. Configure Automatic Sign In
# 3. Standardize PC
# 4. Install Software
# 5. Update PC
# 6. Cleanup Hard Drive
  $FilePath_USB_Cleanup_HD                            = "$USB_Drive\sources\PC-Maintenance\6. Cleanup Hard Drive\CLEANUP HD.ps1"
# 7. Migrate User Profile
  $FilePath_USB_Migrate_User_Profile_BACKUP           = "$USB_Drive\sources\PC-Maintenance\7. Migrate User Profile\1. BACKUP User Profile.ps1"
  $FilePath_USB_Migrate_User_Profile_RESTORE          = "$USB_Drive\sources\PC-Maintenance\7. Migrate User Profile\2. RESTORE User Profile.ps1"
  $FilePath_USB_Migrate_User_Profile_SYNC             = "$USB_Drive\sources\PC-Maintenance\7. Migrate User Profile\3. SYNC User Profile Data.bat"
# 8. Backup Folder
  $FilePath_USB_Backup_Folder_BACKUP                  = "$USB_Drive\sources\PC-Maintenance\8. Backup Folder\BACKUP Folder.bat"

# -=[ Imaging USB MAINTENANCE ]=-
  $FilePath_ImagingUSBMaintenance_BACKUP_Minus_Images       = "$USB_Drive\sources\ImagingUSB-Maintenance\1. BACKUP Imaging Drive - Minus Images.bat"
  $FilePath_ImagingUSBMaintenance_BACKUP                    = "$USB_Drive\sources\ImagingUSB-Maintenance\2. BACKUP Imaging Drive.bat"
  $FilePath_ImagingUSBMaintenance_CREATE_AutoDeploy_Package = "$USB_Drive\sources\ImagingUSB-Maintenance\3. CREATE WinPE USB AutoDeploy Package.bat"
  $FilePath_ImagingUSBMaintenance_CREATE_Package            = "$USB_Drive\sources\ImagingUSB-Maintenance\4. CREATE WinPE USB Package.bat"
  $FilePath_ImagingUSBMaintenance_RESTORE_Minus_Images      = "$USB_Drive\sources\ImagingUSB-Maintenance\5. RESTORE Imaging Drive - Minus Images.bat"
  $FilePath_ImagingUSBMaintenance_RESTORE                   = "$USB_Drive\sources\ImagingUSB-Maintenance\6. RESTORE Imaging Drive.bat"

[string]$WindowsVersion=(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion).DisplayVersion
#endregion Variables?

Write-Host "TechTool.ps1 Pause"
PAUSE
$TechTool = New-TechTool
$TechTool.DisplayMenu()