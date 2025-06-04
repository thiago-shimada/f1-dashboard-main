#!/bin/bash

echo "Starting F1 Dashboard environment..."

# Start PostgreSQL database with Docker Compose
echo "Starting PostgreSQL database..."
cd database
docker compose up -d
cd ..

# Wait for database to be ready
echo "Waiting for database to initialize (10 seconds)..."
sleep 10

# Start development servers
echo "Starting development servers..."
npm run dev

echo "F1 Dashboard environment has been started!"
