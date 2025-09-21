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
