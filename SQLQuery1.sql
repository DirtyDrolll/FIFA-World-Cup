/* -------------------------------------------------------------------------
FIFA WORLD CUP TOURNAMENT DATABASE SCRIPT

----------------------------------------------------------------------------
*/

--//////////////////////Database creation///////////////////////--
Create Database FIFATournamentDB
ON PRIMARY
(
Name=TournamentData1,
FileName='C:\FIFA World Cup\TournData1.mdf',
Size=200MB,
MaxSize=1000MB,
FileGrowth=20MB
)
LOG ON 
(
Name=Tournamentlog1,
FileName='C:\FIFA World Cup\Tournlog1.ldf',
Size=100MB,
MaxSize=500MB,
FileGrowth=10MB
);
GO
--/////////////////////////////////////////////////////////////--

Use FIFATournamentDB;
GO
--//////////////////////Tables creation///////////////////////--
--Reference--
CREATE TABLE Country (
    CountryID INT IDENTITY(1,1) PRIMARY KEY ,
    CountryName NVARCHAR(100) NOT NULL ,
    CONSTRAINT UQ_CountryName UNIQUE (CountryName)
);

CREATE TABLE Cities (
    CityID INT IDENTITY(1,1) PRIMARY KEY ,
    CityName VARCHAR(100) NOT NULL ,
    CountryID INT FOREIGN KEY REFERENCES Country(CountryID) NOT NULL
);

CREATE TABLE Stadiums (
    StadiumID INT IDENTITY(1,1) PRIMARY KEY ,
    StadiumName VARCHAR(100) NOT NULL ,
    SeatingCapacity INT NOT NULL ,
    CityID INT FOREIGN KEY REFERENCES Cities(CityID) NOT NULL,
    CONSTRAINT UQ_StadiumName UNIQUE (StadiumName)
);

CREATE TABLE TicketCategories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY ,
    CategoryName VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Description VARCHAR(255),
    CONSTRAINT UQ_CategoryName UNIQUE (CategoryName)
);
---------------------------

--Participant (Players and Personnel)--
CREATE TABLE NationalTeams (
    TeamID INT PRIMARY KEY IDENTITY(1,1) ,
    GroupLetter CHAR(1) NOT NULL ,
    CountryID INT FOREIGN KEY REFERENCES Country(CountryID) NOT NULL,
    CONSTRAINT UQ_CountryID UNIQUE (CountryID)
);

CREATE TABLE Players (
    PlayerID INT IDENTITY(1,1) PRIMARY KEY ,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Age INT,
    TeamNumber INT,
    Position VARCHAR(50),
    TeamID INT NOT NULL FOREIGN KEY REFERENCES NationalTeams(TeamID),
    CONSTRAINT CH_StadiumName CHECK (Age >= 15)

);
    
CREATE TABLE TeamStaff (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Role VARCHAR(50),
    TeamID INT NOT NULL,
    CONSTRAINT FK_Staff_Teams FOREIGN KEY (TeamID) REFERENCES NationalTeams(TeamID)
);

CREATE TABLE Officials (
    OfficialID INT IDENTITY(1,1) PRIMARY KEY ,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    CountryID INT FOREIGN KEY (CountryID) REFERENCES Country(CountryID) NOT NULL
);
---------------------------

--Match Operations--
CREATE TABLE Matches (
    MatchID INT IDENTITY(1,1) PRIMARY KEY ,
    StadiumID INT NOT NULL,
    Team1ID INT NOT NULL,
    Team2ID INT NOT NULL,
    Team1Score INT DEFAULT 0,
    Team2Score INT DEFAULT 0,
    MatchDate DATETIME NOT NULL,
    TournamentStage VARCHAR(50),
    StadiumAttendance INT,
    CONSTRAINT FK_Match_Stadium FOREIGN KEY (StadiumID) REFERENCES Stadiums(StadiumID),
    CONSTRAINT FK_Match_Team1 FOREIGN KEY (Team1ID) REFERENCES NationalTeams(TeamID),
    CONSTRAINT FK_Match_Team2 FOREIGN KEY (Team2ID) REFERENCES NationalTeams(TeamID)
);

CREATE TABLE MatchEvents (
    EventID INT IDENTITY(1,1) PRIMARY KEY ,
    PlayerID INT NOT NULL,
    MatchID INT NOT NULL,
    EventType VARCHAR(50),
    EventMinute DECIMAL(5,2),
    EventDescription VARCHAR(MAX),
    CONSTRAINT FK_Event_Player FOREIGN KEY (PlayerID) REFERENCES Players(PlayerID),
    CONSTRAINT FK_Event_Match FOREIGN KEY (MatchID) REFERENCES Matches(MatchID)
);

