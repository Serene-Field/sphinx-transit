# Computer Network 1 ｜ Introduction to Computer Network, OSI Model, Principles, and Devices

### 1. Introduction to Computer Network

#### (1) Functions of Computer Network

- **Global Infrastructure**: 3.2b Internet users in 2018 and 4b users in 2020
- **Game Changer**: network changes how we do business
- **Research Innovations**: internet systems, protocol architectures, algorithms, and applications are innovation playgrounds
- **Impactive Solutions**: networking provides opportunities cross fields that can have a huge impact

#### (2) History

- J.C.R. Licklider (1962): Galactic Network - access data through a set of interconnected computers with low-speed dial-up telephone lines in CA
- ARPANET (1969): the first network connects four nodes (from UCLA, Stanford Research Institute, UCSB and Univ. of Utah, respectively)
- Network Control Protocol (1970): initial ARPANET Host-to-Host protocol
- Email (1972): one of the first applications that launches based on NCP
- TCP/IP (1973): new version of the NCP protocol with features like flow control and recovery from lost packets
- Domain Name System (1983): protocol for translating domain names to IP addresses
- World Wide Web (1990): the most popular application based on DNS

#### (3) Architecture

Connecting hosts running the same applications but located in different types of networks. For example, two BitTorrent clients should be able to communicate through different networks (e.g. wifi and Ethernet). In order to mett this need, the designers of network organized the protocols into **layers**.

So the functionalities in the network architecture are implemented by dividing the architecture model into layers and each layer offers different services. Advantages for layered network include scalability, modularity, flexibility, and cost effectiveness.

However, there are also some disadvantages include,

- **dependency**: some layers depend on the information from other layers which violates layer separation
- **duplication**: one layer may duplicate lower layers
- **addition overheads**: caused by abstractions

We call this archirtecture the OSI model.

### 2. OSI Model

#### (1) Intro to 7 layered OSI Model

For the layered implementation, ISO proposed the **seven-layered** OSI model consists of the following layers

- application layer
- presentation layer
- session layer
- transport layer
- network layer
- data link layer
- physical layer

#### (2) Physical Layer

This layer has the actual hardwares used to connect between two nodes and it depends on the actual tranmission medium of the link. For example, Ethernet has different ayer protocols for twisted-pair copper wire, coaxial cable, and single-mode fiber optics.

#### (3) Data Link Layer

The data link layer is responsible to move the frames from one node to the next node. The added frame information make packets **distinguishable** from another. Some common protocols in this layer include **Ethernet**, PPP, **WiFi**. The packets of information are called **frames**.

#### (4) Network Layer

The network layer is responsible for moving datagrams from one Internet host to another and the information will have the **routing** or **path** information. The common protocols include **IP** and **routing**. And the packet of information in this layer is called **datagram**.

#### (5) Transport Layer

The transport layer is responsible for the end-to-end communication between hosts and the information is used to **guarante delivery** and **control flows**. There are two protocols in this layer called **TCP** and **UDP**. The packet of information in this layer is called **segment**.

#### (6) Session Layer

The session layer is responsible for transport streams of different end users. This is an optional layer in the five-layered Internet Protocol Stack model.

#### (7) Presentation Layer

The presentation layer plays the intermediate role of formatting the information. For example, translating integers from big endian to little endian format. This is an optional layer in the five-layered Internet Protocol Stack model.

#### (8) Application Layer

The application layer is the place where the applications are implemented. It has common protocols like **HTTP**, **SMTP**, **FTP**, **DNS**, etc.

#### (9) Communication Between Layers

Encapsulation is the process of send the data from the application layer to the physical layer. And deencapsulation means the opposite. The steps of encapsulation include,

- raw message (M) in application layer
- segment (S) of M added delivery info in transport layer
- datagram (D) of S added path info in network layer
- frame (F) of D added packet info in data link layer
- frame transmitted across the physical medium

#### (10) Layer-2 Device and Layer-3 Device 

Not all the devices in a network is going to implement the whole OSI model. **Layer-2** Device (e.g. switch) is a device that implements only the physical layer and data link layer, while **layer-3** device (e.g. router) is a device that implements only the physical layer, data link layer, and network layer.


### 3. Principles

