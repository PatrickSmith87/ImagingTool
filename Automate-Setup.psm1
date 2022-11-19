#################################################################################################################################################################
#################################################################################################################################################################
###                                                                                                                                                           ###
###                                                               -=[ Automate-Setup Module ]=-                                                               ###
###                                                                                                                                                           ###
#################################################################################################################################################################
#################################################################################################################################################################
<#
This module contains functions that support the Automate-Setup.ps1 functionality
#>
#region Module Variables
$TechTool = New-TechTool
$USB = New-ImagingUSB

$RunOnceKey                                         = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" # This is the registry key that points to what script(s) to run when a user logs in
$FilePath_Local_StartAutomatedSetup                 = "C:\Users\Public\Desktop\Start-AutomatedSetup-RAA.bat"

# 1. Automated Setup
    $Setup_Fo                                       = $TechTool.Setup_Fo
    $Setup_AS_Client_Config_Fo                      = $TechTool.Setup_AS_Client_Config_Fo
    $Setup_AS_Client_Config_Fo_Repository           = $TechTool.Setup_AS_Client_Config_Repository_Fo
    $Setup_AS_RegistryBackup_Fo                     = $TechTool.Setup_AS_RegistryBackup_Fo
    $Setup_AS_Status_Fo                             = $TechTool.Setup_AS_Status_Fo
    $Setup_AS_AutomateSetup_ps1                     = $TechTool.Setup_AS_AutomateSetup_ps1
    $Setup_SoftwareCollection_Fo                    = $TechTool.Setup_SoftwareCollection_Fo
    $Setup_SoftwareCollection_Fo_Configs            = $TechTool.Setup_SoftwareCollection_Fo_Configs
    $Setup_SoftwareCollection_ODTSoftware_Fo        = $TechTool.Setup_SoftwareCollection_ODTSoftware_Fo
    $Setup_SoftwareCollection_ProfileSoftware_Fo    = $TechTool.Setup_SoftwareCollection_ProfileSoftware_Fo
    $Setup_SoftwareCollection_StandardSoftware_Fo   = $TechTool.Setup_SoftwareCollection_StandardSoftware_Fo
    $Setup_SCOPEImageSetup_Fo                       = $TechTool.Setup_SCOPEImageSetup_Fo
    $Setup_SCOPEImageSetup_PublicDesktop_Fo         = $TechTool.Setup_SCOPEImageSetup_PublicDesktop_Fo
    $Setup_SCOPEPostImageSetup_Fo                   = $TechTool.Setup_SCOPEPostImageSetup_Fo
    $Setup_SCOPEUserProfile_Fo                      = $TechTool.Setup_SCOPEUserProfile_Fo
#endregion Module Variables

#region Client Config Functions
##############################################################
############## START OF CLIENT CONFIG FUNCTIONS ##############
##############################################################

# THESE SCRIPTS TO SEARCH FOR CLIENT CONFIGS IN THIS ORDER
# 1. C:\Setup (Final destination if Imaging USB is not plugged in)
# 2. C:\Setup\Automated_Setup\Client_Config (Where client config is saved during Automated Setup process)
# 3. $USB_Drive\sources\PC-Maintenance\1. Automated Setup\Client_Configs (Final destination if Imaging USB IS plugged in)
    # This folder will contain all client configs
    # If Imaging USB is plugged in at start of Automated Setup, will ask tech which of the client configs to load
    # If saving here at the end of the Automated Setup process and config already exists with same name, over-write
        # This will make sure the configs in this directory are the latest version
        # For instance, planning on encrypting local admin password and don't want to keep around configs that don't have the password encrypted

