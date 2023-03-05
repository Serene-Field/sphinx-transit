# Computer Network 10 | Midterm Review

### 1. OSI Basics

#### (1) Layers

- The Internet architecture was not instrumented with security as a central piece and design choice
- DNS is primarily designed to translate domain names into IP address
- The Internet protocol stack is based on layers architecture
- Both data link and transport layer protocols may provide error correction
- If one layer of the protocol stack offers a specific service like error detection, then the service can still be offered by other layers
- Sockets allows for communication between the application layer and transport layer
- HTTP, SMTP, FTP, DNS belongs to the application layer
- TCP, UDP belongs to the transport layer
- IP and routing protocols belongs to the network layer
- ETHERNET, Wifi belongs to the data link layer
- When an application sends a packet of information across the network, the packet travels down the IP stack and undergoes the encapsulation process

#### (2) E2E Principle
- According to E2E principle, most of the Internet's functionality and intelligence should be implemented at the edges of a network
- Some data link layer protocols, such 802.11 (WiFi), implement some basic error correction as the physical medium used is easily prone to interference and noise (such as a nearby running microwave). This is not a violation of the end-to-end principle.
- Violations of the e2e principle typically refer to scenarios where it is not possible to implement a functionality entirely at the end hosts, such as NAT and firewalls.
- The E2E princile suggst that complex functions should be implemented at the end-hosts while the network core should be kept simple.
- Middleboxes (like firewalls and NATs) that do not conform with the E2E principle can still be deploy in a network.


#### (3) Hour Glass Structure (EvoArch)

- Many technologies that were not originally designed for the internet have been modified so that they have versions that can communicate over the internet (such as Radio over IP).
- It has been a difficult and slow process to transition to IPv6, despite the shortage of public IPv4 addresses.
- One consequence of the narrow waist is the cost of transitioning is high
- According to EvoArch, the model predicts that even if new Internet architectures are not initially designed to have the shape of an hourglass, they will probably do so as they evolve over time.
- The evolution of the internet protocol has shown that the most of the innovations have beem happening at the top and the bottom of the protocols hourglass.

#### (4) Spanning Tree Protocol

- The Spanning Tree Algorithm helps to prevent broadcast storms
- STP can not guarantee it's the best tree with all the nodes as close to the root as possible
- Traffic can still traverse an inactive link

#### (5) Network Devices

- Hubs, bridges, and routers operate on different layers of IP stack 
- Hub and repeater operates only on physical layer
- Switch and bridge operates on physical layer and data link layer
- Consider a learning bridge,
    - Asssume that the bridge receives a frame with source MAC unknown and destionation known to its forwarding table. Then it will add the source MAC address and the corresponding port the frame come from into the forwarding table. Then send out the frame out to the appropriate port.
    - Asssume that the bridge receives a frame with both souce and destionation MAC addresses unknown, then it will first add the source MA address and the corresponding port the frame came from into the forwarding table. Then the bridge will flood the frame over all ports except the port the frame came from.

### 2. Transport Layer

#### (1) 

- TCP and UDP have almost different functionalities
- A transport layer protocol provides for logical communication between application processes running on different hosts. 
- An application running on a host can bind to multiple sockets simultaneously
- A host can maintain a TCP socket and a UDP socket simutaneously
- The identifier of a UDP socket is a 2-item tuple of destination IP address and port
- The identifier of a TCP socket is a 4-item tuple of source IP address and port, and destination IP address and port.
- UDP is considered more lightweight than TCP
- When two hosts use TCP to send and receive messages, they need to signal the end of sending data to each other when they are done
- TCP and UDP offers basic error checking by 1's complement for checksums
- UDP doesn't offer the function to increase or decrease the pace with which the sender sends data to the receiver. 
- Assume hosts A, B, C. Host A has a UDP socket with port 123. Host B and C each send their own UDP segment to host A. Host B and C can still use the same destination port 123 for sending UDP segment.
- TCP offers in-order delivery of the packets, flow control, and congestion control
- TCP detects packet loss using timeouts and triple duplicate acknowledges
- Consider TCP, after the sender receives the 3rd duplicate ACK, 
    - the sender will resend the packet shown in the ACK
    - the congestion window will be reduced to half
- A triple duplicate ACKs event is considered a less severe indication of 
- Flow control is a rate control mechianism to protect the receiver's buffer from overflowing
- Congestion control is a rate control mechanism to protect the network from congestion
- TCP receive window is designed to not overflow the receiver's buffer
- In TCP, the number of unacknowledged segments that a send can have is the minimum of congestion window and the receive window
- Consider TCP Reno, 
    - congestion window is cut in half when it detects a triple duplicate ACKs
    - congestion window is reduced to its initial value when a timeout event occurs
- Consider a TCP connection and a diagram showing the congestion as it progresses over time. From the diagram, 
    - when we observe the congestion window drops to its initial vale, then we can infer that a packet loss occurred.
    - we can identify the time periods of additional increment when the congestion window increases by 1 per RTT
    - we can identify the time periods of slow start when the congestion window is increased exponentially per RTT from 1
- TCP Cubic is designed for better network utilization
- TCP Cubic uses a cubic function to increase the congestion window
- TCP Cubic doesn't increase the congestion window in every RTT. 
- TCP Cubic has a congestion window growth independent of RTTs.
- TCP Cubic has a congestion window growth independent because CUBIC's congestion window growth function depends on the real time between congestion events
- 