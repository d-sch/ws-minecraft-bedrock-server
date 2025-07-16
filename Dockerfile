FROM ubuntu:latest AS base
LABEL prebuild=true
ARG BDS_Version=latest
ENV MC_SERVER_DIR="/bedrock-server"
ENV VERSION=$BDS_Version

WORKDIR ${MC_SERVER_DIR}

# Install dependencies
RUN apt-get update && \
    apt-get install -y unzip curl && \
    rm -rf /var/lib/apt/lists/*

FROM base AS mc
# Download and extract the bedrock server
RUN if [ "$VERSION" = "latest" ] ; then \
        LATEST_VERSION=$( \
            curl -v --location --compressed --silent 'https://net-secondary.web.minecraft-services.net/api/v1.0/download/links' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H 'User-Agent: d-sch/ws-minecraft-bedrock-server' | \
            grep -o 'https://www.minecraft.net/bedrockdedicatedserver/bin-linux/[^"]*' | \
            sed 's#.*/bedrock-server-##' | sed 's/.zip//') && \
        export VERSION=$LATEST_VERSION && \
        echo "Setting VERSION to $LATEST_VERSION" ; \
    else echo "Using VERSION of $VERSION"; \
    fi && \
    curl https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-${VERSION}.zip -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H 'User-Agent: d-sch/ws-minecraft-bedrock-server' --output ./bedrock-server.zip && \
    unzip ./bedrock-server.zip -d ${MC_SERVER_DIR} && \
    rm ./bedrock-server.zip

FROM base AS wds
ENV WDS_DIR="/websocketd"
ENV WSD_VERSION="0.3.0"

WORKDIR ${WDS_DIR}

RUN curl --location https://github.com/joewalnes/websocketd/releases/download/v${WSD_VERSION}/websocketd-${WSD_VERSION}-linux_amd64.zip --output ./websocketd.zip && \
     unzip ./websocketd.zip -d ${WDS_DIR} && \
     rm ./websocketd.zip

FROM ubuntu:latest
LABEL prebuild=false
ENV WDS_DIR="/websocketd"
ENV MC_SERVER_DIR="/bedrock-server"
ENV SRV_MC_SERVER_DIR="/srv/bedrock-server"

WORKDIR ${MC_SERVER_DIR}

RUN apt-get update && apt-get install -y libcurl4 ncat

COPY --from=mc ${MC_SERVER_DIR}/ .
COPY --from=wds ${WDS_DIR}/websocketd .

VOLUME ${SRV_MC_SERVER_DIR}/worlds ${SRV_MC_SERVER_DIR}/config

EXPOSE 19132/udp
EXPOSE 8080

ENV LD_LIBRARY_PATH=.
COPY *.sh ./

CMD ["/bin/bash", "./mc_start.sh"]
