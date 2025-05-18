# Nmap Switches

Note : In this repository, I plan to explain some of the important Nmap switches along with the use of its scripts and give you some examples(For those who are new to working with Nmap).


1)Main and frequently used scans:

- [TCP Connect Scan](#-sT)
- [SYN Half-Open Scan](#-sS)
- [UDP Scan](#-sU)

2)More advanced scans:(Less commonly used)

- [TCP Null Scan](#-sN)
- [SYN Fin Scan](#-sF)
- [TCP XMAS Scan](#-sX)
- [Maimon Scan](#-sM)
- [ICMP](#Ping-Scan)


<h2 id="-sT">TCP Connect Scan (-sT)</h2>
Scanning Mechanism:
The -sT scan detects port status by performing a full TCP three-way handshake.

Steps:

1.Send a SYN packet from Nmap to the target port.

2.Nmap marks the port as open → Sent back to Nmap → If the port responds with SYN/ACK

3.If the port is closed → RST (Reset) packet is sent → Nmap marks the port as closed.

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
- Scan for specific ports
```bash
nmap -sT -p 80,443,22 192.168.1.1
```

- Impact of Firewalls

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

1. -sT Scan (TCP Connect Scan):

Suitable for legal/compliance audits where root access is unavailable.

Poor stealth option for penetration testing (leaves clear logs in firewalls).

2. Advanced Firewall Environments:

Combining -sT scans with other techniques (e.g., UDP scans or NSE scripts) is essential to bypass defenses.

3. Reducing Detection Risk:

Use SYN scans (-sS) for stealthier scanning.

Requires root access (operates at a lower network layer).



| Scan type        	| Fully HandShake 	| Root access 	| Stealth 	| Speed  	|
|------------------	|-----------------	|-------------	|---------	|--------	|
| TCP Connect(-sT) 	| ✔️               	| ❌           	| ❌       	| Medium 	|
| SYN Scan(-sS)    	| ❌               	| ✔️           	| ✔️       	| Fast   	|


<h2 id="-sS">SYN Half-Open Scan (-sS)</h2> 


Mechanism of -sS (SYN Scan):  
The SYN scan (half-open scan) detects the status of target ports by sending a SYN packet to the port and analyzing the response.  


 TCP 3-Way Handshake Process:  
1. Send SYN:  
   - A packet with the SYN flag is sent to the target port.  

2. Server Response:  
   - If the port is open:  
     - The server replies with a SYN/ACK packet.  
     - Nmap sends an RST to terminate the connection.  
   - If the port is closed:  
     - The server replies with an RST packet.  

3. Handshake Not Completed:  
   - Unlike the TCP Connect Scan, the connection is not fully established (no final ACK sent by Nmap).  



| Port status 	| Server response           	| Result in nmap 	|
|-------------	|---------------------------	|----------------	|
| Open        	| SYN/ACK → RST is Sent     	| Open           	|
| Closed      	| RST                       	| Closed         	|
| Filtered    	| ICMP Error / Not response 	| Filtered       	|

- Advantages and disadvantages


| Advantages                                                                                                     	| Disadvantages                                                                                                                        	|
|--------------------------------------------------------------------------------------------------------------	|--------------------------------------------------------------------------------------------------------------------------------------	|
| Harder to detect by IDS/Firewalls: SYN scans avoid completing the TCP handshake, reducing detection chances. 	| Requires root/administrator privileges: On Linux, raw socket access (root) is needed to craft SYN packets.                           	|
| Faster than TCP Connect Scan: No time wasted on full handshake completion.                                   	| May crash unstable services: Sending abrupt RST packets can disrupt poorly configured or vulnerable services                         	|
| Minimal logging: Since the connection is never fully established, fewer traces are left in logs.             	| Windows compatibility issues: Windows systems may require additional configurations (e.g., Npcap drivers) for raw packet operations. 	|


SYN Scan vs. TCP Connect Scan:

| Feature          | SYN Scan (-sS)                     | TCP Connect Scan (-sT)         |
|----------------------|----------------------------------------|------------------------------------|
| Root Access      | Required                               | Not required                       |
| Speed            | Fast                                   | Slow                               |
| Stealth          | Stealthier (no full handshake)         | Less stealthy (completes handshake)|
| Service Impact   | May disrupt unstable services          | Minimal impact                     |



<h2 id="-sU">UDP Scan (-sS)</h2> 

 UDP Scan Mechanism
- Protocol: Connectionless (no TCP handshake).  
- Challenge: Detecting open UDP ports due to default lack of response.  

Port Status Detection:  
- Open Port: Usually no response (rarely, a UDP response may indicate openness).  
- Closed Port: ICMP "Port Unreachable" response.  
- Filtered Port: No response (firewall drops packets) → Reported as Open/Filtered.  

UDP Scan Challenges & Advantages
| Challenges                     | Advantages                          |
|------------------------------------|-----------------------------------------|
| Very slow (e.g., ~20 minutes)      | Identifies critical UDP services (DNS, DHCP). |
| Ambiguous results for Open/Filtered| Detects closed ports via ICMP responses. |

 Commands for UDP Scanning
1. Fast Scan (Top Ports):  
   ```bash
   nmap -sU --top-ports 20 192.168.1.1
   ```
2. Targeted Port Scan:  
   ```bash
   nmap -sU -p53,161,123 -T4 192.168.1.1
   ```
Note: Full UDP scans are not recommended due to extreme slowness.


 TCP vs. UDP Scan Comparison
| Feature      | UDP Scan (-sU)                      | TCP SYN Scan (-sS)              |
|------------------|-----------------------------------------|-------------------------------------|
| Protocol     | Connectionless (UDP)                    | Connection-oriented (TCP)           |
| Speed        | Very slow                               | Fast                                |
| Accuracy     | Ambiguous for Open/Filtered ports       | High accuracy for open/closed ports |
| Root Access  | Not required                            | Required                            |


## Advanced TCP Scans 
<h2 id="-sN"> Null Scan (-sN)</h2>

   - Sends a TCP packet without any flags.  
   - Response Analysis:  
     - No response: Port marked as Open/Filtered.  
     - RST response: Port marked as Closed.

     
<h2 id="-sF"> FIN Scan (-sF)</h2>

- Sends a TCP packet with the FIN flag (typically used to close connections).

- Response Analysis: Same as Null Scan.

   
<h2 id="-sX">Xmas Scan (-sX)</h2>

   - Sends a TCP packet with FIN, URG, and PSH flags (like a "lit-up" Christmas tree).  
   - Response Analysis:  
     - No response: Port marked as Open/Filtered.  
     - RST response: Port marked as Closed.
    
<h2 id="-sM">Maimon Scan (-sM)</h2>

   -  Sends a TCP packet with FIN/ACK flags.  
   -  Some systems (e.g., BSD) respond with RST for closed ports.  

Firewall Detection & OS Compatibility:  

| Scan Type | Flags Sent | Firewall Detection Risk | Windows Compatibility |  
|---------------|----------------|------------------------------|---------------------------|  
| Null          | None           | Medium                       | ❌                        |  
| FIN           | FIN            | Medium                       | ❌                        |  
| Xmas          | FIN, URG, PSH  | High                         | ❌                        |  


