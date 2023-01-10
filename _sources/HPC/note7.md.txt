# High Performance Computing 7 | Scan and Rank List

#### 1. Prefix Sum

The prefix sum is defined as the sum of the previous item before the input index. For example, if we have an array A,

```
A = [1, 2, 3, 4, 5]
```

Then the prefix of the index `i = 3` (i starts from 1) should be,

```
prefix sum = 1 + 2 + 3 = 6
```

#### 2. Scans

Scans generalize prefix sum to other operations. To use scan in an algorithm, what we have to do is to say we are scanning and what is the operator. The "Add-scan" is the "prefix sum" we have mentioned and there are some other scans,

- `max-scan`: max value to the current position
- `product-scan`: or prefix-products refers to the products to the current position
- `and-scan`: refers to the cumulative logical AND to the current position

#### 3. Parallel Scans?

Let's think of a problem. Suppose we have the following algorithm,

```
input: A[n]

for i = 2 to n do:
    A[i] += A[i-1]
```

In this case, we can not replace the for loop with a parallelized for loop because the iterations are not independent. This is because the prefix `A[i]` depends on the last prefix `A[i-1]`. 

Note that this algorithm at the best case has `O(n)` operations.

#### 4. Parallel Scan in a Naive Way

To change it to a parallel scan, we have to detach the dependency of the current prefix and the last prefix. A naive solution is to simply reduce the first `i` item based on our operation. The pseudo code should be,

```
input: A[n]
output: B[n]

for i = 1 to n do:
    B[i] = reduce(A[:i])
```

The work here would be `O(n^2)` and this is much worse than the sequenial solution. How can we improve?

#### 5. Advanced Parallel Scan

Let's see how we can improve it. Suppose we have an array `A` of 8 items. The first step is to Create a partial scan array which will scan every two items in this array. So,

```
Scan_partial = [reduce(A[1:2]), 
                reduce(A[3:4]), 
                reduce(A[5:6]), 
                reduce(A[7:8])]
```

Then the scan of this partial scan array would be the scan of all the even items in the array,

```
Scan_even = [reduce(A[1:2]), 
             reduce(A[1:4]), 
             reduce(A[1:6]), 
             reduce(A[1:8])]
```

Now we have all the even scans and the odd scans can be retrieved by using the last even scan by and reduce with itself,

```
Scan = [A[1], 
        reduce(A[1:2]), 
        reduce(A[1:2])+A[3], 
        reduce(A[1:4]), 
        reduce(A[1:4])+A[5], 
        reduce(A[1:6]), 
        reduce(A[1:6])+A[7], 
        reduce(A[1:8])]
```

Now here are some pseudo codes,

```
function addScan(A[n]):
    if n == 1 do:
        return A[:n]
    Let:
        I_odd[1:n/2] = 1, 3, 5, ...
        I_even[1:n/2] = 2, 4, 6, ...
        
    for i in I_odd do:
        A[i+1] = A[i] + A[i+1]       // partial scan
    
    A[I_even] = addScan(A[I_even])   // even scan
    
    for i in I_odd[2:] do:
        A[i] += A[i-1]               // odd scan
```

Then let's see the cost,

- partial scan: n/2 additions
- odd scan: (n/2 - 1) additions
- even scan: W(n/2) additions assume the work is W(n)

Then we have,

```
W(n) = n - 1 + W(n/2),     when n >= 2
W(n) = 0,                  when n = 1
```

This is to say that,

```
W(n) = O(n)
```

#### 6. Sequential Segmented Scan

Now let's see another problem. If we don't want to scan the whole array all along, but we would like to scan it in segments. For example, with array,

```
A = [1, 2, 3, 4, 5, 6]
```

We want to add-scan for the first three items and another add-scan for the next three. So the segmented add scan of A would be,

```
A = [1, 3, 6, 4, 9, 15]
```

Given the flag defined as another array `F` as follows,

```
F = [1, 0, 0, 1, 0, 0]
```

Then the pseudo code for a sequential solution would be,

```
function segAddScan(A[n], F[n]):
    for i = 1 to n do:
        if not i do:
            A[i] += A[i-1]
```

Note that it basically means we keep the value of `A[i]` when the flag shows the position `i` has a new start (aka. `F[i] = 1`).

#### 7. Rank List Sequential Solution

Suppose we have a linked list with a `head` pointer and then we have to rank all the nodes. Sequentially, the pseudo code should be very easy, as 

```
function rankList(head):
    r = 0
    cur = head
    
    while cur != NULL do:
        cur.rank = r
        cur = cur.next
        r++
        
node.rank = distance of node to head
```

If we want to solve this problem as a scan, then what can we do? Think about it before we move on.

#### 8. Rank List As a Scan

So let's see if we want to make the rank a scan, we have to assign each node an initial value so that the add scan would in principle produce the desired ranks. For a simple ordered rank,

- 0 should be assigned to the node head
- 1 should be assigned to the rest of the nodes

