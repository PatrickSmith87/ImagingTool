#################################################################################################################################################################
#################################################################################################################################################################
###                                                                                                                                                           ###
###                                                                  -=[ TechTool Module ]=-                                                                  ###
###                                                                                                                                                           ###
#################################################################################################################################################################
#################################################################################################################################################################

#region TechTool Class
class TechTool {
    [string]$PublicDesktop_Fo                                   = "C:\Users\Public\Desktop"
    [string]$CurrentUserDesktop                                 = "$env:USERPROFILE\Desktop"
    #[string]$TechTool_bat_Fi                                    = "C:\Users\Public\Desktop\TechTool-RAA.bat"
    #[string]$TechTool_ps1_Fi                                    = "C:\Users\Public\Desktop\sources\TechTool.ps1"
    [string]$TechTool_bat_Fi                                    = $this.CurrentUserDesktop + "\TechTool-RAA.bat"
    [string]$TechTool_ps1_Fi                                    = $this.CurrentUserDesktop + "\sources\TechTool.ps1"

    [string]$Modules_Fo                                         = "C:\Program Files\WindowsPowerShell\Modules"
    [string]$Module_ImagingUSB_Fi                               = $this.Modules_Fo +                        "\ImagingUSB\ImagingUSB.psm1"
    [string]$Module_AutomateSetup_Fi                            = $this.Modules_Fo +                        "\Automate-Setup\Automate-Setup.psm1"
    [string]$Module_ConfigurePC_Fi                              = $this.Modules_Fo +                        "\Configure-PC\Configure-PC.psm1"
    [string]$Module_InstallSoftware_Fi                          = $this.Modules_Fo +                        "\Install-Software\Install-Software.psm1"
    [string]$Module_TuneUpPC_Fi                                 = $this.Modules_Fo +                        "\TuneUp-PC\TuneUp-PC.psm1"
    [string]$Module_TechTool_Fi                                 = $this.Modules_Fo +                        "\TechTool\TechTool.psm1"
    [string]$Module_UpdatePC_Fi                                 = $this.Modules_Fo +                        "\Update-PC\Update-PC.psm1"

    [string]$Setup_Fo                                           =          "C:\Setup"
    [string]$Setup_AS_Client_Config_Fo                          = $this.Setup_Fo + "\_Automated_Setup\_Client_Config"
    [string]$Setup_AS_Client_Config_Repository_Fo               = $this.Setup_Fo + "\_Automated_Setup\_Client_Config\Repository"
    [string]$Setup_AS_RegistryBackup_Fo                         = $this.Setup_Fo + "\_Automated_Setup\_RegistryBackup"
    [string]$Setup_AS_RegistryBackup_Fi                         = $this.Setup_Fo + "\_Automated_Setup\_RegistryBackup\registry-backup020622.reg"
    [string]$Setup_AS_Status_Fo                                 = $this.Setup_Fo + "\_Automated_Setup\Status"
    [string]$Setup_AS_AutomateSetup_ps1                         = $this.Setup_Fo + "\_Automated_Setup\Automate-Setup.ps1"
    [string]$Setup_DriverCollection_Fo                          = $this.Setup_Fo + "\_Driver_Collection"
    [string]$Setup_ScriptCollection_Fo                          = $this.Setup_Fo + "\_Script_Collection"
    [string]$Setup_SoftwareCollection_Fo                        = $this.Setup_Fo + "\_Software_Collection"
    [string]$Setup_SoftwareCollection_Configs_Fo                = $this.Setup_Fo + "\_Software_Collection\_Software_Configs"
    [string]$Setup_SoftwareCollection_ODTSoftware_Fo            = $this.Setup_Fo + "\_Software_Collection\ODT"
    [string]$Setup_SoftwareCollection_ProfileSoftware_Fo        = $this.Setup_Fo + "\_Software_Collection\Profile_Specific_Software"
    [string]$Setup_SoftwareCollection_StandardSoftware_Fo       = $this.Setup_Fo + "\_Software_Collection\Standard_Software"
    [string]$Setup_SCOPEImageSetup_Fo                           = $this.Setup_Fo + "\SCOPE-Image_Setup"
    [string]$Setup_SCOPEImageSetup_PublicDesktop_Fo             = $this.Setup_Fo + "\SCOPE-Image_Setup\Public Desktop"
    [string]$Setup_SCOPEPostImageSetup_Fo                       = $this.Setup_Fo + "\SCOPE-POST_Image_Setup"
    [string]$Setup_SCOPEUserProfile_Fo                          = $this.Setup_Fo + "\SCOPE-User_Profile"
    
    [void] Update() {
        $USB = New-ImagingUSB
        if ($USB.Exists()) {
            if ($USB.DevTool) {
                $this.Push_Dev_Scripts()
                $this.Import_Modules()
            } else {
                $this.Download_GitHub_Repo()
                $this.Update_Local_Scripts()
                $this.Import_Modules()
                $this.Update_USB_Scripts()
            }
        } else {
            $this.Download_GitHub_Repo()
            $this.Update_Local_Scripts()
            $this.Import_Modules()
        }
    }

