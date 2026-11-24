# Reto Auditoría FEMSA · Analítico de descarga de agua

Repositorio individual de **Ximena Yamile Serna Angulo (A00842088)**, equipo 1 (Efervescentes), TI2006B Soporte analítico para la toma de decisiones, grupo 303. Profesores: Dr. Servio Palacios Interiano y Mtra. Claudia Aja Leyva.

## El reto

Auditoría Interna de FEMSA revisa el control "Monitoreo de descargas permitidas" de las plantas de tratamiento de aguas residuales (PTAR) de Coca-Cola FEMSA en México. Hoy la revisión es manual y por muestra. El reto es construir un analítico reproducible que concilie la bitácora diaria de cada planta (formato CONAGUA, en m³) contra Reporting Factory (Power BI corporativo, en litros) y detecte lecturas anómalas, para generar un semáforo y una matriz de prioridad por planta y periodo.

- Alcance: plantas de México, enero a octubre de 2026.
- Solo cantidad de agua descargada, no calidad química.
- El resultado orienta la revisión de Auditoría; no declara cumplimiento ni incumplimiento.

## Preguntas de análisis

1. ¿Qué plantas y periodos conviene revisar primero cuando el medidor y la bitácora presentan discrepancias?
2. ¿En qué plantas y meses la bitácora no coincide con Reporting Factory, y por cuánto?
3. ¿Qué plantas tienen lecturas fuera de lo normal: picos, ceros, duplicados o valores constantes?
4. ¿En qué plantas se rompe la continuidad de las lecturas?

## Contenido

| Archivo | Etapa | Qué contiene |
|---|---|---|
| `notebooks/02-reto-femsa-etapa2-exploracion.ipynb` | Etapa 2 | Inspección de los Excel con openpyxl, importación a SQLite como tablas largas, exploración con pandas y SQL, y reglas de negocio (R1 a R13) que generan las tablas acondicionadas `bit_dia_acond` (planta-día) y `conciliacion_mes` (planta-mes). |
| `etapa3_modelo_dimensional.sql` | Etapa 3 | Creación y carga en PostgreSQL del modelo dimensional: `dim_fecha`, `dim_planta`, `fact_registros_diarios` y `fact_conciliacion_mensual` (constelación de hechos, todo en litros). |

## Cómo correr el cuaderno

1. Abre el cuaderno en Google Colab (botón "Open in Colab" o Archivo → Abrir cuaderno → GitHub).
2. Sube a la sesión los 2 archivos del reto con estos nombres exactos: `Bitacora descargas 2026.xlsx` y `ReportingFactory Ene26 - Oct26.xlsx`.
3. Ejecuta todas las celdas en orden (Entorno de ejecución → Ejecutar todas).

Integridad de la bitácora (SHA256 publicado por los profesores):
`66979994cacb55107c946b818f0e512fd744e5d7341d42be177727f1e1f6471d`

Los datos de FEMSA no se suben a este repositorio: `data/raw/` está en `.gitignore`.

## Principio del tratamiento

Ningún dato se elimina ni se imputa. Las anomalías se marcan con banderas y el valor original se conserva junto al corregido, porque el resultado se usa para auditoría.
