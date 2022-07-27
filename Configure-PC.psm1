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
if ($FolderPath_Local_Setup -eq $null)                                                 {$FolderPath_Local_Setup = "C:\Setup"}
if ($FolderPath_Local_Client_Config -eq $null)                                 {$FolderPath_Local_Client_Config = "C:\Setup\_Automated_Setup\_Client_Config"}
# NOT USED? if ($FolderPath_Local_AutomatedSetup_SetupScripts -eq $null) {$FolderPath_Local_AutomatedSetup_SetupScripts = "C:\Setup\Automated_Setup\SetupScripts"}
if ($FolderPath_Local_AutomatedSetup_Status -eq $null)                 {$FolderPath_Local_AutomatedSetup_Status = "C:\Setup\_Automated_Setup\Status"}
if ($FilePath_Local_Automated_Setup_RegistryBackup -eq $null)   {$FilePath_Local_Automated_Setup_RegistryBackup = "C:\Setup\_Automated_Setup\_RegistryBackup\registry-backup020622.reg"}

# $Global:ClientSettings <--- NEEDS to stay defined globally as the ClientConfigs are utilized specifically by the Automate-Setup script
if ($WinLogonKey -eq $null) {$WinLogonKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"}
if ($Target_TimeZone -eq $null) {$Target_TimeZone = "Central Standard Time"}
# Power Settings
if ($AC_Monitor_Timeout -eq $null) {$AC_Monitor_Timeout = 15}
if ($AC_Standby_Timeout -eq $null) {$AC_Standby_Timeout = 0}
if ($DC_Monitor_Timeout -eq $null) {$DC_Monitor_Timeout = 10}
if ($DC_Standby_Timeout -eq $null) {$DC_Standby_Timeout = 20}
if ($AC_Close_Lid_Action -eq $null) {$AC_Close_Lid_Action = 0}
if ($DC_Close_Lid_Action -eq $null) {$DC_Close_Lid_Action = 1}
# Hibernate & Hiberboot settings: 0=disabled, 1=enabled
if ($Hibernate_Setting -eq $null) {$Hibernate_Setting = 0}
if ($Hiberboot_Setting -eq $null) {$Hiberboot_Setting = 0}
if ($SN -eq $null) {$SN = (Get-WmiObject win32_bios).SerialNumber}
# Cleanup related
if ($UnAttend -eq $null) {$UnAttend = "C:\Windows\System32\sysprep\unattend.xml"}
if ($FolderPath_Local_Standard_Software -eq $null) {$FolderPath_Local_Standard_Software = "C:\Setup\_Software_Collection\Standard_Software"}
if ($RunOnceKey -eq $null) {$RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"}

$FolderPath_Local_PublicDesktop         = "C:\Users\Public\Desktop"
$FolderPath_Local_Client_Public_Desktop = "C:\Setup\SCOPE-Image_Setup\Public Desktop"

# ALL the Imaging USB paths should be defined centrally here. Let the functions infer paths from the ImagingUSB object's attributes
class ImagingUSB {
    [string[]]$Drive_Letter = @()
    [string[]]$WinPE_Drive_Letter = @()
    [string]$Automated_Setup_Client_Folders
    [string]$Automated_Setup_Client_Configs
    [string]$Automated_Setup_RegistryBackup_Folder
    [string]$Automated_Setup_RegistryBackup_File
    [string]$Install_Software_Software_Configs
    [string]$Install_Software_ODT
    [string]$Install_Software_Profile_Software
    [string]$Install_Software_Standard_Software

    [boolean]Exists() {
        $this.Drive_Letter = @()
        # Get The Imaing USB Drive Letter
        foreach ($letter in (Get-PSDrive -PSProvider FileSystem).Name) {
            $TestPath = "$letter" + ":\PC_Setup"
            If (Test-Path $TestPath) {
                $this.Drive_Letter += "$letter" + ":"
            }
        }

        $this.WinPE_Drive_Letter = @()
        # Get The WinPE USB Drive Letter
        foreach ($letter in (Get-PSDrive -PSProvider FileSystem).Name) {
            $TestPath = "$letter" + ":\sources\WinPE-Menu.ps1"
            If (Test-Path $TestPath) {
                $this.WinPE_Drive_Letter += "$letter" + ":"
            }
        }
        
        # Set $Exists and USB related paths if it does exist
        If ($this.Drive_Letter.count -eq 0) {
            $this.RemovePaths()
            return $false
        } elseif ($this.Drive_Letter.count -gt 1) {
            Write-Host "Error: Multiple *:\PC_Setup paths have been detected" -ForegroundColor Red
            $this.RemovePaths()
            return $false
        } else {
            $this.SetPaths()
            return $true
        }
    }

    [void]hidden SetPaths() {
        $USB_Drive = $this.Drive_Letter
        $this.Automated_Setup_Client_Folders = "$USB_Drive\PC_Setup\Client_Folders"
        $this.Automated_Setup_Client_Configs = "$USB_Drive\PC_Setup\Client_Folders\_Client_Configs"
        $this.Automated_Setup_RegistryBackup_Folder = "$USB_Drive\sources\PC-Maintenance\1. Automated Setup\Setup\_Automated_Setup\_RegistryBackup"
        $this.Automated_Setup_RegistryBackup_File   = "$USB_Drive\sources\PC-Maintenance\1. Automated Setup\Setup\_Automated_Setup\_RegistryBackup\registry-backup020622.reg"
        $this.Install_Software_Software_Configs  = "$USB_Drive\PC_Setup\_Software_Collection\_Software_Configs"
        $this.Install_Software_ODT               = "$USB_Drive\PC_Setup\_Software_Collection\ODT"
        $this.Install_Software_Profile_Software  = "$USB_Drive\PC_Setup\_Software_Collection\Profile_Specific_Software"
        $this.Install_Software_Standard_Software = "$USB_Drive\PC_Setup\_Software_Collection\Standard_Software"
    }

    [void]hidden RemovePaths() {
        $USB_Drive = $this.Drive_Letter
        $this.Automated_Setup_Client_Folders = $null
        $this.Automated_Setup_Client_Configs = $null
        $this.Automated_Setup_RegistryBackup_Folder = $null
        $this.Automated_Setup_RegistryBackup_File   = $null
        $this.Install_Software_Software_Configs  = $null
        $this.Install_Software_ODT               = $null
        $this.Install_Software_Profile_Software  = $null
        $this.Install_Software_Standard_Software = $null
    }

    ImagingUSB() {
        $this.Exists()
    }
}



#############################################################
############## START OF SYSTEM DEFAULT SCRIPTS ##############
#############################################################
function Set-PCDefaultSettings {
    # -=[ Removed Appx Packages ]=-
    #Remove-SuggestedAppxPackages
    Write-Host "Removing unwanted AppxPackages " -ForegroundColor Yellow
    Start-Process powershell -ArgumentList '-command Remove-SuggestedAppxPackages' -WindowStyle Minimized

    # -=[ Set Clock ]=-
    Set-Clock -Target_TimeZone $Target_TimeZone

    # -=[ Set Power Settings ]=-
    Set-PowerSettings -AC_Monitor_Timeout $AC_Monitor_Timeout -AC_Standby_Timeout $AC_Standby_Timeout -DC_Monitor_Timeout $DC_Monitor_Timeout -DC_Standby_Timeout $DC_Standby_Timeout -AC_Close_Lid_Action $AC_Close_Lid_Action -DC_Close_Lid_Action $DC_Close_Lid_Action

    # -=[ Set Hibernate ]=-
    Toggle-Hibernate -Setting $Hibernate_Setting

    # -=[ Set Hiberboot ]=-
    Toggle-Hiberboot -Setting $Hiberboot_Setting

    # -=[ Set UAC ]=-
    Toggle-UAC

    # -=[ Enable Network Discovery and File & Printer Sharing ]=-
    Enable-FileSharing
} Export-ModuleMember -Function Set-PCDefaultSettings

function Remove-SuggestedAppxPackages {
    param(
        [Parameter(Mandatory = $false)]
        [switch] $Final
    )
    # Removed "-InitialOnly" switch as we want this to remove anything it finds every time it runs, not just initially

    $Step = "Remove Suggested Appx Packages"
    
    if ($Final) {
        Write-Host "`nRemoving Suggested Appx Packages"
    } else {
        Write-Host "Removing Suggested Appx Packages"
    }

    $AppsList = 'king.com.CandyCrushFriends',
    '5A894077.McAfeeSecurity',
    'C27EB4BA.DropboxOEM',
    'Disney.37853FC22B2CE',
    #'Microsoft.Windows.SecHealthUI', #Not sure if this is the "PC Health Check" thing or not but maybe not?

    # DELL BLOATWARE BELOW
    # 'CirqueCorporation.DellPointStick', #This one has something to do with the Trackpad, should be ok to leave. Would potentially cause problems if removed.
    'DellInc.DellCinemaGuide',
    'DellInc.DellCommandUpdate', #This one installs Drivers and Updates
    'DellInc.DellCustomerConnect',
    # 'DellInc.DellDigitalDelivery', #This one sometimes comes with software that was purchased from Dell for the PC
    'DellInc.DellOptimizer', #NOT SURE
    'DellInc.PartnerPromo', #NOT SURE
    'DellInc.DellPowerManager',
    # 'DellInc.DellSupportAssistforPCs', #This one installs Drivers and Updates
    'DellInc.DellUpdate',
    'DellInc.MyDell',
    # 'STMicroelectronicsMEMS.DellFreeFallDataProtection',
    'PortraitDisplays.DellCinemaColor',
    'PortraitDisplays.DellPremierColor',
    'RivetNetworks.KillerControlCenter',
    'ScreenovateTechnologies.DellMobileConnect',
    # DELL BLOATWARE ABOVE

    # HP BLOATWARE BELOW
    'AD2F1837.HPJumpStart',
    # 'AD2F1837.HPEasyClean', #Seems to add itself back...
    'AD2F1837.HPPCHardwareDiagnosticsWindows',
    'AD2F1837.HPPowerManager',
    # 'AD2F1837.HPPrivacySettings', #Seems to add itself back...
    'AD2F1837.HPProgrammableKey',
    'AD2F1837.HPQuickDrop',
    # 'AD2F1837.HPSupportAssistant',
    # 'AD2F1837.HPSystemInformation', #Seems to add itself back...
    'AD2F1837.HPWorkWell',
    'AD2F1837.myHP',
    # HP BLOATWARE ABOVE

    'king.com.FarmHeroesSaga',
    'Microsoft.BingWeather',
    # 'Microsoft.DesktopAppInstaller',
    'Microsoft.GetHelp',
    'Microsoft.Getstarted',
    'Microsoft.Messaging',
    'Microsoft.Microsoft3DViewer',
    'Microsoft.MicrosoftOfficeHub',
    'Microsoft.MicrosoftSolitaireCollection',
    'Microsoft.MixedReality.Portal',
    # 'Microsoft.MSPaint',
    'Microsoft.Office.OneNote',
    'Microsoft.OneConnect',
    'Microsoft.People',
    'Microsoft.Print3D',
    'Microsoft.RemoteDesktop',
    'Microsoft.ScreenSketch',
    'Microsoft.SkypeApp',
    # 'Microsoft.Windows.Cortana',   #doesnt uninstall?
    # 'Microsoft.Windows.Photos',
    'Microsoft.WindowsAlarms',
    'Microsoft.WindowsCamera',
    'microsoft.windowscommunicationsapps', #This is the mail app
    'Microsoft.WindowsFeedbackHub',
    # 'Microsoft.WindowsMaps',
    'Microsoft.WindowsSoundRecorder',
    # 'Microsoft.WindowsStore',
    'Microsoft.Whiteboard',
    #'Microsoft.Xbox.TCUI',
    'Microsoft.XboxApp',
    #'Microsoft.XboxGameCallableUI',
    #'Microsoft.XboxGameOverlay',
    #'Microsoft.XboxGamingOverlay',
    #'Microsoft.XboxIdentityProvider',
    #'Microsoft.XboxSpeechToTextOverlay',
    'Microsoft.YourPhone',
    'Microsoft.ZuneMusic',
    'Microsoft.ZuneVideo',
    'SpotifyAB.SpotifyMusic',
    'Tile.TileWindowsApplication'

    If ($Final) {
        $AppsList += ('DellInc.DellSupportAssistforPCs','AD2F1837.HPSupportAssistant')
        If (Test-Path "C:\Program Files (x86)\HP\HP Support Framework\HP Support Assistant.ico") {Remove-Item "C:\Program Files (x86)\HP\HP Support Framework\HP Support Assistant.ico"}
        If (Test-Path "C:\Program Files (x86)\Hewlett-Packard\HP Support Framework\HPSF.exe") {Remove-Item "C:\Program Files (x86)\Hewlett-Packard\HP Support Framework\HPSF.exe"}
    }

    ForEach ($App in $AppsList){
        $PackageFullName = (Get-AppxPackage $App).PackageFullName
        $ProPackageFullName = (Get-AppxProvisionedPackage -Online | where {$_.Displayname -eq $App}).PackageName
        if ($PackageFullName){
            Remove-AppxPackage -Package $PackageFullName -ErrorAction SilentlyContinue
        }
        if ($ProPackageFullName){
            Remove-AppxProvisionedPackage -Online -PackageName $ProPackageFullName -ErrorAction SilentlyContinue
        }
    }

    Write-Host "$Step`: " -NoNewline; Write-Host "Complete" -ForegroundColor Green
} Export-ModuleMember -Function Remove-SuggestedAppxPackages

function Set-Clock {
    param(
        [Parameter(Mandatory=$false)]
        [String] $Target_TimeZone = "Central Standard Time", #Default

        [Parameter(Mandatory=$false)]
        [switch] $Force
    )
    #Variables - edit as needed
    $Step = "Set Clock"
    #Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    
    #First checks to see if this action has been taken previously. Only takes action if no action previously. Don't use this switch if you want to force the action to occur
    If ((Test-Path "$StepStatus*") -and !($Force)) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Set-ClockTimeZone $Target_TimeZone
        Reset-Clock

        # Finished Message
        Write-Host "Timezone has been set to $Target_TimeZone & the clock has been reset" -ForeGroundColor Green
        New-Item $CompletionFile -ItemType File -Force | Out-Null
    }
} Export-ModuleMember -Function Set-Clock

function Set-ClockTimeZone {
    param(
        [Parameter(Mandatory=$false)]
        [String] $Target_TimeZone = "Central Standard Time" #Default
    )

    #Variables - Editable
    $Step = "Set Clock TimeZone"

    #Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    # Load setting from Client Config if available
    If ($global:ClientSettings.ClockTimeZone) {$Target_TimeZone = $global:ClientSettings.ClockTimeZone}

    # Get currently set Timezone
    $TimeZone = cmd.exe /c "tzutil /g"

    # Set the timezone if incorrect
    If ($TimeZone -eq $Target_TimeZone) {
        Write-Host "Timezone is set to " -NoNewline; Write-Host "$Target_TimeZone" -ForeGroundColor Green
    } else {
        Write-Host ""
        Write-Host "Timezone is set to " -NoNewline; Write-Host "$TimeZone" -ForeGroundColor Yellow
        Write-Host "Setting Timezone to " -NoNewline; Write-Host "$Target_TimeZone..." -ForeGroundColor Yellow
        tzutil /s "$Target_TimeZone"
        Write-Host "Timezone is now set to " -NoNewline; Write-Host "$Target_TimeZone" -ForeGroundColor Green
    }
    If ((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate\" -name Start -ErrorAction SilentlyContinue).Start -eq 3) {
        Write-Host "System is set to update timezone " -NoNewline; Write-Host "automatically" -ForeGroundColor Green
    } else {
        Write-Host "`nSystem is NOT set to update timezone automatically" -ForegroundColor Yellow
        Write-Host "Setting system to update timezone automatically" -ForegroundColor Yellow
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate\" -Name Start -Value 3 -Force
        Write-Host "System is now set to update timezone " -NoNewline; Write-Host "automatically" -ForeGroundColor Green
    }

    # If ClientSetting doesn't exist, update Client Config File
    If (!($global:ClientSettings.ClockTimeZone)) {
        Add-ClientSetting -Name "ClockTimeZone" -Value $Target_TimeZone
        Save-ClientSettings
    }
} Export-ModuleMember -Function Set-ClockTimeZone

function Reset-Clock {
    # Re-Register the time service
    Write-Host "Resetting clock..." -ForeGroundColor Yellow
    Start-Sleep 2
    if ((Get-Service -Name w32time).Status -eq "Running") {cmd.exe /c "net stop w32time" | Out-Null}
    cmd.exe /c "w32tm /unregister" | Out-Null
    cmd.exe /c "w32tm /register" | Out-Null
    cmd.exe /c "net start w32time" | Out-Null
    cmd.exe /c "w32tm /resync /nowait" | Out-Null
    Write-Host "Clock has been reset" -ForeGroundColor Green
} Export-ModuleMember -Function Reset-Clock

function Set-PowerSettings {
    param(
        [Parameter(Mandatory=$false)]
        $AC_Monitor_Timeout = 15, #Default

        [Parameter(Mandatory=$false)]
        $AC_Standby_Timeout = 0, #Default

        [Parameter(Mandatory=$false)]
        $DC_Monitor_Timeout = 10, #Default

        [Parameter(Mandatory=$false)]
        $DC_Standby_Timeout = 20, #Default

        # Close lid actions... 0=Do Nothing 1=Sleep 2=Hibernate 3=Shut Down
        [Parameter(Mandatory=$false)]
        $AC_Close_Lid_Action = 0, #Default

        [Parameter(Mandatory=$false)]
        $DC_Close_Lid_Action = 1, #Default

        [Parameter(Mandatory=$false)]
        [switch] $Force
    )
    #Variables - Editable
    $Step = "Set Power Settings"
    #Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    
    If ((Test-Path "$StepStatus*") -and !($Force)) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        # Load setting from Client Config if available
        If ($global:ClientSettings.pwr_ACMT) {
            $AC_Monitor_Timeout = $global:ClientSettings.pwr_ACMT
            $AC_Standby_Timeout = $global:ClientSettings.pwr_ACST
            $DC_Monitor_Timeout = $global:ClientSettings.pwr_DCMT
            $DC_Standby_Timeout = $global:ClientSettings.pwr_DCST
            $AC_Close_Lid_Action = $global:ClientSettings.pwr_ACCLA
            $DC_Close_Lid_Action = $global:ClientSettings.pwr_DCCLA
        }
        Write-Host ""
        Write-Host "Starting to $Step" -ForeGroundColor Yellow
        
        # Build commands
        $AC_Monitor_Timeout_cmd = "powercfg /change monitor-timeout-ac " + $AC_Monitor_Timeout
        $AC_Standby_Timeout_cmd = "powercfg /change standby-timeout-ac " + $AC_Standby_Timeout
        $DC_Monitor_Timeout_cmd = "powercfg /change monitor-timeout-dc " + $DC_Monitor_Timeout
        $DC_Standby_Timeout_cmd = "powercfg /change standby-timeout-dc " + $DC_Standby_Timeout
        $AC_Close_Lid_Action_cmd = "powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 " + $AC_Close_Lid_Action
        $DC_Close_Lid_Action_cmd = "powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 " + $DC_Close_Lid_Action
        # Execute commands
        Write-Host "PLUGGED IN" -ForegroundColor Yellow
        cmd.exe /c $AC_Monitor_Timeout_cmd
        Write-Host "'Turn off the display'" -NoNewline -ForegroundColor Cyan; Write-Host " set to " -NoNewline; Write-Host "$AC_Monitor_Timeout" -ForegroundColor Green
        cmd.exe /c $AC_Standby_Timeout_cmd
        Write-Host "'Put the computer to sleep'" -NoNewline -ForegroundColor Cyan; Write-Host " set to " -NoNewline; Write-Host "$AC_Standby_Timeout" -ForegroundColor Green
        cmd.exe /c $AC_Close_Lid_Action_cmd
        Write-Host "'When i close the lid'" -NoNewline -ForegroundColor Cyan; Write-Host " set to " -NoNewline; Write-Host "$AC_Close_Lid_Action" -ForegroundColor Green
        Write-Host "ON BATTERY" -ForegroundColor Yellow
        cmd.exe /c $DC_Monitor_Timeout_cmd
        Write-Host "'Turn off the display'" -NoNewline -ForegroundColor Cyan; Write-Host " set to " -NoNewline; Write-Host "$DC_Monitor_Timeout" -ForegroundColor Green
        cmd.exe /c $DC_Standby_Timeout_cmd
        Write-Host "'Put the computer to sleep'" -NoNewline -ForegroundColor Cyan; Write-Host " set to " -NoNewline; Write-Host "$DC_Standby_Timeout" -ForegroundColor Green
        cmd.exe /c $DC_Close_Lid_Action_cmd
        Write-Host "'When i close the lid'" -NoNewline -ForegroundColor Cyan; Write-Host " set to " -NoNewline; Write-Host "$DC_Close_Lid_Action" -ForegroundColor Green
        Write-Host "Close lid actions... 0=Do Nothing, 1=Sleep, 2=Hibernate, 3=Shut Down" -ForegroundColor DarkGray
    
        # If ClientSetting doesn't exist, update Client Config File
        If (!($global:ClientSettings.pwr_ACMT)) {
            Add-ClientSetting -Name "pwr_ACMT" -Value $AC_Monitor_Timeout
            Add-ClientSetting -Name "pwr_ACST" -Value $AC_Standby_Timeout
            Add-ClientSetting -Name "pwr_DCMT" -Value $DC_Monitor_Timeout
            Add-ClientSetting -Name "pwr_DCST" -Value $DC_Standby_Timeout
            Add-ClientSetting -Name "pwr_ACCLA" -Value $AC_Close_Lid_Action
            Add-ClientSetting -Name "pwr_DCCLA" -Value $DC_Close_Lid_Action
            Save-ClientSettings
        }
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Set-PowerSettings

function Toggle-Hibernate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]  $Setting = 0 #Default
    )
    #Variables - edit as needed
    $Step = "Toggle Hibernate"
    #Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    # Load setting from Client Config if available
    If ($global:ClientSettings.Hibernate) {$Setting = $global:ClientSettings.Hibernate}

    If ($Setting = 0) {Disable-Hibernate} else {Enable-Hibernate}

    # If ClientSetting doesn't exist, update Client Config File
    If (!($global:ClientSettings.Hibernate)) {
        Add-ClientSetting -Name "Hibernate" -Value $Setting
        Save-ClientSettings
    }

    New-Item $CompletionFile -ItemType File -Force | Out-Null
} Export-ModuleMember -Function Toggle-Hibernate

