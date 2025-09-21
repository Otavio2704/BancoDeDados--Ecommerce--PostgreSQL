-- Tabela Categorias
CREATE TABLE Categorias (
    id_categoria SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    categoria_pai INTEGER,
    
    FOREIGN KEY (categoria_pai) REFERENCES Categorias(id_categoria)
);
