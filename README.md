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
├── client/          # React frontend (submodule)
├── server/          # Express backend (submodule)
├── docs/           # Documentation
└── README.md       # This file
```

## Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL database with F1 schema
- Git

### Installation

1. Clone the repository with submodules:
```bash
git clone --recurse-submodules https://github.com/YOUR_USERNAME/f1-dashboard-main.git
cd f1-dashboard-main
```

2. Install dependencies:
```bash
# Install server dependencies
cd server
npm install

# Install client dependencies
cd ../client
npm install
```

3. Configure database connection in \`server/server.js\`

4. Start the applications:
```bash
# Terminal 1 - Start backend
cd server
node server.js

# Terminal 2 - Start frontend
cd client
npm start
```

5. Access the application at \`http://localhost:3000\`

## Development

### Adding New Features
- Follow PascalCase for component names
- Use camelCase for variables and functions
- Implement proper error boundaries
- Log errors with contextual information

### Database Requirements
The application requires the following PostgreSQL functions:
- `Autentica_Usuario(varchar, varchar)`
- `ObterInfoUsuario(varchar)`
- `VitoriasEscuderia(integer)`
- `PilotosEscuderia(integer)`
- `AnosEscuderia(integer)`
- `AnosPiloto(integer)`
- `EstatisticasPiloto(integer)`

## Contributing

1. Create feature branches from main
2. Follow the established coding standards
3. Add comprehensive error handling
4. Update documentation as needed
