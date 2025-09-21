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
