---
external help file: Ruleset.IP-help.xml
Module Name: Ruleset.IP
online version: https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.IP/Help/en-US/ConvertTo-DecimalIP.md
schema: 2.0.0
---

# ConvertTo-DecimalIP

## SYNOPSIS

Converts a Decimal IP address into a 32-bit unsigned integer.

## SYNTAX

```none
ConvertTo-DecimalIP [-IPAddress] <IPAddress> [<CommonParameters>]
```

## DESCRIPTION

ConvertTo-DecimalIP takes a decimal IP,
uses a shift operation on each octet and returns a single UInt32 value.

## EXAMPLES

### EXAMPLE 1

```none
ConvertTo-DecimalIP 1.2.3.4
```

Converts an IP address to an unsigned 32-bit integer value.

## PARAMETERS

### -IPAddress

An IP Address to convert.

```yaml
Type: System.Net.IPAddress
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [ipaddress] A decimal IP address

## OUTPUTS

### [uint32] 32-bit unsigned integer value

## NOTES

Following changes by metablaster:
- Include licenses and move comment based help outside of functions
- For code to be consistent with project code formatting and symbol casing.
- Removed unnecessary position arguments, added default argument values explicitly.

## RELATED LINKS
