
<#
MIT License

Project: "Windows Firewall Ruleset" serves to manage firewall on Windows systems
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
# Unit test for ConvertFrom-SID
#
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1

# Check requirements for this project
Import-Module -Name $ProjectRoot\Modules\Project.AllPlatforms.System
Test-SystemRequirements

# Includes
. $PSScriptRoot\ContextSetup.ps1
Import-Module -Name $ProjectRoot\Modules\Project.AllPlatforms.Logging
Import-Module -Name $ProjectRoot\Modules\Project.AllPlatforms.Test @Logs
Import-Module -Name $ProjectRoot\Modules\Project.Windows.UserInfo @Logs
Import-Module -Name $ProjectRoot\Modules\Project.AllPlatforms.Utility @Logs
Import-Module -Name $ProjectRoot\Modules\Project.Windows.ProgramInfo @Logs

# Ask user if he wants to load these rules
Update-Context $TestContext $($MyInvocation.MyCommand.Name -replace ".{4}$") @Logs
if (!(Approve-Execute @Logs)) { exit }

$VerbosePreference = "Continue"
$DebugPreference = "Continue"

Start-Test

New-Test "Get-GroupPrincipal 'Users', 'Administrators', NT SYSTEM, NT LOCAL SERVICE"
$UserAccounts = Get-GroupPrincipal "Users", "Administrators" @Logs
$UserAccounts

$NTAccounts = Get-AccountSID -Domain "NT AUTHORITY" -User "SYSTEM", "LOCAL SERVICE" @Logs
$NTAccounts

New-Test "ConvertFrom-SID users and admins"
foreach ($Account in $UserAccounts)
{
	$Account.SID | ConvertFrom-SID @Logs | Select-Object -ExpandProperty Name
}

New-Test "ConvertFrom-SID NT AUTHORITY users"
foreach ($Account in $NTAccounts)
{
	$Account | ConvertFrom-SID @Logs | Select-Object -ExpandProperty Name
}

New-Test "ConvertFrom-SID App SID"
$AppSID = "S-1-15-2-2967553933-3217682302-2494645345-2077017737-3805576244-585965800-1797614741"
$Result = ConvertFrom-SID $AppSID @Logs # | Select-Object -ExpandProperty Name
$Result | Format-Table

New-Test "Get-TypeName AppSID"
$Result | Get-TypeName @Logs

New-Test "Get-TypeName UserAccounts"
$UserAccounts[0] | Get-TypeName @Logs

Update-Log
Exit-Test
