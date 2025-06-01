#!/bin/bash
echo "Setting up F1 Dashboard development environment..."

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

echo "Setup complete! Run 'npm run dev' to start both servers."
