# 🎓 HANDS-ON: Terraform + GitHub Actions + Oracle Cloud

**Guia prático para executar na live com os alunos**

---

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter:

- [ ] Conta Oracle Cloud (Free Tier) - https://www.oracle.com/cloud/free/
- [ ] Conta GitHub
- [ ] Git instalado localmente
- [ ] Editor de código (VS Code recomendado)

---

## 🚀 PARTE 1: Configurar Credenciais OCI (15 min)

### Passo 1: Criar API Key na OCI

1. **Acesse o Console OCI:** https://cloud.oracle.com
2. **Clique no ícone do perfil** (canto superior direito)
3. **Selecione:** `User Settings`
4. **No menu lateral esquerdo:** `API Keys`
5. **Clique em:** `Add API Key`
6. **Selecione:** `Generate API Key Pair`
7. **Clique em:** `Download Private Key` (salve como `oci_api_key.pem`)
8. **Clique em:** `Download Public Key` (salve como `oci_api_key_public.pem`)
9. **Clique em:** `Add`

✅ **Você verá uma tela com a configuração. NÃO FECHE AINDA!**

### Passo 2: Copiar Informações Importantes

Na tela de configuração que apareceu, copie os seguintes valores:

```ini
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaa...           # ← COPIE ESTE VALOR
fingerprint=aa:bb:cc:dd:ee:ff:...          # ← COPIE ESTE VALOR
tenancy=ocid1.tenancy.oc1..aaaaaaaa...     # ← COPIE ESTE VALOR
region=us-ashburn-1                         # ← COPIE ESTE VALOR
key_file=~/.oci/oci_api_key.pem
```

**📝 Cole esses valores em um arquivo temporário (bloco de notas). Vamos usar em breve!**

### Passo 3: Obter Compartment ID

1. **No menu OCI:** ☰ → `Identity & Security` → `Compartments`
2. **Clique no compartment** que você quer usar (ou use o root)
3. **Copie o OCID** (começa com `ocid1.compartment...`)

**📝 Adicione ao seu arquivo temporário:**
```
compartment_id=ocid1.compartment.oc1..aaaaaaaa...
```

### Passo 4: Converter Chave Privada para Base64

**No terminal (Mac/Linux):**
```bash
cd ~/Downloads
cat oci_api_key.pem | base64 | tr -d '\n' > oci_api_key_base64.txt
cat oci_api_key_base64.txt
```

**No Windows (PowerShell):**
```powershell
cd $HOME\Downloads
[Convert]::ToBase64String([IO.File]::ReadAllBytes("oci_api_key.pem")) | Out-File -Encoding ASCII oci_api_key_base64.txt
Get-Content oci_api_key_base64.txt
```

**📝 Copie o conteúdo do arquivo `oci_api_key_base64.txt` para seu arquivo temporário**

### ✅ Checklist - Você deve ter agora:

```
✓ user (OCI_USER_OCID)
✓ fingerprint (OCI_FINGERPRINT)
✓ tenancy (OCI_TENANCY_OCID)
✓ region (OCI_REGION)
✓ compartment_id (OCI_COMPARTMENT_ID)
✓ chave privada em base64 (OCI_PRIVATE_KEY)
```

---

## 🔧 PARTE 2: Configurar Repositório GitHub (10 min)

### Passo 1: Criar Repositório no GitHub

1. **Acesse:** https://github.com/new
2. **Repository name:** `terraform-oci-demo`
3. **Description:** `Terraform + GitHub Actions + Oracle Cloud`
4. **Visibilidade:** Public ou Private (sua escolha)
5. **NÃO** marque nenhuma opção de inicialização
6. **Clique em:** `Create repository`

### Passo 2: Clonar o Projeto Localmente

**No terminal:**
```bash
# Clone o repositório que acabou de criar
git clone https://github.com/SEU-USUARIO/terraform-oci-demo.git
cd terraform-oci-demo

# Copie os arquivos do projeto para este diretório
# (ou baixe o projeto da aula)
```

### Passo 3: Configurar GitHub Secrets

1. **No seu repositório GitHub:** `Settings` → `Secrets and variables` → `Actions`
2. **Clique em:** `New repository secret`
3. **Adicione os seguintes secrets** (um por vez):

| Name | Value (do seu arquivo temporário) |
|------|-----------------------------------|
| `OCI_TENANCY_OCID` | ocid1.tenancy.oc1..aaaaaaaa... |
| `OCI_USER_OCID` | ocid1.user.oc1..aaaaaaaa... |
| `OCI_FINGERPRINT` | aa:bb:cc:dd:ee:ff:... |
| `OCI_PRIVATE_KEY` | LS0tLS1CRUdJTi... (base64) |
| `OCI_REGION` | us-ashburn-1 |
| `OCI_COMPARTMENT_ID` | ocid1.compartment.oc1..aaaaaaaa... |

**⚠️ IMPORTANTE:** 
- Cole os valores EXATAMENTE como estão
- Não adicione espaços ou quebras de linha extras
- O `OCI_PRIVATE_KEY` deve ser a versão base64 completa

### Passo 4: Configurar Environment "production"

