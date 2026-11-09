CREATE OR REPLACE FUNCTION auditoria.registrar_cambio_cliente()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria.cambios_clientes (operacion, id_cliente, valores_despues)
        VALUES (TG_OP, NEW.id, to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria.cambios_clientes (operacion, id_cliente, valores_antes, valores_despues)
        VALUES (TG_OP, NEW.id, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria.cambios_clientes (operacion, id_cliente, valores_antes)
        VALUES (TG_OP, OLD.id, to_jsonb(OLD));
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

-- Una función nueva la puede ejecutar PUBLIC. Nadie necesita llamarla
-- directamente, y el disparador funciona sin ese privilegio
REVOKE ALL ON FUNCTION auditoria.registrar_cambio_cliente() FROM PUBLIC;

-- Después de cada alta, modificación o baja, una vez por fila
CREATE TRIGGER trg_auditoria_clientes
AFTER INSERT OR UPDATE OR DELETE ON clientes
FOR EACH ROW EXECUTE FUNCTION auditoria.registrar_cambio_cliente();

-- Verificación: el disparador (O = habilitado) y la función
SELECT tgname, tgenabled, tgrelid::regclass FROM pg_trigger WHERE NOT tgisinternal;
SELECT proname, prosecdef, proacl, proconfig FROM pg_proc WHERE proname = 'registrar_cambio_cliente';

-- Primera línea de cada sentencia de la auditoría en la bitácora
SELECT num, linea FROM dba.bitacora
WHERE linea LIKE '%statement:%' AND linea LIKE '%auditoria%'
ORDER BY num;