/* -------------------------------------------------------------------------
FIFA WORLD CUP TOURNAMENT DATABASE SCRIPT

NOTE: Uses default SQL Server file paths for database creation to prevent 
      "Directory lookup failed" OS errors.
----------------------------------------------------------------------------
*/

USE master;
GO

--//////////////////////Database creation///////////////////////--
-- Drop database if it exists to ensure a clean slate
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'FIFATournamentDB')
BEGIN
    ALTER DATABASE FIFATournamentDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FIFATournamentDB;
END
GO

-- Create fresh database using default SQL Server directories
CREATE DATABASE FIFATournamentDB;
GO
--/////////////////////////////////////////////////////////////--

Use FIFATournamentDB;
GO
--//////////////////////Tables creation///////////////////////--
--Reference--
--First checks if the table does not exist, before creating
IF 
OBJECT_ID           -- Finds an object's internal ID number
('Country',         -- The specific name of the table being looked for
'U')                --Tells SQL to ONLY look for User defined Tables
IS NULL        
Begin
CREATE TABLE Country (
    CountryID INT IDENTITY(1,1) PRIMARY KEY ,
    CountryName NVARCHAR(100) NOT NULL ,
    CONSTRAINT UQ_CountryName UNIQUE (CountryName)
);
End;

IF OBJECT_ID('Cities','U') IS NULL 
Begin
CREATE TABLE Cities (
    CityID INT IDENTITY(1,1) PRIMARY KEY ,
    CityName VARCHAR(100) NOT NULL ,
    CountryID INT FOREIGN KEY REFERENCES Country(CountryID) NOT NULL
);
End;

IF OBJECT_ID('Stadiums','U') IS NULL 
Begin
CREATE TABLE Stadiums (
    StadiumID INT IDENTITY(1,1) PRIMARY KEY ,
    StadiumName VARCHAR(100) NOT NULL ,
    SeatingCapacity INT NOT NULL ,
    CityID INT FOREIGN KEY REFERENCES Cities(CityID) NOT NULL,
    CONSTRAINT UQ_StadiumName UNIQUE (StadiumName)
);
End;

IF OBJECT_ID('TicketCategories','U') IS NULL 
Begin
CREATE TABLE TicketCategories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY ,
    CategoryName VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Description VARCHAR(255),
    CONSTRAINT UQ_CategoryName UNIQUE (CategoryName)
);
End;
---------------------------

--Participant (Players and Personnel)--
IF OBJECT_ID('NationalTeams','U') IS NULL 
Begin
CREATE TABLE NationalTeams (
    TeamID INT PRIMARY KEY IDENTITY(1,1) ,
    GroupLetter CHAR(1) NOT NULL ,
    CountryID INT FOREIGN KEY REFERENCES Country(CountryID) NOT NULL,
    CONSTRAINT UQ_CountryID UNIQUE (CountryID)
);
End;

IF OBJECT_ID('Players','U') IS NULL 
Begin
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
End;

IF OBJECT_ID('TeamStaff','U') IS NULL 
Begin
CREATE TABLE TeamStaff (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Role VARCHAR(50),
    TeamID INT NOT NULL,
    CONSTRAINT FK_Staff_Teams FOREIGN KEY (TeamID) REFERENCES NationalTeams(TeamID)
);
End;

IF OBJECT_ID('Officials','U') IS NULL 
Begin
CREATE TABLE Officials (
    OfficialID INT IDENTITY(1,1) PRIMARY KEY ,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    CountryID INT FOREIGN KEY (CountryID) REFERENCES Country(CountryID) NOT NULL
);
End;
---------------------------

--Match Operations--
IF OBJECT_ID('Matches','U') IS NULL 
Begin
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
End;

IF OBJECT_ID('MatchEvents','U') IS NULL 
Begin
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
End;

IF OBJECT_ID('TeamStatistics','U') IS NULL 
Begin
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
End;

IF OBJECT_ID('MatchOfficials','U') IS NULL 
Begin
CREATE TABLE MatchOfficials (
    MatchOfficialID INT IDENTITY(1,1) PRIMARY KEY ,
    OfficialID INT NOT NULL,
    MatchID INT NOT NULL,
    MatchRole VARCHAR(50) NOT NULL,
    CONSTRAINT FK_MatchOff_Official FOREIGN KEY (OfficialID) REFERENCES Officials(OfficialID),
    CONSTRAINT FK_MatchOff_Match FOREIGN KEY (MatchID) REFERENCES Matches(MatchID)
);
End;
 ---------------------------

--Management(Security)--
IF OBJECT_ID('Admins','U') IS NULL 
Begin
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
End;

