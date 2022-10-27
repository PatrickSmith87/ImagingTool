##############################################################################
##############################################################################
###                                                                        ###
###                          -=[ Script Setup ]=-                          ###
###                                                                        ###
##############################################################################
##############################################################################

# Variables may be defined from parent script. If not, they will be defined from here.
# Child scripts should be able to see variables from the parent script...
# However the child script cannot modify the parent's variables unless the scope is defined.
# This should not be a problem since the child script does not need to modify these variables.
# The goal here is to allow the modules to run independantly of the "Automate-Setup" script

# -=[ Static Variables ]=-
# Variables may be defined from parent script. If not, they will be defined from here.
$FolderPath_Local_Setup                 = "C:\Setup"
$FolderPath_Local_AutomatedSetup_Status = "C:\Setup\_Automated_Setup\Status"
$FolderPath_Local_Software              = "C:\Setup\_Software_Collection"
$FolderPath_Local_Software_Configs      = "C:\Setup\_Software_Collection\_Software_Configs"
$FolderPath_Local_ODT_Software          = "C:\Setup\_Software_Collection\ODT"
$FolderPath_Local_Profile_Software      = "C:\Setup\_Software_Collection\Profile_Specific_Software"
$FolderPath_Local_Standard_Software     = "C:\Setup\_Software_Collection\Standard_Software"

##############################################################
############## START OF CLIENT CONFIG FUNCTIONS ##############
##############################################################

function Create-SoftwareConfig {
    $in = $null
    Do {$in = Read-Host -Prompt "Input Software Name"} Until ($in -ne "")
    $Global:Software_Settings = [PSCustomObject]@{
        Name = $in
    }
    Save-SoftwareSettings

    $in = $null
    Do {$in = Read-Host -Prompt "Input Installer Name (Example: Setup.exe)"} Until ($in -ne "")
    Add-SoftwareSetting -Name Installer_Name -Value $in

    $in = $null
    Do {$in = Read-Host -Prompt "Input Installer Source { ODT | Profile_Specific_Software | Standard_Software}"} Until ($in -ne "")
    Add-SoftwareSetting -Name Installer_Source -Value $in

    Write-Host "`nThe next two settings are for a DIRECT DOWNLOAD URL and for the general Installer Download Page"
    Write-Host "Only one of the two should be entered, ideally the Direct Download URL..."
    Write-Host "It is also ok to provide neither"

    $in = $null
    $in = Read-Host -Prompt 'Input Installer DIRECT DOWNLOAD URL (Example: www.DIRECTdownloadlink.com)'
    If ($in -ne "") {Add-SoftwareSetting -Name URL -Value $in}

    $in = $null
    $in = Read-Host -Prompt 'Input Installer Download Page (Example: https://get.adobe.com/reader/)'
    If ($in -ne "") {Add-SoftwareSetting -Name Manual_URL -Value $in}

    $in = $null
    $in = Read-Host -Prompt 'Input Installation Arguments (Example: "/qn" if .msi, maybe "" or "$null" or "/S /v/qn" or "/silent","/install" if .exe)'
    If ($in -ne "") {Add-SoftwareSetting -Name Arguments -Value $in}

    $in = $null
    $in = Read-Host -Prompt "Input Installer Verification Path (Example: C:\Program Files\Google\Chrome\Application\chrome.exe)"
    If ($in -ne "") {Add-SoftwareSetting -Name Verification_Path -Value $in}
} Export-ModuleMember -Function Create-SoftwareConfig

function Read-SoftwareConfig {
    $SoftwareConfig = $null
    $USB = [ImagingUSB]::new()
    if ($USB.Exists()) {
        $FolderPath_USB_Install_Software_Software_Configs  = $USB.Install_Software_Software_Configs
    }

    If ($USB.Exists()) {
        $SoftwareConfigs = (Get-ChildItem -Path "$FolderPath_USB_Install_Software_Software_Configs\*.SoftwareConfig" -ErrorAction SilentlyContinue)
        Write-Host "Imaging Tool Software Config Repository found. Loading Software Config files.." -ForegroundColor Green
    } else {
        $SoftwareConfigs = (Get-ChildItem -Path "$FolderPath_Local_Software_Configs\*.SoftwareConfig" -ErrorAction SilentlyContinue)
        Write-Host "Local Software Config Repository found. Loading Software Config files.." -ForegroundColor Green
    }
    If ($SoftwareConfigs.Count -gt 0) {
        Write-Host ""
        Do {
            Write-Host "   -=[ Available Software Config Files ]=-"
            $Count = 1
            $Line = "   $Count" + ": Read ALL"
            Write-Host $Line
            $Count++
            ForEach ($SoftwareConfig in $SoftwareConfigs) {
                $Line = "   $Count" + ": " + $SoftwareConfig.Name
                Write-Host $Line
                $Count++
            }
            $Line = "   $Count" + ": " + "OR, Go Back..."
            Write-Host $Line
            Write-Host ""
            [int]$choice = Read-Host -Prompt "Which Client Config file would you like to read the properties of? (Enter a number from 1 to $Count)"
        } Until (($choice -gt 0) -and ($choice -le $Count))
        If (($choice -gt 1) -and ($choice -lt $Count)) {
            $SoftwareConfig = $SoftwareConfigs[$choice-2]
            Write-Host ">Loading"$SoftwareConfig.Name -ForegroundColor Yellow
            $SoftwareConfigFile = $SoftwareConfig.FullName
            Get-Member -InputObject (Get-Content -Path $SoftwareConfigFile | ConvertFrom-Json) -MemberType NoteProperty | Format-Table -Property Name,Definition -AutoSize
        } elseif ($choice -eq 1) {
            ForEach ($SoftwareConfig in $SoftwareConfigs) {
                Write-Host ""
                Write-Host ">Loading"$SoftwareConfig.Name -ForegroundColor Yellow
                $SoftwareConfigFile = $SoftwareConfig.FullName
                Get-Member -InputObject (Get-Content -Path $SoftwareConfigFile | ConvertFrom-Json) -MemberType NoteProperty | Format-Table -Property Name,Definition -AutoSize    
            }
        }
    } else {
        If ($USB.Exists()) {
            Write-Host "Could not find any Software Configs in the Imaging Tool Software Config Repository:"
            Write-Host "> $FolderPath_USB_Install_Software_Software_Configs"
        } else {
            Write-Host "Could not find any Software Configs in the Local Software Config Repository:"
            Write-Host "> $FolderPath_Local_Software_Configs"
        }
        Write-Host ""
    }
} Export-ModuleMember -Function Read-SoftwareConfig

function Get-SoftwareSettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $SoftwareName
    )

    $Global:Software_Settings = $null
    $Local_Software_Config_File = "$FolderPath_Local_Software_Configs\$SoftwareName.SoftwareConfig"
    # Get USB Paths
    $USB = [ImagingUSB]::new()
    if ($USB.Exists()) {
        $FolderPath_USB_Install_Software_Software_Configs  = $USB.Install_Software_Software_Configs
        $USB_Software_Config_File = "$FolderPath_USB_Install_Software_Software_Configs\$SoftwareName.SoftwareConfig"
    }

    # First, check for a Software Config file under $FolderPath_Local_Software_Configs
    If (Test-Path $Local_Software_Config_File) {
        $Global:Software_Settings = (Get-Content -Path $Local_Software_Config_File | ConvertFrom-Json)
    # Then, check for a Software Config file under $FolderPath_USB_Install_Software_Software_Configs
    } elseif ($USB_Software_Config_File) {$Global:Software_Settings = (Get-Content -Path $USB_Software_Config_File | ConvertFrom-Json)}

    If ($Global:Software_Settings) {
        #Write-Host "$SoftwareName software config has been loaded"
    }
} Export-ModuleMember -Function Get-SoftwareSettings

