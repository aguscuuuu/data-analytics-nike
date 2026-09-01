/*
========================================================================
                    Actividad Práctica Semana 5 
========================================================================
*/

-----------                1- SUB-CONSULTA

--          Actividad Práctica: Subconsultas Escalares y Tratamiento de NULLs
/* 📝 Listar todos los productos disponibles, incluyendo aquellos que no tuvieron ventas, 
y calcular el monto total vendido por cada uno.
Utiliza una subconsulta en el SELECT para obtener el precio total vendido por producto 
(Precio_Total), y reemplaza los valores nulos por 0 en caso de que no haya ventas registradas. */

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

-- Ver después de los JOIN
--			Refactorización a Pipelines Legibles
/* Consigna : Reescribir la consulta por producto utilizando un CTE. 
Debes separar el proceso en dos etapas:
Transformación: Crear un bloque WITH que calcule el total vendido por cada ID de producto.
Consolidación: Realizar un LEFT JOIN entre la tabla maestra de productos y el CTE para asegurar que se incluyan todos los productos, incluso los que no tienen ventas.*/


-----------                2- Inner Join
--         Actividad Práctica: Análisis de Rentabilidad con INNER JOIN
/* 📉 Mostrá una lista con el nombre de cada producto (cuyo nombre empieza con la letra L), su precio por unidad y su margen operativo. 
Ordená los resultados desde el producto más rentable al menos rentable. */

SELECT
	np.ProductName AS Producto,
	v.PricePerUnit AS PrecioUnitario,
	v.OperatingMargin AS MargenOperativo

FROM dbo.FactNikeSales v
INNER JOIN dbo.DimProductName np
	ON v.id_PRODUCT_NAME = np.id_PRODUCT_NAME
WHERE np.ProductName LIKE 'L%'
ORDER BY v.OperatingMargin DESC;

-----------               3- Left Join 

--         Actividad Práctica: Auditoría de Catálogo y Performance de Ventas
/* 📝 Obtener un listado completo de todos los productos, incluyendo aquellos que no registraron ventas, 
y calcular monto total vendido por cada uno (Precio_Total) */

SELECT
	np.ProductName AS Productos,
	ISNULL(SUM(v.PricePerUnit * v.UnitsSold),0) AS PrecioTotal
FROM dbo.DimProductName np
LEFT JOIN dbo.FactNikeSales v
	ON v.id_PRODUCT_NAME = np.id_PRODUCT_NAME
GROUP BY np.ProductName
ORDER BY PrecioTotal;

-----------             4- Right Join 
--        Actividad Práctica: Análisis de Ingresos y Auditoría Geográfica
/* 📝 Calcula el total de ventas por ciudad. */

SELECT
	c.City AS Ciudad,
	ISNULL(SUM(v.PricePerUnit * v.UnitsSold),0) AS PrecioTotal
FROM dbo.DimCity c
RIGHT JOIN dbo.FactNikeSales v
	ON c.id_City = v.id_City
GROUP BY c.City;

-----------             5- UNION – UNION ALL
--        Actividad Práctica: Consolidación Regional con UNION
/* 📝 Obtené un listado unificado con los productos vendidos en dos ciudades específicas: Chicago y Los Angeles */

-- Productos vendidos en Miami

-----------            6- Window Functions
--        Top productos por rentabilidad en cada ciudad

-- 📝 Obtené los productos más rentables por ciudad con un Ranking




--  📝 Calculá el share de ventas de las tallas S, M y L durante los últimos 3 meses disponibles (Sep, Oct y Nov 2024), mostrando el período en formato YYYY-MM.

/* El objetivo es identificar qué porcentaje de las ventas representa cada talla dentro de cada mes y, 
adicionalmente, qué porcentaje representa cada combinación mes/talla sobre el total del período analizado.*/ 





  