IF OBJECT_ID('AdminLogs','U') IS NULL 
Begin
CREATE TABLE AdminLogs (
    LogID INT IDENTITY(1,1) PRIMARY KEY ,
    AdminID INT FOREIGN KEY (AdminID) REFERENCES Admins(AdminID) NOT NULL,
    ActionType VARCHAR(50),
    AffectedTable VARCHAR(50),
    ActionTimestamp DATETIME DEFAULT GETDATE(),
    OldValue VARCHAR(MAX),
);
End;
 ---------------------------

--SPECTATOR (Fans and Sales)--
IF OBJECT_ID('Fans','U') IS NULL 
Begin
CREATE TABLE Fans (
    FanID INT IDENTITY(1,1) PRIMARY KEY ,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    IdentificationNumber VARCHAR(20) NOT NULL,
    CONSTRAINT UQ_Email UNIQUE (Email),
    CONSTRAINT UQ_IDNum UNIQUE (IdentificationNumber)
);
End;

IF OBJECT_ID('Bookings','U') IS NULL 
Begin
CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY ,
    FanID INT NOT NULL,
    MatchID INT NOT NULL,
    BookingDate DATETIME DEFAULT GETDATE(),
    BookingStatus VARCHAR(20),
    CONSTRAINT FK_Booking_Fan FOREIGN KEY (FanID) REFERENCES Fans(FanID),
    CONSTRAINT FK_Booking_Match FOREIGN KEY (MatchID) REFERENCES Matches(MatchID),
);
End;

IF OBJECT_ID('Tickets','U') IS NULL 
Begin
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
End;
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
(N'Christian', N'Pulisic', 27, 10, 'Forward', 1),
 (N'Santiago', N'Gim�nez', 24, 9, 'Forward', 2),
(N'Alphonso', N'Davies', 25, 19, 'Defender', 3),
 (N'Lionel', N'Messi', 38, 10, 'Forward', 4),
(N'Kylian', N'Mbapp�', 27, 10, 'Forward', 5), 
(N'Vin�cius', N'J�nior', 25, 7, 'Forward', 6),
(N'Jude', N'Bellingham', 22, 10, 'Midfield', 7),
 (N'Lamine', N'Yamal', 18, 19, 'Forward', 8),
