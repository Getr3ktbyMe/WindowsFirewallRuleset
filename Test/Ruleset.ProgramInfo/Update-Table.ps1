
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
Unit test for Update-Table

.DESCRIPTION
Unit test for Update-Table

.EXAMPLE
PS> .\Update-Table.ps1

.INPUTS
None. You cannot pipe objects to Update-Table.ps1

.OUTPUTS
None. Update-Table.ps1 does not generate any output

.NOTES
None.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
	"PSAvoidGlobalVars", "", Justification = "Needed in this unit test")]
[CmdletBinding()]
param ()

# Initialization
# NOTE: As Administrator because of a test with OneDrive which loads reg hive of other users
#Requires -RunAsAdministrator
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1
New-Variable -Name ThisScript -Scope Private -Option Constant -Value (
	$MyInvocation.MyCommand.Name -replace ".{4}$" )

if ((Get-Variable -Name Develop -Scope Global).Value -eq $false)
{
	Write-Error -Category NotEnabled -TargetObject "Variable 'Develop'" `
		-Message "This unit test is enabled only when 'Develop' is set to $true"
	return
}

# Check requirements
Initialize-Project -Abort

# Imports
. $PSScriptRoot\ContextSetup.ps1
Import-Module -Name Ruleset.Logging

# User prompt
Update-Context $TestContext $ThisScript @Logs
if (!(Approve-Execute -Accept $Accept -Deny $Deny @Logs)) { exit }

Enter-Test $ThisScript

Start-Test "-UserProfile switch Fill table with Greenshot"
Initialize-Table @Logs
Update-Table "Greenshot" -UserProfile @Logs
$global:InstallTable | Format-Table -AutoSize @Logs

Start-Test "Install Path"
$global:InstallTable | Select-Object -ExpandProperty InstallLocation @Logs

Start-Test "Failure Test"
Initialize-Table @Logs
Update-Table "Failure" -UserProfile @Logs
$global:InstallTable | Format-Table -AutoSize @Logs

Start-Test "Test multiple paths"
Initialize-Table @Logs
Update-Table "Visual Studio" -UserProfile @Logs
$global:InstallTable | Format-Table -AutoSize @Logs

Start-Test "Install Path"
$global:InstallTable | Select-Object -ExpandProperty InstallLocation @Logs

Start-Test "-Executables switch - Fill table with PowerShell"
Initialize-Table @Logs
Update-Table "PowerShell.exe" -Executable
$global:InstallTable | Format-Table -AutoSize @Logs

Start-Test "Install Path"
$global:InstallTable | Select-Object -ExpandProperty InstallLocation @Logs

Start-Test "-UserProfile switch Fill table with OneDrive"
Initialize-Table @Logs
$Result = Update-Table "OneDrive" -UserProfile @Logs
$Result
$global:InstallTable | Format-Table -AutoSize @Logs

Test-Output $Result -Command Update-Table @Logs

Update-Log
Exit-Test
