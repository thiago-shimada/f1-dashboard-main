# F1 Dashboard Application

A comprehensive Formula 1 dashboard application with role-based access control.

## Architecture

This project consists of two main components:
- **Client**: React.js frontend application
- **Server**: Express.js backend API

## Features

### User Roles
- **Administrator**: Full system access, can insert drivers and constructors
- **Escuderia (Constructor)**: Team-specific views, driver search, file uploads
- **Piloto (Driver)**: Personal statistics and career information

### Key Functionality
- Role-based authentication via PostgreSQL functions
- Dynamic dashboard views based on user permissions
- Paginated data views with advanced filtering
- File upload system for bulk driver imports
- Responsive UI with Tailwind CSS
- Session management and security features

## Project Structure

```
f1-dashboard-main/
├── client/          # React frontend
├── server/          # Express backend
├── database/        # PostgreSQL database setup with Docker Compose
│   ├── data/        # PostgreSQL database will be stored here
│   ├── init/        # SQL initialization scripts
│   └── data_files/  # CSV/TSV files for database population
└── README.md       # This file
```

## Quick Start

### Prerequisites
- Node.js 18+
- Docker and Docker Compose (for database setup)
- Git

### Installation

1. Clone the repository with submodules:
```bash
git clone --recurse-submodules https://github.com/thiago-shimada/f1-dashboard-main.git
cd f1-dashboard-main
```

2. Install dependencies:
```bash
# Install main dependencies
npm install

# Install server dependencies
cd server
npm install

# Install client dependencies
cd ../client
npm install
```

Alternatively, you can run
```bash
./setup.sh
```

3. Set up and start the database:
```bash
# Start PostgreSQL database with Docker
cd database
docker compose up -d
cd ..
```

4. Start the applications:
```bash
# Run both client and server
npm run dev
```

Alternatively, you can run the all-in-one setup script:
```bash
./run.sh
```

5. Access the application at `http://localhost:3000`

## Development

### Adding New Features
- Follow PascalCase for component names
- Use camelCase for variables and functions
- Implement proper error boundaries
- Log errors with contextual information

### Database Requirements
The PostgreSQL database is set up automatically with Docker Compose and contains:
- F1 race data, drivers, constructors, and results
- Required authentication functions:
  - `Autentica_Usuario(varchar, varchar)`
  - `ObterInfoUsuario(varchar)`
- User accounts for different role types
- Indexes for query optimization

All initialization scripts are located in the `database/init/` directory.

## Contributing

1. Create feature branches from main
2. Follow the established coding standards
3. Add comprehensive error handling
4. Update documentation as needed