(N'Cristiano', N'Ronaldo', 41, 7, 'Forward', 9), 
(N'Takefusa', N'Kubo', 24, 20, 'Midfield', 10),
(N'Brenden', N'Aaronson', 25, 11, 'Midfield', 1),
(N'Che', N'Adams', 29, 10, 'Forward', 1),
(N'Tyler', N'Adams', 27, 4, 'Midfield', 1),
(N'Ahmed', N'Al-Rawi', 21, 21, 'Forward', 1),
(N'Oswin', N'Appollis', 24, 44, 'Forward', 1),
(N'Max', N'Arfsten', 24, 27, 'Defender', 1),
(N'Folarin', N'Balogun', 24, 20, 'Forward', 1),
(N'Meshaal', N'Barsham', 28, 22, 'Goalkeeper', 1),
(N'Sebastian', N'Berhalter', 24, 16, 'Midfield', 1),
(N'Johnny', N'Cardoso', 24, 15, 'Midfield', 1),
(N'Ahmed', N'Fathi', 33, 8, 'Midfield', 1),
(N'Lewis', N'Ferguson', 26, 19, 'Midfield', 1),
(N'Alex', N'Freeman', 21, 15, 'Defender', 1),
(N'Matt', N'Freese', 27, 49, 'Goalkeeper', 1),
(N'Craig', N'Gordon', 43, 1, 'Goalkeeper', 1),
(N'Diego', N'Luna', 22, 26, 'Forward', 1),
(N'Weston', N'McKennie', 27, 8, 'Midfield', 1),
(N'Mark', N'McKenzie', 27, 5, 'Defender', 1),
(N'Aidan', N'Morris', 24, 8, 'Midfield', 1),
(N'Yunus', N'Musah', 23, 6, 'Midfield', 1),
(N'Ricardo', N'Pepi', 23, 9, 'Forward', 1),
(N'Tim', N'Ream', 38, 13, 'Defender', 1),
(N'Chris', N'Richards', 26, 3, 'Defender', 1),
(N'Antonee', N'Robinson', 28, 5, 'Defender', 1),
(N'Miles', N'Robinson', 29, 12, 'Defender', 1),
(N'Joe', N'Scally', 23, 29, 'Defender', 1),
(N'Patrick', N'Schulte', 25, 28, 'Goalkeeper', 1),
(N'Kieran', N'Tierney', 28, 3, 'Defender', 1),
(N'Malik', N'Tillman', 23, 10, 'Midfield', 1),
(N'John', N'Tolkin', 23, 47, 'Defender', 1),
(N'Matt', N'Turner', 31, 1, 'Goalkeeper', 1),
(N'Tim', N'Weah', 26, 21, 'Forward', 1),
(N'Haji', N'Wright', 28, 19, 'Forward', 1),
(N'Josh', N'Doig', 24, 3, 'Defender', 2),
(N'Bongokuhle', N'Hlongwane', 26, 21, 'Forward', 2),
(N'Boualem', N'Khoukhi', 36, 16, 'Defender', 2),
(N'Khuliso', N'Mudau', 31, 20, 'Defender', 2),
(N'Mohammed', N'Muntari', 33, 19, 'Forward', 2),
(N'Youssef', N'Abdurisag', 27, 9, 'Forward', 3),
(N'Akram', N'Afif', 30, 11, 'Forward', 3),
(N'Ali', N'Ahmed', 26, 22, 'Forward', 3),
(N'Mo�se', N'Bombito', 26, 15, 'Defender', 3),
(N'Tajon', N'Buchanan', 27, 17, 'Forward', 3),
(N'Mathieu', N'Choini�re', 27, 29, 'Midfield', 3),
(N'Ryan', N'Christie', 31, 11, 'Midfield', 3),
(N'Derek', N'Cornelius', 29, 13, 'Defender', 3),
(N'Maxime', N'Cr�peau', 32, 16, 'Goalkeeper', 3),
(N'Jonathan', N'David', 26, 20, 'Forward', 3),
(N'Stephen', N'Eust�quio', 30, 7, 'Midfield', 3),
(N'Jassem', N'Gaber', 24, 15, 'Midfield', 3),
(N'Owen', N'Goodman', 23, 1, 'Goalkeeper', 3),
(N'Alistair', N'Johnston', 28, 2, 'Defender', 3),
(N'Isma�l', N'Kon�', 24, 8, 'Midfield', 3),
(N'Cyle', N'Larin', 31, 17, 'Forward', 3),
(N'Richie', N'Laryea', 31, 22, 'Defender', 3),
(N'Mbekezeli', N'Mbokazi', 25, 4, 'Defender', 3),
(N'Liam', N'Millar', 27, 23, 'Forward', 3),
(N'Kamal', N'Miller', 29, 4, 'Defender', 3),
(N'Relebohile', N'Mofokeng', 22, 28, 'Forward', 3),
(N'Tani', N'Oluwaseyi', 26, 14, 'Forward', 3),
(N'Jonathan', N'Osorio', 34, 21, 'Midfield', 3),
(N'Anthony', N'Ralston', 28, 2, 'Defender', 3),
(N'Nathan', N'Saliba', 22, 19, 'Midfield', 3),
(N'Jacob', N'Shaffelburg', 27, 14, 'Forward', 3),
(N'Nkosinathi', N'Sibisi', 31, 5, 'Defender', 3),
(N'Niko', N'Sigur', 23, 8, 'Midfield', 3),
(N'Dayne', N'St. Clair', 29, 97, 'Goalkeeper', 3),
(N'Joel', N'Waterman', 30, 16, 'Defender', 3),
(N'Ronwen', N'Williams', 34, 30, 'Goalkeeper', 3),
(N'Luc', N'de Fougerolles', 21, 24, 'Defender', 3),
(N'Scott', N'McTominay', 30, 4, 'Midfield', 4),
(N'Lennon', N'Miller', 20, 38, 'Midfield', 4),
(N'Iqraam', N'Rayners', 31, 9, 'Forward', 4),
(N'Mostafa', N'Tarek', 25, 21, 'Midfield', 4),
(N'Bradley', N'Barcola', 24, 29, 'Forward', 5),
(N'Karim', N'Boudiaf', 36, 12, 'Midfield', 5),
(N'Eduardo', N'Camavinga', 24, 12, 'Midfield', 5),
(N'Lucas', N'Chevalier', 25, 30, 'Goalkeeper', 5),
(N'Ousmane', N'Demb�l�', 29, 10, 'Forward', 5),
(N'Wesley', N'Fofana', 26, 3, 'Defender', 5),
(N'Malo', N'Gusto', 23, 27, 'Defender', 5),
(N'Jack', N'Hendry', 31, 13, 'Defender', 5),
(N'Lucas', N'Hernandez', 30, 21, 'Defender', 5),
(N'Th�o', N'Hernandez', 29, 22, 'Defender', 5),
(N'Randal', N'Kolo Muani', 28, 23, 'Forward', 5),
(N'Ibrahima', N'Konat�', 27, 24, 'Defender', 5),
(N'Manu', N'Kon�', 25, 17, 'Midfield', 5),
(N'Jules', N'Kound�', 28, 5, 'Defender', 5),
(N'Mike', N'Maignan', 31, 16, 'Goalkeeper', 5),
(N'Kylian', N'Mbapp�', 28, 9, 'Forward', 5),
(N'Christopher', N'Nkunku', 29, 18, 'Forward', 5),
(N'Michael', N'Olise', 25, 17, 'Midfield', 5),
(N'Adrien', N'Rabiot', 31, 25, 'Midfield', 5),
(N'Andy', N'Robertson', 32, 3, 'Defender', 5),
(N'William', N'Saliba', 25, 2, 'Defender', 5),
(N'Brice', N'Samba', 32, 1, 'Goalkeeper', 5),
(N'Sphephelo', N'Sithole', 27, 15, 'Midfield', 5),
(N'Aur�lien', N'Tchouam�ni', 26, 8, 'Midfield', 5),
(N'Mathys', N'Tel', 21, 39, 'Forward', 5),
(N'Marcus', N'Thuram', 29, 9, 'Forward', 5),
(N'Dayot', N'Upamecano', 28, 2, 'Defender', 5),
(N'Warren', N'Za�re-Emery', 20, 33, 'Midfield', 5),
(N'Alisson', N'Becker', 34, 1, 'Goalkeeper', 6),
(N'Bento', N'Bento', 27, 12, 'Goalkeeper', 6),
(N'Lucas', N'Beraldo', 23, 17, 'Defender', 6),
(N'Bremer', N'Bremer', 29, 25, 'Defender', 6),
(N'Casemiro', N'Casemiro', 34, 5, 'Midfield', 6),
(N'Sipho', N'Chaine', 30, 22, 'Goalkeeper', 6),
(N'Danilo', N'Danilo', 35, 2, 'Defender', 6),
(N'Lyndon', N'Dykes', 31, 9, 'Forward', 6),
(N'Ederson', N'Ederson', 33, 23, 'Goalkeeper', 6),
(N'Endrick', N'Endrick', 20, 9, 'Forward', 6),
(N'Lyle', N'Foster', 26, 9, 'Forward', 6),
(N'Jo�o', N'Gomes', 25, 15, 'Midfield', 6),
(N'Ricardo', N'Goss', 32, 1, 'Goalkeeper', 6),
(N'Brunos', N'Guimares', 29, 39, 'Midfield', 6),
(N'Angus', N'Gunn', 30, 1, 'Goalkeeper', 6),
(N'Abdulaziz', N'Hatem', 36, 6, 'Midfield', 6),
(N'Vin�cius', N'J�nior', 26, 7, 'Forward', 6),
(N'Douglas', N'Luiz', 28, 6, 'Midfield', 6),
(N'Gabriel', N'Magalh�es', 29, 4, 'Defender', 6),
(N'Marquinhos', N'Marquinhos', 32, 5, 'Defender', 6),
(N'Gabriel', N'Martinelli', 25, 11, 'Forward', 6),
(N'John', N'McGinn', 32, 7, 'Midfield', 6),
(N'Lucas', N'Mendes', 36, 12, 'Defender', 6),
(N'�der', N'Milit�o', 28, 3, 'Defender', 6),
(N'Ime', N'Okon', 22, 14, 'Defender', 6),
(N'Lucas', N'Paquet�', 29, 8, 'Midfield', 6),
(N'Jo�o', N'Pedro', 25, 9, 'Forward', 6),
(N'Raphinha', N'Raphinha', 30, 11, 'Forward', 6),
(N'Richarlison', N'Richarlison', 29, 9, 'Forward', 6),
(N'Rodrygo', N'Rodrygo', 25, 10, 'Forward', 6),
(N'Alex', N'Sandro', 35, 6, 'Defender', 6),
(N'Andrey', N'Santos', 22, 8, 'Midfield', 6),
(N'Savinho', N'Savinho', 22, 26, 'Forward', 6),
(N'Lawrence', N'Shankland', 31, 10, 'Forward', 6),
(N'Tylon', N'Smith', 21, 2, 'Defender', 6),
(N'Vanderson', N'Vanderson', 25, 2, 'Defender', 6),
(N'Al-Hashmi', N'Al-Hussain', 31, 3, 'Defender', 7),
(N'Saad', N'Al-Sheeb', 36, 1, 'Goalkeeper', 7),
(N'Trent', N'Alexander-Arnold', 28, 66, 'Defender', 7),
(N'Jarrod', N'Bowen', 30, 20, 'Forward', 7),
(N'Levi', N'Colwill', 23, 26, 'Defender', 7),
(N'Eberechi', N'Eze', 28, 10, 'Forward', 7),
(N'Phil', N'Foden', 26, 47, 'Forward', 7),
(N'Anthony', N'Gordon', 25, 11, 'Forward', 7),
(N'Marc', N'Gu�hi', 26, 6, 'Defender', 7),
(N'Dean', N'Henderson', 29, 1, 'Goalkeeper', 7),
(N'Reece', N'James', 27, 24, 'Defender', 7),
(N'Harry', N'Kane', 33, 9, 'Forward', 7),
(N'Liam', N'Kelly', 30, 1, 'Goalkeeper', 7),
(N'Ezri', N'Konsa', 29, 4, 'Defender', 7),
(N'Myles', N'Lewis-Skelly', 20, 49, 'Defender', 7),
(N'Tino', N'Livramento', 24, 21, 'Defender', 7),
(N'Kobbie', N'Mainoo', 21, 37, 'Midfield', 7),
(N'Olwethu', N'Makhanya', 22, 5, 'Defender', 7),
(N'Scott', N'McKenna', 30, 26, 'Defender', 7),
(N'Pedro', N'Miguel', 36, 2, 'Defender', 7),
(N'Siyabonga', N'Ngezana', 29, 30, 'Defender', 7),
(N'Cole', N'Palmer', 24, 20, 'Midfield', 7),
(N'Jordan', N'Pickford', 32, 1, 'Goalkeeper', 7),
(N'Aaron', N'Ramsdale', 28, 1, 'Goalkeeper', 7),
(N'Marcus', N'Rashford', 29, 10, 'Forward', 7),
(N'Declan', N'Rice', 27, 41, 'Midfield', 7),
(N'Morgan', N'Rogers', 24, 27, 'Midfield', 7),
(N'Bukayo', N'Saka', 25, 7, 'Forward', 7),
(N'John', N'Stones', 32, 5, 'Defender', 7),
(N'Adam', N'Wharton', 22, 20, 'Midfield', 7),
(N'Jayden', N'Adams', 25, 23, 'Midfield', 8),
(N'Samu', N'Aghehowa', 22, 9, 'Forward', 8),
(N'Ahmed', N'Alaaeldin', 33, 11, 'Forward', 8),
(N'�lex', N'Baena', 25, 16, 'Midfield', 8),
(N'Scott', N'Bain', 35, 29, 'Goalkeeper', 8),
(N'Dani', N'Carvajal', 34, 2, 'Defender', 8),
(N'Pau', N'Cubars�', 19, 33, 'Defender', 8),
(N'Marc', N'Cucurella', 28, 3, 'Defender', 8),
(N'Ben', N'Gannon-Doak', 21, 17, 'Midfield', 8),
(N'Gavi', N'Gavi', 22, 6, 'Midfield', 8),
(N'Alejandro', N'Grimaldo', 31, 20, 'Defender', 8),
(N'Aaron', N'Hickey', 24, 2, 'Defender', 8),
(N'Dean', N'Huijsen', 21, 2, 'Defender', 8),
(N'Aymeric', N'Laporte', 32, 14, 'Defender', 8),
(N'Robin', N'Le Normand', 30, 3, 'Defender', 8),
(N'Evidence', N'Makgopa', 26, 9, 'Forward', 8),
(N'Thalente', N'Mbatha', 26, 42, 'Midfield', 8),
(N'Mikel', N'Merino', 30, 8, 'Midfield', 8),
(N'�lvaro', N'Morata', 34, 7, 'Forward', 8),
(N'Dani', N'Olmo', 28, 10, 'Midfield', 8),
(N'Mikel', N'Oyarzabal', 29, 21, 'Forward', 8),
(N'Pedri', N'Pedri', 24, 8, 'Midfield', 8),
(N'Yeremy', N'Pino', 24, 21, 'Forward', 8),
(N'Pedro', N'Porro', 27, 23, 'Defender', 8),
(N'David', N'Raya', 31, 1, 'Goalkeeper', 8),
(N'�lex', N'Remiro', 31, 1, 'Goalkeeper', 8),
(N'Rodri', N'Rodri', 30, 16, 'Midfield', 8),
(N'Fabi�n', N'Ruiz', 30, 8, 'Midfield', 8),
(N'Tarek', N'Salman', 29, 15, 'Defender', 8),
(N'Unai', N'Sim�n', 29, 23, 'Goalkeeper', 8),
(N'Ferran', N'Torres', 26, 11, 'Forward', 8),
(N'Nico', N'Williams', 24, 17, 'Forward', 8),
(N'Martin', N'Zubimendi', 27, 4, 'Midfield', 8),
(N'Mahmoud', N'Abunada', 26, 21, 'Goalkeeper', 9),
(N'Jo�o', N'Cancelo', 32, 20, 'Defender', 9),
(N'Francisco', N'Concei��o', 24, 26, 'Forward', 9),
(N'Diogo', N'Costa', 27, 22, 'Goalkeeper', 9),
(N'Diogo', N'Dalot', 27, 20, 'Defender', 9),
(N'R�ben', N'Dias', 29, 3, 'Defender', 9),
(N'Brunos', N'Fernandes', 32, 8, 'Midfield', 9),
(N'Jo�o', N'F�lix', 27, 11, 'Forward', 9),
(N'Billy', N'Gilmour', 25, 14, 'Midfield', 9),
(N'Grant', N'Hanley', 35, 5, 'Defender', 9),
(N'George', N'Hirst', 27, 14, 'Forward', 9),
(N'Gon�alo', N'In�cio', 25, 25, 'Defender', 9),
(N'Diogo', N'Jota', 30, 20, 'Forward', 9),
(N'Luke', N'Le Roux', 26, 14, 'Midfield', 9),
(N'Rafael', N'Le�o', 27, 17, 'Forward', 9),
(N'Patrick', N'Maswanganyi', 28, 10, 'Midfield', 9),
(N'Kenny', N'McLean', 34, 23, 'Midfield', 9),
(N'Nuno', N'Mendes', 24, 19, 'Defender', 9),
(N'Aubrey', N'Modiba', 31, 17, 'Defender', 9),
(N'Pedro', N'Neto', 26, 7, 'Forward', 9),
(N'Jo�o', N'Neves', 22, 87, 'Midfield', 9),
(N'R�ben', N'Neves', 29, 18, 'Midfield', 9),
(N'Mohau', N'Nkota', 22, 28, 'Forward', 9),
(N'Ot�vio', N'Ot�vio', 31, 25, 'Midfield', 9),
(N'Jo�o', N'Palhinha', 31, 6, 'Midfield', 9),
(N'Gon�alo', N'Ramos', 25, 9, 'Forward', 9),
(N'N�lson', N'Semedo', 33, 2, 'Defender', 9),
(N'Ant�nio', N'Silva', 23, 4, 'Defender', 9),
(N'Bernardo', N'Silva', 32, 10, 'Midfield', 9),
(N'Rui', N'Silva', 32, 1, 'Goalkeeper', 9),
(N'Jos�', N'S�', 33, 1, 'Goalkeeper', 9),
(N'Renato', N'Veiga', 23, 40, 'Defender', 9),
(N'Vitinha', N'Vitinha', 26, 23, 'Midfield', 9),
(N'Mohammed', N'Waad', 27, 4, 'Defender', 9),
(N'Themba', N'Zwane', 37, 11, 'Midfield', 9),
(N'Homam', N'Al-Amin', 27, 14, 'Defender', 10),
(N'Sultan', N'Al-Brake', 30, 22, 'Defender', 10),
(N'Hassan', N'Al-Haydos', 36, 10, 'Forward', 10),
(N'Almoez', N'Ali', 30, 19, 'Forward', 10),
(N'Assim', N'Madibo', 30, 23, 'Midfield', 10),
(N'Teboho', N'Mokoena', 29, 4, 'Midfield', 10),
(N'John', N'Souttar', 30, 13, 'Defender', 10);
-------------------------------

