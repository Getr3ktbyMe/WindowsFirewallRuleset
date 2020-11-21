
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
Unit test for error logging

.DESCRIPTION
Unit test for error logging

.EXAMPLE
PS> .\Test-Error.ps1

.INPUTS
None. You cannot pipe objects to Test-Error.ps1

.OUTPUTS
None. Test-Error.ps1 does not generate any output

.NOTES
None.
#>

#region Initialization
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1
New-Variable -Name ThisScript -Scope Private -Option Constant -Value (
	$MyInvocation.MyCommand.Name -replace ".{4}$" )

# Check requirements
Initialize-Project -Abort

# Imports
. $PSScriptRoot\ContextSetup.ps1

# User prompt
Update-Context $TestContext $ThisScript
if (!(Approve-Execute -Accept $Accept -Deny $Deny)) { exit }
#endregion

<#
.SYNOPSIS
	Error logging with advanced function
#>
function Test-Error
{
	[CmdletBinding()]
	param ()

	Start-Test '$PSDefaultParameterValues in Test-Error'
	$PSDefaultParameterValues

	Write-Error -Message "[$($MyInvocation.InvocationName)] error 1" -Category PermissionDenied -ErrorId 1
	Write-Error -Message "[$($MyInvocation.InvocationName)] error 2" -Category PermissionDenied -ErrorId 2
}

<#
.SYNOPSIS
	Error logging on pipeline
#>
function Test-Pipeline
{
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
		"PSReviewUnusedParameter", "", Justification = "Needed for test case")]
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true)]
		$Param
	)

	process
	{
		Write-Error -Message "[$($MyInvocation.InvocationName)] End of pipe 1" -Category NotEnabled -ErrorId 3
		Write-Error -Message "[$($MyInvocation.InvocationName)] End of pipe 2" -Category NotEnabled -ErrorId 4
	}
}

<#
.SYNOPSIS
	Error logging with nested function
#>
function Test-Nested
{
	[CmdletBinding()]
	param ()

	Write-Error -Message "[$($MyInvocation.InvocationName)] Nested 1" -Category SyntaxError -ErrorId 5
	Write-Error -Message "[$($MyInvocation.InvocationName)] Nested 2" -Category SyntaxError -ErrorId 6
}

<#
.SYNOPSIS
	Error logging with nested function
#>
function Test-Parent
{
	[CmdletBinding()]
	param ()

	Write-Error -Message "[$($MyInvocation.InvocationName)] Parent 1" -Category MetadataError -ErrorId 7
	Test-Nested
	Write-Error -Message "[$($MyInvocation.InvocationName)] Parent 2" -Category MetadataError -ErrorId 8
}

<#
.SYNOPSIS
	Error logging with a combination of other streams
#>
function Test-Combo
{
	[CmdletBinding()]
	param ()

	Write-Error -Message "[$($MyInvocation.InvocationName)] combo" -Category InvalidResult -ErrorId 9
	Write-Warning -Message "[$($MyInvocation.MyCommand.Name)] combo"
	Write-Information -Tags "Test" -MessageData "[$($MyInvocation.MyCommand.Name)] INFO: combo"
}

<#
.SYNOPSIS
	Pipeline helper
#>
function Test-Empty
{
	[CmdletBinding()]
	param ()

	Write-Output "Data.."
}

Enter-Test

# NOTE: we test generating logs not what is shown in the console
# disabling this for "RunAllTests"
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
$InformationPreference = "SilentlyContinue"

Start-Test "No errors"
Get-ChildItem -Path "C:\" | Out-Null

Start-Test '$PSDefaultParameterValues in script'
$PSDefaultParameterValues

Start-Test "Generate errors"
$Folder = "C:\CrazyFolder"
Get-ChildItem -Path $Folder

Start-Test "Test-Error"
Test-Error

Start-Test "Update-Log first"
Update-Log

Start-Test "Test-Error other actions"
Test-Empty -InformationAction Ignore -WarningAction Stop

Start-Test "Test-Pipeline"
Get-ChildItem -Path $Folder | Test-Pipeline

Start-Test "Test-Parent"
Test-Parent

Start-Test "Test-Combo"
Test-Combo

Start-Test "Create module"
New-Module -Name Dynamic.TestError -ScriptBlock {
	. $PSScriptRoot\..\..\Config\ProjectSettings.ps1 -InsideModule

	# NOTE: Same thing as in parent scope, we test generating logs not what is shown in the console
	$ErrorActionPreference = "SilentlyContinue"
	$WarningPreference = "SilentlyContinue"
	$InformationPreference = "SilentlyContinue"

	# TODO: Start-Test cant be used here, see todo in Ruleset.Test module
	Write-Information -Tags "Test" -MessageData "[$($MyInvocation.InvocationName)] $PSDefaultParameterValues in Dynamic.TestError:" -InformationAction "Continue"
	$PSDefaultParameterValues

	<#
	.SYNOPSIS
	Test default parameter values and error loging inside module function
	#>
	function Test-DynamicFunction
	{
		[CmdletBinding()]
		param()

		Write-Information -Tags "Test" -MessageData "[$($MyInvocation.InvocationName)] $PSDefaultParameterValues in Test-DynamicFunction:" -InformationAction "Continue"
		$PSDefaultParameterValues

		Write-Error -Message "[$($MyInvocation.InvocationName)] error in module" -Category NotSpecified -ErrorId 10
	}
} | Import-Module

New-Test "Test-DynamicFunction"
Test-DynamicFunction
Remove-Module -Name Dynamic.TestError

Start-Test "Update-Log second"
Update-Log
Exit-Test
