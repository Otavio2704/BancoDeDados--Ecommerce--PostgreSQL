# 🛒 E-commerce Database System

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12+-blue.svg)](https://postgresql.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SQL](https://img.shields.io/badge/SQL-Advanced-green.svg)](https://www.postgresql.org/docs/)
[![GitHub stars](https://img.shields.io/github/stars/SEU-USUARIO/ecommerce-database-project.svg)](https://github.com/SEU-USUARIO/ecommerce-database-project/stargazers)

Sistema completo de modelagem lógica de banco de dados para e-commerce, implementando refinamentos específicos e demonstrando conceitos avançados de design de banco de dados relacionais com PostgreSQL.

## ✨ Funcionalidades Principais

- 🧑‍💼 **Clientes PF/PJ**: Sistema especializado que diferencia pessoas físicas e jurídicas
- 💳 **Múltiplos Pagamentos**: Suporte a várias formas de pagamento por pedido (cartão + PIX, etc.)
- 📦 **Rastreamento Completo**: Sistema de entrega com código de rastreio e status detalhado
- 📊 **Análises Avançadas**: 12+ queries complexas para insights de negócio
- 🔍 **Performance Otimizada**: Índices estratégicos e views pré-calculadas
- 🏗️ **Integridade Total**: Constraints robustas garantindo consistência dos dados
- 🔧 **Automação**: Triggers para timestamp automático, validações e auditoria

## 🎯 Refinamentos Implementados

### 1. **Especialização de Clientes** 
```sql
-- Um cliente é PF OU PJ, nunca ambos
CONSTRAINT chk_cliente_pf CHECK (
    (tipo_cliente = 'PF' AND cpf IS NOT NULL AND cnpj IS NULL) OR
    (tipo_cliente = 'PJ' AND cnpj IS NOT NULL AND cpf IS NULL)
)
```

### 2. **Sistema de Pagamento Flexível**
- Relacionamento N:M entre Pedidos e Formas de Pagamento
- Permite dividir pagamento (ex: R$ 500 no cartão + R$ 300 no PIX)
- Status individual para cada transação

### 3. **Controle de Entregas Avançado**
- Código de rastreio único obrigatório
- 6 status possíveis: Preparando → Em Trânsito → Entregue
- Integração com múltiplas transportadoras
- Datas previstas vs. reais para análise de performance

### 4. **Sistema de Triggers e Automação**
- **Timestamp Automático**: Atualização de `data_ultima_atualizacao` no estoque
- **Validação**: Impede quantidades negativas automaticamente
- **Auditoria**: Log de todas as alterações em produtos
- **Integridade**: Verificações automáticas antes de modificações

## 🚀 Início Rápido

### **Opção 1: Setup Automático (Recomendado)**
```bash
# Clone o repositório
git clone https://github.com/SEU-USUARIO/ecommerce-database-project.git
cd ecommerce-database-project

# Execute o script automático
chmod +x scripts/setup-database.sh
./scripts/setup-database.sh
```

### **Opção 2: Manual Completo**
```bash
# Criar banco
createdb ecommerce

# Executar script principal (inclui tudo)
psql -d ecommerce -f database/full-script.sql

# Verificar instalação
psql -d ecommerce -c "SELECT COUNT(*) as tabelas FROM information_schema.tables WHERE table_schema = 'public';"
```

### **Opção 3: Por Componentes**
```bash
# Executar arquivos separadamente
psql -d ecommerce -f database/schema/01-create-tables.sql  # Estrutura
psql -d ecommerce -f database/schema/03-triggers.sql      # Triggers
psql -d ecommerce -f database/data/01-insert-data.sql     # Dados teste
```

## 📊 Estrutura do Banco de Dados

### **Entidades Principais**
| Tabela | Registros | Relacionamento | Propósito |
|--------|-----------|----------------|-----------|
| **Clientes** | 5 | 1:N → Pedidos | PF/PJ com constraints específicas |
| **Produtos** | 5 | N:M ↔ Fornecedores | Catálogo com categorias hierárquicas |
| **Pedidos** | 5 | N:M ↔ Pagamentos | Vendas com múltiplas formas de pagamento |
| **Entregas** | 4 | 1:1 → Pedidos | Rastreamento completo |
| **Estoque** | 5 | N:1 → Produtos | Controle por vendedor e localização |

### **Relacionamentos Complexos**
- **N:M** Produtos ↔ Fornecedores (com preços específicos)
- **N:M** Pedidos ↔ Formas de Pagamento (pagamento misto)
- **1:N** Categorias (hierarquia de produtos)
- **1:1** Pedidos → Entregas (rastreamento único)

### **Triggers Implementados**
- 🕐 **`trg_update_estoque_timestamp`**: Atualização automática de data/hora
- ✅ **`trg_check_estoque_positivo`**: Validação de quantidade não negativa
- 📋 **`trg_log_produto_changes`**: Auditoria de alterações em produtos

## 📋 Queries de Análise Implementadas

### **Perguntas de Negócio Respondidas:**

1. **"Quantos pedidos foram feitos por cada cliente?"**
   ```sql
   SELECT c.nome, COUNT(p.id_pedido) as total_pedidos
   FROM Clientes c LEFT JOIN Pedidos p ON c.id_cliente = p.id_cliente
   GROUP BY c.nome ORDER BY total_pedidos DESC;
   ```

2. **"Algum vendedor também é fornecedor?"**
   ```sql
   SELECT v.nome, v.cnpj, f.razao_social
   FROM Vendedores v INNER JOIN Fornecedores f ON v.cnpj = f.cnpj;
   ```

3. **"Qual a situação do estoque por fornecedor?"**
   ```sql
   SELECT p.nome, f.nome_fantasia, e.quantidade,
          CASE WHEN e.quantidade > 50 THEN 'Alto'
               WHEN e.quantidade > 10 THEN 'Médio' 
               ELSE 'Baixo' END as nivel
   FROM Produtos p
   JOIN Fornecedor_Produto fp ON p.id_produto = fp.id_produto
   JOIN Fornecedores f ON fp.id_fornecedor = f.id_fornecedor
   LEFT JOIN Estoque e ON p.id_produto = e.id_produto;
   ```

4. **"Performance das transportadoras?"**
   ```sql
   SELECT transportadora,
          COUNT(*) as total_entregas,
          ROUND((COUNT(CASE WHEN status_entrega = 'Entregue' THEN 1 END)::DECIMAL / COUNT(*)) * 100, 2) as taxa_sucesso
   FROM Entregas GROUP BY transportadora;
   ```

5. **"Formas de pagamento mais utilizadas?"**
   ```sql
   SELECT fp.nome, COUNT(pg.id_pagamento) as uso,
          SUM(pg.valor_pagamento) as valor_total
   FROM Formas_Pagamento fp
   JOIN Pagamentos pg ON fp.id_forma_pagamento = pg.id_forma_pagamento
   GROUP BY fp.nome ORDER BY valor_total DESC;
   ```

### **Técnicas SQL Demonstradas:**
- ✅ JOINs complexos (INNER, LEFT, múltiplas tabelas)
- ✅ Subconsultas correlacionadas
- ✅ Agregações condicionais (CASE WHEN + COUNT)
- ✅ Funções de janela e rankings
- ✅ CTEs (Common Table Expressions) 
- ✅ Triggers e funções PL/pgSQL
- ✅ Views materializadas para performance

## 🔧 Triggers e Automação

O sistema utiliza triggers PostgreSQL para automação e integridade:

### **Triggers Ativos:**
- ⏰ **Timestamp Automático**: Atualiza `data_ultima_atualizacao` no estoque
- ✅ **Validação de Estoque**: Impede quantidades negativas automaticamente  
- 📊 **Log de Auditoria**: Registra alterações em produtos para rastreabilidade

### **Arquivos de Triggers:**
- `database/full-script.sql` - Script completo com triggers integrados (recomendado)
- `database/schema/triggers.sql` - Arquivo separado para estudo de triggers

### **Exemplo de Uso:**
```sql
-- O trigger atualiza automaticamente o timestamp
UPDATE Estoque SET quantidade = 100 WHERE id_produto = 1;

-- Verificar que data_ultima_atualizacao foi atualizada
SELECT quantidade, data_ultima_atualizacao FROM Estoque WHERE id_produto = 1;
```

## 📁 Estrutura do Projeto

```
📦 ecommerce-database-project/
├── 📄 README.md                         # Este arquivo
├── 📄 LICENSE                           # Licença MIT
├── 📄 .gitignore                        # Arquivos ignorados
├── 📄 .env.example                      # Configurações de exemplo
├── 📁 database/
│   ├── 📄 full-script.sql              # 🚀 Script completo (execute este)
│   ├── 📁 schema/
│   │   ├── 📄 01-create-tables.sql     # Estrutura das tabelas
│   │   ├── 📄 02-insert-data.sql       # Dados de teste
│   │   └── 📄 03-triggers.sql          # Triggers e funções separados
│   ├── 📁 queries/
│   │   ├── 📄 analysis-queries.sql     # Consultas de análise
│   │   └── 📄 business-reports.sql     # Relatórios de negócio
│   └── 📁 views/
│       ├── 📄 customer-summary.sql     # View resumo de clientes
│       └── 📄 inventory-control.sql    # View controle de estoque
├── 📁 docs/
│   ├── 📄 installation-guide.md        # Guia detalhado de instalação
│   ├── 📄 query-examples.md            # Exemplos de consultas
│   ├── 📄 database-design.md           # Decisões de design
│   └── 📄 triggers-documentation.md    # Documentação dos triggers
├── 📁 scripts/
│   ├── 📄 setup-database.sh            # Setup automático completo
│   ├── 📄 run-tests.sql                # Testes de integridade
│   └── 📄 backup-database.sh           # Script de backup
└── 📁 examples/
    ├── 📄 sample-queries.sql           # Queries de exemplo
    └── 📄 business-scenarios.sql       # Cenários de negócio
```

## 🛠️ Tecnologias Utilizadas

- **PostgreSQL 12+** - SGBD principal com recursos avançados
- **SQL ANSI** - Padrão para máxima compatibilidade
- **PL/pgSQL** - Linguagem procedural para triggers e funções
- **Bash Scripts** - Automação de setup e manutenção
- **Git** - Controle de versão
- **Markdown** - Documentação técnica

## 🎓 Conceitos Demonstrados

### **Modelagem de Dados:**
- ✅ Normalização até 3FN
- ✅ Especialização/Generalização (PF/PJ)
- ✅ Relacionamentos 1:1, 1:N, N:M
- ✅ Hierarquias (categorias de produtos)
- ✅ Integridade referencial completa

### **SQL Avançado:**
- ✅ Queries complexas multi-tabela
- ✅ Subconsultas correlacionadas
- ✅ Funções de janela
- ✅ CTEs (Common Table Expressions)
- ✅ Triggers para automação
- ✅ Views para abstração

### **Otimização:**
- ✅ Índices estratégicos (B-tree, compostos)
- ✅ Views para relatórios frequentes  
- ✅ Triggers para automação
- ✅ Constraints para performance e integridade

### **Análise de Dados:**
- ✅ Agregações complexas (GROUP BY, HAVING)
- ✅ Cálculos de métricas de negócio
- ✅ Análises temporais
- ✅ Rankings e comparações

## 🔍 Casos de Uso

- **📚 Acadêmico**: Projeto de disciplinas de Banco de Dados
- **🏢 Empresarial**: Base para sistemas de e-commerce reais
- **📖 Estudo**: Referência para modelagem e SQL avançado
- **🎯 Portfolio**: Demonstração de skills técnicos em dados

## 📈 Exemplos de Resultados

### **Análise de Clientes VIP:**
```sql
-- Query executada:
SELECT c.nome, COUNT(p.id_pedido) as pedidos, SUM(p.valor_total) as total
FROM Clientes c LEFT JOIN Pedidos p ON c.id_cliente = p.id_cliente
GROUP BY c.nome ORDER BY total DESC;

-- Resultado esperado:
┌─────────────────┬─────────┬──────────┐
│ cliente         │ pedidos │ total    │
├─────────────────┼─────────┼──────────┤
│ Carlos Santos   │ 1       │ 8999.99  │
│ Ana Silva       │ 2       │ 5239.97  │ 
│ Lucia Oliveira  │ 1       │ 229.98   │
└─────────────────┴─────────┴──────────┘
```

### **Performance de Entregas:**
```sql
-- Query executada:
SELECT transportadora, COUNT(*) as entregas,
       ROUND((COUNT(CASE WHEN status_entrega = 'Entregue' THEN 1 END)::DECIMAL / COUNT(*)) * 100, 2) as taxa_sucesso
FROM Entregas GROUP BY transportadora;

-- Resultado esperado:
┌────────────────────┬──────────┬──────────────┐
│ transportadora     │ entregas │ taxa_sucesso │
├────────────────────┼──────────┼──────────────┤
│ Correios           │ 3        │ 66.67        │
│ Transportadora XYZ │ 1        │ 0.00         │
└────────────────────┴──────────┴──────────────┘
```

### **Teste de Triggers:**
```sql
-- Antes da modificação
SELECT quantidade, data_ultima_atualizacao FROM Estoque WHERE id_produto = 1;
-- Resultado: 50 | 2024-01-15 10:00:00

-- Executar update (trigger será acionado)
UPDATE Estoque SET quantidade = 75 WHERE id_produto = 1;

-- Após modificação (timestamp atualizado automaticamente)
SELECT quantidade, data_ultima_atualizacao FROM Estoque WHERE id_produto = 1;
-- Resultado: 75 | 2024-01-15 14:32:15
```

## 🧪 Como Testar

### **Teste Completo:**
```bash
# 1. Setup
./scripts/setup-database.sh

# 2. Executar queries de teste
psql -d ecommerce -f examples/sample-queries.sql

# 3. Testar triggers
psql -d ecommerce -c "UPDATE Estoque SET quantidade = quantidade + 1 WHERE id_produto = 1;"

# 4. Verificar views
psql -d ecommerce -c "SELECT * FROM vw_resumo_clientes LIMIT 3;"
```

### **Validação Rápida:**
```sql
-- Este comando valida se tudo foi instalado corretamente
SELECT 
  'Tabelas' as item, COUNT(*) as quantidade FROM information_schema.tables WHERE table_schema = 'public'
UNION ALL
SELECT 'Clientes', COUNT(*) FROM Clientes
UNION ALL  
SELECT 'Produtos', COUNT(*) FROM Produtos
UNION ALL
SELECT 'Pedidos', COUNT(*) FROM Pedidos
UNION ALL
SELECT 'Triggers', COUNT(*) FROM pg_trigger WHERE tgname LIKE 'trg_%';

-- Resultado esperado: 13 tabelas, 5 clientes, 5 produtos, 5 pedidos, 3+ triggers
```

## 🤝 Como Contribuir

1. **Fork** o projeto
2. **Clone** sua fork: `git clone https://github.com/SEU-USUARIO/ecommerce-database-project.git`
3. **Crie** uma branch: `git checkout -b feature/nova-funcionalidade`
4. **Teste** suas mudanças: `psql -d ecommerce -f seu-arquivo.sql`
5. **Commit**: `git commit -m "feat: adiciona nova análise de vendas"`
6. **Push**: `git push origin feature/nova-funcionalidade`
7. **Abra** um Pull Request


## 📄 Licença

Este projeto está sob a licença MIT. Consulte [LICENSE](LICENSE) para mais informações.

---

<div align="center">

**⭐ Se este projeto te ajudou, considere dar uma estrela! ⭐**

[![GitHub stars](https://img.shields.io/github/stars/SEU-USUARIO/ecommerce-database-project.svg?style=social&label=Star)](https://github.com/Otavio2704/ecommerce-database-project)
[![GitHub forks](https://img.shields.io/github/forks/SEU-USUARIO/ecommerce-database-project.svg?style=social&label=Fork)](https://github.com/Otavio2704/ecommerce-database-project/network)

Desenvolvido com 💻 para aprendizado de Banco de Dados

**Projeto educacional demonstrando conceitos avançados de modelagem, SQL e PostgreSQL**

[🔝 Voltar ao topo](#-e-commerce-database-system)

</div>
