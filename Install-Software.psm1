##############################################################################
##############################################################################
###                                                                        ###
###                          -=[ Script Setup ]=-                          ###
###                                                                        ###
##############################################################################
##############################################################################
#using module Configure-PC
Clear-Host

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
$Software                               = New-Software

function New-Software {
    [Software]::new()
} Export-ModuleMember -Function New-Software

class Software {
    [System.Object]$Config

    Software() {
        $this.Load_Configs()
    }

    [void]hidden Load_Configs() {
        $this.Config = $null

        function Add-SoftwareHash {
            [CmdletBinding()]
            param(
                [Parameter(Mandatory = $true)]
                [string] $Name,
        
                [Parameter(Mandatory = $true)]
                [string] $Installer_Name,
                
                [Parameter(Mandatory = $true)]
                [string] $Verification_Path,
                
                [Parameter(Mandatory = $true)]
                [string] $Installer_Source,
                
                [Parameter(Mandatory = $false)]
                [string] $Manual_URL,
                
                [Parameter(Mandatory = $false)]
                [string] $URL,
                
                [Parameter(Mandatory = $false)]
                [string] $Arguments
            )
        
            $Hash = @{
                    "Name"=$Name;
                    "Installer_Name"=$Installer_Name;
                    "Verification_Path"=$Verification_Path;
                    "Installer_Source"=$Installer_Source;
            }
            if ($Manual_URL) {$Hash.Add("Manual_URL",$Manual_URL)}
            if ($URL) {$Hash.Add("URL",$URL)}
            if ($Arguments) {$Hash.Add("Arguments",$Arguments)}
            
            $Software_Settings.Add($Name,$Hash)
        }
        
        $Software_Settings = @{}
    
        Add-SoftwareHash -Name "Adobe Acrobat Pro DC - Trial Installer"`
                         -Installer_Name "rdracrobatdc_acr_xa_mdr_install.exe"`
                         -Verification_Path "C:\Program Files (x86)\Adobe\Acrobat DC\Acrobat\Acrobat.exe"`
                         -Installer_Source "Standard_Software"`
                         -Manual_URL "https://get.adobe.com/reader/download?os=Windows+10&name=AcrobatProDC&lang=en&nativeOs=Windows+10&accepted=&declined=mss%2Cmsc&preInstalled=&site=landing"
        
        Add-SoftwareHash -Name "Adobe Acrobat Reader DC"`
                         -Installer_Name "readerdc64_en_xa_mdr_install.exe"`
                         -Verification_Path "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe"`
                         -Installer_Source "Standard_Software"`
                         -Manual_URL "https://get.adobe.com/reader/download?os=Windows+10&name=Reader+DC+2022.001.20117+English+Windows%2864Bit%29&lang=en&nativeOs=Windows+10&accepted=&declined=mss%2Cmsc&preInstalled=&site=landing"
        
        Add-SoftwareHash -Name "Chrome"`
                         -Installer_Name "ChromeInstaller.exe"`
                         -Verification_Path "C:\Program Files\Google\Chrome\Application\chrome.exe"`
                         -Installer_Source "Standard_Software"`
                         -URL "http://dl.google.com/chrome/install/latest/chrome_installer.exe"`
                         -Arguments '"/silent","/install"'
        
        Add-SoftwareHash -Name "CutePDF Writer"`
                         -Installer_Name "Ninite CutePDF Installer.exe"`
                         -Verification_Path "C:\Program Files (x86)\CutePDF Writer\CutePDFWriter.exe"`
                         -Installer_Source "Standard_Software"`
                         -URL "https://ninite.com/cutepdf/ninite.exe"
        
        Add-SoftwareHash -Name "Dell Support Assist"`
                         -Installer_Name "Dell_Support_Assist_Installer.exe"`
                         -Verification_Path "C:\Setup"`
                         -Installer_Source "Standard_Software"`
                         -URL "https://downloads.dell.com/serviceability/catalog/SupportAssistInstaller.exe"`
                         -Arguments "/S"
        
        Add-SoftwareHash -Name "Dropbox"`
                         -Installer_Name "DropboxInstaller.exe"`
                         -Verification_Path "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe"`
                         -Installer_Source "Standard_Software"`
                         -Manual_URL "https://www.dropbox.com/downloading"`
                         -Arguments "/S"
        
        Add-SoftwareHash -Name "Firefox"`
                         -Installer_Name "FirefoxInstaller.exe"`
                         -Verification_Path "C:\Program Files\Mozilla Firefox\firefox.exe"`
                         -Installer_Source "Standard_Software"`
                         -URL "https://download.mozilla.org/?product=firefox-latest-ssl"`
                         -Arguments "/S"
        
        Add-SoftwareHash -Name "Microsoft 365 Apps for business - en-us (32-bit)"`
                         -Installer_Name "setup.exe"`
                         -Verification_Path "C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE"`
                         -Installer_Source "ODT"`
                         -Arguments "/configure o365Business1_32-bit.xml"
        
        Add-SoftwareHash -Name "Microsoft 365 Apps for business - en-us (64-bit)"`
                         -Installer_Name "setup.exe"`
                         -Verification_Path "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"`
                         -Installer_Source "ODT"`
                         -Arguments "/configure o365Business1.xml"
        
        Add-SoftwareHash -Name "Microsoft 365 Apps for enterprise - en-us (32-bit)"`
                         -Installer_Name "setup.exe"`
                         -Verification_Path "C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE"`
                         -Installer_Source "ODT"`
                         -Arguments "/configure o365Enterprise_32-bit.xml"
        
        Add-SoftwareHash -Name "Microsoft 365 Apps for enterprise - en-us (64-bit)"`
                         -Installer_Name "setup.exe"`
                         -Verification_Path "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"`
                         -Installer_Source "ODT"`
                         -Arguments "/configure o365ProPlus1.xml"
        
        Add-SoftwareHash -Name "MXIE"`
                         -Installer_Name "mxie64-15.0.6.msi"`
                         -Verification_Path "C:\Program Files (x86)\Zultys\MXIE\Bin\mxie.exe"`
                         -Installer_Source "Standard_Software"`
                         -Arguments "/qn"
        
        Add-SoftwareHash -Name "ZAC"`
                         -Installer_Name "ZAC_x64-8.0.28.exe"`
                         -Verification_Path "C:\Program Files (x86)\Zultys\ZAC\zac.exe"`
                         -Installer_Source "Standard_Software"`
                         -URL "https://mirror.zultys.biz/ZAC/ZAC_x64-8.0.28.exe"`
                         -Arguments "/S /v/qn"
        
        Add-SoftwareHash -Name "Zultys Fax 2.0 Printer"`
                         -Installer_Name "Zultys_Fax_2.0_x64.msi"`
                         -Verification_Path "C:\Program Files\Zultys\Zultys Fax 2.0 Printer\display.ico"`
                         -Installer_Source "Standard_Software"`
                         -URL "http://fumcgp.mxvirtual.com/Zultys_Fax_2.0_x64.msi"`
                         -Arguments "/qn"
        
        Add-SoftwareHash -Name "Citrix Files for Windows (ShareFile)"`
                         -Installer_Name "CitrixFilesForWindows-*.exe"`
                         -Verification_Path "C:\Program Files\Citrix\Citrix Files\CitrixFiles.exe"`
                         -Installer_Source "Standard_Software"`
                         -Manual_URL ""`
                         -Arguments "/install /quiet /norestart"

        Add-SoftwareHash -Name "Cisco Jabber"`
                         -Installer_Name "CiscoJabberSetup*.msi"`
                         -Verification_Path "C:\Program Files (x86)\Cisco Systems\Cisco Jabber\CiscoJabber.exe"`
                         -Installer_Source "Standard_Software"`
                         -Manual_URL ""`
                         -Arguments "/qn"

        Add-SoftwareHash -Name "EXTRACT Dell Command | Update"`
                         -Installer_Name "Dell-Command-Update-Application_8D5MC_WIN_4.3.0_A00_02.EXE"`
                         -Installer_Source "Standard_Software"`
                         -URL "https://dl.dell.com/FOLDER07582851M/3/Dell-Command-Update-Application_8D5MC_WIN_4.3.0_A00_02.EXE"`
                         -Arguments "/s /e=C:\Setup\_Software_Collection\Standard_Software"`
                         -Verification_Path "C:\Setup\_Software_Collection\Standard_Software\DCU_Setup_4_3_0.exe"
                         
        Add-SoftwareHash -Name "INSTALL Dell Command | Update"`
                         -Installer_Name "DCU_Setup_4_3_0.exe"`
                         -Installer_Source "Standard_Software"`
                         -Manual_URL "https://www.dell.com/support/home/en-us/drivers/driversdetails?driverid=8d5mc"`
                         -Arguments "/S /v/qn"`
                         -Verification_Path "C:\Program Files (x86)\Dell\CommandUpdate\DellCommandUpdate.exe"

        <#
        Add-SoftwareHash -Name `
                         -Installer_Name `
                         -Verification_Path `
                         -Installer_Source `
                         -Manual_URL `
                         -URL `
                         -Arguments 
        #>

        $this.Config = $Software_Settings
    }
    
