# TechVeo — Kubernetes manifests e scripts

Este repositório contém os manifestos Kubernetes (Kustomize) e scripts para executar, testar e limpar a aplicação TechVeo em ambientes locais (Minikube) e em EKS (AWS).

## Sumário
- Visão geral
- Requisitos
- Como rodar (Minikube)
- Deploy em EKS (links)
- Scripts disponíveis
- Estrutura do projeto

## Requisitos
- Docker
- Minikube (para desenvolvimento local)
- kubectl
- (Opcional) Acesso AWS + Terraform para EKS

## Scripts principais
- `build-images.bat` / `build-images.sh` — build das imagens Docker
- `deploy.bat` / `deploy.sh` — aplica manifests via `kubectl`/`kustomize`
- `validate.bat` / `validate.sh` — valida o deploy
- `cleanup.bat` / `cleanup.sh` — remove recursos e limpa o ambiente
- `setup-ingress.bat` / `setup-ingress.sh` — instala NGINX Ingress local
- `setup-ingress-eks.bat` / `setup-ingress-eks.sh` — helpers para EKS

Observação: existem tasks do VS Code configuradas para executar esses scripts diretamente (veja `tasks` no painel de execução).

## Quickstart — Minikube (local)

1. Inicie o Minikube (exemplo):

```powershell
minikube start --memory=4096 --cpus=2 --driver=docker
```

2. (Opcional) Habilite `metrics-server` para HPA:

```powershell
minikube addons enable metrics-server
```

3. Build das imagens (Windows/Linux):

```powershell
# Windows
./build-images.bat

# Linux/Mac
./build-images.sh
```

4. Deploy:

```powershell
# Windows
./deploy.bat

# Linux/Mac
./deploy.sh
```

5. Instale o Ingress (se necessário):

```powershell
# Windows
./setup-ingress.bat

# Linux/Mac
./setup-ingress.sh
```

6. Validar e inspecionar:

```powershell
./validate.bat
kubectl get pods -n techveo -o wide
kubectl get hpa -n techveo
kubectl logs -f -l app.kubernetes.io/name=techveo-order-api -n techveo
```

7. Limpeza:

```powershell
./cleanup.bat
```

## Deploy em EKS
Este repositório inclui scripts e notas para integração com AWS EKS. Para detalhes da integração NLB/Ingress/terraform, veja os documentos específicos no repositório (quando disponíveis) ou os scripts `setup-ingress-eks.*`.

## Estrutura do projeto

```
src/
├─ base/                  # manifests base (deployments, services, configmaps, secrets, hpa)
└─ overlays/
	└─ development/        # overlays de desenvolvimento

Scripts no diretório raiz: build-images(.sh/.bat), deploy(.sh/.bat), validate(.sh/.bat), cleanup(.sh/.bat)
```

## Observações operacionais
- Namespace usado: `techveo`
- HPA depende do `metrics-server` estar ativo no cluster
- Para acessar via hostname em Minikube, adicione `techveo.local` ao seu `hosts` apontando para o IP do Minikube

## Próximos passos sugeridos
- Ajustar README com exemplos de endpoints específicos do seu ambiente (se desejar)
- Incluir instruções de credenciais/Secrets seguros (ex.: uso de SealedSecrets ou HashiCorp Vault)

---

Arquivo atualizado: [README.md](README.md)

Se quiser, posso também:
- gerar um README em inglês
- adicionar exemplos de `kubectl` para cada componente
- commitar as mudanças (se desejar que eu faça)
