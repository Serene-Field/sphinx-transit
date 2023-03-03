# Computer Network 6 | Introduction to Autonomous Systems, BGP Routing, and Peering Through IXPs

### 1. Introduction to Autonomous Systems (AS)

#### (1) Internet Service Providers (ISPs)

An **Internet Service Provider (ISP)** is a company that provides internet access to individuals, households, and businesses, typically through a wired or wireless connection.

Based on size, there can be three tiers of ISPs,

- Global Scale ISP (Tier-1): AT&T, NTT (Nippon Telegraph and Telephone), Level-3, Sprint
- Regional ISP (Tier-2)
- Access ISP (Tier-3)

Note that a company can be both tier-1 and tier-3 based on its product.

#### (2) Internet Exchange Points (IXPs)

IXPs are physical network exchange infrastructures where multiple networks (eg ISPs and CDNs) can interconnect and exchange traffic locally. Some common IXPs include,

- Equinix (US)
- LINX (London)
- AMS-IX (Amsterdam)
- DE-CIX (Frankfurt)
- JPNAP (Tokyo)
- CNCIX (Beijing)
- etc.

As of 2019, there are approximately 500 IXPs around the world.

#### (3) Content Providers

Content providers are companies or individuals who create, produce, or distribute digital content, such as text, images, videos, music, games, software, and other media formats, to end-users. Some common CPs are,

- Google
- Facebook
- Amazon
- Netflix
- Youtube
- etc.

#### (4) Content Delivery Networks (CDNs)

CDNs are networks created by content providers with the goal of having greater control of how the content is delivered to the end-users, and also to reduce connectivity costs. Some common CDNs are,

- Akamai
- Cloudflare
- Amazon CloudFront
- Google Cloud CDN
- etc.

#### (5) Autonomous System (AS)

Each of the types of networks that we talked about above (eg ISPs and CDNs) may operate as an **Autonomous System (AS)**. An AS is a group of routers (including the links among them) that operate under the same administrative authority.

#### (6) AS Competition and Cooperation

In practice, each level's ISPs are competing with each other. But at the same time, competing ISPs need to cooperate to provide global connectivity to their respective customer networks.

#### (5) ISP Connection

We have discussed that ISPs are connected to larger ISPs for communication and larger ISPs can connect to the same small ISP for communication. However, in today's Internet, there are more ways for two ISPs to communicate,

- Points of Presence (PoP)
- Multihoming
- Peering

#### (6) Hierarchical to Flat Trend

As there are more and more presence of IPSs, IXPs, and CDNs, the internet structure has been morphing from hierarchical to flat.

#### (7) Border Gateway Protocol (BGP)

The border routers as we have discussed talk to the ASes outside the current AS using **Border Gateway Protocol (BGP)** to exchange routing information with one another.

#### (8) Internal Gateway Protocols (IGPs)

IGPs are the routing protocols within an AS as what we have discussed in the previous sections. These include,

- Open Shortest Paths First (OSPF)
- Intermediate System - Intermediate System (IS-IS)
- Routing Information Protocol (RIP)
- E-IGRP

#### (9) AS Business Relationships

- **Provider and Customer**: based on financial settlement which determines how much the customer will pay the provider
- **Peering**: based on money saving purpose, two similar size ASes share the access to a subset of each other’s routing tables

#### (10) How ASes Charge Customers?

A provider usually charges in one of two ways,

- **Flat rate**: Based on a fixed price given that the bandwidth used is within a predefined range.
- **Dynamic**: Based on the bandwidth used based on periodic measurements.

### 2. BGP Routing

#### (1) BGP Routing Policies 1: Exporting Routes

For a given AS, it's important to decide which routes to export. Export routes in an AS means to advertise its network prefixes to the neighboring ASes so that the packets of the other ASes can reach its network.

There are three types of routes that an AS can decide whether to export,

- Routes learnt from **customers** (Yes): it wants to advertise as many as possible becasue the AS is getting paid by the customers
- Routes learnt from **providers** (No): it will not advertise because the customer has no incentive to carry traffic for its provider
- Routes learnt from **peers** (No): it will not afvertise because the the peers will then use it to share the traffic with no financial benefits

#### (2) BGP Routing Policies 2: Importing Routes

Similar to export routes, ASes are also selective about which routes to import when it receives the advertisements from its customers, providers, and peers. In order to select the routes to import, the AS will establish a rank of routes based on the following cateria,

