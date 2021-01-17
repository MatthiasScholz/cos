module github.com/MatthiasScholz/cos

go 1.15

require (
	github.com/gruntwork-io/terratest v0.31.1
	github.com/hashicorp/consul/api v1.8.1
	github.com/hashicorp/nomad v1.0.0
	github.com/hashicorp/nomad/api v0.0.0-20201214220709-0993d5ce707a
	github.com/kenshaw/pemutil v0.1.0
	github.com/stretchr/testify v1.6.1
	k8s.io/api v0.20.0
	k8s.io/apimachinery v0.20.0
	k8s.io/client-go v11.0.0+incompatible
)

replace k8s.io/client-go => k8s.io/client-go v0.20.0
