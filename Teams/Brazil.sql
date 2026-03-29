-- 1. Create the Table
CREATE TABLE BrazilRoster (
    PlayerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100),
    Position NVARCHAR(50),
    CurrentClub NVARCHAR(100),
    IsCoach BIT DEFAULT 0
);

-- 2. Insert the Data
INSERT INTO BrazilRoster (FullName, Position, CurrentClub, IsCoach)
VALUES 
('Carlo Ancelotti', 'Head Coach', 'Brazil', 1),
('Alisson Becker', 'Goalkeeper', 'Liverpool', 0),
('Ederson', 'Goalkeeper', 'Manchester City', 0),
('Bento', 'Goalkeeper', 'Al-Nassr', 0),
('Marquinhos', 'Defender', 'Paris Saint-Germain', 0),
('Gabriel Magalhães', 'Defender', 'Arsenal', 0),
('Éder Militão', 'Defender', 'Real Madrid', 0),
('Danilo', 'Defender', 'Juventus', 0),
('Bremer', 'Defender', 'Juventus', 0),
('Vanderson', 'Defender', 'AS Monaco', 0),
('Lucas Beraldo', 'Defender', 'Paris Saint-Germain', 0),
('Alex Sandro', 'Defender', 'Flamengo', 0),
('Bruno Guimarães', 'Midfielder', 'Newcastle United', 0),
('Lucas Paquetá', 'Midfielder', 'West Ham United', 0),
('Casemiro', 'Midfielder', 'Manchester United', 0),
('João Gomes', 'Midfielder', 'Wolverhampton Wanderers', 0),
('Douglas Luiz', 'Midfielder', 'Juventus', 0),
('Andrey Santos', 'Midfielder', 'Chelsea', 0),
('Vinícius Júnior', 'Forward', 'Real Madrid', 0),
('Rodrygo', 'Forward', 'Real Madrid', 0),
('Raphinha', 'Forward', 'Barcelona', 0),
('Endrick', 'Forward', 'Real Madrid', 0),
('Richarlison', 'Forward', 'Tottenham Hotspur', 0),
('Gabriel Martinelli', 'Forward', 'Arsenal', 0),
('Savinho', 'Forward', 'Manchester City', 0),
('João Pedro', 'Forward', 'Brighton', 0);

-- 3. Verify the Data
SELECT * FROM BrazilRoster ORDER BY IsCoach DESC, Position ASC;