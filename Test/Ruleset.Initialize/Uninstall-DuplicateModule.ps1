
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
Unit test for Uninstall-DuplicateModule

.DESCRIPTION
Unit test for Uninstall-DuplicateModule

.EXAMPLE
PS> .\Uninstall-DuplicateModule.ps1

.INPUTS
None. You cannot pipe objects to Uninstall-DuplicateModule.ps1

.OUTPUTS
None. Uninstall-DuplicateModule.ps1 does not generate any output

.NOTES
None.
#>

[CmdletBinding()]
param (
	[Parameter()]
	[switch] $Force
)

# Initialization
#Requires -RunAsAdministrator
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1
New-Variable -Name ThisScript -Scope Private -Option Constant -Value (
	$MyInvocation.MyCommand.Name -replace ".{4}$" )

# Check requirements
Initialize-Project -Abort

# Imports
. $PSScriptRoot\ContextSetup.ps1
Import-Module -Name Ruleset.Logging

# User prompt
Update-Context $TestContext $ThisScript @Logs
if (!(Approve-Execute -Accept $Accept -Deny $Deny @Logs)) { exit }

Enter-Test $ThisScript -Private

if ($Force -or $PSCmdlet.ShouldContinue("Uninstall specified modules for testing", "Accept dangerous unit test"))
{
	Start-Test "Get-Module"
	[PSModuleInfo[]] $TargetModule = Get-Module -ListAvailable -Name Pester
	$TargetModule += Get-Module -ListAvailable -Name PSReadline

	if ($TargetModule)
	{
		Start-Test "Uninstall-DuplicateModule Pipeline"
		$TargetModule | Uninstall-DuplicateModule @Logs
	}

	Start-Test "Uninstall-DuplicateModule -Name Pester"
	Uninstall-DuplicateModule -Name Pester -Location Shipping, System, User @Logs

	Start-Test "Uninstall-DuplicateModule -Name PowerShellGet, PackageManagement"
	$Result = Uninstall-DuplicateModule -Name PowerShellGet, PackageManagement -Location Shipping, System @Logs
	$Result

	Test-Output $Result -Command Uninstall-DuplicateModule @Logs

	Remove-Module -Name Ruleset.UnitTest
}

Update-Log
Exit-Test
