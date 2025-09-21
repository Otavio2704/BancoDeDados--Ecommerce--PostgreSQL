CREATE INDEX idx_clientes_email ON Clientes(email);
CREATE INDEX idx_clientes_cpf ON Clientes(cpf);
CREATE INDEX idx_clientes_cnpj ON Clientes(cnpj);
CREATE INDEX idx_pedidos_data ON Pedidos(data_pedido);
CREATE INDEX idx_pedidos_status ON Pedidos(status_pedido);
CREATE INDEX idx_produtos_categoria ON Produtos(id_categoria);
CREATE INDEX idx_entregas_status ON Entregas(status_entrega);
CREATE INDEX idx_entregas_codigo ON Entregas(codigo_rastreio);
