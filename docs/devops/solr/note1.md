# Apache Solr 1 | Installation

### 1. Installation 

#### (1) Installing Java

Solr requires Java >= v11 so we have to install Java before we continue. Suppose you are on a MacOS, and you are installing it for the first time, use the following command to install it.

```bash
$ brew install java
...
$ sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk \
     /Library/Java/JavaVirtualMachines/openjdk.jdk
Password:
$ java --version
openjdk 19.0.1 2022-10-18
...
```

#### (2) Download and Install 

```bash
$ mkdir ~/solr
$ cd  ~/solr
$ wget -O solr-9.1.0.tgz "https://www.apache.org/dyn/closer.lua/solr/solr/9.1.0/solr-9.1.0.tgz?action=download"
...
‘solr-9.1.0.tgz’ saved [...]
$ ls solr*
solr-9.1.0.tgz
$ tar -xzf solr-9.1.0.tgz
$ cd solr-9.1.0/
$ bin/solr version
9.1.0
```