CREATE TABLE TeamStatistics (
    StatsID INT IDENTITY(1,1) PRIMARY KEY ,
    TeamID INT NOT NULL,
    MatchID INT NOT NULL,
    Possession DECIMAL(5,1),
    TotalPasses INT,
    Shots INT,
    ShotsOnTarget INT,
    CONSTRAINT FK_Stats_Team FOREIGN KEY (TeamID) REFERENCES NationalTeams(TeamID),
    CONSTRAINT FK_Stats_Match FOREIGN KEY (MatchID) REFERENCES Matches(MatchID)
);

CREATE TABLE MatchOfficials (
    MatchOfficialID INT IDENTITY(1,1) PRIMARY KEY ,
    OfficialID INT NOT NULL,
    MatchID INT NOT NULL,
    MatchRole VARCHAR(50) NOT NULL,
    CONSTRAINT FK_MatchOff_Official FOREIGN KEY (OfficialID) REFERENCES Officials(OfficialID),
    CONSTRAINT FK_MatchOff_Match FOREIGN KEY (MatchID) REFERENCES Matches(MatchID)
);
 ---------------------------

--Management(Security)--
CREATE TABLE Admins (
    AdminID INT  IDENTITY(1,1) PRIMARY KEY,
    UserName VARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50),
    Surname NVARCHAR(50),
    PasswordHash VARBINARY(64) NOT NULL,
    AdminRole VARCHAR(20),
    LastLogin DATETIME,
    CONSTRAINT UQ_UserName UNIQUE (UserName)
);

CREATE TABLE AdminLogs (
    LogID INT IDENTITY(1,1) PRIMARY KEY ,
    AdminID INT FOREIGN KEY (AdminID) REFERENCES Admins(AdminID) NOT NULL,
    ActionType VARCHAR(50),
    AffectedTable VARCHAR(50),
    ActionTimestamp DATETIME DEFAULT GETDATE(),
    OldValue VARCHAR(MAX),
);
 ---------------------------

--SPECTATOR (Fans and Sales)--
CREATE TABLE Fans (
    FanID INT IDENTITY(1,1) PRIMARY KEY ,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    IdentificationNumber VARCHAR(20) NOT NULL,
    CONSTRAINT UQ_Email UNIQUE (Email),
    CONSTRAINT UQ_IDNum UNIQUE (IdentificationNumber)
);

CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY ,
    FanID INT NOT NULL,
    MatchID INT NOT NULL,
    BookingDate DATETIME DEFAULT GETDATE(),
    BookingStatus VARCHAR(20),
    CONSTRAINT FK_Booking_Fan FOREIGN KEY (FanID) REFERENCES Fans(FanID),
    CONSTRAINT FK_Booking_Match FOREIGN KEY (MatchID) REFERENCES Matches(MatchID),

);

CREATE TABLE Tickets (
    TicketID INT IDENTITY(1,1) PRIMARY KEY ,
    BookingID INT NOT NULL,
    TicketCode VARCHAR(20) NOT NULL,
    PriceWhenPurchased DECIMAL(10,2),
    SeatSection VARCHAR(10),
    SeatNumber INT,
    SeatRow VARCHAR(5),
    CategoryID INT NOT NULL,
    CONSTRAINT UQ_TicketCode UNIQUE (TicketCode),
    CONSTRAINT FK_Ticket_Booking FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID),
    CONSTRAINT FK_Ticket_Category FOREIGN KEY (CategoryID) REFERENCES TicketCategories(CategoryID)
);
---------------------------
GO
--/////////////////////////////////////////////////////////////--

--//////////////////////Database Population///////////////////////--
--Country Data--
INSERT INTO Country (CountryName) VALUES 
('USA'), ('Mexico'), ('Canada'), ('Argentina'), ('France'), 
('Brazil'), ('England'), ('Spain'), ('Portugal'), ('Morocco'), ('Japan');
----------------------------

--City Data--
INSERT INTO Cities (CityName,CountryID) VALUES 
('New York', 1), ('Los Angeles', 1), ('Miami', 1), ('Dallas', 1), ('Atlanta', 1),
('Mexico City', 2), ('Guadalajara', 2), ('Monterrey', 2), 
('Toronto', 3), ('Vancouver', 3);
----------------------------

