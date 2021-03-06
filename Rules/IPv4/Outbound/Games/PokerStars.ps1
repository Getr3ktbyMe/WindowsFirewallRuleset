
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

. $PSScriptRoot\..\..\..\..\Config\ProjectSettings.ps1

# Check requirements
Initialize-Project -Abort

# Imports
. $PSScriptRoot\..\DirectionSetup.ps1
. $PSScriptRoot\..\..\IPSetup.ps1
Import-Module -Name Ruleset.Logging
Import-Module -Name Ruleset.UserInfo

# Setup local variables
$Group = "Games - Poker Stars"
$FirewallProfile = "Private, Public"
$Accept = "Outbound rules for Poker Stars game will be loaded, recommended if Poker Stars game is installed to let it access to network"
$Deny = "Skip operation, outbound rules for Poker Stars game will not be loaded into firewall"

# User prompt
Update-Context "IPv$IPVersion" $Direction $Group @Logs
if (!(Approve-Execute -Accept $Accept -Deny $Deny @Logs)) { exit }

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore @Logs

#
# Steam installation directories
#
$PokerStarsRoot = "%ProgramFiles(x86)%\PokerStars.EU"

#
# Rules for PokerStars game
#

# Test if installation exists on system
if ((Test-Installation "PokerStars" ([ref] $PokerStarsRoot) @Logs) -or $ForceLoad)
{
	$Program = "$PokerStarsRoot\PokerStars.exe"
	Test-File $Program @Logs

	New-NetFirewallRule -Platform $Platform `
		-DisplayName "PokerStars - Client" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443, 26002 `
		-LocalUser $UsersGroupSDDL `
		-Description "Main game interface." @Logs | Format-Output @Logs

	# NOTE: It looks like browser no longer needs any interface and any remote address
	$Program = "$PokerStarsRoot\br\PokerStarsBr.exe"
	Test-File $Program @Logs

	New-NetFirewallRule -Platform $Platform `
		-DisplayName "PokerStars - Browser" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
		-LocalUser $UsersGroupSDDL `
		-Description "In game HTML browser" @Logs | Format-Output @Logs

	$Program = "$PokerStarsRoot\PokerStarsOnlineUpdate.exe"
	Test-File $Program @Logs

	New-NetFirewallRule -Platform $Platform `
		-DisplayName "PokerStars - Online update" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80 `
		-LocalUser $UsersGroupSDDL `
		-Description "" @Logs | Format-Output @Logs

	$Program = "$PokerStarsRoot\PokerStarsUpdate.exe"
	Test-File $Program @Logs

	New-NetFirewallRule -Platform $Platform `
		-DisplayName "PokerStars - Update" -Service Any -Program $Program `
		-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
		-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80 `
		-LocalUser $UsersGroupSDDL `
		-Description "Game updater" @Logs | Format-Output @Logs
}

Update-Log
