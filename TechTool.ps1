#############################################################################
#############################################################################
###                                                                       ###
###                          -=[ Script Body ]=-                          ###
###                                                                       ###
#############################################################################
#############################################################################
#region Script Setup
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

#region Configure the UI settings
$Host.UI.RawUI.BackgroundColor = 'Black'
if ($psversiontable.PSversion.build -ne 17763) {
    #do not manipulate the window size in 1809 because MS broke powershell for that build
    [console]::WindowWidth=90
    [console]::BufferWidth=[console]::WindowWidth
    [console]::WindowHeight=40
}
Clear-Host
#endregion Configure the UI settings

#region Prompt to restart as administrator if not currently
$CurrentSessionAdmin=([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))
if (!$CurrentSessionAdmin) {
    Write-Host "`nScript is not being run as an Administrator." -ForegroundColor Red
    Write-Host "`nRe-launch as Admin or exit"
    Write-Host "[ENTER]" -NoNewline -ForegroundColor Green; Write-Host " Re-launch, " -NoNewline; Write-Host "[N]" -NoNewline -ForegroundColor Red; Write-Host " Exit:" -NoNewline
    $choiceInput = Read-Host
    switch -Regex ($choiceInput) {
        default {
            $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
            $newProcess.Arguments = "-executionpolicy bypass &'" + $script:MyInvocation.MyCommand.Path + "'"
            $newProcess.Verb = "runas";
            [System.Diagnostics.Process]::Start($newProcess);
            Exit
        }
        'N|n|x|X' {
            Exit
        }
    }
} else {
    #congratulate the user
    write-host "`nAdministrative permissions confirmed." -ForegroundColor Cyan
}
#endregion Prompt to restart as administrator if not currently

#region Manually Initialize TechTool Library
[string]$FilePath_Local_TechTool_Module = "C:\Program Files\WindowsPowerShell\Modules\TechTool\TechTool.psm1"
if (!(Test-Path $FilePath_Local_TechTool_Module)) {
    [string]$Name                           = "ImagingTool"
    [string]$Author                         = "PatrickSmith87"
    [string]$Branch                         = "master"
    [string]$Location                       = "C:\temp"

    #region Download GitHub Repo
    # Create the Zip file
    $ZipFile = "$Location\$Name.zip"
    New-Item $ZipFile -ItemType File -Force | Out-Null

    # Download the Zip file
    $ZipUrl = "https://github.com/$Author/$Name/archive/$Branch.zip"
    Invoke-RestMethod -Uri $ZipUrl -OutFile $ZipFile

    # Extract the Zip file
    Expand-Archive -Path $ZipFile -DestinationPath "$Location" -Force
 
    # Remove the Zip file
    Remove-Item -Path $ZipFile -Force

    Write-Host "Download GitHub Repo (to $Location): " -NoNewline; Write-Host "Complete" -ForegroundColor Green
    #endregion Download GitHub Repo

    #region Update Local Code (Only what is needed!)
    $PathPieces = $FilePath_Local_TechTool_Module.Split('\')
    $ParentFolderPath = $PathPieces[0]
    $x=1
    foreach ($Piece in $PathPieces) {  # Breaking down the destination file path and then rebuilding it without the filename so that we get a path to it's parent folder
        If ($x -lt ($PathPieces.Count - 1)) {
            $ParentFolderPath = $ParentFolderPath + "\" + $PathPieces[$x]
            $x++
        }
    }
    If (!(Test-Path $ParentFolderPath)) {New-Item $ParentFolderPath -ItemType Directory | Out-Null}
    Copy-Item -Path "$Location\$Name-main\TechTool.psm1" -Destination $ParentFolderPath -Force
    #endregion Update Local Code (Only what is needed!)

    #region Import Modules
    Import-Module TechTool -WarningAction SilentlyContinue -Force | Out-Null
    #endregion Import Modules
}
#endregion Manually Initialize TechTool Library

#endregion Script Setup

$TechTool = New-TechTool
$TechTool.DisplayMenu()