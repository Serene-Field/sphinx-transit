# Computer Network 12 | SDN Firewall Project

### 1. Submission and Rubic

- `packetcapture.pcap` (15)
- `sdn-firewall.py` (5)
- `configure.pol` (5)
- Pass SDN firewall unit tests (35 + 15 + 25)

### 2. Recall: Setup VM

- Use `ssh` for IDE connection
- Use `git` for code version control and sync to github

Reference: [Link](https://serene-field.github.io/sphinx-transit/OMSCS/CN/note7.html)

- Remeber to clean up mininet in case of any conflicts,

```
$ mn -c
```

### 3. Wireshark

- Start a mininet prompt by topo file `ws-topology.py`,

```
$ sudo python ws-topology.py
mininet>
```

- Start two xterm windows for `us1` and `us2` hosts

```
mininet> us1 xterm&
mininet> us2 xterm&
```

In `us1` xterm window, change the command prompt by,

```
# export PS1="us1 >"
us1 >
```

Similarly, in `us2` xterm window,

```
# export PS1="us2 >"
us2 >
```

Note that this step should only be executed with the non-root role. This means we can not use `sudo su -`.

- In mininet prompt, use wireshark command `tshark` to generate packet information of `us1` host.

```
mininet> us1 sudo tshark -w /tmp/packetcapture.pcap
```

- Simulate network traffic with the following steps
    - `us1`: `ping 10.0.1.2`, then ctrl+C to kill the process
    - `us2`: `ping 10.0.1.1`, then ctrl+C to kill the process
    - `us1`: `python test-server.py T 80`
    - `us2`: `python test-client.py T 80`
    - `us1`: ctrl+C to kill the process
    - `us1`: `python test-server.py T 8000`
    - `us2`: `python test-client.py T 8000`
    - `us1`: ctrl+C to kill the process
    - `mininet`: ctrl+C to kill `tshark` process
    - exit `mininet`, `us1`, `us2`

- Copy `packetcapture.pcap` to project path

```bash
$ sudo chmod 755 /tmp/packetcapture.pcap 
$ ls -lrt /tmp/packetcapture.pcap
-rwxrwxrwx 1 755 root 19564 Mar 19 01:57 /tmp/packetcapture.pcap
$ cp /tmp/packetcapture.pcap $PROJECT_PATH # replace with the path
```

- (Optional) Use git and github for version control

- Use `wireshark` to examine the packet information

```
$ sudo wireshark
```

Then File -> Open, choose the `packetcapture.pcap` we have generated.

### 4. Firewall Config File Review

In this project, the firewall configuration rules are stated in the `configure.pol` file. The file is like a `csv` file format with each line representing a firewall rule. There are 9 fields in a line of rule,

- RuleNumber: has to be unique numbers and it is not validated in the program
- Action: `Block` or `Allow`, cannot be `-`
- Source MAC: source host MAC addr
- Destination MAC: destination host MAC addr
- Source IP: source host IP addr
- Destination IP: destination host IP addr. For source/dest IP, we have the following hosts/networks defined in `sdn-topology.py`
    - Headquarters Network: Subnet `10.0.0.0/24` for `hq1` to `hq5`
    - US Network: Subnet `10.0.1.0/24` for `us1` to `us5`
    - India Network: Subnet `10.0.20.0/24` for `in1` to `in5`
    - China Network: Subnet `10.0.30.0/24` for `cn1` to `cn5`
    - UK Network: Subnet `10.0.40.0/24` for `uk1` to `uk5`
- Protocol: protocol number based on [IANA](https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
    - ICMP: `1`
    - TCP: `6`
    - UDP: `17`
- Source Port: source host application port. Only for TCP/UDP
- Destination Port: destination host application port. Only for TCP/UDP
- Comment/Note: extra notes not validated in the program

Let's see two examples,

```
1,Block,-,-,10.0.0.1/32,10.0.1.0/24,6,-,80,Block 10.0.0.1 from accessing a web server on the 10.0.1.0/24 network
```

The first rule basically blocks host `hq1` (IP Address `10.0.0.1/32`) from accessing a web server on any host on the `us` network (the subnet 10.0.1.0/24 network). The web server is running on the TCP IP Protocol (6) and uses TCP Port 80.

```
2,Allow,-,-,10.0.0.1/32,10.0.1.125/32,6,-,80,Allow 10.0.0.1 to access a web server on 10.0.1.125 overriding previous rule
```

The second rule overrides the initial rule to allow `hq1` (IP Address 10.0.0.1/32) to access a web server running on `us5` (IP Address 10.0.1.125/32). The web server is running on the TCP IP Protocol (6) and uses TCP Port 80.

### 5. Basic POX API

Now, let's see how we can implement the firewall with file `sdn-firewall.py`. The code is based on OpenFlow and POX (which is a software for OpenFlow control). As it is provided, we must implement code that does the following steps,

- Create a OpenFlow Flow Modification object `of.ofp_flow_mod()`
- Create a POX Packet Matching object for the rules
    - Set up OpenFlow rules with matching attributes
    - Set up access control with rule's priority
- Create a POX output action to specify what to do with the traffic after it is matched. 

Now, let's view the code in `sdn-firewall.py`. First, we have to comment out `rule = None` and replace it with a flow modificatio object with `of.ofp_flow_mod()`.

The flow modification object is the main object used for this project. This adds a rule to the OpenFlow controller that will affect a modification to the traffic flow based on priority, packet characteristic matchin, and an action that will be done to the traffic that is matched. It is defined in Python [here](https://github.com/noxrepo/pox/blob/gar-experimental/pox/openflow/libopenflow_01.py#L2268) and as follows,

```python
class ofp_flow_mod (ofp_header): 
    def __init__ (self, **kw):
        ofp_header.__init__(self) 
        self.header_type = OFPT_FLOW_MOD 
        if 'match' in kw:
            self.match = None
        else:
            self.match = ofp_match()
        self.priority = OFP_DEFAULT_PRIORITY 
        self.actions = []
```

OpenFlow also defines a matching data structure shown above as `ofp_match()`. This enable us to define a set of headers for the packets to match against. Initially, it will check if there's a `match` string in `kw` to decide whether to create a ofp matching object. Because we are not including string `match` in `kw`, we have to create a match object and attach it to the flow modification object manually by,

```python
rule.match = of.ofp_match()
```

We should also be aware of the following attributes in the ofp matching object,

```
Name           Type              Usage
dl_src         EthAddr           Src MAC Addr
dl_dst         EthAddr           Dst MAC Addr
dl_type        Int               Ethertype / length (e.g. 0x0800=IPv4)
nw_proto       Int               IP protocol (e.g., 6 = TCP) 
nw_src         String/IPAddr     Src IP Addr
nw_dst         String/IPAddr     Dst IP Addr
tp_src         Int               TCP/UDP src application port
tp_dst         Int               TCP/UDP dst application port
```

These attributed can be specified on the match object to specify the rules. For example,

```python
rule.match.tp_src = 5
rule.match.dl_dst = EthAddr("01:02:03:04:05:06")
```

For IP address, there are several ways to specify,

- Easiest: use the string with mask format
```
rule.match.nw_src = "192.168.42.0/24"
```
- Formal: use `IPAddr` type
```
rule.match.nw_src = (IPAddr("192.168.42.0"), 24)
```
- Other: give IP and mask addresses
```
rule.match.nw_src = "192.168.42.0/255.255.255.0"
```

In this project, the string method is recommended because it's the easiest way to do so based on the `configure.pol` file. Note the `policies` variable is actually the return value of `process_configuration()` function defined in file `setup-firewall.py`. It does use a CSV mapper to go through the configuration file `configure.pol` so the original values in property should be `string` type.

Note that in this project, we need to assume all traffic is IPv4 and it's acceptable to hardcode `0x0800` for `dl_type` as we have mentioned above.

### 6. Access Control

In the POX modification object `ofp_flow_mod()`, there's another attribute defined as `priority`. It is initialized as value `OFP_DEFAULT_PRIORITY`.

In this case, there should be two priorities – one for `ALLOW` and one for `BLOCK`. Separate them sufficiently
to override any exact matching behavior that the POX controller implements). 

It is suggested the `BLOCK` priority be 0 or 1 and the `ALLOW` priority above 10000. 

### 7. OpenFlow Actions

There's another attribute in OpenFlow modification object `ofp_flow_mod.actions`. With this, we can define what we want to do for a port after it is matched to a rule. 

To make an action, we have to append an `ofp_action_output` object to the `actions` list. The `ofp_action_output` object has the following structure,

```python
class ofp_action_output (object): 
    def __init__ (self, **kw):
        self.port = None
```

Here the `port` attribute of this class is the integer output port for the matching packet. Its value could be an actual physical switch port number or one of the
following virtual ports expressed as constants,

- `of.OFPP_IN_PORT`: Send back to input switch port
- `of.OFPP_NORMAL`:  Process via normal L2/L3 legacy switch configuration 
- `of.OFPP_FLOOD`: Output to all OpenFlow ports except the input port with flooding enable
- `of.OFPP_ALL`: Output to all OpenFlow ports except the input port
- `of.OFPP_CONTROLLER`: Send to the OpenFlow controller

Here's an example if we redirect the matching packet out to physical switch port number 4,

```python
rule.actions.append(of.ofp_action_output(port=4))
```

### 8. `sdn-firewall.py` Test

At project root directory, copy `sdn-firewall.py` to `test-suite/extra`. Then go to `test-suite/extra`. Change all the files to executable.

```bash
$ cp sdn-firewall.py test-suite/extra/
$ cd test-suite/extra/
$ chmod -R 777 .
```

Open two terminal, 

- One run `$ ./start-firewall.sh configure.pol`
- Thr other run `$ sudo python test_all.py`

A success test should show `Passed 15 / 15`.

### 9. Firewall Rules

As we discussed, we also need a CSV-format file `configure.pol` to create firewall policies. Here's the tasks we have when creating this firewall. 

Note that for the specific IP address of each host, we can go to file `sdn-topology.py` to check them out.

Also note that we should not use `0.0.0.0/0` to address for world due to the restrictions placed on the implementation by POX. Match arbitrary traffic from anywhere on the network with a `-` instead.

What's more, don't overblock.

- **TASK 1 - DNS**: On the headquarters network, there are two active DNS servers,
    - `hq1` provides DNS service to the public, which allows TCP/UDP connects from world at port `853`
    - `hq2` provides private DNS service only to 5 corporate networks (us, cn, in, uk, hq). So only hosts in corporate networks can TCP/UDP connect to `hq2` at port `853`
        - `hq2` blocks the world from TCP/UDP access at 853
        - `hq2` allows corp TCP access at 853
        - `hq2` allows corp UDP access at 853

- **TASK 2 - VPN**: On the headquarters network, `hq3` acts as a VPN server
    - `hq3` blocks the world from TCP/UDP access at 1194
    - `hq3` allows TCP access at 1194 from us3, uk3, in3, and cn3
    - `hq3` allows UDP access at 1194 from us3, uk3, in3, and cn3

- **TASK 3 - ICMP**: hosts except for the ones in headquarters are not pingable from the world
    - US, UK, IN, and CN networks are not reachable by ICMP from the world
    - All corporate hosts can receive a complete ping from any headquarter hosts

- **TASK 4 - VNC**: for remote desktop and VNC purposes
    - Block the world from TCP access to port 3389 and port 5900
    - All corporate hosts can TCP connect to headquarter network at port 3389 and port 5900

- **TASK 5 - Webserver**: block corporate hosts for sensitive financial information
    - Server `us3` and `us4` should block TCP access from uk2, uk3, uk4, uk5, in4, in5, us5, and hq5 at port 8510
    - Note that we should use CIDR notations to make the rules simple. We may use the smallest subnet mask that handles the listed hosts using CIDR notation. We can also use this [IP to bin converter](https://www.browserling.com/tools/ip-to-bin) to make your life easier.

### 10. `configure.pol` Tests

First, clean up the minimap we created through,

```bash
$ sudo ./cleanup.sh
```

At project root directory, copy `sdn-firewall.py` and `configure.pol` to `test-suite`. Then go to `test-suite`. Change all the files to executable.

```bash
$ cp sdn-firewall.py test-suite
$ cp configure.pol test-suite
$ cd test-suite
$ chmod -R 777 .
```

Open two terminal, 

- One run `$ ./start-firewall.sh configure.pol`
- Thr other run `$ sudo python test_all.py`

A success test should show `Passed 100 / 100`.

### 11. Submission 

Go to the git root directory where you implement the code.

```bash
$ zip gtusr_sdn.zip packetcapture.pcap configure.pol sdn-firewall.py
```
