#################################################################################################################################################################
#################################################################################################################################################################
###                                                                                                                                                           ###
###                                                                 -=[ ImagingUSB Module ]=-                                                                 ###
###                                                                                                                                                           ###
#################################################################################################################################################################
#################################################################################################################################################################

#region ImagingUSB Class
function New-ImagingUSB {
    [ImagingUSB]::new()
} Export-ModuleMember -Function New-ImagingUSB

class ImagingUSB {
    [string[]]$WinPE_Drive_Letter = @()
    [string]$WinPE_Menu_ps1_Fi
    [string[]]$Drive_Letter = @()
    [string]$Module_AutomateSetup_Fi
    [string]$Module_ConfigurePC_Fi
    [string]$Module_InstallSoftware_Fi
    [string]$Module_TuneUpPC_Fi
    [string]$Module_TechTool_Fi
    [string]$Module_USB_Fi
    [string]$Module_UpdatePC_Fi
    [string]$PCSetup_Client_Folders_Fo
    [string]$PCSetup_Client_Configs_Fo
    [string]$PCSetup_DriverCollection_Fo
    [string]$PCSetup_ScriptCollection_Fo
    [string]$PCSetup_SoftwareCollection_ODT_Fo
    [string]$PCSetup_SoftwareCollection_ProfileSoftware_Fo
    [string]$PCSetup_SoftwareCollection_StandardSoftware_Fo
    [string]$PCMaint_AS_HomeDir_Fo
    [string]$PCMaint_AS_RegistryBackup_Fo
    [string]$PCMaint_AS_RegistryBackup_Fi
    [string]$PCMaint_AS_AutomateSetup_ps1_Fi
    [string]$TechTool_ps1_Fi
    [string]$TechTool_bat_Fi
    [boolean]$DevTool

    ImagingUSB() {
        $this.Exists()
    }

    [boolean] Exists() {
        $this.Drive_Letter = @() # Reset to empty list
        $this.WinPE_Drive_Letter = @() # Reset to empty list
        
        foreach ($letter in (Get-PSDrive -PSProvider FileSystem).Name) {
            # Get The Imaging USB Drive Letter
            $TestPath = "$letter" + ":\PC_Setup"
            If (Test-Path $TestPath) {
                $this.Drive_Letter += "$letter" + ":"
            }
            # Get The WinPE USB Drive Letter
            $TestPath = "$letter" + ":\sources\WinPE-Menu.ps1"
            If (Test-Path $TestPath) {
                $this.WinPE_Drive_Letter += "$letter" + ":"
            }
        }
        
        # Set\Remove USB related paths and send return value
        If ($this.Drive_Letter.count -eq 0) {
            $this.RemovePaths()
            return $false
        } elseif ($this.Drive_Letter.count -gt 1) {
            Write-Host "Error: Multiple *:\PC_Setup paths have been detected" -ForegroundColor Red
            $this.RemovePaths()
            return $false
        } else {
            $this.SetPaths()
            return $true
        }
    }

