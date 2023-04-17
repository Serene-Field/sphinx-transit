# Computer Network 14 ｜ Introduction to Internet Security, DNS Abuse, Network Reputation, BGP Hijacking, DDoS Attack

### 1. Introduction to Internet Security

#### (1) Internet Security

The Internet was not designed or built with security in mind, so all the protocols that we have learned so far can be exploited by attackers for malicious purposes. Here are some of the common attacks we will discuss,

- Traffic attraction attacks: BGP Hijacking
- Denial-of-Service (DoS) attacks
- Distributed Denial-of-Service (DDoS) attacks

#### (2) Secure Communication

When we talk about secure communication, we are talking about the following properties,

- Confidentiality

The message that is sent from the sender to the receiver is only available to the two parties.

- Integrity

The message should not be somehow modified while in transit.

- Authentication

The communication parties should confirm the identities.

- Availability

The message should be available.

### 2. DNS Abuse

#### (1) DNS Records

DNS records (aka zone files) are instructions that live in authoritative DNS servers and provide domain information. Here are some common types of DNS record types,

- `A`: IPv4 address for a domain
- `AAAA`: IPv6 address for a domain
- `CNAME`: canonical name, used to forward one domain to another domain. This is common for subdomain to its parent domain.
- `MX`: redirect to mail server 

Note that in the DNS records, 

- `@`: means exact match of the root domain
- `*`: means wildcard prefix match of the domain
- `www`: means the prefix of the domain should be `www`

Each record will also have a Time to Live (TTL) value which represents how long will this record be valid after a DNS client receives it. When a record reaches it's TTL, it will no longer be valid and the client has to request for it again. TTL is also the longest time that a record update will be aware of on all the DNS clients.

#### (2) DNS Usage 1: Round Robin DNS (RRDNS)

With RRDNS, the DNS server responds to a DNS request with a list of DNS A records (it indicates the IP address). Then the list of DNS A records will be cycled in a round robin manner. This list is only a part of the mapping list.

