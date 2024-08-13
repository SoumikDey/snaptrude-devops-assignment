## SCALING PARAMETERS
# <5 - low end
# >5 -1 high end
# >10 - 2 high end


module "high_end_asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "high-end-node-asg"

  min_size                  = 0
  max_size                  = 3
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.subnet_ids

  # Launch template
  launch_template_name        = "high-end-node-asg"
  launch_template_description = "Launch template asg"
  update_default_version      = true

  image_id          = "ami-04a94c144c2e133df"
  instance_type     = "t3.micro"
  ebs_optimized     = true
  enable_monitoring = true

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = "high-end-node-asg"
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
      security_groups       = var.security_groups
    }
  ]

  use_mixed_instances_policy = true
  mixed_instances_policy = {
    instance_type = "c6g.large"
  }


  target_group_arns = [ var.high_end_target_group_arn ]

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
