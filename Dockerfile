#################################################
#                                               #
#               Dockerfile arguments            #
#                                               #
#################################################
# Tag of the runtime image. Use 'latest' for
# release builds, or 'debug' if you need shell
# access inside the runtime image.
# e.g: docker build --arg RT_TAG=debug ...
ARG                             RT_TAG='latest'
# Image to build Versio in, make sure it and the
# RT_IMAGE use the same version of Debian
ARG                             BUILD_IMAGE=docker.io/library/rust:slim-bullseye
# Runtime / release image, should be as small as
# possible
ARG                             RT_IMAGE=gcr.io/distroless/base-debian11:${RT_TAG}
# Version of Versio to build
ARG                             VERSIO_VERSION=0.7.1
#################################################
#                                               #
#               Build Versio                    #
#                                               #
#################################################
FROM                            $BUILD_IMAGE AS build
ARG                             VERSIO_VERSION
RUN                             apt-get update && \
                                apt-get install -y \
                                    openssl \
                                    libssl-dev \
                                    libgpgme-dev \
                                    pkg-config && \
                                    mkdir -p /dist 

RUN  cargo install versio --version 0.7.1 --root /dist
RUN ldd /dist/bin/versio && /dist/bin/versio --version
#################################################
#                                               #
#               Runtime image                   #
#                                               #
#################################################
FROM                            $RT_IMAGE AS rt
ARG                             BUILD_IMAGE
ARG                             RT_IMAGE
ARG                             VERSIO_VERSION
LABEL                           build-image=$BUILD_IMAGE
LABEL                           rt-image=$RT_IMAGE
LABEL                           versio-version=$VERSIO_VERSION
#WORKDIR                         /workspace
#VOLUME                          /workspace
COPY --from=build               /dist/bin/ /bin/
COPY --from=build               /usr/lib/x86_64-linux-gnu/libgpg* /usr/lib/x86_64-linux-gnu/
COPY --from=build               /lib/x86_64-linux-gnu/libgpg* /lib/x86_64-linux-gnu/
COPY --from=build               /lib/x86_64-linux-gnu/libgcc_s* /lib/x86_64-linux-gnu/
COPY --from=build               /usr/lib/x86_64-linux-gnu/libassuan* /usr/lib/x86_64-linux-gnu/
#RUN                             ls /bin/
# COPY                            entrypoint.sh /entrypoint.sh
ENTRYPOINT                      ["/bin/versio"]
CMD                             ["-m", "local", "-x", "smart", "plan"]
