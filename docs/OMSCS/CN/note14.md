# Computer Network 14 ｜ 

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

