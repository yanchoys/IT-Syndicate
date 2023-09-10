### Terraform Code
```
provider "aws" {
  region     = "us-east-1" # Замените на ваш регион
  access_key = "AKIAZ2QKJAR7CYZ4MLEQ"
  secret_key = "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"
}

# Создание группы безопасности
resource "aws_security_group" "terraform_sec_group" {
  name   = "terraform_sec"
  vpc_id = "vpc-0f19adefdd84a530c"
  egress {
    cidr_blocks = ["0.0.0.0/0", ]
    description = ""
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0", ]
    description = ""
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0", ]
    description = ""
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", ]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", ]
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0", ]
    description = ""
    from_port   = 3000
    protocol    = "tcp"
    to_port     = 3000
  }

}

# Создание launch template


# Создание таргет-группы
resource "aws_lb_target_group" "example_target_group" {
  name        = "example-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0f19adefdd84a530c" # Используйте ваш ID VPC
  target_type = "instance"              # Или "ip" в зависимости от ваших потребностей
}

# Создание балансировщика нагрузки
resource "aws_lb" "example_lb" {
  name                       = "example-lb"
  internal                   = false
  load_balancer_type         = "application"                                                                                                                                                            # Или "network" в зависимости от ваших потребностей
  subnets                    = ["subnet-05a21e2cbf55f7ada", "subnet-063800a603f8d2096", "subnet-005c2375e2805546f", "subnet-01eac0ea8889e29e7", "subnet-09ab9b1751a04a9bb", "subnet-08f161168ef3d6aee"] # Замените на ваши субнеты
  enable_deletion_protection = false                                                                                                                                                                    # Установите true, если нужно включить защиту от удаления
  security_groups            = [aws_security_group.terraform_sec_group.id]

  enable_http2 = true # Настройки балансировщика, по желанию
}

# Создание правила балансировки
resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.example_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      status_code  = "200"
      content_type = "text/plain"
    }
  }
}


resource "aws_autoscaling_group" "this" {
  name                      = "ASG_test"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = ["subnet-05a21e2cbf55f7ada", "subnet-063800a603f8d2096", "subnet-005c2375e2805546f", "subnet-01eac0ea8889e29e7", "subnet-09ab9b1751a04a9bb", "subnet-08f161168ef3d6aee"]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"
  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }
}

resource "aws_launch_template" "this" {
  name          = "Launch_tmp"
  image_id      = "ami-0f409bae3775dc8e5"
  instance_type = "t2.micro"
  user_data     = filebase64("${path.module}/ec2-init.sh")


  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.terraform_sec_group.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 10 # Размер корневого диска
      volume_type = "gp2"
    }
  }

  # Другие настройки launch template
}


resource "aws_autoscaling_policy" "scale_up" {
  name                   = "asg-scale-up"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1" #increasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30" # New instance will be created once CPU utilization is higher than 30 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.this.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" # decreasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5" # Instance will scale down when CPU utilization is lower than 5 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.this.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down.arn]
}
resource "aws_lb_target_group_attachment" "example_target_attachment" {
  count            = length(aws_autoscaling_group.this.load_balancers)
  target_group_arn = aws_lb_target_group.example_target_group.arn
  target_id        = aws_autoscaling_group.this.id
}
```
#### Output loadBalancer
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/9febac4a-08a1-41d5-98e3-181384c1cbe4)
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/04b7d788-f382-47ee-835f-843171e38ff8)
#### Scaling Policies
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/16f0b884-8025-440e-9199-06f435b6a3d7)

#### Inspector
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/c5a53eb3-8c0e-4bf9-a847-2fb8e507f645)