    [void]Install([string]$SoftwareName) {
        $this.Install($SoftwareName,"none")
    }

    [void]Install([string]$SoftwareName,[string]$CompletionFile) {
        # Define variables
        $FolderPath_Local_ODT_Software          = "C:\Setup\_Software_Collection\ODT"
        $FolderPath_Local_Profile_Software      = "C:\Setup\_Software_Collection\Profile_Specific_Software"
        $FolderPath_Local_Standard_Software     = "C:\Setup\_Software_Collection\Standard_Software"
        $Installer_Name = $this.Config.$SoftwareName.Installer_Name
        $Installer_Source = $this.Config.$SoftwareName.Installer_Source
        $Installer_URL = $this.Config.$SoftwareName.URL
        $Installer_Manual_URL = $this.Config.$SoftwareName.Manual_URL
        $Installer_Arguments = $this.Config.$SoftwareName.Arguments
        $Installer_Verification_Path = $this.Config.$SoftwareName.Verification_Path
        $Installer_Path = $null
        $Local_Installer_Path = $null
        $Local_Installer_Name = $null
        $USB_Installer_Path = $null
        $USB_Installer_Name = $null
        $Working_Dir = $null
        $Local_Working_Dir = $null
        $USB_Working_Dir = $null
        $USB = $null
        $FolderPath_USB_Install_Software_ODT               = $null
        $FolderPath_USB_Install_Software_Profile_Software  = $null
        $FolderPath_USB_Install_Software_Standard_Software = $null
        $Arguments = $null
        # Define USB related variables if USB Imaging Tool is attached
        # Get The USB Drive Letter
        foreach ($letter in (Get-PSDrive -PSProvider FileSystem).Name) {
            $TestPath = "$letter" + ":\PC_Setup"
            If (Test-Path $TestPath) {
                $USB = "$letter" + ":"
            }
        }
        if ($USB) {
            $FolderPath_USB_Install_Software_ODT               = "$USB\PC_Setup\_Software_Collection\ODT"
            $FolderPath_USB_Install_Software_Profile_Software  = "$USB\PC_Setup\_Software_Collection\Profile_Specific_Software"
            $FolderPath_USB_Install_Software_Standard_Software = "$USB\PC_Setup\_Software_Collection\Standard_Software"
        }

        # Define all potential installation parameters that are dependant on installer type
        # Produces:
        #      $Local_Working_Dir       $USB_Working_Dir (if exists)
        #      $Local_Installer_Path    $USB_Installer_Path (if exists)
        switch ($Installer_Source) {
            "Standard_Software" {
                $Local_Working_Dir    = $FolderPath_Local_Standard_Software
                if (Test-Path "$Local_Working_Dir\$Installer_Name") {
                    $Local_Installer_Path = Get-ChildItem -Path "$Local_Working_Dir\$Installer_Name"
                    $Local_Installer_Path = $Local_Installer_Path[-1]
                    $Local_Installer_Name = $Local_Installer_Path.Name
                    $Local_Installer_Path = $Local_Installer_Path.FullName
                } else {
                    $Local_Installer_Path = "$Local_Working_Dir\$Installer_Name"
                    $Local_Installer_Name = $Installer_Name
                }
                if ($USB) {$USB_Working_Dir = $FolderPath_USB_Install_Software_Standard_Software}
            }
            "ODT" {
                $Local_Working_Dir    = $FolderPath_Local_ODT_Software
                $Local_Installer_Path = "$Local_Working_Dir\$Installer_Name"
                if ($USB) {$USB_Working_Dir = $FolderPath_USB_Install_Software_ODT}
            }
            "Profile_Specific_Software" {
                $Local_Working_Dir    = $FolderPath_Local_Profile_Software
                $Local_Installer_Path = "$Local_Working_Dir\$Installer_Name"
                if ($USB) {$USB_Working_Dir = $FolderPath_USB_Install_Software_Profile_Software}
            }
        }
        if ($USB) {
            if (Test-Path "$USB_Working_Dir\$Installer_Name") {
                $USB_Installer_Path = Get-ChildItem -Path "$USB_Working_Dir\$Installer_Name"
                $USB_Installer_Path = $USB_Installer_Path[-1]
                $USB_Installer_Name = $USB_Installer_Path.Name
                $USB_Installer_Path = $USB_Installer_Path.FullName
            }
        }
        
        # Determine Installer location and define $Installer_Path and $Working_Dir
        # Ideally we want a local installer, USB if we have to, otherwise download if we can. In that order.
        # Produces:
        #      $Working_Dir        $Installer_Path
        #
        # If installer is found to be local...
        If (Test-Path $Local_Installer_Path) {
            #Write-Host $Local_Installer_Path
            # Define $Working_Dir
            $Working_Dir = $Local_Working_Dir
            # Make a copy and define that as the $Installer_Path
            If (!(Test-Path "$Working_Dir\copy")) {New-Item -Path "$Working_Dir\copy" -ItemType Directory -Force | Out-Null}
            $Installer_Name = $Local_Installer_Name
            $Installer_Path = "$Working_Dir\copy\$Installer_Name"
            Copy-Item -Path $Local_Installer_Path -Destination $Installer_Path
        # If installer is found to be on USB...
        } elseif ($USB_Installer_Path) {
            #Write-Host "`$USB_Installer_Path = $USB_Installer_Path"
            # Define $Working_Dir
            $Working_Dir = $USB_Working_Dir
            # Make a copy and define that as the $Installer_Path
            If (!(Test-Path "$Working_Dir\copy")) {New-Item -Path "$Working_Dir\copy" -ItemType Directory -Force | Out-Null}
            $Installer_Name = $USB_Installer_Name
            $Installer_Path = "$Working_Dir\copy\$Installer_Name"
            #Write-Host "`$Installer_Path = $Installer_Path"
            Copy-Item -Path $USB_Installer_Path -Destination $Installer_Path
        # Otherwise download the installer if possible
        } elseif ($Installer_URL -ne $null) {
            #Write-Host "`$Installer_URL = $Installer_URL"
            #Write-Host "`$Local_Installer_Path = $Local_Installer_Path"
            # Download Installer
            (New-Object System.Net.WebClient).DownloadFile($Installer_URL, $Local_Installer_Path)
            # Define $Working_Dir
            $Working_Dir = $Local_Working_Dir
            # Make a copy and define that as the $Installer_Path
            If (!(Test-Path "$Working_Dir\copy")) {New-Item -Path "$Working_Dir\copy" -ItemType Directory -Force | Out-Null}
            $Installer_Path = "$Working_Dir\copy\$Installer_Name"
            Copy-Item -Path $Local_Installer_Path -Destination $Installer_Path
            # Copy to USB if USB is present
            If ($USB) {Copy-Item -Path $Local_Installer_Path -Destination $USB_Installer_Path -ErrorAction SilentlyContinue}
        # Else, notify that the installer could not be found
        } else {
            $Installer_Path = $null
            If ($USB) {
                Write-Host "`nWARNING: " -ForegroundColor Red -NoNewline; Write-Host "Was not able to locate an installer for $SoftwareName on the local host or on the Imaging Tool"
            } else {
                Write-Host "`nWARNING: " -ForegroundColor Red -NoNewline; Write-Host "Was not able to locate an installer for $SoftwareName on the local host"
            }
            Write-Host "  >You will need to " -NoNewline; Write-Host "download" -ForegroundColor Cyan -NoNewline; Write-Host " this software and " -NoNewline; Write-Host "install" -ForegroundColor Cyan -NoNewline; Write-Host " it " -NoNewline; Write-Host "manually" -ForegroundColor Red -NoNewline; Write-Host "..."
            If ($Installer_Manual_URL -ne $null) {Write-Host "  >Opening Download portal now" -ForegroundColor Green; Start-Process $Installer_Manual_URL}
            Write-Host "`nPlease also place a copy of $Installer_Name in the $Installer_Source folder on the Imaging Tool" -ForegroundColor Yellow
            Write-Host "  >If you do this, you will not need to download it next time"
            Write-Host "`nOnce the software has been installed," -ForegroundColor Yellow
            PAUSE
        }

        # First see if the software is already installed before running the installer
        #Write-Host "`$Installer_Verification_Path = $Installer_Verification_Path"
        if (!(Test-Path $Installer_Verification_Path)) {
            # If an Installer exists, run the install command
            if (Test-Path $Installer_Path) {
                Write-Host "`nStarting to install $SoftwareName"
                if ($Installer_Path -like "*.exe") {
                    if ($Installer_Arguments) {$Arguments = ($Installer_Arguments).Split(",")}
                    #Write-Host 'Troubleshooting Info - $Arguments = '$Arguments
                    if ($Arguments -eq $null) {
                        #Write-Host "Troubleshooting Info: Start-Process $Installer_Path -WorkingDirectory $Working_Dir -Wait"
                        Start-Process $Installer_Path -WorkingDirectory $Working_Dir -Wait
                    } else {
                        #Write-Host "Troubleshooting Info: Start-Process $Installer_Path -ArgumentList $Arguments -WorkingDirectory $Working_Dir -Wait"
                        Start-Process $Installer_Path -ArgumentList $Arguments -WorkingDirectory $Working_Dir -Wait
                    }
                } elseif ($Installer_Path -like "*.msi") {
                    $Arguments = "/i $Installer_Path $Installer_Arguments"
                    #Write-Host 'Start-Process "msiexec.exe" -ArgumentList $Arguments -Wait'
                    Start-Process "msiexec.exe" -ArgumentList $Arguments -Wait 
                } else {
                    Write-Host "Error 505"
                    Pause
                }
            }
        }

        # Verify Installation Status and Create CompletionFile if install is successful
        If (($Installer_Verification_Path -ne $null) -and ($CompletionFile -ne "none")) {
            $this.Verify_Installation_Success($SoftwareName,$Installer_Verification_Path,$CompletionFile)
        } elseif ($Installer_Verification_Path -ne $null) {
            $this.Verify_Installation_Success($SoftwareName,$Installer_Verification_Path)
        } else {
            Write-Host "WARNING!!" -ForegroundColor Red -NoNewline; Write-Host ": Software config does not have a Verification Path to reference"
            Write-Host "Please update the config file now before continuing, then reboot ideally"
            PAUSE
        }
        If ($CompletionFile -ne "none") {
            If (Test-Path $CompletionFile) {Remove-Item -Path $Installer_Path -Force -ErrorAction SilentlyContinue}
        }
    }

