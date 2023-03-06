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

#### (1) Sockets

- An application running on a host can bind to multiple sockets simultaneously
- A host can maintain a TCP socket and a UDP socket simutaneously

#### (2) UDP

- The identifier of a UDP socket is a 2-item tuple of destination IP address and port
- UDP is considered more lightweight than TCP
- UDP doesn't offer the function to increase or decrease the pace with which the sender sends data to the receiver. 
- Assume hosts A, B, C. Host A has a UDP socket with port 123. Host B and C each send their own UDP segment to host A. Host B and C can still use the same destination port 123 for sending UDP segment.
- UDP does not have a mechanism used to estimate the RTT between the sender and the receiver.

#### (3) TCP

- A transport layer protocol provides for logical communication between application processes running on different hosts. 
- TCP and UDP have almost different functionalities
- TCP and UDP offers basic error checking by 1's complement for checksums
- The identifier of a TCP socket is a 4-item tuple of source IP address and port, and destination IP address and port.
- When two hosts use TCP to send and receive messages, they need to signal the end of sending data to each other when they are done
- TCP offers in-order delivery of the packets, flow control, and congestion control
- TCP detects packet loss using timeouts and triple duplicate acknowledges
- TCP provides a mechanism to estimate the RTT between the sender and the receiver.
- TCP algorithm can switch from the congestion avoidance phase to slow start
- Consider TCP, after the sender receives the 3rd duplicate ACK, 
    - the sender will resend the packet shown in the ACK
    - the congestion window will be reduced to half
- In TCP, a triple duplicate ACKs event is considered a less severe indication of timeout

#### (4) Flow Control

- Flow control is a rate control mechianism to protect the receiver's buffer from overflowing
- TCP receive window is designed to not overflow the receiver's buffer

#### (5) Congestion Control

- Congestion control is a rate control mechanism to protect the network from congestion
- In TCP, the number of unacknowledged segments that a send can have is the minimum of congestion window and the receive window
- Consider TCP Reno, 
    - congestion window is cut in half when it detects a triple duplicate ACKs
    - congestion window is reduced to its initial value when a timeout event occurs
- Consider a TCP connection and a diagram showing the congestion as it progresses over time. From the diagram, 
    - when we observe the congestion window drops to its initial vale, then we can infer that a packet loss occurred.
    - we can identify the time periods of additional increment when the congestion window increases by 1 per RTT
    - we can identify the time periods of slow start when the congestion window is increased exponentially per RTT from 1

#### (6) TCP Cubic
- TCP Cubic is designed for better network utilization
- TCP Cubic uses a cubic function to increase the congestion window
- TCP Cubic doesn't increase the congestion window in every RTT. 
- TCP Cubic has a congestion window growth independent of RTTs.
- TCP Cubic has a congestion window growth independent because CUBIC's congestion window growth function depends on the real time between congestion events
- The event that triggers the TCP algorithm to switch from the slow start to the congestion avoidance phase is the congestion window reaches a threshold.

### 3. Network Layer

#### (1) Intradomain Routing

- When we talk about route cost about the intradomain routing process, the following items can be the edge weights
    - length of the cable 
    - time delay to traverse the link
    - mometary dost
    - link capacity
    - current load on the link
- Routing and forwarding are not interchangeable terms.
- Routing is network-wide which involves multiple routers
- Forwarding is router-wide which refers to send a packet from input link to the apporate output link in a router
- Consider a source and destination host. Before packets leave the source host, the host doesn't need to define the path over which the packets will travel to reach the destionation host. 
- Intradomain routing refers to routing that takes place among routers that belong to the same administrative domain. 
- Routers can run different intradomain algorithm even when they are on the same path for a pair of hosts in different administrative domains

#### (2) Link State

- Upon termination of Dijkstra’s algorithm, all nodes in a network are aware of the entire network topology
- Dijkstra is a global algorithnm which is also referred to as a link-state algorithm
- Consider Link-State Routing Protocol, 
    - the network topology is known to all nodes.
    - the goal is to compute the least-cost pathds from the source to every other node in the network
    - when initialization, we have the initial least cost path for neighbors as the cost of the direct links, and non-neigbors as infinity
