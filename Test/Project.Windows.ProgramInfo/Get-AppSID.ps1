
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

#
# Unit test for Get-AppSID
#

#Requires -RunAsAdministrator
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1

# Check requirements for this project
Initialize-Project

# Imports
. $PSScriptRoot\ContextSetup.ps1
Import-Module -Name Project.AllPlatforms.Logging
Import-Module -Name Project.Windows.UserInfo

# Ask user if he wants to load these rules
Update-Context $TestContext $($MyInvocation.MyCommand.Name -replace ".{4}$") @Logs
if (!(Approve-Execute @Logs)) { exit }

Start-Test

New-Test "Get-GroupPrincipal:"
$GroupAccounts = Get-GroupPrincipal "Users", "Administrators" @Logs
$GroupAccounts

New-Test "Get-AppSID: foreach User"
foreach ($Account in $GroupAccounts)
{
	Get-UserApps -User $Account.User @Logs | ForEach-Object {
		Get-AppSID $Account.User $_.PackageFamilyName @Logs
	}
}

New-Test "Get-AppSID: system apps"
$Result = Get-SystemApps @Logs | ForEach-Object {
	Get-AppSID $Account.User $_.PackageFamilyName @Logs
}
$Result

New-Test "Get-TypeName"
$Result | Get-TypeName @Logs

Update-Log
Exit-Test
