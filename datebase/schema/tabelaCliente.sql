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
