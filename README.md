# AWS/S3 Website Boilerplate

This is a boilerplate [Terraform](https://www.terraform.io/) setup for creating infrastructure for hosting a site on S3, with a CloudFront CDN in front of it, and DNS records managed by CloudFlare.

## Requirements

* Terraform CLI - Version 0.14 or higher
* AWS account
* CloudFlare account

## Use

Set required environment variables:

```bash
export TF_VAR_aws_access_key_id=$YOUR_AWS_ACCESS_KEY_ID
export TF_VAR_aws_secret_access_key=$YOUR_AWS_SECRET_ACCESS_KEY
export TF_VAR_cloudflare_api_key=$YOUR_CLOUDFLARE_API_KEY
```

Set remaining required variables in `terraform.tfvars`.

Run `terraform plan` to verify correct configuration.

Run `terraform apply` to execute.

