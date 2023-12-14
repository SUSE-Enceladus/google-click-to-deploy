ARG MARKETPLACE_TOOLS_TAG

FROM marketplace.gcr.io/google/c2d-debian11 AS build

ARG CHART_NAME
ARG RANCHER_VERSION
ARG JETSTACK_VERSION
ARG INGINX_VERSION

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gettext

RUN mkdir -p /tmp/app/charts
COPY installer/charts /tmp/app/charts

RUN cd /tmp/app/charts && \
    tar -xaf rancher-$RANCHER_VERSION.tgz && \
    tar -xaf cert-manager-v$JETSTACK_VERSION.tgz && \
    tar -xaf ingress-nginx-$INGINX_VERSION.tgz && \
    rm -f *.tgz

COPY installer/run /tmp/app/run
RUN chmod +x /tmp/app/run

FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm:$MARKETPLACE_TOOLS_TAG

RUN mkdir -p /installer/app
COPY --from=build /tmp/app /installer/app

ENV WAIT_FOR_READY_TIMEOUT 1800
ENV TESTER_TIMEOUT 1800

ENTRYPOINT ["/bin/bash", "/installer/app/run"]
CMD ["install"]
