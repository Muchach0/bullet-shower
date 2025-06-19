@PHONY: all build run clean export-client-html docker-client-build-run docker-client-run docker-client-rm docker-client-update gcp-trigger-build gcp-init-dns

DOCKER_IMAGE = muchachoo/bullet-shower
DOCKER_IMAGE_TAG = 1
GCP_CLOUD_RUN_SERVICE = bullet-shower-client
DNS_ZONE = muchacho-app
DNS_NAME = bullet.muchacho.app
CURRENT_BUILD_VERSION_FILE_PATH = builds/build_version.cfg
CURRENT_VERSION = $(shell cat $(CURRENT_BUILD_VERSION_FILE_PATH))
NEXT_VERSION = $(shell echo $$(($(CURRENT_VERSION) + 1)))
DOCKER_IMAGE_VERSION = v$(NEXT_VERSION)

export-client-html:
	../Godot_v4.4.1-stable_linux.x86_64 --headless --path $(shell pwd) --export-release "Web" $(shell pwd)/builds/client-html/index.html


# ========================== CLIENT HTML DOCKER SECTION =========================
docker-client-build-run: export-client-html ## Build client container
	docker build -f builds/Dockerfile-client -t godot-client .
	docker run --name=godot-client --restart unless-stopped --network host --volume "$(shell pwd)/logs:/tmp/logs" -d -t godot-client
	xdg-open https://127.0.0.1

docker-client-run: ## Run client container
	docker run --name=godot-client --restart unless-stopped --network host --volume "$(shell pwd)/logs:/tmp/logs" -d -t godot-client
	xdg-open https://127.0.0.1

docker-client-rm:
	docker container stop godot-client
	docker container rm godot-client
	docker image rm godot-client

docker-client-update: docker-client-rm docker-client-build-run


# =========================== GCP SECTION ===========================
push-new-docker-image:
	docker build -t $(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION) -f builds/Dockerfile-client .
	docker push $(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION)
	echo $(NEXT_VERSION) > $(CURRENT_BUILD_VERSION_FILE_PATH)
	@echo "Updated version to: $(NEXT_VERSION)"

# gcp-init-docker-registry: 
# 	gcloud artifacts repositories create bullet-shower-game --repository-format=docker --location=europe-west1 --description="My Snake Game Docker Repository"

gcp-trigger-build: export-client-html push-new-docker-image ## Trigger GCP build
	@echo "Using Docker image:  $(DOCKER_IMAGE):v$(CURRENT_VERSION)"
	gcloud run deploy $(GCP_CLOUD_RUN_SERVICE) \
          --image $(DOCKER_IMAGE):v$(CURRENT_VERSION) \
          --region europe-west1 \
          --platform managed \
          --allow-unauthenticated \
          --max-instances=1 \
          --port 80 \
          --use-http2
	xdg-open https://$(DNS_NAME)

gcp-init-dns: ## Initialize DNS for GCP
	gcloud dns record-sets transaction start --zone=$(DNS_ZONE)
	gcloud dns record-sets transaction add --zone=$(DNS_ZONE) --name="$(DNS_NAME)" --type=CNAME --ttl=432000 "ghs.googlehosted.com."
	gcloud dns record-sets transaction execute --zone=$(DNS_ZONE)
	gcloud beta run domain-mappings create --service $(GCP_CLOUD_RUN_SERVICE) --domain $(DNS_NAME) --region europe-west1