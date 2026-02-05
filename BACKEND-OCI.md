# 🗄️ Configuração do Backend OCI Object Storage

Este guia explica como configurar o **Terraform Remote State** usando OCI Object Storage com interface S3-compatible.

## 📋 Por que usar Remote State?

**Vantagens:**
- ✅ Estado compartilhado entre equipe e pipelines
- ✅ Lock de estado (evita conflitos simultâneos)
- ✅ Backup automático
- ✅ Versionamento do state
- ✅ Segurança centralizada

**Desvantagens:**
- ⚠️ Configuração adicional necessária
- ⚠️ Requer Customer Secret Keys
- ⚠️ Mais complexo para demos/aulas

## 🎯 Sim, precisa do modo S3-compatible!

O Terraform **não tem backend nativo OCI**. Por isso, usamos a **API S3-compatible** do OCI Object Storage.

---

## 🔧 Passo a Passo: Configurar Backend OCI

### **Passo 1: Criar Bucket no OCI**

1. **Acesse o Console OCI:** https://cloud.oracle.com
2. **Menu:** ☰ → **Storage** → **Buckets**
3. **Clique em:** `Create Bucket`
4. **Configure:**
   - **Bucket Name:** `terraform-state-bucket`
   - **Default Storage Tier:** Standard
   - **Emit Object Events:** Não (desabilitado)
   - **Encryption:** Encrypt using Oracle managed keys
5. **Clique em:** `Create`

### **Passo 2: Obter Object Storage Namespace**

**Opção 1 - Via Console:**
1. Na tela de Buckets, você verá o **Namespace** no topo
2. Copie o valor (ex: `axqhg4xyzabc`)

**Opção 2 - Via Perfil:**
1. Clique no **ícone do perfil** → **Tenancy**
2. Procure por **Object Storage Namespace**

**Opção 3 - Via OCI CLI:**
```bash
oci os ns get --query 'data' --raw-output
```

### **Passo 3: Criar Customer Secret Keys**

As Customer Secret Keys são credenciais no formato AWS (Access Key + Secret Key) para acessar o Object Storage via API S3-compatible.

1. **Console OCI:** Perfil → **User Settings**
2. **Menu lateral:** `Customer Secret Keys`
3. **Clique em:** `Generate Secret Key`
4. **Name:** `terraform-backend`
5. **Clique em:** `Generate Secret Key`

⚠️ **IMPORTANTE:** A tela mostrará:
- **Access Key:** `abc123def456...` (visível sempre)
- **Secret Key:** `xyz789ghi012...` (**só aparece UMA vez!**)

**COPIE AMBOS IMEDIATAMENTE!**

### **Passo 4: Configurar Credenciais AWS Localmente**

O Terraform usa credenciais AWS padrão para acessar o backend S3-compatible:

```bash
# Criar diretório AWS
mkdir -p ~/.aws

# Criar arquivo de credenciais
cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id = SEU_ACCESS_KEY_AQUI
aws_secret_access_key = SEU_SECRET_KEY_AQUI
EOF

# Proteger o arquivo
chmod 600 ~/.aws/credentials
```

### **Passo 5: Atualizar backend.tf**

Edite o arquivo `terraform/backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket   = "terraform-state-bucket"
    key      = "fiap-demo/terraform.tfstate"
    region   = "sa-vinhedo-1"
    endpoint = "https://SEU_NAMESPACE.compat.objectstorage.sa-vinhedo-1.oraclecloud.com"
    
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
```

**Substitua:**
- `SEU_NAMESPACE` → Seu namespace do Object Storage
- `sa-vinhedo-1` → Sua região OCI
- `terraform-state-bucket` → Nome do seu bucket

### **Passo 6: Inicializar Backend**

```bash
cd terraform

# Se já tem state local, migrar para remoto
terraform init

# Confirmar migração quando perguntar
# Type 'yes' to copy state to remote backend
```

### **Passo 7: Adicionar Secrets no GitHub Actions**

Para a pipeline funcionar com backend remoto, adicione estes secrets:

| Secret | Valor |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | Access Key da Customer Secret Key |
| `AWS_SECRET_ACCESS_KEY` | Secret Key da Customer Secret Key |

### **Passo 8: Atualizar Workflows**

