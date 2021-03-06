
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
Unit test for Test-Environment

.DESCRIPTION
Unit test for Test-Environment

.EXAMPLE
PS> .\Test-Environment.ps1

.INPUTS
None. You cannot pipe objects to Test-Environment.ps1

.OUTPUTS
None. Test-Environment.ps1 does not generate any output

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

New-Section "Root drive"

$Result = "C:"
Start-Test "Test-Environment: $Result"
Test-Environment $Result @Logs

$Result = "C:\\"
Start-Test "Test-Environment: $Result"
Test-Environment $Result @Logs

$Result = "D:\"
Start-Test "Test-Environment: $Result"
Test-Environment $Result @Logs

New-Section "Default test"

$Result = "C:\\Windows\System32"
Start-Test "Test-Environment: $Result"
Test-Environment $Result @Logs

$Result = "C:/Windows/explorer.exe"
Start-Test "Test-Environment -PathType Leaf: $Result"
Test-Environment $Result -PathType Leaf @Logs

$Result = "D:\\NoSuchFolder"
Start-Test "Test-Environment: $Result"
Test-Environment $Result @Logs

New-Section "Invalid syntax"

$Result = '"C:\ProgramData\ssh"'
Start-Test "Test-Environment: $Result"
Test-Environment $Result @Logs

$Result = "'C:\Windows\Microsoft.NET\Framework64\v3.5'"
Start-Test "Test-Environment: $Result"
Test-Environment $Result @Logs

New-Section "Users folder"

$Result = "C:\Users"
Start-Test "Test-Environment -UserProfile: $Result"
Test-Environment -UserProfile $Result @Logs

$Result = "C:\Users\\"
Start-Test "Test-Environment -UserProfile: $Result"
Test-Environment -UserProfile $Result @Logs

$Result = "C:\\UsersA\"
Start-Test "Test-Environment -UserProfile: $Result"
Test-Environment -UserProfile $Result @Logs

$Result = "C:\\Users\3"
Start-Test "Test-Environment -UserProfile: $Result"
Test-Environment -UserProfile $Result @Logs

$Result = "C:\Users\Public\Downloads" # "\Public Downloads"
Start-Test "Test-Environment -UserProfile: $Result"
Test-Environment -UserProfile $Result @Logs

$Result = "C:\Users\\"
Start-Test "Test-Environment -Firewall: $Result"
Test-Environment -Firewall $Result @Logs

$Result = "C:\\UsersA\"
Start-Test "Test-Environment -Firewall: $Result"
Test-Environment -Firewall $Result @Logs

$Result = "C:\\Users\3"
Start-Test "Test-Environment -Firewall: $Result"
Test-Environment -Firewall $Result @Logs

New-Section "UserProfile"

$Result = "%LOCALAPPDATA%\MicrosoftEdge"
Start-Test "Test-Environment: $Result"
Test-Environment $Result @Logs

$Result = "%HOME%\AppData\Local\MicrosoftEdge"
Start-Test "Test-Environment: $Result"
Test-Environment $Result @Logs

$Result = "C:\Users\$TestUser\AppData"
Start-Test "Test-Environment: $Result"
Test-Environment $Result @Logs

$Result = "F:\Users\$TestUser"
Start-Test "Test-Environment: $Result"
Test-Environment $Result @Logs

$Result = "%LOCALAPPDATA%\MicrosoftEdge"
Start-Test "Test-Environment -UserProfile: $Result"
Test-Environment -UserProfile $Result @Logs

$Result = "%HOME%\AppData\Local\MicrosoftEdge"
Start-Test "Test-Environment -UserProfile: $Result"
Test-Environment -UserProfile $Result @Logs

$Result = "C:\Users\$TestUser\AppData"
Start-Test "Test-Environment -UserProfile: $Result"
Test-Environment -UserProfile $Result @Logs

$Result = "F:\Users\$TestUser"
Start-Test "Test-Environment -UserProfile: $Result"
Test-Environment -UserProfile $Result @Logs

New-Section "Test firewall"

$Result = "C:\\Windows\System32"
Start-Test "Test-Environment -Firewall: $Result"
Test-Environment -Firewall $Result @Logs

$Result = "%LOCALAPPDATA%\MicrosoftEdge"
Start-Test "Test-Environment -Firewall: $Result"
Test-Environment -Firewall $Result @Logs

$Result = "%HOME%\AppData\Local\MicrosoftEdge"
Start-Test "Test-Environment -Firewall: $Result"
Test-Environment -Firewall $Result @Logs

$Result = "C:\Users\$TestUser\AppData"
Start-Test "Test-Environment -Firewall: $Result"
Test-Environment -Firewall $Result @Logs

$Result = "C:\Users\Public\Downloads" # "\Public Downloads"
Start-Test "Test-Environment -Firewall: $Result"
Test-Environment -Firewall $Result @Logs

New-Section "Environment variables"

$Result = "%SystemDrive%"
Start-Test "Test-Environment: $Result"
$Status = Test-Environment $Result @Logs
$Status

$Result = "C:\Program Files (x86)\Windows Defender\"
Start-Test "Test-Environment: $Result"
Test-Environment $Result @Logs

$Result = "%Path%"
Start-Test "Test-Environment: %Path%"
Test-Environment $Result @Logs

New-Section "-Firewall + -UserProfile"

$Result = "%HOME%\AppData\Local\MicrosoftEdge"
Start-Test "Test-Environment -Firewall: $Result"
Test-Environment -Firewall -UserProfile $Result @Logs

$Result = "C:\Users\$TestUser\AppData"
Start-Test "Test-Environment -Firewall: $Result"
Test-Environment -Firewall -UserProfile $Result @Logs

$Result = "C:\Program Files (x86)\Windows Defender"
Start-Test "Test-Environment -Firewall: $Result"
Test-Environment -Firewall -UserProfile $Result @Logs

New-Section "Null test"

$Result = ""
Start-Test "Test-Environment: '$Result'"
Test-Environment $Result @Logs

$Result = $null
Start-Test "Test-Environment: null"
Test-Environment $Result @Logs

Test-Output $Status -Command Test-Environment @Logs

Update-Log
Exit-Test