function Enable-Hibernate {
    if ((Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power -name HibernateEnabled -ErrorAction SilentlyContinue).HibernateEnabled -eq 0) {
        Write-Host ""
        Write-Host "Hibernate is " -NoNewline; Write-Host "disabled" -ForeGroundColor Red
        Write-Host "Turning Hibernate on..." -ForeGroundColor Yellow
        cmd.exe /c "powercfg -h on"
    }
    Write-Host "Hibernate is " -NoNewline; Write-Host "enabled" -ForeGroundColor Green
} Export-ModuleMember -Function Enable-Hibernate

function Disable-Hibernate {
    if ((Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power -name HibernateEnabled -ErrorAction SilentlyContinue).HibernateEnabled -eq 1) {
        Write-Host ""
        Write-Host "Hibernate is " -NoNewline; Write-Host "enabled" -ForeGroundColor Red
        Write-Host "Turning Hibernate off..." -ForeGroundColor Yellow
        cmd.exe /c "powercfg -h off"
    }
    Write-Host "Hibernate is " -NoNewline; Write-Host "disabled" -ForeGroundColor Green
} Export-ModuleMember -Function Disable-Hibernate

function Toggle-Hiberboot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]  $Setting = 0 #Default
    )

    #Variables - edit as needed
    $Step = "Toggle Hiberboot"
    #Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    # Load setting from Client Config if available
    If ($global:ClientSettings.Hiberboot) {$Setting = $global:ClientSettings.Hiberboot}

    If ($Setting = 0) {Disable-Hiberboot} else {Enable-Hiberboot}

    # If ClientSetting doesn't exist, update Client Config File
    If (!($global:ClientSettings.Hiberboot)) {
        Add-ClientSetting -Name "Hiberboot" -Value $Setting
        Save-ClientSettings
    }

    New-Item $CompletionFile -ItemType File -Force | Out-Null
} Export-ModuleMember -Function Toggle-Hiberboot

