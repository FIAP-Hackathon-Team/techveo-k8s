#!/bin/bash

# Script para fazer deploy da aplicação TechVeo no Kubernetes

echo "🚀 Iniciando deploy do TechVeo no Kubernetes..."

# Verifica se o kubectl está disponível
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl não está instalado. Por favor, instale o kubectl."
    exit 1
fi

# Verifica se o Minikube está rodando
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cluster Kubernetes não está disponível. Verifique se o Minikube está rodando."
    echo "Para iniciar o Minikube, execute: minikube start"
    exit 1
fi

# Habilita o metrics server para HPA
echo "📊 Habilitando metrics server..."
minikube addons enable metrics-server

# Aguarda alguns segundos para o metrics server estar pronto
sleep 10

# Aplica os manifestos usando Kustomize
echo "📦 Aplicando manifetos do Kubernetes..."
kubectl apply -k src/overlays/development/

# Aguarda os pods estarem prontos
echo "⏳ Aguardando pods ficarem prontos..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=techveo-system -n techveo --timeout=300s

# Mostra o status dos recursos
echo "📋 Status dos recursos:"
kubectl get all -n techveo

# Mostra informações sobre como acessar a aplicação
echo ""
echo "🎉 Deploy concluído com sucesso!"
echo ""
echo "Para acessar a aplicação:"
echo "1. Execute: minikube service techveo-nginx-service -n techveo"
echo "2. Ou obtenha a URL: minikube service techveo-nginx-service -n techveo --url"
echo ""
echo "Endpoints disponíveis:"
echo "- Admin: http://localhost:30000/admin"
echo "- Self-Order: http://localhost:30000/self-order"
echo "- Monitor: http://localhost:30000/monitor"
echo "- Order API: http://localhost:30000/api/order"
echo "- Payment API: http://localhost:30000/api/payment"
echo "- Backoffice API: http://localhost:30000/api/backoffice"
echo "- Kitchen API: http://localhost:30000/api/kitchen"
echo ""
echo "Para monitorar os recursos:"
echo "kubectl get pods -n techveo -w"
echo "kubectl get hpa -n techveo -w"
