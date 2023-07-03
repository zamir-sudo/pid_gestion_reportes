--Base de datos reportes de incidencias
CREATE TABLE grupo_trabajo
(
    id_grupo_trabajo SMALLINT PRIMARY KEY,
    nombre_grupo_trabajo VARCHAR(50),
    horas_de_trabajo VARCHAR(3)
);

CREATE TABLE operador
(
    codigo_operador VARCHAR(10) PRIMARY KEY,
    nombre_op VARCHAR(50),
    apellidos_op VARCHAR(150),
    credencial_op VARCHAR(10),
    color_credencial_op VARCHAR(15),
    estado BIT,
    id_grupo_trabajo SMALLINT,
    CONSTRAINT FK_GRUPO FOREIGN KEY(id_grupo_trabajo) REFERENCES grupo_trabajo(id_grupo_trabajo)
);

CREATE TABLE tipo_reporte
(
    id_tipo SMALLINT PRIMARY KEY,
    nombre_tipo_reporte VARCHAR(50)
);

CREATE TABLE reporte
(
    id_reporte BIGSERIAL PRIMARY KEY,
    nombre_reporte VARCHAR(250),
    descripcion_reporte TEXT,
    hora_reporte TIME,
    fecha_reporte DATE,
    lugar_reporte VARCHAR(255),
    link_multimedia VARCHAR(255),
    id_tipo SMALLINT,
    codigo_operador VARCHAR(10),
    CONSTRAINT FK_TIPO FOREIGN KEY(id_tipo) REFERENCES tipo_reporte(id_tipo),
    CONSTRAINT FK_OPERADOR FOREIGN KEY(codigo_operador) REFERENCES operador(codigo_operador)
);
------------------------------------------------------------------------------------------------
------------ ESPECIALIZACION GENERALIZACION-----------------------------------------------------

CREATE TABLE implicado
(
    id_implicado BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    apellidos VARCHAR(250),
    credencial VARCHAR(10),
    color_credencial VARCHAR(15)
);

CREATE TABLE infractor
(
    id_implicado BIGINT PRIMARY KEY,
    filial VARCHAR(150),
    CONSTRAINT FK_IMPLICADO FOREIGN KEY(id_implicado) REFERENCES implicado(id_implicado)
);

CREATE TABLE responsable
(
    id_implicado BIGINT PRIMARY KEY,
    cargo VARCHAR(150),
    CONSTRAINT FK_IMPLICADO FOREIGN KEY(id_implicado) REFERENCES implicado(id_implicado)
);
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

---------------RELACION M:N ENTRE REPORTE E IMPLICADO-------------------------------------------
CREATE TABLE reporte_implicado
(
    id_reporte BIGINT,
    id_implicado BIGINT,
    CONSTRAINT PK_REPORTE_IMPLICADO PRIMARY KEY(id_reporte, id_implicado),
    CONSTRAINT FK_REPORTE FOREIGN KEY(id_reporte) REFERENCES reporte(id_reporte),
    CONSTRAINT FK_IMPLICADO FOREIGN KEY(id_implicado) REFERENCES implicado(id_implicado)
);

------PRUEBAS CON ALGUNOS DATOS
INSERT INTO grupo_trabajo values
(1, 'Area 1'),
(2, 'Area 2'),
(3, 'Area 3'),
(4, 'Area 4'),
(5, 'Operaciones de 8h');

INSERT INTO tipo_reporte values
(1, 'incidencia'),
(2, 'Vulnerabilidad'),
(3, 'Indicio'),
(4, 'Delito');

INSERT INTO operador values
('A1000', 'Alberto', 'Perez Perez', 'AE0010', 'Azul', '1', 1),
('A1001', 'Carlos', 'Alfonzo Perez', 'A02010', 'Azul', '1', 1),
('A1002', 'Juan', 'Sebastian Perez', 'AE5010', 'Naranja', '1', 1),
('A2000', 'Jhony', 'Azteca Ramon', 'A80010', 'Azul', '1', 2),
('A2001', 'Pedro', 'Cartaza Ramon', 'A00010', 'Naranja', '1', 2),
('A2002', 'Maria', 'Teresa Carrasco', 'A30010', 'Verde', '1', 2);

