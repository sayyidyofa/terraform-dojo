# Dojo Terraform

# Advanced usage of Terraform: An example use-case

To follow this example, make sure your local machine:
 - Has Ansible installed
 - Has Terraform CLI installed
 - Has ssh client installed
 - Has a bash-compatible default shell

Let's say hypothetically you are tasked to manage a VM state with Terraform.
It is hosted in Google Cloud Platform (GCP) with following requirements:

 - The user don't want to access the VM via GCP console. Instead you will be supplied with `private_key` and `public_key` from your user to be injected to the VM as means to SSH later
 - The user wants to automate some service setup in the VM with Ansible playbooks. Here the specific service to be set-up is a nginx server, available in `playbok.yml`. This has to be executed after the VM is online
 - Since the VM uses Red Hat Enterprise Linux as it's OS, your user wants it to be automatically registered to the Red Hat subscription. You will be supplying the user's Red Hat login credentials in the `redhat_username` and `redhat_password` variable