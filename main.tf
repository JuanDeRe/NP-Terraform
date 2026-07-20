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

  vpc_id         = module.network.vpc_id
  vpc_cidr_block = module.network.vpc_cidr_block
  subnet_ids     = module.network.redis_subnet_ids

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

  vpc_id                = module.network.vpc_id
  vpc_cidr_block        = module.network.vpc_cidr_block
  subnet_ids            = module.network.public_subnet_ids
  alb_security_group_id = module.load_balancer.security_group_id
  target_group_arn      = module.load_balancer.target_group_arns.auth

  image_uri = "${module.ecr.repository_urls["auth-service"]}:latest"

  instance_type             = var.instance_type
  iam_instance_profile_name = var.iam_instance_profile_name

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  environment_variables = {
    DynamoDb__TableName    = module.dynamodb.table_name
    DynamoDb__UseLocalMode = "false"

    Jwt__Key      = var.jwt_key
    Jwt__Issuer   = "NightwatchAuth"
    Jwt__Audience = "NightwatchClients"
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

  vpc_id         = module.network.vpc_id
  vpc_cidr_block = module.network.vpc_cidr_block

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

  environment_variables = {
    Redis__ConnectionString = module.redis.connection_string
    Redis__InstanceName     = "nightwatch:"

    GameService__MaxMatches = tostring(
      var.game_service_max_matches
    )

    GameService__HeartbeatIntervalSeconds = "5"
  }
}

module "matchmaking_service" {
  source = "./modules/service-asg"

  project_name = var.project_name
  environment  = var.environment
  service_name = "matchmaking-service"

  vpc_id         = module.network.vpc_id
  vpc_cidr_block = module.network.vpc_cidr_block

  subnet_ids            = module.network.public_subnet_ids
  alb_security_group_id = module.load_balancer.security_group_id
  target_group_arn      = module.load_balancer.target_group_arns.matchmaking

  image_uri = "${module.ecr.repository_urls["matchmaking-service"]}:latest"

  instance_type             = var.instance_type
  iam_instance_profile_name = var.iam_instance_profile_name

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  environment_variables = {
    Redis__ConnectionString = module.redis.connection_string
    Redis__InstanceName     = "nightwatch:"
  }
}


module "realtime_gateway" {
  source = "./modules/service-asg"

  project_name = var.project_name
  environment  = var.environment
  service_name = "realtime-gateway"

  vpc_id                = module.network.vpc_id
  vpc_cidr_block        = module.network.vpc_cidr_block
  subnet_ids            = module.network.public_subnet_ids
  alb_security_group_id = module.load_balancer.security_group_id
  target_group_arn      = module.load_balancer.target_group_arns.gateway

  image_uri = "${module.ecr.repository_urls["realtime-gateway"]}:latest"

  instance_type             = var.instance_type
  iam_instance_profile_name = var.iam_instance_profile_name

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  enable_gateway_instance_identity = true

  environment_variables = {
    Redis__ConnectionString = module.redis.connection_string
    Redis__InstanceName     = "nightwatch:"

    Jwt__Key      = var.jwt_key
    Jwt__Issuer   = "NightwatchAuth"
    Jwt__Audience = "NightwatchClients"
  }

}