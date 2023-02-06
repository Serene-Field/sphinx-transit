# Computer Network 3 | Spanning Tree Protocol Implementation

### 1. Project Documentation

`run.py`

The entry of the program. It will take one argument `topology_file` which is the file name of the map file without `.py`.

```
$ python run.py <topology_file>
```

The control flow in this program is,

```
Topology.__init__ 
-> Topology.run_spanning_tree()
-> Topology.log_spanning_tree()
```

-----

`Sample.py`, `NoLoopTopo.py`, `SimpleLoopTopo.py`, `TailTopo.py`, `ComplexLoopTopo.py`

The topology files containing the map information.

-----

`Message.py`

The message to communicate by Spanning Tree Protocol. For example, you will create and send messages in Switch.py by declaring a message `msg` as,

```python
msg = Message(claimedRoot, distanceToRoot, originID, destinationID, pathThrough)
```

-----

`StpSwitch.py`

Definition of a base of `Switch` class. This file contains abstractions of sending messages and verifying topologies.

-----

`Topology.py`

`Topology.py` is the actual program that connects `run.py` and `Switch.py`. It initiates with the topo map `topology_file`.

- `Topology.send_message()`: This function is used to send messages between switches within the given topo map. It has been wrapped into `StpSwitch.send_message` function and because `Switch` class is based on `StpSwitch`, we can directly call `self.send_message` within the `Switch` class.

- `Topology.run_spanning_tree()`: The entry point of starting the spanning tree protocol. It first sends the initial messages from **each node** by invoking `send_intial_messages()`. Afterward, each message is delivered to the destination switch, where `process_message()` is invoked to generate the spanning tree.

- `log_spanning_tree()`: This is for generating the pretty output at the end of simulation. It invokes the `generate_logstring()` function for each node and put the result together.


### 2. Assistant File

`Makefile`

This file can be used to simplify the testing process. 

```bash
#Makefile

clean:
	rm -rf ./*.log

run: clean
	python run.py Sample
	python run.py NoLoopTopo
	python run.py SimpleLoopTopo
	python run.py TailTopo
	python run.py ComplexLoopTopo

test: run
	diff ./Sample.log ./Logs/Sample.log
	diff ./NoLoopTopo.log ./Logs/NoLoopTopo.log
	diff ./SimpleLoopTopo.log ./Logs/SimpleLoopTopo.log
	diff ./TailTopo.log ./Logs/TailTopo.log
	diff ./ComplexLoopTopo.log ./Logs/ComplexLoopTopo.log
```

### 3. The Goal of This Project

Let's use the simple single loop topology `SimpleLoopTopology` as an example to see our goal of this project.

Initially we have the topo map as,

```python
topo = { 1 : [2, 3], 
         2 : [1, 4],
         3 : [1, 4], 
         4 : [2, 3] }
```

In this loop, we have the following edges,

```
1 - 2, 1 - 3
2 - 1, 2 - 4
3 - 1, 3 - 4
4 - 2, 4 - 3
```

However, if we comfirm all these edges, we will create loop in this topo map so some of the packets will never get to the ends. In order to cancel the loops, we have to prun some edges or we have to select only some of the edges. In this example, we can cut any of the edges, for example, `3 - 4` so there will be no loop any more. 

```
1 - 2, 1 - 3
2 - 1, 2 - 4
3 - 1
4 - 2
```

In fact, the final edges we have are `1 - 2`, `1 - 3`, and `2 - 4`. Note that in the final output, the number of edges must be a multiple of 2 because all edges are round-way.

### 4. Implement `generate_logstring`

`generate_logstring` is the smiplest task among all the functions. Based on the description, it will be called after we have the spanning tree represented by a list called `ActiveLinks`.

So now our task is to create a list of strings with all the strings represent the activated links from the current node to another node.

The following script can be used for testing,

```
s1 = Switch(1, None, [])
s1.activeLinks = [2, 3, 4]
assert s1.generate_logstring() == "1 - 2, 1 - 3, 1 - 4"
```

### 5. Revisit `Message.py` and `StpSwitch.py`

Now let's review what variables we have for a `Message` and a based `Switch`.

For a `Message` class, we have,

- `root`: the SwitchID thought to be the original root
- `distance`: distance from current switch to the root
- `origin`: the SwitchID for message sender
- `destination`: the SwitchID for message receiver
- `pathThrough`: indicating the path to the claimed root from the origin passes through the destination

For a based `Switch` we have,

- `switchID`: ID of the current switch
- `topology`: `Topology` object containing the map. However, it should not read the map information in the object. The only thing helps in this case is the `topology.send_message` function. 
- `links`: direct neighbours the current switch can go

Based on `send_initial_messages`, we can know that initially, each switch will treat itself as the root and send initial messages to all its neighbours by,

```python
for destinationID in self.links:
    self.send_message(
        Message(self.switchID, 0, self.switchID, destinationID, False)
    )
```

### 6. Switch Data Structure

Now we have put the list `activateLinks` into the `Switch` data structure, we should consider what else do we need to complete it. From the document we are awared that we need to have,

- `root`: a variable to store the switch ID that this switch sees as the root
- `distance`: a variable to store the distance to the switch’s root
- `pathThroughLink`: a variable to keep track of which neighbor it goes through to get to the root because for a spanning tree, a switch should onlu go through one neighbor, if any, to go to the root

### 7. Message Process

When a message comes to a switch, it has to process the message with the following steps,

#### (1) Whether to activate the link

- If the message have `pathThrough == True`, the link in the message should be activated
- If the message have `pathThrough == False`, and the current switch don't path through the switch where the message came from, the link in the message should be inactivated

#### (2) Whether to update `root`

- The switch should update the `root` stored in its data structure if it receives a message with a lower claimed `root` value
- Update related other fields in the data structure
- Send new messages to neighbors for sync
    - When sending message, `pathThrough` should only be `True` if `destinationID` equals to the `pathThroughLink` that goes through the claimed root

#### (3) Whether to update `distance`

- The switch should update the `distance` stored in its data structure if it receives a message with the same claimed `root` value but a lower `distance` compared to the `current distance - 1`
- Update related other fields in the data structure
- Send new messages to neighbors for sync

#### (4) Whether to update `pathThroughLink`

- The switch should update the `pathThroughLink` stored in its data structure if it receives a message with the same claimed `root` value and the same `distance`, but with a lower `pathThroughLink`
- Update related other fields in the data structure
- Send new messages to neighbors for sync

### 7. Local Test

```bash
$ make test
$ make clean
```