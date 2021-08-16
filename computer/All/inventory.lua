inv={} --inv[itemname], contains name, count
items={} --array of itemdetails
slot={} --slot[itemname] tells in which slot <itemname> is

function resetInv()
	for i in pairs(inv) do
		inv[i]=nil
	end
	for i in pairs(slot) do
		slot[i]=nil
	end
	for i in pairs(items) do
		items[i]=nil
	end
end

function countInventory()
	--inventory.inv={}
	resetInv()
	for i=1,16 do
		det=turtle.getItemDetail(i)
		items[i]=det
		if det~=nil then
			--logger.log(det)
			if inv[det.name]==nil
			then 
				inv[det.name]=det.count
				slot[det.name]=i
			else
				before=inv[det.name]
				toPut=math.min(itemstacksizesAndMaxCounts.getStackSize(det.name)-before, det.count)
				inv[det.name]=inv[det.name]+det.count
				turtle.select(i)
				turtle.transferTo(slot[det.name])
				items[slot[det.name]].count=items[slot[det.name]].count+toPut
				items[i]=turtle.getItemDetail()
			end
		end
	end
	logger.log("Counted inventory!")
end

function printInventoryNames()
	logger.log("Printing Inventory Names")
	for i=1,16 do
		turtle.select(i)
		if (turtle.getItemDetail()~=nil)
		then
			logger.log(turtle.getItemDetail().name)
		end
	end
end

function sortInventory()
	--items in the last slots, first slots empty
	countInventory()
	local j=16
	while items[j]~=nil do 
		j=j-1 
	end
	for i=1,16 do
		if i>=j then 
			return 
		end
		if items[i]~=nil then
			turtle.select(i)
			turtle.transferTo(j)
			items[j]=items[i]
			items[i]=nil
			while items[j]~=nil do 
				j=j-1 
			end
		end
	end
	countInventory()
end

function dropAbundantItems(withSorting)
	if withSorting==nil then withSorting=true end
	removed=false
	chestStorageSystem.sumInventoryAndAllChests()
	for i=1,16 do
		id=turtle.getItemDetail(i)
		if id~=nil then
			c=id.count
			tot=chestStorageSystem.totalItemCounts[id.name]
			if tot==nil then
				logger.log("Something strange happened: inventory.DropAbundantItems says tot is nil")
			else
				dropCount=math.min(c,tot-itemstacksizesAndMaxCounts.maxCountToKeep(id.name))
				logger.log(i.."   "..dropCount)
				if dropCount>0 then
					removed=true
					turtle.select(i)
					turtle.drop(dropCount)
					chestStorageSystem.totalItemCounts[id.name]=chestStorageSystem.totalItemCounts[id.name]-dropCount
				end
			end

		end
	end
	if withSorting and removed then sortInventory() end
end