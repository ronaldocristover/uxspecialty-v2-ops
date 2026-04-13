# UX Specialty v2 Operations

Docker compose setup untuk production environment.

## Services

| Service | Image | Port | Description |
|---------|-------|------|-------------|
| npm | jc21/nginx-proxy-manager | 80, 443, 81 | Reverse proxy & SSL |
| mysql | mysql:8.0 | 3306 | Database |
| api | registry.digitalocean.com/so-thai/uxspecialty-v2-api | - | Backend API |
| portal | registry.digitalocean.com/so-thai/uxspecialty-v2-landing-next | - | Landing page (Next.js) |
| admin | registry.digitalocean.com/so-thai/uxspecialty-v2-vue-dashboard | - | Admin dashboard (Vue) |
| adminer | adminer:latest | 8080 | MySQL GUI |
| mysql-backup | mysql:8.0 | - | Auto backup (daily 02:00) |

## Quick Start

```bash
# Copy environment file
cp .env.template .env

# Edit .env dengan password yang sesuai
nano .env

# Deploy semua service
make deploy
```

## Commands

```bash
make pull              # Pull latest images
make up               # Start services
make deploy            # Pull + start (deploy)
make restart           # Restart all services
make restart SERVICE=api   # Restart specific service
make logs              # Show all logs
make logs SERVICE=api # Filter service logs
make status            # Show container status
make clean             # Stop & remove containers
```

## Akses

- **NPM Admin UI**: http://localhost:81
- **Adminer (MySQL)**: http://localhost:8080
  - Server: `mysql`
  - User: `root`
  - Password: (see .env)
  - Database: `uxspecialty_db`

## Backup

- Backup otomatis setiap jam 02:00
- Disimpan di volume `mysql-backups`
- Retensi: 7 hari

```bash
# Lihat backup files
docker exec uxspecialty-mysql-backup ls /backups
```

## Environment Variables

```env
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=uxspecialty_db
MYSQL_USER=uxspecialty_user
MYSQL_PASSWORD=your_password
```