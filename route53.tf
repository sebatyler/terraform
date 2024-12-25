data "aws_route53_zone" "seba-kim" {
  name = "seba.kim."
}

resource "aws_route53_record" "github_pages_domain" {
  zone_id = data.aws_route53_zone.seba-kim.zone_id
  name    = "_github-pages-challenge-sebatyler.seba.kim"
  type    = "TXT"
  ttl     = 300
  records = [var.github_pages_domain_verification_token]
}
