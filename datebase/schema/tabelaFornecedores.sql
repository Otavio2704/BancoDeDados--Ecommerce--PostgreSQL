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
