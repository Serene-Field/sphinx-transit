# Computer Network 20 | Final Review

### 1. SDN

- The SDN paradigm is based on separating the control plane from the data plane.
- In the SDN paradigm, the rules for forwarding packets can be computed based on any number of header field values in various layers, such as the transport-layer, network-layer and link-layer.
- The introduction of a software layer in an SDN architecture allows network administrators to easily configure network devices, through software as opposed to manually configuring the hardware.
- SDNs use software to control the routers' behavior (e.g., the path selection of process).
- The main reason why SDNs were created was not because of the increase of internet users. 
- The ain reason why SDNs were created was the diversity of equipment and proprietary technologies.
- A few of the main reasons that SDN arose are: a diversity of different network equipment (eg routers, switches, firewalls, etc.) using different protocols that made managing the network difficult, and second a lack of a central platform to control network equipment.
- The main idea behind SDNs is to divide tasks into smaller functions so the code is more modular and easy to manage.
- The Active Networks phase consisted mainly of creating a programming interface that exposed resources/network nodes and supported customization of functionalities for subsets of packets passing through the network.
- SDNs divide the network in two planes: control plane and data plane, to ease management and speed up innovation.
- Software implementations in SDN controllers are increasingly open and publicly available, which speed up innovation in the field.
- With SDNs the control plane and data plane have independent evolution and development.
- An OpenFlow switch has a table of packet-handling rules, and whenever it receives a packet, it determines the highest priority matching rule, performs the action associated with it and increments the respective counter.
- OpenFlow API can be deployed and scaled easily.
- In the SDN approach, the SDN controller can be a centralized or a distributed software.
- The data plane of an SDN contains infrastructures which is mainly SDN controlled switches. 
- The control plane include the SDN controller and other network control applications.
- With the separation of the control plane and the data plane, any change to the forwarding functions on a router is independent from the routing functions of the control plane.
- In the SDN approach, the controller that computes and distributes the forwarding tables to be used by the routers is physically separate from the routers.
- The application layer contains network control applications for loading, IAM, and load-balancing.
- By separating the control plane and the data plane, controlling the router's behavior became easier using higher order programs. For example, it is easier to update the router's state or control the path selection.
- In the SDN approach, ISPs or other third parties can take up the responsibility for computing and distributing the router's forwarding tables.
- For software technologies like SDNs, having openly available allows for finding more bugs or security vulnerabilites
- In SDN networks, the SDN controller is responsible for enforcing policies.
- In SDN networks, the infrastructure layer is responsible for the forwarding of traffic.
- The network-control applications are programs that manage the underlying network with the help of the SDN controller.
- In SDN networks forwarding rules of traffic can be based on other metrics, packet header info etc. as well as IP destinations.
- SDN-controlled switches operate on the Data Plane.
- In an SDN Architecture, the southbound interface keeps track of information about the state of the hosts, links, switches and other controlled elements in the network, as well as copies of the flow tables of the switches.
- In an SDN Architecture, the northbound interface is responsible for receiving info and passing up to application that either keep track of operate on that info.
- In SDN networks, the southbound interface is responsible for the communication between SDN controller and the controlled devices.
- In SDN networks, the controller can be implemented over a centralized server or distibuted.
- An OpenFlow switch may also be used for routing.
- An OpenFlow switch can function as a router.
- Data plane executes a network policy like switch or middle box that performs some operation.
- Both conventional and software defined networks (SDNs) can implement load balancing.
- SDN decouples the control and data planes.
- Middleboxes can only be used in both conventional and SDN networks.
- Routing, security enforcement, QoS enforcement can all be implemented as a network application in software-defined networking.
- The networking operating system (NOS) is a part of the control plane.
- The physical devices in an SDN network have no embedded intelligence and control required to perform forwarding tasks, through SDN stack will lead to control.
- When a packet arrives in an OpenFlow device and it does not match any of the rules in one of the tables, there can be several possible actions like forward or drop.
- The Northbound interfaces are the separating medium between the Network-control Applications and the Control plane functionality.
- OpenFlow enables the communication between the control plane and data plane through event-based messages, flow statistics and packet messages that are sent from forwarding devices to controller.
- One of the disadvantages of an SDN centralized controller architecture is that it can introduce a single point of failure and also scaling issues.
- A distributed controller can be a centralized cluster of nodes or a physically distributed set of elements.
- A distributed controller can be used in large networks and it can also be used in small networks.
- ONOS is an example of a distributed controller platform.
- In order to make forwarding and policy decisions in ONOS, applications get information from the view and then update these decisions back to the view.
- In order to achieve fault tolerance, whenever there is a failure of an ONOS instance, a master is chosen by election.
- The purpose of the creation of the P4 language was to offer programmability on the data plane.
- P4 acts as an interface between the switches and the controller, and its main goal is to allow the controller to define how the switches operate.
- The P4 model allows the design of a common language to write packet processing programs that are independent of the underlying devices.
- In an SDX architecture, each AS can define forwarding policies as if it is the only participant at the SDX, as well as having its own SDN applications for dropping, modifying or forwarding their traffic.
- The network-control applications use the information about the network devices and elements, provided by the controller, to monitor and control the network devices.
- Traffic forwarding can be based on any number of header field values in various layers like the transport-layer, network-layer and link-layer.
- In an SDN, the controller is responsible for the routing of the traffic, and the SDN-controlled network elements such as the switches are responsible for the forwarding of the traffic.
- SDN controllers operate on the control plane.
- The northbound interface is used by the controller and the network-control applications to interact with each other.
- A REST interface is an example of a Northbound API.
- OpenFlow API is an example of a southbound API.
- SDN controllers that are implemented by distributed servers are more likely to achieve fault tolerance, high availability and efficiency.
- In a software defined networking, the controller is designed to make decisions in the routing process.
- The transition to IPv6 would be faster with a software defined networking paradigm compared to a conventional networking paradigm.
- An OpenFlow switch may also be used for routing.
- The management plane defines a network policy.
- The control plane enforces a network policy. 
- The data plane executes a network policy.
- Load balancing is possible with software defined networking and conventional networking.
- In software defined networking, load-balancing would take precedence when managing incoming traffic.
- In software defined networking, middleboxes would take precedence when managing incoming traffic.
- OpenFlow is used in the data plane and it is an example of southbound interface.
- The northbound interfaces separate the Management plane and control plane
- The southbound interfaces separate the Data plane and control plane
- When an incoming flow does NOT match any rules in any of the flow tables in the pipeline, OpenFlow device sends a message to the controller
- An flow statistics message sent by OpenFlow device to the network OS allows for quality of service (QoS) policies to be implemented.
- An event-based message would be sent by an OpenFlow device to the network OS in when it receives new routing information
- A network controller prioritizes the rules generated by various services.
- A distributed controller with a centralized cluster of nodes provides the best throughput
- A distributed controller with a physically distributed set of elements provides the highest level of fault tolerance
- A centralized controller has the strongest consistency semantics
- If an ONOS instance fails, the other instances elect a new master for each of the switches that were previously controlled by the failed instance.
- The P4 programming language can not be used with a conventional network paradigm.
- The P4 language is not designed as a replacement for OpenFlow.
- The P4 language allows programmers to use multiple header fields to parse, match, and perform actions on packets.
- The P4 language is used to program the data plane.
- A multiport switch and a SmartNIC are two devices that can be programmed using P4. This is possible because of the target independence goal of P4.
- The forwarding model used by P4 is a pipeline.
- The match+action tables in P4 are more flexible than those in current version of OpenFlow.
- Two operations in the P4 forwarding model is Configure and Populate.
- SDX architectures provides an AS more flexibility for managing traffic.
- In the SDX architecture, each participant AS doesn't have to use the same network applications for traffic engineering.
- In the SDX architecture, two ASes can choose to only exchange video traffic.
- SDX applications are
    - Inbound traffic engineering
    - Wide-area server load balancing
    - Redirection of traffic through middleboxes
