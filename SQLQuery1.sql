-- crear base de datos 
   
CREATE DATABASE BD_Nike;

GO

-- poner en uso la base de datos 

USE BD_Nike;

GO

-- crear las tablas de dimensión 

CREATE TABLE dbo.DimCategory (
    id_Category INT PRIMARY KEY,
    Category NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.DimSubCategory (
    id_SubCategory INT PRIMARY KEY,
    SubCategory NVARCHAR(150) NOT NULL
);

CREATE TABLE dbo.DimProductType (
    id_PRODUCT_TYPE INT PRIMARY KEY,
    ProductType NVARCHAR(50) NOT NULL
);

CREATE TABLE dbo.DimBrand (
    id_BRAND INT PRIMARY KEY,
    Brand NVARCHAR(80) NOT NULL
);

CREATE TABLE dbo.DimDepartment (
    id_DEPARTMENT INT PRIMARY KEY,
    Department NVARCHAR(50) NOT NULL
);

CREATE TABLE dbo.DimAvailability (
    id_AVAILABILITY INT PRIMARY KEY,
    Availability NVARCHAR(30) NOT NULL
);

CREATE TABLE dbo.DimColor (
    id_COLOR INT PRIMARY KEY,
    Color NVARCHAR(300) NOT NULL
);

CREATE TABLE dbo.DimDescription (
    id_DESCRIPTION INT PRIMARY KEY,
    [Description] NVARCHAR(250) NOT NULL
);

CREATE TABLE dbo.DimProductName (
    id_PRODUCT_NAME INT PRIMARY KEY,
    ProductName NVARCHAR(255) NOT NULL
);

CREATE TABLE dbo.DimRegion (
    id_Region INT PRIMARY KEY,
    Region NVARCHAR(50) NOT NULL
);

CREATE TABLE dbo.DimState (
    id_State INT PRIMARY KEY,
    [State] NVARCHAR(80) NOT NULL
);

CREATE TABLE dbo.DimCity (
    id_City INT PRIMARY KEY,
    City NVARCHAR(120) NOT NULL
);

GO

-- crear tabla de hechos 

CREATE TABLE dbo.FactNikeSales (
    SaleID BIGINT IDENTITY(1,1) PRIMARY KEY,

    -- fecha 
    InvoiceDate DATE NOT NULL,

    -- claves foráneas (fk) 
    id_Region INT NOT NULL,
    id_State INT NOT NULL,
    id_City INT NOT NULL,
    id_DEPARTMENT INT NOT NULL,
    id_Category INT NOT NULL,
    id_SubCategory INT NOT NULL,
    id_PRODUCT_NAME INT NOT NULL,
    id_DESCRIPTION INT NOT NULL,
    id_PRODUCT_TYPE INT NOT NULL,
    id_COLOR INT NOT NULL,
    id_BRAND INT NOT NULL,
    id_AVAILABILITY INT NOT NULL,
    PRODUCT_SIZE NVARCHAR(40) NULL,
    PricePerUnit DECIMAL(12,2) NULL,
    UnitsSold INT NULL,
    CostoUnitario DECIMAL(12,2) NULL,
    OperatingMargin DECIMAL(6,3) NULL,

    -- constraints fk
    CONSTRAINT FK_Fact_Region FOREIGN KEY (id_Region) REFERENCES dbo.DimRegion(id_Region),
    CONSTRAINT FK_Fact_State FOREIGN KEY (id_State) REFERENCES dbo.DimState(id_State),
    CONSTRAINT FK_Fact_City FOREIGN KEY (id_City) REFERENCES dbo.DimCity(id_City),
    CONSTRAINT FK_Fact_Department FOREIGN KEY (id_DEPARTMENT) REFERENCES dbo.DimDepartment(id_DEPARTMENT),
    CONSTRAINT FK_Fact_Category FOREIGN KEY (id_Category) REFERENCES dbo.DimCategory(id_Category),
    CONSTRAINT FK_Fact_SubCategory FOREIGN KEY (id_SubCategory) REFERENCES dbo.DimSubCategory(id_SubCategory),
    CONSTRAINT FK_Fact_ProductName FOREIGN KEY (id_PRODUCT_NAME) REFERENCES dbo.DimProductName(id_PRODUCT_NAME),
    CONSTRAINT FK_Fact_Description FOREIGN KEY (id_DESCRIPTION) REFERENCES dbo.DimDescription(id_DESCRIPTION),
    CONSTRAINT FK_Fact_ProductType FOREIGN KEY (id_PRODUCT_TYPE) REFERENCES dbo.DimProductType(id_PRODUCT_TYPE),
    CONSTRAINT FK_Fact_Color FOREIGN KEY (id_COLOR) REFERENCES dbo.DimColor(id_COLOR),
    CONSTRAINT FK_Fact_Brand FOREIGN KEY (id_BRAND) REFERENCES dbo.DimBrand(id_BRAND),
    CONSTRAINT FK_Fact_Availability FOREIGN KEY (id_AVAILABILITY) REFERENCES dbo.DimAvailability(id_AVAILABILITY)
);
GO