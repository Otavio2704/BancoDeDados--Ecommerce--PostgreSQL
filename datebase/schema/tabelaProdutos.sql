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