- ensure routes towards its customer do not traverse unnecessary costs
- use free peering routes as much as possible
- finally resorts to import routes learned from providers as these will add to costs

#### (3) BGP Design Goals

- **Scalability**: BGP should be able to handle the network growth 
- **Policy Expressions**: BGP should define attributes for AS to implement export and import policies
- **Indenpendency**: BGP should allow each AS to make confidential decisions
- **Security**: as the size and complexity of the Internet growth, BGP is also required to provide security measurements

#### (4) BGP Session

A BGP session (aka. BGP pair) is a connection between two routers that run the BGP protocol and exchange routing information over a semi-permanent TCP.

#### (5) Two Types of BGP Sessions

- eBGP (external BGP): BGP session between two different ASes
- iBGP (internal BGP): BGP session within an AS

#### (6) BGP Session Establishment

To begin a BGP session, 

- **Open**: router `A` sends an `OPEN` message to router `B`
- **Exchange**: `A` and `B` send each other announcements from their individual routing tables

Depending on the number of routes being exchanged, this can take from seconds up to several minutes.

#### (7) BGP Messages

After a BGP session is established, the peers can exchange BGP message which provide reachability information and enforce routing policies.

#### (8) Two Types of BGP Messages

There are two types of BGP messages. 

- `UPDATE`
    - **Announcements**: used to advertise new routes and update existing routes
    - **Withdrawals**: used to remove previously announced routes. This can be caused by some failures or changes in the policy
- `KEEPALIVE`: used to keep a current BGP session going

#### (9) BGP Prefix Reachability Procedure

In BGP protocol, an external subnet is reached with the following steps,

- Destinations are represented by **IP prefixes**
- Each IP prefix represents a **subnet** that AS can reach
- Gateway routers (running eBGP) advertise IP Prefixes they can reach according to the export policy to routers in neighboring ASes
- Gateway routers disseminate routes to external destinations to other internal routers according to the import policy using seperate iBGP sessions
- Internal routers use iBGP to propagate external routes to other internal routers

#### (10) Autonomous System Number (ASN)

Each AS is identified by a unique number called autonomous system number (ASN).

#### (11) BGP Attributes

In addition to the reachable `IP prefix` field, advertised BGP routes consist of a number of **BGP attributes**. Two notable attributes are,

- `AS-PATH`: the ASN of each AS is included in this attribute as the AS route
- `NEXT-HOP`: the IP address of the next-hop router along the path towards the destination
    - For **internal routers**, this attribute stores the IP address of one of the border routers based on the best path

#### (12) iBGP vs eBGP

The eBGP speaking routers learn routes to external prefixes and they disseminate them to all routers within the AS. 

The **dissemination** within AS is happening with iBGP sessions. The dissemination of routes within the AS is done by establishing a full mesh of iBGP sessions between the internal routers. Each eBGP speaking router has an iBGP session with every other BGP router in the AS, so that it can send updates about the routes it learns.

#### (13) iBGP vs IGP

iBGP is not another IGP-like protocol like RIP or OSPF. IGP-like protocols are used to establish paths between the internal routers of an AS based on specific costs within the AS. In contrast, iBGP is only used to disseminate external routes within the AS.

#### (14) BGP Decision Process on Routers

As BGP messages comes to a router, it follows some process to select routes.

- Receive: when the router receives incoming BGP advertisements, it applies import policies to exclude routes entirely from further consideration
- Decision: the router implements the decision process to select the best routes that reflect the policy in place. A router compares a pair of routes, by going through the list of attributes as follows,
    - Highest Local Performance (LocalPref): local
    - Lowest AS Path Length: neighbor
    - Lowest Origin Type: neither
    - Lowest Multi-Exit Discriminator (MED): neighbor
    - eBGP-learned over iBGP-learned: neigher
    - Lowest IGP Cost to Border Router: local
    - Lowest Router ID for breaking ties: neigher
- Export: the router decides which neighbors to export the route to by applying the export policy

Note `local`, `neighbor`, and `neigher` means where the attributes are controlled.

- local: locally by the AS
- neighbor: by the neighboring AS
- neigher: set by the protocol

Here, let's look into two of the attributes: highest `LocalPref` and lowest `MED`.

