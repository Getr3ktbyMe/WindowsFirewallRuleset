
# Firewall Parameters

Parameters and their values are not the same as they are displayed in Firewall GUI such as
GPO or Adv Windows firewall.

Explain what is what by mapping powershell parameters to GUI display equivalents.

In addition, explanation of other parameters which are not self explanatory or well documented
and usually need googling out what they do.

## Table of contents

- [Firewall Parameters](#firewall-parameters)
  - [Table of contents](#table-of-contents)
  - [Port](#port)
    - [LocalPort/RemotePort](#localportremoteport)
    - [LocalPort TCP Inbound](#localport-tcp-inbound)
    - [LocalPort UDP Inbound](#localport-udp-inbound)
    - [LocalPort TCP Outbound](#localport-tcp-outbound)
  - [Address](#address)
    - [RemoteAddress](#remoteaddress)
  - [Interface](#interface)
    - [InterfaceType](#interfacetype)
    - [InterfaceAlias](#interfacealias)
  - [Users](#users)
  - [Edge traversal](#edge-traversal)
  - [Policy store](#policy-store)
  - [Application layer enforcement](#application-layer-enforcement)
  - [Parameter value example](#parameter-value-example)
  - [Log file fields](#log-file-fields)
  - [Outbound](#outbound)
  - [Inbound](#inbound)

## Port

### LocalPort/RemotePort

- `Any` All Ports

### LocalPort TCP Inbound

- `RPCEPMap` RPC Endpoint Mapper
- `RPC` RPC Dynamic Ports
- `IPHTTPSIn` IPHTTPS

### LocalPort UDP Inbound

- `PlayToDiscovery` PlayTo Discovery
- `Teredo` Edge Traversal

### LocalPort TCP Outbound

- `IPHTTPSOut` IPHTTPS

## Address

- *Keywords can be restricted to IPv4 or IPv6 by appending a 4 or 6*

### RemoteAddress

- `Any` Any IP Address
- `LocalSubnet` Local Subnet
- `Internet` Internet
- `Intranet` Intranet
- `DefaultGateway` Default Gateway
- `DNS` DNS Servers
- `WINS` WINS Servers
- `DHCP` DHCP Servers
- `IntranetRemoteAccess` Remote Corp Network
- `PlayToDevice` PlayTo Renderers
- `<unknown>` Captive Portal Addresses

## Interface

### InterfaceType

- `Any` All interface types
- `Wired` Wired
- `Wireless` Wireless
- `RemoteAccess` Remote access

### InterfaceAlias

**NOTE:** Not fully compatible with interfaceType because interfaceType parameter has higher
precedence over InterfaceAlias, Mixing interfaceType with InterfaceAlias doesn't make sense,
except if InterfaceType is "Any", use just one of these two parameters.

- [WildCardPattern] ([string])
- [WildCardPattern] ([string], [WildCardOptions])

## Users

- `Localuser` Authorized local Principals
- `<unknown>` Excepted local Principals
- `Owner` Local User Owner
- `RemoteUser` Authorized Users

## Edge traversal

- `Block` Allow edge traversal
- `Allow` Block edge traversal
- `DeferToUser` Defer to user / Defer allow to user
- `DeferToApp` Defer to application / Defer allow to application

## Policy store

1. Persistent Store (example: `-PolicyStore PersistentStore`)
2. GPO              (example: `-PolicyStore localhost`)
3. RSOP             (example: `-PolicyStore RSOP`)
4. ActiveStore      (example: `-PolicyStore ActiveStore`)

- Persistent Store:

> is what you see in Windows Firewall with Advanced security, accessed trough control panel or
System settings.

- GPO Store:

> is specified as computer name, and it is what you see in Local group policy, accessed trough
secpol.msc or gpedit.msc

- RSOP:

> stands for "resultant set of policy" and is collection of all GPO stores that apply to local computer.
> this applies to domain computers, on your home computer RSOP consists of only single
local GPO (group policy object)

- Active Store:

> Active store is collection (sum) of Persistent store and all GPO stores (RSOP) that apply to
local computer. in other words it's a master store.

There are other stores not mentioned here, which are used in corporate networks, AD's or Domains,
so irrelevant for home users.

## Application layer enforcement

The meaning of this parameter value depends on which parameter it is used:

1. `"*"` Applies to services only / Apply to application packages only
2. `Any` Applies to all programs + and services / and application packages / that meet the specified
condition

## Parameter value example

This is how parameters are used on command line, most of them need to be enclosed in quotes if
assigned to variable first.

```none
Name                  = "NotePadFirewallRule"
DisplayName           = "Firewall Rule for program.exe"
Group                 = "Program Firewall Rule Group"
Ensure                = "Present"
Enabled               = True
Profile               = "Domain, Private"
Direction             = Outbound
RemotePort            = 8080, 8081
LocalPort             = 9080, 9081
Protocol              = TCP
Description           = "Firewall Rule for program.exe"
Program               = "c:\windows\system32\program.exe"
Service               = WinRM
Authentication        = "Required"
Encryption            = "Required"
InterfaceAlias        = "Ethernet"
InterfaceType         = Wired
LocalAddress          = 192.168.2.0-192.168.2.128, 192.168.1.0/255.255.255.0, 10.0.0.0/8
LocalUser             = "O:LSD:(D;;CC;;;S-1-15-3-4)(A;;CC;;;S-1-5-21-3337988176-3917481366-464002247-1001)"
Package               = "S-1-15-2-3676279713-3632409675-756843784-3388909659-2454753834-4233625902-1413163418"
Platform              = "6.1"
RemoteAddress         = 192.168.2.0-192.168.2.128, 192.168.1.0/255.255.255.0, 10.0.0.0/8
RemoteMachine         = "O:LSD:(D;;CC;;;S-1-5-21-1915925333-479612515-2636650677-1621)(A;;CC;;;S-1-5-21-1915925333-479612515-2636650677-1620)"
RemoteUser            = "O:LSD:(D;;CC;;;S-1-15-3-4)(A;;CC;;;S-1-5-21-3337988176-3917481366-464002247-1001)"
DynamicTransport      = ProximitySharing
EdgeTraversalPolicy   = Block
IcmpType              = 51, 52
IcmpType              = 34:4
LocalOnlyMapping      = $true
LooseSourceMapping    = $true
OverrideBlockRules    = $true
Owner                 = "S-1-5-21-3337988176-3917481366-464002247-500"
```

## Log file fields

Their meaning in order how they appear in firewall log file:\
[Interpreting the Windows Firewall Log](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc758040(v=ws.10))

`#Version:`

- Displays which version of the Windows Firewall security log is installed

`#Software:`

- Displays the name of the software creating the log

`#Time:`

- Indicates that all of the timestamps in the log are in local time

`#Fields:`

- Displays a static list of fields that are available for security log entries, as follows:

`date`

- Displays the year, month, and day that the recorded transaction occurred

`time`

- Displays the hour, minute, and seconds at which the recorded transaction occurred

`action`

- Displays which operation was observed by Windows Firewall
- The options available are OPEN, OPEN-INBOUND, CLOSE, DROP, and INFO-EVENTS-LOST

`protocol`

- Displays the protocol that was used for the communication
- The options available are TCP, UDP, ICMP, and a protocol number for packets

`src-ip`

- Displays the source IP address (the IP address of the computer attempting to establish communication)

`dst-ip`

- Displays the destination IP address of a communication attempt

`src-port`

- Displays the source port number of the sending computer
- Only TCP and UDP display a valid src-port entry
- All other protocols display a src-port entry of `-`

`dst-port`

- Displays the port number of the destination computer
- Only TCP and UDP display a valid dst-port entry
- All other protocols display a dst-port entry of `-`

`size`

- Displays the packet size, in bytes.

`tcpflags`

- Displays the TCP control flags found in the TCP header of an IP packet:\
`Ack` Acknowledgment field significant\
`Fin` No more data from sender\
`Psh` Push function\
`Rst` Reset the connection\
`Syn` Synchronize sequence numbers\
`Urg` Urgent Pointer field significant

`tcpsyn`

- Displays the TCP sequence number in the packet

`tcpack`

- Displays the TCP acknowledgement number in the packet

`tcpwin`

- Displays the TCP window size, in bytes, in the packet

`icmptype`

- Displays a number that represents the Type field of the ICMP message

`icmpcode`

- Displays a number that represents the Code field of the ICMP message

`info`

- Displays an entry that depends on the type of action that occurred
- For example, an INFO-EVENTS-LOST action will result in an entry of the number of events that occurred\
but were not recorded in the log from the time of the last occurrence of this event type.

`path`

- Displays the direction of the communication
- The options available are SEND, RECEIVE, FORWARD, and UNKNOWN

Following are mappings between log file, Firewall GUI and PowerShell parameters

## Outbound

```none
Log         GUI               PowerShell
src-ip      Local Address     LocalAddress
dst-ip      Remote Address    RemoteAddress
src-port    Local Port        LocalPort
dst-port    Remote Port       RemotePort
```

## Inbound

```none
Log         GUI               PowerShell
src-ip      Remote Address    RemoteAddress
dst-ip      Local Address     LocalAddress
src-port    Remote Port       RemotePort
dst-port    Local Port        LocalPort
```
