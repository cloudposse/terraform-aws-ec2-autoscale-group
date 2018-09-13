provider "aws" {
  region = "us-west-2"
}

locals {
  userdata = <<USERDATA
    #!/bin/bash -xe
    CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki
    CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt
    mkdir -p $CA_CERTIFICATE_DIRECTORY
    echo XXXXXXXXXXXX | base64 -d >  $CA_CERTIFICATE_FILE_PATH
    INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    sed -i s,MASTER_ENDPOINT,master.us-west-2.testing.cloudposse.co,g /var/lib/kubelet/kubeconfig
    sed -i s,CLUSTER_NAME,us-west-2.testing.cloudposse.co,g /var/lib/kubelet/kubeconfig
    sed -i s,REGION,us-west-2,g /etc/systemd/system/kubelet.service
    sed -i s,MAX_PODS,20,g /etc/systemd/system/kubelet.service
    sed -i s,MASTER_ENDPOINT,master.us-west-2.testing.cloudposse.co,g /etc/systemd/system/kubelet.service
    sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service
    DNS_CLUSTER_IP=10.100.0.10
    if [[ $INTERNAL_IP == 10.* ]] ; then DNS_CLUSTER_IP=172.20.0.10; fi
    sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g /etc/systemd/system/kubelet.service
    sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig
    sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g  /etc/systemd/system/kubelet.service
    systemctl daemon-reload
    systemctl restart kubelet
  USERDATA
}

module "autoscale_group" {
  #source = "git::https://github.com/cloudposse/terraform-aws-ec2-autoscale-group.git?ref=master"
  source = "../../"

  namespace = "eg"
  stage     = "dev"
  name      = "test"

  launch_configuration_enabled            = "true"
  autoscaling_group_enabled               = "true"
  image_id                                = "ami-08cab282f9979fc7a"
  instance_type                           = "t2.small"
  security_groups                         = ["sg-xxxxxxxx"]
  subnet_ids                              = ["subnet-xxxxxxxx", "subnet-yyyyyyyy", "subnet-zzzzzzzz"]
  health_check_type                       = "EC2"
  min_size                                = 1
  max_size                                = 3
  desired_capacity                        = 2
  wait_for_capacity_timeout               = "5m"
  associate_public_ip_address             = true
  root_block_device_volume_type           = "gp2"
  root_block_device_volume_size           = "50"
  root_block_device_delete_on_termination = true

  user_data_base64 = "${base64encode(local.userdata)}"

  ebs_block_device = [
    {
      device_name           = "/dev/xvdd"
      volume_type           = "gp2"
      volume_size           = "100"
      delete_on_termination = true
    },
  ]

  tags {
    Tier              = "1"
    KubernetesCluster = "us-west-2.testing.cloudposse.co"
  }

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled = "true"
  high_cpu_threshold_percent   = "70"
  low_cpu_threshold_percent    = "20"
}
