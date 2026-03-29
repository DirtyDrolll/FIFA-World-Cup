-- 1. Create the Table
CREATE TABLE FranceRoster (
    PlayerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100),
    Position NVARCHAR(50),
    CurrentClub NVARCHAR(100),
    IsCoach BIT DEFAULT 0
);

-- 2. Insert the Data
INSERT INTO FranceRoster (FullName, Position, CurrentClub, IsCoach)
VALUES 
('Didier Deschamps', 'Head Coach', 'France', 1),
('Mike Maignan', 'Goalkeeper', 'AC Milan', 0),
('Brice Samba', 'Goalkeeper', 'Lens', 0),
('Lucas Chevalier', 'Goalkeeper', 'Lille', 0),
('William Saliba', 'Defender', 'Arsenal', 0),
('Ibrahima Konaté', 'Defender', 'Liverpool', 0),
('Dayot Upamecano', 'Defender', 'Bayern Munich', 0),
('Jules Koundé', 'Defender', 'Barcelona', 0),
('Théo Hernandez', 'Defender', 'AC Milan', 0),
('Lucas Hernandez', 'Defender', 'Paris Saint-Germain', 0),
('Wesley Fofana', 'Defender', 'Chelsea', 0),
('Malo Gusto', 'Defender', 'Chelsea', 0),
('Eduardo Camavinga', 'Midfielder', 'Real Madrid', 0),
('Aurélien Tchouaméni', 'Midfielder', 'Real Madrid', 0),
('Warren Zaïre-Emery', 'Midfielder', 'Paris Saint-Germain', 0),
('Michael Olise', 'Midfielder', 'Bayern Munich', 0),
('Manu Koné', 'Midfielder', 'Roma', 0),
('Adrien Rabiot', 'Midfielder', 'Marseille', 0),
('Kylian Mbappé', 'Forward', 'Real Madrid', 0),
('Ousmane Dembélé', 'Forward', 'Paris Saint-Germain', 0),
('Bradley Barcola', 'Forward', 'Paris Saint-Germain', 0),
('Marcus Thuram', 'Forward', 'Inter Milan', 0),
('Randal Kolo Muani', 'Forward', 'Paris Saint-Germain', 0),
('Christopher Nkunku', 'Forward', 'Chelsea', 0),
('Mathys Tel', 'Forward', 'Bayern Munich', 0);

-- 3. Verify the Data
SELECT * FROM FranceRoster ORDER BY IsCoach DESC, Position ASC;