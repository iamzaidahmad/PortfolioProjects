--2ND SQL Portfolio Project - Cleaning Data in SQL
-- Skills Used - ALTER, UPDATE, Self Joins, ISNULL, Substring, CharIndex, Len, ParseName, 
-- Replace, CASE Statements, Row Number, CTEs, DELETE 

-- 1. Viewiing the complete table
SELECT * 
FROM PortfolioProject..NashvilleHousing

-- 2. Changing the data type of SaleDate Column from datetime to date
SELECT SaleDate
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date

-- 3. Populating Property Address Data
-- We populate the NULLs in PropertyAddress with the help of ParcelID column 
SELECT ParcelID, PropertyAddress
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL

--Using a Self Join
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress )
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress )
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- 4. Breaking out Property Address and Owner Address in Individual Columns ( Address, City and State )
SELECT *
FROM PortfolioProject..NashvilleHousing

--Property Address
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address ,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress varchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity varchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))

--Owner Address
SELECT 
PARSENAME(Replace(OwnerAddress,',','.'), 3) AS Address, 
PARSENAME(Replace(OwnerAddress,',','.'), 2) AS City,
PARSENAME(Replace(OwnerAddress,',','.'), 1) AS State
FROM PortfolioProject..NashvilleHousing
WHERE OwnerAddress IS NOT NULL

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress varchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity varchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState varchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

-- 5. Changing Y and N to Yes and No in SoldAsVacant Column
SELECT DISTINCT SoldAsVacant, Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

--Method 1
UPDATE NashvilleHousing
SET SoldAsVacant = 'Yes' WHERE SoldAsVacant = 'Y'

UPDATE NashvilleHousing
SET SoldAsVacant = 'No' WHERE SoldAsVacant = 'N'

--Method 2
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- 6. Removing Duplicates
-- We define duplicates as rows having the same ParcelID, PropertyAddress, SalePrice, SaleDate
-- and LegalReference
WITH RowNumCTE AS (
SELECT * , ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID
) AS RowNum
FROM PortfolioProject..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE RowNum > 1

-- 7. Delete Unused Columns
SELECT * 
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict




