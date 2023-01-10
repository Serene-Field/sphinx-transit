# High Performance Computing 9 | Midterm Review

### 1. Work Span Model

- Average Available Parallelism
```
Avg. Para = W(n) / D(n)
```
- Work-Span Law
```
Tp(n) >= max{D(n), ceil(W(n)/p)}
```
- Brent’s Theorem (Slack)
```
Tp <= (W - D) / P + D
```
- Best Sequential Time
```
T'(n) = τW(n)
T'(n) = W(n) if we assume unit time per work
```
- Computation Time
```
T_comp = τW
```
- Transfer Time
```
T_mem = ɑLQ
```
- Speedup
```
S(p) = = T'(n) / Tp(n) = W(n) / Tp(n)
```
- Work Optimality
```
W = W'
```
- Weak Scalability
```
P = O(W'/D)
```
- Computational Intensity
```
I = W / LQ
```
- Machine Balance Point
```
B = ɑ / τ
```
- Parfor Cost
```
Work: O(n)
Span: O(log(n)) or idealy O(1)
```
- Overall Time Range
```
τW * max(1, B/I) <= T <= τW * (1 + B/I)
```

### 2. Power and Energy
- Recall: ɑ and τ
```
ɑ = time per transaction operation
τ = time per computation operation
```
- Lemma
```
1/ɑ = transaction operation per unit time
1/τ = computation operation per unit time
```
- Execution time for a DAG
```
Usual work: W/(Pτ)
Spans: D/τ
Trasactions: QL/ɑ
Tp >= max(W/(Pτ), D/τ, QL/ɑ)
```
- Principle of Balance
```
W/(Pτ) >= QL/ɑ
Also, W/Q >= τ/ɑ * PL = PL/B
```
- Power
```
P = E / T = P_0 + ΔP = P_0 + CV^2 * f * a
```
- Dynamic Power
```
ΔP = CV^2 * f * a
```
- Frequency-Valt Relation
```
f ∝ V
```
- Power-Clock Law
```
P ∝ f^3
```

### 3. Memory Locality
- Block Transfer Cost
```
W(n) = Ω(n)
Ω(ceil(n/L)) <= Q(n;Z,L) <= ceil(n/L) + 1
```
- Block Reduction Cost
```
W(n) = Θ(n)
Q(n;Z,L) >= Θ(ceil(n/L))
```
- Matrix-Matrix Multiplication Cost
```
W(n) = O(n^3)
Q(n;Z,L) = Ω(n^2 / L)
```
- Matrix-Vector Multiplication Cost
```
W(n) = O(n^2)
Q(n;Z,L) = 3n/L + n^2 + n^2/L = O(n^2)
```
- Normalized Performance
```
R = τW' / T
```
- Maximum Normalized Performance
```
R_max = W'/W * min(1, I/B)
```

### 4. I/O Avoiding
- Two-way Merge Sort
```
# Phase 1
f ∈ [0,1)
Partition input into n/(fZ) chunks
for each chunk i = 1 to n/(fZ) do:
    load chunk i
    sort chunk i into a sorted run i
    write run i

# Phase 2
read L-sized blocks of A, B to _A and _B
while any unmerged items in A and B do:
    _A, _B -> _C as possible
    if _A empty:
        load more A to _A
    if _B empty:
        load more B to _B
    if _C full:
        flush _C to C
Flush any unmerged items in A or B
```
- Two-way Merge Sort Cost
```
W(n) = O(nlogn)
Q(n;Z,L) = O(n/L*log(n/Z))
```
- Multiway Merge Sort Cost
```
W(n) = O(nlogn)
Q(n;Z,L) >~ (n/L)*log_(Z/L)(n/L)
```
- Binary Search
```
W(n) = O(logn)
Q(n) = O(log(n/L)) by solving Recurrence
```

