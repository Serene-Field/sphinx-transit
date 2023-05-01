# Computer Network 16｜DNS Censorship, Connectivity Disruption

### 1. DNS Censorship

#### (1) DNS Censorship

DNS censorship is a large scale network traffic filtering strategy opted by a network to enforce control and censorship over Internet infrastructure to suppress material which they deem as objectionable.

An example of large scale DNS censorship is that implemented by networks located in China, which use a Firewall, popularly known as the Great Firewall of China (GFW).The GFW works on injecting **fake DNS record** responses so that access to a domain name is blocked. 

#### (2) Properties of GFW

Since the GFW is an opaque system, several different studies have been performed to deduce the actual nature of the system and its functionality. Researchers have tried to reverse engineer the GFW and to understand how it works. Here are some of the properties,

- Locality of GFW nodes

There are two differing notions on whether the GFW nodes are present only at the edge ISPs or whether they are also present in non-bordering Chinese ASes. The majority view is that censorship nodes are present at the edge.

- Centralized management

Since the blocklists obtained from two distinct GFW locations are the same, there is a high possibility of a central management (GFW Manager) entity that orchestrates blocklists.

- Load balancing

GFW load balances between processes based on source and destination IP address. The processes are clustered together to collectively send injected DNS responses.

#### (3) DNS Censorship Techniques

There are some techniques developed by the GFW including,

**(i) DNS injection**

GFW uses a ruleset to determine when to inject DNS replies to censor network traffic. When tested against probes for restricted and benign domains, the accuracy of DNS open resolvers to accurately pollute the response is recorded over 99.9%. 

The steps involved in DNS injection are,

- DNS probe is sent to the open DNS resolvers
- The probe is checked against the blocklist of domains and keywords
- For domain level blocking, a fake DNS A record response is sent back. There are two levels of blocking domains,
    - directly blocking the domain
    - blocking it based on keywords

**(ii) Packet dropping**

Packet dropping means all the network traffic that going to a specific set of IP addresses.

- Strength
    - easy to implement
    - low cost
- Weaknesses
    - blocklist maintaince
    - overblocking: if two sites shares the same IP address

**(iii) DNS Poisoning**

When a DNS receives a query for resolving hostname to IP address if there is no answer returned or an incorrect answer is sent to redirect or mislead the user request.

- Strength
    - no overblocking: since there's an extra layer for hostname translation
- Weaknesses
    - can be easily bypassed through changing the hosts

**(iv) Content Inspection**

Proxy-based content inspection allows for all network traffic to pass through a proxy where the traffic is examined for content.

- Strength
    - Precise censorship
    - Flexible
- Weaknesses
    - Not scalable: expensive and large overheads

Intrusion detection system (IDS) based content inspection is to use parts of an IDS to inspect network traffic.

**(v) Blocking with Resets**

Content based resets happen when GFW sends a TCP reset (RST) to block individual connections that contain requests with objectionable content. 

In the following example, after the client `cam54190` sends the request containing flaggable keywords, it receives 3 TCP RSTs corresponding to one request, possibly to ensure that the sender receives a reset.

```
# TCP Connection Establish
cam(54190) → china(http) [SYN]
china(http) → cam(54190) [SYN, ACK] TTL=39 
cam(54190) → china(http) [ACK]

# client sends flagged key word
cam(54190) → china(http) GET /?{keyword} HTTP/1.0
china(http) → cam(54190) [RST] TTL=47, seq=1, ack=1
china(http) → cam(54190) [RST] TTL=47, seq=1461, ack=1 china(http) → cam(54190) [RST] TTL=47, seq=4381, ack=1
china(http) → cam(54190) HTTP/1.1 200 OK (text/html) etc...
cam(54190) → china(http) [RST] TTL=64, seq=25, ack zeroed china(http) → cam(54190) ... more of the web page
cam(54190) → china(http) [RST] TTL=64, seq=25, ack zeroed china(http) → cam(54190) [RST] TTL=47, seq=2921, ack=25
```

**(vi) Immediate Reset of Connections**

