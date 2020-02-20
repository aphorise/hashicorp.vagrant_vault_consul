# HashiCorp `vagrant` template of **`vault`** with **`consul`**
This repo contains a `Vagrantfile` mocking an example [Vault](https://www.vaultproject.io/) + [Consul](https://www.consul.io/) cluster / setup defaults to a multi-node cluster of three (3) Consul & two (2) Vault instances. [Learning material on vault demonstrate](https://learn.hashicorp.com/vault/day-one/ops-vault-ha-consul) and 
[operational  reference architecture](https://learn.hashicorp.com/vault/operations/ops-reference-architecture).


## Makeup & Concept
A depiction below shows network [connectivity and overall PRC, Gossip, UDP/TCP port](https://learn.hashicorp.com/vault/operations/ops-reference-architecture#network-connectivity-details) expected to be produced.

```                      
      (Vault Storage Backend)                      
          CONSUL SERVERS:        ._________________.
                                 |     consul1     |
                              /--|_________________|--\
                             /      ▲      ▲           \
                            /       |      |            \
                           /     .__|______▼_______.     \
                          /    /-|  |  consul2     |-\    \
                         /    /  |__|______________|  \    \
                        /    /      |         ▲        \    \
                       /    /       |         |         \    \
                      /    /     .__▼_________▼____.     \    \
                     /    /      |     consul3     |      \    \
                    /    /       |_________________|       \    \
                   /    /       /                   \       \    \
                  /    /       /                     \       \    \
                 /     |      /                       \       |    \
                .|_____|_____/____.               .____\______|____|.
 VAULT SERVERS: |     vault1 &    |               |     vault2 &    |
  (HA Mode)     |  consul-client  |◄-------------►|  consul-client  |
                |_________________|               |_________________|
```


### Prerequisites
Ensure that you already have the following hardware & software requirements:
 
##### HARDWARE
 - **RAM** **7.5**+ Gb Free at least (ensure you're not hitting SWAP either or are < 100Mb)
 - **CPU** **5**+ Cores Free at least (2 or more per instance better)
 - **Network** interface allowing IP assignment and interconnection in VirtualBox bridged mode for all instances.
 - - adjust `sNET='en0: Wi-Fi (Wireless)'` in **`Vagrantfile`** to match your system.

##### SOFTWARE
 - [**Virtualbox**](https://www.virtualbox.org/)
 - [**Virtualbox Guest Additions (VBox GA)**](https://download.virtualbox.org/virtualbox/)
 - > **MacOS** (aka OSX) - VirtualBox 6.x+ is expected to be shipped with the related .iso present under (eg):
 `/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso`
You may however need to download the .iso specific to your version (mount it) and execute the VBoxDarwinAdditions.pkg
 - [**Vagrant**](https://www.vagrantup.com/)
 - **Few** (**2-5**) **`shell`** or **`screen`** sessions to allow for multiple SSH sessions.
 - :lock: **NOTE**: An [enterprise license](https://www.hashicorp.com/products/vault/pricing/) will be required for [performance standbys](https://www.vaultproject.io/docs/enterprise/performance-standby/) & some other [replication](https://www.vaultproject.io/docs/enterprise/replication/) features (not needed for this demo but bare in mind if making related changes).


## Usage & Workflow
Refer to the contents of **`Vagrantfile`** for the number of instances, resources, Network, IP and provisioning steps.

The provided **`.sh`** script are installer helpers that download the latest binaries (or specific versions) and can install server / client mode systemd services.

**Inline Environment Variables** can be set for specific versions, modes (server / client), license and other settings that are part of `2.install_consul.sh` & `3.install_vault.sh`.

```bash
vagrant up --provider virtualbox ; # or 'vagrant reload' when adjusting Vagrantfile.
# // ... output of provisioning steps.

vagrant global-status --prune ; # should show running nodes
# id       name    provider   state   directory
# ------------------------------------------------------------------------------
# 3f34dad  consul1 virtualbox running /home/auser/hashicorp.vagrant-vault-consul
# 5f6a89e  consul2 virtualbox running /home/auser/hashicorp.vagrant-vault-consul
# 6f022ab  consul3 virtualbox running /home/auser/hashicorp.vagrant-vault-consul
# 83306f1  vault1  virtualbox running /home/auser/hashicorp.vagrant-vault-consul
# 26675b5  vault2  virtualbox running /home/auser/hashicorp.vagrant-vault-consul

# // On a separate Terminal session check status of consul1 & its members.
vagrant ssh consul1
# // ...
vagrant@consul1:~$ \
consul members list
# Node     Address              Status  Type    Build      Protocol  DC   Segment
# consul1  192.168.77.1:8301    alive   server  1.5.1      2         dc1  <all>
# consul2  192.168.77.2:8301    alive   server  1.5.1      2         dc1  <all>
# consul3  192.168.77.3:8301    alive   server  1.5.1      2         dc1  <all>
# vault1   192.168.77.253:8301  alive   client  1.5.1      2         dc1  <default>
# vault2   192.168.77.252:8301  alive   client  1.5.1      2         dc1  <default>

# // On a separate Terminal session SSH to vault1 & perform operations.
vagrant ssh vault1
# // ...
vagrant@vault1:~$ \
vault operator init ;  # // note / pipe tokens & keys.
# // ...
vault operator unseal ; # // followed by keys - repeated.
# // ...
# // ... continue with setup then unseal vault2.

# // On a separate Terminal session SSH to vault1 & perform operations.
vagrant ssh vault2
# // ...
vagrant@vault2:~$ \
vault operator unseal ; # // followed by keys - repeated.
# // ...
vault login
vault status

# // ---------------------------------------------------------------------------
# when completely done:
vagrant destroy -f consul1 consul2 consul3 vault1 vault2 ; # ... destroy al
vagrant box remove -f debian/buster64 --provider virtualbox ; # ... delete box images
```


## Notes
This is intended as a mere practise / training exercise.

Other use cases that can be extended from this template can include:
 - [ ] [Vault PKI Secrets Engine & Vault as Certificate Authority](https://learn.hashicorp.com/vault/secrets-management/sm-pki-engine)
 - [ ] [Other Vault Secrets Engines & Ops](https://learn.hashicorp.com/vault?track=operations#operations)

------
