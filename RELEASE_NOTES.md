# 🎉 IA-Ops MinIO v1.0.0 - Complete Storage Solution

## 🚀 What's New

### ✨ Complete Integrated Solution
- **Portal Unificado**: Dashboard web con navegación completa
- **Documentación Dual**: MkDocs + API Docs integrada
- **S3 Compatible**: API completamente compatible con Amazon S3
- **REST API**: Endpoints personalizados para gestión
- **Docker Ready**: Un solo contenedor para todo

### 🌐 Access URLs
| Service | URL | Description |
|---------|-----|-------------|
| 🏠 **Dashboard** | http://localhost:6540 | Main portal |
| 🖥️ **MinIO Console** | http://localhost:9899 | Web administration |
| 📚 **Documentation** | http://localhost:6541 | Complete MkDocs site |
| 🔌 **API Docs** | http://localhost:6540/api-docs | Integrated API documentation |
| 🚀 **REST API** | http://localhost:8848 | Custom API endpoints |
| 📡 **MinIO API** | http://localhost:9898 | S3 compatible API |

### 📚 Complete Documentation (12+ Pages)
- **🚀 Getting Started**: Installation, Configuration, First Use
- **🗄️ MinIO**: Architecture, Buckets, Access Policies
- **🔌 API REST**: Introduction, Endpoints, Examples
- **🚀 Deployment**: Docker, Production, Monitoring
- **🛠️ Scripts**: Commands, Automation
- **📖 Reference**: Environment Variables, Troubleshooting

### 🛠️ Management Scripts
```bash
# Daily management
./scripts/manage.sh start|stop|restart|status|logs

# Complete deployment
./scripts/deploy-clean.sh

# System verification
./scripts/verify-system.sh
```

### 🔧 Pre-configured Buckets
- `techdocs-storage` - Main documentation (public)
- `repositories-backup` - Repository backups (private)
- `build-artifacts` - Build artifacts (private)
- `static-assets` - Static resources (public)

## 🚀 Quick Start

```bash
# 1. Clone repository
git clone git@github.com:giovanemere/ia-ops-minio.git
cd ia-ops-minio

# 2. Deploy (one command)
./scripts/deploy-clean.sh

# 3. Access dashboard
open http://localhost:6540
```

## 🔐 Default Credentials
- **User**: `minioadmin`
- **Password**: `minioadmin123`

⚠️ **Important**: Change credentials in production!

## 🐳 Docker Image
- **Image**: `edissonz8809/ia-ops-minio-integrated:latest`
- **Size**: Optimized for production
- **Services**: All integrated in single container

## 📊 What's Included
- ✅ MinIO Server (S3 compatible storage)
- ✅ MinIO Console (Web administration)
- ✅ REST API (Custom endpoints)
- ✅ Web Dashboard (Unified portal)
- ✅ MkDocs Documentation (Complete guides)
- ✅ API Documentation (Integrated)
- ✅ Health Checks (Monitoring)
- ✅ Auto Setup (Buckets & policies)

## 🔗 Integration Ready
Perfect for integration with:
- **ia-ops-docs** - Main documentation
- **ia-ops-backstage** - Backstage portal
- **ia-ops-framework** - Base framework
- **CI/CD Pipelines** - Automated deployments
- **Monitoring Systems** - Prometheus, Grafana

## 📈 Production Ready
- SSL/TLS support
- Environment variables
- Health checks
- Logging & monitoring
- Backup scripts
- Security policies

---

**🚀 Part of the IA-Ops Ecosystem**

For complete documentation, visit: http://localhost:6541 after deployment
