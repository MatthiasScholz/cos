module github.com/MatthiasScholz/cos

go 1.15

require (
	github.com/gruntwork-io/terratest v0.31.1
	github.com/hashicorp/consul/api v1.9.1
	github.com/hashicorp/nomad v1.1.14
	github.com/hashicorp/nomad/api v0.0.0-20201214220709-0993d5ce707a
	github.com/imdario/mergo v0.3.8 // indirect
	github.com/stretchr/testify v1.7.0
	golang.org/x/sync v0.0.0-20200317015054-43a5402ce75a // indirect
	k8s.io/client-go v11.0.0+incompatible // indirect
)

replace k8s.io/client-go => k8s.io/client-go v0.20.0
