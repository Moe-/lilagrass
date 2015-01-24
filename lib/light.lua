--[[
The MIT License (MIT)

Copyright (c) 2014 Marcus Ihde

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

LOVE_LIGHT_CURRENT = nil
LOVE_LIGHT_CIRCLE = nil
LOVE_LIGHT_POLY = nil
LOVE_LIGHT_IMAGE = nil
LOVE_LIGHT_BODY = nil
LOVE_LIGHT_LAST_BUFFER = nil
LOVE_LIGHT_SHADOW_GEOMETRY = nil

LOVE_LIGHT_SHADER = love.graphics.newShader("shader/light.glsl")
LOVE_LIGHT_BLURV = love.graphics.newShader("shader/blurv.glsl")
LOVE_LIGHT_BLURH = love.graphics.newShader("shader/blurh.glsl")
LOVE_LIGHT_BLURV:send("screen", {love.window.getWidth(), love.window.getHeight()})
LOVE_LIGHT_BLURH:send("screen", {love.window.getWidth(), love.window.getHeight()})

LOVE_LIGHT_TRANSLATE = false
LOVE_LIGHT_TRANSLATE_X = 0
LOVE_LIGHT_TRANSLATE_Y = 0
LOVE_LIGHT_TRANSLATE_X_OLD = 0
LOVE_LIGHT_TRANSLATE_Y_OLD = 0
LOVE_LIGHT_TRANSLATE_SCALE = 1
LOVE_LIGHT_TRANSLATE_SCALE_OLD = 1
LOVE_LIGHT_TRANSLATE_ROTATION = 0
LOVE_LIGHT_TRANSLATE_ROTATION_OLD = 0

love.light = {}

-- light world
function love.light.newWorld()
	local o = {}

	o.lights = {}
	o.ambient = {0, 0, 0}
	o.body = {}
	o.refraction = {}
	o.shadow = love.graphics.newCanvas()
	o.shadow2 = love.graphics.newCanvas()
	o.shine = love.graphics.newCanvas()
	o.shine2 = love.graphics.newCanvas()
	o.normalMap = love.graphics.newCanvas()
	o.glowMap = love.graphics.newCanvas()
	o.glowMap2 = love.graphics.newCanvas()
	o.refractionMap = love.graphics.newCanvas()
	o.refractionMap2 = love.graphics.newCanvas()
	o.reflectionMap = love.graphics.newCanvas()
	o.reflectionMap2 = love.graphics.newCanvas()
	o.normalInvert = false
	o.glowBlur = 1.0
	o.glowTimer = 0.0
	o.glowDown = false
	o.refractionStrength = 8.0
	o.pixelShadow = love.graphics.newCanvas()
	o.pixelShadow2 = love.graphics.newCanvas()
	o.shader = love.graphics.newShader("shader/poly_shadow.glsl")
	o.glowShader = love.graphics.newShader("shader/glow.glsl")
	o.normalShader = love.graphics.newShader("shader/normal.glsl")
	o.normalInvertShader = love.graphics.newShader("shader/normal_invert.glsl")
	o.materialShader = love.graphics.newShader("shader/material.glsl")
	o.refractionShader = love.graphics.newShader("shader/refraction.glsl")
	o.refractionShader:send("screen", {love.window.getWidth(), love.window.getHeight()})
	o.reflectionShader = love.graphics.newShader("shader/reflection.glsl")
	o.reflectionShader:send("screen", {love.window.getWidth(), love.window.getHeight()})
	o.reflectionStrength = 16.0
	o.reflectionVisibility = 1.0
	o.changed = true
	o.blur = 2.0
	o.optionShadows = true
	o.optionPixelShadows = true
	o.optionGlow = true
	o.optionRefraction = true
	o.optionReflection = true
	o.isShadows = false
	o.isLight = false
	o.isPixelShadows = false
	o.isGlow = false
	o.isRefraction = false
	o.isReflection = false

	-- update
	o.update = function()
		LOVE_LIGHT_LAST_BUFFER = love.graphics.getCanvas()

		if LOVE_LIGHT_TRANSLATE_X ~= LOVE_LIGHT_TRANSLATE_X_OLD
		or LOVE_LIGHT_TRANSLATE_Y ~= LOVE_LIGHT_TRANSLATE_Y_OLD
		or LOVE_LIGHT_TRANSLATE_SCALE ~= LOVE_LIGHT_TRANSLATE_SCALE_OLD
		or LOVE_LIGHT_TRANSLATE_ROTATION ~= LOVE_LIGHT_TRANSLATE_ROTATION_OLD
		then
			LOVE_LIGHT_TRANSLATE_X_OLD = LOVE_LIGHT_TRANSLATE_X
			LOVE_LIGHT_TRANSLATE_Y_OLD = LOVE_LIGHT_TRANSLATE_Y
			LOVE_LIGHT_TRANSLATE_SCALE_OLD = LOVE_LIGHT_TRANSLATE_SCALE
			LOVE_LIGHT_TRANSLATE_ROTATION_OLD = LOVE_LIGHT_TRANSLATE_ROTATION
			o.changed = true
		end

		love.graphics.setColor(255, 255, 255)
		love.graphics.setBlendMode("alpha")
		if o.optionShadows and (o.isShadows or o.isLight) then
			local lightsOnScreen = 0
			LOVE_LIGHT_BODY = o.body
			for i = 1, #o.lights do
				if o.lights[i].changed or o.changed then
					if ((o.lights[i].x + LOVE_LIGHT_TRANSLATE_X) * LOVE_LIGHT_TRANSLATE_SCALE + love.graphics.getWidth() * 0.5) + (o.lights[i].range * LOVE_LIGHT_TRANSLATE_SCALE) > 0
					and ((o.lights[i].x + LOVE_LIGHT_TRANSLATE_X) * LOVE_LIGHT_TRANSLATE_SCALE + love.graphics.getWidth() * 0.5) - (o.lights[i].range * LOVE_LIGHT_TRANSLATE_SCALE) < love.graphics.getWidth()
					and ((o.lights[i].y + LOVE_LIGHT_TRANSLATE_Y) * LOVE_LIGHT_TRANSLATE_SCALE + love.graphics.getHeight() * 0.5) + (o.lights[i].range * LOVE_LIGHT_TRANSLATE_SCALE) > 0
					and ((o.lights[i].y + LOVE_LIGHT_TRANSLATE_Y) * LOVE_LIGHT_TRANSLATE_SCALE + love.graphics.getHeight() * 0.5) - (o.lights[i].range * LOVE_LIGHT_TRANSLATE_SCALE) < love.graphics.getHeight()
					then
						LOVE_LIGHT_CURRENT = o.lights[i]

						o.shader:send("lightPosition", {
							(o.lights[i].x + LOVE_LIGHT_TRANSLATE_X) * LOVE_LIGHT_TRANSLATE_SCALE + love.graphics.getWidth() * 0.5,
							love.graphics.getHeight() - ((o.lights[i].y + LOVE_LIGHT_TRANSLATE_Y) * LOVE_LIGHT_TRANSLATE_SCALE + love.graphics.getHeight() * 0.5),
							o.lights[i].z
						})
						o.shader:send("lightRange", o.lights[i].range * LOVE_LIGHT_TRANSLATE_SCALE)
						o.shader:send("lightColor", {o.lights[i].red / 255.0, o.lights[i].green / 255.0, o.lights[i].blue / 255.0})
						o.shader:send("lightSmooth", o.lights[i].smooth)
						o.shader:send("lightGlow", {1.0 - o.lights[i].glowSize, o.lights[i].glowStrength})
						o.shader:send("lightAngle", math.pi - o.lights[i].angle / 2.0)
						o.shader:send("lightDirection", o.lights[i].direction)

						love.graphics.setCanvas(o.lights[i].shadow)
						love.graphics.clear()

						-- calculate shadows
						LOVE_LIGHT_SHADOW_GEOMETRY = calculateShadows(LOVE_LIGHT_CURRENT, LOVE_LIGHT_BODY)

						-- draw shadow
						love.graphics.setInvertedStencil(shadowStencil)
						love.graphics.setBlendMode("additive")
						love.graphics.setShader(o.shader)

						if LOVE_LIGHT_TRANSLATE and LOVE_GRAPHICS_PUSHED then
							love.graphics.pop()
							LOVE_GRAPHICS_PUSHED = false
						end
						love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
						if LOVE_LIGHT_TRANSLATE then
							love.graphics.push()
							love.graphics.translate(love.window.getWidth() * 0.5, love.window.getHeight() * 0.5)
							love.graphics.scale(LOVE_LIGHT_TRANSLATE_SCALE)
							love.graphics.rotate(LOVE_LIGHT_TRANSLATE_ROTATION)
							love.graphics.translate(LOVE_LIGHT_TRANSLATE_X, LOVE_LIGHT_TRANSLATE_Y)
							LOVE_GRAPHICS_PUSHED = true
						end

						-- draw color shadows
						love.graphics.setBlendMode("multiplicative")
						love.graphics.setShader()
						for k = 1,#LOVE_LIGHT_SHADOW_GEOMETRY do
							if LOVE_LIGHT_SHADOW_GEOMETRY[k].alpha < 1.0 then
								love.graphics.setColor(
									LOVE_LIGHT_SHADOW_GEOMETRY[k].red * (1.0 - LOVE_LIGHT_SHADOW_GEOMETRY[k].alpha),
									LOVE_LIGHT_SHADOW_GEOMETRY[k].green * (1.0 - LOVE_LIGHT_SHADOW_GEOMETRY[k].alpha),
									LOVE_LIGHT_SHADOW_GEOMETRY[k].blue * (1.0 - LOVE_LIGHT_SHADOW_GEOMETRY[k].alpha)
								)
								love.graphics.polygon("fill", unpack(LOVE_LIGHT_SHADOW_GEOMETRY[k]))
							end
						end

						for k = 1, #LOVE_LIGHT_BODY do
							if LOVE_LIGHT_BODY[k].alpha < 1.0 then
								love.graphics.setBlendMode("multiplicative")
								love.graphics.setColor(LOVE_LIGHT_BODY[k].red, LOVE_LIGHT_BODY[k].green, LOVE_LIGHT_BODY[k].blue)
								if LOVE_LIGHT_BODY[k].shadowType == "circle" then
									love.graphics.circle("fill", LOVE_LIGHT_BODY[k].x - LOVE_LIGHT_BODY[k].ox, LOVE_LIGHT_BODY[k].y - LOVE_LIGHT_BODY[k].oy, LOVE_LIGHT_BODY[k].radius)
								elseif LOVE_LIGHT_BODY[k].shadowType == "rectangle" then
									love.graphics.rectangle("fill", LOVE_LIGHT_BODY[k].x - LOVE_LIGHT_BODY[k].ox, LOVE_LIGHT_BODY[k].y - LOVE_LIGHT_BODY[k].oy, LOVE_LIGHT_BODY[k].width, LOVE_LIGHT_BODY[k].height)
								elseif LOVE_LIGHT_BODY[k].shadowType == "polygon" then
									love.graphics.polygon("fill", unpack(LOVE_LIGHT_BODY[k].data))
								end
							end

							if LOVE_LIGHT_BODY[k].shadowType == "image" and LOVE_LIGHT_BODY[k].img then
								love.graphics.setBlendMode("alpha")
								local length = 1.0
								local shadowRotation = math.atan2((LOVE_LIGHT_BODY[k].x) - o.lights[i].x, (LOVE_LIGHT_BODY[k].y + LOVE_LIGHT_BODY[k].oy) - o.lights[i].y)
								--local alpha = math.abs(math.cos(shadowRotation))

								LOVE_LIGHT_BODY[k].shadowVert = {
									{math.sin(shadowRotation) * LOVE_LIGHT_BODY[k].imgHeight * length, (length * math.cos(shadowRotation) + 1.0) * LOVE_LIGHT_BODY[k].imgHeight + (math.cos(shadowRotation) + 1.0) * LOVE_LIGHT_BODY[k].shadowY, 0, 0, LOVE_LIGHT_BODY[k].red, LOVE_LIGHT_BODY[k].green, LOVE_LIGHT_BODY[k].blue, LOVE_LIGHT_BODY[k].alpha * LOVE_LIGHT_BODY[k].fadeStrength * 255},
									{LOVE_LIGHT_BODY[k].imgWidth + math.sin(shadowRotation) * LOVE_LIGHT_BODY[k].imgHeight * length, (length * math.cos(shadowRotation) + 1.0) * LOVE_LIGHT_BODY[k].imgHeight + (math.cos(shadowRotation) + 1.0) * LOVE_LIGHT_BODY[k].shadowY, 1, 0, LOVE_LIGHT_BODY[k].red, LOVE_LIGHT_BODY[k].green, LOVE_LIGHT_BODY[k].blue, LOVE_LIGHT_BODY[k].alpha * LOVE_LIGHT_BODY[k].fadeStrength * 255},
									{LOVE_LIGHT_BODY[k].imgWidth, LOVE_LIGHT_BODY[k].imgHeight + (math.cos(shadowRotation) + 1.0) * LOVE_LIGHT_BODY[k].shadowY, 1, 1, LOVE_LIGHT_BODY[k].red, LOVE_LIGHT_BODY[k].green, LOVE_LIGHT_BODY[k].blue, LOVE_LIGHT_BODY[k].alpha * 255},
									{0, LOVE_LIGHT_BODY[k].imgHeight + (math.cos(shadowRotation) + 1.0) * LOVE_LIGHT_BODY[k].shadowY, 0, 1, LOVE_LIGHT_BODY[k].red, LOVE_LIGHT_BODY[k].green, LOVE_LIGHT_BODY[k].blue, LOVE_LIGHT_BODY[k].alpha * 255}
								}

								LOVE_LIGHT_BODY[k].shadowMesh:setVertices(LOVE_LIGHT_BODY[k].shadowVert)
								love.graphics.draw(LOVE_LIGHT_BODY[k].shadowMesh, LOVE_LIGHT_BODY[k].x - LOVE_LIGHT_BODY[k].ox, LOVE_LIGHT_BODY[k].y - LOVE_LIGHT_BODY[k].oy)
							end
						end

						love.graphics.setShader(o.shader)

						-- draw shine
						love.graphics.setCanvas(o.lights[i].shine)
						o.lights[i].shine:clear(255, 255, 255)
						love.graphics.setBlendMode("alpha")
						love.graphics.setStencil(polyStencil)
						if LOVE_LIGHT_TRANSLATE then
							love.graphics.pop()
						end
						love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
						if LOVE_LIGHT_TRANSLATE then
							love.graphics.push()
							love.graphics.translate(love.window.getWidth() * 0.5, love.window.getHeight() * 0.5)
							love.graphics.scale(LOVE_LIGHT_TRANSLATE_SCALE)
							love.graphics.rotate(LOVE_LIGHT_TRANSLATE_ROTATION)
							love.graphics.translate(LOVE_LIGHT_TRANSLATE_X, LOVE_LIGHT_TRANSLATE_Y)
						end

						lightsOnScreen = lightsOnScreen + 1

						o.lights[i].visible = true
					else
						o.lights[i].visible = false
					end

					o.lights[i].changed = o.changed
				end
			end

			love.graphics.setStencil()
			love.graphics.setShader()
			if LOVE_LIGHT_TRANSLATE then
				love.graphics.pop()
			end

			-- update shadow
			love.graphics.setCanvas(o.shadow)
			love.graphics.setColor(unpack(o.ambient))
			love.graphics.setBlendMode("alpha")
			love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
			love.graphics.setColor(255, 255, 255)
			love.graphics.setBlendMode("additive")
			for i = 1, #o.lights do
				if o.lights[i].visible then
					love.graphics.draw(o.lights[i].shadow)
				end
			end
			o.isShadowBlur = false

			-- update shine
			love.graphics.setCanvas(o.shine)
			love.graphics.setColor(unpack(o.ambient))
			love.graphics.setBlendMode("alpha")
			love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
			love.graphics.setColor(255, 255, 255)
			love.graphics.setBlendMode("additive")
			for i = 1, #o.lights do
				if o.lights[i].visible then
					love.graphics.draw(o.lights[i].shine)
				end
			end

			if LOVE_LIGHT_TRANSLATE then
				love.graphics.push()
				love.graphics.translate(love.window.getWidth() * 0.5, love.window.getHeight() * 0.5)
				love.graphics.scale(LOVE_LIGHT_TRANSLATE_SCALE)
				love.graphics.rotate(LOVE_LIGHT_TRANSLATE_ROTATION)
				love.graphics.translate(LOVE_LIGHT_TRANSLATE_X, LOVE_LIGHT_TRANSLATE_Y)
			end
		end

		--if o.optionPixelShadows and o.isPixelShadows then
			-- update pixel shadow
			love.graphics.setBlendMode("alpha")

			-- create normal map
			o.normalMap:clear(127, 127, 255)
			love.graphics.setShader()
			love.graphics.setCanvas(o.normalMap)
			for i = 1, #o.body do
				if o.body[i].type == "image" and o.body[i].normal then
					love.graphics.setColor(255, 255, 255)
					love.graphics.draw(
						o.body[i].normal,
						o.body[i].quad,
						o.body[i].x,
						o.body[i].y,
						o.body[i].rotation,
						1,
						1,
						o.body[i].nx,
						o.body[i].ny
					)
				end
			end
		--end

		if o.optionGlow and o.isGlow then
			-- create glow map
			o.glowMap:clear(0, 0, 0)
			love.graphics.setCanvas(o.glowMap)

			if o.glowDown then
				o.glowTimer = math.max(0.0, o.glowTimer - love.timer.getDelta())
				if o.glowTimer == 0.0 then
					o.glowDown = not o.glowDown
				end
			else
				o.glowTimer = math.min(o.glowTimer + love.timer.getDelta(), 1.0)
				if o.glowTimer == 1.0 then
					o.glowDown = not o.glowDown
				end
			end

			for i = 1, #o.body do
				if o.body[i].ignoreGlow == false then
					if o.body[i].glowStrength > 0.0 then
						love.graphics.setColor(o.body[i].glowRed * o.body[i].glowStrength, o.body[i].glowGreen * o.body[i].glowStrength, o.body[i].glowBlue * o.body[i].glowStrength)
					else
						love.graphics.setColor(0, 0, 0)
					end

					if o.body[i].type == "circle" then
						love.graphics.circle("fill", o.body[i].x, o.body[i].y, o.body[i].radius)
					elseif o.body[i].type == "rectangle" then
						love.graphics.rectangle("fill", o.body[i].x, o.body[i].y, o.body[i].width, o.body[i].height)
					elseif o.body[i].type == "polygon" then
						if #o.body[i].data >= 3 then
							love.graphics.polygon("fill", unpack(o.body[i].data))
						end
					elseif o.body[i].type == "image" and o.body[i].img then
						if o.body[i].glowStrength > 0.0 and o.body[i].glow then
							love.graphics.setShader(o.glowShader)
							o.glowShader:send("glowImage", o.body[i].glow)
							o.glowShader:send("glowTime", love.timer.getTime() * 0.5)
							love.graphics.setColor(255, 255, 255)
						else
							love.graphics.setShader()
							love.graphics.setColor(0, 0, 0)
						end
						love.graphics.draw(
							o.body[i].img,
							o.body[i].quad,
							o.body[i].x,
							o.body[i].y,
							o.body[i].rotation,
							1,
							1,
							o.body[i].ix,
							o.body[i].iy
						)
					end
				end
			end
		end

		--if o.optionRefraction and o.isRefraction then
			love.graphics.setShader()

			-- create refraction map
			o.refractionMap:clear()
			love.graphics.setCanvas(o.refractionMap)
			for i = 1, #o.body do
				if o.body[i].isRefraction and o.body[i].normalMesh then
					love.graphics.setColor(255, 255, 255)
					o.body[i].normalMesh:setVertices(o.body[i].normalVert)
					love.graphics.draw(o.body[i].normalMesh, o.body[i].x - o.body[i].nx, o.body[i].y - o.body[i].ny)
				end
			end

			love.graphics.setColor(0, 0, 0)
			for i = 1, #o.body do
				if not o.body[i].isRefractive then
					if o.body[i].type == "circle" then
						love.graphics.circle("fill", o.body[i].x, o.body[i].y, o.body[i].radius)
					elseif o.body[i].type == "rectangle" then
						love.graphics.rectangle("fill", o.body[i].x, o.body[i].y, o.body[i].width, o.body[i].height)
					elseif o.body[i].type == "polygon" then
						love.graphics.polygon("fill", unpack(o.body[i].data))
					elseif o.body[i].type == "image" and o.body[i].img then
						love.graphics.draw(o.body[i].img, o.body[i].x - o.body[i].ix, o.body[i].y - o.body[i].iy)
					end
				end
			end
		--end

		--if o.optionReflection and o.isReflection then
			-- create reflection map
			--if o.changed then
				o.reflectionMap:clear(0, 0, 0)

			--end
		--end

		love.graphics.setShader()
		love.graphics.setBlendMode("alpha")
		love.graphics.setStencil()
		love.graphics.setCanvas(LOVE_LIGHT_LAST_BUFFER)

		o.changed = false
	end

	o.updatePixelShadow = function()
		o.pixelShadow:clear()
		love.graphics.setCanvas(o.pixelShadow)
		love.graphics.setBlendMode("additive")
		love.graphics.setShader(o.shader2)
		if LOVE_LIGHT_TRANSLATE then
			love.graphics.pop()
		end

		for i = 1, #o.lights do
			if o.lights[i].visible then
				if o.normalInvert then
					o.normalInvertShader:send('screenResolution', {love.graphics.getWidth(), love.graphics.getHeight()})
					o.normalInvertShader:send('lightColor', {o.lights[i].red / 255.0, o.lights[i].green / 255.0, o.lights[i].blue / 255.0})
					o.normalInvertShader:send('lightPosition',{
						(o.lights[i].x + LOVE_LIGHT_TRANSLATE_X) * LOVE_LIGHT_TRANSLATE_SCALE + love.graphics.getWidth() * 0.5,
						love.graphics.getHeight() - ((o.lights[i].y + LOVE_LIGHT_TRANSLATE_Y) * LOVE_LIGHT_TRANSLATE_SCALE + love.graphics.getHeight() * 0.5),
						o.lights[i].z / 255.0
					})
					o.normalInvertShader:send('lightRange',{o.lights[i].range * LOVE_LIGHT_TRANSLATE_SCALE})
					o.normalInvertShader:send("lightSmooth", o.lights[i].smooth)
					o.normalInvertShader:send("lightAngle", math.pi - o.lights[i].angle / 2.0)
					o.normalInvertShader:send("lightDirection", o.lights[i].direction)
					love.graphics.setShader(o.normalInvertShader)
				else
					o.normalShader:send('screenResolution', {love.graphics.getWidth(), love.graphics.getHeight()})
					o.normalShader:send('lightColor', {o.lights[i].red / 255.0, o.lights[i].green / 255.0, o.lights[i].blue / 255.0})
					o.normalShader:send('lightPosition',{
						(o.lights[i].x + LOVE_LIGHT_TRANSLATE_X) * LOVE_LIGHT_TRANSLATE_SCALE + love.graphics.getWidth() * 0.5,
						love.graphics.getHeight() - ((o.lights[i].y + LOVE_LIGHT_TRANSLATE_Y) * LOVE_LIGHT_TRANSLATE_SCALE + love.graphics.getHeight() * 0.5),
						o.lights[i].z / 255.0
					})
					o.normalShader:send('lightRange',{o.lights[i].range * LOVE_LIGHT_TRANSLATE_SCALE})
					o.normalShader:send("lightSmooth", o.lights[i].smooth)
					o.normalShader:send("lightAngle", math.pi - o.lights[i].angle / 2.0)
					o.normalShader:send("lightDirection", o.lights[i].direction)
					love.graphics.setShader(o.normalShader)
				end
				love.graphics.draw(o.normalMap)
			end
		end

		love.graphics.setShader()
		love.graphics.setBlendMode("alpha")
		love.graphics.setStencil()
		love.graphics.setCanvas(LOVE_LIGHT_LAST_BUFFER)
		if LOVE_LIGHT_TRANSLATE then
			love.graphics.push()
			love.graphics.translate(love.window.getWidth() * 0.5, love.window.getHeight() * 0.5)
			love.graphics.scale(LOVE_LIGHT_TRANSLATE_SCALE)
			love.graphics.rotate(LOVE_LIGHT_TRANSLATE_ROTATION)
			love.graphics.translate(LOVE_LIGHT_TRANSLATE_X, LOVE_LIGHT_TRANSLATE_Y)
		end
	end

	o.refreshScreenSize = function()
		o.shadow = love.graphics.newCanvas()
		o.shadow2 = love.graphics.newCanvas()
		o.shine = love.graphics.newCanvas()
		o.shine2 = love.graphics.newCanvas()
		o.normalMap = love.graphics.newCanvas()
		o.glowMap = love.graphics.newCanvas()
		o.glowMap2 = love.graphics.newCanvas()
		o.refractionMap = love.graphics.newCanvas()
		o.refractionMap2 = love.graphics.newCanvas()
		o.reflectionMap = love.graphics.newCanvas()
		o.reflectionMap2 = love.graphics.newCanvas()
		o.pixelShadow = love.graphics.newCanvas()
		o.pixelShadow2 = love.graphics.newCanvas()
	end
	-- draw shadow
	o.drawShadow = function()
		if #o.lights >= 1 and o.optionShadows and (o.isShadows or o.isLight) then
			love.graphics.setColor(255, 255, 255)
			if LOVE_LIGHT_TRANSLATE then
				love.graphics.pop()
			end

			if o.blur then
				LOVE_LIGHT_LAST_BUFFER = love.graphics.getCanvas()
				LOVE_LIGHT_BLURV:send("steps", o.blur)
				LOVE_LIGHT_BLURH:send("steps", o.blur)
				love.graphics.setBlendMode("alpha")
				love.graphics.setCanvas(o.shadow2)
				love.graphics.setShader(LOVE_LIGHT_BLURV)
				love.graphics.draw(o.shadow)
				love.graphics.setCanvas(o.shadow)
				love.graphics.setShader(LOVE_LIGHT_BLURH)
				love.graphics.draw(o.shadow2)
				love.graphics.setCanvas(LOVE_LIGHT_LAST_BUFFER)
				love.graphics.setBlendMode("multiplicative")
				love.graphics.setShader()
				love.graphics.draw(o.shadow)
				love.graphics.setBlendMode("alpha")
			else
				love.graphics.setBlendMode("multiplicative")
				love.graphics.setShader()
				love.graphics.draw(o.shadow)
				love.graphics.setBlendMode("alpha")
			end

			if LOVE_LIGHT_TRANSLATE then
				love.graphics.push()
				love.graphics.translate(love.window.getWidth() * 0.5, love.window.getHeight() * 0.5)
				love.graphics.scale(LOVE_LIGHT_TRANSLATE_SCALE)
				love.graphics.rotate(LOVE_LIGHT_TRANSLATE_ROTATION)
				love.graphics.translate(LOVE_LIGHT_TRANSLATE_X, LOVE_LIGHT_TRANSLATE_Y)
			end
		end
	end
	-- draw shine
	o.drawShine = function()
		if #o.lights >= 1 and o.optionShadows and o.isShadows then
			love.graphics.setColor(255, 255, 255)
			if LOVE_LIGHT_TRANSLATE then
				love.graphics.pop()
			end

			if o.blur and false then
				LOVE_LIGHT_LAST_BUFFER = love.graphics.getCanvas()
				LOVE_LIGHT_BLURV:send("steps", o.blur)
				LOVE_LIGHT_BLURH:send("steps", o.blur)
				love.graphics.setBlendMode("alpha")
				love.graphics.setCanvas(o.shine2)
				love.graphics.setShader(LOVE_LIGHT_BLURV)
				love.graphics.draw(o.shine)
				love.graphics.setCanvas(o.shine)
				love.graphics.setShader(LOVE_LIGHT_BLURH)
				love.graphics.draw(o.shine2)
				love.graphics.setCanvas(LOVE_LIGHT_LAST_BUFFER)
				love.graphics.setBlendMode("multiplicative")
				love.graphics.setShader()
				love.graphics.draw(o.shine)
				love.graphics.setBlendMode("alpha")
			else
				love.graphics.setBlendMode("multiplicative")
				love.graphics.setShader()
				love.graphics.draw(o.shine)
				love.graphics.setBlendMode("alpha")
			end

			if LOVE_LIGHT_TRANSLATE then
				love.graphics.push()
				love.graphics.translate(love.window.getWidth() * 0.5, love.window.getHeight() * 0.5)
				love.graphics.scale(LOVE_LIGHT_TRANSLATE_SCALE)
				love.graphics.rotate(LOVE_LIGHT_TRANSLATE_ROTATION)
				love.graphics.translate(LOVE_LIGHT_TRANSLATE_X, LOVE_LIGHT_TRANSLATE_Y)
			end
		end
	end
	-- draw pixel shadow
	o.drawPixelShadow = function()
		--if #o.lights >= 1 and o.optionPixelShadows and o.isPixelShadows then
			if LOVE_LIGHT_TRANSLATE then
				love.graphics.pop()
			end

			love.graphics.setColor(255, 255, 255)
			love.graphics.setBlendMode("multiplicative")
			love.graphics.setShader(LOVE_LIGHT_SHADER)
			love.graphics.draw(o.pixelShadow)
			love.graphics.setShader()
			love.graphics.setBlendMode("alpha")

			if LOVE_LIGHT_TRANSLATE then
				love.graphics.push()
				love.graphics.translate(love.window.getWidth() * 0.5, love.window.getHeight() * 0.5)
				love.graphics.scale(LOVE_LIGHT_TRANSLATE_SCALE)
				love.graphics.rotate(LOVE_LIGHT_TRANSLATE_ROTATION)
				love.graphics.translate(LOVE_LIGHT_TRANSLATE_X, LOVE_LIGHT_TRANSLATE_Y)
			end
		--end
	end
	-- draw material
	o.drawMaterial = function()
		love.graphics.setShader(o.materialShader)
		for i = 1, #o.body do
			if o.body[i].material and o.body[i].normal then
				love.graphics.setColor(255, 255, 255)
				o.materialShader:send("material", o.body[i].material)
				love.graphics.draw(o.body[i].normal, o.body[i].x - o.body[i].nx, o.body[i].y - o.body[i].ny)
			end
		end
		love.graphics.setShader()
	end
	-- draw glow
	o.drawGlow = function()
		--if o.optionGlow and o.isGlow then
			love.graphics.setColor(255, 255, 255)
			if LOVE_LIGHT_TRANSLATE then
				love.graphics.pop()
			end

			if o.glowBlur == 0.0 then
				love.graphics.setBlendMode("additive")
				love.graphics.setShader()
				love.graphics.draw(o.glowMap)
				love.graphics.setBlendMode("alpha")
			else
				LOVE_LIGHT_BLURV:send("steps", o.glowBlur)
				LOVE_LIGHT_BLURH:send("steps", o.glowBlur)
				LOVE_LIGHT_LAST_BUFFER = love.graphics.getCanvas()
				love.graphics.setBlendMode("additive")
				o.glowMap2:clear()
				love.graphics.setCanvas(o.glowMap2)
				love.graphics.setShader(LOVE_LIGHT_BLURV)
				love.graphics.draw(o.glowMap)
				love.graphics.setCanvas(o.glowMap)
				love.graphics.setShader(LOVE_LIGHT_BLURH)
				love.graphics.draw(o.glowMap2)
				love.graphics.setCanvas(LOVE_LIGHT_LAST_BUFFER)
				love.graphics.setShader()
				love.graphics.draw(o.glowMap)
				love.graphics.setBlendMode("alpha")
			end

			if LOVE_LIGHT_TRANSLATE then
				love.graphics.push()
				love.graphics.translate(love.window.getWidth() * 0.5, love.window.getHeight() * 0.5)
				love.graphics.scale(LOVE_LIGHT_TRANSLATE_SCALE)
				love.graphics.rotate(LOVE_LIGHT_TRANSLATE_ROTATION)
				love.graphics.translate(LOVE_LIGHT_TRANSLATE_X, LOVE_LIGHT_TRANSLATE_Y)
			end
		--end
	end
	-- draw refraction
	o.drawRefraction = function()
		--if o.optionRefraction and o.isRefraction then
			if LOVE_LIGHT_TRANSLATE then
				love.graphics.pop()
			end

			LOVE_LIGHT_LAST_BUFFER = love.graphics.getCanvas()
			if LOVE_LIGHT_LAST_BUFFER then
				love.graphics.setColor(255, 255, 255)
				love.graphics.setBlendMode("alpha")
				love.graphics.setCanvas(o.refractionMap2)
				love.graphics.draw(LOVE_LIGHT_LAST_BUFFER)
				love.graphics.setCanvas(LOVE_LIGHT_LAST_BUFFER)
				o.refractionShader:send("backBuffer", o.refractionMap2)
				o.refractionShader:send("refractionStrength", o.refractionStrength)
				love.graphics.setShader(o.refractionShader)
				love.graphics.draw(o.refractionMap)
				love.graphics.setShader()
			end

			if LOVE_LIGHT_TRANSLATE then
				love.graphics.push()
				love.graphics.translate(love.window.getWidth() * 0.5, love.window.getHeight() * 0.5)
				love.graphics.scale(LOVE_LIGHT_TRANSLATE_SCALE)
				love.graphics.rotate(LOVE_LIGHT_TRANSLATE_ROTATION)
				love.graphics.translate(LOVE_LIGHT_TRANSLATE_X, LOVE_LIGHT_TRANSLATE_Y)
			end
		--end
	end
	-- draw reflection
	o.drawReflection = function()
		--if o.optionReflection and o.isReflection then
			if LOVE_LIGHT_TRANSLATE then
				love.graphics.pop()
			end

			LOVE_LIGHT_LAST_BUFFER = love.graphics.getCanvas()
			if LOVE_LIGHT_LAST_BUFFER then
				love.graphics.setColor(255, 255, 255)
				love.graphics.setBlendMode("alpha")
				love.graphics.setCanvas(o.reflectionMap2)
				love.graphics.draw(LOVE_LIGHT_LAST_BUFFER)
				love.graphics.setCanvas(LOVE_LIGHT_LAST_BUFFER)
				o.reflectionShader:send("backBuffer", o.reflectionMap2)
				o.reflectionShader:send("reflectionStrength", o.reflectionStrength)
				o.reflectionShader:send("reflectionVisibility", o.reflectionVisibility)
				love.graphics.setShader(o.reflectionShader)
				love.graphics.draw(o.reflectionMap)
				love.graphics.setShader()
			end

			if LOVE_LIGHT_TRANSLATE then
				love.graphics.push()
				love.graphics.translate(love.window.getWidth() * 0.5, love.window.getHeight() * 0.5)
				love.graphics.scale(LOVE_LIGHT_TRANSLATE_SCALE)
				love.graphics.rotate(LOVE_LIGHT_TRANSLATE_ROTATION)
				love.graphics.translate(LOVE_LIGHT_TRANSLATE_X, LOVE_LIGHT_TRANSLATE_Y)
			end
		--end
	end
	-- new light
	o.newLight = function(x, y, red, green, blue, range)
		o.lights[#o.lights + 1] = love.light.newLight(o, x, y, red, green, blue, range)

		return o.lights[#o.lights]
	end
	-- clear lights
	o.clearLights = function()
		o.lights = {}
		o.isLight = false
		o.changed = true
	end
	-- clear objects
	o.clearBodys = function()
		o.body = {}
		o.changed = true
		o.isShadows = false
		o.isPixelShadows = false
		o.isGlow = false
		o.isRefraction = false
		o.isReflection = false
	end
	-- set translation
	o.setTranslation = function(x, y)
		LOVE_LIGHT_TRANSLATE_X = x
		LOVE_LIGHT_TRANSLATE_Y = y
		LOVE_LIGHT_TRANSLATE = true
	end
	-- set scale
	o.setScale = function(scale)
		LOVE_LIGHT_TRANSLATE_SCALE = scale
		LOVE_LIGHT_TRANSLATE = true
	end
	-- set rotation
	o.setRotation = function(rotation)
		LOVE_LIGHT_TRANSLATE_ROTATION = rotation
		LOVE_LIGHT_TRANSLATE = true
	end
	-- set ambient color
	o.setAmbientColor = function(red, green, blue)
		o.ambient = {red, green, blue}
	end
	-- set ambient red
	o.setAmbientRed = function(red)
		o.ambient[1] = red
	end
	-- set ambient green
	o.setAmbientGreen = function(green)
		o.ambient[2] = green
	end
	-- set ambient blue
	o.setAmbientBlue = function(blue)
		o.ambient[3] = blue
	end
	-- set normal invert
	o.setNormalInvert = function(invert)
		o.normalInvert = invert
	end
	-- set blur
	o.setBlur = function(blur)
		o.blur = blur
		o.changed = true
	end
	-- set blur
	o.setShadowBlur = function(blur)
		o.blur = blur
		o.changed = true
	end
	-- set buffer
	o.setBuffer = function(buffer)
		if buffer == "render" then
			love.graphics.setCanvas(LOVE_LIGHT_LAST_BUFFER)
		else
			LOVE_LIGHT_LAST_BUFFER = love.graphics.getCanvas()
		end

		if buffer == "glow" then
			o.isGlow = true
			love.graphics.setCanvas(o.glowMap)
		elseif buffer == "pixelshadow" then
			love.graphics.setCanvas(o.normalMap)
		elseif buffer == "refraction" then
			love.graphics.setCanvas(o.refractionMap)
		elseif buffer == "reflection" then
			love.graphics.setCanvas(o.reflectionMap)
		end
	end
	-- set glow blur
	o.setGlowStrength = function(strength)
		o.glowBlur = strength
		o.changed = true
	end
	-- set refraction blur
	o.setRefractionStrength = function(strength)
		o.refractionStrength = strength
	end
	-- set reflection strength
	o.setReflectionStrength = function(strength)
		o.reflectionStrength = strength
	end
	-- set reflection visibility
	o.setReflectionVisibility = function(visibility)
		o.reflectionVisibility = visibility
	end
	-- new rectangle
	o.newRectangle = function(x, y, w, h)
		return love.light.newRectangle(o, x, y, w, h)
	end
	-- new circle
	o.newCircle = function(x, y, r)
		return love.light.newCircle(o, x, y, r)
	end
	-- new polygon
	o.newPolygon = function(...)
		return love.light.newPolygon(o, ...)
	end
	-- new image
	o.newImage = function(img, x, y, width, height, ox, oy)
		return love.light.newImage(o, img, x, y, width, height, ox, oy)
	end
	-- new refraction
	o.newRefraction = function(normal, x, y)
		return love.light.newRefraction(o, normal, x, y)
	end
	-- new refraction from height map
	o.newRefractionHeightMap = function(heightMap, x, y, strength)
		return love.light.newRefractionHeightMap(o, heightMap, x, y, strength)
	end
	-- new reflection
	o.newReflection = function(normal, x, y)
		return love.light.newReflection(o, normal, x, y)
	end
	-- new reflection from height map
	o.newReflectionHeightMap = function(heightMap, x, y, strength)
		return love.light.newReflectionHeightMap(o, heightMap, x, y, strength)
	end
	-- new body
	o.newBody = function(type, ...)
		return love.light.newBody(o, type, ...)
	end
	-- set polygon data
	o.setPoints = function(n, ...)
		o.body[n].data = {...}
	end
	-- get polygon count
	o.getBodyCount = function()
		return #o.body
	end
	-- get polygon
	o.getPoints = function(n)
		if o.body[n].data then
			return unpack(o.body[n].data)
		end
	end
	-- set light position
	o.setLightPosition = function(n, x, y, z)
		o.lights[n].setPosition(x, y, z)
	end
	-- set light x
	o.setLightX = function(n, x)
		o.lights[n].setX(x)
	end
	-- set light y
	o.setLightY = function(n, y)
		o.lights[n].setY(y)
	end
	-- set light angle
	o.setLightAngle = function(n, angle)
		o.lights[n].setAngle(angle)
	end
	-- set light direction
	o.setLightDirection = function(n, direction)
		o.lights[n].setDirection(direction)
	end
	-- get light count
	o.getLightCount = function()
		return #o.lights
	end
	-- get light x position
	o.getLightX = function(n)
		return o.lights[n].x
	end
	-- get light y position
	o.getLightY = function(n)
		return o.lights[n].y
	end
	-- get type
	o.getType = function()
		return "world"
	end

	return o
end

-- light object
function love.light.newLight(p, x, y, red, green, blue, range)
	local o = {}
	o.direction = 0
	o.angle = math.pi * 2.0
	o.range = 0
	o.shadow = love.graphics.newCanvas()
	o.shine = love.graphics.newCanvas()
	o.x = x or 0
	o.y = y or 0
	o.z = 15
	o.red = red or 255
	o.green = green or 255
	o.blue = blue or 255
	o.range = range or 300
	o.smooth = 1.0
	o.glowSize = 0.1
	o.glowStrength = 0.0
	o.changed = true
	o.visible = true
	p.isLight = true
	-- set position
	o.setPosition = function(x, y, z)
		if x ~= o.x or y ~= o.y or (z and z ~= o.z) then
			o.x = x
			o.y = y
			if z then
				o.z = z
			end
			o.changed = true
		end
	end
	-- get x
	o.getX = function()
		return o.x
	end
	-- get y
	o.getY = function()
		return o.y
	end
	-- set x
	o.setX = function(x)
		if x ~= o.x then
			o.x = x
			o.changed = true
		end
	end
	-- set y
	o.setY = function(y)
		if y ~= o.y then
			o.y = y
			o.changed = true
		end
	end
	-- set color
	o.setColor = function(red, green, blue)
		o.red = red
		o.green = green
		o.blue = blue
		--p.changed = true
	end
	-- set range
	o.setRange = function(range)
		if range ~= o.range then
			o.range = range
			o.changed = true
		end
	end
	-- set direction
	o.setDirection = function(direction)
		if direction ~= o.direction then
			if direction > math.pi * 2 then
				o.direction = math.mod(direction, math.pi * 2)
			elseif direction < 0.0 then
				o.direction = math.pi * 2 - math.mod(math.abs(direction), math.pi * 2)
			else
				o.direction = direction
			end
			o.changed = true
		end
	end
	-- set angle
	o.setAngle = function(angle)
		if angle ~= o.angle then
			if angle > math.pi * 2 then
				o.angle = math.mod(angle, math.pi)
			elseif angle < 0.0 then
				o.angle = math.pi - math.mod(math.abs(angle), math.pi)
			else
				o.angle = angle
			end
			o.changed = true
		end
	end
	-- set glow size
	o.setSmooth = function(smooth)
		o.smooth = smooth
		o.changed = true
	end
	-- set glow size
	o.setGlowSize = function(size)
		o.glowSize = size
		o.changed = true
	end
	-- set glow strength
	o.setGlowStrength = function(strength)
		o.glowStrength = strength
		o.changed = true
	end
	-- get type
	o.getType = function()
		return "light"
	end
	-- clear
	o.clear = function()
		for i = 1, #p.lights do
			if p.lights[i] == o then
				for k = i, #p.lights - 1 do
					p.lights[k] = p.lights[k + 1]
				end
				p.lights[#p.lights] = nil
				break
			end
		end
	end

	return o
end

-- body object
function love.light.newBody(p, type, ...)
	local args = {...}
	local o = {}
	p.body[#p.body + 1] = o
	p.changed = true
	o.id = #p.body
	o.type = type
	o.normal = nil
	o.material = nil
	o.glow = nil
	o.rotation = 0
	o.scale = 1
	if o.type == "circle" then
		o.x = args[1] or 0
		o.y = args[2] or 0
		o.radius = args[3] or 16
		o.ox = args[4] or 0
		o.oy = args[5] or 0
		o.shadowType = "circle"
		o.isReflection = false
		o.isReflective = false
		o.isRefraction = false
		o.isRefractive = false
		p.isShadows = true
	elseif o.type == "rectangle" then
		o.x = args[1] or 0
		o.y = args[2] or 0
		o.width = args[3] or 64
		o.height = args[4] or 64
		o.ox = o.width * 0.5
		o.oy = o.height * 0.5
		o.shadowType = "rectangle"
		o.data = {
			o.x - o.ox,
			o.y - o.oy,
			o.x - o.ox + o.width,
			o.y - o.oy,
			o.x - o.ox + o.width,
			o.y - o.oy + o.height,
			o.x - o.ox,
			o.y - o.oy + o.height
		}
		o.isReflection = false
		o.isReflective = false
		o.isRefraction = false
		o.isRefractive = false
		p.isShadows = true
	elseif o.type == "polygon" then
		o.shadowType = "polygon"
		o.data = args or {0, 0, 0, 0, 0, 0}
		o.isReflection = false
		o.isReflective = false
		o.isRefraction = false
		o.isRefractive = false
		p.isShadows = true
	elseif o.type == "image" then
		o.img = args[1]
		o.x = args[2] or 0
		o.y = args[3] or 0
		if o.img then
			o.imgWidth = o.img:getWidth()
			o.imgHeight = o.img:getHeight()
			o.width = args[4] or o.imgWidth
			o.height = args[5] or o.imgHeight
			o.ix = o.imgWidth * 0.5
			o.iy = o.imgHeight * 0.5
			o.vert = {
				{0.0, 0.0, 0.0, 0.0},
				{o.imgWidth, 0.0, o.imgWidth / o.img:getWidth() / o.scale, 0.0},
				{o.imgWidth, o.imgHeight, o.imgWidth / o.img:getWidth() / o.scale, o.imgHeight / o.img:getHeight() / o.scale},
				{0.0, o.imgHeight, 0.0, o.imgHeight / o.img:getHeight() / o.scale}
			}
			o.msh = love.graphics.newMesh(o.vert, o.img, "fan")
		else
			o.width = args[4] or 64
			o.height = args[5] or 64
		end
		o.ox = args[6] or o.width * 0.5
		o.oy = args[7] or o.height * 0.5
		o.quad = love.graphics.newQuad(0, 0, args[4] or o.imgWidth, args[5] or o.imgHeight, o.img:getWidth() * o.scale, o.img:getHeight() * o.scale)
		o.shadowType = "polygon"
		o.data = {
			o.x - o.ox,
			o.y - o.oy,
			o.x - o.ox + o.width,
			o.y - o.oy,
			o.x - o.ox + o.width,
			o.y - o.oy + o.height,
			o.x - o.ox,
			o.y - o.oy + o.height
		}
		o.isReflection = false
		o.isReflective = true
		o.isRefraction = false
		o.isRefractive = false
		p.isShadows = true
		p.isReflective = true
	elseif o.type == "refraction" then
		o.normal = args[1]
		o.x = args[2] or 0
		o.y = args[3] or 0
		if o.normal then
			o.normalWidth = o.normal:getWidth()
			o.normalHeight = o.normal:getHeight()
			o.width = args[4] or o.normalWidth
			o.height = args[5] or o.normalHeight
			o.nx = o.normalWidth * 0.5
			o.ny = o.normalHeight * 0.5
			o.normal:setWrap("repeat", "repeat")
			o.normalVert = {
				{0.0, 0.0, 0.0, 0.0},
				{o.width, 0.0, 1.0, 0.0},
				{o.width, o.height, 1.0, 1.0},
				{0.0, o.height, 0.0, 1.0}
			}
			o.normalMesh = love.graphics.newMesh(o.normalVert, o.normal, "fan")
		else
			o.width = args[4] or 64
			o.height = args[5] or 64
		end
		o.ox = o.width * 0.5
		o.oy = o.height * 0.5
		o.isReflection = false
		o.isReflective = false
		o.isRefraction = true
		o.isRefractive = false
		p.isRefraction = true
	elseif o.type == "reflection" then
		o.normal = args[1]
		o.x = args[2] or 0
		o.y = args[3] or 0
		if o.normal then
			o.normalWidth = o.normal:getWidth()
			o.normalHeight = o.normal:getHeight()
			o.width = args[4] or o.normalWidth
			o.height = args[5] or o.normalHeight
			o.nx = o.normalWidth * 0.5
			o.ny = o.normalHeight * 0.5
			o.normal:setWrap("repeat", "repeat")
			o.normalVert = {
				{0.0, 0.0, 0.0, 0.0},
				{o.width, 0.0, 1.0, 0.0},
				{o.width, o.height, 1.0, 1.0},
				{0.0, o.height, 0.0, 1.0}
			}
			o.normalMesh = love.graphics.newMesh(o.normalVert, o.normal, "fan")
		else
			o.width = args[4] or 64
			o.height = args[5] or 64
		end
		o.ox = o.width * 0.5
		o.oy = o.height * 0.5
		o.isReflection = true
		o.isReflective = false
		o.isRefraction = false
		o.isRefractive = false
		p.isReflection = true
	end
	o.shine = true
	o.red = 0
	o.green = 0
	o.blue = 0
	o.alpha = 1.0
	o.glowRed = 255
	o.glowGreen = 255
	o.glowBlue = 255
	o.glowStrength = 0.0
	o.ignoreGlow = false
	o.tileX = 0
	o.tileY = 0
	-- refresh
	o.refresh = function()
		if o.shadowType == "rectangle" and o.data then
			o.data[1] = o.x - o.ox
			o.data[2] = o.y - o.oy
			o.data[3] = o.x - o.ox + o.width
			o.data[4] = o.y - o.oy
			o.data[5] = o.x - o.ox + o.width
			o.data[6] = o.y - o.oy + o.height
			o.data[7] = o.x - o.ox
			o.data[8] = o.y - o.oy + o.height
		end
	end
	-- set position
	o.setPosition = function(x, y)
		if x ~= o.x or y ~= o.y then
			o.x = x
			o.y = y
			o.refresh()
			p.changed = true
		end
	end
	-- set x position
	o.setX = function(x)
		if x ~= o.x then
			o.x = x
			o.refresh()
			p.changed = true
		end
	end
	-- set y position
	o.setY = function(y)
		if y ~= o.y then
			o.y = y
			o.refresh()
			p.changed = true
		end
	end
	-- get x position
	o.getX = function()
		return o.x
	end
	-- get y position
	o.getY = function(y)
		return o.y
	end
	-- get width
	o.getWidth = function()
		return o.width
	end
	-- get height
	o.getHeight = function()
		return o.height
	end
	-- get image width
	o.getImageWidth = function()
		return o.imgWidth
	end
	-- get image height
	o.getImageHeight = function()
		return o.imgHeight
	end
	-- set dimension
	o.setDimension = function(width, height)
		o.width = width
		o.height = height
		o.refresh()
		p.changed = true
	end
	-- set rotation
	o.setRotation = function(rotation)
		o.rotation = rotation
		p.changed = true
	end
	-- set scale
	o.setScale = function(scale)
		o.scale = scale
		o.refresh()
		p.changed = true
	end
	-- set offset
	o.setOffset = function(ox, oy)
		if ox ~= o.ox or oy ~= o.oy then
			o.ox = ox
			o.oy = oy
			o.refresh()
			p.changed = true
		end
	end
	-- set x offset
	o.setOffsetX = function(ox)
		if ox ~= o.ox then
			o.ox = ox
			o.refresh()
			p.changed = true
		end
	end
	-- set y offset
	o.setOffsetY = function(oy)
		if oy ~= o.oy then
			o.oy = oy
			o.refresh()
			p.changed = true
		end
	end
	-- set offset
	o.setImageOffset = function(ix, iy)
		if ix ~= o.ix or iy ~= o.iy then
			o.ix = ix
			o.iy = iy
			o.refresh()
			p.changed = true
		end
	end
	-- set x offset
	o.setImageOffsetX = function(ix)
		if ix ~= o.ix then
			o.ix = ix
			o.refresh()
			p.changed = true
		end
	end
	-- set y offset
	o.setImageOffsetY = function(iy)
		if iy ~= o.iy then
			o.iy = iy
			o.refresh()
			p.changed = true
		end
	end
	-- set offset
	o.setNormalOffset = function(nx, ny)
		if nx ~= o.nx or ny ~= o.ny then
			o.nx = nx
			o.ny = ny
			o.refresh()
			p.changed = true
		end
	end
	-- set glow color
	o.setGlowColor = function(red, green, blue)
		o.glowRed = red
		o.glowGreen = green
		o.glowBlue = blue
		p.changed = true
	end
	-- set glow alpha
	o.setGlowStrength = function(strength)
		o.glowStrength = strength
		p.changed = true
	end
	-- get radius
	o.getRadius = function()
		return o.radius
	end
	-- set radius
	o.setRadius = function(radius)
		if radius ~= o.radius then
			o.radius = radius
			p.changed = true
		end
	end
	-- set polygon data
	o.setPoints = function(...)
		o.data = {...}
		p.changed = true
	end
	-- get polygon data
	o.getPoints = function()
		return unpack(o.data)
	end
	-- set shadow on/off
	o.setShadowType = function(type)
		o.shadowType = type
		p.changed = true
	end
	-- set shadow on/off
	o.setShadow = function(b)
		o.castsNoShadow = not b
		p.changed = true
	end
	-- set shine on/off
	o.setShine = function(b)
		o.shine = b
		p.changed = true
	end
	-- set glass color
	o.setColor = function(red, green, blue)
		o.red = red
		o.green = green
		o.blue = blue
		p.changed = true
	end
	-- set glass alpha
	o.setAlpha = function(alpha)
		o.alpha = alpha
		p.changed = true
	end
	-- set reflection on/off
	o.setReflection = function(reflection)
		o.isReflection = reflection
		if reflection then
			p.isReflection = true
		end
	end
	-- set refraction on/off
	o.setRefraction = function(refraction)
		o.isRefraction = refraction
		if refraction then
			p.isRefraction = true
		end
	end
	-- set reflective on other objects on/off
	o.setReflective = function(reflective)
		o.isReflective = reflective
		if reflective then
			p.isReflective = true
		end
	end
	-- set refractive on other objects on/off
	o.setRefractive = function(refractive)
		o.isRefractive = refractive
		if refractive then
			p.isRefractive = true
		end
	end
	-- set image
	o.setImage = function(img, width, height, ix, iy)
		if img then
			o.img = img
			o.imgWidth = o.img:getWidth()
			o.imgHeight = o.img:getHeight()
			o.ix = ix or o.imgWidth * 0.5
			o.iy = iy or o.imgHeight * 0.5
			o.vert = {
				{0.0, 0.0, 0.0, 0.0},
				{o.imgWidth, 0.0, o.imgWidth / o.img:getWidth() / o.scale, 0.0},
				{o.imgWidth, o.imgHeight, o.imgWidth / o.img:getWidth() / o.scale, o.imgHeight / o.img:getHeight() / o.scale},
				{0.0, o.imgHeight, 0.0, o.imgHeight / o.img:getHeight() / o.scale}
			}
			o.msh = love.graphics.newMesh(o.vert, o.img, "fan")
		end
	end
	-- set quad
	o.setQuad = function(x, y, width, height, sw, sh)
		o.quad = love.graphics.newQuad(x, y, width, height, sw, sh)
	end
	-- set viewport
	o.setViewport = function(x, y, width, height)
		o.quad:setViewport(x, y, width, height)
	end
	-- set normal
	o.setNormalMap = function(normal, width, height, nx, ny)
		if normal then
			o.normal = normal
			o.normal:setWrap("repeat", "repeat")
			o.normalWidth = width or o.normal:getWidth()
			o.normalHeight = height or o.normal:getHeight()
			o.nx = nx or o.normalWidth * 0.5
			o.ny = ny or o.normalHeight * 0.5
			o.normalVert = {
				{0.0, 0.0, 0.0, 0.0},
				{o.normalWidth, 0.0, o.normalWidth / o.normal:getWidth() / o.scale, 0.0},
				{o.normalWidth, o.normalHeight, o.normalWidth / o.normal:getWidth() / o.scale, o.normalHeight / o.normal:getHeight() / o.scale},
				{0.0, o.normalHeight, 0.0, o.normalHeight / o.normal:getHeight() / o.scale}
			}
			o.normalMesh = love.graphics.newMesh(o.normalVert, o.normal, "fan")

			p.isPixelShadows = true
		else
			o.normalMesh = nil
		end
	end
	-- set height map
	o.setHeightMap = function(heightMap, strength)
		o.setNormalMap(HeightMapToNormalMap(heightMap, strength))
	end
	-- generate flat normal map
	o.generateNormalMapFlat = function(mode, width, height, nx, ny)
		if o.img then
			local imgData = o.img:getData()
			local imgNormalData = love.image.newImageData(o.imgWidth, o.imgHeight)
			local color

			if mode == "top" then
				color = {127, 127, 255}
			elseif mode == "front" then
				color = {127, 0, 127}
			elseif mode == "back" then
				color = {127, 255, 127}
			elseif mode == "left" then
				color = {31, 0, 223}
			elseif mode == "right" then
				color = {223, 0, 127}
			end

			for i = 0, o.imgHeight - 1 do
				for k = 0, o.imgWidth - 1 do
					local r, g, b, a = imgData:getPixel(k, i)
					if a > 0 then
						imgNormalData:setPixel(k, i, color[1], color[2], color[3], 255)
					end
				end
			end

			o.setNormalMap(love.graphics.newImage(imgNormalData), width, height, nx, ny)
		end
	end
	-- generate faded normal map
	o.generateNormalMapGradient = function(horizontalGradient, verticalGradient, width, height, nx, ny)
		local imgData = o.img:getData()
		local imgNormalData = love.image.newImageData(o.imgWidth, o.imgHeight)
		local dx = 255.0 / o.imgWidth
		local dy = 255.0 / o.imgHeight
		local nx
		local ny
		local nz

		for i = 0, o.imgWidth - 1 do
			for k = 0, o.imgHeight - 1 do
				local r, g, b, a = imgData:getPixel(i, k)
				if a > 0 then
					if horizontalGradient == "gradient" then
						nx = i * dx
					elseif horizontalGradient == "inverse" then
						nx = 255 - i * dx
					else
						nx = 127
					end

					if verticalGradient == "gradient" then
						ny = 127 - k * dy * 0.5
						nz = 255 - k * dy * 0.5
					elseif verticalGradient == "inverse" then
						ny = 127 + k * dy * 0.5
						nz = 127 - k * dy * 0.25
					else
						ny = 255
						nz = 127
					end

					imgNormalData:setPixel(i, k, nx, ny, nz, 255)
				end
			end
		end

		o.setNormalMap(love.graphics.newImage(imgNormalData), width, height, nx, ny)
	end
	-- generate normal map
	o.generateNormalMap = function(strength)
		o.setNormalMap(HeightMapToNormalMap(o.img, strength))
	end
	-- set material
	o.setMaterial = function(material)
		if material then
			o.material = material
		end
	end
	-- set glow map
	o.setGlowMap = function(glow)
		o.glow = glow
		o.glowStrength = 1.0

		p.isGlow = true
	end
	-- set tile offset
	o.setNormalTileOffset = function(tx, ty)
		o.tileX = tx / o.normalWidth
		o.tileY = ty / o.normalHeight
		o.normalVert = {
			{0.0, 0.0, o.tileX, o.tileY},
			{o.normalWidth, 0.0, o.tileX + 1.0, o.tileY},
			{o.normalWidth, o.normalHeight, o.tileX + 1.0, o.tileY + 1.0},
			{0.0, o.normalHeight, o.tileX, o.tileY + 1.0}
		}
		p.changed = true
	end
	-- get type
	o.getType = function()
		return o.type
	end
	-- get type
	o.getShadowType = function()
		return o.shadowType
	end
	-- get type
	o.setShadowType = function(type, ...)
		o.shadowType = type
		local args = {...}
		if o.shadowType == "circle" then
			o.radius = args[1] or 16
			o.ox = args[2] or 0
			o.oy = args[3] or 0
		elseif o.shadowType == "rectangle" then
			o.width = args[1] or 64
			o.height = args[2] or 64
			o.ox = args[3] or o.width * 0.5
			o.oy = args[4] or o.height * 0.5
			o.data = {
				o.x - o.ox,
				o.y - o.oy,
				o.x - o.ox + o.width,
				o.y - o.oy,
				o.x - o.ox + o.width,
				o.y - o.oy + o.height,
				o.x - o.ox,
				o.y - o.oy + o.height
			}
		elseif o.shadowType == "polygon" then
			o.data = args or {0, 0, 0, 0, 0, 0}
		elseif o.shadowType == "image" then
			if o.img then
				o.width = o.imgWidth
				o.height = o.imgHeight
				o.shadowVert = {
					{0.0, 0.0, 0.0, 0.0},
					{o.width, 0.0, 1.0, 0.0},
					{o.width, o.height, 1.0, 1.0},
					{0.0, o.height, 0.0, 1.0}
				}
				if not o.shadowMesh then
					o.shadowMesh = love.graphics.newMesh(o.shadowVert, o.img, "fan")
					o.shadowMesh:setVertexColors(true)
				end
			else
				o.width = 64
				o.height = 64
			end
			o.shadowX = args[1] or 0
			o.shadowY = args[2] or 0
			o.fadeStrength = args[3] or 0.0
		end
	end
	-- clear
	o.clear = function()
		for i = 1, #p.body do
			if p.body[i] == o then
				for k = i, #p.body - 1 do
					p.body[k] = p.body[k + 1]
				end
				p.body[#p.body] = nil
				break
			end
		end
		p.changed = true
	end

	return o
end

-- rectangle object
function love.light.newRectangle(p, x, y, width, height)
	return p.newBody("rectangle", x, y, width, height)
end

-- circle object
function love.light.newCircle(p, x, y, radius)
	return p.newBody("circle", x, y, radius)
end

-- poly object
function love.light.newPolygon(p, ...)
	return p.newBody("polygon", ...)
end

-- image object
function love.light.newImage(p, img, x, y, width, height, ox, oy)
	return p.newBody("image", img, x, y, width, height, ox, oy)
end

-- refraction object
function love.light.newRefraction(p, normal, x, y, width, height)
	return p.newBody("refraction", normal, x, y, width, height)
end

-- refraction object (height map)
function love.light.newRefractionHeightMap(p, heightMap, x, y, strength)
	local normal = HeightMapToNormalMap(heightMap, strength)
	return love.light.newRefraction(p, normal, x, y)
end

-- reflection object
function love.light.newReflection(p, normal, x, y, width, height)
	return p.newBody("reflection", normal, x, y, width, height)
end

-- reflection object (height map)
function love.light.newReflectionHeightMap(p, heightMap, x, y, strength)
	local normal = HeightMapToNormalMap(heightMap, strength)
	return love.light.newReflection(p, normal, x, y)
end

-- vector functions
function normalize(v)
	local len = math.sqrt(math.pow(v[1], 2) + math.pow(v[2], 2))
	local normalizedv = {v[1] / len, v[2] / len}
	return normalizedv
end

function dot(v1, v2)
	return v1[1] * v2[1] + v1[2] * v2[2]
end

function lengthSqr(v)
	return v[1] * v[1] + v[2] * v[2]
end

function length(v)
	return math.sqrt(lengthSqr(v))
end

function calculateShadows(light, body)
	local shadowGeometry = {}
	local shadowLength = 10000
	local rect1 = {}
	local rect2 = {}

	for i = 1, #body do
		if (body[i].shadowType == "rectangle" or body[i].shadowType == "polygon") and body[i].data then
			rect1.x1 = math.min(body[i].data[1], body[i].data[3], body[i].data[5], body[i].data[7])
			rect1.y1 = math.min(body[i].data[2], body[i].data[4], body[i].data[6], body[i].data[8])
			rect1.x2 = math.max(body[i].data[1], body[i].data[3], body[i].data[5], body[i].data[7])
			rect1.y2 = math.max(body[i].data[2], body[i].data[4], body[i].data[6], body[i].data[8])

			rect2.x1 = light.x - light.range
			rect2.y1 = light.y - light.range
			rect2.x2 = light.x + light.range
			rect2.y2 = light.y + light.range

			if not(rect2.x1 > rect1.x2
			or rect2.x2 < rect1.x1
			or rect2.y1 > rect1.y2
			or rect2.y2 < rect1.y1)
			and not body[i].castsNoShadow
			then
				body[i].inView = true
			else
				body[i].inView = false
			end

			if body[i].inView then
				curPolygon = body[i].data

				local edgeFacingTo = {}

				for k = 1, #curPolygon, 2 do
					local indexOfNextVertex = (k + 2) % #curPolygon
					local normal = {-curPolygon[indexOfNextVertex+1] + curPolygon[k + 1], curPolygon[indexOfNextVertex] - curPolygon[k]}
					local lightToPoint = {curPolygon[k] - light.x, curPolygon[k + 1] - light.y}

					normal = normalize(normal)
					lightToPoint = normalize(lightToPoint)

					local dotProduct = dot(normal, lightToPoint)
					if dotProduct > 0 then table.insert(edgeFacingTo, true)
					else table.insert(edgeFacingTo, false) end
				end

				local curShadowGeometry = {}
				curShadowGeometry.id = i
				curShadowGeometry.data = {}

				for k = 1, #edgeFacingTo do
					local nextIndex = (k + 1) % #edgeFacingTo
					if nextIndex == 0 then nextIndex = #edgeFacingTo end
					if edgeFacingTo[k] and not edgeFacingTo[nextIndex] then
						curShadowGeometry.data[1] = curPolygon[nextIndex*2-1]
						curShadowGeometry.data[2] = curPolygon[nextIndex*2]

						local lightVecFrontBack = normalize({curPolygon[nextIndex*2-1] - light.x, curPolygon[nextIndex*2] - light.y})
						curShadowGeometry.data[3] = curShadowGeometry.data[1] + lightVecFrontBack[1] * shadowLength
						curShadowGeometry.data[4] = curShadowGeometry.data[2] + lightVecFrontBack[2] * shadowLength

					elseif not edgeFacingTo[k] and edgeFacingTo[nextIndex] then
						curShadowGeometry.data[7] = curPolygon[nextIndex*2-1]
						curShadowGeometry.data[8] = curPolygon[nextIndex*2]

						local lightVecBackFront = normalize({curPolygon[nextIndex*2-1] - light.x, curPolygon[nextIndex*2] - light.y})
						curShadowGeometry.data[5] = curShadowGeometry.data[7] + lightVecBackFront[1] * shadowLength
						curShadowGeometry.data[6] = curShadowGeometry.data[8] + lightVecBackFront[2] * shadowLength
					end
				end

				if curShadowGeometry.data[1]
				and curShadowGeometry.data[2]
				and curShadowGeometry.data[3]
				and curShadowGeometry.data[4]
				and curShadowGeometry.data[5]
				and curShadowGeometry.data[6]
				and curShadowGeometry.data[7]
				and curShadowGeometry.data[8]
				then
					curShadowGeometry.alpha = body[i].alpha
					curShadowGeometry.red = body[i].red
					curShadowGeometry.green = body[i].green
					curShadowGeometry.blue = body[i].blue
					shadowGeometry[#shadowGeometry + 1] = curShadowGeometry
				end
			end
		elseif body[i].shadowType == "circle" then
			if not body[i].castsNoShadow then
				local length = math.sqrt(math.pow(light.x - (body[i].x - body[i].ox), 2) + math.pow(light.y - (body[i].y - body[i].oy), 2))

				if length >= body[i].radius and length <= light.range then
					local curShadowGeometry = {}
					curShadowGeometry.id = i
					curShadowGeometry.data = {}
					local angle = math.atan2(light.x - (body[i].x - body[i].ox), (body[i].y - body[i].oy) - light.y) + math.pi / 2
					local x2 = ((body[i].x - body[i].ox) + math.sin(angle) * body[i].radius)
					local y2 = ((body[i].y - body[i].oy) - math.cos(angle) * body[i].radius)
					local x3 = ((body[i].x - body[i].ox) - math.sin(angle) * body[i].radius)
					local y3 = ((body[i].y - body[i].oy) + math.cos(angle) * body[i].radius)

					curShadowGeometry.data[1] = x2
					curShadowGeometry.data[2] = y2
					curShadowGeometry.data[3] = x3
					curShadowGeometry.data[4] = y3

					curShadowGeometry.data[5] = x3 - (light.x - x3) * shadowLength
					curShadowGeometry.data[6] = y3 - (light.y - y3) * shadowLength
					curShadowGeometry.data[7] = x2 - (light.x - x2) * shadowLength
					curShadowGeometry.data[8] = y2 - (light.y - y2) * shadowLength
					curShadowGeometry.alpha = body[i].alpha
					curShadowGeometry.red = body[i].red
					curShadowGeometry.green = body[i].green
					curShadowGeometry.blue = body[i].blue
					shadowGeometry[#shadowGeometry + 1] = curShadowGeometry
				end
			end
		end
	end

	return shadowGeometry
end

shadowStencil = function()
	local id = 0

	for i = 1,#LOVE_LIGHT_SHADOW_GEOMETRY do
		if LOVE_LIGHT_SHADOW_GEOMETRY[i].alpha == 1.0 then
			love.graphics.polygon("fill", unpack(LOVE_LIGHT_SHADOW_GEOMETRY[i].data))
			id = LOVE_LIGHT_SHADOW_GEOMETRY[i].id

			if LOVE_LIGHT_BODY[id].shadowType == "circle" then
				love.graphics.circle("fill", LOVE_LIGHT_BODY[id].x - LOVE_LIGHT_BODY[id].ox, LOVE_LIGHT_BODY[id].y - LOVE_LIGHT_BODY[id].oy, LOVE_LIGHT_BODY[id].radius)
			elseif LOVE_LIGHT_BODY[id].shadowType == "rectangle" then
				love.graphics.rectangle("fill", LOVE_LIGHT_BODY[id].x - LOVE_LIGHT_BODY[id].ox, LOVE_LIGHT_BODY[id].y - LOVE_LIGHT_BODY[id].oy, LOVE_LIGHT_BODY[id].width, LOVE_LIGHT_BODY[id].height)
			elseif LOVE_LIGHT_BODY[id].shadowType == "polygon" and LOVE_LIGHT_BODY[id].data and #LOVE_LIGHT_BODY[id].data > 0 then
				love.graphics.polygon("fill", unpack(LOVE_LIGHT_BODY[id].data))
			elseif LOVE_LIGHT_BODY[id].shadowType == "image" then
				--love.graphics.rectangle("fill", LOVE_LIGHT_BODY[i].x - LOVE_LIGHT_BODY[i].ox, LOVE_LIGHT_BODY[i].y - LOVE_LIGHT_BODY[i].oy, LOVE_LIGHT_BODY[i].width, LOVE_LIGHT_BODY[i].height)
			end
		end
	end
end

polyStencil = function()
	local id = 0

	for i = 1, #LOVE_LIGHT_BODY do
		id = i

		if LOVE_LIGHT_BODY[id].shine and LOVE_LIGHT_BODY[id].glowStrength == 0.0 and not LOVE_LIGHT_BODY[id].normal then
			if LOVE_LIGHT_BODY[id].shadowType == "circle" then
				love.graphics.circle("fill", LOVE_LIGHT_BODY[id].x - LOVE_LIGHT_BODY[id].ox, LOVE_LIGHT_BODY[id].y - LOVE_LIGHT_BODY[id].oy, LOVE_LIGHT_BODY[id].radius)
			elseif LOVE_LIGHT_BODY[id].shadowType == "rectangle" then
				love.graphics.rectangle("fill", LOVE_LIGHT_BODY[id].x - LOVE_LIGHT_BODY[id].ox, LOVE_LIGHT_BODY[id].y - LOVE_LIGHT_BODY[id].oy, LOVE_LIGHT_BODY[id].width, LOVE_LIGHT_BODY[id].height)
			elseif LOVE_LIGHT_BODY[id].shadowType == "polygon" and LOVE_LIGHT_BODY[id].data and #LOVE_LIGHT_BODY[id].data > 0 then
				love.graphics.polygon("fill", unpack(LOVE_LIGHT_BODY[id].data))
			end
		end
	end
end

function HeightMapToNormalMap(heightMap, strength)
	local imgData = heightMap:getData()
	local imgData2 = love.image.newImageData(heightMap:getWidth(), heightMap:getHeight())
	local red, green, blue, alpha
	local x, y
	local matrix = {}
	matrix[1] = {}
	matrix[2] = {}
	matrix[3] = {}
	strength = strength or 1.0

	for i = 0, heightMap:getHeight() - 1 do
		for k = 0, heightMap:getWidth() - 1 do
			for l = 1, 3 do
				for m = 1, 3 do
					if k + (l - 1) < 1 then
						x = heightMap:getWidth() - 1
					elseif k + (l - 1) > heightMap:getWidth() - 1 then
						x = 1
					else
						x = k + l - 1
					end

					if i + (m - 1) < 1 then
						y = heightMap:getHeight() - 1
					elseif i + (m - 1) > heightMap:getHeight() - 1 then
						y = 1
					else
						y = i + m - 1
					end

					local red, green, blue, alpha = imgData:getPixel(x, y)
					matrix[l][m] = red
				end
			end

			red = (255 + ((matrix[1][2] - matrix[2][2]) + (matrix[2][2] - matrix[3][2])) * strength) / 2.0
			green = (255 + ((matrix[2][2] - matrix[1][1]) + (matrix[2][3] - matrix[2][2])) * strength) / 2.0
			blue = 192

			imgData2:setPixel(k, i, red, green, blue)
		end
	end

	return love.graphics.newImage(imgData2)
end