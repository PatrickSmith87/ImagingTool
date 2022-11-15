#################################################################################################################################################################
#################################################################################################################################################################
###                                                                                                                                                           ###
###                                                                 -=[ ImagingUSB Module ]=-                                                                 ###
###                                                                                                                                                           ###
#################################################################################################################################################################
#################################################################################################################################################################
$USB = New-ImagingUSB

#region ImagingUSB Class
function New-ImagingUSB {
    [ImagingUSB]::new()
} Export-ModuleMember -Function New-ImagingUSB

class ImagingUSB {
    [string[]]$Drive_Letter = @()
    [string[]]$WinPE_Drive_Letter = @()
    [boolean]$DevTool
    [string]$Module_AutomateSetup_Fi
    [string]$Module_ConfigurePC_Fi
    [string]$Module_InstallSoftware_Fi
    [string]$Module_TuneUpPC_Fi
    [string]$Module_TechTool_Fi
    [string]$Module_USB_Fi
    [string]$WinPE_Menu_ps1_Fi
    [string]$PCSetup_Client_Folders_Fo
    [string]$PCSetup_Client_Configs_Fo
    [string]$PCSetup_DriverCollection_Fo
    [string]$PCSetup_ScriptCollection_Fo
    [string]$PCSetup_SoftwareCollection_ODT_Fo
    [string]$PCSetup_SoftwareCollection_ProfileSoftware_Fo
    [string]$PCSetup_SoftwareCollection_StandardSoftware_Fo
    [string]$ImageMaint_DOWNLOADLatestESDFile_ps1_Fi
    [string]$ImageMaint_EXTRACTWIMfromESD_ps1_Fi
    [string]$ImageMaint_CREATEModdedWIM_ps1_Fi
    [string]$PCMaint_AS_HomeDir_Fo
    [string]$PCMaint_AS_RegistryBackup_Fo
    [string]$PCMaint_AS_RegistryBackup_Fi
    [string]$PCMaint_AS_AutomateSetup_ps1_Fi
    [string]$PCMaint_AS_INJECT_Scripts_bat_Fi
    [string]$PCMaint_CleanupHardDrive_Cleanup_HD_ps1_Fi
    [string]$PCMaint_MigrateUserProfile_BACKUP_ps1_Fi
    [string]$PCMaint_MigrateUserProfile_RESTORE_ps1_Fi
    [string]$PCMaint_MigrateUserProfile_SYNC_bat_Fi
    [string]$PCMaint_BackupFolder_BACKUP_bat_Fi
    [string]$USBMaint_BACKUPMinusImages_bat_Fi
    [string]$USBMaint_BACKUP_bat_Fi
    [string]$USBMaint_CREATEAutoDeployPackage_bat_Fi
    [string]$USBMaint_RESTORE_bat_Fi
    [string]$TechTool_ps1_Fi
    [string]$TechTool_bat_Fi

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
        $ImagingDrive = $this.Drive_Letter
        $WinPEDrive = $this.WinPE_Drive_Letter
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
        $this.WinPE_Menu_ps1_Fi                                     = "$WinPEDrive\sources\WinPE-Menu.ps1"
        $this.PCSetup_Client_Folders_Fo                             = "$ImagingDrive\PC_Setup\Client_Folders"
        $this.PCSetup_Client_Configs_Fo                             = "$ImagingDrive\PC_Setup\Client_Folders\_Client_Configs"
        $this.PCSetup_DriverCollection_Fo                           = "$ImagingDrive\PC_Setup\_Driver_Collection"
        $this.PCSetup_ScriptCollection_Fo                           = "$ImagingDrive\PC_Setup\_Script_Collection"
        $this.PCSetup_SoftwareCollection_ODT_Fo                     = "$ImagingDrive\PC_Setup\_Software_Collection\ODT"
        $this.PCSetup_SoftwareCollection_ProfileSoftware_Fo         = "$ImagingDrive\PC_Setup\_Software_Collection\Profile_Specific_Software"
        $this.PCSetup_SoftwareCollection_StandardSoftware_Fo        = "$ImagingDrive\PC_Setup\_Software_Collection\Standard_Software"
        $this.ImageMaint_DOWNLOADLatestESDFile_ps1_Fi               = "$ImagingDrive\sources\Image-Maintenance\1. Download Latest ESD File.ps1"
        $this.ImageMaint_EXTRACTWIMfromESD_ps1_Fi                   = "$ImagingDrive\sources\Image-Maintenance\2. Extract WIM from ESD.ps1"
        $this.ImageMaint_CREATEModdedWIM_ps1_Fi                     = "$ImagingDrive\sources\Image-Maintenance\3. Create Modded WIM.ps1"
        $this.PCMaint_AS_HomeDir_Fo                                 = "$ImagingDrive\sources\PC-Maintenance\1. Automated Setup"
        $this.PCMaint_AS_RegistryBackup_Fo                          = "$ImagingDrive\sources\PC-Maintenance\1. Automated Setup\Setup\_Automated_Setup\_RegistryBackup"
        $this.PCMaint_AS_RegistryBackup_Fi                          = "$ImagingDrive\sources\PC-Maintenance\1. Automated Setup\Setup\_Automated_Setup\_RegistryBackup\registry-backup020622.reg"
        $this.PCMaint_AS_AutomateSetup_ps1_Fi                       = "$ImagingDrive\sources\PC-Maintenance\1. Automated Setup\Setup\_Automated_Setup\Automate-Setup.ps1"
        $this.PCMaint_AS_INJECT_Scripts_bat_Fi                      = "$ImagingDrive\sources\PC-Maintenance\1. Automated Setup\1. INJECT-AutomatedSetupScripts.bat"
        $this.PCMaint_CleanupHardDrive_Cleanup_HD_ps1_Fi            = "$ImagingDrive\sources\PC-Maintenance\6. Cleanup Hard Drive\CLEANUP HD.ps1"
        $this.PCMaint_MigrateUserProfile_BACKUP_ps1_Fi              = "$ImagingDrive\sources\PC-Maintenance\7. Migrate User Profile\1. BACKUP User Profile.ps1"
        $this.PCMaint_MigrateUserProfile_RESTORE_ps1_Fi             = "$ImagingDrive\sources\PC-Maintenance\7. Migrate User Profile\2. RESTORE User Profile.ps1"
        $this.PCMaint_MigrateUserProfile_SYNC_bat_Fi                = "$ImagingDrive\sources\PC-Maintenance\7. Migrate User Profile\3. SYNC User Profile Data.bat"
        $this.PCMaint_BackupFolder_BACKUP_bat_Fi                    = "$ImagingDrive\sources\PC-Maintenance\8. Backup Folder\BACKUP Folder.bat"
        $this.USBMaint_BACKUPMinusImages_bat_Fi                     = "$ImagingDrive\sources\USB-Maintenance\1. BACKUP Imaging Drive - Minus Images.bat"
        $this.USBMaint_BACKUP_bat_Fi                                = "$ImagingDrive\sources\USB-Maintenance\2. BACKUP Imaging Drive.bat"
        $this.USBMaint_CREATEAutoDeployPackage_bat_Fi               = "$ImagingDrive\sources\USB-Maintenance\3. CREATE WinPE USB AutoDeploy Package.bat"
        $this.USBMaint_RESTORE_bat_Fi                               = "$ImagingDrive\sources\USB-Maintenance\6. RESTORE Imaging Drive.bat"
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
        $this.WinPE_Menu_ps1_Fi                                     = $null
        $this.PCSetup_Client_Folders_Fo                             = $null
        $this.PCSetup_Client_Configs_Fo                             = $null
        $this.PCSetup_DriverCollection_Fo                           = $null
        $this.PCSetup_ScriptCollection_Fo                           = $null
        $this.PCSetup_SoftwareCollection_ODT_Fo                     = $null
        $this.PCSetup_SoftwareCollection_ProfileSoftware_Fo         = $null
        $this.PCSetup_SoftwareCollection_StandardSoftware_Fo        = $null
        $this.ImageMaint_DOWNLOADLatestESDFile_ps1_Fi               = $null
        $this.ImageMaint_EXTRACTWIMfromESD_ps1_Fi                   = $null
        $this.ImageMaint_CREATEModdedWIM_ps1_Fi                     = $null
        $this.PCMaint_AS_HomeDir_Fo                                 = $null
        $this.PCMaint_AS_RegistryBackup_Fo                          = $null
        $this.PCMaint_AS_RegistryBackup_Fi                          = $null
        $this.PCMaint_AS_AutomateSetup_ps1_Fi                       = $null
        $this.PCMaint_AS_INJECT_Scripts_bat_Fi                      = $null
        $this.PCMaint_CleanupHardDrive_Cleanup_HD_ps1_Fi            = $null
        $this.PCMaint_MigrateUserProfile_BACKUP_ps1_Fi              = $null
        $this.PCMaint_MigrateUserProfile_RESTORE_ps1_Fi             = $null
        $this.PCMaint_MigrateUserProfile_SYNC_bat_Fi                = $null
        $this.PCMaint_BackupFolder_BACKUP_bat_Fi                    = $null
        $this.USBMaint_BACKUPMinusImages_bat_Fi                     = $null
        $this.USBMaint_BACKUP_bat_Fi                                = $null
        $this.USBMaint_CREATEAutoDeployPackage_bat_Fi               = $null
        $this.USBMaint_RESTORE_bat_Fi                               = $null
        $this.TechTool_ps1_Fi                                       = $null
        $this.TechTool_bat_Fi                                       = $null
    }
}
#endregion ImagingUSB Class

function Inject-AutomatedSetupScripts {
    #region Function Variables
    $USB = New-ImagingUSB
    $TechTool = New-TechTool

    $USB_AutomatedSetup_HomeDir = $USB.PCMaint_AS_HomeDir_Fo
    $Local_AutomatedSetup_HomeDir = $TechTool.Setup_Fo
        $USB_ClientConfigs_Folder = $USB.PCSetup_Client_Configs_Fo
        $Local_ClientConfigs_Repo = $TechTool.Setup_AS_Client_Config_Repository_Fo
    $USB_StandardSoftware_Folder = $USB.PCSetup_SoftwareCollection_StandardSoftware_Fo
    $Local_StandardSoftware_Folder = $TechTool.Setup_SoftwareCollection_Standard_Software_Fo
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