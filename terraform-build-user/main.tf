module "iam_user" {
  source = "github.com/cisagov/ami-build-iam-user-tf-module"

  providers = {
    aws            = aws
    aws.images-ami = aws.images-ami
    aws.images-ssm = aws.images-ssm
  }

  ssm_parameters = [
    "/guacamole/postgres_username",
    "/guacamole/postgres_password",
    "/rdp/username",
    "/rdp/password",
    "/vnc/ssh/ed25519_private_key",
    "/vnc/username",
    "/vnc/password",
    "/vnc/sftp/windows_base_directory",
    # Necessary when building any instances that run the Wazuh agent
    "/wazuh_agent/manager",
  ]
  user_name = "build-guacamole-packer"
}
