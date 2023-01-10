# Intro to Information Security 4 | Malware Analysis

### 1. Phase 1: Malware Analytics

#### (1) Joe Sandbox Cloud

[Joe Sandbox](https://www.joesandbox.com/) detects and analyzes potential malicious files and URLs on Windows, Android, Mac OS, Linux, and iOS for suspicious activities. It performs deep malware analysis and generates comprehensive and detailed analysis reports.

#### (2) Reports Reading Rules

If any of the behaviors are seen (or attempted, but not necessarily successful) in any process in the report, then that malware has attempted that behavior. This is, of course, not completely practical, as legitimate applications may perform the same actions in a benign fashion. We are not concerned with differentiating the two in this assignment, but it is some food for thought.

#### (3) Understanding the programs

Before we start, let's try to understand each of these malwares based on their `Behavior Graph`s.

- **Malware 1**: this malware uses Follina CVE-2022-30190 for MS office to start `cmd.exe`.
- **Malware 2**: this malware tries to kill multiple processes by sending SIGKILL signal. The goal is to turn the device into remotely controlled bots.
- **Malware 3**: this malware created malicious files and hide that they are downloaded from the internet. The goal is to call Nanocore RAT service.
- **Malware 4**: this malware changes the security center settings and hides it has been downloaded from the internet. Then it attempts to connect to the network and upload the data. This is called Emotet virus.
- **Malware 5**: this malware attempts to execute the `regasm.exe` virus or similar to steal sensitive user information.

#### (4) Check Dropped (Created) Files

Search for `Behavior Graph` and check if a process has created any files that is considered to be malicious. The sky blue block means the files created and if there's a red symbol in the blue box, it means the created file is malicious.

#### (5) Check MS Office Key Deletion

Search for `Key Deleted` and check if we have the keyword `Office` appears in the Key Path shown.

#### (6) Check MS Excel Key Creation

Search for `Key Created` and check if we have the keyword `Excel` appears in the Key Path shown.

#### (7) Check created registry values

Search for `Number of created Registry Values` to view the behavior graph. Then figure out if there're any processes created registry values.

#### (8) Check RegAsm virus

Check if we have keyword `regasm` in the `AV Detection` section.

#### (9) Issues signal to cause immediate program termination

Check out the `Behavior Graph`s and find out which malware will issue signals to terminate the program.

#### (10) Check Malicious file programmed in C or C++

Check out the `Behavior Graph`s for each started process, there should be a bar indicates how malicious the file is. We can also find which language it is programmed, and it should be in,

- Java
- C, C++, or other
- .Net C# or VB .NET
- Visual Basic

We should find out if the malicious file in the current malware is written in C/C++.

#### (11) Detects the Mirai botnet

You may already known which malware uses Mirai Botnet but we can comfirm it by searching `Yara detected Mirai` in the reports.

#### (12) Check attempts for keylogger

Search for `keylog` in the reports and see if the malware has some signatures related to it.

#### (13) Check attempts to copy clipboard

It should be similar to the last one. Search for `Clipboard Data` in the reports and see if the malware has some signatures related to it.

#### (14) Check hooking registry keys/values

Search for `Monitors certain registry keys / values for changes` and see if we have some signatures related to it. This is often done to protect autostart functionality.

#### (15) Detect HIPS/PFW/OS Protection Evasions

Search for `HIPS / PFW / Operating System Protection Evasion` in the reports and see if we have some signatures related to it.

#### (16) Check calling core file `splwow64.exe`

Search for `splwow64.exe` in the reports and see if we have some signatures related to it.

#### (17) Check the drops of a portable executable file into `C:\Windows`

Note that the portable executable (PE) file should have one of the following file extensions,

- .acm
- .ax
- .cpl
- .dll
- .drv
- .efi
- .exe
- .mui
- .ocx
- .scr
- .sys
- .tsp

And then let's search for `Created / dropped Files`. There should be at least one file with `dropped` Category and one of the extensions above. And the Process should be started by `C:\Windows`.

#### (18) Check if it looks for the name or serial number of a device

Search for `Queries the volume information (name, serial number etc) of a device` in the reports and see if we have some signatures related to it.

#### (19) Check the attempts to obscure the meaning of data

Search for `Obfuscated Files or Information` nd see if we have some signatures related to it.

#### (20) Check HTTP GET or POST without a user agent

Search for `HTTP Packets` and check if there's one GET or POST request which doesn't have a `User-Agent` field in its header.

#### (21) Check if uses spans to delay

Check the following keywords `Sample execution stops while process was sleeping` or `Contains medium sleeps (>= 30s)` or `May sleep (evasive loops) to hinder dynamic analysis` or `sleep` or `ping` or `delay` to check if there are some delays for evasion.

#### (22) Check if overrides DNS to redirect

Search for `DNS` in the reports and see if there are potential DNS overrides in signatures.

#### (23) Detect possible system shutdown

Search for `System Shutdown/Reboot` in the reports and see if we have some signatures related to it.

### 2. Machine Learning of Malwares and Malheur

#### (1) Malheur Manual

Malheur is a tool for the automatic analysis of malware behavior and the detailed manual can be found through this [link](http://www.mlsec.org/malheur/manual.html).

There are a few options to keep in mind,

- `-c`: additional option for the config file. By default it should read the config file named `malheur.cfg` but we explicitly use `config.mlw` as an alternative
- `-o`: specifies the output file outfile for analysis
- `-vv cluster`: specified the clustering action on the dataset

Note that we need to use `head` command to read the output result.

#### (2) Testing Malheur

Train the model using our dataset `dataset/training/` and check the output result by,

```
$ malheur -c config.mlw -o training.txt -vv cluster dataset/training/; head training.txt
```

Then test the model using our dataset `dataset/testing/` and check the output result by,

```
$ malheur -c config.mlw -o testing.txt -vv classify dataset/testing/; head testing.txt
```

To classify all five malicious samples we have seen above, we need to run the model against the dataset under `subjects/` and generate the results,

```
$ malheur -c config.mlw -o classify.txt -vv classify subjects/; head classify.txt 
```

#### (3) Datasets

Now, let's get some understandings of the dataset. First, let's go to the training set,

```
$ cd dataset/training
```

Then, we output the first few lines of the first file we can list,

```
$ ls | head -1
00006b6257ef49f6199fd583cfd0b703e2530c8fa45c748a4336a3e691a0054a.allaple
$ cat $(ls | head -1) | head
NtOpenKey;
NtOpenKey;
NtAllocateVirtualMemory;
NtAllocateVirtualMemory;
LdrLoadDll;
LdrGetProcedureAddress;
LdrGetProcedureAddress;
LdrGetProcedureAddress;
LdrLoadDll;
LdrGetProcedureAddress;
```

The data of this file is actually based on information extracted from [Cuckoo malware behavior reports](https://www.virustotal.com/gui/home/upload). To view the original report of the file `00006b6257ef49f6199fd583cfd0b703e2530c8fa45c748a4336a3e691a0054a.allaple`, we can exetract its hash and add `https://www.virustotal.com/gui/file/` to is front. Then we can access the link of the report: 

[https://www.virustotal.com/gui/file/00006b6257ef49f6199fd583cfd0b703e2530c8fa45c748a4336a3e691a0054a](https://www.virustotal.com/gui/file/00006b6257ef49f6199fd583cfd0b703e2530c8fa45c748a4336a3e691a0054a)

in a browser. The extension `allaple` of this file means it actually belongs to malicious family [allaple](https://www.f-secure.com/v-descs/allaple_a.shtml).


#### (4) Configurations

Now, let's look into the config file of the model. The file `config.mlw` should be as follows,

```
$ cat config.mlw
# MALHEUR (0.6.0) - Automatic Analysis of Malware Behavior
# Copyright (c) 2009-2015 Konrad Rieck (konrad@mlsec.org)
# University of Goettingen, Berlin Institute of Technology

generic = {
    input_format = "text";
    event_delim = ";";
    state_dir = "./malheur_state";
    output_file = "malheur.out";
};

features = {
    ngram_len = 2;
    ngram_delim = ";";
    vect_embed = "bin";
};

prototypes = {
    max_dist = 0.0;
    max_num = 0;
};

classify = {
    max_dist = 1.00;
};

cluster = {
    link_mode = "complete";
    min_dist = 0;
    reject_num = 0;
    shared_ngrams = 0;
};
```

Based on the documentation, we shouldn't change the `generic` field and we should modify the other settings in order to get a higher model performance (F-score).

We have to change the hyperparameters in this config file to meet the following two goals,

- Achieve a minimum of 70% f-score in the testing phase only
- Classify all Project 2 malware samples with maximum distance of 1. 

#### (5) Output Result

If we check more of the output result, we can find more information of the classified result rather than just the F-score. We can check it using the `classify.txt` file we have generated because it is much smaller.

```
$ cat classify.txt 
...
# F-measure of classification: ...
# ---
# <report> <label> <prototype> <distance>
...
```

So after the F-score, we can see the report name, the classified label (label/reject), the prototype of the cluster, and the distance.

For the second goal we have mentioned above, it actually means that we need to have the distance here smaller than 1 so that it will not be classified as `reject`.


#### (6) Hints

Here are some hints to slove this problem, and most of the answers can be figured out through the [manual](http://www.mlsec.org/malheur/manual.html).

- `ngram_len` is default 2 but should set to 1 if the data is not sequential. This is relatively important so be careful about what it should be
- `ngram_delim` defines characters for delimiting
- `vect_embed` should be set to `bin` if features are binaries. It should be set to `cnt` if features have many values.
- `hash_seed1` and `hash_seed2` can be added using the default values in the manual. 

We should also try out different combinations of `max_dist` and `min_dist` in order to get a good setting.
