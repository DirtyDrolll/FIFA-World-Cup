-- 1. Create the Table
CREATE TABLE SouthAfricaRoster (
    PlayerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100),
    Position NVARCHAR(50),
    CurrentClub NVARCHAR(100),
    IsCoach BIT DEFAULT 0
);

-- 2. Insert the Data
INSERT INTO SouthAfricaRoster (FullName, Position, CurrentClub, IsCoach)
VALUES 
('Hugo Broos', 'Head Coach', 'South Africa', 1),
('Ronwen Williams', 'Goalkeeper', 'Mamelodi Sundowns', 0),
('Sipho Chaine', 'Goalkeeper', 'Orlando Pirates', 0),
('Ricardo Goss', 'Goalkeeper', 'SuperSport United', 0),
('Siyabonga Ngezana', 'Defender', 'FCSB', 0),
('Khuliso Mudau', 'Defender', 'Mamelodi Sundowns', 0),
('Aubrey Modiba', 'Defender', 'Mamelodi Sundowns', 0),
('Olwethu Makhanya', 'Defender', 'Philadelphia Union', 0),
('Nkosinathi Sibisi', 'Defender', 'Orlando Pirates', 0),
('Tylon Smith', 'Defender', 'Queens Park Rangers', 0),
('Ime Okon', 'Defender', 'Hannover 96', 0),
('Mbekezeli Mbokazi', 'Defender', 'Chicago Fire', 0),
('Teboho Mokoena', 'Midfielder', 'Mamelodi Sundowns', 0),
('Sphephelo Sithole', 'Midfielder', 'CD Tondela', 0),
('Thalente Mbatha', 'Midfielder', 'Orlando Pirates', 0),
('Luke Le Roux', 'Midfielder', 'Portsmouth', 0),
('Jayden Adams', 'Midfielder', 'Stellenbosch FC', 0),
('Patrick Maswanganyi', 'Midfielder', 'Orlando Pirates', 0),
('Themba Zwane', 'Midfielder', 'Mamelodi Sundowns', 0),
('Lyle Foster', 'Forward', 'Burnley', 0),
('Bongokuhle Hlongwane', 'Forward', 'Minnesota United', 0),
('Oswin Appollis', 'Forward', 'Orlando Pirates', 0),
('Relebohile Mofokeng', 'Forward', 'Orlando Pirates', 0),
('Iqraam Rayners', 'Forward', 'Mamelodi Sundowns', 0),
('Mohau Nkota', 'Forward', 'Al-Ettifaq', 0),
('Evidence Makgopa', 'Forward', 'Orlando Pirates', 0);

-- 3. Verify the Data
SELECT * FROM SouthAfricaRoster ORDER BY IsCoach DESC, Position ASC;