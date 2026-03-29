-- 1. Create the Table
CREATE TABLE PortugalRoster (
    PlayerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100),
    Position NVARCHAR(50),
    CurrentClub NVARCHAR(100),
    IsCoach BIT DEFAULT 0
);

-- 2. Insert the Data
INSERT INTO PortugalRoster (FullName, Position, CurrentClub, IsCoach)
VALUES 
('Roberto Martínez', 'Head Coach', 'Portugal', 1),
('Ricardo Carvalho', 'Assistant Coach', 'Portugal', 1),
('Diogo Costa', 'Goalkeeper', 'FC Porto', 0),
('José Sá', 'Goalkeeper', 'Wolves', 0),
('Rui Silva', 'Goalkeeper', 'Real Betis', 0),
('Rúben Dias', 'Defender', 'Manchester City', 0),
('António Silva', 'Defender', 'Benfica', 0),
('Gonçalo Inácio', 'Defender', 'Sporting CP', 0),
('Diogo Dalot', 'Defender', 'Manchester United', 0),
('Nuno Mendes', 'Defender', 'Paris Saint-Germain', 0),
('João Cancelo', 'Defender', 'Barcelona', 0),
('Nélson Semedo', 'Defender', 'Fenerbahçe', 0),
('Renato Veiga', 'Defender', 'Villarreal', 0),
('Bruno Fernandes', 'Midfielder', 'Manchester United', 0),
('Bernardo Silva', 'Midfielder', 'Manchester City', 0),
('João Neves', 'Midfielder', 'Paris Saint-Germain', 0),
('Vitinha', 'Midfielder', 'Paris Saint-Germain', 0),
('João Palhinha', 'Midfielder', 'Tottenham Hotspur', 0),
('Rúben Neves', 'Midfielder', 'Al-Hilal', 0),
('Otávio', 'Midfielder', 'Al-Nassr', 0),
('Cristiano Ronaldo', 'Forward', 'Al-Nassr', 0),
('Rafael Leão', 'Forward', 'AC Milan', 0),
('Gonçalo Ramos', 'Forward', 'Paris Saint-Germain', 0),
('João Félix', 'Forward', 'Al-Nassr', 0), -- Recently moved to join CR7
('Diogo Jota', 'Forward', 'Liverpool', 0),
('Pedro Neto', 'Forward', 'Chelsea', 0),
('Francisco Conceição', 'Forward', 'Juventus', 0);

-- 3. Verify the Data
SELECT * FROM PortugalRoster ORDER BY IsCoach DESC, Position ASC;