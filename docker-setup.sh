#!/bin/bash

# F1 Dashboard Docker Setup Script
echo "🏎️  Setting up F1 Dashboard with Docker..."

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p database/data
mkdir -p server/uploads

# Build and start the services
echo "🐳 Building and starting Docker containers..."
docker-compose down --remove-orphans 2>/dev/null || true
docker-compose build --no-cache
docker-compose up -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if docker-compose exec -T postgres pg_isready -U postgres -d f1db >/dev/null 2>&1; then
        echo "✅ Database is ready!"
        break
    fi
    attempt=$((attempt + 1))
    echo "   Attempt $attempt/$max_attempts - waiting for database..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ Database failed to start within timeout period"
    docker-compose logs postgres
    exit 1
fi

# Check if all services are running
echo "🔍 Checking service status..."
if docker-compose ps | grep -q "Up"; then
    echo ""
    echo "🎉 F1 Dashboard is now running!"
    echo ""
    echo "🌐 Frontend (React): http://localhost:3000"
    echo "🔌 Backend API: http://localhost:3001"
    echo "🗄️  PostgreSQL: localhost:5432"
    echo ""
    echo "📊 You can now access the F1 Dashboard at http://localhost:3000"
    echo ""
    echo "🛠️  Useful commands:"
    echo "   View logs: docker-compose logs -f"
    echo "   Stop services: docker-compose down"
    echo "   Rebuild: docker-compose build --no-cache"
    echo "   Restart: docker-compose restart"
    echo ""
else
    echo "❌ Some services failed to start. Check logs with: docker-compose logs"
    docker-compose ps
    exit 1
fi