So if we continue to scan along this array, we will get the 1s accumulated and these will create a rank for us. Because the head in our case should be ranked as 0, so we have 0 assigned to it.

The problem is that if we have a scan like this, the rank is still sequential and a better one should be a **random access**. This brings us to to the method of array pools.

#### 9. Array Pools Representation of Linked List

Array pools is just another way to represent a linked list. Suppose we have the following linked list,

```
ll = [1, 6, 1, 8, 0, 3, 3, 9, 8, 8, 7, 5]
```

Then the array pools representation takes two steps.

- First, put values in an array `V` of length `n`
- Then, replace the concept of pointer to the index and place to another array `N` of length `n`

Let's see `ll` as an example. Let's assign a unique integer `i` (n = 14 and i < n) for each of the nodes in `ll` randomly,

```
[1, 6, 1, 8, 0, 3, 3, 9, 8, 8, 7, 5] = ll
[12,5,10, 8,13, 9, 1, 2, 3, 6, 7, 4] = I
```

Then use `i` as the index, we can put the nodes of `ll` to an array `V` of length n = 14,

```
V[14] = [3, 9, 8, 5, 6, 8, 7, 8, 3, 1, ?, 1, 0, ?]
```

where `?` means the value is not assigned.

Then for the pointers, we put the assigned integer (index) of the next node of the current node to the array `N`. Note that `0` should be used for not NULLs or not assigned nodes.

```
N[14] = [2, 3, 6, 0, 10, 7, 4, 13, 1, 8, 0, 5, 9, 0]
```

#### 10. Primitive Jump Pseudocode

Now we have a taste of the array pools representation, the other knowledge we have to know about is called a jump for a linked list. 

The jump means to move the next pointer so that it points to the neighbor's neighor,

```
curr.next = curr.next.next
```

If we do this to all the nodes in a linked list, we can split it into two linked list. And we can continue to split for more of them. This is very helpful for divide-and-conquer. Also, note that this can be performed in parallel.

When considering the array pools representation, the pseudo code should be as follows,

```
function jumpList(N_in[1:m], N_out[1:m]):
    parallel for i = 1 to m do:
        if N_in[i] do:
            N_out[i] = N_in[N_in[i]]
```

#### 11. Rank Update

So the ideas we have so far is,

- represent linked list as array pool
- use add scan for list ranking
- jump to divide-and-conquer

But how can we tread the list rank as an add scan? Remeber we have use 0 for the head and 1 for the others, and we can also use jumps to get sublists. And if we jump repeatedly, we can get shorter and shorter sublists. 

So in order to keep the position when we jump, we have to add the integer of the current node to its successor. This is what we called "update" and it can also be parallelized. Let's see an example, suppose we have

```
0 -> 1 -> 1 -> 1 -> 1 -> 1 -> NULL
```

So in an update, every node pushes its value to its successor,

```
0 -> 1+0 -> 1+1 -> 1+1 -> 1+1 -> 1+1 -> NULL
```

for,

```
0 -> 1 -> 2 -> 2 -> 2 -> 2 -> NULL
```

Then we call jump to split the linked list,

```
0 -> 2 -> 2 -> NULL
1 -> 2 -> 2 -> NULL
```

Then another update,

```
0 -> 2 -> 4 -> NULL
1 -> 3 -> 4 -> NULL
```

Then jump,

```
0 -> 4 -> NULL
2 -> NULL
1 -> 4 -> NULL
3 -> NULL
```

Then update,

```
0 -> 4 -> NULL
2 -> NULL
1 -> 5 -> NULL
3 -> NULL
```

And a final jump,

```
0 -> NULL
4 -> NULL
2 -> NULL
1 -> NULL
5 -> NULL
3 -> NULL
```

Now we have all the individual nodes each with a rank and then we are done.

Here's an algorithm for the `update` step with the array pool representation,

```
initial R_in = [0, 1, 1, ...]

function updateRanks(R_in[1:m], R_out[1:m], N[1:m]):
    parallel for i = 1 to n do:
        if N[i] do:
            R_out[N[i]] = R_in[i] + R_in[N[i]]
```

#### 12. Parallel List Rank

So finally let's wrap up the parallel list ranker using pseudocode. Suppose we have an input `V[m]` which is the array holding the values, and we also have an input `N[m]` which holds the next node indexes. The index of head is also given as `h` so we can assign the rank of it to 0.

```
function rankList(V, N, h):
    R_in[m], R_out[m]    // array of ranks
    N_in[m], N_out[m]    // pointer index arrays
    
    // init
    R_in[:], R_out[:] = [1]
    R_in[h], R_out[h] = 0
    N_in[:], N_out[:] = N[:]
    
    // compute
    for i = 1 to (# of jumps) do:
        updateRanks(R_in, R_out, N_in)
        jumpList(N_in, N_out)
        // swap to continue the loop
        R_in, R_out = R_out, R_in
        N_in, N_out = N_out, N_in
```

Note that here the `# of jumps` should be the ceiling of `log(m)`. This algorithm is called Wyllie's algorithm and we should meet it in our project.

