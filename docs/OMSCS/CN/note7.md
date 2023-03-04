# Computer Network 7｜Implement MiniNet

The following instructions is based on MacOS with Apple silicon chip (M1/M2). The used VM software is VMware and Virtual Code Studio is required.

### 1. VM Setup

- Register on VMware
- Download: VMware Fusion Player 13 – Personal Use (VMware Fusion 13.0.1 (for Intel-based and Apple silicon Macs) https://customerconnect.vmware.com/en/evalcenter?p=fusion-player-personal-13
- Select personal use for a free license
- Download from one of the following links for the latest VM image
    - [Dropbox Link](https://www.dropbox.com/s/tv894lhg851pzxv/cs6250-f22-vmware-arm.vmwarevm.zip?dl=0)
    - [Onedrive Link](https://gtvault-my.sharepoint.com/personal/jrandow3_gatech_edu/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fjrandow3%5Fgatech%5Fedu%2FDocuments%2FVM%2DImages%2Fcs6250%2Df22%2Dvmware%2Darm%2Evmwarevm%2Ezip&parent=%2Fpersonal%2Fjrandow3%5Fgatech%5Fedu%2FDocuments%2FVM%2DImages&ga=1)
- Run image with the VMware installed

### 2. Basic Test

- Login to VM with the following information:
    - username: mininet
    - password: mininet
- Then open a QTerminal (terminal emulator) window for testing
```bash
$ sudo su -      # for root permission
[sudo] password for mininet: mininet
```
- Finally, test mininet installed
```bash
% mn
*** Creating network
...
exit
```

### 3. IDE Setup 

- Open VSCode with Remote-SSH extension
- Go to VM terminal and check for the ip address. Check the IP address (`inet`) under `ens160`. For me, it is `192.168.80.129`.
```bash
$ ifconfig
ens160:
    ...
    inet ...
    ...
```
- Connect to the host -> add a new host, then enter the following command
```
ssh mininet@192.168.80.129
```
- Use the default config and connect. Enter the password `mininet` when required.
- Wait to be connected. Then we can use VSCode to edit.

### 4. Mininet Introduction

- Github Source: https://github.com/mininet/mininet
- Offical webpage: https://mininet.org/
- Beginner Guide: http://mininet.org/walkthrough/#interact-with-hosts-and-switches

Here are some common commands,

- `help` – shows all commands
- `nodes` – displays all nodes including the controller c0
- `net` – displays all nodes and links in an extended format
- `links` – brief display of links
- `dump` – displays full network information
- `$mn –c` cleans the Mininet environment after topology runs.

### 5. Useful Sources

- Network topology visualizer for `complextopo.py` and `datacenter.py` (will discuss later): http://demo.spear.narmox.com/app/?apiurl=demo#!/mininet

### 6. Project Setup

- Make `Assignment` directory
```bash
$ mkdir /home/mininet/Assignments
```
- Then use VSCode to go into this folder and copy the starter code from unzipping `SimulatingNetworks.zip` downloaded from Canvas
- Go to the folder
```bash
$ cd /home/mininet/Assignments/SimulatingNetworks
```
- Time to start!

Note: you can also setup git/github for your working directory before you start.

### 7. Part 2 - Modifications

If you can successfully execute the program `topology.sh`, feel free to skip the following discussions.

Because I downloaded the VM image through the first link and it is not perfect, we have to make some change when we are running Part 2.

Inside the `SimulatingNetworks` folder, change the permission by,

```bash
$ chmod -R 755 ./topology.sh
```

Also install `bwn-ng` by,

```bash
$ apt-get install bwm-ng
```

Then bypass the `cgroups` issue by adding the following line in `/etc/fstab`,

```
cgroup /sys/fs/cgroup cgroup defaults,blkio,net_cls,freezer,devices,cpuacct,cpu,cpuset,memory,clone_children 0 0
```

Also, add the following line in `/etc/default/grub`,

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet cgroup_enable=memory,namespace systemd.unified_cgroup_hierarchy=0" 
```

Then update `grub` with,

```bash
$ update-grub
```

And reboot the VM,

```bash
$ reboot
```

Once back, rerun `./topology.sh` then we are able to execute. However, after a couple seconds, we will receive a `matplotlib` error. 

Then we add the following line at the top of the `util/helper.py` file

```bash
#! sh/bin/env python
```

And we should also install `matplotlib` by,

```bash
$ pip3 install matplotlib
```

After this, if we run `./topology.sh` again, it will pass without any further errors.

### 8. Part 2

After running `./topology.sh`, we generate the following two figures in the output folder,

- cwnd: shows a TCP cubic pattern
- bandwidth: shows a rate of about 10 Mbps

![](https://i.imgur.com/GKZjWnu.png)

The topology here we used is defined in `mntopo.py` with 2 hosts, 2 links, and 1 switch. 

![](https://i.imgur.com/qWrxGyf.png)

**Task 1**: Modify the `mntopo.py` so that it represent the following topology. Rerun `./topology.sh` to get the result. Remember to clean the mininet files by `mn -c`.

![](https://i.imgur.com/RkdykBa.png)

After execution, we have a similar because our topology map doesn't have much difference.

![](https://i.imgur.com/MZu70DT.png)

Next, let's test the latency of the current topo. First let's run `python ./ping.py` for the initial bench mark as,

```bash
$ python ./ping.py
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=19.4 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=9.55 ms
64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=8.70 ms
64 bytes from 10.0.0.1: icmp_seq=4 ttl=64 time=8.85 ms
64 bytes from 10.0.0.1: icmp_seq=5 ttl=64 time=8.82 ms

--- 10.0.0.1 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4006ms
rtt min/avg/max/mdev = 8.697/11.063/19.389/4.173 ms
```

**Task 2**: Modify `linkConfig.delay` in `mntopo.py` to `10ms`, then rerun `python ./ping.py` to compare the result.

The possible result is,

```bash
$ python ./ping.py
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=166 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=85.5 ms
64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=81.7 ms
64 bytes from 10.0.0.1: icmp_seq=4 ttl=64 time=81.8 ms
64 bytes from 10.0.0.1: icmp_seq=5 ttl=64 time=81.5 ms

--- 10.0.0.1 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4007ms
rtt min/avg/max/mdev = 81.537/99.397/166.426/33.546 ms
```

Here we say see pings just a bit over 80 ms compared with 10 ms initially.

**Task 3**: Adjust bandwidth `linkConfig.bw` to `50` Mbps per second. Rerun `./topology.sh` to get the result. Remember to clean the mininet files by `mn -c`.

The result should be,

![](https://i.imgur.com/kYBwybE.png)

**Task 4**: Create a new topology representing a more complicated network topology in `complextopo.py`.

![](https://i.imgur.com/LoSELH1.png)

The parameters should be set as follows,

- Ethernet: Bandwidth 25 Mbps, Delay 2 ms, and loss rate 0% 
- WiFi: Bandwidth 10 Mbps, Delay 6 ms, and loss rate 3%
- 3G: Bandwidth 3 Mbps, Delay 10 ms, and loss rate 8%

Also, do not specify ports (use the default ones) in this task.

### 9. Part 3

Now that we have implemented `complextopo.py` so it's the right time to test it out. We run `cli.py` to start the simulation.

```
$ python ./cli.py
```

After Mininet loads the complex topology, you should see the Mininet command prompt: `mininet>`.

Then we can test the following command,

```
mininet> h1 ping h2 -c 10
```

This means to let `h1` to ping `h2` for 10 times. If everything works well, we can expect something like,

```
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=1087 ms
64 bytes from 10.0.0.2: icmp_seq=2 ttl=64 time=57.8 ms
64 bytes from 10.0.0.2: icmp_seq=3 ttl=64 time=27.7 ms
64 bytes from 10.0.0.2: icmp_seq=4 ttl=64 time=26.9 ms
64 bytes from 10.0.0.2: icmp_seq=5 ttl=64 time=25.1 ms
64 bytes from 10.0.0.2: icmp_seq=6 ttl=64 time=25.8 ms
64 bytes from 10.0.0.2: icmp_seq=7 ttl=64 time=26.2 ms
64 bytes from 10.0.0.2: icmp_seq=8 ttl=64 time=25.2 ms
64 bytes from 10.0.0.2: icmp_seq=9 ttl=64 time=25.1 ms
64 bytes from 10.0.0.2: icmp_seq=10 ttl=64 time=25.4 ms

--- 10.0.0.2 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9039ms
rtt min/avg/max/mdev = 25.064/135.192/1086.846/317.361 ms, pipe 2
```

**Task 1**: Test ping from `h1` to `h2` and `h3` for 100 times each. Compare the difference of the results.

- h1 to h2: delay 20 ms with 4% packet loss
- h1 to h3: delay 30 ms with 10% packet loss

This follows the topology we have built.

**Tasl 2**: Use `mininet> pingall` to ping between each pair of hosts. 

If success, we should expect something like,

```
mininet> pingall
...
h1 -> h2 h3
h2 -> h1 h3
h3 -> h1 h2
*** Results: 0% dropped (6/6 received)
```

Note that there can be `X` in the result meaning the one link is not pingable. If this happens, please rerun `pingall` to confirm.

### 10. Part 4

In this part, we are going to implement a fan-in style data center. It has three layers of switch,

- `tls`: top-level switch
- `mls`: mid-level switches
- `rs`: rack switches, these connct to the hosts

The network should have the following two arguments,

- `fi`: fin-in rate, wich is the ratio of,
    - the # of mls / the # of tls
    - the # of rs / the # of mls
- `n`: number of hosts connected to each rack switch

For example,

![](https://i.imgur.com/Uyhi8lw.png)

The code should be implemented based on `datacenter.py` using loops. And the naming conventions should follow,

- tls: tls1
- mls: mls1, mls2, to mlsfi
- rs: s1x1, s1x2... to sfixfi 
- hosts: h1x1x1, h1x1x2, to hfixfixn

For testing, we can run,

```bash
$ python datacenter.py --fi 2 --n 5
```

Then run `pingall` when we are in the Mininet prompt. We can expect this result if everything works well.

![](https://i.imgur.com/GyuJIaa.png)

### 11. Submission 

To submit, use the following command to zip the file.

```bash
$ zip -r <gtid>_sn.zip . -x '.*' -x '__MACOSX' 
```

