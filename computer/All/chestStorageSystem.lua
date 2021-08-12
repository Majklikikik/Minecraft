chests={} --contains all information about the count of chests and their content
itemsWanted={}
function writeChestFile()
	--saves the chests table to file
	local h=fs.open("chests.michi","w")
	h.write(textutils.serialize(chests))
	h.close()
end

function readChestFile()
	--read the chests table from file
	local h=fs.open("Chests.michi","r")
	chests=textutils.unserialize(h.readAll())
	h.close()
end

function setupChests()
	--sets up a "empty" chests table
	chests={}
	chests["count"]=0
	chests["pos"]=0
	chests["rot"]=0
end

function addChestToData()
	--adds a chest to the table
	chests["count"]=chests["count"]+1
	chests[chests["count"]]={}
	chests[chests["count"]]["stackCount"]=0 --count of stacks of items in the chest
	chests[chests["count"]]["items"]={}
end

function addChest()
	addChestToData()
end


--a few methods for moving arount and saving the position in order to be able to go back to the start
function moveForward()
	while not turtle.forward() do turtle.attack() turtle.dig() end
	chests["pos"]=chests["pos"]+1
end

function moveBackwards()
	while not turtle.back() do
		turtle.turnLeft()
		turtle.turnLeft()
		turtle.attack()
		turtle.dig()
		turtle.turnLeft()
		turtle.turnLeft()
	end
	chests["pos"]=chests["pos"]-1
end

function turnLeft()
	turtle.turnLeft()
	chests["rot"]=chests["rot"]-1
end

function turnRight()
	turtle.turnRight()
	chests["rot"]=chests["rot"]+1
end

function gotoChest(index)
	--obvious
	while chests["rot"]<0 do
		turnRight()
	end
	while chests["rot"]>0 do
		turnLeft()
	end
	while chests["pos"]<index+(index%2)-1 do
		moveForward()
	end
	while chests["pos"]>index+(index%2)-1 do
		moveBackwards()
	end
	if index % 2 == 1 then
		turnLeft()
	else
		turnRight()
	end
end

function gotoStart()
	--return to the start
	while chests["rot"]<0 do
		turnRight()
	end
	while chests["rot"]>0 do
		turnLeft()
	end
	while chests["pos"]>0	do
		moveBackwards()
	end
end

function start()
	-- read chests file
	if fs.exists("Chests.michi") then
		readChestFile()
	else
		setupChests()
	end
end

function inventur()
	--turtle should have empty inventory when using this methods
	--counts chests, checks their content, saves all info to file
	i=1
	setupChests()
	while true do
		gotoChest(i)
		turtle.select(1)
		suc, dat=turtle.inspect()
		if suc and dat.name=="minecraft:chest" then
			addChestToData()
			for j=1,8 do turtle.suck() end
			for j=1,8 do
				turtle.select(j)
				d=turtle.getItemDetail()
				if d~=nil then
					chests[i].items[j]=d
					turtle.drop()
					chests[i].stackCount=j
				end
			end
			i=i+1
		else
			gotoStart()
			writeChestFile()
			return
		end
	end
	
end

function storeRest()
	--stores everything, which is not needed for the recipe, in chests
	itemsDesignatedForChest={} --itemsDesignatedForChest[3]=List of items, which should be put in Chest 3
	itemsToStoreInAnyChest={}
	tmp={} -- List of items needed for crafting, local copy
	for i in pairs(itemsWanted) do
		tmp[i]=itemsWanted[i]
	end


--check, in which chests to put which items
	for i=1,16 do
		local it=inventory.items[i]
		if it~=nil then
			local putCount=it.count
			if tmp[it["name"]]~=nil then
				putCount=math.min(putCount-tmp[it["name"]])
				tmp[it["name"]]=tmp[it["name"]]-putCount
				if tmp[it["name"]]==0 then
					tmp[it["name"]]=nil
				end
			end
			-- look for a chest to put "it" in
				local target=findChestFor(it.name,putCount)
				if target==nil then 
					itemsToStoreInAnyChest[i]=putCount 
				else
					if itemsDesignatedForChest[target.chestIndex]==nil then itemsDesignatedForChest[target.chestIndex]={} end
					itemsDesignatedForChest[target.chestIndex][i]=target["count"]
				end
		end
	end


