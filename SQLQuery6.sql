-- poner en uso la base de datos
USE BD_Nike;
GO

-- consulta del tp final ------------------------------------------------------------------------------------

SELECT
    cl.ClientName AS Cliente,
    v.InvoiceDate AS FechaCompra,
    v.PricePerUnit * v.UnitsSold AS TotalVenta
FROM dbo.FactNikeSales v
INNER JOIN dbo.DimClient cl
    ON v.id_Client = cl.id_Client
WHERE v.InvoiceDate > DATEADD(DAY, -30, (SELECT MAX(InvoiceDate) FROM dbo.FactNikeSales))
ORDER BY v.InvoiceDate DESC;
