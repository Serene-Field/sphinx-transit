# Computer Network 19 | Content Distribution Networks (CDNs)

### 1. Content Distribution Networks (CDNs)

#### (1) Motivations for CDN

Almost all major video-streaming companies use Content Distribution Networks (CDNs). CDNs are networks of multiple, geographically distributed servers and/or data
centers with copies of content that direct users to a server or a server cluster that can best serve the user’s request.

Here are some motivations of CDNs,

- users are located all over the globe
- vital videos got fetched again and again which wastes the resource of the data center
- a single data center leads to one point failure

There are some other challenges that content delivery facing,

- Peering point congestion: middle mile bottlenecks
- Inefficient routing protocols: BGP not enough
- Unreliable networks
- Inefficient communication protocols: TCP not enough
- Scalability: scaling up is expensive 
- Application limitations and slow rate of change adoption

Therefore, there are two shifts impacted the Internet ecosystem,

- increased demand for online content
- topological flattening

These shifts imply that more traffics are generated and exchanged locally instead of traversing the complete hierarchy.

#### (2) Types of CDNs

Some CDNs are **private**, such as Google’s CDN, which distributes YouTube videos and other content. Private CDNs are CDNs that are owned by the content provider.

Other CDNs are **third party**, such as Akamai and Limelight. Third party CDNs distribute content on behalf of multiple content providers. These third parties provide CDN as a service for content providers because operating CDNs has its own challenges include,

- cost
- real estate worldwide
- physical devices
- power consumption
- need to be well-connected
- performing maintenance and upgrades

#### (3) Server Placement Strategies 

To find out where to put the CDN servers, CDN providers have two different philosophies,

- **Enter deep**: deploying lots of small clusters to get as close as possible to the users
- **Bring Home**: deploying fewer but larger clusters to critical areas

There’s a tradeoff between these approaches.

With the Enter Deep strategy, CDN reduces the delay and increases the available throughput for each user. However, it is a highly distributed approach so it's much more difficult to manage and maintain.

With the Bring Home strategy, CDNs place fewer larger server clusters at key points to "bring the ISPs home". It's good because only few server clusters are needed be managed or maintained. But the users will experience higher delay and lower throughput.

There's also a hybrid approach. For example, Google owns 16 mega data centers and many small server clusters.

#### (4) CDN Operation Example

Let's see how CDN works through an example. Suppose content provider **ExampleMovies** pays **ExampleCDN** to distribute their content. ExampleMovies has URLs with videos and an ID for the video. For example, movie *Star Wars 37* might have a URL of `http://video.examplemovies.com/R2D2C3PO37`.

Let’s walk through the six steps that occur when a user requests to watch *Star Wars 37* on ExampleMovies.

- The user visits `examplemovies.com` and navigates to the web page with *Star Wars 37*.
- The user clicks on the link `http://video.examplemovies.com/R2D2C3PO37` and the user’s host sends a DNS query for the domain `video.examplemovies.com`.
- DNS query then goes to the local DNS server (LDNS). It then issues an iterative DNS query for video to the authoritative DNS server for `examplemovies.com`, which is ExampleMovies’s DNS server. Because ExampleMovies’s DNS server knows that the “video” domain is stored on ExampleCDN, so it sends back a hostname in ExampleCDN’s domain, like `a1130.examplecdn.com`.
- The user’s LDNS performs an iterative DNS query to ExampleCDN’s name server for a1130.examplecdn.com. ExampleCDN’s name server system eventually returns an IP address of an appropriate ExampleCDN content server to the user’s LDNS.
- LDNS returns the ExampleCDN IP address to the user. From the end-user's side, they asked for `http://video.examplemovies.com/R2D2C3PO37` and got an IP address back.
- The user’s client directly connects via TCP to the IP address provided by the user’s LDNS, and then sends an HTTP GET request for the video.

#### (5) CDN Server Selection Process: 2-Steps

In order to serve an end-user, the first thing is the CDN server selection process. In this process, we need to pick up a cluster not too far away or overwhelmed. There are two main steps in this process,

- mapping the client to a cluster
- a server is selected from the cluster

#### (6) CDN Cluster Selection 1: geographically closest cluster

To select a cluster, there are different strategies,

- pick the geographically closest cluster
- rely on a real-time cluster selection measurements

Let's first talk about the selecting the geographically closest cluster. This approach is very simple and it works well in a lot of cases. However, there are also some limitations,

- it's picking actually closest to LDNS, not to the user
- geographically closest may not be the best choice
    - due to routing inefficiencies, geographically closest doesn't mean BGP routing closest
    - path congestion issues

#### (7) CDN Cluster Selection 2: real-time measurements

To get a real-time snapshot for the end-user, there are two key aspects to note here,

- decide which end-to-end performance metrics to consider while selecting the cluster
    - network-layer metrics
        - delay
        - available bandwidth
        - both
    - application-layer metrics (better)
        - re-buffering ratio
        - average bitrate
        - page load time
        - etc.
