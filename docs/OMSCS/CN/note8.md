# Computer Network 8 | Introduction to Routers and Prefix Match

### 1. Introduction to Routers

#### (1) Router Components

The router's basic function - **forwarding** is implemented in its hardware. The main components of a router are,

- input ports
    - physically **terminate** the incoming links to router
    - **data link processing** unit decapsulates the packets and the implementation of the protocols
    - perform the **lookup** function to the proper output port
- output ports
    - receive and queue the packets from fabric and send over the outgoing link
- switching fabric
    - moves the packets from input to output ports
    - there are three types of switching fabrics
        - memory
        - bus
        - crossbar
- routing processor
    - for running the routing and management softwares called control plane

#### (2) Control Plane vs Data Plane

- **Control plane** is the collection of softwares executed on the routing processor
- **Data plane** is the underlying collection of hardwares includes i/o ports and switch fabric

#### (3) Functions of Control Plane

- implementing routing protocols
- maintaining routing tables
- computing forwarding table

These functions is implemented in the softwares in the routing processor, or the remote controller of an SDN.

#### (4) Router Architecture

Let’s look at what happens when a packet arrives at an input link. Here are the three most time-sensitive tasks,

- Lookup: router looks up destIP at forwarding table (or Forwarding Information Base or **FIB**) and determine the output link
    - FIBs are mappings of prefix to output links
    - To resolve disambiguities, routers use the **longest prefix match** algorithm
- Switch: router transfers the packet from the input link to the output link using crossbar
    - Scheduling is important in this step
- Queue: router maintains an FIFO queue (or more complex) at the output port

There are also some less time-sensitive tasks,

- Header validation and checksum
    - checks the packet's version number
    - decrements the time-to-live (TTL) field
    - recalculates the header checksum
- Route processing: router build forwarding tables using the following protocols,
    - RIP
    - OSPF
    - BGP
- Protocol processing: router implement functions using the following protocols,
    - simple network management protocol (SNMP) for monitoring
    - TCP and UDP
    - Internet control message protocol (ICMP) for error messages

#### (5) Switching via Memory

Now let's talk about switching fabric. We have discussed that there are three types of switching fabric and let's first look into switching via memory. This switch has the following steps,

- input port interrupts routing processor when receiving a packet and the packet is copied in the processor's memory
- processor extracts the destination address and looks into the forward table to find the output port
- finally the packet is copied into that output port's buffer

#### (6) Switch via Bus

If switch via bus, there will be no participation of the processor.

- input port puts an internal header that designates the output port via lookup when receiving a packet, then it sends the packet to the shared bus
- all the ports will receive the packet, but only the designated one will keep it
- designated output port removes internal header and the packet is copied into that output port's buffer

Because only one packet can cross the bus at a given time, and so the speed of the bus limits the speed of the router. In order to solve this issue, we have the crossbar for switching.

#### (7) Switch via Crossbar

A crossbar is actually a mesh of buses. It connects `N` input ports to `N` output ports using `2N` buses. As long as packets are using different input and output ports, a crossbar network can carry multiple packets at the same time.

#### (8) Router Bottlenecks

The fundamental problem of a router is the speed limition problem. Routers have limitations at,

- Bandwidth and Internet population scaling
- Services at high speeds

These limitations are caused by several bottlenecks for the routers,

- exact lookups
- prefix lookups
- packet classification
- switching
- fair queuing
- internal bandwidth
- measurement
- security

### 2. Prefix Match Algorithm

#### (1) Reason for Prefix Match

Because the Internet continues to grow both in terms of networks (AS numbers) and IP addresses. One of the challenges that a router faces is the scalability problem. One way to help with the scalability problem is to “group” multiple IP addresses by the same prefix.

#### (2) Prefix Notation

There are typically three ways for prefix notation. For example, with a binary prefix 

```
1000010011101010*
```

where `*` indicates wildcard character to say that the remaining bits do not matter.

- dot decimal: 
    - `10000100 -> 132`
    - `11101010 -> 234`
    - So `132.234`
- slash notation: 
    - format: Address/Length
    - `132.234.0.0/16` where 16 denotes that only the first 16 bits are relevant for prefixing
- masking:
    - only the bits value = 1 in the `MASK` are relevant for prefixing
    - `IP=123.234.0.0, MASK=255.255.0.0`

#### (3) Reason for Longest Prefix Match

In 1993, Classless Internet Domain Routing (CIDR) protocol allowed us to use arbitrary-length prefixes and it largely decrease the router table size. 

However, at the same time, we have to decide the longest prefix match for looking up or we will get multiple results.

#### (4) Unibit Tries for Longest Prefix Match

Let's use the following example to see the unibit tries algorithm. Suppose we have the following 9 prefixes,

```
p1 = 101*
p2 = 111*
p3 = 11001*
p4 = 1*
p5 = 0*
p6 = 1000*
p7 = 100000*
p8 = 100*
p9 = 110*
```

The following figure shows a unibit trie using the prefixes above,

![](https://i.imgur.com/ZYR22tF.png)

We use the following steps to perform a longest prefix match,

- begin by tracing the trie path
- continue the search until we fail
- when we fail, the last known successful prefix traced in the path is our match

Now let's see some examples,

- The longest prefix match for `111*` is `p2` because we goes three right
- The longest prefix match for `11011*` is `p9` because `p3` has the 4th bit not match
- The longest prefix match for `10*` is `p4` because `p1`, `p6`, `p7`, `p8` must come with more bits

There are also two final notes on the **unibit trie**,

- prefix stored in node (e.g. `p4` and `p6`): when the prefix is the substring of another prefix, then the smaller prefix should be stored in a node along the path
- one-way branch (e.g. `p3` and `p7`): numbers in a circle means we don't have another other options branch and we have to go that way

#### (5) Problem of Unibit Tries

The biggest problem for unibit tries is the number of **memory accesses** that it requires to perform a lookup. 

For example, for 32 bit addresses, we can see that looking up the address in a unibit trie might require 32 memory accesses in the worst case (when we go through 32 nodes). Assuming a 60 nsec latency, the worst case search time is 1.92 microseconds. This could be very inefficient in high speed links.

One solution is to put multiple bits into one node. For example, if we put three bits into one node, then the worst case for a 32 bit address system requires 11 memory accesses. This is called **multibit tries**.

The number of bits that we check at each step is called **stride**.

#### (6) Multibit Tries

Let's review the prefixes above and now we have the following prefixes if we use `stride = 3`.

```
p1  = 101*
p2  = 111*
p31 = 110010*
p32 = 110011*
p51 = 000*
p52 = 001*
p53 = 010*
p54 = 011*
p61 = 100001*
p62 = 100010*
p63 = 100011*
p7  = 100000*
p8  = 100*
p9  = 110*
```

With this expansion, we can then have a multibit trie has a worst case of only 11 memory access. 

![](https://i.imgur.com/X7tIiTn.png)

Here we can find the same result if we check for `111*` and `11011*`.

#### (7) Fixed Length Stride vs Variable Length Stride 

Based on the stride length, we can have two flavors of multibit tries. The case above is a **fixed-stride trie** of length 3 so every node has 3 bits.

Note that in the case above, we don't have prefix `p4` and if we want to include this prefix, we need to use a variable-stride tree. 
