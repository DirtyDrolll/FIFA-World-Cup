USE FIFA_WorldCup2026;
GO

-- ============================================================
-- SECTION 6: FUNCTIONS
-- ============================================================

-- 6.1 Count total goals for a player
CREATE OR ALTER FUNCTION fn_GetPlayerGoalCount
(
	@PlayerID INT
)
RETURNS INT
AS
BEGIN
	DECLARE @GoalCount INT;

	SELECT @GoalCount = COUNT(EventID)
	FROM MatchEvents
	WHERE PlayerID = @PlayerID
	  AND EventType = 'Goal';

	RETURN ISNULL(@GoalCount, 0);
END;
GO
-- Usage: SELECT dbo.fn_GetPlayerGoalCount(1) AS TotalGoals;

-- 6.2 Get formatted match result string
CREATE OR ALTER FUNCTION fn_GetMatchResult
(
	@MatchID INT
)
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @Result NVARCHAR(100);

	SELECT @Result = 
		CAST(m.Team1Score AS NVARCHAR) + ' - ' +
		CAST(m.Team2Score AS NVARCHAR) + ' (' + m.TournamentStage + ')'
	FROM Matches m
	WHERE m.MatchID = @MatchID;

	RETURN ISNULL(@Result, 'Match not found');
END;
GO
-- Usage: SELECT dbo.fn_GetMatchResult(1) AS Result;

-- 6.3 Get all bookings for a fan
CREATE OR ALTER FUNCTION fn_GetFanBookings
(
	@FanID INT
)
RETURNS TABLE
AS
RETURN
(
	SELECT 
		b.BookingID,
		b.MatchID,
		m.MatchDate,
		m.TournamentStage,
		s.StadiumName,
		b.BookingDate,
		b.BookingStatus,
		t.SeatSection,
		t.SeatRow,
		t.SeatNumber,
		t.PriceAtPurchase
	FROM Bookings b
	INNER JOIN Matches m  ON b.MatchID   = m.MatchID
	INNER JOIN Stadiums s ON m.StadiumID = s.StadiumID
	INNER JOIN Tickets t  ON t.BookingID = b.BookingID
	WHERE b.FanID = @FanID
);
GO
-- Usage: SELECT * FROM dbo.fn_GetFanBookings(1);
