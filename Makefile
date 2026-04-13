TF_DIR=terraform
ANSIBLE_DIR=ansible

.PHONY: tf-init tf-plan tf-apply tf-output ansible-deps bootstrap install-controller register-hosts patch-linux

tf-init:
	cd $(TF_DIR) && terraform init

tf-plan:
	cd $(TF_DIR) && terraform plan

tf-apply:
	cd $(TF_DIR) && terraform apply

tf-output:
	cd $(TF_DIR) && terraform output

ansible-deps:
	cd $(ANSIBLE_DIR) && ansible-galaxy collection install -r requirements.yml

bootstrap:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventories/prod/hosts.yml playbooks/01-bootstrap-linux.yml

install-controller:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventories/prod/hosts.yml playbooks/02-install-automation-controller.yml

register-hosts:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventories/prod/hosts.yml playbooks/03-configure-controller-and-inventory.yml

patch-linux:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventories/prod/hosts.yml playbooks/04-linux-patching-demo.yml
