

-- This class contains methods implementing strategies for farming ressources

-- only needed when starting new turtle 



-- gathers atleast the specified amount of wood 
-- spiral 0 is not accounted for but we should not neeed it because our starting area takes a significant amount up and we dont want to fuck it up
-- spiral logic is there progress is saved in the file gathering.txt
-- spiral[progress]
-- spiral[pos]
-- spiral[ring]
-- spiral[dir]
-- 

function gather_wood(quantity)
	local h = fs.open("gathering.txt", "r")
	local spiral = textutils.unserialize(h.readAll())
	h.close() 

	local wood = 0; 
	while wood < quantity do 
		wood = wood + gather_ring(quantity-wood,spiral)
	end
	local w = fs.open("gathering.txt", "w")
	w.write(textutils.serialize(spiral))
	w.close() 
end

-- goes mining in a specified spiral until it gets enough wood. returns true if it found the specified quantity of wood.... 
-- writes progress to the wood file ...
-- also mines sand when encountering it
function gather_ring(quantity, spiral) 

	local wood = 0
	local upward = false
	
	movement.go_towards(vector.new(spiral["pos"].x, spiral["pos"].y,spiral["pos"].z))
	movement.turn(spiral["dir"])	
	local spiral_size = 4 + 8*spiral["ring"]

	for prog = spiral["progress"],spiral_size do
		-- turn turtle left if on one of the 4 edges 
		if math.fmod(prog, (spiral_size / 4)) == 2 + spiral["ring"]  then
			movement.turn_left()
		end 

		local success, data = turtle.inspect()
		--check for tree  and kill it
		print(data.name)
		if is_wood(data.name) then 
			movement.move_forward()
			wood = wood+1
			for i = 1,6 do
				if is_wood(table.pack(turtle.inspectUp())[2].name) then
					wood = wood +1
				end
				movement.move_up()
			end
			for i = 1,6 do
				movement.move_down()
			end
		else 
			-- walk up and down until on a surface and then walk forward

			while not ((turtle.detectDown() and not turtle.detect()) or (upward and not turtle.detect())) do 
				if not turtle.detectDown() and not turtle.detect() and not upward then
					move_down()
				else
					move_up()
					upward = true
				end
			end
			if table.pack(turtle.inspectDown())[2].name == "minecraft:sand" then
				turtle.digDown()
			end
			movement.move_forward()
			upward = false
		end
		if wood >= quantity then 
			print (current_dir)
			spiral["progress"] = prog +1
			spiral["dir"] = current_dir
			spiral["pos"] = vector.new(movement.current_pos.x, movement.current_pos.y, movement.current_pos.z) -- doing it like this to obtain a copy
			return wood
		end
	end
	--next ring
	spiral["progress"] = 1
	spiral["dir"] = movement.directions["SOUTH"]  --default value
	spiral["ring"] = spiral["ring"] +1
	spiral["pos"].x = movement.current_pos.x -1   
	spiral["pos"].y = movement.current_pos.y
	spiral["pos"].z = movement.current_pos.z 


	return wood
end

function is_wood(blockid)	
	return blockid == "minecraft:oak_log" or blockid == "minecraft:spruce_log" or 
		   blockid == "minecraft:birch_log" or blockid == "minecraft:jungle_log" or 
		   blockid == "minecraft:acacia_log" or blockid == "minecraft:dark_oak_log"
end

function is_ore(blockid)
	return blockid == "minecraft:diamond_ore" or blockid == "minecraft:iron_ore" or 
	blockid == "minecraft:coal_ore" or blockid == "minecraft:redstone_ore" or 
	blockid == "minecraft:deepslate_redstone_ore"
end
--- 
function checkForRessources()
	dir = current_dir
	movement.turn(movement.directions["NORTH"])
	if is_ore(table.pack(turtle.inspect())[2].name) then
		turtle.dig()
	end
	movement.turn(movement.directions["SOUTH"])
	if is_ore(table.pack(turtle.inspect())[2].name) then
		turtle.dig()
	end
	if is_ore(table.pack(turtle.inspectUp())[2].name) then 
		turtle.digUp()
	end
	if is_ore(table.pack(turtle.inspectDown())[2].name) then 
		turtle.digDown()
	end
	movement.turn(dir)
end



-- expects a dictionary with neccessary items to mite 
function mine(goal)

	local h = fs.open("mining.txt", "r")
	local mining = textutils.unserialize(h.readAll())
	h.close() 

	local tunnel_length = 5 --low value for testing
	local mining_heigth = 8 -- corresponds to 4 tunnels per walk upwards ....
	mining_spot = vector.new(mining["pos"].x, mining["pos"].y, mining["pos"].z)  -- 60

	heigth = mining["heigth"] --load from file later 

	movement.go_towards(mining_spot)
	for x = 1,1 do   --replace with while loop which checks for inventory containing certain items

		movement.turn(movement.directions["EAST"])
		for i = 0,tunnel_length do
			movement.move_forward()
			checkForRessources()	
		end
		

		 --make row in same field
		heigth = heigth + 2;
		for i = 1,2 do 
			movement.move_up()
		end	
		movement.turn(movement.directions["NORTH"])
		movement.move_forward()
		
		--else calculate new mining spot 
		movement.turn(movement.directions["WEST"])

		for i = 0,tunnel_length do
			movement.move_forward()
			checkForRessources()	
		end
		--check if inventory contains neccessarry ressources
		-- and save mining progress
		-- TODO ....

		if heigth + 4 < mining_heigth then  --make row in same field
			heigth = heigth + 2;
			for i = 1,2 do 
				move_up()
			end	
			movement.turn(movement.directions["NORTH"])
			movement.move_forward()
		else 
			local down = 0; 
			if height - 7 < 0 then 
				down = 5
			else 
				down = 7 
			end
			for i = 1,down do 
				move_down()
			end
			heigth = heigth -down
		end
		  
	end
	
	mining["pos"] = movement.current_pos
	mining["heigth"] = heigth
	local w = fs.open("mining.txt", "w")
	w.write(textutils.serialize(mining))
	w.close()
		
	
end




