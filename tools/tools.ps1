Function Add-User {
	Param
	(
		[string]$user,
		[securestring]$password = ([securestring]::new()),
        [string]$group
	)

	Write-Host "Creating user " + $user 
	# Create admin user
	New-LocalUser -Name $user -Password $password -AccountNeverExpires -PasswordNeverExpires -UserMayNotChangePassword
	Write-Host "User created"
	Add-LocalGroupMember -Group $group -Member $user
	Write-Host "User successfully added to $group"
}

Function Clear-Password {
	Param
	(
		[string]$user
	)

	Write-Host "Clear password for user $user"
	# Remove user password
	Set-LocalUser -name $user -Password ([securestring]::new())
	Write-Host "End of Clear password"
}

Function Set-AutoLogon ([string]$user, [string]$pass) {
	Write-Host "Set autologon"
	#Registry path declaration
	$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
	[String]$DefaultUsername = $user
	[String]$DefaultPassword = $pass
	#setting registry values
	Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String
	Set-ItemProperty $RegPath "DefaultUsername" -Value $DefaultUsername -type String
	Set-ItemProperty $RegPath "DefaultPassword" -Value $DefaultPassword -type String
	Set-ItemProperty $RegPath "AutoLogonCount" -Value "1" -type DWord
	Write-Host "End of Set autologon"
}

Function Disable-OOBE {
	Write-Host "Disable OOBE"

	REG add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v SkipMachineOOBE /t REG_DWORD /d "1" /f

	REG add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v LaunchUserOOBE /t REG_DWORD /d "1" /f

	REG add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v PrivacyConsentStatus /t REG_DWORD /d "1" /f

	REG add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE" /v DisablePrivacyExperience /t REG_DWORD /d "1" /f
}

Function Disable-FastStartup {
	Write-Host "Disable Windows Fast Startup"
	REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d "0" /f
	powercfg -h off
}

Function Disable-Sleep {
	<#
.Synopsis
   Function to suspend your current Power Plan settings when running a PowerShell script.
.DESCRIPTION
   Function to suspend your current Power Plan settings when running a PowerShell script.
   Scenario: When downloading files using Robocopy from PowerShell you don't want your
   laptop to go into sleep mode.
.EXAMPLE
   Disable-Sleep -option Display -Verbose
   Run mylongrunningscript with Display idle timeout prevented and verbose messages
.LINK
  http://www.microsofttranslator.com/bv.aspx?from=ru&to=en&a=http%3A%2F%2Fsocial.technet.microsoft.com%2FForums%2Fen-US%2F1f4754cb-37bf-4e1d-a59f-ec0f1aaf9d1c%2Fsetthreadexecutionstate-powershell%3FThread%3A1f4754cb-37bf-4e1d-a59f-ec0f1aaf9d1c%3DMicrosoft.Forums.Data.Models.Discussion%26ThreadViewModel%3A1f4754cb-37bf-4e1d-a59f-ec0f1aaf9d1c%3DMicrosoft.Forums.CachedViewModels.ThreadPageViewModel%26forum%3Dscrlangru
#>
	[CmdletBinding()]
	[Alias()]
	[OutputType([int])]
	Param
	(
		# Param1 help description
		#[Parameter(Mandatory=$true,
		#           Position=0)]
		#$script,
		[ValidateSet("Away", "Display", "System")]
		[string]$option = "Display"

	)

	$code = @'
[DllImport("kernel32.dll", CharSet = CharSet.Auto,SetLastError = true)]
  public static extern void SetThreadExecutionState(uint esFlags);
'@

	$ste = Add-Type -memberDefinition $code -name System -namespace Win32 -passThru
	$ES_CONTINUOUS = [uint32]"0x80000000" #Requests that the other EXECUTION_STATE flags set remain in effect until SetThreadExecutionState is called again with the ES_CONTINUOUS flag set and one of the other EXECUTION_STATE flags cleared.
	$ES_AWAYMODE_REQUIRED = [uint32]"0x00000040" #Requests Away Mode to be enabled.
	$ES_DISPLAY_REQUIRED = [uint32]"0x00000002" #Requests display availability (display idle timeout is prevented).
	$ES_SYSTEM_REQUIRED = [uint32]"0x00000001" #Requests system availability (sleep idle timeout is prevented).

	Switch ($option) {
		"Away" { $setting = $ES_AWAYMODE_REQUIRED }
		"Display" { $setting = $ES_DISPLAY_REQUIRED }
		"System" { $setting = $ES_SYSTEM_REQUIRED }
		Default { $setting = $ES_SYSTEM_REQUIRED }

	}

	Write-Host "Power Plan suspended with option: $option"

	$ste::SetThreadExecutionState($ES_CONTINUOUS -bor $setting)
	Write-Host "`nComputer sleep has been temporarily disabled. Use the command 'Enable-Sleep' when done."
}

