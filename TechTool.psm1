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
    [string]$Module_ConfigureProfile_Fi                         = $this.Modules_Fo +                        "\Configure-Profile\Configure-Profile.psm1"
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
        $this.Restore("$Source\Configure-Profile.psm1",$this.Module_ConfigureProfile_Fi,"Copy")
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
        Import-Module Configure-Profile -WarningAction SilentlyContinue -Force | Out-Null
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
            $this.Restore("$GitHubRepo\Configure-Profile.psm1",$USB.Module_ConfigureProfile_Fi,"Move")
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
            $this.Restore($USB.Module_ConfigureProfile_Fi,$this.Module_ConfigureProfile_Fi,"Copy")
            $this.Restore($USB.Module_InstallSoftware_Fi,$this.Module_InstallSoftware_Fi,"Copy")
            $this.Restore($USB.Module_TuneUpPC_Fi,$this.Module_TuneUpPC_Fi,"Copy")
            $this.Restore($USB.Module_TechTool_Fi,$this.Module_TechTool_Fi,"Copy")
            $this.Restore($USB.Module_USB_Fi,$this.Module_ImagingUSB_Fi,"Copy")
            $this.Restore($USB.Module_UpdatePC_Fi,$this.Module_UpdatePC_Fi,"Copy")
            $this.Restore($USB.PCMaint_AS_AutomateSetup_ps1_Fi,$this.Setup_AS_AutomateSetup_ps1,"Copy")
            $this.Restore($USB.TechTool_ps1_Fi,$this.TechTool_ps1_Fi,"Copy")
            $this.Restore($USB.TechTool_bat_Fi,$this.TechTool_bat_Fi,"Copy")
            Write-Host "`nPush Dev Scripts: " -NoNewline; Write-Host "Complete" -ForegroundColor Green
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
                $this.Restore($USB.Module_ConfigureProfile_Fi,"$GitHubRepo\Configure-Profile.psm1","Copy")
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
        1 {Clear-Host; Download-LatestESDFile}
        2 {Clear-Host; Extract-WIMfromESD}
        3 {Clear-Host; Create-ModdedWIM}
        4 {EXIT}
    }
    # Recursivly call the Image Maintenance Menu
    Enter-ImageMaintenance_Menu
} Export-ModuleMember -Function Enter-ImageMaintenance_Menu

