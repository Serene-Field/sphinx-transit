# Computer Network 2 | Introduction to Transport Layer, UDP and TCP, Congestion Control, Fairness

### 1. Introduction to Transport Layer

#### (1) Reasons for Transport Layer

It seems like we can transfer data based only on the application layer (i.e. where the applications locate) and the network layer (i.e. the source & destination IP addresses), so some may ask why do we need the transport layer in between the network layer and the application layer.

Recall what we have mentioned in the OSI model, the network layer maintain the best-effort delivery for packets. Thus, it doesn't **guarantee** the delivery of packets, nor it guarantees **integrity** in data. Because the transport layer maintains the delivery and checks the integrity, the application can run without worrying about the unreliability of the network.

#### (2) How Transport Layer Work

On the sender host, the transport layer receives a message sent from the application layer and then it appends its own header. The combined message is then called a **segment**. This transport layer will then send this segment to the network layer for encapsulation and then it will send it to the receiving host via routers, bridges, switches etc.

#### (3) Two Protocols in Transport Layer

Within the transport layer, there are two types of protocols - **User datagram protocol (UDP)** and the **Transmission Control Protocol (TCP)**. These protocols differ based on the functionality they offer to the application developers.

- UDP provides very basic functionality and relies on the application-layer to implement the remaining. 
- TCP provides some strong primitives with a goal to make end-to-end communication more reliable and cost-effective. 

In fact, because of these primitives, TCP has become quite ubiquitous and is used for most of the applications today. We will now look at these functionalities in detail.

#### (4) Ports

Commonly, we have multiple applications running with the same IP address, so it becomes a problem to distinguish data from the applications. So the transport layer comes in to solve this problem by **multiplexing** using additional identifiers known as **ports**. Thus, each application binds itself to a unique port number by opening sockets and listening for any data from a remote application.

#### (5) Multiplexing

With the help of ports, the transport layer is able to run multiple applications to use the network simultaneously, and this is referred as **multiplexing**.

More specifically, the **sending host** will need to gather data from different sockets, and encapsulate each data chunk with header information to create segments, and then forward the segments to the network layer. We refer to this job as multiplexing.

#### (6) Demultiplexing

The job of delivering the data that are included in a transport-layer segment to the appropriate socket, and then to the appropriate application, as defined in the segment fields, is called **demultiplexing**.

#### (7) Socket Identifiers

Sockets are software abstractions that allows different processes or applications talk through the same machine or different machines. It's the endpoint between the application and the end-to-end transport protocol. The sockets are identified based on special fields in the segment such as the **source port number field** and the **destination port number field** in the segments.

For UDP protocol, the segment is defined by,

```
------------------------------------------
|     src port      |      dst port      |  <-  socket id
------------------------------------------
|     Headlen       |      checksum      |
------------------------------------------
|                 data                   |
------------------------------------------
```

For TCP protocol, the segment is defined by,

```
----------------------------------------------------
|        src port         |        dst port        |  <-  socket id
----------------------------------------------------
|                     Sequence Num                 |
----------------------------------------------------
|                       ACK Num                    |
----------------------------------------------------
| Headlen | RSV |  Flags  |      Window Size       |
----------------------------------------------------
|        Checksum         |     Urgent Pointer     |
----------------------------------------------------
|                        Opts                      |
----------------------------------------------------
|                        data                      |
----------------------------------------------------
```

### 2. UDP and TCP

#### (1) UDP: Connectless Multiplexing/Demultiplexing

The identifier of a UDP socket is a **two-item tuple** consisted of 

- destination IP
- destination port number

When the receiving host receives the packet from the sending host, the packet will be de-encapsulated into IP addresses with segments. Then the transport layer in the receiving host identifies the correct socket by looking at the field of the destination port. In case the receiving host runs multiple processes, the segment will be demultiplexed for port numbers to target the apportate socket. 

Note that if the receiving host receives UDP segments with destination port number, it will forward the segments to the same destination process vis the destination socket, even if the segments are coming from different source hosts and/or different source port numbers.

