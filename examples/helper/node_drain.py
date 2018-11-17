import json
import subprocess
import argparse

# Python 3.5 required

# Use the following commands to get list on nodes you want to drain
#  curl -k  'https://nomad.address/v1/nodes?pretty' | jq '.[] | {dc: .Datacenter, id: .ID, instance: .Name, status: .Status} |  select(.dc=="private-services") | select(.status=="ready") | .id '
# aws ec2 describe-tags --profile=default --region=eu-central-1 | jq '.Tags | .[] | select(.Key=="teg_key") | select(.Value=="tag_value")'


def select_ec2_instances_by_tag(key, value, profile, region):
    aws_cmd = [
        "aws", "ec2", "describe-tags",
        "--profile", profile,
        "--region", region,
    ]
    with open('ec2_tags.json', "w") as outfile:
        subprocess.call(aws_cmd, stdout=outfile)

    jq_filter_cmd = [
        "jq", "-r",
        "[.Tags | .[] | select(.Key==\"%s\") | select(.Value==\"%s\") | .ResourceId]" % (key, value),
        "ec2_tags.json"
    ]
    proc = subprocess.run(jq_filter_cmd, stdout=subprocess.PIPE)
    ids_object = proc.stdout.decode()
    ids = json.loads(ids_object)
    print(ids)
    return ids


def select_nomad_clients_by_ec2_ids(ec2_ids, nomad_addr):
    curl_cmd = [
        "curl", "-k", nomad_addr + "/v1/nodes?pretty"
    ]
    with open('nomad_clients.json', "w") as outfile:
        subprocess.call(curl_cmd, stdout=outfile)

    jq_filter_cmd = [
        "jq", "-r",
        # we can do some filtering here
        # ".[] | {dc: .Datacenter, id: .ID, instance: .Name, status: .Status} |  select(.dc=="private-services") | select(.status=="ready") | .id",
        "[.[] | {dc: .Datacenter, id: .ID, instance: .Name, status: .Status} ]",
        "nomad_clients.json"
    ]
    proc = subprocess.run(jq_filter_cmd, stdout=subprocess.PIPE)
    nomad_clients_object = proc.stdout.decode()
    nomad_clients = json.loads(nomad_clients_object)

    nomad_client_ids = []
    for node in nomad_clients:
        if node["instance"] in ec2_ids:
            nomad_client_ids.append(node["id"])

    return nomad_client_ids


if __name__ == "__main__":
    nomad_options = "-tls-skip-verify"
    drain_deadline = "15m"

    parser = argparse.ArgumentParser(description="Initiate nomad nodes draining based on EC2 instance tags")
    parser.add_argument("--no-dry", help="Apply real commands", default=False, action='store_true')
    parser.add_argument("--tag", help="Tag key for nodes selection", required=True)
    parser.add_argument("--value", help="Tag value for nodes selection", required=True)
    parser.add_argument("--region", help="AWS  region", required=True)
    parser.add_argument("--profile", help="AWS credentials profile", required=True)
    parser.add_argument("--nomad", help="Nomad cluster URL", required=True)

    args = parser.parse_args()

    ec2_ids = select_ec2_instances_by_tag(args.tag, args.value, args.profile, args.region)

    print("EC2 instance selected (%d): " % len(ec2_ids))
    for id in ec2_ids:
        print("\t" + id)

    nodes_to_drain = select_nomad_clients_by_ec2_ids(ec2_ids, args.nomad)
    print("Nomad clients selected (%d): " % len(nodes_to_drain))
    for id in nodes_to_drain:
        print("\t" + id)

    print("Start draining:")

    for node in nodes_to_drain:
        cmd = ["nomad", "node-drain", "-address", args.nomad, nomad_options, "-deadline", drain_deadline, "-enable",
               "-detach", node]
        print("\t" + " ".join(cmd))
        if args.no_dry:
            out = subprocess.call(cmd)
            if out != 0:
                print(out)
