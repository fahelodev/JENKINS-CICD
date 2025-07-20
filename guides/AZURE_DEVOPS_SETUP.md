# 🔷 Azure DevOps + Jenkins Integration Guide

## 📋 Paso 1: Crear Personal Access Token (PAT)

1. **Azure DevOps** → **User Settings** (click en tu avatar) → **Personal Access Tokens**
2. **+ New Token**:
   - **Name**: `Jenkins-Integration`
   - **Organization**: Tu organización
   - **Expiration**: `1 year`
   - **Scopes**: 
     - ✅ **Code**: `Read & write`
     - ✅ **Build**: `Read & execute`
     - ✅ **Release**: `Read, write, execute & manage`

3. **Create** → **Copiar el token** 🔐 (¡Guárdalo seguro!)
    9oXvCnvUleZ17SyUdjWF7d16Bg5nad93JoyAc9EOJRuUpgIa6BThJQQJ99BGACAAAAAOvceoAAASAZDO4Y41

## 📋 Paso 2: Configurar Credenciales en Jenkins

1. **Jenkins** → **Manage Jenkins** → **Manage Credentials**
2. **Stores scoped to Jenkins** → **System** → **Global credentials**
3. **+ Add Credentials**:
   - **Kind**: `Username with password`
   - **Scope**: `Global`
   - **Username**: Tu email de Azure DevOps
   - **Password**: El PAT que copiaste
   - **ID**: `azure-devops-credentials`
   - **Description**: `Azure DevOps Personal Access Token`

## 📋 Paso 3: Configurar Pipeline

### Repository URL Format:
```
https://dev.azure.com/ORGANIZACION/PROYECTO/_git/REPOSITORIO
```

### Ejemplo:
```
https://dev.azure.com/esmax/mobile-app/_git/smx-app-front
```

## 📋 Paso 4: Crear Jenkinsfile Básico

Crea este archivo en la raíz de tu repositorio:

```groovy
pipeline {
    agent any
    
    environment {
        NODE_VERSION = '18'
        JAVA_HOME = '/opt/java/openjdk'
        ANDROID_HOME = '/opt/android-sdk'
    }
    
    stages {
        stage('📋 Info') {
            steps {
                echo "🚀 Building ESMax App"
                echo "📂 Branch: ${env.GIT_BRANCH}"
                echo "🔨 Build #${env.BUILD_NUMBER}"
                
                sh 'node --version'
                sh 'npm --version'
                sh 'java -version'
            }
        }
        
        stage('📦 Dependencies') {
            steps {
                echo "📦 Installing dependencies..."
                sh 'npm install'
            }
        }
        
        stage('🧪 Tests') {
            steps {
                echo "🧪 Running tests..."
                sh 'npm test -- --watchAll=false'
            }
        }
        
        stage('🔨 Build Android') {
            steps {
                echo "🤖 Building Android..."
                sh 'cd android && ./gradlew assembleRelease'
            }
        }
        
        stage('🔨 Build iOS') {
            when {
                expression { return env.NODE_NAME == 'master' } // Solo en Mac
            }
            steps {
                echo "🍎 Building iOS..."
                sh 'cd ios && xcodebuild -workspace aramcoAppRN.xcworkspace -scheme aramcoAppRN -configuration Release archive'
            }
        }
        
        stage('📦 Artifacts') {
            steps {
                echo "📦 Archiving artifacts..."
                archiveArtifacts artifacts: 'android/app/build/outputs/apk/**/*.apk', fingerprint: true
                // archiveArtifacts artifacts: 'ios/build/**/*.ipa', fingerprint: true
            }
        }
    }
    
    post {
        always {
            echo "🏁 Build completed"
            cleanWs()
        }
        success {
            echo "✅ Build successful!"
        }
        failure {
            echo "❌ Build failed!"
        }
    }
}
```

## 📋 Paso 5: Service Hook (Opcional)

Para triggers automáticos desde Azure DevOps:

1. **Azure DevOps** → **Project Settings** → **Service hooks**
2. **+ Create subscription**
3. **Jenkins** → **Next**
4. **Trigger**: `Code pushed`
5. **Repository**: Tu repo
6. **Jenkins URL**: `http://TU_JENKINS:8080/job/TU_PIPELINE/build?token=azure-devops-webhook-token`

## 🔧 Troubleshooting

### Error: "Couldn't find any revision to build"
- Verificar Branch Specifier: `*/main` o `*/develop`
- Verificar credenciales
- Verificar URL del repositorio

### Error: "Permission denied"
- Verificar scopes del PAT
- Verificar username en credenciales

### Error: "Host key verification failed"
- Usar HTTPS en lugar de SSH
- O configurar SSH keys si prefieres SSH 