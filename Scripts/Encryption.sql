USE FIFA_WorldCup2026;
GO

-- ============================================================
-- SECTION 12: SECURITY - ENCRYPTION
-- ============================================================

-- 12.1 Create the master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'M@sterKey#2026!';
GO

-- 12.2 Create a certificate
CREATE CERTIFICATE FIFA_Cert
	WITH SUBJECT = 'FIFA WorldCup 2026 Data Protection';
GO

-- 12.3 Create the symmetric key that does the actual encryption
CREATE SYMMETRIC KEY FIFA_SymKey
	WITH ALGORITHM = AES_256
	ENCRYPTION BY CERTIFICATE FIFA_Cert;
GO

-- 12.4 Add a column to store encrypted data
ALTER TABLE Fans ADD EncryptedIDNumber VARBINARY(256);
GO

-- Encrypt all existing ID numbers
OPEN SYMMETRIC KEY FIFA_SymKey
	DECRYPTION BY CERTIFICATE FIFA_Cert;

UPDATE Fans
SET EncryptedIDNumber = ENCRYPTBYKEY(
	KEY_GUID('FIFA_SymKey'),
	CONVERT(NVARCHAR(50), IdentificationNumber)
);

CLOSE SYMMETRIC KEY FIFA_SymKey;
GO

-- 12.5 Decrypt the data to read it
OPEN SYMMETRIC KEY FIFA_SymKey
	DECRYPTION BY CERTIFICATE FIFA_Cert;

SELECT 
	FanID,
	FirstName,
	LastName,
	CONVERT(NVARCHAR(50), DECRYPTBYKEY(EncryptedIDNumber)) AS DecryptedID
FROM Fans;

CLOSE SYMMETRIC KEY FIFA_SymKey;
GO
