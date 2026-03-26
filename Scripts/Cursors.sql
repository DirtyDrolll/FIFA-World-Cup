USE FIFA_WorldCup2026;
GO

-- ============================================================
-- SECTION 9: CURSORS
-- ============================================================

-- 9.1 Print a summary line for each match
DECLARE @MatchID     INT,
		@MatchDate   DATE,
		@Stage       NVARCHAR(50),
		@Team1Score  INT,
		@Team2Score  INT,
		@StadiumName NVARCHAR(100);

DECLARE cur_MatchSummary CURSOR FOR
	SELECT m.MatchID, m.MatchDate, m.TournamentStage,
		   m.Team1Score, m.Team2Score, s.StadiumName
	FROM Matches m
	INNER JOIN Stadiums s ON m.StadiumID = s.StadiumID
	ORDER BY m.MatchDate;

OPEN cur_MatchSummary;

FETCH NEXT FROM cur_MatchSummary 
INTO @MatchID, @MatchDate, @Stage, @Team1Score, @Team2Score, @StadiumName;

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT 'Match ' + CAST(@MatchID AS NVARCHAR)
		+ ' | ' + @Stage
		+ ' | ' + CAST(@MatchDate AS NVARCHAR)
		+ ' | Score: ' + CAST(ISNULL(@Team1Score, 0) AS NVARCHAR)
		+ '-'          + CAST(ISNULL(@Team2Score, 0) AS NVARCHAR)
		+ ' | Venue: ' + @StadiumName;

	FETCH NEXT FROM cur_MatchSummary 
	INTO @MatchID, @MatchDate, @Stage, @Team1Score, @Team2Score, @StadiumName;
END;

CLOSE cur_MatchSummary;
DEALLOCATE cur_MatchSummary;
GO

-- 9.2 Cancel old pending bookings
DECLARE @BookingID   INT,
		@BookingDate DATE,
		@Status      NVARCHAR(20);

DECLARE cur_ExpiredBookings CURSOR FOR
	SELECT BookingID, BookingDate, BookingStatus
	FROM Bookings
	WHERE BookingStatus = 'Pending'
	  AND BookingDate < DATEADD(DAY, -7, GETDATE());

OPEN cur_ExpiredBookings;

FETCH NEXT FROM cur_ExpiredBookings 
INTO @BookingID, @BookingDate, @Status;

WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE Bookings
	SET BookingStatus = 'Cancelled'
	WHERE BookingID = @BookingID;

	PRINT 'Cancelled expired booking ID: ' + CAST(@BookingID AS NVARCHAR);

	FETCH NEXT FROM cur_ExpiredBookings 
	INTO @BookingID, @BookingDate, @Status;
END;

CLOSE cur_ExpiredBookings;
DEALLOCATE cur_ExpiredBookings;
GO
