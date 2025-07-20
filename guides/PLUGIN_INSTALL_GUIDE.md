# 🔌 Guía de Instalación de Plugins Jenkins

## 📋 Plugins Esenciales para ESMax DevOps

### 🚀 Cómo Instalar Plugins

1. **Acceder a Jenkins**: http://localhost:8080
2. **Login**: admin / admin123
3. **Ir a Plugin Manager**: Manage Jenkins → Plugin Manager
4. **Seleccionar Tab**: "Available plugins"
5. **Buscar e instalar** los plugins de la lista de abajo

### 🎯 Lista de Plugins Prioritarios

#### Core Pipeline (CRÍTICO)
- [ ] **Pipeline** - Soporte básico para pipelines
- [ ] **Pipeline: Stage View** - Vista de etapas del pipeline
- [ ] **Pipeline: Utility Steps** - Pasos adicionales para pipelines
- [ ] **Build Timeout** - Timeouts para builds
- [ ] **Timestamper** - Timestamps en logs
- [ ] **Workspace Cleanup** - Limpieza de workspace

#### Git y SCM (CRÍTICO)
- [ ] **Git** - Integración con Git
- [ ] **GitHub** - Integración con GitHub
- [ ] **GitHub Branch Source** - Branches de GitHub

#### Docker (CRÍTICO)
- [ ] **Docker Pipeline** - Soporte Docker en pipelines
- [ ] **Docker** - Plugin principal de Docker

#### Build Tools (IMPORTANTE)
- [ ] **Gradle** - Builds de Android
- [ ] **Maven Integration** - Builds Java/Maven
- [ ] **NodeJS** - Builds Node.js/React Native

#### Seguridad (IMPORTANTE)
- [ ] **Role-based Authorization Strategy** - Roles y permisos
- [ ] **Matrix Authorization Strategy** - Permisos matriciales
- [ ] **Credentials** - Gestión de credenciales
- [ ] **SSH Credentials** - Credenciales SSH

#### Reporting (ÚTIL)
- [ ] **JUnit** - Reportes de tests
- [ ] **HTML Publisher** - Reportes HTML

#### Extras (OPCIONAL)
- [ ] **Blue Ocean** - Interfaz moderna (consume recursos)
- [ ] **Copy Artifact** - Copiar artefactos entre jobs
- [ ] **Rebuild** - Reconstruir builds fácilmente

### 🛠️ Instalación Automática (RECOMENDADO)

**Los plugins se instalan automáticamente** durante la construcción de la imagen Docker.

**Archivo de configuración**: `config/plugins.txt`

**Para actualizar plugins**:
1. Editar `config/plugins.txt`
2. Reconstruir la imagen: `docker-compose build --no-cache`
3. Reiniciar Jenkins: `docker-compose down && docker-compose up -d`

### 🛠️ Instalación Manual (Alternativa)

**Opción 1**: Instalar uno por uno desde la interfaz web

**Opción 2**: Usar Jenkins CLI (avanzado)
```bash
# Entrar al contenedor
docker exec -it jenkins-master bash

# Instalar plugins
jenkins-plugin-cli --plugins workflow-aggregator git github docker-workflow gradle nodejs credentials junit
```

### 📱 Configuración Específica para iOS/Android

#### Para Builds Android:
1. **Instalar Gradle Plugin**
2. **Configurar ANDROID_HOME** en Global Tool Configuration
3. **Añadir JDK** en Global Tool Configuration

#### Para Builds iOS:
1. **Configurar Mac Agent** (siguiente paso)
2. **Instalar SSH Credentials Plugin**
3. **Configurar Xcode path** en el agente Mac

### 🔧 Configuración Post-Instalación

#### 1. Configurar Herramientas Globales
- **Manage Jenkins** → **Global Tool Configuration**
- **Añadir NodeJS 18+**
- **Añadir JDK 17+**
- **Configurar Git**

#### 2. Configurar Credenciales
- **Manage Jenkins** → **Credentials**
- **Añadir GitHub Token**
- **Añadir SSH Key para Mac Agent**
- **Añadir Android Keystore**

#### 3. Configurar Agentes
- **Manage Jenkins** → **Manage Nodes**
- **Añadir Mac Agent** para builds iOS

### 🎯 Verificación

Una vez instalados los plugins, verifica que estén activos:

1. **Manage Jenkins** → **Plugin Manager** → **Installed**
2. **Buscar** los plugins de la lista
3. **Verificar** que estén marcados como "Enabled"

### 🚨 Troubleshooting

#### Si un plugin falla al instalar:
1. **Verificar dependencias** (se instalarán automáticamente)
2. **Reiniciar Jenkins**: `make restart`
3. **Verificar logs**: `make logs`

#### Si hay conflictos:
1. **Actualizar Jenkins**: Ya tienes la versión LTS más reciente
2. **Desinstalar plugins conflictivos**
3. **Reinstalar en orden correcto**

### 📚 Próximos Pasos

1. ✅ **Instalar plugins esenciales**
2. ⏳ **Configurar Mac Agent** para iOS
3. ⏳ **Crear primer pipeline**
4. ⏳ **Migrar scripts locales**

---

**💡 Tip**: Instala primero los plugins CRÍTICOS, luego reinicia Jenkins, y después instala los IMPORTANTES y ÚTILES.

**🔄 Comando útil**: `make restart` para reiniciar Jenkins después de instalar plugins. 