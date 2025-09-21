-- =====================================================
-- SISTEMA E-COMMERCE - MODELAGEM LÓGICA DE BANCO DE DADOS
-- VERSÃO POSTGRESQL
-- =====================================================

-- Criação do esquema do banco de dados
-- No PostgreSQL, você cria o database fora do script ou usa um existente
-- CREATE DATABASE ecommerce;
-- \c ecommerce;

-- =====================================================
-- CRIAÇÃO DAS TABELAS
-- =====================================================

-- Tabela Clientes (com refinamento PJ/PF)
CREATE TABLE Clientes (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    tipo_cliente VARCHAR(2) CHECK (tipo_cliente IN ('PF', 'PJ')) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Campos específicos para Pessoa Física
    cpf CHAR(11) UNIQUE,
    data_nascimento DATE,
    
    -- Campos específicos para Pessoa Jurídica
    cnpj CHAR(14) UNIQUE,
    razao_social VARCHAR(150),
    inscricao_estadual VARCHAR(20),
    
    -- Constraints para garantir integridade PF/PJ
    CONSTRAINT chk_cliente_pf CHECK (
        (tipo_cliente = 'PF' AND cpf IS NOT NULL AND cnpj IS NULL AND razao_social IS NULL AND inscricao_estadual IS NULL) OR
        (tipo_cliente = 'PJ' AND cnpj IS NOT NULL AND cpf IS NULL AND data_nascimento IS NULL)
    )
);

-- Tabela Endereços
CREATE TABLE Enderecos (
    id_endereco SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    tipo_endereco VARCHAR(20) CHECK (tipo_endereco IN ('Residencial', 'Comercial', 'Entrega')) NOT NULL,
    logradouro VARCHAR(200) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(100),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado CHAR(2) NOT NULL,
    cep CHAR(8) NOT NULL,
    
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente) ON DELETE CASCADE
);

-- Tabela Categorias
CREATE TABLE Categorias (
    id_categoria SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    categoria_pai INTEGER,
    
    FOREIGN KEY (categoria_pai) REFERENCES Categorias(id_categoria)
);

-- Tabela Fornecedores
CREATE TABLE Fornecedores (
    id_fornecedor SERIAL PRIMARY KEY,
    razao_social VARCHAR(150) NOT NULL,
    nome_fantasia VARCHAR(100),
    cnpj CHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100),
    telefone VARCHAR(20),
    contato_responsavel VARCHAR(100)
);

-- Tabela Produtos
CREATE TABLE Produtos (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    id_categoria INTEGER,
    peso DECIMAL(8,3),
    dimensoes VARCHAR(50),
    status_produto VARCHAR(15) CHECK (status_produto IN ('Ativo', 'Inativo', 'Descontinuado')) DEFAULT 'Ativo',
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria),
    CONSTRAINT chk_preco_positivo CHECK (preco > 0)
);

-- Tabela Fornecedor_Produto (Relacionamento N:M)
CREATE TABLE Fornecedor_Produto (
    id_fornecedor INTEGER,
    id_produto INTEGER,
    preco_fornecimento DECIMAL(10,2),
    prazo_entrega_dias INTEGER,
    data_inicio_fornecimento DATE,
    
    PRIMARY KEY (id_fornecedor, id_produto),
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedores(id_fornecedor),
    FOREIGN KEY (id_produto) REFERENCES Produtos(id_produto)
);

-- Tabela Vendedores (Terceiros)
CREATE TABLE Vendedores (
    id_vendedor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefone VARCHAR(20),
    cpf CHAR(11) UNIQUE,
    cnpj CHAR(14) UNIQUE,
    taxa_comissao DECIMAL(5,2) DEFAULT 5.00,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_documento_vendedor CHECK (cpf IS NOT NULL OR cnpj IS NOT NULL)
);

-- Tabela Estoque
CREATE TABLE Estoque (
    id_estoque SERIAL PRIMARY KEY,
    id_produto INTEGER NOT NULL,
    id_vendedor INTEGER,
    quantidade INTEGER NOT NULL DEFAULT 0,
    localizacao VARCHAR(100),
    data_ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_produto) REFERENCES Produtos(id_produto),
    FOREIGN KEY (id_vendedor) REFERENCES Vendedores(id_vendedor),
    CONSTRAINT chk_quantidade_positiva CHECK (quantidade >= 0)
);