function Download-LatestESDFile {
    # Get USB Drive
    foreach ($Drive_Letter in (Get-PSDrive -PSProvider FileSystem).Name) {
        $Test_Path = "$Drive_Letter" + ":\PC_Setup"
        If (Test-Path $Test_Path) {
            $USB_Drive = "$Drive_Letter" + ":"
        }
    }

    # Inform user before continuing
    Write-Host "`n!!!WARNINGS!!!" -ForegroundColor Red
    Write-Host "-Most of this is a manual process."
    Write-Host "-Also, you will need a USB device (8GB or higher) in order to create a Microsoft Windows"
    Write-Host "  10 Installation Tool."
    Write-Host "-You will need to do this whenever a new Windows 10 version is released"
    Write-Host "-DO NOT " -NoNewline -ForegroundColor Red ; Write-Host "remove the Imaging Tool during this process"
    Write-Host "[ENTER]" -NoNewline -ForegroundColor Green; Write-Host " Continue, " -NoNewline; Write-Host "[N]" -NoNewline -ForegroundColor Red; Write-Host " Exit:" -NoNewline
    $choiceInput = Read-Host
    switch -Regex ($choiceInput) {
        default {
            #do nothing
        }
        'N|n|x|X' {
            Exit
        }
    }

    # Download \ Run \ Create - Media Creation Tool
    Write-Host "`nStep 1 of 4:" -ForegroundColor Green -NoNewline; Write-Host " We need to download the latest Windows 10 Media Creation Tool"
    Write-Host ">Downloading now..."
    If (!(Test-Path "C:\temp")) {New-Item -Path "C:\temp" -ItemType Directory}
    (New-Object System.Net.WebClient).DownloadFile("https://go.microsoft.com/fwlink/?LinkId=691209", "C:\temp\MediaCreationTool.exe")
    Write-Host ">Download complete"
    Write-Host "`nStep 2 of 4:" -ForegroundColor Green -NoNewline; Write-Host " Plug in an extra USB that is at least 8GB"
    Write-Host "-This USB will be erased and used to create the Microsoft Windows 10 Installation Tool"
    Write-Host "-Make sure you backup any data on the USB or it will be lost" -ForegroundColor Yellow
    Write-Host "-DO NOT USE THE IMAGING TOOL FOR THIS, YOU NEED A SECOND USB" -ForegroundColor Red
    PAUSE
    Write-Host "`nStep 3 of 4:" -ForegroundColor Green -NoNewline; Write-Host " Launch installer and create a Windows 10 Installation Tool"
    Write-Host ">First Option:" -ForegroundColor Cyan -NoNewline; Write-Host '  Choose to "Create installation media" (NOT to "Upgrade this PC now")'
    Write-Host ">Second Option:" -ForegroundColor Cyan -NoNewline; Write-Host " Edition=Windows 10, Architecture=64-bit"
    Write-Host ">Third Option:" -ForegroundColor Cyan -NoNewline; Write-Host "  Choose 'USB flash drive' (NOT 'ISO file')"
    Write-Host ">Fourth Option:" -ForegroundColor Cyan -NoNewline; Write-Host " Select the USB designated to become the Windows 10 Installation Tool"
    Write-Host "                    !!Make sure NOT to select your Imaging Tool!!" -ForegroundColor Red
    Write-Host "Hit enter when ready for the installer to launch" -ForegroundColor Green
    Read-Host "-NOTE: It can take awhile to create the USB..."
    Start-Process "C:\temp\MediaCreationTool.exe" -Wait

    # Find Media Creation Tool
    DO {
        foreach ($Drive_Letter in (Get-PSDrive -PSProvider FileSystem).Name) {
            $Test_Path = "$Drive_Letter" + ":\sources\install.esd"
            If (Test-Path $Test_Path) {$Media_Tool_Drive = "$Drive_Letter" + ":"}
        }
        If ((Test-Path $Media_Tool_Drive) -and (Test-Path $USB_Drive)) {
            Write-Host "`nStep 4 of 4:" -ForegroundColor Green -NoNewline;Write-Host " Copying $Media_Tool_Drive\sources\install.esd to $USB_Drive\Images\ESD File\Install.esd"
            Copy-Item -Path "$Media_Tool_Drive\sources\install.esd" -Destination "$USB_Drive\Images\ESD File\Install.esd" -Force
            Write-Host ">Complete"
        } Else {
            If (Test-Path $Media_Tool_Drive) {
                Write-Host "`nWARNING!!!" -ForegroundColor Red -NoNewline;Write-Host " Could not find the Windows 10 Installation Tool..."
                Write-Host "Make sure the Windows 10 Installation Tool is plugged in"
                PAUSE
            }
            If (Test-Path $USB_Drive) {
                Write-Host "`nWARNING!!!" -ForegroundColor Red -NoNewline;Write-Host " Could not find the Imaging Tool..."
                Write-Host "Make sure the Imaging Tool is plugged in"
                PAUSE
            }
        }
    } UNTIL ((Test-Path $Media_Tool_Drive) -and (Test-Path $USB_Drive))
}

