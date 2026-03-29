-- 1. Create the Table
CREATE TABLE ScotlandRoster (
    PlayerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100),
    Position NVARCHAR(50),
    CurrentClub NVARCHAR(100),
    IsCoach BIT DEFAULT 0
);

-- 2. Insert the Data
INSERT INTO ScotlandRoster (FullName, Position, CurrentClub, IsCoach)
VALUES 
('Steve Clarke', 'Head Coach', 'Scotland', 1),
('Alan Irvine', 'Assistant Coach', 'Scotland', 1),
('Steven Naismith', 'Assistant Coach', 'Scotland', 1),
('Craig Gordon', 'Goalkeeper', 'Hearts', 0),
('Angus Gunn', 'Goalkeeper', 'Nottingham Forest', 0),
('Scott Bain', 'Goalkeeper', 'Falkirk', 0),
('Liam Kelly', 'Goalkeeper', 'Motherwell', 0),
('Andy Robertson', 'Defender', 'Liverpool', 0),
('Kieran Tierney', 'Defender', 'Arsenal', 0),
('Aaron Hickey', 'Defender', 'Brentford', 0),
('John Souttar', 'Defender', 'Rangers', 0),
('Scott McKenna', 'Defender', 'Dinamo Zagreb', 0),
('Jack Hendry', 'Defender', 'Al-Ettifaq', 0),
('Grant Hanley', 'Defender', 'Norwich City', 0),
('Josh Doig', 'Defender', 'Sassuolo', 0),
('Anthony Ralston', 'Defender', 'Celtic', 0),
('Scott McTominay', 'Midfielder', 'Napoli', 0),
('John McGinn', 'Midfielder', 'Aston Villa', 0),
('Billy Gilmour', 'Midfielder', 'Napoli', 0),
('Lewis Ferguson', 'Midfielder', 'Bologna', 0),
('Ryan Christie', 'Midfielder', 'Bournemouth', 0),
('Kenny McLean', 'Midfielder', 'Norwich City', 0),
('Ben Gannon-Doak', 'Midfielder', 'Bournemouth', 0), -- Breakout star of 2025
('Lennon Miller', 'Midfielder', 'Motherwell', 0),
('Che Adams', 'Forward', 'Torino', 0),
('Lawrence Shankland', 'Forward', 'Hearts', 0),
('Lyndon Dykes', 'Forward', 'Birmingham City', 0),
('George Hirst', 'Forward', 'Ipswich Town', 0);

-- 3. Verify the Data
SELECT * FROM ScotlandRoster ORDER BY IsCoach DESC, Position ASC;