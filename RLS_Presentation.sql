USE [db_rls_demo_hospital]
GO

/****** Object:  Table [dbo].[patients]    Script Date: 2017-06-09 15:24:21 ******/
SET ANSI_NULLS ON
GO

CREATE USER [YoshidaT] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
CREATE USER [QuinnT] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
CREATE USER [Manager] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO




SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[patients](
	[patientId] [int] NOT NULL,
	[name] [nvarchar](256) NULL,
	[room] [int] NULL,
	[Wing] [int] NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL,	
	[User_Name] [nvarchar](256) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[patientId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
GRANT SELECT ON [dbo].[patients] TO YoshidaT;
GO				
GRANT SELECT ON [dbo].[patients] TO Manager;
GO				
GRANT SELECT ON [dbo].[patients] TO QuinnT;
GO				
GRANT INSERT ON [dbo].[patients] TO QuinnT;
GO				
GRANT UPDATE ON [dbo].[patients] TO QuinnT;
GO				
GRANT DELETE ON [dbo].[patients] TO QuinnT;
GO
INSERT INTO [dbo].[patients]
           ([patientId]
		   ,[name]
           ,[room]
           ,[Wing]
           ,[startTime]
           ,[endTime]
		   ,[User_Name]
		   )    
		   VALUES
		    (1, 	'Ludwig van Beethoven',		101,	1,	'2013-12-17 00:00:00.000',	'2014-03-26 00:00:00.000', 'YoshidaT'),
			(2,	'Niccolo Paganini',				102,	1,	'2013-10-27 00:00:00.000',	'2014-05-27 00:00:00.000', 'YoshidaT'),
			(3,	'Carl Philipp Emanuel Bach',	203,	2,	'2013-03-08 00:00:00.000',	'2013-12-14 00:00:00.000', 'YoshidaT'),
			(4,	'Wolfgang Amadeus Mozart',		205,	2,	'2013-01-27 00:00:00.000',	'2013-12-05 00:00:00.000', 'YoshidaT'),
			(5,	'Pyotr Ilyich Tchaikovsky',		107,	1,	'2013-05-07 00:00:00.000',	'2013-11-06 00:00:00.000', 'QuinnT'),
			(6,	'Philip Morris Glass',			301,	3,	'2014-01-31 00:00:00.000',	NULL					 , 'QuinnT'),
			(7,	'Edvard Hagerup Grieg',			308,	3,	'2013-06-15 00:00:00.000',	'2013-09-04 00:00:00.000', 'QuinnT')
GO


select * from [dbo].[patients]

GO

-- 1.2 Create the RLS predicate function: First we'll use a simple filter
-- Create a new schema
CREATE SCHEMA [Security]
GO

-- Create the RLS predicate function
CREATE FUNCTION [Security].fn_securitypredicate(@User_Name varchar(256))
RETURNS TABLE 
WITH SCHEMABINDING
AS
    RETURN SELECT 1 as [fn_securitypredicateContext_result] 
	 WHERE @User_Name = USER_NAME() or USER_NAME() = 'Manager'
GO


CREATE SECURITY POLICY [Security].[PatientsSecurity] 
ADD FILTER PREDICATE [Security].[fn_securitypredicate]([User_Name]) 
ON [dbo].[patients]
GO

select * from sys.security_policies
select * from sys.security_predicates

GO

SELECT USER_NAME()
GO
EXECUTE AS USER = 'YoshidaT';

GO
SELECT * FROM [dbo].[patients]
GO
REVERT
GO
EXECUTE AS USER = 'QuinnT';

GO
SELECT * FROM [dbo].[patients]
GO
REVERT
GO
EXECUTE AS USER = 'Manager';

GO
SELECT * FROM [dbo].[patients]


--w³¹czanie, wy³¹czanie polityki zabezpieczeñ
GO
REVERT
GO
SELECT USER_NAME()
GO
ALTER SECURITY POLICY [Security].[PatientsSecurity]
WITH (STATE = OFF);

GO
SELECT * FROM [dbo].[patients]
GO
ALTER SECURITY POLICY [Security].[PatientsSecurity]
WITH (STATE = ON);


--Dodawanie, modyfikacja, usuwanie rekordów
GO
SELECT USER_NAME()
GO

EXECUTE AS USER = 'QuinnT';
GO
INSERT INTO [dbo].[patients] ([patientId],[name],[room],[Wing],[startTime],[endTime],[User_Name])    
		   VALUES
		    (8, 	'Vivaldi',		101,	1,	'2013-12-17 00:00:00.000',	'2014-03-26 00:00:00.000', 'QuinnT')

GO

INSERT INTO [dbo].[patients] ([patientId],[name],[room],[Wing],[startTime],[endTime],[User_Name])    
		   VALUES
		    (9, 	'Chopin',		101,	1,	'2013-12-17 00:00:00.000',	'2014-03-26 00:00:00.000', 'YoshidaT')


UPDATE [dbo].[patients] SET [name] = 'aaa' WHERE patientId = 20
GO
DELETE FROM [dbo].[patients] WHERE patientId = 20



--blokowanie wstawiania wierszy
GO
REVERT
GO
ALTER SECURITY POLICY [Security].[PatientsSecurity]
ADD BLOCK PREDICATE [Security].[fn_securitypredicate]([User_Name]) ON [dbo].[patients]

GO

select * from sys.security_policies
select * from sys.security_predicates

GO
ALTER SECURITY POLICY [Security].[PatientsSecurity]
DROP BLOCK PREDICATE  ON [dbo].[patients]


EXECUTE AS USER = 'QuinnT';
GO

INSERT INTO [dbo].[patients] ([patientId],[name],[room],[Wing],[startTime],[endTime],[User_Name])    
		   VALUES
		    (13, 	'Chopin',		101,	1,	'2013-12-17 00:00:00.000',	'2014-03-26 00:00:00.000', 'YoshidaT')



--DROP SECURITY POLICY [Security].[PatientsSecurity]
			
--DROP TABLE [dbo].[patients]
--go
--DROP FUNCTION [Security].fn_securitypredicate
--go
--DROP SCHEMA [Security]
--go
--DROP USER [YoshidaT]
--go
--DROP USER [QuinnT]
--go
--DROP USER [Manager]