function Get-ClientSettings {
    $ClientConfig = $null
    
    # Get USB Paths
    if ($USB.Exists()) {
        $FolderPath_USB_Automated_Setup_Client_Configs = $USB.Client_Configs_Fo
    }

    # First, check for a Client Config file under $Setup_Fo = C:\Setup
    $ClientConfig = (Get-ChildItem -Path "$Setup_Fo\*.ClientConfig" -ErrorAction SilentlyContinue)
    # Second, check the Local Client Config repository under $Setup_AS_Client_Config_Fo = "C:\Setup\_Automated_Setup\_Client_Config"
    If (!($ClientConfig)) {$ClientConfig = (Get-ChildItem -Path "$Setup_AS_Client_Config_Fo\*.ClientConfig" -ErrorAction SilentlyContinue)} else {$DelFlag = $true; $NewFlag = $true}
    # Third, check the USB Client Configs repository under $FolderPath_USB_Automated_Setup_Client_Configs = "$USB_Drive\PC_Setup\Client_Folders\_Client_Configs"
    If (!($ClientConfig)) {
        $NewFlag = $true
        $ClientConfigs = (Get-ChildItem -Path "$FolderPath_USB_Automated_Setup_Client_Configs\*.ClientConfig" -ErrorAction SilentlyContinue)
        If ($ClientConfigs.Count -gt 0) {
            Write-Host "Imaging Tool Client Config Repository found. Loading Client Config files.." -ForegroundColor Green
            Do {
                $Count = 1
                Write-Host "`n   -=[ Available Client Config Files ]=-"
                ForEach ($Config in $ClientConfigs) {
                    $Line = "   $Count" + ": " + $Config.Name
                    Write-Host $Line
                    $Count++
                }
                $Line = "   $Count" + ": " + "OR, start a new Client Config..."
                Write-Host $Line
                [int]$choice = Read-Host -Prompt "`nWhich Client Config file would you like to load? (Enter a number from 1 to $Count)"
            } Until (($choice -gt 0) -and ($choice -le $Count))
            If ($choice -ne $Count) {
                $ClientConfig = $ClientConfigs[$choice-1]
            }
        }
    } 
    if (!($ClientConfig)) {
    # Fourth, check the Local Client Configs repository under $Setup_AS_Client_Config_Fo_Repository = "C:\Setup\_Automated_Setup\_Client_Config\Repository"
        $NewFlag = $true
        $ClientConfigs = (Get-ChildItem -Path "$Setup_AS_Client_Config_Fo_Repository\*.ClientConfig" -ErrorAction SilentlyContinue)
        If ($ClientConfigs.Count -gt 0) {
            Write-Host "Local Client Config Repository found. Loading Client Config files.." -ForegroundColor Green
            Do {
                $Count = 1
                Write-Host "`n   -=[ Available Client Config Files ]=-"
                ForEach ($Config in $ClientConfigs) {
                    $Line = "   $Count" + ": " + $Config.Name
                    Write-Host $Line
                    $Count++
                }
                $Line = "   $Count" + ": " + "OR, start a new Client Config..."
                Write-Host $Line
                [int]$choice = Read-Host -Prompt "`nWhich Client Config file would you like to load? (Enter a number from 1 to $Count)"
            } Until (($choice -gt 0) -and ($choice -le $Count))
            If ($choice -ne $Count) {
                $ClientConfig = $ClientConfigs[$choice-1]
            }
        }
    }

    If ($ClientConfig) {
        # load if found
        $ClientConfigFile = $ClientConfig.FullName
        Write-Host ">Loading"$ClientConfig.Name -ForegroundColor Yellow
        $Global:ClientSettings = Get-Content -Path $ClientConfigFile | ConvertFrom-Json
        Write-Host "Completed`n" -ForegroundColor Green
        Save-ClientSettings
        #If ($DelFlag = $true) {Remove-Item -Path $ClientConfigFile -Force | Out-Null}
    } else {
        $NewFlag = $true
        # Otherwise start a new client config
        Write-Host "`nStarting a new Client Config..." -ForegroundColor Green
        Write-Host "What is the client's abbreviated name? Example: SFoT, Mustang, etc..." -ForegroundColor Yellow
        Write-Host "Make it a single word with no spaces. The shorter the better." -ForegroundColor Red
        $choice = $null
        Do {$choice = Read-Host -Prompt "Client Abbreviated Name"} Until ($choice -ne $null)
        $Global:ClientSettings = [PSCustomObject]@{
            CreationDate = (Get-Date)
            ClientName = $choice
        }
        Save-ClientSettings
        $ClientConfig = (Get-ChildItem -Path "$Setup_AS_Client_Config_Fo\*.ClientConfig" -ErrorAction SilentlyContinue)
        Write-Host "Client Config File started: "$ClientConfig.Name -ForegroundColor Green
        Write-Host ""
    }
    if ($NewFlag = $true) {
        #if (Test-Path "$USB_Drive") {
        #    $source = "$FolderPath_USB_Automated_Setup_Client_Folders\$ClientName"
        #    $what = '/A-:SH /COPYALL /B /E'
        #    $options = '/R:3 /W:1 /XX /XO'
        #    $dest = $Setup_Fo
        #    $command = "ROBOCOPY $source $dest $what $options"
        #    Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
        #}
    }

    # Remove Local Client Configs Repository if it exists
    If (Test-Path $Setup_AS_Client_Config_Fo_Repository) {Remove-Item -Path $Setup_AS_Client_Config_Fo_Repository -Recurse -Force -ErrorAction SilentlyContinue}
} Export-ModuleMember -Function Get-ClientSettings

