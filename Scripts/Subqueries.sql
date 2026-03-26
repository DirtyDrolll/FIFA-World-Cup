USE FIFA_WorldCup2026;
GO

-- ============================================================
-- SECTION 2: SUBQUERIES
-- ============================================================

-- 2.1 Only fans who've actually made a booking
SELECT 
	FanID,
	FirstName,
	LastName,
	Email
FROM Fans
WHERE FanID IN (
	SELECT DISTINCT FanID 
	FROM Bookings
);
GO

-- 2.2 Matches in above-average capacity stadiums
SELECT 
	MatchID,
	MatchDate,
	TournamentStage,
	StadiumAttendance
FROM Matches
WHERE StadiumID IN (
	SELECT StadiumID 
	FROM Stadiums 
	WHERE SeatingCapacity > (
		SELECT AVG(SeatingCapacity) FROM Stadiums
	)
);
GO

-- 2.3 Players who've scored at least one goal
SELECT 
	PlayerID,
	FirstName,
	LastName,
	Position
FROM Players
WHERE PlayerID IN (
	SELECT DISTINCT PlayerID 
	FROM MatchEvents 
	WHERE EventType = 'Goal'
);
GO

-- 2.4 Teams that haven't played yet
SELECT 
	TeamID,
	GroupLetter
FROM NationalTeams
WHERE TeamID NOT IN (
	SELECT Team1ID FROM Matches
	UNION
	SELECT Team2ID FROM Matches
);
GO

-- 2.5 Each fan's most recent booking date
SELECT 
	f.FanID,
	f.FirstName,
	f.LastName,
	(
		SELECT MAX(b.BookingDate) 
		FROM Bookings b 
		WHERE b.FanID = f.FanID
	) AS LastBookingDate
FROM Fans f;
GO

-- 2.6 Matches with above-average attendance
SELECT 
	MatchID,
	MatchDate,
	TournamentStage,
	StadiumAttendance
FROM Matches
WHERE StadiumAttendance > (
	SELECT AVG(StadiumAttendance) 
	FROM Matches 
	WHERE StadiumAttendance IS NOT NULL
);
GO
