# resource "pagerduty_user" "bob" {
#   name  = "Bob"
#   email = "bob@hashicorp.com"
# }

data "pagerduty_user" "erik" {
  email = "eveld@hashicorp.com"
}

resource "pagerduty_tag" "user_id" {
  label = boundary_user.erik.id
}

resource "pagerduty_tag_assignment" "user_id" {
  tag_id      = pagerduty_tag.user_id.id
  entity_type = "users"
  entity_id   = data.pagerduty_user.erik.id
}

resource "pagerduty_escalation_policy" "app" {
  name      = "Engineering Escalation Policy"
  num_loops = 2

  rule {
    escalation_delay_in_minutes = 1

    target {
      type = "user_reference"
      id   = data.pagerduty_user.erik.id
    }
  }
}

resource "pagerduty_service" "app" {
  name              = "App"
  escalation_policy = pagerduty_escalation_policy.app.id
  alert_creation    = "create_alerts_and_incidents"

  auto_pause_notifications_parameters {
    enabled = true
    timeout = 300
  }
}

# data "pagerduty_service" "app" {
#   name = "App"
# }

resource "pagerduty_webhook_subscription" "rift" {
  delivery_method {
    type = "http_delivery_method"
    url  = "https://rift.stickhorse.io/v1/pagerduty"
    custom_header {
      name  = "X-Boundary-Project"
      value = boundary_scope.project.id
    }
    custom_header {
      name  = "X-Boundary-Targets"
      value = boundary_target.kubernetes.id
    }
  }
  description = "Rift integration"
  events = [
    "incident.acknowledged",
    "incident.resolved",
  ]
  active = true
  filter {
    id   = pagerduty_service.app.id
    type = "service_reference"
  }
  type = "webhook_subscription"
}
