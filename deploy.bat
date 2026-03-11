@echo off
REM Script para fazer deploy da aplicação TechVeo no Kubernetes (Windows)

echo 🚀 Iniciando deploy do TechVeo no Kubernetes...

REM Verifica se o kubectl está disponível
kubectl version --client >nul 2>&1
if errorlevel 1 (
    echo ❌ kubectl não está instalado. Por favor, instale o kubectl.
    pause
    exit /b 1
)

REM Verifica se o Minikube está rodando
kubectl cluster-info >nul 2>&1
if errorlevel 1 (
    echo ❌ Cluster Kubernetes não está disponível. Verifique se o Minikube está rodando.
    echo Para iniciar o Minikube, execute: minikube start
    pause
    exit /b 1
)

REM Habilita Addons necessários
echo 📊 Habilitando Addons necessários...
minikube addons enable metrics-server
minikube addons enable ingress

REM Aguarda alguns segundos para o metrics server estar pronto
timeout /t 10 /nobreak >nul

REM Aplica os manifestos usando Kustomize
echo 📦 Aplicando manifetos do Kubernetes...
kubectl apply -k src/overlays/development/

REM Aguarda os pods estarem prontos
echo ⏳ Aguardando pods ficarem prontos...
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=techveo-system -n techveo --timeout=300s

REM Mostra o status dos recursos
echo 📋 Status dos recursos:
kubectl get all -n techveo

REM Mostra informações sobre como acessar a aplicação
echo.
echo 🎉 Deploy concluído com sucesso!
echo.
echo Para acessar a aplicação:
echo.
echo 🔧 OPÇÃO 1 - Port Forward (Recomendado para Windows):
echo    Execute: port-forward.bat
echo    Depois acesse: http://localhost:30000
echo.
echo 🔧 OPÇÃO 2 - Minikube Service (Tunnel):
echo    Execute: start-tunnel.bat
echo    O navegador abrirá automaticamente com a URL correta
echo.
echo 🔧 OPÇÃO 3 - Manual:
echo    Execute: minikube service techveo-nginx-service -n techveo
echo    Mantenha o terminal aberto e use a URL fornecida
echo.
echo ⚠️  IMPORTANTE: No Windows com Docker driver, a porta 30000 não funciona diretamente!
echo Use uma das opções acima para criar um tunnel ou port-forward.
echo.
echo Após estabelecer a conexão, os endpoints e serviços estarão disponíveis/visíveis assim:
echo - Web UI: http://localhost:30000/ (ou /web dependendo do ingress)
echo - Management API: http://localhost:30000/api/management
echo.
echo Observação sobre workers:
echo - Management/Processing/Notification workers sao processos em background e nao expõem uma porta HTTP.
echo - Para inspecionar/monitorar logs use:
echo    kubectl logs -l app.kubernetes.io/name=techveo-management-worker -n techveo -f
echo    kubectl logs -l app.kubernetes.io/name=techveo-processing-worker -n techveo -f
echo    kubectl logs -l app.kubernetes.io/name=techveo-notification-worker -n techveo -f
echo.
echo Para monitorar os recursos:
echo kubectl get pods -n techveo -w
echo kubectl get hpa -n techveo -w
echo.
pause
