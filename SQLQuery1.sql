/* -------------------------------------------------------------------------
FIFA WORLD CUP TOURNAMENT DATABASE SCRIPT

NOTE:Change your path for "\TournData1.mdf" and "\Tournlog1.ldf" at FileName to your
     file path this is saved on.
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