Adicione as variáveis de ambiente em **todos os workflows** (.github/workflows/*.yml):

```yaml
- name: Configure AWS Credentials for Backend
  run: |
    mkdir -p ~/.aws
    cat > ~/.aws/credentials << EOF
    [default]
    aws_access_key_id=${{ secrets.AWS_ACCESS_KEY_ID }}
    aws_secret_access_key=${{ secrets.AWS_SECRET_ACCESS_KEY }}
    EOF
    chmod 600 ~/.aws/credentials
```

Adicione este step **ANTES** do `Terraform Init` em cada workflow.

---

## 📝 Exemplo Completo de backend.tf

```hcl
terraform {
  backend "s3" {
    # Nome do bucket criado no OCI
    bucket = "terraform-state-bucket"
    
    # Caminho dentro do bucket (organize por projeto/ambiente)
    key = "fiap-demo/terraform.tfstate"
    
    # Região do bucket
    region = "sa-vinhedo-1"
    
    # Endpoint S3-compatible do OCI
    # Formato: https://<namespace>.compat.objectstorage.<region>.oraclecloud.com
    endpoint = "https://axqhg4xyzabc.compat.objectstorage.sa-vinhedo-1.oraclecloud.com"
    
    # Configurações necessárias para OCI
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
```

---

## 🔍 Verificar se Está Funcionando

### Ver State Remoto

```bash
# Listar states
terraform state list

# Ver informações do backend
terraform init
# Deve mostrar: "Initializing the backend..." com sucesso
```

### Verificar no OCI Console

1. **Menu:** ☰ → **Storage** → **Buckets**
2. **Clique no bucket:** `terraform-state-bucket`
3. **Você deve ver:** Arquivo `fiap-demo/terraform.tfstate`

---

## 🔒 Segurança do Backend

### ✅ Best Practices

1. **Bucket Privado:** Nunca deixe público
2. **Customer Secret Keys:** Uma por usuário/serviço
3. **Rotação de Keys:** Trocar periodicamente
4. **Versionamento:** Habilitar no bucket
5. **Backup:** Object Storage já faz automaticamente

### ⚠️ Nunca Fazer

- ❌ Commitar Customer Secret Keys no código
- ❌ Compartilhar Secret Keys por e-mail/chat
- ❌ Usar mesma key para múltiplos serviços
- ❌ Deixar credenciais em arquivos não protegidos

---

## 🧹 Limpeza do Backend

### Remover Backend Remoto (voltar para local)

```bash
cd terraform

# 1. Comentar configuração do backend no backend.tf
# (ou deletar o arquivo)

# 2. Re-inicializar migrando state de volta
terraform init -migrate-state

# 3. Confirmar migração
# Type 'yes' to copy remote state to local
```

### Deletar Bucket e Credenciais

1. **Deletar arquivo do state:**
   - Buckets → `terraform-state-bucket` → Selecionar arquivo → Delete

2. **Deletar bucket:**
   - Buckets → `terraform-state-bucket` → Delete

3. **Revogar Customer Secret Key:**
   - User Settings → Customer Secret Keys → Selecionar → Delete

---

## 📊 Comparação: Local vs Remote State

| Característica | Local State | Remote State |
|----------------|-------------|--------------|
| **Compartilhamento** | ❌ Não | ✅ Sim |
| **Lock de Estado** | ❌ Não | ✅ Sim |
| **Backup** | ❌ Manual | ✅ Automático |
| **Versionamento** | ❌ Não | ✅ Sim |
| **Configuração** | ✅ Simples | ⚠️ Complexa |
| **Ideal para** | Testes locais, demos | Produção, equipes |

---

## 🎓 Recomendação para Aula

**Para demonstração/aula:**
- Use **Local State** (sem backend configurado)
- Mais simples e direto
- Foco no Terraform, não na infraestrutura do state

**Para ambiente produtivo:**
- Use **Remote State** (OCI Object Storage)
- Necessário para equipes
- Essencial para pipelines CI/CD compartilhadas

---

## 🔗 Referências

- [Terraform S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [OCI Object Storage S3 Compatibility](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/s3compatibleapi.htm)
- [OCI Customer Secret Keys](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcredentials.htm#Working2)

---

**✅ Backend configurado!** Seu Terraform state agora está seguro e compartilhado no OCI Object Storage.
