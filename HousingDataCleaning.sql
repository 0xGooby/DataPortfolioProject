Select *
FROM PortfolioProject..NashvilleHousing




Select SaleDate
FROM PortfolioProject..NashvilleHousing




-- SaleDate used to be 2013:04:09:00:00:00:000 now it is 2013:04:09
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


-- Property address populating

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

-- check if null addresses were filled in
SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL





-- Seperating the street address from the city to make them into 2 seperate columns
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS CityName
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertyCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

ALTER TABLE NashvilleHousing
Add PropertyStreetAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)




-- Doing the same thing for the owner address

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 2)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerStreetAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 3)

ALTER TABLE NashvilleHousing
add OwnerCityAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 2)

ALTER TABLE NashvilleHousing
add OwnerStateAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 1)


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
order by SoldAsVacant

-- I had to convert my column to a nvarchar and then update it to yes or no since it was 0 or 1 

ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant NVARCHAR(3);

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
                     WHEN SoldAsVacant = 0 THEN 'No'
                     WHEN SoldAsVacant = 1 THEN 'Yes'
                     ELSE SoldAsVacant
                  END;


WITH RowNumCTE as(
SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) RowNum
FROM NashvilleHousing
)
select *
FROM RowNumCTE
WHERE RowNum > 1



-- DROP UNUSED COLUMNS

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress