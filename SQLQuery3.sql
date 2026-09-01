 /*ACTIVIDAD PRÁCTICA: consultas, filtros y expresiones en SQL Server

En este bloque vamos a trabajar con consultas sobre las tablas de NikeVentas para comprender
cómo seleccionar columnas, filtrar registros, interpretar valores NULL y construir nuevas 
salidas a partir de operadores y funciones.

El objetivo es que practiquen cómo recuperar información útil, aplicando distintos criterios 
de búsqueda, comparación y transformación de datos. */

-- OPERADORES RELACIONALES ----------------------------------------------------------------------------------

/* MENOR QUE (<)
Filtrar registros cuyo valor sea menor al indicado en la condición. En este caso, mostrar 
productos con precio inferior a 50 */

SELECT
	PRODUCT_SIZE,
	PricePerUnit
FROM dbo.FactNikeSales
WHERE PricePerUnit < 50;

/* DISTINTO DE (!=) (otro modo <>)
Filtrar registros cuyo valor sea diferente al especificado. En este ejemplo, mostrar todas 
las tallas excepto XXS. */

SELECT DISTINCT
	PRODUCT_SIZE
FROM dbo.FactNikeSales
WHERE PRODUCT_SIZE != 'XXS';

-- OPERADORES LÓGICOS ---------------------------------------------------------------------------------------

/* AND
Mostrar únicamente los registros que cumplen ambas condiciones al mismo tiempo. En este caso, 
productos con precio alto y margen operativo elevado. */

SELECT
	PRODUCT_SIZE AS Tallas,
	PricePerUnit AS Precio,
	OperatingMargin AS MargenOperativo
FROM dbo.FactNikeSales
WHERE PricePerUnit > 1500 AND OperatingMargin > 0.50;

/* OR
Mostrar registros que cumplan al menos una de las condiciones indicadas. En este ejemplo, 
productos con talle M o L. */

SELECT
	PRODUCT_SIZE AS Tallas,
	UnitsSold UnidadesVendidas
FROM dbo.FactNikeSales
WHERE PRODUCT_SIZE = 'M' OR PRODUCT_SIZE = 'L'

/* NOT
Excluir del resultado los registros que cumplan una condición específica. En este caso, mostrar 
todos los productos excepto los de talle S. */

SELECT DISTINCT
	PRODUCT_SIZE AS Tallas,
	UnitsSold UnidadesVendidas
FROM dbo.FactNikeSales
WHERE NOT PRODUCT_SIZE = 'S';

-- FILTROS AVANZADOS: LIKE, IN, BETWEEN, CASE ---------------------------------------------------------------

/* LIKE 'L%'
Filtrar registros de texto que comienzan con una letra o patrón específico. En este ejemplo, 
mostrar productos cuyo nombre empieza con la letra L. */

SELECT
	id_PRODUCT_NAME,
	ProductName AS Producto
FROM dbo.DimProductName
WHERE ProductName LIKE 'L%';

/* LIKE '2_L'
Filtrar valores que sigan una estructura específica usando comodines. En este caso, talles de 
3 caracteres donde el primero es 2, el tercero es L y el segundo puede variar. */

SELECT DISTINCT
	PRODUCT_SIZE
FROM dbo.FactNikeSales
WHERE PRODUCT_SIZE LIKE '2_L';

/* LIKE '%Mid%'
Buscar textos que contengan una palabra o fragmento en cualquier posición. En este ejemplo, 
productos que contienen la palabra Mid en su nombre. */

SELECT
	id_PRODUCT_NAME,
	ProductName AS Producto
FROM dbo.DimProductName
WHERE ProductName LIKE '%Mid%';

/* LIKE '[S-X]%'
Filtrar registros cuyo texto comience dentro de un rango de caracteres. En este caso, productos 
que empiezan con letras entre S y X. */

SELECT
	id_PRODUCT_NAME,
	ProductName AS Producto
FROM dbo.DimProductName
WHERE ProductName LIKE '[S-X]%';

/* IN
Filtrar registros cuyos valores pertenezcan a una lista específica. En este ejemplo, mostrar productos 
con talle XS, M o L. */

SELECT
	PRODUCT_SIZE AS Tallas,
	UnitsSold UnidadesVendidas