- An OpenFlow switch can function as a router.

### 2. Network Security

- Authentication property of secure communication ensures that people are who they say they are when communicating over the internet.
- Integrity property of secure communication ensures that a message is not modified before it reaches the receiver.
- Confidentiality  property of secure communication is protected by encrypting the messages exchanged.
- Availability is offended when there is a hardware failure on critical network infrastructure.
- Availability is offended when a network experiences connectivity disruptions.
- In the event that Trudy is able to access and modify the contents of a message between Alice and Bob, confidentiality and integrity properties of secure communication are violated.
- The uptime of domains used for malicious purposes are kept based on the purpose of attackers.
- Round Robin DNS is a mechanism used by large websites to distribute the load of incoming requests to several servers at a single physical location.
- Fast-Flux Service Networks (FFSNs) can be leveraged by malicious actors to extend the availability of a scam.
- Fast-Flux Service Networks makes it easier to shut down online scams
- Using the fast flux technique to extend the availability of a scam domain name, it makes it complex for the scam to be taken down.
- The main qualitative difference between rogue and legitimate networks is the persistence of malicious behavior.
- Legitimate networks will not let malicious content be up for weeks to more than a year.
- The FIRE system takes primarily a reactive approach to infer network reputation, relying on monitoring IP blacklists.
- FIRE identify the most malicious networks by analyzing the information given by data sources and searching for ASes with a large percentage of malicious IP addresses.
- FIRE system flag a network as malicious only after we have observed indications of malicious behavior (network has a large enough concentration of blacklisted IPs) for a long enough period of time.
- ASwatch which uses information only from the control plane (ie. routing behavior) to identify malicious networks.
- ASwatch takes primarily a proactive approach to infer network reputation by monitoring the routing behavior of networks.
- A rogue network remain undetected by ASwatch (stay under the radar) by maintaining a stable control plane behavior.
- ASwatch monitors routing behavior to determine the legitimacy of a network.
- ASwatch parts from the premise that "bulletproof" ASes have distinct interconnection patterns and overall different control plane behavior from most legitimate networks.
- ARTEMIS uses routing behavior to detect BGP hijacking attacks.
- Prefix deaggregation is a defense against prefix hijacking.
- BGP Blackholing is a defense against DDoS attacks.
- One of the major drawbacks of BGP blackholing is that the destination under attack becomes unreachable since all the traffic including the legitimate traffic is dropped.
- The BGP blackholing technique can not be applied for traffic related to specific applications.
- Consider the reflection and amplification attack as shown in the figure below. IP Address of the Victim s being spoofed in this attack.
![](https://i.imgur.com/ieA4TkO.png)
- Suppose that you are designing a detection system to detect DNS reflection and amplification attacks. To accomplish that you need access to data plane data.
- Suppose that you are designing a detection system to detect BGP hijacking attacks (specifically BGP path and prefix attacks). To accomplish that you need access to control plane data.
- Which of the following techniques can help an attacker to attract more traffic when attempting to hijack a prefix? Select all that apply.
    - Advertise a more specific prefix than the original owner AS
    - Advertise a shorter path to the prefix.
    - Advertise the same path as the original owner AS but change the origin AS.
- In order to stop a prefix or AS-Path announcement attack, we need access to the control plane data, such as IP prefixes and AS-paths.
- ARTEMIS uses a configuration file and a mechanism for receiving BGP updates from routers and monitoring services to detect BGP hijacking attacks.
- Prefix deaggregation and mitigation with Multiple Origin AS (MOAS) are dependent to ARTEMIS.
- Sub-prefix hijacking attack disrupts the BGP characteristic to favor more specific prefixes.
- In attacks where network traffic is dropped, manipulated or impersonated, the data accessed is located at the data plane
- A DDoS Attack consists on the attacker sending a large volume of traffic to the victim through servers (slaves), so that the victim host becoming unreachable or in exhaustion of its bandwidth.
- IP spoofing is the act of setting a false IP address in the source field of a packet with the purpose of impersonating a legitimate server.
- In a reflection attack, the attackers use a set of reflectors to initiate an attack on the victim.
- During a Reflection and Amplification attack, the slaves set the source address of the packets to the victim's IP address. 
- In a DDos attack, the slaves send traffic directly to the victim as opposed to a reflector sending the traffic to the victim.
- BGP Flowspec mitigation technique uses fine-grained filters across AS domain borders, and attributes such as length and fragment can be used to match traffic.
- Traffic Scrubbing Services consists on a service that diverts the incoming traffic to a specialized server, where traffic is divided in either clean or unwanted traffic, and clean traffic is then sent to its original destination.
- BGP Blackholing stops the traffic closer to the source of the attack.
- BGP Blackholing is used to mitigate DDoS attacks.
- One of the disadvantages of a data plane monitoring-based approach to infer network reputation is that it is not feasible to monitor the traffic of all networks to detect malicious behaviors.
- Two different ASes (one genuine one counterfeit) announce a path for the same prefix called exact prefix hijacking 
- The hijacking AS works with a subprefix of the genuine prefix of the real AS called sub-prefix hijacking
- Hijacking AS announces a prefix that has not yet been announced by the owner AS called squatting
- Type-0 hijacking means an AS announcing a prefix not owned by itself.
- Type-N hijacking means counterfeit AS announces an illegitimate path for a prefix that it does not own to create a fake path.
- Type-U hijacking means the hijacking AS does not modify the AS-PATH but may change the prefix.
- Legitimate traffic is also affected with BGP blackholing 
- BGP Blackholing is a defense against DDoS
- The BGP blackholing technique can be applied for traffic related to specific applications.
- Victim AS is responsible to detect the DDoS
- Provider AS is responsible to filter the DDoS traffic
- Attackers set false source and/or destination IP addresses when attempting DDoS to impersonate legitimate servers.
- Assume AS1 is a legitimate network with very low fraction of IPs blacklisted for malicious activity (eg spam, fraudulent activity, etc). Assume that AS2 becomes a customer network of AS1. Monitoring systems will not automatically whitelist AS2.
- Assume that you are the operator of a network where a network range that hosts a critical sever is hijacked. The fastest method to mitigate is to advertise a more specific prefix.
- Suppose that you are designing a detection system to detect DNS reflection and amplification attacks. To accomplish that, at a minimum, you need access to data plane data

### 3. Censorship

- The Great Firewall of China injects fake DNS A records to block domain names.
- The Great Firewall of China injects fake DNS record responses to restrict access to specific domain names.
- Packet Dropping is prone to overblocking traffic
- Suppose a user loads a webpage, but a single image will not load. The user has determined that some entity is likely censoring the content. In this case, content inspection is the most likely to be used.
- TCP RSTs allow blocking of individual connections.
- The Great Firewall of China is likely managed by a single entity.
- The Great Firewall of China may block content based on
    - Keywords within the URL
	- Images on webpage
	- Destination IP
- The GFW can block a portion of a website using content inspection
- Suppose a client in Cambridge makes a request to a website based in China. GFW resets the connection after the ACK sent by the client in Cambridge
- A censorship technique can use any combination of criteria based on content, source IP and destination IP to block access to objectionable content.
- DNS injection uses DNS replies to censor network traffic based on faking DNS A record response values.
- With a censorship technique based on packet dropping, all network traffic going to a set of specific IP addresses is discarded.
- When using DNS poisoning, there is no answer returned or an incorrect answer is sent to redirect or mislead the user request.
- When using content inspection, all traffic passes through a proxy where it is examined for content, and the proxy rejects requests that serve objectionable content.
- When using the Blocking with Resets technique, if a client sends a request containing flaggable keywords, only the connection containing requests with objectionable content is blocked.
- With the Immediate Reset of Connections technique, whenever a request is sent containing flaggable keywords, any subsequent request will receive resets from the firewall for a certain amount of time.
- One of the obstacles to fully understand DNS censorship is the heterogeneity of DNS manipulation across the globe.
- It is difficult to infer if there is DNS manipulation based on few indications such as inconsistent or anomalous DNS responses.
- There is a need for methods and tools independent of human intervention and participation in order to achieve the scalability necessary to measure Internet censorship.
- It is considered dangerous for volunteers to participate in censorship measurement studies and accessing DNS resolvers or DNS forwarders.
- Augur targets to identify IP-based disruptions as opposed to DNS-based manipulations.
- CensMon is a global censorship measurement tool used PlanetLab nodes in different countries.
- OpenNet Initiative requires volunteers perform measurements on their home networks at different times since the past decade.
- Iris uses open DNS resolvers for diversity and  identifies DNS manipluation via machine learning.
- In order to infer DNS manipulation, Iris relies on consistency metrics (internal metrics that should be consist) and independent verifiability metrics (metrics that can be externally verified using external data sources). 
- In Augur, assume a scenario where there is no blocking. The Measurement Machine sends a `SYN-ACK` to the reflector, then the return IPID from the reflector to the Measurement Machine should increase by 2.
- In Augur, assume a scenario where there is inbound blocking. The Measurement Machine sends a `SYN-ACK` to the reflector, then the return IPID from the reflector to the Measurement Machine will increase by 1.
- In Augur, assume a scenario where there is outbound blocking. The Measurement Machine sends a `SYN-ACK` to the reflector, then the return IPID from the reflector to the Measurement Machine will increase by 4.
- Censorship methods are inconsistent across ISPs making it difficult to measure DNS manipulation.
- Current research methods for understanding DNS methods are not scalable due to the little number of volunteers participating.
- The use of Open DNS resolvers resolves some of the ethical concerns associated with Internet censorship studies.
- DNS manipulation occurs when making mistake due to misconfigurations and some entity attempts to block access to particular content.
- Iris uses Open DNS Resolvers to obtain a dataset for machine learning.
- Suppose Iris is being used to detect DNS manipulation. Iris queries a global resolver for an IP addresses (consistency metric) and receives a DNS A record with a different IP address than the ones stored. The response is inconsistent, but might not be classified as manipulated.
- Augur is used to identify IP-based manipulations.
- Iris is used to identify DNS-based manipulations.
- Which of the following censorship methods can be deployed to enable connectivity disruption?
    - Physically disconnect critical network infrastructure
    - Disrupting the routers responsible for communicating BGP updates to other routers in a network
    - Filtering packets that match certain criteria
- The greatest weakness of the packet dropping DNS censorship technique is the difficulty to maintain up-to-date blocklists
- One of the challenges associated with measuring DNS manipulation is the ethical issues related to involving citizens in censorship measurement studies.
- The techniques used for DNS manipulation is inconsistent across Internet service providers.
- There is no trend to design censorship detection and circumvention techniques that rely on the participation of volunteers across the globe.
- Iris uses both its own consistency metrics and also independent verifiability metrics to identify manipulation.
- Iris identifies and uses Open DNS resolvers to obtain a dataset for its censorship detection module.
- Augur is a method and accompanying system that utilizes TCP/IP side channels to measure reachability (if there is any filtering) between two Internet locations without directly controlling a measurement vantage point at either location.

### 4. VoIP

- File Transfer is the less sensitive to network delays compared to VoIP.
- File Transfer is the more tolerant to packet losses compared to VoIP.
- Consider packet loss with VoIP application, using TCP instead of UDP results in less packet loss and more end-to-end delay.
- QoS metrics for VoIP applications are
    - end-to-end delay
    - jitter
    - packet loss
- In VoIP applications, increased packet jitter results in increased end-to-end delay.
- A longer jitter reduces the number of packets that are discarded because they were received too late, but that adds to the end-to-end delay.
- A shorter jitter buffer will not add to the end-to-end delay as much but thet can lead to more dropped packets, which reduces the speech quality.
- Network conditions such as buffer sizes, queueing delays, network congestion levels has an impackt on packet jitter.
- In VoIP applications, we have a harsher definition for packet loss, as we consider a packet to be lost if it never arrives or if it arrives after its scheduled playout.
- With Forward Error Concealment we also transmit redundant data that can be used for reconstructing the stream at the receiver’s side. This approach to error recovery can lead to more bandwidth consumption.
- With interleaving we mix chunks of audio together so we avoid scenarios where consecutive chunks are lost. This approach can lead to increased latency.
- UDP is the preferred transport-level protocol for VoIP.
- Conversational voice and video over IP is not using traditional circuit-switched telephony networks.
- The rounding of samples to a discrete number in a particular range is called quantization.
- For VoIP, the important thing is that we want to still be able to understand the speech and the words that are being said, while at the same time still using as little bandwidth as possible.
- VoIP maintains a jitter buffer as a mechanism for mitigating jitter.
- Most of the time, VoIP uses UDP to transmit audio.
- Interleaving has added latency for VoIP
- Error concealment can be computationally cheap if a lost packet is simply replaced with a previous packet.

### 5. Streaming

- When streaming stored multimedia applications, users don't have to download the entire content before it can start playing.
- With streaming stored multimedia applications, the user can pause, fast forward, skip ahead the audio/video.
- TCP is the preferred transport-level protocol for video streaming.
- From the user’s perspective, the characteristics of good quality of experience include
    - Low or zero re-buffering
    - High video quality
    - Low video quality variations
    - Low start up latency
- With throughout-based rate adaption, our goal is to have a buffer-filling rate that is greater than the buffer-depletion rate.
- With rate-based adaption, when the bandwidth changes rapidly, the player takes some time to converge to the right estimate of the bandwidth, which can lead to overestimation of the future bandwidth.
- When streaming stored multimedia applications, the user must download first the entire content before it can start playing.
- Streaming audio and video is interactive and should have a continuous playout.
- Streaming live audio and video is usually not interactive and is delay-sensitive.
- Video delivery does not tolerant to packet losses.
- Content providers store all the intelligence to download the video at the client.
- A manifest files is the first item downloaded by a client's video player.
- A single-bitrate encoded video is not the best solution for video streaming because network conditions can vary.
- Forward Error Concealment (FEC) increases playout delay, because it results in the generation of additional data.

### 5. CDNs

- Having a single server for providing Internet content has the following disadvantages
    - Single point of failure.
    - Bandwidth waste in high demand for the same content.
    - Scalability issues.
    - Potentially big geographic distance between Internet hosts/users and the server.
- Although routing protocols are challenging for content delivery, CDNs doesn't take aspects like congestion and latency into consideration.
- There are several factors that can make a CDN network unreliable, such as misconfigured routers, power outages, malicious attacks or natural disasters.
- As the Internet evolves, the topology of the ISPs has become flatter, and the number of IXPs increases as the time progresses due to the services they offer and the lower costs for the ISPs.
- The major drawback of the Enter Deep approach is the difficulties to manage and maintain so many clusters.
- The major drawback of the Bring Home approach is that, if one server is lost, that geographic area will experience a higher delay and lower throughput.
- When using CDN servers for content delivery, there is more overhead than when using the traditional approach.
- For a CDN to deliver content to an Internet user, a cluster is mapped to a client first and then a server within that cluster is selected.
- Picking the geographically closest cluster location for a user is always not the optimal choice in terms of performance for content delivery.
- By using consistent hashing for server selection, in the case of a server failure, the objects that the server was responsible for can be taken care of by the next server within the same ID space.
- When using DNS caching, if a host A makes a request for a domain that was just previously queried by another host, the local DNS server will immediately answer the host with the IP address.
- The type of DNS record `amazon.com, dns.amazon.com, ?, TTL` is NS.
- IP Anycast assigns the same IP address to multiple servers in order to deliver content from CDNs by using the closest server to a client based on BGP path length.
- HTTP redirection can be used in order to share the load of content requests among servers for load-balancing.
- DNS-based content delivery aims to distribute the load amongst multiple servers at a single location, but also distribute these servers across the world.
- DNS-based content delivery determines the nearest server, which results in increased responsiveness and availability.
