local FormatNumber = {}

local SUFFIXES = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}

function FormatNumber.FormatCompact(number: number): string
	if not number then return "0" end
	if number < 0 then
		return "-" .. FormatNumber.FormatCompact(-number)
	end
	if number < 1000 then
		return tostring(math.floor(number))
	end
	
	local index = math.floor(math.log10(number) / 3)
	if index > #SUFFIXES then
		index = #SUFFIXES
	end
	
	local scale = 10 ^ (index * 3)
	local shortVal = number / scale
	
	-- Format with up to 2 decimal places, removing trailing zeros
	local formatted = string.format("%.2f", shortVal)
	formatted = formatted:gsub("%.?0+$", "") -- Clean up decimals like 1.00 -> 1 or 1.50 -> 1.5
	
	return formatted .. SUFFIXES[index + 1]
end

function FormatNumber.FormatWithCommas(number: number): string
	if not number then return "0" end
	local formatted = tostring(math.floor(number))
	while true do  
		local k
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

return FormatNumber
