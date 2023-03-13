# Computer Network 11 | Introduction of SDN and SDN Architecture

### 1. Introduction of SDN

#### (1) Difficulties of Managing Computer Networks

In practice, it's very difficult to manage a computer network because of the following two reasons,

- **Diversity of Equipment**: computer networks have a large range of equipments and these equipments require to operate at a level of individual protocols, mechanisms and configuration interfaces, making the network difficult to manage. The common equipments include,
    - routers
    - switches
    - middleboxes
        - firewalls
        - network address translators (NATs)
        - server load balancers (LBs)
        - intrusion detection systems (IDSs)

- **Proprietary Technologies**: Equipments like routers and switches tends to run softwares that are closed-source and proprietary, which means the config interfaces can be various. 

#### (2) Software Defined Networking (SDN)

Because of these difficulties of managing the network, SDN was developed as part of the process to make computer networks more programmable. The basic idea of SDN is to seperate the tasks into **control plane** and **data plane** so the the network become modular and manageable.

#### (3) History of SDN 1: Active Networks (mid 1990s ~ early 2000s)

In early 1990s, the networking approach was primarily via IP or ATM (we mentioned it when we talked about knockout scheme).

The network took off and researchers were eager to test out new ideas to improve network efficiency. However, this process was bottlenecked by standardization of new protocols of organization Internet Engineering Task Force (IETF).

Therefore, this lead to the growth of activate network which aimed at opening up network control. It envisioned **APIs** that exposed the network nodes and it supported customization of functionalities for flows of packets.

#### (4) Two Active Network Models

There are two main types of programming models in activate networking, include,

- Capsule model: each capsulate contains both the data and a set of instructions for processing the data. The capsules are processed by a sequence of Capsule routers.

- Programmable router/switch model: the routers and switches in the network are themselves programmable.

Note that the capsule model has the following benefits,

- most closely related to active networking
- bring a new data-plane functionality
- cache to make code distribution more efficient

#### (5) Reasons for Active Networking

There are several technological incentives that lead to the active networks,

- Reduction in computation cost
- Advancement in programming languages
- Advances in rapid code compilation and formal methods
- Funding from agencies such as U.S. Defense Advanced Research Projects Agency (DARPA)

There are also some other emerging use cases require this properity,

- Network service providers require shorter time to develop and deploy new network services.
- Third party interests to add value by implementing control of specific applications or network conditions.
- Researchers interest in having a network that would support large-scale experimentation.
- Unified control over middleboxes.

#### (6) Active Network's Contributions to SDN

- Programmable functions in the network to lower the barrier to innovation.
- Network virtualization, and the ability to demultiplex to software programs based on packet headers.
- The vision of a unified architecture for middlebox orchestration.

#### (7) History of SDN 2: Control and Data Plane Separation (2001 ~ 2007)

Because there was a steady increase in traffic volumes during this period of time, the network reliability, predictability and performance became more important.

Therefore, network providers were looking for better network-management functions and researchers identified the challenge in network management happened because of a tight integrate of control plane and data plane in switches. Once this was identified, efforts to separate the these two planes began.

#### (8) Reasons for Seperation

There are several technological incentives that lead to the plane seperation,

- Higher link speeds in backbone networks requires direct packet forwarding implement by hardware
- ISPs found it hard to meet the increasing demands for reliability, VPNs, and scalability
- Servers are more powerful on processing, storage, and memory
- Open-source routing software lowered the barrier of creating centralized routing prototype

These incentives lead to two main innovations,

- Open API between control plane and data plane
- Logically centralized network management

There are also some other emerging use cases require this properity,

- Demand of selecting network paths
- Minimize routing change disruptions
- Detect and drop suspicious attacking traffic
- Allow customized network traffic
- Provide other services like VPN

As a result, the data plane and control plane seperation leads to the following two main benefits,

- **Independency**: Independent evolution and development of data plane and control plane
- **Control**: SDN can control through high-level software program

#### (9) Control and Data Plane Separation's Contributions to SDN

- Centralized control to data plane through API
- Distributed state management

What's more, this separation leads to opportunities in different areas of SDN,

- **Data centers**: SDN helps to manage data center networks
- **Routing**: SDN can provide more control over path selection and it's easier to update router's state
- **Enterprise networks**: SDN can improve the security applications for enterprise networks
- **Research networks**: SDN allows research networks to coexist with production networks
 
#### (10) History of SDN 3: OpenFlow API (2007 ~ 2010)

OpenFlow is a network protocol developed with the purpose of increasing network scalability. It allows the server to tell the OpenFlow enabled switch where to send the packets.

When a packet comes to an OpenFlow enabled switch, it will switch based on a table of packet-handling rules where each rule has,

- a pattern
- a list of actions
- a set of counters
- a priority

The packet-moving decisions are made based on the highest priority matching rule. This process under OpenFlow is centralized so that the network can be programmed independently of the individual switches.

#### (11) Reasons for OpenFlow

There are several technological incentives that lead to the OpenFlow,

- With microchips, switches are programmable
- Companies build switches without having to design and fabricate their own data plane
- Early OpenFlow versions built on technology that the switches already supported

There are also some other emerging use cases require this properity,

- OpenFlow came up to meet the need of conducting large scale experimentation on network architectures
- OpenFlow was useful in data-center networks
- Companies started investing more in programmers to write control programs

#### (12) OpenFlow's Contributions to SDN

- Generalize network devices and functions
- Transfer network to an operating system
- Enable other distributed state management techniques

### 2. SDN Architecture

#### (1) Components of SDN

The data plane of an SDN contains infrastructures which is mainly SDN controlled switches. The control plane include the SDN controller and other network control applications.

- Infra layer: SDN controlled switches
- Controller layer: Network OS (SDN Controller)
- Application layer: Network Control Applications
    - Routing
    - Access Control (IAM)
    - Load Balancer (LB)

There are two API rules in this structure, 

- Northbound API: API between applications and controller
- Sorthbound API (OpenFlow): API between controller and infra

![](https://i.imgur.com/GfGUjtS.png)


#### (2) SDN Architecture Features

- Flow-based forwarding

The rules for forwarding packets in the SDN-controlled switches can be computed based on any number of header field values in various layers. For example, OpenFlow allows up to 11 header field values to be considered.

- Separation of data plane and control plane

SDN-controlled switches operate on the data plane and they only execute the rules in the flow tables.

- Network control functions

The controller provide update-to-date network states about infra devices for applications to monitor and control.

- Programmable network

Network control applications used to control the network are programmable.

#### (3) SDN Controller Architecture

- Communication Layer

This layer consists of a protocol for SDN communication to infra devices. We can have several options on this protocol including `OpenFlow`, `PCEP`, `SB` and etc. This layer is also know as the **Southbound API**.

Today's SDN controllers are using `OpenFlow`.

- Network-wide state-management layer

This layer is where the real process happens. It includes the informations like state of the hosts, links, switches and other controlled elements in the network. Network-state information is needed by the SDN control plane to configure the flow tables.

- Interface to application layer

This layer is also known as the **Northbound API**. Through this interface, controller can notify the applications changes of the network state based on the event notifications.

There are several kinds of interfaces we can choose in this layer include `HTTP`, RESTful API, `RPC`, Java Native Functions, etc.


![](https://i.imgur.com/t9KBaBN.png)
