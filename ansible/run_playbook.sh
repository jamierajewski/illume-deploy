#!/bin/bash

./create_config.py
ansible-playbook -i inventory playbook.yml
