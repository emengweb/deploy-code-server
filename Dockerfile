# Start from the code-server Debian base image
FROM codercom/code-server:latest

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
# RUN code-server --install-extension esbenp.prettier-vscode

# Install apt packages:
# RUN sudo apt-get install -y ubuntu-make

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

RUN . /etc/lsb-release && \
    apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime && \
    apt-get install -y curl locales gnupg2 tzdata && locale-gen en_US.UTF-8 && \
    curl -sL https://deb.nodesource.com/setup_current.x | bash - && \
    apt-get upgrade -y && \
    apt-get install -y  \
      inetutils-ping \
      sudo \
      openssl \
      net-tools \
      openvpn \
      jq \
      git \
      tree \
      locales \ 
      curl \
      dumb-init \
      wget \
      httpie \
      nodejs \
      python \
      python3-pip \
      joe \
      ansible \
      bash-completion \
      openssh-client \
      default-jdk && \
    npm install -g npm && \
    npm i -g nodemon && \
    npm i -g apostrophe-cli && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* 

RUN locale-gen en_US.UTF-8 && \
    cd /tmp && \
    
ENV LC_ALL=en_US.UTF-8

RUN mkdir -p projects && mkdir -p certs && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.35.3/install.sh | bash && \
    
RUN sudo apt-get install -y ubuntu-make

RUN code-server --install-extension ms-azuretools.vscode-cosmosdb
RUN code-server --install-extension punkave.apostrophecms-vs-snippets
RUN code-server --install-extension tabnine.tabnine-vscode
RUN code-server --install-extension GitHub.copilot

# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
