
IMAGE="trifacta/clang:3.6"
DEBIMAGE=${IMAGE}-deb

all:

# Note, building the Docker image needs the default image size increased.
# On Fedora: add "--storage-opt dm.basesize=30G" to /etc/sysconfig/docker.

docker-build:
	docker build -t ${IMAGE} .

docker-build-deb:
	docker build -t ${DEBIMAGE} deb
	docker run --rm -v ${PWD}:/target ${DEBIMAGE}

docker-run:
	docker run -i -t ${IMAGE}

docker-push:
	docker push ${IMAGE}
