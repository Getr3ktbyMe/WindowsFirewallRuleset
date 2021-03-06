
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2020 metablaster zebal@protonmail.ch

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

<#
.SYNOPSIS
Restart and optionally reset network

.DESCRIPTION
Restart or reset all physical network adapters to their default values
Without the need to reboot system.
Reset few esoteric default options
Set network profile to private
Apply computer group policy settings
Grant requested user and firewall service permissions to read/write logs into this repository.
This is useful to troubleshoot problems or to generate network traffic that occurs only during
first time connection or system boot such as DHCP or IGMP

.PARAMETER KeepDNS
Skip clearing DNS server IP addresses
This parameter is ignored if "KeepIP" is specified

.PARAMETER KeepIP
Skip clearing IP, mask and default gateway

.PARAMETER Reset
Reset all network properties in addition to restarting network

.PARAMETER Performance
Set adapter for maximum performance, all power management features are disabled
By default, all supported power management features are enabled

.EXAMPLE
PS> .\RestartNetwork.ps1

.EXAMPLE
PS> .\RestartNetwork.ps1 -KeepIP

.EXAMPLE
PS> .\RestartNetwork.ps1 MyUsername -KeepDNS -Reset

.INPUTS
None. You cannot pipe objects to RestartNetwork.ps1

.OUTPUTS
None. RestartNetwork.ps1 does not generate any output

.NOTES
TODO: IP protocol parameter
TODO: Utilize all parameters for commandlets to make sure all is reset to default
TODO: Optionally reset virtual and hidden adapters and their configuration

.LINK
https://devblogs.microsoft.com/scripting/enabling-and-disabling-network-adapters-with-powershell
#>

[CmdletBinding()]
param (
	[Parameter()]
	[string] $Principal,

	[Parameter()]
	[switch] $KeepDNS,

	[Parameter()]
	[switch] $KeepIP,

	[Parameter()]
	[switch] $Reset,

	[Parameter()]
	[switch] $Performance
)

# Initialization
#Requires -RunAsAdministrator
. $PSScriptRoot\..\Config\ProjectSettings.ps1
New-Variable -Name ThisScript -Scope Private -Option Constant -Value (
	$MyInvocation.MyCommand.Name -replace ".{4}$" )

# Check requirements
Initialize-Project -Abort
Write-Debug -Message "[$ThisScript] params($($PSBoundParameters.Values))"

# Imports
. $PSScriptRoot\ContextSetup.ps1
Import-Module -Name Ruleset.Logging

# User prompt
$Accept = "Restart all connected network adapters and reassign IP"
$Deny = "Abort operation, no change to network configuration is done"
if ($Reset)
{
	$Accept = "Reset all connected network adapters and network settings"
}

Update-Context $ScriptContext $ThisScript @Logs
if (!(Approve-Execute -Accept $Accept -Deny $Deny @Logs)) { exit }

<#
.SYNOPSIS
Get adapter aliases of specified state

.DESCRIPTION
Select-AdapterAlias gets physical interface aliases of adapters that are in specified state

.PARAMETER Interface
An optional list of required adapters that must meet given state.
If successful aliases are returned back, otherwise warning message is show.

.PARAMETER Status
Specify minimum state of network adapters for which to get interface aliases:
Removed - Network adapter is removed
Disabled - Network adapter is disabled
Enabled - Network adapter is enabled but disconnected
Operational - Network adapter is enabled and able to connect to network
Connected - Network adapter has internet access

.EXAMPLE
Select-AdapterAlias Disabled

.EXAMPLE
Select-AdapterAlias Operational -Adapter @("Ethernet", "Realtek WI-FI")

