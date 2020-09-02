
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

. $PSScriptRoot\..\..\..\Config\ProjectSettings.ps1

# Check requirements
Initialize-Project

# Imports
. $PSScriptRoot\DirectionSetup.ps1
. $PSScriptRoot\..\IPSetup.ps1
Import-Module -Name Project.AllPlatforms.Logging
Import-Module -Name Project.Windows.UserInfo

# Setup local variables
$Group = "Additional Networking"
$Accept = "Inbound rules for additional networking will be loaded, recommended for specific scenarios"
$Deny = "Skip operation, inbound additional networking rules will not be loaded into firewall"

# User prompt
Update-Context "IPv$IPVersion" $Direction $Group @Logs
if (!(Approve-Execute -Accept $Accept -Deny $Deny @Logs)) { exit }

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore @Logs

#
# Firewall predefined rules related to networking not handled by other more strict scripts
#

#
# Cast to device predefined rules
#

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Cast to Device functionality (qWave)" -Service QWAVE -Program $ServiceHost `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private, Public -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress PlayToDevice4 -LocalPort 2177 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any `
	-Description "Inbound rule for the Cast to Device functionality to allow use of the Quality Windows Audio Video Experience Service.
Quality Windows Audio Video Experience (qWave) is a networking platform for Audio Video (AV) streaming applications on IP home networks.
qWave enhances AV streaming performance and reliability by ensuring network quality-of-service (QoS) for AV applications.
It provides mechanisms for admission control, run time monitoring and enforcement, application feedback, and traffic prioritization." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Cast to Device functionality (qWave)" -Service QWAVE -Program $ServiceHost `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private, Public -InterfaceType $Interface `
	-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress PlayToDevice4 -LocalPort 2177 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "Inbound rule for the Cast to Device functionality to allow use of the Quality Windows Audio Video Experience Service.
Quality Windows Audio Video Experience (qWave) is a networking platform for Audio Video (AV) streaming applications on IP home networks.
qWave enhances AV streaming performance and reliability by ensuring network quality-of-service (QoS) for AV applications.
It provides mechanisms for admission control, run time monitoring and enforcement, application feedback, and traffic prioritization." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Cast to Device SSDP Discovery" -Service SSDPSRV -Program $ServiceHost `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private, Public -InterfaceType $Interface `
	-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress Any -LocalPort PlayToDiscovery -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "Inbound rule to allow discovery of Cast to Device targets using SSDP." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Cast to Device streaming server (HTTP)" -Service Any -Program System `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Domain -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Any -LocalPort 10246 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System `
	-Description "Inbound rule for the Cast to Device server to allow streaming using HTTP." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Cast to Device streaming server (HTTP)" -Service Any -Program System `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort 10246 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System `
	-Description "Inbound rule for the Cast to Device server to allow streaming using HTTP." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Cast to Device streaming server (HTTP)" -Service Any -Program System `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Public -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress PlayToDevice4 -LocalPort 10246 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System `
	-Description "Inbound rule for the Cast to Device server to allow streaming using HTTP." @Logs | Format-Output @Logs

$mdeserver = "%SystemRoot%\System32\mdeserver.exe"
Test-File $mdeserver

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Cast to Device streaming server (RTCP)" -Service Any -Program $mdeserver `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Public -InterfaceType $Interface `
	-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress PlayToDevice4 -LocalPort Any -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "Inbound ror the Cast to Device server to allow streaming using RTSP and RTP." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Cast to Device streaming server (RTCP)" -Service Any -Program $mdeserver `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private -InterfaceType $Interface `
	-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort Any -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "Inbound rule for the Cast to Device server to allow streaming using RTSP and RTP." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Cast to Device streaming server (RTCP)" -Service Any -Program $mdeserver `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Domain -InterfaceType $Interface `
	-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress Any -LocalPort Any -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "Inbound rule for the Cast to Device server to allow streaming using RTSP and RTP." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Cast to Device streaming server (RTSP)" -Service Any -Program $mdeserver `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Public -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress PlayToDevice4 -LocalPort 23554-23556 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any `
	-Description "Inbound rule for the Cast to Device server to allow streaming using RTSP and RTP." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Cast to Device streaming server (RTSP)" -Service Any -Program $mdeserver `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort 23554-23556 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any `
	-Description "Inbound rule for the Cast to Device server to allow streaming using RTSP and RTP." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Cast to Device streaming server (RTSP)" -Service Any -Program $mdeserver `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Domain -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Any -LocalPort 23554-23556 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any `
	-Description "Inbound rule for the Cast to Device server to allow streaming using RTSP and RTP." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Cast to Device UPnP Events" -Service Any -Program System `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Public -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress PlayToDevice4 -LocalPort 2869 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System `
	-Description "Inbound rule to allow receiving UPnP Events from Cast to Device targets." @Logs | Format-Output @Logs

