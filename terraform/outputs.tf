# Output the ELB DNS name
output "elb_dns" {
  value = "${aws_elb.elb_dokku.dns_name}"
}

# Output the dokku DNS name
output "dokku_dns" {
  value = "${aws_instance.dokku.public_dns}"
}