INSERT INTO reporte(nombre_reporte, descripcion_reporte, hora_reporte, fecha_reporte, lugar_reporte, link_multimedia, id_tipo, codigo_operador) values
('Incidencia 1', ' descripcion de la incidencia 1...', '00:05:25', '12-02-2022', 'Hueco de llegada', '', 1, 'A1000'),
('Incidencia 2', ' descripcion de la incidencia 2...', '01:25:00', '12-02-2022', 'Hueco de salida', '', 1, 'A1000'),
('Incidencia 3', ' descripcion de la incidencia 3...', '05:40:10', '12-02-2022', 'Huecos', '', 1, 'A1000'),
('Incidencia 4', ' descripcion de la incidencia 4...', '02:05:25', '12-02-2022', 'planta', '', 1, 'A2000'),
('Incidencia 5', ' descripcion de la incidencia 5...', '03:05:25', '12-02-2022', 'Rampa', '', 1, 'A1000');

INSERT INTO implicado(nombre, apellidos, credencial, color_credencial) values
('Alfonso', 'Rod Rofr', 'AE2555', 'Azul'),
('MAriano', 'Perfr Rofr', 'Ae2500', 'Azul'),
('Judith', 'Carina defrr', 'AE2055', 'Azul'),
('LAurebn', 'Garcia Petroph', 'AEfr55', 'Verde'),
('Lampierf', 'efrgf Rogtrhgfr', 'AE2005', 'NAranja');

INSERT INTO infractor values
(1, 'Manipulador T3'),
(4, 'Asistente limp T3'),
(5, 'Manipulador T2');

INSERT INTO responsable values
(2, 'Jefe de manipuladores'),
(3, 'J 28 Mabel');

INSERT INTO reporte_implicado values
(1, 1 ),
(1, 2 ),
(1, 3 ),
(2, 4 ),
(2, 1 ),
(2, 3 ),
(3, 5 ),
(3, 3),
(3, 2),
(4, 4),
(4, 3),
(5, 1),
(5, 4),
(5, 2),
(5, 3);

-----------------------------------------------IMPLEMENTACION DEL ------------------------------------------
CREATE OR REPLACE FUNCTION listar_op(grupo integer) returns table
(
    Operador VARCHAR(150),
    Credencial VARCHAR(10),
    color VARCHAR(15),
    Area VARCHAR(15)
) as $$
Declare
    var record;
    puntero cursor(area integer) for SELECT nombre_op || ' '|| apellidos_op as nombres, credencial_op, color_credencial_op, nombre_grupo_trabajo
                                 from operador
                                 inner join grupo_trabajo on grupo_trabajo.id_grupo_trabajo = operador.id_grupo_trabajo
                                 where operador.id_grupo_trabajo = area and operador.estado = '1';
begin
    for var in puntero(grupo) loop
    Operador:= var.nombres;
    Credencial:= var.credencial_op;
    color:= var.color_credencial_op;
    Area:= var.nombre_grupo_trabajo;
    return next;
    end loop;
end
$$ LANGUAGE PLPGSQL;

----------------------------------------------------DESACTIVAR UN OPERADOR--------------------------
CREATE OR REPLACE FUNCTION delete_op(codigo varchar(10)) returns boolean
AS $$
Declare
    succes boolean;
begin
    UPDATE operador set estado = '0' where operador.codigo_operador = codigo;
    IF FOUND THEN
        succes = true;
    ELSE
        succes = false;
    END IF;
    RETURN succes;

end
$$ language plpgsql;

