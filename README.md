## Deployment

```shel
$ stackit auth login
Successfully logged into STACKIT CLI.
```

```console
$ export STACKIT_SERVICE_ACCOUNT_TOKEN=$(stackit auth get-access-token 2>/dev/stdout)
```

```console
$ export TF_VAR_project_id=$(stackit project describe | jq -r ".projectId")
```

```console
$ terraform init
Initializing the backend...
Initializing provider plugins...
- Reusing previous version of hashicorp/cloudinit from the dependency lock file
- Reusing previous version of stackitcloud/stackit from the dependency lock file
- Using hashicorp/cloudinit v2.3.6 from the shared cache directory
- Using stackitcloud/stackit v0.44.0 from the shared cache directory

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```console
$ terraform apply
data.cloudinit_config.backend: Reading...
data.cloudinit_config.backend: Read complete after 0s [id=3677671302]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

[...]

Plan: 18 to add, 0 to change, 0 to destroy.

[...]

Apply complete! Resources: 18 added, 0 changed, 0 destroyed.
```