--Stadium Data--
INSERT INTO Stadiums (StadiumName,SeatingCapacity,CityID) VALUES 
('MetLife Stadium', 82500, 1), ('SoFi Stadium', 70000, 2), 
('Hard Rock Stadium', 64767, 3), ('AT&T Stadium', 80000, 4), ('Mercedes-Benz Stadium', 71000, 5),
('Estadio Azteca', 87523, 6), ('Estadio Akron', 48071, 7), ('Estadio BBVA', 53500, 8), 
('BMO Field', 30000, 9), ('BC Place', 54500, 10);
-----------------------------

--Category Data--
INSERT INTO TicketCategories(CategoryName,Price,Description) VALUES 
('VIP', 2500.00, 'Luxury Lounge'), ('Category 1', 850.00, 'Lower Tier'), 
('Category 2', 450.00, 'Middle Tier'), ('Category 3', 225.00, 'Upper Tier');
------------------------------  

--Team Data--
INSERT INTO NationalTeams(GroupLetter,CountryID) VALUES 
('A', 1), ('A', 2), ('B', 3), ('B', 4), 
('C', 5), ('C', 6), ('D', 7), ('D', 8), 
('E', 9), ('E',11);
-------------------------------

--Player Data--
INSERT INTO Players(FirstName, LastName, Age, TeamNumber, Position, TeamID) VALUES 
(N'Christian', N'Pulisic', 27, 10, 'Forward', 1), (N'Santiago', N'Giménez', 24, 9, 'Forward', 2),
(N'Alphonso', N'Davies', 25, 19, 'Defender', 3), (N'Lionel', N'Messi', 38, 10, 'Forward', 4),
(N'Kylian', N'Mbappé', 27, 10, 'Forward', 5), (N'Vinícius', N'Júnior', 25, 7, 'Forward', 6),
(N'Jude', N'Bellingham', 22, 10, 'Midfield', 7), (N'Lamine', N'Yamal', 18, 19, 'Forward', 8),
(N'Cristiano', N'Ronaldo', 41, 7, 'Forward', 9), (N'Takefusa', N'Kubo', 24, 20, 'Midfield', 10);
-------------------------------

--Staff Data--
INSERT INTO TeamStaff(FirstName, LastName, Role, TeamID) VALUES 
(N'Mauricio', N'Pochettino', 'Head Coach', 1), (N'Javier', N'Aguirre', 'Head Coach', 2),
(N'Jesse', N'Marsch', 'Head Coach', 3), (N'Lionel', N'Scaloni', 'Head Coach', 4),
(N'Didier', N'Deschamps', 'Head Coach', 5), (N'Dorival', N'Júnior', 'Head Coach', 6),
(N'Thomas', N'Tuchel', 'Head Coach', 7), (N'Luis', N'de la Fuente', 'Head Coach', 8),
(N'Roberto', N'Martínez', 'Head Coach', 9), (N'Hajime', N'Moriyasu', 'Head Coach', 10);
-------------------------------

--Official Data--
INSERT INTO Officials(FirstName, LastName, CountryID) VALUES 
(N'Michael', N'Oliver', 7), (N'César', N'Ramos', 2), (N'Iván', N'Barton', 2),
(N'Szymon', N'Marciniak', 8), (N'Daniele', N'Orsato', 9), (N'Wilton', N'Sampaio', 6),
(N'Jesus', N'Valenzuela', 4), (N'Anthony', N'Taylor', 7), (N'Danny', N'Makkelie', 5), (N'Yoshimi', N'Yamashita', 11);
-------------------------------

--Match Data--
INSERT INTO Matches (StadiumID, Team1ID, Team2ID, MatchDate, TournamentStage) VALUES 
(6, 2, 1, '2026-06-11', 'Opening'), (9, 3, 4, '2026-06-12', 'Group'),
(1, 1, 5, '2026-06-13', 'Group'), (2, 6, 7, '2026-06-14', 'Group'),
(3, 8, 9, '2026-06-15', 'Group'), (4, 10, 2, '2026-06-16', 'Group'),
(5, 4, 6, '2026-06-17', 'Group'), (7, 5, 8, '2026-06-18', 'Group'),
(8, 9, 3, '2026-06-19', 'Group'), (10, 7, 10, '2026-06-20', 'Group');
---------------------------------

