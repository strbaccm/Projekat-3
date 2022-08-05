Select *
From DataCleaning..NashvilleHousing



--MIJENJANJE FORMATA DATUMA

Select SaleDate, CONVERT(Date,SaleDate)
From DataCleaning.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select *
From DataCleaning..NashvilleHousing


--ADRESA NEKRETNINE

Select *
From DataCleaning..NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaning.dbo.NashvilleHousing a
JOIN DataCleaning.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a --ovdje moramo da koristimo alijas nece proci sa NashvilleHousing
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaning.dbo.NashvilleHousing a
JOIN DataCleaning.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Select *
From DataCleaning..NashvilleHousing


--DIJELIMO ADRESU NA NEKOLIKO KOLONA(adresa,grad,drzava)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
From DataCleaning..NashvilleHousing


--kreiranje nove kolone

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) 


Select *
From DataCleaning..NashvilleHousing


Select OwnerAddress
From DataCleaning..NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From DataCleaning..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select *
From DataCleaning..NashvilleHousing


--Mijenjamo y i n u yes i no

Select Distinct(SoldAsVacant)
From DataCleaning..NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaning..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No' 
	   ELSE SoldAsVacant
	   END
From DataCleaning..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
                        When SoldAsVacant = 'N' Then 'No' 
	                    ELSE SoldAsVacant
	                    END


-- BRISANJE DUPLIKATA
WITH RowNumCTE AS(
Select *,
 ROW_NUMBER() OVER(
 PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY
			  UniqueID ) row_num


From DataCleaning..NashvilleHousing
--order by ParcelID

)
DELETE
From RowNumCTE
Where row_num > 1


--BRISANJE NEPOTREBNIH KOLONA

Select *
From DataCleaning..NashvilleHousing


ALTER TABLE DataCleaning..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE DataCleaning..NashvilleHousing
DROP COLUMN SaleDate
