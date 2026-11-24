-- =====================================================================
-- Reto Auditoría FEMSA | Etapa 3: Modelo dimensional lógico (PostgreSQL)
-- Se ejecuta en DBeaver sobre las tablas acondicionadas de la Etapa 2:
--     bit_encabezado, bit_dia_acond, conciliacion_mes
-- Constelación de hechos: 2 tablas de hechos que comparten dim_fecha y
-- dim_planta. Todos los volúmenes en litros (bitácora m3 x 1,000).
-- =====================================================================

DROP TABLE IF EXISTS fact_conciliacion_mensual, fact_registros_diarios, dim_planta, dim_fecha;

-- ---------------------------------------------------------------------
-- Creación de tablas
-- ---------------------------------------------------------------------
CREATE TABLE dim_fecha (
    fecha_id DATE,
    anio INTEGER,
    mes INTEGER,
    nombre_mes VARCHAR(50),
    dia INTEGER,
    trimestre INTEGER,
    dias_mes INTEGER,
    CONSTRAINT PK_dim_fecha PRIMARY KEY (fecha_id)
);

CREATE TABLE dim_planta (
    planta_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nombre_planta VARCHAR(50) NOT NULL,
    valor_referencia NUMERIC(20,2),
    usa_riego BOOLEAN,
    limite_pico NUMERIC(20,2)
);

CREATE TABLE fact_registros_diarios (
    fecha_id DATE NOT NULL,
    planta_id INTEGER NOT NULL,
    flujo_efluente NUMERIC(20,2),
    flujo_efluente_anterior NUMERIC(20,2),
    dias_entre_lecturas INTEGER,
    diferencia_reportada_efluente NUMERIC(20,2),
    diferencia_diaria_efluente NUMERIC(20,2),
    descarga_promedio_dia NUMERIC(20,2),
    flujo_riego NUMERIC(20,2),
    diferencia_reportada_riego NUMERIC(20,2),
    diferencia_diaria_riego NUMERIC(20,2),
    flag_sin_lectura INTEGER,
    flag_difiere_reportada INTEGER,
    flag_retroceso INTEGER NOT NULL,
    flag_cero INTEGER NOT NULL,
    flag_duplicado INTEGER NOT NULL,
    flag_pico INTEGER NOT NULL,
    flag_constante INTEGER NOT NULL,
    flag_anomalia INTEGER NOT NULL,
    CONSTRAINT FK_fecha FOREIGN KEY (fecha_id) REFERENCES dim_fecha(fecha_id),
    CONSTRAINT FK_planta FOREIGN KEY (planta_id) REFERENCES dim_planta(planta_id)
);

CREATE TABLE fact_conciliacion_mensual (
    fecha_id DATE NOT NULL,
    planta_id INTEGER NOT NULL,
    periodo VARCHAR(50) NOT NULL,
    dias_con_registro INTEGER NOT NULL,
    dias_faltantes INTEGER NOT NULL,
    descarga_bit_L NUMERIC(20,2),
    rf_original_L NUMERIC(20,2),
    flag_posible_error_unidad INTEGER,
    rf_L NUMERIC(20,2),
    diferencia_L NUMERIC(20,2),
    pct_discrepancia NUMERIC(20,2),
    riego_bit_L NUMERIC(20,2),
    descarga_mas_riego_L NUMERIC(20,2),
    pct_discrepancia_con_riego NUMERIC(20,2),
    dias_cero INTEGER,
    dias_duplicado INTEGER,
    dias_pico INTEGER,
    dias_constante INTEGER,
    dias_anomalos INTEGER,
    pct_dias_anomalos NUMERIC(20,2),
    dias_retroceso INTEGER,
    pct_continuidad NUMERIC(20,2),
    dias_difiere_reportada INTEGER,
    CONSTRAINT FK_fecha_id FOREIGN KEY (fecha_id) REFERENCES dim_fecha(fecha_id),
    CONSTRAINT FK_planta_id FOREIGN KEY (planta_id) REFERENCES dim_planta(planta_id)
);

-- ---------------------------------------------------------------------
-- Inserción de datos
-- ---------------------------------------------------------------------

-- dim_fecha: una fila por día del periodo
INSERT INTO dim_fecha (fecha_id, anio, mes, nombre_mes, dia, trimestre, dias_mes)
SELECT DISTINCT
    to_date(fecha, 'YYYY-MM-DD') AS fecha_id,
    EXTRACT(YEAR FROM to_date(fecha, 'YYYY-MM-DD')) AS anio,
    EXTRACT(MONTH FROM to_date(fecha, 'YYYY-MM-DD')) AS mes,
    to_char(to_date(fecha, 'YYYY-MM-DD'), 'TMMonth') AS nombre_mes,
    EXTRACT(DAY FROM to_date(fecha, 'YYYY-MM-DD')) AS dia,
    EXTRACT(QUARTER FROM to_date(fecha, 'YYYY-MM-DD')) AS trimestre,
    EXTRACT(DAY FROM (date_trunc('month', to_date(fecha, 'YYYY-MM-DD'))
        + INTERVAL '1 MONTH' - INTERVAL '1 DAY')) AS dias_mes
