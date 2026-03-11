@echo off
REM Script para limpeza completa do deployment Kubernetes

echo 🧹 Limpando recursos do TechVeo no Kubernetes...

echo.
echo ⚠️ Este script irá remover todos os recursos do namespace techveo
echo ⚠️ Isso inclui pods, services, deployments, PVCs e dados persistentes
echo.
set /p CONFIRM="Tem certeza que deseja continuar? (s/N): "

if /i not "%CONFIRM%"=="s" (
    echo ❌ Operação cancelada pelo usuário
    exit /b 0
)

echo.
echo 🗑️ Removendo recursos do namespace techveo...

REM Remover namespace (isso remove todos os recursos dentro dele)
kubectl delete namespace techveo --ignore-not-found=true

if errorlevel 1 (
    echo ❌ Erro ao remover namespace
    echo.
    echo 🔧 Tentando limpeza manual...
    kubectl delete all --all -n techveo --ignore-not-found=true
    kubectl delete pvc --all -n techveo --ignore-not-found=true
    kubectl delete configmap --all -n techveo --ignore-not-found=true
    kubectl delete secret --all -n techveo --ignore-not-found=true
    kubectl delete hpa --all -n techveo --ignore-not-found=true
    kubectl delete namespace techveo --ignore-not-found=true
) else (
    echo ✅ Namespace techveo removido com sucesso
)

echo.
echo 🔍 Verificando se ainda existem recursos...
kubectl get all -n techveo 2>nul

if errorlevel 1 (
    echo ✅ Todos os recursos foram removidos
) else (
    echo ⚠️ Ainda existem alguns recursos. Você pode precisar removê-los manualmente.
)

echo.
echo 🎉 Limpeza concluída!
echo.
echo 💡 Para fazer um novo deploy:
echo    k8s\build-images.bat
echo    k8s\deploy.bat
echo.
pause
