#!/bin/bash

# =============================================================================
# 🧪 SCRIPT DE PRUEBA DEL PIPELINE - JENKINS DOCKER
# =============================================================================
# Este script prueba las funcionalidades del pipeline sin ejecutar Jenkins
# Útil para verificar que todas las dependencias estén correctamente instaladas

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =============================================================================
# 📋 VERIFICACIÓN INICIAL
# =============================================================================

log_info "🧪 Iniciando prueba del pipeline local"
log_info "📋 Verificando que el contenedor Jenkins esté ejecutándose..."

if ! docker ps | grep -q jenkins-master; then
    log_error "❌ Contenedor Jenkins no está ejecutándose"
    log_info "💡 Ejecuta: docker-compose up -d"
    exit 1
fi

log_success "✅ Contenedor Jenkins ejecutándose"

# =============================================================================
# 🔍 VERIFICACIÓN DE DEPENDENCIAS
# =============================================================================

log_info "🔍 Verificando dependencias en el agente Docker..."

# Verificar Node.js 20
log_info "📦 Verificando Node.js..."
NODE_VERSION=$(docker exec jenkins-master node --version 2>/dev/null || echo "NOT_FOUND")
if [[ "$NODE_VERSION" == v20* ]]; then
    log_success "✅ Node.js: $NODE_VERSION"
else
    log_error "❌ Node.js 20 no encontrado: $NODE_VERSION"
    exit 1
fi

# Verificar pnpm
log_info "📦 Verificando pnpm..."
PNPM_VERSION=$(docker exec jenkins-master pnpm --version 2>/dev/null || echo "NOT_FOUND")
if [[ "$PNPM_VERSION" != "NOT_FOUND" ]]; then
    log_success "✅ pnpm: $PNPM_VERSION"
else
    log_error "❌ pnpm no encontrado"
    exit 1
fi

# Verificar Android SDK
log_info "🤖 Verificando Android SDK..."

ANDROID_HOME=$(docker exec jenkins-master bash -c 'echo $ANDROID_HOME' 2>/dev/null)

if [[ "$ANDROID_HOME" == "/opt/android-sdk" ]]; then
    log_success "✅ Android SDK: $ANDROID_HOME"
else
    log_error "❌ Android SDK no configurado correctamente en el contenedor: $ANDROID_HOME"
    exit 1
fi

# Verificar sdkmanager
log_info "📱 Verificando sdkmanager..."
if docker exec jenkins-master which sdkmanager >/dev/null 2>&1; then
    log_success "✅ sdkmanager disponible"
else
    log_error "❌ sdkmanager no encontrado"
    exit 1
fi

# Verificar Firebase CLI
log_info "🔥 Verificando Firebase CLI..."
FIREBASE_VERSION=$(docker exec jenkins-master firebase --version 2>/dev/null || echo "NOT_FOUND")
if [[ "$FIREBASE_VERSION" != "NOT_FOUND" ]]; then
    log_success "✅ Firebase CLI: $FIREBASE_VERSION"
else
    log_warn "⚠️ Firebase CLI no encontrado (opcional)"
fi

# Verificar Docker
log_info "🐳 Verificando Docker..."
DOCKER_VERSION=$(docker exec jenkins-master docker --version 2>/dev/null || echo "NOT_FOUND")
if [[ "$DOCKER_VERSION" != "NOT_FOUND" ]]; then
    log_success "✅ Docker: $DOCKER_VERSION"
else
    log_error "❌ Docker no encontrado"
    exit 1
fi

# =============================================================================
# 🏗️ PRUEBA DE BUILD SIMULADO
# =============================================================================

log_info "🏗️ Simulando pasos del pipeline..."

# Simular checkout
log_info "🔐 Simulando checkout del repositorio..."
if docker exec jenkins-master git --version >/dev/null 2>&1; then
    log_success "✅ Git disponible para checkout"
else
    log_error "❌ Git no disponible"
    exit 1
fi

# Simular instalación de dependencias
log_info "📦 Simulando instalación de dependencias..."
if docker exec jenkins-master pnpm --version >/dev/null 2>&1; then
    log_success "✅ pnpm disponible para instalación de dependencias"
else
    log_error "❌ pnpm no disponible"
    exit 1
fi

# Simular build de Android
log_info "🤖 Simulando build de Android..."
if docker exec jenkins-master test -d /opt/android-sdk; then
    log_success "✅ Android SDK disponible para build"
else
    log_error "❌ Android SDK no disponible"
    exit 1
fi

# Verificar componentes de Android SDK
log_info "📱 Verificando componentes de Android SDK..."
SDK_COMPONENTS=$(docker exec jenkins-master sdkmanager --list_installed 2>/dev/null | grep -E "(platform-tools|build-tools|platforms)" | wc -l)
if [[ "$SDK_COMPONENTS" -gt 0 ]]; then
    log_success "✅ Componentes de Android SDK instalados: $SDK_COMPONENTS"
else
    log_warn "⚠️ Pocos componentes de Android SDK instalados"
fi

# =============================================================================
# 🔧 VERIFICACIÓN DE CONFIGURACIÓN
# =============================================================================

log_info "🔧 Verificando configuración de Jenkins..."

# Verificar que Jenkins esté respondiendo
log_info "🌐 Verificando acceso a Jenkins..."
if curl -s http://localhost:8080 >/dev/null 2>&1; then
    log_success "✅ Jenkins accesible en http://localhost:8080"
else
    log_error "❌ Jenkins no accesible"
    exit 1
fi

# Verificar configuración JCasC
log_info "📋 Verificando configuración JCasC..."
if docker exec jenkins-master test -f /var/jenkins_config/jenkins.yaml; then
    log_success "✅ Archivo de configuración JCasC encontrado"
else
    log_error "❌ Archivo de configuración JCasC no encontrado"
    exit 1
fi

# =============================================================================
# 📊 RESUMEN
# =============================================================================

echo ""
log_info "📊 RESUMEN DE LA PRUEBA DEL PIPELINE"
echo "=================================================="
log_success "✅ Todas las dependencias principales verificadas"
log_success "✅ Agente Docker configurado correctamente"
log_success "✅ Jenkins funcionando y accesible"
log_success "✅ Pipeline listo para ejecutarse"

echo ""
log_info "🎯 PRÓXIMOS PASOS:"
echo "1. Configurar credenciales de Azure DevOps en Jenkins"
echo "2. Crear job de pipeline en Jenkins"
echo "3. Ejecutar el pipeline con el proyecto smx-app-front"
echo "4. Verificar generación de artefactos APK/AAB"

echo ""
log_info "🔗 Enlaces útiles:"
echo "- Jenkins: http://localhost:8080"
echo "- Documentación: README.md"
echo "- Configuración: config/jenkins.yaml"

log_success "🎉 Prueba del pipeline completada exitosamente!" 