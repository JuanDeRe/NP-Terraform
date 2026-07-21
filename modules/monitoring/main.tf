locals {
  alarm_prefix = "${var.project_name}-${var.environment}"

  service_labels = {
    auth        = "AuthService"
    matchmaking = "MatchmakingService"
    gateway     = "RealtimeGateway"
    game        = "GameService"
  }
}
resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  for_each = var.target_group_arn_suffixes

  alarm_name = "${local.alarm_prefix}-${each.key}-unhealthy-targets"

  alarm_description = "${local.service_labels[each.key]} has one or more unhealthy targets."

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"

  statistic = "Maximum"
  period    = 60

  evaluation_periods  = 2
  datapoints_to_alarm = 2

  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = each.value
  }

  alarm_actions = var.alarm_actions

  tags = {
    Name    = "${local.alarm_prefix}-${each.key}-unhealthy"
    Service = each.key
  }
}
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name = "${local.alarm_prefix}-alb-5xx"

  alarm_description = (
    "Application Load Balancer is producing HTTP 5XX responses."
  )

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"

  statistic = "Sum"
  period    = 300

  evaluation_periods  = 1
  datapoints_to_alarm = 1

  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = var.alarm_actions

  tags = {
    Name = "${local.alarm_prefix}-alb-5xx"
  }
}
resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  for_each = var.target_group_arn_suffixes

  alarm_name = "${local.alarm_prefix}-${each.key}-target-5xx"

  alarm_description = "${local.service_labels[each.key]} generated five or more HTTP 5XX responses in five minutes."

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"

  statistic = "Sum"
  period    = 300

  evaluation_periods  = 1
  datapoints_to_alarm = 1

  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = each.value
  }

  alarm_actions = var.alarm_actions

  tags = {
    Name    = "${local.alarm_prefix}-${each.key}-target-5xx"
    Service = each.key
  }
}
resource "aws_cloudwatch_metric_alarm" "target_latency" {
  for_each = var.target_group_arn_suffixes

  alarm_name = "${local.alarm_prefix}-${each.key}-high-latency"

  alarm_description = "${local.service_labels[each.key]} average response time exceeded two seconds."

  namespace   = "AWS/ApplicationELB"
  metric_name = "TargetResponseTime"

  statistic = "Average"
  period    = 300

  evaluation_periods  = 2
  datapoints_to_alarm = 2

  threshold           = 2
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = each.value
  }

  alarm_actions = var.alarm_actions

  tags = {
    Name    = "${local.alarm_prefix}-${each.key}-latency"
    Service = each.key
  }
}
resource "aws_cloudwatch_metric_alarm" "asg_no_instances" {
  for_each = var.autoscaling_group_names

  alarm_name = "${local.alarm_prefix}-${each.key}-no-inservice-instances"

  alarm_description = "${local.service_labels[each.key]} has no InService EC2 instances."

  namespace   = "AWS/AutoScaling"
  metric_name = "GroupInServiceInstances"

  statistic = "Minimum"
  period    = 60

  evaluation_periods  = 2
  datapoints_to_alarm = 2

  threshold           = 1
  comparison_operator = "LessThanThreshold"

  treat_missing_data = "breaching"

  dimensions = {
    AutoScalingGroupName = each.value
  }

  alarm_actions = var.alarm_actions

  tags = {
    Name    = "${local.alarm_prefix}-${each.key}-capacity"
    Service = each.key
  }
}
resource "aws_cloudwatch_metric_alarm" "redis_evictions" {
  alarm_name = "${local.alarm_prefix}-redis-evictions"

  alarm_description = (
    "Redis is evicting keys due to memory pressure."
  )

  namespace   = "AWS/ElastiCache"
  metric_name = "Evictions"

  statistic = "Sum"
  period    = 300

  evaluation_periods  = 1
  datapoints_to_alarm = 1

  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {
    CacheClusterId = var.redis_cluster_id
  }

  alarm_actions = var.alarm_actions

  tags = {
    Name = "${local.alarm_prefix}-redis-evictions"
  }
}
resource "aws_cloudwatch_metric_alarm" "redis_low_memory" {
  alarm_name = "${local.alarm_prefix}-redis-low-memory"

  alarm_description = (
    "Redis free memory is below 100 MiB."
  )

  namespace   = "AWS/ElastiCache"
  metric_name = "FreeableMemory"

  statistic = "Minimum"
  period    = 300

  evaluation_periods  = 2
  datapoints_to_alarm = 2

  threshold = 104857600

  comparison_operator = "LessThanThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {
    CacheClusterId = var.redis_cluster_id
  }

  alarm_actions = var.alarm_actions

  tags = {
    Name = "${local.alarm_prefix}-redis-low-memory"
  }
}
resource "aws_cloudwatch_metric_alarm" "game_capacity_high" {
  alarm_name = "${local.alarm_prefix}-game-capacity-high"

  alarm_description = "GameService match capacity utilization is at or above 80 percent."

  namespace   = "NightwatchProtocol"
  metric_name = "MatchCapacityUtilization"

  statistic = "Average"
  period    = 60

  evaluation_periods  = 3
  datapoints_to_alarm = 2

  threshold           = 80
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {
    Environment = var.environment
    Service     = "game-service"
  }

  alarm_actions = var.alarm_actions

  tags = {
    Name    = "${local.alarm_prefix}-game-capacity-high"
    Service = "game"
  }
}
resource "aws_cloudwatch_metric_alarm" "matchmaking_creation_failures" {
  alarm_name = "${local.alarm_prefix}-matchmaking-creation-failures"

  alarm_description = "MatchmakingService failed to create one or more matches."

  namespace   = "NightwatchProtocol"
  metric_name = "MatchCreationFailures"

  statistic = "Sum"
  period    = 300

  evaluation_periods  = 1
  datapoints_to_alarm = 1

  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {
    Environment = var.environment
    Service     = "matchmaking-service"
  }

  alarm_actions = var.alarm_actions

  tags = {
    Name    = "${local.alarm_prefix}-matchmaking-creation-failures"
    Service = "matchmaking"
  }
}
resource "aws_cloudwatch_metric_alarm" "auth_dynamodb_failures" {
  alarm_name = "${local.alarm_prefix}-auth-dynamodb-failures"

  alarm_description = "AuthService encountered one or more DynamoDB operation failures."

  namespace   = "NightwatchProtocol"
  metric_name = "DynamoDbOperationFailures"

  statistic = "Sum"
  period    = 300

  evaluation_periods  = 1
  datapoints_to_alarm = 1

  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {
    Environment = var.environment
    Service     = "auth-service"
  }

  alarm_actions = var.alarm_actions

  tags = {
    Name    = "${local.alarm_prefix}-auth-dynamodb-failures"
    Service = "auth"
  }
}
resource "aws_cloudwatch_metric_alarm" "gateway_routing_failures" {
  alarm_name = "${local.alarm_prefix}-gateway-routing-failures"

  alarm_description = "RealtimeGateway could not resolve one or more match routes."

  namespace   = "NightwatchProtocol"
  metric_name = "RoutingFailures"

  statistic = "Sum"
  period    = 300

  evaluation_periods  = 1
  datapoints_to_alarm = 1

  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {
    Environment = var.environment
    Service     = "realtime-gateway"
  }

  alarm_actions = var.alarm_actions

  tags = {
    Name    = "${local.alarm_prefix}-gateway-routing-failures"
    Service = "gateway"
  }
}
resource "aws_cloudwatch_metric_alarm" "gateway_game_service_failures" {
  alarm_name = "${local.alarm_prefix}-gateway-game-service-failures"

  alarm_description = "RealtimeGateway encountered failures while communicating with GameService."

  namespace   = "NightwatchProtocol"
  metric_name = "GameServiceRequestFailures"

  statistic = "Sum"
  period    = 300

  evaluation_periods  = 1
  datapoints_to_alarm = 1

  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {
    Environment = var.environment
    Service     = "realtime-gateway"
  }

  alarm_actions = var.alarm_actions

  tags = {
    Name    = "${local.alarm_prefix}-gateway-game-service-failures"
    Service = "gateway"
  }
}
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}"

  dashboard_body = jsonencode({
    widgets = concat(
      [
        {
          type   = "text"
          x      = 0
          y      = 0
          width  = 24
          height = 2

          properties = {
            markdown = "# Nightwatch Protocol - ${var.environment}\nDisponibilidad, rendimiento y estado de los servicios."
          }
        },
        {
          type   = "metric"
          x      = 0
          y      = 2
          width  = 12
          height = 6

          properties = {
            title  = "Targets saludables"
            region = var.aws_region
            view   = "timeSeries"
            stat   = "Minimum"
            period = 60

            metrics = [
              for service, target_group
              in var.target_group_arn_suffixes :
              [
                "AWS/ApplicationELB",
                "HealthyHostCount",
                "LoadBalancer",
                var.alb_arn_suffix,
                "TargetGroup",
                target_group,
                {
                  label = local.service_labels[service]
                }
              ]
            ]
          }
        },
        {
          type   = "metric"
          x      = 12
          y      = 2
          width  = 12
          height = 6

          properties = {
            title  = "Targets no saludables"
            region = var.aws_region
            view   = "timeSeries"
            stat   = "Maximum"
            period = 60

            metrics = [
              for service, target_group
              in var.target_group_arn_suffixes :
              [
                "AWS/ApplicationELB",
                "UnHealthyHostCount",
                "LoadBalancer",
                var.alb_arn_suffix,
                "TargetGroup",
                target_group,
                {
                  label = local.service_labels[service]
                }
              ]
            ]
          }
        },
        {
          type   = "metric"
          x      = 0
          y      = 8
          width  = 12
          height = 6

          properties = {
            title  = "Tiempo de respuesta"
            region = var.aws_region
            view   = "timeSeries"
            stat   = "Average"
            period = 60

            metrics = [
              for service, target_group
              in var.target_group_arn_suffixes :
              [
                "AWS/ApplicationELB",
                "TargetResponseTime",
                "LoadBalancer",
                var.alb_arn_suffix,
                "TargetGroup",
                target_group,
                {
                  label = local.service_labels[service]
                }
              ]
            ]

            yAxis = {
              left = {
                min = 0
              }
            }
          }
        },
        {
          type   = "metric"
          x      = 12
          y      = 8
          width  = 12
          height = 6

          properties = {
            title  = "Errores HTTP 5XX"
            region = var.aws_region
            view   = "timeSeries"
            stat   = "Sum"
            period = 300

            metrics = concat(
              [
                [
                  "AWS/ApplicationELB",
                  "HTTPCode_ELB_5XX_Count",
                  "LoadBalancer",
                  var.alb_arn_suffix,
                  {
                    label = "ALB 5XX"
                  }
                ]
              ],
              [
                for service, target_group
                in var.target_group_arn_suffixes :
                [
                  "AWS/ApplicationELB",
                  "HTTPCode_Target_5XX_Count",
                  "LoadBalancer",
                  var.alb_arn_suffix,
                  "TargetGroup",
                  target_group,
                  {
                    label = "${local.service_labels[service]} 5XX"
                  }
                ]
              ]
            )
          }
        },
        {
          type   = "metric"
          x      = 0
          y      = 14
          width  = 12
          height = 6

          properties = {
            title  = "Instancias InService"
            region = var.aws_region
            view   = "timeSeries"
            stat   = "Minimum"
            period = 60

            metrics = [
              for service, asg_name
              in var.autoscaling_group_names :
              [
                "AWS/AutoScaling",
                "GroupInServiceInstances",
                "AutoScalingGroupName",
                asg_name,
                {
                  label = local.service_labels[service]
                }
              ]
            ]
          }
        },
        {
          type   = "metric"
          x      = 12
          y      = 14
          width  = 12
          height = 6

          properties = {
            title  = "Redis"
            region = var.aws_region
            view   = "timeSeries"
            period = 60

            metrics = [
              [
                "AWS/ElastiCache",
                "CurrConnections",
                "CacheClusterId",
                var.redis_cluster_id,
                {
                  label = "Conexiones"
                }
              ],
              [
                ".",
                "Evictions",
                ".",
                ".",
                {
                  label = "Evictions"
                }
              ],
              [
                ".",
                "CPUUtilization",
                ".",
                ".",
                {
                  label = "CPU"
                  yAxis = "right"
                }
              ]
            ]
          }
        },
        {
          type   = "metric"
          x      = 0
          y      = 20
          width  = 24
          height = 6

          properties = {
            title  = "DynamoDB"
            region = var.aws_region
            view   = "timeSeries"
            period = 300

            metrics = [
              [
                "AWS/DynamoDB",
                "UserErrors",
                "TableName",
                var.dynamodb_table_name,
                {
                  label = "UserErrors"
                }
              ],
              [
                ".",
                "SystemErrors",
                ".",
                ".",
                {
                  label = "SystemErrors"
                }
              ],
              [
                ".",
                "ReadThrottleEvents",
                ".",
                ".",
                {
                  label = "ReadThrottleEvents"
                }
              ],
              [
                ".",
                "WriteThrottleEvents",
                ".",
                ".",
                {
                  label = "WriteThrottleEvents"
                }
              ]
            ]
          }
        },
        {
          type   = "metric"
          x      = 0
          y      = 26
          width  = 12
          height = 6

          properties = {
            title  = "Partidas activas"
            region = var.aws_region
            view   = "timeSeries"
            stat   = "Average"
            period = 60

            metrics = [
              [
                "NightwatchProtocol",
                "ActiveMatches",
                "Environment",
                var.environment,
                "Service",
                "game-service",
                {
                  label = "ActiveMatches"
                }
              ]
            ]

            yAxis = {
              left = {
                min = 0
              }
            }
          }
        },
        {
          type   = "metric"
          x      = 12
          y      = 26
          width  = 12
          height = 6

          properties = {
            title  = "Utilización de capacidad de GameService"
            region = var.aws_region
            view   = "timeSeries"
            stat   = "Average"
            period = 60

            metrics = [
              [
                "NightwatchProtocol",
                "MatchCapacityUtilization",
                "Environment",
                var.environment,
                "Service",
                "game-service",
                {
                  label = "Capacidad utilizada"
                }
              ]
            ]

            yAxis = {
              left = {
                min = 0
                max = 100
              }
            }
          }
        },
        {
          type   = "metric"
          x      = 0
          y      = 32
          width  = 12
          height = 6

          properties = {
            title  = "Jugadores en cola"
            region = var.aws_region
            view   = "timeSeries"
            stat   = "Maximum"
            period = 60

            metrics = [
              [
                "NightwatchProtocol",
                "QueuedPlayers",
                "Environment",
                var.environment,
                "Service",
                "matchmaking-service",
                {
                  label = "QueuedPlayers"
                }
              ]
            ]

            yAxis = {
              left = {
                min = 0
              }
            }
          }
        },
        {
          type   = "metric"
          x      = 12
          y      = 32
          width  = 12
          height = 6

          properties = {
            title  = "Creación de partidas"
            region = var.aws_region
            view   = "timeSeries"
            period = 60

            metrics = [
              [
                "NightwatchProtocol",
                "MatchCreationLatency",
                "Environment",
                var.environment,
                "Service",
                "matchmaking-service",
                {
                  label = "Latencia ms"
                  stat  = "Average"
                }
              ],
              [
                ".",
                "MatchCreationFailures",
                ".",
                ".",
                ".",
                ".",
                {
                  label = "Fallos"
                  stat  = "Sum"
                  yAxis = "right"
                }
              ]
            ]
          }
        },
        {
          type   = "metric"
          x      = 0
          y      = 38
          width  = 12
          height = 6

          properties = {
            title  = "Autenticación"
            region = var.aws_region
            view   = "timeSeries"
            period = 60

            metrics = [
              [
                "NightwatchProtocol",
                "LoginAttempts",
                "Environment",
                var.environment,
                "Service",
                "auth-service",
                {
                  label = "Intentos de login"
                  stat  = "Sum"
                }
              ],
              [
                ".",
                "LoginFailures",
                ".",
                ".",
                ".",
                ".",
                {
                  label = "Fallos de login"
                  stat  = "Sum"
                }
              ],
              [
                ".",
                "RegistrationAttempts",
                ".",
                ".",
                ".",
                ".",
                {
                  label = "Intentos de registro"
                  stat  = "Sum"
                }
              ],
              [
                ".",
                "RegistrationFailures",
                ".",
                ".",
                ".",
                ".",
                {
                  label = "Fallos de registro"
                  stat  = "Sum"
                }
              ]
            ]
          }
        },
        {
          type   = "metric"
          x      = 12
          y      = 38
          width  = 12
          height = 6

          properties = {
            title  = "Latencia y fallos de AuthService"
            region = var.aws_region
            view   = "timeSeries"
            period = 60

            metrics = [
              [
                "NightwatchProtocol",
                "AuthenticationLatency",
                "Environment",
                var.environment,
                "Service",
                "auth-service",
                {
                  label = "Latencia de autenticación"
                  stat  = "Average"
                }
              ],
              [
                ".",
                "DynamoDbOperationFailures",
                ".",
                ".",
                ".",
                ".",
                {
                  label = "Fallos DynamoDB"
                  stat  = "Sum"
                  yAxis = "right"
                }
              ]
            ]
          }
        },
        {
          type   = "metric"
          x      = 0
          y      = 44
          width  = 12
          height = 6

          properties = {
            title  = "Conexiones WebSocket"
            region = var.aws_region
            view   = "timeSeries"
            stat   = "Maximum"
            period = 60

            metrics = [
              [
                "NightwatchProtocol",
                "ConnectedWebSockets",
                "Environment",
                var.environment,
                "Service",
                "realtime-gateway",
                {
                  label = "WebSockets conectados"
                }
              ]
            ]

            yAxis = {
              left = {
                min = 0
              }
            }
          }
        },
        {
          type   = "metric"
          x      = 12
          y      = 44
          width  = 12
          height = 6

          properties = {
            title  = "Fallos de RealtimeGateway"
            region = var.aws_region
            view   = "timeSeries"
            stat   = "Sum"
            period = 60

            metrics = [
              [
                "NightwatchProtocol",
                "RoutingFailures",
                "Environment",
                var.environment,
                "Service",
                "realtime-gateway",
                {
                  label = "Fallos de routing"
                }
              ],
              [
                ".",
                "GameServiceRequestFailures",
                ".",
                ".",
                ".",
                ".",
                {
                  label = "Fallos hacia GameService"
                }
              ]
            ]
          }
        }
      ]
    )
  })
}