-- Trigger para atualizar data_ultima_atualizacao automaticamente
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_ultima_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_estoque_timestamp
    BEFORE UPDATE ON Estoque
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

-- Tabela Pedidos
CREATE TABLE Pedidos (
    id_pedido SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    id_vendedor INTEGER,
    status_pedido VARCHAR(25) CHECK (status_pedido IN ('Aguardando Pagamento', 'Processando', 'Enviado', 'Entregue', 'Cancelado')) DEFAULT 'Aguardando Pagamento',
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10,2),
    desconto DECIMAL(10,2) DEFAULT 0.00,
    
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    FOREIGN KEY (id_vendedor) REFERENCES Vendedores(id_vendedor)
);

-- Tabela Itens do Pedido
CREATE TABLE Itens_Pedido (
    id_pedido INTEGER,
    id_produto INTEGER,
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    desconto_item DECIMAL(10,2) DEFAULT 0.00,
    
    PRIMARY KEY (id_pedido, id_produto),
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_produto) REFERENCES Produtos(id_produto),
    CONSTRAINT chk_quantidade_item_positiva CHECK (quantidade > 0)
);

-- Tabela Formas de Pagamento (Refinamento: múltiplas formas)
CREATE TABLE Formas_Pagamento (
    id_forma_pagamento SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao VARCHAR(200),
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela Pagamentos (Relacionamento N:M com Pedidos)
CREATE TABLE Pagamentos (
    id_pagamento SERIAL PRIMARY KEY,
    id_pedido INTEGER NOT NULL,
    id_forma_pagamento INTEGER NOT NULL,
    valor_pagamento DECIMAL(10,2) NOT NULL,
    status_pagamento VARCHAR(15) CHECK (status_pagamento IN ('Pendente', 'Aprovado', 'Rejeitado', 'Cancelado')) DEFAULT 'Pendente',
    data_pagamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dados_transacao TEXT,
    
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido),
    FOREIGN KEY (id_forma_pagamento) REFERENCES Formas_Pagamento(id_forma_pagamento)
);

-- Tabela Entregas (Refinamento: status e código de rastreio)
CREATE TABLE Entregas (
    id_entrega SERIAL PRIMARY KEY,
    id_pedido INTEGER NOT NULL UNIQUE,
    id_endereco_entrega INTEGER NOT NULL,
    codigo_rastreio VARCHAR(50) UNIQUE,
    transportadora VARCHAR(100),
    status_entrega VARCHAR(25) CHECK (status_entrega IN ('Preparando', 'Em Trânsito', 'Saiu para Entrega', 'Entregue', 'Tentativa de Entrega', 'Devolvido')) DEFAULT 'Preparando',
    data_envio TIMESTAMP,
    data_entrega_prevista DATE,
    data_entrega_real TIMESTAMP,
    valor_frete DECIMAL(8,2),
    observacoes TEXT,
    
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido),
    FOREIGN KEY (id_endereco_entrega) REFERENCES Enderecos(id_endereco)
);

-- =====================================================
-- INSERÇÃO DE DADOS DE TESTE
-- =====================================================

-- Inserir Categorias
INSERT INTO Categorias (nome, descricao) VALUES 
('Eletrônicos', 'Produtos eletrônicos e tecnológicos'),
('Roupas', 'Vestuário e acessórios'),
('Casa e Jardim', 'Produtos para casa e jardim'),
('Livros', 'Livros e materiais educacionais'),
('Esportes', 'Artigos esportivos e fitness');

-- Inserir subcategorias
INSERT INTO Categorias (nome, descricao, categoria_pai) VALUES 
('Smartphones', 'Telefones celulares', 1),
('Laptops', 'Computadores portáteis', 1),
('Roupas Masculinas', 'Vestuário masculino', 2),
('Roupas Femininas', 'Vestuário feminino', 2);