    [boolean]hidden Verify_Installation_Success([string]$SoftwareName,[string]$Installer_Verification_Path) {
        return $this.Verify_Installation_Success($SoftwareName,$Installer_Verification_Path,"")
    }

    [boolean]hidden Verify_Installation_Success([string]$SoftwareName,[string]$Installer_Verification_Path,[string]$CompletionFile) {
        Write-Host "Verifying if the software is now installed..."
        If (Test-Path $Installer_Verification_Path) {
            Write-Host "Installed - $SoftwareName" -ForegroundColor Green
            If ($CompletionFile -ne "") {New-Item $CompletionFile -ItemType File -Force | Out-Null}
            return $true
        } else {
            Write-Host "$SoftwareName is not installed" -ForegroundColor Red
            Write-Host "Reboot or just relog to re-attempt install"
            [int]$Global:InstallationErrorCount++
            return $false
        }
    }
}

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

    Write-Host "`n-=[ $Step ]=-" -ForegroundColor DarkGray
    If (Test-Path "$StepStatus*") {
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
                if ($global:Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
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
    $Software = New-Software

    # Status check
    # If already installed for skipped, just report so and skip the rest
    If ((Test-Path "$StepStatus*.txt") -and ($global:Automated_Setup)) {
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
            if ($global:Automated_Setup) {
                # Update Client Config File with choice
                Add-ClientSetting -Name FileShareApp -Value $choice
            }
        }
        # Act on choice
        switch ($choice) {
            0 {
                if ($global:Automated_Setup) {New-Item "$StepStatus-0.txt" -ItemType File -Force | Out-Null}
                Write-Host "$Step has been skipped"
            }
            1 {
                $SoftwareName = "Citrix Files for Windows (ShareFile)"
                $CompletionFile = "$StepStatus-1.txt"
                $Software.Install($SoftwareName,$CompletionFile)
            }
            2 {
                $SoftwareName = "Dropbox"
                $CompletionFile = "$StepStatus-2.txt"
                $Software.Install($SoftwareName,$CompletionFile)
            }
        }
    }
} Export-ModuleMember -Function Choose-FileShareApp

