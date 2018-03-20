#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4

"""Helper-Script to generate host files and ssh configuration
"""

import os
import json
import subprocess
from string import Template

worker_kinds = ['nogpu', '1080ti']

def create_ssh_config(data, outfile, special_config_name=None):
    subnet = data['subnet']['value']
    ssh_username = data['ssh-username']['value']
    ssh_keyfile  = data['ssh-key-file']['value']
    bastion_host_public = data['bastion-address-public']['value']
    bastion_host        = data['bastion-address']['value']

    if special_config_name is not None:
        ssh_config_flag = "-F "+special_config_name
    else:
        ssh_config_flag = ""

    if len(subnet.split('/'))==1:
        subnet_stars = subnet
    else:
        subnet_stars, subnet_mask = subnet.split('/')
        subnet_mask = int(subnet_mask)
        if subnet_mask == 32:
            subnet_stars = subnet_stars
        elif subnet_mask == 24:
            subnet_stars = '.'.join(subnet_stars.split('.')[:-1]) + '.*'
        elif subnet_mask == 16:
            subnet_stars = '.'.join(subnet_stars.split('.')[:-2]) + '.*'
        elif subnet_mask == 8:
            subnet_stars = '.'.join(subnet_stars.split('.')[:-3]) + '.*'
        else:
            raise RuntimeError('CIDR netmasks supported are: 32,24,16 and 8. Mask is {}'.format(subnet_mask))

    # Substitute vars in template
    filein = open("roles/common/files/ssh.cfg.template")
    src = Template(filein.read())
    del filein
    d = {
        'ssh_username':ssh_username,
        'ssh_keyfile':ssh_keyfile,
        'bastion_host_public':bastion_host_public,
        'bastion_host':bastion_host,
        'subnet_stars':subnet_stars,
        'ssh_config_flag':ssh_config_flag
        }
    result = src.substitute(d) + "\n"

    filein = open("roles/common/files/ssh.cfg.template.per_host")
    src = Template(filein.read())
    del filein

    d = {
        'hostname':"illume-bastion",
        'host_ip':bastion_host,
        'port':22,
        'ssh_username':ssh_username,
        'ssh_keyfile':ssh_keyfile,
        'bastion_host_public':bastion_host_public,
        'ssh_config_flag':ssh_config_flag
        }
    result += src.substitute(d) + "\n"

    for idx, address in enumerate(data['illume-proxy-addresses']['value']):
        d = {
            'hostname':"illume-proxy-{:02d}".format(idx+1),
            'host_ip':address,
            'port':22,
            'ssh_username':ssh_username,
            'ssh_keyfile':ssh_keyfile,
            'bastion_host_public':bastion_host_public,
            'ssh_config_flag':ssh_config_flag
            }
        result += src.substitute(d) + "\n"

    for idx, address in enumerate(data['illume-control-addresses']['value']):
        d = {
            'hostname':"illume-control-{:02d}".format(idx+1),
            'host_ip':address,
            'port':2222,
            'ssh_username':ssh_username,
            'ssh_keyfile':ssh_keyfile,
            'bastion_host_public':bastion_host_public,
            'ssh_config_flag':ssh_config_flag
            }
        result += src.substitute(d) + "\n"
    for worker_kind in worker_kinds:
        for idx, address in enumerate(data['illume-worker-{}-addresses'.format(worker_kind)]['value']):
            d = {
                'hostname':"illume-worker-{}-{:02d}".format(worker_kind, idx+1),
                'host_ip':address,
                'port':2222,
                'ssh_username':ssh_username,
                'ssh_keyfile':ssh_keyfile,
                'bastion_host_public':bastion_host_public,
                'ssh_config_flag':ssh_config_flag
                }
            result += src.substitute(d) + "\n"
    for idx, address in enumerate(data['illume-ingress-addresses']['value']):
        d = {
            'hostname':"illume-ingress-{:02d}".format(idx+1),
            'host_ip':address,
            'port':2222,
            'ssh_username':ssh_username,
            'ssh_keyfile':ssh_keyfile,
            'bastion_host_public':bastion_host_public,
            'ssh_config_flag':ssh_config_flag
            }
        result += src.substitute(d) + "\n"

    text_file = open(outfile, "w")
    text_file.write(result)
    text_file.close()


