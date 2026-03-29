-- 1. Create the Table
CREATE TABLE EnglandRoster (
    PlayerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100),
    Position NVARCHAR(50),
    CurrentClub NVARCHAR(100),
    IsCoach BIT DEFAULT 0
);

-- 2. Insert the Data
INSERT INTO EnglandRoster (FullName, Position, CurrentClub, IsCoach)
VALUES 
('Thomas Tuchel', 'Head Coach', 'England', 1),
('Jordan Pickford', 'Goalkeeper', 'Everton', 0),
('Dean Henderson', 'Goalkeeper', 'Crystal Palace', 0),
('Aaron Ramsdale', 'Goalkeeper', 'Southampton', 0),
('John Stones', 'Defender', 'Manchester City', 0),
('Marc Guéhi', 'Defender', 'Crystal Palace', 0),
('Levi Colwill', 'Defender', 'Chelsea', 0),
('Ezri Konsa', 'Defender', 'Aston Villa', 0),
('Reece James', 'Defender', 'Chelsea', 0),
('Trent Alexander-Arnold', 'Defender', 'Real Madrid', 0),
('Tino Livramento', 'Defender', 'Newcastle United', 0),
('Myles Lewis-Skelly', 'Defender', 'Arsenal', 0),
('Declan Rice', 'Midfielder', 'Arsenal', 0),
('Jude Bellingham', 'Midfielder', 'Real Madrid', 0),
('Kobbie Mainoo', 'Midfielder', 'Manchester United', 0),
('Cole Palmer', 'Midfielder', 'Chelsea', 0),
('Adam Wharton', 'Midfielder', 'Crystal Palace', 0),
('Morgan Rogers', 'Midfielder', 'Aston Villa', 0),
('Harry Kane', 'Forward', 'Bayern Munich', 0),
('Bukayo Saka', 'Forward', 'Arsenal', 0),
('Phil Foden', 'Forward', 'Manchester City', 0),
('Anthony Gordon', 'Forward', 'Newcastle United', 0),
('Marcus Rashford', 'Forward', 'Aston Villa', 0),
('Jarrod Bowen', 'Forward', 'West Ham United', 0),
('Eberechi Eze', 'Forward', 'Crystal Palace', 0);

-- 3. Verify the Data
SELECT * FROM EnglandRoster ORDER BY IsCoach DESC, Position ASC;