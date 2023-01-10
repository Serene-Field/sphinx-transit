# Intro to Information Security 2 | Capture The Flag and Operating System Vulnerabilities

### 1. Capture the Flag

#### (1) Intro

In this project we are going to view some capture the flag (CTF) problems. The first question should be easy and you should add the ID number to `e.py` script by vim.

#### (2) Buffer Overflow 1

In this case, we have a easy case of buffer overflow. The `payload` is a input used for the `buffer` and `buffer` can be found in the file `flag.c`. To exploit this vulnerability, we have to build a `payload` with enough lenth to rewrite the data on the memory.

It's also good to know some `gdb` commands for this case,

- `break <line>` or `b <line>`: set the breakpoint to line number `<line>`
- `run` or `r`: run the program to the next breakpoint 
- `step` or `s`: go to the next line executed in the function
- `next` or `n`: go to the next line executed and skip the function
- `continue` or `c`: continue running to the next breakpoint or to the end
- `print` or `p`: print the value of a variable

In this case, we need to run the following command to trigger the GNU debugger,

```shell
$ python3 e.py dbg
```

#### (3) Buffer Overflow 2

Now, let's come to the next challenge. In this case, we have a `e.py` similar to the last one and we also have a `flag.c` script. However, in the `flag.c` script, we can find out that we need to bypass the current `unsafe()` function and return to the `can_you_reach_me()` function if we want to capture the flag. So the first task is to find the return address of the `unsafe()` function.

First, we can make a long cyclic as the `payload` and then use `gdb` to find the space we want. In the `gdb` page, we can press `c` to continue to the `SIGBUS` error where we can spot the `Invalid address`. `p64()` function can change that address back to the cyclic section so that we can then use `cyclic_find` to get its position. To check if we got the return address correct, we can append `p64( 0xdeadbeef )` to the end and use `gdb` to check if we return to the address `0xdeadbeef`. If we now return to this address, we finished our first step.

Second, we have to find out the address we have to return. To view the address, we have to check the assembly code of the executable file `flag` by,

```
$ objdump -D flag > flag.asm
```

And then we use `vim` and `/` to search for the function we need. Here we have to search for `can_you_reach_me`. From the line with the `bl` command, we can get the address we need to return. The returned address should be the hex before the `:` sign. So finally, we can create a `payload` with the cyclic offset plus the return address we need.

#### (4) Understanding Assembly

In this case, we can to figure out the right order for the assembly code to come up with the address for the flag. So again, we have to convert the executable `flag` to its assembly by,

```
$ objdump -D flag > flag.asm
```

If we also look into the `flag.c` script, we can figure out the callback of `call_me` is stored in a variable called `caller`. Then in the assembly code, we can search for this `caller` and record its address.

Next, we have to figure out the right order of the assemblies. Here are some functions of the ARM assembly instructions,

- `MOVZ A, #N`: replace the current value in register `A` with instant number `#N`. The bits not assigned will be 0s.
- `MOVK A, #N, lsl M`: put the instant number `#N` to register `A` and then logical shift left for `M` bits. The other bits in the register remains the same.
- `LDR A, [B]`: value in address found at register `B` is loaded to the register `A`
- `STR A, [B]`: value in the register `A` is stored at the address found at register `B`
- `STP A, B, [C]`: move the sp pointer to the address found at register `C` and then write the value of `A` and `B` after that
- `ret`: return the the address at register `x30`

#### (5) Bad Random Caused By Leak

Based on the `flag.c` and also run the executable `flag`, we can figure out in this case that the leaked part of the base address `system` has 8 valid bytes and we have to figure out the rest 4 bytes. 

Second, if we try out the executable `flag` a few time, we can find out the the last 3 bytes of the base address never change. Then in this case, the only guess we have to make is the remaining 1 byte.

Then we have to edit the `e.py` script and create a loop to guess the address for several times. When we make a correct guess, we are able to capture the flag. The following tricks are useful while editing the script. 

- `p = process('./flag')`: create a process executing the command `./flag`
- `p.recvline()`: get one line from output
- `p.sendline(payload)`: send the payload to the process
- `p.recvall()`: get all the output. It will hang up if we have to wait for an input
- `p.close()`: close the current process

#### (6) Get Strings

The next trick is that we can exploit the strings coded in the executable file. To do that, we can use `strings` command in Linux to output all the readable strings in a file,

```shell
$ strings flag > flag_str
```

Then we can use `vim` to check the `flag_str` file and find out the answers. The assumption is that we commonly have related strings appeared together in the code.

#### (7) Client and Server

The solution for this problem is similar to the buffer overflow 2 one and it's a good idea to operate a similar procedure. However, the difference is that we have a client sending messages to the server and the flag is stored on the server. In spite of this, we can also rewrite the return address on the client.

#### (8) XOR Trick

In this problem, we have to read the script `flag.c` first and then understand the logic of the `for` loop. For the bitwise operations, here's a quick reference,

- `^`: XOR
- `|`: OR
- `&`: AND
- `>>`: Shift right
- `<<`: Shift left

After we figure out the meaning of the `flag.c` script, we can easily build a payload that has a `0xefbeadde` value for `XORbius` variable based on the following formula,

```
0 ^ a = a
```

Then we have to build a payload that gives us the result that we need to pass the `if` check. In this case, we will have the following equation where both `c1` and `c2` are constants,

```
x ^ c1 = c2
```

In order to solve this equation, we will need the following property for XOR,

```
a ^ b ^ a = b
```

Therefore, we can solve the equation above by,

```
c1 ^ x ^ c1 = c1 ^ c2 = x
```

So,

```
x = c1 ^ c2
```

Here are also some tools that can help on solving this problem. 

- [Bitwise calculator](https://miniwebtool.com/bitwise-calculator/)
- [Decimal to hex converter](https://www.rapidtables.com/convert/number/decimal-to-hex.html)

Also, because we are using python for payload, we can build characters by,

- `chr()`: decimal to char by ASCII
- `ord()`: char to decimal by ASCII

#### (9) Buffer Overflow 3 (pointy_pointy_point)

This problem highly relies on Math and `gdb`. This problem is very similar to the buffer overflow problems we have met. Here are some hints for this problem,

- To bypass the `protector`, we have to do some calculations
- In order to pass the check, we have to put `0x0badf00d` somewhere and then make the pointer point at it.
- For the calculation of `*(&protector + some_other_value)`, we have to overwrite `some_other_value` by buffer overflow and then make this address the address we want.
- To bypass the `characters_read` check, we can not use buffer overflow to rewrite this variable because it will redo the calculation. We can think about putting some Null characters `b'\x00'` in the buffer so that it will not detect the buffer overflow issue.
- Both x86 and ARM is little endian.

#### (10) Hunt Then Rop

The final task is a combination of two tasks. The first one is to find the vulnerable file by verifying the sha256 checksum for each file. The second one is to find out how to crack the program. 

For the first question, we can output the sha256 checksums of all the files in the current directory by the command line mentioned in [this post](https://askubuntu.com/questions/1091335/create-checksum-sha256-of-all-files-and-directories). The output format can be different so I wrote a python script to check the difference, but there can be many other ways to deal with that issue. Make sure to ignore the files `readme`, `user.txt`, and `checksum`, and the other file left should be the one with vulnerabilities. 



