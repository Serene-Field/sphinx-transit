# Computer Network 5 | Distance Vector Implementation

### 1. Project Documentation

The current project is similar to the last one we ran.

`run_topo.py`

The simple driver that triggers the simulation and write the logs. 

- `open_log`: function defined in `helpers` package used to load a file for logging purpose
- `Topology`: define a class of `Topology` which contains a collection of `Node`s
- `topo.run_topo()`: triggers the simulation
- `finish_log`: function defined in `helpers` to end the logging

-----

`SimpleTopo.txt`, `SimpleNegativeCycleTopo.txt`, `BadTopo.txt`, `SingleLoopTopo.txt`, `ComplexTopo.txt`

The topology files containing the map information. Note that `BadTopo.txt` is a topology that defined with node `A` link to an nonexistent node `z`. It should give an error message.

-----

`Neighbor`

A simple class defined in `Node.py` with a neighbor node and a path cost.

- `name`: neighbor node name
- `weight`: the path cost

-----

`Node`

`Node` is a class defined in `Node.py` used to store the node information.

- `name`: node/router name
- `incoming_links`: list of `Neighbor` objects of incoming node name and cost
- `outgoing_links`: list of `Neighbor` objects of outgoing node name and cost
- `neighbor_names`: list of incoming link node names
- `topology`: a backlink to the `Topology` object and it should not be used in the implementation
- `messages`: list of messages defined by user
- `A.send_msg(msg, B)`: send the message `msg` to the node `B` from `A`
- `B.queue_msg(msg)`: called when other nodes sends message `msg` to `B`. It contains a simple attend function that will add the message to a list.

Note that `DistanceVector` class is based on this class.

-----

`Topology`

A class defined by `Topology.py` used to store the topology map.

- `topodict`: a dictionary with each node as the field mapping to its `incoming_links` and `outgoing_links`. It contains `DistanceVector` objects. 
- `nodes`: a list version of `topodict`

-----

`helpers.py`

A helper package that contains several useful functions. 

- `open_log(filename)`: function called in `run_topo.py` to open a log file `filename`. Variables `logfile` and `current_logs` are set to zeros. It also initialize the `current_logs` as an empty dictionary.
- `finish_log()`: close the global `logfile` variable
- `add_entry(switch, logstring)`: add `switch: logstring` entry to `current_logs`
- `finish_round()`: This is the function called in `Topology.py` and it is used to write all the entries in the `current_logs` to the `logfile` with a alphabet order of field names. It will seperate each round with string `"-----\n"` and clear the `current_logs`

### 2. Assistant File

`Makefile`

This file can be used to simplify the testing process. 

```bash
#Makefile

clean:
	rm -rf ./*.log

run: clean
	./run.sh SimpleTopo 2>/dev/null | grep -i 'invalid\|complete'
	./run.sh SimpleNegativeCycleTopo 2>/dev/null | grep -i 'invalid\|complete'
	./run.sh BadTopo 2>/dev/null | grep -i 'invalid\|complete'
	./run.sh SingleLoopTopo 2>/dev/null | grep -i 'invalid\|complete'
	./run.sh ComplexTopo 2>/dev/null | grep -i 'invalid\|complete'
	rm -rf __pycache__
```

### 3. `Message` Class

We should define a `Message` class or other data types but it should have the following information.

- `name`: source node to forward from
- `distVector`: the distance vector of the source node

### 4. `DistanceVector` Class

`DistanceVector` is a given class based on class `Node` and it should add a mapping variable called `distVector` which keeps track of the distance vector information. it should be initialized with itself as the field and 0 cost as a value.

### 5. `send_initial_messages` Function

`send_initial_messages` is relatively simple. It is used to send the initial message to all the incoming links (say, neighboring routers) at the beginning. `Node.send_msg(Message, str)` function should be called and the implementation of this message queue is a FIFO data structure. 

Note that when passing the `distVector` in `Message`, make sure it is copyed with its current value so a future change won't effect its value.

### 6. `log_distances` Function

`log_distances` is used to output the current `distVector` in a easy-reading way. For example, it should have the pattern like `A:A0,B1,C2` based on `{A: 0, B: 1, C: 2}` and its implementation should be very easy.

### 7. `process_BF` Function

`process_BF` is actually a impletation of Bellman-Ford algorithm and it must accomplish the two tasks,

1. Process queued messages 
2. Send neighbors sendMessage distance

The second task is like `send_initial_messages` with the new message so let's consider the first task. This is a pseudocode for implementing this task,

```
Loop through all messages:
    Loop through all nodes in message.distVector:
    
        Skip current node
        
        Calculate the cost from x -> s
        - Cost(x, v)
        - Dv(s)
        - dist* = Cost(x, v) + Dv(s)
        
        1 For new nodes in distVector
        1-1 if node is a neighbor
            update with Cost(x, s)
        1-2 if node is not a neighbor
            update with dist*
        
        2 For existing nodes in distVector
        2-1 if Cost(x, v) or Dv(s) is smaller than -99, then dist* will be -99 no matter the other value
        2-2 if Cost(x, v) + Dv(s) < -99, then dist* will be -99
        2-3 if Cost(x, v) + Dv(s) > -99 but smaller than Dv(s), should also update
```
