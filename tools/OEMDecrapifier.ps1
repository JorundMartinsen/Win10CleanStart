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

Function Remove-Office {
        Write-Host "Downloading tools to remove office installs"
        (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/JorundMartinsen/Win10CleanStart/office/officesetup.exe', 'C:\IT\officesetup.exe')
        (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/JorundMartinsen/Win10CleanStart/office/removeOffice.xml', 'C:\IT\removeOffice.xml')
        Write-Host "Removing office installs"
        C:\IT\officesetup /configure C:\IT\removeOffice.xml
}

Function Remove-HpDocumentation {
        Write-Host "Removing HP documentation"
        & 'C:\Program Files\HP\Documentation\Doc_uninstall.cmd'
}

Remove-HP
Remove-HPInc
Remove-HpPackages
Remove-OfficePackages
Remove-MicrosoftO365Package
Remove-Office
Remove-HpDocumentation