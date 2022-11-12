function New-TechTool {
    [TechTool]::new()
} Export-ModuleMember -Function New-TechTool

class TechTool {
    [string]$FilePath_Local_TechTool_bat            = "C:\Users\Public\Desktop\TechTool-RAA.bat"
    [string]$FilePath_Local_TechTool_ps1            = "C:\Users\Public\Desktop\sources\TechTool.ps1"
    [string]$FolderPath_Local_Modules               = "C:\Program Files\WindowsPowerShell\Modules"
    [string]$FilePath_Local_ImagingUSB_Module       = $this.FolderPath_Local_Modules + "\ImagingUSB\ImagingUSB.psm1"
    [string]$FilePath_Local_AutomateSetup_ps1       = "C:\Setup\_Automated_Setup\Automate-Setup.ps1"
    [string]$FilePath_Local_AutomateSetup_Module    = $this.FolderPath_Local_Modules + "\Automate-Setup\Automate-Setup.psm1"
    [string]$FilePath_Local_ConfigurePC_Module      = $this.FolderPath_Local_Modules + "\Configure-PC\Configure-PC.psm1"
    [string]$FilePath_Local_InstallSoftware_Module  = $this.FolderPath_Local_Modules + "\Install-Software\Install-Software.psm1"
    [string]$FilePath_Local_TuneUpPC_Module         = $this.FolderPath_Local_Modules + "\TuneUp-PC\TuneUp-PC.psm1"
    [string]$FilePath_Local_TechTool_Module         = $this.FolderPath_Local_Modules + "\TechTool\TechTool.psm1"
    
