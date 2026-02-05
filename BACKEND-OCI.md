# 🗄️ Configuração do Backend OCI Object Storage

Este guia explica como configurar o **Terraform Remote State** usando **Backend OCI Nativo** (não S3-compatible).

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

## 🎯 Backend OCI Nativo Disponível!

O Terraform **TEM backend nativo OCI** desde versões recentes! Muito mais simples que S3-compatible:
- ✅ Usa as **mesmas credenciais** do provider OCI
- ✅ **Não precisa** de Customer Secret Keys
- ✅ **Não precisa** de credenciais AWS
- ✅ Configuração muito mais simples

**Documentação oficial:** https://developer.hashicorp.com/terraform/language/backend/oci

---

## 🔧 Passo a Passo: Backend OCI Nativo (Simples!)

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

### **Passo 3: Atualizar backend.tf**

Edite o arquivo `terraform/backend.tf`:

```hcl
terraform {
  backend "oci" {
    bucket    = "terraform-state-bucket"
    namespace = "SEU_NAMESPACE"
    key       = "fiap-demo/terraform.tfstate"
    region    = "sa-vinhedo-1"
  }
}
```

**Substitua:**
- `SEU_NAMESPACE` → Seu namespace do Object Storage
- `sa-vinhedo-1` → Sua região OCI
- `terraform-state-bucket` → Nome do seu bucket

✅ **Pronto!** O backend usa automaticamente as credenciais do `~/.oci/config`

### **Passo 4: Inicializar Backend**

```bash
cd terraform

# Se já tem state local, migrar para remoto
terraform init

# Confirmar migração quando perguntar
# Type 'yes' to copy state to remote backend
```

### **Passo 5: GitHub Actions (Nenhuma configuração extra!)**

✅ **Não precisa de secrets adicionais!**

O backend OCI usa as **mesmas credenciais OCI** já configuradas no step "Configure OCI Credentials" dos workflows.

As credenciais do `~/.oci/config` criadas pela pipeline são automaticamente usadas pelo backend.

---

## 📝 Exemplo Completo de backend.tf

```hcl
terraform {
  backend "oci" {
    # Nome do bucket criado no OCI Object Storage
    bucket = "terraform-state-bucket"
    
    # Object Storage Namespace
    namespace = "axqhg4xyzabc"
    
    # Caminho do state dentro do bucket
    key = "fiap-demo/terraform.tfstate"
    
    # Região OCI
    region = "sa-vinhedo-1"
  }
}
```

✅ **Simples assim!** Apenas 4 parâmetros necessários.

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

## 🔗 Referências

- [Terraform S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [OCI Object Storage S3 Compatibility](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/s3compatibleapi.htm)
- [OCI Customer Secret Keys](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcredentials.htm#Working2)

---