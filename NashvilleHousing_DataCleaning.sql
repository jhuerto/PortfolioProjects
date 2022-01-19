SELECT *
FROM housing

-- Standardize Date Format

ALTER TABLE `nashville_housing`.`housing` 
CHANGE COLUMN `SaleDate` `SaleDate` DATE NULL DEFAULT NULL ;

-- Populate Property Address

SELECT *
FROM housing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM housing a
JOIN housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM housing a
JOIN housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT 
SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) +1, LENGTH(PropertyAddress)) AS Address
FROM housing


ALTER TABLE housing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress) -1)


ALTER TABLE housing
ADD PropertySplitCity NVARCHAR(255);

UPDATE housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) +1, LENGTH(PropertyAddress))

--

SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
    PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
    PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM housing

ALTER TABLE housing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE housing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE housing
ADD OwnerSplitState NVARCHAR(255);

UPDATE housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-- Change Y and N to Yes and No in "SoldAsVacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM housing

UPDATE housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER()OVER(
    PARTITION BY ParcelID,
				PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY
					UniqueID
                    ) row_num
FROM housing)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Column

ALTER TABLE housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate