#!/bin/bash

# Script de verificación de herramientas para Jenkins Dockerizado
# Verifica que todas las dependencias del proyecto local-cicd estén disponibles

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo ""
echo -e "${BLUE}=================================================="
echo "🔍 VERIFICACIÓN DE HERRAMIENTAS - JENKINS DOCKER"
echo "=================================================="
echo "📋 Verificando dependencias para proyecto local-cicd"
echo -e "==================================================${NC}"
echo ""

# Contador de herramientas verificadas
total_tools=0
verified_tools=0

# Función para verificar herramienta
check_tool() {
    local tool_name="$1"
    local command="$2"
    local version_flag="${3:---version}"
    
    ((total_tools++))
    
    if command -v "$command" &> /dev/null; then
        local version=$($command $version_flag 2>&1 | head -n 1)
        log_success "✅ $tool_name: $version"
        ((verified_tools++))
        return 0
    else
        log_error "❌ $tool_name: No encontrado"
        return 1
    fi
}

# Función para verificar variable de entorno
check_env_var() {
    local var_name="$1"
    local expected_value="$2"
    
    ((total_tools++))
    
    if [[ -n "${!var_name}" ]]; then
        if [[ "${!var_name}" == "$expected_value" ]]; then
            log_success "✅ $var_name: ${!var_name}"
        else
            log_success "✅ $var_name: ${!var_name} (configurado)"
        fi
        ((verified_tools++))
        return 0
    else
        log_error "❌ $var_name: No configurado"
        return 1
    fi
}

# Función para verificar directorio
check_directory() {
    local dir_name="$1"
    local dir_path="$2"
    
    ((total_tools++))
    
    if [[ -d "$dir_path" ]]; then
        log_success "✅ $dir_name: $dir_path"
        ((verified_tools++))
        return 0
    else
        log_error "❌ $dir_name: $dir_path (no existe)"
        return 1
    fi
}

# =============================================================================
# 🔧 HERRAMIENTAS BÁSICAS
# =============================================================================

log_info "🔧 Verificando herramientas básicas..."

check_tool "Git" "git"
check_tool "Curl" "curl"
check_tool "Wget" "wget"
check_tool "Unzip" "unzip"
check_tool "Python3" "python3"
check_tool "Ruby" "ruby"

# =============================================================================
# 🐳 DOCKER
# =============================================================================

log_info "🐳 Verificando Docker..."

check_tool "Docker CLI" "docker"
check_tool "Docker Compose" "docker-compose"

# =============================================================================
# 📦 NODE.JS Y PNPM
# =============================================================================

log_info "📦 Verificando Node.js y pnpm..."

check_tool "Node.js" "node"
check_tool "npm" "npm"
check_tool "pnpm" "pnpm"

# Verificar versión específica de Node.js
if command -v node &> /dev/null; then
    local node_version=$(node --version)
    if [[ "$node_version" == v20* ]]; then
        log_success "✅ Node.js versión correcta: $node_version"
    else
        log_warn "⚠️ Node.js versión: $node_version (recomendado: v20.x)"
    fi
fi

# =============================================================================
# 🤖 ANDROID SDK
# =============================================================================

log_info "🤖 Verificando Android SDK..."

check_env_var "ANDROID_HOME" "/opt/android-sdk"
check_env_var "ANDROID_SDK_ROOT" "/opt/android-sdk"

if [[ -n "$ANDROID_HOME" ]]; then
    check_directory "Android SDK" "$ANDROID_HOME"
    check_tool "sdkmanager" "sdkmanager"
    check_tool "adb" "adb"
    check_tool "aapt2" "aapt2"
fi

# =============================================================================
# 🍎 HERRAMIENTAS iOS (EXCLUIDAS EN FASE 1)
# =============================================================================

log_info "🍎 Verificando herramientas iOS..."

log_warn "⚠️ Herramientas iOS excluidas en Fase 1 (Solo Android)"
log_info "   - CocoaPods: Se instalará en fases posteriores"
log_info "   - Xcode CLI: Se instalará en fases posteriores"

# =============================================================================
# 🔥 FIREBASE
# =============================================================================

log_info "🔥 Verificando Firebase..."

check_tool "Firebase CLI" "firebase"

# =============================================================================
# 📦 HERRAMIENTAS DE COMPRESIÓN
# =============================================================================

log_info "📦 Verificando herramientas de compresión..."

check_tool "Pigz" "pigz"

# =============================================================================
# 🛠️ HERRAMIENTAS ADICIONALES
# =============================================================================

log_info "🛠️ Verificando herramientas adicionales..."

check_tool "Bundletool" "bundletool"
check_tool "Java" "java"

# Verificar versión de Java
if command -v java &> /dev/null; then
    local java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [[ "$java_version" -ge 17 ]]; then
        log_success "✅ Java versión correcta: JDK $java_version"
    else
        log_warn "⚠️ Java versión: JDK $java_version (recomendado: JDK 17+)"
    fi
fi

# =============================================================================
# 📁 DIRECTORIOS Y CONFIGURACIÓN
# =============================================================================

log_info "📁 Verificando directorios y configuración..."

check_directory "Jenkins Home" "/var/jenkins_home"
check_directory "Jenkins Config" "/var/jenkins_config"
check_directory "Android SDK" "/opt/android-sdk"
check_directory "pnpm Store" "/var/jenkins_home/.pnpm-store"

# Verificar permisos de Docker socket
if [[ -S /var/run/docker.sock ]]; then
    log_success "✅ Docker socket: /var/run/docker.sock"
    ((verified_tools++))
else
    log_error "❌ Docker socket: No encontrado"
fi

# =============================================================================
# 🌍 VARIABLES DE ENTORNO
# =============================================================================

log_info "🌍 Verificando variables de entorno..."

check_env_var "JENKINS_OPTS" "--httpPort=8080"
check_env_var "JAVA_OPTS" "-Djenkins.install.runSetupWizard=false"
check_env_var "GRADLE_USER_HOME" "/var/jenkins_home/.gradle"
check_env_var "PNPM_HOME" "/var/jenkins_home/.pnpm-store"

# =============================================================================
# 📊 RESUMEN
# =============================================================================

echo ""
echo -e "${BLUE}=================================================="
echo "📊 RESUMEN DE VERIFICACIÓN"
echo "=================================================="
echo -e "✅ Herramientas verificadas: $verified_tools/$total_tools${NC}"

if [[ $verified_tools -eq $total_tools ]]; then
    echo ""
    log_success "🎉 ¡Todas las herramientas están instaladas correctamente!"
    log_success "🚀 Jenkins está listo para ejecutar pipelines local-cicd"
    echo ""
    log_info "📋 Próximos pasos:"
    echo "   1. Acceder a Jenkins: http://localhost:8080"
    echo "   2. Configurar credenciales para certificados"
    echo "   3. Crear pipeline job para proyecto local-cicd"
    echo "   4. Configurar triggers automáticos"
    exit 0
else
    echo ""
    log_error "❌ Faltan $((total_tools - verified_tools)) herramientas"
    log_error "🔧 Revisar la instalación de las herramientas faltantes"
    echo ""
    log_info "💡 Soluciones comunes:"
    echo "   - Reconstruir la imagen: docker-compose build --no-cache"
    echo "   - Verificar Dockerfile y dependencias"
    echo "   - Revisar logs de construcción"
    exit 1
fi 