Instead of blocking based on the content, GFW has extra blocking rules to suspend traffic coming from a source immediately for a short period of time.

After sending a request with flaggable keywords (above), we see a series of packet trace, like this,

```
cam(54191) → china(http) [SYN]
china(http) → cam(54191) [SYN, ACK] TTL=41 cam(54191) → china(http) [ACK]
china(http) → cam(54191) [RST] TTL=49, seq=1
```

The reset packet received by the client is from the firewall. It does not matter that the client sends out legitimate GET requests following one “questionable” request. It will continue to receive resets from the firewall for a particular duration. Running different experiments suggests that this blocking period is variable for “questionable” requests.

#### (4) Difficulties to Measure DNS Manipulation

- Diverse Measurements

Widespread longitudinal measurements are required to measure global Internet manipulation and the heterogeneity of DNS manipulation, across countries, resolvers, and domains. 

- Need for Scale

The methods to measure Internet censorship were relying on volunteers who were running measurement software on their own devices because of the large scale.

- Identifying the intent to restrict content access

Identifying DNS manipulation requires to detect the intent to block access to content and it's a challenge to tell. So we need to rely on identifying multiple indications to infer DNS manipulation.

- Ethics and Minimizing Risks

There are also risks associated with involving citizens in censorship measurement studies based on how different countries maybe penalizing access to censored material. 

#### (5) Censorship Detection System: CensMon, OpenNet Initiative, and Augur

**CensMon** is a global censorship measurement tool used PlanetLab nodes in different countries. It's no longer in use.

Another tool is the **OpenNet Initiative** where volunteers perform measurements on their home networks at different times since the past decade. Relying on volunteer efforts make continuous and diverse measurements very difficult.

**Augur** is a new system created to perform longitudinal global measurements using TCP/IP side channels. However, this system focuses on identifying IP-based disruptions as opposed to DNS-based manipulations.

#### (6) Iris Network Measurement System

Then, let's explore an example of global measurement methodology called Iris. It is a method to identify DNS manipluation via machine learning. Let's the steps of measuring DNS manipluation based on Iris,

- Using open **DNS resolvers** for diversity
    - Scanning the Internet’s IPv4 space for open DNS resolvers
    - Identifying Infrastructure DNS Resolvers
- Annoting dataset with **DNS measurements**
    - Performing global DNS queries
    - Annotating DNS responses with auxiliary information based on Censys dataset
    - Additional PTR and TLS scanning: To avoid DNS inconsistencies, Iris adds PTR and SNI certificates
- **Cleaning dataset**
- **Identify DNS manipulations**
    - Consistency Metrics: If these consistency metrics are changed, it's possible there's a DNS manipulation. some consistency metrics used by Iris are,
        -  IP address
        -  Autonomous System
        -  HTTP Content
        -  HTTPS Certificate
        -  PTRs for CDN
    - Independent Verifiability Metrics: Iris determined that some other metrics can also effect manipulation,
        - HTTPS certificate without SNI
        - HTTPS Certificate with SNI

### 2. Connectivity Disruption

#### (1) Connectivity Disruption

The highest level of Internet censorship is to completely block access to the Internet. However, it may not be feasible as the infrastructure could be distributed over a wide area.

A more subtle approach is to use software to interrupt the routing or packet forwarding mechanisms. This is called connectivity disruption. There are two types of connectivity disruption, **routing disruption** and **packet filtering**.

Connectivity disruption can include multiple layers apart from the two methods mentioned above. It can include,

- DNS-based blocking
- deep packet inspection by an ISP
- client software blocking
- etc.

#### (2) Routing Disruption

A routing mechanism decides which part of the network can be reachable. If this communication is disrupted or disabled on critical routers, it could result in unreachability of the large parts of a network. 

Using this approach can be easily detectable, as it involves withdrawing previously advertised prefixes must be withdrawn or re-advertising them with different properties and therefore modifying the global
routing state of the network.

#### (3) Packet Filtering

Packet filtering is used as a security mechanism in firewalls and switches. However, it can also be used to block packets matching a certain criteria disrupting the normal forwarding action. This approach can be harder to detect and might require active probing of the forwarding path or monitoring traffic of the impacted
network.

