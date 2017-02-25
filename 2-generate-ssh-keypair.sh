#!/bin/bash

ssh-keygen -t rsa -b 4096
{echo; cat ~/.ssh/id_rsa.pub } >> pnpr/authorized_keys