    [void] Update() {
        $this.Download_GitHub_Repo()
        $this.Update_Local_Scripts()
        $this.Import_Modules()
        Write-Host "Update Pause4"
        Pause
        $USB = New-ImagingUSB
        Write-Host "$USB"
        Write-Host "`$USB.Exists() = $USB.Exists()"
        Write-Host "`$USB.DevTool = $USB.DevTool"
        Write-Host "Update Pause4.1"
        Pause
        if ($USB.Exists()) {
            if ($USB.DevTool) {
                Write-Host "Update Pause5"
                Pause
                $this.Push_Dev_Scripts()
                Write-Host "Update Pause6"
                Pause
                $this.Import_Modules()
                Write-Host "Update Pause7"
                Pause
            } else {
                $this.Update_USB_Scripts()
                Write-Host "Update Pause8"
                Pause
            }
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

    [void] Download_GitHub_Repo([string]$Name,[string]$Author,[string]$Branch,[string]$Location) {
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

    [void] Update_Local_Scripts([string]$Location,[string]$Name) {
        # NEEDS TO WORK INDEPENDANTLY OF ANY (OTHER) MODULES OR OTHER PARENT\CHILD SCRIPTS 

        $Source = "$Location\$Name-main"

        $this.Restore("$Source\TechTool-RAA.bat",$this.FilePath_Local_TechTool_bat,"Copy")
        $this.Restore("$Source\TechTool.ps1",$this.FilePath_Local_TechTool_ps1,"Copy")
        $this.Restore("$Source\ImagingUSB.psm1",$this.FilePath_Local_ImagingUSB_Module,"Copy")
        $this.Restore("$Source\Automate-Setup.ps1",$this.FilePath_Local_AutomateSetup_ps1,"Copy")
        $this.Restore("$Source\Automate-Setup.psm1",$this.FilePath_Local_AutomateSetup_Module,"Copy")
        $this.Restore("$Source\Configure-PC.psm1",$this.FilePath_Local_ConfigurePC_Module,"Copy")
        $this.Restore("$Source\Install-Software.psm1",$this.FilePath_Local_InstallSoftware_Module,"Copy")
        $this.Restore("$Source\TuneUp-PC.psm1",$this.FilePath_Local_TuneUpPC_Module,"Copy")
        $this.Restore("$Source\TechTool.psm1",$this.FilePath_Local_TechTool_Module,"Copy")

        Write-Host "Update Local Scripts: " -NoNewline; Write-Host "Complete" -ForegroundColor Green
    }

    [void]hidden Restore([string]$SourceFile,[string]$DestinationFile,[string]$CopyORMove) {
    <# This function does three things
            1. Verify source file exists
            2. Remove Destination File if exists
            3. Move or Copy file #>
        Write-Host "`$SourceFile = $SourceFile"
        Write-Host "`$DestinationFile = $DestinationFile"
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

        Write-Host "Import Modules: " -NoNewline; Write-Host "Complete" -ForegroundColor Green
    }

    [void] Update_USB_Scripts() {
        [string]$Location = "C:\temp"
        [string]$Name = "ImagingTool"
        $this.Update_USB_Scripts($Location,$Name)
    }

    [void] Update_USB_Scripts([string]$Location,[string]$Name) {
        # Requires ImagingUSB module
        
        $Source = "$Location\$Name-main"
        $USB = New-ImagingUSB

        if ($USB.Exists()) {
            $WinPEDrive                             = $USB.WinPE_Drive_Letter
            $this.Restore("$Source\WinPE-Menu.ps1","$WinPEDrive\sources\WinPE-Menu.ps1","Move")
            
            $this.Restore("$Source\TechTool-RAA.bat",$USB.FilePath_TechTool_bat,"Move")
            $this.Restore("$Source\TechTool.ps1",$USB.FilePath_TechTool_ps1,"Move")
            $this.Restore("$Source\ImagingUSB.psm1",$USB.FilePath_ImagingUSB_Module,"Move")
            $this.Restore("$Source\Automate-Setup.ps1",$USB.FilePath_AutomateSetup_ps1,"Move")
            $this.Restore("$Source\Automate-Setup.psm1",$USB.FilePath_AutomateSetup_Module,"Move")
            $this.Restore("$Source\Configure-PC.psm1",$USB.FilePath_ConfigurePC_Module,"Move")
            $this.Restore("$Source\Install-Software.psm1",$USB.FilePath_InstallSoftware_Module,"Move")
            $this.Restore("$Source\TuneUp-PC.psm1",$USB.FilePath_TuneUpPC_Module,"Move")
            $this.Restore("$Source\TechTool.psm1",$USB.FilePath_TechTool_Module,"Move")

            Write-Host "Update USB Scripts: " -NoNewline; Write-Host "Complete" -BackgroundColor Green
        } else {
            Write-Host "Imaging USB not detected - " -NoNewline; Write-Host "Not Updated" -BackgroundColor Red
        }
    }

    [void] Push_Dev_Scripts() {
        # Requires ImagingUSB module
        
        $USB = New-ImagingUSB

        if ($USB.Exists()) {            
            $this.Restore($USB.FilePath_TechTool_bat,$this.FilePath_Local_TechTool_bat,"Copy")
            $this.Restore($USB.FilePath_TechTool_ps1,$this.FilePath_Local_TechTool_ps1,"Copy")
            $this.Restore($USB.FilePath_ImagingUSB_Module,$this.FilePath_Local_ImagingUSB_Module,"Copy")
            $this.Restore($USB.FilePath_AutomateSetup_ps1,$this.FilePath_Local_AutomateSetup_ps1,"Copy")
            $this.Restore($USB.FilePath_AutomateSetup_Module,$this.FilePath_Local_AutomateSetup_Module,"Copy")
            $this.Restore($USB.FilePath_ConfigurePC_Module,$this.FilePath_Local_ConfigurePC_Module,"Copy")
            $this.Restore($USB.FilePath_InstallSoftware_Module,$this.FilePath_Local_InstallSoftware_Module,"Copy")
            $this.Restore($USB.FilePath_TuneUpPC_Module,$this.FilePath_Local_TuneUpPC_Module,"Copy")
            $this.Restore($USB.FilePath_TechTool_Module,$this.FilePath_Local_TechTool_Module,"Copy")
 
            $this.fi
            Write-Host "Push Dev Scripts: " -NoNewline; Write-Host "Complete" -BackgroundColor Green
        } else {
            Write-Host "Imaging USB not detected - " -NoNewline; Write-Host "Not Updated" -BackgroundColor Red
        }
    }

    [void] Update_Local_GitHubRepo() {
        $this.Update_Local_GitHubRepo("C:\Git-Repositories\ImagingTool")
    }
    
    [void] Update_Local_GitHubRepo([string]$RepoPath) {
        $GitHubRepo = $RepoPath
        $USB = New-ImagingUSB

        if (Test-Path $GitHubRepo) {
            if ($USB.Exists()) {
                $WinPEDrive                                         = $USB.WinPE_Drive_Letter
                $this.Restore("$WinPEDrive\sources\WinPE-Menu.ps1","$GitHubRepo\WinPE-Menu.ps1","Copy")

                $this.Restore($USB.FilePath_TechTool_bat,"$GitHubRepo\TechTool-RAA.bat","Copy")
                $this.Restore($USB.FilePath_TechTool_ps1,"$GitHubRepo\TechTool.ps1","Copy")
                $this.Restore($USB.FilePath_TechTool_Module,"$GitHubRepo\TechTool.psm1","Copy")
                $this.Restore($USB.FilePath_ImagingUSB_Module,"$GitHubRepo\ImagingUSB.psm1","Copy")
                $this.Restore($USB.FilePath_AutomateSetup_ps1,"$GitHubRepo\Automate-Setup.ps1","Copy")
                $this.Restore($USB.FilePath_AutomateSetup_Module,"$GitHubRepo\Automate-Setup.psm1","Copy")
                $this.Restore($USB.FilePath_ConfigurePC_Module,"$GitHubRepo\Configure-PC.psm1","Copy")
                $this.Restore($USB.FilePath_InstallSoftware_Module,"$GitHubRepo\Install-Software.psm1","Copy")
                $this.Restore($USB.FilePath_TuneUpPC_Module,"$GitHubRepo\TuneUp-PC.psm1","Copy")

                Write-Host "Files Updated to GitHub Repo Folder: $GitHubRepo" -ForegroundColor Green
            } else {
                Write-Host "Imaging USB not found"
            }
        } else {
            Write-Host "GitHubRepo ($GitHubRepo) not found"
        }
    }

    [void] DisplayMenu() {
        #########################################################################################################################################
        ############################################################### MAIN MENU ###############################################################
        #########################################################################################################################################
        function Main_Menu {
            Clear-Host
            
            DO {
                Write-Host "`n-=[ Main Menu ]=-" -ForegroundColor DarkGray
                Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
                Write-Host "`n    1. Enter " -NoNewline; Write-Host "PC Maintenance " -NoNewline -ForegroundColor Cyan; Write-Host "menu"
                Write-Host "        -Enter this menu to access several scripts that you can use to;" -ForegroundColor DarkGray
                Write-Host "              +Setup a PC               +Install Software" -ForegroundColor DarkGray
                Write-Host "              +Update the OS            +Cleanup System Drive" -ForegroundColor DarkGray
                Write-Host "              +Migrate User Profiles    +Etc.." -ForegroundColor DarkGray
                Write-Host "        -This is the menu you will use 99% of the time" -ForegroundColor Green
                Write-Host "`n    2. Enter " -NoNewline; Write-Host "Image Maintenance " -NoNewline -ForegroundColor DarkCyan; Write-Host "menu"
                Write-Host "        -Enter this menu to create a fresh .wim file of the latest Win10 OS version" -ForegroundColor DarkGray
                Write-Host "        -This should only need to be done every 6-12 months" -ForegroundColor DarkYellow
                Write-Host "`n    3. Enter " -NoNewline; Write-Host "Imaging Tool Maintenance " -NoNewline -ForegroundColor DarkGray; Write-Host "menu"
                Write-Host "        -Enter this menu for Maintenance tasks related to this USB Tool" -ForegroundColor DarkGray
                Write-Host "        -This menu is intended for developers. An average tech should" -ForegroundColor DarkYellow
                Write-Host "         not need to use this under normal circumstances" -ForegroundColor DarkYellow
                Write-Host "`n    4. " -NoNewline; Write-Host "EXIT SCRIPT" -ForegroundColor DarkRed
                $choice = Read-Host -Prompt "`nEnter a number, 1 thru 4"
                $choice = $choice -as [int]
            } UNTIL (($choice -ge 1) -and ($choice -le 4))
            Switch ($choice) {
                1 {Clear-Host; PC-Maintenance_submenu}
                2 {Clear-Host; Image-Maintenance_submenu}
                3 {Clear-Host; ImagingUSB-Maintenance_submenu}
                4 {EXIT}
            }
        } # End of Main_Menu

        #region PC Maintenance
        #########################################################################################################################################
        ############################################################ PC Maintenance #############################################################
        #########################################################################################################################################
        function PC-Maintenance_submenu {
            DO {
                Write-Host "`n-=[ PC Maintenance ]=-" -ForegroundColor DarkGray
                Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
                Write-Host "0. " -NoNewline; Write-Host "BACK TO MAIN MENU" -ForegroundColor DarkGray
                Write-Host "1. Enter " -NoNewline; Write-Host "Automated Setup " -NoNewline -ForegroundColor DarkCyan; Write-Host "menu"
                Write-Host "2. Enter " -NoNewline; Write-Host "TuneUp PC " -NoNewline -ForegroundColor DarkYellow; Write-Host "menu" -NoNewline; Write-Host " **WARNING - This is not fully functional yet" -ForegroundColor Red
                Write-Host "3. Enter " -NoNewline; Write-Host "Configure Automatic Sign-in " -NoNewline -ForegroundColor DarkCyan; Write-Host "menu"
                Write-Host "4. Enter " -NoNewline; Write-Host "Standardize PC " -NoNewline -ForegroundColor DarkCyan; Write-Host "menu"
                Write-Host "5. Enter " -NoNewline; Write-Host "Install Software " -NoNewline -ForegroundColor DarkCyan; Write-Host "menu"
                Write-Host "6. Enter " -NoNewline; Write-Host "Update PC " -NoNewline -ForegroundColor DarkCyan; Write-Host "menu"
                Write-Host "7. Enter " -NoNewline; Write-Host "Cleanup Hard Drive " -NoNewline -ForegroundColor DarkCyan; Write-Host "menu"
                Write-Host "8. Enter " -NoNewline; Write-Host "Migrate User Profile " -NoNewline -ForegroundColor DarkCyan; Write-Host "menu"
                Write-Host "9. Enter " -NoNewline; Write-Host "Backup Folder " -NoNewline -ForegroundColor DarkCyan; Write-Host "menu"
                Write-Host "10. Pull " -NoNewline; Write-Host "Intune " -NoNewline -ForegroundColor DarkYellow; Write-Host "Hardware ID " -ForegroundColor DarkCyan
                Write-Host "11. " -NoNewline; Write-Host "EXIT SCRIPT" -ForegroundColor DarkRed
                $choice = Read-Host -Prompt "Enter a number, 0 thru 11"
                $choice = $choice -as [int]
            } UNTIL (($choice -ge 0) -and ($choice -le 11))
            Switch ($choice) {
                0 {Clear-Host; Main_Menu}
                1 {Clear-Host; Automated_Setup_submenu}
                2 {Clear-Host; TuneUp-PC_submenu}
                3 {Clear-Host; Configure_Automatic_Sign_In_submenu}
                4 {Clear-Host; Standardize_PC_submenu}
                5 {Clear-Host; Install_Software_submenu}
                6 {Clear-Host; Update_PC_submenu}
                7 {Clear-Host; Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -ArgumentList "-NoExit -Windowstyle maximized -ExecutionPolicy Bypass -File $FilePath_USB_Cleanup_HD"}
                8 {Clear-Host; Migrate_User_Profile_submenu}
                9 {Clear-Host; Start-Process $FilePath_USB_Backup_Folder_BACKUP}
                10 {Clear-Host; Pull_IntuneHWID}
                11 {EXIT}
            }
            # Recursivly call the PC Maintenance Menu
            PC-Maintenance_submenu
        }

        function Automated_Setup_submenu {    
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
                0 {Clear-Host; PC-Maintenance_submenu}
                1 {
                    Clear-Host
                    Write-Host "`nInjecting the Automated Setup program in the background..." -ForegroundColor Green
                    Write-Host "Note: If the Automated Setup program is already on the current OS, it will be" -ForegroundColor Yellow
                    Write-Host "      updated to the version on the Imaging Tool if it is newer" -ForegroundColor Yellow
                    Write-Host "-To kick off the Automated Setup program, run the file on the desktop called"
                    Write-Host "    Start-NewImage-RAA.bat (RAA - Run As Admin)"
                    Write-Host '-Or select "START Automated Setup program on current OS" in the Automated Setup'
                    Write-Host '    submenu'
                    Start-Process $FilePath_USB_Automated_Setup_INJECT_Scripts_Script
                }
                2 {Clear-Host; Start-AutomatedSetup}
                3 {Clear-Host; Stop-AutomatedSetup}
                4 {Clear-Host; Remove-Automated_Setup_Files}
                5 {Clear-Host; Read-ClientConfig}
                6 {Clear-Host; Create-ClientConfig}
                7 {EXIT}
            }
            
            #Recursivly call the submenu
            Automated_Setup_submenu
        } # End of Automated_Setup_submenu

        function TuneUp-PC_submenu {
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
                0 {Clear-Host; PC-Maintenance_submenu}
                1 {Clear-Host; Inject-TuneUp_PC}
                2 {Clear-Host; Start-TuneUp_PC}
                3 {Clear-Host; Stop-TuneUp_AtLogon}
                4 {EXIT}
            }

            #Recursivly call the submenu
            TuneUp-PC_submenu
        } # End of TuneUp-PC_submenu

        function Configure_Automatic_Sign_In_submenu {
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
                0 {Clear-Host; PC-Maintenance_submenu}
                1 {Clear-Host; Enable-AutoLogon}
                2 {Clear-Host; Remove-AutoLogon}
                3 {EXIT}
            }
            #Recursivly call the submenu
            Configure_Automatic_Sign_In_submenu
        } # End of Configure_Automatic_Sign_In_submenu

        function Standardize_PC_submenu {
            DO {
                Write-Host "`n-=[ Standardize PC submenu ]=-" -ForegroundColor DarkGray
                Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
                Write-Host "0. " -NoNewline; Write-Host "BACK TO PREVIOUS MENU" -ForegroundColor DarkGray
                Write-Host "1. " -NoNewline; Write-Host "STANDARDIZE " -NoNewline -ForegroundColor Cyan; Write-Host "PC Settings"
                Write-Host "2. " -NoNewline; Write-Host "EXIT SCRIPT" -ForegroundColor DarkRed
                $choice = Read-Host -Prompt "Enter a number, 0 thru 2"
                $choice = $choice -as [int]
            } UNTIL (($choice -ge 0) -and ($choice -le 2))
            Switch ($choice) {
                0 {Clear-Host; PC-Maintenance_submenu}
                1 {Clear-Host; Set-PCDefaultSettings}
                2 {EXIT}
            }
            #Recursivly call the submenu
            Standardize_PC_submenu
        } # End of Standardize_PC_submenu

        function Install_Software_submenu {
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
                0 {Clear-Host; PC-Maintenance_submenu}
                1 {Clear-Host; Install-Image_Softwares}
                2 {Clear-Host; Choose-Browser}
                3 {Clear-Host; Choose-PDF_Viewer}
                4 {Clear-Host; Choose-o365}
                5 {Clear-Host; Choose-VPN}
                6 {Clear-Host; Choose-Collaboration_Software}
                7 {Clear-Host; Choose-FileShareApp}
                8 {Clear-Host; Install-SupportAssistant}
                9 {Clear-Host; Write-Host "This doesn't do anything yet"}
                10 {Clear-Host; Write-Host "This doesn't do anything yet"}
                11 {Clear-Host; Read-SoftwareConfig}
                12 {Clear-Host; Create-SoftwareConfig}
                13 {EXIT}
            }
            #Recursivly call the submenu
            Install_Software_submenu
        } # End of Install_Software_submenu

