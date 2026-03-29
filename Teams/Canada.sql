-- 1. Create the Table
CREATE TABLE CanadaRoster (
    PlayerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100),
    Position NVARCHAR(50),
    CurrentClub NVARCHAR(100),
    IsCoach BIT DEFAULT 0
);

-- 2. Insert the Data
INSERT INTO CanadaRoster (FullName, Position, CurrentClub, IsCoach)
VALUES 
('Jesse Marsch', 'Head Coach', 'Canada Soccer', 1),
('Dayne St. Clair', 'Goalkeeper', 'Minnesota United', 0),
('Maxime Crépeau', 'Goalkeeper', 'Portland Timbers', 0),
('Owen Goodman', 'Goalkeeper', 'Crystal Palace', 0),
('Alphonso Davies', 'Defender', 'Bayern Munich', 0),
('Alistair Johnston', 'Defender', 'Celtic', 0),
('Moïse Bombito', 'Defender', 'OGC Nice', 0),
('Derek Cornelius', 'Defender', 'Rangers', 0),
('Richie Laryea', 'Defender', 'Toronto FC', 0),
('Kamal Miller', 'Defender', 'Portland Timbers', 0),
('Joel Waterman', 'Defender', 'Chicago Fire', 0),
('Luc de Fougerolles', 'Defender', 'Fulham', 0),
('Stephen Eustáquio', 'Midfielder', 'FC Porto', 0),
('Ismaël Koné', 'Midfielder', 'Marseille', 0),
('Jonathan Osorio', 'Midfielder', 'Toronto FC', 0),
('Mathieu Choinière', 'Midfielder', 'Grasshopper Zurich', 0),
('Nathan Saliba', 'Midfielder', 'Anderlecht', 0),
('Niko Sigur', 'Midfielder', 'Hajduk Split', 0),
('Jonathan David', 'Forward', 'Juventus', 0),
('Cyle Larin', 'Forward', 'Mallorca', 0),
('Tajon Buchanan', 'Forward', 'Inter Milan', 0),
('Jacob Shaffelburg', 'Forward', 'Nashville SC', 0),
('Tani Oluwaseyi', 'Forward', 'Minnesota United', 0),
('Liam Millar', 'Forward', 'Hull City', 0),
('Ali Ahmed', 'Forward', 'Vancouver Whitecaps', 0);

-- 3. Verify the Data
SELECT * FROM CanadaRoster ORDER BY IsCoach DESC, Position ASC;