# Computer Network 9｜Packet Classification, Packet Scheduling, Traffic Scheduling

### 1. Packet Classification

#### (1) Reasons for Packet Classification

Network requires quality of service and secutiry guarantees when the internet becomes more complex. Therefore, forwarding based on prefix match is not enough and we need to handle packets based on multiple criteria,

- TCP flags
- source addresses
- etc.

#### (2) Variants of Packet Classification

- Firewall: implement on routers to filter out unwanted traffic
- Resource Reservation Protocols: For example, `DiffServ` has been used to reserve bandwidth
- Routing Based on Traffic Type: helps avoid delay for time-sensitive services (e.g. videos)

#### (3) Packet Classification Simple Solution 1: Linear Search

The first simple approach to implement packet classification is **linear search**. This solution can be reasonable for a few rules but the time to search through a large database that may have thousands of rules can be prohibitive.

**Firewall** implementations perform a linear search of the rules database and keep track of the best-match rule.

#### (4) Packet Classification Simple Solution 2: Caching

Another apporach is to cache the results so that future searches can run faster. However, this approach has two problems,

- We still need a search for the cache misses 
- We need to search in cache's space. This is much faster than a linear search but it can still result in poor performance

#### (5) Packet Classification Simple Solution 3: Passing Labels

The idea of passing labels is that when A sends a packet to B, the packet will be labelled somewhere so that intermediate routers don't have to conduct the packet classification.

This approach is widely used in some protocols,

- Multiprotocol Label Switching (MPLS): one router stores the label in a MPLS header so no need for future classification
- DiffServ: mark packets edges for special quality of service

#### (6) Packet Classification Fast Solution 1: Set-Pruning Tries

Using pruning tries for the rules provide a faster solution for packet classification. Let's see an example. Suppose we have the following rules to classify,

```
R1:    Dest = 0*    Source = 10*
R2:    Dest = 0*    Source = 01*
R3:    Dest = 0*    Source = 1*
R4:    Dest = 00*   Source = 1*
R5:    Dest = 00*   Source = 11*
R6:    Dest = 10*   Source = 1*
R7:    Dest = *     Source = 00*
```

Then we can build a prune trie based on the destinations,

