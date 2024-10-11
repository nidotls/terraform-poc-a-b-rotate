resource "time_rotating" "a" {
  rotation_minutes = 10
}

resource "time_offset" "b" {
  triggers = {
    a_time = resource.time_rotating.a.id
  }

  offset_minutes = 5
}

resource "random_password" "a" {
  length  = 16
  special = false

  lifecycle {
    replace_triggered_by = [time_rotating.a.id]
  }
}

resource "random_password" "b" {
  length  = 16
  special = false

  lifecycle {
    replace_triggered_by = [time_offset.b.id]
  }
}

resource "local_file" "a" {
  content  = random_password.a.result
  filename = "${path.module}/.test/a_token.txt"
}

resource "local_file" "b" {
  content  = random_password.b.result
  filename = "${path.module}/.test/b_token.txt"
}

resource "local_file" "current" {
  content  = time_rotating.a.unix > time_offset.b.unix ? random_password.a.result : random_password.b.result
  filename = "${path.module}/.test/current_token.txt"

  lifecycle {
    replace_triggered_by = [time_rotating.a.id, time_offset.b.id]
  }
}