function Enable-Hiberboot {
    if ((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled).HiberbootEnabled -eq 0) {
        Write-Host ""
        Write-Host "Hiberboot is " -NoNewline; Write-Host "disabled" -ForeGroundColor Red
        Write-Host "Turning Hiberboot on..." -ForeGroundColor Yellow
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled -Value 1 -Force
    }
    Write-Host "Hiberboot is " -NoNewline; Write-Host "enabled" -ForeGroundColor Green
} Export-ModuleMember -Function Enable-Hiberboot

function Disable-Hiberboot {
    if ((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled).HiberbootEnabled -eq 1) {
        Write-Host ""
        Write-Host "Hiberboot is " -NoNewline; Write-Host "enabled" -ForeGroundColor Red
        Write-Host "Turning Hiberboot off..." -ForeGroundColor Yellow
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled -Value 0 -Force
    }
    Write-Host "Hiberboot is " -NoNewline; Write-Host "disabled" -ForeGroundColor Green
} Export-ModuleMember -Function Disable-Hiberboot

function Toggle-UAC {
    #Variables - edit as needed
    $Step = "Set UAC"
    #Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $SkippedFile = "$StepStatus-Skipped.txt"
    $CompletionFile = "$StepStatus-Completed.txt"

    # Load setting from Client Config if available
    $Setting = $null; If ($global:ClientSettings.UAC -ne $null) {$Setting = $global:ClientSettings.UAC}

    If (Test-Path "$StepStatus*") {
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        If ($Setting -eq "Up") {
            TurnUp-UAC
        } elseif ($Setting -eq "Down") {
            TurnDown-UAC
        } elseif ($Setting -eq "Skip") {
            If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
        } else {
            DO {
                Write-Host ""
                Write-Host "-=[ $Step ]=-" -ForegroundColor Yellow
                Write-Host "What UAC level should be set?"
                Write-Host "1. Turn UAC UP all the way"
                Write-Host "2. Turn UAC DOWN all the way"
                Write-Host "3. Leave as default"
                [int]$choice = Read-Host -Prompt "Enter a number, 1 through 3"
            } UNTIL (($choice -ge 1) -and ($choice -le 3))
            # Act on choice
            switch ($choice) {
                1 {
                    # Update Client Config File with choice
                    Add-ClientSetting -Name UAC -Value "Up"
                    Save-ClientSettings
                    TurnUp-UAC
                    New-Item $CompletionFile -ItemType File -Force | Out-Null
                }
                2 {
                    # Update Client Config File with choice
                    Add-ClientSetting -Name UAC -Value "Down"
                    Save-ClientSettings
                    TurnDown-UAC
                    New-Item $CompletionFile -ItemType File -Force | Out-Null
                }
                3 {
                    # Update Client Config File with choice
                    Add-ClientSetting -Name UAC -Value "Skip"
                    Save-ClientSettings
                    If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
                    New-Item $SkippedFile -ItemType File -Force | Out-Null
                }
            }
        }
    }
} Export-ModuleMember -Function Toggle-UAC