-- Inserir Fornecedores
INSERT INTO Fornecedores (razao_social, nome_fantasia, cnpj, email, telefone, contato_responsavel) VALUES 
('Tech Distribuidor LTDA', 'TechDist', '12345678000191', 'contato@techdist.com', '11987654321', 'João Silva'),
('Moda Brasil S.A.', 'ModaBR', '98765432000112', 'vendas@modabr.com', '11876543210', 'Maria Santos'),
('Casa Lar Fornecimentos', 'CasaLar', '45678912000133', 'pedidos@casalar.com', '11765432109', 'Pedro Costa');

-- Inserir Clientes PF
INSERT INTO Clientes (nome, email, telefone, tipo_cliente, cpf, data_nascimento) VALUES 
('Ana Silva', 'ana.silva@email.com', '11999888777', 'PF', '12345678901', '1985-05-15'),
('Carlos Santos', 'carlos.santos@email.com', '11888777666', 'PF', '98765432102', '1990-03-22'),
('Lucia Oliveira', 'lucia.oliveira@email.com', '11777666555', 'PF', '45678912303', '1988-11-08');

-- Inserir Clientes PJ
INSERT INTO Clientes (nome, email, telefone, tipo_cliente, cnpj, razao_social, inscricao_estadual) VALUES 
('Empresa ABC', 'contato@empresaabc.com', '1133334444', 'PJ', '11222333000144', 'ABC Comercio LTDA', '123456789'),
('Loja XYZ', 'pedidos@lojaxyz.com', '1144445555', 'PJ', '55666777000155', 'XYZ Varejo S.A.', '987654321');

-- Inserir Endereços
INSERT INTO Enderecos (id_cliente, tipo_endereco, logradouro, numero, bairro, cidade, estado, cep) VALUES 
(1, 'Residencial', 'Rua das Flores', '123', 'Centro', 'São Paulo', 'SP', '01234567'),
(2, 'Residencial', 'Av. Paulista', '456', 'Bela Vista', 'São Paulo', 'SP', '01310100'),
(3, 'Comercial', 'Rua Augusta', '789', 'Consolação', 'São Paulo', 'SP', '01305100'),
(4, 'Comercial', 'Rua Oscar Freire', '321', 'Jardins', 'São Paulo', 'SP', '01426001'),
(5, 'Comercial', 'Av. Faria Lima', '654', 'Itaim Bibi', 'São Paulo', 'SP', '04538132');

-- Inserir Vendedores
INSERT INTO Vendedores (nome, email, telefone, cpf, taxa_comissao) VALUES 
('Vendedor Silva', 'vendedor1@empresa.com', '11555666777', '11122233344', 7.50),
('Maria Vendedora', 'maria.v@empresa.com', '11444555666', '55566677788', 6.00);

-- Inserir Produtos
INSERT INTO Produtos (nome, descricao, preco, id_categoria, peso, dimensoes) VALUES 
('iPhone 15', 'Smartphone Apple iPhone 15 128GB', 4999.99, 6, 0.171, '14.76 x 7.15 x 0.78 cm'),
('MacBook Air M2', 'MacBook Air 13" com chip M2', 8999.99, 7, 1.24, '30.41 x 21.24 x 1.13 cm'),
('Camiseta Polo', 'Camiseta Polo Masculina 100% Algodão', 89.99, 8, 0.2, 'P/M/G/GG'),
('Vestido Floral', 'Vestido Feminino Estampa Floral', 149.99, 9, 0.3, 'P/M/G/GG'),
('Mesa de Jantar', 'Mesa de Jantar 6 Lugares', 899.99, 3, 25.0, '160x90x75 cm');

-- Relacionar Fornecedores com Produtos
INSERT INTO Fornecedor_Produto (id_fornecedor, id_produto, preco_fornecimento, prazo_entrega_dias) VALUES 
(1, 1, 4200.00, 5),
(1, 2, 7500.00, 7),
(2, 3, 45.00, 3),
(2, 4, 89.00, 3),
(3, 5, 650.00, 15);

-- Inserir Estoque
INSERT INTO Estoque (id_produto, id_vendedor, quantidade, localizacao) VALUES 
(1, 1, 50, 'Depósito A1'),
(2, 1, 20, 'Depósito A1'),
(3, 2, 100, 'Depósito B2'),
(4, 2, 75, 'Depósito B2'),
(5, NULL, 10, 'Depósito Central');