#### (2) TCP: Connection Oriented Multiplexing/Demultiplexing

The identifier for a TCP socket is a **four-item tuple** that is consisted by,

- source IP
- source port number
- destination IP
- destination port number

Under this case, the TCP client created a socket and sends a connection request which is a TCP segment with a source port number chosen by the client. When the TCP server receives the connection request, the server would create a socket that is identified by the TCP socket identifier. After that, the upcoming packets with the same socket identifier will be demultiplexed and forward to this socket.

Note that several connections can be set up to the same socket identifier. In which case, the TCP server will be able to demultiplexing incoming data from multiple connections.

#### (3) Persistent HTTP vs Non-Persitent HTTP

A common TCP example is an HTTP webserver. Suppose we have a HTTP server listens to port 80. Then if multiple users are trying to access the webpage, the client and the server will establish TCP connection. If the connection is established for only once, this is called the **Persistent HTTP**. If the connection has to be established per response, then it is called **Non-Persitent HTTP**. In the second case, a busy webserver may experience severe performance impact.

#### (4) UDP Properties

In a word, the UDP protocol has the following proporties

- an unreliable protocol as it lacks the mechanisms that TCP has in place
- a connectionless protocol that does not require the establishment of a connection before sending packets

However, it does also provide some benefits,

- less delays with no connection management overhead
- better over sending data with no congestion control

#### (5) Applications Using UDP

Some of the real world services are using UDP. Most of them are using it because there's no need to maintain the connection before sending the packets and in most cases it will be a single question/response.

- Remote File Server: NFS was by default using UDP on RHEL5 but now it supports TCP
- Network Management: SNMP uses UDP because there's no need to maintain connections on an internal monitoring application
- Routing: RIP uses UDP to avoid overheads in transfer
- Domain Translation: DNS uses UDP because it's usually a single response

#### (6) TCP Connection Estsablish: Three-way Handshake

- Handshake 1. Client -> Server: 
    - TCP segment without data
    - flag `SYN = 1`
    - sequence number (after the port numbers): initial sequence number (aka. `isn`) generated by client, which is a random number between 0 (`hex = 0x00000000`) to 4,294,967,295 (`hex = 0xFFFFFFFF`). This is used to check the same respond stream so the client and the server won't mess up with the other packets.

- Handshake 2. Server -> Client:
    - TCP segment without data called SYNACK segment
    - flag `SYN = 1`
    - sequence number: `isn`
    - ACK number (after the sequence number): `isn + 1`

- Handshake 3. Client -> Server: 
    - TCP segment without data
    - flag `SYN = 0`
    - sequence number: `isn + 1`
    - ACK number: `isn + 1`

#### (7) TCP Connection Teardown: Four-way Handshake

- Handshake 1. Client -> Server
    - TCP segment with `FIN = 1` to trigger closing the server connection
- Handshake 2. Server -> Client
    - TCP segment with `ACK = 1` to confirm the server is closing
- Handshake 3. Server -> Client
    - TCP segment with `FIN = 1` to trigger closing the client connection
- Handshake 4. Client -> Server
    - TCP segment with `ACK = 1` to confirm the client is closing

#### (8) Reliable Transmission

Let's first think about the lost packets. Because the network layer is not reliable, the packets sent can be easily lost during the transmission, or the internet can easily corrupted. 

With UDP, most responses are one-time single response. So if the client can not get the respond from the server, it will generate a time out error and resend the request to get the respond. Also, the developer can take care of the network losses as well.

However, with TCP, the packets sequence should be in-order so we can not tolerant any packet loss during the transmission. Thus, TCP needs to implement **reliability**.

#### (9) Automatic Repeat Request (ARQ)

In order to maintain a reliable communication, the sender should be able to detect any of the packet loss within a short period of time. So one way to do so is to send acknowledgements from the receiver after it successfully receives each segment. If there's no acknowledgement of a packet within the given time, we can assume the packet is lost. This method of using acknowledgements and timeouts is also known as **Automatic Repeat Request** or **ARQ**.

#### (10) Stop and Wait ARQ

