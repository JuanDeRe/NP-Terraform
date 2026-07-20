data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "service" {
  name_prefix = "${var.project_name}-${var.environment}-${var.service_name}-"

  description = "Security group for ${var.service_name} instances."

  vpc_id = var.vpc_id

  ingress {
    description = "HTTP from Application Load Balancer"

    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"

    security_groups = [
      var.alb_security_group_id
    ]
  }

  ingress {
    description = "Internal HTTP between Nightwatch services"

    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"

    cidr_blocks = [
      var.vpc_cidr_block
    ]
  }

  dynamic "ingress" {
    for_each = var.additional_alb_ports

    content {
      description = "Additional application port from ALB"

      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"

      security_groups = [
        var.alb_security_group_id
      ]
    }
  }

  egress {
    description = "Allow outbound traffic"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-${var.service_name}-sg"
  }
}

resource "aws_launch_template" "service" {
  name_prefix = "${var.project_name}-${var.environment}-${var.service_name}-"

  image_id      = data.aws_ssm_parameter.amazon_linux.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  vpc_security_group_ids = [
    aws_security_group.service.id
  ]

  user_data = base64encode(
    templatefile(
      "${path.module}/user-data.sh.tftpl",
      {
        image_uri                        = var.image_uri
        service_name                     = var.service_name
        environment_variables            = var.environment_variables
        enable_game_instance_identity    = var.enable_game_instance_identity
        enable_gateway_instance_identity = var.enable_gateway_instance_identity
      }
    )
  )

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 12
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-${var.environment}-${var.service_name}"

      Service = var.service_name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "service" {
  name_prefix = "${var.project_name}-${var.environment}-${var.service_name}-"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = var.subnet_ids

  target_group_arns = [
    var.target_group_arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.service.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 180
    }
  }

  tag {
    key = "Name"

    value = "${var.project_name}-${var.environment}-${var.service_name}"

    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}

resource "aws_autoscaling_policy" "cpu" {
  count = var.max_size > var.min_size ? 1 : 0

  name = "${var.project_name}-${var.environment}-${var.service_name}-cpu"

  autoscaling_group_name = aws_autoscaling_group.service.name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50
  }
}