
SET QUOTED_IDENTIFIER ON
GO

CREATE USER [YoshidaT] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
CREATE USER [QuinnT] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
CREATE USER [Manager] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO

CREATE TABLE [dbo].[patientsNoRLS](
	[patientId] [int] NOT NULL,
	[P_name] [nvarchar](256) NULL,
	[room] [int] NULL,
	[Wing] [int] NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL,
	[User_Name] [sysname],
PRIMARY KEY CLUSTERED 
(
	[patientId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE INDEX IX_Patient_NoRLS ON patientsNoRLS(P_name)
GO

INSERT INTO [dbo].[patientsNoRLS]
           ([patientId]
		   ,[P_name]
           ,[room]
           ,[Wing]
           ,[startTime]
           ,[endTime]
		   ,[User_Name]
		   )    
		   VALUES
		    (1, 	'Ludwig van Beethoven',			101,	1,	'2013-12-17 00:00:00.000',	'2014-03-26 00:00:00.000', 'YoshidaT'),
			(2,	'Niccolo Paganini',				102,	1,	'2013-10-27 00:00:00.000',	'2014-05-27 00:00:00.000', 'YoshidaT'),
			(3,	'Carl Philipp Emanuel Bach',	203,	2,	'2013-03-08 00:00:00.000',	'2013-12-14 00:00:00.000', 'YoshidaT'),
			(4,	'Wolfgang Amadeus Mozart',		205,	2,	'2013-01-27 00:00:00.000',	'2013-12-05 00:00:00.000', 'YoshidaT'),
			(5,	'Pyotr Ilyich Tchaikovsky',		107,	1,	'2013-05-07 00:00:00.000',	'2013-11-06 00:00:00.000', 'QuinnT'),
			(6,	'Philip Morris Glass',			301,	3,	'2014-01-31 00:00:00.000',	NULL, 'QuinnT'					 ),
			(7,	'Edvard Hagerup Grieg',			308,	3,	'2013-06-15 00:00:00.000',	'2013-09-04 00:00:00.000', 'QuinnT')
GO

GO

SELECT * FROM [dbo].[patientsNoRLS]
GO

CREATE VIEW  [dbo].[V_patientsNoRLS] AS
SELECT 
           [patientId]
		   ,[P_name]
           ,[room]
           ,[Wing]
           ,[startTime]
           ,[endTime]
		   ,[User_Name]
		   FROM [dbo].[patientsNoRLS]
		   WHERE User_Name = USER_NAME() or USER_NAME() = 'Manager'

GO

SELECT * FROM [dbo].[patientsNoRLS]
GO

SELECT * FROM [dbo].[V_patientsNoRLS]

GO
GRANT SELECT ON [V_patientsNoRLS] TO YoshidaT
GO
GRANT SELECT ON [V_patientsNoRLS] TO Manager
GO
GRANT SELECT ON [V_patientsNoRLS] TO QuinnT
GO
GRANT INSERT ON [V_patientsNoRLS] TO QuinnT
GO
GRANT UPDATE ON [V_patientsNoRLS] TO QuinnT

EXECUTE AS USER = 'YoshidaT';
GO
SELECT * FROM [dbo].[patientsNoRLS]
GO

SELECT * FROM [dbo].[V_patientsNoRLS]

GO
REVERT
GO

EXECUTE AS USER = 'Manager';
GO
SELECT * FROM [dbo].[patientsNoRLS]
GO

SELECT * FROM [dbo].[V_patientsNoRLS]

SELECT USER_NAME()

REVERT
GO
EXECUTE AS USER = 'QuinnT';


INSERT INTO [dbo].[V_patientsNoRLS] ([patientId],[P_name],[room],[Wing],[startTime],[endTime],[User_Name])   
 VALUES (10, 	'Chopin F',			101,	1,	'2013-12-17 00:00:00.000',	'2014-03-26 00:00:00.000', 'QuinnT')
 GO

 SELECT * FROM [dbo].[V_patientsNoRLS]
 
 GO

 SELECT USER_NAME()

 GO
 
 INSERT INTO [dbo].[V_patientsNoRLS] ([patientId],[P_name],[room],[Wing],[startTime],[endTime],[User_Name])   
 VALUES (9, 	'Chopis F',			101,	1,	'2013-12-17 00:00:00.000',	'2014-03-26 00:00:00.000', 'YoshidaT')

 GO
 REVERT
 GO
ALTER VIEW  [dbo].[V_patientsNoRLS] AS
SELECT 
           [patientId]
		   ,[P_name]
           ,[room]
           ,[Wing]
           ,[startTime]
           ,[endTime]
		   ,[User_Name]
		   FROM [dbo].[patientsNoRLS]
		   WHERE User_Name = USER_NAME() or USER_NAME() = 'Manager'
		   WITH CHECK OPTION
GO
EXECUTE AS USER = 'QuinnT';

GO

INSERT INTO [dbo].[V_patientsNoRLS] ([patientId],[P_name],[room],[Wing],[startTime],[endTime],[User_Name])   
 VALUES (12, 	'Chopin F',			101,	1,	'2013-12-17 00:00:00.000',	'2014-03-26 00:00:00.000', 'YoshidaT')

--REVERT
--go
--DROP TABLE [dbo].[patientsNoRLS]
--go
--DROP VIEW [dbo].[V_patientsNoRLS]
--go
--DROP INDEX IX_Patient_NoRLS
--go
--DROP USER [YoshidaT]
--go
--DROP USER [QuinnT]
--go
--DROP USER [Manager]