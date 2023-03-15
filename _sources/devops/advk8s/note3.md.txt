# Advanced Kubernetes 3 | LDAP

### 1. LDAP

#### (1) LDAP Introduction

LDAP is a protocol initially used to manage telephone directories through telecommunication companies. It's operating on the application layer of OSI. The default port for LDAP is port `389`.

![](https://i.imgur.com/DF7MJbY.png)

#### (2) LDAP Data Interchange Format (LDIF)

LDIF is the standard plain text data files used for LDAP directory content and update requests. There are several fields used in LDIF,

- `dn`: unique distinguished name for each entry
- `dc`: domain component, for example `www.mydomain.com` would be written as `DC=www,DC=mydomain,DC=com`
- `ou`: organizational unit, used to specifiy a user as part of one group
- `cn`: common name referring to individual objects

#### (3) Example: LDAP Pod in Minikube

Let's continue with the minikube cluster we have built in the last article. 

First, let's create a new namespace called `ldap`,

```
$ kubectl create ns ldap
```

Then, make a directory named `ldif` and download the LDIF plain text files from github,

```
$ mkdir ldif
$ cd ldif
$ curl -LO https://raw.githubusercontent.com/Sadamingh/minikube-with-dex/main/ldap/ldif/0-ous.ldif
$ curl -LO https://raw.githubusercontent.com/Sadamingh/minikube-with-dex/main/ldap/ldif/1-users.ldif
$ curl -LO https://raw.githubusercontent.com/Sadamingh/minikube-with-dex/main/ldap/ldif/2-groups.ldif
```

Go back to the last directory after this,

```
$ cd ..
```

Create a `secert` and a `configmap` for the deployment under this nameapce,

```
$ kubectl create secret generic openldap \
    --namespace ldap \
    --from-literal=adminpassword=adminpassword
    
$ kubectl create configmap ldap \
    --namespace ldap \
    --from-file=ldif
```

Finally, curl the YAML file `ldap.yaml` from github and then apply it to create the `service` and `deployment`.

```
$ curl -LO https://raw.githubusercontent.com/Sadamingh/minikube-with-dex/main/ldap/ldap.yaml
$ kubectl apply --namespace ldap -f ldap.yaml
```

Now we have an `ldap` pod running for further exploration.

```
$ kubectl get pods -A | grep ldap
ldap           openldap-6d86d655c5-5bkvc                 1/1     Running   0          73m
```

#### (4) Interact with LDAP

Now we can access the LDAP pod through,

```
$ kubectl exec --stdin --tty -n ldap $LDAP_POD -- /bin/sh
#
```

We can check the LDIF entries through `ldapsearch` but for now because we have no user or group imported, we will receive `No such object (32)` errors,

```
# ldapsearch -x -D "cn=admin,dc=example,dc=org" -w adminpassword -b "ou=groups,dc=example,dc=org"
No such object (32)
# ldapsearch -x -D "cn=admin,dc=example,dc=org" -w adminpassword -b "ou=people,dc=example,dc=org"
No such object (32)
```

From `ldap.yaml` and config map `ldap`, we have mounted local path `ldap/ldif` to `/ldifs`. Therefore, now we are able to access the LDIF files,

```
# ls -lrt /ldifs
lrwxrwxrwx 1 root root 20 Mar 15 03:31 2-groups.ldif -> ..data/2-groups.ldif
lrwxrwxrwx 1 root root 19 Mar 15 03:31 1-users.ldif -> ..data/1-users.ldif
lrwxrwxrwx 1 root root 17 Mar 15 03:31 0-ous.ldif -> ..data/0-ous.ldif
```

These LDIF files can be mapped to the following tree structure,

```
├─dc=example,dc=org    # example.org
│  ├─ou=people
│  │  ├─cn=admin1
│  │  ├─cn=admin2
│  │  ├─cn=developer1
│  │  └─cn=developer2
│  └─ou=groups
│     ├─cn=admins
│     │  ├─cn=admin1
│     │  └─cn=admin2
│     └─cn=developers
│        ├─cn=developer1
│        └─cn=developer2
```

Then, we can add them to the LDAP server at `localhost:389` by using command `ldapadd`,

```
# ldapadd -x -D "cn=admin,dc=example,dc=org" -w adminpassword -H ldap://localhost:389 -f /ldifs/0-ous.ldif
adding new entry "ou=people,dc=example,dc=org"
adding new entry "ou=groups,dc=example,dc=org"
# ldapadd -x -D "cn=admin,dc=example,dc=org" -w adminpassword -H ldap://localhost:389 -f /ldifs/1-users.ldif
adding new entry "cn=admin1,ou=people,dc=example,dc=org"
adding new entry "cn=admin2,ou=people,dc=example,dc=org"
adding new entry "cn=developer1,ou=people,dc=example,dc=org"
adding new entry "cn=developer2,ou=people,dc=example,dc=org"
# ldapadd -x -D "cn=admin,dc=example,dc=org" -w adminpassword -H ldap://localhost:389 -f /ldifs/2-groups.ldif
adding new entry "cn=admins,ou=groups,dc=example,dc=org"
adding new entry "cn=developers,ou=groups,dc=example,dc=org"
```

After the LDIF is added to the LDAP server, we can access the data through `ldapsearch`. Note that `cn=admin,dc=example,dc=org` means the default admin account for the LDAP server which has access to all the objects in the server.

```
# ldapsearch -x -D "cn=admin,dc=example,dc=org" -w adminpassword -b "ou=groups,dc=example,dc=org"
...
# numResponses: 4
# numEntries: 3
# ldapsearch -x -D "cn=admin,dc=example,dc=org" -w adminpassword -b "ou=people,dc=example,dc=org"
...
# numResponses: 6
# numEntries: 5
```

#### (5) Password Hashing

There's one remaining problem. In the LDIF file `1-users.ldif`, `userPassword` is defined through a hash value `{SSHA}RRN6AM9u0tpTEOn6oBcIt9X3BbFPKVk5` according to the code. You can check it out through this [link](https://github.com/Sadamingh/minikube-with-dex/blob/main/ldap/ldif/1-users.ldif#L8-L9).

This value is generated by `slappasswd` command with,

```
# slappasswd -h {SSHA} -s secret
```

And here the original password for `admin1` is actually `secret`. People don't store the original password `secret` directly in LDIF files because someone can easily retrieve the password and it's not secure.

Now, let's try to use `slappasswd` using `SSHA` (using SHA-1 algorithm) to generate the hash value for secret `secret`. We will have something like,

```
# slappasswd -h {SSHA} -s secret  
{SSHA}wH8Y5PJH9h31HoWBj9ZafqB43pyslcjS
```

Here the hash code is very different from the one we have in the `1-users.ldif`. This is because `slappasswd` utility uses a random `salt` by default to make the hash more secure and the server can know both of the hash values means `secret`. 

#### (6) Salted Hash

Let's see how salted hash works. 

![](https://i.imgur.com/LizSFpA.png)

The idea of salted hash is to add some random bits to the password each time before hash so that the hash value will become more randomlized. We will put this salt after the hash value as an appendix for the program to verify.

Suppose we use `secret` as our password. Then after using command `slappasswd`, we get a hash value as follows,

```
{SSHA}RRN6AM9u0tpTEOn6oBcIt9X3BbFPKVk5
```

This hash value is encoded with base64. So let's first decode it, and then we `od` command to change it to hexed bin values,

```
$ echo -n RRN6AM9u0tpTEOn6oBcIt9X3BbFPKVk5 | base64 -d | od -A n -t x1
45  13  7a  00  cf  6e  d2  da  53  10  e9  fa  a0  17  08  b7  d5  f7  05  b1  4f  29  59  39 
```

The value above has two parts. The first 20 bytes are the actual hash value and the last 4 bytes is the salt we used for extra security.

When user enters password as `secret`, we will append the salt after the secret as `secret\x4f\x29\x59\x39`. Then the same encryption process will generate the hash value for us. It should be exactly the same as the one we stored in the LDAP server to pass the authentication. 

```
$ slappasswd -h {SHA} -s $(printf 'secret\x4f\x29\x59\x39') | sed 's/{SHA}//' | base64 -d | od -A n -t x1
45  13  7a  00  cf  6e  d2  da  53  10  e9  fa  a0  17  08  b7  d5  f7  05  b1  
```

Because the salt is randomly added, we will have different hash values even for the same password. This is useful when the passwords are simple, and the attackers can not guess the password through the hash value.
