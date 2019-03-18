workflow "Build, Test" {
  on = "push"
  resolves = ["Ember exam"]
}

action "Ember build" {
  uses = "actions/docker/cli@master"
  args = "build ."
}

action "Ember exam" {
  uses = "actions/docker/cli@master"
  args = "build . --build-arg RUN_TESTS=true"
  needs = ["Ember build"]
}
