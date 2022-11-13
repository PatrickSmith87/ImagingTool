#################################################################################################################################################################
#################################################################################################################################################################
###                                                                                                                                                           ###
###                                                               -=[ Automate-Setup Module ]=-                                                               ###
###                                                                                                                                                           ###
#################################################################################################################################################################
#################################################################################################################################################################

#region Module Variables
$USB = New-ImagingUSB

$RunOnceKey                                   = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
$FilePath_Local_StartAutomatedSetup           = "C:\Users\Public\Desktop\Start-AutomatedSetup-RAA.bat"

# Modules Folder
    $FilePath_Local_AutomateSetup_Module             = "C:\Program Files\WindowsPowerShell\Modules\Automate-Setup\Automate-Setup.psm1"
    $FilePath_Local_ConfigurePC_Module               = "C:\Program Files\WindowsPowerShell\Modules\Configure-PC\Configure-PC.psm1"
    $FilePath_Local_InstallSoftware_Module           = "C:\Program Files\WindowsPowerShell\Modules\Install-Software\Install-Software.psm1"
    $FilePath_Local_TuneUpPC_Module                  = "C:\Program Files\WindowsPowerShell\Modules\TuneUp-PC\TuneUp-PC.psm1"
# 1. Automated Setup
    $FolderPath_Local_Setup                          = "C:\Setup"
    $FolderPath_Local_Client_Config                  = "C:\Setup\_Automated_Setup\_Client_Config"
    $FolderPath_Local_Client_Config_Repository       = "C:\Setup\_Automated_Setup\_Client_Config\Repository"
    $FolderPath_Local_Automated_Setup_RegistryBackup = "C:\Setup\_Automated_Setup\_RegistryBackup"
    $FolderPath_Local_AutomatedSetup_Status          = "C:\Setup\_Automated_Setup\Status"
    $FilePath_Local_AutomateSetup_Script             = "C:\Setup\_Automated_Setup\Automate-Setup.ps1"
    $FolderPath_Local_Software                       = "C:\Setup\_Software_Collection"
    $FolderPath_Local_Software_Configs               = "C:\Setup\_Software_Collection\_Software_Configs"
    $FolderPath_Local_ODT_Software                   = "C:\Setup\_Software_Collection\ODT"
    $FolderPath_Local_Profile_Software               = "C:\Setup\_Software_Collection\Profile_Specific_Software"
    $FolderPath_Local_Standard_Software              = "C:\Setup\_Software_Collection\Standard_Software"
    $FolderPath_Local_SCOPE_Image_Setup              = "C:\Setup\SCOPE-Image_Setup"
    $FolderPath_Local_Client_Public_Desktop          = "C:\Setup\SCOPE-Image_Setup\Public Desktop"
    $FolderPath_Local_SCOPE_POST_Image_Setup         = "C:\Setup\SCOPE-POST_Image_Setup"
    $FolderPath_Local_SCOPE_User_Profile             = "C:\Setup\SCOPE-User_Profile"

<#
 THESE are defined in functions within this module
 $FolderPath_USB_Automated_Setup_RegistryBackup      = "$USB_Drive\sources\PC-Maintenance\1. Automated Setup\Setup\_Automated_Setup\_RegistryBackup"
 $FilePath_USB_Automated_Setup_RegistryBackup        = "$USB_Drive\sources\PC-Maintenance\1. Automated Setup\Setup\_Automated_Setup\_RegistryBackup\registry-backup020622.reg"


