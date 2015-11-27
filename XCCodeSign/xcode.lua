-- make xcode work on my iPhone
--[[
filename = arg[1]
mycodesign = "iPhone Developer: jie zhao (BF2E4X5CV7)"

if not string.find(filename, "project.pbxproj$") then
	print("Usage: "..arg[0].." project.pbxproj")
	os.exit(1)
end
--]]

count = 0
function quite_replace(str, rep, noqout)
	count = count + 1
	local e = string.find(str, "=[^=]*$") -- find last =
	if noqout then
		return string.sub(str, 1, e)..string.format(" %s;", rep)
	end
	return string.sub(str, 1, e)..string.format(" \"%s\";", rep)
end

function stack_value(str)
	if string.find(str, "{$") then
		return 1
	end
	if string.find(str, "};$") then
		return -1
	end
	return 0
end

debug_stack = 0
pbxlines = {}
fho,err = io.open(filename,"r")
if fho == nil then
	print(err)
	os.exit(2)
end

line = fho:read()
while line ~= nil do
	pbxlines[#pbxlines+1] = line
	if debug_stack > 0 or string.find(line, "/* Debug */", 1, true) then
::search::
		if string.find(line, "DEBUG_INFORMATION_FORMAT") then
			pbxlines[#pbxlines] = quite_replace(line, "dwarf", true)
		elseif string.find(line, "ONLY_ACTIVE_ARCH") then
			pbxlines[#pbxlines] = quite_replace(line, "YES", true)
		elseif string.find(line, "CODE_SIGN_IDENTITY ") then
			pbxlines[#pbxlines] = quite_replace(line, "iPhone Developer")
			-- check next line, incase not exist
			line = fho:read()
			if not string.find(line, "CODE_SIGN_IDENTITY[sdk=", 1, true) then
				pbxlines[#pbxlines+1] = [["CODE_SIGN_IDENTITY[sdk=iphoneos*]" = ]]..mycodesign..";"
				pbxlines[#pbxlines+1] = line
			else
				goto search
			end
		elseif string.find(line, "CODE_SIGN_IDENTITY[sdk=iphoneos*]", 1, true) or
		   string.find(line, "CODE_SIGN_IDENTITY[sdk=watchos*]", 1, true) then
			pbxlines[#pbxlines] = quite_replace(line, mycodesign)
			codesign_exec = true
		elseif string.find(line, "PROVISIONING_PROFILE") then
			pbxlines[#pbxlines] = quite_replace(line, "")
		end
		-- 
		debug_stack = debug_stack + stack_value(line)
		-- print(pbxlines[#pbxlines])
	end
	line = fho:read()
end
fho:close()

--[-[
-- line by line
fho = io.open(filename,"w")
for _, line in ipairs(pbxlines) do
    fho:write(line)
    fho:write("\n")
end
fho:close()
--]]
print(string.format("replace %s %d line", filename, count))
