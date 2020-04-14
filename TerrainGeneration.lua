local generationParts = game.Workspace.EclipsisGeneration


local function initialize_grid(w, h)
  local a = {}
  for i = 1, h do
    table.insert(a, {})
    for j = 1, w do
      table.insert(a[i], false)
    end
  end
  return a
end

local function checkIfEmpty(map, w, h)
	if map[w] == nil then
		return false
	elseif map[w][h] == false then
		return true
	else
		return false
	end
end

local function getRegion(map, steps, posW, posH)
	
	local length = (steps * 2) - 1
	local tab = {}
		
	local minW = posW-steps+1
	local maxW = posW+steps-1
	local minH = posH-steps+1
	local maxH = posH+steps-1
	
	if minW < 0 then
		minW = 0
	end
	
	if maxW > #map then
		maxW = #map
	end
	
	
	if minH < 0 then
		minH = 0
	end
	
	if maxW > #map[1] then
		maxW = #map[1]
	end
	
	for w = minW, maxW do
		for h = minH, maxH do
			table.insert(tab, {w, h})
		end
	end
	
	return tab
	
end



local function addRoundedRegion(tab, map, steps, posW, posH)
	
	local length = (steps * 2) - 1
	
		
	local minW = posW-steps+1
	local maxW = posW+steps-1
	local minH = posH-steps+1
	local maxH = posH+steps-1
	
	local count = 1

	for w = minW, maxW do
		for h = minH, maxH do
			
			count = count + 1
			table.insert(tab, {w, h})
		end
	end
	
	local outerstepsNum = (length/2)-1
	
	
	for t = 1, outerstepsNum do
		length = length - 2
		local offset = math.ceil(length/2)
		
		for i = 1, length do
			
			table.insert(tab, {posW-offset+i, maxH+t}) -- top
			table.insert(tab, {maxW+t, posH-offset+i}) -- right
			table.insert(tab, {posW-offset+i, minH-t}) -- bottom
			table.insert(tab, {minW-t, posH-offset+i}) -- left
			
		end
				
	end 
	
	return tab
	
end


local function getRoundedRegion(map, steps, posW, posH)
	
	local length = (steps * 2) - 1
	local tab = {}
		
	local minW = posW-steps+1
	local maxW = posW+steps-1
	local minH = posH-steps+1
	local maxH = posH+steps-1
	
	local count = 1

	for w = minW, maxW do
		for h = minH, maxH do
			
			count = count + 1
			table.insert(tab, {w, h})
		end
	end
	
	local outerstepsNum = (length/2)-1
	
	
	for t = 1, outerstepsNum do
		length = length - 2
		local offset = math.ceil(length/2)
		
		for i = 1, length do
			
			table.insert(tab, {posW-offset+i, maxH+t}) -- top
			table.insert(tab, {maxW+t, posH-offset+i}) -- right
			table.insert(tab, {posW-offset+i, minH-t}) -- bottom
			table.insert(tab, {minW-t, posH-offset+i}) -- left
			
		end
				
	end 
	
	return tab
	
end

local function drawIsland(map, minSize, maxSize, startW, startH, islandGrowthMin, islandGrowthMax)
	
	local randomGrowth = math.random(islandGrowthMin, islandGrowthMax)
	local tab = {}
	local islandStems = {{startW, startH}}
	
	for i = 1, randomGrowth do
		
		local size = math.random(minSize, maxSize)
		tab = addRoundedRegion(tab, map, size, startW, startH)
		
		startH = startH + math.random(-size+1, size-1)
		startW = startW + math.random(-size+1, size-1)
		
		table.insert(islandStems, {startW, startH})
		
	end
	
	return tab, islandStems
	
end


local function getIslandPos(map, w, h)
	local intialw = math.random(1, w)
	local intialh = math.random(1, h)
	
	local area = getRegion(map, 2, intialw, intialh)
	
	local isempty = true
	
	for i,v in pairs(area) do
		if checkIfEmpty(map, v[1], v[2]) == false then
			isempty = false
		end
	end
	
	if isempty then return {intialw,intialh}
	else return nil
	end
end

local function getWeightTotal(tab)  
local weight = 0
for i,v in pairs(tab) do
	weight = weight + v[2]
end
return weight
end

local StemItems = {
{"Pipe", 10},
{"StemBlock", 20},
{"StemLadder", 5}

}

local SpireItems = {
{"SpireBlock", 50},
{"SpireEmpty", 50}
}

local Items = {
{"Pipe", 1},
{"All", 40},
{"Block", 20},
{"NoRoof", 5},
{"Open", 5},
{"RoofOnly", 5},

}

local stemWeight = getWeightTotal(StemItems)
local itemWeight = getWeightTotal(Items)
local spireWeight = getWeightTotal(SpireItems)


local function chooseItem(tab, weight)
	local randomStem = math.random(1, weight)
	local item = nil
	
	for i,v in pairs(tab) do
		if v[2] >= randomStem then
			item = v[1]
			break
		else
			randomStem = randomStem - v[2]
		end
	end
	
	return item
	
end



