
<#
NOTE: This file has been sublicensed by metablaster zebal@protonmail.ch
under a dual license of the MIT license AND the ISC license, see both licenses below
#>

<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

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
ISC License

Copyright (C) 2016, Chris Dent

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#>

#region:TestFileHeader
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
	"PSReviewUnusedParameter", "Number", Justification = "Likely false positive")]
param (
	[bool] $UseExisting
)

if (-not $UseExisting)
{
	$ModuleBase = $PSScriptRoot.Substring(0, $PSScriptRoot.IndexOf("\Test"))
	$StubBase = Resolve-Path (Join-Path $ModuleBase "Test*\Stub\*")

	if ($null -ne $StubBase)
	{
		$StubBase | Import-Module -Force
	}

	Import-Module $ModuleBase -Force
}
#endregion

InModuleScope Ruleset.IP {
	Describe 'ConvertFrom-HexIP' {
		It 'Returns an IPAddress' {
			ConvertFrom-HexIP '12345678' | Should -BeOfType [ipaddress]
		}

		It 'Converts 30201000 to 48.32.16.0' {
			ConvertFrom-HexIP '30201000' | Should -Be '48.32.16.0'
		}

		It 'Converts 00000000 to 0.0.0.0' {
			ConvertFrom-HexIP '00000000' | Should -Be '0.0.0.0'
		}

		It 'Converts FFFFFFFF to 255.255.255.255' {
			ConvertFrom-HexIP 'FFFFFFFF' | Should -Be '255.255.255.255'
		}

		It 'Converts "0xFFFFFFFF" to 255.255.255.255' {
			ConvertFrom-HexIP '0xFFFFFFFF' | Should -Be '255.255.255.255'
		}

		It 'Accepts pipeline input' {
			'00FF00FF' | ConvertFrom-HexIP | Should -Be '0.255.0.255'
		}

		It 'Throws an error if the input format is not valid' {
			{ ConvertFrom-HexIP '1GFFFFFF' } | Should -Throw
		}

		It 'Example <Number> is valid' -TestCases (
			(Get-Help ConvertFrom-HexIP).Examples.Example.Code | ForEach-Object -Begin {
				[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
					"PSUseDeclaredVarsMoreThanAssignment", "", Justification = "FalsePositive")]
				$Number = 1
			} -Process {
				@{ Number = $Number++; Code = $_ }
			}
		) {
			param (
				$Number,
				$Code
			)

			$ScriptBlock = [ScriptBlock]::Create($Code.Trim())
			$ScriptBlock | Should -Not -Throw
		}
	}
}