function Choose-Browser {
    # Variables - edit as needed
    $Step = "Install Browser"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $Software = New-Software

    # Status check
    # If already installed for skipped, just report so and skip the rest
    If ((Test-Path "$StepStatus*.txt") -and ($global:Automated_Setup)) {
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
            if ($global:Automated_Setup) {
                # Update Client Config File with choice
                Add-ClientSetting -Name Browser -Value $choice
            }
        }
        # Act on choice
        switch ($choice) {
            1 {
                $SoftwareName = "Chrome"
                $CompletionFile = "$StepStatus-1.txt"
                $Software.Install($SoftwareName,$CompletionFile)
            }
            2 {
                $SoftwareName = "Firefox"
                $CompletionFile = "$StepStatus-2.txt"
                $Software.Install($SoftwareName,$CompletionFile)
            }
            3 {
                $SoftwareName = "Chrome"
                $Software.Install($SoftwareName)

                $SoftwareName = "Firefox"
                $CompletionFile = "$StepStatus-3.txt"
                $Software.Install($SoftwareName,$CompletionFile)
            }
            4 {
                Write-Host "Chrome and Firefox browser installs have been skipped"
                if ($global:Automated_Setup) {New-Item "$StepStatus-4.txt" -ItemType File -Force | Out-Null}
            }
        }
    }
} Export-ModuleMember -Function Choose-Browser

