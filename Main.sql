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
(N'Christian', N'Pulisic', 27, 10, 'Forward', 1),
 (N'Santiago', N'Giménez', 24, 9, 'Forward', 2),
(N'Alphonso', N'Davies', 25, 19, 'Defender', 3),
 (N'Lionel', N'Messi', 38, 10, 'Forward', 4),
(N'Kylian', N'Mbappé', 27, 10, 'Forward', 5), 
(N'Vinícius', N'Júnior', 25, 7, 'Forward', 6),
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
(N'Moïse', N'Bombito', 26, 15, 'Defender', 3),
(N'Tajon', N'Buchanan', 27, 17, 'Forward', 3),
(N'Mathieu', N'Choinière', 27, 29, 'Midfield', 3),
(N'Ryan', N'Christie', 31, 11, 'Midfield', 3),
(N'Derek', N'Cornelius', 29, 13, 'Defender', 3),
(N'Maxime', N'Crépeau', 32, 16, 'Goalkeeper', 3),
(N'Jonathan', N'David', 26, 20, 'Forward', 3),
(N'Stephen', N'Eustáquio', 30, 7, 'Midfield', 3),
(N'Jassem', N'Gaber', 24, 15, 'Midfield', 3),
(N'Owen', N'Goodman', 23, 1, 'Goalkeeper', 3),
(N'Alistair', N'Johnston', 28, 2, 'Defender', 3),
(N'Ismaël', N'Koné', 24, 8, 'Midfield', 3),
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
(N'Ousmane', N'Dembélé', 29, 10, 'Forward', 5),
(N'Wesley', N'Fofana', 26, 3, 'Defender', 5),
(N'Malo', N'Gusto', 23, 27, 'Defender', 5),
(N'Jack', N'Hendry', 31, 13, 'Defender', 5),
(N'Lucas', N'Hernandez', 30, 21, 'Defender', 5),
(N'Théo', N'Hernandez', 29, 22, 'Defender', 5),
(N'Randal', N'Kolo Muani', 28, 23, 'Forward', 5),
(N'Ibrahima', N'Konaté', 27, 24, 'Defender', 5),
(N'Manu', N'Koné', 25, 17, 'Midfield', 5),
(N'Jules', N'Koundé', 28, 5, 'Defender', 5),
(N'Mike', N'Maignan', 31, 16, 'Goalkeeper', 5),
(N'Kylian', N'Mbappé', 28, 9, 'Forward', 5),
(N'Christopher', N'Nkunku', 29, 18, 'Forward', 5),
(N'Michael', N'Olise', 25, 17, 'Midfield', 5),
(N'Adrien', N'Rabiot', 31, 25, 'Midfield', 5),
(N'Andy', N'Robertson', 32, 3, 'Defender', 5),
(N'William', N'Saliba', 25, 2, 'Defender', 5),
(N'Brice', N'Samba', 32, 1, 'Goalkeeper', 5),
(N'Sphephelo', N'Sithole', 27, 15, 'Midfield', 5),
(N'Aurélien', N'Tchouaméni', 26, 8, 'Midfield', 5),
(N'Mathys', N'Tel', 21, 39, 'Forward', 5),
(N'Marcus', N'Thuram', 29, 9, 'Forward', 5),
(N'Dayot', N'Upamecano', 28, 2, 'Defender', 5),
(N'Warren', N'Zaïre-Emery', 20, 33, 'Midfield', 5),
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
(N'João', N'Gomes', 25, 15, 'Midfield', 6),
(N'Ricardo', N'Goss', 32, 1, 'Goalkeeper', 6),
(N'Bruno', N'Guimarães', 29, 39, 'Midfield', 6),
(N'Angus', N'Gunn', 30, 1, 'Goalkeeper', 6),
(N'Abdulaziz', N'Hatem', 36, 6, 'Midfield', 6),
(N'Vinícius', N'Júnior', 26, 7, 'Forward', 6),
(N'Douglas', N'Luiz', 28, 6, 'Midfield', 6),
(N'Gabriel', N'Magalhães', 29, 4, 'Defender', 6),
(N'Marquinhos', N'Marquinhos', 32, 5, 'Defender', 6),
(N'Gabriel', N'Martinelli', 25, 11, 'Forward', 6),
(N'John', N'McGinn', 32, 7, 'Midfield', 6),
(N'Lucas', N'Mendes', 36, 12, 'Defender', 6),
(N'Éder', N'Militão', 28, 3, 'Defender', 6),
(N'Ime', N'Okon', 22, 14, 'Defender', 6),
(N'Lucas', N'Paquetá', 29, 8, 'Midfield', 6),
(N'João', N'Pedro', 25, 9, 'Forward', 6),
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
(N'Marc', N'Guéhi', 26, 6, 'Defender', 7),
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
(N'Álex', N'Baena', 25, 16, 'Midfield', 8),
(N'Scott', N'Bain', 35, 29, 'Goalkeeper', 8),
(N'Dani', N'Carvajal', 34, 2, 'Defender', 8),
(N'Pau', N'Cubarsí', 19, 33, 'Defender', 8),
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
(N'Álvaro', N'Morata', 34, 7, 'Forward', 8),
(N'Dani', N'Olmo', 28, 10, 'Midfield', 8),
(N'Mikel', N'Oyarzabal', 29, 21, 'Forward', 8),
(N'Pedri', N'Pedri', 24, 8, 'Midfield', 8),
(N'Yeremy', N'Pino', 24, 21, 'Forward', 8),
(N'Pedro', N'Porro', 27, 23, 'Defender', 8),
(N'David', N'Raya', 31, 1, 'Goalkeeper', 8),
(N'Álex', N'Remiro', 31, 1, 'Goalkeeper', 8),
(N'Rodri', N'Rodri', 30, 16, 'Midfield', 8),
(N'Fabián', N'Ruiz', 30, 8, 'Midfield', 8),
(N'Tarek', N'Salman', 29, 15, 'Defender', 8),
(N'Unai', N'Simón', 29, 23, 'Goalkeeper', 8),
(N'Ferran', N'Torres', 26, 11, 'Forward', 8),
(N'Nico', N'Williams', 24, 17, 'Forward', 8),
(N'Martin', N'Zubimendi', 27, 4, 'Midfield', 8),
(N'Mahmoud', N'Abunada', 26, 21, 'Goalkeeper', 9),
(N'João', N'Cancelo', 32, 20, 'Defender', 9),
(N'Francisco', N'Conceição', 24, 26, 'Forward', 9),
(N'Diogo', N'Costa', 27, 22, 'Goalkeeper', 9),
(N'Diogo', N'Dalot', 27, 20, 'Defender', 9),
(N'Rúben', N'Dias', 29, 3, 'Defender', 9),
(N'Bruno', N'Fernandes', 32, 8, 'Midfield', 9),
(N'João', N'Félix', 27, 11, 'Forward', 9),
(N'Billy', N'Gilmour', 25, 14, 'Midfield', 9),
(N'Grant', N'Hanley', 35, 5, 'Defender', 9),
(N'George', N'Hirst', 27, 14, 'Forward', 9),
(N'Gonçalo', N'Inácio', 25, 25, 'Defender', 9),
(N'Diogo', N'Jota', 30, 20, 'Forward', 9),
(N'Luke', N'Le Roux', 26, 14, 'Midfield', 9),
(N'Rafael', N'Leão', 27, 17, 'Forward', 9),
(N'Patrick', N'Maswanganyi', 28, 10, 'Midfield', 9),
(N'Kenny', N'McLean', 34, 23, 'Midfield', 9),
(N'Nuno', N'Mendes', 24, 19, 'Defender', 9),
(N'Aubrey', N'Modiba', 31, 17, 'Defender', 9),
(N'Pedro', N'Neto', 26, 7, 'Forward', 9),
(N'João', N'Neves', 22, 87, 'Midfield', 9),
(N'Rúben', N'Neves', 29, 18, 'Midfield', 9),
(N'Mohau', N'Nkota', 22, 28, 'Forward', 9),
(N'Otávio', N'Otávio', 31, 25, 'Midfield', 9),
(N'João', N'Palhinha', 31, 6, 'Midfield', 9),
(N'Gonçalo', N'Ramos', 25, 9, 'Forward', 9),
(N'Nélson', N'Semedo', 33, 2, 'Defender', 9),
(N'António', N'Silva', 23, 4, 'Defender', 9),
(N'Bernardo', N'Silva', 32, 10, 'Midfield', 9),
(N'Rui', N'Silva', 32, 1, 'Goalkeeper', 9),
(N'José', N'Sá', 33, 1, 'Goalkeeper', 9),
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
