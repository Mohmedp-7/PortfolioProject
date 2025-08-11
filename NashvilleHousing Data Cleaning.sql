--Standardize Data Format
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address Data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ] != b.[UniqueID ] 
 Where a.PropertyAddress is null


 Update a
 SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ] != b.[UniqueID ] 
Where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address,City,State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing



Select 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NvarChar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity  NvarChar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))




Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NvarChar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity  NvarChar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState  NvarChar(255);

Update NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldasVacant),Count(SoldasVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
	    Else SoldAsVacant
	    End




-- Remove Duplicates

WITH RowNumCTE as(

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
Where row_num > 1


--Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP Column OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP Column SaleDate