-----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW listar_reportes AS
with operadores as (
    SELECT concat(nombre_op, ' ', apellidos_op, ' ', credencial_op) as Reporta,
    reporte.codigo_operador,
    descripcion_reporte, fecha_reporte,  hora_reporte, lugar_reporte, reporte.id_reporte, reporte.id_tipo, nombre_tipo_reporte from operador
    inner join reporte on reporte.codigo_operador = operador.codigo_operador
    inner join tipo_reporte on reporte.id_tipo = tipo_reporte.id_tipo
),
infractores as(
    SELECT concat(implicado.nombre, ' ', implicado.apellidos, ' ', implicado.credencial) as Infractores, filial, reporte_implicado.id_reporte
    from infractor
    inner join implicado on implicado.id_implicado = infractor.id_implicado
    inner join reporte_implicado on reporte_implicado.id_implicado = implicado.id_implicado
),
responsables as(
    SELECT concat(implicado.nombre, ' ', implicado.apellidos, ' ', implicado.credencial) as Responsables,
    cargo, reporte_implicado.id_reporte from responsable
    inner join implicado on implicado.id_implicado = responsable.id_implicado
    inner join reporte_implicado on reporte_implicado.id_implicado = implicado.id_implicado
)
SELECT operadores.codigo_operador, operadores.reporta, nombre_tipo_reporte, operadores.descripcion_reporte, operadores.fecha_reporte, operadores.hora_reporte, infractores.infractores, filial,
responsables.Responsables, responsables.cargo from operadores
left join infractores on operadores.id_reporte = infractores.id_reporte
left join responsables on responsables.id_reporte = operadores.id_reporte
order by operadores.reporta;
-----------------------------------------------------------------------------
-------------------------------REPORTES EN EL MES----------------------------
CREATE OR REPLACE VIEW listar_reportes_mes AS
with operadores as (
    SELECT concat(nombre_op, ' ', apellidos_op, ' ', credencial_op) as Reporta,
    descripcion_reporte, fecha_reporte,  hora_reporte, lugar_reporte, reporte.id_reporte, reporte.id_tipo, nombre_tipo_reporte from operador
    
    inner join reporte on reporte.codigo_operador = operador.codigo_operador
    inner join tipo_reporte on reporte.id_tipo = tipo_reporte.id_tipo
    where reporte.fecha_reporte > date_trunc('month', current_date)
),
total as (
    SELECT COUNT(operadores.id_reporte) as total, operadores.id_reporte  from operadores
    group by operadores.nombre_tipo_reporte, operadores.id_reporte
),
infractores as(
    SELECT concat(implicado.nombre, ' ', implicado.apellidos, ' ', implicado.credencial) as Infractores, filial, reporte_implicado.id_reporte
    from infractor
    inner join implicado on implicado.id_implicado = infractor.id_implicado
    inner join reporte_implicado on reporte_implicado.id_implicado = implicado.id_implicado
),
responsables as(
    SELECT concat(implicado.nombre, ' ', implicado.apellidos, ' ', implicado.credencial) as Responsables,
    cargo, reporte_implicado.id_reporte from responsable
    inner join implicado on implicado.id_implicado = responsable.id_implicado
    inner join reporte_implicado on reporte_implicado.id_implicado = implicado.id_implicado
)
SELECT operadores.reporta, nombre_tipo_reporte, total, operadores.descripcion_reporte, operadores.fecha_reporte, operadores.hora_reporte, infractores.infractores, filial,
responsables.Responsables, responsables.cargo from operadores
inner join total on total.id_reporte = operadores.id_reporte
left join infractores on operadores.id_reporte = infractores.id_reporte
left join responsables on responsables.id_reporte = operadores.id_reporte
order by operadores.reporta;


-------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION insertar_reporte(nombre varchar(150), descripcion text, hora time, fecha date, lugar varchar(150), link varchar(255), tipo integer, operador varchar(10)) returns integer
AS $$
declare
    id integer;
begin
    INSERT INTO reporte(nombre_reporte, descripcion_reporte, hora_reporte, fecha_reporte, lugar_reporte, link_multimedia, id_tipo, codigo_operador) values
    (nombre, descripcion, hora, fecha, lugar, link, tipo, operador) RETURNING id_reporte into id;
    return id;
end
$$ language plpgsql;
--------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insertar_responsable(nombre varchar(150), apellidos varchar(100), credencial varchar(10), color_credencial varchar(15), cargo varchar(150), reporte_id integer) returns integer
AS $$
declare
    id integer;
begin
    INSERT INTO implicado(nombre, apellidos, credencial, color_credencial) values
    (nombre, apellidos, credencial, color_credencial) returning id_implicado into id;
    INSERT INTO responsable(id_implicado, cargo) values
    (id, cargo);
    INSERT INTO reporte_implicado(id_reporte, id_implicado) values
    (reporte_id, id);
    return id;
end
$$ language plpgsql;
-------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insertar_infractor(nombre varchar(150), apellidos varchar(100), credencial varchar(10), color_credencial varchar(15), filial varchar(150), reporte_id integer) returns integer
AS $$
declare
    id integer;
