#!/bin/bash

# Supabase Development Environment Setup Script
# This script helps developers get the Supabase environment running quickly

set -e  # Exit on any error

echo "🚀 Setting up Supabase development environment..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found. Creating from example..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "📄 Created .env file from .env.example"
        echo "⚠️  Please edit .env file and set your preferred credentials before continuing"
        exit 1
    else
        echo "❌ No .env.example file found. Please create .env manually."
        exit 1
    fi
fi

# Source environment variables
source .env

# Verify required environment variables
required_vars=(
    "POSTGRES_PASSWORD"
    "JWT_SECRET" 
    "DASHBOARD_USERNAME"
    "DASHBOARD_PASSWORD"
    "ANON_KEY"
    "SERVICE_ROLE_KEY"
)

echo "🔍 Checking required environment variables..."
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Required environment variable $var is not set in .env"
        exit 1
    fi
done
echo "✅ All required environment variables are set"

# Pull latest images
echo "📥 Pulling latest Docker images..."
docker compose pull

# Stop any existing containers
echo "🛑 Stopping any existing containers..."
docker compose down

# Start services
echo "🏗️  Starting Supabase services..."
docker compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to start..."
sleep 10

# Check service health
echo "🏥 Checking service health..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if docker compose ps | grep -q "healthy"; then
        echo "✅ Services are starting up..."
        break
    fi
    
    attempt=$((attempt + 1))
    echo "   Attempt $attempt/$max_attempts - waiting for services..."
    sleep 2
done

echo ""
echo "🎉 Supabase development environment is ready!"
echo ""
echo "📊 Dashboard:     http://localhost:8000 (login: $DASHBOARD_USERNAME)"
echo "🗃️  Studio:        http://localhost:54323"
echo "🔐 Database:      postgresql://postgres:***@localhost:54322/postgres"
echo "📧 Inbucket:      http://localhost:54324"
echo "📈 Analytics:     http://localhost:4000"
echo ""
echo "🔧 Useful commands:"
echo "   View logs:        docker compose logs -f"
echo "   Stop services:    docker compose down"
echo "   Reset database:   ./reset.sh"
echo "   View status:      docker compose ps"
echo ""