-- 1. Create the Table
CREATE TABLE SpainRoster (
    PlayerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100),
    Position NVARCHAR(50),
    CurrentClub NVARCHAR(100),
    IsCoach BIT DEFAULT 0
);

-- 2. Insert the Data
INSERT INTO SpainRoster (FullName, Position, CurrentClub, IsCoach)
VALUES 
('Luis de la Fuente', 'Head Coach', 'Spain', 1),
('Unai Simón', 'Goalkeeper', 'Athletic Bilbao', 0),
('David Raya', 'Goalkeeper', 'Arsenal', 0),
('Álex Remiro', 'Goalkeeper', 'Real Sociedad', 0),
('Aymeric Laporte', 'Defender', 'Al-Nassr', 0),
('Robin Le Normand', 'Defender', 'Atletico Madrid', 0),
('Dani Carvajal', 'Defender', 'Real Madrid', 0),
('Alejandro Grimaldo', 'Defender', 'Bayer Leverkusen', 0),
('Marc Cucurella', 'Defender', 'Chelsea', 0),
('Pau Cubarsí', 'Defender', 'Barcelona', 0),
('Dean Huijsen', 'Defender', 'Real Madrid', 0),
('Pedro Porro', 'Defender', 'Tottenham Hotspur', 0),
('Rodri', 'Midfielder', 'Manchester City', 0),
('Pedri', 'Midfielder', 'Barcelona', 0),
('Gavi', 'Midfielder', 'Barcelona', 0),
('Mikel Merino', 'Midfielder', 'Arsenal', 0),
('Martin Zubimendi', 'Midfielder', 'Arsenal', 0),
('Fabián Ruiz', 'Midfielder', 'Paris Saint-Germain', 0),
('Dani Olmo', 'Midfielder', 'Barcelona', 0),
('Álex Baena', 'Midfielder', 'Atletico Madrid', 0),
('Lamine Yamal', 'Forward', 'Barcelona', 0),
('Nico Williams', 'Forward', 'Athletic Bilbao', 0),
('Álvaro Morata', 'Forward', 'Como', 0),
('Mikel Oyarzabal', 'Forward', 'Real Sociedad', 0),
('Ferran Torres', 'Forward', 'Barcelona', 0),
('Samu Aghehowa', 'Forward', 'Porto', 0),
('Yeremy Pino', 'Forward', 'Crystal Palace', 0);

-- 3. Verify the Data
SELECT * FROM SpainRoster ORDER BY IsCoach DESC, Position ASC;