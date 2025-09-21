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
