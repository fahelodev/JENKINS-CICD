#!/bin/bash

# Script de respaldo para Jenkins Dockerizado
# Autor: DevOps Team
# Fecha: $(date +%Y-%m-%d)

set -e

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

# Configuración
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="jenkins_backup_${TIMESTAMP}.tar.gz"

# Crear directorio de respaldos si no existe
mkdir -p "$BACKUP_DIR"

log_info "🔄 Iniciando respaldo de Jenkins..."

# Verificar que Jenkins esté ejecutándose
if ! docker-compose ps | grep -q "Up"; then
    log_warn "Jenkins no está ejecutándose. Continuando con el respaldo del volumen..."
fi

# Crear respaldo del volumen de Jenkins
log_info "📦 Creando respaldo del volumen jenkins_home..."
docker run --rm \
    -v jenkins_cicd_jenkins_home:/jenkins_data \
    -v "$(pwd)/$BACKUP_DIR:/backup" \
    alpine tar czf "/backup/$BACKUP_NAME" -C /jenkins_data .

if [ $? -eq 0 ]; then
    log_info "✅ Respaldo creado exitosamente: $BACKUP_NAME"
    
    # Mostrar información del archivo
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_NAME" | cut -f1)
    log_info "📊 Tamaño del respaldo: $BACKUP_SIZE"
    
    # Limpiar respaldos antiguos (mantener solo los últimos 10)
    log_info "🧹 Limpiando respaldos antiguos..."
    cd "$BACKUP_DIR"
    ls -t jenkins_backup_*.tar.gz | tail -n +11 | xargs -r rm -f
    cd ..
    
    log_info "🎉 Proceso de respaldo completado!"
else
    log_error "❌ Error al crear el respaldo"
    exit 1
fi

# Función para restaurar (comentada por seguridad)
log_info "📋 Para restaurar un respaldo, usa:"
echo "  docker run --rm \\"
echo "    -v jenkins_cicd_jenkins_home:/jenkins_data \\"
echo "    -v \$(pwd)/backups:/backup \\"
echo "    alpine tar xzf /backup/NOMBRE_DEL_ARCHIVO.tar.gz -C /jenkins_data" 