function Save-ClientSettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $Final
    )
    $ClientName            = $Global:ClientSettings.ClientName
    $SetupType             = $Global:ClientSettings.SetupType
    $ClientConfig_FileName = "$ClientName-$SetupType.ClientConfig"

    # Get USB Paths
    if ($USB.Exists()) {
        $FolderPath_USB_Automated_Setup_Client_Configs = $USB.Client_Configs_Fo
    }

    If ($Final) {
        Write-Host ""
        If (!($USB.Exists())) {
            Write-Host "WARNING:" -ForegroundColor Red -NoNewline; Write-Host " Conducting final save of $ClientConfig_FileName and the Imaging Tool is not detected"
            Write-Host "If you want $ClientConfig_FileName to be saved to your Imaging Tool, " -NoNewline; Write-Host "plug it in now" -NoNewline -ForegroundColor Red; Write-Host " before continuing"
            Pause
            # Get USB Paths
            if ($USB.Exists()) {
                $FolderPath_USB_Automated_Setup_Client_Configs = $USB.Client_Configs_Fo
            }
        }
        # If $Final switch and USB is plugged in, save to USB at $FolderPath_USB_Automated_Setup_Client_Configs = "$USB_Drive\PC_Setup\Client_Configs"
        If ($USB.Exists()) {
            $Global:ClientSettings | ConvertTo-Json -depth 1 | Set-Content -Path "$FolderPath_USB_Automated_Setup_Client_Configs\$ClientConfig_FileName" -Force
            Write-Host "Saved: " -NoNewline -ForegroundColor Green; Write-Host "$FolderPath_USB_Automated_Setup_Client_Configs\$ClientConfig_FileName"
            #$dest = "$FolderPath_USB_Automated_Setup_Client_Folders\$ClientName"
            #$what = '/A-:SH /COPYALL /B /E'
            #$options = '/R:3 /W:1 /XX /XO'
            #$source = $Setup_SCOPEImageSetup_Fo; $command = "ROBOCOPY $source $dest\SCOPE-Image_Setup $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
            #$source = $Setup_SCOPEPostImageSetup_Fo; $command = "ROBOCOPY $source $dest\SCOPE-POST_Image_Setup $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
            #$source = $Setup_SCOPEUserProfile_Fo; $command = "ROBOCOPY $source $dest\SCOPE-User_Profile $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
            #Write-Host "REMOVE THIS PAUSE AFTER TROUBLESHOOTING ROBOCOPY"
            #PAUSE
        } else {
        # If $Final switch and USB is NOT plugged in, save to $Setup_Fo = "C:\Setup"
            $Global:ClientSettings | ConvertTo-Json -depth 1 | Set-Content -Path "$Setup_Fo\$ClientConfig_FileName" -Force
            Write-Host "Saved: " -NoNewline -ForegroundColor Green; Write-Host "$Setup_Fo\$ClientConfig_FileName"
            Write-Host "Make sure to move this to your Imaging USB for future use if desired" -ForegroundColor Yellow
        }
    } else {
        # If not $Final switch, save locally to $Setup_AS_Client_Config_Fo = "C:\Setup\Automated_Setup\Client_Config"
        $Global:ClientSettings | ConvertTo-Json -depth 1 | Set-Content -Path "$Setup_AS_Client_Config_Fo\$ClientConfig_FileName" -Force
        if ($USB.Exists()) {
            #$dest = "$FolderPath_USB_Automated_Setup_Client_Folders\$ClientName"
            #$what = '/A-:SH /COPYALL /B /E'
            #$options = '/R:3 /W:1 /XX /XO'
            #$source = $Setup_SCOPEImageSetup_Fo; $command = "ROBOCOPY $source $dest\SCOPE-Image_Setup $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
            #$source = $Setup_SCOPEPostImageSetup_Fo; $command = "ROBOCOPY $source $dest\SCOPE-POST_Image_Setup $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
            #$source = $Setup_SCOPEUserProfile_Fo; $command = "ROBOCOPY $source $dest\SCOPE-User_Profile $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
        }
    }
} Export-ModuleMember -Function Save-ClientSettings

