variable "sysdig_secure_for_cloud_member_account_id" {
  type        = string
  description = "organizational member account where the secure-for-cloud workload is going to be deployed"
}


#---------------------------------
# optionals - with defaults
#---------------------------------


#
# organizational
#

variable "connector_ecs_task_role_name" {
  type        = string
  default     = "organizational-ECSTaskRole"
  description = "Name for the ecs task role. This is only required to resolve cyclic dependency with organizational approach"
}

variable "organizational_member_default_admin_role" {
  type        = string
  default     = "OrganizationAccountAccessRole"
  description = "Default role created by AWS for management-account users to be able to admin member accounts.<br/>https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html"
}

#
# cloudtrail configuration
#
variable "cloudtrail_is_multi_region_trail" {
  type        = bool
  default     = true
  description = "true/false whether the created cloudtrail will ingest multi-regional events. testing/economization purpose."
}

variable "cloudtrail_kms_enable" {
  type        = bool
  default     = true
  description = "true/false whether the created cloudtrail should deliver encrypted events to s3"
}


variable "existing_cloudtrail_config" {
  type = object({
    cloudtrail_s3_arn         = optional(string)
    cloudtrail_sns_arn        = optional(string)
    cloudtrail_s3_role_arn    = optional(string)
    cloudtrail_s3_sns_sqs_arn = optional(string)
    cloudtrail_s3_sns_sqs_url = optional(string)
  })
  default = {
    cloudtrail_s3_arn         = "create"
    cloudtrail_sns_arn        = "create"
    cloudtrail_s3_role_arn    = null
    cloudtrail_s3_sns_sqs_arn = null
    cloudtrail_s3_sns_sqs_url = null
  }

  description = <<-EOT
    Optional block. If not set, a new cloudtrail, sns and sqs resources will be created<br/>
    If there's an existing cloudtrail, input mandatory attributes, and one of the 1, 2 or 3 grouped labeled optionals.
    <ul>
      <li>cloudtrail_s3_arn: Mandatory ARN of a pre-existing cloudtrail_sns s3 bucket. Used together with `cloudtrail_sns_arn`, `cloudtrail_s3_arn`. If it does not exist, it will be inferred from create cloudtrail"</li>
      <li>cloudtrail_sns_arn: Optional 1. ARN of a pre-existing cloudtrail_sns. Used together with `cloudtrail_sns_arn`, `cloudtrail_s3_arn`. If it does not exist, it will be inferred from created cloudtrail. Providing an ARN requires permission to SNS:Subscribe, check ./modules/infrastructure/cloudtrail/sns_permissions.tf block</li>
      <li>cloudtrail_s3_role_arn: Optional 2. ARN of the role to be assumed for S3 access. This role must be in the same account of the S3 bucket. Currently this setup is not compatible with organizational scanning feature</li>
      <li>cloudtrail_s3_sns_sqs_arn: Optional 3. ARN of the queue that will ingest events forwarded from an existing cloudtrail_s3_sns</li>
      <li>cloudtrail_s3_sns_sqs_url: Optional 3. URL of the queue that will ingest events forwarded from an existing cloudtrail_s3_sns<</li>
    </ul>
  EOT
}


#
# scanning configuration
#

variable "deploy_image_scanning_ecr" {
  type        = bool
  description = "true/false whether to deploy the image scanning on ECR pushed images"
  default     = false
}

variable "deploy_image_scanning_ecs" {
  type        = bool
  description = "true/false whether to deploy the image scanning on ECS running images"
  default     = false
}


#
# benchmark configuration
#

variable "deploy_benchmark" {
  type        = bool
  description = "Whether to deploy or not the cloud benchmarking"
  default     = true
}

variable "benchmark_regions" {
  type        = list(string)
  description = "List of regions in which to run the benchmark. If empty, the task will contain all aws regions by default."
  default     = []
}


#---------------------------------
# ecs, security group,  vpc
#---------------------------------

variable "ecs_cluster_name" {
  type        = string
  default     = "create"
  description = "Name of a pre-existing ECS (elastic container service) cluster. If defaulted, a new ECS cluster/VPC/Security Group will be created. If specified all three parameters `ecs_cluster_name`, `ecs_vpc_id` and `ecs_vpc_subnets_private_ids` are required. ECS location will/must be within the `sysdig_secure_for_cloud_member_account_id` parameter accountID"
}

variable "ecs_vpc_id" {
  type        = string
  default     = "create"
  description = "ID of the VPC where the workload is to be deployed. If defaulted a new VPC will be created. If specified all three parameters `ecs_cluster_name`, `ecs_vpc_id` and `ecs_vpc_subnets_private_ids` are required"
}

variable "ecs_vpc_subnets_private_ids" {
  type        = list(string)
  default     = []
  description = "List of VPC subnets where workload is to be deployed. If defaulted new subnets will be created within the VPC. A minimum of two subnets is suggested. If specified all three parameters `ecs_cluster_name`, `ecs_vpc_id` and `ecs_vpc_subnets_private_ids` are required."
}

variable "ecs_vpc_region_azs" {
  type        = list(string)
  description = "List of Availability Zones for ECS VPC creation. e.g.: [\"apne1-az1\", \"apne1-az2\"]. If defaulted, two of the default 'aws_availability_zones' datasource will be taken"
  default     = []
}

# Configure CPU and memory in pairs.
# See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
variable "ecs_task_cpu" {
  type        = string
  description = "Amount of CPU (in CPU units) to reserve for cloud-connector task"
  default     = "256"
}

variable "ecs_task_memory" {
  type        = string
  description = "Amount of memory (in megabytes) to reserve for cloud-connector task"
  default     = "512"
}



#
# general
#

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags. always include 'product' default tag for resource-group proper functioning"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}