function Save-SoftwareSettings {
    $SoftwareName = $Global:Software_Settings.Name

    # Save locally
    $Local_Software_Config_File = "$FolderPath_Local_Software_Configs\$SoftwareName.SoftwareConfig"
    $Global:Software_Settings | ConvertTo-Json -depth 1 | Set-Content -Path $Local_Software_Config_File -Force
    
    # Save to USB if plugged in
    $USB = [ImagingUSB]::new()
    if ($USB.Exists()) {
        $FolderPath_USB_Install_Software_Software_Configs  = $USB.Install_Software_Software_Configs
        $USB_Software_Config_File = "$FolderPath_USB_Install_Software_Software_Configs\$SoftwareName.SoftwareConfig"
        $Global:Software_Settings | ConvertTo-Json -depth 1 | Set-Content -Path $USB_Software_Config_File -Force
    }
} Export-ModuleMember -Function Save-SoftwareSettings

function Add-SoftwareSetting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [string] $Value
    )

    $Global:Software_Settings | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
    Save-SoftwareSettings
} Export-ModuleMember -Function Add-SoftwareSetting

##############################################################
############## END OF SOFTWARE CONFIG FUNCTIONS ##############
##############################################################

###############################################################################
############## START OF IMAGE-CAPABLE Software Install Functions ##############
###############################################################################

function Install-Image_Softwares {
    <#
        -The point of this is to run through all potential image-capable software installs
        -Once software installs are completed, it will just report so, rather than continually going through each software function for no reason
            -This is for two reasons really;
                1. To speed up the process (likely has a minimal effect but could matter as software list gets larger. Also just proper to have efficient code)
                2. Clean up the output on the console after reloads, as it's getting rather lengthy...
    #>
    
    # Variables - edit as needed
    $Step = "Install Image Capable Softwares"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    Write-Host ""
    Write-Host "-=[ $Step ]=-" -ForegroundColor DarkGray
    If (Test-Path "$StepStatus*") {
        #Install-Basic_Softwares # Is this needed here? Removing for now
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        # .EXE EXAMPLE: Start-Process C:\Setup\Agent_Install.exe -Wait -ArgumentList '/s'
        # .MSI EXAMPLE: Start-Process "msiexec.exe" -Wait -ArgumentList '/I C:\Setup\Agent_Install.msi' -NoNewWindow

        # Get-Installed_Softwares # Is this pre-check needed anymore since we check for status files instead?
        $Software_Categories = 'Browser','PDF_Viewer','o365','VPN','Collaboration_Software','FileShareApp'
        Do {
            [int]$Global:InstallationErrorCount = 0
                        
            foreach ($Category in $Software_Categories) {
	            $Command = "Choose-$Category"
                & $Command
            }

            If ($Global:InstallationErrorCount -ge 1) {
                Write-Host "`nNot all softwares installed correctly..." -ForegroundColor Yellow
                DO {
                    Write-Host "`n-=[ Software issues detected ]=-" -ForegroundColor Yellow
                    Write-Host "How would you like to continue?"
                    Write-Host "1. Start software installations over"
                    Write-Host "2. Move on"
                    [int]$choice = Read-Host -Prompt "Enter a number, 1 through 2"
                } UNTIL (($choice -ge 1) -and ($choice -le 2))
                # Act on choice
                switch ($choice) {
                    1 {
                        Write-Host "`nStarting software installations over...`n"
                    }
                    2 {
                        Write-Host "`nMoving on...`n"
                        [int]$Global:InstallationErrorCount = 0
                    }
                }
            } else {
                New-Item $CompletionFile -ItemType File -Force | Out-Null
                Write-Host "`n$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
            }
        } Until ($Global:InstallationErrorCount -eq 0)
    }
} Export-ModuleMember -Function Install-Image_Softwares