function Add-ClientSetting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [string] $Value
    )

    $Global:ClientSettings | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
    Save-ClientSettings
} Export-ModuleMember -Function Add-ClientSetting

############################################################
############## END OF CLIENT CONFIG FUNCTIONS ##############
############################################################
#endregion Client Config Functions

#region Automated-Setup Related Functions
function Start-AutomatedSetup_AtLogon {
    Set-ItemProperty -Path $RunOnceKey -Name SetupComputer -Value ("C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe -NoExit -Windowstyle maximized -ExecutionPolicy Bypass -File $Setup_AS_AutomateSetup_ps1") -Force
    Write-Host "Set Automated-Setup script to run at next logon: " -NoNewline; Write-Host "Complete" -ForegroundColor Green
} Export-ModuleMember -Function Start-AutomatedSetup_AtLogon

function Remove-StartAutomatedSetup_BatchFile {
<#
.Notes
    -Used a function for this rather than just a single 'Remove-Item' line, so that it would simply additionally report when it removes the file or if it already has
    -No '-InitialOnly' flag needed in this case
    -This is a very simple function. Should run the same regardless of client config or if building a single PC or an Image
#>
    param(
        [Parameter(Mandatory = $false)]
        [string] $Path = "$FilePath_Local_StartAutomatedSetup" #Default
    )

    If (Test-Path $Path) {
        Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue | Out-Null
        Write-Host "`nRemove Start-AutomatedSetup-RAA.bat from the public desktop: " -NoNewline; Write-Host "Complete" -ForeGroundColor Green
    } else {
        Write-Host "Remove Start-AutomatedSetup-RAA.bat from the public desktop: " -NoNewline; Write-Host "Previously Completed" -ForeGroundColor Green
    }
} Export-ModuleMember -Function Remove-StartAutomatedSetup_BatchFile

function Determine-SetupType {
    If (!($global:ClientSettings.SetupType)) {
        #Remove-Item -Path "$Setup_AS_Client_Config_Fo\*" -Recurse -Force -ErrorAction SilentlyContinue
        $CurrentConfig = Get-ChildItem -Path "$Setup_AS_Client_Config_Fo\*"
        DO {
            Write-Host ""
            Write-Host "Are you setting up a single PC or are you building an image?" -ForegroundColor Yellow
            Write-Host "1. Setting up a single PC"
            Write-Host "2. Building an image that i will capture later"
            $choice = Read-Host -Prompt "Enter a number, 1 or 2"
        } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
        switch ($choice) {
            1 {Add-ClientSetting -Name "SetupType" -Value SingleSetup}
            2 {Add-ClientSetting -Name "SetupType" -Value BuildImage}
        }
        Remove-Item $CurrentConfig -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    If ($global:ClientSettings.SetupType -eq "SingleSetup") {
        Write-Host "Setting up a single PC" -ForeGroundColor Green
    }
    If ($global:ClientSettings.SetupType -eq "BuildImage") {
        Write-Host "Building an image" -ForeGroundColor Green
    }
} Export-ModuleMember -Function Determine-SetupType

function Standard-Checks {
    If ($ClientSettings.SetupType -eq "BuildImage") {Write-Host "`n-=[ PRE-Image Tasks ]=-" -ForegroundColor DarkGray}
    If ($ClientSettings.SetupType -eq "SingleSetup") {Write-Host "`n-=[ Standard Checks ]=-" -ForegroundColor DarkGray}
    Get-DomainJoinInfo
    If ($global:ClientSettings.SetupType -eq "SingleSetup") {Join-Domain}
    CheckPoint-Client_Software
    Set-DefaultApps
    CheckPoint-Client_WiFi
    CheckPoint-Public_Desktop
    CheckPoint-CreateScansFolder
} Export-ModuleMember -Function Standard-Checks

function CheckPoint-Capture_Image {
    # Variables - edit as needed
    $Step = "Capture Image"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    
    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step has been completed" -ForegroundColor Green}
    } else {
        DO {
            Write-Host ""
            Write-Host "-=[ Cleanup ]=-" -ForegroundColor DarkGray
            Write-Host "!!Last Step!!" -ForegroundColor Red
            Write-Host "Please continue creating the image" -ForeGroundColor Yellow
            Write-Host "When image is complete, type in 'ready' to get the PC ready to have an image taken" -ForegroundColor Yellow 
            Write-Host "First Disk Cleaner will run to clean up the PC, then the pc will shutdown so that you can take an image" -ForeGroundColor Yellow
            $choice = Read-Host -Prompt "When ready, type in 'ready'"
        } UNTIL ($choice -eq "ready")

        Run-Disk_Cleanup
        Remove-SuggestedAppxPackages -Final
        Write-Host "`nRemoving unnecessary files to shrink image size"
        Remove-Folder -Folder $Setup_SoftwareCollection_ODTSoftware_Fo
        Remove-Folder -Folder $Setup_SoftwareCollection_StandardSoftware_Fo
    
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host "`Hit any key to shut down the computer in order to take an image"
        PAUSE
        Stop-Computer
        PAUSE
    }
} Export-ModuleMember -Function CheckPoint-Capture_Image

