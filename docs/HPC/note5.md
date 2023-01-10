# High Performance Computing 5 | Work Span Model

### 1. Basic Concepts

#### (1) Dynamic Multithreading Models

The dynamic multithreading models are consisted of two parts,

- computation can be represented by a DAG
- pseudocode notation which will be defined when we execute one of these algorithms, it generates a computational DAG 

In this lesson we will focusing on how to create the DAGs instead of how to map these DAGs to cores or execute them.

#### (2) Multithreading DAGs

In a DAG, each node is an operation and the edges are dependencies. We should also assume that there will be only one starting vertex and one exit vertex, or we should add one starting vertex or/and one exit vertex to make things simple in some cases.

When an operation is ready to go (means it has no dependencies), then we can execute it on any of the available cores. 

#### (3) Scheduling 

At every step of the computation, the problem of how to take free units of work and assign them to processors is called a scheduling problem. 

#### (4) DAG Example: Sequential Reduction

Let's suppose we have the following pseudocode,

```
let A = array(n)
s = 0
for i = i to n do:
    s += A[i]
```

So in the DAG, there should be two nodes in each iteration,

- `Load A[i]`
- `Add`

There will also be an edge between them because the Add can not start if we did not load the `A[i]`. However, the loads of `A[i]`s have no dependencies but the add operation in each iteration relies on the load of `A[i]` and the add operation in the last iteration. 

However, there should be dependence goes from the last add operation to the current load operation. This is because the loop is being executed in sequential and we have what is called the control dependency. But for now let's ignore these dependencies. 

Thus, the time PRAM takes to execute this DAG with `p` processors should be,

```
Tp(n) >= ceil(n/p) + n
```

So the time should be,

```
Tp(n) >= n
```

This result matches our intuition.

#### (5) DAG Example 2: Btree Reduction

For a binary tree reduction, the time PRAM takes to execute this DAG with `p` processors assuming `p >= n` in one level would be,

```
Tp(n,l) = O(1)
```

And because there are `logn` levels, then,

```
Tp(n) = O(logn)
```

Here because the tree layout generates more parallism, we may choose it as a better algorithm.

#### (6) Work and Span

- Work (note as `W(n)`): how many vertices does it have in total
- Span (note as `D(n)`): how many vertices on the longest path

The longest path is also called the cirtical path.

#### (7) Processors and W/S

Now suppose we have only one processor `p = 1`, then the total time we spend is only based on how many work we have. So,

```
T_1(n) = W(n)
```

However, when we have infinite processors `p = ∞`, the time is actually depending on the longest path we have in the DAG so,

```
T_inf(n) = D(n)
```

#### (8) Average Available Parallelism

The ratio of `W` by `D` measures the amount of work per critical path vertex. So,

```
Avg. Para = W(n) / D(n)
```

This is useful because `W/D` shows the number of processors we need in a PRAM model and it shows the average busy processors we have for a DAG.

#### (9) The Span Law

Because the span is the workload when the program is fully parallel, then we can know the span should be the lower bound of the time to execute,

```
Tp(n) >= D(n)
```

#### (10) The Work Law

When there's no critical path, the lower bound of the time should be evenly seperate the work onto `p` processors so that,

```
Tp(n) >= ceil(W(n)/p)
```

This is called the work law.

#### (11) Work-Span Law

Because both of the laws above holds, we can have the following work-span law,

```
Tp(n) >= max{D(n), ceil(W(n)/p)}
```

#### (12) Phases

Before we continue, let's see some rules to divide a DAG to some phases. 

- Each phase should have 1 critical path vertex
- Non critical path vertices in each phase are independent
- Every vertex must appear in some phase

Under this definition, we have the time for execution on phase `k` should be,

```
t_k = ceil(W_k / p)
```

And because the time in each phase sums up to the total time we need, then,

```
Tp = SUM{k=1~D}(t_k) = SUM{k=1~D}(ceil(W_k / p))
```

