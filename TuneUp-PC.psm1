##############################################################################
##############################################################################
###                                                                        ###
###                          -=[ Script Setup ]=-                          ###
###                                                                        ###
##############################################################################
##############################################################################
$RunOnceKey                                   = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"

# Modules Folder
    $FilePath_Local_AutomateSetup_Module             = "C:\Program Files\WindowsPowerShell\Modules\Automate-Setup\Automate-Setup.psm1"
    $FilePath_Local_ConfigurePC_Module               = "C:\Program Files\WindowsPowerShell\Modules\Configure-PC\Configure-PC.psm1"
    $FilePath_Local_InstallSoftware_Module           = "C:\Program Files\WindowsPowerShell\Modules\Install-Software\Install-Software.psm1"
    $FilePath_Local_TuneUpPC_Module                  = "C:\Program Files\WindowsPowerShell\Modules\TuneUp-PC\TuneUp-PC.psm1"
# 2. TuneUp
    $FolderPath_Local_TuneUp_PC_Status               = "C:\Setup\_TuneUp_PC\Status"
    $FilePath_Local_TuneUp_PC_Script                 = "C:\Setup\_TuneUp_PC\TuneUp-PC.ps1"
    $FilePath_Local_TuneUp_PC_DellInstaller          = "C:\Setup\_TuneUp_PC\Dell_Support_Assist_Installer.exe"
    $FilePath_Local_TuneUp_PC_HPInstaller            = "C:\Setup\_TuneUp_PC\HP_Support_Assistant.exe"
    $FilePath_Local_TuneUp_PC_Win10Installer         = "C:\Setup\_TuneUp_PC\MediaCreationTool21H2.exe"
    [string]$WindowsVersion_Latest                   = "22H2"

function Inject-TuneUp_PC {
    $what = '/COPY:DAT /DCOPY:DA /E'
    $options = '/R:5 /W:6 /LOG+:C:\Setup\TuneUp_Log.log /TEE /V /XO /XX'
    

    # Get USB Drive
    foreach ($Drive_Letter in (Get-PSDrive -PSProvider FileSystem).Name) {
        $Test_Path = "$Drive_Letter" + ":\PC_Setup"
        If (Test-Path $Test_Path -ErrorAction SilentlyContinue) {
            $USB_Drive = "$Drive_Letter" + ":"
        }
    }

    $source = "$USB_Drive\sources\PC-Maintenance\2. TuneUp PC\Setup\_TuneUp_PC"
    $dest = "C:\Setup\_TuneUp_PC"
    if (!(Test-Path $dest)) {New-Item $dest -ItemType Directory | Out-Null}   
    
    Write-Host "`nTransferring " -NoNewline; Write-Host "$source" -ForegroundColor Cyan
    Write-Host "to " -NoNewline; Write-Host "$dest" -ForegroundColor Cyan
    Write-Host "now..."

    $command = 'ROBOCOPY "' + $source + '" "' + $dest + '" ' + "$what $options"
    Start-Process cmd.exe -ArgumentList "/c $command" -Wait
    Write-Host "`nTransfer is " -NoNewline; Write-Host "Complete!" -ForegroundColor Green
} Export-ModuleMember -Function Inject-TuneUp_PC

function Start-TuneUp_PC {
    Write-Host ""
    if (!(Test-Path $FilePath_Local_TuneUp_PC_Script)) {
        Write-Host "TuneUp PC program is not detected on the current computer" -ForegroundColor Red
        Write-Host "First, Inject it into the PC" -ForegroundColor Yellow
    } else {
        Write-Host "Starting TuneUp PC program" -ForegroundColor Green
        Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -ArgumentList "-NoExit -Windowstyle maximized -ExecutionPolicy Bypass -File $FilePath_Local_TuneUp_PC_Script"
    }
} Export-ModuleMember -Function Start-TuneUp_PC

function Start-TuneUp_AtLogon {
    Set-ItemProperty -Path $RunOnceKey -Name TuneUpPC -Value ("C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe -NoExit -Windowstyle maximized -ExecutionPolicy Bypass -File $FilePath_Local_TuneUp_PC_Script") -Force
    Write-Host "Set Tune-Up script to run at next logon: " -NoNewline; Write-Host "Complete" -ForegroundColor Green
} Export-ModuleMember -Function Start-TuneUp_AtLogon

function Stop-TuneUp_AtLogon {
    Write-Host "`nStopping TuneUp PC program" -ForegroundColor Yellow
    Write-Host "-When you relog, the TuneUp PC program will no longer run automatically like before" -ForegroundColor Green
    Remove-ItemProperty -Path $RunOnceKey -Name TuneUpPC -Force -ErrorAction SilentlyContinue | Out-Null
} Export-ModuleMember -Function Stop-TuneUp_AtLogon

function Upgrade-Win10Version {
    [string]$WindowsVersion_Current=(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion).DisplayVersion
    
    If ($WindowsVersion_Current -ne $WindowsVersion_Latest) {
        # Update to latest Win10 version
        Write-Host "Please update the OS at this time to the latest major release"
        Write-Host "The upgrade installer should be launching shortly"
        Start-Process $FilePath_Local_TuneUp_PC_Win10Installer -Wait
        Pause
    } else {
        Write-Host "Current OS is already on latest version: $WindowsVersion_Latest" -ForegroundColor Green
    }
} Export-ModuleMember -Function Upgrade-Win10Version