#>
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
    if ($script:USB.Exists()) {
        $FolderPath_USB_Automated_Setup_Client_Configs = $USB.FolderPath_Automated_Setup_Client_Configs
    }

    # First, check for a Client Config file under $FolderPath_Local_Setup = C:\Setup
    $ClientConfig = (Get-ChildItem -Path "$FolderPath_Local_Setup\*.ClientConfig" -ErrorAction SilentlyContinue)
    # Second, check the Local Client Config repository under $FolderPath_Local_Client_Config = "C:\Setup\_Automated_Setup\_Client_Config"
    If (!($ClientConfig)) {$ClientConfig = (Get-ChildItem -Path "$FolderPath_Local_Client_Config\*.ClientConfig" -ErrorAction SilentlyContinue)} else {$DelFlag = $true; $NewFlag = $true}
    # Third, check the USB Client Configs repository under $FolderPath_USB_Automated_Setup_Client_Configs = "$USB_Drive\PC_Setup\Client_Folders\_Client_Configs"
    If (!($ClientConfig)) {
        $NewFlag = $true
        $ClientConfigs = (Get-ChildItem -Path "$FolderPath_USB_Automated_Setup_Client_Configs\*.ClientConfig" -ErrorAction SilentlyContinue)
        Pause
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
    # Fourth, check the Local Client Configs repository under $FolderPath_Local_Client_Config_Repository = "C:\Setup\_Automated_Setup\_Client_Config\Repository"
        $NewFlag = $true
        $ClientConfigs = (Get-ChildItem -Path "$FolderPath_Local_Client_Config_Repository\*.ClientConfig" -ErrorAction SilentlyContinue)
        Write-Host "$ClientConfigs"
        Write-Host "TEST POINT 3"
        Pause
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
        $input = $null
        Do {$input = Read-Host -Prompt "Client Abbreviated Name"} Until ($input -ne $null)
        $Global:ClientSettings = [PSCustomObject]@{
            CreationDate = (Get-Date)
            ClientName = $input
        }
        Save-ClientSettings
        $ClientConfig = (Get-ChildItem -Path "$FolderPath_Local_Client_Config\*.ClientConfig" -ErrorAction SilentlyContinue)
        Write-Host "Client Config File started: "$ClientConfig.Name -ForegroundColor Green
        Write-Host ""
    }
    if ($NewFlag = $true) {
        #if (Test-Path "$USB_Drive") {
        #    $source = "$FolderPath_USB_Automated_Setup_Client_Folders\$ClientName"
        #    $what = '/A-:SH /COPYALL /B /E'
        #    $options = '/R:3 /W:1 /XX /XO'
        #    $dest = $FolderPath_Local_Setup
        #    $command = "ROBOCOPY $source $dest $what $options"
        #    Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
        #}
    }

    # Remove Local Client Configs Repository if it exists
    If (Test-Path $FolderPath_Local_Client_Config_Repository) {Remove-Item -Path $FolderPath_Local_Client_Config_Repository -Recurse -Force -ErrorAction SilentlyContinue}
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
        $USB_Drive = $USB.Drive_Letter
        $FolderPath_USB_Automated_Setup_Client_Folders = $USB.FolderPath_Automated_Setup_Client_Folders
        $FolderPath_USB_Automated_Setup_Client_Configs = $USB.FolderPath_Automated_Setup_Client_Configs
    }

    If ($Final) {
        Write-Host ""
        If (!($USB.Exists())) {
            Write-Host "WARNING:" -ForegroundColor Red -NoNewline; Write-Host " Conducting final save of $ClientConfig_FileName and the Imaging Tool is not detected"
            Write-Host "If you want $ClientConfig_FileName to be saved to your Imaging Tool, " -NoNewline; Write-Host "plug it in now" -NoNewline -ForegroundColor Red; Write-Host " before continuing"
            Pause
            # Get USB Paths
            if ($USB.Exists()) {
                $USB_Drive = $USB.Drive_Letter
                $FolderPath_USB_Automated_Setup_Client_Folders = $USB.FolderPath_Automated_Setup_Client_Folders
                $FolderPath_USB_Automated_Setup_Client_Configs = $USB.FolderPath_Automated_Setup_Client_Configs
            }
        }
        # If $Final switch and USB is plugged in, save to USB at $FolderPath_USB_Automated_Setup_Client_Configs = "$USB_Drive\PC_Setup\Client_Configs"
        If ($USB.Exists()) {
            $Global:ClientSettings | ConvertTo-Json -depth 1 | Set-Content -Path "$FolderPath_USB_Automated_Setup_Client_Configs\$ClientConfig_FileName" -Force
            Write-Host "Saved: " -NoNewline -ForegroundColor Green; Write-Host "$FolderPath_USB_Automated_Setup_Client_Configs\$ClientConfig_FileName"
            #$dest = "$FolderPath_USB_Automated_Setup_Client_Folders\$ClientName"
            #$what = '/A-:SH /COPYALL /B /E'
            #$options = '/R:3 /W:1 /XX /XO'
            #$source = $FolderPath_Local_SCOPE_Image_Setup; $command = "ROBOCOPY $source $dest\SCOPE-Image_Setup $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
            #$source = $FolderPath_Local_SCOPE_POST_Image_Setup; $command = "ROBOCOPY $source $dest\SCOPE-POST_Image_Setup $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
            #$source = $FolderPath_Local_SCOPE_User_Profile; $command = "ROBOCOPY $source $dest\SCOPE-User_Profile $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
            #Write-Host "REMOVE THIS PAUSE AFTER TROUBLESHOOTING ROBOCOPY"
            #PAUSE
        } else {
        # If $Final switch and USB is NOT plugged in, save to $FolderPath_Local_Setup = "C:\Setup"
            $Global:ClientSettings | ConvertTo-Json -depth 1 | Set-Content -Path "$FolderPath_Local_Setup\$ClientConfig_FileName" -Force
            Write-Host "Saved: " -NoNewline -ForegroundColor Green; Write-Host "$FolderPath_Local_Setup\$ClientConfig_FileName"
            Write-Host "Make sure to move this to your Imaging USB for future use if desired" -ForegroundColor Yellow
        }
    } else {
        # If not $Final switch, save locally to $FolderPath_Local_Client_Config = "C:\Setup\Automated_Setup\Client_Config"
        $Global:ClientSettings | ConvertTo-Json -depth 1 | Set-Content -Path "$FolderPath_Local_Client_Config\$ClientConfig_FileName" -Force
        if ($USB.Exists()) {
            #$dest = "$FolderPath_USB_Automated_Setup_Client_Folders\$ClientName"
            #$what = '/A-:SH /COPYALL /B /E'
            #$options = '/R:3 /W:1 /XX /XO'
            #$source = $FolderPath_Local_SCOPE_Image_Setup; $command = "ROBOCOPY $source $dest\SCOPE-Image_Setup $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
            #$source = $FolderPath_Local_SCOPE_POST_Image_Setup; $command = "ROBOCOPY $source $dest\SCOPE-POST_Image_Setup $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
            #$source = $FolderPath_Local_SCOPE_User_Profile; $command = "ROBOCOPY $source $dest\SCOPE-User_Profile $what $options"; Start-Process cmd.exe -ArgumentList "/c $command" -WindowStyle Minimized
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
    Set-ItemProperty -Path $RunOnceKey -Name SetupComputer -Value ("C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe -NoExit -Windowstyle maximized -ExecutionPolicy Bypass -File $FilePath_Local_AutomateSetup_Script") -Force
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
        Write-Host ""
        Write-Host "Remove Start-AutomatedSetup-RAA.bat from the public desktop: " -NoNewline; Write-Host "Complete" -ForeGroundColor Green
    } else {
        Write-Host "Remove Start-AutomatedSetup-RAA.bat from the public desktop: " -NoNewline; Write-Host "Previously Completed" -ForeGroundColor Green
    }
} Export-ModuleMember -Function Remove-StartAutomatedSetup_BatchFile

