#!/bin/bash

./create_config.py
ANSIBLE_PIPELINING=True ansible-playbook -i inventory playbook.yml $@
