#!/bin/bash

# Script para fazer build das imagens Docker no Minikube (microservices + frontends)

echo "🐳 Fazendo build das imagens Docker para o Minikube..."

# Configura o ambiente Docker para usar o Minikube
echo "🔧 Configurando ambiente Docker do Minikube..."
eval $(minikube docker-env)

images=(
    "grupotechchallenge/techveo-management-api:latest|services/management-api/Dockerfile|services/management-api"
    "grupotechchallenge/techveo-management-worker:latest|services/management-worker/Dockerfile|services/management-worker"
    "grupotechchallenge/techveo-processing-worker:latest|services/processing-worker/Dockerfile|services/processing-worker"
    "grupotechchallenge/techveo-notification-worker:latest|services/notification-worker/Dockerfile|services/notification-worker"
    "grupotechchallenge/techveo-web:latest|apps/web/Dockerfile|apps/web"
)

for entry in "${images[@]}"; do
    IFS='|' read -r tag dockerfile context <<<"$entry"
    if [ ! -f "$dockerfile" ]; then
        echo "⚠️  Dockerfile não encontrado para $tag em $dockerfile, pulando..."
        continue
    fi

    echo "📦 Building $tag ..."
    docker build -t "$tag" -f "$dockerfile" "$context"
    if [ $? -ne 0 ]; then
        echo "❌ Erro ao fazer build de $tag"
        exit 1
    fi
done

echo "✅ Todas as imagens foram processadas."
echo ""
echo "Para fazer o deploy, execute:"
echo "kubectl apply -k src/overlays/development/"
echo ""
echo "Ou use o script de deploy:"
echo "./deploy.sh"