#
# Connected devices platform predefined rules
#

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Connected Devices Platform - Wi-Fi Direct Transport" -Service CDPSvc -Program $ServiceHost `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Public -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Any -LocalPort Any -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any `
	-Description "Inbound rule to use Wi-Fi Direct traffic in the Connected Devices Platform." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Connected Devices Platform" -Service CDPSvc -Program $ServiceHost `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private, Domain -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Any -LocalPort Any -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any `
	-Description "Inbound rule for Connected Devices Platform traffic." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Connected Devices Platform" -Service CDPSvc -Program $ServiceHost `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private, Domain -InterfaceType $Interface `
	-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress Any -LocalPort Any -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "Inbound rule for Connected Devices Platform traffic." @Logs | Format-Output @Logs

#
# AllJoyn Router predefined rules
#

New-NetFirewallRule -Platform $Platform `
	-DisplayName "AllJoyn Router" -Service AJRouter -Program $ServiceHost `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private, Domain -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Any -LocalPort 9955 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any `
	-Description "Inbound rule for AllJoyn Router traffic.
AllJoyn Router service routes AllJoyn messages for the local AllJoyn clients.
If this service is stopped the AllJoyn clients that do not have their own bundled routers will be unable to run." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "AllJoyn Router" -Service AJRouter -Program $ServiceHost `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private, Domain -InterfaceType $Interface `
	-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress Any -LocalPort Any -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "Inbound rule for AllJoyn Router traffic.
AllJoyn Router service routes AllJoyn messages for the local AllJoyn clients.
If this service is stopped the AllJoyn clients that do not have their own bundled routers will be unable to run." @Logs | Format-Output @Logs

#
# Proximity sharing predefined rules
#

# NOTE: probably does not exist in Windows Server 2019
$Program = "%SystemRoot%\System32\ProximityUxHost.exe"
Test-File $Program @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Proximity sharing" -Service Any -Program $Program `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private, Public -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Any -LocalPort Any -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any `
	-Description "Inbound rule for Proximity sharing over." @Logs | Format-Output @Logs

#
# DIAL Protocol predefined rules
#

New-NetFirewallRule -Platform $Platform `
	-DisplayName "DIAL protocol server (HTTP)" -Service Any -Program System `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Private -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort 10247 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System `
	-Description "rule for DIAL protocol server to allow remote control of Apps using HTTP.
Discovery and Launch (DIAL) is a protocol co-developed by Netflix and YouTube with help from Sony and Samsung.
It is a mechanism for discovering and launching applications on a single subnet, typically a home network.
It relies on Universal Plug and Play (UPnP), Simple Service Discovery Protocol (SSDP), and HTTP protocols." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "DIAL protocol server (HTTP)" -Service Any -Program System `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile Domain -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Intranet4 -LocalPort 10247 -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System `
	-Description "rule for DIAL protocol server to allow remote control of Apps using HTTP.
Discovery and Launch (DIAL) is a protocol co-developed by Netflix and YouTube with help from Sony and Samsung.
It is a mechanism for discovering and launching applications on a single subnet, typically a home network.
It relies on Universal Plug and Play (UPnP), Simple Service Discovery Protocol (SSDP), and HTTP protocols." @Logs | Format-Output @Logs

Update-Log
