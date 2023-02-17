######################################################################################################################################################################
######################################################################################################################################################################
###                                                                                                                                                                ###
###                                                                -=[ Configure-Profile Module ]=-                                                                ###
###                                                                                                                                                                ###
######################################################################################################################################################################
######################################################################################################################################################################
<#

#>

#region Module Variables
$TechTool = New-TechTool

$Setup_AS_Status_Fo                             = $TechTool.Setup_AS_Status_Fo

#region Profile Related Functions
########################################################
############## START Of Profile Functions ##############
########################################################
function Start-UserProfileSetup {
    # Variables - edit as needed
    $Step = "User Profile Setup"
    Write-Host "`n-=[ $Step ]=-" -ForegroundColor DarkGray

    # Static Variables - DO NOT EDIT
    $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"
    $InProgressFile = "$StepStatus-InProgress.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        if (!(Test-Path $InProgressFile)) {
            DO {
                Write-Host "`n-=[ $Step ]=-" -ForegroundColor Yellow
                Write-Host "At this point, the PC should be configured as much as possible before"
                Write-Host "  setting up the user profile of the person assigned to it"
                Write-Host "`nYou can now enter the $Step phase of the Automated Setup"
                Write-Host "  program " -NoNewline; Write-Host "(which is still under development and maybe buggy)" -ForegroundColor Red -NoNewline; Write-Host ", or skip"
                Write-Host "  that phase and end the program now"
                Write-Host "`nDo you want to enter the $Step phase?"
                Write-Host "  0. Skip $Step phase and end the Automated Setup program"
                Write-Host "  1. Yes, enter the $Step phase"
                $choice = Read-Host -Prompt "Enter a number, 0 or 1"
            } UNTIL (($choice -ge 0) -and ($choice -le 1))
            switch ($choice) {
                0 {
                    Write-Host "$Step has been skipped" -ForegroundColor Green
                    if ($Automated_Setup -or $TuneUp_PC) {New-Item $SkippedFile -ItemType File -Force | Out-Null}
                }
                1 {
                    Write-Host "Entering $Step" -ForegroundColor Green
                    if ($Automated_Setup -or $TuneUp_PC) {New-Item $InProgressFile -ItemType File -Force | Out-Null}
                }
            }
        }

        if (Test-Path $InProgressFile) {
            Create-LocalUser
            Login-AsUser
            Grant-LocalAdminRights
            Setup-RDP
            Redirect-Profile
            Checkpoint-LicenseOffice
            Checkpoint-ConfigureOneDrive
            Checkpoint-SignIntoOutlook
            Migrate-UserProfileData
            Install-ProfileSpecificSoftware
            if ($Automated_Setup -or $TuneUp_PC) {
                New-Item $CompletionFile -ItemType File -Force | Out-Null
            }
            Remove-Item $InProgressFile -Force | Out-Null
            Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
        }
    }

    
    
    
    <#
    OLD PC Checklist:
        1. STOP, sign into OneDrive, Enable Backup, Verify sync has started, Monitor progress (OneDrive Sync tends to get stuck if a large number of files are syncing and\or Files are being moved around at the same time).
        2. Sign into browsers? or not needed?
        3. Take screenshot of taskbar icons, printers, mapped drives, desktop icons, quick access in file explorer > save to desktop  
    #>
} Export-ModuleMember -Function Start-UserProfileSetup

function Create-LocalUser {
    # Variables - edit as needed
    $Step = "Create Local User"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
    }
}

function Login-AsUser {
    <#
    Check for complete file
            If not already noted, should take note of the currently logged on user. 
            When script runs again (After loging in as new user [ideally], or if just signs into same account), it will compare usernames again and if it is different, continues to next step
                log completion
    #>
}

function Grant-LocalAdminRights {
    <#
    make user a local admin...
    #>
}

function Setup-RDP {
    <#
    enable RDP and add user\group to allowed list?
    #>
}

function Redirect-Profile {
    <#
    Configure redirected profiles?
    #>
}

function Checkpoint-LicenseOffice {
    #STOP, sign into Word (launch word) and sign in to license Office
}

