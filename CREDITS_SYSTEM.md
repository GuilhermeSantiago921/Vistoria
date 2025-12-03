# Sistema de Gerenciamento de Créditos com Preços - Vistoria

## 💰 Sistema de Preços
- **Valor por crédito**: R$ 25,00 (configurável)
- **1 crédito = 1 vistoria completa**
- **Sistema pré-pago**: Cliente compra créditos antes de usar

## 📋 Funcionalidades Implementadas

### 1. **Painel do Administrador**
- **Gerenciar Créditos**: `/admin/credits/manage`
  - Visualizar todos os clientes e seus créditos atuais
  - Adicionar créditos para clientes específicos
  - Definir um valor total de créditos
  - Sistema de logs para auditoria

- **Histórico de Créditos**: `/admin/credits/history`
  - Acompanhar uso de créditos por cliente
  - Visualizar histórico de vistorias
  - Estatísticas detalhadas por cliente

### 2. **Funcionalidades do Sistema**

#### **Adição de Créditos**
- Administrador pode adicionar entre 1-100 créditos por operação
- Campo opcional para motivo da operação
- Log automático de todas as operações

#### **Definição de Créditos**
- Administrador pode definir o total de créditos (0-1000)
- Substitui o valor atual
- Útil para correções ou pacotes especiais

#### **Controle Automático**
- Créditos são deduzidos automaticamente ao enviar vistoria
- Dashboard mostra créditos disponíveis em tempo real
- Verificação de créditos antes de permitir nova vistoria

### 3. **Interface do Usuário**

#### **Dashboard do Cliente**
- Exibe créditos disponíveis em destaque
- Status visual (✅ Pronto / ❌ Sem créditos)
- Botão inteligente (Nova Vistoria ou Comprar Créditos)

#### **Dashboard do Administrador**
- Card dedicado para gerenciar créditos
- Navegação rápida para todas as funcionalidades
- Estatísticas em tempo real

### 4. **Sistema de Valores e Cálculos**

#### **Configuração de Preços**
- Arquivo: `config/inspection.php`
- Variável de ambiente: `INSPECTION_CREDIT_PRICE=25.00`
- Valor padrão: R$ 25,00 por crédito

#### **Exibição de Valores**
- Dashboard do cliente: mostra valor total dos créditos
- Painel do admin: mostra valores individuais e totais
- Modais: cálculo em tempo real dos valores
- Histórico: valores por cliente e resumos gerais

### 5. **Melhorias no Modelo User**

#### **Novos Métodos**
```php
// Verificar se tem créditos
$user->hasCredits()

// Consumir um crédito
$user->consumeCredit()

// Adicionar créditos
$user->addCredits($amount)

// Definir total de créditos
$user->setCredits($amount)

// Obter valor total dos créditos
$user->getCreditsValue()

// Obter valor formatado
$user->getFormattedCreditsValue()

// Calcular valor de quantidade de créditos
User::calculateCreditsValue($credits)

// Formatar valor monetário
User::formatMoney($value)
```

### 6. **JavaScript Interativo**
- Cálculo em tempo real nos modais
- Formatação automática de valores
- Validação visual de campos
- Feedback instantâneo de preços

### 7. **Sistema de Logs**
Todas as operações de crédito são registradas com:
- ID e nome do administrador
- ID e nome do cliente
- Quantidade de créditos (anterior/nova)
- Motivo da operação
- Timestamp da operação

### 8. **Rotas Implementadas**
```php
// Gerenciamento de créditos (Admin apenas)
Route::get('/admin/credits/manage', 'AdminController@manageCredits');
Route::post('/admin/credits/add', 'AdminController@addCredits');
Route::post('/admin/credits/set', 'AdminController@setCredits');
Route::get('/admin/credits/history', 'AdminController@creditsHistory');
```

### 9. **Validações**
- **Adicionar créditos**: 1-100 por operação
- **Definir créditos**: 0-1000 total
- **Verificação de papel**: Apenas clientes podem receber créditos
- **Autenticação**: Apenas administradores podem gerenciar

### 10. **Interface Responsiva**
- Modais para adicionar/definir créditos
- Tabelas responsivas
- Cards informativos
- Navegação intuitiva

## 🚀 Como Usar

### **Para Administradores:**
1. Acesse o dashboard administrativo
2. Clique em "Gerenciar Créditos" ou "💳 Controle de créditos"
3. Visualize a lista de clientes
4. Use os botões "➕ Adicionar" ou "⚙️ Definir" para cada cliente
5. Acompanhe o histórico em "📋 Histórico de Créditos"

### **Para Clientes:**
1. Visualize seus créditos no Dashboard
2. Se tiver créditos: clique em "Nova Vistoria"
3. Se não tiver créditos: clique em "Comprar Créditos"
4. Créditos são descontados automaticamente ao enviar vistoria

## 📊 Estatísticas Disponíveis
- Total de clientes
- Total de créditos no sistema
- **Valor total em reais dos créditos**
- Clientes sem créditos
- Histórico de vistorias por cliente
- Taxa de aprovação/reprovação
- **Valores monetários por cliente**
- **Receita potencial do sistema**

## 🔒 Segurança
- Apenas administradores podem gerenciar créditos
- Logs detalhados de todas as operações
- Validação de entrada para evitar valores inválidos
- Verificação de papel de usuário antes das operações

## 🔧 Configuração de Preços

### **Alterar o valor do crédito:**
1. Edite o arquivo `.env`:
   ```
   INSPECTION_CREDIT_PRICE=30.00
   ```
2. Ou altere diretamente em `config/inspection.php`
3. Reinicie a aplicação

### **Valores de exemplo:**
- **R$ 25,00**: Preço padrão atual
- **R$ 30,00**: Preço premium
- **R$ 20,00**: Preço promocional

### **Impacto da mudança:**
- Todos os cálculos são atualizados automaticamente
- Interface mostra novos valores em tempo real
- Créditos existentes mantêm valor atual (não são recalculados)

---

**Sistema de preços implementado com sucesso! ✅💰**