FROM bit_dia_acond
ORDER BY fecha_id;

-- dim_planta: una fila por planta; usa_riego = registró riego en el periodo
INSERT INTO dim_planta (nombre_planta, valor_referencia, usa_riego, limite_pico)
SELECT
    be.planta AS nombre_planta,
    be.limite_diario_m3 * 1000 AS valor_referencia,
    CASE WHEN SUM(COALESCE(bda.riego_calculado, 0)) > 0 THEN true ELSE false END AS usa_riego,
    MAX(bda.limite_pico) * 1000 AS limite_pico
FROM bit_encabezado be
JOIN bit_dia_acond bda ON be.planta = bda.planta
GROUP BY be.planta, be.limite_diario_m3
ORDER BY be.planta;

-- fact_registros_diarios: una fila por planta por día
INSERT INTO fact_registros_diarios (
    fecha_id, planta_id, flujo_efluente, flujo_efluente_anterior, dias_entre_lecturas,
    diferencia_reportada_efluente, diferencia_diaria_efluente, descarga_promedio_dia,
    flujo_riego, diferencia_reportada_riego, diferencia_diaria_riego,
    flag_sin_lectura, flag_difiere_reportada, flag_retroceso, flag_cero,
    flag_duplicado, flag_pico, flag_constante, flag_anomalia
)
SELECT
    to_date(bda.fecha, 'YYYY-MM-DD'),
    dp.planta_id,
    bda.lectura * 1000, bda.lectura_anterior * 1000, bda.dias_entre_lecturas,
    bda.diferencia_reportada * 1000, bda.diferencia_calculada * 1000,
    bda.descarga_promedio_dia * 1000,
    bda.lectura_riego * 1000, bda.diferencia_riego_reportada * 1000,
    bda.riego_calculado * 1000,
    bda.flag_sin_lectura, bda.flag_difiere_reportada, bda.flag_retroceso, bda.flag_cero,
    bda.flag_duplicado, bda.flag_pico, bda.flag_constante, bda.flag_anomalia
FROM bit_dia_acond bda
JOIN dim_planta dp ON dp.nombre_planta = bda.planta
ORDER BY bda.planta, bda.fecha;

-- fact_conciliacion_mensual: una fila por planta por mes (fecha_id = primer día del mes)
INSERT INTO fact_conciliacion_mensual (
    fecha_id, planta_id, periodo, dias_con_registro, dias_faltantes,
    descarga_bit_L, rf_original_L, flag_posible_error_unidad, rf_L, diferencia_L,
    pct_discrepancia, riego_bit_L, descarga_mas_riego_L, pct_discrepancia_con_riego,
    dias_cero, dias_duplicado, dias_pico, dias_constante, dias_anomalos,
    pct_dias_anomalos, dias_retroceso, pct_continuidad, dias_difiere_reportada
)
WITH suma_riego AS (
    -- riego del mes en litros y días que difieren de lo reportado
    SELECT planta, anio, mes,
           SUM(riego_calculado) * 1000 AS riego_bit_L,
           SUM(flag_difiere_reportada) AS dias_difiere_reportada
    FROM bit_dia_acond
    GROUP BY planta, anio, mes
)
SELECT
    df.fecha_id, dp.planta_id, cm.periodo, cm.dias_con_registro, cm.dias_faltantes,
    cm."descarga_bit_L", cm."rf_original_L", cm.flag_posible_error_unidad,
    cm."rf_L", cm."diferencia_L", cm.pct_discrepancia,
    sm.riego_bit_L,
    cm."descarga_bit_L" + sm.riego_bit_L AS descarga_mas_riego_L,
    ABS(cm."descarga_bit_L" + sm.riego_bit_L - cm."rf_L") * 100.0 / cm."rf_L" AS pct_discrepancia_con_riego,
    cm.dias_cero, cm.dias_duplicado, cm.dias_pico, cm.dias_constante, cm.dias_anomalos,
    cm.pct_dias_anomalos, cm.dias_retroceso, cm.pct_continuidad,
    sm.dias_difiere_reportada
FROM conciliacion_mes cm
JOIN dim_fecha df ON df.anio = cm.anio AND df.mes = cm.mes AND df.dia = 1
JOIN dim_planta dp ON dp.nombre_planta = cm.planta
LEFT JOIN suma_riego sm ON sm.planta = cm.planta AND sm.anio = cm.anio AND sm.mes = cm.mes
ORDER BY dp.planta_id, df.fecha_id;
