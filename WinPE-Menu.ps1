##############################################################################
##############################################################################
###                                                                        ###
###                          -=[ Script Setup ]=-                          ###
###                                                                        ###
##############################################################################
##############################################################################
$Found_Drives = 0
foreach ($Drive_Letter in (Get-PSDrive -PSProvider FileSystem).Name) {
    $Test_Path = "$Drive_Letter" + ":\Images"
    If (Test-Path $Test_Path) {
        $Imaging_Drive = "$Drive_Letter" + ":"
        $Found_Drives++
        Write-Host " -Imaging Drive Found: $Imaging_Drive"
    }

    $Test_Path = "$Drive_Letter" + ":\Windows\Setup"
    If (Test-Path $Test_Path) {
        $Windows_Drive = "$Drive_Letter" + ":"
        $Found_Drives++
        Write-Host " -Windows OS Drive Found: $Windows_Drive"
    }
}

Write-Host "`nIdentifying Boot Mode"
$FirmwareType = (Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Control -name PEFirmwareType -ErrorAction SilentlyContinue).PEFirmwareType
If ($FirmwareType -eq "0x1") {
    Write-Host " -Boot mode: BIOS mode"
} ElseIf ($FirmwareType -eq "0x2") {
    Write-Host " -Boot mode: UEFI mode"
} Else {
    Write-Host " -Could not determine FirmwareType!!!" -ForegroundColor Red
    Write-Host " -Do NOT attempt to deploy an image. The tool will not be able to format the drive properly without knowing what the firmwaretype is (BIOS\UEFI)."
}


###########################################################################
###########################################################################
###                                                                     ###
###                          -=[ Functions ]=-                          ###
###                                                                     ###
###########################################################################
###########################################################################
function Menu {
    If ($Found_Drives -ne 2) {
        Write-Host "`nWARNING!!!" -ForegroundColor Red
        Write-Host " -Was not able to identify both the Imaging Tool drive as well as the Windows OS drive - Will not be able to capture or deploy images properly`n" -ForegroundColor Yellow
        PAUSE
        EXIT
    } Else {
        Write-Host "`n================================================================================"
        Write-Host "`n-=[ Actions Menu ]=-"

        $Images = Get-ChildItem -Path "$Imaging_Drive\Images\*.wim"
        Do {
            $Count = 1
            $3spaces = "   "
            $2spaces = "  "
            Write-Host "`n   1: " -NoNewline; Write-Host "Capture Image" -ForegroundColor Green; $Count++
            ForEach ($Image in $Images) {
                $Name = $Image.Name
                If ($count -ge 10) {$spaces = $2spaces} else {$spaces = $3spaces}
                Write-Host "$spaces$Count`: " -NoNewline; Write-Host "Deploy " -ForegroundColor Cyan -NoNewline; Write-Host "$Name"; $Count++
            }
            If ($count -ge 10) {$spaces = $2spaces} else {$spaces = $3spaces}
            Write-Host "$spaces$Count`: " -NoNewline; Write-Host "Open Command Prompt" -ForegroundColor Yellow; $Count++
            If ($count -ge 10) {$spaces = $2spaces} else {$spaces = $3spaces}
            Write-Host "$spaces$Count`: " -NoNewline; Write-Host "Repair Boot Partition" -ForegroundColor Yellow
            Write-Host "$spaces$spaces$spaces !!!WARNING!!!" -ForegroundColor Red -NoNewline; Write-Host " This ONLY works on PCs that were built with this tool." -ForegroundColor DarkGray
            Write-Host "$spaces$spaces$spaces Otherwise the boot partition cannot be predicted." -ForegroundColor DarkGray ; $Count++
            If ($count -ge 10) {$spaces = $2spaces} else {$spaces = $3spaces}
            Write-Host "$spaces$Count`: " -NoNewline; Write-Host "Reboot" -ForegroundColor Red; $Count++
            If ($count -ge 10) {$spaces = $2spaces} else {$spaces = $3spaces}
            Write-Host "$spaces$Count`: " -NoNewline; Write-Host "Shutdown" -ForegroundColor Red
            [int]$choice = Read-Host -Prompt "`n Enter the number for the action you wish to take (Enter a number from 1 to $Count)"
        } Until (($choice -gt 0) -and ($choice -le $Count))
        If ($choice -eq 1) {
            Capture-Image
        } elseif ($choice -eq ($Count - 3)) {
            cmd.exe /c "Start cmd.exe"
            Clear-Host
        } elseif ($choice -eq ($Count - 2)) {
            Repair-BootPartition
            Clear-Host
        } elseif ($choice -eq ($Count - 1)) {
            Write-Host "Restarting..." -ForegroundColor Red
            Restart-Computer
            Start-Sleep 6000
        } elseif ($choice -eq $Count) {
            Write-Host "Shutting down..." -ForegroundColor Red
            Stop-Computer
            Start-Sleep 6000
        } else {
            $Image = $Images[$choice-2].FullName
            Deploy-Image $Image
        }
        Menu
    }
}

