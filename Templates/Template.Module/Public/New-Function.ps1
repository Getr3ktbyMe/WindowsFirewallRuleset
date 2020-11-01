
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
A brief description of the  function.
This keyword can be used only once in each topic.

.DESCRIPTION
A detailed description of the  function.
This keyword can be used only once in each topic.

.PARAMETER Param
The description of a parameter. Add a ".PARAMETER" keyword for each parameter
in the  function syntax.

.EXAMPLE
A sample command that uses the  function,
optionally followed by sample output and a description. Repeat this keyword for each example.

.INPUTS
The Microsoft .NET Framework types of objects that can be piped to the  function.
You can also include a description of the input objects.

.OUTPUTS
The .NET Framework type of the objects that the cmdlet returns.
You can also include a description of the returned objects.

.NOTES
Additional information about the  function.
TODO: Update Copyright and start implementing module function

.LINK
The name of a related topic. The value appears on the line below the ".LINK" keyword and must
be preceded by a comment symbol # or included in the comment block.

.COMPONENT
The technology or feature that the  function uses, or to which it is related.
This content appears when the Get-Help command includes the Component parameter of Get-Help.

.ROLE
The user role for the help topic. This content appears when the Get-Help command includes
the Role parameter of Get-Help.

.FUNCTIONALITY
The intended use of the function. This content appears when the Get-Help command includes
the Functionality parameter of Get-Help.
#>
function New-Function
{
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
		"PSReviewUnusedParameter", "", Justification = "This is template function")]
	[OutputType([void])]
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
	param (
		[Parameter(Mandatory = $true)]
		[string] $Param
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] params($($PSBoundParameters.Values))"

	# TODO: Update confirm parameters
	# 'TARGET', 'MESSAGE', 'OPERATION', [ref]$reason
	# https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.shouldprocessreason?view=powershellsdk-7.0.0
	# https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7#quick-parameter-reference
	$CallReason
	if ($PSCmdlet.ShouldProcess("Template TARGET", "Template MESSAGE", "Template OPERATION", [ref] $CallReason))
	{
		# NOTE: Sample output depens on amount of parameters (2, 3 or 4 parameters)
		# Performing the operation "Template MESSAGE" on target "Template TARGET"
		#
		# OR
		#
		# "Template OPERATION"
		# "Template MESSAGE"

		$CallReason
		return $null
	}
}

#
# TODO: Module variables from this script
#

# Template variable
Set-Variable -Name TemplateVariable -Scope Global -Value $null