    [void] Download_GitHub_Repo() {
        # NEEDS TO WORK INDEPENDANTLY OF ANY (OTHER) MODULES OR OTHER PARENT\CHILD SCRIPTS

        [string]$Name = "ImagingTool"
        [string]$Author = "PatrickSmith87"
        [string]$Branch = "master"
        [string]$Location = "C:\temp"
        $this.Download_GitHub_Repo($Name,$Author,$Branch,$Location)
    }

    [void]hidden Download_GitHub_Repo([string]$Name,[string]$Author,[string]$Branch,[string]$Location) {
        # NEEDS TO WORK INDEPENDANTLY OF ANY (OTHER) MODULES OR OTHER PARENT\CHILD SCRIPTS 

        # Create the Zip file
        $ZipFile = "$Location\$Name.zip"
        New-Item $ZipFile -ItemType File -Force

        # Download the Zip file
        $ZipUrl = "https://github.com/$Author/$Name/archive/$Branch.zip"
        <#
        #$ZipUrl = "https://github.com/PatrickSmith87/ImagingTool/archive/master.zip"
        #$ZipUrl = "https://api.github.com/repos/PatrickSmith87/Setup/zipball/master" 
        #$ZipUrl = "https://api.github.com/repos/$Author/$Name/zipball/$Branch" 
        #>
        Invoke-RestMethod -Uri $ZipUrl -OutFile $ZipFile
 
        # Extract the Zip file
        Expand-Archive -Path $ZipFile -DestinationPath "$Location" -Force
     
        # Remove the Zip file
        Remove-Item -Path $ZipFile -Force

        Write-Host "Download GitHub Repo (to $Location): " -NoNewline; Write-Host "Complete" -ForegroundColor Green
    }

    [void] Update_Local_Scripts() {
        # NEEDS TO WORK INDEPENDANTLY OF ANY (OTHER) MODULES OR OTHER PARENT\CHILD SCRIPTS 

        [string]$Location = "C:\temp"
        [string]$Name = "ImagingTool"
        $this.Update_Local_Scripts($Location,$Name)
    }

    [void]hidden Update_Local_Scripts([string]$Location,[string]$Name) {
        # NEEDS TO WORK INDEPENDANTLY OF ANY (OTHER) MODULES OR OTHER PARENT\CHILD SCRIPTS 

        $Source = "$Location\$Name-main"

        $this.Restore("$Source\TechTool-RAA.bat",$this.TechTool_bat_Fi,"Copy")
        $this.Restore("$Source\TechTool.ps1",$this.TechTool_ps1_Fi,"Copy")
        $this.Restore("$Source\ImagingUSB.psm1",$this.Module_ImagingUSB_Fi,"Copy")
        $this.Restore("$Source\Automate-Setup.ps1",$this.Setup_AS_AutomateSetup_ps1,"Copy")
        $this.Restore("$Source\Automate-Setup.psm1",$this.Module_AutomateSetup_Fi,"Copy")
        $this.Restore("$Source\Configure-PC.psm1",$this.Module_ConfigurePC_Fi,"Copy")
        $this.Restore("$Source\Install-Software.psm1",$this.Module_InstallSoftware_Fi,"Copy")
        $this.Restore("$Source\TuneUp-PC.psm1",$this.Module_TuneUpPC_Fi,"Copy")
        $this.Restore("$Source\TechTool.psm1",$this.Module_TechTool_Fi,"Copy")
        $this.Restore("$Source\Update-PC.psm1",$this.Module_UpdatePC_Fi,"Copy")

        Write-Host "Update Local Scripts: " -NoNewline; Write-Host "Complete" -ForegroundColor Green
    }