.NOTES
We select InterfaceAlias instead of adapter objects because of non consistent CIM parameters
used by commandlets in this script resulting in errors
TODO: Parameter to control strict selection
TODO: This functionality should part of Get-ConfiguredAdapter somehow if possible
#>
function Select-AdapterAlias
{
	[OutputType([string[]])]
	[CmdletBinding(PositionalBinding = $false)]
	param (
		[Alias("State")]
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateSet("Removed", "Disabled", "Enabled", "Operational", "Connected")]
		[string] $Status,

		[Alias("Interface")]
		[Parameter()]
		[string[]] $Adapter
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] params($($PSBoundParameters.Values))"

	[CimInstance[]] $TargetAdapter = @()
	if ($Adapter)
	{
		$TargetAdapter = Get-NetAdapter -Name $Adapter
	}
	else
	{
		$TargetAdapter = Get-NetAdapter -Physical -Name *
	}

	[string[]] $AcceptStatus = @()
	[string[]] $AdapterAlias = @()

	foreach ($Item in $TargetAdapter)
	{
		$ifAlias = $Item.InterfaceAlias
		Write-Debug -Message "[$($MyInvocation.InvocationName)] Processing '$ifAlias' adapter with '$($Item.Status)' status"

		# NOTE: Adapter "Status" values:
		# Not Present - adapter is not present
		# Disabled - adapter is disabled and disconnected
		# Disconnected - adapter is enabled but disconnected from network
		# Up - adapter is enabled and able to connect to internet
		switch -Wildcard ($Item.Status)
		{
			"Not Present"
			{
				$ifStatus =	"Removed"
				$AcceptStatus = @("Removed")
				break
			}
			"Disabled"
			{
				$ifStatus =	$Item.Status
				$AcceptStatus = @("Disabled")
				break
			}
			"Disconnected"
			{
				$ifStatus =	"Enabled"
				$AcceptStatus = @("Enabled")
				break
			}
			"Up"
			{
				$ifStatus = "Operational"
				$AcceptStatus = @("Enabled", "Operational")

				$NetworkProfile = Get-NetConnectionProfile -IPv4Connectivity Internet -InterfaceAlias $ifAlias -ErrorAction Ignore

				if ($NetworkProfile)
				{
					switch -Wildcard ($NetworkProfile.Name)
					{
						# NOTE: Known profiles when there is not internet access
						# Identifying...
						# Unidentified network
						"Identifying*" { }
						"Unidentified*" { break }
						default
						{
							$ifStatus = "Connected"
							$AcceptStatus = @("Enabled", "Operational", "Connected")
						}
					}
				}

				break
			}
			default
			{
				$ifStatus =	"Unknown"
			}
		}

		if ([array]::Find($AcceptStatus, [System.Predicate[string]] { $Status -eq $args[0] }))
		{
			$AdapterAlias += $ifAlias
		}

		Write-Information -Tags "User" -MessageData "INFO: '$ifAlias' adapter status is '$ifStatus'"
	}

	Write-Output -InputObject $AdapterAlias
}

<#
.SYNOPSIS
Wait until adapters are put into requested state

.DESCRIPTION
Wait in incrementail time intervals until specified network adapters are put into requested state

.PARAMETER Status
Wait until adapter is put into specified state

.PARAMETER Adapter
A list of interface aliases which should be put into requested state

.PARAMETER Seconds
Maximum time to wait for adapter state, expressed in seconds

.EXAMPLE
Wait-Adapter Enabled -Adapter "Ethernet"

.EXAMPLE
Wait-Adapter Connected -Adapter "Ethernet" -Seconds 20

.NOTES
None.
#>
function Wait-Adapter
{
	[OutputType([string])]
	[CmdletBinding(PositionalBinding = $false)]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateSet("Removed", "Disabled", "Enabled", "Operational", "Connected")]
		[string] $Status,

		[Parameter(Mandatory = $true)]
		[string[]] $Adapter,

		[Parameter()]
		[uint32] $Seconds = 10
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] params($($PSBoundParameters.Values))"

	for ($Time = 2; $Time -le ($Seconds - $Time + 2); $Time += 2)
	{
		[string[]] $Result = Select-AdapterAlias $Status -Adapter $Adapter

		# If all adapters are in desired state
		if ($Result -and ($Result.Count -eq $Adapter.Count))
		{
			return
		}

		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Waiting adapters for '$Status' state"
		Start-Sleep -Seconds $Time
	}

	Write-Warning -Message "Not all of the requested adapters are in '$Status' state"
}

# Ensure adapters are put into valid state for configuration
[string[]] $AdapterAlias = Select-AdapterAlias Disabled @Logs

if ($AdapterAlias)
{
	Write-Information -Tags "User" -MessageData "INFO: Attempt to bring up disabled adapters"

	Enable-NetAdapter -InterfaceAlias $AdapterAlias
	Wait-Adapter Enabled -Adapter $AdapterAlias
}

# TODO: It's not clear which methods may fail with disconnected adapters
$AdapterAlias = Select-AdapterAlias Enabled @Logs