function Choose-FileShareApp {
    # Variables - edit as needed
    $Step = "Install File Share App"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")

    # Status check
    # If already installed for skipped, just report so and skip the rest
    If (Test-Path "$StepStatus*.txt") {
        If (Test-Path "$StepStatus-1.txt") {Write-Host "Citrix Files for Windows has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        #If (Test-Path "$StepStatus-2.txt") {Write-Host "Citrix Files for Outlook has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        #If (Test-Path "$StepStatus-3.txt") {Write-Host "Both Citrix Files for Windows " -NoNewline; Write-Host "and " -NoNewline -ForegroundColor Cyan; Write-Host "Citrix Files for Outlook have been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-2.txt") {Write-Host "Citrix Files for Windows has been " -NoNewline; Write-Host "skipped"}
    # Assuming no progress on this step yet
    } else {
        # First see if the choice has already been made
        $choice = $null
        If ($global:ClientSettings.FileShareApp) {
            $choice = $global:ClientSettings.FileShareApp
        } else {
        # Otherwise ask tech to choose action to take
            DO {
                Write-Host "`n-=[ $Step Choice ]=-" -ForegroundColor Yellow
                Write-Host "Which File Share App(s) do you want to install?"
                Write-Host "0. Skip"
                Write-Host "1. Citrix Files for Windows"
                Write-Host "2. Dropbox"
                [int]$choice = Read-Host -Prompt "Enter a number, 0 through 2"
            } UNTIL (($choice -ge 0) -and ($choice -le 2))
            # Update Client Config File with choice
            Add-ClientSetting -Name FileShareApp -Value $choice
            Save-ClientSettings
        }
        # Act on choice
        switch ($choice) {
            0 {
                New-Item "$StepStatus-0.txt" -ItemType File -Force | Out-Null
                Write-Host "$Step has been skipped"
            }
            1 {
                $SoftwareName = "Citrix Files for Windows (ShareFile)"
                $CompletionFile = "$StepStatus-1.txt"

                Write-Host "`nInstalling $SoftwareName"
                $InstallerPath = Get-ChildItem -Path "$FolderPath_Local_Standard_Software\CitrixFilesForWindows-*.exe"
                $InstallerPath = $InstallerPath[-1]
                $InstallerPath = $InstallerPath.FullName
                Start-Process "$InstallerPath" -Wait -ArgumentList '/install /quiet /norestart'
                Write-Host "Verifying if the software is now installed..."
                If (Test-Path "C:\Program Files\Citrix\Citrix Files\CitrixFiles.exe") {
                    Write-Host "Installed - $Software" -ForegroundColor Green
                    New-Item $CompletionFile -ItemType File -Force | Out-Null
                } else {
                    Write-Host "$Software is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                    [int]$Global:InstallationErrorCount++
                }
            }
            2 {
                $SoftwareName = "Dropbox"
                $CompletionFile = "$StepStatus-2.txt"
                $Working_Directory = $FolderPath_Local_Standard_Software

                Write-Host "`nInstalling $SoftwareName"
                # Make a copy and define that as the $Installer_Path
                If (!(Test-Path "$Working_Directory\copy")) {New-Item -Path "$Working_Directory\copy" -ItemType Directory -Force | Out-Null}
                Copy-Item -Path "$Working_Directory\DropboxInstaller.exe" -Destination "$Working_Directory\copy\DropboxInstaller.exe"
                $Installer_Path = (Get-ChildItem -Path "$Working_Directory\copy\DropboxInstaller.exe").FullName

                # Run Installer
                Start-Process "$Installer_Path" -Wait -ArgumentList '/S'
                
                # Verify Installation > Report Status
                Write-Host "Verifying if the software is now installed..."
                If (Test-Path "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe") {
                    Write-Host "Installed - $Software" -ForegroundColor Green
                    New-Item $CompletionFile -ItemType File -Force | Out-Null
                } else {
                    Write-Host "$Software is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                    [int]$Global:InstallationErrorCount++
                }
            }
        }
    }
} Export-ModuleMember -Function Choose-FileShareApp


function Choose-Browser {
    # Variables - edit as needed
    $Step = "Install Browser"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")

    # Status check
    # If already installed for skipped, just report so and skip the rest
    If (Test-Path "$StepStatus*.txt") {
        If (Test-Path "$StepStatus-1.txt") {Write-Host "Chrome has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-2.txt") {Write-Host "Firefox has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-3.txt") {Write-Host "Both Chrome " -NoNewline; Write-Host "and " -NoNewline -ForegroundColor Cyan; Write-Host "Firefox have been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-4.txt") {Write-Host "Both Chrome " -NoNewline; Write-Host "and " -NoNewline -ForegroundColor Cyan; Write-Host "Firefox have been " -NoNewline; Write-Host "skipped"}
    # Assuming no progress on this step yet
    } else {
        # First see if the choice has already been made
        $choice = $null
        If ($global:ClientSettings.Browser) {
            $choice = $global:ClientSettings.Browser
        } else {
        # Otherwise ask tech to choose action to take
            DO {
                Write-Host ""
                Write-Host "-=[ Browser Choice ]=-" -ForegroundColor Yellow
                Write-Host "Which browser(s) do you want to install?"
                Write-Host "1. Chrome"
                Write-Host "2. Firefox"
                Write-Host "3. BOTH"
                Write-Host "4. NEITHER"
                [int]$choice = Read-Host -Prompt "Enter a number, 1 through 4"
            } UNTIL (($choice -ge 1) -and ($choice -le 4))
            # Update Client Config File with choice
            Add-ClientSetting -Name Browser -Value $choice
            Save-ClientSettings
        }
        # Act on choice
        switch ($choice) {
            1 {
                $SoftwareName = "Chrome"
                $CompletionFile = "$StepStatus-1.txt"

                # Install
                Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile
            }
            2 {
                $SoftwareName = "Firefox"
                $CompletionFile = "$StepStatus-2.txt"

                # Install
                Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile
            }
            3 {
                $SoftwareName = "Chrome"
                # Install
                Install-Software -SoftwareName $SoftwareName -CompletionFile $null

                $SoftwareName = "Firefox"
                $CompletionFile = "$StepStatus-3.txt"
                # Install
                Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile
            }
            4 {
                Write-Host "Chrome and Firefox browser installs have been skipped"
                New-Item "$StepStatus-4.txt" -ItemType File -Force | Out-Null
            }
        }
    }
} Export-ModuleMember -Function Choose-Browser

function Choose-PDF_Viewer {
    # Variables - edit as needed
    $Step = "Install PDF Viewer"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")

    # Status check
    # If already installed for skipped, just report so and skip the rest
    If (Test-Path "$StepStatus*.txt") {
        If (Test-Path "$StepStatus-1.txt") {Write-Host "Adobe Acrobat Reader DC has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-2.txt") {Write-Host "Adobe Acrobat Pro DC - Trial Installer has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-3.txt") {Write-Host "Adobe Acrobat Reader DC " -NoNewline; Write-Host "-AND- " -NoNewline -ForegroundColor Cyan; Write-Host "Adobe Acrobat Pro DC - Trial Installer have been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-4.txt") {Write-Host "CutePDF has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-5.txt") {Write-Host "Adobe Acrobat Reader DC " -NoNewline; Write-Host "-AND- " -NoNewline -ForegroundColor Cyan; Write-Host "CutePDF have been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-6.txt") {Write-Host "All PDF viewers\editers have been skipped"}
    # Assuming no progress on this step yet
    } else {
        # First see if the choice has already been made
        $choice = $null
        If ($Global:ClientSettings.PDF_Viewer) {
            $choice = $Global:ClientSettings.PDF_Viewer
        } else {
        # Otherwise ask tech to choose action to take
            DO {
                Write-Host ""
                Write-Host "-=[ PDF Viewer Choice ]=-" -ForegroundColor Yellow
                Write-Host "Which PDF Viewer(s) do you want to install?"
                Write-Host "1. Adobe Acrobat Reader DC"
                Write-Host "2. Adobe Acrobat Pro DC - Trial Installer"
                Write-Host "3. Adobe Acrobat Reader DC -AND- Adobe Acrobat Pro DC - Trial Installer"
                Write-Host "4. CutePDF Writer (and converter)"
                Write-Host "5. Adobe Acrobat Reader DC -AND- CutePDF Writer (and converter)"
                Write-Host "6. NONE"
                [int]$choice = Read-Host -Prompt "Enter a number, 1 through 6"
            } UNTIL (($choice -ge 1) -and ($choice -le 6))
            # Update Client Config File with choice
            Add-ClientSetting -Name PDF_Viewer -Value $choice
            Save-ClientSettings
        }
        # Act on choice
        switch ($choice) {
            1 {
                $SoftwareName = "Adobe Acrobat Reader DC"
                $CompletionFile = "$StepStatus-1.txt"
                Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile
            }
            2 {
                $SoftwareName = "Adobe Acrobat Pro DC - Trial Installer"
                $CompletionFile = "$StepStatus-2.txt"
                Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile
            }
            3 {
                $SoftwareName = "Adobe Acrobat Reader DC"
                Install-Software -SoftwareName $SoftwareName -CompletionFile $null

                $SoftwareName = "Adobe Acrobat Pro DC - Trial Installer"
                $CompletionFile = "$StepStatus-3.txt"
                Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile
            }
            4 {
                $SoftwareName = "CutePDF Writer"
                $CompletionFile = "$StepStatus-4.txt"
                Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile
            }
            5 {
                $SoftwareName = "Adobe Acrobat Reader DC"
                Install-Software -SoftwareName $SoftwareName -CompletionFile $null

                $SoftwareName = "CutePDF Writer"
                $CompletionFile = "$StepStatus-5.txt"
                Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile
            }
            6 {
                Write-Host "All PDF Editor\Viewer installs have been skipped"
                New-Item "$StepStatus-6.txt" -ItemType File -Force | Out-Null
            }
        }
    }
} Export-ModuleMember -Function Choose-PDF_Viewer

function Choose-o365 {
    # Variables - edit as needed
    $Step = "Install o365"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")

    # Status check
    # If already installed for skipped, just report so and skip the rest
    If (Test-Path "$StepStatus*.txt") {
        If (Test-Path "$StepStatus-1.txt") {Write-Host "o365 Enterprise (64-bit) has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-2.txt") {Write-Host "o365 Business (64-bit) has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-3.txt") {Write-Host "o365 Enterprise (32-bit) has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-4.txt") {Write-Host "o365 Business (32-bit) has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-5.txt") {Write-Host "o365 installation has been skipped"}
    # Assuming no progress on this step yet
    } else {
        # First see if the choice has already been made
        $choice = $null
        If ($Global:ClientSettings.o365) {
            $choice = $Global:ClientSettings.o365
        } else {
        # Otherwise ask tech to choose action to take
            DO {
                Write-Host ""
                Write-Host "-=[ o365 Choice ]=-" -ForegroundColor Yellow
                Write-Host "Which version of o365 would you like to install?"
                Write-Host "64-bit versions:"
                Write-Host "  1. o365 Pro\Enterprise"
                Write-Host "  2. o365 Business"
                Write-Host "32-bit versions:"
                Write-Host "  3. o365 Pro\Enterprise"
                Write-Host "  4. o365 Business"
                Write-Host "5. NONE"
                [int]$choice = Read-Host -Prompt "Enter a number, 1 through 5"
            } UNTIL (($choice -ge 1) -and ($choice -le 5))
            # Update Client Config File with choice
            Add-ClientSetting -Name o365 -Value $choice
            Save-ClientSettings
        }
        # Act on choice
        switch ($choice) {
            1 {
                $SoftwareName = "Microsoft 365 Apps for enterprise - en-us (64-bit)"
                $CompletionFile = "$StepStatus-1.txt"
                #Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile

                Write-Host ""
                Write-Host "Installing $SoftwareName"
                $InstallerPath = "$FolderPath_Local_ODT_Software\Install o365ProPlus1.bat"
                Start-Process $InstallerPath -Wait
                Write-Host "Verifying if the software is now installed..."
                If (Test-Path -LiteralPath "C:\Program Files\Microsoft Office\root\Office16\WINWORD.exe") {
                    Write-Host "Installed - $SoftwareName" -ForegroundColor Green
                    New-Item $CompletionFile -ItemType File -Force | Out-Null
                } else {
                    Write-Host "$SoftwareName is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                    [int]$Global:InstallationErrorCount++
                }
            }
            2 {
                $SoftwareName = "Microsoft 365 Apps for business - en-us (64-bit)"
                $CompletionFile = "$StepStatus-2.txt"
                #Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile

                Write-Host ""
                Write-Host "Installing $SoftwareName"
                $InstallerPath = "$FolderPath_Local_ODT_Software\Install o365Business1.bat"
                Start-Process $InstallerPath -Wait
                Write-Host "Verifying if the software is now installed..."
                If (Test-Path -LiteralPath "C:\Program Files\Microsoft Office\root\Office16\WINWORD.exe") {
                    Write-Host "Installed - $SoftwareName" -ForegroundColor Green
                    New-Item $CompletionFile -ItemType File -Force | Out-Null
                } else {
                    Write-Host "$SoftwareName is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                    [int]$Global:InstallationErrorCount++
                }
            }
            3 {
                $SoftwareName = "Microsoft 365 Apps for enterprise - en-us (32-bit)"
                $CompletionFile = "$StepStatus-3.txt"
                #Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile

                Write-Host ""
                Write-Host "Installing $SoftwareName"
                $InstallerPath = "$FolderPath_Local_ODT_Software\Install o365Enterprise_32-bit.bat"
                Start-Process $InstallerPath -Wait
                Write-Host "Verifying if the software is now installed..."
                If (Test-Path -LiteralPath "C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.exe") {
                    Write-Host "Installed - $SoftwareName" -ForegroundColor Green
                    New-Item $CompletionFile -ItemType File -Force | Out-Null
                } else {
                    Write-Host "$SoftwareName is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                    [int]$Global:InstallationErrorCount++
                }
            }
            4 {
                $SoftwareName = "Microsoft 365 Apps for business - en-us (32-bit)"
                $CompletionFile = "$StepStatus-4.txt"
                #Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile

                Write-Host ""
                Write-Host "Installing $SoftwareName"
                $InstallerPath = "$FolderPath_Local_ODT_Software\Install o365Business1_32-bit.bat"
                Start-Process $InstallerPath -Wait
                Write-Host "Verifying if the software is now installed..."
                If (Test-Path -LiteralPath "C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.exe") {
                    Write-Host "Installed - $SoftwareName" -ForegroundColor Green
                    New-Item $CompletionFile -ItemType File -Force | Out-Null
                } else {
                    Write-Host "$SoftwareName is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                    [int]$Global:InstallationErrorCount++
                }
            }
            5 {
                Write-Host "o365 installation has been skipped"
                New-Item "$StepStatus-5.txt" -ItemType File -Force | Out-Null
            }
        }
    }
} Export-ModuleMember -Function Choose-o365

function Choose-VPN {
    # Variables - edit as needed
    $Step = "Install VPN"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")

    # Status check
    # If already installed for skipped, just report so and skip the rest
    If (Test-Path "$StepStatus*.txt") {
        If (Test-Path "$StepStatus-1.txt") {Write-Host "WatchGuard VPN has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-2.txt") {Write-Host "VPN Installations have been " -NoNewline; Write-Host "skipped" -ForegroundColor Green}
    # Assuming no progress on this step yet
    } else {
        # First see if the choice has already been made
        $choice = $null
        If ($Global:ClientSettings.VPN) {
            $choice = $Global:ClientSettings.VPN
        } else {
        # Otherwise ask tech to choose action to take
            DO {
                Write-Host ""
                Write-Host "-=[ VPN Choice ]=-" -ForegroundColor Yellow
                Write-Host "Would you like to install a VPN client?"
                Write-Host "1. WatchGuard Mobile VPN with SSL client"
                Write-Host "2. None"
                [int]$choice = Read-Host -Prompt "Enter a number, 1 through 2"
            } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
            # Update Client Config File with choice
            Add-ClientSetting -Name VPN -Value $choice
            Save-ClientSettings
        }
        # Act on choice
        switch ($choice) {
            1 {
                $SoftwareName = "WatchGuard Mobile VPN with SSL client"
                $CompletionFile = "$StepStatus-1.txt"
                #Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile

                $Software = "WatchGuard Mobile VPN with SSL client"
                Write-Host ""
                Write-Host "Installing $Software"
                $ZipPath = "$FolderPath_Local_Standard_Software\WG-MVPN-SSL_12_7.zip"
                $InstallerPath = "$FolderPath_Local_Standard_Software\temp"
                Expand-Archive -LiteralPath $ZipPath -DestinationPath $InstallerPath -Force
                $InstallerPath = $InstallerPath + "\Install_WG_SSL_VPN_12.7.bat"
                Start-Process $InstallerPath -Wait
                Write-Host "Verifying if the software is now installed..."
                If (Test-Path -LiteralPath "C:\Program Files (x86)\WatchGuard\WatchGuard Mobile VPN with SSL\wgsslvpnc.exe") {
                    Write-Host "Installed - $Software" -ForegroundColor Green
                    New-Item $CompletionFile -ItemType File -Force | Out-Null
                } else {
                    Write-Host "$Software is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                    [int]$Global:InstallationErrorCount++
                }
            }
            2 {
                Write-Host "VPN client installation has been skipped"
                New-Item "$StepStatus-2.txt" -ItemType File -Force | Out-Null
            }
        }
    }
} Export-ModuleMember -Function Choose-VPN

function Choose-Collaboration_Software {
    # Variables - edit as needed
    $Step = "Install Collaboration Software"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")

    # Status check
    # If already installed for skipped, just report so and skip the rest
    If (Test-Path "$StepStatus*.txt") {
        If (Test-Path "$StepStatus-1.txt") {Write-Host "Cisco Jabber has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-2.txt") {Write-Host "ZAC has been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-3.txt") {Write-Host "ZAC " -NoNewline; Write-Host "& " -NoNewline -ForegroundColor Cyan; Write-Host "Zulty's Fax Driver have been " -NoNewline; Write-Host "installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-4.txt") {Write-Host "Cisco Jabber, ZAC, and Zulty's Fax Driver installs have been " -NoNewline; Write-Host "skipped" -ForegroundColor Green}
    # Assuming no progress on this step yet
    } else {
        # First see if the choice has already been made
        $choice = $null
        If ($Global:ClientSettings.Collab) {
            $choice = $Global:ClientSettings.Collab
        } else {
        # Otherwise ask tech to choose action to take
            DO {
                Write-Host ""
                Write-Host "-=[ Collaboration Software Choice ]=-" -ForegroundColor Yellow
                Write-Host "Which Collaboration Software do you want to install?"
                Write-Host "1. Cisco Jabber"
                Write-Host "2. ZAC"
                Write-Host "3. ZAC & Zultys Fax 2.0 Printer"
                Write-Host "4. NONE"
                [int]$choice = Read-Host -Prompt "Enter a number, 1 through 4"
            } UNTIL (($choice -ge 1) -and ($choice -le 4))
            # Update Client Config File with choice
            Add-ClientSetting -Name Collab -Value $choice
            Save-ClientSettings
        }
        # Act on choice
        switch ($choice) {
            1 {
                $SoftwareName = "Cisco Jabber"
                $CompletionFile = "$StepStatus-1.txt"
                #Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile

                $Software = "Cisco Jabber"
                Write-Host ""
                Write-Host "Installing $Software"
                $JabberInstaller = Get-ChildItem -Path "$FolderPath_Local_Standard_Software\CiscoJabberSetup*.msi"
                $JabberInstaller = $JabberInstaller[-1]
                $JabberInstaller = $JabberInstaller.FullName
                $command = "msiexec /i $JabberInstaller /qn"
                cmd.exe /c $command
                Write-Host "Verifying if the software is now installed..."
                $Global:WMI_Installed_Software = Get-WmiObject -Class Win32_Product
                If ($Global:WMI_Installed_Software | Where-Object -FilterScript {$_.Name -match $Software}) {
                    Write-Host "Installed - $Software" -ForegroundColor Green
                    New-Item $CompletionFile -ItemType File -Force | Out-Null
                } else {
                    Write-Host "$Software is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                    [int]$Global:InstallationErrorCount++
                }
            }
            2 {
                $SoftwareName = "ZAC"
                $CompletionFile = "$StepStatus-2.txt"
                Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile
            }
            3 {
                $SoftwareName = "ZAC"
                Install-Software -SoftwareName $SoftwareName -CompletionFile $null

                $SoftwareName = "Zultys Fax 2.0 Printer"
                $CompletionFile = "$StepStatus-3.txt"
                Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile
            }
            4 {
                Write-Host "Cisco Jabber, MXIE, ZAC, and Zulty's Fax Driver installs have been skipped"
                New-Item "$StepStatus-4.txt" -ItemType File -Force | Out-Null
            }
        }
    }
} Export-ModuleMember -Function Choose-Collaboration_Software

function Install-Software {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $SoftwareName,

        [Parameter(Mandatory = $false)]
        [string] $CompletionFile
    )

    # Get software information
    #Load-Software_Config -SoftwareName $SoftwareName
    Get-SoftwareSettings -SoftwareName $SoftwareName
    $Installer_Name = $Global:Software_Settings.Installer_Name
    $Installer_Source = $Global:Software_Settings.Installer_Source
    $Installer_URL = $Global:Software_Settings.URL
    $Installer_Manual_URL = $Global:Software_Settings.Manual_URL
    $Installer_Arguments = $Global:Software_Settings.Arguments
    $Installer_Verification_Path = $Global:Software_Settings.Verification_Path
    $Installer_Path = $null
    $Working_Directory = $null

    # Find Installer location and define $Installer_Path and $Working_Directory
    # Ideally we want a local installer, USB if we have to, otherwise download if we can. In that order.
    function Search {
        # If installer is found to be local...
        If (Test-Path $Installer_Local_Path) {
            # Define $Working_Directory
            $Script:Working_Directory = $Local_Working_Dir
            # Make a copy and define that as the $Installer_Path
            If (!(Test-Path "$Script:Working_Directory\copy")) {New-Item -Path "$Script:Working_Directory\copy" -ItemType Directory -Force | Out-Null}
            $Script:Installer_Path = "$Script:Working_Directory\copy\$Installer_Name"
            Copy-Item -Path $Installer_Local_Path -Destination $Script:Installer_Path
        # If installer is found to be on USB...
        } elseif ($Installer_USB_Path) {
            # Define $Working_Directory
            $Script:Working_Directory = $USB_Working_Dir
            # Make a copy and define that as the $Installer_Path
            If (!(Test-Path "$Script:Working_Directory\copy")) {New-Item -Path "$Script:Working_Directory\copy" -ItemType Directory -Force | Out-Null}
            $Script:Installer_Path = "$Script:Working_Directory\copy\$Installer_Name"
            Copy-Item -Path $Installer_USB_Path -Destination $Script:Installer_Path
        # Otherwise download the installer if possible
        } elseif ($Installer_URL -ne $null) {
            # Download Installer
            (New-Object System.Net.WebClient).DownloadFile($Installer_URL, $Installer_Local_Path)
            # Define $Working_Directory
            $Script:Working_Directory = $Local_Working_Dir
            # Make a copy and define that as the $Installer_Path
            If (!(Test-Path "$Script:Working_Directory\copy")) {New-Item -Path "$Script:Working_Directory\copy" -ItemType Directory -Force | Out-Null}
            $Script:Installer_Path = "$Script:Working_Directory\copy\$Installer_Name"
            Copy-Item -Path $Installer_Local_Path -Destination $Script:Installer_Path
            # Copy to USB if USB is present
            If ($USB.Exists()) {Copy-Item -Path $Installer_Local_Path -Destination $Installer_USB_Path -ErrorAction SilentlyContinue}
        # Else, notify that the installer could not be found
        } else {
            $Script:Installer_Path = $null
            If ($USB.Exists()) {
                Write-Host "`nWARNING: " -ForegroundColor Red -NoNewline; Write-Host "Was not able to locate an installer for $SoftwareName on the local host or on the Imaging Tool"
            } else {
                Write-Host "`nWARNING: " -ForegroundColor Red -NoNewline; Write-Host "Was not able to locate an installer for $SoftwareName on the local host"
            }
            Write-Host "  >You will need to " -NoNewline; Write-Host "download" -ForegroundColor Cyan -NoNewline; Write-Host " this software and " -NoNewline; Write-Host "install" -ForegroundColor Cyan -NoNewline; Write-Host " it " -NoNewline; Write-Host "manually" -ForegroundColor Red -NoNewline; Write-Host "..."
            If ($Installer_Manual_URL -ne $null) {Write-Host "  >Opening Download portal now" -ForegroundColor Green; Start $Installer_Manual_URL}
            Write-Host "`nPlease also place a copy of $Installer_Name in the $Installer_Source folder on the Imaging Tool" -ForegroundColor Yellow
            Write-Host "  >If you do this, you will not need to download it next time"
            Write-Host "`nOnce the software has been installed," -ForegroundColor Yellow
            PAUSE
        }
    }
    
    # Define installer parameters that are dependant on installer type, then Search to locate the installer
    # Produces $Installer_Path and $Working_Directory
    $USB = [ImagingUSB]::new()
    if ($USB.Exists()) {
        $USB_Drive = $USB.Drive_Letter
        $FolderPath_USB_Install_Software_ODT               = $USB.Install_Software_ODT
        $FolderPath_USB_Install_Software_Profile_Software  = $USB.Install_Software_Profile_Software
        $FolderPath_USB_Install_Software_Standard_Software = $USB.Install_Software_Standard_Software
        $Installer_USB_Path   = "$USB_Working_Dir\$Installer_Name"
    }

    if ($Installer_Source -eq "Standard_Software") {
        $Local_Working_Dir    = $FolderPath_Local_Standard_Software
        $Installer_Local_Path = "$Local_Working_Dir\$Installer_Name"
        if ($USB.Exists()) {$USB_Working_Dir = $FolderPath_USB_Install_Software_Standard_Software}
    } elseif ($Installer_Source -eq "ODT") {
        $Local_Working_Dir    = $FolderPath_Local_ODT_Software
        $Installer_Local_Path = "$Local_Working_Dir\$Installer_Name"
        if ($USB.Exists()) {$USB_Working_Dir = $FolderPath_USB_Install_Software_ODT}
    } elseif ($Installer_Source -eq "Profile_Specific_Software") {
        $Local_Working_Dir    = $FolderPath_Local_Profile_Software
        $Installer_Local_Path = "$Local_Working_Dir\$Installer_Name"
        if ($USB.Exists()) {$USB_Working_Dir = $FolderPath_USB_Install_Software_Profile_Software}
    }
    Search

    # First see if the software is already installed before running the installer
    if (!(Test-Path $Installer_Verification_Path)) {
        # If an Installer exists, run the install command
        if ($Script:Installer_Path -ne $null) {
            # NOW INSTALL THE SOFTWARE
            Write-Host "`nStarting to install $SoftwareName"
            if ($Script:Installer_Path -like "*.exe") {
                if ($Installer_Arguments) {$Arguments = ($Installer_Arguments).Split(",")}
                #Write-Host 'Troubleshooting Info - $Arguments = '$Arguments
                if ($Arguments -eq $null) {
                    Start-Process $Script:Installer_Path -WorkingDirectory $Script:Working_Directory -Wait
                } else {
                    #Write-Host "Troubleshooting Info: Start-Process $Script:Installer_Path -ArgumentList $Arguments -WorkingDirectory $Script:Working_Directory -Wait"
                    Start-Process $Script:Installer_Path -ArgumentList $Arguments -WorkingDirectory $Script:Working_Directory -Wait
                }
            } elseif ($Script:Installer_Path -like "*.msi") {
                $Arguments = "/i $Script:Installer_Path $Installer_Arguments"
                Start-Process "msiexec.exe" -ArgumentList $Arguments -Wait 
            }
        }
    }

    # Verify Installation Status and Create CompletionFile if install is successful
    If ($Installer_Verification_Path -ne $null -and $CompletionFile) {
        Verify-Installation_Success -SoftwareName $SoftwareName -Installer_Verification_Path $Installer_Verification_Path -CompletionFile $CompletionFile
    } elseif ($Installer_Verification_Path -ne $null) {
        Verify-Installation_Success -SoftwareName $SoftwareName -Installer_Verification_Path $Installer_Verification_Path
    } else {
        Write-Host "WARNING!!" -ForegroundColor Red -NoNewline; Write-Host ": Software config does not have a Verification Path to reference"
        Write-Host "Please update the config file now before continuing, then reboot ideally"
        PAUSE
    }
    If ($CompletionFile) {
        If (Test-Path $CompletionFile) {Remove-Item -Path $Script:Installer_Path -Force -ErrorAction SilentlyContinue}
    }
} Export-ModuleMember -Function Install-Software

