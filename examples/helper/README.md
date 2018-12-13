# Nomad Helper Scripts

* [get_nomad_client_info.sh](get_nomad_client_info.sh)
* [get_nomad_server_ip.sh](get_nomad_server_ip.sh)
* [get_nomad_subnet_mask.sh](get_nomad_subnet_mask.sh)
* [nomad-examples-helper.sh](nomad-examples-helper.sh)
* [node-drain](NodeDrain.md) ... A script to do a script based node draining.

## Setup

To use the scripts you have do to the following set up.

```bash
cd examples/helper

# Add script folder to PATH
script_dir=$(pwd) && export PATH=$PATH:$script_dir

# Option 1 Set AWS profile
export AWS_PROFILE=playground

# Option 2 call the script with the profile name
# <script> <profile>
# i.e.
get_nomad_server_ip.sh playground
```