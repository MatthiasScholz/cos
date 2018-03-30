.PHONY: all
all: build fmt vet lint test

APP=consul-envoy-xds
GLIDE_NOVENDOR=$(shell glide novendor)
ALL_PACKAGES=$(shell go list ./... | grep -v "vendor")
UNIT_TEST_PACKAGES=$(shell glide novendor | grep -v "featuretests")

APP_EXECUTABLE="./out/$(APP)"

setup:
	go get -u github.com/golang/lint/golint
	go get github.com/DATA-DOG/godog/cmd/godog
	go get -u github.com/go-playground/overalls
	@echo "consul-envoy-xds is setup!! Run make build and make test to run tests"

build-deps:
	glide install

update-deps:
	glide update

compile:
	mkdir -p out/
	pwd
	ls -la .
	go build -o $(APP_EXECUTABLE)

build: build-deps update-deps compile

check: fmt vet lint

install:
	go install ./...

fmt:
	go fmt $(GLIDE_NOVENDOR)

vet:
	go vet $(GLIDE_NOVENDOR)

lint:
	@for p in $(UNIT_TEST_PACKAGES); do \
		echo "==> Linting $$p"; \
		golint $$p | { grep -vwE "exported (var|function|method|type|const) \S+ should have comment" || true; } \
	done

test: compile
	ENVIRONMENT=test go test $(UNIT_TEST_PACKAGES) -p=1

test-coverage: compile
	@echo "mode: count" > out/coverage-all.out
	env ENVIRONMENT=test overalls -project consul-envoy-xds
	find . -name "profile.coverprofile" -exec rm "{}" \;
	mv overalls.coverprofile out/overalls.coverprofile
	go tool cover -html=out/overalls.coverprofile -o out/coverage.html
