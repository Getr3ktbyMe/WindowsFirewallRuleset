
<#
NOTE: This file has been sublicensed by metablaster zebal@protonmail.ch
under a dual license of the MIT license AND the ISC license, see both licenses below
#>

<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

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
ISC License

Copyright (C) 2016, Chris Dent

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#>

<#
.SYNOPSIS
Convert a start and end IP address to the closest matching subnet.

.DESCRIPTION
ConvertTo-Subnet attempts to convert a starting and ending IP address from a range to the closest subnet.

.PARAMETER IPAddress
Any IP address in the subnet.

.PARAMETER SubnetMask
A subnet mask.

.PARAMETER Start
The first IP address from a range.

.PARAMETER End
The last IP address from a range.

.EXAMPLE
PS> ConvertTo-Subnet -Start 0.0.0.0 -End 255.255.255.255

.EXAMPLE
PS> ConvertTo-Subnet -Start 192.168.0.1 -End 192.168.0.129

.EXAMPLE
PS> ConvertTo-Subnet 10.0.0.23/24

.EXAMPLE
PS> ConvertTo-Subnet 10.0.0.23 255.255.255.0

.INPUTS
None. You cannot pipe objects to ConvertTo-Subnet

.OUTPUTS
"Ruleset.IP.Subnet" Custom object

.NOTES
Following changes by metablaster:
- Include licenses and move comment based help outside of functions
- For code to be consistent with project code formatting and symbol casing.
- Removed unnecessary position arguments, added default argument values explicitly.
#>
function ConvertTo-Subnet
{
	[CmdletBinding(DefaultParameterSetName = "FromIPAndMask",
		HelpURI = "https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.IP/Help/en-US/ConvertTo-Subnet.md")]
	[OutputType("Ruleset.IP.Subnet")]
	param (
		[Parameter(Mandatory = $true, Position = 0,
			ParameterSetName = "FromIPAndMask")]
		[string] $IPAddress,

		[Parameter(Position = 1,
			ParameterSetName = "FromIPAndMask")]
		[string] $SubnetMask,

		[Parameter(Mandatory = $true,
			ParameterSetName = "FromStartAndEnd")]
		[ipaddress] $Start,

		[Parameter(Mandatory = $true,
			ParameterSetName = "FromStartAndEnd")]
		[ipaddress] $End
	)

	if ($PSCmdlet.ParameterSetName -eq "FromIPAndMask")
	{
		try
		{
			$Network = ConvertTo-Network @PSBoundParameters
		}
		catch
		{
			$PSCmdlet.ThrowTerminatingError($_)
		}
	}
	elseif ($PSCmdlet.ParameterSetName -eq 'FromStartAndEnd')
	{
		if ($Start -eq $End)
		{
			$MaskLength = 32
		}
		else
		{
			$DecimalStart = ConvertTo-DecimalIP $Start
			$DecimalEnd = ConvertTo-DecimalIP $End

			if ($DecimalEnd -lt $DecimalStart)
			{
				$Start = $End
			}

			# Find the point the binary representation of each IP address diverges
			$i = 32
			do
			{
				$i--
			}
			until (($DecimalStart -band ([uint32]1 -shl $i)) -ne ($DecimalEnd -band ([uint32]1 -shl $i)))

			$MaskLength = 32 - $i - 1
		}

		try
		{
			$Network = ConvertTo-Network $Start $MaskLength
		}
		catch
		{
			$PSCmdlet.ThrowTerminatingError($_)
		}
	}

	$hostAddresses = [math]::Pow(2, (32 - $Network.MaskLength)) - 2

	if ($hostAddresses -lt 0)
	{
		$hostAddresses = 0
	}

	$Subnet = [PSCustomObject]@{
		NetworkAddress = Get-NetworkAddress $Network.ToString()
		BroadcastAddress = Get-BroadcastAddress $Network.ToString()
		SubnetMask = $Network.SubnetMask
		MaskLength = $Network.MaskLength
		HostAddresses = $hostAddresses
		PSTypeName = 'Ruleset.IP.Subnet'
	}

	$Subnet | Add-Member ToString -MemberType ScriptMethod -Force -Value {
		return '{0}/{1}' -f $this.NetworkAddress, $this.MaskLength
	}

	$Subnet
}