    [void]hidden SetPaths() {
        $WinPEDrive = $this.WinPE_Drive_Letter
        $this.WinPE_Menu_ps1_Fi                                     = "$WinPEDrive\sources\WinPE-Menu.ps1"
        $ImagingDrive = $this.Drive_Letter
        if (Test-Path "$ImagingDrive\sources\DevTool") {
            $this.DevTool = $true
        } else {
            $this.DevTool = $false
        }
        $this.Module_AutomateSetup_Fi                               = "$ImagingDrive\sources\PC-Maintenance\_modules\Automate-Setup\Automate-Setup.psm1"
        $this.Module_ConfigurePC_Fi                                 = "$ImagingDrive\sources\PC-Maintenance\_modules\Configure-PC\Configure-PC.psm1"
        $this.Module_InstallSoftware_Fi                             = "$ImagingDrive\sources\PC-Maintenance\_modules\Install-Software\Install-Software.psm1"
        $this.Module_TuneUpPC_Fi                                    = "$ImagingDrive\sources\PC-Maintenance\_modules\TuneUp-PC\TuneUp-PC.psm1"
        $this.Module_TechTool_Fi                                    = "$ImagingDrive\sources\TechTool-Maintenance\_modules\TechTool\TechTool.psm1"
        $this.Module_USB_Fi                                         = "$ImagingDrive\sources\USB-Maintenance\_modules\ImagingUSB\ImagingUSB.psm1"
        $this.Module_UpdatePC_Fi                                    = "$ImagingDrive\sources\PC-Maintenance\_modules\Update-PC\Update-PC.psm1"
        $this.PCSetup_Client_Folders_Fo                             = "$ImagingDrive\PC_Setup\Client_Folders"
        $this.PCSetup_Client_Configs_Fo                             = "$ImagingDrive\PC_Setup\Client_Folders\_Client_Configs"
        $this.PCSetup_DriverCollection_Fo                           = "$ImagingDrive\PC_Setup\_Driver_Collection"
        $this.PCSetup_ScriptCollection_Fo                           = "$ImagingDrive\PC_Setup\_Script_Collection"
        $this.PCSetup_SoftwareCollection_ODT_Fo                     = "$ImagingDrive\PC_Setup\_Software_Collection\ODT"
        $this.PCSetup_SoftwareCollection_ProfileSoftware_Fo         = "$ImagingDrive\PC_Setup\_Software_Collection\Profile_Specific_Software"
        $this.PCSetup_SoftwareCollection_StandardSoftware_Fo        = "$ImagingDrive\PC_Setup\_Software_Collection\Standard_Software"
        $this.PCMaint_AS_HomeDir_Fo                                 = "$ImagingDrive\sources\PC-Maintenance\1. Automated Setup"
        $this.PCMaint_AS_RegistryBackup_Fo                          = "$ImagingDrive\sources\PC-Maintenance\1. Automated Setup\Setup\_Automated_Setup\_RegistryBackup"
        $this.PCMaint_AS_RegistryBackup_Fi                          = "$ImagingDrive\sources\PC-Maintenance\1. Automated Setup\Setup\_Automated_Setup\_RegistryBackup\registry-backup020622.reg"
        $this.PCMaint_AS_AutomateSetup_ps1_Fi                       = "$ImagingDrive\sources\PC-Maintenance\1. Automated Setup\Setup\_Automated_Setup\Automate-Setup.ps1"
        $this.TechTool_ps1_Fi                                       = "$ImagingDrive\sources\TechTool.ps1"
        $this.TechTool_bat_Fi                                       = "$ImagingDrive\TechTool-RAA.bat"
    }

    [void]hidden RemovePaths() {
        $this.DevTool                                               = $false
        $this.Module_AutomateSetup_Fi                               = $null
        $this.Module_ConfigurePC_Fi                                 = $null
        $this.Module_InstallSoftware_Fi                             = $null
        $this.Module_TuneUpPC_Fi                                    = $null
        $this.Module_TechTool_Fi                                    = $null
        $this.Module_USB_Fi                                         = $null
        $this.Module_UpdatePC_Fi                                    = $null
        $this.WinPE_Menu_ps1_Fi                                     = $null
        $this.PCSetup_Client_Folders_Fo                             = $null
        $this.PCSetup_Client_Configs_Fo                             = $null
        $this.PCSetup_DriverCollection_Fo                           = $null
        $this.PCSetup_ScriptCollection_Fo                           = $null
        $this.PCSetup_SoftwareCollection_ODT_Fo                     = $null
        $this.PCSetup_SoftwareCollection_ProfileSoftware_Fo         = $null
        $this.PCSetup_SoftwareCollection_StandardSoftware_Fo        = $null
        $this.PCMaint_AS_HomeDir_Fo                                 = $null
        $this.PCMaint_AS_RegistryBackup_Fo                          = $null
        $this.PCMaint_AS_RegistryBackup_Fi                          = $null
        $this.PCMaint_AS_AutomateSetup_ps1_Fi                       = $null
        $this.TechTool_ps1_Fi                                       = $null
        $this.TechTool_bat_Fi                                       = $null
    }
}
#endregion ImagingUSB Class