1. **No repositório:** `Settings` → `Environments`
2. **Clique em:** `New environment`
3. **Name:** `production`
4. **Marque:** `Required reviewers`
5. **Adicione:** Seu usuário como revisor
6. **Clique em:** `Save protection rules`

✅ **Agora o Terraform Apply vai precisar de aprovação manual!**

---

## 📝 PARTE 3: Ajustar Variáveis do Terraform (5 min)

### Passo 1: Obter Image OCID (Oracle Linux)

**No Console OCI:**
1. **Menu:** ☰ → `Compute` → `Instances`
2. **Clique em:** `Create Instance` (não vamos criar, só pegar o OCID)
3. **Em "Image":** Clique em `Change Image`
4. **Selecione:** `Oracle Linux 8`
5. **Copie o OCID** da imagem (ex: `ocid1.image.oc1.iad.aaaaaaaa...`)
6. **Cancele** a criação da instância

**OU use este comando no terminal (se tiver OCI CLI instalado):**
```bash
oci compute image list \
  --compartment-id <SEU_COMPARTMENT_ID> \
  --operating-system "Oracle Linux" \
  --operating-system-version "8" \
  --shape "VM.Standard.E2.1.Micro" \
  --query 'data[0].id' \
  --raw-output
```

### Passo 2: Gerar Chave SSH (se não tiver)

**No terminal:**
```bash
# Gerar nova chave SSH
ssh-keygen -t rsa -b 4096 -f ~/.ssh/oci_demo_key -N ""

# Ver a chave pública
cat ~/.ssh/oci_demo_key.pub
```

**📝 Copie o conteúdo da chave pública (começa com `ssh-rsa AAAA...`)**

### Passo 3: Criar arquivo terraform.tfvars

**Crie o arquivo:** `terraform/terraform.tfvars`

```hcl
# terraform/terraform.tfvars
project_name      = "fiap-demo"
environment       = "dev"
instance_count    = 2
instance_image_id = "ocid1.image.oc1.iad.aaaaaaaa..."  # ← Cole o OCID da imagem
ssh_public_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAA..."   # ← Cole sua chave SSH pública
```

**⚠️ IMPORTANTE:** Adicione este arquivo ao `.gitignore` (já está configurado)

---

## 🎯 PARTE 4: Testar Localmente (OPCIONAL - 10 min)

Se quiser testar antes de fazer push:

### Passo 1: Instalar Terraform

**Mac (Homebrew):**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Linux:**
```bash
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**Windows (Chocolatey):**
```powershell
choco install terraform
```

### Passo 2: Configurar Credenciais Localmente

```bash
# Criar diretório OCI
mkdir -p ~/.oci

# Copiar chave privada
cp ~/Downloads/oci_api_key.pem ~/.oci/
chmod 600 ~/.oci/oci_api_key.pem

# Criar arquivo de configuração
cat > ~/.oci/config << EOF
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaa...
fingerprint=aa:bb:cc:dd:ee:ff:...
tenancy=ocid1.tenancy.oc1..aaaaaaaa...
region=us-ashburn-1
key_file=~/.oci/oci_api_key.pem
EOF
```

### Passo 3: Testar Terraform

```bash
cd terraform

# Exportar variáveis
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaa..."
export TF_VAR_user_ocid="ocid1.user.oc1..aaaaaaaa..."
export TF_VAR_fingerprint="aa:bb:cc:dd:ee:ff:..."
export TF_VAR_region="us-ashburn-1"
export TF_VAR_compartment_id="ocid1.compartment.oc1..aaaaaaaa..."

# Inicializar (vai falhar no backend, tudo bem por enquanto)
terraform init -backend=false

# Validar
terraform validate

# Ver o plano (sem aplicar)
terraform plan
```

✅ **Se aparecer o plano sem erros, está tudo certo!**

---

## 🚀 PARTE 5: Deploy via GitHub Actions (15 min)

### Passo 1: Fazer Push do Código

```bash
# Voltar para a raiz do projeto
cd ..

# Adicionar todos os arquivos
git add .

# Commit
git commit -m "Initial commit: Terraform + GitHub Actions + OCI"

# Push para o GitHub
git push origin main
```

### Passo 2: Criar Pull Request de Teste

```bash
# Criar branch de teste
git checkout -b feature/test-pipeline

# Fazer uma pequena alteração (ex: adicionar comentário)
echo "# Test pipeline" >> terraform/main.tf

