# F1 Dashboard - Docker Deployment Guide

## 🏎️ Overview

This is a complete F1 Dashboard application with Docker containerization support. The application consists of:

- **Frontend**: React.js application with Tailwind CSS
- **Backend**: Node.js/Express API server
- **Database**: PostgreSQL with F1 data
- **Reverse Proxy**: Nginx for production deployment

## 🚀 Quick Start with Docker

### Prerequisites

- Docker Engine 20.10+
- Docker Compose V2
- 4GB+ RAM available
- 10GB+ disk space

### One-Command Setup

```bash
./docker-setup.sh
```

This script will:
1. Build all Docker images
2. Start all services
3. Wait for database initialization
4. Verify all services are running

### Manual Setup

If you prefer manual control:

```bash
# Build and start services
docker-compose up --build -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

## 🌐 Access Points

Once running, access the application at:

- **Frontend**: http://localhost:3000
- **API Backend**: http://localhost:3001
- **Database**: localhost:5432

## 📋 Default Login Credentials

The application comes with pre-configured users:

### Administrator
- **Username**: `admin`
- **Password**: `admin123`

### Constructor (Escuderia)
- **Username**: `ferrari_c`
- **Password**: `ferrari123`

### Driver (Piloto)
- **Username**: `hamilton`
- **Password**: `hamilton123`

## 🐳 Docker Services

### Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   Database      │
│   (React+Nginx) │───▶│   (Node.js)     │───▶│   (PostgreSQL)  │
│   Port: 3000    │    │   Port: 3001    │    │   Port: 5432    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Service Details

#### Frontend (f1_client)
- **Base Image**: nginx:alpine
- **Build**: Multi-stage (Node.js build → Nginx serve)
- **Features**: SPA routing, API proxying, gzip compression
- **Health Check**: HTTP request to root

#### Backend (f1_server)
- **Base Image**: node:18-alpine
- **Features**: Express API, file uploads, session management
- **Health Check**: HTTP request to `/check-auth`
- **Volumes**: `./server/uploads` for file storage

#### Database (f1_postgres)
- **Base Image**: postgres:16.8
- **Features**: Auto-initialization with F1 data
- **Volumes**: Persistent data storage
- **Health Check**: `pg_isready` command

## 🛠️ Development Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f client
docker-compose logs -f server
docker-compose logs -f postgres
```

### Service Management
```bash
# Stop all services
docker-compose down

# Restart services
docker-compose restart

# Rebuild and restart
docker-compose up --build -d

# Scale services (if needed)
docker-compose up -d --scale server=2
```

### Database Operations
```bash
# Connect to database
docker-compose exec postgres psql -U postgres -d f1db

# Backup database
docker-compose exec postgres pg_dump -U postgres f1db > backup.sql

# Restore database
docker-compose exec -T postgres psql -U postgres f1db < backup.sql
```

### Debugging
```bash
# Enter container shell
docker-compose exec server sh
docker-compose exec client sh
docker-compose exec postgres bash

# Check container resources
docker stats

# Inspect networks
docker network ls
docker network inspect f1-dashboard_f1_network
```

## 🔧 Configuration

### Environment Variables

Edit `.env` file to customize:

```env
# Database
DB_HOST=postgres
DB_PORT=5432
DB_NAME=f1db
DB_USER=postgres
DB_PASSWORD=postgres

# Server
NODE_ENV=production
PORT=3001

# Frontend
REACT_APP_API_URL=http://localhost:3001
```

### Docker Compose Override

Create `docker-compose.override.yml` for local customizations:

```yaml
version: '3.8'
services:
  server:
    environment:
      - NODE_ENV=development
    volumes:
      - ./server:/app
    command: npm run dev
```

## 🚨 Troubleshooting

### Common Issues

#### Port Conflicts
```bash
# Check what's using ports
sudo netstat -tulpn | grep :3000
sudo netstat -tulpn | grep :3001
sudo netstat -tulpn | grep :5432

# Kill processes if needed
sudo pkill -f "node"
```

#### Database Connection Issues
```bash
# Check database logs
docker-compose logs postgres

# Verify database is ready
docker-compose exec postgres pg_isready -U postgres -d f1db

# Reset database
docker-compose down -v
docker-compose up -d
```

#### Build Issues
```bash
# Clean rebuild
docker-compose down --rmi all --volumes --remove-orphans
docker-compose build --no-cache
docker-compose up -d
```

#### Memory Issues
```bash
# Check Docker resources
docker system df
docker system prune -f

# Monitor container memory
docker stats --no-stream
```

### Performance Optimization

#### Production Deployment
- Use Docker Swarm or Kubernetes for orchestration
- Implement container health checks
- Set up monitoring (Prometheus + Grafana)
- Configure log aggregation (ELK stack)

#### Database Optimization
- Tune PostgreSQL configuration
- Set up read replicas for scaling
- Implement connection pooling
- Regular maintenance (VACUUM, ANALYZE)

## 📊 Features

### User Roles & Capabilities

#### Administrator
- View all dashboard data
- Insert new drivers and constructors
- Access all reports
- Manage system data

#### Constructor (Escuderia)
- View constructor-specific dashboards
- Upload driver files (CSV format)
- Search drivers by surname
- Access constructor reports

#### Driver (Piloto)
- View personal statistics
- Access driver-specific reports
- View performance data

### File Upload System
- **Format**: CSV only
- **Columns**: `driverref,code,forename,surname,dob,nationality,number,url`
- **Method**: PostgreSQL COPY streaming for performance
- **Features**: Duplicate detection, detailed processing feedback

### Reporting System
- Dynamic report generation based on user role
- PostgreSQL functions for data processing
- Interactive data tables with pagination
- Export capabilities

## 🔒 Security

### Production Considerations
- Change default passwords
- Use environment variables for secrets
- Implement SSL/TLS (add reverse proxy)
- Set up proper firewall rules
- Regular security updates

### Docker Security
- Run containers as non-root users
- Use specific image tags (not `latest`)
- Scan images for vulnerabilities
- Limit container resources

## 📝 License

This project is for educational purposes as part of the Database Laboratory course.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Test with Docker
4. Submit pull request

---

For more information, check the individual README files in `/client`, `/server`, and `/database` directories.
