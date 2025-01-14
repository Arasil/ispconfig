#Dockerfile vars

#vars
TAG=3.2.12p1
IMAGENAME=ispconfig
IMAGEFULLNAME=arasil/${IMAGENAME}
BRANCH=${shell git symbolic-ref --short HEAD}
LASTCOMMIT=$(shell git log -1 --pretty=short | tail -n 1 | tr -d " " | tr -d "UPDATE:")


help:
	    @echo "Makefile arguments:"
	    @echo ""
	    @echo "Makefile commands:"
	    @echo "build"
			@echo "publish-latest"
			@echo "publish-tag"

.DEFAULT_GOAL := all

ifeq (${BRANCH}, master) 
        BRANCH=latest
endif

ifneq ($(shell echo $(LASTCOMMIT) | grep -E '^v([0-9]+\.){0,2}(\*|[0-9]+)'),)
        BRANCH=${LASTCOMMIT}
else
        BRANCH=latest
endif

build:
	@echo ">>>> Build docker image: latest"
	@docker build --build-arg TAG=${TAG} --build-arg BUILDDATE=${BUILDDATE} -t ${IMAGEFULLNAME}:latest .

push:
	@echo ">>>> Publish docker image: " ${BRANCH}
	@docker build --push --build-arg TAG=${TAG} --build-arg BUILDDATE=${BUILDDATE} -t ${IMAGEFULLNAME}:${BRANCH} .
	@docker build --push --build-arg TAG=${TAG} --build-arg BUILDDATE=${BUILDDATE} -t ${IMAGEFULLNAME}:latest .

seccheck:
	grype --add-cpes-if-none dir:.

imagecheck:
	trivy image ${IMAGEFULLNAME}:${BRANCH} 

sboom:
	syft dir:. > sbom.txt
	syft dir:. -o json > sbom.json


all: seccheck sboom build imagecheck
