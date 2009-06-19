--[[
    Xcalc see version in xcalc.toc.
    author: moird
    email: dan@moird.com

]]

--Sudo General Namespaces and globals
xcalc = {}
xcalc.events = {}
Xcalc_Settings = { }
xcalc.RemapBindings = { }

xcalc.NumberDisplay = "0"
xcalc.RunningTotal = ""
xcalc.PreviousKeyType = "none"
xcalc.PreviousOP = ""

xcalc.ConsoleLastAns = "0"
xcalc.MemoryIndicator = ""
xcalc.MemoryIndicatorON = "M"
xcalc.MemoryNumber = "0"
xcalc.MemorySet = "0"

xcalc.BindingMap = {
    NUMLOCK = "XC_NUMLOCK",
    HOME = "XC_CLEAR",
    BACKSPACE = "XC_BACKSPACE",
    NUMPADDIVIDE = "XC_DIV",
    NUMPADMULTIPLY = "XC_MUL",
    NUMPADMINUS = "XC_SUB",
    NUMPADPLUS = "XC_ADD",
    ENTER = "XC_EQ",
    NUMPAD0 = "XC_0",
    NUMPAD1 = "XC_1",
    NUMPAD2 = "XC_2",
    NUMPAD3 = "XC_3",
    NUMPAD4 = "XC_4",
    NUMPAD5 = "XC_5",
    NUMPAD6 = "XC_6",
    NUMPAD7 = "XC_7",
    NUMPAD8 = "XC_8",
    NUMPAD9 = "XC_9",
    NUMPADDECIMAL = "XC_DEC"
    }


--Register to addon load event
local frame = CreateFrame("Frame")

--Main Initialization
function xcalc.events:ADDON_LOADED(...)
	if( arg1 == "xcalc") then
		--Mod Initialization
		SlashCmdList["XCALC"] = xcalc.cmdline
		SLASH_XCALC1 = "/xcalc"
		SLASH_XCALC2 = "/calc"
		SLASH_XCALC3 = "/="
	    xcalc.optionvariables()
	    xcalc.minimap_init()
	    XCALC_VERSION = GetAddOnMetadata("xcalc", "Version")
	end
end

frame:SetScript("OnEvent", function(self, event, ...) xcalc.events[event](self, ...) end)
for k, v in pairs(xcalc.events) do
	frame:RegisterEvent(k)
end


--Fuction for setting up Saved Variables
function xcalc.optionvariables()
    if (Xcalc_Settings.Binding == nil) then
        Xcalc_Settings.Binding = 1
    end
    if (Xcalc_Settings.Minimapdisplay == nil) then
        Xcalc_Settings.Minimapdisplay = 1
    end
    if (Xcalc_Settings.Minimappos == nil) then
        Xcalc_Settings.Minimappos = 295
    end
end

--[[--------------------------------------------------------------------
    Function for adding Debug messages via xcalc.debug("message") call
    
    --------------------------------------------------------------------]]
function xcalc.debug(debugmsg)
    ChatFrame1:AddMessage("xcalc_debug: " .. debugmsg)
end

--Function for handling the chat slash commands
function xcalc.cmdline(msg)
	-- this function handles our chat command
	if (msg == nil or msg == "") then
		xcalc.windowdisplay()
		return nil
	end

	local expression = msg

	newexpression = xcalc.parse(expression)

	local result = xcalc.xcalculate(newexpression)

	if ( result == nil ) then
		result = 'nil'
	end

	xcalc.ConsoleLastAns = result

	--message(result)
	ChatFrame1:AddMessage("Xcalc Result: " .. expression .. " = " .. result, 1.0, 1.0, 0.5)
end

--Processes for binding and unbinding numberpad keys to Xcalc
function xcalc.rebind()
    if (Xcalc_Settings.Binding == 1) then
    	for key,value in pairs(xcalc.BindingMap) do
    		xcalc.RemapBindings[key] = GetBindingAction(key)
    	end
        for key,value in pairs(xcalc.BindingMap) do
        	SetBinding(key, value)
        end
    end
end

function xcalc.unbind()
    if (Xcalc_Settings.Binding == 1) then
        for key,value in pairs(xcalc.RemapBindings) do
        	SetBinding(key, value)
        end
    end
end

