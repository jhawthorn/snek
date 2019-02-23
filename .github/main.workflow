workflow "New workflow" {
  on = "push"
  resolves = ["Docker Login", "Restart Azure Container"]
}

action "Docker Login" {
  uses = "actions/docker/login@master"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "Build docker container" {
  uses = "docker://docker:stable"
  args = "build -t jhawthorn/gitadder ."
}

action "Push container" {
  uses = "docker://docker:stable"
  needs = ["Build docker container", "Docker Login"]
  args = "push jhawthorn/gitadder"
}

action "GitHub Action for Azure" {
  uses = "Azure/github-actions/login@master"
  needs = ["Push container"]
  secrets = ["AZURE_SERVICE_APP_ID", "AZURE_SERVICE_PASSWORD", "AZURE_SERVICE_TENANT"]
}

action "Restart Azure Container" {
  uses = "Azure/github-actions/cli@7e91de5a41b40f2db181215fbbeaf6a2155b9f38"
  needs = ["GitHub Action for Azure"]
  args = "webapp restart --name gitadder --resource-group gitadder"
}