- find a way to obtain the measurements
    - Active measurements: LDNS could probe multiple clusters by sending ICMP ping requests to clusters for monitoring the RTT and then use the “closest” server.
        - most of the LDNS are not equipped to perform these actions
        - this would create lots of extra traffic
    - Passive measurements: CDN’s name server system can also use passive measurements to keep track of the network conditions because we can infer the cluster measurements from the IPs under the same subnet.
        - requires a centralized controller
        - it needs to have data for different subnet-cluster pairs. So  some of the clients are deliberately routed to sub-optimal clusters

#### (8) Server Selection Policy

Once the cluster has been selected, the next step is to select a server within the cluster. 

There are several policies that we can select a server within a cluster,

- Random selection
- Random selection with simple load-balancer
- Random selection with consistant hasing

#### (9) Server Selection Policy 1: Random selection

The implest strategy could be to assign a server from the cluster randomly. This is not optimal because the workload for different servers can be unbalanced and it might end up selecting a highly loaded server whereas a less loaded server was available.

To deal with this, we can add some load-balancers.

#### (10) Server Selection Policy 2: Random selection with simple load-balancer

Another solution is to select a server with some load-balancing techniques and route a client to the least-loaded server. While this solves the above mentioned problem, it is still not optimal.

This happens because if we just use a simple load balancing technique for server selection, a server that already had the requested content is not selected because the client was loaded to a less- loaded server.

So finally, we come to the idea that we have to map the requests based on the content.

#### (11) Server Selection Policy 3: Random selection with consistant hasing

In order to create a mapping strategy for all the objects, we need a continuous hash table across different servers. 

**Consistent hashing** is an example of distributed hash table has been developed. It tends to balance the load by mapping servers and the content objects to the same ID space. For instance, imagine we map the servers to the edge of a circle (say uniformly).

![](https://i.imgur.com/g6yqDlN.png)

In this case, the solution is optimal, which means that least number of keys need to be remapped to maintain load-balance on an average.

#### (12) Server Selection Protocols

We have already known the policies used for selecting a CDN server. Now let's see three different network protocols that can be used for server selection,

- DNS
- IP Anycast
- HTTP Redirection

We will talk about them in the following sections.

#### (13) Server Selection Protocols 1: DNS

The DNS is implemented to map human readable domain names to IP address. It is designed with a distributed hierarchical pattern. 

- root DNS: 13 servers, mostly in north America
- Top level domain (TLD) Servers: responsible for top level domains like .com, .org, .edu and .uk, .fr, .jp.
- Authoritative servers: an organization’s authoritative DNS server can also keep DNS records
- Local DNS (LDNS) servers: Each Internet Service Provider (ISP), such as a university, a company or a small residential ISP, has one or more local DNS servers.

There are also two types of DNS queries,

- Recursive

![](https://i.imgur.com/rF5WbOp.png)

- Iterative

![](https://i.imgur.com/MW6G8r2.png)

DNS also provide fast responding through **DNS caching** so in both iterative and recursive queries, after a server receives the DNS reply of mapping from any host to IP address, it stores this information in the cache memory before sending it to the client.

The DNS servers store the mappings between hostnames and IP addresses as **resource records (RRs)**. A DNS resource record has four fields,

- name: depend on type
- value: depend on type
- Type
- TTL: specifies how long record should remain in the cache

The most common DNS RR types are four,

- `A`: domain name to IP mapping
    - name = domain name
    - value = IP
- `NS`: DNS IP of domain name
    - name = domain name
    - value = IP of the appropriate authoritative DNS server that can obtain the IP addresses for hosts in that domain
- `CNAME`: alias hostname to domain name
    - name = alias hostname
    - value = canonical name
- `MX`: alias email server hostname to domain name
    - name = alias hostname of email server
    - value = canonical name of email server

#### (14) Server Selection Protocols 2: IP Anycast

The main goal of IP anycast is to route a client to the closest server determained by BGP routing. It uses a trick that different physical servers in different clusters shares the same IP address. Therefore, the BGP router will treat them as multiple paths to the same locations, and the shortest path will be stored and
used for routing packets.

![](https://i.imgur.com/YgJqilw.png)

By nature of the internet, it could happen that the link is congested and thus for a new client it was actually better to go to another alternative cluster. Thus, it is not commonly used in practice by CDNs.

Though not for content delivery, IP anycasting is used is in routing to the DNS server. In order to serve clients from multiple locations, it has multiple DNS servers distributed geographically with all of the servers being assigned the same address.

#### (15) Server Selection Protocols 3: HTTP Redirection

When a client sends a GET request to a server `A`, it can redirect the client to another server `B` by sending an HTTP response with a code 3xx and the name of the new server. This means the client should now fetch the content from this new server.

HTTP redirection is widely used by CDNs for load-balancing when a popular video is requested by a large number of clients from the same region. 

A recent measurement study reports that YouTube uses this kind of mechanism for load balancing. According to the study, YouTube first tries to use HTTP redirection for sharing the load within a cluster, and then can also use it to redirect clients to a different cluster if the former is not enough.
 