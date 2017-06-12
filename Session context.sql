USE [db_rls_demo_hospital]
GO

/****** Object:  Table [dbo].[patients]    Script Date: 2017-06-09 15:24:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[patientsContext](
	[patientId] [int] NOT NULL,
	[name] [nvarchar](256) NULL,
	[room] [int] NULL,
	[Wing] [int] NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL,
	[UserId] [int] DEFAULT CAST(SESSION_CONTEXT(N'user_id') as int),
PRIMARY KEY CLUSTERED 
(
	[patientId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

select * from [dbo].[patientsContext];


CREATE TABLE [dbo].[Users](
	[UserId] [int] NOT NULL,
	[Uname] [nvarchar](256) NULL,
	[Upass] [nvarchar](256) NULL,)
GO

INSERT INTO  [dbo].[Users]
			(UserId
			,Uname
			,Upass)
			VALUES
			(2, 'adm1','a'),
			(4, 'adm2','a')

GO

select * from dbo.users;

--Ustawiam session context

exec sp_set_session_context 'user_id',4;
select SESSION_CONTEXT(N'user_id');


--dodaje rekory do nowoutworzonej tablicy

INSERT INTO [dbo].[patientsContext]
           ([patientId]
		   ,[name]
           ,[room]
           ,[Wing]
           ,[startTime]
           ,[endTime]
		   )    
		   VALUES
		    (1, 	'Ludwig van Beethoven',			101,	1,	'2013-12-17 00:00:00.000',	'2014-03-26 00:00:00.000'),
			(2,	'Niccolo Paganini',				102,	1,	'2013-10-27 00:00:00.000',	'2014-05-27 00:00:00.000'),
			(3,	'Carl Philipp Emanuel Bach',	203,	2,	'2013-03-08 00:00:00.000',	'2013-12-14 00:00:00.000'),
			(4,	'Wolfgang Amadeus Mozart',		205,	2,	'2013-01-27 00:00:00.000',	'2013-12-05 00:00:00.000'),
			(5,	'Pyotr Ilyich Tchaikovsky',		107,	1,	'2013-05-07 00:00:00.000',	'2013-11-06 00:00:00.000'),
			(6,	'Philip Morris Glass',			301,	3,	'2014-01-31 00:00:00.000',	NULL					 ),
			(7,	'Edvard Hagerup Grieg',			308,	3,	'2013-06-15 00:00:00.000',	'2013-09-04 00:00:00.000')
GO


select * from [dbo].[patientsContext];

--zmieniamy userId dla ostatniego rekordu
update  [dbo].[patientsContext] SET UserId = 2 where patientId = 7;

select * from [dbo].[patientsContext];


--tworze schemat Security, zgodnie z zaleceniami
CREATE SCHEMA Security;

GO

-- Create the RLS predicate function
CREATE FUNCTION [Security].fn_securitypredicateContext(@UserId int)
RETURNS TABLE 
WITH SCHEMABINDING
AS
    RETURN SELECT 1 as [fn_securitypredicateContext_result] 
	WHERE CAST(SESSION_CONTEXT(N'user_id') as int) = @UserId;
GO

CREATE SECURITY POLICY [Security].[PatientsSecurityContext] 
ADD FILTER PREDICATE [Security].[fn_securitypredicateContext]([UserId]) 
ON [dbo].[patientsContext];
GO


exec sp_set_session_context 'user_id',4;
select * from [dbo].[patientsContext];


exec sp_set_session_context 'user_id',2;
select * from [dbo].[patientsContext];




--DROP TABLE [dbo].[patientsContext]
--DROP FUNCTION [Security].fn_securitypredicateContext
--DROP SECURITY POLICY [Security].[PatientsSecurityContext] 
--DROP TABLE [dbo].[Users]
--DROP SCHEMA Security