function Choose-PDF_Viewer {
    # Variables - edit as needed
    $Step = "Install PDF Viewer"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $Software = New-Software

    # Status check
    # If already installed for skipped, just report so and skip the rest
    If ((Test-Path "$StepStatus*.txt") -and ($global:Automated_Setup)) {
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
            if ($choice -eq 3) {$choice = 1}
        } else {
        # Otherwise ask tech to choose action to take
            DO {
                Write-Host ""
                Write-Host "-=[ PDF Viewer Choice ]=-" -ForegroundColor Yellow
                Write-Host "Which PDF Viewer(s) do you want to install?"
                Write-Host "1. Adobe Acrobat Reader DC"
                Write-Host "2. Adobe Acrobat Pro DC - Trial Installer"
                Write-Host "3. Adobe Acrobat Reader DC -AND- Adobe Acrobat Pro DC - Trial Installer" -NoNewline; Write-Host " <--- No longer possible - Do Not Choose" -ForegroundColor Red
                Write-Host "4. CutePDF Writer (and converter)"
                Write-Host "5. Adobe Acrobat Reader DC -AND- CutePDF Writer (and converter)"
                Write-Host "6. NONE"
                [int]$choice = Read-Host -Prompt "Enter a number, 1 through 6"
            } UNTIL (($choice -ge 1) -and ($choice -le 6))
            if ($global:Automated_Setup) {
                # Update Client Config File with choice
                Add-ClientSetting -Name PDF_Viewer -Value $choice
            }
        }
        # Act on choice
        switch ($choice) {
            1 {
                $SoftwareName = "Adobe Acrobat Reader DC"
                $CompletionFile = "$StepStatus-1.txt"
                $Software.Install($SoftwareName,$CompletionFile)
            }
            2 {
                $SoftwareName = "Adobe Acrobat Pro DC - Trial Installer"
                $CompletionFile = "$StepStatus-2.txt"
                $Software.Install($SoftwareName,$CompletionFile)
            }
            3 {
                Write-Host "Option 3 is no longer possible, please remove this choice from your client config file and then relog to start the Automated Setup script again"
                $ClientConfigFile = (Get-ChildItem -Path "$FolderPath_Local_Client_Config\*.ClientConfig" -ErrorAction SilentlyContinue).FullName
                Write-Host "Client Config File: $ClientConfigFile"
                PAUSE
                Choose-PDF_Viewer
            }
            4 {
                $SoftwareName = "CutePDF Writer"
                $CompletionFile = "$StepStatus-4.txt"
                $Software.Install($SoftwareName,$CompletionFile)
            }
            5 {
                $SoftwareName = "Adobe Acrobat Reader DC"
                $Software.Install($SoftwareName)

                $SoftwareName = "CutePDF Writer"
                $CompletionFile = "$StepStatus-5.txt"
                $Software.Install($SoftwareName,$CompletionFile)
            }
            6 {
                Write-Host "All PDF Editor\Viewer installs have been skipped"
                if ($global:Automated_Setup) {New-Item "$StepStatus-6.txt" -ItemType File -Force | Out-Null}
            }
        }
    }
} Export-ModuleMember -Function Choose-PDF_Viewer

