container "vm" {
  network {
    name = "network.local"
    ip_address = "10.0.0.100"
  }

  image {
      name = "nicholasjackson/ubuntu_ssh:v0.0.1"
  }

  volume {
    source = "./Dockerfiles/supervisor.conf"
    destination = "/etc/supervisor/conf.d/ssh.conf"
  }

  volume {
    source = data("temp")
    destination = "/files"
  }

  port {
    local  = 22
    remote = 22
  }
}

template "vm_init" {
  source = <<-EOF
    #! /bin/bash
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo "#{{ (file "./files/id_rsa.pub") | trim }}" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
  EOF

  destination = "${data("temp")}/init.sh"

  vars = {
    data_dir = "/tmp"
  }
}

exec_remote "vm_init" {
  depends_on = ["template.vm_init"]
  target = "container.vm"

  cmd = "/bin/bash"
  args = [
    "/files/init.sh"
  ]
}
