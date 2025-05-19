#Main Scans:
#TCP Connect Scan

#Example:
nmap -sT 192.168.1.1

#Scan for specific ports:
nmap -sT -p 80,443,22 192.168.1.1

#Impact of Firewalls:
iptables -I INPUT -p tcp --dport 80 -j REJECT --reject-with tcp-reset

#UDP Scan:

#Fast Scan(Top ports):
nmap -sU --top-ports 20 192.168.1.1

#Targeted Port Scan:
nmap -sU -p53,161,123 -T4 192.168.1.1

#Ping Sweep:
nmap -sn 192.168.0.0/24                  # Scan entire subnet
nmap -sn 192.168.0.1-254                 # Scan IP range  
nmap -sn 192.168.0.0/24 -oN ping.txt     # Save results to a file 

#NSE Scripts:
nmap --script vuln,brute 192.168.1.1       #Run specific scripts  
nmap --script "category=safe" 192.168.1.1  #Run all safe scripts  
nmap --script-updatedb                     #Update script database  

#Firewall Evasion Tips:
nmap -sS -f -Pn -T4 192.168.1.1   #Stealthy SYN scan with fragmentation  
