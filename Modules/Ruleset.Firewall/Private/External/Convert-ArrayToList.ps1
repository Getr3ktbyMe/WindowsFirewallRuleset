
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2020 Markus Scholtes

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
Convert String array to comma separated list

.DESCRIPTION
Convert String array to comma separated list.
Used by Export-FirewallRules ex. to pack an array of IP addresses into a single string

.PARAMETER StringArray
String array which to convert

.EXAMPLE
PS> Convert-ArrayToList @("192.168.1.1", "192.168.2.1", "172.24.33.100")

"192.168.1.1,192.168.2.1,172.24.33.100"

.INPUTS
None. You cannot pipe objects to Convert-ArrayToList

.OUTPUTS
[string] comma separated list

.NOTES
Changes by metablaster:
August 2020:
- Make Convert-ArrayToList Advanced function
September 2020:
- Show warning for unexpected input
#>
function Convert-ArrayToList
{
	[CmdletBinding()]
	[OutputType([string])]
	param(
		[Parameter()]
		[string[]] $StringArray
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] params($($PSBoundParameters.Values))"

	[string] $Result = ""

	if ($StringArray -and ($StringArray.Length -gt 0))
	{
		foreach ($Value In $StringArray)
		{
			$Result += "$Value,"
		}

		return $Result.TrimEnd(",")
	}

	Write-Warning "Input is missing, result is empty string"
	return $Result
}
