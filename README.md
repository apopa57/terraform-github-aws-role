This is a proof of concept for how to [Configure OpenID Connect in AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

Please note that the role mentioned in the action has already been deleted.

If you apply the configuration, you can get the role ARN from the Terraform outputs.

Please note this does not work with CCoE accounts out of the box.

## How to apply the Terraform configuration
```
terraform init
AWS_PROFILE=... terraform apply
```
