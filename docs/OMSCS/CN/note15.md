# Computer Network 15 ｜ BGP Hijacking Project

### 1. BGP Hijacking Demo

![](https://i.imgur.com/XOACdZk.png)

```bash
$ sudo pip install --upgrade pip
$ sudo pip install termcolor
```

Then for the file `bgp.py`, replace line 87 of,

```python
routers.append(self.addSwitch('R4'))
```

to,

```python
self.addSwitch('R4')
```

Open a second terminal, we will use this terminal to start a remote session with AS1’s routing daemon,

```bash
$ ./connect.sh
```

Then enter the password for the VM and the quagga password `en` to access the administration shell and R1 routing table. When we get the prompt `bgpd-R1>`, type in the command `sh ip bgp` for the BGP table

```
bgpd-R1> sh ip bgp
BGP table version is 3, local router ID is 9.0.0.1, vrf id 0
Default local pref 100, local AS 1
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 11.0.0.0/8       0.0.0.0                  0         32768 i
*> 12.0.0.0/8       9.0.0.2                  0             0 2 i
*> 13.0.0.0/8       9.0.0.2                                0 2 3 i

Displayed  3 routes and 3 total paths
```

To test a BGP hijacking process, open a third terminal  to setup a web server in AS3,

```bash
$ ./website.sh
```

Then open a fourth terminal to start a rogue AS (AS4) connecting directly to AS1 and advertising the same 13.0.0.0/8 prefix.

```bash
$ ./start_rogue.sh
```

To stop the attack, we can use the following command in the fourth terminal,

```bash
$ ./stop_rogue.sh
```

### 2. Code Architecture

- `Zebra` is a multi-server routing software which provides TCP/IP based routing protocols. `Zebra` has been decommissioned and `Quagga` is the latest fork
- `bgpd` is a routing component that works with the Quagga routing engine.
    - `-f`: set the bgpd config file
    - `-d`: runs in daemon mode, forking and exiting from tty
    - `-i`: the pid-file path where process identifier is written to 

----

`getIP()`

- Given a host name `h1-1`, map it to `11.0.1.1/24`.
- Given a host name `h2-1`, map it to `12.0.1.1/24`.
- Given a host name `h1-2`, map it to `11.0.2.1/24`.
 
----

`getGateway()`

- Given a host name `h1-1`, map it to `1.0.1.254`.
- Given a host name `h2-1`, map it to `2.0.1.254`.
- Given a host name `h1-2`, map it to `1.0.2.254`.

----

`startWebserver()`

Execute `webserver.py` with message `text` on a given node. This function is called twice with different messages,

- 1) on the legit webserver
- 2) on the malicious webserver

----

`webserver.py`

This is a script for starting a TCP webserver on a node at port 80. It takes one argument `--text` as the message in the `h1` tag. By default, the message is `Default web server`.

----

`connect.sh`

- `${parameter:-word}`:  If `parameter` is unset or null, the expansion of `word` is substituted. Otherwise, the value of `parameter` is substituted.

----

`run.py`

A simple run script used to execute a command in a node.

- `sudo python run.py --node R1 --cmd "telnet localhost bgpd"`, the command used in `connect.sh` to login to `R1` router

----

`website.sh`

A loop script curls from the webserver every second. It can be used to check if the current webserver is normal or malicious. 

----

`start_rouge.sh`

The script executes `run.py` for the rogue AS.

----

`stop_rouge.sh`

The script kills the rogue AS by command `pkill -f --signal 9 ...`.

### 3. System Design

In this project, we have to modify the BGP hijacking demo above to mock the following network.

![](https://i.imgur.com/YY9wH5o.png)

Here we have 6 ASes. AS5 is the webserver and AS6 should be the rouge AS that will perform BGP hijacking. All the ASes advertise single prefix,

- AS1: 11.0.0.0/8
- AS2: 12.0.0.0/8
- AS3: 13.0.0.0/8
- AS4: 14.0.0.0/8
- AS5: 15.0.0.0/8
- AS6: 11.0.0.0/8 

To design the network, we should keep the neighbour `eth` ports under the same subnet so they can communicate. A helpful network graph `fig2_topo.pdf` should be created before the implementation so that we are able to align the edges.

### 4. Implementation

To complete this project, we have to modify the following files,

- config files under `conf/`
- `bgp.py`
- `connect.sh`
- `website.sh`
- `start_rogue.sh`
- `stop_rogue.sh`

Note the `self.addLink`, the `zebra` configurations, and the `eth` definitions should be in the same order for building the proper network.
