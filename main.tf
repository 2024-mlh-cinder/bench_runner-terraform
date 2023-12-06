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

   cd home/ubuntu
   mkdir actions-runner && cd actions-runner
   curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz 2>&1 | tee curl-logs.txt
   tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz 2>&1 | tee tar-logs.txt

   RUNNER_ALLOW_RUNASROOT="1" ./config.sh --url https://github.com//cinder_bench_runner --token "${var.register_token}" --runnergroup "Default" --name "benchrunner" --labels "self-hosted,Linux,X64" --work "_work" 2>&1 | tee config-logs.txt

   ./run.sh

   sudo ./svc.sh install
   sudo ./svc.sh start
   sudo ./svc.sh status

  EOF

  tags = {
    Name = "BenchmarkingEC2Runner"
  }
}
