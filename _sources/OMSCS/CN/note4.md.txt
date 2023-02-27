# Computer Network 4 | Introduction to Routing, Link State, Distance Vector, RIP, OSPF, Hot Potato Routing

### 1. Introduction to Routing

#### (1) Forwarding

By **forwarding** we refer to transferring a packet from an incoming link to an outgoing link within a single router. The router is responsible to consult a **forwarding table** and then to determine the outgoinglink interface within a single router.

#### (2) Routing

By **routing** we refer to how routers work together using routing protocols to determine the good paths (or good routes as we call them) over which the packets travel from the source to the destination node.

#### (3) Intradomain Routing Vs. Interdomain Routing

When we have routers that belong to the same administrative domain we refer to the routing that takes place as **intradomain routing**.

But when the routers belong to different administrative domains, we refer to **interdomain routing**.

### 2. Intradomain Routing Algorithms

#### (1) Introduction to Intradomain Routing Algorithms

There are two major class of the intradomain routing algorithms,

- Link State: OSPF and IS-IS
- Distance Vector: ARPANET and RIP

In those algorithms, we represent each router as a **node** and a link between two routers as an **edge**. Each edge is associated with a cost.

#### (2) Link-State Routing: Dijkstra’s algorithm

Dijkstra’s algorithm is designed to solve the problem of finding the least cost path when the link costs and the network topology are known to all the nodes. 

In the link-state routing protocol, we have the following terminologies,

- `u`: the source node or the first-hop router
- `v`: every rest of the nodes in the network
- `D[v]`: the cost of the current least cost path from the source to the node `v`
- `p[v]`: the previous node to go in the network
- `N`: the set of all the nodes in the network
- `N_`: a subset of `N`

Here's the pseudocode of the Dijkstra’s algorithm,

```
function dijkstra(u, N):

    # Initialization
    
    D = {}
    p = {}
    N_ = [u]
    for each v:
        if v is a neighbor of u:
            D[v] = Cost(u, v)
            p[v] = u
        else:
            D[v] = inf
            
    # Iterations
    
    While N_ != N:
        
        for each w in N and w not in N_:
            find w with least D[w]
        
        add w to N_
        
        for each v in N and v not in N_:
            if v is a neighbor of w:
                D[v] = min(D[v], D[W] + Cost(v, w))
                p[v] = w
                
    return D, p
```

Now, let's use an example to see how it works. Suppose we have the following cost function with 6 nodes `u/v/w/x/y/z`,

```
function Cost(a, b):

    if a == b:
        return 0
        
    if a, b == u, v and b, a == u, v:
        return 2
    elif a, b == u, w and b, a == u, w:
        return 5
    elif a, b == v, w and b, a == v, w:
        return 3
    elif a, b == w, z and b, a == w, z:
        return 5
    elif a, b == u, x and b, a == u, x:
        return 1
    elif a, b == v, x and b, a == v, x:
        return 2
    elif a, b == x, w and b, a == x, w:
        return 3
    elif a, b == x, y and b, a == x, y:
        return 1
    elif a, b == w, y and b, a == w, y:
        return 1
    elif a, b == y, z and b, a == y, z:
        return 2
    else:
        print "Not neighbor"
        return inf
```

Then if the source node is `u`, let's see how Dijkstra’s algorithm works. 

- After initialization, 

```
D = { v: 2,
      w: 5, 
      x: 1,
      y: inf,
      z: inf }
      
p = { v: u,
      w: u, 
      x: u }
      
N_ = [u]
```

- In the first iteration, we select the next node `x` because `D[x]` is the least cost path. So,

```
D = { v: 2,
      w: 4, 
      x: 1,
      y: 2,
      z: inf }
      
p = { v: u,
      w: x, 
      x: u,
      y: x }
      
N_ = [u, x]
```

- In the 2nd iteration, we can choose either `v` or `y` as the next node. Here we just choose `y` as the next node and you will get the same final result if you choose `v` in this step.

```
D = { v: 2,
      w: 3, 
      x: 1,
      y: 2,
      z: 4 }
      
p = { v: u,
      w: y, 
      x: u,
      y: x,
      z: y }
      
N_ = [u, x, y]
```

- In the 3rd iteration, will select `v` because `D[v]` is now the least and `v` is not in `N_`,

```
D = { v: 2,
      w: 3, 
      x: 1,
      y: 2,
      z: 4 }
      
p = { v: u,
      w: y, 
      x: u,
      y: x,
      z: y }
      
N_ = [u, x, y, v]
```

