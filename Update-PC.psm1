##################################################################################################################################################################
##################################################################################################################################################################
###                                                                                                                                                            ###
###                                                                  -=[ Update-PC Module ]=-                                                                  ###
###                                                                                                                                                            ###
##################################################################################################################################################################
##################################################################################################################################################################

#region Module Variables
$Software = New-Software
$TechTool = New-TechTool

# -=[ Static Variables ]=-
# Variables may be defined from parent script. If not, they will be defined from here.
[string]$DellDriverUpdaterSoftware                      = $null
$Setup_AS_Status_Fo                             = $TechTool.Setup_AS_Status_Fo
#endregion Module Variables

function ReUpdate-PC {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $RebootAllowed,
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    #Variables - edit as needed
    $Step = "Install Updates Again, Post-Image"
    
    # Static Variables - DO NOT EDIT
    $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If ((Test-Path $CompletionFile) -and !($Force) -and (($Automated_Setup) -or ($TuneUp_PC))) {
        Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    } else {
        Remove-Item -Path "$Setup_AS_Status_Fo\Install_a_Driver_Update_Assistant-Completed.txt" -Force
        Remove-Item -Path "$Setup_AS_Status_Fo\Install_Driver_Updates-Completed.txt" -Force
        Remove-Item -Path "$Setup_AS_Status_Fo\Install_HP_Softpaq_BIOS,_Drivers,_and_Firmware_Updates-Completed.txt" -Force
        Remove-Item -Path "$Setup_AS_Status_Fo\Install_Dell_BIOS,_Drivers,_and_Firmware_Updates-Completed.txt" -Force
        Remove-Item -Path "$Setup_AS_Status_Fo\Install_Windows_Updates-Completed.txt" -Force
        if ($Automated_Setup -or $TuneUp_PC) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }

    Update-PC
} Export-ModuleMember -Function ReUpdate-PC

function Update-PC {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $RebootAllowed,
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    if (!($Manufacturer)) {$Global:Manufacturer = Get-Manufacturer}

    Write-Host "`n-=[ Update PC ]=-" -ForegroundColor DarkGray
    Install-Windows_Updates
    Install-Driver_Updates
} Export-ModuleMember -Function Update-PC

#region driver update functions
function Install-Driver_Updates {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $RebootAllowed,
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    $Step = "Install Driver Updates"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    Install-DriverUpdateAssistant

    If ($Manufacturer -match "HP") {
        Install-HP_Drivers
    } elseif ($Manufacturer -match "Dell") {
        Install-Dell_Drivers
    } else {
        Write-Host "`n-=[ $Step ]=-" -ForegroundColor Yellow
        Write-Host "`n`$Manufacturer = $Manufacturer"
        Write-Host "Manufacturer not detected to be either HP or Dell"
        Write-Host "Please manually install driver updates before continuing with the setup"
        DO {$choice = Read-Host -Prompt "`nType in 'continue' to move on to the next step"} UNTIL ($choice -eq "continue")
        if ($Automated_Setup -or $TuneUp_PC) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }
} #end of Install-Driver_Updates function

function Install-HP_Drivers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $RebootAllowed,
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )
    
    # Variables - edit as needed
    $Step = "Install HP Softpaq BIOS, Drivers, and Firmware Updates"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If ((Test-Path $CompletionFile) -and !($Force) -and (($Automated_Setup) -or ($TuneUp_PC))) {
        # If task is completed or skipped...
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        # If task is not completed...

        # Keep installing updates and rebooting when needed until fully up to date
        Write-Host "Checking for and Installing HP Softpaq BIOS, Drivers, & Firmware Updates..."

        # Get USB Paths
        $USB = New-ImagingUSB
        if ($USB.Exists()) {
            $USB_Drive = $USB.Drive_Letter
            $FolderPath_USB_Driver_Collection = "$USB_Drive\PC_Setup\_Driver_Collection"
        }

        # Check for updates
        Write-Host "Checking for available updates..."
        $Arguments = '/Operation:Analyze /Action:List /Category:BIOS,Drivers,Firmware /Selection:All /Silent /ReportFolder:"C:\Setup\HPIA_Logs" /BIOSPwdFile:pwd1.bin'
        Start-Process "C:\Program Files\HP\HPIA\HPImageAssistant.exe" -ArgumentList $Arguments -WorkingDirectory "C:\Setup" -Wait
        Start-Sleep -Seconds 10
        $JSON_File = Get-ChildItem -Path "C:\Setup\HPIA_Logs\*.json" -ErrorAction SilentlyContinue
        $Status = Get-Content "$JSON_File" | ConvertFrom-Json
        # Install Updates if any are available
        $UpdateCount = $Status.HPIA.Recommendations.Count
        if ($UpdateCount -gt 0) {
            Write-Host "$UpdateCount updates found, installing now..."
            If ($USB.Exists()) {
                $Arguments = '/Operation:Analyze /Action:Install /Category:BIOS,Drivers,Firmware /Selection:All /Silent /ReportFolder:"C:\Setup\HPIA_Logs"' + " /SoftpaqDownloadFolder:$FolderPath_USB_Driver_Collection /BIOSPwdFile:pwd1.bin"
            } else {
                $Arguments = '/Operation:Analyze /Action:Install /Category:BIOS,Drivers,Firmware /Selection:All /Silent /ReportFolder:"C:\Setup\HPIA_Logs" /SoftpaqDownloadFolder:"C:\Setup\HPSoftpaqs" /BIOSPwdFile:pwd1.bin'
            }
            Start-Process "C:\Program Files\HP\HPIA\HPImageAssistant.exe" -ArgumentList $Arguments -WorkingDirectory "C:\Setup" -Wait
            Write-Host "Completed" -ForegroundColor Green
            if ($RebootAllowed) {
                Restart-Computer -Force | Out-Null
                Write-Host "Should be restarting soon..." -ForegroundColor Red
                Pause
            } else {
                Write-Host "(There may be additional updates after a reboot)"
            }
        } else {
            Write-Host "No updates found!"
            if ($Automated_Setup -or $TuneUp_PC) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
            Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
        }
    }
} #end of Install-HP_Drivers function