This can be implemented in verious ways. One common implementation is called the **Stop and Wait ARQ**. 

If the receiver hasn't receive the former packet but it does receive the latter packets, it will respond an acknowledge of the lost packet. When the sender detects **3 duplicate ACKs** from the server, it will be awared that the packet referred in the duplicate ACKs may be lost. So the sender will do a **fast retransmit** to send the lost packet again to the receiver.

#### (11) Go-Back-N

After the fast retransmit, 

- the **sender** would then send all packets from the most recently received in-order packet, even if some of them had been sent before.
- the **receiver** can simply discard any out-of-order received packets

This is called **go-back-N**, like a reset.

Note that in this process, the packets **buffer** is need for both the sender and the receiver. 

- the **sender** would need to buffer packets that have been transmitted but not acknowledged. 
- the **receiver** may need to buffer the packets because the rate of consuming these packets (say writing to a disk) is slower than the rate at which packets arrive.

#### (12) In-Order Maintainance 

Now, let's see another problem. How can the receiver know that which packet is the former one and which is the latter one? The answer is to use the **sequence number** in the TCP segment. After each transmission, the sequence number will be increased by the packet size so that the receiver can check and verify the correct order.

#### (13) Selective ACKing

in the above case, a single packet error can cause a lot of unnecessary retransmissions. To solve this, TCP uses **selective ACKing**.

With this mechanism, the receiver in this case would acknowledge a correctly received packet even if it is not in order. The out-of-order packets are buffered until any missing packets have been received at which point the batch of the packets can be delivered to the application layer.

Also, TCP would need to use a **timeout** as there is a possibility of ACKs getting lost in the network. In addition, TCP also uses duplicate acknowledgements as a means to detect loss.

### 3. Flow Control

#### (1) Reason for Flow Control

Now we have buffers on both the sender and the receiver, we need to provide some protection mechanism so that the buffer will not overflow. 

#### (2) Receive Window

In order to protect the buffer from overflowing, the sender maintains a variable called **receive window**. This variable is defined to provide the sender an idea of how much data the receiver can handle at the moment.

The receiving host maintains two variables after each  packet received,

- `LastByteRead`: number of byte that was last read from the buffer
- `LastByteRcvd`: last byte number that has arrived from sender and placed in the buffer

Based on these two variables and the receiver buffer size `RcvBuffer`, the receiver can get the receive window by,

```
rwnd = RcvBuffer - (LastByteRcvd - LastByteRead)
```

The receiver advertises this value of `rwnd` in every ACK segment it sends back to the sender so the sender can know how many packets it can send.

The sender also keeps track of two variables, `LastByteSent` and `LastByteAcked`, and the data sent should be,

```
UnAcked Data Sent = LastByteSent - LastByteAcked < rwnd
```

#### (3) Problem: Sender Blocking Scenario

Even through the method above can avoid the receiver buffer from overflowing, it can also cause a blocking problem. Let's think about a case when the receiver had informed the sender that `rwnd = 0`, then the sender stops sending the data. 

However, when the receiver consumes the data in the buffer, the sender will not know the new buffer space is now available and it will continue to be blocked from sending data.

#### (4) Solution: 1b Size Segments 

TCP resolves this problem by making sender continue sending segments of size `1 byte` even after when `rwnd = 0`. When the receiver acknowledges these segments, it will specify the rwnd value and the sender will know as soon as the receiver has some room in the buffer.

After the sender gets `rwnd != 0`, it will start to send new packets. We call this a **cold start**. Before we look into how we cold start, let's review the topic of AIMD (additive increase multiplicative decrease).

#### (5) Congestion Window

We have discussed how to protect the receiver buffer from overflow, now let's talk about how to avoid congestion so as to protect the network transmission. Two main results of the network congestion is **packet delay** and **packet loss**, and we definitely don't want them happen.

The idea of TCP congestion control is that each source uses the ACK to determine if the packet released earlier to the network was received by the receiving host. **Congestion window** represents the maximum number of unacknowledged data that a sending host can have in transit. It's actually the upper bound of `UnAcked Data Sent` we have discussed in above.

