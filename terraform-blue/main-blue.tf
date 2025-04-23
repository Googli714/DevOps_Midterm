terraform {
  required_version = ">= 0.12"
}

# Port for the Flask application
variable "app_port" {
  description = "Port to expose the Flask application"
  type        = number
  default     = 5001
}

# Local variables for paths and container names
locals {
  source_dir        = "${path.module}/../src"
  deployment_color  = "blue"
  deployment_dir    = "${path.module}/../${local.deployment_color}"
  container_name    = "flask-${local.deployment_color}-deployment"
  docker_image_name = "flask-${local.deployment_color}:latest"
}

# Resource to create deployment directory if it doesn't exist
resource "local_file" "ensure_directory" {
  content     = ""
  filename    = "${local.deployment_dir}/.terraform-directory-marker"

  provisioner "local-exec" {
    command = "mkdir -p ${local.deployment_dir}"
  }
}

# Resource to copy files from source to deployment directory
resource "null_resource" "copy_app_files" {
  depends_on = [local_file.ensure_directory]

  triggers = {
    # This will ensure the copy happens on each apply
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      cp -R ${local.source_dir}/* ${local.deployment_dir}/
      cp ${local.source_dir}/../Dockerfile ${local.deployment_dir}/
      cp ${local.source_dir}/../requirements.txt ${local.deployment_dir}/
      cp ${local.source_dir}/../health_check.sh ${local.deployment_dir}/
    EOT
  }
}

# Resource to build Docker image
resource "null_resource" "build_docker_image" {
  depends_on = [null_resource.copy_app_files]

  triggers = {
    # This ensures the image is rebuilt on each apply
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      cd ${local.deployment_dir}
      docker build -t ${local.docker_image_name} .
    EOT
  }
}

# Resource to stop and remove previous container if exists
resource "null_resource" "stop_previous_container" {
  depends_on = [null_resource.build_docker_image]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if container exists and remove it (ignore errors if not exists)
      docker rm -f ${local.container_name}
    EOT
  }
}

# Resource to run the Docker container
resource "null_resource" "run_docker_container" {
  depends_on = [null_resource.stop_previous_container]

  provisioner "local-exec" {
    command = <<-EOT
      docker run --name ${local.container_name} \
        -d \
        -p ${var.app_port}:5000 \
        --restart unless-stopped \
        ${local.docker_image_name}
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }

}

resource "null_resource" "health_check" {
  provisioner "local-exec" {
    environment = {
      INTERVAL = 60
      APP_URL = "http://localhost:${var.app_port}/health"
      PROJECT_ROOT = local.deployment_dir
    }
    command = "nohup bash ${local.deployment_dir}/health_check.sh > health_check.out 2>&1 &"
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [null_resource.run_docker_container]
}

# Output the deployment color, container name, and application URL
output "deployment_info" {
  value = {
    color           = local.deployment_color
    container_name  = local.container_name
    image_name      = local.docker_image_name
    url             = "http://localhost:${var.app_port}"
  }
}