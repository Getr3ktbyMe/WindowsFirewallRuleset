
# Delivery Optimization

If you set up Delivery Optimization to create peer groups that include devices across NAT's,
(or any form of internal subnet that uses gateways or firewalls between subnets),
it will use Teredo.

For this to work, you must allow inbound TCP/IP traffic over port 3544.
Look for a "NAT traversal" setting in your firewall to set this up.

Delivery Optimization also communicates with its cloud service by using HTTP/HTTPS over port 80.

## Setting

Settings -> Updates & Security -> Allow download from other PC's (PC's on my local network)

## Services

For delivery optimization:

- **Delivery Optimization (DoSvc)**
  - Remote Procedure call (RPC)...

For teredo:

- **IP Helper (iphlpsvc)**
  - Network Store Interface Service...
  - Remote Procedure call (RPC)...
  - TCP/IP Protocol Driver (Driver: KERNEL_DRIVER, startup type = BOOT_START)
  - Windows Management instrumentation
  - WinHTTP Web Proxy Auto-Discovery Service
