# K8s Tools Container Makefile

# Variables
IMAGE_NAME = k8s-tools
IMAGE_TAG = latest
CONTAINER_NAME = k8s-tools-container

# Build the Docker image
.PHONY: build
build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Run the container interactively
.PHONY: run
run:
	docker run -it --rm \
		--name $(CONTAINER_NAME) \
		-v ~/.kube:/home/k8suser/.kube:ro \
		-v $(PWD):/workspace \
		--network host \
		$(IMAGE_NAME):$(IMAGE_TAG)

# Run a specific command in the container
.PHONY: exec
exec:
	@if [ -z "$(CMD)" ]; then \
		echo "Usage: make exec CMD='your-command'"; \
		echo "Example: make exec CMD='kubectl get pods'"; \
		exit 1; \
	fi
	docker run --rm \
		-v ~/.kube:/home/k8suser/.kube:ro \
		-v $(PWD):/workspace \
		--network host \
		$(IMAGE_NAME):$(IMAGE_TAG) \
		$(CMD)

# Start container with docker-compose
.PHONY: up
up:
	docker-compose up -d k8s-tools

# Stop and remove containers
.PHONY: down
down:
	docker-compose down

# Get a shell in running container
.PHONY: shell
shell:
	docker-compose exec k8s-tools /bin/bash

# Verify tools in container
.PHONY: verify
verify:
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) verify-tools

# Clean up Docker resources
.PHONY: clean
clean:
	docker-compose down -v
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
	docker system prune -f

# Show container logs
.PHONY: logs
logs:
	docker-compose logs -f k8s-tools

# Build and run in one command
.PHONY: build-run
build-run: build run

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  build      - Build the Docker image"
	@echo "  run        - Run container interactively"
	@echo "  exec       - Execute a command in container (use CMD=)"
	@echo "  up         - Start with docker-compose"
	@echo "  down       - Stop docker-compose services"
	@echo "  shell      - Get shell in running container"
	@echo "  verify     - Verify tools installation"
	@echo "  clean      - Clean up Docker resources"
	@echo "  logs       - Show container logs"
	@echo "  build-run  - Build and run in one step"
	@echo "  help       - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make build"
	@echo "  make run"
	@echo "  make exec CMD='kubectl get nodes'"
	@echo "  make exec CMD='k9s'"