function Cleanup-AutomatedSetup {
    Write-Host "`n-=[ Cleanup Automated-Setup ]=-" -ForegroundColor DarkGray -NoNewline; Write-Host " !!Last Steps!!" -ForegroundColor Red
    Write-Host "This is the end of the AutomatedSetup script. After this last question, all of the AutomatedSetup related scripts and settings will be removed" -ForegroundColor Yellow
    Save-ClientSettings -Final
    CheckPoint-Disk_Cleanup
    Remove-AutoLogon -Force
    Remove-SuggestedAppxPackages -Final
    Write-Host ""
    Remove-Folder -Folder $Setup_SoftwareCollection_Fo
    Remove-Folder -Folder $Setup_SCOPEImageSetup_Fo
    Remove-Folder -Folder $Setup_SCOPEPostImageSetup_Fo
    #Remove-Folder -Folder $Setup_SCOPEUserProfile_Fo
    Remove-Automated_Setup_Files
    Stop-AutomatedSetup
    New-Item "$Setup_Fo\AutomatedSetup-Complete.txt" -ItemType File -Value "Auto-Setup completed and system has been cleaned up" -Force | Out-Null
    Write-Host "`nCleanup is complete!" -ForegroundColor Green
} Export-ModuleMember -Function Cleanup-AutomatedSetup

function Remove-Folder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Folder
    )
    
    If (Test-Path -Path $Folder) {
        Remove-Item $Folder -Recurse
        Write-Host "Removed - $Folder" -ForeGroundColor Green
    } else {Write-Host "$Folder has already been removed" -ForegroundColor Green}
}

