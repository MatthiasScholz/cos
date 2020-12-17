resource "aws_key_pair" "dummy" {
  key_name   = "dummy-HP-${var.aws_region}-${var.deploy_profile}-instancekey-${random_pet.unicorn.id}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKBWdJWrWs0juMQa7b9quvVN7o5NofS1SDdXu7T8VnVQC5Q7UfkvfP+1JG5kyc5rJedqQfP410MMHbzWxTMLtAhYzM5qMa1c/V+Gx2WWCjbKeIJNKEQG9Xv/KgLi8EV1fzvhkY3vOXC81L6G4/6ICdmmICb9k7FY8kgUq3DFPzir0tO+9cf+r3Yx+zi3uT6LI5rr46PAHCIYO9+IgF5HXXiQx5RZwsNcQzwx26Ln3/I2rlcvc/y+O0zQ9uaZP7hNIy7ghYkNnrXipoeVHrt3s1kJaJ6ycCBhRVnfhq2rEy7Qob0IOYarV0w5uAjUH/RJHmv5cckGIGxIQd8m7em06YgfCKECUWHLGenK8/TfgC7pET5IU2RH3lr95K+bNMI/mJPAI/ac2kY2bJwRPk43d5ygolpzwWXOPmAPF1sHCHIq5IXdT+5dPSJm/FZmlqS8FXGRMt0OcfCA7eR9bJo+3JsW75bRxsv0XDXoKXx+DVcjzgZROwrCe+ZxEeekUFa6c= cos@aws.dummy"
}