```
cwnd = max{UnAcked Data Sent}
```

When `cwnd` is too small, we will not fully utilize the network so there's a waste of resource. However, when `cwnd` is too large, there can be a congestion problem in the network. So in the TCP, it uses a **probe-and-adapt** approach in adapting the congestion window. Under regular conditions, TCP increases the congestion window trying to achieve the available throughput. Once it detects congestion then the congestion window is decreased.

Note that the upper bound of `UnAcked Data Sent` is not only decided by `cwnd`, it also has to be decided by `rwnd`, so,

```
LastByteSent – LastByteAcked <= min{cwnd, rwnd}
```

In a nutshell, a TCP sender cannot send faster than the slowest component, which is either the network or the receiving host.

#### (6) Congestion Control: AIMD

TCP decreases the window when the level of congestion goes up, and it increases the window when the level of congestion goes down. We refer to this combined mechanism as **additive increase/multiplicative decrease (AIMD)**.

**Additive increase** means to increase the congestion window by one packet every RTT (i.e. round trip time). So every time the sending host successfully sends a `cwnd` number of packets, `cwnd += 1`.

Also, in practicem, this increase in AIMD happens incrementally. TCP increases `cwnd` as soon as each ACK arrives, and the increment is decided by **MSS** (i.e. **maximum segment size**).

```
Increment = MSS^2 / cwnd
cwnd += Increment
```

Multiplicative decrease means when congestion is detected by a timeout occuring, it sets the congestion window (`cwnd`) to **half** of its previous value.

#### (7) Slow Start

When we have a connection starts from cold start, it takes too long if we increase congestion window `cwnd` by AIMD. Therefore, we need a mechanism which can rapidly increase the congestion window from a cold start.

To handle this, a **slow start** phase is introduced where the congestion window is increased exponentially instead of linearly as in the case of AIMD. The congestion window starts from 1 and each time the sender receives an ACK, `cwnd` will be doubled. 

Once the congestion window becomes more than a threshold (often referred to as slow start threshold), it starts using AIMD.

#### (8) TCP Tahoe

Tahoe is a lake in the US. This particular TCP was designed around that lake and hence it was named TCP Tahoe. It is designed because the initial TCP in 1981  doesn't have congestion control. 

TCP Tahoe is designed as,

```
TCP Tahoe = Slow Start + AIMD + Fast Retransmit
```

#### (9) Fast Recovery

Recall what we have discussed for fast retransmit. The idea is when the sender receives triple duplicate ACKs, it will send the lost packet and then do Go-Back-N to resend the data. Selective ACKing is designed to avoid sending to much replicate packets. However, can we further improve Go-Back-N so that we can have a better efficiency?

When a packet is lost in transmission, it can be caused by either the network is congest or the network has bad connection. In either case, if the sender receives triple duplicate ACKs, it means the network is back and performing well again. So in that case, we don't have to do Go-Back-N and start over from cold start. Instead, we will do a similar operation like multiplicative decrease. This is to reduce the congestion window by half recover from there. This is called **fast recovery**.

#### (10) TCP Reno

Reno is another US city near Tahoe Lake and TCP Reno is an algothrim designed upon TCP Tahoe. 

TCP Reno is designed as,

```
TCP Reno = TCP Tahoe + Fast Recovery
```

#### (11) Sawtooth Pattern

Because TCP continually decreases and increases the congestion window throught the lifetime of the connection, if we plot the cwnd with respect to time, we observe that it follows a sawtooth pattern as shown,