function TurnUp-UAC {
    Write-Host "Turning Hiberboot up..." -ForeGroundColor Yellow
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA -Value 1 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name ConsentPromptBehaviorAdmin -Value 2 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name PromptOnSecureDesktop -Value 1 -Force
    Write-Host "UAC has been turned " -NoNewline; Write-Host "UP" -ForeGroundColor Green
} Export-ModuleMember -Function TurnUp-UAC

function TurnDown-UAC {
    Write-Host "Turning Hiberboot down..." -ForeGroundColor Yellow
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name ConsentPromptBehaviorAdmin -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name PromptOnSecureDesktop -Value 0 -Force
    Write-Host "UAC has been turned" -NoNewline; Write-Host "DOWN" -ForeGroundColor Green
} Export-ModuleMember -Function TurnDown-UAC

function Enable-FileSharing {
    #Variables - edit as needed
    $Step = "Enable Network Discover and File & Printer Sharing settings"
    #Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Write-Host ""
        Write-Host "Network Discovery and File & Printer Sharing settings have not been set" -ForeGroundColor Yellow
        Write-Host "Configuring Network Discovery and File & Printer Sharing settings now..." -ForeGroundColor Yellow
        cmd.exe /c 'REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f' | Out-Null
        cmd.exe /c 'netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes' | Out-Null
        cmd.exe /c 'netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes' | Out-Null
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host "$Step`: " -NoNewline; Write-Host " Completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Enable-FileSharing
###########################################################
############## END OF SYSTEM DEFAULT SCRIPTS ##############
###########################################################

##########################################################
############## START Of Local Admin Scripts ##############
##########################################################
function Setup-LocalAdmin {
    # -=[ Set Local Admin ]=-
    Set-LocalAdmin
    
    # -=[ Enable Auto-Logon ]=-
    Enable-AutoLogon -LocalAdmin

    # -=[ Remove 'User' Account ]=-
    Remove-UserAccount
} Export-ModuleMember -Function Setup-LocalAdmin

function Set-LocalAdmin {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )
    # Variables - edit as needed
    $Step = "Set Local Admin Account"
    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If ((Test-Path "$StepStatus*") -and !($Force)) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Write-Host "`n-=[ $Step ]=-" -ForegroundColor Yellow

        # Get LocalAdminName
        $choice = $null
        If ($Global:ClientSettings.LocalAdminName -and $Global:ClientSettings.LocalAdminPassword) {
            Write-Host "Local Administrator Name obtained from client config: "$Global:ClientSettings.LocalAdminName -ForegroundColor Green
            Write-Host "Local Administrator Password obtained from client config: "$Global:ClientSettings.LocalAdminPassword -ForegroundColor Green
        } else {
            DO {
                Write-Host "Provide the credentials for the local administrator account."
                Write-Host "If you haven't created it yet, it will be created for you."
                Write-Host "If you are already signed into the desired local administrator account, please enter the credentials anyway. (NOTE: In this case, make sure you enter the credentials correctly!)" -ForegroundColor Yellow
                $Credentials = Get-Credential
            } UNTIL ($Credentials -ne $null)
            Add-ClientSetting -Name LocalAdminName -Value $Credentials.UserName
            Add-ClientSetting -Name LocalAdminPassword -Value ($Credentials.Password | ConvertFrom-SecureString -Key (Get-Content -Path $FilePath_Local_Automated_Setup_RegistryBackup))
        }
        
        # Configure Local Admin Account
        $LocalAdminName = $Global:ClientSettings.LocalAdminName
        $LocalAdminPassword = ($Global:ClientSettings.LocalAdminPassword | ConvertTo-SecureString -Key (Get-Content -Path $FilePath_Local_Automated_Setup_RegistryBackup))
        If ($LocalAdminName -eq "Administrator") {
            #$command = "net user Administrator $LocalAdminPassword"
            #cmd.exe /c $command # Reset local 'Administrator' account since it already exists by default
            Set-LocalUser -Name $LocalAdminName -Password $LocalAdminPassword -AccountNeverExpires
            $command = "net user Administrator /active:yes"
            cmd.exe /c $command # Enable local 'Administrator' account since it is disabled by default
        } else {
            #$command = "net user '$LocalAdminName' '$LocalAdminPassword' /add"
            #cmd.exe /c $command # Add user with specified password
            New-LocalUser -Name $LocalAdminName -Password $LocalAdminPassword -AccountNeverExpires
            #$command = "net localgroup administrators '$LocalAdminName' /add"
            #cmd.exe /c $command # Add user to 'Administrators' local group
            Add-LocalGroupMember -Group "Administrators" -Member $LocalAdminName
        }
        #$command = "wmic useraccount where Name='$LocalAdminName' set PasswordExpires=false"
        #cmd.exe /c $command # Set password to never expire
        
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
    }   
} Export-ModuleMember -Function Set-LocalAdmin