        function Update_PC_submenu {
            DO {
                Write-Host "`n-=[ Update PC submenu ]=-" -ForegroundColor DarkGray
                Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
                Write-Host "0. " -NoNewline; Write-Host "BACK TO PREVIOUS MENU" -ForegroundColor DarkGray
                Write-Host "1. " -NoNewline; Write-Host "INSTALL " -NoNewline -ForegroundColor Cyan; Write-Host "Windows Updates"
                Write-Host "2. " -NoNewline; Write-Host "EXIT SCRIPT" -ForegroundColor DarkRed
                $choice = Read-Host -Prompt "Enter a number, 0 thru 2"
                $choice = $choice -as [int]
            } UNTIL (($choice -ge 0) -and ($choice -le 2))
            Switch ($choice) {
                0 {Clear-Host; PC-Maintenance_submenu}
                1 {Clear-Host; Install-Windows_Updates -RebootAllowed}
                2 {EXIT}
            }
            #Recursivly call the submenu
            Update_PC_submenu
        } # End of Update_PC_submenu

        function Migrate_User_Profile_submenu {
            DO {
                Write-Host "`n-=[ Migrate User Profile submenu ]=-" -ForegroundColor DarkGray
                Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
                Write-Host "0. " -NoNewline; Write-Host "BACK TO PREVIOUS MENU" -ForegroundColor DarkGray
                Write-Host "1. " -NoNewline; Write-Host "BACKUP " -NoNewline -ForegroundColor Cyan; Write-Host "User Profile, using " -NoNewline; Write-Host "Transwiz" -ForegroundColor DarkCyan -NoNewline; Write-Host "  -Not developed yet" -ForegroundColor DarkRed
                Write-Host "2. " -NoNewline; Write-Host "RESTORE " -NoNewline -ForegroundColor Cyan; Write-Host "User Profile, using " -NoNewline; Write-Host "Transwiz" -ForegroundColor DarkCyan -NoNewline; Write-Host "  -Not developed yet" -ForegroundColor DarkRed
                Write-Host "3. " -NoNewline; Write-Host "SYNC " -NoNewline -ForegroundColor Cyan; Write-Host "User Profile, using " -NoNewline; Write-Host "Sync-UserProfileData script" -ForegroundColor Green
                Write-Host "4. " -NoNewline; Write-Host "EXIT SCRIPT" -ForegroundColor DarkRed
                $choice = Read-Host -Prompt "Enter a number, 0 thru 4"
                $choice = $choice -as [int]
            } UNTIL (($choice -ge 0) -and ($choice -le 4))
            Switch ($choice) {
                0 {Clear-Host; PC-Maintenance_submenu}
                1 {Clear-Host; Start-Process $FilePath_USB_Migrate_User_Profile_BACKUP}
                2 {Clear-Host; Start-Process $FilePath_USB_Migrate_User_Profile_RESTORE}
                3 {Clear-Host; Start-Process $FilePath_USB_Migrate_User_Profile_SYNC}
                4 {EXIT}
            }
            #Recursivly call the submenu
            Migrate_User_Profile_submenu
        } # End of Migrate_User_Profile_submenu

