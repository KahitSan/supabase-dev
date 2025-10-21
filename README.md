# Supabase Development Environment

A complete, production-ready Supabase development environment with Docker Compose, featuring dashboard authentication and custom configurations for team development.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/KahitSan/supabase-dev.git
cd supabase-dev

# Navigate to Docker environment
cd docker/

# Run the setup script
./setup.sh
```

**That's it!** Your Supabase environment will be running with:

- **Dashboard**: http://localhost:8000 (login: `kahitsan`)
- **Studio**: http://localhost:54323 (direct access)
- **Database**: `postgresql://postgres:***@localhost:54322/postgres`
- **API**: http://localhost:8000/rest/v1/

## 🌟 Features

- **🔐 Secure Dashboard** - Authentication required for admin access
- **📊 Complete Stack** - Database, API, Auth, Storage, Analytics
- **🛠️ Developer Tools** - 15+ utility commands for daily development
- **📱 GitHub OAuth** - Pre-configured for social authentication
- **📧 Email Testing** - Built-in email development server
- **🗃️ File Storage** - Local file storage with custom buckets
- **📈 Analytics** - Built-in logging and monitoring

## 📚 Documentation

Full documentation is available in the [`docker/README.md`](./docker/README.md) file, including:

- Complete setup instructions
- Development commands reference
- Troubleshooting guide
- Team development practices
- Configuration options

## 🔧 Quick Commands

```bash
cd docker/

# View service status
./dev-utils.sh status

# View logs
./dev-utils.sh logs

# Connect to database
./dev-utils.sh psql

# Create backup
./dev-utils.sh backup

# Reset environment
./reset.sh
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `./setup.sh`
5. Submit a pull request

## 📋 Requirements

- Docker Desktop
- Git
- 8GB+ RAM recommended

## 🆘 Support

- Check the [documentation](./docker/README.md)
- Review [troubleshooting guide](./docker/README.md#-troubleshooting)
- Open an issue for bugs or questions

---

**Built with ❤️ for the KahitSan development team**