if (!$AdapterAlias)
{
	# TODO: Use NetConnectionStatus property to get details
	Write-Warning -Message "None of the adapters are ready for configuration"
}
else
{
	# NOTE: The order of tasks is important because:
	# 1. Keep network interface up as long as possible to capture precise network stop and start time
	# 2. Some properties can be modified only in specific adapter state
	# 3. Reset as many properties as possible before restarting network adapter
	# TODO: Reset adapter items (optionally reinstall them, which requires reboot?)
	# HACK: Reset APIPA alternate IP fields
	# HACK: Reset WINS and LMHOSTS options
	# TODO: Restart network services
	# TODO: Test network

	if ($KeepIP -or $KeepDNS)
	{
		Write-Information -Tags "User" -MessageData "INFO: Saving IP configuration"

		# NOTE: IPv4DefaultGateway not used, Get-NetRoute is simpler
		# TypeName: Selected.NetIPConfiguration
		$IPInfo = Get-NetIPConfiguration -All @Logs |
		Select-Object -Property IPv4Address, DNSServer @Logs

		# Typename: Microsoft.Management.Infrastructure.CimInstance#ROOT/StandardCimv2/MSFT_NetRoute
		$GatewayInfo = Get-NetRoute -DestinationPrefix 0.0.0.0/0 -AddressFamily IPv4
	}

	if ($KeepIP)
	{
		# TypeName Selected.Microsoft.Management.Infrastructure.CimInstance
		$PrefixInfo = Get-NetIPAddress -InterfaceAlias $AdapterAlias -AddressFamily IPv4 @Logs |
		Select-Object -Property PrefixLength, InterfaceAlias @Logs
	}

	if ($Reset)
	{
		Write-Information -Tags "User" -MessageData "INFO: Reseting adapter properties"

		# Reset the advanced properties of a network adapter to their factory default values
		Start-Job -Name "AdvancedProperties" -ArgumentList $AdapterAlias -ScriptBlock {
			param ($AdapterAlias)
			Reset-NetAdapterAdvancedProperty -InterfaceAlias $AdapterAlias -DisplayName "*" -NoRestart
		} @Logs

		Receive-Job -Name "AdvancedProperties" -Wait -AutoRemoveJob @Logs

		# Sets the interface-specific DNS client configurations on the computer
		Start-Job -Name "AdvancedDNS" -ArgumentList $AdapterAlias -ScriptBlock {
			param ($AdapterAlias)
			Set-DnsClient -InterfaceAlias $AdapterAlias -RegisterThisConnectionsAddress $true -ResetConnectionSpecificSuffix `
				-UseSuffixWhenRegistering $false
		} @Logs

		Receive-Job -Name "AdvancedDNS" -Wait -AutoRemoveJob @Logs

		# Set NETBIOS adapter option
		Start-Job -Name "NETBIOS" -ScriptBlock {
			# NETBIOS Option:
			# 0 - Use NetBIOS setting from the DHCP server
			# 1 - Enable NetBIOS over TCP/IP
			# 2 - Disable NetBIOS over TCP/IP

			# NOTE: There is no InterfaceAlias in CIM selection
			$Description = Get-NetAdapter -Physical | Where-Object Status -EQ "Up" |
			Select-Object -ExpandProperty InterfaceDescription

			foreach ($Name in $Description)
			{
				$Adapter = Get-CimInstance -Namespace "root\cimv2" -QueryDialect "WQL" `
					-Query "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE Description LIKE '$Name'"

				# NOTE: Error code 72: An error occurred while accessing the registry for the requested information.
				# Invalid domain name (Action requires elevation)
				# NOTE: Error code 84: IP not enabled on adapter
				# https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/settcpipnetbios-method-in-class-win32-networkadapterconfiguration
				Invoke-CimMethod -InputObject $Adapter -MethodName SetTcpipNetbios -Arguments @{
					TcpipNetbiosOptions = 0
				} | Out-Null
			}
		} @Logs

		Receive-Job -Name "NETBIOS" -Wait -AutoRemoveJob @Logs

		# TCP auto-tuning can improve throughput on high throughput, high latency networks
		Start-Job -Name "AutoTuningLevel" -ScriptBlock {
			# Normal. Sets the TCP receive window to grow to accommodate almost all scenarios
			Set-NetTCPSetting -AutoTuningLevelLocal Normal
		} @Logs

		Receive-Job -Name "AutoTuningLevel" -Wait -AutoRemoveJob @Logs
	} # Reset

	# NOTE: To set specific power saving options use Set-NetAdapterPowerManagement
	if ($Performance)
	{
		Write-Information -Tags "User" -MessageData "INFO: Setting adapters for maximum performance"
		Disable-NetAdapterPowerManagement -Name $AdapterAlias -NoRestart
	}
	else
	{
		Write-Information -Tags "User" -MessageData "INFO: Setting adapters for maximum power saving"
		Enable-NetAdapterPowerManagement -Name $AdapterAlias -NoRestart
	}

	# Remove primary and secondary DNS
	Start-Job -Name "DNSServers" -ArgumentList $AdapterAlias -ScriptBlock {
		param ($AdapterAlias)
		Set-DnsClientServerAddress -InterfaceAlias $AdapterAlias -ResetServerAddress
	} @Logs

	Receive-Job -Name "DNSServers" -Wait -AutoRemoveJob @Logs

	# Remove IP address and subnet mask
	# NOTE: Adapter must be enabled
	Start-Job -Name "IPAddress" -ArgumentList $AdapterAlias -ScriptBlock {
		param ($AdapterAlias)
		Remove-NetIPAddress -InterfaceAlias $AdapterAlias -IncludeAllCompartments -Confirm:$false
	} @Logs

	Receive-Job -Name "IPAddress" -Wait -AutoRemoveJob @Logs

	# Remove "Default Gateway" entry and clear routing table for interface
	# NOTE: Routes are available only when adapter is enabled (and in connected media state?)
	# HACK: Remove-NetRoute: Element not found, error appears randomly
	Start-Job -Name "RoutingTable" -ArgumentList $AdapterAlias -ScriptBlock {
		param ($AdapterAlias)
		Remove-NetRoute -InterfaceAlias $AdapterAlias -AddressFamily IPv4 -Confirm:$false
	} @Logs

	Receive-Job -Name "RoutingTable" -Wait -AutoRemoveJob @Logs

	# Set IPv6 interface to "Obtain an IP address automatically" and "Obtain DNS server address automatically"
	Start-Job -Name "InterfaceIPv6" -ArgumentList $AdapterAlias -ScriptBlock {
		param ($AdapterAlias)

		# NOTE: By default, RouterDiscovery is ControlledByDHCP for IPv4 and Enabled for IPv6
		# EcnMarking Allow an application or higher layer protocol, such as TCP, to decide how to apply ECN marking
		# NOTE: In order for an application to fully control ECN capability value in the Network TCP setting must also be set to Enabled
		Set-NetIPInterface -InterfaceAlias $AdapterAlias -RouterDiscovery Enabled -AutomaticMetric Enabled `
			-NeighborDiscoverySupported Yes -AddressFamily IPv6 -EcnMarking AppDecide -Dhcp Enabled
	} @Logs

	Receive-Job -Name "InterfaceIPv6" -Wait -AutoRemoveJob @Logs

	# Set IPv4 interface to "Obtain an IP address automatically" and "Obtain DNS server address automatically"
	Start-Job -Name "InterfaceIPv4" -ArgumentList $AdapterAlias -ScriptBlock {
		param ($AdapterAlias)

		Set-NetIPInterface -InterfaceAlias $AdapterAlias -RouterDiscovery ControlledByDHCP -AutomaticMetric Enabled `
			-NeighborDiscoverySupported Yes -AddressFamily IPv4 -EcnMarking AppDecide -Dhcp Enabled
	} @Logs

	Receive-Job -Name "InterfaceIPv4" -Wait -AutoRemoveJob @Logs

	# Restart adapters for changes to take effect
	Write-Information -Tags "User" -MessageData "INFO: Disabling network adapters"

	# NOTE: Need to wait until registry is updated for IP removal
	Disable-NetAdapter -InterfaceAlias $AdapterAlias -Confirm:$false @Logs
	Wait-Adapter Disabled -Adapter $AdapterAlias @Logs

	$NetworkTime = Get-Date -DisplayHint Time @Logs | Select-Object -ExpandProperty DateTime @Logs
	Write-Information -Tags "User" -MessageData "INFO: Network stop time is $NetworkTime"

	Write-Information -Tags "User" -MessageData "INFO: Waiting 10 seconds to silence network"
	Start-Sleep -Seconds 10 @Logs

	# Clears the contents of the DNS client cache
	Start-Job -Name "ClearDNSCache" -ScriptBlock {
		Clear-DnsClientCache
	} @Logs

	Receive-Job -Name "ClearDNSCache" -Wait -AutoRemoveJob

	# Make changes done to GPO firewall effective
	gpupdate.exe /target:computer

	Write-Information -Tags "User" -MessageData "INFO: Enabling network adapters"

	# NOTE: Need to wait for firewall service to set up file system permissions for logs in final step
	# Setting IP and DNS also requires enabled adapter
	Enable-NetAdapter -InterfaceAlias $AdapterAlias @Logs
	Wait-Adapter Operational -Adapter $AdapterAlias

	$NetworkTime = Get-Date -DisplayHint Time | Select-Object -ExpandProperty DateTime
	Write-Information -Tags "User" -MessageData "INFO: Network start time is $NetworkTime"

	if ($KeepIP)
	{
		# Restore previous IP configuration
		Write-Information -Tags "User" -MessageData "INFO: Restoring old IP configuration"

		foreach ($Adapter in (Get-NetAdapter -Physical -Name $AdapterAlias @Logs))
		{
			Write-Debug -Message "[$($MyInvocation.InvocationName)] Processing $($Adapter.InterfaceAlias) adapter"

			$ifAlias = $Adapter.InterfaceAlias

			[byte] $Prefix = $PrefixInfo | Where-Object -Property InterfaceAlias -EQ $ifAlias |
			Select-Object -ExpandProperty PrefixLength

			if (!$Prefix)
			{
				Write-Warning -Message "Restoring IP configuration ignored, subnet mask is missing"
				continue
			}

			[string] $Address = $IPInfo.IPv4Address | Where-Object -Property InterfaceAlias -EQ $ifAlias |
			Select-Object -ExpandProperty IPAddress

			if ([string]::IsNullOrEmpty($Address))
			{
				Write-Warning -Message "Restoring IP configuration ignored, IP address is missing"
				continue
			}

			[string] $Gateway = $GatewayInfo | Where-Object -Property InterfaceAlias -EQ $ifAlias |
			Select-Object -ExpandProperty NextHop

			if ([string]::IsNullOrEmpty($Gateway))
			{
				Write-Warning -Message "Restoring IP configuration ignored, default gateway address is missing"
				continue
			}

			# NOTE: For "Inconsistent parameters PolicyStore PersistentStore and Dhcp Enabled"
			# Adapter cannot be in disconnected state when configuring the IP address
			New-NetIPAddress -InterfaceAlias $ifAlias -AddressFamily IPv4 -IPAddress $Address `
				-PrefixLength $Prefix -DefaultGateway $Gateway | Out-Null
		}
	}

	if ($KeepIP -or $KeepDNS)
	{
		# Restore previous DNS servers
		Write-Information -Tags "User" -MessageData "INFO: Restoring old DNS server addresses"

		foreach ($Adapter in (Get-NetAdapter -Physical -Name $AdapterAlias @Logs))
		{
			Write-Debug -Message "[$($MyInvocation.InvocationName)] Processing $($Adapter.InterfaceAlias) adapter"

			# NOTE: AddressFamily 2 = IPv4, 23 = IPv6
			# https://docs.microsoft.com/en-us/dotnet/api/system.net.sockets.addressfamily?view=netcore-3.1
			[string[]] $DNSAddress4 = $IPInfo.DNSServer | Where-Object -Property InterfaceAlias -EQ $Adapter.InterfaceAlias |
			Where-Object -Property AddressFamily -EQ 2 | Select-Object -ExpandProperty ServerAddresses

			if ([string]::IsNullOrEmpty($DNSAddress4))
			{
				Write-Warning -Message "Restoring DNS Server addresses ignored, DNS server addresses are missing"
				continue
			}

			# NOTE: Adapter cannot be in disconnected state when configuring the DNS server address
			# HACK: -Validate does not work: "A general error occurred that is not covered by a more specific error code"
			Set-DnsClientServerAddress -InterfaceAlias $Adapter.InterfaceAlias -ServerAddresses $DNSAddress4 @Logs
		}
	}

	# Registers all of the IP addresses on the computer onto the configured DNS server
	Start-Job -Name "RegisterDNSClient" -ScriptBlock {
		Register-DnsClient
	} @Logs

	Receive-Job -Name "RegisterDNSClient" -Wait -AutoRemoveJob @Logs

	Wait-Adapter Connected -Adapter $AdapterAlias @Logs

	# TODO: Set to old profile, or define default profile in project settings
	Start-Job -Name "NetworkProfile" -ArgumentList $AdapterAlias -ScriptBlock {
		param ($AdapterAlias)
		Set-NetConnectionProfile -InterfaceAlias $AdapterAlias -NetworkCategory Private
	} @Logs

	Receive-Job -Name "NetworkProfile" -Wait -AutoRemoveJob @Logs
}

# Grant access to firewall logs
if (![string]::IsNullOrEmpty($Principal))
{
	& "$ProjectRoot\Scripts\GrantLogs.ps1" -Principal $Principal -SkipPrompt
}

Update-Log