--Handle Key Inputs
function xcalc.buttoninput(key)
	if ( key == "CL" ) then
		xcalc.clear()
	elseif ( key == "CE") then
		xcalc.ce()
	elseif ( key == "PM" ) then
		xcalc.plusminus()
	elseif ( key == "GOLD" ) then
		xcalc.stategold()
	elseif ( key == "SILVER" ) then
		xcalc.statesilver()
	elseif ( key == "COPPER" ) then
		xcalc.statecopper()
	elseif ( key == "MC" ) then
		xcalc.mc()
	elseif ( key == "MA" ) then
		xcalc.ma()
	elseif ( key == "MS" ) then
		xcalc.ms()
	elseif ( key == "MR" ) then
		xcalc.mr()
	elseif ( key == "BS" ) then
		xcalc.backspace()
	elseif (key == "=" or key == "/" or key == "*" or key == "-" or key == "-" or key == "+" or key == "^") then
		xcalc.funckey(key)
	else
		xcalc.numkey(key)
	end
end

--Button Clear
function xcalc.clear()
    xcalc.RunningTotal = ""
    xcalc.PreviousKeyType = "none"
    xcalc.PreviousOP = ""
    xcalc.display("0")
end

--Button CE
function xcalc.ce()
    xcalc.display("0")
end

--Button Backspace
function xcalc.backspace()
    local currText = xcalc.NumberDisplay
    if (currText == "0") then
        return
    else
        length = string.len(currText)-1
        if (length < 0) then
            length = 0
        end
        currText = string.sub(currText,0,length)
        if (string.len(currText) < 1) then
            xcalc.display("0")
        else
            xcalc.display(currText)
        end
    end
end

--Button Plus Minus Key
function xcalc.plusminus()
    local currText = xcalc.NumberDisplay
    if (currText ~= "0") then
		if (string.find(currText, "-")) then
            currText = string.sub(currText, 2)
		else
			currText = "-" .. currText
		end
	end
    xcalc.PreviousKeyType = "state"
    xcalc.display(currText)
end

--Button Gold (state)
function xcalc.stategold()
    local currText = xcalc.NumberDisplay
	if (string.find(currText, "[csg]") == nil) then
		currText = currText .. "g"
	end
    xcalc.PreviousKeyType = "state"
    xcalc.display(currText)
end

--Button Silver (state)
function xcalc.statesilver()
    local currText = xcalc.NumberDisplay
	if (string.find(currText, "[cs]") == nil) then
		currText = currText .. "s"
	end
    xcalc.PreviousKeyType = "state"
    xcalc.display(currText)
end

--Button Copper (state)
function xcalc.statecopper()
    local currText = xcalc.NumberDisplay
	if (string.find(currText, "c") == nil) then
		currText = currText .. "c"
	end
    xcalc.PreviousKeyType = "state"
    xcalc.display(currText)
end

--Button Memory Clear
function xcalc.mc()
    xcalc.MemoryNumber = "0"
    xcalc.display(xcalc.NumberDisplay, "0")
end

--Button Memory Add
function xcalc.ma()
    temp = xcalc.parse(xcalc.MemoryNumber .. "+" .. xcalc.NumberDisplay)
    xcalc.MemoryNumber = xcalc.xcalculate(temp)
    xcalc.display("0","1")
    xcalc.clear()
end

--Button Memory Store
function xcalc.ms()
    xcalc.MemoryNumber = xcalc.parse(xcalc.NumberDisplay)
    xcalc.display("0","1")
    xcalc.clear()
end

--Button Memory Recall
function xcalc.mr()
    xcalc.display(xcalc.MemoryNumber)
end

--Sets up the function keys ie, + - * / =
function xcalc.funckey(key)
	local currText = xcalc.NumberDisplay
    if ( IsShiftKeyDown() and key == "=" ) then
        ChatFrame_OpenChat("")
        return
    end
	if (xcalc.PreviousKeyType=="none" or xcalc.PreviousKeyType=="num" or xcalc.PreviousKeyType=="state") then
			if (key == "/" or key == "*" or key == "-" or key == "-" or key == "+" or key == "^") then
					
				if (xcalc.PreviousOP~="" and xcalc.PreviousOP ~= "=") then
					temp = xcalc.parse(xcalc.RunningTotal .. xcalc.PreviousOP .. currText)
					currText = xcalc.xcalculate(temp)
				end
				xcalc.RunningTotal = currText
				xcalc.PreviousOP = key
			elseif (key == "=") then
				if xcalc.PreviousOP ~= "=" and  xcalc.PreviousOP ~= "" then
					temp = xcalc.parse(xcalc.RunningTotal .. xcalc.PreviousOP .. currText)
					currText = xcalc.xcalculate(temp)
					xcalc.RunningTotal = currText
					xcalc.PreviousOP="="
				end
			end
				
	else --must be a func key, a second+ time
		if (key == "/" or key == "*" or key == "-" or key == "-" or key == "+" or key == "^") then
			xcalc.PreviousOP=key
		else
			xcalc.PreviousOP=""
		end 
	end
	xcalc.PreviousKeyType = "func"
	xcalc.display(currText)
