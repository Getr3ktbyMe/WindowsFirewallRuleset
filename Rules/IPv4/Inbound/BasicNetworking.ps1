
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
Initialize-Project -Abort

# Imports
. $PSScriptRoot\DirectionSetup.ps1
. $PSScriptRoot\..\IPSetup.ps1
Import-Module -Name Project.AllPlatforms.Logging
Import-Module -Name Project.Windows.UserInfo

# Setup local variables
$Group = "Basic Networking - IPv4"
$FirewallProfile = "Any"
$Accept = "Inbound rules for basic networking will be loaded, required for proper network funcioning"
$Deny = "Skip operation, inbound basic networking rules will not be loaded into firewall"

# User prompt
Update-Context "IPv$IPVersion" $Direction $Group @Logs
if (!(Approve-Execute -Accept $Accept -Deny $Deny @Logs)) { exit }

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore @Logs

# TODO: specifying -InterfaceAlias $Loopback does not work, dropped packets
# NOTE: even though we specify "IPv4 the loopback interface alias is the same for for IPv4 and IPv6, meaning there is only one loopback interface!"
# $Loopback = Get-NetIPInterface | Where-Object {$_.InterfaceAlias -like "*Loopback*" -and $_.AddressFamily -eq "IPv4"} | Select-Object -ExpandProperty InterfaceAlias

#
# Predefined rules from Core Networking are here
#

#
# Loopback
# Used on TCP, UDP, IGMP
#

# TODO: is there a need or valid reason to make rules for "this machine"? (0.0.0.0)
# TODO: should we use -InterfaceAlias set to Loopback pseudo interface?
New-NetFirewallRule -Platform $Platform `
	-DisplayName "Loopback" -Service Any -Program Any `
	-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType Any `
	-Direction $Direction -Protocol Any -LocalAddress Any -RemoteAddress 127.0.0.1 -LocalPort Any -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any `
	-Description "Network software and utilities use loopback address to access a local computer's TCP/IP network resources." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform `
	-DisplayName "Loopback" -Service Any -Program Any `
	-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType Any `
	-Direction $Direction -Protocol Any -LocalAddress 127.0.0.1 -RemoteAddress Any -LocalPort Any -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any `
	-Description "Network software and utilities use loopback address to access a local computer's TCP/IP network resources." @Logs | Format-Output @Logs

#
# mDNS (Multicast Domain Name System)
# NOTE: this should be placed in Multicast.ps1 like it is for IPv6, but it's here because of specific address,
# which is part of "Local Network Control Block" (224.0.0.0 - 224.0.0.255)
# An mDNS message is a multicast UDP packet sent using the following addressing:
# IPv4 address 224.0.0.251 or IPv6 address ff02::fb
# UDP port 5353
# https://en.wikipedia.org/wiki/Multicast_DNS
#

New-NetFirewallRule -Platform $Platform -PolicyStore $PolicyStore `
	-DisplayName "Multicast Domain Name System" -Service Dnscache -Program $ServiceHost `
	-Enabled True -Action Allow -Group $Group -Profile Private, Domain -InterfaceType $Interface `
	-Direction $Direction -Protocol UDP -LocalAddress 224.0.0.251 -RemoteAddress LocalSubnet4 -LocalPort 5353 -RemotePort 5353 `
	-EdgeTraversalPolicy Block -LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "In computer networking, the multicast DNS (mDNS) protocol resolves hostnames to IP addresses
within small networks that do not include a local name server.
It is a zero-configuration service, using essentially the same programming interfaces,
packet formats and operating semantics as the unicast Domain Name System (DNS)." @Logs | Format-Output @Logs

New-NetFirewallRule -Platform $Platform -PolicyStore $PolicyStore `
	-DisplayName "Multicast Domain Name System" -Service Dnscache -Program $ServiceHost `
	-Enabled True -Action Block -Group $Group -Profile Public -InterfaceType $Interface `
	-Direction $Direction -Protocol UDP -LocalAddress 224.0.0.251 -RemoteAddress LocalSubnet4 -LocalPort 5353 -RemotePort 5353 `
	-EdgeTraversalPolicy Block -LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "In computer networking, the multicast DNS (mDNS) protocol resolves hostnames to IP addresses
within small networks that do not include a local name server.
It is a zero-configuration service, using essentially the same programming interfaces,
packet formats and operating semantics as the unicast Domain Name System (DNS)." @Logs | Format-Output @Logs

#
# DHCP (Dynamic Host Configuration Protocol)
#

New-NetFirewallRule -Platform $Platform -PolicyStore $PolicyStore `
	-DisplayName "Dynamic Host Configuration Protocol" -Service Dhcp -Program $ServiceHost `
	-Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
	-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress DHCP4 -LocalPort 68 -RemotePort 67 `
	-EdgeTraversalPolicy Block -LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "Allow DHCPv4 messages for stateful auto-configuration.
UDP port number 67 is the destination port of a server, and UDP port number 68 is used by the client." `
	@Logs | Format-Output @Logs

#
# IGMP (Internet Group Management Protocol)
#

New-NetFirewallRule -Platform $Platform -PolicyStore $PolicyStore `
	-DisplayName "Internet Group Management Protocol" -Service Any -Program System `
	-Enabled True -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
	-Direction $Direction -Protocol 2 -LocalAddress Any -RemoteAddress LocalSubnet4 -LocalPort Any -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System `
	-Description "IGMP messages are sent and received by nodes to create, join and depart multicast groups." @Logs | Format-Output @Logs

#
# IPHTTPS (IPv4 over HTTPS)
#

New-NetFirewallRule -Platform $Platform -PolicyStore $PolicyStore `
	-DisplayName "IPv4 over HTTPS" -Service Any -Program System `
	-Enabled False -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort IPHTTPSIn -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser $NT_AUTHORITY_System `
	-Description "Allow IPv4 IPHTTPS tunneling technology to provide connectivity across HTTP proxies and firewalls." @Logs | Format-Output @Logs

#
# Teredo
#

New-NetFirewallRule -Platform $Platform -PolicyStore $PolicyStore `
	-DisplayName "Teredo" -Service iphlpsvc -Program $ServiceHost `
	-Enabled False -Action Allow -Group $Group -Profile $FirewallProfile -InterfaceType $Interface `
	-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Teredo -RemotePort Any `
	-EdgeTraversalPolicy Block -LocalUser Any -LocalOnlyMapping $false -LooseSourceMapping $false `
	-Description "Allow Teredo edge traversal, a technology that provides address assignment and automatic tunneling
for unicast IPv6 traffic when an IPv6/IPv4 host is located behind an IPv4 network address translator." @Logs | Format-Output @Logs

Update-Log
