module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}

module "dynamodb" {
  source = "./modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment
}

module "redis" {
  source = "./modules/redis"

  project_name = var.project_name
  environment  = var.environment

  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.redis_subnet_ids

  node_type = var.redis_node_type
}

module "load_balancer" {
  source = "./modules/load-balancer"

  project_name = var.project_name
  environment  = var.environment

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}

module "auth_service" {
  source = "./modules/service-asg"

  project_name = var.project_name
  environment  = var.environment
  service_name = "auth-service"

  ami_id = var.service_ami_id

  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.public_subnet_ids
  alb_security_group_id = module.load_balancer.security_group_id
  target_group_arn      = module.load_balancer.target_group_arns.auth

  image_uri = "${module.ecr.repository_urls["auth-service"]}:latest"

  instance_type             = var.instance_type
  iam_instance_profile_name = var.iam_instance_profile_name

  aws_region = var.aws_region

  cloudwatch_log_group_name = (
    module.observability.log_group_names[
      "auth-service"
    ]
  )

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  environment_variables = {
    DynamoDb__TableName     = module.dynamodb.table_name
    DynamoDb__UseLocalMode  = "false"
    Cors__AllowedOrigins__0 = (module.web_client.website_url)

    Jwt__Key                        = var.jwt_key
    Jwt__Issuer                     = "NightwatchAuth"
    Jwt__Audience                   = "NightwatchClients"
    Metrics__Enabled                = "true"
    Metrics__Namespace              = "NightwatchProtocol"
    Metrics__Environment            = var.environment
    Metrics__PublishIntervalSeconds = "60"
  }
}

module "web_client" {
  source = "./modules/web-client"

  project_name = var.project_name
  environment  = var.environment
}
module "game_service" {
  source = "./modules/service-asg"

  project_name = var.project_name
  environment  = var.environment
  service_name = "game-service"

  ami_id = var.service_ami_id

  vpc_id = module.network.vpc_id

  subnet_ids            = module.network.public_subnet_ids
  alb_security_group_id = module.load_balancer.security_group_id
  target_group_arn      = module.load_balancer.target_group_arns.game

  image_uri = "${module.ecr.repository_urls["game-service"]}:latest"

  instance_type             = var.instance_type
  iam_instance_profile_name = var.iam_instance_profile_name

  min_size         = 1
  desired_capacity = 1
  max_size         = 3

  enable_game_instance_identity = true
  disable_scale_in              = true

  aws_region = var.aws_region

  cloudwatch_log_group_name = (
    module.observability.log_group_names[
      "game-service"
    ]
  )


  environment_variables = {
    Redis__ConnectionString = (module.redis.connection_string)
    Redis__InstanceName     = "nightwatch:"

    GameService__AutoScalingGroupName = (var.game_service_asg_name)

    GameService__MaxMatches = tostring(var.game_service_max_matches)

    GameService__HeartbeatIntervalSeconds = "5"

    Metrics__Enabled = "true"

    Metrics__Namespace = ("NightwatchProtocol")

    Metrics__Environment = (var.environment)

    Metrics__PublishIntervalSeconds = "60"
  }
}

module "matchmaking_service" {
  source = "./modules/service-asg"

  project_name = var.project_name
  environment  = var.environment
  service_name = "matchmaking-service"

  ami_id = var.service_ami_id

  vpc_id = module.network.vpc_id

  subnet_ids            = module.network.public_subnet_ids
  alb_security_group_id = module.load_balancer.security_group_id
  target_group_arn      = module.load_balancer.target_group_arns.matchmaking

  image_uri = "${module.ecr.repository_urls["matchmaking-service"]}:latest"

  aws_region = var.aws_region

  cloudwatch_log_group_name = (
    module.observability.log_group_names[
      "matchmaking-service"
    ]
  )

  instance_type             = var.instance_type
  iam_instance_profile_name = var.iam_instance_profile_name

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  environment_variables = {
    Redis__ConnectionString         = module.redis.connection_string
    Redis__InstanceName             = "nightwatch:"
    Cors__AllowedOrigins__0         = module.web_client.website_url
    Metrics__Enabled                = "true"
    Metrics__Namespace              = "NightwatchProtocol"
    Metrics__Environment            = var.environment
    Metrics__PublishIntervalSeconds = "60"
  }
}


module "realtime_gateway" {
  source = "./modules/service-asg"

  project_name = var.project_name
  environment  = var.environment
  service_name = "realtime-gateway"

  ami_id = var.service_ami_id

  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.public_subnet_ids
  alb_security_group_id = module.load_balancer.security_group_id
  target_group_arn      = module.load_balancer.target_group_arns.gateway

  image_uri = "${module.ecr.repository_urls["realtime-gateway"]}:latest"

  instance_type             = var.instance_type
  iam_instance_profile_name = var.iam_instance_profile_name

  aws_region = var.aws_region

  cloudwatch_log_group_name = (
    module.observability.log_group_names[
      "realtime-gateway"
    ]
  )

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  enable_gateway_instance_identity = true

  environment_variables = {
    Redis__ConnectionString = module.redis.connection_string
    Redis__InstanceName     = "nightwatch:"
    Cors__AllowedOrigins__0 = (module.web_client.website_url)

    Jwt__Key                        = var.jwt_key
    Jwt__Issuer                     = "NightwatchAuth"
    Jwt__Audience                   = "NightwatchClients"
    Metrics__Enabled                = "true"
    Metrics__Namespace              = "NightwatchProtocol"
    Metrics__Environment            = var.environment
    Metrics__PublishIntervalSeconds = "60"
  }

}

module "observability" {
  source = "./modules/observability"

  project_name = var.project_name
  environment  = var.environment

  log_retention_days = 7
}
module "monitoring" {
  source = "./modules/monitoring"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  alb_arn_suffix = (
    module.load_balancer.alb_arn_suffix
  )

  target_group_arn_suffixes = (
    module.load_balancer.target_group_arn_suffixes
  )

  autoscaling_group_names = {
    auth = (
      module.auth_service.autoscaling_group_name
    )

    matchmaking = (
      module.matchmaking_service.autoscaling_group_name
    )

    gateway = (
      module.realtime_gateway.autoscaling_group_name
    )

    game = (
      module.game_service.autoscaling_group_name
    )
  }

  redis_cluster_id = module.redis.cluster_id

  dynamodb_table_name = (
    module.dynamodb.table_name
  )
}