--Staff Data--
INSERT INTO TeamStaff(FirstName, LastName, Role, TeamID) VALUES 
(N'Mauricio', N'Pochettino', 'Head Coach', 1), (N'Javier', N'Aguirre', 'Head Coach', 2),
(N'Jesse', N'Marsch', 'Head Coach', 3), (N'Lionel', N'Scaloni', 'Head Coach', 4),
(N'Didier', N'Deschamps', 'Head Coach', 5), (N'Dorival', N'J�nior', 'Head Coach', 6),
(N'Thomas', N'Tuchel', 'Head Coach', 7), (N'Luis', N'de la Fuente', 'Head Coach', 8),
(N'Roberto', N'Mart�nez', 'Head Coach', 9), (N'Hajime', N'Moriyasu', 'Head Coach', 10);
-------------------------------

--Official Data--
INSERT INTO Officials(FirstName, LastName, CountryID) VALUES 
(N'Michael', N'Oliver', 7), (N'C�sar', N'Ramos', 2), (N'Iv�n', N'Barton', 2),
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
(N'Kevin', N'Lewis', 'kevin@email.com', 'ID1011'), 
(N'Laura', N'Martin', 'laura@email.com', 'ID1012'),
(N'Mason', N'Nelson', 'mason@email.com', 'ID1013'), 
(N'Nora', N'Owens', 'nora@email.com', 'ID1014'),
(N'Oliver', N'Perez', 'oliver@email.com', 'ID1015'), 
(N'Penelope', N'Quinn', 'penelope@email.com', 'ID1016'),
(N'Quincy', N'Roberts', 'quincy@email.com', 'ID1017'), 
(N'Rachel', N'Smith', 'rachel@email.com', 'ID1018'),
(N'Samuel', N'Taylor', 'samuel@email.com', 'ID1019'), 
(N'Tina', N'Underwood', 'tina@email.com', 'ID1020'),
(N'Ulysses', N'Vance', 'ulysses@email.com', 'ID1021'), 
(N'Victoria', N'White', 'victoria@email.com', 'ID1022'),
(N'William', N'Xavier', 'william@email.com', 'ID1023'), 
(N'Xena', N'Yates', 'xena@email.com', 'ID1024'),
(N'Yusuf', N'Zane', 'yusuf@email.com', 'ID1025'), 
(N'Zara', N'Adams', 'zara@email.com', 'ID1026'),
(N'Aaron', N'Baker', 'aaron@email.com', 'ID1027'), 
(N'Bella', N'Clark', 'bella@email.com', 'ID1028'),
(N'Caleb', N'Dixon', 'caleb@email.com', 'ID1029'), 
(N'Delilah', N'Ellis', 'delilah@email.com', 'ID1030');
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
--/////////////////////////////////////////////////////////////--Use FIFATournamentDB;


