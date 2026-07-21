resource "aws_security_group" "service" {
  name_prefix = "${var.project_name}-${var.environment}-${var.service_name}-"

  description = "Security group for ${var.service_name} instances."

  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-${var.service_name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.service.id

  referenced_security_group_id = (
    var.alb_security_group_id
  )

  description = "HTTP from Application Load Balancer"

  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"

  tags = {
    Name = "${var.project_name}-${var.environment}-${var.service_name}-alb-http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "additional_alb_ports" {
  for_each = var.additional_alb_ports

  security_group_id = aws_security_group.service.id

  referenced_security_group_id = (
    var.alb_security_group_id
  )

  description = "Additional application port from ALB"

  from_port   = each.value
  to_port     = each.value
  ip_protocol = "tcp"

  tags = {
    Name = "${var.project_name}-${var.environment}-${var.service_name}-alb-${each.value}"
  }
}

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.service.id

  description = "Allow outbound IPv4 traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = {
    Name = "${var.project_name}-${var.environment}-${var.service_name}-egress"
  }
}

resource "aws_launch_template" "service" {
  name_prefix = "${var.project_name}-${var.environment}-${var.service_name}-"

  image_id      = var.ami_id
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
        aws_region                       = var.aws_region
        cloudwatch_log_group_name        = var.cloudwatch_log_group_name
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
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

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
    disable_scale_in = var.disable_scale_in

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50
  }
}