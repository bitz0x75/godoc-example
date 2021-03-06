# Makefile
APPNAME=godoc-example
CURRENT_DIR=`pwd`
PACKAGE_DIRS=`go list -e ./... | egrep -v "binary_output_dir|.git|mocks"`

.PHONY: test test-package-dirs test-report dep mocks dep
test: test-report
test-package-dirs:
	@echo 'Executing unit tests...'
	go vet $(PACKAGE_DIRS)
	go test $(PACKAGE_DIRS) -race -coverprofile=cover.out -covermode=atomic
test-report: test-package-dirs
	@echo 'Generating test coverage report...'
	go tool cover -html=cover.out -o cover.html
dep:
	@dep ensure -update

# docker cmd below
.PHONY:  docker-build docker-run docker-gen-docs docker-gen-docs-server
docker-build:
	docker build . -t $(APPNAME)/v1
docker-run: docker-build
	docker run -p 6060:6060 -it $(APPNAME)/v1
docker-gen-docs: docker-build
	rm -rf localhost:6060
	docker run --entrypoint="./gen-docs.sh" -it -v $(CURRENT_DIR):/tmp $(APPNAME)/v1
docker-gen-docs-server: docker-gen-docs
	docker build . -f js-server.Dockerfile -t $(APPNAME)-js-docs-server/v1
	docker run -p 8080:8080 -it $(APPNAME)-js-docs-server/v1