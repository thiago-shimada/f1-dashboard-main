#!/bin/bash
echo "Setting up F1 Dashboard development environment..."

echo "Installing main dependencies..."
npm install

# Install server dependencies
echo "Installing server dependencies..."
cd server
npm install
cd ..

# Install client dependencies
echo "Installing client dependencies..."
cd client
npm install
cd ..

echo "Setup complete!"
echo "- To start everything (database and servers): ./run.sh"
echo "- To start only the database: cd database && docker compose up -d"
echo "- To start only the development servers: npm run dev"
