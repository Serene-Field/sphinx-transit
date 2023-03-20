# Computer Network 13 | 

### 1. Advanced SDN Topics

#### (1) Recall: SDN Motivation

- Handle the ever growing complexity and dynamic nature of networks
- Tightly coupled architecture of control plane and data plane

#### (2) Recall: Software Defined Networking (SDN)

This networking paradigm is an attempt to overcome limitations of the legacy IP networking
paradigm. It starts by separating out the control logic (in the control plane) from the data plane. 

#### (3) Recall: OpenFlow

The separation of control and data plane is achieved by using a programming interface (API) between the SDN controller and the switches. An example of such an API is `OpenFlow`. 

An OpenFlow switch can be instructed by the controller to behave like a firewall, switch,
router, or even perform other roles like load balancer, traffic shaper, etc.

#### (4) Three Planes of Network Functionality

- Data plane: These are functions and processes that forward data in the form of packets or frames.
- Control plane: These refer to functions and processes that determine which path to use by using protocols to populate forwarding tables of data plane elements.
- Management plane: These are services that are used to monitor and configure the control functionality, e.g. `SNMP`-based tools.

#### (5) SDN Advantages

- Shared abstractions: with SDN, the middlebox services (or network functionalities) can be programmed easily with the abstractions provided by the control platform
- Consistency: all network applications have the same global network information view, leading to consistent policy decisions
- Locality: with SDN, middlebox applications can take actions from anywhere in the network
- Simpler integration: integrations of networking applications are smoother

#### (6) Control Plane Functions 

Compared with conventional network, the control plane is responsible for,

- MAC learning
- Routing Algorithms
- Intrusion Detection
- Load Balancing

#### (7) SDN Landscape

The landscape of the SDN architecture can be decomposed into layers as shown in the figure below. The figure presents three perspectives of the SDN landscape,

- (a) plane-oriented view
- (b) SDN layers view
- (c) system design view