function Verify-Installation_Success {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $SoftwareName,

        [Parameter(Mandatory = $true)]
        [string] $Installer_Verification_Path,

        [Parameter(Mandatory = $false)]
        [string] $CompletionFile
    )

    Write-Host "Verifying if the software is now installed..."
    If (Test-Path $Installer_Verification_Path) {
        Write-Host "Installed - $SoftwareName" -ForegroundColor Green
        If ($CompletionFile) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
    } else {
        Write-Host "$SoftwareName is not installed" -ForegroundColor Red
        Write-Host "Reboot or just relog to re-attempt install"
        [int]$Global:InstallationErrorCount++
    }
} Export-ModuleMember -Function Verify-Installation_Success

function Get-Installed_Softwares {
    # Get lists of installed software
    # NOTE: Neither WMI nor the registry apears to contain a full list!!!
    Write-Host "Getting list of installed softwares..." -ForegroundColor Yellow
    $Global:Installed_Software = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*
    $Global:WMI_Installed_Software = Get-WmiObject -Class Win32_Product
} Export-ModuleMember -Function Get-Installed_Softwares

function CheckPoint-Client_Software {
    # Variables - edit as needed
    $Step = "Install Client Software"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    
    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Write-Host ""
        Write-Host "If needed, install Client Specific Software now"
        PAUSE
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host "$Step - Marked As Completed" -ForeGroundColor Green
    }
} Export-ModuleMember -Function CheckPoint-Client_Software