-- Inserir Formas de Pagamento
INSERT INTO Formas_Pagamento (nome, descricao) VALUES 
('Cartão de Crédito', 'Pagamento com cartão de crédito'),
('Cartão de Débito', 'Pagamento com cartão de débito'),
('PIX', 'Transferência instantânea PIX'),
('Boleto Bancário', 'Pagamento via boleto bancário'),
('Dinheiro', 'Pagamento em espécie');

-- Inserir Pedidos
INSERT INTO Pedidos (id_cliente, id_vendedor, status_pedido, valor_total, desconto) VALUES 
(1, 1, 'Entregue', 5089.98, 50.00),
(2, 1, 'Enviado', 8999.99, 0.00),
(3, 2, 'Processando', 239.98, 10.00),
(4, NULL, 'Aguardando Pagamento', 899.99, 0.00),
(1, 2, 'Entregue', 149.99, 0.00);

-- Inserir Itens dos Pedidos
INSERT INTO Itens_Pedido (id_pedido, id_produto, quantidade, preco_unitario, desconto_item) VALUES 
(1, 1, 1, 4999.99, 0.00),
(1, 3, 1, 89.99, 0.00),
(2, 2, 1, 8999.99, 0.00),
(3, 3, 1, 89.99, 0.00),
(3, 4, 1, 149.99, 10.00),
(4, 5, 1, 899.99, 0.00),
(5, 4, 1, 149.99, 0.00);

-- Inserir Pagamentos
INSERT INTO Pagamentos (id_pedido, id_forma_pagamento, valor_pagamento, status_pagamento) VALUES 
(1, 1, 3000.00, 'Aprovado'),
(1, 3, 2039.98, 'Aprovado'),
(2, 1, 8999.99, 'Aprovado'),
(3, 3, 229.98, 'Aprovado'),
(5, 2, 149.99, 'Aprovado');

-- Inserir Entregas
INSERT INTO Entregas (id_pedido, id_endereco_entrega, codigo_rastreio, transportadora, status_entrega, data_envio, data_entrega_prevista, valor_frete) VALUES 
(1, 1, 'BR123456789', 'Correios', 'Entregue', '2024-01-15 10:00:00', '2024-01-17', 15.90),
(2, 2, 'BR987654321', 'Transportadora XYZ', 'Em Trânsito', '2024-01-20 14:30:00', '2024-01-25', 25.50),
(3, 3, 'BR456789123', 'Correios', 'Saiu para Entrega', '2024-01-22 09:15:00', '2024-01-24', 12.80),
(5, 1, 'BR789123456', 'Correios', 'Entregue', '2024-01-10 11:20:00', '2024-01-12', 8.90);

-- =====================================================
-- QUERIES COMPLEXAS PARA ANÁLISE DE DADOS
-- =====================================================

-- 1. RECUPERAÇÕES SIMPLES COM SELECT
-- Pergunta: Quais são todos os produtos disponíveis com seus preços?
SELECT nome, preco, status_produto 
FROM Produtos 
WHERE status_produto = 'Ativo';

-- 2. FILTROS COM WHERE
-- Pergunta: Quais clientes são Pessoa Jurídica e estão localizados em São Paulo?
SELECT c.nome, c.email, c.razao_social, e.cidade 
FROM Clientes c
JOIN Enderecos e ON c.id_cliente = e.id_cliente
WHERE c.tipo_cliente = 'PJ' AND e.cidade = 'São Paulo';

-- 3. EXPRESSÕES PARA ATRIBUTOS DERIVADOS
-- Pergunta: Qual o valor total de cada pedido considerando descontos?
SELECT 
    p.id_pedido,
    c.nome AS cliente,
    p.valor_total,
    p.desconto,
    (p.valor_total - p.desconto) AS valor_final,
    CASE 
        WHEN p.desconto > 0 THEN ROUND((p.desconto / p.valor_total) * 100, 2)
        ELSE 0 
    END AS percentual_desconto
FROM Pedidos p
JOIN Clientes c ON p.id_cliente = c.id_cliente;