--Match Officials Data--
INSERT INTO MatchOfficials(OfficialID, MatchID, MatchRole) VALUES 
(1, 1, 'Main Referee'), (2, 1, 'VAR'), (3, 2, 'Main Referee'), (4, 3, 'Main Referee'),
(5, 4, 'Main Referee'), (6, 5, 'Main Referee'), (7, 6, 'Main Referee'), (8, 7, 'Main Referee'),
(9, 8, 'Main Referee'), (10, 9, 'Main Referee'), (1, 10, 'Main Referee');
---------------------------------

--Event Data--
INSERT INTO MatchEvents (PlayerID, MatchID, EventType, EventMinute, EventDescription) VALUES 
(4, 2, 'Goal', 23, 'Header from corner'), (5, 3, 'Goal', 45, 'Solo run'),
(1, 1, 'Yellow Card', 12, 'Tactical foul'), (9, 5, 'Goal', 88, 'Penalty'),
(6, 4, 'Goal', 10, 'Long range shot'), (2, 6, 'Red Card', 75, 'Dangerous tackle'),
(7, 4, 'Goal', 55, 'Tap in'), (8, 8, 'Goal', 30, 'Assist by midfielder'),
(10, 10, 'Goal', 92, 'Counter attack'), (3, 9, 'Yellow Card', 60, 'Handball');
---------------------------------

--Statistic Data--
INSERT INTO TeamStatistics(TeamID, MatchID, Possession, TotalPasses, Shots, ShotsOnTarget) VALUES 
(2, 1, 52.40, 480, 12, 5), (1, 1, 47.60, 410, 8, 3),
(3, 2, 40.25, 300, 5, 2), (4, 2, 59.75, 620, 18, 9),
(5, 3, 55.00, 510, 14, 6), (1, 3, 45.00, 390, 7, 2),
(6, 4, 51.20, 470, 11, 4), (7, 4, 48.80, 430, 9, 3),
(8, 5, 60.10, 650, 20, 10), (9, 5, 39.90, 280, 4, 1);
-----------------------------------

--Fan Data--
INSERT INTO Fans (FirstName, LastName, Email, IdentificationNumber) VALUES 
(N'Alice', N'Green', 'alice@email.com', 'ID1001'), (N'Bob', N'Brown', 'bob@email.com', 'ID1002'),
(N'Charlie', N'Davis', 'charlie@email.com', 'ID1003'), (N'Diana', N'Evans', 'diana@email.com', 'ID1004'),
(N'Ethan', N'Fox', 'ethan@email.com', 'ID1005'), (N'Fiona', N'Gomez', 'fiona@email.com', 'ID1006'),
(N'George', N'Hill', 'george@email.com', 'ID1007'), (N'Hannah', N'Ivers', 'hannah@email.com', 'ID1008'),
(N'Ian', N'Jones', 'ian@email.com', 'ID1009'), (N'Julia', N'King', 'julia@email.com', 'ID1010');
--------------------------------

--Booking Data--
INSERT INTO Bookings (FanID, MatchID, BookingStatus) VALUES 
(1, 1,'Paid'), (2, 1,'Paid'), (3, 2,'Paid'), (4, 3,'Paid'),
(5, 4,'Paid'), (6, 5,'Paid'), (7, 6,'Paid'), (8, 7,'Paid'),
(9, 8,'Paid'), (10, 9,'Paid');
----------------------------------

--Ticket Data--
INSERT INTO Tickets (BookingID, TicketCode, PriceWhenPurchased, SeatSection, SeatNumber, SeatRow, CategoryID) VALUES 
(1, 'TC-001', 2500.00, 'A1', 10, '1', 1), (2, 'TC-002', 850.00, 'B2', 15, '5', 2),
(3, 'TC-003', 450.00, 'C3', 20, '10', 3), (4, 'TC-004', 2500.00, 'A1', 11, '1', 1),
(5, 'TC-005', 850.00, 'B2', 16, '5', 2), (6, 'TC-006', 450.00, 'C3', 21, '10', 3),
(7, 'TC-007', 2500.00, 'A1', 12, '1', 1), (8, 'TC-008', 850.00, 'B2', 17, '5', 2),
(9, 'TC-009', 450.00, 'C3', 22, '10', 3), (10, 'TC-010', 2500.00, 'A1', 13, '1', 1);
-----------------------------------

--Admin Data--
INSERT INTO Admins (UserName, FirstName, Surname, PasswordHash, AdminRole) VALUES 
('superadmin', N'Sarah', N'Miller', 0x123456, 'SuperUser'),
('ticket_mgr', N'Tom', N'Wilson', 0xABCDEF, 'Sales'),
('match_coord', N'Anna', N'Lee', 0x987654, 'Operator');
-------------------------------------