function Enable-AutoLogon {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        [Parameter(
            Mandatory=$false,
            ParameterSetName = 'A'
        )]
        $Username = $null, #Default

        [Parameter(
            Mandatory=$false,
            ParameterSetName = 'A'
        )]
        $Password = $null, #Default

        [Parameter(Mandatory = $false)]
        [switch] $Force,

        [Parameter(Mandatory = $false)]
        [switch] $LocalAdmin,

        [Parameter(Mandatory = $false)]
        [switch] $DomainAdmin
    )
    # Variables - edit as needed
    $Step = "Enable Auto-Logon"
    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If ((Test-Path "$StepStatus*") -and !($Force)) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Write-Host "`n-=[ $Step ]=-" -ForegroundColor Yellow
        Set-ItemProperty -Path $WinLogonKey -Name DefaultDomainName -Value ".\" -Force
        If ($LocalAdmin) {
            # Load settings from Client Config if available
            If ($global:ClientSettings.LocalAdminName) {
                $username = $global:ClientSettings.LocalAdminName
                $password = ($global:ClientSettings.LocalAdminPassword | ConvertTo-SecureString -Key (Get-Content -Path $FilePath_Local_Automated_Setup_RegistryBackup))
                $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
            }
        } elseif ($DomainAdmin) {
            # Load settings from Client Config if available
            If ($global:ClientSettings.DomainAdminName) {
                $username = $global:ClientSettings.DomainAdminName
                $password = ($global:ClientSettings.DomainAdminPassword | ConvertTo-SecureString -Key (Get-Content -Path $FilePath_Local_Automated_Setup_RegistryBackup))
                $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
                Set-ItemProperty -Path $WinLogonKey -Name DefaultDomainName -Value (Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem).Domain -Force
            }
        } else {
            DO {
                Write-Host ""
                Write-Host "Are you configuring a local or domain account for Auto-Logon?"
                Write-Host "1. Local"
                Write-Host "2. Domain"
                $choice = Read-Host -Prompt "Enter a number, 1 through 2"
            } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
            Write-Host ""
            If ($choice -eq 1) {
                Write-Host "-Provide the credentials for the local account that you want to configure for Auto-Logon"
                Write-Host "-If you haven't created the account yet, it will be created for you"
                Write-Host "-If the account already exists, please ender the credentials anyway"
                Write-Host " (NOT: In this case, make sure you enter the credentials correctly or you will need to run this script again!)"
                Write-Host ""
                Write-Host "============================================================================"
                cmd.exe /c "NET USER"
                Write-Host "============================================================================"
                Write-Host ""
                $username = Read-Host -Prompt "Enter the local username. Example: Administrator"
                If ($username -eq "administrator") {$username = "Administrator"}
                $password = Read-Host -Prompt "Enter the password for this account. Example: P@ssw0rd1!" -AsSecureString
                If (Get-LocalUser -Name $username) {
                    Write-Host "$username account already exists"
                } else {
                    Write-Host "$username account does not exist, creating it now"
                    New-LocalUser -Name $username -Password $password -PasswordNeverExpires
                }
                DO {
                    Write-Host "Should this account be set as a local administrator?"
                    Write-Host "1. Yes"
                    Write-Host "2. No"
                    $choice = Read-Host -Prompt "Enter a number, 1 through 2"
                } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
                If ($choice -eq 1) {
                    Add-LocalGroupMember -Group "Administrators" -Member $username
                    Write-Host "-Account has been set as a local administrator"
                } else {
                    Write-Host "-Account has NOT been set as a local administrator"
                }
            } else {
                Write-Host "-Provide the credentials for the domain account that you want to configure for Auto-Logon"
                $username = Read-Host -Prompt "Enter the domain username. Example: DomainAdmin"
                $password = Read-Host -Prompt "Enter the password for this account. Example: P@ssw0rd1!"
                Set-ItemProperty -Path $WinLogonKey -Name DefaultDomainName -Value (Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem).Domain -Force
            }
        }
        Set-ItemProperty -Path $WinLogonKey -Name DefaultUserName -Value $username -Force
        Set-ItemProperty -Path $WinLogonKey -Name DefaultPassword -Value $password -Force
        Set-ItemProperty -Path $WinLogonKey -Name AutoAdminLogon -Value "1"
        Set-ItemProperty -Path $WinLogonKey -Name ForceAutoLogon -Value "1"
        
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
        Ask-Logoff -Force
    }   
} Export-ModuleMember -Function Enable-AutoLogon

function Ask-Logoff {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    $choice = $null
    If ($Force) {
        $choice = 1
    } else {
        DO {
            Write-Host ""
            Write-Host "-=[ Relog Choice ]=-" -ForegroundColor Yellow
            Write-Host "Do you want relog now?"
            Write-Host "1. Yes"
            Write-Host "2. No"
            $choice = Read-Host -Prompt "Enter a number, 1 or 2"
        } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
        Write-Host ""
    }
    switch ($choice) {
        1 {
            Write-Host "Relogging in 5 seconds"
            Start-Sleep 5
            cmd.exe /c "logoff"
            Pause
        }
        2 {
            Write-Host "Not relogging now..."
        }
    }
} Export-ModuleMember -Function Ask-Logoff

function Remove-UserAccount {
<#
.Notes
    -Used a function for this rather than just a single 'Remove-LocalUser' line, so that it would simply additionally report when it removes the user or if it already has
    -No '-InitialOnly' flag needed in this case
    -This is a very simple function. Should run the same regardless of client config or if building a single PC or an Image
#>
    #Variables - edit as needed
    $Step = "Remove User Account"

    #Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        If (Get-LocalUser -Name 'User' -ErrorAction SilentlyContinue) {
            Write-Host ""
            Write-Host "Removing 'User' Account"
            Remove-LocalUser -Name User
            Start-Sleep 3
            Remove-Item -Path "C:\Users\User" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
            New-Item $CompletionFile -ItemType File -Force | Out-Null
            Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "There is no local account called 'user', and it hasn't already been removed..." -ForegroundColor Yellow
            Write-Host "If you created the initial user under a different username, delete the user and the user profile from this pc now" -ForegroundColor Red
            Write-Host "In the future, create the initial user with username 'user'. Then the account will be automatically removed at this step." -ForegroundColor Red
            Write-Host ""
        }
    }
} Export-ModuleMember -Function Remove-UserAccount
########################################################
############## END Of Local Admin Scripts ##############
########################################################

######################################################
############## START Of Profile Scripts ##############
######################################################
function Set-ProfileDefaultSettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $AdminProfile
    )

    Show-FileExtensions
    If ($AdminProfile) {Show-HiddenObjects}
} Export-ModuleMember -Function Set-ProfileDefaultSettings

function Show-FileExtensions {
    # 0=Show 1=Hide
    $Step = "Show File Extensions"
    $Key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if ((Get-ItemProperty -Path $Key -Name HideFileExt -ErrorAction SilentlyContinue).HideFileExt -ne 0) {
        Write-Host ""
        Write-Host "$Step is " -NoNewline; Write-Host "disabled" -ForeGroundColor Red
        Write-Host "Enabling " -ForeGroundColor Yellow -NoNewline; Write-Host "$Step..."
        Set-ItemProperty -Path $Key -Name HideFileExt -Value 0 -Force
        Write-Host "$Step is " -NoNewline; Write-Host "enabled" -ForeGroundColor Green
    } else {
        Write-Host "$Step is " -NoNewline; Write-Host "enabled" -ForeGroundColor Green
    }
} Export-ModuleMember -Function Show-HiddenObjects

function Show-HiddenObjects {
    # 1=Show 2=Hide
    $Step = "Show Hidden Objects"
    $Key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if ((Get-ItemProperty -Path $Key -name Hidden -ErrorAction SilentlyContinue).Hidden -ne 1) {
        Write-Host ""
        Write-Host "$Step is " -NoNewline; Write-Host "disabled" -ForeGroundColor Red
        Write-Host "Enabling " -ForeGroundColor Yellow -NoNewline; Write-Host "$Step..."
        Set-ItemProperty -Path $Key -Name Hidden -Value 1 -Force
        Write-Host "$Step is " -NoNewline; Write-Host "enabled" -ForeGroundColor Green
    } else {
        Write-Host "$Step is " -NoNewline; Write-Host "enabled" -ForeGroundColor Green
    }
} Export-ModuleMember -Function Show-HiddenObjects
####################################################
############## END Of Profile Scripts ##############
####################################################

