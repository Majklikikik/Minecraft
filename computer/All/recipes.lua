rec={6,6,6}
count=1
mult=1
name=""
itemsNeeded={} --itemsNeeded[<name>]=count of item <name> needed
maxCount=64 -- how many items of the current recipe can maximally be crafted (for example: 16 diamond pickaxes, as there is not space for 17 in turtle inventory)
-- but only 10 doors, as 11 need more than 1 stack of planks

function checkInventoryMatchesRecipe()
	-- returns: true, if inventory matches recipe, false, if not
	countInventory()
	log("inv: "..textutils.serialize(inv)..", end")
	for i=1,3 do
		for j=1,3 do
			if rec[i][j]~=nil
			then
				if inv[rec[i][j]]==nil
				then
					log("Doesn't Match!")
					log(textutils.serialize(inv))
					log(rec[i][j])
					return false
				else
					inv[rec[i][j]]=inv[rec[i][j]]-count
				end
			end
		end
	end
	for i in pairs(inv) do
		if inv[i]~=0
		then
			log("Too many or not enough items!")
			log(inv[i])
			log(i)
			return false
		end
	end
	log("Matches!")
	return true
end

function craftIndexToInvIndex(y,x)
	return 4*(y-1)+x
end

function arrangeInventoryToRecipe()
	countInventory()
	for i=1,16 do
		if items[i]~=nil then
			turtle.select(i)
			for y=1,3 do
				for x=1,3 do
					if turtle.getItemDetail()~=nil and rec[y][x]==turtle.getItemDetail().name then
						turtle.transferTo(craftIndexToInvIndex(y,x),count)
					end
				end
			end
		end
	end
end

function craftRecipe()
end

function setRecipe(id,c)
	count=c or 1
	name=id
	--log("Setting recipe to "..id.." x "..c)
 	if (id=="minecraft:diamond_pickaxe")
 		then
 		rec={{"minecraft:diamond","minecraft:diamond","minecraft:diamond"},{nil,"minecraft:stick",nil},{nil,"minecraft:stick",nil}}
 		maxCount=16
		--count=math.min(count,maxCount)
		mult=1
		recalculateItemsNeeded()
		return true;
	elseif (id=="minecraft:chest")
	then
		rec={{"minecraft:oak_planks","minecraft:oak_planks","minecraft:oak_planks"},{"minecraft:oak_planks",nil,"minecraft:oak_planks"},{"minecraft:oak_planks","minecraft:oak_planks","minecraft:oak_planks"}}
		maxCount=8
		--count=math.min(count,maxCount)
		mult=1
		recalculateItemsNeeded()
		return true;
	elseif (id=="minecraft:oak_planks")
	then
		rec={ { nil,nil,nil},{nil,"minecraft:oak_log",nil },{nil,nil,nil}}
		maxCount=256
		--count=math.min(count,maxCount)
		mult=4
		recalculateItemsNeeded()
		return true;
	elseif (id=="computercraft:computer_normal")
	then
		rec={ { "minecraft:stone","minecraft:stone","minecraft:stone"},{"minecraft:stone","minecraft:redstone","minecraft:stone" },{"minecraft:stone","minecraft:glass_pane","minecraft:stone"}}
		maxCount=9
		--count=math.min(count,maxCount)
		mult=1
		recalculateItemsNeeded()
		return true;
	elseif (id=="computercraft:turtle_normal")
	then
		rec={ { "minecraft:iron_ingot","minecraft:iron_ingot","minecraft:iron_ingot"},{"minecraft:iron_ingot","computercraft:computer_normal","minecraft:iron_ingot" },{"minecraft:iron_ingot","minecraft:chest","minecraft:iron_ingot"}}
		maxCount=9
		--count=math.min(count,maxCount)
		mult=1
		recalculateItemsNeeded()
		return true;
	elseif (id=="minecraft:glass_pane")
	then
		rec={ { "minecraft:glass","minecraft:glass","minecraft:glass"},{"minecraft:glass","minecraft:glass","minecraft:glass" },{nil,nil,nil}}
		maxCount=160
		--count=math.min(count,maxCount)
		mult=16
		recalculateItemsNeeded()
		return true;
	elseif (id=="computercraft:turtle_normal")
	then
		rec={ { "minecraft:stone","minecraft:stone","minecraft:stone"},{"minecraft:stone","minecraft:redstone","minecraft:stone" },{"minecraft:stone","minecraft:glass_pane","minecraft:stone"}}
		maxCount=8
		--count=math.min(count,maxCount)
		mult=1
		recalculateItemsNeeded()
		return true;
	elseif (id=="computercraft:turtle_normal")
	then
		rec={ { "minecraft:stone","minecraft:stone","minecraft:stone"},{"minecraft:stone","minecraft:redstone","minecraft:stone" },{"minecraft:stone","minecraft:glass_pane","minecraft:stone"}}
		maxCount=8
		--count=math.min(count,maxCount)
		mult=1
		recalculateItemsNeeded()
		return true;
	elseif (id=="computercraft:turtle_normal")
	then
		rec={ { "minecraft:stone","minecraft:stone","minecraft:stone"},{"minecraft:stone","minecraft:redstone","minecraft:stone" },{"minecraft:stone","minecraft:glass_pane","minecraft:stone"}}
		maxCount=8
		--count=math.min(count,maxCount)
		mult=1
		recalculateItemsNeeded()
		return true;
	elseif (id=="minecraft:stick") then
		rec = {{nil,nil,nil},{nil,nil,"minecraft:oak_planks"},{nil,nil,"minecraft:oak_planks"}}
		maxCount=8 --? idk what this means
		recalculateItemsNeeded()
		return true;
 	end
	log("Recipe not found!")
	return false;
end 

function recalculateItemsNeeded()
	for i in pairs(itemsNeeded) do
		itemsNeeded[i]=nil
	end
	local c=math.ceil(count/mult)
	for i=1,3 do
		for j=1,3 do
			if rec[i][j]~=nil then
				if itemsNeeded[rec[i][j]]==nil then
					itemsNeeded[rec[i][j]]=c
				else
					itemsNeeded[rec[i][j]]=itemsNeeded[rec[i][j]]+c
				end
			end
		end
	end
	if count>maxCount then
		log("Warning: Recipe set for "..count.." of "..name..", but maximum craftable in 1 batch is "..maxCount.."!")
	end
end