#region Module Variables
# Variables may be defined from parent script. If not, they will be defined from here.
# Child scripts should be able to see variables from the parent script...
# However the child script cannot modify the parent's variables unless the scope is defined.
# This should not be a problem since the child script does not need to modify these variables.
# The goal here is to allow the modules to run independantly of the "Automate-Setup" script

# Objects
$TechTool = New-TechTool
$USB = New-ImagingUSB
#endregion Module Variables

#region ImagingUSB functions
function New-AutoDeploy_ImagingUSB_InstallPackage {
    Write-Host "`nDO NOT EJECT the Imaging USB" -ForegroundColor Red
    DO {
        # SET WinPE & Imaging Drives
        foreach ($Drive_Letter in (Get-PSDrive -PSProvider FileSystem).Name) {
            $ImagingUSB_WinPE_Test_Path = "$Drive_Letter" + ":\en-us\bootmgr.efi.mui"
            $ImagingUSB_Imaging_Test_Path = "$Drive_Letter" + ":\Images"
            If (Test-Path $ImagingUSB_WinPE_Test_Path) {$WinPE_Drive = "$Drive_Letter" + ":"}
            If (Test-Path $ImagingUSB_Imaging_Test_Path) {$Imaging_Drive = "$Drive_Letter" + ":"}
        }
        
        if ($null -eq $WinPE_Drive) {Write-Host "`nWARNING!!! Could not detect the WinPE partition" -ForegroundColor Red}
        if ($null -eq $Imaging_Drive) {Write-Host "`nWARNING!!! Could not detect the Imaging partition" -ForegroundColor Red}
        if (($null -eq $WinPE_Drive) -or ($null -eq $Imaging_Drive)) {Write-Host "`nHit any key to check and try again"; Pause}
    } until (($null -ne $WinPE_Drive) -and ($null -ne $Imaging_Drive))
    Write-Host "`nWinPE Drive: " -NoNewline; Write-Host "$WinPE_Drive" -ForegroundColor Cyan
    Write-Host "Imaging Drive: " -NoNewline; Write-Host "$Imaging_Drive" -ForegroundColor Cyan
    # SET WinPE_USB_Package SOURCE FOLDER ROOT
    $WinPE_USB_Package_SOURCE = "$Imaging_Drive\sources\USB-Maintenance\AutoDeploy_ImagingUSB_InstallPackage\"

    # SET WinPE_USB_Package DESTINATION FOLDER ROOT
    $WinPE_USB_Package_DESTINATION = "C:\ImagingUSB_Install_Package(AutoDeploy)"
    Write-Host "`nDownloading\Updating " -NoNewline; Write-Host "$WinPE_USB_Package_DESTINATION" -ForegroundColor Cyan

    # Set ROBOCOPY What and Options
    $what = @("/A-:SH","/B","/E")
    $options = @("/R:5","/W:6","/XO","/XX")
    
    <#
    # START TRANSFERS
    # 0. WinPE USB Package Shell - "C:\WinPE_USB_Install_Package\"
    $cmdArgs = @("$WinPE_USB_Package_SOURCE","$WinPE_USB_Package_DESTINATION",$what,$options)
    robocopy @cmdArgs

    # 1. WinPE Drive Files
    $WinPE_Dest = "$WinPE_USB_Package_DESTINATION\sources\Create_WinPE_USB\WinPE_Drive"

    # P:\
    # C:\ImagingUSB_Install_Package\sources\Create_WinPE_USB\WinPE_Drive
    $cmdArgs = @("$WinPE_Drive\autorun.inf","$WinPE_Dest\autorun.inf*","/H","/Y"); xcopy @cmdArgs
    $cmdArgs = @("+h","$WinPE_Dest\autorun.inf"); attrib $cmdArgs # Make sure it's hidden just in case it didn't copy over hidden

    # P:\sources
    # C:\ImagingUSB_Install_Package\sources\Create_WinPE_USB\WinPE_Drive
    $cmdArgs = @("$WinPE_Drive\sources\WinPE.ico","$WinPE_Dest\sources\WinPE.ico*","/Y"); xcopy @cmdArgs
    $cmdArgs = @("$WinPE_Drive\sources\WinPE-Menu.ps1","$WinPE_Dest\sources\WinPE-Menu.ps1*","/Y"); xcopy @cmdArgs
    #>
} Export-ModuleMember -Function New-AutoDeploy_ImagingUSB_InstallPackage