###########################################################
############## START Of Configure PC Scripts ##############
###########################################################
function Rename-PC {
    [CmdletBinding(DefaultParameterSetName="A")]
    param(
        [Parameter(Mandatory = $false)]
        [string] $NewName,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'A'
        )]
        [switch] $PreImage,
        
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'B'
        )]
        [switch] $PostImage,
        
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    If ($PreImage) {$Step = "Rename This PC"}
    If ($PostImage) {$Step = "Rename This PC - Post-Image"}

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SN = (Get-WmiObject win32_bios).SerialNumber
    
    If ((Test-Path "$StepStatus*") -and !($Force)) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        If ($PreImage) {
            If ($global:ClientSettings.SetupType -eq "BuildImage") {
                # Load setting from Client Config if available
                If ($global:ClientSettings.ImageName) {
                    $NewName = $global:ClientSettings.ImageName
                } else {
                    Write-Host ""
                    Write-Host "Rename the image at this time" -ForegroundColor Red
                    Write-Host "Image name suggestion: <Client Abbreviation>-Image" -ForegroundColor DarkYellow
                    Write-Host "Example: ATI-Image" -ForegroundColor DarkYellow
                    $NewName = Read-Host -Prompt "Please enter desired computer name, and then hit enter. The computer will be renamed and then rebooted."
                    Add-ClientSetting -Name "ImageName" -Value $NewName
                    Save-ClientSettings
                }
            } ElseIf (($global:ClientSettings.SetupType -eq "SingleSetup") -or ($Force)) {
                Write-Host ""
                Write-Host "Rename the computer at this time" -ForegroundColor Red
                Write-Host "Make sure to label the computer with it's name, if possible" -ForegroundColor DarkYellow
                Write-Host "NOTE: Serial Number is $SN"
                $NewName = Read-Host -Prompt "Please enter desired computer name, and then hit enter. The computer will be renamed and then rebooted."
            }
            Rename-Computer -NewName $NewName -Force -ErrorAction Continue
        }
        If ($PostImage) {
            If ($global:ClientSettings.SetupType -eq "BuildImage") {
                # Get New PC Name
                Write-Host "`nPlease manually enter a new name for the computer at this time." -ForegroundColor Yellow
                Write-Host "Example: "$global:ClientSettings.Naming_Convention -ForegroundColor Yellow
                Write-Host "Example: "$global:ClientSettings.PC_Name_Example -ForegroundColor Yellow
                Write-Host "NOTE: Serial Number is $SN"
                # Prompt for computer name
                $NewComputerName = Read-Host -Prompt "Please enter desired computer name then hit enter."
                Write-Host "`nHit any key and the computer will be renamed to $NewComputerName, then rebooted." -ForegroundColor Yellow
                Write-Host "Make sure to label the PC!" -ForegroundColor Red
                PAUSE
                Rename-Computer -NewName $NewComputerName -Force -ErrorAction Continue
            } ElseIf ($global:ClientSettings.SetupType -eq "SingleSetup") {
                Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
            } ElseIf ($Force) {
                Write-Host ""
                Write-Host "Rename the computer at this time" -ForegroundColor Red
                Write-Host "Make sure to label the computer with it's name, if possible" -ForegroundColor DarkYellow
                Write-Host "NOTE: Serial Number is $SN"
                $NewName = Read-Host -Prompt "Please enter desired computer name, and then hit enter. The computer will be renamed and then rebooted."
                Rename-Computer -NewName $NewName -Force -ErrorAction Continue
            }
        }
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host ""
        Write-Host "$Step has been completed" -ForegroundColor Green
        Write-Host "Rebooting in 3..."
        Start-Sleep 1
        Write-Host "Rebooting in 2..."
        Start-Sleep 1
        Write-Host "Rebooting in 1..."
        Start-Sleep 1
        Restart-Computer -Force -ErrorAction Continue
        Pause
    }
} Export-ModuleMember -Function Rename-PC

function Get-DomainJoinInfo {
    # Variables - edit as needed
    $Step = "Get Domain Join Info"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
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
                Write-Host ""
                Write-Host "-=[ $Step ]=-" -ForegroundColor Yellow
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
                If (!($global:ClientSettings.DomainJoin)) {
                    Add-ClientSetting -Name "DomainJoin" -Value $choice
                    Save-ClientSettings
                }
                
                # Get NETBIOS
                $choice = $null
                If ($global:ClientSettings.NETBIOS) {
                    Write-Host "NETBIOS obtained from client config: "$global:ClientSettings.NETBIOS -ForegroundColor Green
                } else {
                    DO {
                        Write-Host ""
                        Write-Host "What is the NETBIOS Domain name?" -ForegroundColor Yellow
                        Write-Host "Example: ATI"
                        $choice = Read-Host -Prompt "Enter the NETBIOS Domain name"
                    } UNTIL ($choice -ne $null)
                    Add-ClientSetting -Name NETBIOS -Value $choice
                    Save-ClientSettings
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
                    Add-ClientSetting -Name DNS_Domain_Name -Value $choice
                    Save-ClientSettings
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
                    Add-ClientSetting -Name Domain_Admin_Username -Value $choice
                    Save-ClientSettings
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
                        Add-ClientSetting -Name Naming_Convention -Value $choice
                        Save-ClientSettings
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
                        Add-ClientSetting -Name PC_Name_Example -Value $choice
                        Save-ClientSettings
                    }
                }
                # Mark this section as completed
                New-Item $CompletionFile -ItemType File -Force | Out-Null
                Write-Host "$Step has been completed" -ForegroundColor Green
            } # End of Switch(1)
            2 {
                # Save the fact that we do NOT want to join the domain
                If (!($global:ClientSettings.DomainJoin)) {
                    Add-ClientSetting -Name "DomainJoin" -Value $choice
                    Save-ClientSettings
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
                        Add-ClientSetting -Name Naming_Convention -Value $choice
                        Save-ClientSettings
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
                        Add-ClientSetting -Name PC_Name_Example -Value $choice
                        Save-ClientSettings
                    }
                    Write-Host "$Step has been completed" -ForegroundColor Green
                }
                New-Item $SkippedFile -ItemType File -Force | Out-Null
                Write-Host ""
            } # End of Switch(2)
        } # End of Switch($choice)
    }
} Export-ModuleMember -Function Get-DomainJoinInfo

function Sign-Into_VPN {
    # Variables - edit as needed
    $Step = "Sign Into VPN"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        DO {
            Write-Host ""
            Write-Host "-=[ $Step ]=-" -ForegroundColor Yellow
            # -=[ If SingleSetup ]=-
            If ($global:ClientSettings.SetupType -eq "SingleSetup") {
                Write-Host "We are about to join the PC to the domain. If required, please take a minute to connect to the VPN client." -ForeGroundColor Red
            }
            # -=[ If Building Image ]=-
            If ($global:ClientSettings.SetupType -eq "BuildImage.txt") {
                Write-Host "Please take a minute to connect to the VPN client. This way the login information will be cached and in the image and we know it will work when we need to join to the domain later" -ForeGroundColor Yellow
            }
            $choice = Read-Host -Prompt "Type in 'continue' move on to the next step"
        } UNTIL ($choice -eq "continue")
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host "$Step has been completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Sign-Into_VPN

function Set-DefaultApps {
    # Variables - edit as needed
    $Step = "Set Default Apps"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Write-Host ""
        Write-Host "Set the default applications before continuing... Once you hit any key, this script will then set default app associations for all future users." -ForegroundColor Yellow
        Pause
        cmd.exe /c "dism /online /export-defaultappassociations:C:\Setup\appassoc.xml" | Out-Null
        cmd.exe /c "dism /online /import-defaultappassociations:C:\Setup\appassoc.xml" | Out-Null
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host "Default apps have been set" -ForeGroundColor Green
    }
} Export-ModuleMember -Function Set-DefaultApps

function CheckPoint-Client_WiFi {
    # Variables - edit as needed
    $Step = "Input Client WiFi"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        Write-Host ""
        Write-Host "-=[ $Step ]=-" -ForegroundColor Yellow
        Write-Host "Please take a minute to input the client's wifi info into the computer now" -ForegroundColor Cyan
        Write-Host "  Start > Settings > Network & Internet > Wi-Fi > Manage known networks > Add a new network"
        PAUSE
        Write-Host "$Step - Marked As Completed" -ForeGroundColor Green
        New-Item $SkippedFile -ItemType File -Force | Out-Null
    }
} Export-ModuleMember -Function CheckPoint-Client_WiFi

function CheckPoint-Public_Desktop {
    # Variables - edit as needed
    $Step = "Transfer Public Desktop Items"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Write-Host "`n-=[ $Step ]=-" -ForegroundColor Yellow
        Write-Host "!!WARNING!!" -ForegroundColor Yellow
        Write-Host "We are about to copy items"
        Write-Host "  from:" -NoNewline -ForegroundColor Cyan; Write-Host " $FolderPath_Local_Client_Public_Desktop"
        Write-Host "  to:" -NoNewline -ForegroundColor Cyan; Write-Host " $FolderPath_Local_PublicDesktop"
        Write-Host "`nPlease take a moment to populate the client's " -NoNewline; Write-Host "$FolderPath_Local_Client_Public_Desktop " -ForegroundColor Cyan -NoNewline; Write-Host "folder, before continuing..."
        Write-Host "(Such as RDP links, Browser links, VPN Connection Guides, etc...)"
        PAUSE
        If (($items = Get-ChildItem $FolderPath_Local_Client_Public_Desktop).count -gt 0) {Copy-Item -Path (Get-ChildItem $FolderPath_Local_Client_Public_Desktop).FullName -Destination "$FolderPath_Local_PublicDesktop" -Recurse}
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host "$Step - Marked As Completed" -ForeGroundColor Green
    }
} Export-ModuleMember -Function CheckPoint-Public_Desktop

