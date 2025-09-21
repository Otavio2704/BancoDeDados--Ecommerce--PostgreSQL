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
