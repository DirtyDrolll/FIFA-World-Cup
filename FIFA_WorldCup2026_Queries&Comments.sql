-- ============================================================
-- FIFA World Cup 2026 - Database Queries & Programmability
-- Subject:    Database Development 281
-- ============================================================
-- Contents:
--   Section 1  : Joins
--   Section 2  : Subqueries
--   Section 3  : CTEs (Common Table Expressions)
--   Section 4  : CASE Statements
--   Section 5  : Stored Procedures
--   Section 6  : Functions
--   Section 7  : Views
--   Section 8  : Triggers
--   Section 9  : Cursors
--   Section 10 : Transactions
--   Section 11 : Security - Authentication & Authorization
--   Section 12 : Security - Encryption
-- ============================================================

USE FIFA_WorldCup2026;
GO
-- ============================================================

-- Section 1: Joins
-- INNER JOIN, LEFT JOIN, and multi-table relationships

-- 1.1 Player roster with team group assignments
-- Joins Players to NationalTeams via TeamID foreign key
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

-- 1.2 Complete match schedule with venue details
-- Self-join on NationalTeams for Team1 Team2 chains to Stadiums, Cities, Country
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

-- 1.3 Fan registration status with booking history
-- LEFT JOIN ensures all fans appear, including those without bookings
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

-- 1.4 Match events with player attribution
-- LEFT JOINs handle matches without events and events without player assignments
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

-- 1.5 Ticket details with purchaser information
-- Traverses Tickets -> Bookings -> Fans relationship chain
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

-- 1.6 Match official assignments with nationality
-- Joins junction table MatchOfficials to Matches, Officials, and Country
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

-- 1.7 Coaching staff directory by team
-- Links CoachingStaff to NationalTeams and Country for complete roster
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

-- ============================================================
-- Section 2: Subqueries
-- ============================================================

-- 2.1 Active fans with existing bookings
-- IN clause filters Fans table against derived list of booking holders
SELECT 
    FanID,
    FirstName,
    LastName,
    Email
FROM Fans
WHERE FanID IN
(
    SELECT DISTINCT FanID 
    FROM Bookings
);
GO

-- 2.2 Matches scheduled in above average capacity venues
-- Nested subquery calculates AVG(SeatingCapacity) for comparison
SELECT 
    MatchID,
    MatchDate,
    TournamentStage,
    StadiumAttendance
FROM Matches
WHERE StadiumID IN 
 (
    SELECT StadiumID 
    FROM Stadiums 
    WHERE SeatingCapacity > (
        SELECT AVG(SeatingCapacity) FROM Stadiums
    )
);
GO

-- 2.3 Players with goal scoring records
-- EXISTS subquery identifies players with 'Goal' event types
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

-- 2.4 Teams awaiting their first match
-- NOT IN with UNION excludes teams appearing in either Team 1ID or Team 2ID
SELECT 
    TeamID,
    GroupLetter
FROM NationalTeams
WHERE TeamID NOT IN
(
    SELECT Team1ID FROM Matches
    UNION
    SELECT Team2ID FROM Matches
);
GO

-- 2.5 Correlated subquery: Most recent booking per fan
-- Inner query references outer table (f.FanID) for row specific calculation
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

-- 2.6 Matches exceeding average attendance
-- Scalar subquery computes average excluding NULL (unplayed) matches
SELECT 
    MatchID,
    MatchDate,
    TournamentStage,
    StadiumAttendance
FROM Matches
WHERE StadiumAttendance > 
(
    SELECT AVG(StadiumAttendance) 
    FROM Matches 
    WHERE StadiumAttendance IS NOT NULL
);
GO

-- ============================================================
-- Section 3: CTEs (Common Table Expressions)
-- ============================================================

