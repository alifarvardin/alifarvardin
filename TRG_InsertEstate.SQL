CREATE TRIGGER [Estate].[TRG_InsertEstate]
ON [Estate].[Estate]
with encryption
FOR INSERT
AS 
BEGIN
    SET NOCOUNT ON;

    /* Insert Details of New ROW into ChangeLog */ 
      DECLARE @Username NVARCHAR(MAX)
      SELECT
        @Username = ISNULL(CAST(SESSION_CONTEXT(N'Username') AS NVARCHAR), 'SQL Server');

      DECLARE @IP NVARCHAR(MAX)
      SELECT
        @IP = ISNULL(CAST(SESSION_CONTEXT(N'IP') AS NVARCHAR), 'Localhost');

      DECLARE @result NVARCHAR(MAX)
      DECLARE @resultBase NVARCHAR(MAX)
      DECLARE @resultOld NVARCHAR(MAX)
      DECLARE @resultNew NVARCHAR(MAX)
      DECLARE @operation CHAR(6)
      SET @operation = 'Insert'
  

      SET @resultBase = (SELECT
        @operation 'OPERATION'
       ,@IP 'HOST_IP'
       ,SYSTEM_USER 'SYSTEM_USER'
       ,USER_NAME() 'USER_NAME'
       ,HOST_NAME() 'HOST_NAME'
       ,SESSION_USER 'SESSION_USER'
       ,TRIM(HOST_ID()) 'HOST_ID'
      FROM inserted i
      FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);


    SET @result = JSON_QUERY('{"Detail":' + @resultBase + '}');

INSERT INTO Core.Changelog (TableId, RowId, ModifiedBy, ModifiedOn, [Description])
  SELECT
    'Estate.Estate' AS TableId
   ,i.Id AS RowId
   ,@Username AS ModifiedBy
   ,GETDATE() AS ModifiedOn
   ,@result
  FROM inserted i;


END
