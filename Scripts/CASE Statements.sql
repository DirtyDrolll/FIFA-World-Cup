USE FIFA_WorldCup2026;
GO

-- ============================================================
-- SECTION 4: CASE STATEMENTS
-- ============================================================

-- 4.1 Who won each match?
SELECT 
	m.MatchID,
	m.MatchDate,
	m.TournamentStage,
	t1.GroupLetter AS Team1,
	t2.GroupLetter AS Team2,
	m.Team1Score,
	m.Team2Score,
	CASE 
		WHEN m.Team1Score > m.Team2Score THEN 'Team1 Win'
		WHEN m.Team1Score < m.Team2Score THEN 'Team2 Win'
		WHEN m.Team1Score = m.Team2Score THEN 'Draw'
		ELSE 'Not Yet Played'
	END AS MatchResult
FROM Matches m
INNER JOIN NationalTeams t1 ON m.Team1ID = t1.TeamID
INNER JOIN NationalTeams t2 ON m.Team2ID = t2.TeamID;
GO

-- 4.2 Booking urgency based on match date
SELECT 
	t.TicketID,
	t.SeatSection,
	t.SeatRow,
	t.SeatNumber,
	b.BookingDate,
	m.MatchDate,
	CASE 
		WHEN DATEDIFF(DAY, GETDATE(), m.MatchDate) < 0   THEN 'Match Already Played'
		WHEN DATEDIFF(DAY, GETDATE(), m.MatchDate) <= 3  THEN 'Last Minute Booking'
		WHEN DATEDIFF(DAY, GETDATE(), m.MatchDate) <= 14 THEN 'Booking Soon'
		ELSE 'Advance Booking'
	END AS BookingUrgency
FROM Tickets t
INNER JOIN Bookings b ON t.BookingID = b.BookingID
INNER JOIN Matches m  ON b.MatchID   = m.MatchID;
GO

-- 4.3 Stadium attendance levels
SELECT 
	m.MatchID,
	m.MatchDate,
	s.StadiumName,
	m.StadiumAttendance,
	s.SeatingCapacity,
	CASE 
		WHEN m.StadiumAttendance < (s.SeatingCapacity * 0.50) THEN 'Low Attendance'
		WHEN m.StadiumAttendance < (s.SeatingCapacity * 0.80) THEN 'Medium Attendance'
		ELSE 'High Attendance'
	END AS AttendanceCategory
FROM Matches m
INNER JOIN Stadiums s ON m.StadiumID = s.StadiumID;
GO

-- 4.4 Group player positions into broad categories
SELECT 
	PlayerID,
	FirstName + ' ' + LastName AS PlayerName,
	Position,
	CASE 
		WHEN Position IN ('Goalkeeper')                                          THEN 'GK'
		WHEN Position IN ('Defender', 'Centre-Back', 'Left-Back', 'Right-Back') THEN 'DEF'
		WHEN Position IN ('Midfielder', 'Defensive Mid',
						  'Attacking Mid', 'Central Mid')                       THEN 'MID'
		WHEN Position IN ('Forward', 'Striker', 'Winger',
						  'Left Wing', 'Right Wing')                            THEN 'ATT'
		ELSE 'Unknown'
	END AS PositionCategory
FROM Players;
GO

-- 4.5 Make booking status more readable
SELECT 
	b.BookingID,
	f.FirstName + ' ' + f.LastName AS FanName,
	b.BookingDate,
	CASE b.BookingStatus
		WHEN 'Confirmed' THEN 'Booking Confirmed - Ticket Ready'
		WHEN 'Pending'   THEN 'Awaiting Payment'
		WHEN 'Cancelled' THEN 'Booking Cancelled'
		ELSE 'Status Unknown'
	END AS StatusDescription
FROM Bookings b
INNER JOIN Fans f ON b.FanID = f.FanID;
GO