Function Disconnect-AllUsers {
	<#
	.DESCRIPTION
		Logs off all users from a machine.
#>
	(quser) -replace ">", " " -replace "\s+", "," -replace "IDLE,TIME", "IDLE TIME" -replace "LOGON,TIME", "LOGON TIME" | ConvertFrom-Csv -Delimiter "," | foreach {
		logoff ($_.ID)
	}
}

Function Enable-SSL {
	Write-Host "Enabling SSL"
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
}

Function Expand-Terminal {
	mode con: cols=160 lines=120
}

Function Get-ITFunctions {
	If (Get-Module -Name ITFunctions -ErrorAction SilentlyContinue) {
		# List imported functions from ITFunctions
		Write-Host ====================================================
		Write-Host "The below functions are now loaded and ready to use:"
		Write-Host ====================================================
		Get-Command -Module ITFunctions | Format-Wide -Column 3
		Write-Host ====================================================
		Write-Host "Type: 'Help <function name> -Detailed' for more info"
		Write-Host ====================================================
	}
 Else {
		$progressPreference = 'silentlyContinue'
		iwr https://raw.githubusercontent.com/JorundMartinsen/Win10CleanStart/main/tools/tools.ps1 -UseBasicParsing | iex
		# List imported functions from ITFunctions
		Write-Host ====================================================
		Write-Host "The below functions are now loaded and ready to use:"
		Write-Host ====================================================
		Get-Command -Module ITFunctions | Format-Wide -Column 3
		Write-Host ====================================================
		Write-Host "Type: 'Help <function name> -Detailed' for more info"
		Write-Host ====================================================
	}
}

