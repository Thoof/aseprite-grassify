--[[-------------------------------------------------------------------------------
Aseprite script that is intended for making pixel grass out of whatever is on the 
current layer or selection

By Thoof (@Thoof4 on twitter)
-------------------------------------------------------------------------------]]--

local dlg = Dialog { title = "Grassify options" }

local function grassify(image)
	local new_image = Image(app.activeSprite.width, app.activeSprite.height, image.colorMode)


	local selection = app.activeSprite.selection
	local offset = selection.bounds
	
	local image_offset = app.activeCel.bounds
	
	local image_selection_offset = Point(offset.x - image_offset.x, offset.y - image_offset.y)
	
	new_image:drawImage(image, Point(app.activeCel.bounds.x, app.activeCel.bounds.y))
	
	
	
	local max_grass_length = dlg.data.grass_length
	local grass_coverage = dlg.data.grass_amount
	local randomize_grass = dlg.data.rand_length
	
	local y_offset = 1
	
	for x = 0, new_image.width - 1, 2 do 
		
		for y = 0, new_image.height - 1, y_offset do
			local invalid_pixel = (y - y_offset) >= new_image.height or (y - y_offset) < 0
		
			if (selection.isEmpty or selection:contains(Point(x, y))) and invalid_pixel == false then 
				local pixel = new_image:getPixel(x, y)
				local next_pixel = new_image:getPixel(x, y - y_offset)
				
				local rand_coverage = math.random(0, 100)
				
				local length = max_grass_length
				if randomize_grass then 
					length = math.random(1, max_grass_length)
				end 

				local pixel_is_transparent = (app.pixelColor.rgbaA(pixel) == 0)
				if image.colorMode == ColorMode.INDEXED then
					pixel_is_transparent = (pixel == app.activeSprite.spec.transparentColor)
				elseif image.colorMode == ColorMode.GRAY then 
					pixel_is_transparent = (app.pixelColor.grayaA(pixel) == 0)
				end
				
				-- If we've found a spot where different colors occur
				if rand_coverage < grass_coverage and pixel_is_transparent == false and pixel ~= next_pixel then 
					
					local y_value = y - y_offset
					local left_pixel = new_image:getPixel(x - 1, y_value)
					local right_pixel = new_image:getPixel(x + 1, y_value)
					
					local grass_length = 0

					while grass_length < length-1 or (left_pixel == pixel or right_pixel == pixel) do
						
						new_image:drawPixel(x, y_value, pixel)
						y_value = y_value - y_offset
						
						left_pixel = new_image:getPixel(x - 1, y_value)
						right_pixel = new_image:getPixel(x + 1, y_value)
						
						grass_length = grass_length + 1
					end
					
					
					new_image:drawPixel(x, y_value, pixel)
				end 
			end
		end 
	end
	
	y_offset = -1
	
	for x = 1, new_image.width, 2 do 
		
		for y = new_image.height - 1, 0, y_offset do
			local invalid_pixel = (y - y_offset) >= new_image.height or (y - y_offset) < 0
				
			if (selection.isEmpty or selection:contains(Point(x, y))) and invalid_pixel == false then 
				local pixel = new_image:getPixel(x, y)
				local next_pixel = new_image:getPixel(x, y - y_offset)
				
				local rand_coverage = math.random(0, 100)
				
				local length = max_grass_length
				if randomize_grass then 
					length = math.random(1, max_grass_length)
				end 
				
				local pixel_is_transparent = app.pixelColor.rgbaA(pixel) == 0
				if image.colorMode == ColorMode.INDEXED then
					pixel_is_transparent = (pixel == app.activeSprite.spec.transparentColor)
				elseif image.colorMode == ColorMode.GRAY then 
					pixel_is_transparent = (app.pixelColor.grayaV(pixel) == 0)
				end
				
				local next_pixel_is_transparent = (app.pixelColor.rgbaA(next_pixel) == 0)
				if image.colorMode == ColorMode.INDEXED then
					next_pixel_is_transparent = (next_pixel == app.activeSprite.spec.transparentColor)
				elseif image.colorMode == ColorMode.GRAY then 
					next_pixel_is_transparent = (app.pixelColor.grayaA(next_pixel) == 0)
				end
				

				
				-- If we've found a spot where different colors occur. For this second loop we only need to do it when the next
				-- pixel is transparent
				if rand_coverage < grass_coverage and pixel_is_transparent == false and pixel ~= next_pixel and next_pixel_is_transparent == true then 
					local y_value = y - y_offset
					local left_pixel = new_image:getPixel(x - 1, y_value)
					local right_pixel = new_image:getPixel(x + 1, y_value)
					
					local grass_length = 0

					while grass_length < length - 1 or (left_pixel == pixel or right_pixel == pixel) do
						new_image:drawPixel(x, y_value, pixel)
						y_value = y_value - y_offset
						
						left_pixel = new_image:getPixel(x - 1, y_value)
						right_pixel = new_image:getPixel(x + 1, y_value)
						
						grass_length = grass_length + 1
					end
					
					
					new_image:drawPixel(x, y_value, pixel)
				end 
			end
		end 
	end
	
	
	
	return new_image
end

dlg:slider {
    id = "grass_amount",
    label = "Grass coverage (%): ",
    min = 1,
    max = 100,
    value = 100,
	onchange = function()
			
	end
}

dlg:slider {
    id = "grass_length",
    label = "Grass length (px)",
    min = 1,
    max = 5,
    value = 1,
	onchange = function()
			
	end
}

dlg:check {
	id = "rand_length",
	label = string,
	text = "Randomize length",
	selected = boolean,
	onclick = function()
	end
}

dlg:button {
	id = "grassify",
	text = "Grassify",
	onclick = function()
		app.transaction(
			function()
				app.activeCel.image = grassify(app.activeCel.image)
				app.activeCel.position = Point(0, 0)
				app.refresh()
			end)
		
	end 
}


dlg:show { 
	wait = false
}

