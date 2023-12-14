include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

define print_download
  @$(call print_notice,Downloading $@...)
endef

RANCHER_VERSION := 2.7.9
JETSTACK_VERSION := 1.12.3
INGINX_VERSION := 4.8.0

CHART_NAME := rancher-prime-byos
APP_ID ?= $(CHART_NAME)

TRACK ?= 2.7
$(info ---- TRACK = $(TRACK))

VERIFY_WAIT_TIMEOUT = 1800

#SOURCE_REGISTRY ?= marketplace.gcr.io/google
SOURCE_REGISTRY ?= gcr.io/mp-images-public
IMAGE_RANCHER ?= $(SOURCE_REGISTRY)/${APP_ID}/rancher:$(TRACK)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_RANCHER))

#C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))
C2D_CONTAINER_RELEASE := $(RANCHER_VERSION)

$(info ---- C2D_CONTAINER_RELEASE = $(C2D_CONTAINER_RELEASE))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester \
	    .build/installer

# Build installer image
INSTALLER_IMAGE ?= $(REGISTRY)/$(APP_ID):$(RELEASE)
INSTALLER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID):$(TRACK)
INSTALLER_CHARTS_DIR := installer/charts
RANCHER_CHART_TGZ := $(INSTALLER_CHARTS_DIR)/rancher-$(RANCHER_VERSION).tgz
JETSTACK_CHART_TGZ := $(INSTALLER_CHARTS_DIR)/cert-manager-v$(JETSTACK_VERSION).tgz
INGINX_CHART_TGZ := $(INSTALLER_CHARTS_DIR)/ingress-nginx-$(INGINX_VERSION).tgz

installer/build:: .build/installer

$(INSTALLER_CHARTS_DIR):
	mkdir -p "$@"

$(RANCHER_CHART_TGZ):
	$(call print_download,$0)
	helm pull --destination $(INSTALLER_CHARTS_DIR) --version $(RANCHER_VERSION) --repo https://releases.rancher.com/server-charts/stable rancher

$(JETSTACK_CHART_TGZ):
	$(call print_download,$0)
	helm pull --destination $(INSTALLER_CHARTS_DIR) --version $(JETSTACK_VERSION) --repo https://charts.jetstack.io cert-manager

$(INGINX_CHART_TGZ):
	$(call print_download,$0)
	helm pull --destination $(INSTALLER_CHARTS_DIR) --version $(INGINX_VERSION) --repo https://kubernetes.github.io/ingress-nginx ingress-nginx

.PHONY: .build/RANCHER_TGZ
.build/RANCHER_TGZ: $(RANCHER_CHART_TGZ)

.PHONY: .build/JETSTACK_TGZ
.build/JETSTACK_TGZ: $(JETSTACK_CHART_TGZ)

.PHONY: .build/INGINX_TGZ
.build/INGINX_TGZ: $(INGINX_CHART_TGZ)

.build/installer: installer/run \
                  .build/RANCHER_TGZ \
                  .build/JETSTACK_TGZ \
                  .build/INGINX_TGZ \
                  .build/var/RANCHER_VERSION \
                  .build/var/JETSTACK_VERSION \
                  .build/var/MARKETPLACE_TOOLS_TAG \
                  .build/var/INSTALLER_IMAGE \
                  .build/var/INSTALLER_IMAGE_TRACK_TAG \
                  | .build/$(CHART_NAME)
	$(call print_target,$0)
	docker build \
		--build-arg RANCHER_VERSION="$(RANCHER_VERSION)" \
		--build-arg JETSTACK_VERSION="$(JETSTACK_VERSION)" \
		--build-arg INGINX_VERSION="$(INGINX_VERSION)" \
		--build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
		--tag "$(INSTALLER_IMAGE)" \
		-f installer/Dockerfile \
		.
	docker tag "$(INSTALLER_IMAGE)" "$(INSTALLER_IMAGE_TRACK_TAG)"
	docker push "$(INSTALLER_IMAGE)"
	docker push "$(INSTALLER_IMAGE_TRACK_TAG)"
	@touch "$@"
