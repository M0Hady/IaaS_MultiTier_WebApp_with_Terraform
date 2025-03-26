resource "aws_autoscaling_group" "T_ASG" {
  vpc_zone_identifier = [
    aws_subnet.T_Subnets["Priv_Sub1"].id,
    aws_subnet.T_Subnets["Priv_Sub2"].id
  ]
  
  desired_capacity     = 2
  max_size            = 4
  min_size            = 2

  launch_template {
    id      = aws_launch_template.T_LT.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "T_WebApp"
    propagate_at_launch = true
  }
}



resource "aws_launch_template" "T_LT" {
  name_prefix   = "T_LT"
  image_id      = "ami-0ace34e9f53c91c5d"
  instance_type = "t2.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.T_EC2_Instance_Profile.name
  }
  vpc_security_group_ids = [aws_security_group.T_SG.id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 10
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    systemctl start httpd
    systemctl enable httpd
    echo "Web Server $(hostname)" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "T_WebApp"
    }
  }
}


resource "aws_autoscaling_attachment" "T_ASG_Attach" {
  autoscaling_group_name = aws_autoscaling_group.T_ASG.id
  lb_target_group_arn    = aws_lb_target_group.T_TargetGroup.arn
}


resource "aws_autoscaling_policy" "T_ScaleDown" {
  name                   = "T_ScaleDown"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 60
  autoscaling_group_name = aws_autoscaling_group.T_ASG.name
}


resource "aws_autoscaling_policy" "T_ScaleUp" {
  name                   = "T_ScaleUp"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 60
  autoscaling_group_name = aws_autoscaling_group.T_ASG.name
}

resource "aws_cloudwatch_metric_alarm" "T_CPUHigh" {
  alarm_name          = "T_CPUHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name        = "CPUUtilization"
  namespace         = "AWS/EC2"
  period            = 60
  statistic         = "Average"
  threshold        = 70
  alarm_description = "Scale up if CPU usage exceeds 70% for 2 minutes"
  alarm_actions     = [aws_autoscaling_policy.T_ScaleUp.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.T_ASG.name
  }
}

resource "aws_cloudwatch_metric_alarm" "T_CPULow" {
  alarm_name          = "T_CPULow"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name        = "CPUUtilization"
  namespace         = "AWS/EC2"
  period            = 60
  statistic         = "Average"
  threshold        = 30
  alarm_description = "Scale down if CPU usage falls below 30% for 2 minutes"
  alarm_actions     = [aws_autoscaling_policy.T_ScaleDown.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.T_ASG.name
  }
}