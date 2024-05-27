#!/bin/bash

# Function to print messages
print_message() {
    echo "-----------------------------------"
    echo "$1"
    echo "-----------------------------------"
}

# Check if running in Docker environment by looking for /.dockerenv file
if [ -f /.dockerenv ]; then
    DOCKER_ENV=true
else
    DOCKER_ENV=false
fi

# Function to install packages using apt
install_packages() {
    local packages=("$@")
    if [ "$DOCKER_ENV" = true ]; then
        echo "installing ${packages[@]}"
        apt-get install -y "${packages[@]}"
    else
        echo "installing ${packages[@]}"
        sudo apt-get install -y "${packages[@]}"
    fi
}

# Update package lists
print_message "Updating package lists"
if [ "$DOCKER_ENV" = true ]; then
    apt-get update
else
    sudo apt-get update
fi

# Function to install pipx and poetry
install_pipx_and_poetry() {
    # Check for pipx
    if ! command -v pipx &> /dev/null; then
        print_message "pipx is not installed. Installing..."
        install_packages pipx

        # Install Poetry using pipx
        print_message "Installing Poetry with pipx"
        pipx install poetry
        pipx ensurepath
        # update the .bashrc file for the PATH
        source ~/.bashrc
    fi


}

# Function to install Composer
install_composer() {
    print_message "Installing Composer"

    # Download and install Composer
    curl -sS https://getcomposer.org/installer -o composer-setup.php
    HASH=`curl -sS https://composer.github.io/installer.sig`
    echo $HASH
    if [ "$DOCKER_ENV" = true ]; then
        php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
        php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    else
        sudo php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
        sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    fi

    # Remove temporary setup script
    rm composer-setup.php
}

# Function to install Go
install_go() {
  install_packages golang-go

  # Update environment variables (modify if needed)
  export GOPATH=$HOME/go
  export GOARCH=amd64
  export GOOS=linux
  export PATH=$PATH:/usr/local/go/bin
}


# Function to install Visual Studio Code
install_vscode() {
    print_message "Installing Visual Studio Code"
    if [ "$DOCKER_ENV" = true ]; then
        # Install VS Code from official package repositories (if available)
        apt-get install -y code
    else
        # Install dependencies for adding Microsoft repository
        install_packages software-properties-common apt-transport-https wget

        # Add Microsoft repository for VS Code
        wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"

        # Install VS Code
        install_packages code
    fi
}

# Function to install NVM, source .bashrc, and install Node.js (LTS)
install_nvm_and_node() {
    print_message "Installing NVM"

    # Install NVM using the official installation script
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

    # Source .bashrc (consider alternatives for specific needs)
    print_message "Sourcing .bashrc (consider alternatives for interactive use)"
    source ~/.bashrc

    # Install Node.js (latest LTS version) using NVM
    print_message "Installing Node.js (latest LTS version) using NVM"
    nvm install --lts
}

# Function to install Rust
install_rust() {
    print_message "Installing Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
}

# Function to install tools for non-Docker environment
install_non_docker_tools() {
    if [ "$DOCKER_ENV" = false ]; then
        print_message "Installing Docker and related tools"
        install_packages docker.io apt-transport-https
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        print_message "Installing Kubernetes"
        sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
        install_packages kubectl

        print_message "Installing HashiCorp Vault"
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        install_packages vault
    fi
}

# Function to install essential packages and create a symlink for python3
install_essential_packages() {
    print_message "Installing essential packages"
    # List of essential packages
    local packages=(
    ack-grep autoconf automake build-essential clang curl cmake emacs eslint gdb git gnupg htop iftop mosh make nano ncdu nmap package-cli package-mbstring pass ripgrep rsync sphinx tar tmux tree unzip vlc wget zip
    )

    install_packages "${packages[@]}"
    print_message "Creating symlink for python3 to python"
    if [ "$DOCKER_ENV" = true ]; then
        ln -sf /usr/bin/python3 /usr/bin/python
    else
        sudo ln -sf /usr/bin/python3 /usr/bin/python
    fi
}

# Function to install development packages
install_dev_packages() {
    print_message "Installing Git and additional development tools"
    install_packages git sqlitebrowser
}

# Install essential packages and create symlink for python3
install_essential_packages

# Install development packages
install_dev_packages

# Install tools for non-Docker environment (if applicable)
install_non_docker_tools

# Install Rust
install_rust

# Install Go
install_go

# Install VS Code
install_vscode

# Install pipx and Poetry
install_pipx_and_poetry

# Install Composer
install_composer

# Install NVM, source .bashrc, and install Node.js (LTS)
install_nvm_and_node

# Temporary source command to ensure environment variables are updated
print_message "Reloading shell environment"
exec $SHELL