function Install-RMM_Agent {
    # Variables - edit as needed
    $Step = "Install RMM Agent"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"

    
    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        If (Test-Path "$FolderPath_Local_Setup\*Agent_Install*.exe") {
            $Installers = Get-ChildItem -Path "$FolderPath_Local_Setup\*Agent_Install*.exe"
            Write-Host "`n-=[ $Step ]=-" -ForegroundColor Yellow
            If ($Installers.count -gt 1) {
                Do {
                    Write-Host "   -=[ Available RMM Agent Installers ]=-"
                    ForEach ($Installer in $Installers) {
                        $Count++
                        $Line = "   $Count" + ": " + $Installer.Name
                        Write-Host $Line
                        
                    }
                    [int]$choice = Read-Host -Prompt "Which Installer would you like to run? (Enter a number from 1 to $Count)"
                } Until (($choice -gt 0) -and ($choice -le $Count))
                $Installer = ($Installers[$choice-1]).FullName
            } else {$Installer = $Installers}
            Write-Host "`nStarting - RMM Agent Silent Installation" -ForegroundColor Yellow
            Start-Process $Installer -Wait -ArgumentList '/s'
            Start-Sleep 5
            If (Test-Path "C:\Windows\LTSvc\LTSVC.exe") {Remove-Item -Path "$FolderPath_Local_Setup\*Agent_Install*.exe" -Force -ErrorAction SilentlyContinue}
        } else {
            DO {
                Write-Host "Install the client's RMM agent at this time before continuing with the setup" -ForeGroundColor Yellow
                $input = Read-Host -Prompt "Type in 'continue' to move on to the next step"
            } UNTIL ($input -eq "continue")
        }
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    } 
} Export-ModuleMember -Function Install-RMM_Agent

