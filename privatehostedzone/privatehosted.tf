resource "aws_route53_zone" "private" {
  name = var.domain

  vpc {
    vpc_id = data.aws_vpc.defaultvpc.id
  }
}

resource "aws_route53_record" "private_record" {
  zone_id  = aws_route53_zone.private.zone_id
  for_each = toset(var.records)
  name     = each.value
  type     = "CNAME"
  ttl      = "300"
  records = [
    "${data.aws_lb.istiolb.dns_name}"
  ]
}

output "name_server" {
  value = aws_route53_zone.private.name_servers
}