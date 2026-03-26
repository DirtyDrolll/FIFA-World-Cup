USE FIFA_WorldCup2026;
GO

-- ============================================================
-- SECTION 3: CTEs (Common Table Expressions)
-- ============================================================

-- 3.1 Top scorers per team
WITH TeamGoalScorers AS (
	SELECT 
		p.TeamID,
		p.PlayerID,
		p.FirstName + ' ' + p.LastName AS PlayerName,
		COUNT(me.EventID) AS TotalGoals
	FROM MatchEvents me
	INNER JOIN Players p ON me.PlayerID = p.PlayerID
	WHERE me.EventType = 'Goal'
	GROUP BY p.TeamID, p.PlayerID, p.FirstName, p.LastName
)
SELECT 
	tgs.TeamID,
	co.CountryName AS TeamCountry,
	tgs.PlayerName,
	tgs.TotalGoals
FROM TeamGoalScorers tgs
INNER JOIN NationalTeams nt ON tgs.TeamID   = nt.TeamID
INNER JOIN Country co       ON nt.CountryID = co.CountryID
ORDER BY tgs.TotalGoals DESC;
GO

-- 3.2 Most popular matches by booking count
WITH BookingsPerMatch AS (
	SELECT 
		MatchID,
		COUNT(BookingID) AS TotalBookings
	FROM Bookings
	GROUP BY MatchID
)
SELECT 
	bpm.MatchID,
	m.MatchDate,
	m.TournamentStage,
	s.StadiumName,
	bpm.TotalBookings,
	DENSE_RANK() OVER (ORDER BY bpm.TotalBookings DESC) AS PopularityRank
FROM BookingsPerMatch bpm
INNER JOIN Matches m  ON bpm.MatchID  = m.MatchID
INNER JOIN Stadiums s ON m.StadiumID  = s.StadiumID
ORDER BY PopularityRank, bpm.MatchID;
GO

-- 3.3 Yellow and red card summary per player
WITH DisciplineRecord AS (
	SELECT 
		PlayerID,
		COUNT(CASE WHEN EventType = 'Yellow Card' THEN 1 END) AS TotalYellowCards,
		COUNT(CASE WHEN EventType = 'Red Card'    THEN 1 END) AS TotalRedCards
	FROM MatchEvents
	GROUP BY PlayerID
)
SELECT 
	p.FirstName + ' ' + p.LastName AS PlayerName,
	p.Position,
	nt.GroupLetter,
	co.CountryName,
	dr.TotalYellowCards,
	dr.TotalRedCards
FROM DisciplineRecord dr
INNER JOIN Players p        ON dr.PlayerID  = p.PlayerID
INNER JOIN NationalTeams nt ON p.TeamID     = nt.TeamID
INNER JOIN Country co       ON nt.CountryID = co.CountryID
ORDER BY dr.TotalRedCards DESC, dr.TotalYellowCards DESC;
GO

-- 3.4 Money made per match from ticket sales
WITH MatchRevenue AS (
	SELECT 
		b.MatchID,
		SUM(tc.Price) AS TotalRevenue
	FROM Tickets t
	INNER JOIN Bookings b          ON t.BookingID  = b.BookingID
	INNER JOIN TicketCategories tc ON t.CategoryID = tc.CategoryID
	GROUP BY b.MatchID
)
SELECT 
	mr.MatchID,
	m.MatchDate,
	m.TournamentStage,
	s.StadiumName,
	mr.TotalRevenue
FROM MatchRevenue mr
INNER JOIN Matches m  ON mr.MatchID  = m.MatchID
INNER JOIN Stadiums s ON m.StadiumID = s.StadiumID
ORDER BY mr.TotalRevenue DESC;
GO
