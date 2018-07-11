IMAGE:=sameersbn/$(shell basename $$PWD)
RELEASE:=$$(cat VERSION)

all: latest

latest:
	@echo "Building ${IMAGE}:$@..."
	@docker build --cache-from ${IMAGE} -t ${IMAGE}:$@ .

release:
	@echo "Building ${IMAGE}:${RELEASE}..."
	@docker build --cache-from ${IMAGE} -t ${IMAGE}:${RELEASE} .