-- 3.1 Goal scorers ranked by team
-- CTE aggregates goals per player, outer query joins dimensional data
WITH TeamGoalScorers AS
 (
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

-- 3.2 Match popularity ranking by booking volume
-- DENSE_RANK handles ties without gaps in ranking sequence
WITH BookingsPerMatch AS 
(
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

-- 3.3 Player disciplinary records
-- Conditional aggregation via CASE expressions within COUNT
WITH DisciplineRecord AS
 (
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

-- 3.4 Revenue analysis per match
-- CTE calculates SUM of TicketCategories.Price via junction tables
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

-- ============================================================
-- Section 4: CASE Statements
-- ============================================================

-- 4.1 Match outcome determination
-- Evaluates score differentials to classify results, ELSE handles NULL
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

-- 4.2 Booking urgency classification
-- DATEDIFF categorizes bookings by temporal proximity to match date
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

-- 4.3 Stadium attendance categorization
-- Percentage-based thresholds relative to SeatingCapacity
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

-- 4.4 Positional grouping standardization
-- Maps specific positions to generalized role categories
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

-- 4.5 Booking status description mapping
-- Simple CASE for discrete value translation
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

-- ============================================================
-- Section 5: Stored Procedures
-- ============================================================

-- 5.1 Match retrieval by tournament stage
-- Input parameter filters Matches table; returns schedule details
CREATE OR ALTER PROCEDURE usp_GetMatchesByStage
    @Stage NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        m.MatchID,
        m.MatchDate,
        t1.GroupLetter AS Team1,
        t2.GroupLetter AS Team2,
        m.Team1Score,
        m.Team2Score,
        s.StadiumName,
        c.CityName
    FROM Matches m
    INNER JOIN NationalTeams t1 ON m.Team1ID   = t1.TeamID
    INNER JOIN NationalTeams t2 ON m.Team2ID   = t2.TeamID
    INNER JOIN Stadiums s       ON m.StadiumID = s.StadiumID
    INNER JOIN Cities c         ON s.CityID    = c.CityID
    WHERE m.TournamentStage = @Stage;
END;
GO

-- 5.2 Fan registration with duplicate prevention
-- Validates email uniqueness; returns SCOPE_IDENTITY() on success
CREATE OR ALTER PROCEDURE usp_RegisterFan
    @FirstName            NVARCHAR(50),
    @LastName             NVARCHAR(50),
    @Email                NVARCHAR(100),
    @IdentificationNumber NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Fans WHERE Email = @Email)
    BEGIN
        RAISERROR('A fan with this email already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO Fans (FirstName, LastName, Email, IdentificationNumber)
    VALUES (@FirstName, @LastName, @Email, @IdentificationNumber);

    PRINT 'Fan registered successfully with ID: ' + CAST(SCOPE_IDENTITY() AS NVARCHAR);
END;
GO

-- 5.3 Player statistics aggregation by match
-- Pivot-style aggregation using conditional COUNT
CREATE OR ALTER PROCEDURE usp_GetPlayerStatsByMatch
    @MatchID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.FirstName + ' ' + p.LastName                            AS PlayerName,
        p.Position,
        co.CountryName                                            AS Team,
        COUNT(CASE WHEN me.EventType = 'Goal'        THEN 1 END) AS Goals,
        COUNT(CASE WHEN me.EventType = 'Assist'      THEN 1 END) AS Assists,
        COUNT(CASE WHEN me.EventType = 'Yellow Card' THEN 1 END) AS YellowCards,
        COUNT(CASE WHEN me.EventType = 'Red Card'    THEN 1 END) AS RedCards
    FROM MatchEvents me
    INNER JOIN Players p        ON me.PlayerID  = p.PlayerID
    INNER JOIN NationalTeams nt ON p.TeamID     = nt.TeamID
    INNER JOIN Country co       ON nt.CountryID = co.CountryID
    WHERE me.MatchID = @MatchID
    GROUP BY p.PlayerID, p.FirstName, p.LastName, p.Position, co.CountryName
    ORDER BY Goals DESC;
END;
GO

-- ============================================================
-- Section 6: Functions
-- ============================================================

-- 6.1 Scalar function: Player goal tally
-- Returns COUNT of 'Goal' events per PlayerID, ISNULL handles NULL
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

-- 6.2 Scalar function: Formatted match result
-- Concatenates scores and tournament stage into descriptive string
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

-- 6.3 Inline table-valued function: Fan booking history
-- Returns table result set for use in FROM clauses
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

-- ============================================================
-- Section 7: Views
-- ============================================================

-- 7.1 Comprehensive match schedule view
-- Denormalizes match data including teams, venue, and host country
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

-- 7.2 Player statistics summary view
-- Aggregates events across all matches per player
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

-- 7.3 Ticket sales metrics per match
-- Aggregates revenue and ticket counts with averaging
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

-- ============================================================
-- Section 8: Triggers
-- ============================================================

-- 8.1 Audit logging for match deletions
-- AFTER DELETE trigger capturing deleted rows to AdminLogs
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

-- 8.2 Multiple booking prevention with 4-ticket limit
-- AFTER INSERT validation limiting fans to maximum 4 bookings per match
CREATE OR ALTER TRIGGER trg_PreventDuplicateBooking
ON Bookings
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verify fan hasn't exceeded 4 bookings for the same match
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE (
            SELECT COUNT(*)
            FROM Bookings b
            WHERE b.FanID = i.FanID
              AND b.MatchID = i.MatchID
        ) > 4
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('A fan cannot have more than 4 bookings for the same match.', 16, 1);
    END;
END;
GO

-- 8.3 Automatic booking confirmation on ticket issuance
-- Updates BookingStatus from 'Pending' to 'Confirmed'
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

-- ============================================================
-- Section 9: Cursors
-- ============================================================

-- 9.1 Match summary report generation
-- Iterates Matches result set for PRINT output
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

-- 9.2 Expired pending booking cancellation
-- Cursor-based update for bookings exceeding 7-day pending threshold
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

-- ============================================================
-- Section 10: Transactions
-- ============================================================

-- 10.1 Atomic booking and ticket creation
-- Ensures both Booking and Ticket rows succeed or fail together
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

-- 10.2 Match score update with audit logging
-- Dual operation atomicity: data modification + audit trail
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

-- 10.3 Cascading fan deletion with booking cancellation
-- Updates child records before parent deletion within transaction boundary
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

-- ============================================================
-- Section 11: Security - Authentication & Authorization
-- ============================================================

-- 11.1 SQL Server authentication login creation
-- CHECK_POLICY enforces complexity; CHECK_EXPIRATION enables password aging
CREATE LOGIN TournamentAdmin 
WITH PASSWORD         = 'Adm!nS3cur3#2026',
     CHECK_POLICY     = ON,
     CHECK_EXPIRATION = ON;
GO

-- 11.2 Database user mapping
-- Associates server login with database security context
CREATE USER TournamentAdmin FOR LOGIN TournamentAdmin;
GO

-- 11.3 Role-based access for reporting
-- Custom role with SELECT permissions on specific views only
CREATE ROLE db_ReportViewer;
GO

GRANT SELECT ON vw_MatchSchedule       TO db_ReportViewer;
GRANT SELECT ON vw_PlayerStatsSummary  TO db_ReportViewer;
GRANT SELECT ON vw_TicketSalesOverview TO db_ReportViewer;
GO

-- 11.4 Data manipulation permissions for administrators
-- Explicit GRANT on tables and EXECUTE on stored procedures
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

-- 11.5 Explicit deny permissions
-- DENY overrides GRANT; prevents deletion of critical entities
DENY DELETE ON Matches       TO TournamentAdmin;
DENY DELETE ON NationalTeams TO TournamentAdmin;
GO

-- ============================================================
-- Section 12: Security - Encryption
-- ============================================================

-- 12.1 Database Master Key creation
-- Root encryption key protected by password
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'M@sterKey#2026!';
GO

-- 12.2 Certificate creation
-- Protects symmetric key; contains public/private key pair
CREATE CERTIFICATE FIFA_Cert
    WITH SUBJECT = 'FIFA WorldCup 2026 Data Protection';
GO

-- 12.3 Symmetric key creation
-- AES_256 algorithm for data encryption/decryption operations
CREATE SYMMETRIC KEY FIFA_SymKey
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE FIFA_Cert;
GO

-- 12.4 Data encryption implementation
-- Adds VARBINARY column and encrypts existing identification data
ALTER TABLE Fans ADD EncryptedIDNumber VARBINARY(256);
GO

OPEN SYMMETRIC KEY FIFA_SymKey
    DECRYPTION BY CERTIFICATE FIFA_Cert;

UPDATE Fans
SET EncryptedIDNumber = ENCRYPTBYKEY(
    KEY_GUID('FIFA_SymKey'),
    CONVERT(NVARCHAR(50), IdentificationNumber)
);

CLOSE SYMMETRIC KEY FIFA_SymKey;
GO

-- 12.5 Data decryption query
-- Opens key, decrypts VARBINARY to NVARCHAR, closes key
OPEN SYMMETRIC KEY FIFA_SymKey
    DECRYPTION BY CERTIFICATE FIFA_Cert;

SELECT 
    FanID,
    FirstName,
    LastName,
    CONVERT(NVARCHAR(50), DECRYPTBYKEY(EncryptedIDNumber)) AS DecryptedID
FROM Fans;

CLOSE SYMMETRIC KEY FIFA_SymKey;
GO

-- ============================================================
-- END OF SCRIPT
-- ============================================================