#### (12) Brent's Theorem on the Upper Bound

Now assume we know the fact that,

```
ceil(a/b) = floor((a-1)/b) + 1
```

Then the equation above can be written to,

```
Tp = SUM{k=1~D}(t_k) = SUM{k=1~D}(floor((W_k - 1) / p) + 1)
```

Because,

```
floor(x) <= x
```

Then we have,

```
Tp <= SUM{k=1~D}((W_k - 1) / p + 1)
```

As a result we have,

```
Tp <= (W - D) / P + D
```

And this is the upper bound we would love to see.

#### (13) Meanings of the Brent's Theorem

From Brent's theorem, we can find out that the time to execute a DAG is no more than the time to execute the critical path plus to execute the everything off the critical path using `p` processors.

Note that the Brent's theorem is a upper bound and it is usually slack in the real cases.

#### (14) Speedup

The speedup measures how good a DAG is and it is defined as the ratio of the best sequential time over the parallel time. "best" means we don't choose a terrible sequence as our benchmark.

```
Speedup = best sequential time / parallel time
        = T'(n) / Tp(n)
        = W(n) / Tp(n)
```

Idealy, we want the time to be `p` times faster then the best sequential algorithm called the ideal speedup,

```
Sp(n) = Θ(p)
```

Now, let's pug in the Brent's theorem and then the lower bound of speedup we have here is,

```
Sp(n) >= W' / ((W - D) / P + D)
```

This is also,

```
Sp(n) >= P / (W/W' + (p-1)/(W'/D))
```

This means that if we want to achieve to the speedup goal of `P`, we have to pay a penality which is `W/W' + (p-1)/(W'/D)`. And in the best case, we want the denominator to be constant,

```
W/W' + (P-1)/(W'/D) = O(1)
```

#### (15) Work Optimality

To achieve,

```
W/W' + (P-1)/(W'/D) = O(1)
```

The first thing is to make,

```
W/W' = O(1)
```

So the work of the parallel slgorithm has to match to the best sequential algorithm so,

```
W = W'
```

#### (16) Weak Scalability

Second we need to have,

```
(P-1)/(W'/D) = O(1)
```

So,

```
P = O(W'/D)
```

This is also,

```
W'/P = Ω(D)
```

This means the work per processor has to grow proportional to the span. And because the span depends on the problem size `n`, so work per processor should grow as some function of `n`. This is called weak scalability.

#### (17) Concurrency Primitive 1: Spawn and Sync

- Spawn: the target of a spawn keyword is either a function call or a procedure call and it is a signal to the runtime or compiler that the target is an independent unit of work
- Sync: the sync keywork means that's a dependence of the the current operation 

Here are some notes,

- Sync matches any spawn in the same frame
- There's always an implicit sync before returning to the caller

#### (18) Application of Spawn and Sync Framework

The good thing of spawn-sync is that we can almost do exactly the same thing for a sequential model or a work-span model.

- for the work, we just count spawns and syncs as 1 so that it will be the sames as analyzing a sequential work
- for the span, the span in a frame depends only on the spawn that has the longest path.

#### (19) Work-Optimality Low-Span

As a parallel algorithm designer, one of the goals is to achieve "Work-Optimality Low-Span", this means that we have,

```
W(n) = W'(n)
```

As well as a polylogarithmic span

```
D(n) = O(log^k(n))
```

This is motivated because `W/D = O(n/log^k(n))` which grows with n and close to linearly

#### (20) Concurrency Primitive 2: parfor

`parfor` before a loop means a for loop with iterations that can be executed without dependencies. A `parfor` will create a implicit sync that will join after the loop.

- Work: O(n)
- Span: O(1) in theory

In fact the `parfor` is either implemented linearly or logarithmic and we should assume `parfor` uses logarithmic implementation from now on.

#### (21) Data Race

Data race means at least one read and at least one write may happen at the same memory location at the same time.