-- ============================================================
-- FIFA World Cup 2026 - Database Queries & Programmability
-- Subject:Database Development 281
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

Use FIFATournamentDB;
GO
-- ============================================================

-- Section 1: Joins
-- INNER JOIN, LEFT JOIN, and multi-table relationships

-- Player roster with team group assignments
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

-- Complete match schedule with venue details
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

-- Fan registration status with booking history
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

-- Match events with player attribution
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

-- Ticket details with purchaser information
-- Traverses Tickets -> Bookings -> Fans relationship chain
SELECT 
    t.TicketID,
    t.TicketCode,
    t.SeatSection,
    t.SeatRow,
    t.SeatNumber,
    t.PriceWhenPurchased,
    f.FirstName + ' ' + f.LastName AS FanName,
    f.Email,
    b.BookingDate,
    b.BookingStatus
FROM Tickets t
INNER JOIN Bookings b ON t.BookingID = b.BookingID
INNER JOIN Fans f     ON b.FanID     = f.FanID;
GO

-- Match official assignments with nationality
-- Joins junction table MatchOfficials to Matches, Officials, and Country
SELECT 
    m.MatchID,
    m.MatchDate,
    m.TournamentStage,
    o.FirstName + ' ' + o.LastName AS OfficialName,
    mo.MatchRole                   AS OfficialRole,
    c.CountryName                  AS OfficialNationality