![](https://i.imgur.com/R6ey4fL.png)

#### (8) Recall: SDN Archirecture Overview

As we have discussed, SDN has the following structure,

- Infrastructure: routers, switches and other middlebox hardware
- Southbound interfaces: the most popular southbound API is OpenFlow but there are many other APIs like ForCES, OVSDB, POF, OpFlex, OpenState, etc.
- Network virtualization: existing virtualization constructs such as VLAN, NAT and MLPS are able to provide full network virtualization. New advancements that provides more abstractions in SDN network virtualization such as VxLAN, NVGRE, FlowVisor, FlowN, NVP are promising.
- Network operating systems (NOS): network management and network problem resolving abilities are centrialized by NOS. Some popular NOSs are OpenDayLight, OpenContrail, Onix, Beacon and HP VAN SDN.
- Northbound interfaces: Northbound interface is still an open problem. The northbound APIs are supposed to be a mostly software ecosystem like Floodlight, Trema, NOX, Onix and SFNet.
- Language-based virtualization: Programming languages as an important characteristic of virtualization. Some popular examples of programming languages that support virtualization are Pyretic, libNetVirt, AutoSlice, RadioVisor, OpenVirteX, etc.
- Network programming languages: Network programmability can be achieved by low-level or high-level programming languages like Pyretic, Frenetic, Merlin, Nettle, Procera, FML, etc.
- Network applications: These are the functionalities that implement the control plane logic and translate to commands in the data plane. Some well known solutions are Hedera, Aster*x, OSP, OpenQoS, Pronto, Plug-N-Serve, SIMPLE, FAMS, FlowSense, OpenTCP, NetGraph, FortNOX, FlowNAC, VAVE, etc.

![](https://i.imgur.com/ZTjuFQm.png)

#### (9) SDN Infrastructure Layer

Let's focus more on the infra layer. As we have discussed, the infra layer composes of networking equipment like routers, switches and appliance hardware. 

In the SDN architecture, a data plane device is a hardware or software entity that forwards packets, while a controller is a software stack running on commodity hardware. 

A model derived from `OpenFlow` is currently the most widely accepted design of SDN data plane devices. It is based on a pipeline of flow tables where each entry of a flow table has three parts,

- matching rule
- actions to be executed on matching packets
- counters that keep statistics of matching packets

Other SDN-enabled forwarding device specifications include Protocol-Oblivious Forwarding (POF) and Negotiable Datapath Models (NDMs).

In an OpenFlow device, when a packet arrives, the lookup process starts in the first table and ends either with a match in one of the tables of the pipeline or with a miss. Some possible actions for the packet include,

- Forward the packet to outgoing port
- Encapsulate the packet and forward it to controller
- Drop the packet
- Send the packet to normal processing pipeline
- Send the packet to next flow table

We have already seen these actions in the SDN Fireward project.

#### (10) Flow Info Sources from OpenFlow to NOS

- Event-based messages: sent by forwarding devices to controller when there is a link or port change
- Flow statistics: generated by forwarding devices and collected by controller
- Packet messages: sent by forwarding devices to controller when they do not know what to do with a new incoming flow

#### (11) Centralized vs Distributed SDN Controllers

In **centrialized SDN controller** architecture, we typically see a single entity that manages all forwarding devices in the network, which is a single point of failure and may have scaling issues. Also, a single controller may not be enough to handle a large number of data plane elements.

Some examples of Centrialized SDN controllers are,

- With muli-threaded designs: Maestro, Beacon, NOX-MT
- Target specific environments (e.g. data center or cloud infra): Trema, Ryu NOS
- Specific funcality: Rosemary
- Container-based structure: micro-NOS


Unlike single controller architectures that cannot scale in practice, a **distributed network controller** can be scaled to meet the requirements of potentially any environment - small or large networks. Distribution can occur in two ways,

- a centralized cluster of nodes
- a physically distributed set of elements

Typically, a cloud provider that runs across multiple data centers interconnected by a WAN may require a hybrid approach to distribution - clusters of controllers inside each data center and distributed controller nodes in different sites. 

Properties of distributed controllers are,

- Weak consistency semantics
- Fault tolerance

#### (12) SDN Controller Example: Open NOS (ONOS)

ONOS (Open Networking Operating System) is a distributed SDN control platform. It aims to provide a global view of the network to the applications, scale-out performance and fault tolerance. The prototype was built based on `Floodlight`, an open-source single-instance SDN controller. The figure belows shows a layered view of ONOS,

![](https://i.imgur.com/FhRxPOs.png)

And ONOS contains the components in the figure shown below.

![](https://i.imgur.com/k8htI6M.png)

Owing to the distributed architecture of ONOS, there are several ONOS instances running in a cluster. The management and sharing of the network state across these instances is achieved by maintaining a global network view.

To make **forwarding and policy** decisions, the applications consume information from the view and then update these decisions back to the view. The corresponding `OpenFlow` managers receive the changes the applications make to the view, and the appropriate
switches are programmed.

To achieve **fault tolerance**, ONOS redistributes the work of a failed instance to other remaining instances. Each switch in the network connects to multiple ONOS instances with only one instance acting as its master. Each ONOS instance acts as a master for a subset of switches. 

`Zoopkeeper` is used to maintain the mastership between the switch and the controller.

### 2. Programming the Data Plane

#### (1) Motivation for Data Plane Programming

- Reconfigurability: The way parsing and processing of packets takes place in the switches should be modifiable by the controller.
- Protocol independence: To enable the switches to be independent of any particular protocol, the controller defines a packet parser and a set of tables mapping matches and their actions.
- Target device independence: The packet processing programs should be programmed independent of the underlying target devices.

#### (2) Programming Protocol-independent Packet Processors (P4)

P4 (Programming Protocol-independent Packet Processors) is a high-level programming language to configure switches which works in conjunction with SDN control protocols. The popular vendor-agnostic OpenFlow interface enables the control plane to manage devices from different vendors. Thus, to manage the demand for increasing number of header fields, a need arises for an extensible, flexible approach to parse packets and match header fields. 

#### (3) P4 Forwarding Model

Switches with P4 use a programmable **parser** and a set of **match action tables** to forward packets. 

P4 model also allows **generalization** of packet processing across various forwarding devices like routers and load balancers. It also uses multiple technologies such as fixed function switches, NPUs, etc. This generalization allows the design of a common language to write packet processing programs that are independent of the underlying devices.

There are two main operations in a P4 forwarding model,

- Configure: sets of operations are used to program the parser. They specify the header fields to be processed in each match action stage and also define the order of these stages.
- Populate: entries in tables specified during configuration may be altered using the populate operations

![](https://i.imgur.com/Lc86WZm.png)

### 3. SDN Applications

#### (1) Types of SDN Application

There are many types of SDN applications include,

- Traffic Engineering: for minimize power consumption, judiciously use network resources, perform load balancing, etc.
    - ElasticTree: reduce power consumption
    - Plug-n-Serve: load balancing control
    - Aster*x: load balancing control
    - ALTO VPN: dynamic provisioning of VPNs
- Mobility and Wireless: for management of the limited spectrum, allocation of radio resources and load-balancing
    - OpenRadio: OpenFlow for wireless
    - Light virtual access points (LVAPs): wireless network management
- Measurement and Monitoring: for adding features to other networking services and improving the existing features
    - BISmark: add new measurements
    - OpenSketch: SB API offers flexibility for network measurements
    - OpenSample: monitoring frameworks
    - PayLess: monitoring frameworks
- Security and Dependability: for improving the security of networks
    - DDoS detection: application identifies and mitigates DDoS flooding attacks
    - OF-RHM: fake dynamic IPs to the attackers
    - CloudWatcher: monitoring the cloud infrastructures
- Data Center Networking: for data center related services such as live migration of networks, troubleshooting, real-time monitoring of networks
    - LIME: provide live virtual network migration
    - FlowDiff: detect abnormalities

#### (2) Software Defined Internet Exchange (SDX)

In a previous topic, we talked about the Internet Exchange Points (IXPs). In this topic we are looking at how the SDN technology could be applied to improve the operation of an IXP.

Let's recall the two limitations of BGP for IXPs,

- Routing only on destination IP prefix
- Networks have little control over end-to-end paths

In the context of the IXPs, researchers have proposed an SDN based architecture called **software defined internet exchange (SDX)** to improve these BGP limitions. SDX was proposed to implement multiple applications including,

- Application specific peering
- Traffic engineering
- Traffic load balancing
- Traffic redirection through middleboxes

#### (3) SDX Architecture

In a traditional IXP the participant ASes connect their BGP-speaking border router to a shared layer-two network and a BGP route server (RS).

In the SDX architecture, each AS the illusion of its own **virtual SDN switch** that connects its border router to every other participant AS. 

- Each AS can define **forwarding policies** as if it is the only participant at the SDX, without influencing how other participants forward packets on their own virtual switches. The policies can also be different based on the direction of the traffic (inbound or outbound). The SDX is responsible to combine the policies from multiple participants into a single policy for the physical switch.
- Each AS can have its **own SDN applications** for dropping, modifying, or forwarding their traffic. 

To write policies, SDX uses the `Pyretic` language to match header fields of the packets and to express actions on the packets.

#### (4) SDX Example

Let's suppose we have three ASes `A`, `B`, and `C`. Each of them has its own virtual switch connecting to the other ASes' virtual switches. 

Suppose AS `A` has an outbound policy as,

```
(match(dstport=80) >> fwd(B)) + (match(dstport=443) >> fwd(C))
```

And AS `B` has an inbound policy as,

```
(match(srcip={0/1}) >> fwd(B1)) + (match(srcip={128/1}) >> fwd(B2))
```

Then according to AS `A`’s outbound policy, the HTTP traffic with destination port `80` is forwarded to AS B and HTTPS traffic with destination port `443` is forwarded to AS `C`.

![](https://i.imgur.com/9qxvMap.png)

#### (5) SDX Applications

SDX can be useful in various applicaions,

- Application specific peering
- Inbound traffic engineering
- Wide-area server load balancing
- Redirection through middle boxes