function Install-AV_Agent {
    #Variables - edit as needed
    $Step = "Install Anti-Virus"
    
    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"
    
    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        If (Test-Path "$FolderPath_Local_Setup\SophosSetup.exe") {
            Write-Host "`n-=[ $Step ]=-" -ForegroundColor DarkGray
            Write-Host "Starting - AV Agent Installation"
            Write-Host "NOTE: This can take 15 minutes or so, especially if on WiFi or an otherwise slow network" -ForegroundColor Yellow
            Start-Process "$FolderPath_Local_Setup\SophosSetup.exe" -Wait -ArgumentList '--quiet'
            Start-Sleep 5
            If (Test-Path "C:\Program Files (x86)\Sophos\") {Remove-Item -Path "$FolderPath_Local_Setup\SophosSetup.exe" -Force -ErrorAction SilentlyContinue}
        } else {
            DO {
                Write-Host ""
                Write-Host "-=[ $Step ]=-" -ForegroundColor Yellow
                Write-Host "Install the client's AV agent at this time before continuing with the setup" -ForeGroundColor Yellow
                $input = Read-Host -Prompt "Type in 'continue' to move on to the next step"
            } UNTIL ($input -eq "continue")
        }
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host "$Step has been completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Install-AV_Agent

function Reinstall-SupportAssistant {
    #Variables - edit as needed
    $Step = "Reinstall Support Assistant"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"
    
    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        DO {
            Write-Host "`n-=[ $Step ]=-" -ForegroundColor Yellow
            Write-Host "Would you like to install a support assistant so that you can update drivers?"
            Write-Host "1. Yes"
            Write-Host "2. No"
            [int]$choice = Read-Host -Prompt "Enter a number, 1 through 2"
        } UNTIL (($choice -eq 1) -OR ($choice -eq 2))

        switch ($choice) {
            1 {
                $DellInstallerPath = "$FolderPath_Local_Setup\Dell_Support_Assist_Installer.exe"
                $HPInstallerPath = "$FolderPath_Local_Setup\HP_Support_Assistant.exe"
                #check to see if an installer is in the setup folder
                Write-Host ""
                Write-Host "Checking Support Assistant Status" -ForegroundColor Yellow
                If (Test-Path $DellInstallerPath) {
                    #check to see if it's installed
                    $Software = "Dell Support Assist"
                    $Global:Installed_Software = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*
                    If (!(($Global:Installed_Software).DisplayName -match $Software)) {
                        Write-Host "Re-Installing Dell Support Assist"
                        Start-Process "$DellInstallerPath" -Wait
                        Write-Host "Verifying if the software is now installed..."
                        $Global:Installed_Software = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*
                        If (($Global:Installed_Software).DisplayName -match $Software) {
                            New-Item $CompletionFile -ItemType File -Force | Out-Null
                            Write-Host "Installed - $Software" -ForegroundColor Green
                        } else {
                            Write-Host "$Software is not installed" -ForegroundColor Red
                            Write-Host "Try Running the installer under $FolderPath_Local_Setup manually" -ForegroundColor Yellow
                        }
                    }
                } ElseIf (Test-Path $HPInstallerPath) {
                    #check to see if it's installed
                    $Software = "HP Support Assistant"
                    If (!(Test-Path "C:\Program Files (x86)\HP\HP Support Framework\HP Support Assistant.ico") -And !(Test-Path "C:\Program Files (x86)\Hewlett-Packard\HP Support Framework\HPSF.exe")) {
                        Write-Host "Re-Installing HP Support Assistant"
                        Start-Process "$HPInstallerPath" -Wait
                        Write-Host "Verifying if the software is now installed..."
                        If ((Test-Path "C:\Program Files (x86)\HP\HP Support Framework\HP Support Assistant.ico") -OR (Test-Path "C:\Program Files (x86)\Hewlett-Packard\HP Support Framework\HPSF.exe")) {
                            New-Item $CompletionFile -ItemType File -Force | Out-Null
                            Write-Host "Installed - $Software" -ForegroundColor Green
                        } else {
                            Write-Host "$Software is not installed" -ForegroundColor Red
                            Write-Host "Try Running the installer under C:\Setup manually" -ForegroundColor Yellow
                        }
                    } else {
                        Write-Host "It appears that $Software is already installed"
                        If (Test-Path "C:\Program Files (x86)\HP\HP Support Framework\HP Support Assistant.ico") {Write-Host "Found: C:\Program Files (x86)\HP\HP Support Framework\HP Support Assistant.ico"}
                        If (Test-Path "C:\Program Files (x86)\Hewlett-Packard\HP Support Framework\HPSF.exe") {Write-Host "Found: C:\Program Files (x86)\Hewlett-Packard\HP Support Framework\HPSF.exe"}
                    }
                } Else {
                    Write-Host "No Support Assistant Installers found" -ForegroundColor Red
                    Write-Host "You may want to manually download HP or Dell's Support Assistant software to run driver updates. Especially if this image is fairly old." -ForegroundColor Yellow
                }
            }
            2 {
                New-Item $SkippedFile -ItemType File -Force | Out-Null
                Write-Host "Skipping - $Step" -ForegroundColor Green
            }
        }
    }
} Export-ModuleMember -Function Reinstall-SupportAssistant

function Install-SupportAssistant {
    #Variables - edit as needed
    $Step = "Install Support Assistant"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
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
                $InstallerPath = "$FolderPath_Local_Standard_Software\Dell_Support_Assist_Installer.exe"
                Copy-Item -Path $InstallerPath -Destination $FolderPath_Local_Setup -Force
                Start-Process "$InstallerPath" -Wait
                Write-Host "Verifying if the software is now installed..."
                $Global:Installed_Software = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*
                If (($Global:Installed_Software).DisplayName -match $Software) {
                    Write-Host "Installed - $Software" -ForegroundColor Green
                    New-Item "$StepStatus-Dell.txt" -ItemType File -Force | Out-Null
                } else {
                    Write-Host "$Software is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                }
            }
            2 {
                $Software = "HP Support Assistant"
                Write-Host ""
                Write-Host "Installing $Software"
                $InstallerPath = "$FolderPath_Local_Standard_Software\HP_Support_Assistant.exe"
                Copy-Item -Path $InstallerPath -Destination $FolderPath_Local_Setup -Force
                Start-Process "$InstallerPath" -Wait
                Write-Host "Verifying if the software is now installed..."
                If ((Test-Path "C:\Program Files (x86)\HP\HP Support Framework\HP Support Assistant.ico") -OR (Test-Path "C:\Program Files (x86)\Hewlett-Packard\HP Support Framework\HPSF.exe")) {
                    Write-Host "Installed - $Software" -ForegroundColor Green
                    New-Item "$StepStatus-HP.txt" -ItemType File -Force | Out-Null
                } else {
                    Write-Host "$Software is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                }
            }
            3 {
                Write-Host "Both Dell and HP Support Assistant Installations have been skipped" -ForegroundColor Green
                New-Item $SkippedFile -ItemType File -Force | Out-Null
            }
        }
    }
} Export-ModuleMember -Function Install-SupportAssistant