![](https://i.imgur.com/kRE9U50.png)

### 4. TCP Fairness

#### (1) Goals of Congestion Control

For designing the TCP congestion control algorithm, we commonly consider the following properties,

- **Efficiency**: High throughput & High network utility
- **Fairness**: End users have fair shares of bandwidth
- **Low delay**: No long packet queues
- **Fast convergence**: Flow should converge to fair allocation as fast as possible

#### (2) AIMD Fairness 1

Now let's consider if AIMD leads to TCP fairness. Suppoes we have only two connections sharing the same bandwidth, and at a time, the total utilized bandwidth is also smaller than the total utilized bandwidth. 

At this time, both connections will increase their window size. Note that in this process, both connections will have additive increment so that point moving trace will be parallel to the bandwidth share fairness line.

![](https://i.imgur.com/rrYS7wG.png)

#### (3) AIMD Fairness 2

When the total utilized bandwidth reached the limitation, the packets will start to get loss. Now both of the connections will be cut to half. Therefore, the point moving trace will be move towards to the fairness line. 

![](https://i.imgur.com/Aw4nw3U.png)


#### (4) AIMD Fairness 3

Now let's suppose that after a long time, the point finally reaches the fairness line. Starting from this time, the point will move along the fairness line back and forth and from a long-term prospective, we reach fairness anytime from now on.

![](https://i.imgur.com/XUbr4aE.png)

Suppose we have the total bandwidth capacity `R` bps shared by `k` connections, each connection will finally gets an average of `R/k` throughput.

#### (5) AIMD Fairness Violation

There are some cases when AIMD can be violated and the result will not reach to fairness.

- **Different RTT**

The above discussion is under an assumption that all the connections increment with the same pace. However, in the real practice, this assumption is always violated. It turns out that the connections have smaller RTT values would increase their congestion window faster than the ones with larger RTT values. And this leads to an unequal sharing of the bandwidth.

- **Parallel TCP**

Another case is that when an application uses multiple parallel TCP connections on the same link, it gets a higher share of the bandwidth due to all the TCP connections are equal.

#### (6) TCP CUBIC

To achieve TCP RTT-fairness, the window growth function is improved from a linear function (additive) to a cubic function. TCP CUBIC is a mechanism implemented in the Linux kernel and it uses CUBIC polynomial as the growth fuction.

```
cwnd = constant * (t - K)^3 + cwnd_max
```

where,
- `cwnd_max` is the window size when the packet loss was detected.
- `K` is the time period that the function takes to increase from `cwnd_max/2` to `cwnd_max` united by RTT
- `t` is the time united by RTT

Commonly if we have multiplicative reduction by half, this function will go through point `(0, cwnd_max/2)` so the value of `K` is,

```
constant * K^3 = cwnd_max/2
```

So,

```
K = cubicroot(cwnd_max/(2*constant))
```

Or generally,

```
K = cubicroot(cwnd_max * β / constant)
```

Where `β` is a multiplier.

Because here we can assign the same `K * RTT` time for each connection, the time for increment will be the same so as to achieve the TCP RTT-fairness.

#### (7) Bandwidth Limitation

Let's finally look into the theoretical upper bound of the bandwidth. Suppose we have the congestion window size `cwnd_max` at the packet loss point and the connection follows TCP Reno. Then the time between a packet loss to `cwnd` reaches `cwnd_max` is,

```
time = RTT * cwnd_max / 2
```

At this time, assume AIMD follows a constant rate of 1 packet for every RTT. So the total number of packet sent during this time is,

```
Packets = (cwnd_max / 2)^2 + (cwnd_max / 2)^2/2
        = (3/8) * cwnd_max^2
```

Assume that the probability of a packet loss is `p`, so the expected total number of packets sent when we can observe 1 packet loss is `1/p`. Therefore, we have the following equation,

```
(3/8) * cwnd_max^2 = 1/p
```

So,

```
cwnd_max = sqrt(8/(3*p))
```

Recall the definition of the bandwidth is,

```
BW = data per cycle / time per cycle
```

So,

```
BW = MSS * packets / time
```

where `MSS` is the maximum segment size. Therefore,

```
BW = MSS * (3/8) * cwnd_max^2 / (RTT * cwnd_max / 2)
```

Replace `cwnd_max` with `p` and assume the constant `C = sqrt(3/2)`, we have

```
BW = MSS/RTT * C/sqrt(p)
```

In practice, becaause of the additional parameters such as small receiver windows, extra bandwidth availability, and TCP timeouts, C is usually less than 1. So,

```
BW < MSS/RTT * 1/sqrt(p)
```

This is the upper bound of the bandwidth.

