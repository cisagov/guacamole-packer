module "iam_user" {
  source = "github.com/cisagov/ami-build-iam-user-tf-module"

  providers = {
    aws                       = aws
    aws.images-production-ami = aws.images-production-ami
    aws.images-production-ssm = aws.images-production-ssm
    aws.images-staging-ami    = aws.images-staging-ami
    aws.images-staging-ssm    = aws.images-staging-ssm
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
  ]
  user_name = "build-guacamole-packer"
}
