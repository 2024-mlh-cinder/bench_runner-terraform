terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

variable "register_token" {}

resource "aws_instance" "bench_runner" {
  ami           = "ami-093467ec28ae4fe03"
  instance_type = "t2.micro"
  key_name      = "bench-runner"
  user_data     = <<-EOF
    #!/bin/bash

    sudo hostnamectl set-hostname cinder-benchmarking-aws
    sudo dnf install -y lttng-ust openssl-libs krb5-libs zlib libicu

    su ec2-user <<'EOF2'
      cd ~ec2-user
      mkdir actions-runner && cd actions-runner
      curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
      tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
      rm -f ./actions-runner-linux-x64-2.311.0.tar.gz

      ./config.sh --url https://github.com/2014-mlh-cinder/bench_runner-results --token "${var.register_token}" --runnergroup "Default" --name "benchrunner" --labels "self-hosted,Linux,X64" --work "_work"
    EOF2
  EOF

  tags = {
    Name = "BenchmarkingEC2Runner"
  }
}
