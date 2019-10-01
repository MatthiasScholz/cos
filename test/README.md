# Tests

This folder contains automated tests for this all modules provided in this repository
using a helper library called [Terratest](https://github.com/gruntwork-io/terratest).
The tests are written in [Go](https://golang.org/).

## WARNING WARNING WARNING

* [Source of the Disclaimer: terraform-aws-nomad](https://raw.githubusercontent.com/hashicorp/terraform-aws-nomad/master/test/README.md)

**Note #1**: Many of these tests create real resources in an AWS account and
then try to clean those resources up at the end of a test run.
That means these tests may cost you money to run! When adding tests,
please be considerate of the resources you create and
take extra care to clean everything up when you're done!

**Note #2**: Never forcefully shut the tests down (e.g. by hitting `CTRL + C`) or
the cleanup tasks won't run!

**Note #3**: We set `-timeout 60m` on all tests
not because they necessarily take that long,
but because Go has a default test timeout of 10 minutes,
after which it forcefully kills the tests with a `SIGQUIT`,
preventing the cleanup tasks from running.
Therefore, we set an overlying long timeout
to make sure all tests have enough time to finish and clean up.

## Test Coverage

[-] ami
[-] ami2
[x] bastion
[x] consul
[-] ecr
[x] networking
[x] nomad
[x] nomad-datacenter
[-] sgrules
[x] ui-access
[x] root-example

## Usage Hints

### Setup

* To be able to run the tests you need to have a working golang setup and terratest needs to be installed.
* The golang installation is described [here](https://golang.org/doc/install).
* Terratest will be installed when executing the tests.

### Execute tests

* `make all`

#### Using Stages

The tests are broken into "stages":

* `test_structure.RunTestStage(t, "teardown", func() {...})`

One can skip stages by setting environment variables:

* Skip stage `teardown` by setting the environment variable `SKIP_teardown=true`.
  * `SKIP_teardown=true make TestConsulExample`

Using stages will create the temporary configuration in the main folder,
IGNORING the copy command into the temporary folder!
This is activate once ONE `SKIP_XXX` statement was found.

#### Teardown

To tear down the debug session at least one `SKIP_XXX` statement
has to be provided in order to use the main folder configuration settings.
The suggestion is to skip the setup steps, like:

* `SKIP_setup_ami=true SKIP_setup=true make TestConsulExample`

### Caching

Golang is using caching and
will not run the test again if no source code changes are detected.

To avoid problems with testing terraform clear the cache before every test run:
`go clean -testcache`. This is how the [Makefile](test/Makefile) is configured.

### Logging

Using Terratest's logger.Log and logger.Logf functions,
which log to stdout immediately instead of testing logger
which only log to stdout after the completion of a test.

Run the test sequentially to avoid golang stdout buffering `-p 1`.
This is how the [Makefile](test/Makefile) is configured.

### Troubleshooting

#### root project import: <some folder> is not within any GOPATH/src

* If you get an error message like `root project import: [..]/test is not within any GOPATH/src` you have to check out this repository in a folder-structure that fits the needs of golang.
* This means the code has to reside in a folder-structure like this `<some-folder>/src`.
* The best solution would be to just check out this repo into your GOPATH structure: `cd %GOPATH/src && clone https://github.com/MatthiasScholz/cos.git` which then would result in `<some-folder>/src/cos` containing all the code.
