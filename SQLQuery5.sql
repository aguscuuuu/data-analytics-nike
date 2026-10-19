/* DIMENSIÓN CLIENTES (DimClient)

El dataset de Nike no trae información de clientes, por lo que se genera una dimensión de
clientes ficticios (minoristas que compran a Nike) a partir de las ubicaciones donde se
registraron ventas. Cada cliente pertenece a una ciudad, un estado y una región, y cada
venta se asigna a uno de los clientes de su misma ubicación.

El script se puede volver a ejecutar: elimina la dimensión y la columna id_Client de la
tabla de hechos si ya existen y las vuelve a crear (por ejemplo, después de recargar
FactNikeSales). */

-- Poner en uso la base de datos

USE BD_Nike;
GO

-- LIMPIEZA PREVIA ------------------------------------------------------------------------------------------

IF COL_LENGTH('dbo.FactNikeSales', 'id_Client') IS NOT NULL
BEGIN
    IF OBJECT_ID('dbo.FK_Fact_Client', 'F') IS NOT NULL
        ALTER TABLE dbo.FactNikeSales DROP CONSTRAINT FK_Fact_Client;

    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Fact_Client' AND object_id = OBJECT_ID('dbo.FactNikeSales'))
        DROP INDEX IX_Fact_Client ON dbo.FactNikeSales;

    ALTER TABLE dbo.FactNikeSales DROP COLUMN id_Client;
END;

DROP TABLE IF EXISTS dbo.DimClient;
GO

-- CREAR LA TABLA DE DIMENSIÓN ------------------------------------------------------------------------------

CREATE TABLE dbo.DimClient (
    id_Client INT PRIMARY KEY,
    ClientName NVARCHAR(150) NOT NULL,
    ClientType NVARCHAR(50) NOT NULL,

    -- ubicación del cliente (fk)
    id_Region INT NOT NULL,
    id_State INT NOT NULL,
    id_City INT NOT NULL,

    -- constraints
    CONSTRAINT UQ_Client_Name UNIQUE (ClientName),
    CONSTRAINT FK_Client_Region FOREIGN KEY (id_Region) REFERENCES dbo.DimRegion(id_Region),
    CONSTRAINT FK_Client_State FOREIGN KEY (id_State) REFERENCES dbo.DimState(id_State),
    CONSTRAINT FK_Client_City FOREIGN KEY (id_City) REFERENCES dbo.DimCity(id_City)
);
GO

-- CARGAR CLIENTES FICTICIOS --------------------------------------------------------------------------------

/* Se toman las combinaciones región / estado / ciudad que existen en las ventas (hay ciudades
con el mismo nombre en distintos estados, como Portland o Charleston, por eso la ubicación se
define con las tres claves). Para cada ubicación se crean 3 clientes, combinando un nombre
comercial ficticio con el nombre de la ciudad. Las ubicaciones se ordenan por ciudad para que
dos ciudades homónimas queden contiguas y reciban nombres comerciales distintos. */

WITH Ubicaciones AS (
    SELECT DISTINCT
        f.id_Region,
        f.id_State,
        f.id_City,
        c.City,
        s.[State]
    FROM dbo.FactNikeSales f
    INNER JOIN dbo.DimCity c
        ON f.id_City = c.id_City
    INNER JOIN dbo.DimState s
        ON f.id_State = s.id_State
),
UbicacionesNumeradas AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY City, [State]) AS NroUbicacion
    FROM Ubicaciones
),
NombresComerciales AS (
    SELECT * FROM (VALUES
        (0, 'Summit Sports',        'Tienda deportiva'),
        (1, 'Urban Runners',        'Tienda especializada'),
        (2, 'Victory Outlet',       'Outlet'),
        (3, 'Peak Performance',     'Tienda deportiva'),
        (4, 'Fast Track Footwear',  'Tienda especializada'),
        (5, 'Mega Sport Store',     'Cadena minorista'),
        (6, 'Champion Athletics',   'Tienda deportiva'),
        (7, 'Street Kicks',         'Tienda especializada'),
        (8, 'All Stars Retail',     'Cadena minorista')
    ) AS n (idNombre, NombreComercial, TipoCliente)
),
ClientesPorUbicacion AS (
    SELECT * FROM (VALUES (1), (2), (3)) AS k (NroCliente)
)
INSERT INTO dbo.DimClient (id_Client, ClientName, ClientType, id_Region, id_State, id_City)
SELECT
    (u.NroUbicacion - 1) * 3 + k.NroCliente AS id_Client,
    CONCAT(n.NombreComercial, ' ', u.City) AS ClientName,
    n.TipoCliente,
    u.id_Region,
    u.id_State,
    u.id_City
