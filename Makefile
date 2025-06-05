# F1 Dashboard Docker Management

.PHONY: help build up down restart logs status clean rebuild dev

# Default target
help:
	@echo "🏎️  F1 Dashboard Docker Management"
	@echo ""
	@echo "Available commands:"
	@echo "  make build     - Build all Docker images"
	@echo "  make up        - Start all services"
	@echo "  make down      - Stop all services"
	@echo "  make restart   - Restart all services"
	@echo "  make logs      - Show logs from all services"
	@echo "  make status    - Show status of all services"
	@echo "  make clean     - Remove all containers, networks, and volumes"
	@echo "  make rebuild   - Clean rebuild and start"
	@echo "  make dev       - Start in development mode with hot reload"
	@echo ""

# Build all images
build:
	@echo "🔨 Building Docker images..."
	docker-compose build --no-cache

# Start services
up:
	@echo "🚀 Starting F1 Dashboard services..."
	docker-compose up -d
	@echo "✅ Services started!"
	@echo "🌐 Frontend: http://localhost:3000"
	@echo "🔌 Backend: http://localhost:3001"

# Stop services
down:
	@echo "🛑 Stopping F1 Dashboard services..."
	docker-compose down

# Restart services
restart:
	@echo "🔄 Restarting F1 Dashboard services..."
	docker-compose restart

# Show logs
logs:
	@echo "📋 Showing logs from all services..."
	docker-compose logs -f

# Show service status
status:
	@echo "📊 Service Status:"
	docker-compose ps
	@echo ""
	@echo "🏥 Health Status:"
	docker-compose exec postgres pg_isready -U postgres -d f1db || echo "❌ Database not ready"
	docker-compose exec server node healthcheck.js || echo "❌ Server not healthy"
	docker-compose exec client wget --spider -q http://localhost:80/ && echo "✅ Client healthy" || echo "❌ Client not healthy"

# Clean everything
clean:
	@echo "🧹 Cleaning up Docker resources..."
	docker-compose down --rmi all --volumes --remove-orphans
	docker system prune -f

# Full rebuild
rebuild: clean build up

# Development mode with hot reload
dev:
	@echo "🛠️  Starting in development mode..."
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Database operations
db-connect:
	@echo "🔌 Connecting to database..."
	docker-compose exec postgres psql -U postgres -d f1db

db-backup:
	@echo "💾 Creating database backup..."
	docker-compose exec postgres pg_dump -U postgres f1db > backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "✅ Backup created: backup_$$(date +%Y%m%d_%H%M%S).sql"

# Quick setup
quick-start: build up
	@echo "⏳ Waiting for services to be ready..."
	@sleep 10
	@make status

# Production deployment
prod: 
	@echo "🚀 Starting production deployment..."
	docker-compose -f docker-compose.yml up -d --scale server=2
	@echo "✅ Production deployment complete!"
