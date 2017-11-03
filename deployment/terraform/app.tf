data "template_file" "raster_vision_ecs_task" {
  template = "${file("task-definitions/app-server.json")}"

  vars {
    nginx_image_url      = "${var.aws_account_id}.dkr.ecr.us-east-1.amazonaws.com/rastervision-nginx:${var.image_version}"
    api_server_image_url = "${var.aws_account_id}.dkr.ecr.us-east-1.amazonaws.com/rastervision-api-server:${var.image_version}"
    region               = "${var.aws_region}"
    environment          = "${var.environment}"
  }
}

resource "aws_ecs_task_definition" "raster_vision" {
  family                = "${var.environment}RasterVision"
  container_definitions = "${data.template_file.raster_vision_ecs_task.rendered}"
}

resource "aws_cloudwatch_log_group" "raster_vision" {
  name = "log${var.environment}RasterVision"

  tags {
    Environment = "${var.environment}"
  }
}

module "raster_vision_ecs_service" {
  source = "github.com/azavea/terraform-aws-ecs-web-service?ref=0.2.0"

  name                = "RasterVision"
  vpc_id              = "${data.terraform_remote_state.core.vpc_id}"
  public_subnet_ids   = ["${data.terraform_remote_state.core.public_subnet_ids}"]
  access_log_bucket   = "${data.terraform_remote_state.core.logs_bucket_id}"
  access_log_prefix   = "ALB/RasterVision"
  port                = "443"
  ssl_certificate_arn = "${var.ssl_certificate_arn}"

  cluster_name                   = "${data.terraform_remote_state.core.container_instance_name}"
  task_definition_id             = "${aws_ecs_task_definition.raster_vision.family}:${aws_ecs_task_definition.raster_vision.revision}"
  desired_count                  = "${var.raster_vision_ecs_desired_count}"
  min_count                      = "${var.raster_vision_ecs_min_count}"
  max_count                      = "${var.raster_vision_ecs_max_count}"
  deployment_min_healthy_percent = "${var.raster_vision_ecs_deployment_min_percent}"
  deployment_max_percent         = "${var.raster_vision_ecs_deployment_max_percent}"
  container_name                 = "nginx"
  container_port                 = "443"
  health_check_path              = "/"
  ecs_service_role_name          = "${data.terraform_remote_state.core.ecs_service_role_name}"
  ecs_autoscale_role_arn         = "${data.terraform_remote_state.core.ecs_autoscale_role_arn}"

  project     = "Raster Vision"
  environment = "${var.environment}"
}
