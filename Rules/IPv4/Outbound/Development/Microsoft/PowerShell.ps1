
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2019, 2020 metablaster zebal@protonmail.ch

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

. $PSScriptRoot\..\..\..\..\..\Config\ProjectSettings.ps1

# Check requirements
Initialize-Project

# Imports
. $PSScriptRoot\..\..\DirectionSetup.ps1
. $PSScriptRoot\..\..\..\IPSetup.ps1
Import-Module -Name Project.AllPlatforms.Logging
Import-Module -Name Project.Windows.UserInfo

#
# Setup local variables
#
$Group = "Development - Microsoft PowerShell"
$FirewallProfile = "Private, Public"

# User prompt
Update-Context "IPv$IPVersion" $Direction $Group @Logs
if (!(Approve-Execute @Logs)) { exit }

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore @Logs

#
# PowerShell installation directories
#
$PowerShell64Root = "%SystemRoot%\System32\WindowsPowerShell\v1.0"
$PowerShell86Root = "%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0"
$PowerShellCore64Root = "%PROGRAMFILES%\PowerShell\7"

#
# Rules for PowerShell
#

# TODO: add rule for Core x86
# NOTE: administrators may need powershell, let them add them self temporary? currently adding them for PS x64
$PowerShellUsers = Get-SDDL -Group "Users", "Administrators" @Logs

# Test if installation exists on system
if ((Test-Installation "Powershell64" ([ref] $PowerShell64Root) @Logs) -or $ForceLoad)
{
	$Program = "$PowerShell64Root\powershell_ise.exe"
	Test-File $Program @Logs
	New-NetFirewallRule -Platform $Platform `
		-DisplayName "PowerShell ISE x64" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
		-LocalUser $UsersGroupSDDL `
		-Description "Rule to allow powershell help update" @Logs | Format-Output @Logs

	$Program = "$PowerShell64Root\powershell.exe"
	Test-File $Program @Logs
	New-NetFirewallRule -Platform $Platform `
		-DisplayName "PowerShell x64" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
		-LocalUser $PowerShellUsers `
		-Description "Rule to allow powershell help update" @Logs | Format-Output @Logs
}

# Test if installation exists on system
if ((Test-Installation "PowershellCore64" ([ref] $PowerShellCore64Root) @Logs) -or $ForceLoad)
{
	$Program = "$PowerShellCore64Root\pwsh.exe"
	Test-File $Program @Logs
	New-NetFirewallRule -Platform $Platform `
		-DisplayName "PowerShell Core x64" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
		-LocalUser $PowerShellUsers `
		-Description "Rule to allow powershell help update" @Logs | Format-Output @Logs
}

# Test if installation exists on system
if ((Test-Installation "Powershell86" ([ref] $PowerShell86Root) @Logs) -or $ForceLoad)
{
	$Program = "$PowerShell86Root\powershell_ise.exe"
	Test-File $Program @Logs
	New-NetFirewallRule -Platform $Platform `
		-DisplayName "PowerShell ISE x86" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
		-LocalUser $UsersGroupSDDL `
		-Description "Rule to allow powershell help update" @Logs | Format-Output @Logs

	$Program = "$PowerShell86Root\powershell.exe"
	Test-File $Program @Logs
	New-NetFirewallRule -Platform $Platform `
		-DisplayName "PowerShell x86" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
		-LocalUser $UsersGroupSDDL `
		-Description "Rule to allow powershell help update" @Logs | Format-Output @Logs
}

Update-Log
