@echo off
setlocal enabledelayedexpansion
REM Script para fazer build das imagens Docker no Minikube (microservices + frontends)

echo 🐳 Fazendo build das imagens Docker para o Minikube...

REM Configura o ambiente Docker para usar o Minikube
echo 🔧 Configurando ambiente Docker do Minikube...
FOR /f "tokens=*" %%i IN ('minikube docker-env --shell cmd') DO %%i

REM Lista de imagens do projeto: tag|dockerfile|context
set IMAGES=
set IMAGES=!IMAGES! "grupotechchallenge/techveo-management-api:latest|services/management-api/Dockerfile|services/management-api"
set IMAGES=!IMAGES! "grupotechchallenge/techveo-management-worker:latest|services/management-worker/Dockerfile|services/management-worker"
set IMAGES=!IMAGES! "grupotechchallenge/techveo-processing-worker:latest|services/processing-worker/Dockerfile|services/processing-worker"
set IMAGES=!IMAGES! "grupotechchallenge/techveo-notification-worker:latest|services/notification-worker/Dockerfile|services/notification-worker"
set IMAGES=!IMAGES! "grupotechchallenge/techveo-web:latest|apps/web/Dockerfile|apps/web"

for %%I in (!IMAGES!) do (
    for /f "tokens=1,2,3 delims=|" %%A in (%%~I) do (
        set "TAG=%%~A"
        set "DF=%%~B"
        set "CTX=%%~C"
        if not exist "!DF!" (
            echo ⚠️  Dockerfile nao encontrado para !TAG! em !DF!, pulando...
        ) else (
            echo 📦 Building !TAG! ...
            docker build -t !TAG! -f "!DF!" "!CTX!"
            if errorlevel 1 (
                echo ❌ Erro ao fazer build de !TAG!
                exit /b 1
            )
        )
    )
)

echo ✅ Todas as imagens foram processadas.
echo.
echo Para fazer o deploy, execute:
echo kubectl apply -k src/overlays/development/
echo.
echo Ou use o script de deploy:
echo deploy.bat
pause