# Commit e push
git add .
git commit -m "Test: Validar pipeline"
git push origin feature/test-pipeline
```

### Passo 3: Abrir PR no GitHub

1. **No GitHub:** Você verá um banner `Compare & pull request`
2. **Clique nele**
3. **Adicione descrição:** "Teste da pipeline de validação"
4. **Clique em:** `Create pull request`

✅ **Observe a pipeline `Terraform Plan` executando!**

### Passo 4: Verificar o Plan

1. **Aguarde a pipeline terminar** (1-2 minutos)
2. **Veja o comentário automático** com o plano do Terraform
3. **Revise as mudanças** que serão aplicadas

### Passo 5: Fazer Merge (Deploy)

1. **Se o plan estiver OK:** Clique em `Merge pull request`
2. **Confirme:** `Confirm merge`
3. **Vá para:** `Actions` tab

✅ **Observe a pipeline `Terraform Apply` executando!**

### Passo 6: Aprovar Deploy em Produção

1. **A pipeline vai pausar** em "Review deployments"
2. **Clique em:** `Review deployments`
3. **Marque:** `production`
4. **Clique em:** `Approve and deploy`

🎉 **Aguarde 3-5 minutos para o deploy completar!**

---

## 🔍 PARTE 6: Verificar Recursos Criados (5 min)

### No Console OCI:

1. **VCN:**
   - Menu: ☰ → `Networking` → `Virtual Cloud Networks`
   - Você deve ver: `fiap-demo-vcn`

2. **Compute Instances:**
   - Menu: ☰ → `Compute` → `Instances`
   - Você deve ver: 2 instâncias `fiap-demo-instance-0` e `fiap-demo-instance-1`

3. **Verificar IPs Públicos:**
   - Clique em cada instância
   - Copie o `Public IP Address`

### Testar Conexão SSH:

```bash
# Conectar na primeira instância
ssh -i ~/.ssh/oci_demo_key opc@<IP_PUBLICO>

# Dentro da instância
whoami
hostname
exit
```

---

## 📊 PARTE 7: Ver Outputs do Terraform (2 min)

### No GitHub:

1. **Actions** → Última execução do `Terraform Apply`
2. **Scroll down** até `Artifacts`
3. **Download:** `terraform-outputs`
4. **Abra o arquivo** `outputs.json`

```json
{
  "vcn_id": {
    "value": "ocid1.vcn.oc1.iad.aaaaaaaa..."
  },
  "instance_public_ips": {
    "value": ["150.136.x.x", "150.136.y.y"]
  }
}
```

---

## 🧹 PARTE 8: Destruir Recursos (IMPORTANTE!)

**Para não gastar créditos, destrua os recursos após a demo:**

### Opção 1: Via Terraform Local

```bash
cd terraform

# Exportar variáveis (se ainda não estiverem)
export TF_VAR_tenancy_ocid="..."
export TF_VAR_user_ocid="..."
export TF_VAR_fingerprint="..."
export TF_VAR_region="..."
export TF_VAR_compartment_id="..."

# Destruir
terraform destroy
```

### Opção 2: Via Console OCI (Manual)

1. **Terminar Instâncias:**
   - Compute → Instances → Selecionar todas → More Actions → Terminate

2. **Deletar VCN:**
   - Networking → Virtual Cloud Networks → fiap-demo-vcn → Delete

---

## 🎯 Checklist Final

Ao final da live, os alunos devem ter:

- [ ] Conta OCI configurada com API Key
- [ ] Repositório GitHub com código Terraform
- [ ] Secrets configurados no GitHub
- [ ] Pipeline de Plan funcionando (PRs)
- [ ] Pipeline de Apply funcionando (merge)
- [ ] Environment "production" com aprovação manual
- [ ] Recursos provisionados na OCI (VCN + 2 VMs)
- [ ] Conexão SSH funcionando nas instâncias
- [ ] Recursos destruídos (para não gastar créditos)

---

## 🐛 Troubleshooting Comum

### Erro: "Service error: NotAuthenticated"
**Solução:** Verificar se os secrets estão corretos no GitHub

### Erro: "out of host capacity"
**Solução:** Trocar `ad_number = 1` para `2` ou `3` no `main.tf`

### Erro: "shape VM.Standard.E2.1.Micro is not available"
**Solução:** Verificar se está usando Free Tier na região correta

### Erro: "Invalid private key"
**Solução:** Verificar se o base64 da chave privada está correto (sem espaços/quebras)

### Pipeline não executa
**Solução:** Verificar se os arquivos estão na pasta correta (`.github/workflows/`)

### Terraform Plan mostra "No changes"
**Solução:** Normal se já foi aplicado. Faça uma alteração no código para testar.

---

## 📚 Recursos Adicionais

- **Documentação OCI:** https://docs.oracle.com/en-us/iaas/
- **Terraform OCI Provider:** https://registry.terraform.io/providers/oracle/oci/
- **GitHub Actions:** https://docs.github.com/en/actions
- **Free Tier OCI:** https://www.oracle.com/cloud/free/

---

## 🎓 Dicas para a Live

1. **Prepare tudo antes:** Crie sua conta OCI e configure as credenciais previamente
2. **Tenha um repositório de backup:** Caso algo dê errado, você pode usar um já configurado
3. **Mostre os erros comuns:** Ajuda os alunos a entenderem o troubleshooting
4. **Explique o fluxo GitOps:** PR → Plan → Merge → Apply → Aprovação
5. **Destaque a segurança:** Secrets no GitHub, não no código
6. **Mostre o custo zero:** Recursos Always Free da OCI

---

**🚀 Boa live! Qualquer dúvida, consulte este guia passo a passo.**

**Professor:** José Neto  
**Curso:** Arquitetura de Sistemas - FIAP  
**Tema:** Infrastructure as Code com Terraform + CI/CD
