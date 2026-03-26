USE FIFA_WorldCup2026;
GO

-- ============================================================
-- SECTION 10: TRANSACTIONS
-- ============================================================

-- 10.1 Create a booking and ticket together
BEGIN TRANSACTION;

BEGIN TRY
	INSERT INTO Bookings (FanID, MatchID, CategoryID, BookingDate, SeatNumber, BookingStatus)
	VALUES (1, 1, 1, GETDATE(), 'A12', 'Pending');

	DECLARE @NewBookingID INT = SCOPE_IDENTITY();

	INSERT INTO Tickets (BookingID, TicketCode, PriceAtPurchase, SeatSection, SeatRow, SeatNumber)
	VALUES (@NewBookingID, 'WC2026-A12-001', 250.00, 'A', '1', '12');

	COMMIT TRANSACTION;
	PRINT 'Booking and ticket created successfully.';
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	PRINT 'Transaction failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 10.2 Update match score and log it together
BEGIN TRANSACTION;

BEGIN TRY
	UPDATE Matches
	SET Team1Score = 2, Team2Score = 1
	WHERE MatchID = 1;

	INSERT INTO AdminLogs (ActionType, AffectedTable, ActionTimeStamp, OldValue)
	VALUES ('UPDATE', 'Matches', GETDATE(), 'MatchID 1 score updated to 2-1');

	COMMIT TRANSACTION;
	PRINT 'Match score updated and logged successfully.';
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	PRINT 'Transaction failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 10.3 Delete a fan and their bookings together
BEGIN TRANSACTION;

BEGIN TRY
	DECLARE @FanToDelete INT = 5;

	UPDATE Bookings
	SET BookingStatus = 'Cancelled'
	WHERE FanID = @FanToDelete;

	DELETE FROM Fans
	WHERE FanID = @FanToDelete;

	COMMIT TRANSACTION;
	PRINT 'Fan and associated bookings removed successfully.';
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	PRINT 'Transaction failed: ' + ERROR_MESSAGE();
END CATCH;
GO