    [void]hidden Restore([string]$SourceFile,[string]$DestinationFile,[string]$CopyORMove) {
    <# This function does three things
            1. Verify source file exists
            2. Remove Destination File if exists
            3. Move or Copy file #>
        #Write-Host "`$SourceFile = $SourceFile"
        #Write-Host "`$DestinationFile = $DestinationFile"
        If (($CopyORMove -eq "Copy") -or ($CopyORMove -eq "Move")) {
            If (Test-Path $SourceFile) { #1. Verify source file exists
                If (Test-Path $DestinationFile) {Remove-Item $DestinationFile -Force} #2. Remove Destination File if exists
                $PathPieces = $DestinationFile.Split('\')
                $FolderPath = $PathPieces[0]
                $x=1
                foreach ($Piece in $PathPieces) {  # Breaking down the destination file path and then rebuilding it without the filename so that we get a path to it's parent folder
                    If ($x -lt ($PathPieces.Count - 1)) {
                        $FolderPath = $FolderPath + "\" + $PathPieces[$x]
                        $x++
                    }
                }
                If (!(Test-Path $FolderPath)) {New-Item $FolderPath -ItemType Directory}
                If ($CopyORMove -eq "Copy") {
                    Copy-Item -Path $SourceFile -Destination $DestinationFile -Force
                    #Write-Host "Copied " -NoNewline; Write-Host "$SourceFile" -ForegroundColor Cyan -NoNewline; Write-Host " to " -NoNewline; Write-Host "$DestinationFile" -ForegroundColor Cyan
                } elseif ($CopyORMove -eq "Move") {
                    Move-Item -Path $SourceFile -Destination $DestinationFile -Force
                    #Write-Host "Moved " -NoNewline; Write-Host "$SourceFile" -ForegroundColor Cyan -NoNewline; Write-Host " to " -NoNewline; Write-Host "$DestinationFile" -ForegroundColor Cyan
                }
            } else {
                Write-Host "`n!!WARNING!!!" -ForegroundColor Red -NoNewline; Write-Host " Source file not found: $SourceFile"
                Write-Host "-No Copy\Move action taken`n" -ForegroundColor Yellow
            }
        } else {
            Write-Host "`n!!WARNING!!!" -ForegroundColor Red -NoNewline; Write-Host ' The 3rd parameter, "CopyorMove", MUST be defined as either "Copy" or "Move"'
            Write-Host "-No Copy\Move action taken`n" -ForegroundColor Yellow
        }
    }

    [void] Import_Modules() {
        Import-Module ImagingUSB -WarningAction SilentlyContinue -Force | Out-Null
        Import-Module Automate-Setup -WarningAction SilentlyContinue -Force | Out-Null
        Import-Module Configure-PC -WarningAction SilentlyContinue -Force | Out-Null
        Import-Module Install-Software -WarningAction SilentlyContinue -Force | Out-Null
        Import-Module TuneUp-PC -WarningAction SilentlyContinue -Force | Out-Null
        Import-Module TechTool -WarningAction SilentlyContinue -Force | Out-Null
        Import-Module Update-PC -WarningAction SilentlyContinue -Force | Out-Null

        Write-Host "Import Modules: " -NoNewline; Write-Host "Complete" -ForegroundColor Green
    }

    [void] Update_USB_Scripts() {
        [string]$Location = "C:\temp"
        [string]$Name = "ImagingTool"
        $this.Update_USB_Scripts($Location,$Name)
    }

    [void]hidden Update_USB_Scripts([string]$Location,[string]$Name) {
        # Requires ImagingUSB module
        
        $GitHubRepo = "$Location\$Name-main"
        $USB = New-ImagingUSB

        if ($USB.Exists()) {
            $this.Restore("$GitHubRepo\WinPE-Menu.ps1",$USB.WinPE_Menu_ps1_Fi,"Move")
            $this.Restore("$GitHubRepo\ImagingUSB.psm1",$USB.Module_USB_Fi,"Move")
            $this.Restore("$GitHubRepo\Automate-Setup.ps1",$USB.PCMaint_AS_AutomateSetup_ps1_Fi,"Move")
            $this.Restore("$GitHubRepo\Automate-Setup.psm1",$USB.Module_AutomateSetup_Fi,"Move")
            $this.Restore("$GitHubRepo\Configure-PC.psm1",$USB.Module_ConfigurePC_Fi,"Move")
            $this.Restore("$GitHubRepo\Install-Software.psm1",$USB.Module_InstallSoftware_Fi,"Move")
            $this.Restore("$GitHubRepo\TuneUp-PC.psm1",$USB.Module_TuneUpPC_Fi,"Move")
            $this.Restore("$GitHubRepo\Update-PC.psm1",$USB.Module_UpdatePC_Fi,"Move")
            $this.Restore("$GitHubRepo\TechTool.psm1",$USB.Module_TechTool_Fi,"Move")
            $this.Restore("$GitHubRepo\TechTool.ps1",$USB.TechTool_ps1_Fi,"Move")
            $this.Restore("$GitHubRepo\TechTool-RAA.bat",$USB.TechTool_bat_Fi,"Move")

            Write-Host "Update USB Scripts: " -NoNewline; Write-Host "Complete" -ForegroundColor Green
        } else {
            Write-Host "Imaging USB not detected - " -NoNewline; Write-Host "Not Updated" -ForegroundColor Red
        }
    }

    [void] Push_Dev_Scripts() {
        # Requires ImagingUSB module
        $USB = New-ImagingUSB

        if ($USB.Exists()) {            
            #$this.Restore($USB.WinPE_Menu_ps1_Fi,"$this.,"Copy")
            $this.Restore($USB.Module_AutomateSetup_Fi,$this.Module_AutomateSetup_Fi,"Copy")
            $this.Restore($USB.Module_ConfigurePC_Fi,$this.Module_ConfigurePC_Fi,"Copy")
            $this.Restore($USB.Module_InstallSoftware_Fi,$this.Module_InstallSoftware_Fi,"Copy")
            $this.Restore($USB.Module_TuneUpPC_Fi,$this.Module_TuneUpPC_Fi,"Copy")
            $this.Restore($USB.Module_TechTool_Fi,$this.Module_TechTool_Fi,"Copy")
            $this.Restore($USB.Module_USB_Fi,$this.Module_ImagingUSB_Fi,"Copy")
            $this.Restore($USB.Module_UpdatePC_Fi,$this.Module_UpdatePC_Fi,"Copy")
            $this.Restore($USB.PCMaint_AS_AutomateSetup_ps1_Fi,$this.Setup_AS_AutomateSetup_ps1,"Copy")
            $this.Restore($USB.TechTool_ps1_Fi,$this.TechTool_ps1_Fi,"Copy")
            $this.Restore($USB.TechTool_bat_Fi,$this.TechTool_bat_Fi,"Copy")
            Write-Host "Push Dev Scripts: " -NoNewline; Write-Host "Complete" -ForegroundColor Green
        } else {
            Write-Host "Imaging USB not detected - " -NoNewline; Write-Host "Not Updated" -ForegroundColor Red
        }
    }

    [void] Update_Local_GitHubRepo() {
        $this.Update_Local_GitHubRepo("C:\Git-Repositories\ImagingTool")
    }
    
    [void]hidden Update_Local_GitHubRepo([string]$RepoPath) {
        $GitHubRepo = $RepoPath
        $USB = New-ImagingUSB
        Write-Host "$USB"

        if (Test-Path $GitHubRepo) {
            if ($USB.Exists()) {
                $this.Restore($USB.WinPE_Menu_ps1_Fi,"$GitHubRepo\WinPE-Menu.ps1","Copy")
                $this.Restore($USB.Module_USB_Fi,"$GitHubRepo\ImagingUSB.psm1","Copy")
                $this.Restore($USB.PCMaint_AS_AutomateSetup_ps1_Fi,"$GitHubRepo\Automate-Setup.ps1","Copy")
                $this.Restore($USB.Module_AutomateSetup_Fi,"$GitHubRepo\Automate-Setup.psm1","Copy")
                $this.Restore($USB.Module_ConfigurePC_Fi,"$GitHubRepo\Configure-PC.psm1","Copy")
                $this.Restore($USB.Module_InstallSoftware_Fi,"$GitHubRepo\Install-Software.psm1","Copy")
                $this.Restore($USB.Module_TuneUpPC_Fi,"$GitHubRepo\TuneUp-PC.psm1","Copy")
                $this.Restore($USB.Module_TechTool_Fi,"$GitHubRepo\TechTool.psm1","Copy")
                $this.Restore($USB.Module_UpdatePC_Fi,"$GitHubRepo\Update-PC.psm1","Copy")
                $this.Restore($USB.TechTool_ps1_Fi,"$GitHubRepo\TechTool.ps1","Copy")
                $this.Restore($USB.TechTool_bat_Fi,"$GitHubRepo\TechTool-RAA.bat","Copy")
                Write-Host "Files Updated to GitHub Repo Folder: $GitHubRepo" -ForegroundColor Green
            } else {
                Write-Host "Imaging USB not found"
            }
        } else {
            Write-Host "GitHubRepo ($GitHubRepo) not found"
        }
    }

    [void] DisplayMenu() {
        $this.Update()
        Enter-Main_Menu
    }
}

function New-TechTool {
    [TechTool]::new()
} Export-ModuleMember -Function New-TechTool

function Update-TechTool {
    $USB = New-ImagingUSB
    if ($USB.Exists()) {
        if ($USB.DevTool) {
            $TechTool.Push_Dev_Scripts()
            $TechTool.Import_Modules()
        } else {
            $TechTool.Download_GitHub_Repo()
            $TechTool.Update_Local_Scripts()
            $TechTool.Import_Modules()
            $TechTool.Update_USB_Scripts()
        }
    } else {
        $TechTool.Download_GitHub_Repo()
        $TechTool.Update_Local_Scripts()
        $TechTool.Import_Modules()
    }
} Export-ModuleMember -Function Update-TechTool
#endregion TechTool Class

#region Module Variables
# !!ImagingUSB module may not exist yet, so can't relie on using the ImagingUSB class!!
# Get USB Drive
$USB = New-ImagingUSB
$TechTool = New-TechTool

# VARIABLES
# -=[ IMAGE MAINTENANCE ]=-
$ImageMaintenance_DOWNLOAD_Latest_ESD_File_Fi         = $USB.ImageMaint_DOWNLOADLatestESDFile_ps1_Fi
$ImageMaintenance_EXTRACT_WIM_from_ESD_Fi             = $USB.ImageMaint_EXTRACTWIMfromESD_ps1_Fi
$ImageMaintenance_CREATE_Modded_WIM_Fi                = $USB.ImageMaint_CREATEModdedWIM_ps1_Fi

# -=[ Imaging USB MAINTENANCE ]=-
$USBMaintenance_CREATE_AutoDeploy_Package_Fi          = $USB.USBMaint_CREATEAutoDeployPackage_bat_Fi
#endregion Module Variables

#region Menu Functions

#region Main Menu
#########################################################################################################################################
############################################################### MAIN MENU ###############################################################
#########################################################################################################################################

function Enter-Main_Menu {
    #Clear-Host
    DO {
        [int]$StepNum = 1
        Write-Host "`n-=[ Main Menu ]=-" -ForegroundColor DarkGray
        Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
        Write-Host "`n    $StepNum. Enter " -NoNewline; Write-Host "PC Maintenance " -NoNewline -ForegroundColor Cyan; Write-Host "menu"
        Write-Host "        -Enter this menu to access several scripts that you can use to;" -ForegroundColor DarkGray
        Write-Host "              +Setup a PC               +Install Software" -ForegroundColor DarkGray
        Write-Host "              +Update the OS            +Cleanup System Drive" -ForegroundColor DarkGray
        Write-Host "              +Migrate User Profiles    +Etc.." -ForegroundColor DarkGray
        Write-Host "        -This is the menu you will use 99% of the time" -ForegroundColor Green
        if ($USB.Exists()) {
            $StepNum++
            Write-Host "`n    $StepNum. Enter " -NoNewline; Write-Host "Image Maintenance " -NoNewline -ForegroundColor DarkCyan; Write-Host "menu"
            Write-Host "        -Enter this menu to create a fresh .wim file of the latest Win10 OS version" -ForegroundColor DarkGray
            Write-Host "        -This should only need to be done every 6-12 months" -ForegroundColor Yellow
        }
        If ($USB.DevTool) {
            $StepNum++
            Write-Host "`n    $StepNum. Enter " -NoNewline; Write-Host "Imaging Tool Maintenance " -NoNewline -ForegroundColor DarkGray; Write-Host "menu"
            Write-Host "        -Enter this menu for Maintenance tasks related to this USB Tool" -ForegroundColor DarkGray
            Write-Host "        -This menu is intended for developers. An average tech should" -ForegroundColor Yellow
            Write-Host "         not need to use this under normal circumstances" -ForegroundColor Yellow
        }
        $StepNum++
        Write-Host "`n    $StepNum. " -NoNewline; Write-Host "EXIT SCRIPT" -ForegroundColor DarkRed
        $choice = Read-Host -Prompt "`nEnter a number, 1 thru $StepNum"
        $choice = $choice -as [int]
    } UNTIL (($choice -ge 1) -and ($choice -le $StepNum))
    Switch ($choice) {
        1 {Clear-Host; Enter-PCMaintenance_Menu}
        2 {Clear-Host; Enter-ImageMaintenance_Menu}
        3 {Clear-Host; Enter-ImagingUSBMaintenance_Menu}
        4 {EXIT}
    }
} Export-ModuleMember -Function Enter-Main_Menu
#endregion Main Menu

#region PC Maintenance
#########################################################################################################################################
############################################################ PC Maintenance #############################################################
#########################################################################################################################################
function Enter-PCMaintenance_Menu {
    DO {
        Write-Host "`n-=[ PC Maintenance ]=-" -ForegroundColor DarkGray
        Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
        Write-Host "0. " -NoNewline; Write-Host "BACK TO MAIN MENU" -ForegroundColor DarkGray
        Write-Host "1. Enter " -NoNewline; Write-Host "Automated Setup " -NoNewline -ForegroundColor DarkCyan; Write-Host "menu"
        Write-Host "2. Enter " -NoNewline; Write-Host "TuneUp PC " -NoNewline -ForegroundColor DarkYellow; Write-Host "menu" -NoNewline; Write-Host " **WARNING - This is not fully functional yet" -ForegroundColor Red
        Write-Host "3. Enter " -NoNewline; Write-Host "Configure Automatic Sign-in " -NoNewline -ForegroundColor DarkCyan; Write-Host "menu"
        Write-Host "4. " -NoNewline; Write-Host "Standardize PC " -ForegroundColor DarkCyan
        Write-Host "5. Enter " -NoNewline; Write-Host "Install Software " -NoNewline -ForegroundColor DarkCyan; Write-Host "menu"
        Write-Host "6. " -NoNewline; Write-Host "Update PC" -ForegroundColor DarkCyan
        Write-Host "7. " -NoNewline; Write-Host "Cleanup System Drive" -ForegroundColor DarkCyan
        Write-Host "8. " -NoNewline; Write-Host "Migrate User Profile" -ForegroundColor DarkCyan
        Write-Host "9. " -NoNewline; Write-Host "Sync Folder" -ForegroundColor DarkCyan
        Write-Host "10. Pull " -NoNewline; Write-Host "Intune " -NoNewline -ForegroundColor DarkYellow; Write-Host "Hardware ID " -ForegroundColor DarkCyan
        Write-Host "11. " -NoNewline; Write-Host "EXIT SCRIPT" -ForegroundColor DarkRed
        $choice = Read-Host -Prompt "Enter a number, 0 thru 11"
        $choice = $choice -as [int]
    } UNTIL (($choice -ge 0) -and ($choice -le 11))
    Switch ($choice) {
        0 {Clear-Host; Enter-Main_Menu}
        1 {Clear-Host; Enter-AutomatedSetup_submenu}
        2 {Clear-Host; Enter-TuneUpPC_submenu}
        3 {Clear-Host; Enter-ConfigureAutomaticSignIn_submenu}
        4 {Clear-Host; Set-PCDefaultSettings}
        5 {Clear-Host; Enter-InstallSoftware_submenu}
        6 {Clear-Host; Update-PC}
        7 {Clear-Host; Cleanup-SystemDrive}
        8 {Clear-Host; Start-Process powershell -ArgumentList '-command Sync-UserProfile' -WindowStyle Maximized}
        9 {Clear-Host; Sync-Folder}
        10 {Clear-Host; Get-IntuneHWID}
        11 {EXIT}
    }
    # Recursivly call the PC Maintenance Menu
    Enter-PCMaintenance_Menu
} Export-ModuleMember -Function Enter-PCMaintenance_Menu

function Enter-AutomatedSetup_submenu {    
    DO {
        Write-Host "`n-=[ Automated Setup submenu ]=-" -ForegroundColor DarkGray
        Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
        Write-Host "0. " -NoNewline; Write-Host "BACK TO PREVIOUS MENU" -ForegroundColor DarkGray
        Write-Host "1. " -NoNewline; Write-Host "INJECT " -NoNewline -ForegroundColor Cyan; Write-Host "Automated Setup program into current OS"
        Write-Host "2. " -NoNewline; Write-Host "START " -NoNewline -ForegroundColor Green; Write-Host "Automated Setup program on current OS"
        Write-Host "3. " -NoNewline; Write-Host "STOP " -NoNewline -ForegroundColor Red; Write-Host "Automated Setup program on current OS"
        Write-Host "4. " -NoNewline; Write-Host "REMOVE " -NoNewline -ForegroundColor DarkCyan; Write-Host "Automated Setup program from current OS"
        Write-Host "5. " -NoNewline; Write-Host "READ " -NoNewline -ForegroundColor Cyan; Write-Host "Client Config"
        Write-Host "6. " -NoNewline; Write-Host "CREATE " -NoNewline -ForegroundColor Cyan; Write-Host "Client Config"
        Write-Host "7. " -NoNewline; Write-Host "EXIT SCRIPT" -ForegroundColor DarkRed
        $choice = Read-Host -Prompt "Enter a number, 0 thru 7"
        $choice = $choice -as [int]
    } UNTIL (($choice -ge 0) -and ($choice -le 7))
    Switch ($choice) {
        0 {Clear-Host; Enter-PCMaintenance_Menu}
        1 {
            Clear-Host
            Write-Host "`nInjecting the Automated Setup program in the background..." -ForegroundColor Green
            Write-Host "Note: If the Automated Setup program is already on the current OS, it will be" -ForegroundColor Yellow
            Write-Host "      updated to the version on the Imaging Tool if it is newer" -ForegroundColor Yellow
            Write-Host "-To kick off the Automated Setup program, run the file on the desktop called"
            Write-Host "    Start-AutomatedSetup-RAA (RAA - Run As Admin)"
            Write-Host '-Or select "START Automated Setup program on current OS" in the Automated Setup'
            Write-Host '    submenu'
            #Start-Process $FilePath_USB_Automated_Setup_INJECT_Scripts_Script
            Start-Process powershell -ArgumentList '-command Inject-AutomatedSetupScripts' -WindowStyle Minimized
        }
        2 {Clear-Host; Start-AutomatedSetup}
        3 {Clear-Host; Stop-AutomatedSetup}
        4 {Clear-Host; Remove-Automated_Setup_Files}
        5 {Clear-Host; Read-ClientConfig}
        6 {Clear-Host; Create-ClientConfig}
        7 {EXIT}
    }
    
    #Recursivly call the submenu
    Enter-AutomatedSetup_submenu
} Export-ModuleMember -Function Enter-AutomatedSetup_submenu # End of Enter-AutomatedSetup_submenu

function Enter-TuneUpPC_submenu {
    DO {
        Write-Host "`n-=[ TuneUp PC submenu ]=-" -ForegroundColor DarkGray
        Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
        Write-Host "0. " -NoNewline; Write-Host "BACK TO PREVIOUS MENU" -ForegroundColor DarkGray
        Write-Host "1. " -NoNewline; Write-Host "INJECT " -NoNewline -ForegroundColor Cyan; Write-Host "TuneUp program into current OS"
        Write-Host "2. " -NoNewline; Write-Host "START " -NoNewline -ForegroundColor Green; Write-Host "TuneUp program on current OS"
        Write-Host "3. " -NoNewline; Write-Host "STOP " -NoNewline -ForegroundColor Red; Write-Host "TuneUp program on current OS"
        Write-Host "4. " -NoNewline; Write-Host "EXIT SCRIPT" -ForegroundColor DarkRed
        $choice = Read-Host -Prompt "Enter a number, 0 thru 4"
        $choice = $choice -as [int]
    } UNTIL (($choice -ge 0) -and ($choice -le 4))
    Switch ($choice) {
        0 {Clear-Host; Enter-PCMaintenance_Menu}
        1 {Clear-Host; Inject-TuneUp_PC}
        2 {Clear-Host; Start-TuneUp_PC}
        3 {Clear-Host; Stop-TuneUp_AtLogon}
        4 {EXIT}
    }

    #Recursivly call the submenu
    Enter-TuneUpPC_submenu
} Export-ModuleMember -Function Enter-TuneUpPC_submenu # End of Enter-TuneUpPC_submenu

function Enter-ConfigureAutomaticSignIn_submenu {
    DO {
        Write-Host "`n-=[ Configure Automatic Sign-In submenu ]=-" -ForegroundColor DarkGray
        Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
        Write-Host "0. " -NoNewline; Write-Host "BACK TO PREVIOUS MENU" -ForegroundColor DarkGray
        Write-Host "1. " -NoNewline; Write-Host "CONFIGURE " -NoNewline -ForegroundColor Green; Write-Host "Automatic Sign-on"
        Write-Host "2. " -NoNewline; Write-Host "DISABLE " -NoNewline -ForegroundColor Red; Write-Host "Automatic Sign-on"
        Write-Host "3. " -NoNewline; Write-Host "EXIT SCRIPT" -ForegroundColor DarkRed
        $choice = Read-Host -Prompt "Enter a number, 0 thru 3"
        $choice = $choice -as [int]
    } UNTIL (($choice -ge 0) -and ($choice -le 3))
    Switch ($choice) {
        0 {Clear-Host; Enter-PCMaintenance_Menu}
        1 {Clear-Host; Enable-AutoLogon}
        2 {Clear-Host; Remove-AutoLogon}
        3 {EXIT}
    }
    #Recursivly call the submenu
    Enter-ConfigureAutomaticSignIn_submenu
} Export-ModuleMember -Function Enter-ConfigureAutomaticSignIn_submenu # End of Enter-ConfigureAutomaticSignIn_submenu

function Enter-InstallSoftware_submenu {
    DO {
        Write-Host "`n-=[ Install Software submenu ]=-" -ForegroundColor DarkGray
        Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
        Write-Host "0. " -NoNewline; Write-Host "BACK TO PREVIOUS MENU" -ForegroundColor DarkGray
        Write-Host " 1. " -NoNewline; Write-Host "INSTALL " -NoNewline -ForegroundColor Cyan; Write-Host "Image Compatible Software"
        Write-Host "    -Includes Browser, PDF Viewer, o365, VPN, -AND- Collaboration Software"
        Write-Host "    -Note: These are softwares that can be installed on an image"
        Write-Host " 2. " -NoNewline; Write-Host "INSTALL " -NoNewline -ForegroundColor Cyan; Write-Host "Browser"
        Write-Host " 3. " -NoNewline; Write-Host "INSTALL " -NoNewline -ForegroundColor Cyan; Write-Host "PDF Viewer"
        Write-Host " 4. " -NoNewline; Write-Host "INSTALL " -NoNewline -ForegroundColor Cyan; Write-Host "o365"
        Write-Host " 5. " -NoNewline; Write-Host "INSTALL " -NoNewline -ForegroundColor Cyan; Write-Host "VPN"
        Write-Host " 6. " -NoNewline; Write-Host "INSTALL " -NoNewline -ForegroundColor Cyan; Write-Host "Collaboration Software"
        Write-Host " 7. " -NoNewline; Write-Host "INSTALL " -NoNewline -ForegroundColor Cyan; Write-Host "File Share Software"
        Write-Host " 8. " -NoNewline; Write-Host "INSTALL " -NoNewline -ForegroundColor Cyan; Write-Host "a Driver Update Assistant"
        Write-Host " 9. " -NoNewline; Write-Host "INSTALL " -NoNewline -ForegroundColor Cyan; Write-Host "Post-Image\Client-Specific Software"
        Write-Host "10. " -NoNewline; Write-Host "INSTALL " -NoNewline -ForegroundColor Cyan; Write-Host "Profile-Specific Software"
        Write-Host "11. " -NoNewline; Write-Host "READ " -NoNewline -ForegroundColor Cyan; Write-Host "Software Config"
        Write-Host "12. " -NoNewline; Write-Host "CREATE " -NoNewline -ForegroundColor Cyan; Write-Host "Software Config"
        Write-Host "13. " -NoNewline; Write-Host "EXIT SCRIPT" -ForegroundColor DarkRed
        $choice = Read-Host -Prompt "        Enter a number, 0 thru 13"
        $choice = $choice -as [int]
    } UNTIL (($choice -ge 0) -and ($choice -le 13))
    Switch ($choice) {
        0 {Clear-Host; Enter-PCMaintenance_Menu}
        1 {Clear-Host; Install-Image_Softwares}
        2 {Clear-Host; Choose-Browser}
        3 {Clear-Host; Choose-PDF_Viewer}
        4 {Clear-Host; Choose-o365}
        5 {Clear-Host; Choose-VPN}
        6 {Clear-Host; Choose-Collaboration_Software}
        7 {Clear-Host; Choose-FileShareApp}
        8 {Clear-Host; Install-DriverUpdateAssistant}
        9 {Clear-Host; Write-Host "This doesn't do anything yet"}
        10 {Clear-Host; Write-Host "This doesn't do anything yet"}
        11 {Clear-Host; Read-SoftwareConfig}
        12 {Clear-Host; Create-SoftwareConfig}
        13 {EXIT}
    }
    #Recursivly call the submenu
    Enter-InstallSoftware_submenu
} Export-ModuleMember -Function Enter-InstallSoftware_submenu # End of Enter-InstallSoftware_submenu
#endregion PC Maintenance

#region Image Maintenance
#########################################################################################################################################
########################################################### Image Maintenance ###########################################################
#########################################################################################################################################
function Enter-ImageMaintenance_Menu {
    DO {
        Write-Host "`n-=[ Image Maintenance ]=-" -ForegroundColor DarkGray
        Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
        Write-Host "0. " -NoNewline; Write-Host "BACK TO MAIN MENU" -ForegroundColor DarkGray
        Write-Host "1. " -NoNewline; Write-Host "DOWNLOAD" -NoNewline -ForegroundColor Cyan; Write-Host " latest .esd file"
        Write-Host "2. " -NoNewline; Write-Host "EXTRACT" -NoNewline -ForegroundColor Cyan; Write-Host " basic .wim from .esd"
        Write-Host "3. " -NoNewline; Write-Host "CREATE" -NoNewline -ForegroundColor Cyan; Write-Host " **MODDED** .WIM (Injects Automated Setup into basic .WIM)"
        Write-Host "4. " -NoNewline; Write-Host "EXIT SCRIPT" -ForegroundColor DarkRed
        $choice = Read-Host -Prompt "    Enter a number, 0 thru 4"
        $choice = $choice -as [int]
    } UNTIL (($choice -ge 0) -and ($choice -le 4))
    Switch ($choice) {
        0 {Clear-Host; Enter-Main_Menu}
        1 {Clear-Host; & $ImageMaintenance_DOWNLOAD_Latest_ESD_File_Fi}
        2 {Clear-Host; & $ImageMaintenance_EXTRACT_WIM_from_ESD_Fi}
        3 {Clear-Host; & $ImageMaintenance_CREATE_Modded_WIM_Fi}
        4 {EXIT}
    }
    # Recursivly call the Image Maintenance Menu
    Enter-ImageMaintenance_Menu
} Export-ModuleMember -Function Enter-ImageMaintenance_Menu
#endregion Image Maintenance

#region Imaging USB Maintenance
########################################################################################################################################
########################################################## USB Maintenance #############################################################
########################################################################################################################################
function Enter-ImagingUSBMaintenance_Menu {
    DO {
        Write-Host "`n-=[ Tool Maintenance ]=-" -ForegroundColor DarkGray
        Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
        Write-Host "0. " -NoNewline; Write-Host "BACK TO MAIN MENU" -ForegroundColor DarkGray
        Write-Host "1. " -NoNewline; Write-Host "BACKUP " -NoNewline -ForegroundColor Green; Write-Host "Imaging Drive (Minus Images - Can save a lot of time and local disk space)"
        Write-Host "2. " -NoNewline; Write-Host "BACKUP " -NoNewline -ForegroundColor Green; Write-Host "Imaging Drive"
        Write-Host "3. " -NoNewline; Write-Host "CREATE " -NoNewline -ForegroundColor Cyan; Write-Host "AutoDeploy Imaging USB Install Package"
        Write-Host "4. " -NoNewline; Write-Host "CREATE " -NoNewline -ForegroundColor Cyan; Write-Host "Standard Imaging USB Install Package"
        Write-Host "5. " -NoNewline; Write-Host "TRANSFER " -NoNewline -ForegroundColor Cyan; Write-Host "WinPE USB Package to Axxys Storage"
        Write-Host "6. " -NoNewline; Write-Host "RESTORE " -NoNewline -ForegroundColor DarkCyan; Write-Host "Imaging Drive (Minus Images - Can save a lot of time and local disk space)"
        Write-Host "7. " -NoNewline; Write-Host "RESTORE " -NoNewline -ForegroundColor DarkCyan; Write-Host "Imaging Drive"
        Write-Host "8. " -NoNewline; Write-Host "UPDATE " -NoNewline -ForegroundColor DarkYellow; Write-Host "Imaging Tool"
        Write-Host "9. " -NoNewline; Write-Host "UPDATE " -NoNewline -ForegroundColor DarkYellow; Write-Host "GitHub Repository"
        Write-Host "10. " -NoNewline; Write-Host "EXIT SCRIPT" -ForegroundColor DarkRed
        $choice = Read-Host -Prompt "Enter a number, 0 thru 10"
        $choice = $choice -as [int]
    } UNTIL (($choice -ge 0) -and ($choice -le 10))
    Switch ($choice) {
        0 {Clear-Host; Enter-Main_Menu}
        1 {
            Clear-Host
            Write-Host "`nRunning the script in the background..." -ForegroundColor Green
            Write-Host "Logfile: " -NoNewline; Write-Host "C:\ImagingUSB_Backup_Log.txt`n" -ForegroundColor Cyan
            Start-Process powershell -ArgumentList '-command Backup-ImagingUSB -WithoutImages' -WindowStyle Minimized
        }
        2 {
            Clear-Host
            Write-Host "`nRunning the script in the background..." -ForegroundColor Green
            Write-Host "Logfile: " -NoNewline; Write-Host "C:\ImagingUSB_Backup_Log.txt`n" -ForegroundColor Cyan
            Start-Process powershell -ArgumentList '-command Backup-ImagingUSB -WithoutImages' -WindowStyle Minimized
        }
        3 {Clear-Host; New-AutoDeploy_ImagingUSB_InstallPackage}
        4 {Clear-Host; New-Standard_ImagingUSB_InstallPackage}
        5 {Clear-Host; Move-Imaging_USB_Package_To_Axxys_Storage}
        6 {
            Clear-Host
            Write-Host "`nRunning the script in the background..." -ForegroundColor Green
            Write-Host "Logfile: " -NoNewline; Write-Host "C:\ImagingUSB_Restore_Log.txt`n" -ForegroundColor Cyan
            Start-Process powershell -ArgumentList '-command Restore-ImagingUSB -WithoutImages' -WindowStyle Minimized
        }
        7 {
            Clear-Host
            Write-Host "`nRunning the script in the background..." -ForegroundColor Green
            Write-Host "Logfile: " -NoNewline; Write-Host "C:\ImagingUSB_Restore_Log.txt`n" -ForegroundColor Cyan
            Start-Process powershell -ArgumentList '-command Restore-ImagingUSB' -WindowStyle Minimized
        }
        8 {Clear-Host; $TechTool.Download_GitHub_Repo() ;$TechTool.Update_USB_Scripts()}
        9 {Clear-Host; $TechTool.Update_Local_GitHubRepo()}
        10 {EXIT}
    }
    Enter-ImagingUSBMaintenance_Menu
} Export-ModuleMember -Function Enter-ImagingUSBMaintenance_Menu
#endregion Imaging USB Maintenance

#endregion Menu Functions