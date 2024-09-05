# syntax=docker/dockerfile:1.3-labs

# updateBaseImages.sh can't operate on SHA-based tags as they're not date-based or semver-sequential, and therefore cannot be ordered
# FROM quay.io/devfile/base-developer-image:ubi8-latest
FROM linhnt35/ubi8-with-user:v1.0
LABEL maintainer="Red Hat, Inc."

LABEL com.redhat.component="devfile-universal-container"
LABEL name="devfile/universal-developer-image"
LABEL version="ubi8"

#label for EULA
LABEL com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI"

#labels for container catalog
LABEL summary="devfile universal developer image"
LABEL description="Image with developers tools. Languages SDK and runtimes included."
LABEL io.k8s.display-name="devfile-developer-universal"
LABEL io.openshift.expose-services=""

USER 0

# $PROFILE_EXT contains all additions made to the bash environment
ENV PROFILE_EXT=/etc/profile.d/udi_environment.sh
RUN touch ${PROFILE_EXT} & chown 10001 ${PROFILE_EXT}

USER 10001

# We install everything to /home/tooling/ as /home/user/ may get overriden, see github.com/eclipse/che/issues/22412
ENV HOME=/home/tooling

# Java
RUN curl -fsSL "https://get.sdkman.io/?rcupdate=false" | bash \
    && bash -c ". /home/tooling/.sdkman/bin/sdkman-init.sh \
             && sed -i "s/sdkman_auto_answer=false/sdkman_auto_answer=true/g" /home/tooling/.sdkman/etc/config \
	     && sed -i "s/sdkman_auto_env=false/sdkman_auto_env=true/g" /home/tooling/.sdkman/etc/config \
             && sdk install java 8.0.402-tem \
             && sdk install java 11.0.22-tem \
             && sdk install java 17.0.10-tem \
             && sdk install java 21.0.2-tem \
             && sdk install java 23.1.2.r21-mandrel \
             && sdk default java 17.0.10-tem \
             && sdk install gradle \
             && sdk install maven \
             && sdk install jbang \
             && sdk flush archives \
             && sdk flush temp" \
         && chgrp -R 0 /home/tooling && chmod -R g=u /home/tooling

# sdk home java <version>
ENV JAVA_HOME_8=/home/tooling/.sdkman/candidates/java/8.0.402-tem
ENV JAVA_HOME_11=/home/tooling/.sdkman/candidates/java/11.0.22-tem
ENV JAVA_HOME_17=/home/tooling/.sdkman/candidates/java/17.0.10-tem
ENV JAVA_HOME_21=/home/tooling/.sdkman/candidates/java/21.0.2-tem

# Java-related environment variables are described and set by ${PROFILE_EXT}, which will be loaded by ~/.bashrc
# To make Java working for dash and other shells, it needs to initialize them in the Dockerfile.
ENV SDKMAN_CANDIDATES_API="https://api.sdkman.io/2"
ENV SDKMAN_CANDIDATES_DIR="/home/tooling/.sdkman/candidates"
ENV SDKMAN_DIR="/home/tooling/.sdkman"
ENV SDKMAN_PLATFORM="linuxx64"
ENV SDKMAN_VERSION="5.18.2"

ENV GRADLE_HOME="/home/tooling/.sdkman/candidates/gradle/current"
ENV JAVA_HOME="/home/tooling/.sdkman/candidates/java/current"
ENV MAVEN_HOME="/home/tooling/.sdkman/candidates/maven/current"

ENV GRAALVM_HOME=/home/tooling/.sdkman/candidates/java/23.1.2.r21-mandrel

ENV PATH="/home/tooling/.krew/bin:$PATH"
ENV PATH="/home/tooling/.sdkman/candidates/maven/current/bin:$PATH"
ENV PATH="/home/tooling/.sdkman/candidates/java/current/bin:$PATH"
ENV PATH="/home/tooling/.sdkman/candidates/gradle/current/bin:$PATH"
ENV PATH="/home/tooling/.local/share/coursier/bin:$PATH"