function Choose-o365 {
    # Variables - edit as needed
    $Step = "Install o365"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $Software = New-Software

    # Status check
    # If already installed for skipped, just report so and skip the rest
    If ((Test-Path "$StepStatus*.txt") -and ($global:Automated_Setup)) {
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
            if ($global:Automated_Setup) {
                # Update Client Config File with choice
                Add-ClientSetting -Name o365 -Value $choice
            }
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
                    if ($global:Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
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
                    if ($global:Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
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
                    if ($global:Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
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
                    if ($global:Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
                } else {
                    Write-Host "$SoftwareName is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                    [int]$Global:InstallationErrorCount++
                }
            }
            5 {
                Write-Host "o365 installation has been skipped"
                if ($global:Automated_Setup) {New-Item "$StepStatus-5.txt" -ItemType File -Force | Out-Null}
            }
        }
    }
} Export-ModuleMember -Function Choose-o365

function Choose-VPN {
    # Variables - edit as needed
    $Step = "Install VPN"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $Software = New-Software

    # Status check
    # If already installed for skipped, just report so and skip the rest
    If ((Test-Path "$StepStatus*.txt") -and ($global:Automated_Setup)) {
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
            if ($global:Automated_Setup) {
                # Update Client Config File with choice
                Add-ClientSetting -Name VPN -Value $choice
            }
        }
        # Act on choice
        switch ($choice) {
            1 {
                $SoftwareName = "WatchGuard Mobile VPN with SSL client"
                $CompletionFile = "$StepStatus-1.txt"
                #Install-Software -SoftwareName $SoftwareName -CompletionFile $CompletionFile

                Write-Host "`nInstalling $SoftwareName"
                $ZipPath = "$FolderPath_Local_Standard_Software\WG-MVPN-SSL_12_7.zip"
                $InstallerPath = "$FolderPath_Local_Standard_Software\temp"
                Expand-Archive -LiteralPath $ZipPath -DestinationPath $InstallerPath -Force
                $InstallerPath = $InstallerPath + "\Install_WG_SSL_VPN_12.7.bat"
                Start-Process $InstallerPath -Wait
                Write-Host "Verifying if the software is now installed..."
                If (Test-Path -LiteralPath "C:\Program Files (x86)\WatchGuard\WatchGuard Mobile VPN with SSL\wgsslvpnc.exe") {
                    Write-Host "Installed - $SoftwareName" -ForegroundColor Green
                    {New-Item $CompletionFile -ItemType File -Force | Out-Null}
                } else {
                    Write-Host "$SoftwareName is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                    [int]$Global:InstallationErrorCount++
                }
            }
            2 {
                Write-Host "VPN client installation has been skipped"
                if ($global:Automated_Setup) {New-Item "$StepStatus-2.txt" -ItemType File -Force | Out-Null}
            }
        }
    }
} Export-ModuleMember -Function Choose-VPN

