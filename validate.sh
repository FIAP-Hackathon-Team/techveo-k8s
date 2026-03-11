#!/bin/bash

# Script de validação do deployment Kubernetes

echo "🔍 Validando deployment do TechVeo no Kubernetes..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para logs coloridos
log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

log_info() {
    echo -e "ℹ️ $1"
}

# Contador de erros
ERRORS=0

# Verificar se o kubectl está funcionando
if ! kubectl cluster-info &> /dev/null; then
    log_error "Cluster Kubernetes não está disponível"
    exit 1
fi

log_success "Cluster Kubernetes está disponível"

# Verificar se o namespace existe
if kubectl get namespace techveo &> /dev/null; then
    log_success "Namespace 'techveo' existe"
else
    log_error "Namespace 'techveo' não encontrado"
    ((ERRORS++))
fi

# Verificar pods
echo ""
log_info "Verificando status dos pods..."
PODS=$(kubectl get pods -n techveo --no-headers 2>/dev/null | wc -l)

if [ $PODS -eq 0 ]; then
    log_error "Nenhum pod encontrado no namespace techveo"
    ((ERRORS++))
else
    log_success "Encontrados $PODS pods no namespace techveo"

    # Verificar se todos os pods estão rodando
    NOT_RUNNING=$(kubectl get pods -n techveo --no-headers 2>/dev/null | grep -v "Running" | wc -l)

    if [ $NOT_RUNNING -eq 0 ]; then
        log_success "Todos os pods estão rodando"
    else
        log_warning "$NOT_RUNNING pods não estão rodando"
        kubectl get pods -n techveo | grep -v "Running"
    fi
fi

# Verificar services
echo ""
log_info "Verificando services..."
SERVICES=$(kubectl get services -n techveo --no-headers 2>/dev/null | wc -l)

if [ $SERVICES -eq 0 ]; then
    log_error "Nenhum service encontrado"
    ((ERRORS++))
else
    log_success "Encontrados $SERVICES services"
fi

# Verificar deployments
echo ""
log_info "Verificando deployments..."
DEPLOYMENTS=$(kubectl get deployments -n techveo --no-headers 2>/dev/null | wc -l)

if [ $DEPLOYMENTS -eq 0 ]; then
    log_error "Nenhum deployment encontrado"
    ((ERRORS++))
else
    log_success "Encontrados $DEPLOYMENTS deployments"

    # Verificar se todos os deployments estão prontos
    NOT_READY=$(kubectl get deployments -n techveo --no-headers 2>/dev/null | awk '$2 != $3 { print $1 }')

    if [ -z "$NOT_READY" ]; then
        log_success "Todos os deployments estão prontos"
    else
        log_warning "Deployments não prontos: $NOT_READY"
    fi
fi

# Verificar HPA
echo ""
log_info "Verificando HPA..."
HPAS=$(kubectl get hpa -n techveo --no-headers 2>/dev/null | wc -l)

if [ $HPAS -eq 0 ]; then
    log_warning "Nenhum HPA encontrado"
else
    log_success "Encontrados $HPAS HPAs"
fi

# Verificar PVCs
echo ""
log_info "Verificando PVCs..."
PVCS=$(kubectl get pvc -n techveo --no-headers 2>/dev/null | wc -l)

if [ $PVCS -eq 0 ]; then
    log_warning "Nenhum PVC encontrado"
else
    log_success "Encontrados $PVCS PVCs"

    # Verificar se PVCs estão bound
    NOT_BOUND=$(kubectl get pvc -n techveo --no-headers 2>/dev/null | grep -v "Bound" | wc -l)

    if [ $NOT_BOUND -eq 0 ]; then
        log_success "Todos os PVCs estão bound"
    else
        log_warning "$NOT_BOUND PVCs não estão bound"
    fi
fi

# Verificar se a aplicação está acessível
echo ""
log_info "Verificando conectividade da aplicação..."

# Obter a URL do serviço
SERVICE_URL=$(minikube service techveo-nginx-service -n techveo --url 2>/dev/null)

if [ -z "$SERVICE_URL" ]; then
    log_error "Não foi possível obter a URL do serviço"
    ((ERRORS++))
else
    log_success "URL do serviço: $SERVICE_URL"

    # Testar conectividade
    if curl -s "$SERVICE_URL/health" > /dev/null; then
        log_success "Aplicação está respondendo"
    else
        log_warning "Aplicação não está respondendo em /health"
    fi
fi

# Resumo final
echo ""
echo "=================== RESUMO ==================="
if [ $ERRORS -eq 0 ]; then
    log_success "Validação concluída com sucesso!"
    echo ""
    echo "🌐 Para acessar a aplicação:"
    echo "   minikube service techveo-nginx-service -n techveo"
    echo ""
    echo "📊 Para monitorar:"
    echo "   kubectl get pods -n techveo -w"
    echo "   kubectl get hpa -n techveo -w"
else
    log_error "Validação falhou com $ERRORS erros"
    echo ""
    echo "🔍 Para diagnosticar:"
    echo "   kubectl get all -n techveo"
    echo "   kubectl describe pod <pod-name> -n techveo"
    echo "   kubectl logs <pod-name> -n techveo"
fi
echo "=============================================="