function Install-Driver_Updates {
    #Variables - edit as needed
    $Step = "Update Drivers"
    
    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_TuneUp_PC_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        $choice = $null
        DO {
            Write-Host ""
            Write-Host "-=[ $Step ]=-" -ForegroundColor Yellow
            Write-Host "Would you like to $Step ?"
            Write-Host "1. Yes"
            Write-Host "2. No"
            [int]$choice = Read-Host -Prompt "Enter a number, 1 or 2"
        } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
        If ($choice -eq 1) {
            #Variables - edit as needed
            $Step = "Install Support Assistant"

            # Static Variables - DO NOT EDIT
            $StepStatus = "$FolderPath_Local_TuneUp_PC_Status\"+$Step.Replace(" ","_")
            $SkippedFile = "$StepStatus-Skipped.txt"
    
            If (Test-Path "$StepStatus*") {
                If (Test-Path "$StepStatus-Dell.txt") {Write-Host "Dell Support Assistant" -NoNewline; Write-Host " has been installed" -ForegroundColor Green}
                If (Test-Path "$StepStatus-HP.txt") {Write-Host "HP Support Assistant" -NoNewline; Write-Host " has been installed" -ForegroundColor Green}
                If (Test-Path $SkippedFile) {Write-Host "Both Dell and HP Support Assistant Installations" -NoNewline; Write-Host " have been skipped"}
            } else {
                $choice = $null
                DO {
                    Write-Host "`n-=[ $Step ]=-" -ForegroundColor Yellow
                    Write-Host "Which version of Support Assistant would you like to install?"
                    Write-Host "1. Dell"
                    Write-Host "2. HP"
                    Write-Host "3. NEITHER"
                    [int]$choice = Read-Host -Prompt "Enter a number, 1 through 3"
                } UNTIL (($choice -ge 1) -and ($choice -le 3))
                switch ($choice) {
                    1 {
                        $Software = "Dell Support Assist"
                        Write-Host ""
                        Write-Host "Installing $Software"
                        $InstallerPath = $FilePath_Local_TuneUp_PC_DellInstaller
                        Start-Process "$InstallerPath" -Wait
                        Write-Host "Verifying if the software is now installed..."
                        $Global:Installed_Software = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*
                        If (($Global:Installed_Software).DisplayName -match $Software) {
                            Write-Host "Installed - $Software" -ForegroundColor Green
                            if ($global:Automated_Setup) {New-Item "$StepStatus-Dell.txt" -ItemType File -Force | Out-Null}
                        } else {
                            Write-Host "$Software is not installed" -ForegroundColor Red
                            Write-Host "Reboot or just relog to re-attempt install"
                        }
                    }
                    2 {
                        $Software = "HP Support Assistant"
                        Write-Host ""
                        Write-Host "Installing $Software"
                        $InstallerPath = $FilePath_Local_TuneUp_PC_HPInstaller
                        Start-Process "$InstallerPath" -Wait
                        Write-Host "Verifying if the software is now installed..."
                        If ((Test-Path "C:\Program Files (x86)\HP\HP Support Framework\HP Support Assistant.ico") -OR (Test-Path "C:\Program Files (x86)\Hewlett-Packard\HP Support Framework\HPSF.exe")) {
                            Write-Host "Installed - $Software" -ForegroundColor Green
                            if ($global:Automated_Setup) {New-Item "$StepStatus-HP.txt" -ItemType File -Force | Out-Null}
                        } else {
                            Write-Host "$Software is not installed" -ForegroundColor Red
                            Write-Host "Reboot or just relog to re-attempt install"
                        }
                    }
                    3 {
                        Write-Host "Both Dell and HP Support Assistant Installations have been skipped" -ForegroundColor Green
                        if ($global:Automated_Setup) {New-Item $SkippedFile -ItemType File -Force | Out-Null}
                    }
                }
            }

            #Variables - edit as needed
            $Step = "Update Drivers"
    
            # Static Variables - DO NOT EDIT
            $StepStatus = "$FolderPath_Local_TuneUp_PC_Status\"+$Step.Replace(" ","_")
            $CompletionFile = "$StepStatus-Completed.txt"
            DO {
                Write-Host ""
                Write-Host "Please take a minute to run the HP or Dell support assistant tool to update the computer's drivers" -ForeGroundColor Yellow
                $input = Read-Host -Prompt "Type in 'continue' move on to the next step"
            } UNTIL ($input -eq "continue")
            Write-Host "$Step has been completed"
            if ($global:Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        } else {
            Write-Host "$Step has been skipped"
            if ($global:Automated_Setup) {New-Item $SkippedFile -ItemType File -Force | Out-Null}
        }
    }
} Export-ModuleMember -Function Install-Driver_Updates

function Defrag-HDD {

} Export-ModuleMember -Function Defrag-HDD