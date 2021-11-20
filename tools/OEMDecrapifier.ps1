Function Remove-HP {
    Write-Host "Removing Win32 apps from HP"
    $apps = Get-WmiObject -Class Win32_Product | Where-Object { $_.Vendor -like "HP" } -ErrorAction SilentlyContinue
    foreach ($app in $apps) { $app.Uninstall() }
} 

Function Remove-HPInc {
    Write-Host "Removing Win32 apps from HP Inc."
    $apps = Get-WmiObject -Class Win32_Product | Where-Object { $_.Vendor -like "HP Inc." }
    foreach ($app in $apps) { $app.Uninstall() }
} 

Function Remove-HpPackages {
    Write-Host "Removing packages matching HP*"
    $apps = Get-Package -Name "HP*" -ErrorAction SilentlyContinue
    Uninstall-Package $apps -Force -ErrorAction SilentlyContinue
} 

Function Remove-OfficePackages {
    Write-Host "Removing packages matching Office*"
    $apps = Get-Package -Name "Office*" -ErrorAction SilentlyContinue
    Uninstall-Package $apps -Force -ErrorAction SilentlyContinue
} 

Function Remove-MicrosoftO365Package {
    Write-Host "Removing packages matching Microsoft 365*"
    $apps = Get-Package -Name "Microsoft 365*" -ErrorAction SilentlyContinue
    Uninstall-Package $apps -Force -ErrorAction SilentlyContinue
} 

Function Remove-McAfee {
    Write-Host "Removing packages matching McAfee*"
    $apps = Get-Package -Name "McAfee*" -ErrorAction SilentlyContinue
    Uninstall-Package $apps -Force -ErrorAction SilentlyContinue
} 

Function Remove-WildTangent {
    Write-Host "Removing packages matching WildTangent*"
    $apps = Get-Package -Name "WildTangent*" -ErrorAction SilentlyContinue
    Uninstall-Package $apps -Force -ErrorAction SilentlyContinue
} 

Function Remove-ExpressVPN {
    Write-Host "Removing packages matching ExpressVPN*"
    $apps = Get-Package -Name "ExpressVPN*" -ErrorAction SilentlyContinue
    Uninstall-Package $apps -Force -ErrorAction SilentlyContinue
} 

Function Remove-Office {
    Write-Host "Downloading tools to remove office installs"
    If (!(Test-Path "C:\IT")) { New-Item -Path "C:\" -Name "IT" -ItemType "directory" }
    (New-Object System.Net.WebClient).DownloadFile('https://github.com/JorundMartinsen/Win10CleanStart/blob/main/office/officesetup.exe', 'C:\IT\officesetup.exe')
    (New-Object System.Net.WebClient).DownloadFile('https://github.com/JorundMartinsen/Win10CleanStart/blob/main/office/removeOffice.xml', 'C:\IT\removeOffice.xml')
    Write-Host "Removing office installs"
    C:\IT\officesetup /configure C:\IT\removeOffice.xml
}

Function Remove-HpDocumentation {
    Write-Host "Removing HP documentation"
    & 'C:\Program Files\HP\Documentation\Doc_uninstall.cmd'
}

Function Remove-WizLink {
    Write-Host "Removing WizLink"
    Remove-Item -Path "C:\Program Files (x86)\Online Services" -Recurse
}

Function Clean-StartMenuShortcuts {
    Write-Host "Cleaning up start menu shortcuts"
    $Shortcuts = Get-ChildItem -Recurse "C:\ProgramData\Microsoft\Windows\Start Menu\Programs" -Include *.lnk
    $Shell = New-Object -ComObject WScript.Shell
    foreach ($Shortcut in $Shortcuts)
    {
        $Target = $Shell.CreateShortcut($Shortcut).targetpath
        if (!(Test-Path $Target)) {
            Remove-Item $Shortcut
        }
    }
    [Runtime.InteropServices.Marshal]::ReleaseComObject($Shell) | Out-Null
}

Remove-HP
Remove-HPInc
Remove-HpPackages
Remove-OfficePackages
Remove-MicrosoftO365Package
Remove-McAfee
Remove-WildTangent
Remove-WizLink
Remove-Office
Remove-HpDocumentation
Clean-StartMenuShortcuts