end

--Manage Number Inputs
function xcalc.numkey(key)
	local currText = xcalc.NumberDisplay
	
	if (xcalc.PreviousKeyType=="none" or xcalc.PreviousKeyType=="num" or xcalc.PreviousKeyType=="state")then
		if (key == ".") then
			if (string.find(currText, "[csg%.]") == nil) then
				currText = currText .. "."
			end
		else
			if (currText == "0") then
				currText = ""
			end	

			currText = currText .. key
		end
	else
		if (key == ".") then
			currText = "0."
		else
			currText = key
		end
	end

	xcalc.PreviousKeyType = "num"
    xcalc.display(currText)
end

--Send the number display to an open chatbox
function xcalc.numberdisplay_click(button, ignoreShift)
	if ( button == "LeftButton" ) then
		if ( IsShiftKeyDown() and not ignoreShift ) then
			if ( ChatFrameEditBox:IsVisible() ) then
				ChatFrameEditBox:Insert(xcalc.NumberDisplay)
			end
		end
	end
end


--[[-----------------------------------------------------------------------------------
    Where the Calculations occur
    On a side note, Simple is easier, getting into complex if/then/elseif/else statements
    to perform math functions may introduce unexpected results... maybe.
    -----------------------------------------------------------------------------------]]
function xcalc.xcalculate(expression)
	local tempvar = "QCExpVal"

	setglobal(tempvar, nil)
	RunScript(tempvar .. "=(" .. expression .. ")")
	local result = getglobal(tempvar)

	return result
end

--This function parses the input for the money functions
function xcalc.parse(expression)
	local ismoney = false

	newexpression = expression

	local newexpression = string.gsub(newexpression, "ans", xcalc.ConsoleLastAns)

	-- g s c
	local newexpression = string.gsub(newexpression, "%d+g%d+s%d+c", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )

	-- g s
	local newexpression = string.gsub(newexpression, "%d+g%d+s", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )


	-- g   c
	local newexpression = string.gsub(newexpression, "%d+g%d+c", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )

	-- g         allows #.#
	local newexpression = string.gsub(newexpression, "%d+%.?%d*g", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )

	--   s c
	local newexpression = string.gsub(newexpression, "%d+s%d+c", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )

	--   s       allows #.#
	local newexpression = string.gsub(newexpression, "%d+%.?%d*s", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )

	--     c
	local newexpression = string.gsub(newexpression, "%d+c", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )


	if (ismoney) then
		newexpression = "xcalc.ToGSC(" .. newexpression .. ")"
	end

	return newexpression
end

--The following two functions do the to and from gold calculations
function xcalc.ToGSC(decimal, std)
	local gold = 0
	local silver = 0
	local copper = 0

	if (std == "gold") then
		copper = math.fmod(decimal, .01)
		decimal = decimal - copper
		copper = copper * 10000

		silver = math.fmod(decimal, 1)
		decimal = decimal - silver
		silver = silver * 100

		gold = decimal
	elseif (std == "silver") then
		copper = math.fmod(decimal, 1)
		decimal = decimal - copper
		copper = copper * 100

		silver = math.fmod(decimal, 100)
		decimal = decimal - silver

		gold = decimal / 100
	else
		copper = math.fmod(decimal, 100)
		decimal = decimal - copper

		silver = math.fmod(decimal, 10000)
		decimal = decimal - silver
		silver = silver / 100

		gold = decimal / 10000
	end

	local temp = ""

	if (gold > 0) then
		temp = temp .. gold .. "g"
	end
	if (silver > 0 or (gold > 0 and copper > 0)) then
		temp = temp .. silver .. "s"
	end
	if (copper > 0) then
		temp = temp .. copper .. "c"
	end

	return temp
end

function xcalc.FromGSC(gold, silver, copper)
	if (gold == nil) then
		return ""
	end

	local total = 0

	if (type(gold) == "string" and (not silver or type(silver) == "nil") and (not copper or type(copper) == "nil")) then
		local temp = gold
		
		golds,golde = string.find(temp, "%d*%.?%d*g")
		if (golds == nil) then
			gold = 0
		else
			gold = string.sub(temp, golds, golde - 1)
		end
	
		silvers,silvere = string.find(temp, "%d*%.?%d*s")
		if (silvers == nil) then
			silver = 0
		else
			silver = string.sub(temp, silvers, silvere - 1)
		end

		coppers,coppere = string.find(temp, "%d*c")
		if (coppers == nil) then
			copper = 0
		else
			copper = string.sub(temp, coppers, coppere - 1)
		end
	end

	total = total + copper
	total = total + (silver * 100)
	total = total + (gold * 10000)

	return "" .. total
end