function Get-DomainJoinInfo {
    # Variables - edit as needed
    $Step = "Get Domain Join Info"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$Setup_AS_Status_Fo\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        DO {
            # Load setting from Client Config if available
            If ($global:ClientSettings.DomainJoin) {
                $choice = $global:ClientSettings.DomainJoin
            } else {
            # Otherwise ask tech
                Write-Host "`n-=[ $Step ]=-" -ForegroundColor Yellow
                If ($Global:ClientSettings.SetupType -eq "SingleSetup") {Write-Host "Will you be joining this PC to a domain?"}
                If ($Global:ClientSettings.SetupType -eq "BuildImage") {Write-Host "After applying this image to PCs, will you be joining them to the domain?"}
                Write-Host "1. Yes"
                Write-Host "2. No" 
                $choice = Read-Host -Prompt "Enter a number, 1 or 2"
            }
        } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
        switch ($choice) {
            1 {
                # Save the fact that we DO want to join the domain (either now or later)
                If (!($global:ClientSettings.DomainJoin -and $Automated_Setup)) {
                    Add-ClientSetting -Name "DomainJoin" -Value $choice
                }
                
                # Get NETBIOS
                $choice = $null
                If ($global:ClientSettings.NETBIOS) {
                    Write-Host "NETBIOS obtained from client config: "$global:ClientSettings.NETBIOS -ForegroundColor Green
                } else {
                    DO {
                        Write-Host "`nWhat is the NETBIOS Domain name?" -ForegroundColor Yellow
                        Write-Host "Example: ATI"
                        $choice = Read-Host -Prompt "Enter the NETBIOS Domain name"
                    } UNTIL ($choice -ne $null)
                    if ($Automated_Setup) {Add-ClientSetting -Name NETBIOS -Value $choice}
                }

                # Get DNS Domain Name
                $choice = $null
                If ($global:ClientSettings.DNS_Domain_Name) {
                    Write-Host "DNS Domain Name obtained from client config: "$global:ClientSettings.DNS_Domain_Name -ForegroundColor Green
                } else {
                    DO {
                        Write-Host ""
                        Write-Host "What is the DNS Domain name?" -ForegroundColor Yellow
                        Write-Host "Example: ati.local"
                        $choice = Read-Host -Prompt "Enter the DNS Domain name"
                    } UNTIL ($choice -ne $null)
                    if ($Automated_Setup) {Add-ClientSetting -Name DNS_Domain_Name -Value $choice}
                }

                # Get Domain Admin Username
                $choice = $null
                If ($global:ClientSettings.Domain_Admin_Username) {
                    Write-Host "Domain Admin username obtained from client config: "$global:ClientSettings.Domain_Admin_Username -ForegroundColor Green
                } else {
                    DO {
                        Write-Host ""
                        Write-Host "What is the domain admin username?" -ForegroundColor Yellow
                        Write-Host "Example: Axxys"
                        $choice = Read-Host -Prompt "Enter the domain admin username"
                    } UNTIL ($choice -ne $null)
                    if ($Automated_Setup) {Add-ClientSetting -Name Domain_Admin_Username -Value $choice}
                }

                # If building an image, need to get naming convention and example
                If ($global:ClientSettings.SetupType -eq "BuildImage") {
                    # Get naming convention
                    $choice = $null
                    If ($global:ClientSettings.Naming_Convention) {
                        Write-Host "Naming Convention obtained from client config: "$global:ClientSettings.Naming_Convention -ForegroundColor Green
                    } else {
                        DO {
                            Write-Host ""
                            Write-Host "What is the PC naming convention?" -ForegroundColor Yellow
                            Write-Host "Example: ATI-[DT/LT]-XX"
                            $choice = Read-Host -Prompt "Enter the PC naming convention"
                        } UNTIL ($choice -ne $null)
                        if ($Automated_Setup) {Add-ClientSetting -Name Naming_Convention -Value $choice}
                    }

                    # Get PC Name Example
                    $choice = $null
                    If ($global:ClientSettings.PC_Name_Example) {
                        Write-Host "PC Name Example obtained from client config: "$global:ClientSettings.PC_Name_Example -ForegroundColor Green
                    } else {
                        DO {
                            Write-Host ""
                            Write-Host "What is an example for a PC name?" -ForegroundColor Yellow
                            Write-Host "Example: ATI-DT-01"
                            $choice = Read-Host -Prompt "Enter the example PC name"
                        } UNTIL ($choice -ne $null)
                        if (Automated_Setup) {Add-ClientSetting -Name PC_Name_Example -Value $choice}
                    }
                }
                # Mark this section as completed
                if ($Automated_Setup -or $global:TuneUp_PC) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
                Write-Host "$Step has been completed" -ForegroundColor Green
            } # End of Switch(1)
            2 {
                # Save the fact that we do NOT want to join the domain
                If (!($global:ClientSettings.DomainJoin) -and $Automated_Setup) {
                    Add-ClientSetting -Name "DomainJoin" -Value $choice
                }
                Write-Host "$Step has been skipped" -ForegroundColor Green
                
                # If building an image, still need to get naming convention and example
                If ($global:ClientSettings.SetupType -eq "BuildImage") {
                    Write-Host "Basic info only is needed..."
                    # Get naming convention
                    $choice = $null
                    If ($global:ClientSettings.Naming_Convention) {
                        Write-Host "Naming Convention obtained from client config: " + $global:ClientSettings.Naming_Convention -ForegroundColor Green
                    } else {
                        DO {
                            Write-Host ""
                            Write-Host "What is the PC naming convention?" -ForegroundColor Yellow
                            Write-Host "Example: ATI-[DT/LT]-XX"
                            $choice = Read-Host -Prompt "Enter the PC naming convention"
                        } UNTIL ($choice -ne $null)
                        if ($Automated_Setup) {Add-ClientSetting -Name Naming_Convention -Value $choice}
                    }

                    # Get PC Name Example
                    $choice = $null
                    If ($global:ClientSettings.PC_Name_Example) {
                        Write-Host "PC Name Example obtained from client config: " + $global:ClientSettings.PC_Name_Example -ForegroundColor Green
                    } else {
                        DO {
                            Write-Host ""
                            Write-Host "What is an example for a PC name?" -ForegroundColor Yellow
                            Write-Host "Example: ATI-DT-01"
                            $choice = Read-Host -Prompt "Enter the example PC name"
                        } UNTIL ($choice -ne $null)
                        if ($Automated_Setup) {Add-ClientSetting -Name PC_Name_Example -Value $choice}
                    }
                    Write-Host "$Step has been completed" -ForegroundColor Green
                }
                if ($Automated_Setup -or $global:TuneUp_PC) {New-Item $SkippedFile -ItemType File -Force | Out-Null}
                Write-Host ""
            } # End of Switch(2)
        } # End of Switch($choice)
    }
} Export-ModuleMember -Function Get-DomainJoinInfo