#### (4) Detect Connectivity disruptions: Augur

In this section, we will talk about another monitoring Augur which is a measurement machine to detect filtering between hosts.

The system aims to detect if filtering exists between two hosts, a reflector and a site,

- **reflector**: a host which maintains a global IP ID
- **site**: a host that may be potentially blocked

To identify if filtering exists, it makes use of a third machine called the **measurement machine**. Augur uses a unique 16-bit IP identifier (**IP ID**) assigned to each host for measurement. 

The global counter is incremented for each packet that is generated and helps in keeping track of the total number of packets generated by that host. Using this counter, we can determine if and how many packets are generated by a host.

In addition to the IP ID counter, the approach also leverages the fact that when an unexpected TCP packet is sent to a host, it sends back a RST (TCP Reset) packet. It also assumes there is no complex factors involved such as cross-traffic or packet loss. Let’s look at two important mechanisms used by the approach,

- Probing: monitor IP ID over time

We use the measurement machine to observe the IP ID generated by the reflector. To do so, the measurement machine sends a TCP `SYN-ACK` to the reflector and receives a TCP `RST` packet as the response. 

The `RST` packet received would contain the latest IP ID that was generated by the reflector. Thus, the measurement machine can track the IP ID counter of the reflector at any given point.

- Perturbation

Perturbation is a mechanism which forces a host to increment its IP ID counter by sending traffic from different sources such that the host generates a response packet. Perturbation has the following steps,

(i) The measurement machine sends a spoofed TCP `SYN` packet to the site with source address set to the reflector’s IP address
(ii) The site responds to the reflector with a TCP `SYN-ACK` packet
(iii) The reflector returns a TCP `RST` packet to the site while also incrementing its global IP ID counter by 1

#### (5) Filtering Detection Example

Let the initial IP ID counter of the reflector be 5. Assume a scenario where there’s no filtering,

![](https://i.imgur.com/qzgkzFY.png)

- 1. The measurement machine probes the IP ID of the reflector by sending a TCP `SYN-ACK` packet. It receives a `RST` response packet with IP ID set to 6 (`IPID(t1) = 6`)
- 2. Now, the measurement machine performs perturbation by sending a spoofed TCP SYN to the site. The site sends a TCP `SYN-ACK` packet to the reflector and receives a `RST` packet as a response. The IP ID of the reflector is now incremented to 7
- 3. The measurement machine again probes the IP ID of the reflector and receives a response with the IP ID value set to 8 (`IPID(t4) = 8`)

The measurement machine thus observes that the difference in IP IDs between steps 1 and 4 is 2 and infers that communication has occurred between the two hosts.

#### (6) Filtering Scenario 1: Inbound Blocking

The scenario where filtering occurs on the path from the site to the reflector is termed as inbound blocking. In this case, the `SYN-ACK` packet sent from the site in step 3 does not reach the reflector. 

Hence, there is no response generated and the IP ID of the reflector does not increase. The returned IP ID in step 4 will be 7 (`IPID(t4)  = 7`) as shown in the figure. Since the measurement machine observes the increment in IP ID value as 1, it detects filtering on the path from the site to the reflector.

![](https://i.imgur.com/MVquBVr.png)

#### (7) Filtering Scenario 2: Outbound Blocking


Outbound blocking is the filtering imposed on the outgoing path from the reflector. Here, the reflector receives the `SYN-ACK` packet and generates a `RST` packet. 

As per our example, in step 3, the IP ID increments to 7. However, the `RST` packet does not reach the site. When the site doesn’t receive a `RST` packet, it continues to resend the `SYN-ACK` packets at regular intervals depending on the site’s OS and its configuration. This is shown in step 5 of the figure. It results in further increment of the IP ID value of the reflector. 

In step 6, the probe by the measurement machine reveals the IP ID has again increased by 2, which shows that retransmission of packets has occurred. In this way, outbound blocking can be detected.

![](https://i.imgur.com/4c0Rea9.png)
