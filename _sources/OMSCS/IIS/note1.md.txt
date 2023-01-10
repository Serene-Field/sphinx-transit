# Intro to Information Security 1 | Modular Calculation and Software Vulnerabilities

### 0. Mod Calculation

#### (1) A mod B

If A is a negative number, then the result should be,
```
Result = A - B * floor(A/B)
```

#### (2) Congruence
```
If A == B mod C, then A mod C == B mod C
If A mod C == B mod C, then A == B mod C
```

#### (3) Modular Addition
```
(A + B) mod C = (A mod C + B mod C) mod C
```

#### (4) Modular Subtraction
```
(A - B) mod C = (A mod C - B mod C) mod C
```

#### (5) Modular Multiplication
```
(A * B) mod C = (A mod C * B mod C) mod C
```

#### (6) Exponentiation
```
A^n mod C = (A mod C)^n mod C
```

#### (7) Quick Trick of 2-Based Exponentiation
```
A^(2^n) mod C = (A^(2^(n-1)) mod C)^2 mod C
```

#### (8) Exponentiation Trick
Suppose we have to calculate M^N mod C, where N is a large number, then we can calculate the result by

- Rewrite N to binary form `bin(N)`
- Convert the exponentials to polynominals with powers of 2
- Calculate each term with the quick trick of 2-based exonentiation
- Combine the individual powers to find the final answer

#### (9) Modular Inverse
The modular inverse of A mod C is B satisifies,
```
(A B) mod C == 1
```

#### (10) Co-prime
Two integers a and b are said to be co-prime if the only positive integer integer that evenly divides both of them is 1.

#### (11) Prime Root
A number M is a prime root of a number N if every number co-prime to N is congtuent to a power of M mod N.

#### (12) Relative Prime
It describes two numbers for which the only common factor is 1. In other words, relatively prime numbers have a greatest common factor (gcf) of 1.

#### (13) Totients
The totient function φ(n), also called Euler's totient function, which is defined as the number of positive integers <= n that are relatively prime to n, where 1 is counted as being relatively prime to all numbers.

Since a number less than or equal to and relatively prime to a given number is called a totative, the totient function phi(n) can be simply defined as the number of totatives of n.



### 1. Introduction 
#### (1) Cyber Security Requirements (CIA rule)
- Confidentiality: only some people can view it
- Integrity: only some people can modify it
- Availability: the data must exist somewhere

#### (2) Role of the Good Guys
- Prevention
- Detection
- Respnse
- Recovery and remediation
- Establish policies and mechanisms

#### (3) Ways to address cyber security
- Complexity is our enemy
- Fail-safe defaults: allow only if someone really need the data
- Complete mediation: no one should be able to bypass the monitor
- Open design: don't count on someone who will not find out your design
- Least privilage: only have the privilege to the resource someone absoluately need
- Psychological acceptability

### 2. Software Vulnerabilities

#### (1) Common Software Vulnerabilities
- Memory overflow
- Stack buffer overflow
    - Stacks are used in function/procedure calls
    - Stacks are also used for allocating memory
        - local variables
        - parameteres
        - control information (return address)

#### (2) Vulnerable Program Example
```c++
#include <stdio.h>
#include <strings.h>

int main(int argc, char *argv[]) {
    int allow_login = 0;
    char pwdstr[12];
    char targetpwd[12] = "MyPwd123";
    
    gets(pwdstr);
    
    if (strncmp(pwdstr, targetpwd, 12) == 0)
        allow_login = 1;
        
    if (allow_login == 0) 
        printf("Login request rejected");
    else
        printf("Login request allowed");
}
```
Now let's look into the stack of this program.

#### (4) Understanding the Stack

```
---------------------- <- High address (addr)
argc = 4 bytes
---------------------- <- (addr - 4)
argv = 4 bytes
---------------------- <- (addr - 8)
return address = 4 bytes
---------------------- <- (addr - 12)
allowlogin = 4 bytes
---------------------- <- (addr - 16)
pwdstr = 12 bytes
---------------------- <- (addr - 28)
targetpwd = 12 byte
---------------------- <- (addr - 40)
...
---------------------- <- Low address
```

#### (5) Bypass Case

The problem of this program is that when we have the function `gets` read a string, it will not check the length of that string so that the input string can be longer than the memory we have allocated for the variable `pwdstr`. Therefore, the variable memory will overflow and it will continue writing to `allowlogin` variable. For example, if the input string is `BadPasswordHere!`, then

```
---------------------- <- High address (addr)
argc = 4 bytes
---------------------- <- (addr - 4)
argv = 4 bytes
---------------------- <- (addr - 8)
return address = 4 bytes
---------------------- <- (addr - 12)
allowlogin = ere!
---------------------- <- (addr - 16)
pwdstr = BadPasswordH
---------------------- <- (addr - 28)
targetpwd = MyPwd123
---------------------- <- (addr - 40)
...
---------------------- <- Low address
```

Then if we compare `pwdstr` and `targetpwd`, even though those two varibles will not match and the program will not assign 1 to `allowlogin`, this variable has already been overwritten by the input string that exceed 12 bytes (aka. `ere!`). In this case, we can still pass the check for this login.

#### (6) Shellcode

Shellcode creates a shell which allows it to execute any code the attacker wants. Basically, the attackers would like to allocate the following privileges,

- the host program
- system service
- OS root privileges

#### (7) Variations of Buffer Overflow

- **"return-to-libc" Attack**: means to rewrite the return address to a standard library function. This works because if we can return to a standard library function and we are also able to setup some arguments or parameters for it on the stack, then we can execute a function with the argument of our choice.
- **"Heap Overflow" Attack**: Longer variables like the global variables are stored on the heap. The difference between a stack and a heap is that the heap doesn't have a return address. However, the heap do have some function pointers and the data can be the tables of function pointers. So the data stored in the heap is overwritten and we are able to corrupt the memory in some sense as we have done before.
- **"OpenSSL Heartbleed Vulnerability" Attack**: the attacks above is about writing too much and overwriting the data. However, the overflow attacks don't necessarily to be assoicated with writing data. OpenSSL heartbleed vulnerability happens when we read too much. It keeps reading beyond the variables that we are supposed to read.

#### (8) Defense Against Overflow

- Programming language is crucial. Common safe programming languages are C++, Java, etc. A safe language should have the following traits:
    - should be strongly typed
    - should do automatic bounds checks
    - should do automatic memory management
- Check inputs (All input is evil)
- Use safer functions that do bounds checking
- Use automatic tools to analyze code to flag potential unsafe vulnerabilities. These tools can be found at [OWASP](https://owasp.org/www-community/Source_Code_Analysis_Tools).
    - they can flag potential unsafe fucntions/constructs
    - they can help mitigate security lapses (but can hardly eliminate all buffer overflow vulnerabilities)
- Use canary values: a canary value is written when a return address is stored in a stack frame and any attempts to rewrite the address using buffer overflow will result in the canary being rewritten and an overflow will be detected.
- Address Space Layout Randomization (ASLR): this is a feature supported by the operating system that randomizes stack, heap, libc, etc. This makes it harder for the attacker to find important locations like libc function addresses.