FROM MatchOfficials mo
INNER JOIN Matches m   ON mo.MatchID    = m.MatchID
INNER JOIN Officials o ON mo.OfficialID = o.OfficialID
INNER JOIN Country c   ON o.CountryID   = c.CountryID;
GO

-- Team staff directory by team
-- Links TeamStaff to NationalTeams and Country for complete roster
SELECT 
    cs.StaffID,
    cs.FirstName + ' ' + cs.LastName AS StaffName,
    cs.Role,
    nt.GroupLetter,
    co.CountryName
FROM TeamStaff cs
INNER JOIN NationalTeams nt ON cs.TeamID    = nt.TeamID
INNER JOIN Country co       ON nt.CountryID = co.CountryID;
GO

-- ============================================================
-- Section 2: Subqueries
-- ============================================================

-- Active fans with existing bookings
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

-- Matches scheduled in above average capacity venues
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

-- Players with goal scoring records
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

-- Teams awaiting their first match
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

-- Correlated subquery: Most recent booking per fan
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

-- Matches exceeding average attendance
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

-- Goal scorers ranked by team
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

-- Match popularity ranking by booking volume
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

-- Player disciplinary records
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

-- Revenue analysis per match
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

-- Match outcome determination
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

-- Booking urgency classification
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

-- Stadium attendance categorization
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