def main():
    # get data from  terraform output for injection in template
    tf_output= subprocess.Popen("terraform output -state=../terraform/terraform.tfstate -json", shell=True, stdout=subprocess.PIPE).stdout.read()
    data = json.loads(tf_output)

    subnet = data['subnet']['value']
    ssh_username = data['ssh-username']['value']
    ssh_keyfile  = data['ssh-key-file']['value']
    bastion_host_public = data['bastion-address-public']['value']
    bastion_host        = data['bastion-address']['value']

    # Write ssh config (for localhost)
    create_ssh_config(data, outfile="ssh.cfg", special_config_name="ssh.cfg")

    # Write ssh.cfg (for role)
    create_ssh_config(data, outfile="roles/common/files/ssh.cfg")

    #######################################################################

    all_worker_addresses_gpu = []
    all_worker_addresses_nogpu = []
    for worker_kind in worker_kinds:
        new_addr = data['illume-worker-{}-addresses'.format(worker_kind)]['value']
        if worker_kind[:5]=="nogpu":
            all_worker_addresses_nogpu += new_addr
        else:
            all_worker_addresses_gpu += new_addr

    # Substitute vars in template
    filein = open("inventory.template")
    src = Template(filein.read())
    d = {
        'bastion'      :data['bastion-address']['value']+" ansible_connection=ssh ansible_user="+ssh_username,
        'proxy'        :'\n'.join(x+" ansible_connection=ssh ansible_user="+ssh_username for x in data['illume-proxy-addresses']['value']),
        'control'      :'\n'.join(x+" ansible_connection=ssh ansible_port=2222 ansible_user="+ssh_username for x in data['illume-control-addresses']['value']),
        'worker_gpu'   :'\n'.join(x+" ansible_connection=ssh ansible_port=2222 ansible_user="+ssh_username for x in all_worker_addresses_gpu),
        'worker_nogpu' :'\n'.join(x+" ansible_connection=ssh ansible_port=2222 ansible_user="+ssh_username for x in all_worker_addresses_nogpu),
        'ingress'      :'\n'.join(x+" ansible_connection=ssh ansible_port=2222 ansible_user="+ssh_username for x in data['illume-ingress-addresses']['value']),
        }
    result = src.substitute(d)
    del filein
    # Write inventory (for ansible)
    text_file = open("inventory", "w")
    text_file.write(result)
    text_file.close()

    #######################################################################

    # Substitute vars in template
    filein = open("roles/rke/defaults/main.yml.template")

    rke_control_nodes = ""
    for idx, address in enumerate(data['illume-control-addresses']['value']):
        rke_control_nodes += "  - illume-control-{:02d}".format(idx+1) + "\n"

    # some worker nodes are GPU nodes, all worker nodes are storage nodes
    rke_gpu_nodes = ""
    rke_storage_nodes = ""
    for worker_kind in worker_kinds:
        for idx, address in enumerate(data['illume-worker-{}-addresses'.format(worker_kind)]['value']):
            worker_name = "illume-worker-{}-{:02d}".format(worker_kind, idx+1)
            if worker_kind != "nogpu":
                rke_gpu_nodes += "  - " + worker_name + "\n"
            rke_storage_nodes += "  - " + worker_name + "\n"

    src = Template(filein.read())
    d = {
        'rke_control_nodes' : rke_control_nodes,
        'rke_gpu_nodes'     : rke_gpu_nodes,
        'rke_storage_nodes' : rke_storage_nodes
        }
    result = src.substitute(d)
    del filein
    # Write inventory (for ansible)
    text_file = open("roles/rke/defaults/main.yml", "w")
    text_file.write(result)
    text_file.close()

    #######################################################################

    # Substitute vars in cvmfs configuration
    cvmfs_proxies = ["http://"+x+":3128" for x in data['illume-proxy-addresses']['value']]
    cvmfs_proxies = '|'.join(cvmfs_proxies)

    filein = open("roles/cvmfs/defaults/main.yml.template")
    src = Template(filein.read())
    d = {'cvmfs_proxies' : cvmfs_proxies, }
    result = src.substitute(d)
    del filein
    # Write inventory (for ansible)
    text_file = open("roles/cvmfs/defaults/main.yml", "w")
    text_file.write(result)
    text_file.close()

    #######################################################################

    # Substitute vars in docker configuration
    http_proxies = ["  - http://"+x+":3128/" for x in data['illume-proxy-addresses']['value']]
    http_proxies = '\n'.join(http_proxies)

    filein = open("roles/docker/defaults/main.yml.template")
    src = Template(filein.read())
    d = {'http_proxies' : http_proxies, }
    result = src.substitute(d)
    del filein
    # Write inventory (for ansible)
    text_file = open("roles/docker/defaults/main.yml", "w")
    text_file.write(result)
    text_file.close()

    #######################################################################

    # Write /etc/hosts file
    filein = open("roles/common/files/hosts.template")
    text_file = open("roles/common/files/hosts", "w")
    text_file.write(filein.read())

    text_file.write(bastion_host + " illume-bastion\n")
    for idx, address in enumerate(data['illume-proxy-addresses']['value']):
        text_file.write(address + " illume-proxy-{:02d}\n".format(idx+1))
    for idx, address in enumerate(data['illume-control-addresses']['value']):
        text_file.write(address + " illume-control-{:02d}\n".format(idx+1))
    for worker_kind in worker_kinds:
        for idx, address in enumerate(data['illume-worker-{}-addresses'.format(worker_kind)]['value']):
            text_file.write(address + " illume-worker-{}-{:02d}\n".format(worker_kind, idx+1))
    for idx, address in enumerate(data['illume-ingress-addresses']['value']):
        text_file.write(address + " illume-ingress-{:02d}\n".format(idx+1))

    text_file.close()
    del filein

    #######################################################################

    # create node configuration for rke

    node_configuration = ""
    for idx, address in enumerate(data['illume-control-addresses']['value']):
        node_configuration += """
  - address: {address}
    hostname_override: {hostname}
    user: {username}
    port: 2222
    role:
      - controlplane
      - etcd
        """.format(
            address=address,
            hostname="illume-control-{:02d}".format(idx+1),
            username=ssh_username)

    for worker_kind in worker_kinds:
        for idx, address in enumerate(data['illume-worker-{}-addresses'.format(worker_kind)]['value']):
            node_configuration += """
  - address: {address}
    hostname_override: {hostname}
    user: {username}
    port: 2222
    role:
      - worker
""".format(
                address=address,
                hostname="illume-worker-{}-{:02d}".format(worker_kind, idx+1),
                username=ssh_username)

            if worker_kind != "nogpu":
                accelerator_tags = {
                    "1080ti"  : "nvidia-gtx-1080ti",
                    "titanx"  : "nvidia-titanx",
                    "titanxp" : "nvidia-titanxp",
                }

                node_configuration += """    labels:
      accelerator: {accelerator_tag}
      has_nvidia_gpu: true
                """.format(
                    accelerator_tag=accelerator_tags[worker_kind]
                )


    for idx, address in enumerate(data['illume-ingress-addresses']['value']):
        node_configuration += """
  - address: {public_address}
    internal_address: {address}
    hostname_override: {hostname}
    user: {username}
    port: 2222
    role:
      - worker
    labels:
      app: ingress
        """.format(
            public_address=data['illume-ingress-addresses-public']['value'][idx],
            address=address,
            hostname="illume-ingress-{:02d}".format(idx+1),
            username=ssh_username)


    # Substitute vars in template
    filein = open("roles/rke/files/cluster.yml.template")
    src = Template(filein.read())
    d = {
        'node_configuration':node_configuration,
        'ssh_keyfile':ssh_keyfile
        }
    result = src.substitute(d)
    del filein

    # Write cluster.yml
    text_file = open("roles/rke/files/cluster.yml", "w")
    text_file.write(result)
    text_file.close()

if __name__ == '__main__':
    main()