function Install-Dell_Drivers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $RebootAllowed,
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )
    
    # Variables - edit as needed
    $Step = "Install Dell BIOS, Drivers, and Firmware Updates"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If (Test-Path $CompletionFile) {
        # If task is completed or skipped...
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        $AvailableUpdates = Get-DellDriverUpdates
        if ($AvailableUpdates -gt 0) {
            Write-Output "Starting Dell Command Update Process. "
            if ($RebootAllowed) {
                Start-Process -FilePath "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/ApplyUpdates","-reboot=enable" -Wait
                Write-Host "Completed" -ForegroundColor Green
                Restart-Computer -Force | Out-Null
                Write-Host "Should be restarting soon..." -ForegroundColor Red
                Pause
            } else {
                Start-Process -FilePath "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/ApplyUpdates","-reboot=disable" -Wait
                Write-Host "Completed" -ForegroundColor Green
                Write-Host "(There may be additional updates after a reboot)"
            }
        } else {
            if ($Automated_Setup -or $TuneUp_PC) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
            Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
        }
    }
} #end of Install-Dell_Drivers function

function Get-DellDriverUpdates {
    # Get Activity
    Start-Process -FilePath "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/scan","-outputLog=C:\Setup\DellCommand.log" -Wait -WindowStyle Hidden
    [int]$UpdateCount = (((Select-String -Path "C:\Setup\DellCommand.log" -Pattern 'Number of applicable updates for the current system configuration:').ToString()).Split(":"))[-1]

    return $UpdateCount
} #end of Get-DellDriverUpdates
#endregion driver update functions

#region windows update functions
function Install-Windows_Updates {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $RebootAllowed,
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    $Step = "Install Windows Updates"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $PreReqCompletionFile = "$StepStatus-PreReqsCompleted.txt"

    If ((Test-Path $CompletionFile) -and !($Force) -and (($Automated_Setup) -or ($TuneUp_PC))) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Write-Host ""
        <#If (!(Test-Path $PreReqCompletionFile)) {
            New-Item $PreReqCompletionFile -ItemType File -Force | Out-Null
            Write-Host "Installing Windows Update Provider"
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
            Install-Module PSWindowsUpdate -Force
        }#>

        Write-Host "Installing Windows Update Provider"
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        Install-Module PSWindowsUpdate -Force

        Write-Host "Checking for available Windows Updates..."
        $Updates = Get-WindowsUpdate
        If ($Updates.count -gt 0) {
            Write-Host "Installing all available Windows Updates..."
            if ($RebootAllowed) {
                Get-WindowsUpdate -AcceptAll -Install -AutoReboot
                Restart-Computer -Force | Out-Null
                Write-Host "Should be restarting soon..." -ForegroundColor Red
                Pause
            } else {
                Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot
                Write-Host "Completed" -ForegroundColor Green
                Write-Host "(There may be additional updates after a reboot)"
            }
        } else {
            if ($Automated_Setup -or $TuneUp_PC) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
            Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
        }
    }
} #end of Install-Windows_Updates
#endregion windows update functions

#region shared functions
function NewCheck-CompletionFile {
    $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
}

function NewCreate-CompletionFile {

}
#endregion shared functions