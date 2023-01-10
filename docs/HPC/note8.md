# High Performance Computing 8 | Parallel on Trees

### 1. Tree Basics

#### (1) Parents Array Representation

The parent array representation of a tree is to store the parent node index into the array. For the root, it will have no parent node so the value would be NULL.

For example, suppose we have the following tree,

```
               3
             /   \
           2       8
                 /   \
               1       5
             /
           6
         /  \
        7    4
```

Then its parent array representation is,

```
P = [8, 3, NULL, 6, 8, 1, 6, 3]
```

#### (2) Finding Root by Parents Array Representation

To find the root of a tree in the parent array representation, we can looply get the parent node until we find a node that has no parent node. This is a very easy sequential solution,

So the pseudo code should be,

```
function root(P[n]):
    if n < 1 then return NULL
    Start from a random node and assign to `node`
    while P[node] != NULL do:
        node = P[node]
    return node
```

The running time of this algo is O(n) because in the worst case we have a very unbalanced tree - linked list.

#### (3) Finding Root Parallely

Now we have seen a sequential algo, and let's think about how to implement a parallel algo. The idea is to explore from all the nodes simultaneously and at each node, change the parent to its grand parent until all the nodes have one signal ancestor node.

Let's see the pseudocode,

```
// k is a node
function hasGrandParent(k, P[n]):
    return k != NULL && P[k] != NULL && P[P[k]] != NULL

funtion adopt(P[n], G[n]):
    parfor i = 1 to n do:
         if hasGrandParent(i, P[n]) then:
             G[i] = P[P[i]]
         else:
             G[i] = P[i]
             
function root(P[n], R[n]):
    P_cur[n] = P[:]
    P_next[n] = empty buffer
    
    // Maximum depth of a tree should be logn
    for l = 1 to ceil(logn) do:   
        adopt(P_cur[n], P_next[n])
        P_cur[:] = P_next[:]
        
    R[:] = P_cur[:]
    return R
```

Here are some properties of this idea,

- Idea uses pointer jumping: `G[i] = P[P[i]]`
- Not work optimal: because we find n roots
- Polylogarithmic Span: outer loop has `ceil(logn)` and `adopt` is polylogarithmic
- Work on forest, no on one tree because the procedure will make every node pointing to its own tree

#### (4) Recall: Wyllie's algorithm

Remember we have a linked list ranking problem and we use Wyllie's algorithm. It assigns the value of head to 0 and the rest to 1s so that we can use prefix sum (add scan) to parallely calculating the ranks. 

The cost of this algorithm is,

- W(n) = O(n logn)
- D(n) = O(logn)

So here although the span is polylogarithmic, the work is not optimal (should be `O(n)` if optimal).

#### (5) Trick to make Wyllie's algorithm Work Optimal

Now let's see a trick to make Wyllie's algorithm work optimal. Suppose we magically have a way to shrink the list and the output will represent the same list. Then assume we shrink the list to `m` (`m < n`) and then we run Wyllie's algorithm against it. It should have a work of,

```
W_shrinked(m) = O(m logm)
```

Here `m` is chosen as `n/logn`. We don't use `logn` or `sqrt(n)` for `m` because then `m logm` will be asymptotically less than `n`. And we also don't choose `nlogn`, `n`, or `n^2` because then `m logm` will be asymptotically more than `n` and these will be sub-optimal. Therefore, we can choose a `m = n/logn` and shrink the list into smaller lists. Then parallelized computing can be applied to achieve the work optimal.

But how to shrink a list in parallel?

#### (6) Successor Representation of Linked List

We couldn't do a successor representation for a binary tree because a node can have more than one successors. However, we can apply successor representation to the linked list because each node will have at most one successor.

For example, suppose we are given the following linked list,

```
4 -> 2 -> 7 -> 1 -> 3 -> 5 -> 6 -> 8
```

Then a successor array of this linked list would be,

```
N[:] = [3, 7, 5, 2, 6, 8, 1, NULL]
```

#### (7) Independent Set