-- 4. ORDENAÇÃO COM ORDER BY
-- Pergunta: Quais são os produtos mais caros do catálogo?
SELECT nome, preco, id_categoria
FROM Produtos 
WHERE status_produto = 'Ativo'
ORDER BY preco DESC, nome ASC;

-- 5. CONDIÇÕES DE FILTRO COM HAVING
-- Pergunta: Quais clientes fizeram pedidos com valor total superior a R$ 1000?
SELECT 
    c.nome,
    c.tipo_cliente,
    COUNT(p.id_pedido) as total_pedidos,
    SUM(p.valor_total) as valor_total_compras,
    AVG(p.valor_total) as ticket_medio
FROM Clientes c
JOIN Pedidos p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nome, c.tipo_cliente
HAVING SUM(p.valor_total) > 1000
ORDER BY valor_total_compras DESC;

-- 6. JUNÇÕES COMPLEXAS ENTRE TABELAS
-- Pergunta: Quantos pedidos foram feitos por cada cliente e qual o status de entrega?
SELECT 
    c.nome AS cliente,
    c.tipo_cliente,
    COUNT(DISTINCT p.id_pedido) as total_pedidos,
    SUM(p.valor_total) as valor_total,
    STRING_AGG(DISTINCT p.status_pedido, ', ') as status_pedidos,
    STRING_AGG(DISTINCT e.status_entrega, ', ') as status_entregas
FROM Clientes c
LEFT JOIN Pedidos p ON c.id_cliente = p.id_cliente
LEFT JOIN Entregas e ON p.id_pedido = e.id_pedido
GROUP BY c.id_cliente, c.nome, c.tipo_cliente
ORDER BY total_pedidos DESC;

-- 7. VERIFICAÇÃO: ALGUM VENDEDOR TAMBÉM É FORNECEDOR?
-- Pergunta: Existe algum vendedor que também atua como fornecedor?
SELECT 
    v.nome as vendedor_nome,
    v.cnpj as vendedor_cnpj,
    f.razao_social as fornecedor_razao_social,
    f.cnpj as fornecedor_cnpj
FROM Vendedores v
INNER JOIN Fornecedores f ON v.cnpj = f.cnpj
WHERE v.cnpj IS NOT NULL;

-- 8. RELAÇÃO DE PRODUTOS, FORNECEDORES E ESTOQUES
-- Pergunta: Qual a situação do estoque por produto e fornecedor?
SELECT 
    p.nome as produto,
    f.nome_fantasia as fornecedor,
    fp.preco_fornecimento,
    e.quantidade as quantidade_estoque,
    e.localizacao,
    CASE 
        WHEN e.quantidade > 50 THEN 'Alto'
        WHEN e.quantidade BETWEEN 11 AND 50 THEN 'Médio'
        WHEN e.quantidade BETWEEN 1 AND 10 THEN 'Baixo'
        ELSE 'Sem Estoque'
    END as nivel_estoque
FROM Produtos p
LEFT JOIN Fornecedor_Produto fp ON p.id_produto = fp.id_produto
LEFT JOIN Fornecedores f ON fp.id_fornecedor = f.id_fornecedor
LEFT JOIN Estoque e ON p.id_produto = e.id_produto
ORDER BY p.nome, f.nome_fantasia;

-- 9. RELAÇÃO DE NOMES DOS FORNECEDORES E PRODUTOS
-- Pergunta: Quais produtos cada fornecedor oferece e a que preço?
SELECT 
    f.razao_social as fornecedor,
    f.nome_fantasia,
    p.nome as produto,
    p.preco as preco_venda,
    fp.preco_fornecimento,
    (p.preco - fp.preco_fornecimento) as margem_lucro,
    ROUND(((p.preco - fp.preco_fornecimento) / p.preco) * 100, 2) as percentual_margem
FROM Fornecedores f
JOIN Fornecedor_Produto fp ON f.id_fornecedor = fp.id_fornecedor
JOIN Produtos p ON fp.id_produto = p.id_produto
ORDER BY f.nome_fantasia, p.nome;

