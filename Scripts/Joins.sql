USE FIFA_WorldCup2026;
GO

-- ============================================================
-- SECTION 1: JOINS
-- ============================================================

-- 1.1 Show all players with their team's group letter
SELECT 
	p.PlayerID,
	p.FirstName,
	p.LastName,
	p.Position,
	p.TeamNumber,
	nt.GroupLetter
FROM Players p
INNER JOIN NationalTeams nt ON p.TeamID = nt.TeamID;
GO

-- 1.2 Complete match schedule - who plays who, where, and when
SELECT 
	m.MatchID,
	t1.GroupLetter  AS Team1Group,
	t2.GroupLetter  AS Team2Group,
	m.Team1Score,
	m.Team2Score,
	m.MatchDate,
	m.TournamentStage,
	s.StadiumName,
	c.CityName,
	co.CountryName  AS HostCountry
FROM Matches m
INNER JOIN NationalTeams t1 ON m.Team1ID   = t1.TeamID
INNER JOIN NationalTeams t2 ON m.Team2ID   = t2.TeamID
INNER JOIN Stadiums s       ON m.StadiumID = s.StadiumID
INNER JOIN Cities c         ON s.CityID    = c.CityID
INNER JOIN Country co       ON c.CountryID = co.CountryID;
GO

-- 1.3 All fans and their bookings (if they have any)
SELECT 
	f.FanID,
	f.FirstName,
	f.LastName,
	f.Email,
	b.BookingID,
	b.BookingDate,
	b.BookingStatus
FROM Fans f
LEFT JOIN Bookings b ON f.FanID = b.FanID;
GO

-- 1.4 Matches with their events (goals, cards, etc.)
SELECT 
	m.MatchID,
	m.MatchDate,
	m.TournamentStage,
	me.EventType,
	me.EventMinute,
	me.EventDescription,
	p.FirstName + ' ' + p.LastName AS PlayerName
FROM Matches m
LEFT JOIN MatchEvents me ON m.MatchID   = me.MatchID
LEFT JOIN Players p      ON me.PlayerID = p.PlayerID;
GO

-- 1.5 Full ticket details with the fan who bought them
SELECT 
	t.TicketID,
	t.TicketCode,
	t.SeatSection,
	t.SeatRow,
	t.SeatNumber,
	t.PriceAtPurchase,
	f.FirstName + ' ' + f.LastName AS FanName,
	f.Email,
	b.BookingDate,
	b.BookingStatus
FROM Tickets t
INNER JOIN Bookings b ON t.BookingID = b.BookingID
INNER JOIN Fans f     ON b.FanID     = f.FanID;
GO

-- 1.6 Which officials are assigned to which matches
SELECT 
	m.MatchID,
	m.MatchDate,
	m.TournamentStage,
	o.FirstName + ' ' + o.LastName AS OfficialName,
	mo.Role                        AS OfficialRole,
	c.CountryName                  AS OfficialNationality
FROM MatchOfficials mo
INNER JOIN Matches m   ON mo.MatchID    = m.MatchID
INNER JOIN Officials o ON mo.OfficialID = o.OfficialID
INNER JOIN Country c   ON o.CountryID   = c.CountryID;
GO

-- 1.7 Coaching staff with their teams
SELECT 
	cs.StaffID,
	cs.StaffName,
	cs.Role,
	cs.Experience,
	nt.GroupLetter,
	co.CountryName
FROM CoachingStaff cs
INNER JOIN NationalTeams nt ON cs.TeamID    = nt.TeamID
INNER JOIN Country co       ON nt.CountryID = co.CountryID;
GO