- Finally, in the last iteration, we select the last node `z` and put it into the set `N_`. Now we are able to break the loop and return `D` and `p` as our result. So,

```
D = { v: 2,
      w: 3, 
      x: 1,
      y: 2,
      z: 4 }
      
p = { v: u,
      w: y, 
      x: u,
      y: x,
      z: y }
```

Let's finally see how we can find a shortest path from two nodes. Suppose the source is node `u` and the destination is node `z`. Then the path is,

```
u -> p[p[p[z]]] -> p[p[z]] -> p[z] -> z
```

So,

```
u -> x -> w -> y -> z
```

And the total distance is,

```
D[z] = 4
```

#### (3) Link-State Routing Algorithm Computational Complexity

In the worst case, each node is a neighbor of the others so we have to search every rest of the nodes in each iteration. In this case, suppose we have `n` nodes,

```
Total iterations = n + (n - 1) + ... + 1
                 = n(n + 1) / 2
                 = O(n^2)
```

#### (4) Distance Vector Routing: Bellman Ford Algorithm

Bellman Ford algorithm is used to solve the shortest path problem when the nodes are not awared of the whole network topology. It has the following properties,

- iterative: it keeps iterating until the neighbors do not have new updates sent
- asynchronous: does not require the nodes to be synchronized with each other
- distributed: the routing calculations are not happening in a centralized manner

In the distance vector routing protocol, we have the following terminologies,

- `x`: the current node or the node we look into
- `v`: every rest of the nodes in the network
- `Dx[v]`: the cost of the current least cost path from the current node to the node `v`. `Dx` is called the **distance vector** of node `x`.
- `N`: the set of all the nodes in the network

So the pseudocode for this algorithm is,

```
function bellmanford(x, N):
    
    # Initialization
    for each node y in N except for x:
        Dx(y) = Cost(x, y)
        
    for each neighbor w of x:
        Dw(x) = inf
        send(Dx, w)    # send distance vector Dx to w
        
    # Iterations
    while True:
        
        if (no distance vectors received from neighbors) and (no change on the Cost function):
            continue
            
        else:
            for each y in N except for x:
                update Dx(y) = min{Cost(x, v) + Dv(y)}
        
            if Dx changed:
                for each neighbor w of x:
                    send(Dx, w)
```

Then let's see a simliar example to the one above. Suppose we have the cost function the same as,

```
function Cost(a, b):
    
    if a == b:
        return 0
    
    if a, b == u, v and b, a == u, v:
        return 2
    elif a, b == u, w and b, a == u, w:
        return 5
    elif a, b == v, w and b, a == v, w:
        return 3
    elif a, b == w, z and b, a == w, z:
        return 5
    elif a, b == u, x and b, a == u, x:
        return 1
    elif a, b == v, x and b, a == v, x:
        return 2
    elif a, b == x, w and b, a == x, w:
        return 3
    elif a, b == x, y and b, a == x, y:
        return 1
    elif a, b == w, y and b, a == w, y:
        return 1
    elif a, b == y, z and b, a == y, z:
        return 2
    else:
        print "Not neighbor"
        return inf
```

Suppose `u` is the current node we look into. Then after initialization, we will have,

```
Du = {
    u: 0,
    v: 2,
    w: 5,
    x: 1,
    y: inf,
    z: inf
}

D_others = {
    u: inf,
    v: inf,
    w: inf,
    x: inf,
    y: inf,
    z: inf
}
```

Node `u` sends `Du` to its neoghbors and it will also receive the initial distance vector `Dv`, `Dw`, and `Dx` from its neighbor `v`, `w`, and `x`. So in the first iteration, the node `u` has the following information,

```
Du = {
    u: 0,
    v: 2,
    w: 5,
    x: 1,
    y: inf,
    z: inf
}

Dv = {
    u: 2,
    v: 0,
    w: 3,
    x: 2,
    y: inf,
    z: inf
}

Dw = {
    u: 5,
    v: 3,
    w: 0,
    x: 3,
    y: 1,
    z: 5
}

Dx = {
    u: 1,
    v: 2,
    w: 3,
    x: 0,
    y: 1,
    z: inf
}

D_others = {
    u: inf,
    v: inf,
    w: inf,
    x: inf,
    y: inf,
    z: inf
}
```

Then in the first iteration, `Du` will be updated by `Du(y) = min{Du(v) + Dv(y)}` based on `Dv`, `Dw`, and `Dx`. So,