# NodeJS
RUN mkdir -p /home/tooling/.nvm/
ENV NVM_DIR="/home/tooling/.nvm"
ENV NODEJS_20_VERSION=20.7.0
ENV NODEJS_18_VERSION=18.19.1
ENV NODEJS_DEFAULT_VERSION=${NODEJS_18_VERSION}
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | PROFILE=/dev/null bash
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ${PROFILE_EXT} \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ${PROFILE_EXT}
RUN source /home/user/.bashrc && source $NVM_DIR/nvm.sh && \
    nvm install v${NODEJS_20_VERSION} && \
    nvm install v${NODEJS_18_VERSION} && \
    nvm alias default v${NODEJS_DEFAULT_VERSION} && nvm use v${NODEJS_DEFAULT_VERSION} && \
    npm install --global yarn@v1.22.17 &&\
    chgrp -R 0 /home/tooling && chmod -R g=u /home/tooling
ENV PATH=$NVM_DIR/versions/node/v${NODEJS_DEFAULT_VERSION}/bin:$PATH
ENV NODEJS_HOME_20=$NVM_DIR/versions/node/v${NODEJS_20_VERSION}
ENV NODEJS_HOME_18=$NVM_DIR/versions/node/v${NODEJS_18_VERSION}

USER 0

# Required packages for AWT
RUN dnf install -y libXext libXrender libXtst libXi

# Lombok
ENV LOMBOK_VERSION=1.18.18
RUN wget -O /usr/local/lib/lombok.jar https://projectlombok.org/downloads/lombok-${LOMBOK_VERSION}.jar

# Scala
RUN curl -fLo cs https://git.io/coursier-cli && \
    chmod +x cs && \
    mv cs /usr/local/bin/
RUN curl -fLo sbt https://raw.githubusercontent.com/dwijnand/sbt-extras/master/sbt && \
    chmod +x sbt && \
    mv sbt /usr/local/bin/
RUN curl -fLo mill https://raw.githubusercontent.com/lefou/millw/main/millw && \
    chmod +x mill && \
    mv mill /usr/local/bin/

# C/CPP
RUN dnf -y install llvm-toolset gcc gcc-c++ clang clang-libs clang-tools-extra gdb

# Go 1.18+    - installed to /usr/bin/go
# gopls 0.10+ - installed to /home/tooling/go/bin/gopls and /home/tooling/go/pkg/mod/
RUN dnf install -y go-toolset && \
    GO111MODULE=on go install -v golang.org/x/tools/gopls@latest && \
    chgrp -R 0 /home/tooling && chmod -R g=u /home/tooling
ENV GOBIN="/home/tooling/go/bin/"
ENV PATH="$GOBIN:$PATH"

RUN mkdir -p /home/tooling/certs && \
    mkdir -p /home/tooling/.m2 && \
    mkdir -p /home/tooling/.gradle && \
    mkdir -p /home/tooling/.sbt/1.0 && \
    mkdir -p /home/tooling/.nuget && \
    chgrp -R 0 /home/tooling && chmod -R g=u /home/tooling
 

# Configure container engine
COPY --chown=0:0 containers.conf /etc/containers/containers.conf

RUN echo 'alias docker=podman' >> ${PROFILE_EXT}

## Add sdkman's init script launcher to the end of ${PROFILE_EXT} since we are not adding it on sdkman install
## NOTE: all modifications to ${PROFILE_EXT} must happen BEFORE this step in order for sdkman to function correctly
RUN echo 'export SDKMAN_DIR="/home/tooling/.sdkman"' >> ${PROFILE_EXT}
RUN echo '[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"' >> ${PROFILE_EXT}



# Bash completions
RUN dnf -y install bash-completion \
    && dnf clean all \
    && rm -rf /var/cache/yum

RUN <<EOF
cat ${NVM_DIR}/bash_completion > /usr/share/bash-completion/completions/nvm
EOF

# Create symbolic links from /home/tooling/ -> /home/user/
RUN stow . -t /home/user/ -d /home/tooling/ --no-folding

# Set permissions on /etc/passwd, /etc/group, /etc/pki and /home to allow arbitrary users to write
RUN chgrp -R 0 /home && chmod -R g=u /etc/passwd /etc/group /home /etc/pki

# cleanup dnf cache
RUN dnf -y clean all --enablerepo='*'

COPY --chown=0:0 entrypoint.sh /

USER 10001

ENV HOME=/home/user