### 5. Cache Oblivious
- Cache Defined Transfers
```
Q(n;Z,L) = # of misses + # of store evictions
```
- Lemma: Optimal and LRU
```
Q_LRU(n;Z,L) <= 2Q_OPT(n;Z/2,L)
```
- Tall Cache Assumption
```
Z >= L^2
```
- CO Matrix Matrix Multiplication
```
function mm(n, A, B, C):
    if n = 1 then C <- A + B
    else
        Logically partition A, B and C into quadrants
        for i = 1 to 2 do:
            for j = 1 to 2 do:
                 for k = 1 to 2 do:
                     mm(n/2, Aik, Bkj, Cij)
```
- CO Matrix Matrix Multiplication Cost
```
W(n) = O(n^3)
Q(n;Z,L) = Θ(n^3/(L*sqrt(Z)))
```
- CO Binary Search: the I/O avoiding binary search is already cache oblivious
- Van Emde Boas BST
    - partitioning the levels
    - layout all the upper subtree elements together
    - concatenate with the lower subtree elements
- Van Emde Boas BST Maximum Cache misses
```
Q = h / h_sub = Ω(logN/logL)
```

### 6. Scan and Rank
- Sequential Add Scan Cost
```
W(n) = O(n)
D(n) = O(n)
```
- Naive Add Scan (par)
```
for i = 1 to n do:
    B[i] = reduce(A[:i])
```
- Naive Add Scan Cost
```
W(n) = O(n^2)
D(n) = O(n)
```
- Advanced Add Scan (par): odd-even seperate
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
- Advanced Add Scan Cost
```
W(n) = O(n)
D(n) = O(log^2(n))
```
- Sequential RankList
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
- Sequential RankList Cost
```
W(n) = O(n)
```
- Linked List Representation: Array Pool
    - Assign index to each node by list I
    - Based on I, put nodes to a list V
    - Replace the concept of pointer to the index and place to another array N
- Premitive jump
```
function jumpList(N_in[1:m], N_out[1:m]):
    parallel for i = 1 to m do:
        if N_in[i] do:
            N_out[i] = N_in[N_in[i]]
```
- Parallel List Rank
```
initial R_in = [0, 1, 1, ...]

function updateRanks(R_in[1:m], R_out[1:m], N[1:m]):
    parallel for i = 1 to n do:
        if N[i] do:
            R_out[N[i]] = R_in[i] + R_in[N[i]]
            
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
- Parallel List Rank Cost
```
W(n) = O(nlogn) not work optimal
D(n) = O(log^2(n))
```

### 7. Bitonic Sort
- Three Item Sort Network
![](https://github.com/Sadamingh/notepics/blob/main/hpc/2.png?raw=true)
- Four Item Bitonic Sorting Network
![](https://github.com/Sadamingh/notepics/blob/main/hpc/3.png?raw=true)
- Bitonic Split
```
function bitonicSplit(A[n]):
    // assume 2|n
    parfor i = 0 to (n/2-1) do:
        a = A[i]
        b = A[i + n/2]
        A[i] = min(a, b)
        A[i + n/2] = max(a, b)
```
- Bitonic Split Network
![](https://github.com/Sadamingh/notepics/blob/main/hpc/5.png?raw=true)
- Bitonic Merge
```
function bitonicMerge(A[n]):
    // assime A is bitonic, 2|n
    if n>= 2 then:
        bitonicSplit(A[:])
        spawn bitonicMerge(A[:(n/2-1)])
        bitonicMerge(A[(n/2):(n-1)])
```
- Bitonic Merge Network
![](https://github.com/Sadamingh/notepics/blob/main/hpc/5.png?raw=true)
- Generate Bitonic Sequence
```
function genBitonic(A[n]):
    if n >= 2 then:
    // assume 2|n
    spawn genBitonic(A[:(n/2-1)])
    genBitonic(A[(n/2):(n-1)])
    sync
    spawn bitonicMerge+(A[:(n/2-1)])
    bitonicMerge-(A[(n/2):(n-1)])
```
- Bitonic Sort
```
function bitonicSort(A[n]):
    genBitonic(A[:])
    bitonicMerge+(A[:])
```
- Bitonic Sort Cost
```
W(n) = Θ(nlog^2(n)) not work optimal
D(n) = Θ(log^2(n))
```

### 8. Tree


