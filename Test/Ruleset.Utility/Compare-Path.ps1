
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
Unit test for Compare-Path

.DESCRIPTION
Unit test for Compare-Path

.EXAMPLE
PS> .\Compare-Path.ps1

.INPUTS
None. You cannot pipe objects to Compare-Path.ps1

.OUTPUTS
None. Compare-Path.ps1 does not generate any output

.NOTES
None.
#>

# Initialization
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

Enter-Test $ThisScript

Start-Test "Compare-Path same path"
Compare-Path "%SystemDrive%\Windows" "C:\Windows" @Logs

Start-Test "Compare-Path relative path"
Compare-Path "%SystemDrive%/Windows" "C:\Windows\System32\..\" @Logs

Start-Test "Compare-Path non existent path"
Compare-Path "%SystemDrive%\Windows" "Z:\Nonexistent" @Logs

Start-Test "Compare-Path wildcards + relative path -Sensitive"
Compare-Path "%SystemDrive%\Win*\System32\en-US\.." "C:\Wind*\System3?\" -Sensitive @Logs

Start-Test "Compare-Path same -Loose"
Compare-Path "%SystemDrive%\\Windows" "C:/Win*/" -Loose

Start-Test "Compare-Path same wrong order -Loose"
Compare-Path "C:\Win*" "%SystemDrive%\Windows" -Loose

Start-Test "Compare-Path not same path"
$Result = Compare-Path "%SystemDrive%\" "D:\" @Logs
$Result

Test-Output $Result -Command Compare-Path @Logs

Update-Log
Exit-Test