--go from one chest to the next and store the items there
	for i=1,chests.count do
		if chests[i]["stackCount"]<8 and #itemsToStoreInAnyChest~=0 or itemsDesignatedForChest[i]~=nil then
			gotoChest(i)
			if itemsDesignatedForChest[i]~=nil then
				for j in pairs(itemsDesignatedForChest[i]) do
					--print("Putting designated items to chest ",i)
					turtle.select(j)
					turtle.drop(itemsDesignatedForChest[i][j])
					addItemToChest(i,inventory.items[j].name,itemsDesignatedForChest[i][j])
					itemsDesignatedForChest[i][j]=nil
				end
			end
			for j in pairs(itemsToStoreInAnyChest) do
				if chests[i]["stackCount"]<8 then
					--print("Putting undesignated items to chest",i)
					turtle.select(j)
					turtle.drop(itemsToStoreInAnyChest[j])
					addItemToChest(i,inventory.items[j].name,itemsToStoreInAnyChest[j])
					itemsToStoreInAnyChest[j]=nil
				else
					break
				end
			end
		end
	end
	--return to start and save changes
	gotoStart()
	writeChestFile()
end

function getmissing()
	inventory.sortInventory()
	tmp={} -- List of items needed for crafting, local copy
	for i in pairs(itemsWanted) do
		tmp[i]=itemsWanted[i]
		if inventory.inv[i]~=nil then
			tmp[i]=tmp[i]-inventory.inv[i]
		end
	end


	--check, in which chests the searched items are
	toGet={}-- toGet[i][j]= count of items to take from chest i, slot j
	for i in pairs(chests) do
		toGet[i]={}
		for j=1,8 do
			if chests[i].items[j]~=nil then
				local c=tmp[chests[i].items[j].name]
				if c~=nil then
					toGet[i][j]=math.min(c,chests[i].items[j].count)
					tmp[chests[i].items[j].name]=math.max(0,c-chests[i].items[j].count)
				end
			end
		end
		if #toGet[i]==0 then
			toGet[i]=nil
		end
		if #tmp==0 then 
			break
		end
	end

--get the items
	for i in pairs(chests) do
		--if a searched item is in chest i go there
		if toGet[i]~=nil then
			gotoChest(i)
			turtle.select(1)
			-- take all items
			for j=1,8 do turtle.suck() end

			-- a second counter is needed, as it could happen, that the turtle keeps all items from slot 3, therefore the items from the 4th slot move to the 3rd, the ones from the 5th to the 4th and so on0
			local ind=1
			for j=1,8 do
				--if the j-th item is nil, then we are already done
				if chests[i].items[j]==nil then 
					break 
				end
				turtle.select(j)
				--if toGet[i][j] is nil, then put everything back, else keep some items
				if toGet[i][j]==nil then
					chests[i].items[ind]=chests[i].items[j]
					turtle.drop()
					ind=ind+1
				else
					--in case of equality, keep all items and therefore don't change anything
					-- elsewise return the rest
					if chests[i].items[j]~=toGet[i][j] then
						chests[i].items[ind]=chests[i].items[j]
						print(chests[i].items[j], toGet[i], toGet[i][j])
						turtle.drop(chests[i].items[j].count-toGet[i][j])
						ind=ind+1
					end
				end
			end
			inventory.sortInventory()
		end
	end
	gotoStart()
	writeChestFile()
end

function addItemToChest(chest,name,count)
	-- 
	for i=1,8 do
		t=chests[chest].items[i]
		if t==nil then
			chests[chest].stackCount=chests[chest].stackCount+1
			chests[chest].items[i]={name=name,count=count}
			return true
		else
			if chests[chest].items[i].name==name and chests[chest].items[i].count<itemstacksizes.getStackSize(name) then
				chests[chest].items[i].count=chests[chest].items[i].count+count
				return true
			end
		end
	end
	print("Couldn't find where to put ",count," ",name," in chest",chest)
	return false
end


function findChestFor(item,count)
	for i=1,chests["count"] do
		for j=1,chests[i]["stackCount"] do
			if chests[i]["items"][j]~=nil and chests[i]["items"][j]["name"]==item then
				if chests[i]["items"][j]["count"]<itemstacksizes.getStackSize(item) then
					return {chestIndex=i, count=math.min(count, itemstacksizes.getStackSize(item)-chests[i]["items"][j]["count"])}
				end
			end
		end
	end
	return nil
end


function getItemsFor( itemname, count )
	count=count or 1
	recipes.setRecipe(itemname, count)
	inventory.countInventory()
	--check Which items are needed
	for i in pairs(itemsWanted) do
		itemsWanted[i]=nil
	end
	for i in pairs(recipes.itemsNeeded) do
		itemsWanted[i]=recipes.itemsNeeded[i]
	end
	--store the rest in chests
	storeRest()
	--get the missing items
	getmissing()
end