```
Du[u] = 0
Du[v] = min{Cost(u, u) + Du[v], 
            Cost(u, v) + Dv[v],
            Cost(u, w) + Dw[v],
            Cost(u, x) + Dx[v],
            Cost(u, y) + Dy[v],
            Cost(u, z) + Dz[v]
            } = min{2, 2, 8, 3, inf, inf} = 2
Du[w] = min{Cost(u, u) + Du[w], 
            Cost(u, v) + Dv[w],
            Cost(u, w) + Dw[w],
            Cost(u, x) + Dx[w],
            Cost(u, y) + Dy[w],
            Cost(u, z) + Dz[wx
            } = min{5, 5, 5, 4, inf, inf} = 4
Du[x] = min{Cost(u, u) + Du[x], 
            Cost(u, v) + Dv[x],
            Cost(u, w) + Dw[x],
            Cost(u, x) + Dx[x],
            Cost(u, y) + Dy[x],
            Cost(u, z) + Dz[x]
            } = min{1, 4, 8, 1, inf, inf} = 1
Du[y] = min{Cost(u, u) + Du[y], 
            Cost(u, v) + Dv[y],
            Cost(u, w) + Dw[y],
            Cost(u, x) + Dx[y],
            Cost(u, y) + Dy[y],
            Cost(u, z) + Dz[y]
            } = min{inf, inf, 6, 2, inf, inf} = 2
Du[z] = min{Cost(u, u) + Du[z], 
            Cost(u, v) + Dv[z],
            Cost(u, w) + Dw[z],
            Cost(u, x) + Dx[z],
            Cost(u, y) + Dy[z],
            Cost(u, z) + Dz[z]
            } = min{inf, inf, 10, inf, inf, inf} = 10
```

Therefore, after the first iteration, `Du` will be,

```
Du = {
    u: 0,
    v: 2,
    w: 4,
    x: 1,
    y: 2,
    z: 10
}
```

Then node `u` will send this distance vector `Du` to all its neighbors.

The other iterations will continue the process like this whenever it receives an updated distance vector from its neighbor. As time goes by, `Du` will converge to the least cost of paths.

#### (5) Link Cost Decrease in DV Routing

Now, let's see how the change in link costs impacts the DV routing. Let's first look into a single link cost decreasement.

After the `Cost()` function change, the node link to that edge will detect it and its distance vector will be update to the new decreased value. 

Let's see an example. Suppose we have the following cost function,

```
function Cost(a, b):

    if a == b:
        return 0
    
    if a, b == x, y or b, a == x, y:
        return 4
    elif a, b == y, z or b, a == y, z:
        return 1
    elif a, b == x, z or b, a == x, z:
        return 50
    else:
        return inf
```

Then at the balance point, we have,

```
Dx = [0, 4, 5]
Dy = [4, 0, 1]
Dz = [5, 1, 0]
```

When there's a sudden decrease of the cost of edge `x - y` from `4` to `1`, then,

- Update `Dx = [0, min{1, 51}, min{5, 50}] = [0, 1, 5]`
- Update `Dy = [min{1, 6}, 0, min{6, 1}] = [1, 0, 1]`
- Send new `Dx` and `Dy` to neighbors
- When `z` receives `Dx` and `Dy`
    ```
    Dz = [min{50, 2}, min{51, 1}, 0] = [2, 1, 0]
    ```
- When `x` receives `Dy`
    ```
    Dx = [0, min{1, 51}, min{2, 50}] = [0, 1, 2]
    ```
    
In this scenario, we note that the fact that when there was a decrease in the link cost, it propagated quickly among the node as it only took a few iterations.

#### (6) Count-to-Infinity Problem: Link Cost Increase in DV Routing

Let's consider the same example but this time, the cost of edge `x - y` increase from `4` to `60`, then,

Recall initially we have,

```
Dx = [0, 4, 5]
Dy = [4, 0, 1]
Dz = [5, 1, 0]
```

Then,

- Update `Dx = [0, min{60, 51}, min{61, 50}] = [0, 51, 50]`
- Update `Dy = [min{60, 6}, 0, min{65, 1}] = [6, 0, 1]`
- Send new `Dx` and `Dy` to neighbors
- When node `z` gets the update of `Dx` and `Dy`, it will update `Dz` as `Dz = [min{50, 7}, min{1, 101}, 0] = [7, 1, 0]`. After this, `Dz` will be sent to node `x`and `y`.
- **Bouncing stage**: node `y` and node `z` will keep updating each other until `Dy = [51, 0, 1]` and `Dz = [50, 1, 0]`