begin
    INSERT INTO implicado(nombre, apellidos, credencial, color_credencial) values
    (nombre, apellidos, credencial, color_credencial) returning id_implicado into id;

    INSERT INTO infractor(id_implicado, filial) values
    (id, filial);

    INSERT INTO reporte_implicado(id_reporte, id_implicado) values
    (reporte_id, id);

    return id;
end
$$ language plpgsql;
--------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION buscar_reportes(fe date) returns SETOF listar_reportes
AS $$
declare
    registro record;
begin
    for registro in select * from listar_reportes where fecha_reporte = fe
    loop
    return next registro;
    end loop;
end
$$ language plpgsql;
------------------------------SOBRECARGA-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION buscar_reportes(inicio date, fin date) returns setof listar_reportes
AS $$
declare
    registro record;
begin
    for registro in select * from listar_reportes where fecha_reporte between inicio and fin
    loop
    return next registro;
    end loop;
end
$$ language plpgsql;

----------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION buscar_reportes(inicio date, fin date, reporte_tipo varchar(20)) returns setof listar_reportes
AS $$
declare
    registro record;
begin
    for registro in select * from listar_reportes where fecha_reporte between inicio and fin and listar_reportes.nombre_tipo_reporte = reporte_tipo
    loop
    return next registro;
    end loop;
end
$$ language plpgsql;
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION buscar_reportes(inicio date, fin date, reporte_tipo varchar(20), operador varchar(10)) returns setof listar_reportes
AS $$
declare
    registro record;
begin
    for registro in select * from listar_reportes where fecha_reporte between inicio and fin and listar_reportes.nombre_tipo_reporte = reporte_tipo and listar_reportes.codigo_operador = operador
    loop
    return next registro;
    end loop;
end
$$ language plpgsql;
-----------------------------------------------------------------------------------------------------------------------



CREATE OR REPLACE FUNCTION mayor_incidente(grupo integer) returns text
AS $$
declare
    nombre text;
begin
    with conteo as 
    (
        SELECT COUNT(id_reporte) as cont, reporte.codigo_operador from reporte
        inner join operador on operador.codigo_operador = reporte.codigo_operador
        where id_grupo_trabajo = grupo
        group by reporte.codigo_operador
    ),
    suma as 
    (
        SELECT MAX(cont), codigo_operador from conteo
        group by codigo_operador
    )
    SELECT into nombre concat(nombre_op, ' ', apellidos_op) as Operador from operador
    inner join suma on operador.codigo_operador = suma.codigo_operador;

    return nombre;
end
$$ language plpgsql;

---------------------------------------------------------------------------------------------------------------------------------
create or replace function estadistica(tp integer) returns table (Grupo varchar(100), tipo varchar(15), total integer) as
$$
declare
    var record;
    tipo_de varchar(50);
    puntero cursor for select nombre_grupo_trabajo, id_grupo_trabajo from grupo_trabajo;
begin
    select nombre_tipo_reporte into tipo_de from tipo_reporte;
    tipo:= tipo_de;
    for var in puntero loop
    Grupo:= var.nombre_grupo_trabajo;
    select count(id_reporte) into total from reporte
    inner join operador on operador.codigo_operador = reporte.codigo_operador
    where var.id_grupo_trabajo = operador.id_grupo_trabajo and reporte.id_tipo = tp;
    return next;
    end loop;
end
$$ language plpgsql;

--------------------------------------------------------------------------------

create table usuarios_log(
    codigo_operador varchar(15),
    Trabajador varchar(150),
    fecha_agregado timestamp,
    fecha_eliminado timestamp
)

create or replace function actualizar_estado() returns trigger as
$$
Declare

begin
    if (NEW.estado = '1') then
        insert into usuarios_log (codigo_operador, Trabajador, fecha_agregado) values(NEW.codigo_operador, NEW.nombre_op, Current_timestamp);
    ELSE
        update usuarios_log set fecha_eliminado = Current_timestamp where usuarios_log.codigo_operador = OLD.codigo_operador;
    end if;
    return NEW;
end;
$$ language plpgsql;

create trigger control_usuarios after update or insert on operador
for each row
execute function actualizar_estado();

