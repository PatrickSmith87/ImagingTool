######################################################################################################################################################################
######################################################################################################################################################################
###                                                                                                                                                                ###
###                                                                -=[ Configure-Profile Module ]=-                                                                ###
###                                                                                                                                                                ###
######################################################################################################################################################################
######################################################################################################################################################################
<#

#>

#region Profile Related Functions
########################################################
############## START Of Profile Functions ##############
########################################################
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

    # Display Source PC, Get Source User
    Clear-Host
    Write-Host "`nSource PC: " -NoNewline; Write-Host "$SourcePC" -ForegroundColor Cyan
    $Username = Read-Host -Prompt "Enter the username for the source PC. Example: psmith"
    $SourceProfile = "\\$SourcePC\C$\Users\$Username"
    
    # Display Source Info, Get Dest PC
    Clear-Host
    Write-Host "`nSource PC: " -NoNewline; Write-Host "$SourcePC" -ForegroundColor Cyan
    Write-Host "Source Username: " -NoNewline; Write-Host "$Username" -ForegroundColor Cyan
    Write-Host "Source Profile: " -NoNewline; Write-Host "$SourceProfile" -ForegroundColor Cyan
    Write-Host "`nEnter the name of the destination PC. Example Laptop-05"
    Write-Host "Or if it is this PC, just hit enter"
    $DestPC = Read-Host -Prompt "Destination PC"
    if ($DestPC -eq "") {$DestPC = $Computername}

    # Display Source Info, Get Dest User
    Clear-Host
    Write-Host "`nSource PC: " -NoNewline; Write-Host "$SourcePC" -ForegroundColor Cyan
    Write-Host "Source Username: " -NoNewline; Write-Host "$Username" -ForegroundColor Cyan
    Write-Host "Source Profile: " -NoNewline; Write-Host "$SourceProfile" -ForegroundColor Cyan
    Write-Host "`nDestination PC: " -NoNewline; Write-Host "$DestPC" -ForegroundColor Cyan
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
                Pause
            } Until ($null -ne $Dest)
        }
        $cmdArgs = @("$Source","$Dest",$what,$options)
        Robocopy @cmdArgs
        
        # MIGRATE - Chrome Profile
        $what = @("/COPYALL","/E")
        $options = @("/R:2","/W:3","/LOG:$DestProfile\MigrateUser_ChromeProfile.txt","/TEE","/V","/MT:16")
        $Destination = "$DestProfile\AppData\Local\Google\Chrome"
        if (!(Test-Path $Destination)) {
            DO {
                Clear-Host
                Write-Host "`n!!WARNING!! " -NoNewline -ForegroundColor Red; Write-Host "Chrome profile folder on destination PC not found..."
	            Write-Host "On the destination PC, open and then close Chrome for it to automatically create the Chrome profile folder`n"
                Pause
            } Until (Test-Path $Destination)
        }
        $cmdArgs = @("$SourceProfile\AppData\Local\Google\Chrome","$Destination",$what,$options)
        Robocopy @cmdArgs
        
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