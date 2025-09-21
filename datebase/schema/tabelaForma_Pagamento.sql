-- Tabela Formas de Pagamento (Refinamento: múltiplas formas)
CREATE TABLE Formas_Pagamento (
    id_forma_pagamento SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao VARCHAR(200),
    ativo BOOLEAN DEFAULT TRUE
);
