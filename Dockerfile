FROM jenkins/jenkins:lts-jdk21

USER root

# =============================================================================
# 🛠️ INSTALACIÓN DE HERRAMIENTAS BÁSICAS
# =============================================================================

# Actualizar repositorios e instalar herramientas básicas
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    unzip \
    git \
    build-essential \
    python3 \
    python3-pip \
    ruby \
    ruby-dev \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# 🐳 INSTALACIÓN DE DOCKER CLI
# =============================================================================

# Detectar arquitectura y instalar Docker CLI apropiadamente
RUN arch=$(dpkg --print-architecture) && \
    if [ "$arch" = "amd64" ]; then \
        curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
        apt-get update && \
        apt-get install -y docker-ce-cli && \
        rm -rf /var/lib/apt/lists/*; \
    else \
        echo "Docker CLI no disponible para arquitectura $arch, usando alternativa" && \
        apt-get update && \
        apt-get install -y docker.io && \
        rm -rf /var/lib/apt/lists/*; \
    fi

# =============================================================================
# 📦 INSTALACIÓN DE NODE.JS Y PNPM
# =============================================================================

# Instalar Node.js 20 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Instalar pnpm globalmente
RUN npm install -g pnpm@latest

# =============================================================================
# 🍎 HERRAMIENTAS iOS (EXCLUIDAS EN FASE 1 - SOLO ANDROID)
# =============================================================================

# NOTA: Las herramientas iOS (CocoaPods, Xcode CLI) se instalarán en fases posteriores
# cuando se requiera soporte para builds iOS

# =============================================================================
# 🔥 INSTALACIÓN DE FIREBASE CLI
# =============================================================================

RUN npm install -g firebase-tools

# =============================================================================
# 📦 INSTALACIÓN DE HERRAMIENTAS DE COMPRESIÓN
# =============================================================================

# Instalar pigz para compresión paralela
RUN apt-get update && \
    apt-get install -y pigz && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# 🤖 INSTALACIÓN DE HERRAMIENTAS ANDROID
# =============================================================================

# Instalar Android SDK Command Line Tools
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Descargar e instalar Android SDK Command Line Tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d /tmp && \
    mv /tmp/cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

# Aceptar licencias de Android
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses

# Instalar componentes esenciales de Android SDK
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "extras;android;m2repository" \
    "extras;google;m2repository"

# =============================================================================
# 🛠️ INSTALACIÓN DE HERRAMIENTAS ADICIONALES
# =============================================================================

# Instalar bundletool para análisis de AAB
RUN wget -q https://github.com/google/bundletool/releases/download/1.17.2/bundletool-all-1.17.2.jar -O /usr/local/bin/bundletool.jar && \
    echo '#!/bin/bash\njava -jar /usr/local/bin/bundletool.jar "$@"' > /usr/local/bin/bundletool && \
    chmod +x /usr/local/bin/bundletool

# Instalar aapt2 (incluido en build-tools)
RUN ln -sf $ANDROID_HOME/build-tools/34.0.0/aapt2 /usr/local/bin/aapt2

# =============================================================================
# 📁 CREAR DIRECTORIOS NECESARIOS
# =============================================================================

RUN mkdir -p /var/jenkins_config \
    /var/jenkins_home/.android \
    /var/jenkins_home/.gradle \
    /var/jenkins_home/.pnpm-store

# =============================================================================
# 🔧 CONFIGURACIÓN DE PERMISOS
# =============================================================================

# Configurar pnpm store como root
RUN pnpm config set store-dir /var/jenkins_home/.pnpm-store

# Configurar CocoaPods cache (EXCLUIDO EN FASE 1)
# RUN pod setup --silent

# =============================================================================
# 🐳 CONFIGURACIÓN DE DOCKER PARA JENKINS
# =============================================================================

# Crear grupo docker si no existe y agregar usuario jenkins
RUN groupadd -g 999 docker || true && \
    usermod -aG docker jenkins

# Cambiar de vuelta al usuario jenkins
USER jenkins

# =============================================================================
# 📋 COPIA DE CONFIGURACIÓN
# =============================================================================

# Copiar configuración como código
COPY config/jenkins.yaml /var/jenkins_config/jenkins.yaml

# =============================================================================
# 🔌 INSTALACIÓN AUTOMÁTICA DE PLUGINS
# =============================================================================

# Copiar lista de plugins
COPY config/plugins.txt /usr/share/jenkins/ref/plugins.txt

# Instalar plugins automáticamente
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# =============================================================================
# 🌐 EXPONER PUERTOS
# =============================================================================

EXPOSE 8080 50000 