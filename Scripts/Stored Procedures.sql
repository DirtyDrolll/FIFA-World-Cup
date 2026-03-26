USE FIFA_WorldCup2026;
GO

-- ============================================================
-- SECTION 5: STORED PROCEDURES
-- ============================================================

-- 5.1 Get all matches for a specific tournament stage
CREATE OR ALTER PROCEDURE usp_GetMatchesByStage
	@Stage NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		m.MatchID,
		m.MatchDate,
		t1.GroupLetter AS Team1,
		t2.GroupLetter AS Team2,
		m.Team1Score,
		m.Team2Score,
		s.StadiumName,
		c.CityName
	FROM Matches m
	INNER JOIN NationalTeams t1 ON m.Team1ID   = t1.TeamID
	INNER JOIN NationalTeams t2 ON m.Team2ID   = t2.TeamID
	INNER JOIN Stadiums s       ON m.StadiumID = s.StadiumID
	INNER JOIN Cities c         ON s.CityID    = c.CityID
	WHERE m.TournamentStage = @Stage;
END;
GO

-- 5.2 Register a new fan
CREATE OR ALTER PROCEDURE usp_RegisterFan
	@FirstName            NVARCHAR(50),
	@LastName             NVARCHAR(50),
	@Email                NVARCHAR(100),
	@IdentificationNumber NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM Fans WHERE Email = @Email)
	BEGIN
		RAISERROR('A fan with this email already exists.', 16, 1);
		RETURN;
	END

	INSERT INTO Fans (FirstName, LastName, Email, IdentificationNumber)
	VALUES (@FirstName, @LastName, @Email, @IdentificationNumber);

	PRINT 'Fan registered successfully with ID: ' + CAST(SCOPE_IDENTITY() AS NVARCHAR);
END;
GO

-- 5.3 Get player stats for a specific match
CREATE OR ALTER PROCEDURE usp_GetPlayerStatsByMatch
	@MatchID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		p.FirstName + ' ' + p.LastName                            AS PlayerName,
		p.Position,
		co.CountryName                                            AS Team,
		COUNT(CASE WHEN me.EventType = 'Goal'        THEN 1 END) AS Goals,
		COUNT(CASE WHEN me.EventType = 'Assist'      THEN 1 END) AS Assists,
		COUNT(CASE WHEN me.EventType = 'Yellow Card' THEN 1 END) AS YellowCards,
		COUNT(CASE WHEN me.EventType = 'Red Card'    THEN 1 END) AS RedCards
	FROM MatchEvents me
	INNER JOIN Players p        ON me.PlayerID  = p.PlayerID
	INNER JOIN NationalTeams nt ON p.TeamID     = nt.TeamID
	INNER JOIN Country co       ON nt.CountryID = co.CountryID
	WHERE me.MatchID = @MatchID
	GROUP BY p.PlayerID, p.FirstName, p.LastName, p.Position, co.CountryName
	ORDER BY Goals DESC;
END;
GO
