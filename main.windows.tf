terraform {                             // terraform block provider global configuration for the script,
  required_providers {                  // such as required_providers. 
                                        // See more at https://www.terraform.io/language/settings
    docker = {                          // here the required provider is "docker"
      source  = "kreuzwerker/docker"    // the most common field to be filled is source and version
      version = ">= 2.13.0"             // source refers to provider address in terraform provider registry
    }                                   // version refers to provider version
  }                                     // See more at https://www.terraform.io/language/providers/requirements
}


provider "docker" {                             // After specifying required providers,
  host    = "npipe:////.//pipe//docker_engine"  // We can configure the parameters for said providers,
}                                               // such as credentials etc. Here windows pipe is configured


resource "docker_image" "nginx" {   // The goal of this script is to provision a nginx container.
                                    // Now a docker container runs from a docker image
  name         = "nginx:latest"     // so we declare a resource of type: docker_image and name: nginx,
  keep_locally = false              // with parameters the docker image name to be pulled (name)
                                    // and if the image will be deleted after usage (keep_locally)
}                                   // See more at https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image


resource "docker_container" "nginx" { // After specifying which docker image to be pulled and used,
  image = docker_image.nginx.latest   // docker_container sourced the image from previous "nginx" image
  name  = "tutorial"                  // We give the name of the container "tutorial"
  ports {                             // The "ports" block connects the container port to your machine's port 
    internal = 80                     // "internal" is the container's port
    external = 8000                   // "external" is your machine's port. Here the nginx server will be at port 8000
  }                                   // See more at https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container
}