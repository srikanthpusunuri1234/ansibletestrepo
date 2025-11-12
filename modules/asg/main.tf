
data "aws_iam_role" "existing_role" {
  name = "s3_get_list_role"
}

data "aws_iam_instance_profile" "existing_instance_profile" {
  name = "s3_get_list_role"
}

# Launch Template
resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.ec2_key_name
  iam_instance_profile {
    name = data.aws_iam_instance_profile.existing_instance_profile.name
  }
  user_data = filebase64("${path.module}/bootstrap.sh")

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.asg_sg_id
  }
/*
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 8         # 70 GB EBS volume
      volume_type           = "gp3"      # General Purpose SSD
      delete_on_termination = true       # Automatically clean up when instance is terminated
      encrypted             = true       # Optional but recommended
    }
  }
*/
  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name}-instance"
      Role = "app-server"      # for prometheous autoscrape using label
    }
  }

  # A dummy tag that changes with each deployment for asg instance refresh triggering
  tags = {
    latest_version = var.app_version
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "this" {
  name                       = "${var.name}-asg"
  min_size                   = var.min_size
  max_size                   = var.max_size
  desired_capacity           = var.desired_capacity
  vpc_zone_identifier        = var.subnet_ids
  health_check_type          = "ELB"
  force_delete               = true         # change this to false in production
  health_check_grace_period  = 300

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  # Attach ASG to  ALB Target Group (from alb module)
  target_group_arns = [var.target_group_arn]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
    }
    # triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_scale_out" {
  name                   = "${var.name}-cpu-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 30.0
  }

  estimated_instance_warmup = 300   # to control the short spike scalling
  
}