#### (1) Intro to End-to-End(e2e) Principle

In our previous discussions, we have noticed that the end hosts implement all the five layers but some intermediate devices don’t. As a result of this design, the computer will become complicated and ingelligent at the edges but the core will be relatively simple. 

Therefore, the **e2e principle** suggests that specific application-level functions usually cannot, and preferably should not be built into the lower levels of the system at the core of the network. Under this principle, systems designers should avoid building any more than the essential and commonly shared functions into the network.

#### (2) Goal of E2E Principle

The goal of e2e principle is to move functions and services closer to the applications that use them. Thus, the higher-level protocol layers are more specific to an application, whereas the lower-level protocol layers are free to organize the lower-level network resources.

#### (3) Violations of E2E Principle: Firewalls and NAT Boxes

Even through E2E principle is followed in the most cases, there are some applications where we violate it. 

The first application is the firewall since they are intermediate devices that can drop end hosts communcations.

The second application is the Network Address Translation (NAT) boxes. An NAT-enabled router can be assigned a public IP address and every the other interface gets an IP address that belongs to the same private subnet (LAN). These private networks are always behind a NAT.

The NAT box will maintain an NAT translation table which maps the public \[IP:port\] to LAN \[IP:port\]. For example, \[128.119.40.186:80\] can be mapped to \[10.0.0.4:3005\] in LAN.

NAT boxes violate the E2E principle because the end hosts in LAN and public can not communicate without the intervention of a NAT box.

#### (4) Hourglass Shape Protocols Principle

The idea of the hourglass shape of protocols is that there can be many protocols in the physical layer and the application layer, but in the middle, mostly IPv4, TCP, and UDP are difficult to be replaced (like the waist if the hourglass). Researchers suggest a model called the **Evolutionary Architecture model**(EvoArch) to explain why the hierarchical structure of the layer architecture eventually lead to the hourglass shape. 

The EvoArch model suggests that the TCP/IP stack was not trying to compete with the telephone network services. The TCP/IP was mostly used for applications such as FTP, E-mail, and Telnet, so it managed to grow and increase its value without competing or being threatened by the telephone network, at that time that it first appeared. Later it gained even more traction, with numerous and powerful applications relying on it.

EvoArch explains a large birth rate at the layer above the waist can cause death for the protocols at the waist if these are not chosen as substrates by the new nodes at the higher layers. Any new protocols that might appear at the transport layer are unlikely to survive the competition with TCP and UDP which already have multiple products. And the stability of the TCP/UDP adds to the stability of IPv4 by eliminating any potential new transport protocols.

### 4. Devices

#### (1) Recall: Layer-2 Devices

**Layer-2 Device** (e.g. switch or bridge) is a device that implements only the physical layer and data link layer. The packets are transmitted based on the MAC addresses and the limitation is the bandwidth. 


#### (2) Recall: Layer-3 Devices

**Layer-3 device** (e.g. router) is a device that implements only the physical layer, data link layer, and network layer. The packets are transmitted based on the IP addresses.

#### (3) Layer-1 Devices

**Layer-1 device** (e.g. hub or repeater) operates only on the physical layer as they receive and forward digital signals to connect different Ethernet segments. They provide connectivity between hosts that are directly connected in the same network.

#### (4) Bridge

Now let's talk more about bridge. The bridge is an L2 devices that commonly used to connect two private networks. It receives inputs on one port and transfer them to another port as the outputs. However, it will check the MAC address of the source and the destination. If an input has the source and the destination belonging to the same private network, it will not forward the message to the other network. 

Although we can manually maintain a mapping table so that the bidge will know which node is in which network, it's better if the bridge can learn itself. This is possible because the bridge can know which port is accessible to which host, so it can automatically create a table over time as follows. We call this a learning bridge. 

| Host | Port |
| ---- | ---- |
| A    | 1    |
| B    | 1    |
| C    | 1    |
| X    | 2    |
| Y    | 2    |
| Z    | 2    |

#### (5) Looping Problem For Bridges

However, if we have many LANs and many bridges to connect between them, the network topology commonly ends up with loops. In this case, if we don't have a solution, the packets will loop through the network forever. 

We will solve this problem later in a project with the spinning tree protocol.

