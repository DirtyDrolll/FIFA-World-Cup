-- ============================================================
-- FIFA World Cup 2026 - Database Queries & Programmability
-- Subject:    Database Development 271/281
-- Assessment: Project
-- ============================================================
-- What we're covering in this script:
--   Section 1  : Joins
--   Section 2  : Subqueries
--   Section 3  : CTEs
--   Section 4  : CASE Statements
--   Section 5  : Stored Procedures
--   Section 6  : Functions
--   Section 7  : Views
--   Section 8  : Triggers
--   Section 9  : Cursors
--   Section 10 : Transactions
--   Section 11 : Security - Authentication
--   Section 12 : Security - Encryption
-- ============================================================

USE FIFA_WorldCup2026;
GO

-- ============================================================
-- SECTION 1: JOINS
-- Joins let you combine data from multiple tables. Think of it
-- like matching puzzle pieces - you connect tables where their
-- columns match up. INNER JOIN only shows matching rows,
-- LEFT JOIN shows everything from the left table even if there's
-- no match on the right (fills with NULLs).
-- ============================================================

-- 1.1 Show all players with their team's group letter
--     Links Players to NationalTeams using TeamID
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
--     We join NationalTeams twice (as t1 and t2) because each match
--     has two teams. Then we chain through Stadiums -> Cities -> Country
--     to get all the location info
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
--     LEFT JOIN here means fans without bookings still show up
--     with NULL in the booking columns - useful for seeing who
--     registered but hasn't bought tickets yet
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
--     LEFT JOIN because matches that haven't been played yet won't
--     have any events. Also some events like "Half Time" don't link
--     to a specific player, so we LEFT JOIN Players too
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
--     Following the chain: Tickets -> Bookings -> Fans
--     INNER JOIN is fine here because every ticket must have
--     a booking and every booking must have a fan
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
--     MatchOfficials is a junction table that links refs to matches
--     We also grab the official's nationality from Country
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
--     Shows which coaches work for which country
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
-- SECTION 2: SUBQUERIES
-- A query inside another query. You can use them in WHERE, FROM,
-- or SELECT clauses. They're great for filtering based on
-- calculated results or other table data.
-- ============================================================

-- 2.1 Only fans who've actually made a booking
--     The inner query gets all FanIDs that have bookings,
--     then the outer query filters to just those fans
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
--     Inner query calculates average stadium size,
--     middle query finds big stadiums,
--     outer query gets matches in those stadiums
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
--     Checks MatchEvents for goal records and filters players to just those
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
--     UNION combines teams from both Team1ID and Team2ID columns
--     so we catch teams that played in either position.
--     NOT IN then excludes all those teams, leaving only unplayed teams
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
--     This is a "correlated" subquery because the inner query references
--     the outer query (f.FanID). It runs once per fan row
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
--     Subquery calculates the average (ignoring unplayed matches),
--     then we filter to matches above that average
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

-- ============================================================
-- SECTION 3: CTEs (Common Table Expressions)
-- Think of CTEs as temporary named result sets that exist just
-- for your query. They make complex queries way more readable
-- by breaking them into logical steps. Use WITH to define them.
-- ============================================================