- OSPF is based on the link state routing algorithm 
- In the previous example, node u was the source node, and distances were calculated from u to each other node. Consider the same example, but let x be the source node. Notice that node x has more direct neighbors than u does. Suppose x is executing the linkstate algorithm as discussed, and has just finished the initialization step. Node x will execute the same number of iterations that node u did, as the number of immediate neighbors has no impact on the number of iterations the algorithm requires.
![](https://i.imgur.com/qNDy3j8.png)
- Consider the following topo, then decide the cost to all the nodes in from source `b`,
![](https://i.imgur.com/4PbmRdg.png)
    - a: 3
    - c: 4
    - d: 6
    - e: 8
    - f: 9
- Consider the following topo
```
u ---- 1 ---- v ---- 1 ---- w ---- 4 ---- x
|                           |
+ ----------- 3 ----------- + 
```
Then fill in blanks of the following table,
```
Step    N'        D(v),p(v)      D(w),p(w)      D(x),p(x)
0       u         1,u            3,u            inf
1
2
3
```
The solution is,
```
Step     N'        D(v),p(v)      D(w),p(w)      D(x),p(x)
0        u         1,u            3,u            inf
1       u,v        1,u            2,v            inf
2      u,v,w       1,u            2,v            6,w
3     u,v,w,x      1,u            2,v            6,w
```


#### (3) Distance Vector

- Distance vector algorithm continues iterating as long as neighbors send new updates to each other
- Distance vector is an example of decentralized algorithm
- Distance vector is an asynchronous algorithm which doesn't require synchronization between routers
- Distance vector is a self-terminating algorithm with no signal to stop
- In distance vector routing algorithm, each node maintains and updates its own view of the network
- Consider the DV algorithm, 
    - the Bellman Ford equation is used by each node to update the node's distance vector
    - the distance vector, that each node maintains, is a table with costs to reach every node in the network.
- The cause of count-to-infinity problem are routing loops
- The count-to-infinity problem states that a bad news (e.g. an increased link cost) propagates slowly among nodes in the network
- The poison reserve technique solves the count-to-infinity problems but not for topologies involving 3 or more nodes that are not directly connected
- RIP is based on distance vector protocol

#### (4) Hot Potato

- There may be multiple egress points from an administrative domain to an external destination
- The number of egress points that a network has is unlimited
- The different egress points in a network that offer different paths to the same external destination can have the same cost
- According to the hot potato routing technique, 
    - it is in the network’s best interest to route the traffic so that it takes the closest exit out of the network.
    - it is not in a network's best interest to route the traffic if it exits the network at the router geographically closest to the one from which it entered the network
- Hot potato routing always selects the cloest egress point based on inteadomain path cost rather than the egress point that is geographically closest to the ingress point.
- Suppose we have the following topo inside an AS with `A` and `B` are egresses.
```
-> S ---- 20 ----> C ---- 31 ----> D ---->  |
   |                                        | Neighbor AS
   + ---- 50 ----> A -------------------->  | 
```
Then with hot potato routing, `S` will choose the path goes through egress `A`.

#### (5) Interdomain Routing

- Interdomain routing refers to routing that takes place among routers that belong to different administrative domains. 
- Internet topology has been envolving to an increasingly prominent flat structure

#### (6) Autonomous System 

- An AS operates in a single administrative domain
- An AS is a group of routers that operate under the same administrative domain
- A CDN ot an ISP can operate over multiple ASes.
- Two ASes are not required to find common ground in internal policies and traffic engineering approaches to form a peering agreement
- Suppose we have the following AS relationships, where C1, C2, C3 are customers of ISP-X and ISP-P is a provider of ISP-X. Then,
![](https://i.imgur.com/2AvTBR0.png)
    - ISP-X has the incentive to advertise routes for C3 to Y
    - ISP-X has no incentive to advertise routes for ISP-P's customers to Y and Z
    - Assume ISP-X learns multiple routs for the same external destination W. These multiple routes are advertised from C3, Y, and ISP-P. Then the rank of importing should be,
        - routes from C3
        - routes from Y
        - routes from ISP-P
- In a peering relationship, the traffic exchanged between two peers have to be symmetric so that there's enough incentive
- The customer pays AS regardless of the direction of the traffic
- When a router receives multiple advertisements for the same destination, it prefers the routes it learns from the customer’s networks first
- Suppose that two peer routers have an open BGP session, it would trigger a router to terminate the session if the peer router is not sending KEEPALIVE messages within the specified keepalive timer.

#### (7) BGP

- ASes implement their own set of policies, make their own traffic engineering decisions and interconnection strategies, and determine how traffic leaves and enters the network.
- AS has control over which routes are selected through attributes like `LocalPerf` and `MED`
- An AS can use LocalPref to control which routers are used as exit points (for the outgoing traffic), and it can use the MED attribute to control which routers are used as entry points (for the incoming traffic).
- Once a router learns about a prefix from another router through eBGP, it needs to check the import policy before entering the path and update its Forwarding Information Base (FIB).
- A router within an AS decides which route to export by first applying import policies to exclude routes entirely from further consideration
- Consider the following topology
![](https://i.imgur.com/itP1Foy.png)
    - R-A1 to R-A3 uses iBGP
    - R-B1 to R-A3 uses eBGP
    - After R-D2 learns a route to a destination in AS-A via eBGP, R-D2 disseminate this route to R-D3 and R-D1 via iBGP
    - After R-D2 learns a route to a destination in AS-D, R-D2 disseminate this route to R-D3 and R-D1 via IGP
    - After R-B1 learns about a route to a destination in AS-C, it disseminate this route to R-A3 via eBGP
    - Assume AS-B learns about an exteral destination both from AS-C and AS-A, then it can show preference to use the route heard from AS-C by assigning higher LocalPerf value to that route
    - Assume AS-B adertises the routes to its internal destination to AS-A using routers R-B1 and R-B4. Then AS-B can communicate to AS-A that it prefers R-B1 as an entry to the network by assigning lower MED values to these routers
    - R-D1 learns from routes for AS-B with iBGP and eBGP
    
#### (8) IXPs

- One of the services provided by IXPs is additional security protections such as mitigation of DDoS (Distributed Denial of Service) attacks.
- There are costs involved for an AS to participate at an IXP.
- TXPs tries to limit the traffic local to save cost
- IXPs handle large volumes of traffic
- An IXP is not responsible for deep packet inspection and traffic filtering for each AS participant.
- When a large CP or CDN joins an IXP, this can act as an incentive for other networks to join as well.
- At an IXP, the members have the choice to peer privately or publicly.
- The main incentive for an IXP to establish route servers is to simplify the exchange of routing information between participants, which can improve network efficiency, reduce operational costs, and improve network performance.
- An IXP route server (RS) need to run the BGP protocol to facilitate the establishment of multi- lateral peering sessions.
- For multi-lateral BGP peering sessions at an IXP, 
    - the participants do not have the choice to advertise routes directly to other participants
    - the participants should advertise routes to the route server
- Private peering PIs do not use IXP's public peering infrastructure
- IXPs users can use RS without additional costs
- RS keeps track of BGP sessions with each particiant AS through RIBs
- RS uses import filters to maintain each AS only advertises routes that it should advertise
- RS uses export filters to restrict the set of other IXP member ASes that receive their routes

#### (9) Routers

- The router can have many IP addresses depending on its interfaces.
- The data plane functions of a traditional router are implemented in hardware
- The control plane functions of a traditional router are implemented in software
- Data plane operates on a shorter timescale 
- Data plane operates the following functions,
    - Forwarding packets at Layer 3
    - Switching packets at Layer 2
    - Decrementing Time To Live (TTL) 
    - Computing an IP header checksum
    - Forwarding packets according to installed rules in a middlebox device 
    - Filtering packets through a middlebox device 
- Control plane operates the following functions,
    - Computing paths based on a protocol
    - Running routing algorithms
    - Running protocols to build a routing table
    - Computing routing paths to optimize the use of the network
    - Running the Spanning Tree protocol
    - Running a protocol/logic to configure a middlebox device for load balancing
- The forwarding functions of a traditional router refer to transferring packets from the input ports to the appropriate output ports
- The control plane functions can either be implemented in the router's processor or they can be outsourced for implementation at a remote controller
- In traditional routers, traffic forwarding is performed based on destination IP address only

#### (10) Prefix Match

- The mask of 192.168.0.1/24 is 255.255.255.0
- Unibit tries require the least amount of memory.
- Consider the following unibit trie. For each prefix look up, determine the node we return.
![](https://i.imgur.com/q5P0oHb.png)
     - 0* -> a
     - 1* -> b
     - 01* -> c
     - 00* -> a
     - 0000* -> e
     - 00011* -> h
- Suppose we have the forwarding table,
```
Prefix Match                Output Link
11100000 00*                A
11100000 01000000*          B
1110000*                    C
11100001 1*                 D
otherwise                   E
```
- Then,
    - `10001000 11110001 01010001 11110101` goes to port E
    - `11100001 01000000 11000011 00111100` goes to port C
    - `11100001 10000000 00010001 01110111` goes to port D
- Consider the following unibit trie
![](https://i.imgur.com/abip6TI.png)

    - longest prefix match for `111*` is P2
    - longest prefix match for `11011*` is P9
    - longest prefix match for `10*` is P4
- By stride we refer to the number of bits that we check at every step when traversing a trie.
- A multibit trie is shorter than a unibit trie representing the same prefix database and requires fewer memory accesses to perform a lookup. 
- Consider the following rules
```
P1   =>   101*  
P2   =>   0*  
P3   =>   1*  
P4   =>   10101*  
```
Consider expanding each prefix with stride length 3, so that we construct a fixed length multibit trie. The the following prefixes are associated with P3,
- Solution:
    - 110*
    - 100*
    - 111*
- Variant length multibit tries can support an arbitrary number of prefix lengths. 
- Construct the following variable-stride multibit trie
![](https://i.imgur.com/vS80YOy.png)
Then we will have the following prefix,
```
a => 0*
b => 01000* 
c => 011* 
d => 1* 
e => 100* 
f => 1100* 
g => 1101* 
h => 1110* 
i => 1111* 
```
Then fill in the nodes with the prefixes above,
```
n1: none
n2: a 
n3: a
n4: d
n5: d
n6: a
n7: a
n8: c
n9: c
n10: e
n11: d
n12: f
n13: g
n14: h
n15: i
n16: b
n17: a
```
- Crossbar switching can send multiple packets across the fabric in parallel.

#### (11) Packet Classification

- Using packet classification techniques we can perform packer forwarding based on multiple criteria, and not just based on destination IP address
- Set pruning tries are used to solve packet classification problem
- The backtracking approach has a higher cost in terms of time
- The set-pruning approach has a higher cost in terms of memory
- The grid of tries technique offers a “middle ground” approach, merging the backtracking and the set-pruning techniques.

#### (12) Packet and Traffic Scheduling

- The head-of-line blocking refers to the problem when an entire queue remains blocked because the head of the queue is blocked.
- One technique to avoid head of line blocking is with parallel iterative matching.
- With parallel iterative matching the input links are not matched with output links in a fixed manner
- The reason of make scheduling more complex than FIFO tail drop is because various types of traffic require different QoS
- The flow with small packet sizes will result in getting served more frequently with a round robin manner
- With the token bucket traffic approach, we can still have bursts of traffic entering the network, but these bursts are capped
- With the leaky bucket approach, we only allow the traffic to enter the network in a configured rate.
- Traffic policers target to limit traffic bursts to a configured max, whereas traffic shapers target to smooth out the overall rate.
- With the leaky bucket we can still have discarded packets.
