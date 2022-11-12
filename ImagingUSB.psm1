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
    [string[]]$Drive_Letter = @()
    [string[]]$WinPE_Drive_Letter = @()
    [string]$FolderPath_Automated_Setup_Client_Folders
    [string]$FolderPath_Automated_Setup_Client_Configs
    [string]$FolderPath_Automated_Setup_RegistryBackup
    [string]$FilePath_Automated_Setup_RegistryBackup
    [string]$FolderPath_Install_Software_Software_Configs
    [string]$FolderPath_Install_Software_ODT
    [string]$FolderPath_Install_Software_Profile_Software
    [string]$FolderPath_Install_Software_Standard_Software
    [string]$FilePath_TechTool_bat
    [string]$FilePath_TechTool_ps1
    [string]$FilePath_ImagingUSB_Module
    [string]$FilePath_AutomateSetup_ps1
    [string]$FilePath_AutomateSetup_Module
    [string]$FilePath_ConfigurePC_Module
    [string]$FilePath_InstallSoftware_Module
    [string]$FilePath_TuneUpPC_Module
    [string]$FilePath_TechTool_Module
    [boolean]$DevTool

    ImagingUSB() {
        $this.Exists()
    }

    [boolean]Exists() {
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
        $this.FolderPath_Automated_Setup_Client_Folders         = "$ImagingDrive\PC_Setup\Client_Folders"
        $this.FolderPath_Automated_Setup_Client_Configs         = "$ImagingDrive\PC_Setup\Client_Folders\_Client_Configs"
        $this.FolderPath_Automated_Setup_RegistryBackup         = "$ImagingDrive\sources\PC-Maintenance\1. Automated Setup\Setup\_Automated_Setup\_RegistryBackup"
        $this.FilePath_Automated_Setup_RegistryBackup           = "$ImagingDrive\sources\PC-Maintenance\1. Automated Setup\Setup\_Automated_Setup\_RegistryBackup\registry-backup020622.reg"
        $this.FolderPath_Install_Software_Software_Configs      = "$ImagingDrive\PC_Setup\_Software_Collection\_Software_Configs"
        $this.FolderPath_Install_Software_ODT                   = "$ImagingDrive\PC_Setup\_Software_Collection\ODT"
        $this.FolderPath_Install_Software_Profile_Software      = "$ImagingDrive\PC_Setup\_Software_Collection\Profile_Specific_Software"
        $this.FolderPath_Install_Software_Standard_Software     = "$ImagingDrive\PC_Setup\_Software_Collection\Standard_Software"
        $this.FilePath_TechTool_bat                             = "$ImagingDrive\TechTool-RAA.bat"
        $this.FilePath_TechTool_ps1                             = "$ImagingDrive\sources\TechTool.ps1"
        $this.FilePath_ImagingUSB_Module                        = "$ImagingDrive\sources\ImagingUSB-Maintenance\_modules\ImagingUSB\ImagingUSB.psm1"
        $this.FilePath_AutomateSetup_ps1                        = "$ImagingDrive\sources\PC-Maintenance\1. Automated Setup\Setup\_Automated_Setup\Automate-Setup.ps1"
        $this.FilePath_AutomateSetup_Module                     = "$ImagingDrive\sources\PC-Maintenance\_modules\Automate-Setup\Automate-Setup.psm1"
        $this.FilePath_ConfigurePC_Module                       = "$ImagingDrive\sources\PC-Maintenance\_modules\Configure-PC\Configure-PC.psm1"
        $this.FilePath_InstallSoftware_Module                   = "$ImagingDrive\sources\PC-Maintenance\_modules\Install-Software\Install-Software.psm1"
        $this.FilePath_TuneUpPC_Module                          = "$ImagingDrive\sources\PC-Maintenance\_modules\TuneUp-PC\TuneUp-PC.psm1"
        $this.FilePath_TechTool_Module                          = "$ImagingDrive\sources\TechTool\_modules\TechTool\TechTool.psm1"
        if (Test-Path "$ImagingDrive\sources\DevTool") {
            $this.DevTool = $true
        } else {
            $this.DevTool = $false
        }                                        
    }

    [void]hidden RemovePaths() {
        $this.FolderPath_Automated_Setup_Client_Folders         = $null
        $this.FolderPath_Automated_Setup_Client_Configs         = $null
        $this.FolderPath_Automated_Setup_RegistryBackup         = $null
        $this.FilePath_Automated_Setup_RegistryBackup           = $null
        $this.FolderPath_Install_Software_Software_Configs      = $null
        $this.FolderPath_Install_Software_ODT                   = $null
        $this.FolderPath_Install_Software_Profile_Software      = $null
        $this.FolderPath_Install_Software_Standard_Software     = $null
        $this.FilePath_TechTool_bat                             = $null
        $this.FilePath_TechTool_ps1                             = $null
        $this.FilePath_ImagingUSB_Module                        = $null
        $this.FilePath_AutomateSetup_ps1                        = $null
        $this.FilePath_AutomateSetup_Module                     = $null
        $this.FilePath_ConfigurePC_Module                       = $null
        $this.FilePath_InstallSoftware_Module                   = $null
        $this.FilePath_TuneUpPC_Module                          = $null
        $this.FilePath_TechTool_Module                          = $null
        $this.DevTool                                           = $false
    }
}
#endregion ImagingUSB Class
