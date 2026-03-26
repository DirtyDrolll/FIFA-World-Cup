USE FIFA_WorldCup2026;
GO

-- ============================================================
-- SECTION 11: SECURITY - AUTHENTICATION
-- ============================================================

-- 11.1 Create a SQL login for an admin
CREATE LOGIN TournamentAdmin 
WITH PASSWORD         = 'Adm!nS3cur3#2026',
	 CHECK_POLICY     = ON,
	 CHECK_EXPIRATION = ON;
GO

-- 11.2 Create a database user for that login
CREATE USER TournamentAdmin FOR LOGIN TournamentAdmin;
GO

-- 11.3 Create a read-only role for reports
CREATE ROLE db_ReportViewer;
GO

GRANT SELECT ON vw_MatchSchedule       TO db_ReportViewer;
GRANT SELECT ON vw_PlayerStatsSummary  TO db_ReportViewer;
GRANT SELECT ON vw_TicketSalesOverview TO db_ReportViewer;
GO

-- 11.4 Give admin rights to manage data
GRANT SELECT, INSERT, UPDATE, DELETE ON Matches       TO TournamentAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Players       TO TournamentAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Bookings      TO TournamentAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Tickets       TO TournamentAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Fans          TO TournamentAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON NationalTeams TO TournamentAdmin;
GRANT EXECUTE ON usp_GetMatchesByStage     TO TournamentAdmin;
GRANT EXECUTE ON usp_RegisterFan           TO TournamentAdmin;
GRANT EXECUTE ON usp_GetPlayerStatsByMatch TO TournamentAdmin;
GO

-- 11.5 Block deletes on critical tables
DENY DELETE ON Matches       TO TournamentAdmin;
DENY DELETE ON NationalTeams TO TournamentAdmin;
GO
