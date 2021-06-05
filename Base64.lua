local BUILD_STRING_CHUNK_SIZE = 4096

local function build(values)
	local chunks = {}

	for index = 1, #values, BUILD_STRING_CHUNK_SIZE do
		table.insert(chunks, string.char(
			unpack(values, index, math.min(index + BUILD_STRING_CHUNK_SIZE - 1, #values))
		))
	end

	return table.concat(chunks, "")
end

local function encode(source)
	local sourceLength = #source
	local remainingCharacters = sourceLength % 3
	
	if remainingCharacters > 0 then
		-- Pad extra 0s on the end
		source = source .. string.char(0):rep(3 - remainingCharacters)
	end
	
	-- Since chunks are only 3 characters wide and we're parsing 4 characters, we need
	-- to add an extra 0 on the end (which will be discarded anyway)
	source = source .. string.char(0)
	
	local outputLength = (sourceLength / 3) * 4
	local output = table.create(outputLength)

	for index = 0, math.floor(sourceLength / 3) - 1 do
		local inputIndex = index * 3 + 1
		local outputIndex = bit32.lshift(index, 2) + 1
		
		-- Parse this as a single 32-bit integer instead of splitting into multiple
		local chunk = bit32.rshift(string.unpack(">J", source, inputIndex), 8)
		
		local value1 = bit32.rshift(chunk, 18)
		local value2 = bit32.band(bit32.rshift(chunk, 12), 0b111111)
		local value3 = bit32.band(bit32.rshift(chunk, 6), 0b111111)
		local value4 = bit32.band(chunk, 0b111111)
		
		if value1 <= 25 then -- A-Z
			value1 += 65
		elseif value1 <= 51 then -- a-z
			value1 += 71 -- 97 - (25 + 1)
		elseif value1 <= 61 then -- 0-9
			value1 -= 4 -- 48 - (51 + 1)
		elseif value1 == 62 then -- +
			value1 = 43
		elseif value1 == 63 then -- /
			value1 = 47
		end
		
		if value2 <= 25 then -- A-Z
			value2 += 65
		elseif value2 <= 51 then -- a-z
			value2 += 71 -- 97 - (25 + 1)
		elseif value2 <= 61 then -- 0-9
			value2 -= 4 -- 48 - (51 + 1)
		elseif value2 == 62 then -- +
			value2 = 43
		elseif value2 == 63 then -- /
			value2 = 47
		end

		if value3 <= 25 then -- A-Z
			value3 += 65
		elseif value3 <= 51 then -- a-z
			value3 += 71 -- 97 - (25 + 1)
		elseif value3 <= 61 then -- 0-9
			value3 -= 4 -- 48 - (51 + 1)
		elseif value3 == 62 then -- +
			value3 = 43
		elseif value3 == 63 then -- /
			value3 = 47
		end

		if value4 <= 25 then -- A-Z
			value4 += 65
		elseif value4 <= 51 then -- a-z
			value4 += 71 -- 97 - (25 + 1)
		elseif value4 <= 61 then -- 0-9
			value4 -= 4 -- 48 - (51 + 1)
		elseif value4 == 62 then -- +
			value4 = 43
		elseif value4 == 63 then -- /
			value4 = 47
		end

		output[outputIndex] = value1
		output[outputIndex + 1] = value2
		output[outputIndex + 2] = value3
		output[outputIndex + 3] = value4
	end

	-- Ensure length is multiple of 4
	if remainingCharacters > 0 then
		for _ = 1, 3 - remainingCharacters do
			table.insert(output, 61) -- =
		end
	end

	return build(output)
end

local function decode(source)
	local sourceLength = #source
	
	local outputLength = (sourceLength / 3) * 4
	local output = table.create(outputLength)

	for index = 0, (sourceLength / 4) - 1 do
		local inputIndex = bit32.lshift(index, 2) + 1
		local outputIndex = index * 3 + 1

		local value1, value2, value3, value4 = string.byte(source, inputIndex, inputIndex + 3)
		
		if value1 >= 97 then -- a-z
			value1 -= 71 -- 97 - 26
		elseif value1 >= 65 then -- A-Z
			value1 -= 65 -- 65 - 0
		elseif value1 >= 48 then -- 0-9
			value1 += 4 -- 52 - 48
		elseif value1 == 47 then -- /
			value1 = 63
		elseif value1 == 43 then -- +
			value1 = 62
		elseif value1 == 61 then -- =
			value1 = 0
		end

		if value2 >= 97 then -- a-z
			value2 -= 71 -- 97 - 26
		elseif value2 >= 65 then -- A-Z
			value2 -= 65 -- 65 - 0
		elseif value2 >= 48 then -- 0-9
			value2 += 4 -- 52 - 48
		elseif value2 == 47 then -- /
			value2 = 63
		elseif value2 == 43 then -- +
			value2 = 62
		elseif value2 == 61 then -- =
			value1 = 0
		end

		if value3 >= 97 then -- a-z
			value3 -= 71 -- 97 - 26
		elseif value3 >= 65 then -- A-Z
			value3 -= 65 -- 65 - 0
		elseif value3 >= 48 then -- 0-9
			value3 += 4 -- 52 - 48
		elseif value3 == 47 then -- /
			value3 = 63
		elseif value3 == 43 then -- +
			value3 = 62
		elseif value3 == 61 then -- =
			value1 = 0
		end

		if value4 >= 97 then -- a-z
			value4 -= 71 -- 97 - 26
		elseif value4 >= 65 then -- A-Z
			value4 -= 65 -- 65 - 0
		elseif value4 >= 48 then -- 0-9
			value4 += 4 -- 52 - 48
		elseif value4 == 47 then -- /
			value4 = 63
		elseif value4 == 43 then -- +
			value4 = 62
		elseif value4 == 61 then -- =
			value1 = 0
		end

		-- Combine all variables into one 24-bit variable to be split up
		local compound = bit32.bor(
			bit32.lshift(value1, 18),
			bit32.lshift(value2, 12),
			bit32.lshift(value3, 6),
			value4
		)

		output[outputIndex] = bit32.rshift(compound, 16)
		output[outputIndex + 1] = bit32.band(bit32.rshift(compound, 8), 0b11111111)
		output[outputIndex + 2] = bit32.band(compound, 0b11111111)
	end

	-- If the last couple of characters were padding, remove them from the output
	if string.byte(source, sourceLength) == 61 then
		output[outputLength] = nil
	end
	if string.byte(source, sourceLength - 1) == 61 then
		output[outputLength - 1] = nil
	end

	return build(output)
end

return {
	encode = encode,
	decode = decode,
}