--Admin Log Data--
INSERT INTO AdminLogs(AdminID, ActionType, AffectedTable, OldValue) VALUES 
(1, 'INSERT', 'Stadium', 'New Venue Added'), (1, 'UPDATE', 'Category', 'Price Increase'),
(2, 'INSERT', 'Booking', 'Bulk Ticket Sale'), (3, 'UPDATE', 'Match', 'Time Change'),
(1, 'DELETE', 'Staff', 'Retired Coach'), (2, 'INSERT', 'Fan', 'New Registry'),
(3, 'UPDATE', 'Official', 'Assigned Match'), (1, 'INSERT', 'Player', 'Squad Update'),
(2, 'UPDATE', 'Ticket', 'Seat Reassignment'), (3, 'INSERT', 'Event', 'Goal Recorded');
-------------------------------------
--/////////////////////////////////////////////////////////////--


USE FIFATournamentDB
GO

-------TRIGGERS


--TRIGGER 1: Audit trigger on matches table
-----Logs any UPDATE action on the matches table

CREATE TRIGGER trg_AuditMatchUpdate
ON [dbo].[Matches]
AFTER UPDATE 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @OldScore VARCHAR(MAX)
	DECLARE @MatchID INT

SELECT @MatchID = d.MatchID,
           @OldScore = 'Team1Score: ' + CAST(d.Team1Score AS VARCHAR) 
                     + ' Team2Score: ' + CAST(d.Team2Score AS VARCHAR)
					 FROM deleted d;

/*This column for will trigger updates record into the AdminLogs table*/

INSERT INTO AdminLogs (AdminID, ActionType, AffectedTable, OldValue)
    VALUES (1, 'UPDATE', 'Matches', 'MatchID: ' + CAST(@MatchID AS VARCHAR) + '  Old Scores - ' + @OldScore);
END
GO

--Verification of TRIGGER 1: 

UPDATE Matches SET Team1Score = 2, Team2Score = 1 WHERE MatchID = 1;
SELECT TOP 1 * FROM AdminLogs ORDER BY LogID DESC;
GO

/*TRIGGER 2: Prevent booking a match that has already been played and Blocks INSERT command on Bookings if the match date is in the past*/

CREATE TRIGGER trg_PreventPastMatchBooking
ON Bookings
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
 
    -- Check if any inserted booking references a match with a past date
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Matches m ON i.MatchID = m.MatchID
        WHERE m.MatchDate < GETDATE()
    )
    BEGIN
        RAISERROR('Cannot book tickets for a match that has already been played.', 16, 1); -- used to generate a custom error message in SQL Server.
        RETURN;
    END;
 
/* in the instance the match is in the future, allow the insert update: */

    INSERT INTO Bookings (FanID, MatchID, BookingDate, BookingStatus)
    SELECT FanID, MatchID, BookingDate, BookingStatus
    FROM inserted;
END;
GO

--TRIGGER 3
--Auto-log new player registrations into AdminLog and fires after a new player is inserted into the Players table

CREATE TRIGGER trg_LogNewPlayer
ON Players
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @PlayerInfo VARCHAR(MAX);
 
    -- Build a descriptive string of the new player
    SELECT @PlayerInfo = 'New Player: ' + i.FirstName + ' ' + i.LastName 
                       + ' Team: ' + CAST(i.TeamID AS VARCHAR)
                       + '  Position: ' + ISNULL(i.Position, 'N/A')
    FROM inserted i;
 
    -- Log the action
    INSERT INTO AdminLogs (AdminID, ActionType, AffectedTable, OldValue)
    VALUES (1, 'INSERT', 'Players', @PlayerInfo);
END;
GO

/*verification of Trigger 3
INSERT INTO Players (FirstName, LastName, Age, TeamNumber, Position, TeamID)
VALUES (N'Demo', N'Player', 25, 99, 'Midfield', 1);
SELECT TOP 1 * FROM AdminLogs ORDER BY LogID DESC;

DELETE FROM Players WHERE FirstName = 'Test' AND LastName = 'Player';

*/

GO

---------CURSORS-------------------

--CURSOR 1: Generate a match summary report
-- Iterate through all matches and prints team names with scores

DECLARE @MatchID INT, @Team1ClubName NVARCHAR(100), @Team2ClubName NVARCHAR(100),@Team1Score INT, @Team2Score INT, @MatchDate DATETIME, @Stage VARCHAR(50);
 
