
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

<#
.SYNOPSIS
Merge 2 SDDL strings into one

.DESCRIPTION
This function helps to merge 2 SDDL strings into one
Referenced SDDL is expanded with new one

.PARAMETER RefSDDL
Reference to SDDL into which to merge new SDDL

.PARAMETER NewSDDL
New SDDL string which to merge with reference SDDL

.EXAMPLE
$RefSDDL = "D:(A;;CC;;;S-1-5-32-545)(A;;CC;;;S-1-5-32-544)
$NewSDDL = "D:(A;;CC;;;S-1-5-32-333)(A;;CC;;;S-1-5-32-222)"
Merge-SDDL ([ref] $RefSDDL) $NewSDDL

.INPUTS
None. You cannot pipe objects to Merge-SDDL

.OUTPUTS
None. Merge-SDDL does not generate any output

.NOTES
TODO: Validate input using regex
TODO: Process an array of SDDL's
TODO: Pipeline input
#>
function Merge-SDDL
{
	[CmdletBinding(
		HelpURI = "https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.UserInfo/Help/en-US/Merge-SDDL.md")]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true)]
		[ref] $RefSDDL,

		[Parameter(Mandatory = $true)]
		[string] $NewSDDL
	)

	$RefSDDL.Value += $NewSDDL.Substring(2)
}
