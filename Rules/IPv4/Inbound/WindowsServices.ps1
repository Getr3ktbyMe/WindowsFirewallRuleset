
<#
MIT License

Project: "Windows Firewall Ruleset" serves to manage firewall on Windows systems
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

. $PSScriptRoot\..\..\..\Config\ProjectSettings.ps1

# Check requirements for this project
Test-SystemRequirements

# Imports
. $PSScriptRoot\DirectionSetup.ps1
. $PSScriptRoot\..\IPSetup.ps1
Import-Module -Name Project.AllPlatforms.Logging
Import-Module -Name Project.Windows.UserInfo

#
# Setup local variables:
#
$Group = "Windows Services"
# $FirewallProfile = "Private, Public"

# Ask user if he wants to load these rules
Update-Context "IPv$IPVersion" $Direction $Group @Logs
if (!(Approve-Execute @Logs)) { exit }

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore @Logs

#
# Windows services rules
# Rules that apply to Windows services which are not handled by predefined rules
#

#
# Delivery Optimization predefined rules
#

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Delivery Optimization" -Service DoSvc -Program $ServiceHost `
	-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile Private, Domain -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort 7680 -RemotePort Any `
	-EdgeTraversalPolicy Allow -LocalUser Any `
	-Description "Service responsible for delivery optimization.
Windows Update Delivery Optimization works by letting you get Windows updates and Microsoft Store apps from sources in addition to Microsoft,
like other PCs on your local network, or PCs on the Internet that are downloading the same files.
Delivery Optimization also sends updates and apps from your PC to other PCs on your local network or PCs on the Internet, based on your settings." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Delivery Optimization" -Service DoSvc -Program $ServiceHost `
	-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile Private, Domain -InterfaceType $Interface `
	-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort 7680 -RemotePort Any `
	-EdgeTraversalPolicy Allow -LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "Service responsible for delivery optimization.
Windows Update Delivery Optimization works by letting you get Windows updates and Microsoft Store apps from sources in addition to Microsoft,
like other PCs on your local network, or PCs on the Internet that are downloading the same files.
Delivery Optimization also sends updates and apps from your PC to other PCs on your local network or PCs on the Internet, based on your settings." @Logs | Format-Output @Logs

#
# @FirewallAPI.dll,-80204 predefined rule
#

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Windows Camera Frame Server" -Service FrameServer -Program $ServiceHost `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private, Public -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort 554, 8554-8558 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any `
	-Description "Service enables multiple clients to access video frames from camera devices." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Windows Camera Frame Server" -Service FrameServer -Program $ServiceHost `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private, Public -InterfaceType $Interface `
	-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort 5000-5020 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "Service enables multiple clients to access video frames from camera devices." @Logs | Format-Output @Logs

Update-Log
