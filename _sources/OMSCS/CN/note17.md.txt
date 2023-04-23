# Computer Network 17 | BGP Measurement Project

### 1. BGPStream

[BGPStream](https://bgpstream.caida.org/) is an open-source python package that can be used for live and historical BGP data analysis. It can be installed through,

```bash
$ pip install pybgpstream
```

In this project we will be using the python environment in the virtual machine so `pybgpstream` is already installed. 

To gather BGP information using BGPStream, we have to use an object called Route Collectors (or `collecter`s). he code for accessing a collector or set of collectors directly usually looks like this,

```Python
stream = pybgpstream.BGPStream(
    record_type="updates",
    from_time="2017-07-07 00:00:00",
    until_time="2017-07-07 00:10:00 UTC",
    collectors=["route-views.sg", "route-views.eqix"],
    filter="peer 11666 and prefix more 210.180.0.0/16"
)
```

In this project, we will use only the historical data so there's no need to specify the collector. We can easily set up and configure streams with,

```Python
stream = pybgpstream.BGPStream(data_interface="singlefile")
stream.set_data_interface_option("singlefile", type, fpath)
```

Where,

- `type` should be either `"rib-file"` or `"upd-file"`
- `fpath` is a string representing the path to a specific cache file

### 2. Update File and RIB File

In this project, we have two types of cached files with BGP data. Let's read some example cache files. Before trying to run `bgpreader` , `ldconfig` command should be used to create the necessary links to the installed package on the VM,

```bash
$ sudo ldconfig
```

Then we can view an update file `./rrc04/update_files/ris.rrc04.updates.1609476900.300.cache` through,

```bash
$ bgpreader -e --data-interface singlefile --data-interface-option \
    upd-file=./rrc04/update_files/ris.rrc04.updates.1609476900.300.cache \
    --filter 'ipv 4'
```

Select one line from the result as,

```
update|A|1499385779.000000|routeviews|route-views.eqix|None|None|11666|206.126.236.24|210.180.224.0/19|206.126.236.24|11666 3356 3786|11666:1000 3356:3 3356:2003 3356:575 3786:0 3356:22 11666:1002 3356:666 3356:86|None|None
```

In the record, the “|” character separates different fields. We also have,

- type `A`: stands for Advertisement
- advertised prefix: `210.180.224.0/19`
- AS path: `11666 3356 3786`
- original AS: `3786`, the last ASID in the AS path

For Routing Information Base (RIB) files, we can also use the `bgpreader` tool to read a cached file,

```bash
$ bgpreader -e --data-interface singlefile --data-interface-option \
    rib-file=./rrc04/rib_files/ris.rrc04.ribs.1262332740.120.cache \
    --filter 'ipv 4'
```

In the result, consecutive “|” characters indicate fields without data.

```
R|R|1445306400.000000|routeviews|route- views.sfmix|||32354|206.197.187.5|1.0.0.0/24|206.197.187.5|3235 4 15169|15169|||
```

### 3. Project Restrictions

- Don't import `os` or `pathlib`. This is because Gradescope does not mirror the directory layout from the provided files. Use the values from `cache_files` parameter instead.
- Do not pull your own data. Use the cache files locate the directory within this project. 

### 4. Rubics

Only `bgpm.py` is required to submitted to Gradescope.

- Task 1A (10pts)
- Task 1B (10pts)
- Task 1C (10pts)
- Task 2 (30pts)
- Task 3 (20pts)
- Task 4 (20pts)

### 5. Task 1A

Generally, task 1 will measure BGP routing table growth so we can assume the input files are RIB files.

Complete function `unique_prefixes_by_snapshot`. This function is used to measure the number of **unique** advertised prefixes over time.

Each input file in `cache_files` is an annual snapshot and it's already chronologically sorted. It should return a list containing the number of unique IP prefixes for each input file like `[2, 5]`.

`stream` is a list of BGP record elements `elem` with each element represents one BGP record. Here are some useful queries,

- Get the prefix: `pfx = elem.fields["prefix"]`
- Get AS path: `ASPath = elem.fields["as-path"].split(" ")`
- Get the origin AS: `origin = elem.fields["as-path"].split(" ")[-1]`

After implementation, run the script `check_solution.py` for verification. Also git the implemented resolution.

### 6. Task 1B

Let's now calculate the number of unique ASes over time. We should take all the ASes in the AS path into account. 

Note that the AS path can have corner case like `25152 2914 18687 {7829,14265}`. In this case we should count `{7829,14265}` as only 1 ASes.

There's also another edge case when ASpath is empty. We have to skip these cases in the loop.

Because we have tested the Task 1A, before testing we can comment out the line `(TASK_1A, unique_prefixes_by_snapshot, "rib_files")` so that we will skip the check process for task 1A.

### 7. Task 2

We'll skip task 1c for now because it's not easy to implement. 

The idea is to get the shortest path length for each origin AS in each RIB cached file (or called a "snapshot"). The returned vaule should be a dictionary with ASIDs as fields and lists of shortest path length as values. For example, 

```
{"455": [4, 0, 3], "533": [0, 1, 2]}
```
 
 There are also some corner cases,
 
 - if origin AS not in a snapshot, the corresponding shortest path length should be 0
 - if there's a set of ASes for the origin AS, the set is counted as one unique AS
 - The ASes in the set is considered a different AS
 - filter out all paths of length 1

`defaultdict` can be used in this task to simplify the procedure. Also, `tqdm` can be used to track the iterating process. Note that `tqdm` doesn't come with the VM so we have to `pip` install it.

### 8. Task 3

In this task, we will focus on the AW events of the update files. An AW event is defined as the event that a prefix gets Advertised (A) and then Withdrawn (W). This matters because this information propagates and affects the volume of the associated BGP traffic.

There are two types of withdraws in the AW events,

- explicit withdrawals: a prefix is advertised with an announcement and is then withdrawn
- implicit withdrawals: a prefix is advertised and then re-advertised with different BGP attributes

In this task, we will only consider the explicit withdrawals. The duration of an AW event is considered to be the time slot between the last A and first W for a specific prefix. 

The returned dictionary should be a dictionary where each key is a peerIP, and each value equals another dictionary where the field is prefix and the value is a list of explicit AW event durations. For example,

```
{
    "192.65.185.137": {
        "185.202.130.0/24": [
            30.0,
            20.0
        ]
    }
}
```

Note that prefix is not necessary in every update record so we have to use `._maybe_field("prefix")` method instead of `.fields["prefix"]`

```
pfx = elem._maybe_field("prefix")
```

Some other queries are useful in this task,

- update peer address: `elem.peer_address`
- update time: `elem.time`
- update type (`A` or `W`): `elem.type`

There are two general tips we should take care of,

- We should assume the records across snapshots are seamless. This means an `A` record for the last snapshot can impact the next `W` record
- Make sure we considered `A` and `W` records with both the same peer IP and the same prefix. The durations across different peer IPs or prefixes would be meaningless

### 9. Task 4

Task 4 is to measure the duration of Real-Time BlackHoling (RTBH) events. It's very similar to the task 3 and we will start the explaination from the definition of a RTBH event.

In this task we will still examine the update files. for a given peerIP/prefix pair is the time elapsed between the last (A)nnouncement of the peerIP/prefix that is tagged with an RTBH community value and the first (W)ithdrawal of the peerIP/prefix.

The solution of this task can be modified based on the solution of task 3.

Note the blackholing tag for the community should be ending with `:666` and we should check it through `._maybe_field('communities')` because `communities` is not a necessary field.

```
community = elem._maybe_field('communities')
```

In this task, there are some extra corner cases,

- Given the stream A1 A2 A3(RTBH) A4 A5 W1 W2 for a specific peerIP/prefix pair, the announcement A3(RTBH) followed by A4 is an implicit withdrawal. There is no explicit withdrawal and, thus, no RTBH event.
- Check carefully about the case that `community` is an empty set. If this happens, the loop for checking blackholing tag `:666` would quite and cause some edge cases.

### 10. Task 1C

In the end, let's implement the task 1C. We will compute the top 10 origin ASes ordered by percentage increase (smallest to largest) of advertised prefixes.

The percentage change for number of prefixes of an origin AS between two snapshots is defined by,

```
# of prefixes for origin in snapshot1 / # of prefixes for origin in snapshot2 - 1
```

In this task, we will consider the total unique prefixes change which means we should identify the first and the last snapshot where the origin AS appeared and calculate the change between them.

Therefore, for each AS we have to conduct the following steps,

- Count the number of unique prefixes for each snapshot
- Filter out the snapshots with 0 prefix
- Calculate the total percentage change for each origin
- Report the top 10 origins

Here are some tips for debugging,

- There can be a tied result but a simple `sorted` function would give the correct order
- Don't use data structures like `[set()]*num` because the specific pointer to `set()` will be copied and all values in the list would be the same.

### 11. Other Tips

- Make sure you remove all the packets not in the environment, for example, `tqdm` before you submit
