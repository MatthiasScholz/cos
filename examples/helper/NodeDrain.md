# Node-Drain

This is a simple script that helps draining nomad nodes.
The nodes to be drained can be filtered using EC2 instance tags.
Per default the script uses a drain-deadline of 15 min.

## Preconditions
* Python has to be installed
* [jq](https://stedolan.github.io/jq/) has to be installed
* [aws cli](https://aws.amazon.com/cli/) has to be installed
* [nomad](https://www.nomadproject.io) has to be installed

## Run the Script

```bash
# generic call
python3 node_drain.py --profile=<aws-profile> --region=<aws-region> --tag=<EC2-tag-name> --value=<EC2-tag-value> --nomad=<http-addr-of-nomad> --no-dry

# example (dry-mode)
python3 node_drain.py --profile=prod --region=eu-central-1 --tag=nomad_version --value=0.8.6 --nomad=https://nomad.mycompany.com

# example (live-mode)
python3 node_drain.py --profile=prod --region=eu-central-1 --tag=nomad_version --value=0.8.6 --nomad=https://nomad.mycompany.com --no-dry
```