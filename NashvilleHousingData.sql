/*
Cleaning Data in SQL Queries with PostgreSQL15
*/

SELECT *
FROM Nashville_Housing_Data


-- Populate Property Address data with NULL


Select DISTINCT PropertyAddress
FROM Nashville_Housing_Data

    
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress,b.PropertyAddress)
From Nashville_Housing_Data a
INNER JOIN Nashville_Housing_Data b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;

-- 35 Property Address were NULL after Query. Noticed that the ParcelID was linked to an address. Used it to fill in the NULL areas.


Select PropertyAddress
FROM Nashville_Housing_Data
WHERE Propertyaddress IS NULL;


UPDATE Nashville_Housing_Data
SET PropertyAddress = (
  SELECT COALESCE(a.PropertyAddress, b.PropertyAddress)
  FROM Nashville_Housing_Data a
  INNER JOIN Nashville_Housing_Data b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
  WHERE a.PropertyAddress IS NULL
	LIMIT 1
)
WHERE PropertyAddress IS NULL;



-- Breaking out address into individual columns (Address, City, State)

Select PropertyAddress
FROM Nashville_Housing_Data

SELECT
SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress)-1) AS Address 
,	SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress)+1, LENGTH(PropertyAddress)) AS City
FROM Nashville_Housing_Data

--Creating new tables to hold only the street address and the city.

ALTER TABLE Nashville_Housing_Data
ADD PropertyStreet VARCHAR(255);

UPDATE Nashville_Housing_Data
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress)-1)


ALTER TABLE Nashville_Housing_Data
ADD PropertyCity VARCHAR(255);

UPDATE Nashville_Housing_Data
SET PropertyCity = SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress)+1, LENGTH(PropertyAddress))

SELECT PropertyStreet, PropertyCity
FROM Nashville_Housing_Data

--Breaking out OwnerAddress into street address, city, and state

SELECT OwnerAddress
FROM Nashville_Housing_Data

SELECT
SPLIT_Part(OwnerAddress, ',', 1),
SPLIT_Part(OwnerAddress, ',', 2),
SPLIT_Part(OwnerAddress, ',', 3)
FROM Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
ADD OwnerStreet VARCHAR(255);

UPDATE Nashville_Housing_Data
SET OwnerStreet = SPLIT_Part(OwnerAddress, ',', 1);


ALTER TABLE Nashville_Housing_Data
ADD OwnerCity VARCHAR(255);

UPDATE Nashville_Housing_Data
SET OwnerCity = SPLIT_Part(OwnerAddress, ',', 2);

ALTER TABLE Nashville_Housing_Data
ADD OwnerState VARCHAR(255);

UPDATE Nashville_Housing_Data
SET OwnerState = SPLIT_Part(OwnerAddress, ',', 3);

SELECT *
FROM Nashville_Housing_Data


-- Change Y and N to Yes and No in SoldAsYacant field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM Nashville_Housing_Data
GROUP BY SoldAsVacant
ORDER By 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Nashville_Housing_Data

UPDATE Nashville_Housing_Data
SET SoldAsVacant =
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- Remove Duplicates that have the same ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference details using CTE

SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
)row_num
FROM Nashville_Housing_Data


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
)row_num
FROM Nashville_Housing_Data
				)
SELECT *
FROM RowNumCTE
WHERE row_num>1

WITH RowNumCTE AS(
SELECT UniqueID
	FROM (
	SELECT UniqueID, ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
)row_num
FROM Nashville_Housing_Data
				) s
	WHERE row_num>1
	)

DELETE FROM Nashville_Housing_Data
WHERE UniqueID in (SELECT * FROM RowNumCTE)





