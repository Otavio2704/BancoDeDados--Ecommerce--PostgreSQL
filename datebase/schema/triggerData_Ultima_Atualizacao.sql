CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_ultima_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_estoque_timestamp
    BEFORE UPDATE ON Estoque
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();