function CheckPoint-DriverUpdates {
    Install-DriverUpdateAssistant
    Update-Drivers
} Export-ModuleMember -Function CheckPoint-DriverUpdates
#endregion Automated-Setup Related Functions

#region Automated-Setup Submenu Functions
##############################################################################
############## Imaging Tool - Automated Setup Submenu Functions ##############
##############################################################################
function Inject-AutomatedSetupScripts {
    #region Function Variables
    $USB_AutomatedSetup_HomeDir = $USB.PCMaint_AS_HomeDir_Fo
    $Local_AutomatedSetup_HomeDir = $TechTool.Setup_Fo
        $USB_ClientConfigs_Folder = $USB.PCSetup_Client_Configs_Fo
        $Local_ClientConfigs_Repo = $TechTool.Setup_AS_Client_Config_Repository_Fo
    $USB_StandardSoftware_Folder = $USB.PCSetup_SoftwareCollection_StandardSoftware_Fo
    $Local_StandardSoftware_Folder = $TechTool.Setup_SoftwareCollection_StandardSoftware_Fo
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

function Start-AutomatedSetup {
    if (!(Test-Path $Setup_AS_AutomateSetup_ps1)) {
        Write-Host "`nAutomated Setup program is not detected on the current computer" -ForegroundColor Red
        Write-Host "First, Inject it into the PC" -ForegroundColor Yellow
    } else {
        Write-Host "`nStarting Automated Setup program" -ForegroundColor Green
        Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -ArgumentList "-NoExit -Windowstyle maximized -ExecutionPolicy Bypass -File $Setup_AS_AutomateSetup_ps1"
    }
} Export-ModuleMember -Function Start-AutomatedSetup

function Stop-AutomatedSetup {
    Write-Host "`nStopping Automated Setup program" -ForegroundColor Yellow
    Write-Host "-When you relog, the Automated Setup program will no longer run automatically like before" -ForegroundColor Green
    Remove-ItemProperty -Path $RunOnceKey -Name SetupComputer -Force -ErrorAction SilentlyContinue | Out-Null
} Export-ModuleMember -Function Stop-AutomatedSetup

function Remove-Automated_Setup_Files {
        Write-Host "`nStarting cleanup of Automated Setup Files" -ForegroundColor Yellow
        #Remove-Item $UnAttend -ErrorAction SilentlyContinue | Out-Null
        Remove-Item $Setup_AS_RegistryBackup_Fo -Recurse | Out-Null
        Remove-Item $Setup_AS_Client_Config_Fo -Recurse | Out-Null
        Remove-Folder -Folder $Setup_SoftwareCollection_Fo_Configs
        Write-Host "Automated Setup files have been removed from the PC" -ForegroundColor Green
} Export-ModuleMember -Function Remove-Automated_Setup_Files

function Read-ClientConfig {
    $ClientConfig = $null

    # Get USB Paths
    if ($USB.Exists()) {
        $FolderPath_USB_Automated_Setup_Client_Configs = $USB.Client_Configs_Fo
    }

    # Check the USB Client Configs repository under $FolderPath_USB_Automated_Setup_Client_Configs = "$USB_Drive\sources\PC-Maintenance\1. Automated Setup\Client_Configs"
    $ClientConfigs = (Get-ChildItem -Path "$FolderPath_USB_Automated_Setup_Client_Configs\*.ClientConfig" -ErrorAction SilentlyContinue)
    If ($ClientConfigs.Count -gt 0) {
        Write-Host "Imaging Tool Client Config Repository found. Loading Client Config files.." -ForegroundColor Green
        Do {
            $Count = 1
            Write-Host "`n   -=[ Available Client Config Files ]=-"
            ForEach ($ClientConfig in $ClientConfigs) {
                $Line = "   $Count" + ": " + $ClientConfig.Name
                Write-Host $Line
                $Count++
            }
            $Line = "   $Count" + ": " + "OR, Go Back..."
            Write-Host $Line
            $choice = Read-Host -Prompt "`nWhich Client Config file would you like to read the properties of? (Enter a number from 1 to $Count)"
        } Until (($choice -gt 0) -and ($choice -le $Count))
        If ($choice -ne $Count) {
            $ClientConfig = $ClientConfigs[$choice-1]
            Write-Host ">Loading"$ClientConfig.Name -ForegroundColor Yellow
            $ClientConfigFile = $ClientConfig.FullName
            Get-Member -InputObject (Get-Content -Path $ClientConfigFile | ConvertFrom-Json) -MemberType NoteProperty | Format-Table -Property Name,Definition -AutoSize
        }
    } else {
        Write-Host "Could not find any Client Configs in the Imaging Tool Repository:"
        Write-Host "> $FolderPath_USB_Automated_Setup_Client_Configs`n"
    }
} Export-ModuleMember -Function Read-ClientConfig

function Create-ClientConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $Final
    )


} Export-ModuleMember -Function Create-ClientConfig

