-- 1. Create the Table
CREATE TABLE QatarRoster (
    PlayerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100),
    Position NVARCHAR(50),
    CurrentClub NVARCHAR(100),
    IsCoach BIT DEFAULT 0
);

-- 2. Insert the Data
INSERT INTO QatarRoster (FullName, Position, CurrentClub, IsCoach)
VALUES 
('Julen Lopetegui', 'Head Coach', 'Qatar', 1),
('Meshaal Barsham', 'Goalkeeper', 'Al-Sadd', 0),
('Saad Al-Sheeb', 'Goalkeeper', 'Al-Sadd', 0),
('Mahmoud Abunada', 'Goalkeeper', 'Al-Arabi', 0),
('Lucas Mendes', 'Defender', 'Al-Wakrah', 0),
('Boualem Khoukhi', 'Defender', 'Al-Sadd', 0),
('Tarek Salman', 'Defender', 'Al-Sadd', 0),
('Pedro Miguel', 'Defender', 'Al-Sadd', 0),
('Homam Al-Amin', 'Defender', 'Al-Gharafa', 0),
('Sultan Al-Brake', 'Defender', 'Al-Duhail', 0),
('Mohammed Waad', 'Defender', 'Al-Sadd', 0),
('Al-Hashmi Al-Hussain', 'Defender', 'Al-Sadd', 0),
('Jassem Gaber', 'Midfielder', 'Al-Rayyan', 0),
('Ahmed Fathi', 'Midfielder', 'Al-Arabi', 0),
('Abdulaziz Hatem', 'Midfielder', 'Al-Rayyan', 0),
('Assim Madibo', 'Midfielder', 'Al-Gharafa', 0),
('Mostafa Tarek', 'Midfielder', 'Al-Sadd', 0),
('Karim Boudiaf', 'Midfielder', 'Al-Duhail', 0),
('Akram Afif', 'Forward', 'Al-Sadd', 0),
('Almoez Ali', 'Forward', 'Al-Duhail', 0),
('Hassan Al-Haydos', 'Forward', 'Al-Sadd', 0),
('Ahmed Alaaeldin', 'Forward', 'Al-Gharafa', 0),
('Mohammed Muntari', 'Forward', 'Al-Duhail', 0),
('Ahmed Al-Rawi', 'Forward', 'Al-Rayyan', 0),
('Youssef Abdurisag', 'Forward', 'Al-Sadd', 0);

-- 3. Verify the Data
SELECT * FROM QatarRoster ORDER BY IsCoach DESC, Position ASC;