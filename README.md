# New Linux Setup Script Documentation

## Overview

This project aims to streamline the setup of a Debian-based Linux development environment by automating the installation of essential development tools and packages. The script is designed to work both in Docker containers and on physical machines.

## Repository Structure

```
new_linux_setup
├── Dockerfile
├── linux_setup.sh
├── Makefile
├── packages.json
├── README.md
└── version_check.sh
```

### Files Description

- **Dockerfile**: Defines the Docker image and the steps to run the setup scripts.
- **linux_setup.sh**: Main script to install packages and configure the environment.
- **Makefile**: Provides commands to build, run, and clean Docker containers.
- **packages.json**: JSON file listing the packages to be installed (not currently in use).
- **version_check.sh**: Script to verify the installation and versions of the packages.

## Dockerfile

The Dockerfile sets up a minimal Debian environment, copies the setup scripts, and runs them to install the necessary packages.

```dockerfile
FROM debian:bookworm-slim

COPY linux_setup.sh version_check.sh /tmp/

RUN /tmp/linux_setup.sh 
RUN /tmp/version_check.sh
```

## Makefile

The Makefile includes targets to build, run, and manage Docker containers for testing the setup script.

```makefile
# Define the image name
IMAGE_NAME="linux_packages_test"

# Stop the previous container
stop:
	@if [ "$(docker ps -aqf name=$(IMAGE_NAME))"]; then \
		docker stop $(IMAGE_NAME); \
	fi

# Remove any previous container (optional)
clean: stop
	@if [ "$(docker ps -aqf name=$(IMAGE_NAME))"]; then \
		docker rm $(shell docker ps -aqf name=${IMAGE_NAME}); \
	fi

# Build the image
build: clean
	docker build -t $(IMAGE_NAME) .

# Run the built image
run: build  # Clean first, then Builds, then Runs
	docker run $(IMAGE_NAME)

# Run the built image interactively
run-it: build
	docker run -it $(IMAGE_NAME)
	
# Clean up unused resources
prune: stop
	docker system prune

.PHONY: build clean run run-it prune
```

## linux_setup.sh

The `linux_setup.sh` script installs essential packages, development tools, and other utilities. It detects whether it is running in a Docker container and adapts its behavior accordingly.



## version_check.sh

This script checks the versions of installed packages to verify successful installations.

## Usage

1. **Running in Docker:**
   - Build and run the Docker container using the Makefile:
     ```sh
     make run
     ```

2. **Running on Physical Machine:**
   - Ensure the script has executable permissions:
     ```sh
     chmod +x linux_setup.sh
     ```
   - Execute the script:
     ```sh
     ./linux_setup.sh
     ```

## Conclusion

This setup script simplifies the installation and configuration of a Debian-based development environment, ensuring all necessary tools and packages are readily available. The use of Docker and Makefile enhances reproducibility and ease of use, making it suitable for both individual development and team environments.