function Choose-Collaboration_Software {
    # Variables - edit as needed
    $Step = "Install Collaboration Software"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $Software = New-Software

    # Status check
    # If already installed for skipped, just report so and skip the rest
    If ((Test-Path "$StepStatus*.txt") -and ($global:Automated_Setup)) {
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
            if ($global:Automated_Setup) {
                # Update Client Config File with choice
                Add-ClientSetting -Name Collab -Value $choice
            }
        }
        # Act on choice
        switch ($choice) {
            1 {
                $SoftwareName = "Cisco Jabber"
                $CompletionFile = "$StepStatus-1.txt"
                $Software.Install($SoftwareName,$CompletionFile)
            }
            2 {
                $SoftwareName = "ZAC"
                $CompletionFile = "$StepStatus-2.txt"
                $Software.Install($SoftwareName,$CompletionFile)
            }
            3 {
                $SoftwareName = "ZAC"
                $Software.Install($SoftwareName)

                $SoftwareName = "Zultys Fax 2.0 Printer"
                $CompletionFile = "$StepStatus-3.txt"
                $Software.Install($SoftwareName,$CompletionFile)
            }
            4 {
                Write-Host "Cisco Jabber, MXIE, ZAC, and Zulty's Fax Driver installs have been skipped"
                if ($global:Automated_Setup) {New-Item "$StepStatus-4.txt" -ItemType File -Force | Out-Null}
            }
        }
    }
} Export-ModuleMember -Function Choose-Collaboration_Software