-- 10. ANÁLISE DE FORMAS DE PAGAMENTO POR PEDIDO
-- Pergunta: Quais são as formas de pagamento mais utilizadas e seus valores?
SELECT 
    fp.nome as forma_pagamento,
    COUNT(pg.id_pagamento) as total_transacoes,
    SUM(pg.valor_pagamento) as valor_total,
    AVG(pg.valor_pagamento) as valor_medio,
    COUNT(CASE WHEN pg.status_pagamento = 'Aprovado' THEN 1 END) as transacoes_aprovadas
FROM Formas_Pagamento fp
LEFT JOIN Pagamentos pg ON fp.id_forma_pagamento = pg.id_forma_pagamento
GROUP BY fp.id_forma_pagamento, fp.nome
HAVING COUNT(pg.id_pagamento) > 0
ORDER BY valor_total DESC;

-- 11. ANÁLISE TEMPORAL DE PEDIDOS
-- Pergunta: Como está a distribuição de pedidos ao longo do tempo?
SELECT 
    TO_CHAR(data_pedido, 'YYYY-MM') as mes_ano,
    COUNT(*) as total_pedidos,
    SUM(valor_total) as faturamento_mes,
    AVG(valor_total) as ticket_medio_mes,
    MIN(valor_total) as menor_pedido,
    MAX(valor_total) as maior_pedido
FROM Pedidos
GROUP BY TO_CHAR(data_pedido, 'YYYY-MM')
ORDER BY mes_ano;

-- 12. ANÁLISE DE PERFORMANCE DE ENTREGAS
-- Pergunta: Qual a performance das transportadoras nas entregas?
SELECT 
    transportadora,
    COUNT(*) as total_entregas,
    AVG(valor_frete) as frete_medio,
    COUNT(CASE WHEN status_entrega = 'Entregue' THEN 1 END) as entregas_concluidas,
    COUNT(CASE WHEN status_entrega IN ('Em Trânsito', 'Saiu para Entrega') THEN 1 END) as entregas_pendentes,
    ROUND((COUNT(CASE WHEN status_entrega = 'Entregue' THEN 1 END)::DECIMAL / COUNT(*)) * 100, 2) as taxa_sucesso
FROM Entregas
GROUP BY transportadora
ORDER BY taxa_sucesso DESC;

-- =====================================================
-- VIEWS ÚTEIS PARA RELATÓRIOS
-- =====================================================

-- View para Resumo de Clientes
CREATE VIEW vw_resumo_clientes AS
SELECT 
    c.id_cliente,
    c.nome,
    c.email,
    c.tipo_cliente,
    COUNT(DISTINCT p.id_pedido) as total_pedidos,
    COALESCE(SUM(p.valor_total), 0) as valor_total_compras,
    COALESCE(AVG(p.valor_total), 0) as ticket_medio
FROM Clientes c
LEFT JOIN Pedidos p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nome, c.email, c.tipo_cliente;

-- View para Controle de Estoque
CREATE VIEW vw_controle_estoque AS
SELECT 
    p.id_produto,
    p.nome as produto,
    cat.nome as categoria,
    e.quantidade,
    e.localizacao,
    v.nome as vendedor_responsavel,
    CASE 
        WHEN e.quantidade = 0 THEN 'CRÍTICO'
        WHEN e.quantidade <= 10 THEN 'BAIXO'
        WHEN e.quantidade <= 50 THEN 'MÉDIO'
        ELSE 'ALTO'
    END as nivel_estoque
FROM Produtos p
LEFT JOIN Estoque e ON p.id_produto = e.id_produto
LEFT JOIN Categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN Vendedores v ON e.id_vendedor = v.id_vendedor;

-- =====================================================
-- ÍNDICES PARA OTIMIZAÇÃO DE PERFORMANCE
-- =====================================================

CREATE INDEX idx_clientes_email ON Clientes(email);
CREATE INDEX idx_clientes_cpf ON Clientes(cpf);
CREATE INDEX idx_clientes_cnpj ON Clientes(cnpj);
CREATE INDEX idx_pedidos_data ON Pedidos(data_pedido);
CREATE INDEX idx_pedidos_status ON Pedidos(status_pedido);
CREATE INDEX idx_produtos_categoria ON Produtos(id_categoria);
CREATE INDEX idx_entregas_status ON Entregas(status_entrega);
CREATE INDEX idx_entregas_codigo ON Entregas(codigo_rastreio);
