
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
Initialize-Project -Abort

# Imports
. $PSScriptRoot\..\..\DirectionSetup.ps1
. $PSScriptRoot\..\..\..\IPSetup.ps1
Import-Module -Name Ruleset.Logging
Import-Module -Name Ruleset.UserInfo

# Setup local variables
$Group = "Microsoft - Edge Chromium"
$FirewallProfile = "Private, Public"
$Accept = "Outbound rules for Edge Chromium browser will be loaded, recommended if Edge Chromium is installed to let it access to network"
$Deny = "Skip operation, outbound rules for internet browsers will not be loaded into firewall"

# User prompt
Update-Context "IPv$IPVersion" $Direction $Group @Logs
if (!(Approve-Execute -Accept $Accept -Deny $Deny @Logs)) { exit }

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore @Logs

#
# Browser installation directories
# TODO: returned path will miss browser updater
#
$EdgeChromiumRoot = "%ProgramFiles(x86)%\Microsoft\Edge\Application"

#
# Microsoft Edge-Chromium
#

# Test if installation exists on system
if ((Test-Installation "EdgeChromium" ([ref] $EdgeChromiumRoot) @Logs) -or $ForceLoad)
{
	# TODO: no FTP rule
	$EdgeChromiumApp = "$EdgeChromiumRoot\msedge.exe"
	Test-File $EdgeChromiumApp

	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Edge-Chromium HTTP" -Service Any -Program $EdgeChromiumApp `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80 `
		-LocalUser $UsersGroupSDDL `
		-Description "Hyper text transfer protocol." @Logs | Format-Output @Logs

	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Edge-Chromium QUIC" -Service Any -Program $EdgeChromiumApp `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
		-LocalUser $UsersGroupSDDL -LocalOnlyMapping $false -LooseSourceMapping $false `
		-Description "Quick UDP Internet Connections,
	Experimental transport layer network protocol developed by Google and implemented in 2013." @Logs | Format-Output @Logs

	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Edge-Chromium HTTPS" -Service Any -Program $EdgeChromiumApp `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
		-LocalUser $UsersGroupSDDL `
		-Description "Hyper text transfer protocol over SSL." @Logs | Format-Output @Logs

	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Edge-Chromium speedtest" -Service Any -Program $EdgeChromiumApp `
		-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 5060, 8080 `
		-LocalUser $UsersGroupSDDL `
		-Description "Ports needed for https://speedtest.net" @Logs | Format-Output @Logs

	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Edge-Chromium FTP" -Service Any -Program $EdgeChromiumApp `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 21 `
		-LocalUser $UsersGroupSDDL `
		-Description "File transfer protocol." @Logs | Format-Output @Logs

	# TODO: Figure out why edge chromium needs this rule, do additional test and update description
	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Edge-Chromium SSDP" -Service Any -Program $EdgeChromiumApp `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress 239.255.255.250 -LocalPort Any -RemotePort 1900 `
		-LocalUser $UsersGroupSDDL `
		-Description "" @Logs | Format-Output @Logs

	# TODO: we should probably have a function for this and similar cases?
	$EdgeUpdateRoot = "$(Split-Path -Path $(Split-Path -Path $EdgeChromiumRoot -Parent) -Parent)\EdgeUpdate"
	$EdgeChromiumUpdate = "$EdgeUpdateRoot\MicrosoftEdgeUpdate.exe"
	Test-File $EdgeChromiumUpdate

	$UpdateAccounts = Get-SDDL -Domain "NT AUTHORITY" -User "SYSTEM" @Logs
	Merge-SDDL ([ref] $UpdateAccounts) $UsersGroupSDDL @Logs

	New-NetFirewallRule -Platform $Platform `
		-DisplayName "Edge-Chromium Update" -Service Any -Program $EdgeChromiumUpdate `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
		-LocalUser $UpdateAccounts `
		-Description "Update Microsoft Edge" @Logs | Format-Output @Logs
}

Update-Log