function CheckPoint-CreateScansFolder {
    # Variables - edit as needed
    $Step = "Create Scans Folder"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"

    
    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        # Determine action to take
        DO {
            # Load setting from Client Config if available
            If ($global:ClientSettings.ScansFolder) {
                $choice = $global:ClientSettings.ScansFolder
            } else {
            # Otherwise ask tech
                Write-Host "`n-=[ $Step ]=-" -ForegroundColor DarkGray
                Write-Host "Do you want to create a Scans folder?"
                Write-Host "1. Yes"
                Write-Host "2. No" 
                [int]$choice = Read-Host -Prompt "Enter a number, 1 or 2"
            }
        } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
        # Record choice, if needed
        If (!($global:ClientSettings.ScansFolder)) {
            Add-ClientSetting -Name "ScansFolder" -Value $choice
            Save-ClientSettings
        }
        # Take action based on choice
        switch ($choice) {
            1 {
                # Get Scans Foldername
                $choice = $null
                If ($global:ClientSettings.ScansFolderName) {
                    Write-Host "Scans folder name obtained from client config: "$global:ClientSettings.ScansFolderName -ForegroundColor Green
                } else {
                    DO {
                        Write-Host ""
                        Write-Host "What is the desired name for the Scans folder?" -ForegroundColor Yellow
                        Write-Host "Example: Scans"
                        [string]$choice = Read-Host -Prompt "Enter the Scans folder name"
                    } UNTIL ($choice -ne $null)
                    Add-ClientSetting -Name ScansFolderName -Value $choice
                }


                # Get Scanner account credentials
                $choice = $null
                If ($global:ClientSettings.ScannerAccount -and $global:ClientSettings.ScannerAccountPassword) {
                    Write-Host "Scanner account name obtained from client config: "$global:ClientSettings.ScannerAccount -ForegroundColor Green
                    Write-Host "Scanner account password obtained from client config: "$global:ClientSettings.ScannerAccountPassword -ForegroundColor Green
                } else {
                    DO {
                        Write-Host "Provide the credentials for the Scanner account."
                        $Credentials = Get-Credential
                    } UNTIL (($Credentials.UserName -ne $null) -and ($Credentials.Password -ne $null))
                    Add-ClientSetting -Name ScannerAccount -Value $Credentials.UserName
                    Add-ClientSetting -Name ScannerAccountPassword -Value ($Credentials.Password | ConvertFrom-SecureString -Key (Get-Content -Path $FilePath_Local_Automated_Setup_RegistryBackup))
                }

                # Configure Scanner Account
                $ScannerAccountName = $global:ClientSettings.ScannerAccount
                $ScannerAccountPassword = ($global:ClientSettings.ScannerAccountPassword | ConvertTo-SecureString -Key (Get-Content -Path $FilePath_Local_Automated_Setup_RegistryBackup))
                New-LocalUser -Name $ScannerAccountName -Password $ScannerAccountPassword -AccountNeverExpires
                Write-Host "Scanner account created" -ForegroundColor Green

                # Make "Scans" folder
                $ScansFolderName = $global:ClientSettings.ScansFolderName
                New-Item -Path "C:\$ScansFolderName" -ItemType Directory -Force
                Write-Host "C:\$ScansFolderName created" -ForegroundColor Green

                # Share the "Scans" folder to the scanner account
                New-SmbShare -Path "C:\$ScansFolderName" -Name "$ScansFolderName" -ChangeAccess "$ScannerAccountName" -InformationAction SilentlyContinue | Out-Null
                Write-Host "Scans folder shared" -ForegroundColor Green
                Write-Host "Scanner account given share access to Scans folder" -ForegroundColor Green
            
                # Create a shortcut on the public desktop for the scans folder
                $TargetFolder = "C:\$ScansFolderName"
                $ShortcutFile = "C:\Users\Public\Desktop\$ScansFolderName.lnk"
                If (!(Test-Path $ShortcutFile)) {
                    $WScriptShell = New-Object -ComObject WScript.Shell
                    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
                    $Shortcut.TargetPath = $TargetFolder
                    $Shortcut.Save()
                }
                Write-Host "shortcut to scans folder created and placed on public desktop" -ForegroundColor Green

                # Mark this section as completed
                New-Item $CompletionFile -ItemType File -Force | Out-Null
                Write-Host "$Step - Marked As Completed" -ForeGroundColor Green
            } # End of Switch(1)
            2 {
                Write-Host "$Step has been skipped" -ForegroundColor Green
                
                New-Item $SkippedFile -ItemType File -Force | Out-Null
                Write-Host ""
            } # End of Switch(2)
        } # End of Switch($choice)
    }
} Export-ModuleMember -Function CheckPoint-CreateScansFolder

function CheckPoint-Client_AV {
    # Variables - edit as needed
    $Step = "Install AV agent"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Write-Host "`nIf needed, Install AV agent"
        PAUSE
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host "$Step - Marked As Completed" -ForeGroundColor Green
    }
} Export-ModuleMember -Function CheckPoint-Client_AV

function CheckPoint-Bitlocker_Device {
    # Variables - edit as needed
    $Step = "Bitlocker Device"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Write-Host ""
        Write-Host "If needed, Bitlocker Device"
        PAUSE
        New-Item $CompletionFile -ItemType File -Force | Out-Null
        Write-Host "$Step - Marked As Completed" -ForeGroundColor Green
    }
} Export-ModuleMember -Function CheckPoint-Bitlocker_Device

function Transfer-RMM_Agent {
    # Variables - edit as needed
    $Step = "Transfer RMM Agent"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"

    If (Test-Path "$StepStatus*") {
        # If already completed or skipped, report so
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        # See if installer is already present
        If (Test-Path "$FolderPath_Local_Setup\*Agent_Install*.exe") {
            Write-Host "`nAutomate Agent Installer " -NoNewline; Write-Host "found in $FolderPath_Local_Setup" -ForegroundColor Green
            New-Item $CompletionFile -ItemType File -Force | Out-Null
        } else {
        # Ask tech to move it there
            DO {
                Write-Host "`n-=[ Automate Agent Installer Choice ]=-" -ForegroundColor Yellow
                Write-Host "Are you going to place the client agent under C:\Setup?"
                Write-Host "1. Yes"
                Write-Host "2. No"
                Write-Host "NOTE: If you place the Automate Agent under $FolderPath_Local_Setup then it will automatically install on an imaged PC" -ForegroundColor DarkCyan
                $choice = Read-Host -Prompt "Enter a number, 1 or 2"
                Write-Host ""
            } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
            switch ($choice) {
                1 {
                    DO {
                        Write-Host "Please place the Automate Agent Installer under C:\Setup and then hit enter when ready" -ForegroundColor Yellow
                        Write-Host "Make sure to place the .exe installer, not the .msi installer" -ForegroundColor Red
                        PAUSE
                    } UNTIL (Test-Path "$FolderPath_Local_Setup\*Agent_Install*.exe")
                    Write-Host "The Automate Agent Installer under $FolderPath_Local_Setup has been detected" -ForegroundColor Green
                    New-Item $CompletionFile -ItemType File -Force | Out-Null
                }
                2 {
                    Write-Host "Placing the Automate Agent Installer under $FolderPath_Local_Setup has been skipped" -ForegroundColor Green
                    New-Item $SkippedFile -ItemType File -Force | Out-Null
                }
            }
        }
    }
} Export-ModuleMember -Function Transfer-RMM_Agent

function Transfer-Sophos_Agent {
    # Variables - edit as needed
    $Step = "Transfer Sophos Agent"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"

    If (Test-Path "$StepStatus*") {
        # If already completed or skipped, report so
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        # See if installer is already present
        If (Test-Path "$FolderPath_Local_Setup\*SophosSetup*.exe") {
            Write-Host "`nSophos Agent Installer " -NoNewline; Write-Host "found in $FolderPath_Local_Setup" -ForegroundColor Green
            New-Item $CompletionFile -ItemType File -Force | Out-Null
        } else {
        # Ask tech to move it there
            DO {
                Write-Host "`n-=[ Sophos Installer Choice ]=-" -ForegroundColor Yellow
                Write-Host "Are you going to place the client's Sophos Installer under C:\Setup?"
                Write-Host "1. Yes"
                Write-Host "2. No"
                Write-Host "NOTE: If you place the Sophos Installer under $FolderPath_Local_Setup then it will automatically install on an imaged PC" -ForegroundColor DarkCyan
                [int]$choice = Read-Host -Prompt "Enter a number, 1 or 2"
                Write-Host ""
            } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
            switch ($choice) {
                1 {
                    DO {
                        Write-Host "Please place the Automate Agent Installer under $FolderPath_Local_Setup and then hit enter when ready" -ForegroundColor Yellow
                        PAUSE
                    } UNTIL (Test-Path "$FolderPath_Local_Setup\*SophosSetup*.exe")
                    Write-Host "The Sophos Agent Installer under $FolderPath_Local_Setup has been detected" -ForegroundColor Green
                    New-Item $CompletionFile -ItemType File -Force | Out-Null
                }
                2 {
                    Write-Host "Placing the Sophos Agent Installer under $FolderPath_Local_Setup has been skipped" -ForegroundColor Green
                    New-Item $SkippedFile -ItemType File -Force | Out-Null
                }
            }
        }
    }
} Export-ModuleMember -Function Transfer-Sophos_Agent