        function Pull_IntuneHWID {
            # Get The USB Drive Letter
            foreach ($letter in (Get-PSDrive -PSProvider FileSystem).Name) {
                $TestPath = "$letter" + ":\PC_Setup"
                If (Test-Path $TestPath) {
                    $USB = "$letter" + ":"
                }
            }

            If (Test-Path $USB) {
                #New-Item -Type Directory -Path "$USB\HWID" -Force
                Set-Location -Path "$USB\"
                $OriginalPath = $env:Path
                $env:Path += ";$USB\sources\PC-Maintenance\Get-WindowsAutoPilotInfo"
                Write-Host ""
                #Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
                Get-WindowsAutopilotInfo -OutputFile IntuneAutopilot_HWID.csv -Append
                Write-Host "`nSaved\Added to " -NoNewline; Write-Host "$USB\IntuneAutopilot_HWID.csv" -ForegroundColor Cyan
                $env:Path = $OriginalPath
            }
        }
        #endregion PC Maintenance

        #region Image Maintenance
        #########################################################################################################################################
        ########################################################### Image Maintenance ###########################################################
        #########################################################################################################################################
        function Image-Maintenance_submenu {
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
                0 {Clear-Host; Main_Menu}
                1 {Clear-Host; & $FilePath_ImageMaintenance_DOWNLOAD_Latest_ESD_File}
                2 {Clear-Host; & $FilePath_ImageMaintenance_EXTRACT_WIM_from_ESD}
                3 {Clear-Host; & $FilePath_ImageMaintenance_CREATE_Modded_WIM}
                4 {EXIT}
            }
            # Recursivly call the Image Maintenance Menu
            Image-Maintenance_submenu
        }
        #endregion Image Maintenance

        #region Imaging USB Maintenance
        ########################################################################################################################################
        ########################################################## USB Maintenance #############################################################
        ########################################################################################################################################
        function ImagingUSB-Maintenance_submenu {
            DO {
                Write-Host "`n-=[ Tool Maintenance ]=-" -ForegroundColor DarkGray
                Write-Host "Input a number to take the corresponding action" -ForegroundColor Yellow
                Write-Host "0. " -NoNewline; Write-Host "BACK TO MAIN MENU" -ForegroundColor DarkGray
                Write-Host "1. " -NoNewline; Write-Host "BACKUP " -NoNewline -ForegroundColor Green; Write-Host "Imaging Drive (Minus Images - Can save a lot of time and local disk space)"
                Write-Host "2. " -NoNewline; Write-Host "BACKUP " -NoNewline -ForegroundColor Green; Write-Host "Imaging Drive"
                Write-Host "3. " -NoNewline; Write-Host "CREATE " -NoNewline -ForegroundColor Cyan; Write-Host "WinPE USB AutoDeploy Package"
                Write-Host "4. " -NoNewline; Write-Host "CREATE " -NoNewline -ForegroundColor Cyan; Write-Host "WinPE USB Package"
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
                0 {Clear-Host; Main_Menu}
                1 {Clear-Host; & $FilePath_ImagingUSBMaintenance_BACKUP_Minus_Images}
                2 {Clear-Host; & $FilePath_ImagingUSBMaintenance_BACKUP}
                3 {Clear-Host; & $FilePath_ImagingUSBMaintenance_CREATE_AutoDeploy_Package}
                4 {Clear-Host; ImagingUSBMaintenance_Create-Package}
                5 {Clear-Host; ImagingUSBMaintenance_Transfer-Package}
                6 {Clear-Host; & $FilePath_ImagingUSBToolMaintenance_RESTORE_Minus_Images}
                7 {Clear-Host; & $FilePath_ImagingUSBMaintenance_RESTORE}
                8 {Clear-Host; Update-Scripts}
                9 {Clear-Host; Update-GitHubRepo}
                10 {EXIT}
            }
            ImagingUSB-Maintenance_submenu
        }

        function ImagingUSBMaintenance_Transfer-Package {
            $what = '/A-:SH /B /E'
            $options = '/R:5 /W:6 /LOG:C:\Transfer-Package_Backup_Log.txt /TEE /V /XO /XX'
            $source = "C:\WinPE_USB_Install_Package"
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
        }

        function ImagingUSBMaintenance_Create-Package {
            Write-Host "`nDO NOT EJECT the Imaging USB" -ForegroundColor Red
            DO {
                # SET WinPE & Imaging Drives
                foreach ($Drive_Letter in (Get-PSDrive -PSProvider FileSystem).Name) {
                    $WinPE_Test_Path = "$Drive_Letter" + ":\en-us\bootmgr.efi.mui"
                    $Imaging_Test_Path = "$Drive_Letter" + ":\Images"
                    If (Test-Path $WinPE_Test_Path) {
                        $WinPE_Drive = "$Drive_Letter" + ":"
                    }
                    If (Test-Path $Imaging_Test_Path) {
                        $Imaging_Drive = "$Drive_Letter" + ":"
                    }
                }

                Write-Host "`nWinPE Drive: " -NoNewline; Write-Host "$WinPE_Drive" -ForegroundColor Cyan
                Write-Host "Imaging Drive: " -NoNewline; Write-Host "$Imaging_Drive" -ForegroundColor Cyan
                if (($WinPE_Drive -eq $null) -or ($Imaging_Drive -eq $null)) {
                    Write-Host "`nWARNING!!! Could not detect either the WinPE or Imaging partition drives" -ForegroundColor Red
                    Write-Host "Hit any key to check and try again"
                }
            } until (($WinPE_Drive -ne $null) -and ($Imaging_Drive -ne $null)) 

            # SET WinPE_USB_Package SOURCE FOLDER ROOT
            $WinPE_USB_Package_SOURCE = "$Imaging_Drive\sources\ImagingUSB-Maintenance\Create-WinPE_USB_Package\"

            # SET WinPE_USB_Package DESTINATION FOLDER ROOT
            $WinPE_USB_Package_DESTINATION = "C:\WinPE_USB_Install_Package"

            # Set ROBOCOPY What and Options
            $what = '/A-:SH /B /E'
            $options = '/R:5 /W:6 /XO /XX'

            # START TRANSFERS
            Write-Host "`nDownloading\Updating " -NoNewline; Write-Host "$WinPE_USB_Package_DESTINATION" -ForegroundColor Cyan

            # 0. WinPE USB Package Shell - "C:\WinPE_USB_Install_Package\"
                $command = "ROBOCOPY $WinPE_USB_Package_SOURCE $WinPE_USB_Package_DESTINATION $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait

            # 1. WinPE Drive Files
                $WinPE_Dest = "$WinPE_USB_Package_DESTINATION\sources\Create_WinPE_USB\WinPE_Drive"
            
                # C:\WinPE_USB_Install_Package\sources\Create_WinPE_USB\WinPE_Drive
                # P:\
                $command = "XCOPY $WinPE_Drive\autorun.inf $WinPE_Dest\autorun.inf* /h /Y"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait
                $command = "attrib +h $WinPE_Dest\autorun.inf"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait
            
                # C:\WinPE_USB_Install_Package\sources\Create_WinPE_USB\WinPE_Drive
                # P:\sources
                $command = "XCOPY $WinPE_Drive\sources\WinPE.ico $WinPE_Dest\sources\WinPE.ico* /Y"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait
                $command = "XCOPY $WinPE_Drive\sources\WinPE-Menu.ps1 $WinPE_Dest\sources\WinPE-Menu.ps1* /Y"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait

            # 2. Imaging Drive Files
                $Imaging_Dest = "$WinPE_USB_Package_DESTINATION\sources\Create_WinPE_USB\Imaging_Drive"

                # C:\WinPE_USB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive
                # I:\
                $command = "XCOPY $Imaging_Drive\autorun.inf $Imaging_Dest\autorun.inf* /h /Y"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait
                $command = "attrib +h $Imaging_Dest\autorun.inf"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait
                $command = "XCOPY $Imaging_Drive\Imaging_Tool_Menu-RAA.bat $Imaging_Dest\Imaging_Tool_Menu-RAA.bat* /h /Y"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait

                # C:\WinPE_USB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive\sources
                # I:\sources
                $command = "ROBOCOPY $Imaging_Drive\sources\ $Imaging_Dest\sources\ $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait
                $command = "attrib +h $Imaging_Dest\sources"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait

                # C:\WinPE_USB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive\Images
                # I:\Images
                $command = "ROBOCOPY $Imaging_Drive\Images\ $Imaging_Dest\Images\ $what $options /XF *.wim *.esd"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait

                # C:\WinPE_USB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive\PC_Setup
                # I:\PC_Setup
                $command = "ROBOCOPY $Imaging_Drive\PC_Setup\ $Imaging_Dest\PC_Setup\ $what /MIR $options /XD Client_Folders ODT Personal_Software"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait

                # C:\WinPE_USB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive\PC_Setup\Client_Folders
                # I:\PC_Setup\Client_Folders
                #if (!(test-path "$Imaging_Dest\PC_Setup\Client_Folders")) {New-Item "$Imaging_Dest\PC_Setup\Client_Folders" -ItemType Directory -Force | Out-Null}
                # Not needed since copying a child folder (the next command) will automatically create this parent folder

                # C:\WinPE_USB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive\PC_Setup\Client_Folders\_Client_Configs
                # I:\PC_Setup\Client_Folders\_Client_Configs
                $command = "ROBOCOPY $Imaging_Drive\PC_Setup\Client_Folders\_Client_Configs\ $Imaging_Dest\PC_Setup\Client_Folders\_Client_Configs $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait

                # C:\WinPE_USB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive\PC_Setup\Client_Folders\Axxys
                # I:\PC_Setup\Client_Folders\Axxys
                $command = "ROBOCOPY $Imaging_Drive\PC_Setup\Client_Folders\Axxys\ $Imaging_Dest\PC_Setup\Client_Folders\Axxys\ $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait

                # C:\WinPE_USB_Install_Package\sources\Create_WinPE_USB\Imaging_Drive\PC_Setup\_Software_Collection\ODT
                # I:\PC_Setup\_Software_Collection\ODT
                $command = "XCOPY $Imaging_Drive\PC_Setup\_Software_Collection\ODT\*.bat $Imaging_Dest\PC_Setup\_Software_Collection\ODT\*.bat /h /Y"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait
                $command = "XCOPY $Imaging_Drive\PC_Setup\_Software_Collection\ODT\*.xml $Imaging_Dest\PC_Setup\_Software_Collection\ODT\*.xml /h /Y"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait
                $command = "XCOPY $Imaging_Drive\PC_Setup\_Software_Collection\ODT\*.exe $Imaging_Dest\PC_Setup\_Software_Collection\ODT\*.exe /h /Y"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized -Wait
            
            # TRANSFERS COMPLETED
            Write-Host "`nDownload\Update of " -NoNewline; Write-Host "$WinPE_USB_Package_DESTINATION" -NoNewline -ForegroundColor Cyan; Write-Host " is " -NoNewline; Write-Host "Complete" -ForegroundColor Green
        }
        #endregion Imaging USB Maintenance

        $this.Update()
        Write-Host "DisplayMenu Pause2"
        PAUSE
        Main_Menu
    }
}

<#
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
Write-Host $ScriptDir
#>