Function Install-AppDefaults {
	Write-Host "Downloading App Defaults"
	New-Item -ItemType Directory -Force -Path C:\IT\PPKG
	(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/JorundMartinsen/Win10CleanStart/main/config/AppDefaults.xml', 'C:\IT\AppDefaults.xml')
	Write-Host "Deploying App Defaults"
	Dism.exe /online /import-defaultappassociations:'C:\IT\AppDefaults.xml'
}

Function Install-Choco {
	Write-Host "Installing Chocolatey"
	$progressPreference = 'silentlyContinue'
	Set-ExecutionPolicy Bypass -Scope Process -Force
	Enable-SSL
	Invoke-WebRequest https://community.chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
}

Function Set-SoundScheme {
	Write-Host "Setting sound scheme to none"

	New-ItemProperty -Path HKCU:\AppEvents\Schemes -Name "(Default)" -Value ".None" -Force | Out-Null

	Get-ChildItem -Path "HKCU:\AppEvents\Schemes\Apps" | Get-ChildItem | Get-ChildItem | Where-Object {$_.PSChildName -eq ".Current"} | Set-ItemProperty -Name "(Default)" -Value ""
    
	Set-ItemProperty -Path 'HKCU:\AppEvents\Schemes\Apps\.Default\.Default\.Current' -Name "(Default)" -Value "C:\Windows\media\notify.wav" -Type String -Force
    
	Set-ItemProperty -Path 'HKCU:\AppEvents\Schemes\Apps\.Default\.Default\.Modified' -Name "(Default)" -Value "C:\Windows\media\notify.wav" -Type String -Force
}

Function Disable-Notifications {
	Write-Host "Disable notifications"
	Reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /V DisableNotificationCenter /D 1 /T REG_DWORD /F

	Reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /V ScoobeSystemSettingEnabled /D 0 /T REG_DWORD /F

	Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /V ToastEnabled /D 0 /T REG_DWORD /F
}

Function Disable-Firewall {
	Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
	$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
	Set-RegKey -path $path -value 1 -name "NoToastApplicationNotification"
	Set-RegKey -path $path -value 1 -name "NoToastApplicationNotificationOnLockScreen"
	$path = "HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications"
	Set-RegKey -path $path -value 1 -name "DisableEnhancedNotifications"
	# $path = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Spynet"
	# Set-RegKey -path $path -value 0 -name "SpyNetReporting"
	# Set-RegKey -path $path -value 0 -name "SubmitSamplesConsent"
}
Function Disable-Antivirus {
	Set-MpPreference -DisableRealtimeMonitoring $true
}
Function Disable-AppAndBrowserControl {
	$path = "HKCU:\SOFTWARE\Microsoft\Windows Security Health\State"
	Set-RegKey -path $path -value 0 -name "AppAndBrowser_EdgeSmartScreenOff"
	Set-RegKey -path $path -value 0 -name "AppAndBrowser_StoreAppsSmartScreenOff"
	$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
	Set-RegKey -path $path -value "Off" -name "SmartScreenEnabled"
}
Function Add-DotNet35 {
	DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
}

Function Set-PowerScheme {
	param (
		$name
	)
	$schemeRow = powercfg -list | findstr $name
	$guid = $schemeRow.Substring(19, 36)
	powercfg -setactive $guid
}

Function Set-PowerSettings {
	# Set power configuration
	Set-PowerScheme -name "High Performance"

	# Set timeout to never
	powercfg -change -monitor-timeout-ac 0
	powercfg -change -disk-timeout-ac 0
	powercfg -change -standby-timeout-ac 0
	powercfg -change -hibernate-timeout-ac 0
}

Function Set-DesktopBackground ([string]$name = 'EM') {
    (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/JorundMartinsen/Win10CleanStart/main/images/' + $name + '.png', 'C:\IT\background.png')
    
	Set-RegKey -path 'HKCU:\Control Panel\Desktop\' -name Wallpaper -value "C:\IT\background.png"
	Set-RegKey -path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' -name LockScreenImage -value "C:\IT\background.png"
	Set-RegKey -path 'HKCU:\Control Panel\Desktop\' -name TileWallpaper -value "0"
	Set-RegKey -path 'HKCU:\Control Panel\Desktop\' -name WallpaperStyle -value "10" -Force
}

Function Invoke-Win10Decrap {
	Write-Host "Windows 10 Decrapifier"
	#Based on https://community.spiceworks.com/scripts/show/4378-windows-10-decrapifier-18xx-19xx-2xxx
	$progressPreference = 'silentlyContinue'
	Set-ExecutionPolicy Bypass -Scope Process -Force
	Enable-SSL
	Invoke-WebRequest https://raw.githubusercontent.com/JorundMartinsen/Win10CleanStart/main/tools/Windows10Decrapifier.ps1 -UseBasicParsing | Invoke-Expression
}

Function Invoke-OEMDecrap {
	Write-Host "OEM Decrapifier"
	$progressPreference = 'silentlyContinue'
	Set-ExecutionPolicy Bypass -Scope Process -Force
	Enable-SSL
	Invoke-WebRequest https://raw.githubusercontent.com/JorundMartinsen/Win10CleanStart/main/tools/OEMDecrapifier.ps1 -UseBasicParsing | Invoke-Expression
}

Function Remove-PPKGInstallFolder {
	Write-Host "Cleaning up and Restarting Computer"
	PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "If (Test-Path C:\IT\PPKG){Remove-Item -LiteralPath 'C:\IT\PPKG' -Force -Recurse};Restart-Computer -Force"
	Stop-transcript
	Restart-Computer -Force
}

Function Rename-ClientComputer {
	Write-Host "Rename Computer"
	$title = 'Rename Computer'
	$msg = 'Enter the computer name'
	$default = 'MASTER'
	#Message box prompts onscreen for input
	[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
	$ClientCode = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, $default)
	Rename-Computer ($ClientCode) -Force
	Write-Host "End of Rename Computer"
}

Function Set-UTCTime {
	Write-Host "Setting local time zone to UTC"
	Set-TimeZone -Name "Co-ordinated Universal Time"
	net start W32Time
	W32tm /resync /force
}

Function Disable-SetTimeAutomatically {
	Write-Host "Setting no time sync"
	Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters' -Name "Type" -Value "NoSync" -Force -PassThru
}

Function Set-NumLock {
	Write-Host "Setting Numlock on keyboard as default"
	Set-ItemProperty -Path 'Registry::HKU\.DEFAULT\Control Panel\Keyboard' -Name "InitialKeyboardIndicators" -Value "2" -Force -PassThru
}

Function Set-RunOnceScript {
	param
	(
		[string]$Label,
		[string]$Script
	)

	$RunOnceValue = 'PowerShell.exe -ExecutionPolicy Bypass -File "' + $Script + '"'
	Write-Host "Install After Reboot"
	Set-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name $Label -Value $RunOnceValue
}

Function Start-PPKGLog ([String] $LogLabel) {
	Write-Host "Making a log file for debugging"
	$LogPath = "C:\IT\" + $SiteCode + "-" + $LogLabel + ".log"
	Start-Transcript -path $LogPath -Force -Append
}

Function Update-Edge {
	Write-Host "Updating Microsoft Edge"
	If (!(Get-Command choco -ErrorAction SilentlyContinue)) { Install-Choco }
	If (Get-Process MicrosoftEdge -ErrorAction SilentlyContinue) { Get-Process MicrosoftEdge | Stop-Process -Force }
	Choco upgrade microsoft-edge -y
}

Function Update-PWSH {
	Write-Host "Updating PWSH"
	If (!(Get-Command choco -ErrorAction SilentlyContinue)) { Install-Choco }
	Choco upgrade pwsh -y
}

Function Update-Windows {
	Write-Host "Install Windows Updates"
	Set-ExecutionPolicy Bypass -Scope Process -Force
	Enable-SSL
	Install-PackageProvider -Name NuGet -Force
	Invoke-WebRequest https://raw.githubusercontent.com/AmbitionsTechnologyGroup/ATG-PS-Functions/master/Scripts/Windows-Update/UpdateWindows.txt -UseBasicParsing | Invoke-Expression
	Write-Host "End of Install Windows Updates"
}

Function Update-WindowsApps {
	Write-Host "Updating Windows Apps"
	Start-Process ms-windows-store:
	Start-Sleep -Seconds 5
		(Get-WmiObject -Namespace "root\cimv2\mdm\dmmap" -Class "MDM_EnterpriseModernAppManagement_AppManagement01").UpdateScanMethod()
	Write-Host "Update Windows Apps initiated"
}

Function Update-WindowTitle ([String] $PassNumber) {
	Write-Host "Changing window title"
	$host.ui.RawUI.WindowTitle = "$SiteCode Provisioning | $env:computername | Pass $PassNumber | Please Wait"
}


Function Set-RegKey {
	param (
		$path,
		$name,
		$value
	)
	IF (!(Test-Path -Path $path)) {  
		New-Item $path -ItemType Directory
	}
	Set-ItemProperty -Path $path -Name $name -Value $value
}

If (Get-Module -Name ITFunctions -ErrorAction SilentlyContinue) {
	# List imported functions from ITFunctions
	Write-Host `n====================================================
	Write-Host "The below functions are now loaded and ready to use:"
	Write-Host ====================================================

	Get-Command -Module ITFunctions | Format-Wide -Column 3

	Write-Host ====================================================
	Write-Host "Type: 'Help <function name> -Detailed' for more info"
	Write-Host ====================================================
}