FROM UbicacionesNumeradas u
CROSS JOIN ClientesPorUbicacion k
INNER JOIN NombresComerciales n
    ON n.idNombre = (u.NroUbicacion % 3) * 3 + k.NroCliente - 1;
GO

-- VINCULAR LA TABLA DE HECHOS ------------------------------------------------------------------------------

ALTER TABLE dbo.FactNikeSales ADD id_Client INT NULL;
GO

/* Cada venta se asigna a un cliente de su misma ubicación. Para que los clientes no tengan
todos el mismo volumen, se reparte según SaleID: el 1° cliente recibe ~50% de las ventas,
el 2° ~33% y el 3° ~17%. */

UPDATE f
SET f.id_Client = cl.id_Client
FROM dbo.FactNikeSales f
INNER JOIN dbo.DimClient cl
    ON  cl.id_Region = f.id_Region
    AND cl.id_State  = f.id_State
    AND cl.id_City   = f.id_City
    AND (cl.id_Client - 1) % 3 + 1 =
        CASE
            WHEN f.SaleID % 6 < 3 THEN 1
            WHEN f.SaleID % 6 < 5 THEN 2
            ELSE 3
        END;
GO

ALTER TABLE dbo.FactNikeSales ALTER COLUMN id_Client INT NOT NULL;

ALTER TABLE dbo.FactNikeSales
    ADD CONSTRAINT FK_Fact_Client FOREIGN KEY (id_Client) REFERENCES dbo.DimClient(id_Client);

CREATE INDEX IX_Fact_Client ON dbo.FactNikeSales (id_Client);
GO

-- VERIFICAR CARGAS -----------------------------------------------------------------------------------------

-- viendo la tabla de clientes
SELECT
    cl.id_Client,
    cl.ClientName AS Cliente,
    cl.ClientType AS TipoCliente,
    c.City AS Ciudad,
    s.[State] AS Estado,
    r.Region AS Region
FROM dbo.DimClient cl
INNER JOIN dbo.DimCity c ON cl.id_City = c.id_City
INNER JOIN dbo.DimState s ON cl.id_State = s.id_State
INNER JOIN dbo.DimRegion r ON cl.id_Region = r.id_Region
ORDER BY cl.id_Client;

-- ventas cuya ubicación no coincide con la de su cliente (debe dar 0)
SELECT COUNT(*) AS VentasConUbicacionDistinta
FROM dbo.FactNikeSales f
INNER JOIN dbo.DimClient cl
    ON f.id_Client = cl.id_Client
WHERE f.id_Region <> cl.id_Region
   OR f.id_State  <> cl.id_State
   OR f.id_City   <> cl.id_City;

-- cantidad de ventas y monto total por cliente
SELECT
    cl.ClientName AS Cliente,
    COUNT(*) AS CantidadVentas,
    SUM(f.PricePerUnit * f.UnitsSold) AS TotalVendido
FROM dbo.FactNikeSales f
INNER JOIN dbo.DimClient cl
    ON f.id_Client = cl.id_Client
GROUP BY cl.ClientName
ORDER BY TotalVendido DESC;

-- CONSULTA DEL TRABAJO PRÁCTICO ----------------------------------------------------------------------------

/* Extraer el nombre del cliente, la fecha de la compra y el total de la venta de las ventas
realizadas en los últimos 30 días (contados desde la fecha de la última venta del dataset),
ordenadas por fecha de compra descendente. */

DECLARE @UltimaFecha DATE = (SELECT MAX(InvoiceDate) FROM dbo.FactNikeSales);

SELECT
    cl.ClientName AS Cliente,
    v.InvoiceDate AS FechaCompra,
    v.PricePerUnit * v.UnitsSold AS TotalVenta
FROM dbo.FactNikeSales v
INNER JOIN dbo.DimClient cl
    ON v.id_Client = cl.id_Client
WHERE v.InvoiceDate > DATEADD(DAY, -30, @UltimaFecha)
ORDER BY v.InvoiceDate DESC;