-- 3.1 Top scorers per team
--     First we count goals per player in the CTE,
--     then join it with team/country info for the final result
WITH TeamGoalScorers AS (
    SELECT 
        p.TeamID,
        p.PlayerID,
        p.FirstName + ' ' + p.LastName AS PlayerName,
        COUNT(me.EventID) AS TotalGoals  -- count goal events
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
--     Count bookings per match, then rank them.
--     DENSE_RANK means ties get the same rank and the next rank
--     doesn't skip (1,1,2 not 1,1,3)
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
--     Using CASE inside COUNT to count specific event types.
--     CASE returns 1 when it matches, NULL otherwise.
--     COUNT ignores NULLs, so we only count the matches
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
--     Sum up all ticket prices for each match.
--     Prices come from TicketCategories, not directly from Tickets
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
-- SECTION 4: CASE STATEMENTS
-- SQL's version of if/else. Checks conditions top-to-bottom
-- and returns the first match. Super useful for categorizing
-- or transforming data on the fly.
-- ============================================================

-- 4.1 Who won each match?
--     Compare the scores and label the result.
--     ELSE catches unplayed matches where scores are NULL
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
--     Labels bookings as last-minute, soon, or advance based on
--     days remaining until the match
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
--     Categorize attendance as low/medium/high based on % of capacity.
--     Uses percentages so it works for stadiums of any size
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
--     Maps specific positions like "Left-Back" into general categories
--     like "DEF" for easier analysis
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
--     Turns codes like "Confirmed" into full descriptions
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
-- SECTION 5: STORED PROCEDURES
-- Pre-written SQL blocks you can execute by name. Great for
-- code reuse and security - users can run the proc without
-- needing direct table access. SET NOCOUNT ON stops the
-- "X rows affected" messages from cluttering the output.
-- ============================================================

-- 5.1 Get all matches for a specific tournament stage
--     Pass in a stage like 'Group Stage' or 'Final'
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

-- 5.2 Register a new fan
--     Checks for duplicate emails first. If email exists, throws an
--     error and stops. Otherwise creates the fan and returns their new ID
CREATE OR ALTER PROCEDURE usp_RegisterFan
    @FirstName            NVARCHAR(50),
    @LastName             NVARCHAR(50),
    @Email                NVARCHAR(100),
    @IdentificationNumber NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Stop if email already exists
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

-- 5.3 Get player stats for a specific match
--     Counts goals, assists, and cards per player in the match
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
-- SECTION 6: FUNCTIONS
-- Return values that you can use in other queries. Scalar functions
-- return a single value. Table-valued functions return a whole table
-- you can query like any other table.
-- ============================================================

-- 6.1 Count total goals for a player
--     Returns 0 if they haven't scored (instead of NULL)
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
--     Returns something like "2 - 1 (Quarter-Final)"
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
--     Returns a table you can query. Way more efficient than
--     a multi-statement function
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

-- ============================================================
-- SECTION 7: VIEWS
-- Saved SELECT statements. They don't store data themselves,
-- just re-run the query whenever you access them. Great for
-- simplifying complex queries and controlling what data users see.
-- ============================================================

-- 7.1 Complete match schedule view
--     Joins everything together - teams, stadium, location info.
--     Country is joined 3 times: for Team1, Team2, and host country
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
--     One row per player with all their totals
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
--     Shows how many tickets sold and how much money made
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
-- SECTION 8: TRIGGERS
-- Code that fires automatically when something happens to a table
-- (INSERT, UPDATE, DELETE). Inside triggers you get two magic tables:
--   inserted : the new data being added/updated
--   deleted  : the old data being removed/changed
-- ============================================================

-- 8.1 Log when matches get deleted
--     Records what got deleted in an audit table
CREATE OR ALTER TRIGGER trg_LogMatchDelete
ON Matches
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- 'deleted' table contains the rows that just got removed
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
--     Checks if they already have a booking for this match.
--     If yes, rolls back the insert and throws an error
CREATE OR ALTER TRIGGER trg_PreventDuplicateBooking
ON Bookings
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- 'inserted' table has the new booking row we just added
    IF EXISTS (
        SELECT 1
        FROM Bookings b
        INNER JOIN inserted i 
            ON  b.FanID    = i.FanID
            AND b.MatchID  = i.MatchID
            AND b.BookingID <> i.BookingID  -- don't compare to itself
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('This fan already has a booking for this match.', 16, 1);
    END;
END;
GO

-- 8.3 Auto-confirm bookings when a ticket is created
--     When a ticket gets inserted, find its booking and
--     change status from 'Pending' to 'Confirmed'
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
-- SECTION 9: CURSORS
-- Process result sets row-by-row instead of all at once.
-- Steps: DECLARE -> OPEN -> FETCH (in loop) -> CLOSE -> DEALLOCATE
-- @@FETCH_STATUS = 0 means we got a row, anything else means we're done
-- Note: Cursors are slower than set-based operations, use them sparingly
-- ============================================================

-- 9.1 Print a summary line for each match
DECLARE @MatchID     INT,
        @MatchDate   DATE,
        @Stage       NVARCHAR(50),
        @Team1Score  INT,
        @Team2Score  INT,
        @StadiumName NVARCHAR(100);

-- Define what data we're looping through
DECLARE cur_MatchSummary CURSOR FOR
    SELECT m.MatchID, m.MatchDate, m.TournamentStage,
           m.Team1Score, m.Team2Score, s.StadiumName
    FROM Matches m
    INNER JOIN Stadiums s ON m.StadiumID = s.StadiumID
    ORDER BY m.MatchDate;

OPEN cur_MatchSummary;

-- Get the first row
FETCH NEXT FROM cur_MatchSummary 
INTO @MatchID, @MatchDate, @Stage, @Team1Score, @Team2Score, @StadiumName;

-- Loop until no more rows
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Match ' + CAST(@MatchID AS NVARCHAR)
        + ' | ' + @Stage
        + ' | ' + CAST(@MatchDate AS NVARCHAR)
        + ' | Score: ' + CAST(ISNULL(@Team1Score, 0) AS NVARCHAR)
        + '-'          + CAST(ISNULL(@Team2Score, 0) AS NVARCHAR)
        + ' | Venue: ' + @StadiumName;

    -- Get next row
    FETCH NEXT FROM cur_MatchSummary 
    INTO @MatchID, @MatchDate, @Stage, @Team1Score, @Team2Score, @StadiumName;
END;

-- Clean up
CLOSE cur_MatchSummary;
DEALLOCATE cur_MatchSummary;
GO

-- 9.2 Cancel old pending bookings
--     Finds bookings older than 7 days and cancels them one by one
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
-- SECTION 10: TRANSACTIONS
-- Wrap multiple statements into one all-or-nothing unit.
-- Either everything succeeds (COMMIT) or everything fails (ROLLBACK).
-- TRY/CATCH handles errors - if anything fails in TRY, jump to CATCH
-- and roll everything back. Keeps your data consistent.
-- ============================================================

-- 10.1 Create a booking and ticket together
--      If either fails, both get rolled back - no orphaned data
BEGIN TRANSACTION;

BEGIN TRY
    -- Insert the booking
    INSERT INTO Bookings (FanID, MatchID, CategoryID, BookingDate, SeatNumber, BookingStatus)
    VALUES (1, 1, 1, GETDATE(), 'A12', 'Pending');

    -- Get the ID we just created
    DECLARE @NewBookingID INT = SCOPE_IDENTITY();

    -- Insert the ticket linked to that booking
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
--      Both the score update and audit log must succeed as one unit
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
--      Cancel their bookings first, then delete the fan.
--      If either fails, both roll back
BEGIN TRANSACTION;

BEGIN TRY
    DECLARE @FanToDelete INT = 5;

    -- Cancel all their bookings first
    UPDATE Bookings
    SET BookingStatus = 'Cancelled'
    WHERE FanID = @FanToDelete;

    -- Then remove the fan
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
-- SECTION 11: SECURITY - AUTHENTICATION
-- Two ways to log in: Windows (uses your OS account) or
-- SQL Server (username + password).
-- Roles group permissions so you can assign them to multiple users.
-- GRANT gives permission, DENY blocks it (overrides GRANT),
-- REVOKE removes it.
-- ============================================================

-- 11.1 Create a SQL login for an admin
--      CHECK_POLICY enforces strong passwords
--      CHECK_EXPIRATION makes them change it periodically
CREATE LOGIN TournamentAdmin 
WITH PASSWORD         = 'Adm!nS3cur3#2026',
     CHECK_POLICY     = ON,
     CHECK_EXPIRATION = ON;
GO

-- 11.2 Create a database user for that login
--      Login = server level, User = database level
CREATE USER TournamentAdmin FOR LOGIN TournamentAdmin;
GO

-- 11.3 Create a read-only role for reports
--      Give them access to views only, not raw tables
CREATE ROLE db_ReportViewer;
GO

GRANT SELECT ON vw_MatchSchedule       TO db_ReportViewer;
GRANT SELECT ON vw_PlayerStatsSummary  TO db_ReportViewer;
GRANT SELECT ON vw_TicketSalesOverview TO db_ReportViewer;
GO

-- 11.4 Give admin rights to manage data
--      Can read/write tables and run stored procedures
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

-- 11.5 Block deletes on critical tables
--      DENY beats GRANT, so even if they get another role that
--      allows delete, this will still block it
DENY DELETE ON Matches       TO TournamentAdmin;
DENY DELETE ON NationalTeams TO TournamentAdmin;
GO

-- ============================================================
-- SECTION 12: SECURITY - ENCRYPTION
-- Three-layer key system:
--   1. Master Key - protected by password (root of everything)
--   2. Certificate - protects the symmetric key
--   3. Symmetric Key - actually encrypts your data (AES-256)
-- Always OPEN the key before encrypting/decrypting,
-- then CLOSE it right after to minimize exposure.
-- ============================================================

-- 12.1 Create the master key
--      This is required before anything else. Keep the password safe!
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'M@sterKey#2026!';
GO

-- 12.2 Create a certificate
--      This protects the symmetric key below
CREATE CERTIFICATE FIFA_Cert
    WITH SUBJECT = 'FIFA WorldCup 2026 Data Protection';
GO

-- 12.3 Create the symmetric key that does the actual encryption
--      Using AES-256 (industry standard)
CREATE SYMMETRIC KEY FIFA_SymKey
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE FIFA_Cert;
GO

-- 12.4 Add a column to store encrypted data
ALTER TABLE Fans ADD EncryptedIDNumber VARBINARY(256);
GO

-- Encrypt all existing ID numbers
OPEN SYMMETRIC KEY FIFA_SymKey
    DECRYPTION BY CERTIFICATE FIFA_Cert;

UPDATE Fans
SET EncryptedIDNumber = ENCRYPTBYKEY(
    KEY_GUID('FIFA_SymKey'),
    CONVERT(NVARCHAR(50), IdentificationNumber)
);

-- Always close the key when done
CLOSE SYMMETRIC KEY FIFA_SymKey;
GO

-- 12.5 Decrypt the data to read it
--      Open key, decrypt, close key
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