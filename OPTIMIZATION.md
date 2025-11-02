# Supabase Optimization Branch

This branch contains an optimized Supabase configuration that disables unused services to reduce resource consumption and improve performance.

## Disabled Services

The following services have been disabled in this optimization:

### Docker Services (docker-compose.yml)
- **realtime** - WebSocket realtime subscriptions
- **analytics** - Logflare analytics and logging
- **functions** - Edge Functions runtime
- **vector** - Log collection service

### API Routes (kong.yml)
- **GraphQL** - `/graphql/v1/*` endpoint
- **Realtime** - `/realtime/v1/*` endpoints
- **Functions** - `/functions/v1/*` endpoint
- **Analytics** - `/analytics/v1/*` endpoint

## Active Services

The following core services remain active:

- **db** - PostgreSQL database
- **rest** - PostgREST API (REST endpoints)
- **auth** - GoTrue authentication
- **storage** - Storage API with image transformation
- **imgproxy** - Image transformation
- **kong** - API gateway
- **studio** - Supabase Studio dashboard
- **meta** - Postgres metadata API
- **supavisor** - Connection pooler

## How to Re-enable Services

All disabled services are commented out with clear markers. To re-enable any service:

### Re-enabling Docker Services

1. Open `docker/docker-compose.yml`
2. Find the service marked with `# OPTIMIZATION:` comment
3. Uncomment the entire service block
4. Find dependencies on that service in other services (also marked with `# OPTIMIZATION:`)
5. Uncomment those dependencies
6. Restart the stack: `docker compose down && docker compose up -d`

**Example - Re-enabling Realtime:**

```yaml
# Find and uncomment in docker-compose.yml:
realtime:
  container_name: realtime-dev.supabase-realtime
  image: supabase/realtime:v2.34.47
  # ... rest of config

# Also uncomment in other services that depend on it:
depends_on:
  analytics:  # If re-enabling analytics too
    condition: service_healthy
```

### Re-enabling Analytics

Analytics requires multiple changes:

1. **docker-compose.yml** - Uncomment:
   - `analytics` service
   - `vector` service
   - All `depends_on: analytics` sections in other services
   - Analytics environment variables in `studio` service

2. **Restart services:**
   ```bash
   docker compose down
   docker compose up -d
   ```

### Re-enabling API Routes

1. Open `docker/volumes/api/kong.yml`
2. Find the route marked with `# OPTIMIZATION:` comment
3. Uncomment the route configuration
4. Restart Kong: `docker compose restart kong`

**Example - Re-enabling GraphQL:**

```yaml
# Uncomment in kong.yml:
- name: graphql-v1
  _comment: 'PostgREST: /graphql/v1/* -> http://rest:3000/rpc/graphql'
  url: http://rest:3000/rpc/graphql
  routes:
    - name: graphql-v1-all
      strip_path: true
      paths:
        - /graphql/v1
  plugins:
    # ... rest of config
```

### Re-enabling Edge Functions

1. **docker-compose.yml** - Uncomment the `functions` service
2. **kong.yml** - Uncomment the `functions-v1` route
3. Restart: `docker compose down && docker compose up -d`

## Quick Reference

| Service/Route | File | Line Markers |
|--------------|------|--------------|
| Realtime Service | docker/docker-compose.yml | `# OPTIMIZATION: Realtime disabled` |
| Analytics Service | docker/docker-compose.yml | `# OPTIMIZATION: Analytics/Logflare disabled` |
| Vector Service | docker/docker-compose.yml | `# OPTIMIZATION: Vector logging disabled` |
| Functions Service | docker/docker-compose.yml | `# OPTIMIZATION: Edge Functions disabled` |
| GraphQL Route | docker/volumes/api/kong.yml | `# OPTIMIZATION: GraphQL routes disabled` |
| Realtime Routes | docker/volumes/api/kong.yml | `# OPTIMIZATION: Realtime routes disabled` |
| Functions Route | docker/volumes/api/kong.yml | `# OPTIMIZATION: Edge Functions routes disabled` |
| Analytics Route | docker/volumes/api/kong.yml | `# OPTIMIZATION: Analytics routes disabled` |

## Resource Savings

**Measured Resource Usage (Optimized Stack):**

- **Total Memory**: ~1.61 GB (1,613 MiB)
- **Total CPU**: ~11.5% (idle)
- **Containers**: 9 running

**Disabled Services (Not Consuming Resources):**
- realtime
- analytics (logflare)
- edge-functions
- vector

**Estimated Savings**: 450-700 MB compared to full stack

**Individual Container Usage:**

| Container | Memory | CPU % |
|-----------|--------|-------|
| kong | 941.8 MiB | 0.20% |
| pooler | 178.3 MiB | 0.91% |
| studio | 144.8 MiB | 0.00% |
| storage | 102.7 MiB | 4.75% |
| db | 102.4 MiB | 0.04% |
| meta | 77.9 MiB | 0.62% |
| imgproxy | 25.2 MiB | 0.00% |
| auth | 23.0 MiB | 0.00% |
| rest | 13.2 MiB | 0.09% |

## Use Cases

This optimized configuration is ideal for:

- Development environments focused on API and Storage only
- Production deployments that don't require realtime features
- Resource-constrained environments
- Projects using external analytics/logging solutions
- Serverless architectures with external function hosting

## Testing After Re-enabling

After re-enabling services, verify they work:

```bash
# Check all services are healthy
docker compose ps

# Test specific endpoints (replace with your URL and keys)
# Realtime
curl -X GET 'http://localhost:8000/realtime/v1/api/tenants'

# GraphQL
curl -X POST 'http://localhost:8000/graphql/v1' \
  -H 'apikey: YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"query": "{ __typename }"}'

# Functions (if you have functions deployed)
curl -X POST 'http://localhost:8000/functions/v1/YOUR_FUNCTION' \
  -H 'apikey: YOUR_ANON_KEY'
```

## Notes

- All optimization comments are prefixed with `# OPTIMIZATION:` for easy searching
- Service dependencies have also been updated (marked with comments)
- The backup of the original kong.yml is saved as `kong.yml.bak` in `docker/volumes/api/`
- No data is lost - re-enabling services will restore full functionality
