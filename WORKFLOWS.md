# Developer Workflows

Common workflows for working with this Supabase infrastructure.

---

## Daily Operations

### Standard Startup (No Resource Limits)

```bash
# Start Supabase without resource limits
./setup.sh

# Stop services
cd docker && docker compose down

# View logs
cd docker && docker compose logs -f

# View specific service logs
cd docker && docker compose logs -f db

# Check service status
cd docker && docker compose ps

# Restart specific service
cd docker && docker compose restart db
```

### Startup with Resource Limits (Production Simulation)

Use the benchmark helper to start with DigitalOcean plan limits:

```bash
cd docker

# Start with specific plan limits
./benchmark.sh start 4gb          # 4GB / 2 CPU ($24/mo) - Recommended
./benchmark.sh start 2gb          # 2GB / 1 CPU ($12/mo) - Minimum
./benchmark.sh start 8gb          # 8GB / 4 CPU ($48/mo) - High traffic
./benchmark.sh start unlimited    # No limits (default)

# Check resource usage
./benchmark.sh stats

# Stop services
./benchmark.sh stop
```

**Available Plans:**
- `512mb` - $4/mo (not viable)
- `1gb` - $6/mo (dev/test only)
- `2gb` - $12/mo (minimum production)
- `2gb-2cpu` - $18/mo (better performance)
- `4gb` - $24/mo (recommended) ⭐
- `8gb` - $48/mo (high traffic)
- `16gb` - $96/mo (enterprise)
- `unlimited` - No limits (development)

See [DIGITALOCEAN-BENCHMARKS.md](../DIGITALOCEAN-BENCHMARKS.md) for detailed comparison.

---

## Fresh Environment Setup

```bash
# Clean slate
./setup.sh --reset
```

**Note**: This deletes all data. Use with caution.

---

## Updating Configuration

```bash
# 1. Stop services
cd docker && docker compose down

# 2. Edit .env
vim docker/.env

# 3. Restart
./setup.sh
```

---

## Backing Up Data

### Database Backup

```bash
cd docker
PGPASSWORD=$(grep POSTGRES_PASSWORD .env | cut -d'=' -f2) \
  pg_dump -h localhost -p 54322 -U postgres -d postgres > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Volumes Backup

```bash
cd docker
tar czf volumes_backup_$(date +%Y%m%d_%H%M%S).tar.gz volumes/
```

---

## Restoring Data

### Database Restore

```bash
# Start fresh
./setup.sh --reset

# Restore from backup
cd docker
PGPASSWORD=$(grep POSTGRES_PASSWORD .env | cut -d'=' -f2) \
  psql -h localhost -p 54322 -U postgres -d postgres < backup_20251102_120000.sql
```

### Volumes Restore

```bash
cd docker && docker compose down
tar xzf volumes_backup_20251102_120000.tar.gz
./setup.sh
```

---

## Troubleshooting Services

### Check Service Status

```bash
cd docker && docker compose ps
```

### View Service Logs

```bash
cd docker && docker compose logs -f [service-name]
```

### Restart Service

```bash
cd docker && docker compose restart [service-name]
```

### Rebuild Service

```bash
cd docker && docker compose up -d --force-recreate [service-name]
```

---

## Common Issues

### Services Not Starting

```bash
# Check container status
cd docker && docker compose ps

# View error logs
cd docker && docker compose logs -f

# Full reset
./setup.sh --reset
```

### Database Connection Refused

Check if Supabase is running:
```bash
cd docker && docker compose ps
```

Check port mapping:
```bash
docker ps | grep 54322
```

Verify PostgreSQL port:
```bash
docker exec supabase-db psql -U postgres -c "SHOW port;"
```

Verify configuration:
```bash
cd docker
grep "POSTGRES_PORT=" .env          # Should be 5432
grep "POSTGRES_EXTERNAL_PORT=" .env # Should be 54322
```

If wrong, fix and restart:
```bash
./setup.sh --reset
```

### Port Already in Use

Find process using port:
```bash
sudo lsof -i :54322
sudo lsof -i :8000
```

Kill process if needed:
```bash
sudo kill -9 <PID>
```

---

## Service Architecture

### Access Points

| Service | URL/Port |
|---------|----------|
| Dashboard | http://localhost:8000 |
| API | http://localhost:8000 |
| Database | localhost:54322 |

Credentials are in `docker/.env`

### Active Containers (Optimized Setup)

**Running Services (9 containers):**

| Container | Purpose | Internal Port | External Port | Memory |
|-----------|---------|---------------|---------------|--------|
| `supabase-kong` | API gateway | 8000 | 8000 | ~942 MB |
| `supabase-pooler` | Connection pooler | - | 6543 | ~178 MB |
| `supabase-studio` | Web dashboard | 3000 | 8000 | ~145 MB |
| `supabase-storage` | File storage | 5000 | - | ~103 MB |
| `supabase-db` | PostgreSQL database | 5432 | 54322 | ~102 MB |
| `supabase-meta` | Database metadata | 8080 | - | ~78 MB |
| `supabase-imgproxy` | Image optimization | 5001 | - | ~25 MB |
| `supabase-auth` | GoTrue auth server | 9999 | - | ~23 MB |
| `supabase-rest` | PostgREST API | 3000 | - | ~13 MB |

**Total: ~1.6 GB RAM usage**

**Disabled Services** (not running, see [OPTIMIZATION.md](./OPTIMIZATION.md) to re-enable):
- `realtime` - WebSocket realtime subscriptions
- `analytics` - Logflare logging and monitoring
- `functions` - Edge functions runtime
- `vector` - Log aggregation

### Network Flow

```
Host Machine (localhost)
│
├─ Port 8000 ────────► Kong (API Gateway)
│                       └─► Routes to: Auth, REST, Storage, Studio
│
├─ Port 54322 ──────► PostgreSQL (supabase-db:5432)
│
Docker Network (172.x.x.x)
└─ All services connect internally using service names
   (e.g., db:5432, auth:9999, rest:3000)
```

### Key Configuration

- `POSTGRES_PORT=5432` - Internal Docker network port (do not change)
- `POSTGRES_EXTERNAL_PORT=54322` - Host machine access port (customizable)

---

## Pro Tips

1. **Always use `./setup.sh`** instead of manually running `docker compose up`
2. **Never commit `docker/.env`** - contains secrets
3. **Use `--reset` flag liberally** during development - fresh start fixes most issues
4. **Check logs first** when troubleshooting: `cd docker && docker compose logs -f`
5. **Database port is 54322 externally, 5432 internally** - this is intentional
6. **Keep `setup.sh` idempotent** - should be safe to run multiple times
