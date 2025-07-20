#!/bin/bash

# Script de configuración inicial para Jenkins Dockerizado
# Autor: DevOps Team
# Fecha: $(date +%Y-%m-%d)

set -e

echo "🚀 Iniciando configuración de Jenkins Dockerizado..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    log_error "Docker no está instalado. Por favor instala Docker primero."
    exit 1
fi

# Verificar que Docker Compose esté instalado
if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose no está instalado. Por favor instala Docker Compose primero."
    exit 1
fi

log_info "Docker y Docker Compose verificados correctamente."

# Crear directorios necesarios
log_info "Creando estructura de directorios..."
mkdir -p jenkins_home
mkdir -p secrets
mkdir -p logs

# Verificar si existe archivo .env
if [ ! -f .env ]; then
    log_warn "Archivo .env no encontrado. Creando desde .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        log_info "Archivo .env creado. Por favor revisa y configura las variables de entorno."
    else
        log_warn "Archivo .env.example no encontrado. Creando .env básico..."
        cat > .env << EOF
# Configuración de Jenkins
JENKINS_ADMIN_PASSWORD=admin123
JENKINS_URL=http://localhost:8080

# Configuración de Docker
DOCKER_HOST=unix:///var/run/docker.sock
EOF
    fi
fi

# Construir imagen de Jenkins
log_info "Construyendo imagen de Jenkins..."
docker-compose build

# Iniciar servicios
log_info "Iniciando servicios de Jenkins..."
docker-compose up -d

# Esperar a que Jenkins esté listo
log_info "Esperando a que Jenkins esté listo..."
sleep 30

# Verificar estado del contenedor
if docker-compose ps | grep -q "Up"; then
    log_info "✅ Jenkins está ejecutándose correctamente!"
    log_info "🌐 Accede a Jenkins en: http://localhost:8080"
    log_info "👤 Usuario: admin"
    log_info "🔑 Contraseña: admin123 (cambia esto en producción)"
else
    log_error "❌ Error al iniciar Jenkins. Revisa los logs con: docker-compose logs"
    exit 1
fi

# Mostrar logs iniciales
log_info "Mostrando logs iniciales..."
docker-compose logs --tail=20

# Verificar herramientas instaladas
log_info "🔍 Verificando herramientas instaladas..."
if docker exec jenkins-master /var/jenkins_config/verify-tools.sh; then
    log_success "✅ Todas las herramientas verificadas correctamente"
else
    log_warn "⚠️ Algunas herramientas pueden no estar disponibles"
fi

echo ""
log_info "🎉 Configuración completada exitosamente!"
log_info "📋 Comandos útiles:"
echo "  - Ver logs: docker-compose logs -f"
echo "  - Detener: docker-compose down"
echo "  - Reiniciar: docker-compose restart"
echo "  - Backup: ./scripts/backup.sh"
echo "  - Verificar herramientas: docker exec jenkins-master /var/jenkins_config/verify-tools.sh" 