function Install-Windows_Updates {
    # Variables - edit as needed
    $Step = "Install Windows Updates"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"
    $InProgressFile = "$StepStatus-InProgress.txt"

    If ((Test-Path $CompletionFile) -or (Test-Path $SkippedFile)) {
        # If task is completed or skipped...
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        # If task is not completed...
        
        # Choice
        If (!(Test-Path $InProgressFile)) {
            If ($global:ClientSettings.WindowsUpdates) {
                $choice = $global:ClientSettings.WindowsUpdates
            } else {
                DO {
                    Write-Host ""
                    Write-Host "-=[ $Step ]=-" -ForegroundColor Yellow
                    Write-Host "Would you like to $Step ?"
                    Write-Host "1. Yes"
                    Write-Host "2. No"
                    Write-Host "Note: If you are in a rush, you may want to skip this" -ForegroundColor Cyan
                    [int]$choice = Read-Host -Prompt "Enter a number, 1 or 2"
                } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
            }
            If ($choice -eq 1) {
                # If ClientSetting doesn't exist, update Client Config File
                If (($global:ClientSettings) -and (!($global:ClientSettings.WindowsUpdates))) {
                    Add-ClientSetting -Name WindowsUpdates -Value $choice
                    Save-ClientSettings
                }
                New-Item $InProgressFile -ItemType File -Force | Out-Null
                Write-Host "Installing Windows Update Provider"
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
                Install-Module PSWindowsUpdate -Force
            } else {
                If (($global:ClientSettings) -and (!($global:ClientSettings.WindowsUpdates))) {
                    Add-ClientSetting -Name WindowsUpdates -Value $choice
                    Save-ClientSettings
                }
                New-Item $SkippedFile -ItemType File -Force | Out-Null
                Write-Host "$Step`: " -NoNewline; Write-Host "Skipped"
            }
        }

        # Keep installing updates and rebooting when needed until fully up to date
        If (Test-Path $InProgressFile) {
            Write-Host "Checking for available Windows Updates..."
            $Updates = Get-WindowsUpdate
            If ($Updates.count -gt 0) {
                Write-Host "Installing all available Windows Updates"
                Get-WindowsUpdate -AcceptAll -Install -AutoReboot
                Restart-Computer -Force | Out-Null
                Write-Host "Should be restarting soon..." -ForegroundColor Red
                Pause
            } else {
                Remove-Item $InProgressFile | Out-Null
                New-Item $CompletionFile -ItemType File -Force | Out-Null
                Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green
            }
        }
    }
} Export-ModuleMember -Function Install-Windows_Updates

function CheckPoint-Disk_Cleanup {
    # Variables - edit as needed
    $Step = "Run Disk Cleanup"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        DO {
            Write-Host ""
            Write-Host "-=[ $Step ]=-" -ForegroundColor Yellow
            Write-Host "Would you like to $Step ?"
            Write-Host "This could be skipped to save time" -ForegroundColor Cyan
            Write-Host "1. Yes"
            Write-Host "2. No"
            $choice = Read-Host -Prompt "Enter a number, 1 or 2"
        } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
        If ($choice -eq 1) {
            Run-Disk_Cleanup
            New-Item $CompletionFile -ItemType File -Force | Out-Null
        } else {
            New-Item $SkippedFile -ItemType File -Force | Out-Null
            Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Yellow
        }
    }
} Export-ModuleMember -Function CheckPoint-Disk_Cleanup

function Run-Disk_Cleanup {
    # -=[ Run Disk Cleaner Before Taking Image ]=-
    Write-Host "`nRunning Disk Cleanup..."
    $vol = Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
    $vol.GetSubKeyNames() | ForEach-Object { $vol.OpenSubKey($_, $true).SetValue('StateFlags0000', 2) }
    cmd.exe /c "cleanmgr /SAGERUN:0"
    Write-Host "Disk Cleanup has been completed" -ForegroundColor Green
} Export-ModuleMember -Function Run-Disk_Cleanup

function Join-Domain {
    # Variables - edit as needed
    $Step = "Join PC to the domain"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    $SkippedFile = "$StepStatus-Skipped.txt"

    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green}
    } else {
        Write-Host ""
        Write-Host "-=[ $Step ]=-" -ForegroundColor Yellow
        If ($Global:ClientSettings.DomainJoin -eq "2") {
            New-Item $SkippedFile -ItemType File -Force | Out-Null
            Write-Host "$Step has been skipped"
        } ElseIf ($Global:ClientSettings.DomainJoin -eq "1") {
            Write-Host "Make sure the VPN is connected if remote..." -ForegroundColor Red
            Write-Host "Hit any key and the computer will be joined to the domain, then rebooted."
            Pause
            
            Try {
                Add-Computer -DomainName $Global:ClientSettings.DNS_Domain_Name -Credential (($Global:ClientSettings.NETBIOS)+"\"+($Global:ClientSettings.Domain_Admin_Username)) -Force -Verbose
                New-Item $CompletionFile -ItemType File -Force | Out-Null
                Write-Host ""
                Write-Host "$Step has been completed" -ForegroundColor Green
                Restart-Computer
                Pause
            }
            Catch {
                Write-Host "$Step did not complete successfully" -ForegroundColor Red
                DO {
                    Write-Host ""
                    Write-Host "-=[ Error Handling ]=-" -ForegroundColor Yellow
                    Write-Host "Would you like to try again or skip this step?"
                    Write-Host "1. Try to $Step again"
                    Write-Host "2. Skip this step"
                    $choice = Read-Host -Prompt "Enter a number, 1 or 2"
                } UNTIL (($choice -eq 1) -OR ($choice -eq 2))
                If ($choice -eq 1) {
                    Join-Domain
                } else {
                    New-Item $SkippedFile -ItemType File -Force | Out-Null
                    Write-Host "$Step`: " -NoNewline; Write-Host "Skipped" -ForegroundColor Green
                }
            }
        }
    }
} Export-ModuleMember -Function Join-Domain

function Remove-AutoLogon {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )
    
    # Variables - edit as needed
    $Step = "Remove Auto-Logon"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If ((Test-Path "$StepStatus*") -and !($Force)) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Write-Host ""
        Write-Host "Resetting AutoAdminLogon Registry settings"
        Set-ItemProperty -Path $WinLogonKey -Name AutoAdminLogon -Value "0"
        Set-ItemProperty -Path $WinLogonKey -Name ForceAutoLogon -Value "0"
        Remove-ItemProperty -Path $WinLogonKey -Name DefaultUserName -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $WinLogonKey -Name DefaultPassword -Force -ErrorAction SilentlyContinue
    
        If (!($Force)) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step`: " -NoNewline; Write-Host "completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Remove-AutoLogon

function Activate-Windows {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Variables - edit as needed
    $Step = "Activate Windows"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"

    If ((Test-Path "$StepStatus*") -and !($Force)) {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Write-Host "`n-=[ $Step ]=-" -ForegroundColor DarkGray
        $service = get-wmiObject -query 'select * from SoftwareLicensingService'
        if($key = $service.OA3xOriginalProductKey){
            Write-Host "Activating using product Key: $key"
	        $service.InstallProductKey($key)
            Write-Host "An attempt to license Windows with a digital license has completed" -ForegroundColor Green
            Write-Host "However, this doesn't seem to work reliably..." -ForegroundColor Red
            Write-Host "Please take a second to activate the OS manually" -ForegroundColor Yellow
            Write-Host "Settings > Update & Security > Activation > Troubleshoot by Activation" -ForegroundColor Yellow
        } else {
            Write-Host "Key not found, cannot activate OS automatically" -ForegroundColor Red
            Write-Host "Please take a second to activate the OS manually" -ForegroundColor Yellow
            Write-Host "Settings > Update & Security > Activation > Troubleshoot by Activation" -ForegroundColor Yellow
        }
        PAUSE

        If (!($Force)) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        Write-Host "$Step has been completed" -ForegroundColor Green
    }
} Export-ModuleMember -Function Activate-Windows
#########################################################
############## END OF Configure PC SCRIPTS ##############
#########################################################

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
} Export-ModuleMember -Function Remove-Folder