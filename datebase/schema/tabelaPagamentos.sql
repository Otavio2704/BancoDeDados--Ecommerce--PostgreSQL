-- Tabela Pagamentos (Relacionamento N:M com Pedidos)
CREATE TABLE Pagamentos (
    id_pagamento SERIAL PRIMARY KEY,
    id_pedido INTEGER NOT NULL,
    id_forma_pagamento INTEGER NOT NULL,
    valor_pagamento DECIMAL(10,2) NOT NULL,
    status_pagamento VARCHAR(15) CHECK (status_pagamento IN ('Pendente', 'Aprovado', 'Rejeitado', 'Cancelado')) DEFAULT 'Pendente',
    data_pagamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dados_transacao TEXT,
    
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido),
    FOREIGN KEY (id_forma_pagamento) REFERENCES Formas_Pagamento(id_forma_pagamento)
);
