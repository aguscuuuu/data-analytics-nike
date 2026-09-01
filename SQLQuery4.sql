/* ACTIVIDAD PRÁCTICA: Subconsultas escalares y tratamiento de NULLs, análisis de rentabilidad 
con INNER JOIN, auditoría de catálogo y performance de ventas, análisis de ingresos y auditoría
geográfica, consolidación regional con UNION. */

-- Poner en uso la base de datos 

USE BD_Nike;
GO

-- SUB-CONSULTA ---------------------------------------------------------------------------------------------

/* Listar todos los productos disponibles, incluyendo aquellos que no tuvieron ventas, y calcular el monto 
total vendido por cada uno. Utiliza una subconsulta en el SELECT para obtener el precio total vendido por 
producto (Precio_Total), y reemplaza los valores nulos por 0 en caso de que no haya ventas registradas.*/

SELECT
	np.id_PRODUCT_NAME,
	np.ProductName AS Productos,
	ISNULL( 
		(SELECT
			SUM(v.PricePerUnit * v.UnitsSold)
		FROM dbo.FactNikeSales v
		WHERE v.id_PRODUCT_NAME = np.id_PRODUCT_NAME
		),
	0) AS Precio_Total
FROM dbo.DimProductName np;

/* Refactorización a Pipelines Legibles. Reescribir la consulta por producto utilizando un CTE. Debes 
separar el proceso en dos etapas:
- Transformación: Crear un bloque WITH que calcule el total vendido por cada ID de producto.
- Consolidación: Realizar un LEFT JOIN entre la tabla maestra de productos y el CTE para asegurar que se 
incluyan todos los productos, incluso los que no tienen ventas.*/

WITH VentasAgrupadas AS (
	SELECT
		v.id_PRODUCT_NAME,
		SUM(v.PricePerUnit * v.UnitsSold) AS Total_Vendido
	FROM dbo.FactNikeSales v
	GROUP BY v.id_PRODUCT_NAME
)
SELECT
	np.id_PRODUCT_NAME,
	np.ProductName AS Productos,
	ISNULL(va.Total_Vendido, 0) AS Precio_Total
FROM dbo.DimProductName np
LEFT JOIN VentasAgrupadas va
	ON np.id_PRODUCT_NAME = va.id_PRODUCT_NAME
ORDER BY Precio_Total DESC;

-- INNER JOIN -----------------------------------------------------------------------------------------------
/* Mostrá una lista con el nombre de cada producto (cuyo nombre empieza con la letra L), su precio por unidad 
y su margen operativo. Ordená los resultados desde el producto más rentable al menos rentable. */

SELECT
	np.ProductName AS Producto,
	v.PricePerUnit AS PrecioUnitario,
	v.OperatingMargin AS MargenOperativo

FROM dbo.FactNikeSales v
INNER JOIN dbo.DimProductName np
	ON v.id_PRODUCT_NAME = np.id_PRODUCT_NAME
WHERE np.ProductName LIKE 'L%'
ORDER BY v.OperatingMargin DESC;

-- LEFT JOIN ------------------------------------------------------------------------------------------------ 
/* Obtener un listado completo de todos los productos, incluyendo aquellos que no registraron ventas, y 
calcular monto total vendido por cada uno (Precio_Total) */

SELECT
	np.id_PRODUCT_NAME,
	np.ProductName AS Productos,
	ISNULL(SUM(v.PricePerUnit * v.UnitsSold),0) AS Precio_Total
FROM dbo.DimProductName np
LEFT JOIN dbo.FactNikeSales v
	ON np.id_PRODUCT_NAME = v.id_PRODUCT_NAME
GROUP BY np.id_PRODUCT_NAME, np.ProductName
ORDER BY Precio_Total ASC;

-- RIGHT JOIN -----------------------------------------------------------------------------------------------
/* Calcula el total de ventas por ciudad. */

SELECT
	c.City AS Ciudad,
	SUM(v.PricePerUnit * v.UnitsSold) AS VentasTotales
FROM dbo.DimCity c
RIGHT JOIN dbo.FactNikeSales v
	ON c.id_City = v.id_City
GROUP BY c.City

-- UNION / UNION ALL ----------------------------------------------------------------------------------------
/* Obtené un listado unificado con los productos vendidos en dos ciudades específicas: 
Miami y Denver. */

-- Productos vendidos en Miami
SELECT
	np.ProductName AS Producto,
	'Miami' AS Ciudad
FROM dbo.FactNikeSales v
INNER JOIN dbo.DimCity c
	ON v.id_City = c.id_City
INNER JOIN dbo.DimProductName np
	ON v.id_PRODUCT_NAME = np.id_PRODUCT_NAME
WHERE c.City = 'Miami'

UNION

-- Productos vendido en Denver
SELECT
	np.ProductName AS Producto,
	'Denver' AS Ciudad
FROM dbo.FactNikeSales v
INNER JOIN dbo.DimCity c
	ON v.id_City = c.id_City
INNER JOIN dbo.DimProductName np
	ON v.id_PRODUCT_NAME = np.id_PRODUCT_NAME
WHERE c.City = 'Denver';

-- WINDOW FUNCTIONS -----------------------------------------------------------------------------------------
/* Top productos por rentabilidad en cada ciudad. Obtené los productos más rentables por ciudad con un 
Ranking. */

SELECT
	c.City AS Sucursal,
	np.ProductName AS Productos,
	v.OperatingMargin AS Margen_Operativo,
	ROW_NUMBER() OVER (PARTITION BY c.City ORDER BY v.OperatingMargin DESC) AS Ranking_Margen
-- Veamos también ROW_NUMBER
FROM dbo.FactNikeSales v
INNER JOIN dbo.DimCity c
	ON v.id_City = c.id_City
INNER JOIN dbo.DimProductName np
	ON v.id_PRODUCT_NAME = np.id_PRODUCT_NAME;

/* Calculá el share de ventas de las tallas S, M y L durante los últimos 3 meses disponibles (Sep, Oct 
y Nov 2024), mostrando el período en formato YYYY-MM. El objetivo es identificar qué porcentaje de las 
ventas representa cada talla dentro de cada mes y, adicionalmente, qué porcentaje representa cada 
combinación mes/talla sobre el total del período analizado.*/ 

WITH ventas_por_talla AS (
	SELECT
		FORMAT(v.InvoiceDate, 'yyyy-MM') AS Periodo,
		v.PRODUCT_SIZE AS Talla,
		SUM(v.UnitsSold * v.PricePerUnit) AS Ventas
	
	FROM dbo.FactNikeSales v
	WHERE v.InvoiceDate >= '2024-09-01'
		AND v.InvoiceDate < '2024-12-01'
		AND v.PRODUCT_SIZE IN ('S','M','L')
	GROUP BY 
		FORMAT(v.InvoiceDate, 'yyyy-MM'),
		v.PRODUCT_SIZE
)
SELECT
	Periodo,
	Talla,
	Ventas,
	SUM(Ventas) OVER (
		PARTITION BY Periodo
	) AS Ventas_Totales_Mes,
	CAST(Ventas
		/ SUM(Ventas) OVER (
			PARTITION BY Periodo
	) AS DECIMAL(18,2)) AS Share_Mensual,
	SUM(Ventas) OVER () AS Ventas_Totales_Periodo,
	CAST(Ventas
		/ SUM(Ventas) OVER ()
	AS DECIMAL(18,2)) AS Share_Total_Periodo

FROM ventas_por_talla
ORDER BY
	Periodo,
	Talla



  






