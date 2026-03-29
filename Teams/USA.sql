-- 1. Create the Table
CREATE TABLE USARoster (
    PlayerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100),
    Position NVARCHAR(50),
    CurrentClub NVARCHAR(100),
    IsCoach BIT DEFAULT 0
);

-- 2. Insert the Data
INSERT INTO USARoster (FullName, Position, CurrentClub, IsCoach)
VALUES 
('Mauricio Pochettino', 'Head Coach', 'USMNT', 1),
('Matt Turner', 'Goalkeeper', 'Crystal Palace', 0),
('Matt Freese', 'Goalkeeper', 'New York City FC', 0),
('Patrick Schulte', 'Goalkeeper', 'Columbus Crew', 0),
('Antonee Robinson', 'Defender', 'Fulham', 0),
('Tim Ream', 'Defender', 'Charlotte FC', 0),
('Chris Richards', 'Defender', 'Crystal Palace', 0),
('Miles Robinson', 'Defender', 'FC Cincinnati', 0),
('Mark McKenzie', 'Defender', 'Toulouse', 0),
('Joe Scally', 'Defender', 'Borussia Mönchengladbach', 0),
('Alex Freeman', 'Defender', 'Villarreal', 0),
('John Tolkin', 'Defender', 'Holstein Kiel', 0),
('Max Arfsten', 'Defender', 'Columbus Crew', 0),
('Tyler Adams', 'Midfielder', 'Bournemouth', 0),
('Weston McKennie', 'Midfielder', 'Juventus', 0),
('Yunus Musah', 'Midfielder', 'AC Milan', 0),
('Johnny Cardoso', 'Midfielder', 'Atletico Madrid', 0),
('Malik Tillman', 'Midfielder', 'PSV Eindhoven', 0),
('Brenden Aaronson', 'Midfielder', 'Leeds United', 0),
('Aidan Morris', 'Midfielder', 'Middlesbrough', 0),
('Sebastian Berhalter', 'Midfielder', 'Vancouver Whitecaps', 0),
('Christian Pulisic', 'Forward', 'AC Milan', 0),
('Folarin Balogun', 'Forward', 'AS Monaco', 0),
('Ricardo Pepi', 'Forward', 'PSV Eindhoven', 0),
('Tim Weah', 'Forward', 'Marseille', 0),
('Haji Wright', 'Forward', 'Coventry City', 0),
('Diego Luna', 'Forward', 'Real Salt Lake', 0);

-- 3. Verify the Data
SELECT * FROM USARoster ORDER BY IsCoach DESC, Position ASC;