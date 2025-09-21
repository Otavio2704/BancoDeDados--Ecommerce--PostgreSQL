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
