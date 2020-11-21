
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
Unit test for Get-IPAddress

.DESCRIPTION
Unit test for Get-IPAddress

.EXAMPLE
PS> .\Get-IPAddress.ps1

.INPUTS
None. You cannot pipe objects to Get-IPAddress.ps1

.OUTPUTS
None. Get-IPAddress.ps1 does not generate any output

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

Enter-Test

Start-Test "Get-IPAddress IPv4"
Get-IPAddress IPv4

Start-Test "Get-IPAddress IPv6 FAILURE TEST"
Get-IPAddress IPv6 -ErrorAction SilentlyContinue

Start-Test "Get-IPAddress IPv4 -IncludeDisconnected"
Get-IPAddress IPv4 -IncludeDisconnected

Start-Test "Get-IPAddress IPv4 -IncludeVirtual"
Get-IPAddress IPv4 -IncludeVirtual

Start-Test "Get-IPAddress IPv4 -IncludeVirtual -IncludeDisconnected"
Get-IPAddress IPv4 -IncludeVirtual -IncludeDisconnected

Start-Test "Get-IPAddress IPv4 -IncludeVirtual -IncludeDisconnected -ExcludeHardware"
Get-IPAddress IPv4 -IncludeVirtual -IncludeDisconnected -ExcludeHardware

Start-Test "Get-IPAddress IPv4 -IncludeHidden"
Get-IPAddress IPv4 -IncludeHidden

Start-Test "Get-IPAddress IPv4 -IncludeAll"
$Result = Get-IPAddress IPv4 -IncludeAll
$Result

Start-Test "Get-IPAddress IPv4 -IncludeAll -ExcludeHardware"
Get-IPAddress IPv4 -IncludeAll -ExcludeHardware

Test-Output $Result -Command Get-IPAddress

Update-Log
Exit-Test