Let's talking about the bouncing stage. In this stage, node `y` thinks the shortest route from `y` to `x` is,

```
y -> z -> x
```

While node `z` thinks the shortest route from `z` to `x` is,

```
z -> y -> x
```

So a packet sent from `y` or `z` to `x` will not reach the destionation because there's a loop in the route and the packet keeps bouncing between `y` and `z`. Therefore, we can expect a delay of packets because,

```
z <-> y
```

So how long is the delay? While for `Dy = [6, 0, 1]` to `Dy = [51, 0, 1]`, it takes `45` iterations and for `Dz = [5, 1, 0]` to `Dz = [50, 1, 0]`, it also takes `45` iterations. 

This is called the **count-to-infinity** problem.

#### (7) Poison Reverse 

Let's now see how we can solve the count-to-infinity problem. Suppose we are at the bouncing stage and there's a packet sent from node `y` to node `x` through node `z` because it thinks the shortest path is,

```
y -> z -> x
```

When this packet arrives at `z`, the node `z` knows the following information,

```
source: y
destination: x
least cost path: z -> y -> x
```

So now node `z` will notice that this packet came from `y` and the least cost path of it to `x` goes through `y`. This means if `z` follows the path, it will never get the packet delievered to `x`. 

Therefore, while forwarding the packet back to `y`, `z` also advertises `y` a lie that `Dz[x] = inf` even through `z` knows that `Dz[x] = 5`. Since it tells this lie to `y`, `y` acknowledges that `z` has no path to `x` expect via `y`. So it will never send packets to `x` via `z`. And we call it the node `z` **poisons** the path from `z` to `y`.

This technique will solve the problem with 2 nodes, however poisoned reverse will not solve a general count to infinity problem involving 3 or more nodes that are not directly connected.

### 3. Routing Algorithm Applications

#### (1) DV Routing Application: Router Information Protocol (RIP)


RIP is a routing protocol based on the distance vector protocol. The first version of it is released as a part of the BSD version of UNIX and it uses hop count as a metric.

As distance verctor shows, the messages are exchanged between router neighbors periodically using a RIP response called **RIP advertisements**. It contain the information about the sender distance to destination subnets as follows,

```
nextRouter       distSubnet       numOfHops
A                w                2
B                y                2
B                z                7
```

For a node `C` with the topology,

```
C ---2---> A ---> w
|
+ ---2---> B --- 5 ----> D ---> z
           |
           + ---> y
```

#### (2) Link-State Routing Application: Open Shortest Path First (OSPF)

OSPF is introduced as an advanced of the RIP Protocol, operating in upper-tier ISPs because the link-state protocol requires a full map of topology. Here's a briefing of the OSPF protocol.

- Areas: an OSPF autonomous system (aka. AS, meaning a large network with single routing protocol) can be configured to areas where its own OSPF is operaing
- Border routers: one or more border routers are responsible for routing packets outside the area
- Backbone area: exactly one OSPF area in the AS is configured to be the backbone area. It always contains all area border routers in the AS and it is responsible to route traffic between the other areas.
- Link State Advertisements (LSA): Every router within a domain uses LSAs. It is used for building a database called Link State Database containing all the link states. LSAs are typically flooded to every router in the domain and this helps form a consistent network topology view. 
- LSA refresh rate: OSPF has a default 30-minute refresh rate. If a link states changed before this period is reached, the neighbor routers connected will ensure the LSA flooding.

Next, let's see how a router process an OSPF message. 

- Trigger: the LS-update packet which contain LSAs reach the current router's OSPF
- Database update: a consistent view of the topology is being formed and this information is stored in the link-state database on the router
- SPF: Using the information from the database, the current router calculates the shortest path using shortest path first (SPF) algorithm. The result of this step is fed to the** Forwarding Information Base (FIB)**
- Forwarding: when a data packet arrives at an interface card of the current router, the next hop for the packet is decided based on the FIB of the last step

#### (3) Hot Potato Routing

Compared to RIP and OSPF, there's another routing protocol considering the routing speed over finding the most efficient (shortest) path. This is called the **hot potato routing**. 

Hot potato routing is a technique of choosing a path within the network by choosing the **closest** egress point based on intradomain path cost (aka. Interior Gateway Protocol (IGP) cost) even if the overall path is not optimized. 

Hot potato routing is commonly used for applications that cares more about speed or in a relatively simple network. For example,

- real-time communication
- high-frequency trading
- CDNs
- cloud computing