- `LocalPerf`: this atribute is used to perfer routes from a specific AS due to peering or business. In practice, there may be the following scheme in place, to reflect the business relationships,
    - Customer: `LocalPerf = 90 ~ 99`
    - Peer: `LocalPerf = 80 ~ 89`
    - Provider: `LocalPerf = 70 ~ 79`
    - Backup Links: `LocalPerf = 60 ~ 69`
- `MED`: this attribute is used by ASes connected by multiple links (the same route) to designate which of those links are preferred for inbound traffic. For example, if AS `A` advertise links to AS `B` (route: A -> B) through the border routers `R1` and `R2`. Then it can assign different `MED` value to these two links and `B` will select the link with a lower `MED` as its route.

#### (15) BGP Limitations

There are two major limitations for BGP in practice,

- Faults
- Misconfigurations

A possible misconfig can largely impact route instability, router processor and memory overloading, outages, and router failures.

There are also some solutions to these limitations,

- Solution 1: limiting routing table size using filtering or configuring default routes
- Solution 2: limiting the number of route changes by limiting the propagation of unstable routes using a technique called **flap damping**

#### (16) Flap Damping

AS will track the number of updates to a specific prefix over a certain amount of time. If the tracked value reaches a configurable value, the AS can suppress that route until a later time. Because this can affect reachability, an AS can also be strategic about how it uses this technique for certain prefixes.

### 3. Peering Through IXPs

#### (1) AS Peering

Commonly, there are two ways for peering ASes,

- Directly: two ASes can directly peer to each other
- IXP as a Mediation: ASes can also peer at IXPs

#### (2) Architecture of IXP

As we have said, IXPs are physical infras consisted of,

- switches 
- routers
- redundant switching fabric: for fault-tolerance

Typically, the IXPs are localed large data centers. There are also some other services provided in the data center,

- power backup
- cooling system
- monitoring
- security

For fault tolerance, some nodes in the IXP will be core of the infrastructure and there are also some additional sites in different facilities.

#### (3) IXPs Properties

- interconnection hubs to handle large traffic volumes
- mitigating DDoS attacks
- real-world infra with researching opportunities
- active marketplace for tech innovations

#### (4) AS Peering Procedure (through IXP)

- Participating AS brings a router to IXP
- Connect a port of the router to IXP switch
- Config the router to run BGP
- Participating AS agrees to IXP’s General Terms and Conditions (GTC)

In this process, the following costs will be calculated,

- one-time cost for establishing a circuit
- monthly charge for using a chosen IXP port
- possibly an annual fee for membership of IXP

Depending on the IXP, the time it takes to establish a public peering link can range from a few days to a couple of weeks.

#### (5) Incentives to Use IXPs

- Keeping local traffic local
- Lower cost
- Improve network service and reduce delay
- Big CP requires to be present in a specific IXP in order for peering

#### (6) IXP Services

- Public peering
- Private peering
- Route servers and Service level agreements
- Remote peering through resellers
- Mobile peering
- DDoS blackholing
- Free value-added services

#### (7) Bi-lateral BGP Session

Bi-lateral BGP session refers to two ASes exchange traffic through the switching fabric was utilizing a two-way BGP session. This is commonly not scalable. 

#### (8) Multi-lateral BGP Session

To mitigate the bi-lateral traffic, IXPs operate a **route server (RS)** that helps with following functions,

- **Collect ASN info**: Collects and shares routing information from its peers or participants that connects with
- **Make BGP decisions**: Executes it’s own BGP decision process and also re-advertise the resulting information to all RS’s peer routers

This is called a **multi-lateral BGP** peering session which is essentially an RS that facilitates and manages how multiple ASes can talk on the control plane simultaneously.

#### (9) RS architecture

The router server maintains,

- AS-specific **Routing Information Bases (RIBs)** to keep track of the individual BGP sessions
- Two types of route filters
    - Import filters: each AS only advertises routes that it should advertise
    - Export filters: restrict the set of other IXP member ASes that receive their routes

#### (10) Multi-lateral Peering Process

- Step 1 (AS to RS): AS `X` advertise prefix `p` to RS, and it is added to RS's `X` specific RIB
- Step 2 (on RS): applying peer-specific import filter to check whether AS `X` is allowed to advertise `p`. If allowed, add `p` to master RIB
- Step 3 (on RS): applying peer-specific export filter to check if AS `X` allows AS `Z` to receive `p`. If true, add `p` to RS's `Z` specific RIB

Now, RS advertises `p` to AS `Z` with AS `X` as the next hop.

