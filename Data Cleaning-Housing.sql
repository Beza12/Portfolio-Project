select * from [Portfolio project]..NashvilleHousing

-- Standardize daye format
select SaleDateConverted ,CONVERT(date, SaleDate)
from [Portfolio project]..NashvilleHousing

update [Portfolio project]..NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

alter table NashvilleHousing
add saleDateConverted Date;

update [Portfolio project]..NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

--populate property address date

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from [Portfolio project]..NashvilleHousing a
join [Portfolio project]..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
 
update a
set PropertyAddress =isnull(a.PropertyAddress, b.PropertyAddress)
from [Portfolio project]..NashvilleHousing a
join [Portfolio project]..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Address
select
SUBSTRING(propertyAddress, 1, charindex(',', PropertyAddress) -1) as Address
,SUBSTRING(propertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from [Portfolio project]..NashvilleHousing 

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update [Portfolio project]..NashvilleHousing
set PropertySplitAddress = SUBSTRING(propertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update [Portfolio project]..NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))

select *
from [Portfolio project]..NashvilleHousing

select OwnerAddress
from [Portfolio project]..NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
from [Portfolio project]..NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update [Portfolio project].. NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

update [Portfolio project]..NashvilleHousing

set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

update [Portfolio project]..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

select *
from [Portfolio project]..NashvilleHousing

select SoldAsVacant
, case when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   end
from [Portfolio project]..NashvilleHousing

update [Portfolio project]..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   end
select distinct(SoldAsVacant), count( SoldAsVacant)
from [Portfolio project]..NashvilleHousing
group by SoldAsVacant
order by 2

--Remove Duplicates

With RowNumCTE AS (
Select* , Row_Number() over (Partition by ParcelID,
                                          PropertyAddress,
                                          SalePrice,
                                          SaleDate,
                                          LegalReference
                             ORDER BY UniqueID) Row_Num

From [Portfolio project]..NashvilleHousing
)

Select*
From RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress

--Delete unused columns

ALTER TABLE [Portfolio project]..NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio project]..NashvilleHousing
DROP Column SaleDate

select *
from [Portfolio project]..NashvilleHousing