-- Positional grouping standardization
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

-- Booking status description mapping
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

-- Match retrieval by tournament stage
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

-- Fan registration with duplicate prevention
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

-- Player statistics aggregation by match
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

-- Scalar function: Player goal tally
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

-- Scalar function: Formatted match result
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

-- Inline table-valued function: Fan booking history
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
        t.PriceWhenPurchased
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

-- Comprehensive match schedule view
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

-- Player statistics summary view
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

-- Ticket sales metrics per match
-- Aggregates revenue and ticket counts with averaging
CREATE OR ALTER VIEW vw_TicketSalesOverview AS
SELECT 
    m.MatchID,
    m.MatchDate,
    m.TournamentStage,
    s.StadiumName,
    COUNT(t.TicketID)  AS TotalTicketsSold,
    SUM(t.PriceWhenPurchased) AS TotalRevenue,
    AVG(t.PriceWhenPurchased) AS AvgTicketPrice
FROM Tickets t
INNER JOIN Bookings b          ON t.BookingID  = b.BookingID
INNER JOIN Matches m           ON b.MatchID    = m.MatchID
INNER JOIN Stadiums s          ON m.StadiumID  = s.StadiumID
GROUP BY m.MatchID, m.MatchDate, m.TournamentStage, s.StadiumName;
GO

-- ============================================================
-- Section 8: Triggers
-- ============================================================