function Install-SupportAssistant2 {
# THIS IS FOR TESTING THE NEW HP INSTALLER COMMANDS


    #Variables - edit as needed
    $Step = "Install Support Assistant"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $SkippedFile = "$StepStatus-Skipped.txt"
    
    If (Test-Path "$StepStatus*") {
        If (Test-Path "$StepStatus-Dell.txt") {Write-Host "Dell Support Assistant" -NoNewline; Write-Host " has been installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-HP.txt") {Write-Host "HP Support Assistant" -NoNewline; Write-Host " has been installed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "Both Dell and HP Support Assistant Installations" -NoNewline; Write-Host " have been skipped"}
    } else {
        $choice = $null
        If ($Global:ClientSettings.SupportAssistant) {
            $choice = $Global:ClientSettings.SupportAssistant
        } else {
            DO {
                Write-Host "`n-=[ $Step ]=-" -ForegroundColor Yellow
                Write-Host "Which version of Support Assistant would you like to install?"
                Write-Host "1. Dell"
                Write-Host "2. HP"
                Write-Host "3. NEITHER"
                [int]$choice = Read-Host -Prompt "Enter a number, 1 through 3"
            } UNTIL (($choice -ge 1) -and ($choice -le 3))
            # If ClientSetting doesn't exist, update Client Config File
            If (!($Global:ClientSettings.SupportAssistant)) {
                Add-ClientSetting -Name SupportAssistant -Value $choice
                Save-ClientSettings
            }
        }
        switch ($choice) {
            1 {
                $Software = "Dell Support Assist"
                Write-Host ""
                Write-Host "Installing $Software"
                $InstallerPath = "$FolderPath_Local_Standard_Software\Dell_Support_Assist_Installer.exe"
                Copy-Item -Path $InstallerPath -Destination $FolderPath_Local_Setup -Force
                Start-Process "$InstallerPath" -Wait
                Write-Host "Verifying if the software is now installed..."
                $Global:Installed_Software = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*
                If (($Global:Installed_Software).DisplayName -match $Software) {
                    Write-Host "Installed - $Software" -ForegroundColor Green
                    New-Item "$StepStatus-Dell.txt" -ItemType File -Force | Out-Null
                } else {
                    Write-Host "$Software is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                }
            }
            2 {
                $Software = "HP Support Assistant"
                Write-Host ""
                Write-Host "Downloading $Software"
                # Download Installer
                $Local_Working_Dir    = $FolderPath_Local_Standard_Software
                $Installer_Local_Path = "$Local_Working_Dir\HP_Support_Assistant.exe"
                $Installer_URL = "https://ftp.ext.hp.com/pub/softpaq/sp138501-139000/sp138693.exe"
                (New-Object System.Net.WebClient).DownloadFile($Installer_URL, $Installer_Local_Path)
                # Extract
                Write-Host "Extracting $Software"
                Start-Process $Installer_Local_Path -ArgumentList '/s /e /f "C:\Setup\HP Support Assistant"' -WorkingDirectory "C:\Setup" -Wait
                # Install
                Write-Host "Installing $Software"
                Start-Process $Installer_Local_Path -ArgumentList '/S /v/qn' -WorkingDirectory "C:\Setup\HP Support Assistant" -Wait
                #Start-Process $Installer_Local_Path -ArgumentList '/S' -WorkingDirectory "C:\Setup\HP Support Assistant" -Wait
                # Not sure if the /v/qn works in the argumentlist...
                # Using '/S /v/qn' doesn't seem to work on my non-HP but that may be because it's confirming if the machine is an HP machine first. If you just run the installer manually then it does this...
                # Using '/S' only will install the software with a little gui popup but no interaction is needed and it installs even if the system isn't an HP

                Write-Host "Verifying if the software is now installed..."
                If ((Test-Path "C:\Program Files (x86)\HP\HP Support Framework\HP Support Assistant.ico") -OR (Test-Path "C:\Program Files (x86)\Hewlett-Packard\HP Support Framework\HPSF.exe")) {
                    Write-Host "Installed - $Software" -ForegroundColor Green
                    New-Item "$StepStatus-HP.txt" -ItemType File -Force | Out-Null
                } else {
                    Write-Host "$Software is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                }
            }
            3 {
                Write-Host "Both Dell and HP Support Assistant Installations have been skipped" -ForegroundColor Green
                New-Item $SkippedFile -ItemType File -Force | Out-Null
            }
        }
    }
} Export-ModuleMember -Function Install-SupportAssistant2

function CheckPoint-DriverUpdates {
    #Variables - edit as needed
    $Step = "Install a SupportAssistant"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"
    
    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        $choice = $null
        DO {
            Write-Host "`n-=[ $Step ]=-" -ForegroundColor Yellow
            Write-Host "Would you like to $Step ?"
            Write-Host "1. Yes"
            Write-Host "2. No"
            [int]$choice = Read-Host -Prompt "Enter a number, 1 or 2"
        } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
        If ($choice -eq 1) {
            Install-SupportAssistant
            New-Item $CompletionFile -ItemType File -Force | Out-Null
        } else {
            Write-Host "$Step has been skipped"
            New-Item $SkippedFile -ItemType File -Force | Out-Null
        }
    }

    #Variables - edit as needed
    $Step = "Update Drivers"
    
    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
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
            $choice = Read-Host -Prompt "Enter a number, 1 or 2"
        } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
        If ($choice -eq 1) {
            DO {
                Write-Host ""
                Write-Host "Please take a minute to run the HP or Dell support assistant tool to update the computer's drivers" -ForeGroundColor Yellow
                Write-Host "NOTE: Installing a BIOS update and then capturing the image does NOT add the BIOS update it to the image. BIOS updates are written directly to the machine hardware. This is not part of the Windows' System partition on the hard drive that is captured as an image" -ForeGroundColor Yellow
                $input = Read-Host -Prompt "Type in 'continue' move on to the next step"
            } UNTIL ($input -eq "continue")
            New-Item $CompletionFile -ItemType File -Force | Out-Null
        } else {
            Write-Host "$Step has been skipped"
            New-Item $SkippedFile -ItemType File -Force | Out-Null
        }
    }
} Export-ModuleMember -Function CheckPoint-DriverUpdates

###########################################################
############### END OF INSTALLATION FUNCTIONS #############
###########################################################