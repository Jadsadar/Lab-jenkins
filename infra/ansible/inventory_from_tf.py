"""Build the Ansible inventory from `terraform output -json` (Lab 08 dynamic inventory).

Usage: python3 inventory_from_tf.py <tf-outputs.json> <inventory.ini>

The host is named after the Terraform instance id and carries the instance address as
tf_address. ansible_host is that address, unless TARGET_HOST_OVERRIDE is set: LocalStack's
free EC2 is a mock with no machine behind its IP, so the pipeline points SSH at the
stand-in container (infra/lab-host) while keeping everything else from Terraform.
SSH user and key file come from ANSIBLE_SSH_USER / ANSIBLE_SSH_KEY (Jenkins credential).
"""
import json
import os
import sys

outputs_path, inventory_path = sys.argv[1], sys.argv[2]
with open(outputs_path) as f:
    outputs = {name: item["value"] for name, item in json.load(f).items()}

address = outputs["instance_address"]
host_vars = {
    "ansible_host": os.environ.get("TARGET_HOST_OVERRIDE") or address,
    "tf_address": address,
    "ansible_user": os.environ["ANSIBLE_SSH_USER"],
    "ansible_ssh_private_key_file": os.environ["ANSIBLE_SSH_KEY"],
    "ansible_python_interpreter": "auto_silent",
}
line = outputs["instance_id"] + " " + " ".join(f"{k}={v}" for k, v in host_vars.items())

with open(inventory_path, "w") as f:
    f.write("[taskflow]\n" + line + "\n")
print(open(inventory_path).read(), end="")
