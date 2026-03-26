USE FIFA_WorldCup2026;
GO

-- ============================================================
-- SECTION 7: VIEWS
-- ============================================================

-- 7.1 Complete match schedule view
CREATE OR ALTER VIEW vw_MatchSchedule AS
SELECT 
	m.MatchID,
	m.MatchDate,
	m.TournamentStage,
	c1.CountryName AS Team1Country,
	c2.CountryName AS Team2Country,
	m.Team1Score,
	m.Team2Score,
	s.StadiumName,
	ci.CityName,
	co.CountryName AS HostCountry,
	m.StadiumAttendance
FROM Matches m
INNER JOIN NationalTeams nt1 ON m.Team1ID     = nt1.TeamID
INNER JOIN NationalTeams nt2 ON m.Team2ID     = nt2.TeamID
INNER JOIN Country c1        ON nt1.CountryID = c1.CountryID
INNER JOIN Country c2        ON nt2.CountryID = c2.CountryID
INNER JOIN Stadiums s        ON m.StadiumID   = s.StadiumID
INNER JOIN Cities ci         ON s.CityID      = ci.CityID
INNER JOIN Country co        ON ci.CountryID  = co.CountryID;
GO

-- 7.2 Player stats summary across all matches
CREATE OR ALTER VIEW vw_PlayerStatsSummary AS
SELECT 
	p.PlayerID,
	p.FirstName + ' ' + p.LastName                            AS PlayerName,
	p.Position,
	co.CountryName                                            AS Team,
	COUNT(CASE WHEN me.EventType = 'Goal'        THEN 1 END) AS TotalGoals,
	COUNT(CASE WHEN me.EventType = 'Assist'      THEN 1 END) AS TotalAssists,
	COUNT(CASE WHEN me.EventType = 'Yellow Card' THEN 1 END) AS TotalYellowCards,
	COUNT(CASE WHEN me.EventType = 'Red Card'    THEN 1 END) AS TotalRedCards
FROM MatchEvents me
INNER JOIN Players p        ON me.PlayerID  = p.PlayerID
INNER JOIN NationalTeams nt ON p.TeamID     = nt.TeamID
INNER JOIN Country co       ON nt.CountryID = co.CountryID
GROUP BY p.PlayerID, p.FirstName, p.LastName, p.Position, co.CountryName;
GO

-- 7.3 Ticket sales and revenue per match
CREATE OR ALTER VIEW vw_TicketSalesOverview AS
SELECT 
	m.MatchID,
	m.MatchDate,
	m.TournamentStage,
	s.StadiumName,
	COUNT(t.TicketID)  AS TotalTicketsSold,
	SUM(tc.Price)      AS TotalRevenue,
	AVG(tc.Price)      AS AvgTicketPrice
FROM Tickets t
INNER JOIN Bookings b          ON t.BookingID  = b.BookingID
INNER JOIN Matches m           ON b.MatchID    = m.MatchID
INNER JOIN Stadiums s          ON m.StadiumID  = s.StadiumID
INNER JOIN TicketCategories tc ON t.CategoryID = tc.CategoryID
GROUP BY m.MatchID, m.MatchDate, m.TournamentStage, s.StadiumName;
GO
