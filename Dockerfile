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

RUN sudo apt-get install -y curl locales gnupg2 tzdata 
RUN sudo locale-gen en_US.UTF-8
#RUN sudo curl -sL https://deb.nodesource.com/setup_current.x | bash -
RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
#RUN sudo apt-get upgrade -y
RUN sudo apt-get install -y apt-utils
RUN sudo apt-get install -y inetutils-ping sudo openssl net-tools openvpn jq git tree locales curl dumb-init wget httpie nodejs python python3-pip joe ansible bash-completion openssh-client default-jdk
RUN sudo npm install -g npm
RUN sudo npm i -g nodemon
RUN sudo npm i -g apostrophe-cli
RUN sudo apt clean
RUN sudo rm -rf /var/lib/apt/lists/* 

RUN sudo locale-gen en_US.UTF-8 
    
ENV LC_ALL=en_US.UTF-8

RUN sudo mkdir -p project 
RUN sudo curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.35.3/install.sh | bash
    
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
