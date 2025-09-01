#!/bin/bash

# IA-Ops MinIO Management Script
# Uso: ./scripts/manage.sh [start|stop|restart|status|logs]

COMPOSE_FILE="docker-compose.integrated.yml"

case "$1" in
    start)
        echo "🚀 Iniciando servicios IA-Ops MinIO..."
        docker compose -f $COMPOSE_FILE up -d
        echo "✅ Servicios iniciados"
        echo "📊 Dashboard: http://localhost:6540"
        ;;
    
    stop)
        echo "🛑 Deteniendo servicios IA-Ops MinIO..."
        docker compose -f $COMPOSE_FILE down
        echo "✅ Servicios detenidos"
        ;;
    
    restart)
        echo "🔄 Reiniciando servicios IA-Ops MinIO..."
        docker compose -f $COMPOSE_FILE restart
        echo "✅ Servicios reiniciados"
        echo "📊 Dashboard: http://localhost:6540"
        ;;
    
    status)
        echo "📊 Estado de servicios IA-Ops MinIO:"
        docker compose -f $COMPOSE_FILE ps
        ;;
    
    logs)
        echo "📋 Logs de servicios (Ctrl+C para salir):"
        docker compose -f $COMPOSE_FILE logs -f
        ;;
    
    *)
        echo "Uso: $0 {start|stop|restart|status|logs}"
        echo ""
        echo "Comandos disponibles:"
        echo "  start   - Iniciar todos los servicios"
        echo "  stop    - Detener todos los servicios"
        echo "  restart - Reiniciar todos los servicios"
        echo "  status  - Ver estado de los servicios"
        echo "  logs    - Ver logs en tiempo real"
        echo ""
        echo "Ejemplo: ./scripts/manage.sh start"
        exit 1
        ;;
esac