-- Audit logging for match deletions
-- AFTER DELETE trigger capturing deleted rows to AdminLogs
CREATE OR ALTER TRIGGER trg_LogMatchDelete
ON Matches
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AdminLogs (AdminID, ActionType, AffectedTable, ActionTimeStamp, OldValue)
    SELECT 
        1,
        'DELETE',
        'Matches',
        GETDATE(),
        'MatchID: ' + CAST(d.MatchID AS NVARCHAR) 
        + ' | Stage: ' + d.TournamentStage
    FROM deleted d;
END;
GO

-- Multiple booking prevention with 4-ticket limit
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

-- Automatic booking confirmation on ticket issuance
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

-- Match summary report generation
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

-- Expired pending booking cancellation
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

-- Atomic booking and ticket creation
-- Ensures both Booking and Ticket rows succeed or fail together
BEGIN TRANSACTION;

BEGIN TRY
    -- Insert booking without invalid columns
    INSERT INTO Bookings (FanID, MatchID, BookingDate, BookingStatus)
    VALUES (1, 1, GETDATE(), 'Pending');

    DECLARE @NewBookingID INT = SCOPE_IDENTITY();

    -- Insert ticket with correct column name
    INSERT INTO Tickets (BookingID, TicketCode, PriceWhenPurchased, 
                        SeatSection, SeatRow, SeatNumber, CategoryID)
    VALUES (@NewBookingID, 'WC2026-A12-001', 250.00, 'A', '1', 12, 1);

    COMMIT TRANSACTION;
    PRINT 'Booking and ticket created successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Transaction failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Match score update with audit logging
-- Dual operation atomicity: data modification + audit trail
BEGIN TRANSACTION;

BEGIN TRY
    UPDATE Matches
    SET Team1Score = 2, Team2Score = 1
    WHERE MatchID = 1;

    -- Added AdminID
    INSERT INTO AdminLogs (AdminID, ActionType, AffectedTable, ActionTimeStamp, OldValue)
    VALUES (1, 'UPDATE', 'Matches', GETDATE(), 'MatchID 1 score updated to 2-1');

    COMMIT TRANSACTION;
    PRINT 'Match score updated and logged successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Transaction failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Cascading fan deletion with booking cancellation
-- Updates child records before parent deletion within transaction boundary
BEGIN TRANSACTION;

BEGIN TRY
    DECLARE @FanToDelete INT = 20;  -- Using fan 20 to avoid conflicts

    -- Delete tickets first
    DELETE FROM Tickets
    WHERE BookingID IN (
        SELECT BookingID FROM Bookings WHERE FanID = @FanToDelete
    );

    -- Then delete bookings
    DELETE FROM Bookings
    WHERE FanID = @FanToDelete;

    -- Finally delete the fan
    DELETE FROM Fans
    WHERE FanID = @FanToDelete;

    COMMIT TRANSACTION;
    PRINT 'Fan and associated records removed successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Transaction failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- Section 11: Security - Authentication & Authorization
-- ============================================================

-- SQL Server authentication login creation
-- CHECK_POLICY enforces complexity; CHECK_EXPIRATION enables password aging
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'TournamentAdmin')
BEGIN
    CREATE LOGIN TournamentAdmin 
    WITH PASSWORD         = 'Adm!nS3cur3#2026',
         CHECK_POLICY     = ON,
         CHECK_EXPIRATION = ON;
END
GO

-- Database user mapping
-- Associates server login with database security context
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'TournamentAdmin')
BEGIN
    CREATE USER TournamentAdmin FOR LOGIN TournamentAdmin;
END
GO

-- Role-based access for reporting
-- Custom role with SELECT permissions on specific views only
CREATE ROLE db_ReportViewer;
GO

GRANT SELECT ON vw_MatchSchedule       TO db_ReportViewer;
GRANT SELECT ON vw_PlayerStatsSummary  TO db_ReportViewer;
GRANT SELECT ON vw_TicketSalesOverview TO db_ReportViewer;
GO

-- Data manipulation permissions for administrators
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

-- Explicit deny permissions
-- DENY overrides GRANT; prevents deletion of critical entities
DENY DELETE ON Matches       TO TournamentAdmin;
DENY DELETE ON NationalTeams TO TournamentAdmin;
GO

-- ============================================================
-- Section 12: Security - Encryption
-- ============================================================

-- Database Master Key creation
-- Root encryption key protected by password
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'M@sterKey#2026!';
GO

-- Certificate creation
-- Protects symmetric key, contains public/private key pair
CREATE CERTIFICATE FIFA_Cert
    WITH SUBJECT = 'FIFA WorldCup 2026 Data Protection';
GO

-- Symmetric key creation
-- AES_256 algorithm for data encryption/decryption operations
CREATE SYMMETRIC KEY FIFA_SymKey
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE FIFA_Cert;
GO

-- Data encryption implementation
-- Adds VARBINARY column and encrypts existing identification data
ALTER TABLE Fans ADD EncryptedIDNumber VARBINARY(32);
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

-- Data decryption query
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