function Checkpoint-ConfigureOneDrive {
    #STOP, sign into OneDrive, Enable Backup, Verify sync has started, Monitor progress (OneDrive Sync tends to get stuck if a large number of files are syncing and\or Files are being moved around at the same time).
}

function Checkpoint-SignIntoOutlook {
    # STOP, sign into Outlook (or should we transfer the profile data first?)
}

function Migrate-UserProfileData {
    <#
    check for complete file
    Should run the migrate user script
    log completion
    #>
}

function Install-ProfileSpecificSoftware { # This function should go to Install-Software module most likely...
    <#
    Install-Profile_Specific_Software
        Install profile specific softwares located under 
        This will likely call several other functions to:
            Install-DropBox
            Install-OneNote (Is this actually profile specific? If not, needs added to script during PC Imaging)
    #>
}

function Set-ProfileDefaultSettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $AdminProfile,

        [Parameter(Mandatory = $false)]
        [switch] $RestartExplorer
    )
    
    # Variables - edit as needed
    $Step = "Set Profile Default Settings"

    # Static Variables - DO NOT EDIT
    if ($Automated_Setup) {
        $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
        $CompletionFile = "$StepStatus-Completed.txt"
    }

    If (($Automated_Setup) -and (Test-Path "$StepStatus*")) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Disable-Live_Tiles
        Remove-CortanaFromTaskbar
        Remove-PeopleFromTaskbar
        Remove-TaskViewButtonFromTaskbar
        Show-SearchIcon
        If ($AdminProfile) {
            Show-FileExtensions -Scope CurrentUser
            Show-HiddenObjects -Scope CurrentUser
            Show-ALLSysTrayIcons -Scope CurrentUser
            Hide-NewsIcon -Scope CurrentUser
        }
        if ($RestartExplorer) {Restart-Explorer}

        if ($Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }    
} Export-ModuleMember -Function Set-ProfileDefaultSettings