FROM dbo.FactNikeSales
WHERE PRODUCT_SIZE IN ('M','L','XS');

/* BETWEEN
Filtrar registros que se encuentren dentro de un rango numérico. En este caso, productos con margen 
operativo entre 0.40 y 0.80 inclusive. */

SELECT
	id_PRODUCT_NAME id,
	OperatingMargin AS MargenOperativo
FROM dbo.FactNikeSales
WHERE OperatingMargin BETWEEN 0.40 AND 0.80;

/* CASE 
Clasificar registros que se encuentren dentro de un rango numérico y correspondan a los talles 
XS, M o L. En este caso, productos con margen operativo inferior a 0.40 = Bajo, entre 0.41 y menor 
a 0.80 Medio, igual o mayor a 0.80 Alto */






-- OPERADORES ARITMÉTICOS -----------------------------------------------------------------------------------

/* SUMA (+)
Crear una nueva columna calculada sumando dos valores numéricos fila por fila. En este ejemplo, 
sumar precio unitario y margen operativo. */

SELECT
	PricePerUnit + OperatingMargin AS Suma_Ejemplo
FROM dbo.FactNikeSales;

/* DIVISIÓN (/)
Realizar un cálculo entre columnas para obtener un nuevo valor derivado. En este caso, calcular 
un promedio dividiendo precio por unidades vendidas. Evitar errores de división por cero reemplazando 
temporalmente el valor 0 por NULL cuando una columna pueda generar una operación inválida. */

SELECT
	id_PRODUCT_NAME,
	PricePerUnit / NULLIF(UnitsSold,0) AS PrecioPromedio
FROM dbo.FactNikeSales;

-- FORMATEO NUMÉRICO ----------------------------------------------------------------------------------------

/* ROUND
Redondear un valor numérico a una cantidad específica de decimales. En este ejemplo, mostrar el 
resultado con 2 decimales. */






/* CAST
Convertir un valor de un tipo de dato a otro. En este caso, transformar un resultado decimal en 
entero. */






/* FORMAT
Convertir un número en texto con un formato visual específico. En este ejemplo, mostrar el valor 
como texto formateado con decimales. */






-- ORDENAMIENTO Y SELECCIÓN ---------------------------------------------------------------------------------

/* ORDER BY
Ordenar los resultados de una consulta según una columna específica. En este caso, mostrar las tallas 
ordenadas por unidades vendidas de mayor a menor. */

SELECT
	PRODUCT_SIZE AS Tallas,
	UnitsSold AS UnidadesVendidas
FROM dbo.FactNikeSales
WHERE PRODUCT_SIZE IN ('S','M','L')
ORDER BY UnitsSold DESC;

/* TOP
Limitar la cantidad de registros devueltos por la consulta. En este ejemplo, mostrar solo las 5 tallas 
con mayor precio unitario. */

SELECT TOP 5
	PRODUCT_SIZE AS Tallas,
	PricePerUnit AS Precio
FROM dbo.FactNikeSales
ORDER BY PricePerUnit DESC;

-- AGRUPACIÓN Y FILTROS SOBRE AGREGADOS ---------------------------------------------------------------------

/* GROUP BY
Agrupar los registros que comparten un mismo valor para resumir la información por categoría. En este caso, 
reunir los datos por talle para analizar sus ventas. (AGREGACIÓN Aplicar funciones como SUM, COUNT, AVG, MIN 
o MAX sobre cada grupo generado en la consulta). */

SELECT
	id_PRODUCT_NAME AS Producto,
	SUM(UnitsSold) AS Total_Vendido
FROM dbo.FactNikeSales
WHERE PRODUCT_SIZE = 'M'
GROUP BY id_PRODUCT_NAME;

/* HAVING
Filtrar los resultados después de haber realizado la agrupación. A diferencia de WHERE, HAVING se utiliza 
sobre  resultados agregados. En este ejemplo, mostrar solo los grupos que cumplan una condición sobre el 
total calculado. */

SELECT
	id_PRODUCT_NAME AS Producto,
	SUM(UnitsSold) AS Total_Vendido
FROM dbo.FactNikeSales
WHERE PRODUCT_SIZE = 'M'
GROUP BY id_PRODUCT_NAME
HAVING SUM(UnitsSold) >800;