![](https://i.imgur.com/9cJr9q7.png)

However, this is only half of the result and we also have to store the source filters somewhere. For example, suppose a packet comes with `Dest = 001*`, then `R1`, `R2`, `R3`, `R4`, `R5`, `R7` can all be possible matches. Therefore, we will need another trie at the end of this branch to filter the sources. In this example, we need to build 4 source tries and each of them will take a space in the memory.

![](https://i.imgur.com/QQADoWP.png)

We can find out that a source rule in this appoach can appear in multiple source tries. For example, `S7` appears in all the for tries and it causes duplications.

So the challenge for this approach is, when the network grows large enough, it can be impossible to fit the duplicated source in tries into the memory. This is called the **memory explosion** issue.

#### (6) Packet Classification Fast Solution 2: Backtracking

The opposite approach of set-pruning is backtracking. Suppose we have a packet with a destination `D` and a source `S`. Then,

- First, the algorithm goes through the destination trie and finds the longest prefix match. It then stores every ancestor prefix of `D` that points to a non-empty source tree.
- Then it goes backup and search the source trie associated with every ancestor prefix of `D`.

What we can find in this approach is that there will be no duplicated tries. We will have only one destination trie and one source trie. 

However, the challenge of this approach is the lookup cost. Because a single source trie can be higher than multiple shallow source tries. 

#### (7) Packet Classification Fast Solution 3: Grid of Tries

The grid of tries approach is a combination of those two approaches. Rather than tries, this approach has a data structure that looks more like a network.

As we have discussed, the problem of set-pruning trees is multiple sources appears in different tries. So the idea is to keep a single source trie for a single source, and we add edges that across the the source tries to target the match.

Here's an example using the grid of tries approach.

![](https://i.imgur.com/XRk1fvh.png)

### 2. Packet Scheduling

#### (1) Reasons for Scheduling

We are maintaining packet scheduling because of the following reasons,

- each crosspoint in the crossbar needs control (on/off)
- maximize the number of input/output links pairs for parallel

#### (2) Scheduling Algorithm 1: Take a Ticket Algorithm

Take a ticket algorithm is like a "ticket assign, done, reallocate" workflow and it has the following steps,

- When an input line wants to send a packet to the output line, it requests a **ticket**
- When the request reach the output line, it will process them in order and assign the ticket

Let's see an example. Suppose we have three input links `A`, `B`, and `C`, and we also have 4 output links `w`, `x`, `y`, `z`.

Then at a time, we have the following packets waiting to be sent,

```
A -> {w, x, y}
B -> {w, x, y}
C -> {w, y, z}
```

First, each of them will request a ticket to `w` and suppose `w` will process in the order `A`, `B`, and `C`.

So in round 1, there will be connections as follows,

```
A -> w
```

In round 2, we have `A` send to `x` and `B` send to `w` because `w` is no longer occupied by `A`.

```
A -> {x, y}
B -> {w, x, y}
C -> {w, y, z}

A -> x
B -> w
```

In round 3, we have the following status for input links and output links,

```
A -> {y}
B -> {x, y}
C -> {w, y, z}

A -> y
B -> x
c -> w
```

#### (3) Problem of Take a Ticket: Head of Line (HOL) Blocking

From the discussion above, we can find out when `A` sends its packet to `w`, the entire queue for `B` and `C` are waiting. We refer to this problem as **head-of-line (HOL)** blocking.

So head-of-the-line (HOL) blocking is a queued packet in an input queue must wait for transfer through the **fabric** (even though its output port is free) because it is blocked by another packet at the head of the line.

#### (4) HOL Avoidance Solution 1: Faster Fabric

Because HOL is caused by the occupied fabric, then a simple idea to deal with it is to make the fabric much faster than the input links. 

In order to avoid any of the blocks in the input queue, in the worst case we need to have the fabric `N` times faster than the input links, where `N` is the number of the inputs. 

A practical implementation of this approach is called the **Knockout scheme**. This means to split packets into fixed sized chunks called **cells**. If the average splits for a packet is `K`, then we are able to slower the input queue by `K` times so the fabric is `K` times faster than the input queue. This technique was used in Asynchronous Transfer Mode (ATM) networks once and now it's replaced by some other technologies like Ethernet.

In practice, the expected splits `K` is usually smaller than `N`, so we have to accommodate some scenarios,

- `K = N`: No packet queue caused by fabric
- `K < N`: There's a queue caused by fabric. The ATM network uses a switch called concentrator that connects multiple low-speed networks (input links) to a single `K` times faster high-speed links (fabric). Because `K < N`, there will still be a queue in the fabric and in this case, the switch randomly picks one out of `N` outputs for connection. We use multiple 2-by-2 concentrators.

As we used multiple 2-by-2 concentrators above, the network structure will be like a binary tree with each node in the tree represents a switch or concentrator that can be used to aggregate traffic from multiple inputs and forward it to a single output. In fact, this approach is complex to implement.

#### (5) HOL Avoidance Solution 2: Parallel Iterative Matching

Another idea to avoid blockings on the fabric is to do out-of-order packet forwarding on the input links. Although we still maintain the packet queues on the input link, we send more ticket requests to the output of some future packets. 

In this case, even the head is blocked in the input queue, we can still go ahead for forwarding some later packets if we are able to establish a connection.

Because this approach avoides the HOL issue, it's clearly more efficient than the take a ticket approach.

#### (6) Scheduling Algorithm 2: FIFO with Tail Drop

After talking about take a ticket approach, let's look into some other simple scheduling algorithm used when new packets come to a router. 

Suppose we have some new packets coming in through the input links, then the simplest approach to maintain a packet queue at a input link is by maintaining an **FIFO queue** for packets.

When this queue is full, packets will be dropped from the tail of the queue (where new packets come in). This method to avoid buffer overflow is called **tail-drop** and it results in fast scheduling decisions. But it can also cause potential loss in important data packets.

#### (7) Quality of Service (QoS)

In the real world, it's very important to provide the quality of service (QoS) for a computer network. The QoS refers to a set of mechanisms for the following functions,

- Prioritize certain types of network traffic over others: times-sensitive services like real-time chatting and video stream
- Implement traffic shaping
- Implement packet classification
- Implement queue management
- Implement fair bandwidth allocation

QoS is used to guarantees to a **flow of packets**, which refers to a stream of packets that travels the same route from source to destination. A flow of packets should also require the same level of service at each intermediate router and gateway. In addition, flows must be identifiable using fields in the packet headers.

In order to provide QoS, FIFO with tail drop is clearly not enough. Therefore, we will talk about some more complex scheduling algorithms in the next section.

#### (8) Reasons for Complex Scheduling Algorithms

Here are more reasons to use complex scheduling algorithms,

- router support for congestion
- fair sharing of links among competing flows
- providing QoS garantees to flows

#### (9) FIFO with Tail Drop vs Round Robin

One problem of FIFO with tail drop is that it will result in some packets being dropped randomly. If a source sends many packets to router when its input buffer is full, it will lead to the fairness issue.

So solve this problem, we can easily think about the round-robin approach which takes packets from each flow in a cyclic oder. Each flow is given a certain amount of time to transmit before the next one comes in.

However, the flow with small packet sizes will result in getting served more frequently. To avoid this, researchers came up with bit-by-bit round robin.

#### (9) Complex Scheduling Algorithm 1-1: Bit-by-bit Round Robin

Bit-by-bit round robin is a imaginary system which doesn't actually exist in the real world. It is a simple idea for dealing with the fairness issue of round robin. The idea is to take 1 bit from each active flow in a round robin manner so it ensures fairness in bandwith allocation. 

We can not implement it because we can not split packets to bits. Although it's not a real-world implementation, we can still do some calculations to check its performance. 

Let's suppose the following conditions,

- `R(t)`: current round number at time `t`
- `μ`: a router can send `μ` bits per time unit
- `N`: number of active flows

So the rate of increase of `R` is,

```
rate = dR / dt = μ / N
```

Suppose we have a packet of size `p` bits to transmit, then the time it takes should be,

```
time = size / rate = p * N / μ
```

We can find out that this result is not depend on the number of the backlogged queues.

Also suppose this packet is the i-th packet in the flow `α`.

- If this packet reach an empty input queue, then it reaches the head of queue at the current round `R(t)`
- If not, then it needs to wait for the `i - 1` packets at the front to finish. We denote the round number as `F(i-1)`

So the round number at which the packet reaches the head is given by,

```
S(i) = max{R(t), F(i-1)}
```

The round number at which a packet finishes, which depends only on the size of the packet, is given by

```
F(i-1) = S(i-1) + p(i-1)
```

where `p(i-1)` means the size of the (i-1)-th packet in flow `α`.

With the two equations above, we can calculate the finish round of every packet in a queue. We will use the finish round values in the next section.

#### (10) Complex Scheduling Algorithm 1-2: Packet-level Fair Queuing

This packet-level fair strategy emulates the bit-by-bit fair queueing by sending the packet which has the smallest finishing round number. 

It will calculate the finish round values for each packet in different flows and choose to schedule the one with the smallest finish round value.

Although this method provides fairness, it also introduces new complexities. We will need to keep track of the finishing time at which the head packet of each queue would depart and choose the earliest one. This requires a priority queue implementation, which has time complexity which is logarithmic in the number of flows. 

Additionally, if a new queue becomes active, all timestamps may have to change – which is an operation with time complexity linear in the number of flows. Thus, the time complexity of this method makes it hard to implement at gigabit speeds.

Therefore, although the bit-by-bit round robin gave us bandwidth and delay guarantees, the time complexity was too high.

#### (11) Complex Scheduling Algorithm 2: Deficit Round Robin (DRR)

Let's see an idea that makes everything easier. It's called deficit round robin. The idea is to control of size rather than the time (compared with round robin) and allocate a fixed quantum size for each flow in each round instead of doing 1 bits (compared with bit-by-bit round robin).

Here are the terms we use in this case,

- Quantim size: a single, fixed value represents the number of bits we are able to accumulate for each flow at a round.
- Deficit counters: we have one deficit counter assigned to one flow and the value of it represents how many bits we can send in this round. At the beginning of each round, it will use its remaining value to add the quantim size. Initially, all the counters will be set to 0s.

In one round, the packet sending process will stop in the following cases,

- the non-sent packet queue in the flow is empty
- the specific deficit counter shows a value that is not enough to send the next packet in the flow

### 3. Traffic Scheduling

#### (1) Reasons for Traffic Scheduling

There are scenarios where we want to set bandwidth guarantees for flows in the same queue without separating them. 

For example, we can have a scenario where we want to limit a specific type of traffic (eg news traffic or email traffic) in the network to no more than X Mbps, without putting this traffic into a separate queue.

#### (2) Traffic Policing

Traffic policing and traffic shaping are two related but distinct mechanisms used in computer networks to control the flow of data traffic. Let's first discuss traffic policing.

Traffic policing involves monitoring the rate of incoming network traffic and **enforcing a maximum** rate or bandwidth limit. If the incoming traffic exceeds the limit, packets may be dropped or marked as non-conforming.

When traffic rate reaches the maximum configured rate, excess traffic is either dropped, or the setting or “marking” of a packet is changed. The output rate appears as a **saw-toothed wave**.

![](https://i.imgur.com/Aw0A2yn.png)

#### (3) Traffic Shaping

Traffic shaping, on the other hand, involves delaying or buffering packets to ensure that they are transmitted at a **steady rate**, even if the actual rate of incoming traffic fluctuates.

A **shaper** typically retains excess packets in a queue or a buffer and this excess is scheduled for later transmission. The result is that excess traffic is delayed instead of dropped. Thus, when the data rate is higher than the configured rate, the flow is shaped or smoothed. 

![](https://i.imgur.com/sNn0iey.png)

Traffic shaping and policing can work together.

#### (4) Traffic Scheduling Approach 1: Token Bucket Shaping

The idea of this approach is to maintain an extra token bucket with tokens generated by a fixed rate. The token bucket and the data buffer are suppose to have the same length. Each incoming packet must take a token from the bucket in order to be transmitted.

When the token bucket is full with tokens, then additional tokens are dropped. When a packet arrives, it can go through if there are enough tokens. If not, the packet needs to wait until enough tokens are in the bucket.

Suppose the token bucket has a size of `B`, then burst is limited to `B` bits per second.

In pactice, the token bucket is implemented through a timer and a counter. 

#### (5) Traffic Scheduling Approach 1: Token Bucket Policing

The problem of token bucket shaping is that we have one queue per flow so even when some other flows have empty bucket, we are blocked and we can not use them.

To fully use all the queues, we can combine multiple queues to a single long queue. However, in this case, the token bucket shaping will be modified to token bucket policing.

So when a packet arrives will need to have tokens at the bucket or if the token bucket is empty, the packet is dropped.

#### (6) Traffic Scheduling Approach 2: Leaky Bucket

Leaky Bucket is an algorithm which can be used in both traffic policing and traffic shaping.

To learn about leaky bucket, we have to know the following terms,

- bucket capacity `b`: epresents a buffer that holds packets
- leak rate `r`: constant rate at which the packets are allowed to enter the network

If an arriving packet does not cause an overflow when added to the bucket, it is said to be **conforming**. Otherwise, if the incoming traffic rate exceeds the leak rate, the bucket will overflow, and the excess traffic will be dropped or marked as **non-conforming**.

Irrespective of the input rate of packets, the output rate is constant which leads to uniform distribution of packets send to the network. This algorithm can be implemented as a single server queue.
