local ALPHABET = {}
local INDICES = {}

-- A-Z
for index = 65, 90 do
	table.insert(ALPHABET, index)
end

-- a-z
for index = 97, 122 do
	table.insert(ALPHABET, index)
end

-- 0-9
for index = 48, 57 do
	table.insert(ALPHABET, index)
end

table.insert(ALPHABET, 43) -- +
table.insert(ALPHABET, 47) -- /

for index, character in ipairs(ALPHABET) do
	INDICES[character] = index
end

local Base64 = {}

local bit32_rshift = bit32.rshift
local bit32_lshift = bit32.lshift
local bit32_band = bit32.band

--[[**
	Encodes a string in Base64.
	@param [t:string] Input The input string to encode.
	@returns [t:string] The string encoded in Base64.
**--]]
function Base64.encode(input: string): string
	local inputLength = #input
	local output = table.create(4 * math.floor((inputLength + 2) / 3)) -- Credit to AstroCode for finding the formula.
	local length = 0

	for index = 1, inputLength, 3 do
		local c1, c2, c3 = string.byte(input, index, index + 2)

		local a = bit32_rshift(c1, 2)
		local b = bit32_lshift(bit32_band(c1, 3), 4) + bit32_rshift(c2 or 0, 4)
		local c = bit32_lshift(bit32_band(c2 or 0, 15), 2) + bit32_rshift(c3 or 0, 6)
		local d = bit32_band(c3 or 0, 63)

		output[length + 1] = ALPHABET[a + 1]
		output[length + 2] = ALPHABET[b + 1]
		output[length + 3] = c2 and ALPHABET[c + 1] or 61
		output[length + 4] = c3 and ALPHABET[d + 1] or 61
		length += 4
	end

	local preallocate = math.ceil(length / 4096)
	if preallocate == 1 then
		return string.char(table.unpack(output, 1, math.min(4096, length)))
	else
		local newOutput = table.create(preallocate)
		local newLength = 0

		for index = 1, length, 4096 do
			newLength += 1
			newOutput[newLength] = string.char(table.unpack(output, index, math.min(index + 4096 - 1, length)))
		end

		return table.concat(newOutput)
	end
end

--[[**
	Decodes a string from Base64.
	@param [t:string] Input The input string to decode.
	@returns [t:string] The newly decoded string.
**--]]
function Base64.decode(input: string): string
	local inputLength = #input
	local output = table.create(inputLength / 3 * 4)
	local length = 0

	for index = 1, inputLength, 4 do
		local c1, c2, c3, c4 = string.byte(input, index, index + 3)

		local i1 = INDICES[c1] - 1
		local i2 = INDICES[c2] - 1
		local i3 = (INDICES[c3] or 1) - 1
		local i4 = (INDICES[c4] or 1) - 1

		local a = bit32_lshift(i1, 2) + bit32_rshift(i2, 4)
		local b = bit32_lshift(bit32_band(i2, 15), 4) + bit32_rshift(i3, 2)
		local c = bit32_lshift(bit32_band(i3, 3), 6) + i4

		length += 1
		output[length] = a
		if c3 ~= 61 then
			length += 1
			output[length] = b
		end

		if c4 ~= 61 then
			length += 1
			output[length] = c
		end
	end

	local preallocate = math.ceil(length / 4096)
	if preallocate == 1 then
		return string.char(table.unpack(output, 1, math.min(4096, length)))
	else
		local newOutput = table.create(preallocate)
		local newLength = 0

		for index = 1, length, 4096 do
			newLength += 1
			newOutput[newLength] = string.char(table.unpack(output, index, math.min(index + 4096 - 1, length)))
		end

		return table.concat(newOutput)
	end
end

return Base64