function Extract-WIMfromESD {
    # Get USB Drive
    foreach ($Drive_Letter in (Get-PSDrive -PSProvider FileSystem).Name) {
        $Test_Path = "$Drive_Letter" + ":\PC_Setup"
        If (Test-Path $Test_Path) {
            $USB_Drive = "$Drive_Letter" + ":"
        }
    }

    $ESD_File_Path = $null

    Write-Host "`nStep 1 of 3:" -ForegroundColor Green -NoNewline;Write-Host " We need to find the install.esd file"
    Write-Host ">Searching..."

    Function Find_ESD_File {
        If ($USB_Drive) {
            $Destination = "$USB_Drive\Images\ESD File\Install.esd"
            # Primary USB Location
            $Test_Path = "$USB_Drive\Images\ESD File\Install.esd"
            If (Test-Path $Test_Path) {
                Write-Host ">Found $Test_Path"
                $Script:ESD_File_Path = "$Test_Path"
            }
            If (!($Script:ESD_File_Path)) {
                # Secondary USB Location
                $Test_Path = "$USB_Drive\Images\Install.esd"
                If (Test-Path $Test_Path) {
                    Write-Host ">Found $Test_Path"
                    Move-Item -Path $Test_Path -Destination $Destination
                    Write-Host ">Moved file to $Destination"
                    $Script:ESD_File_Path = $Destination
                }
            }
            If (!($Script:ESD_File_Path)) {
                # Tirchiary USB Location
                $Test_Path = "$USB_Drive\Install.esd"
                If (Test-Path $Test_Path) {
                    Write-Host ">Found $Test_Path"
                    Move-Item -Path $Test_Path -Destination $Destination
                    Write-Host ">Moved file to $Destination"
                    $Script:ESD_File_Path = $Destination
                }
            }
        }
        If (!($Script:ESD_File_Path)) {
            # Only acceptable USB Location
            $Test_Path = "C:\Install.esd"
            If (Test-Path $Test_Path) {
                Write-Host ">Found $Test_Path"
                If ($USB_Drive) {
                    Move-Item -Path $Test_Path -Destination $Destination
                    Write-Host ">Moved file to $Destination"
                } else {
                    $Destination = $Test_Path   
                }
                $Script:ESD_File_Path = $Destination
            }
        }
    }

    DO {
        Find_ESD_File
        If (!($ESD_File_Path)) {
            Write-Host ">Could not find the install.esd file" -ForegroundColor Red
            Write-Host ">Please make sure it is named correctly and located in one of these folders:"
            If ($USB_Drive) {
                Write-Host "$USB_Drive\Images\ESD File\Install.esd"
                Write-Host "$USB_Drive\Images\Install.esd"
                Write-Host "$USB_Drive\Install.esd"
            }
            Write-Host "C:\Install.esd"
            Write-Host "`nPlease place the Install.esd file into one of these locations then hit enter to continue" -ForegroundColor Yellow
            PAUSE
        }
    } UNTIL ($ESD_File_Path)

    PAUSE
    Write-Host "`nStep 2 of 3:" -ForegroundColor Green -NoNewline;Write-Host ' We need to verify the "ImageIndex" number to be used in the next command'
    Write-Host '   (Generally we want the "Windows 10 Pro" version)' -NoNewline
    Get-WindowsImage -ImagePath "$ESD_File_Path"
    $ImageIndex = Read-Host '>Please enter the desired "ImageIndex" number'

    Write-Host "`nStep 3 of 3:" -ForegroundColor Green -NoNewline;Write-Host " The .wim file will now be extracted"
    Write-Host ">Please stand by..."
    If ($USB_Drive) {
        Export-WindowsImage -SourceImagePath $ESD_File_Path -DestinationImagePath "$USB_Drive\Images\Install.wim" -SourceIndex $ImageIndex -CompressionType Max -CheckIntegrity
    } else {
        Export-WindowsImage -SourceImagePath $ESD_File_Path -DestinationImagePath "C:\Install.wim" -SourceIndex $ImageIndex -CompressionType Max -CheckIntegrity
    }
    Write-Host "Image has been created!" -ForegroundColor Green
    Write-Host '>Check "ImagePath" above for the location of the new .wim file'
}