function CheckPoint-Client_Software {
    # Variables - edit as needed
    $Step = "Install Client Software"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $CompletionFile = "$StepStatus-Completed.txt"
    
    If (Test-Path "$StepStatus*") {
        If (Test-Path $CompletionFile) {Write-Host "$Step`: " -NoNewline; Write-Host "Completed" -ForegroundColor Green}
    } else {
        Write-Host "`nIf needed, install Client Specific Software now"
        PAUSE
        if ($global:Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
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
        if ($global:Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
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
        if ($global:Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
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
                            if ($global:Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
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
                            if ($global:Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
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
                if ($global:Automated_Setup) {New-Item $SkippedFile -ItemType File -Force | Out-Null}
                Write-Host "Skipping - $Step" -ForegroundColor Green
            }
        }
    }
} Export-ModuleMember -Function Reinstall-SupportAssistant

function Install-SupportAssistant {
    #Variables - edit as needed
    $Step = "Install a Driver Update Assistant"

    # Static Variables - DO NOT EDIT
    $StepStatus = "$FolderPath_Local_AutomatedSetup_Status\"+$Step.Replace(" ","_")
    $SkippedFile = "$StepStatus-Skipped.txt"
    
    If (Test-Path "$StepStatus*") {
        If (Test-Path "$StepStatus-DellSA.txt") {Write-Host "Dell Support Assistant" -NoNewline; Write-Host " has been installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-DellCU.txt") {Write-Host "Dell Command | Update" -NoNewline; Write-Host " has been installed" -ForegroundColor Green}
        If (Test-Path "$StepStatus-HP.txt") {Write-Host "HP Support Assistant" -NoNewline; Write-Host " has been installed" -ForegroundColor Green}
        If (Test-Path $SkippedFile) {Write-Host "Both Dell and HP Support Assistant Installations" -NoNewline; Write-Host " have been skipped"}
    } else {
        $choice = $null
        DO {
            Write-Host "`n-=[ $Step ]=-" -ForegroundColor Yellow
            Write-Host "Which Driver Update Assistant would you like to install?"
            Write-Host "1. Dell Command | Update"
            Write-Host "2. Dell SupportAssist"
            Write-Host "3. HP Support Assistant"
            Write-Host "4. None"
            [int]$choice = Read-Host -Prompt "Enter a number, 1 through 4"
        } UNTIL (($choice -ge 1) -and ($choice -le 4))
        switch ($choice) {
            1 {
                $SoftwareName = "EXTRACT Dell Command | Update"
                $Software.Install($SoftwareName)

                $SoftwareName = "INSTALL Dell Command | Update"
                $CompletionFile = "$StepStatus-DellCU.txt"
                $Software.Install($SoftwareName,$CompletionFile)
            }
            2 {
                $Software = "Dell SupportAssist"
                Write-Host "`nInstalling $Software"
                $InstallerPath = "$FolderPath_Local_Standard_Software\Dell_Support_Assist_Installer.exe"
                Copy-Item -Path $InstallerPath -Destination $FolderPath_Local_Setup -Force
                Start-Process "$InstallerPath" -Wait
                Write-Host "Verifying if the software is now installed..."
                $Global:Installed_Software = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*
                If (($Global:Installed_Software).DisplayName -match $Software) {
                    Write-Host "Installed - $Software" -ForegroundColor Green
                    if ($global:Automated_Setup) {New-Item "$StepStatus-DellSA.txt" -ItemType File -Force | Out-Null}
                } else {
                    Write-Host "$Software is not installed" -ForegroundColor Red
                    Write-Host "Reboot or just relog to re-attempt install"
                }
            }
            3 {
                $Software = "HP Support Assistant"
                Write-Host "`nInstalling $Software"
                $InstallerPath = "$FolderPath_Local_Standard_Software\HP_Support_Assistant.exe"
                Copy-Item -Path $InstallerPath -Destination $FolderPath_Local_Setup -Force
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
            4 {
                Write-Host "All Driver Update Assistant installations have been skipped" -ForegroundColor Green
                if ($global:Automated_Setup) {New-Item $SkippedFile -ItemType File -Force | Out-Null}
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
            }
        }
        switch ($choice) {
            1 {
                $Software = "Dell Support Assist"
                Write-Host "`nInstalling $Software"
                $InstallerPath = "$FolderPath_Local_Standard_Software\Dell_Support_Assist_Installer.exe"
                Copy-Item -Path $InstallerPath -Destination $FolderPath_Local_Setup -Force
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
} Export-ModuleMember -Function Install-SupportAssistant2

function CheckPoint-DriverUpdates {
    #Variables - edit as needed
    $Step = "Install a Driver Update Assistant"

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
            if ($global:Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        } else {
            Write-Host "$Step has been skipped"
            if ($global:Automated_Setup) {New-Item $SkippedFile -ItemType File -Force | Out-Null}
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
            if ($global:Automated_Setup) {New-Item $CompletionFile -ItemType File -Force | Out-Null}
        } else {
            Write-Host "$Step has been skipped"
            if ($global:Automated_Setup) {New-Item $SkippedFile -ItemType File -Force | Out-Null}
        }
    }
} Export-ModuleMember -Function CheckPoint-DriverUpdates

###########################################################
############### END OF INSTALLATION FUNCTIONS #############
###########################################################