function Capture-Image {
    Clear-Host
    $NewImages = Get-ChildItem -Path "$Imaging_Drive\Images\NewImage*.wim"
    [int]$NewImagesCount = 0
    If ($NewImages) {
        $NewImagesCount = $NewImages.Count
        $NewImageName = "NewImage$NewImagesCount.wim"
    } else {$NewImageName = "NewImage.wim"}
    Write-Host "`n -=[ Capturing Image to $Imaging_Drive\Images\$NewImageName ]=- "
    $command = "DISM /Capture-Image /Capturedir:$Windows_Drive\ /Imagefile:$Imaging_Drive\Images\$NewImageName /Name:New_Image /Compress:max"
    cmd.exe /c $command
}

function Deploy-Image {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Image
    )
    Clear-Host
    Write-Host "`n-=[ Deploying $Image ]=-"
    If ($FirmwareType -eq "0x1") {
        $command = "diskpart /s $Imaging_Drive\sources\CreatePartitions-BIOS.txt"
        cmd.exe /c $command
    } ElseIf ($FirmwareType -eq "0x2") {
        $command = "diskpart /s $Imaging_Drive\sources\CreatePartitions-UEFI.txt"
        cmd.exe /c $command
    } Else {
        Write-Host " -Could not determine FirmwareType!!!" -ForegroundColor Red
        Write-Host " -Do NOT attempt to deploy an image. The tool will not be able to format the drive properly without knowing what the firmwaretype is (BIOS\UEFI)."
        PAUSE
        EXIT
    }
    $command = "DISM /Apply-Image /ImageFile:$Image /Index:1 /ApplyDir:C:\"
    cmd.exe /c $command
    Write-Host "`nCopying boot files to the System partition"
    $command = "C:\Windows\System32\bcdboot C:\Windows /s S:"
    cmd.exe /c $command
}

function Repair-BootPartition {
    $command = "diskpart /s $Imaging_Drive\sources\Repair-BootPartition.txt"; cmd.exe /c $command
    $command = "bootsect /nt60 all /force"; cmd.exe /c $command
    If ($FirmwareType -eq "0x1") {
        $command = "bcdboot C:\Windows /s S: /f BIOS"; cmd.exe /c $command
    } Else {
        $command = "bcdboot C:\Windows /s S: /f UEFI"; cmd.exe /c $command
    }
    $command = "bootrec /scanos"; cmd.exe /c $command
    $command = "bootrec /fixmbr"; cmd.exe /c $command
    $command = "bootrec /fixboot"; cmd.exe /c $command
    $command = "bootrec /rebuildbcd"; cmd.exe /c $command
    PAUSE
}

#############################################################################
#############################################################################
###                                                                       ###
###                          -=[ Script Body ]=-                          ###
###                                                                       ###
#############################################################################
#############################################################################
Menu