function Show-FileExtensions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('CurrentUser','Computer')]
        [string] $Scope,

        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    if ($Scope) {$Step = "Show File Extensions - $Scope"} else {$Step = "Show File Extensions"}

    # Static Variables - DO NOT EDIT
    if ($Automated_Setup) {
        $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
        $CompletionFile = "$StepStatus-Completed.txt"
    }
    $Key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    # 0=Show 1=Hide

    If (($Automated_Setup) -and (Test-Path "$StepStatus*") -and (!($Force))) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        if ($Scope -eq 'CurrentUser') {
            Set-ItemProperty -Path $Key -Name HideFileExt -Value 0 -Force
        } elseif ($Scope -eq 'Computer') {
            Set-ItemProperty -Path $Key -Name HideFileExt -Value 0 -Force
        } else {
            Set-ItemProperty -Path $Key -Name HideFileExt -Value 0 -Force
            Set-ItemProperty -Path $Key -Name HideFileExt -Value 0 -Force
        }

        if ($Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Show-FileExtensions

function Show-HiddenObjects {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('CurrentUser','Computer')]
        [string] $Scope,

        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    if ($Scope) {$Step = "Show Hidden Objects - $Scope"} else {$Step = "Show Hidden Objects"}

    # Static Variables - DO NOT EDIT
    if ($Automated_Setup) {
        $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
        $CompletionFile = "$StepStatus-Completed.txt"
    }
    $Key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    # 1=Show 2=Hide

    If (($Automated_Setup) -and (Test-Path "$StepStatus*") -and (!($Force))) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        if ($Scope -eq 'CurrentUser') {
            Set-ItemProperty -Path $Key -Name Hidden -Value 1 -Force
        } elseif ($Scope -eq 'Computer') {
            Set-ItemProperty -Path $Key -Name Hidden -Value 1 -Force
        } else {
            Set-ItemProperty -Path $Key -Name Hidden -Value 1 -Force
            Set-ItemProperty -Path $Key -Name Hidden -Value 1 -Force
        }

        if ($Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Show-HiddenObjects

function Disable-Live_Tiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('CurrentUser','Computer')]
        [string] $Scope,

        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    if ($Scope) {$Step = "Remove Cortana From Taskbar - $Scope"} else {$Step = "Remove Cortana From Taskbar"}
    
    # Static Variables - DO NOT EDIT
    if ($Automated_Setup) {
        $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
        $CompletionFile = "$StepStatus-Completed.txt"
    }

    If (($Automated_Setup) -and (Test-Path "$StepStatus*") -and (!($Force))) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        if ($Scope -eq 'CurrentUser') {
            cmd.exe /c 'REG ADD "HKCU\Software\Policies\Microsoft\Windows\CurrentVersion\Pushnotications" /v NoTileApplictionNotification /d 1 /f /t REG_DWORD' | Out-Null
        } elseif ($Scope -eq 'Computer') {
            cmd.exe /c 'REG ADD "HKLM\Software\Policies\Microsoft\Windows\CurrentVersion\Pushnotications" /v NoTileApplictionNotification /d 1 /f /t REG_DWORD' | Out-Null
        } else {
            cmd.exe /c 'REG ADD "HKLM\Software\Policies\Microsoft\Windows\CurrentVersion\Pushnotications" /v NoTileApplictionNotification /d 1 /f /t REG_DWORD' | Out-Null
            cmd.exe /c 'REG ADD "HKCU\Software\Policies\Microsoft\Windows\CurrentVersion\Pushnotications" /v NoTileApplictionNotification /d 1 /f /t REG_DWORD' | Out-Null
        }

        if ($Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Disable-Live_Tiles

function Remove-CortanaFromTaskbar {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('CurrentUser','Computer')]
        [string] $Scope,

        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    if ($Scope) {$Step = "Remove Cortana From Taskbar - $Scope"} else {$Step = "Remove Cortana From Taskbar"}

    # Static Variables - DO NOT EDIT
    if ($Automated_Setup) {
        $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
        $CompletionFile = "$StepStatus-Completed.txt"
    }

    If (($Automated_Setup) -and (Test-Path "$StepStatus*") -and (!($Force))) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        if ($Scope -eq 'CurrentUser') {
            cmd.exe /c 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCortanaButton /d 0 /f /t REG_DWORD' | Out-Null
        } elseif ($Scope -eq 'Computer') {
            cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCortanaButton /d 0 /f /t REG_DWORD' | Out-Null
        } else {
            cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCortanaButton /d 0 /f /t REG_DWORD' | Out-Null
            cmd.exe /c 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCortanaButton /d 0 /f /t REG_DWORD' | Out-Null
        }

        if ($Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step is " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Remove-CortanaFromTaskbar

function Remove-PeopleFromTaskbar {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('CurrentUser','Computer')]
        [string] $Scope,

        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    if ($Scope) {$Step = "Remove People From Taskbar - $Scope"} else {$Step = "Remove People From Taskbar"}

    # Static Variables - DO NOT EDIT
    if ($Automated_Setup) {
        $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
        $CompletionFile = "$StepStatus-Completed.txt"
    }

    If (($Automated_Setup) -and (Test-Path "$StepStatus*") -and (!($Force))) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        if ($Scope -eq 'CurrentUser') {
            cmd.exe /c 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v PeopleBand /d 0 /f /t REG_DWORD' | Out-Null
        } elseif ($Scope -eq 'Computer') {
            cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v PeopleBand /d 0 /f /t REG_DWORD' | Out-Null
        } else {
            cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v PeopleBand /d 0 /f /t REG_DWORD' | Out-Null
            cmd.exe /c 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v PeopleBand /d 0 /f /t REG_DWORD' | Out-Null
        }

        if ($Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step is " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Remove-PeopleFromTaskbar

function Remove-TaskViewButtonFromTaskbar {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('CurrentUser','Computer')]
        [string] $Scope,

        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    if ($Scope) {$Step = "Remove Task View Button From Taskbar - $Scope"} else {$Step = "Remove Task View Button From Taskbar"}

    # Static Variables - DO NOT EDIT
    if ($Automated_Setup) {
        $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
        $CompletionFile = "$StepStatus-Completed.txt"
    }

    If (($Automated_Setup) -and (Test-Path "$StepStatus*") -and (!($Force))) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        if ($Scope -eq 'CurrentUser') {
            cmd.exe /c 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /d 0 /f /t REG_DWORD' | Out-Null
        } elseif ($Scope -eq 'Computer') {
            cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /d 0 /f /t REG_DWORD' | Out-Null
        } else {
            cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /d 0 /f /t REG_DWORD' | Out-Null
            cmd.exe /c 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /d 0 /f /t REG_DWORD' | Out-Null
        }
        
        if ($Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step is " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Remove-TaskViewButtonFromTaskbar

function Show-ALLSysTrayIcons {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('CurrentUser','Computer')]
        [string] $Scope,

        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    if ($Scope) {$Step = "Show all System Tray Icons - $Scope"} else {$Step = "Show all System Tray Icons"}

    # Static Variables - DO NOT EDIT
    if ($Automated_Setup) {
        $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
        $CompletionFile = "$StepStatus-Completed.txt"
    }

    If (($Automated_Setup) -and (Test-Path "$StepStatus*") -and (!($Force))) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        if ($Scope -eq 'CurrentUser') {
            cmd.exe /c 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v EnableAutoTray /d 0 /f /t REG_DWORD' | Out-Null
        } elseif ($Scope -eq 'Computer') {
            cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v EnableAutoTray /d 0 /f /t REG_DWORD' | Out-Null
        } else {
            cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v EnableAutoTray /d 0 /f /t REG_DWORD' | Out-Null
            cmd.exe /c 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v EnableAutoTray /d 0 /f /t REG_DWORD' | Out-Null
        }

        if ($Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step is " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Show-ALLSysTrayIcons

function Show-SearchIcon {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('CurrentUser','Computer')]
        [string] $Scope,

        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    if ($Scope) {$Step = "Show Search Icon - $Scope"} else {$Step = "Show Search Icon"}

    # Static Variables - DO NOT EDIT
    if ($Automated_Setup) {
        $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
        $CompletionFile = "$StepStatus-Completed.txt"
    }

    If (($Automated_Setup) -and (Test-Path "$StepStatus*") -and (!($Force))) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        if ($Scope -eq 'CurrentUser') {
            cmd.exe /c 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /d 1 /f /t REG_DWORD' | Out-Null
        } elseif ($Scope -eq 'Computer') {
            cmd.exe /c 'REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /d 1 /f /t REG_DWORD' | Out-Null
        } else {
            cmd.exe /c 'REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /d 1 /f /t REG_DWORD' | Out-Null
            cmd.exe /c 'REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /d 1 /f /t REG_DWORD' | Out-Null
        }

        if ($Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step is " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Show-SearchIcon

function Hide-NewsIcon {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('CurrentUser','Computer')]
        [string] $Scope,

        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    if ($Scope) {$Step = "Hide News Icon - $Scope"} else {$Step = "Hide News Icon"}
    
    # Static Variables - DO NOT EDIT
    if ($Automated_Setup) {
        $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
        $CompletionFile = "$StepStatus-Completed.txt"
    }

    If (($Automated_Setup) -and (Test-Path "$StepStatus*") -and (!($Force))) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        if ($Scope -eq 'CurrentUser') {
            cmd.exe /c 'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /d 2 /f /t REG_DWORD' | Out-Null
        } elseif ($Scope -eq 'Computer') {
            cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /d 2 /f /t REG_DWORD' | Out-Null
        } else {
            cmd.exe /c 'REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /d 2 /f /t REG_DWORD' | Out-Null
            cmd.exe /c 'REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /d 2 /f /t REG_DWORD' | Out-Null
        }

        if ($Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step is " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Hide-NewsIcon

function Restart-Explorer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    $Step = "Restart-Explorer"

    # Static Variables - DO NOT EDIT
    if ($Automated_Setup) {
        $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
        $CompletionFile = "$StepStatus-Completed.txt"
    }

    If (($Automated_Setup) -and (Test-Path "$StepStatus*") -and (!($Force))) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Pause
        cmd.exe /c 'taskkill /F /IM explorer.exe' | Out-Null
        Start-Sleep 3
        #cmd.exe /c 'start explorer.exe' | Out-Null
        Start-Process powershell -ArgumentList '-command cmd.exe /c "start explorer.exe"' -WindowStyle Hidden
        
        if ($Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step is " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Restart-Explorer

function Sync-UserProfile {
    $Host.UI.RawUI.BackgroundColor = 'Black'
    $Computername = Hostname

    # INTRO
    Clear-Host
    Write-Host "`nThis script will migrate user profile data from one computer to another" -ForegroundColor Cyan
    Write-Host "`nNOTE: " -NoNewline -ForegroundColor Yellow; Write-Host "When this script asks for a username, technically it is asking for the name of the user's profile folder under C:\Users\. If you encounter issues running the script, you may want to confirm that the user's folder doesn't have .LOCAL, .TEMP, or .ATI (or whatever the client's NETBIOS is)`n`n"
    Pause
    
    # Get Source PC
    Clear-Host
    Write-Host "`nEnter the name of the source PC. Example: Desktop-01"
    Write-Host "Or if it is this PC, just hit enter"
    $SourcePC = Read-Host -Prompt "Source PC"
    if ($SourcePC -eq "") {$SourcePC = $Computername}

    # Display Source PC
    Clear-Host
    Write-Host "`nSource PC: " -NoNewline; Write-Host "$SourcePC" -ForegroundColor Cyan

    # Get Source User
    $Username = Read-Host -Prompt "Enter the username for the source PC. Example: psmith"
    $SourceProfile = "\\$SourcePC\C$\Users\$Username"
    
    # Display Source Info
    Clear-Host
    Write-Host "`nSource PC: " -NoNewline; Write-Host "$SourcePC" -ForegroundColor Cyan
    Write-Host "Source Username: " -NoNewline; Write-Host "$Username" -ForegroundColor Cyan
    Write-Host "Source Profile: " -NoNewline; Write-Host "$SourceProfile" -ForegroundColor Cyan
    
    # Get Dest PC
    Write-Host "`nEnter the name of the destination PC. Example Laptop-05"
    Write-Host "Or if it is this PC, just hit enter"
    $DestPC = Read-Host -Prompt "Destination PC"
    if ($DestPC -eq "") {$DestPC = $Computername}

    # Display Known Info
    Clear-Host
    Write-Host "`nSource PC: " -NoNewline; Write-Host "$SourcePC" -ForegroundColor Cyan
    Write-Host "Source Username: " -NoNewline; Write-Host "$Username" -ForegroundColor Cyan
    Write-Host "Source Profile: " -NoNewline; Write-Host "$SourceProfile" -ForegroundColor Cyan
    Write-Host "`nDestination PC: " -NoNewline; Write-Host "$DestPC" -ForegroundColor Cyan

    #Get Dest User
    Write-Host "`nEnter the username for the destination PC. If it is the same, just leave blank and hit enter"
    $Username2 = Read-Host -Prompt "Example: psmith.ATI"
    if ($Username2 -eq "") {$Username2 = $Username}
    $DestProfile = "\\$DestPC\C$\Users\$Username2"

    # Transfer Confirmation
    Clear-Host
    Write-Host "`nScript will migrate files from"
    Write-Host "$SourceProfile" -ForegroundColor Cyan
    Write-Host "to"
    Write-Host "$DestProfile" -ForegroundColor Cyan
    Write-Host "`nReview the above information before continuing. When you hit any key, the profile migration will begin"
    Pause

    # Verify Source Profile Access
    Clear-Host
    if (!(Test-Path $SourceProfile)) {
        DO {
            Write-Host "`n!!WARNING!! " -ForegroundColor Red -NoNewline; Write-Host "Source profile not found. Open File Explorer and make sure you can reach $SourceProfile. You may need to authenticate to the machine, or enable Network Discovery and File and Printer Sharing settings so that the computers filesystem can be accessed remotely.`n"
            Pause
        } Until (Test-Path $SourceProfile)
    }
    

    # Verify Dest Profile Access
    Clear-Host
    if (!(Test-Path $DestProfile)) {
        DO {
            Write-Host "`n!!WARNING!! " -ForegroundColor Red -NoNewline; Write-Host "Destination profile not found."
            if ($Computername -eq $DestProfile) {
                Write-Host "Make sure to sign into this computer with the user's credentials in order to create the user's profile on this PC first"
                Write-Host "THEN run this script to migrate the user's profile data"
            } else {
                Write-Host "Open File Explorer and make sure you can reach $DestProfile"
                Write-Host "You may need to authenticate to the machine, or enable Network Discovery and File and Printer Sharing settings so that the computers filesystem can be accessed remotely."
            }
            Pause
        } Until (Test-Path $DestProfile)
    }

    # Start Profile Data Migration
    function Start_Profile_Data_Migration {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            [string] $SourceProfile,

            [Parameter(Mandatory = $true)]
            [string] $DestProfile
        )
        $what = @("/COPYALL","/B","/E")

        # MIGRATE - User Profile - Minus Hidden, System, Backups, AppData, etc.
        $options = @("/R:2","/W:3","/LOG:$DestProfile\MigrateUser_RoboLog.txt","/TEE","/V","/XX","/XO","/XA:SH","/XD","*temp","""temporary internet files""","*cache","mozilla","*desktop.ini*","*OneDrive*","*DropBox*","$SourceProfile\AppData","""$SourceProfile\Application Data""","/XJ","/MT:16")
        $cmdArgs = @("$SourceProfile","$DestProfile",$what,$options)
        #$command = "ROBOCOPY $SourceProfile $DestProfile $what $options"
        #Start-Process cmd.exe -ArgumentList "/c $command" -Wait
        Robocopy @cmdArgs

        # MIGRATE - Adobe Acrobat DC Stamps
        $options = @("/R:2","/W:3","/LOG:$DestProfile\MigrateUser_AcrobatDCStamps.txt","/TEE","/V","/XX","/XO","/MT:16")
        $cmdArgs = @("$SourceProfile\AppData\Roaming\Adobe\Acrobat\DC\Stamps","$DestProfile\AppData\Roaming\Adobe\Acrobat\DC\Stamps",$what,$options)
        #$command = "ROBOCOPY ""$SourceProfile\AppData\Roaming\Adobe\Acrobat\DC\Stamps"" ""$DestProfile\AppData\Roaming\Adobe\Acrobat\DC\Stamps"" $what $options"
        #Start-Process cmd.exe -ArgumentList "/c $command" -Wait
        Robocopy @cmdArgs

        # MIGRATE - Sticky Notes
        # DOES NOT APPEAR TO BE WORKING!!!?
        $options = @("/R:2","/W:3","/LOG:$DestProfile\MigrateUser_StickyNotes.txt","/TEE","/V","/XX","/XO","/MT:16")
        $cmdArgs = @("$SourceProfile\AppData\Roaming\Microsoft\Sticky Notes","$DestProfile\AppData\Roaming\Microsoft\Sticky Notes",$what,$options)
        Robocopy @cmdArgs
        
        # MIGRATE - Outlook Signatures
        $options = @("/R:2","/W:3","/LOG:$DestProfile\MigrateUser_OutlookSignatures.txt","/TEE","/V","/XX","/XO","/MT:16")
        $cmdArgs = @("$SourceProfile\AppData\Roaming\Microsoft\Signatures","$DestProfile\AppData\Roaming\Microsoft\Signatures",$what,$options)
        Robocopy @cmdArgs
        
        # MIGRATE - Firefox Profile
        $what = @("/COPY:DAT","/E")
        $options = @("/R:2","/W:3","/LOG:$DestProfile\MigrateUser_FirefoxProfile.txt","/TEE","/V","/XX","/XO","/MT:16")
        if (Test-Path "$SourceProfile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release-*") {
            $Source = (Get-ChildItem "$SourceProfile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release-*").FullName
        } else {
            $Source = (Get-ChildItem "$SourceProfile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release").FullName
        }

        if ($Source) {
            # Firefox Profile found in source profile
            # Now verify Firefox Profile exists in destination profile
            DO {
                if (Test-Path "$DestProfile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release-*") {
                    $Dest = (Get-ChildItem "$DestProfile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release-*").FullName
                } else {
                    $Dest = (Get-ChildItem "$DestProfile\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release").FullName
                }
                if ($null -eq $Dest) {
                    DO {
                        Clear-Host
                        Write-Host "`nWARNING!! " -NoNewline -ForegroundColor Red; Write-Host "Firefox profile folder on destination PC not found.."
                        Write-Host "On the destination PC, please open and then close firefox to automatically create the Firefox profile folder`n"
                        Write-Host "1. Continue (Will check again to make sure the Firefox profile in the destination now exists)"
                        Write-Host "2. Skip (Will NOT migrate the Firefox profile that was found on the source profile)"
                        [int]$choice = Read-Host -Prompt "Enter a number, 1 or 2"
                    } Until (($choice -ge 1) -and ($choice -le 2))
                }
            } Until (($null -ne $Dest) -or ($choice -eq 2))
            # Finally, Migrate Firefox Profile if not skipping
            if ($null -ne $Dest) {
                $cmdArgs = @("$Source","$Dest",$what,$options)
                Robocopy @cmdArgs
            }
        } else {
            # Firefox Profile NOT found in source profile
            # Do nothing and move on to the next item to migrate
        }
        
        # MIGRATE - Chrome Profile
        $what = @("/COPYALL","/E")
        $options = @("/R:2","/W:3","/LOG:$DestProfile\MigrateUser_ChromeProfile.txt","/TEE","/V","/MT:16")
        $Source = "$SourceProfile\AppData\Local\Google\Chrome"
        $Destination = "$DestProfile\AppData\Local\Google\Chrome"

        if (Test-Path $Source) {
            # Chrome Profile found in source profile
            # Now verify Chrome Profile exists in destination profile
            DO {
                if (!(Test-Path $Destination)) {
                    DO {
                        Clear-Host
                        Write-Host "`nWARNING!! " -NoNewline -ForegroundColor Red; Write-Host "Chrome profile folder on destination PC not found.."
                        Write-Host "On the destination PC, please open and then close Chrome to automatically create the Chrome profile folder`n"
                        Write-Host "1. Continue (Will check again to make sure the Chrome profile in the destination now exists)"
                        Write-Host "2. Skip (Will NOT migrate the Chrome profile that was found on the source profile)"
                        [int]$choice = Read-Host -Prompt "Enter a number, 1 or 2"
                    } Until (($choice -ge 1) -and ($choice -le 2))
                }
            } Until ((Test-Path $Destination) -or ($choice -eq 2))
            # Finally, Migrate Chrome Profile if not skipping
            if (Test-Path $Destination) {
                $cmdArgs = @("$Source","$Destination",$what,$options)
                Robocopy @cmdArgs
            }
        } else {
            # Chrome Profile NOT found in source profile
            # Do nothing and move on to the next item to migrate
        }
        #test
        # Complete!
        Write-Host "`nUser Migration is complete!!" -ForegroundColor Cyan
        Write-Host "`nWhat would you like to do now?"
        Write-Host "1. Run same migration again"
        Write-Host "2. Run a new migration on different profiles"
        Write-Host "3. Close this script"
        [int]$choice = Read-Host -Prompt "Enter your choice (1, 2, or 3)"
        Switch ($choice) {
            1 {Clear-Host; Start_Profile_Data_Migration -SourceProfile $SourceProfile -DestProfile $DestProfile}
            2 {Clear-Host; Sync-UserProfile}
            3 {Clear-Host}
        }
    }
    Start_Profile_Data_Migration -SourceProfile $SourceProfile -DestProfile $DestProfile
} Export-ModuleMember -Function Sync-UserProfile
######################################################
############## END Of Profile Functions ##############
######################################################
#endregion Profile Related Functions