local function createMap(w, h, minIslands, maxIslands, minIslandSize, maxIslandSize, islandDistanceFactor, islandGrowthMin, islandGrowthMax, spireChance, spireClusterMaxSize)
	local map = initialize_grid(w, h)
	
	local spiremap = initialize_grid(w, h)
	
	
	local islandsNum = math.random(minIslands, maxIslands)
	local islandsPositions = {}
	
	for i= 1, islandsNum do
		local islandPos = nil
		repeat islandPos = getIslandPos(map, w, h) wait() until islandPos ~= nil
		
		table.insert(islandsPositions, islandPos)
		
		map[islandPos[1]][islandPos[2]] = {chooseItem(StemItems, stemWeight), "Island"..i}
		
	end
	
	for i,v in pairs(islandsPositions) do
		
		local region, islandStems = drawIsland(map, minIslandSize, maxIslandSize, v[1], v[2], islandGrowthMin, islandGrowthMax)
		
		
		for q, t in pairs(islandStems) do
		
		local centerW = t[1]
		local centerH = t[2]
		-- add a stem to island
		local stemsize = math.random(-3, 3)
			
		if stemsize > 1 then
			for wt = centerW, centerW+stemsize+(stemsize-1) do
				for ht = centerH, centerH+(stemsize-1) do
					if checkIfEmpty(map, wt,ht) then
					map[wt][ht] = {chooseItem(StemItems, stemWeight), "Island"..i}	
					end
				end
			end
		
		
		elseif stemsize > 0 and checkIfEmpty(map, centerW, centerH) then
			map[centerW][centerH] = {chooseItem(StemItems, stemWeight), "Island"..i}
		end
			
						
		end	
		
					
			
			
			for x,v in pairs(region) do
				
				if checkIfEmpty(map,v[1],v[2]) then
					local spirechance = math.random(1, spireChance)
					
					if spirechance == 1 then
						
						local cluster = getRoundedRegion(map, math.random(1,spireClusterMaxSize), v[1], v[2])
						
						for x, d in pairs(cluster) do
							if spiremap[d[1]]~= nil then
							
							spiremap[d[1]][d[2]] = {chooseItem(SpireItems, spireWeight), math.abs(d[1]-v[1])+math.abs(d[2]-v[2])}
							end
						end
						
					end
					map[v[1]][v[2]] =  {chooseItem(Items, itemWeight), "Island"..i}
				end
				
			end
	
		
	end
	
	
	
	return map, spiremap
end


function generateMap(w, h, minIslands, maxIslands, minIslandSize, maxIslandSize, islandDistanceFactor, islandGrowthMin, islandGrowthMax, spireChance, spireClusterMaxSize, partSize, offsetPos)
	local map, spires = createMap(w, h, minIslands, maxIslands, minIslandSize, maxIslandSize, islandDistanceFactor, islandGrowthMin, islandGrowthMax, spireChance, spireClusterMaxSize)
	
	local model = Instance.new("Model", workspace)
	model.Name = "Generated Eclipsis terrain" 
	
	for wd = 1, w do
		for ht = 1, h do
			local pos = map[wd][ht]
			
			if pos~=false and pos~=nil and generationParts:FindFirstChild(pos[1]) then
				local mod = generationParts:FindFirstChild(pos[1]):Clone()
				
				if model:FindFirstChild(pos[2]) ~= nil then
					mod.Parent = model[pos[2]]
				else
					local m = Instance.new("Model", model)
					m.Name = pos[2]
					mod.Parent = m
				end
				
			
				local part = mod:GetChildren()[1]
				part.CFrame = CFrame.new(offsetPos + Vector3.new(partSize.X*wd, 0, partSize.Z*ht))
				if #part:GetChildren() > 0 then
					part:GetChildren()[1].CFrame = CFrame.new(offsetPos + Vector3.new(partSize.X*wd, 0, partSize.Z*ht)) *CFrame.fromEulerAnglesYXZ(0,0,math.rad(90))
					part:GetChildren()[1].Parent = mod
				end
				
				if string.sub(mod.Name, 1, 4) == "Stem" or mod.Name == "Pipe" then
				
				for i = 1, 20 do
					local mode = generationParts:FindFirstChild(pos[1]):Clone()
					mode.Parent = mod
					local part = mode:GetChildren()[1]
					part.CFrame = CFrame.new(offsetPos + Vector3.new(partSize.X*wd, partSize.Y*-i, partSize.Z*ht))
					if #part:GetChildren() > 0 then
						part:GetChildren()[1].CFrame = CFrame.new(offsetPos + Vector3.new(partSize.X*wd, partSize.Y*-i, partSize.Z*ht)) *CFrame.fromEulerAnglesYXZ(0,0,math.rad(90))
						part:GetChildren()[1].Parent = mod
					end
					
					
				end
						
				end
				
				
				local spire = spires[wd][ht]
					
					if spire ~= false then
					
							
						local spireHeight = math.ceil(math.random(math.ceil(spireClusterMaxSize*2),math.ceil(spireClusterMaxSize*2.5))-spire[2])
						for i = 1, spireHeight do
							local mode = nil
							if i ~= spireHeight then
							mode = generationParts:FindFirstChild(spire[1]):Clone()
							else
							mode = generationParts.SpireTop:Clone()
							end
							mode.Parent = mod.Parent
							local part = mode:GetChildren()[1]
							
							part.CFrame = CFrame.new(offsetPos + Vector3.new(partSize.X*wd, partSize.Y*i, partSize.Z*ht))
							if #part:GetChildren() > 0 then
								part:GetChildren()[1].CFrame = CFrame.new(offsetPos + Vector3.new(partSize.X*wd, partSize.Y*i, partSize.Z*ht)) *CFrame.fromEulerAnglesYXZ(0,0,math.rad(90))
							end
							
							
							
						end
						
					
				
				
					
					
					
				end
					
			end
			
		end
		wait()
	end
	
end

--w, h, minIslands, maxIslands, minIslandSize, maxIslandSize, islandDistanceFactor, islandGrowthMin, islandGrowthMax, spireChance, spireClusterMaxSize, partSize, offsetPos
generateMap(125, 125, 60, 60, 1, 6, 2, 1, 9, 600, 5, Vector3.new(1.483, 1.271, 1.483), Vector3.new(0,40,0))
