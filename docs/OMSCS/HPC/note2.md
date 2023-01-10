# High Performance Computing 2 | Algorithmic Time: Energy and Power

### 1. Speed and Time

#### (1) Speed Trend

As a part of Danny Hillis' thesis, let's consider a processor that can execute about 100 billion operations per second (`100 Giga ops/s`) in the best case and this is called the peak throughput today. Let's also assume that this performance doubled in every 2 years and now let's consider how fast a processor will be in 10 years.

The answer is about 3 Tera ops/s. It can be calculated through,

```
100 Giga ops/s * 2 ^ (10 / 2) = 3200 Gops/s = 3.2 Tops/s
```

#### (2) Speed Limits

And we should also think about the speed limits. Suppose we have a 2D mesh of physical processors which has many cores that firs on a physical die of a certain size of `l by l`. 

Also, in this mesh, each core is connected to its 8 nearest neighbours like the following plot and this means each processing unit can communite along its diagonal routes.

```
          |        |       |
      --- * ------ * ----- * ---
          |   \    |    /  |
          |    \   |   /   |
      --- * ------ * ----- * ---
          |    /   |   \   |
          |   /    |    \  |
      --- * ------ * ----- * ---
          |        |       |
```

If a single operation defines as to start from at the processsing unit at the center and the operation then travels as a signal to a unit at one of the corners, it then goes back and make it a round trip. If we want to do 3 Tops/s (also `3*10^12 ops/s`) sequentially, then what is the upper bound of `l` that we can have? Assuming the light speed is 3*10^8 m/s.

To solve this problem, let's have the following calculation. Suppose we execute 1 operation and the distance it should travel is a round trip of the half diagonal, so,

```
d = sqrt(2) l / 2 * 2 = sqrt(2) l
```

The light speed is the fastest speed we can achieve, so

```
d / t <= c
```

And the time we have here should be the time of executing 1 operation under the current performance,

```
t = 1 / P
```

So we have,

```
dP <= c
```

Then,

```
sqrt(2)lP <= c
```

So,

```
l <= c/(sqrt(2)P) = 7e-5 m = 70 µm
```

#### (3) Recall: Machine Balance

Let's recall what we have discussed in the last lesson. We have,

- Computational Cost: `T_comp = τW`
- Transfer Cost: `T_mem = ɑLQ`

where τ is related to the processor and it means the processor can process `τ` operations per second. And `ɑ` is the rate of transfering the data between the slow and fast memory, and it means we can have `ɑ` words transferred in a time unit. 

Then the machine balance is defined by,

```
B = τ / ɑ
```

And it has a unit of operations per word.

#### (4) Computational Cost and Transistor Density

The cost of this computation τ is related to the transistor density, which is defined by the number of transistors that can fit in a given amount of space. In the last 40 years, the transistors that can be fitted in a given area has increased by a factor about a million. The performance of computation density doubles roughly every `1.9` years.

#### (5) Transfer Cost and Stream

Similar to the transistor density, there's also a benchmark called steam that measures the growth of transfer cost. Statistically, it shows that the `ɑ` has essentially doubled once every `2.9` years.

#### (6) Machine Balance Doubling Time

Now, let's do some calculations based on the information we have. Suppose we have `τ` doubled in 1.9 years and `ɑ` doubled in 2.9 years. Then how many years do we need if we want to double the machine balance `B`?

To solve this question, let's first assume that we can get `B` doubled in `t` years. Then 

```
(τ2^(T/1.9)) / (ɑ2^(T/2.9)) = 2B = 2τ/ɑ
```

So,

```
τ/ɑ * 2^(T/1.9 - T/2.9) = 2τ/ɑ
```

So,

```
2^(T/1.9 - T/2.9) = 2
```

Therefore,

```
T/1.9 - T/2.9 = 1
```

Times 1.9 * 2.9 on both sides, then,

```
T = 1.9 * 2.9 = 5.51
```

#### (7) Machine Balance Principle

In the case above, we can confirm that the rate of improvement in computation far outstrips the rate of improvement in communication. So for an algorithm, it may be better to trade off more computation with less communication. 

Suppose we have the following notations,

- Work: W = W(n) = total ops
- Span/Critical Path Length: D = D(n) = critical ops
- Processing Cores on Processor: P
- Theoritical Transactions: Q = Q(n;Z,L)

And we will also assume W includes the count of Q, so

- Q <= W

Let's also assume that each core can execute some number of operations per unit time `R_0` (note that R here is simliar to `τ`), and each transaction initiates a data transfer across the `L` wires in parallel and the time it takes to go across a wire is `β_0`.

Recall that because both `R_0` and `β_0` are dependent to the machine, we usually ignore these costs while calculating W, Q, and D, and this is called the **unit cost** because we are assuming unit cost operations. However, in the HPC setting, we have to take `R_0` and `β_0` into consideration for the **real cost** to see what they imply for the overall system.

To transfer a model of unit cost to real cost, we can account for non-unit const by transforming a unit cost DAG to a non-unit cost DAG. Suppose this node is one of the compute operations and executing it cost `1/R_0` time units as follows,

```
       cost: 1/R_0
           ↓
... -----> * ------> ....
           \
            ...
```

Then we can replace this single unit cost node with a sequence of `1/R_0` unit-cost vertices,

```
           | ------ 1/R_0 nodes ------- |
           |                            |
        cost: 1  cost: 1    cost: 1  cost: 1
           ↓        ↓          ↓        ↓
... -----> * -----> * --...--> * -----> * ------> ....
                                      \
                                       ...
```

Next, let's also say that the words of the memory transaction can be in flat corrently with compute operations. In terms of DAGs, there's additional set of `L/β_0` fully concurrent nodes.

