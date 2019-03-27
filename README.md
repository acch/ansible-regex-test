Regex-test Ansible Role
=======================

[![Build Status](https://travis-ci.org/acch/ansible-regex-test.svg?branch=master)](https://travis-ci.org/acch/ansible-regex-test) [![GitHub Issues](https://img.shields.io/github/issues/acch/ansible-regex-test.svg)](https://github.com/acch/ansible-regex-test/issues) [![GitHub Stars](https://img.shields.io/github/stars/acch/ansible-regex-test.svg?label=github%20%E2%98%85)](https://github.com/acch/ansible-regex-test/) [![Role Downloads](https://img.shields.io/ansible/role/d/29537.svg)](https://galaxy.ansible.com/acch/regex_test) [![License](https://img.shields.io/github/license/acch/ansible-regex-test.svg)](LICENSE)

Ansible role for comparing command output with reference file

Features
--------

The purpose of this role is to verify that previously run tasks have left the system in a certain well-defined state. For this purpose it is supposed to be run after other role(s). A system's state is tested by executing a series of shell (`/bin/sh`) commands, and comparing their output with reference files. Thus, one needs to define the test commands as well as the expected output of such commands beforehand. The role will fail if one of the command's output differs from the corresponding reference file.

As command output may contain details which are irrelevant for verification of the system state (e.g. timestamps, version numbers, etc.) the reference file can contain regular expressions &mdash; for example: `.` will match any character, `[0-9]` will match any single-digit number, `[0-9]{20}` will match any 20-digit number, and so on. For a detailed description of regular expression syntax refer to the following page:

> A Brief Introduction to Regular Expressions &mdash;
> http://tldp.org/LDP/abs/html/x17129.html

Installation
------------

```
$ ansible-galaxy install --roles-path roles/ acch.regex_test
```

Usage
-----

The fact that the reference file will be interpreted as regular expressions means that you need to mask special characters in that file. Thus, run the following to generate a reference file from a command's output:

```
$ /path/to/command > command.out
$ while read string ; do printf '%s\n' "$string" | sed 's/[.[\*^$()+?{|]/\\&/g' ; done < command.out > command.rgx
```

Place the reference file (`command.rgx`) in the `files/` directory of the regex-test role and define your test(s) using host variables.

Role Variables
--------------

Tests need to be defined as host variables. Each element of *regex_tests* needs to have a *name*, a *command* which is executed, as well as a corresponding *regex* reference file in the `files/` directory:

```
# group_vars/all:
---
regex_tests:
  - name: Test command
    command: /path/to/command
    regex: command.{{ test_id }}.rgx
```

The purpose of the *test_id* variable is to allow for different variants of the same test. It must be defined for each individual play.

Furthermore, specify if you want to run the tests for each individual host in the current play (`regex_test_runonce: false`), or only once for the entire play (`regex_test_runonce: true`).

```
# group_vars/all:
---
regex_test_runonce: false
```

The actual play needs to also define a unique *test_id*. Its purpose is to allow for different variants of the same test:

```
# playbook.yml
---
- hosts: ...
  vars:
    test_id: t1
  roles:
    - somerole
    - acch.regex_test
```

Example Playbook
----------------

The following is a minimal working example playbook:

```
myproject
├── group_vars
│   └── all
├── roles
│   ├── myrole
│   │   └── tasks
│   │       └── main.yml
│   ├── myotherrole
│   │   └── tasks
│   │       └── main.yml
│   └── acch.regex_test
│       ├── files
│       │   ├── pythonrpms.t1.rgx
│       │   └── pythonrpms.t2.rgx
│       ├── scripts
│       │   └── regex-test.sh
│       └── tasks
│           └── main.yml
└── myplaybook.yml
```

```
# group_vars/all:
---
regex_tests:
  - name: Test installed python packages
    command: rpm -qa | grep python | sort
    regex: pythonrpms.{{ test_id }}.rgx

regex_test_runonce: false
```

```
# myplaybook.yml
---
- hosts: myhosts
  vars:
    test_id: t1
  roles:
    - myrole
    - acch.regex_test

- hosts: myhosts
  vars:
    test_id: t2
  roles:
    - myotherrole
    - acch.regex_test
```

Troubleshooting
---------------

Please use the [issue tracker](https://github.com/acch/ansible-regex-test/issues) to ask questions, report bugs and request features.


Copyright and license
---------------------

Copyright 2018 Achim Christ, released under the [MIT license](LICENSE)
