# Jenkins Dockerizado - Fase 1: Solo Android

Este proyecto proporciona un ambiente completo de Jenkins dockerizado con configuración como código (Configuration as Code) y soporte para Docker-in-Docker, **optimizado para builds de Android**.

## 🚀 Características

- **Jenkins LTS**: Versión estable y soportada
- **Docker-in-Docker**: Capacidad de ejecutar contenedores desde Jenkins
- **Configuration as Code**: Configuración automatizada con JCasC
- **Volumen persistente**: Datos preservados entre reinicios
- **Scripts de automatización**: Setup y backup automáticos
- **Seguridad configurada**: Usuario administrador y permisos básicos
- **🤖 Android Build Tools**: SDK completo, Gradle, bundletool
- **📦 Node.js + pnpm**: Para React Native y dependencias
- **🔥 Firebase CLI**: Para distribución de artefactos
- **📦 Compresión optimizada**: Pigz para cache rápido

## 📁 Estructura del Proyecto

```
JENKINS CICD/
├── docker-compose.yml          # Orquestación de servicios
├── Dockerfile                  # Imagen personalizada de Jenkins
├── jenkins_home/              # Volumen persistente para datos
├── scripts/
│   ├── setup.sh               # Script de configuración inicial
│   └── backup.sh              # Script de respaldo
├── config/
│   └── jenkins.yaml           # Configuración como código (JCasC)
├── secrets/                   # Secretos y credenciales
├── backups/                   # Respaldos automáticos
├── logs/                      # Logs del sistema
├── env.example                # Variables de entorno de ejemplo
└── README.md                  # Esta documentación
```

## 🛠️ Requisitos Previos

- Docker Engine 20.10+
- Docker Compose 2.0+
- Al menos 6GB de RAM disponible (para builds Android)
- 15GB de espacio en disco (incluyendo Android SDK)

## ⚡ Inicio Rápido

### 1. Clonar o descargar el proyecto
```bash
cd /Users/arayaeduardo/Documents/esmax_devops/JENKINS CICD
```

### 2. Configurar variables de entorno
```bash
cp env.example .env
# Editar .env con tus configuraciones
```

### 3. Ejecutar el script de setup
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 4. Acceder a Jenkins
- **URL**: http://localhost:8080
- **Usuario**: admin
- **Contraseña**: admin123 (cambiar en producción)

## 🔧 Configuración Detallada

### Variables de Entorno (.env)

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `JENKINS_ADMIN_PASSWORD` | Contraseña del administrador | admin123 |
| `JENKINS_URL` | URL de Jenkins | http://localhost:8080 |
| `JAVA_OPTS` | Opciones de Java | -Xmx2g -Xms1g |
| `DOCKER_HOST` | Host de Docker | unix:///var/run/docker.sock |

### Configuración como Código (JCasC)

El archivo `config/jenkins.yaml` contiene toda la configuración de Jenkins:

- **Seguridad**: Usuario administrador y permisos
- **Herramientas**: Git, Docker, Node.js, Gradle y Android SDK configurados
- **Agentes**: Nodo Docker configurado
- **Propiedades globales**: Variables de entorno optimizadas para Android

## 📋 Comandos Útiles

### Gestión de Servicios
```bash
# Iniciar servicios
docker-compose up -d

# Detener servicios
docker-compose down

# Reiniciar servicios
docker-compose restart

# Ver logs
docker-compose logs -f

# Ver estado
docker-compose ps
```

### Respaldo y Restauración
```bash
# Crear respaldo
./scripts/backup.sh

# Restaurar respaldo (ejemplo)
docker run --rm \
  -v jenkins_cicd_jenkins_home:/jenkins_data \
  -v $(pwd)/backups:/backup \
  alpine tar xzf /backup/jenkins_backup_20241201_120000.tar.gz -C /jenkins_data
```

### Mantenimiento
```bash
# Limpiar contenedores no utilizados
docker system prune -f

# Ver uso de recursos
docker stats

# Actualizar imagen de Jenkins
docker-compose pull
docker-compose up -d
```

## 🔒 Seguridad

### Configuración Actual
- ✅ Usuario administrador configurado
- ✅ Registro de usuarios deshabilitado
- ✅ Permisos básicos configurados
- ✅ Docker socket con acceso restringido
- ✅ Android SDK con licencias aceptadas

### Recomendaciones para Producción
1. **Cambiar contraseña por defecto**
2. **Configurar HTTPS/TLS**
3. **Implementar autenticación externa (LDAP, OAuth)**
4. **Configurar firewall**
5. **Habilitar auditoría de logs**
6. **Implementar backup automático**
7. **Configurar credenciales de Android keystore**

## 🐛 Solución de Problemas

### Jenkins no inicia
```bash
# Verificar logs
docker-compose logs jenkins

# Verificar recursos del sistema
docker stats

# Reiniciar completamente
docker-compose down
docker-compose up -d
```

### Problemas con Docker-in-Docker
```bash
# Verificar permisos del socket de Docker
ls -la /var/run/docker.sock

# Verificar que el usuario jenkins tenga acceso
sudo usermod -aG docker jenkins
```

### Problemas con Android SDK
```bash
# Verificar instalación del SDK
docker exec jenkins-master sdkmanager --list

# Verificar licencias aceptadas
docker exec jenkins-master sdkmanager --licenses
```

### Problemas de memoria
```bash
# Ajustar límites de memoria en .env
JAVA_OPTS=-Xmx2g -Xms1g
```

## 📊 Monitoreo

### Métricas Disponibles
- **Uso de CPU y memoria**: `docker stats`
- **Logs de Jenkins**: `docker-compose logs -f`
- **Estado de servicios**: `docker-compose ps`
- **Uso de disco**: `df -h`

### Alertas Recomendadas
- Uso de memoria > 80%
- Uso de disco > 90%
- Contenedor no responde
- Backup fallido

## 🔄 Actualizaciones

### Actualizar Jenkins
```bash
# Detener servicios
docker-compose down

# Actualizar imagen
docker-compose pull

# Reiniciar con nueva imagen
docker-compose up -d
```

### Actualizar configuración
```bash
# Modificar config/jenkins.yaml
# Reiniciar Jenkins
docker-compose restart jenkins
```

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Crear un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo LICENSE para más detalles.

## 📞 Soporte

Para soporte técnico o preguntas:
- Crear un issue en el repositorio
- Contactar al equipo de DevOps
- Revisar la documentación oficial de Jenkins

## 🚧 Fases Futuras

### Fase 2: Soporte iOS
- Instalación de CocoaPods
- Xcode Command Line Tools
- Configuración de certificados iOS
- Soporte para builds iOS

### Fase 3: Optimizaciones Avanzadas
- Cache distribuido
- Builds paralelos
- Monitoreo avanzado
- Integración con sistemas externos

---

**Nota**: Este ambiente está configurado para desarrollo y pruebas con soporte completo para Android. Para producción, revisar y ajustar todas las configuraciones de seguridad. 