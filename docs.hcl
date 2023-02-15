docs "docs" {
  port = 3000
  
  network {
      name = "network.local"
  }

  path = "./docs"
  
  image {
    name = "shipyardrun/docs:v0.6.1"
  }

  index_title = "Docs"
}
