# OVERVIEW
#
# This Makefile provides the basic setup to use terratest as convenient as possible.
# You can add your specific test cases at the end of the file following the pattern shown for "TestAMI2".

# Version of terratest tools to be used
# - IMPORTANT: Check Gopkg.toml to align with the used go package version!
TT_VERSION="v0.17.4"
# Installation path for terratest helper tools
TT_INSTALL_PATH=$(HOME)/bin/

# Check: test/README.md for further details
TIMEOUT="60m"
TEST_OUTPUT="test_output.log"
TEST_OUTPUT_DIR="tmp_test_output"

# Detect the host system to download the appropriate version of the tool.
# ONLY MacOSX, Linux and Windows as 64 bit version supported!
OS:=$(shell uname -s)
ifeq ($(OS),Darwin)
	OS_VERSION:="darwin_amd64"
else ifeq ($(OS),Linux)
	OS_VERSION:="linux_amd64"
else
	OS_VERSION:="windows_amd64.exe"
endif

# Define: Terratest output formatting
# - Stripping logout of one test into a separate file in the test output directory.
# - Creating a Junit XML formatted report which is supported by many CI systems.
# - Creation of a summary
define out_parsing
@echo "--- Tests finished parsing output ---"
@$(TT_INSTALL_PATH)/terratest_log_parser -testlog $(TEST_OUTPUT) -outputdir $(TEST_OUTPUT_DIR) --log-level "warning"
@echo "--- Output parsing finished ---"
endef

# Define: Generic test execution
define run_test
go clean -testcache
go test -v -timeout $(TIMEOUT) -p 1 -run $@ | tee $(TEST_OUTPUT)
$(out_parsing)
endef

all: setup test_all

setup: install_terratest_log_parser
	dep ensure -vendor-only -v

os:
	@echo $(OS_VERSION)

install_terratest_log_parser:
	@mkdir -p $(TT_INSTALL_PATH)
	@curl --location --silent --fail --show-error -o terratest_log_parser https://github.com/gruntwork-io/terratest/releases/download/$(TT_VERSION)/terratest_log_parser_$(OS_VERSION)
	@chmod +x terratest_log_parser
	mv terratest_log_parser $(TT_INSTALL_PATH)

cleanup:
	@rm -f $(TEST_OUTPUT)
	@rm -f -r $(TEST_OUTPUT_DIR)


# ALL: Execute all tests
test_all: cleanup
	go clean -testcache
	go test -v -timeout $(TIMEOUT) -p 1 | tee $(TEST_OUTPUT)
	$(out_parsing)

# SPECIFIC: Matching the name of the Makefile target with the name in of the test to be executed.
TestBastionExample: cleanup
	$(run_test)

TestConsulExample: cleanup
	$(run_test)

TestNetworkingExample: cleanup
	$(run_test)

TestNomadExample: cleanup
	$(run_test)

TestNomadDataCenterExample: cleanup
	$(run_test)

TestUIAccessExample: cleanup
	$(run_test)

TestRootExample: cleanup
	$(run_test)