To shrink a list in parallel, a handy trick is to use something called the **independent set**. The independent set is defined as a subset of the vertices such that any vertex within the set does not also have it's successor in the set.

Based on this definition and the linked list above, we can say that

```
{3, 7, 8} is an independent set
{3, 6, 7, 8} is not an independent set
```

Note that computing an independent set sequentially is super easy. Suppose we start with an empty independent set and then traverse the list from head to tail with skips for every other node, then we cam have a independent set like,

```
I = {4, 7, 3, 6}
```

#### (8) Recall: Postorder Numbering

Let's now recall some basic thing we have learnt from the CS101 about tree, which is the postorder numbering. The pseudocode should be as follows,

```
function postorder(root, V[n], v0):
    v = v0
    for each node C in root.children() do:
        v = postorder(C, V, v) + 1
    V[root] = v
    return v
    
postorder(root, V[n], 0)
```

For example, suppose we are given a tree,

```
                       0
                   /   |   \
                 1     2    3 
             /   |   \
           4     5    6
                    /   \
                  7      8
```

Then the postorder traversal should be,

```
4 5 7 8 6 1 2 3 0
```

#### (9) Recall: Preorder Numbering

Another traversal technique is the preorder traversal. The pseudocode is,

```
function preorder(root, V[n], v0):
    v = v0
    for each node C in root.children() do:
        v = preorder(C, V, v+1)
    V[root] = v
    return v
    
preorder(root, V[n], 0)
```

For the same tree we have above, the preorder traversal should then be,

```
0 1 4 5 6 7 8 2 3
```

### 2. Work Optimal Wyllie's

#### (1) Symmetry Issue in Parallely Generating Independ Set

However, computing an independent set in parallel is a little bit tricker because for any vertex `i` in the list and suppose we are performing a parfor loop. when in one iteration, we don't know whether this vertex goes to the independent set. This problem is caused by symmetry, which means that all nodes look the same. So a simple idea is to find a scheme to break this symmerty.

#### (2) Symmetry Breaking Scheme: Gamble

One way to create a scheme is by gambling. Suppose we filp a coin for each node and each coin should be either a head or a tail. If we have a head for an item, then this assumes that this item should be selected into the independent set.

However, there may be a case that we have two consecutive heads which will put one node and its successor into the independent set. So before we select the element to put in the independent set, we check if there's any double heads in the sequence. And if there's two consecutive heads, we will change filp the prior result to tail as follows,

```
H H                     T H
H T        ---->        H T
T H                     T H
T T                     T T
```

So the pseudocode of this scheme is,

```
function parIndSet(N[n], I[m]):
    let C[n], C'[n] = space for coins
    
    parfor i = 1 to n do:
        C[i] <- filpcoin() = H or T
        C'[n] = C.copy()
        
    parfor i = 1 to n do:
        // check if there's double heads
        if C'[i] = H and N[i] != NULL and C'[N[i]] = H then:
            C[i] = T
            
    I[:] = C[val=H]
```

And the cost for this algorithm should be,

- Work: O(n) because the work is linear
- Span: O(logn) because the parfor is usually implemented with a logarithmic solution, while idealy it should be O(1)

The average vertices that ends up in the independent set is `n/4` and we will not prove it here.

#### (3) Work Optimal Wyllie's algorithm 

Recall what we have mentioned about the work optimal list ranking algorithm. The trick is,

- Shrink the list to size `m = n / logn`
- Run Wyllie against shrinked lists `O(mlogm) = O(n)`
- Repeat the process until we have list of `n / logn`
- Restore full list and ranks

In the last Wyllie's we will have the true rank of the last independent set of size smaller than `n / logn`, but how can we restore the full list in the last stage. Well, we basically need to run the process that we just ran to contract the list. This is not hard but it's a lot of bookkeeping. We will talk about this very soon.

#### (4) Cost Analysis of Work Optimal Wyllie's algorithm 

Before we analyze this work optimal Wyllie's algo, let's first answer a basic problem. How many times do we have to run the independent set to shrink the list in general? Let's suppose this value is `k`.