function Determine-SetupType {
    If (!($global:ClientSettings.SetupType)) {
        #Remove-Item -Path "$FolderPath_Local_Client_Config\*" -Recurse -Force -ErrorAction SilentlyContinue
        $CurrentConfig = Get-ChildItem -Path "$FolderPath_Local_Client_Config\*"
        DO {
            Write-Host ""
            Write-Host "Are you setting up a single PC or are you building an image?" -ForegroundColor Yellow
            Write-Host "1. Setting up a single PC"
            Write-Host "2. Building an image that i will capture later"
            $input = Read-Host -Prompt "Enter a number, 1 or 2"
        } UNTIL (($input -eq 1) -OR ($input -eq 2))
        switch ($input) {
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
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
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
            $input = Read-Host -Prompt "When ready, type in 'ready'"
        } UNTIL ($input -eq "ready")

        Run-Disk_Cleanup
        Remove-SuggestedAppxPackages -Final
        Write-Host "`nRemoving unnecessary files to shrink image size"
        Remove-Folder -Folder $FolderPath_Local_ODT_Software
        Remove-Folder -Folder $FolderPath_Local_Standard_Software
    
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
    Remove-Folder -Folder $FolderPath_Local_Software
    Remove-Folder -Folder $FolderPath_Local_SCOPE_Image_Setup
    Remove-Folder -Folder $FolderPath_Local_SCOPE_POST_Image_Setup
    #Remove-Folder -Folder $FolderPath_Local_SCOPE_User_Profile
    Remove-Automated_Setup_Files
    Stop-AutomatedSetup
    New-Item "$FolderPath_Local_Setup\AutomatedSetup-Complete.txt" -ItemType File -Value "Auto-Setup completed and system has been cleaned up" -Force | Out-Null
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
#endregion Automated-Setup Related Functions

#region Automated-Setup Submenu Functions
##############################################################################
############## Imaging Tool - Automated Setup Submenu Functions ##############
##############################################################################
function Start-AutomatedSetup {
    Write-Host ""
    if (!(Test-Path $FilePath_Local_AutomateSetup_Script)) {
        Write-Host "Automated Setup program is not detected on the current computer" -ForegroundColor Red
        Write-Host "First, Inject it into the PC" -ForegroundColor Yellow
    } else {
        Write-Host "Starting Automated Setup program" -ForegroundColor Green
        Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -ArgumentList "-NoExit -Windowstyle maximized -ExecutionPolicy Bypass -File $FilePath_Local_AutomateSetup_Script"
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
        Remove-Item $FolderPath_Local_Automated_Setup_RegistryBackup -Recurse | Out-Null
        Remove-Item $FolderPath_Local_Client_Config -Recurse | Out-Null
        Remove-Item $FilePath_Local_AutomateSetup_Module | Out-Null
        Remove-Item $FilePath_Local_ConfigurePC_Module | Out-Null
        Remove-Item $FilePath_Local_InstallSoftware_Module | Out-Null
        Remove-Folder -Folder $FolderPath_Local_Software_Configs
        Write-Host "Automated Setup files have been removed from the PC" -ForegroundColor Green
} Export-ModuleMember -Function Remove-Automated_Setup_Files

function Read-ClientConfig {
    $ClientConfig = $null

    # Get USB Paths
    if ($USB.Exists()) {
        $FolderPath_USB_Automated_Setup_Client_Configs = $USB.FolderPath_Automated_Setup_Client_Configs
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
            $input = Read-Host -Prompt "`nWhich Client Config file would you like to read the properties of? (Enter a number from 1 to $Count)"
        } Until (($input -gt 0) -and ($input -le $Count))
        If ($input -ne $Count) {
            $ClientConfig = $ClientConfigs[$input-1]
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
            $FolderPath_USB_Automated_Setup_RegistryBackup = $USB.Automated_Setup_RegistryBackup_Folder
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