function New-Standard_ImagingUSB_InstallPackage {
    Write-Host "`nDO NOT EJECT the Imaging USB" -ForegroundColor Red
    DO {
        # SET WinPE & Imaging Drives
        foreach ($Drive_Letter in (Get-PSDrive -PSProvider FileSystem).Name) {
            $ImagingUSB_WinPE_Test_Path = "$Drive_Letter" + ":\en-us\bootmgr.efi.mui"
            $ImagingUSB_Imaging_Test_Path = "$Drive_Letter" + ":\Images"
            If (Test-Path $ImagingUSB_WinPE_Test_Path) {$WinPE_Drive = "$Drive_Letter" + ":"}
            If (Test-Path $ImagingUSB_Imaging_Test_Path) {$Imaging_Drive = "$Drive_Letter" + ":"}
        }
        
        if ($null -eq $WinPE_Drive) {Write-Host "`nWARNING!!! Could not detect the WinPE partition" -ForegroundColor Red}
        if ($null -eq $Imaging_Drive) {Write-Host "`nWARNING!!! Could not detect the Imaging partition" -ForegroundColor Red}
        if (($null -eq $WinPE_Drive) -or ($null -eq $Imaging_Drive)) {Write-Host "`nHit any key to check and try again"; Pause}
    } until (($null -ne $WinPE_Drive) -and ($null -ne $Imaging_Drive))
    Write-Host "`nWinPE Drive: " -NoNewline; Write-Host "$WinPE_Drive" -ForegroundColor Cyan
    Write-Host "Imaging Drive: " -NoNewline; Write-Host "$Imaging_Drive" -ForegroundColor Cyan
    # SET WinPE_USB_Package SOURCE FOLDER ROOT
    $WinPE_USB_Package_SOURCE = "$Imaging_Drive\sources\USB-Maintenance\Standard_ImagingUSB_InstallPackage\"

    # SET WinPE_USB_Package DESTINATION FOLDER ROOT
    $WinPE_USB_Package_DESTINATION = "C:\ImagingUSB_Install_Package(Standard)"
    Write-Host "`nDownloading\Updating " -NoNewline; Write-Host "$WinPE_USB_Package_DESTINATION" -ForegroundColor Cyan

    # Set ROBOCOPY What and Options
    $what = @("/A-:SH","/B","/E")
    $options = @("/R:5","/W:6","/XO","/XX")
    
    # START TRANSFERS
    # 0. WinPE USB Package Shell - "C:\WinPE_USB_Install_Package\"
    $cmdArgs = @("$WinPE_USB_Package_SOURCE","$WinPE_USB_Package_DESTINATION",$what,$options)
    robocopy @cmdArgs

    # 1. WinPE Drive Files
    $WinPE_Dest = "$WinPE_USB_Package_DESTINATION\sources\Create_WinPE_USB\WinPE_Drive"

    # P:\
    # C:\ImagingUSB_Install_Package\sources\Create_WinPE_USB\WinPE_Drive
    $cmdArgs = @("$WinPE_Drive\autorun.inf","$WinPE_Dest\autorun.inf*","/H","/Y"); xcopy @cmdArgs
    $cmdArgs = @("+h","$WinPE_Dest\autorun.inf"); attrib $cmdArgs # Make sure it's hidden just in case it didn't copy over hidden

    # P:\sources
    # C:\ImagingUSB_Install_Package\sources\Create_WinPE_USB\WinPE_Drive
    $cmdArgs = @("$WinPE_Drive\sources\WinPE.ico","$WinPE_Dest\sources\WinPE.ico*","/Y"); xcopy @cmdArgs
    $cmdArgs = @("$WinPE_Drive\sources\WinPE-Menu.ps1","$WinPE_Dest\sources\WinPE-Menu.ps1*","/Y"); xcopy @cmdArgs

    # 2. Imaging Drive Files
    $Imaging_Dest = "$WinPE_USB_Package_DESTINATION\sources\Create_WinPE_USB\Imaging_Drive"

    # I:\
    # C:\ImagingUSB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive
    $cmdArgs = @("$Imaging_Drive\autorun.inf","$Imaging_Dest\autorun.inf*","/h","/Y"); xcopy @cmdArgs
    $cmdArgs = @("+h","$Imaging_Dest\autorun.inf"); attrib $cmdArgs # Make sure it's hidden just in case it didn't copy over hidden
    $cmdArgs = @("$Imaging_Drive\TechTool-RAA.bat","$Imaging_Dest\TechTool-RAA.bat*","/h","/Y"); xcopy @cmdArgs
    $cmdArgs = @("$Imaging_Drive\Get-WindowsAutoPilotInfo-RAA.bat","$Imaging_Dest\Get-WindowsAutoPilotInfo-RAA.bat*","/h","/Y"); xcopy @cmdArgs

    # I:\sources
    # C:\ImagingUSB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive\sources
    $cmdArgs = @("$Imaging_Drive\sources\","$Imaging_Dest\sources\",$what,$options,"/XF","DevTool"); robocopy @cmdArgs
    $cmdArgs = @("+h","$Imaging_Dest\sources"); attrib $cmdArgs # Make sure it's hidden just in case it didn't copy over hidden

    # I:\Images
    # C:\ImagingUSB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive\Images
    $cmdArgs = @("$Imaging_Drive\Images\","$Imaging_Dest\Images\",$what,$options,"/XF","*.wim","*.esd"); robocopy @cmdArgs

    # I:\PC_Setup
    # C:\ImagingUSB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive\PC_Setup
    $cmdArgs = @("$Imaging_Drive\PC_Setup\","$Imaging_Dest\PC_Setup\",$what,"/MIR",$options,"/XD","Client_Folders","ODT","Personal_Software","Uncommon_Software"); robocopy @cmdArgs

    # I:\PC_Setup\Client_Folders\_Client_Configs
    # C:\ImagingUSB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive\PC_Setup\Client_Folders\_Client_Configs
    $cmdArgs = @("$Imaging_Drive\PC_Setup\Client_Folders\_Client_Configs\","$Imaging_Dest\PC_Setup\Client_Folders\_Client_Configs",$what,$options); robocopy @cmdArgs

    # I:\PC_Setup\Client_Folders\Axxys
    # C:\ImagingUSB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive\PC_Setup\Client_Folders\Axxys
    $cmdArgs = @("$Imaging_Drive\PC_Setup\Client_Folders\Axxys\","$Imaging_Dest\PC_Setup\Client_Folders\Axxys\",$what,$options); robocopy @cmdArgs

    # I:\PC_Setup\_Software_Collection\ODT
    # C:\ImagingUSB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive\PC_Setup\_Software_Collection\ODT
    $cmdArgs = @("$Imaging_Drive\PC_Setup\_Software_Collection\ODT\*.bat","$Imaging_Dest\PC_Setup\_Software_Collection\ODT\*.bat","/h","/Y"); xcopy @cmdArgs
    $cmdArgs = @("$Imaging_Drive\PC_Setup\_Software_Collection\ODT\*.xml","$Imaging_Dest\PC_Setup\_Software_Collection\ODT\*.xml","/h","/Y"); xcopy @cmdArgs
    $cmdArgs = @("$Imaging_Drive\PC_Setup\_Software_Collection\ODT\*.exe","$Imaging_Dest\PC_Setup\_Software_Collection\ODT\*.exe","/h","/Y"); xcopy @cmdArgs
    # TRANSFERS COMPLETED
    Write-Host "`nDownload\Update of " -NoNewline; Write-Host "$WinPE_USB_Package_DESTINATION" -NoNewline -ForegroundColor Cyan; Write-Host " is " -NoNewline; Write-Host "Complete" -ForegroundColor Green
} Export-ModuleMember -Function New-Standard_ImagingUSB_InstallPackage

function Move-Imaging_USB_Package_To_Axxys_Storage {
    $what = '/A-:SH /B /E'
    $options = '/R:5 /W:6 /LOG:C:\Transfer-Package_Backup_Log.txt /TEE /V /XO /XX'
    $source = "C:\ImagingUSB_Install_Package(Standard)"
    $dest = "\\ATIQNAP1\Tech"
        
    DO {
        [int]$error = 0
        if (Test-Path $source) {
            Write-Host "$source " -NoNewline; Write-Host "`nfound" -ForegroundColor green
        } else {
            $error++
            Write-Host "$source " -NoNewline; Write-Host "`nmissing" -ForegroundColor red
        }
        if (Test-Path $dest) {
            Write-Host "$dest " -NoNewline; Write-Host "found" -ForegroundColor green
        } else {
            $error++
            Write-Host "$dest " -NoNewline; Write-Host "missing" -ForegroundColor red
        }
        if ($error -gt 0) {
            Write-Host "WARNING!!! Was not able to find either the destination or source" -ForegroundColor Red
            Write-Host "Hit any key to check and try again"
            Pause
        }
    } until ($error -eq 0)
    
    $dest = "$dest\Axxys_Imaging_And_PC_Setup_Tool"
    if (!(Test-Path $dest)) {New-Item $dest -ItemType Directory | Out-Null}
    $dest = "$dest\WinPE_USB_Install_Package"
    if (!(Test-Path $dest)) {New-Item $dest -ItemType Directory | Out-Null}
    
    Write-Host "`nTransferring " -NoNewline; Write-Host "$source" -ForegroundColor Cyan
    Write-Host "to " -NoNewline; Write-Host "$dest" -ForegroundColor Cyan
    Write-Host "now..."

    $command = "ROBOCOPY $source $dest $what $options"
    Start-Process cmd.exe -ArgumentList "/c $command" -Wait
    Write-Host "`nTransfer is " -NoNewline; Write-Host "Complete!" -ForegroundColor Green
} Export-ModuleMember -Function Move-Imaging_USB_Package_To_Axxys_Storage

function Backup-ImagingUSB {
    param(
        [Parameter(Mandatory = $false)]
        [switch] $WithoutImages
    )

    Write-Host "`nDO NOT EJECT the Imaging USB" -ForegroundColor Red
    Do {
        if ($USB.Exists()) {
            $Source = $USB.Drive_Letter
            
        } else {
            Write-Host "`nWARNING!!! Could not detect the Imaging USB" -ForegroundColor Red
            Write-Host "`nHit any key to check and try again"
            Pause
        }
    } Until ($Source)
    Write-Host "`nSource: " -NoNewline; Write-Host "$Source" -ForegroundColor Cyan
    $Dest = "C:\ImagingUSB_Backup"
    Write-Host "Destination: " -NoNewline; Write-Host "$Dest" -ForegroundColor Cyan
    
    $what = @("/A-:SH","/COPYALL","/B","/MIR")
    
    if ($WithoutImages) {
        $options = @("/R:5","/W:6","/LOG+:C:\ImagingUSB_Backup_Log.txt","/TEE","/V","/XO","/XD","Virtual Machines","/XF","*.wim","*.esd")
    } else {
        $options = @("/R:5","/W:6","/LOG+:C:\ImagingUSB_Backup_Log.txt","/TEE","/V","/XO","/XD","Virtual Machines")
    }
    
    $cmdArgs = @("$Source","$Dest",$what,$options)
    robocopy @cmdArgs
    $cmdArgs = @("-h","-s","$Dest"); attrib $cmdArgs # Make it NOT hidden
    Write-Host "`nBackup to " -NoNewline; Write-Host "$Dest" -NoNewline -ForegroundColor Cyan; Write-Host " is " -NoNewline; Write-Host "Complete" -ForegroundColor Green
} Export-ModuleMember -Function Backup-ImagingUSB

function Restore-ImagingUSB {
    param(
        [Parameter(Mandatory = $false)]
        [switch] $WithoutImages
    )

    Write-Host "`nDO NOT EJECT the Imaging USB" -ForegroundColor Red
    Do {
        if ($USB.Exists()) {
            $Dest = $USB.Drive_Letter
            
        } else {
            Write-Host "`nWARNING!!! Could not detect the Imaging USB" -ForegroundColor Red
            Write-Host "`nHit any key to check and try again"
            Pause
        }
    } Until ($Dest)
    $Source = "C:\ImagingUSB_Backup"
    Write-Host "Source: " -NoNewline; Write-Host "$Source" -ForegroundColor Cyan
    Write-Host "`nDestination: " -NoNewline; Write-Host "$Dest" -ForegroundColor Cyan
    
    $what = @("/A-:SH","/COPYALL","/B","/MIR")
    
    if ($WithoutImages) {
        $options = @("/R:5","/W:6","/LOG+:C:\ImagingUSB_Restore_Log.txt","/TEE","/V","/XO","/XD","Virtual Machines","/XF","*.wim","*.esd")
    } else {
        $options = @("/R:5","/W:6","/LOG+:C:\ImagingUSB_Restore_Log.txt","/TEE","/V","/XO","/XD","Virtual Machines")
    }
    
    $cmdArgs = @("$Source","$Dest",$what,$options)
    robocopy @cmdArgs
    Write-Host "`nRestore from " -NoNewline; Write-Host "$Source" -NoNewline -ForegroundColor Cyan; Write-Host " is " -NoNewline; Write-Host "Complete" -ForegroundColor Green
} Export-ModuleMember -Function Restore-ImagingUSB

function Inject-AutomatedSetupScripts {
    #region Function Variables
    $USB_AutomatedSetup_HomeDir = $USB.PCMaint_AS_HomeDir_Fo
    $Local_AutomatedSetup_HomeDir = $TechTool.Setup_Fo
        $USB_ClientConfigs_Folder = $USB.PCSetup_Client_Configs_Fo
        $Local_ClientConfigs_Repo = $TechTool.Setup_AS_Client_Config_Repository_Fo
    $USB_StandardSoftware_Folder = $USB.PCSetup_SoftwareCollection_StandardSoftware_Fo
    $Local_StandardSoftware_Folder = $TechTool.Setup_SoftwareCollection_StandardSoftware_Fo
        $USB_ODTSoftware_Folder = $USB.PCSetup_SoftwareCollection_ODT_Fo
        $Local_ODTSoftware_Folder = $TechTool.Setup_SoftwareCollection_ODTSoftware_Fo
    $USB_ProfileSoftware_Folder = $USB.PCSetup_SoftwareCollection_ProfileSoftware_Fo
    $Local_ProfileSoftware_Folder = $TechTool.Setup_SoftwareCollection_ProfileSoftware_Fo
        $USB_DriverCollection_Folder = $USB.PCSetup_DriverCollection_Fo
        $Local_DriverCollection_Folder = $TechTool.Setup_DriverCollection_Fo
    $USB_ScriptCollection_Folder = $USB.PCSetup_ScriptCollection_Fo
    $Local_ScriptCollection_Folder = $TechTool.Setup_ScriptCollection_Fo
    #endregion Function Variables

    #region Edit Registry
    ###########################
    ## -=[ EDIT REGISTRY ]=- ##
    ###########################

    # -=[ Disable Live Tiles ]=-
    cmd.exe /c 'REG ADD "HKLM\Software\Policies\Microsoft\Windows\CurrentVersion\Pushnotications" /v NoTileApplictionNotification /d 1 /f /t REG_DWORD'# | Out-Null
    
    # -=[ Remove "Cortana" button from the taskbar ]=-
    cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCortanaButton /d 0 /f /t REG_DWORD'# | Out-Null
    
    # -=[ Remove "People" icon from the taskbar ]=-
    cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v PeopleBand /d 0 /f /t REG_DWORD'# | Out-Null
    
    # -=[ Remove "TaskViewButton" from the taskbar ]=-
    cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /d 0 /f /t REG_DWORD'# | Out-Null

    # -=[ Show ALL system tray icons ]=-
    cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v EnableAutoTray /d 0 /f /t REG_DWORD'# | Out-Null

    # Set Searchbar as Icon rather than Search Box
    cmd.exe /c 'REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /d 1 /f /t REG_DWORD'# | Out-Null
    
    # Do not show News & Interests button
    cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /d 2 /f /t REG_DWORD'# | Out-Null
    #endregion Edit Registry

    #region Deploy Setup Package
    ##################################
    ## -=[ Deploy_Setup_Package ]=- ##
    ##################################

    # -=[ Transfer Setup Core ]=-
    XCOPY "$USB_AutomatedSetup_HomeDir\Setup\*" "$Local_AutomatedSetup_HomeDir\" /E /Y

    # -=[ Transfer Client Configs ]=-
    XCOPY "$USB_ClientConfigs_Folder\*" "$Local_ClientConfigs_Repo\" /E /Y

    # -=[ Transfer Public Desktop ]=-
    XCOPY "$USB_AutomatedSetup_HomeDir\PublicDesktop\*" "C:\Users\Public\Desktop\" /E /Y

    # -=[ Transfer C:\Setup\Software\Standard_Software ]=-
    XCOPY "$USB_StandardSoftware_Folder\*" "$Local_StandardSoftware_Folder\" /E /Y

    # -=[ Transfer C:\Setup\Software\ODT ]=-
    XCOPY "$USB_ODTSoftware_Folder\Install o365ProPlus1.bat" "$Local_ODTSoftware_Folder\Install o365ProPlus1.bat*" /Y
    XCOPY "$USB_ODTSoftware_Folder\Install o365Business1.bat" "$Local_ODTSoftware_Folder\Install o365Business1.bat*" /Y
    XCOPY "$USB_ODTSoftware_Folder\Install o365Enterprise_32-bit.bat" "$Local_ODTSoftware_Folder\Install o365Enterprise_32-bit.bat*" /Y
    XCOPY "$USB_ODTSoftware_Folder\Install o365Business1_32-bit.bat" "$Local_ODTSoftware_Folder\Install o365Business1_32-bit.bat*" /Y
    XCOPY "$USB_ODTSoftware_Folder\o365Business1.xml" "$Local_ODTSoftware_Folder\o365Business1.xml*" /Y
    XCOPY "$USB_ODTSoftware_Folder\o365Business1_32-bit.xml" "$Local_ODTSoftware_Folder\o365Business1_32-bit.xml*" /Y
    XCOPY "$USB_ODTSoftware_Folder\o365ProPlus1.xml" "$Local_ODTSoftware_Folder\o365ProPlus1.xml*" /Y
    XCOPY "$USB_ODTSoftware_Folder\o365Enterprise_32-bit.xml" "$Local_ODTSoftware_Folder\o365Enterprise_32-bit.xml*" /Y
    XCOPY "$USB_ODTSoftware_Folder\setup.exe" "$Local_ODTSoftware_Folder\setup.exe*" /Y
    XCOPY "$USB_ODTSoftware_Folder\Office\*" "$Local_ODTSoftware_Folder\Office\" /E /Y

    # -=[ Transfer C:\Setup\Standard_Software\Profile_Specific_Software ]=-
    XCOPY "$USB_ProfileSoftware_Folder\*" "$Local_ProfileSoftware_Folder\" /E /Y

    # -=[ Transfer Driver Collection ]=-
    XCOPY "$USB_DriverCollection_Folder\*" "$Local_DriverCollection_Folder\" /E /Y

    # -=[ Transfer Script Collection ]=-
    XCOPY "$USB_ScriptCollection_Folder\*" "$Local_ScriptCollection_Folder\" /E /Y

    #endregion Deploy Setup Package

    ###################################
    ## -=[ Start Automated Setup ]=- ##
    ###################################
    #IF EXIST "C:\Users\Public\Desktop\Start-AutomatedSetup-RAA.bat" CALL "C:\Users\Public\Desktop\Start-AutomatedSetup-RAA.bat"
} Export-ModuleMember -Function Inject-AutomatedSetupScripts
#endregion region ImagingUSB functions