We have said that the average vertices that ends up in the independent set is `n/4`, so after each shrink, we will have an average remaining list of size `3n/4`. Then after `k` runs, we shoule have it satisified the following equation,

```
(3/4)^k * n = n / logn
```

To slove this equation, we have,

```
k = log_(3/4)(1/logn) = O(loglog(n))
```

Therefore, the cost of this algorithm should be,

- Work: `W(n) = k * n = O(nloglog(n))`
- Span: `D(n) = k * logn = O(lognloglog(n))`

Ah, you may see there's a lie here. Because the work is `O(nloglog(n)) > O(n)`, then this algorithm is the suboptimal case. There are some good news,

- `loglogn` doesn't grow very quickly
- the parallel independent set only needs to be run for a few times
- the `k` is roughly calculated and it depends on the probability

### 3. Parallel Tree Traversals

#### (1) Euler Graph

An Euler graph (aka. Euler circuit) is a directed close path that uses every edge node once.

#### (2) Traversal and Euler Graph

If we draw two edges pointing to opposite directions for each tree traversal map, we are then able to create an Euler graph that connects every node.

#### (3) Postorder Euler Graph

Let's recall the pseudocode of the postorder traversal. In the recursive call, it just passes along the current value of v and upon the return value, it adds 1 as shown below,

```
v = postorder(C, V, v) + 1
```

Based on this idea, we can assign the initial ranks for each sink (aka. node) we have in the Euler graph. For,

- parent-to-child sink: assign 0
- child-to-parent sink: assign 1

Then if we do a scan against this Euler graph created for the tree, then we can get the postorder values. This is called a **Euler tour** technique.

#### (4) Euler Tour Algorithm Cost

Now let's see the cost of this technique. An Euler tour would have the following three stages,

- Turn the tree to a list
- Label the list nodes with ranks initialized to {0, 1}
- List Prefix Sum (add scan)

Suppose we use a work optimal algorithm for the list scan (like ideal work optimal Wyllie's), then the cost would be,

- Work: `W(n) = work of optimal scan = O(n)`
- Span: `D(n) = O(logn)` because the tree is now a list and its height is no longer relevant

#### (5) Another Euler Tour Example: level

Let's now see another example about the Euler tour. Suppose we want to know the level of each node in a tree, then what should be the initial ranks for the Euler path? You may think of the following answer,

- parent-to-child sink: assign 1
- child-to-parent sink: assign -1

#### (6) Tree to Array

Let's see how to store the tree for an Euler tour. For each node `v`, we will define its adjacency list to be the set of its outgoing neighbors,

```
adj(v) = {u0, u1, ..., u_(dv-1)}
```
For example, if we have the following tree,

```
                       0
                   /   |   \
                 1     2    3 
             /   |   \
           4     5    6
                    /   \
                  7      8
```

Then the adjacency list or table would be,

```
[[1, 2, 3],
 [4, 5, 6, 0],
 [0],
 [0],
 [1],
 [1],
 [7, 8, 1],
 [6],
 [6]]
```

If we take vertex 1, we can get a list of `[4, 5, 6, 0]`, which will be the vertics that vertex 1 points to. The number is called the outer degree and it is noted as `dv` in this case.

#### (7) Successor Function

Now we have the scheme of tree as an adjency table, but how can we know the successor of each node based on it? We use something called a successor function and it's relatively simple. The pseudocode should be,

```
function successor(u[i], v):
    return v, u[(i+1) mod dv]
```

Let's see why it works. With the tree we used above, suppose we have an edge that goes from 0 to 1, then we have,

```
successor(0, 1)
```

Here, 

- `u[i] = 0`
- `v = 1`
- `i = 0`
- `dv = 4`
- `(i+1) mod dv = 1`

So it returns,

```
(1, u[(i+1) mod dv]) = (1, 4)
```

From the graph we can figure out that the successor edge should goes from 1 to 4.

However, each time we switch to a new node `v`, we need to change the `u` to its corresponding adjacent set and there needs some techiques to turn this into `O(1)`. A common techque being used here is to augment some extra pointers in the adjacency list data structure but this can also be quite messy.