DECLARE MatchCursor CURSOR FOR
    SELECT m.MatchID, c1.CountryName, c2.CountryName, 
           m.Team1Score, m.Team2Score, m.MatchDate, m.TournamentStage
    FROM Matches m
    INNER JOIN NationalTeams nt1 ON m.Team1ID = nt1.TeamID
    INNER JOIN Country c1 ON nt1.CountryID = c1.CountryID
    INNER JOIN NationalTeams nt2 ON m.Team2ID = nt2.TeamID
    INNER JOIN Country c2 ON nt2.CountryID = c2.CountryID;
 
OPEN MatchCursor;
FETCH NEXT FROM MatchCursor INTO @MatchID, @Team1ClubName, @Team2ClubName, @Team1Score, @Team2Score, @MatchDate, @Stage;
 
PRINT '             MATCH SUMMARY REPORT                ';
PRINT '';
 
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Match ' + CAST(@MatchID AS VARCHAR) + ' | ' + @Stage 
        + ' | ' + CONVERT(VARCHAR, @MatchDate, 23)
        + ' | ' + @Team1ClubName + ' ' + CAST(@Team1Score AS VARCHAR) 
        + ' - ' + CAST(@Team2Score AS VARCHAR) + ' ' + @Team2ClubName;
 
    FETCH NEXT FROM MatchCursor INTO @MatchID, @Team1ClubName, @Team2ClubName, 
                                      @Team1Score, @Team2Score, @MatchDate, @Stage;
END;
 
CLOSE MatchCursor;
DEALLOCATE MatchCursor;
GO

-- CURSOR 2: Calculate and display total revenue per match which iterates through matches and sums ticket revenue for each

--declaration of all cursors
DECLARE @CurMatchID INT, @MatchLabel VARCHAR(200), @Revenue DECIMAL(10,2); 
 
DECLARE RevenueCursor CURSOR FOR
    SELECT m.MatchID,
           c1.CountryName + ' vs ' + c2.CountryName AS MatchLabel
    FROM Matches m
    INNER JOIN NationalTeams nt1 ON m.Team1ID = nt1.TeamID
    INNER JOIN Country c1 ON nt1.CountryID = c1.CountryID
    INNER JOIN NationalTeams nt2 ON m.Team2ID = nt2.TeamID
    INNER JOIN Country c2 ON nt2.CountryID = c2.CountryID;
 
OPEN RevenueCursor;
FETCH NEXT FROM RevenueCursor INTO @CurMatchID, @MatchLabel;
 
PRINT '			TICKET REVENUE PER MATCH			';
PRINT '';

-- Calculate total ticket revenue for the current match
WHILE @@FETCH_STATUS = 0					
BEGIN
    
    SELECT @Revenue = ISNULL(SUM(t.PriceWhenPurchased), 0)
    FROM Tickets t
    INNER JOIN Bookings b ON t.BookingID = b.BookingID
    WHERE b.MatchID = @CurMatchID;
 
    PRINT @MatchLabel + ' | Revenue: R' + CAST(@Revenue AS VARCHAR);
 
    FETCH NEXT FROM RevenueCursor INTO @CurMatchID, @MatchLabel;
END;
 
CLOSE RevenueCursor;
DEALLOCATE RevenueCursor;
GO
 
 /*TRANSACTION 1: Book a ticket for a fan in multi-tables. Inserts into Bookings and Tickets atomically and if any step fails, the entire operation is rolled back*/

BEGIN TRY
    BEGIN TRANSACTION BookTicketTransaction;
 
--  Create the booking        
INSERT INTO Bookings (FanID, MatchID, BookingStatus)			
VALUES (1, 5, 'Paid');

-- Capture the new BookingID
DECLARE @NewBookingID INT = SCOPE_IDENTITY();			
 
--  Create the ticket linked to the booking      
INSERT INTO Tickets (BookingID, TicketCode, PriceWhenPurchased, SeatSection, SeatNumber, SeatRow, CategoryID)		
VALUES (@NewBookingID, 'TC-011', 850.00, 'B2', 18, '5', 2);
 
    COMMIT TRANSACTION BookTicketTransaction;
    PRINT 'Transaction 1 successful: Booking and ticket created successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION BookTicketTransaction;
    PRINT 'Transaction 1 FAILED: ' + ERROR_MESSAGE();
END CATCH;
GO
