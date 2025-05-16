# Nmap Switches

*Note : In this repository, I plan to explain some of the important Nmap switches along with the use of its scripts and give you some examples(For those who are new to working with Nmap).
Source:[tryhackme.com] , [nmap.org]

1)Main and frequently used scans:

-[TCP Connect Scan](#-sT)
-[SYN Half-Open Scan](#-sS)
-[UDP Scan](#-sU)

2)More advanced scans:(Less commonly used)
-[TCP Null Scan](#-sN)
-[SYN Fin Scan](#-sF)
-[TCP XMAS Scan](#-sX)
-[ICMP](#Ping-Scan)

## TCP Connect Scan(-sT):
Scanning Mechanism:
The -sT scan detects port status by performing a full TCP three-way handshake.

Steps:

1.Send a SYN packet from Nmap to the target port.

2.Nmap marks the port as open → Sent back to Nmap → If the port responds with SYN/ACK

3.If the port is closed → RST (Reset) packet is sent → Port is marked as closed.

4.If a firewall drops the packets → No response is received → Port is marked as filtered.

| Port status | Respond              | Namp Result |
|-------------|----------------------|-------------|
| Open        | SYN/ACK              | Open        |
| Close       | RST                  | Close       |
| Filtered    | ICMP Error/No Result | Filtered    |

Example:

```bash
nmap -sT 192.168.1.1
```
-Scan for specific ports
```bash
nmap -sT -p 80,443,22 192.168.1.1
```

-Impact of Firewalls:

1. Firewalls that Drop Packets (No Response):
Behavior: When a firewall silently drops incoming packets (e.g., no SYN/ACK or RST response), Nmap waits for a timeout.

Result: Nmap marks the port as "filtered" (no response detected).

2. Firewalls that Send Fake RST Packets:
Behavior: Some firewalls are configured to send spoofed RST (Reset) packets to mislead scanning tools like Nmap.

Result: Nmap mistakenly marks the port as "closed" (since it receives an RST), even though the port might actually be open but protected by the firewall.

```bash
iptables -I INPUT -p tcp --dport 80 -j REJECT --reject-with tcp-reset
```

Key Notes:
1.-sT Scan (TCP Connect Scan):

Suitable for legal/compliance audits where root access is unavailable.

Poor stealth option for penetration testing (leaves clear logs in firewalls).

2.Advanced Firewall Environments:

Combining -sT scans with other techniques (e.g., UDP scans or NSE scripts) is essential to bypass defenses.

3.Reducing Detection Risk:

Use SYN scans (-sS) for stealthier scanning.

Requires root access (operates at a lower network layer).



| Scan type        	| Fully HandShake 	| Root access 	| Stealth 	| Speed  	|
|------------------	|-----------------	|-------------	|---------	|--------	|
| TCP Connect(-sT) 	| ✔️               	| ❌           	| ❌       	| Medium 	|
| SYN Scan(-sS)    	| ❌               	| ✔️           	| ✔️       	| Fast   	|
