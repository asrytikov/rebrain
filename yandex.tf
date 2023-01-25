terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "${file("~/key.json")}"
  cloud_id  = "b1gm6imb36aoic2km8d0"
  folder_id = "b1gu2vqv4hil3okf70bb"
  zone = "ru-central1-a"
}

data "yandex_vpc_subnet" "default_a" {
  name = "default-ru-central1-a"  # одна из дефолтных подсетей
}

data "yandex_compute_image" "foo-image" {
  family     = "ubuntu-2004-lts"
  folder_id  = "standard-images" 
}

resource "yandex_compute_instance" "vm-1" {
  name        = "asrytikov-lnxa-01-04"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  labels      = {
           user_email = "asrytikov@gmail.com"
           task_name  = "lnxa-01-04"
  }

  resources {
    core_fraction = 5
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
        image_id = data.yandex_compute_image.foo-image.id
    }
  }
  network_interface {
    subnet_id = data.yandex_vpc_subnet.default_a.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/ubuntu.pub")}"
  }  
  
}

output "default_instance_public_ip" {
    value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}