![](https://i.imgur.com/isWacKR.png)

When the list arrives at the DNS client, it can then choose a record using different strategies,

- **first record**: so it will balance the load
- **closest record**: in terms of network proximity

Note that if the DNS lookup happens within the same TTL period, the list of records will be the same in a different order because of round robin. However, if it's not the same TTL period, it's likely the DNS client will receive a different set of A records.

#### (3) DNS-based Content Delivery Networks (CDNs)

CDNs also use DNS-based techniques to distribute content but using more complex strategies. CDNs not only distribute the load among multiple servers at a single location, but it also distribute these servers across the world. 

When accessing the name of the service using DNS, the CDN computes the nearest edge server (or in the figure as surrogate server) and returns its IP address to the DNS client. This results in the content being moved closer to the DNS client which increases responsiveness and availability. CDNs can also react quickly to changes in links as their TTL is lower than RRDNS.

![](https://i.imgur.com/fSSveEv.png)

#### (4) Fast-Flux Service Networks (FFSNs)

Although RRDNS provides reliability for the network, it can also be benefit to spammers. One famous criminal technique is called the fast-flux service networks (FFSNs). 

FFSNs utilitize the feature DNS provides. 

- DNS `A` record list: a DNS request receives multiple A records make it hard to shut down online scams because even if there's one IP functional, the spam is still working
- Low TTL: FFSNs also use low TTLs lower than RRDNS and CDNs so that it will rapidly change in DNS answers. Each time the TTL of current records reached, the records will expired and new IP addresses will be captured from a zombie network (a large set of compromised machines). The machines in this network are then used as proxies to communicate with the mothership node (the node hosts spam contents and it is normally blocked).

![](https://i.imgur.com/nmQRCkP.png)

### 3. Network Reputation

#### (1) Rogue networks

Rogue networks are networks whose main purpose is malicious activity such as phishing, hosting spam pages, hosting pirated software, etc.

#### (2) Infer Network Reputation

There are several ways to infer a network reputation,

- By Evidence of DNS Abuse
- By Interconnection Patterns
- By Likelihood of Breach

We will talk in details about them in the following discussions.

#### (3) DNS Abuse Detection: Finding Rogue Networks (FIRE) System 

FIRE (Finding Rogue Networks) is a system that monitors the data plane for rogue networks. It uses three main data sources to identify hosts that likely belong to rogue networks,

- Botnet command and control providers: use centralized command and control (C&C) on networks where it is unlikely to be taken down.
    - IRC-based botnets
    - HTTP-based botnets
- Drive-by-download hosting providers: method of malware installation without interaction with the user. It occurs when the victims visit a web page that contains an exploit for their vulnerable browser.
- Phish housing providers: phishing pages mimic aithentic sites to steal the login credentials, credit card numbers, as well as other personal information. These pages are hosted on compromised servers and usually are up only for a short period of time.

Because each of these data sources produces a list of malicious IP addresses daily, FIRE can combine the information from these three lists to identify rogue AS. The approach is to identify the most malicious networks as those which have the highest ratio of malicious IP addresses as compared to the total owned IP addresses of
that AS.

Therefore, only if a network has a large enough concentration of blacklisted IPs for a long enough period of time, it will be flagged as malicious.

#### (4) Limitations of DNS Abuse Detection

In practice, it is not feasible to monitor the traffic of all networks as decribed with the FIRE system. There are several reasons,

- It requires a **long time** to confirm a malicious behavior
- The approach does not differentiate well between malicious and cyberactors (i.e. networks that are legitimate but abused)

With the limitations mentioned above, `ASwatch` was improved as an other network reputation inference technique.

#### (5) Interconnection Pattern Inference: ASwatch

`ASwatch` uses the information exclusively from the data plane and it also aims to detect malicious networks run by cyberactors (also called bulletproof). It was first mention in [this article](https://conferences.sigcomm.org/sigcomm/2015/pdf/papers/p625.pdf). 

The idea of `ASwatch`  is based on the observation that bulletproof ASes have

- distinct interconnection patterns
- overall different control plane behavior from legitimate networks

The `ASwatch` system has two phases the training phase and the operation phase. 

- Training phase
    - The system is given a list of known malicious and legitimate ASes, and then it learns control-plane behavior typical of both types of ASes.
    - `ASwatch` then tracks ASes' business relationships and their BGP updates/withdrawals patterns. Commonly, there are three main features that `ASwatch` will look into
        - Rewiring activities
            - frequent changes in customers/providers
            - connecting with less popular providers
        - IP Space Fragmentation and Churn: to avoid all the host IPs being taken down if detected
            - use small BGP prefixes
            - advertise a small section of its IP space
        - BGP Routing Dynamics
            - periodically announcing prefixes for short periods of time
- Operational phase
    - Given an unknown AS, `ASwatch` uses the model to assign a reputation score based on its features.
    - If one AS got a low reputation score for several days, it will be inferred as malicious

#### (6) Likelihood of Breach

Another way to infer a network reputation is to use a system for predicting the likelihood of a security breach within an organization. The system will only use externally observable features so the model can be scalable to all organizations.

The idea of predicting with a likelihood of breach is based on the random forest model with 258 features. These features can be classified into three classes,

- Mismanagement Symptoms
    - Open Recursive Resolvers
    - DNS Source Port Randomization
    - BGP Misconfiguration
    - Untrusted HTTPS Certificates
    - Open SMTP Mail Relays
- Malicious Activities
    - Capturing spam activity
    - Capturing phishing and malware activities
    - Capturing scanning activity
- Security Incident Reports
    - VERIS Community Database
    - Hackmageddon
    - The Web Hacking Incidents Database

With these features for the random forest model, we can get a prediction on the likelihood of breach for us to infer whether a network is malicious or legitimate.

### 4. BGP Hijacking

#### (1) BGP Hijacking Category 1: by Affected Prefix

In this class of hijacking attacks, we are primarily concerned with the IP prefixes that are advertised by BGP.

- Exact prefix hijacking

Two different ASes (one genuine one counterfeit) announce a path for the same prefix, the routing is disruppted to the hijacker wherever the ASpath is shorter.

- Sub-prefix hijacking

The hijacking AS works with a subprefix of the genuine prefix of the real AS, and as a result
route large/entire amount of traffic to the hijacking AS.

- Squatting

In this type of attack, the hijacking AS announces a prefix that has not yet been announced by the owner AS.

#### (2) BGP Hijacking Category 2: by AS-Path announcement

In this class of attacks, an illegitimate AS announces the AS-path for a prefix for which it doesn’t have ownership rights.

- Type-0 hijacking

This is simply an AS announcing a prefix not owned by itself.

- Type-N hijacking

This is an attack where the counterfeit AS announces an illegitimate path for a prefix that it does not own to create a fake link (path) between different ASes.

- Type-U hijacking

In this attack the hijacking AS does not modify the AS-PATH but may change the prefix.

#### (3) BGP Hijacking Category 3: by Data-Plane traffic manipulation

In this class of attacks, the intention of the attacker is to hijack the network traffic and manipulate the redirected network traffic on its way to the receiving AS.

- Dropped

Blackholing (BH) attack, means the traffic intercepted by the hijacker can never reach the intended destination.

- Manipulated

Man-in-the-middle (MM) attack, means the traffic intercepted by the hijacker can be eavesdropped or manipulated before it reaches the receiving AS

- Impersonated

Imposture (IM) attack, means the network traffic of the victim AS is impersonated and the response to this network traffic is sent back to the sender.

#### (4) BGP Hijacking Attacks Causes

There are several causes behind the BGP hijacking attacks. 

- Human Error

Accendital routing misconfiguration due to manual errors can lead to large scale exact-prefix hijacking. For example, China Telecom's Type-0 hijacking

- Targeted Attack

Hijacking AS intercepts network traffic (MM attack) while operating in stealth mode to remain under the radar on the control plane (Type-N and Type-U attacks). For example, Visa and Mastercard’s traffic were hijacked by in 2017.

- High Impact Attack

The attacker is obvious in their intent to cause widespread disruption of services. For example, Pakistan Telecom in a Type-0 sub-prefix hijacking, essentially blackholing all of YouTube’s services worldwide for nearly 2 hours.

#### (5) BGP Hijacking Example 1: Hijack Prefix

Let's suppose we have AS1 ~ AS5 and AS1 has a subnet with prefix 10.10.0.0/16 and it announce this prefix to the network so the other ASes in the network can route to this subnet. Assume we have the following network topology, as a result, we have the paths as,

![](https://i.imgur.com/Vx5an60.png)

Now suppose AS4 is a malicious AS and it has no path to subnet with prefix 10.10.0.0/16. However, it can announce fake messages to pretend that 10.10.0.0/16 belongs to AS4.

![](https://i.imgur.com/8wwLC3H.png)

As a result, several paths are modified, 

- AS3 to 10.10.0.0/16 now routing to AS4
- AS5 to 10.10.0.0/16 now routing to AS4

So in this network, both AS3 and AS4 can not route to subnet 10.10.0.0/16 because the path is now misleading.

#### (6) BGP Hijacking Example 2: Hijack Path

Another way for AS4 to hijack the route is by annoncing the path. For example, AS4 can create a fake to pretend it has a direct path to AS1. So,

![](https://i.imgur.com/2x6aEgd.png)

As a result, the path from AS5 to AS1 is modified, 

- AS5 to 10.10.0.0/16 now routing to AS4

In this case, AS4 performs BGP hijacking by hijacking a path.

#### (7) BGP Hijacking Detection System

One of the high level idea for BGP hijacking defense is to use a detection system called ARTEMIS. RTEMIS is a system that is run locally by network operators to safeguard its own prefixes against malicious BGP hijacking attempts.

The key idea of ARTEMIS is as following,

- configuration file: prefixes owned by the network are listed
- mechanism for BGP updates: allows receiving updates from local routers and monitoring services

Using the local configuration file as a reference, for the received BGP updates, ARTEMIS can check for prefixes and AS-PATH fields and trigger alerts when there are anomalies.

#### (8) BGP Hijacking Mitigation Techniques

The ARTEMIS system uses two automated techniques in mitigating BGP hijacking attacks,

- Prefix deaggregation

The affected network can either contact other networks or it can simply deaggregate the prefixes that were targeted by announcing more specific prefixes of a certain prefix.

- Mitigation with Multiple Origin AS (MOAS)

The idea is to have third party organizations and service providers do BGP announcements for a given network. When a BGP hijacking event occurs, the following steps occur,

- a. A third party is notified and immediately announces from the hijacked prefix.
- b. In this way, network traffic from across the world is attracted to the third party organization, which then scrubbs it and tunnels it to the legitimate AS

### 5. Distributed Denial of Service (DDoS) Attack

#### (1) Distributed Denial of Service (DDoS) Attack

Distributed Denial of Service (DDoS) attack is an attempt to compromise a server or network resources with a flood of traffic. To achieve this, the attacker first compromises and deploys flooding servers (slaves).

![](https://i.imgur.com/Kws5EFG.png)

#### (2) IP spoofing

IP spoofing is the act of setting a false IP address in the source field of a packet with the purpose of impersonating a legitimate server. In DDoS attacks, this can happen in two forms,

- spoof source IP address

It results in the response of the server sent to some other client instead of the attacker’s machine. It also results in wastage of network resources and the client
resources while also causing denial of service to legitimate users.

- spoof same source IP and destination IP

In the second type of attack, the attacker sets the same IP address in both the source and destination IP fields. This results in the server sending the replies to itself, causing it to crash.

#### (3) DDoS Reflection and Amplification

A **reflector** in DDoS is any server that sends a response to a request. In a **reflection attack**, the attackers use a set of reflectors to initiate an attack on the victim. 

For example, the master directs the slaves to send spoofed requests to a very large number of reflectors, usually in the range of 1 million. The slaves set the source address of the packets to the victim’s IP address, thereby redirecting the response of the reflectors to the victim. 

Thus, the victim receives responses from millions of reflectors resulting in exhaustion of its bandwidth. In addition, the resources of the victim is wasted in processing these responses, making it unable to respond to legitimate requests.

![](https://i.imgur.com/tYGjPtV.png)

The master commands the three slaves to send spoofed requests to the reflectors, which in turn sends traffic to the victim. This is in contrast with the conventional DDoS attack we saw in the previous section, where the slaves directly send traffic to the victim. 

Note that the victim can easily identify the reflectors from the response packets. However, the reflector cannot identify the slave sending the spoofed requests.

If the requests are chosen in such a way that the reflectors send large responses to the victim, it is a **reflection and amplification attack**. Not only would the victim receive traffic from millions of servers, the response sent would be large in size, making it further difficult for the victim to handle it.

#### (4) DDoS Attack Defense

Then, let's look into some tools that we can leverage to help detect the DDoS attack.

- **Traffic Scrubbing** Services: A scrubbing service diverts the incoming traffic to a specialized server, where the traffic is “scrubbed” into either clean or unwanted traffic. The problem of this tools is the monetary costs of the service (in-time subscription, setup and other recurring costs). Also the performance will be decreased because of rerouting.
    - Clean traffic: sent to its original destination
    - Unwanted traffic: filtered out
- **Access Control List (ACL)** Filters: deployed by ISPs or IXPs at their AS border routers to filter out unwanted traffic. The drawbacks of these filters include limited scalability and since the filtering does not occur at the ingress points, it can exhaust the bandwidth to a neighboring AS.
- **BGP Flowspec**: The flow specification feature of BGP, called `Flowspec`, helps to mitigate DDoS attacks by supporting the deployment and propagation of fine-grained filters across AS domain borders. Let's discuss more about it in the next section.

#### (5) BGP Flowspec

BGP Flowspec is an extension to the BGP protocol which allows rules to be created on the traffic flows and take corresponding actions. 

This feature of BGP can help mitigate DDoS attacks by specifying appropriate rules. The AS domain borders supporting BGP Flowspec are capable of matching packets in a specific flow based on a variety of parameters such as source IP, destination IP, packet length, protocol used, etc. Please refer to [this document](https://content.cisco.com/chapter.sjs?uri=/searchable/chapter/content/en/us/td/docs/routers/ncs6000/software/ncs6k-r7-0/routing/configuration/guide/b-routing-cg-ncs6000-70x/b-routing-cg-ncs6000-70x_chapter_011.html.xml) for the 12 types of matching components.

Let's now see an example. Suppose we want to specify the following rule as "all HTTP/HTTPS traffic from port 80 and 443 to one of the Google servers with IP 172.217.19.195 from subnet 130.89.161.0/24", then we will have,

```
{
“type 1”: "172.217.19.195/32”
“type 2": "130.89.161.0/24" "type 3": [6],
"type 5": [80, 443], 
"action": {
    "type ": "traffic-rate", 
    “value ": "0"
    }
}
```

The `traffic-rate = 0` means we discard the matching traffic. The other possible actions include rate limiting, redirecting or filtering. If no rule is specified, the default action for a rule is to accept the incoming traffic.

In contrast to ACL filters, FlowSpec leverages the BGP control plane making it easier to add rules to all the routers simultaneously. Although FlowSpec is seen to be effective in intra-domain environment, it is not so popular in inter-domain environments as it depends on trust and cooperation among competitive networks. Also, it might not scale for large attacks where the attack traffic originates from multiple sources as it would multiple rules or combining the sources into one prefix.

#### (6) DDoS Mitigation Technique: BGP Blackholing

BGP blackholing is a countermeasure to mitigate a DDoS attack. With this mechanism, all the attack traffic to a targeted DoS destination is dropped to a null location.

BGP blackholing is implemented with either the help of IX or the upstream provider (ISP). The blackhole messages are tagged with a specific BGP blackhole community attribute, usually publicly available, to differentiate it from the regular routing updates.

#### (7) BGP Blackholing Example 1: Peering or ISP

Let's see two examples. Assume the IP `130.149.1.1` in AS2 is under attack.

First, if the blackholing provider is a peer or an upstream provider, the AS must announce its associated blackhole community along with the blackhole prefix.

![](https://i.imgur.com/fllet4m.png)

To mitigate this attack, AS2 (victim network) announces a blackholing message to AS1, which is the provider network. The message contains,

- the IP `130.149.1.1/32`, which is the host IP under attack
- the community field `AS1:666`, which is the blackholing community of the AS1 provider

Once the provider receives the message, AS1 identifies it as a blackholing message since it contains its blackholing community and sets the next-hop field of the `130.149.1.1` IP to a blackholing IP, thereby effectively dropping all the incoming traffic to host `130.149.1.1`. Thus, the victim host stops receiving the attack traffic that was sent to it.

#### (8) BGP Blackholing Example 2: IXP

Let's look at the scenario, where blackholing is implemented with the help of the IXP.

If the AS is a member of an IXP and it's under attack, it sends the blackholing messages to the **IXP route server** when a member connects to the route server. The route server then announces the message to all the connected IXP member ASes, which then drops the traffic towards the blackholed prefix.

![](https://i.imgur.com/HLWEPdk.png)

Here when AS2 is under attack, AS2 connects to the
router server of the IXP and sends a BGP blackholing message. The message contains,

- IP under attack: `130.149.1.1`
- Community field `ASIXP:666`

The route server identifies it as a blackholing message and sets the next-hop of `130.149.1.1` to a blackholing IP. It propagates this announcement to all its member ASes, which then drops all the traffic to host `130.149.1.1`.

#### (9) BGP Blackholing Limitations

There are also some limitations of the BGP blackholing.

- Unreachable

One of the major drawbacks of BGP blackholing is that the destination under attack becomes unreachable since all the traffic including the legitimate traffic is dropped.

- Collateral damage

All the traffic including legitimate traffic via a neighbor AS is dropped.

- Rejection leads to ineffectiveness

If the majority of the attack traffic is coming through a neighbor AS choosing not to participate in blackholing and rejecting the updates, then the mitigation is ineffective. The same is true if a large number of peers do not accept the blackholing announcements.