```
       cost: 1/R_0
           ↓
... ------> * ------> ....   ---+
    |               |           |
... +-----> * ------+ ....      |
    |               |           |
           ...             L/β_0 nodes
    |               |           |
... +-----> * ------+ ....      |
    |               |           |
... +-----> * ------+ ....   ---+
```

So now let's consider the best case execution time for this DAG. We have the following calcuations,

- **Usual work** only scaled by processor speed: `W/(PR_0)`
- **Span locks** only scaled by processor speed: `D/R_0`

There's also one extra cost to do the communications so for each transaction, we have to pay for the `L/β_0` nodes. So,

- **Communication cost**: `QL/β_0`

Because these times are fully overlapped in the best case, then we have the best case execution time as,

```
T_p >= max(W/(PR_0), D/R_0, QL/β_0)
```

Assume we have done a good job of designing the algorithm, the critical path should be short. So,

```
D << W / P
```

Therefore, 

```
D/R_0 << W/(PR_0)
```

So,

```
T_p >= max(W/(PR_0), QL/β_0)
```

So in this case, when the right hand side is minimized, that means we need to have `W/(PR_0) = QL/β_0`. But to think about the historical growth rate trend, if we want to benefit from transistor scaling, then we need the compute time to dominate the communication time. This is what we called the **principle of balance**.

```
W/(PR_0) >= QL/β_0
```

#### (8) Algorithm Goal and System Goal

We can also write this inequation as follows,

```
W/Q >= R_0/β_0 * PL
```

So this inequation indicates that on the algorithm side, we should make the left side `W/Q` **as large as possible** because the right side is subject to inevitable scaling trends that cause it to grow over time. On the system side, the goal is to try to keep `R_0/β_0 * PL` as small as possible to help the algorithms people out. 

#### (9) Doubling Issue

Now let's see an example. Suppose we have a machine that is perfectly balanced for sorting large arrays. Then how can you maintain balance if the number of cores doubles? Let's assume that for sorting, the best case ratio of `W/Q` should be,

```
W/Q ~ L * log(Z/L)
```

We call `β_0` the bandwith (of the wires) and `R_0` the peak (of the processors). And in this example, we have,

```
log(Z/L) >= R_0/β_0 * P
```

So here are some possible answers,

- Square both the fast memory size `Z` and transaction size `L`

```
log(Z^2/L^2) = 2log(Z/L) >= R_0/β_0 * 2P
```

- Double the bandwidth

```
log(Z/L) >= R_0/(2β_0) * 2P = R_0/β_0 * P
```

### 2. Power

#### (1) Definition of Power

Power is defined by the energy consumed in the unit time,

```
P = E / T
```

Because increasing the clock frequency makes the power consumption skyrocket, that's why we use multicores.

#### (2) Components of Power

The power of a computing system has two parts, 

```
P = P_0 + ΔP
```

where `P_0` is the constant power (or static power or idle power), which is what you pay just to keep the system on. `ΔP` is the dynamic power and that is what you pay beyond the constant power when the program is running.

#### (3) Dynamic Power Equation

Now let's suppose we have a gate and `C` is the capacitance of this gate and `V` is the supply voltage. Then the energy consumed by this gate while switching is,

```
E = CV^2
```

The **frequency** or the **clock rate** `f` of this circuit is the maximum number of cycles per unit time. However, the gate doesn't necessarily switch on every cycle and it might happen only once ever few cycles. So **activity factor** `a` is the number of switches per cycle (<= 1). 

Then taken together, these parameters tell us how to compute dynamic power.

```
ΔP = CV^2 * f * a
```

Before moving on, there's one more quick fact about this. The clock rate `f` and the supply voltage `V` need to be kept in proportion to one another. And this is necessary to maintaining the stability and reliability of the circuit.

```
f ∝ V
```

Note that `V`, `f`, and `a` are all changable by systems or algorithms. `V` and `f` can be changed through dynamic voltage and frequency scaling (DVFS, or cpufreq for Linux). `a` can be improved by turning of the chunks we don't necessary need.

#### (4) DVFS Example

Suppose we have two systems A and B, and 

- Energy: E_B = 2 E_A
- Time: T_B = 1/3 T_A

Now if we use DVFS to rescale B so that it's power matches A. So,

```
P_B = E_B / T_B = 2 E_A / (1/3 T_A) = 6 P_A
```

For,

```
P ∝ f^3
```

So,

```
f_B = 6^(1/3) f_A
```

Also,

```
T ∝ 1/f
```

So,

```
T_B' / T_A = f_A / f_B = 1 / 6^(1/3) < 1
```

So 

```
T_B' < T_A
```

Therefore, B is still faster than A.

#### (5) Metrics We Have

To measure different energies, now we have several metrics. 

- Total work: `W = W(n)`
- Span: `D = D(n)`
- Average available Parallelism: `W/D`
- Time for `P` processors: `max(D, W/P) <= T_P <= D + (W-D)/P`
- Self-speedup: `S_P = T_1 / T_P` which means time on a single-core processor devided by time on a processor with `P` cores

#### (6) Best Metric for Energy

The best metric for energy is the work `W` because energy is paied for each operation,

```
E = eW
```

#### (7) Best Metric for Dynamic Power

The best metric for the dynamic power if we ignore the constant power and assume constant energy per operation is the **self-speedup**. Let's see why.

The dynamic power should be defined as,

```
Power = Energy / Time
```

And the total energy we need for our algorithm is in proportion to the time we spend on a single-core processor. And the time we spend here is equal to the time we spend on this P-core system. So in this case that we can figure out self-speedup is a good metric.