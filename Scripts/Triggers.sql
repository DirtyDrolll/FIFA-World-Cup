USE FIFA_WorldCup2026;
GO

-- ============================================================
-- SECTION 8: TRIGGERS
-- ============================================================

-- 8.1 Log when matches get deleted
CREATE OR ALTER TRIGGER trg_LogMatchDelete
ON Matches
AFTER DELETE
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO AdminLogs (ActionType, AffectedTable, ActionTimeStamp, OldValue)
	SELECT 
		'DELETE',
		'Matches',
		GETDATE(),
		'MatchID: ' + CAST(d.MatchID AS NVARCHAR) 
		+ ' | Stage: ' + d.TournamentStage
	FROM deleted d;
END;
GO

-- 8.2 Stop fans from booking the same match twice
CREATE OR ALTER TRIGGER trg_PreventDuplicateBooking
ON Bookings
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (
		SELECT 1
		FROM Bookings b
		INNER JOIN inserted i 
			ON  b.FanID    = i.FanID
			AND b.MatchID  = i.MatchID
			AND b.BookingID <> i.BookingID
	)
	BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR('This fan already has a booking for this match.', 16, 1);
	END;
END;
GO

-- 8.3 Auto-confirm bookings when a ticket is created
CREATE OR ALTER TRIGGER trg_ConfirmBookingOnTicket
ON Tickets
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Bookings
	SET BookingStatus = 'Confirmed'
	FROM Bookings b
	INNER JOIN inserted i ON b.BookingID = i.BookingID
	WHERE b.BookingStatus = 'Pending';
END;
GO
