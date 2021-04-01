data "github_user" "current_user" {
  username = ""
}

data "github_user" "dkamacharov19" {
  username = "dkamacharov19"
}

resource "github_team_membership" "dkamacharov19_devs_membership" {
  team_id  = github_team.devs.id
  username = data.github_user.dkamacharov19.username
  role     = "member"
}