function Create-ModdedWIM {
    # Get USB Drive
    foreach ($Drive_Letter in (Get-PSDrive -PSProvider FileSystem).Name) {
        $Test_Path = "$Drive_Letter" + ":\PC_Setup"
        If (Test-Path $Test_Path) {
            $USB_Drive = "$Drive_Letter" + ":"
        }
    }


    Write-Host "`nStep 1 of 6:" -ForegroundColor Green -NoNewline;Write-Host " We need to find the Install.wim file"
    Write-Host ">Searching..."
    Function Find_WIM_File {
        If ($USB_Drive) {
            $Destination = "$USB_Drive\Images\Install.wim"
            # Primary USB Location
            $Test_Path2 = "$USB_Drive\Images\Install.wim"
            If (Test-Path $Test_Path2) {
                Write-Host ">Found $Test_Path2"
                $Script:WIM_File_Path = "$Test_Path2"
                $Script:mount = $USB_Drive+"\Images\mount"
                New-Item $Script:mount -ItemType Directory -Force > $null
            }
        }
        If (!($Script:WIM_File_Path)) {
            # Only acceptable Local Location
            $Test_Path2 = "C:\Install.wim"
            If (Test-Path $Test_Path2) {
                Write-Host ">Found $Test_Path2"
                If ($USB_Drive) {
                    Move-Item -Path $Test_Path2 -Destination $Destination
                    Write-Host ">Moved file to $Destination"
                    $Script:mount = "$USB_Drive\Images\mount"
                    New-Item $Script:mount -ItemType Directory -Force
                } else {
                    $Destination = $Test_Path2
                    $Script:mount = "C:\mount"
                    New-Item $Script:mount -ItemType Directory -Force | Out-Null
                }
                $Script:WIM_File_Path = $Destination
            }
        }
    }

    DO {
        Find_WIM_File
        If (!($WIM_File_Path)) {
            Write-Host ">Could not find the install.wim file" -ForegroundColor Red
            Write-Host ">Please make sure it is named correctly and located in one of these folders:"
            If ($USB_Drive) {
                Write-Host "$USB_Drive\Images\Install.wim"
            }
            Write-Host "C:\Install.wim"
            Write-Host "`nPlease place the Install.wim file into one of these locations then hit enter to continue" -ForegroundColor Yellow
            PAUSE
        }
    } UNTIL ($WIM_File_Path)
    # Modules Paths
    $FilePath_Mount_AutomateSetup_Module   = "$mount\Program Files\WindowsPowerShell\Modules\Automate-Setup\Automate-Setup.psm1"
    $FilePath_Mount_ConfigurePC_Module     = "$mount\Program Files\WindowsPowerShell\Modules\Configure-PC\Configure-PC.psm1"
    $FilePath_Mount_InstallSoftware_Module = "$mount\Program Files\WindowsPowerShell\Modules\Install-Software\Install-Software.psm1"
    
    $FilePath_USB_AutomateSetup_Module     = "$USB_Drive\sources\PC-Maintenance\_modules\Automate-Setup\Automate-Setup.psm1"
    $FilePath_USB_ConfigurePC_Module       = "$USB_Drive\sources\PC-Maintenance\_modules\Configure-PC\Configure-PC.psm1"
    $FilePath_USB_InstallSoftware_Module   = "$USB_Drive\sources\PC-Maintenance\_modules\Install-Software\Install-Software.psm1"


    Write-Host "`nStep 2 of 6:" -ForegroundColor Green -NoNewline; Write-Host " Please confirm that this is the correct file."
    Write-Host "If it is not the correct wim, try moving or renaming the wim that was found, then re-run this script"
    Write-Host "[ENTER]" -NoNewline -ForegroundColor Green; Write-Host " Confirm, " -NoNewline; Write-Host "[X]" -NoNewline -ForegroundColor Red; Write-Host " Exit:" -NoNewline
    $choiceInput = Read-Host
    switch -Regex ($choiceInput) {
        default {
            # do nothing
        }
        'N|n|x|X' {Exit}
    }


    Write-Host "`nStep 3 of 6:" -ForegroundColor Green -NoNewline; Write-Host " Copy and rename Install.wim..."
    If (Test-Path "$USB_Drive\Images\Install-Modded.wim") {
        $ModdedImages = Get-ChildItem -Path "$USB_Drive\Images\Install-Modded*.wim"
        [int]$ModdedImagesCount = 0
        $ModdedImagesCount = $ModdedImages.Count
        $ModdedImageName = "Install-Modded$ModdedImagesCount.wim"
    } else {$ModdedImageName = "Install-Modded.wim"}
    $WIM_File_Path = "$USB_Drive\Images\$ModdedImageName"
    Write-Host ">Copying and renaming Install.wim to $ModdedImageName"
    Write-Host ">Please stand by..."
    Copy-Item -Path "$USB_Drive\Images\Install.wim" -Destination $WIM_File_Path
    Write-Host ">Completed"


    Write-Host "`nStep 4 of 6:" -ForegroundColor Green -NoNewline; Write-Host " Mounting $WIM_File_Path to $mount..."
    Write-Host ">Please stand by..."
    Mount-WindowsImage -ImagePath $WIM_File_Path -Index 1 -Path $mount
    Write-Host ">Completed"


    Write-Host "`nStep 5 of 6:" -ForegroundColor Green -NoNewline; Write-Host " Modifying the Install.wim file..."
    Write-Host ">Beggining registry edits on the Install.wim file..."
    # Load the wim's SOFTWARE registry
    REG LOAD HKLM\WimRegistrySOFTWARE "$mount\windows\system32\config\software"
    # Disable Live Tiles
    REG ADD 'HKLM\WimRegistrySOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Pushnotications' /v NoTileApplictionNotification /d 1 /f /t REG_DWORD
    # Remove Cortana button from the taskbar
    REG ADD 'HKLM\WimRegistrySOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v ShowCortanaButton /d 0 /f /t REG_DWORD
    # Remove "People" icon from taskbar
    REG ADD 'HKLM\WimRegistrySOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People' /v PeopleBand /d 0 /f /t REG_DWORD
    # Remove "TaskViewButton" from the taskbar
    REG ADD 'HKLM\WimRegistrySOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v ShowTaskViewButton /d 0 /f /t REG_DWORD
    # Show ALL system tray icons
    REG ADD 'HKLM\WimRegistrySOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' /v EnableAutoTray /d 0 /f /t REG_DWORD
    # Set Searchbar as Icon rather than Search Box
    REG ADD 'HKLM\WimRegistrySOFTWARE\Microsoft\Windows\CurrentVersion\Search' /v SearchboxTaskbarMode /d 1 /f /t REG_DWORD
    # Do not show News & Interests button
    REG ADD 'HKLM\WimRegistrySoftware\Microsoft\Windows\CurrentVersion\Feeds' /v ShellFeedsTaskbarViewMode /d 2 /f /t REG_DWORD
    # Unload the wim's SOFTWARE registry
    REG UNLOAD HKLM\WimRegistrySOFTWARE
    Write-Host ">Registry edits completed"
    #
    Write-Host ">Beginning FileSystem edits on the Install.wim file..."
    # Transfer Public Desktop
    Copy-Item -Path "$USB_Drive\sources\PC-Maintenance\1. Automated Setup\PublicDesktop\*" -Destination "$mount\Users\Public\Desktop\" -Recurse -Force
    # Transfer Modules
    # Automate-Setup module
    New-Item -Path "$mount\Program Files\WindowsPowerShell\Modules\Automate-Setup" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    Copy-Item -Path $FilePath_USB_AutomateSetup_Module -Destination $FilePath_Mount_AutomateSetup_Module -Force
    # Configure-PC module
    New-Item -Path "$mount\Program Files\WindowsPowerShell\Modules\Configure-PC" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    Copy-Item -Path $FilePath_USB_ConfigurePC_Module -Destination $FilePath_Mount_ConfigurePC_Module -Force
    # Install-Software module
    New-Item -Path "$mount\Program Files\WindowsPowerShell\Modules\Install-Software" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    Copy-Item -Path $FilePath_USB_InstallSoftware_Module -Destination $FilePath_Mount_InstallSoftware_Module -Force
    # Transfer Setup Folder
    New-Item -Path "$mount\Setup" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    Copy-Item -Path "$USB_Drive\sources\PC-Maintenance\1. Automated Setup\Setup\*" -Destination "$mount\Setup" -Force -Recurse
    # Transfer Software Collection Folders
    New-Item -Path "$mount\Setup\_Software_Collection" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    Copy-Item -Path "$USB_Drive\PC_Setup\_Software_Collection\_Software_Configs" -Destination "$mount\Setup\_Software_Collection\" -Force -Recurse
    Copy-Item -Path "$USB_Drive\PC_Setup\_Software_Collection\ODT" -Destination "$mount\Setup\_Software_Collection\" -Force -Recurse
    Copy-Item -Path "$USB_Drive\PC_Setup\_Software_Collection\Profile_Specific_Software" -Destination "$mount\Setup\_Software_Collection\" -Force -Recurse
    Copy-Item -Path "$USB_Drive\PC_Setup\_Software_Collection\Standard_Software" -Destination "$mount\Setup\_Software_Collection\" -Force -Recurse
    # Transfer Driver Collection
    Copy-Item -Path "$USB_Drive\PC_Setup\_Driver_Collection" -Destination "$mount\Setup\" -Force -Recurse
    # Transfer Script Collection
    Copy-Item -Path "$USB_Drive\PC_Setup\_Script_Collection" -Destination "$mount\Setup\" -Force -Recurse
    Write-Host ">FileSystem edits completed"
    # Install .NET 3.5
    Write-Host ">Beginning .NET 3.5 Install on the Install.wim file..."
    Write-Host "`nMake sure the correct sxs cab files are directly under $USB_Drive\Images\sxs before continuing"
    Write-Host "              (Each different version of Win10 has different sxs cab files)`n" -ForegroundColor Yellow
    PAUSE
    Write-Host "`nInstalling .NET 3.5..."
    DISM /image:$mount /enable-feature /featurename:NetFx3 /All /Source:$USB_Drive\Images\sxs
    Write-Host "`n>.NET 3.5 Install completed"


    Write-Host "`nStep 6 of 6:" -ForegroundColor Green -NoNewline; Write-Host " Un-mounting $WIM_File_Path from $mount..."
    Write-Host ">Please stand by..."
    Dismount-WindowsImage -Path $mount -Save
    Remove-Item -Path "$USB_Drive\Images\mount"
    Write-Host ">Completed"
}
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