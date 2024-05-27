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
