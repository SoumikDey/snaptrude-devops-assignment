## SCALING PARAMETERS
# <5 - low end
# >5 -1 high end
# >10 - 2 high end


module "low_end_asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "low-end-node-asg"

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = ["subnet-0b9787a45292c548f", "subnet-04de3a54ccf0f851d"]

  # Launch template
  launch_template_name        = "node-asg"
  launch_template_description = "Launch template asg"
  update_default_version      = true

  image_id          = "ami-04a94c144c2e133df"
  instance_type     = "t3.micro"
  ebs_optimized     = true
  enable_monitoring = true

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = "low-end-node-asg"
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role for ASG"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 30
        volume_type           = "gp3"
      }
    }
  ]

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = ["sg-0bd4033715c583e75"]
    }
  ]

  target_group_arns = ["arn:aws:elasticloadbalancing:ap-southeast-1:167814279506:targetgroup/low-end-node-tg/47eb294ec184ab68"]


  tag_specifications = [
    {
      resource_type = "instance"
      tags          = { WhatAmI = "Instance" }
    },
    {
      resource_type = "volume"
      tags          = { WhatAmI = "Volume" }
    },
  ]

  tags = {
    Environment = "dev"
    Project     = "snaptrude"
  }
}
