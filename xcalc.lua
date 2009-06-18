--[[
    Xcalc see version in xcalc.toc.
    author: moird
    email: dan@moird.com

]]

--Sudo General Namespaces
xcalc = {}
xcalc.events = {}


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
    ChatFrame1:AddMessage("xcalc.debug: " .. debugmsg)
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

	XCALC_CONSOLE_LAST_ANS = result

	--message(result)
	ChatFrame1:AddMessage("Xcalc Result: " .. expression .. " = " .. result, 1.0, 1.0, 0.5)
end

--Processes for binding and unbinding numberpad keys to Xcalc
function xcalc.rebind()
    if (Xcalc_Settings.Binding == 1) then
    	for key,value in pairs(XCALC_BINDINGMAP) do
    		XCALC_REMAPBINDINGS[key] = GetBindingAction(key)
    	end
        for key,value in pairs(XCALC_BINDINGMAP) do
        	SetBinding(key, value)
        end
    end
end

function xcalc.unbind()
    if (Xcalc_Settings.Binding == 1) then
        for key,value in pairs(XCALC_REMAPBINDINGS) do
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
    XCALC_RUNNINGTOTAL = ""
    XCALC_PREVIOUSKEYTYPE = "none"
    XCALC_PREVIOUSOP = ""
    xcalc.display("0")
end

--Button CE
function xcalc.ce()
    xcalc.display("0")
end

--Button Backspace
function xcalc.backspace()
    local currText = XCALC_NUMBERDISPLAY
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
    local currText = XCALC_NUMBERDISPLAY
    if (currText ~= "0") then
		if (string.find(currText, "-")) then
            currText = string.sub(currText, 2)
		else
			currText = "-" .. currText
		end
	end
    XCALC_PREVIOUSKEYTYPE = "state"
    xcalc.display(currText)
end

--Button Gold (state)
function xcalc.stategold()
    local currText = XCALC_NUMBERDISPLAY
	if (string.find(currText, "[csg]") == nil) then
		currText = currText .. "g"
	end
    XCALC_PREVIOUSKEYTYPE = "state"
    xcalc.display(currText)
end

--Button Silver (state)
function xcalc.statesilver()
    local currText = XCALC_NUMBERDISPLAY
	if (string.find(currText, "[cs]") == nil) then
		currText = currText .. "s"
	end
    XCALC_PREVIOUSKEYTYPE = "state"
    xcalc.display(currText)
end

--Button Copper (state)
function xcalc.statecopper()
    local currText = XCALC_NUMBERDISPLAY
	if (string.find(currText, "c") == nil) then
		currText = currText .. "c"
	end
    XCALC_PREVIOUSKEYTYPE = "state"
    xcalc.display(currText)
end

--Button Memory Clear
function xcalc.mc()
    XCALC_MEMORYNUMBER = "0"
    xcalc.display(XCALC_NUMBERDISPLAY, "0")
end

--Button Memory Add
function xcalc.ma()
    temp = xcalc.parse(XCALC_MEMORYNUMBER .. "+" .. XCALC_NUMBERDISPLAY)
    XCALC_MEMORYNUMBER = xcalc.xcalculate(temp)
    xcalc.display("0","1")
    xcalc.clear()
end

--Button Memory Store
function xcalc.ms()
    XCALC_MEMORYNUMBER = xcalc.parse(XCALC_NUMBERDISPLAY)
    xcalc.display("0","1")
    xcalc.clear()
end

--Button Memory Recall
function xcalc.mr()
    xcalc.display(XCALC_MEMORYNUMBER)
end

--Sets up the function keys ie, + - * / =
function xcalc.funckey(key)
	local currText = XCALC_NUMBERDISPLAY
    if ( IsShiftKeyDown() and key == "=" ) then
        ChatFrame_OpenChat("")
        return
    end
	if (XCALC_PREVIOUSKEYTYPE=="none" or XCALC_PREVIOUSKEYTYPE=="num" or XCALC_PREVIOUSKEYTYPE=="state") then
			if (key == "/" or key == "*" or key == "-" or key == "-" or key == "+" or key == "^") then
					
				if (XCALC_PREVIOUSOP~="" and XCALC_PREVIOUSOP ~= "=") then
					temp = xcalc.parse(XCALC_RUNNINGTOTAL .. XCALC_PREVIOUSOP .. currText)
					currText = xcalc.xcalculate(temp)
				end
				XCALC_RUNNINGTOTAL = currText
				XCALC_PREVIOUSOP = key
			elseif (key == "=") then
				if XCALC_PREVIOUSOP ~= "=" and  XCALC_PREVIOUSOP ~= "" then
					temp = xcalc.parse(XCALC_RUNNINGTOTAL .. XCALC_PREVIOUSOP .. currText)
					currText = xcalc.xcalculate(temp)
					XCALC_RUNNINGTOTAL = currText
					XCALC_PREVIOUSOP="="
				end
			end
				
	else --must be a func key, a second+ time
		if (key == "/" or key == "*" or key == "-" or key == "-" or key == "+" or key == "^") then
			XCALC_PREVIOUSOP=key
		else
			XCALC_PREVIOUSOP=""
		end 
	end
	XCALC_PREVIOUSKEYTYPE = "func"
	xcalc.display(currText)
end

--Manage Number Inputs
function xcalc.numkey(key)
	local currText = XCALC_NUMBERDISPLAY
	
	if (XCALC_PREVIOUSKEYTYPE=="none" or XCALC_PREVIOUSKEYTYPE=="num" or XCALC_PREVIOUSKEYTYPE=="state")then
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

	XCALC_PREVIOUSKEYTYPE = "num"
    xcalc.display(currText)
end

--Send the number display to an open chatbox
function xcalc.numberdisplay_click(button, ignoreShift)
	if ( button == "LeftButton" ) then
		if ( IsShiftKeyDown() and not ignoreShift ) then
			if ( ChatFrameEditBox:IsVisible() ) then
				ChatFrameEditBox:Insert(XCALC_NUMBERDISPLAY)
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

	local newexpression = string.gsub(newexpression, "ans", XCALC_CONSOLE_LAST_ANS)

	-- g s c
	local newexpression = string.gsub(newexpression, "%d+g%d+s%d+c", function (a)
			ismoney = true
			return FromGSC(a)
		end )

	-- g s
	local newexpression = string.gsub(newexpression, "%d+g%d+s", function (a)
			ismoney = true
			return FromGSC(a)
		end )


	-- g   c
	local newexpression = string.gsub(newexpression, "%d+g%d+c", function (a)
			ismoney = true
			return FromGSC(a)
		end )

	-- g         allows #.#
	local newexpression = string.gsub(newexpression, "%d+%.?%d*g", function (a)
			ismoney = true
			return FromGSC(a)
		end )

	--   s c
	local newexpression = string.gsub(newexpression, "%d+s%d+c", function (a)
			ismoney = true
			return FromGSC(a)
		end )

	--   s       allows #.#
	local newexpression = string.gsub(newexpression, "%d+%.?%d*s", function (a)
			ismoney = true
			return FromGSC(a)
		end )

	--     c
	local newexpression = string.gsub(newexpression, "%d+c", function (a)
			ismoney = true
			return FromGSC(a)
		end )


	if (ismoney) then
		newexpression = "ToGSC(" .. newexpression .. ")"
	end

	return newexpression
end

--The following two functions do the to and from gold calculations
function ToGSC(decimal, std)
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

function FromGSC(gold, silver, copper)
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