#endregion Automated-Setup Submenu Functions

#region IGNORE
# This will not be called by script or Menu.ps1. It is not intended to be used except for one instance
function Create-RegistryBackupFile {
    DO {
        <#
        # Get USB Drive
        foreach ($Drive_Letter in (Get-PSDrive -PSProvider FileSystem).Name) {
            $Test_Path = "$Drive_Letter`:\PC_Setup"
            If (Test-Path $Test_Path) {
                $USB_Drive = "$Drive_Letter" + ":"
            }
        }
        #>

        # Get USB Paths
        $USB = New-ImagingUSB
        if ($USB.Exists()) {
            $USB_Drive = $USB.Drive_Letter
            $FolderPath_USB_Automated_Setup_RegistryBackup = $USB.Setup_AS_RegistryBackup_Folder
            $FilePath_USB_Automated_Setup_RegistryBackup   = $USB.Automated_Setup_RegistryBackup_File
        } else {
            Write-Host "WARNING:" -ForegroundColor Red -NoNewline; Write-Host " the Imaging Tool is not detected"
            Write-Host "Plug it in now before continuing" -ForegroundColor Red
            Pause
        }
    } Until ($USB.Exists())
    If (Test-Path $FilePath_USB_Automated_Setup_RegistryBackup) {
        Write-Host "WARNING:" -ForegroundColor Red -NoNewline; Write-Host " Registry backup already exists"
        Write-Host "Continuing will" -NoNewline; Write-Host " Over-write " -ForegroundColor Red -NoNewline; Write-Host "the existing backup file"
        Write-Host "Take a second to rename the existing file if you want to save it"
        PAUSE
    }
    Remove-Item -Path $FolderPath_USB_Automated_Setup_RegistryBackup -Force
    New-Item -Path $FolderPath_USB_Automated_Setup_RegistryBackup -ItemType Directory | Out-Null
    Get-Random -Count 32 -InputObject (0..255) | Out-File -FilePath $FilePath_USB_Automated_Setup_RegistryBackup
    Write-Host "$FilePath_USB_Automated_Setup_RegistryBackup has been created" -ForegroundColor Green
} # DO NOT EXPORT-MODULEMEMBER!!!
#endregion IGNORE