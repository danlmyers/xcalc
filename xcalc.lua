--[[
	Xcalc see version in xcalc.toc.
	author: moird
	email: dan@moird.com
	web: http://moird.com
]]

local NAME, xcalc = ...

-- Sudo General Namespaces and globals
xcalc.events = {}
Xcalc_Settings = {}
xcalc.BindingMap = {}

xcalc.NumberDisplay = "0"
xcalc.RunningTotal = ""
xcalc.PreviousKeyType = "none"
xcalc.PreviousOP = ""

xcalc.ConsoleLastAns = "0"
xcalc.MemoryIndicator = ""
xcalc.MemoryIndicatorON = "M"
xcalc.MemoryNumber = "0"
xcalc.MemorySet = "0"

if (IsMacClient()) then
	xcalc.BindingMap.NUMLOCK_MAC = "XC_NUMLOCK"
	xcalc.BindingMap.BACKSPACE_MAC = "XC_BACKSPACE"
	xcalc.BindingMap.ENTER_MAC = "XC_EQ"
else
	xcalc.BindingMap.NUMLOCK = "XC_NUMLOCK"
	xcalc.BindingMap.BACKSPACE = "XC_BACKSPACE"
	xcalc.BindingMap.ENTER = "XC_EQ"
end
xcalc.BindingMap.HOME = "XC_CLEAR"
xcalc.BindingMap.NUMPADDIVIDE = "XC_DIV"
xcalc.BindingMap.NUMPADMULTIPLY = "XC_MUL"
xcalc.BindingMap.NUMPADMINUS = "XC_SUB"
xcalc.BindingMap.NUMPADPLUS = "XC_ADD"
xcalc.BindingMap.NUMPAD0 = "XC_0"
xcalc.BindingMap.NUMPAD1 = "XC_1"
xcalc.BindingMap.NUMPAD2 = "XC_2"
xcalc.BindingMap.NUMPAD3 = "XC_3"
xcalc.BindingMap.NUMPAD4 = "XC_4"
xcalc.BindingMap.NUMPAD5 = "XC_5"
xcalc.BindingMap.NUMPAD6 = "XC_6"
xcalc.BindingMap.NUMPAD7 = "XC_7"
xcalc.BindingMap.NUMPAD8 = "XC_8"
xcalc.BindingMap.NUMPAD9 = "XC_9"
xcalc.BindingMap.NUMPADDECIMAL = "XC_DEC"


-- Register to addon load event
local frame = CreateFrame("Frame")
local overrideOn

-- Main Initialization
function xcalc.events:ADDON_LOADED(arg1, ...)
	if( arg1 == NAME) then
		-- Mod Initialization
		SlashCmdList["XCALC"] = xcalc.cmdline
		SLASH_XCALC1 = "/xcalc"
		SLASH_XCALC2 = "/calc"
		SLASH_XCALC3 = "/="
		xcalc.optionvariables()
		xcalc.minimap_init()
		xcalc.VERSION = GetAddOnMetadata(NAME, "Version")
		frame:UnregisterEvent("ADDON_LOADED")
	end
end

function xcalc.events:PLAYER_REGEN_ENABLED()
	if xcalc_window and Xcalc_Settings.Binding and Xcalc_Settings.Binding == 1 then
		if xcalc_window:IsShown() and not overrideOn then
			xcalc.rebind()
		elseif not xcalc_window:IsShown() and overrideOn then
			xcalc.unbind()
		end
	end
end

function xcalc.events:PLAYER_REGEN_DISABLED()
	if Xcalc_Settings.Binding and Xcalc_Settings.Binding == 1 and overrideOn then 
		xcalc.unbind() -- unconditionally remove our overrides on combat, we don' want to be hogging keys when someone's jumped.
	end
end

frame:SetScript("OnEvent", function(self, event, ...) xcalc.events[event](self, ...) end)
for k, v in pairs(xcalc.events) do
	frame:RegisterEvent(k)
end


-- Fuction for setting up Saved Variables
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
	Function for adding Debug messages via xcalc.debug(object) call
	-------------------------------------------------------------------- ]]
function xcalc.debug(object)
	UIParentLoadAddOn("Blizzard_DebugTools")
	_G['xcalcinfostruct'] = object
	DevTools_DumpCommand('xcalcinfostruct')
	_G['xcalcinfostruct'] = nil
end

function xcalc.tochat(...)
	local expression,result = ...
	if (DEFAULT_CHAT_FRAME) then
		if (expression and result) then
			DEFAULT_CHAT_FRAME:AddMessage(("XCalc: %s = %s"):format(expression,result),1.0, 1.0, 0.5)
			if not DEFAULT_CHAT_FRAME:IsVisible() then FCF_SelectDockFrame(DEFAULT_CHAT_FRAME) end
		end
	else
		print(tostringall(...))
	end
end

-- Function for handling the chat slash commands
function xcalc.cmdline(msg)
	-- this function handles our chat command
	if (msg == nil or msg == "") then
		xcalc.windowdisplay()
		return nil
	end

	local expression = msg

	local newexpression = xcalc.parse(expression)

	local result = xcalc.xcalculate(newexpression)

	if ( result == nil ) then
		result = 'nil'
	end

	xcalc.ConsoleLastAns = result

	-- message(result)
	xcalc.tochat(expression,result)
end

-- Processes for binding and unbinding numberpad keys to Xcalc
function xcalc.rebind()
	if (Xcalc_Settings.Binding == 1) and not InCombatLockdown() then
		
		for key,value in pairs(xcalc.BindingMap) do
			SetOverrideBinding(frame,false,key,value)
		end
		overrideOn = true
	end
end

function xcalc.unbind()
	if (Xcalc_Settings.Binding == 1) and not InCombatLockdown() then
		ClearOverrideBindings(frame)
		overrideOn = nil
	end
end

-- Handle Key Inputs
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

-- Button Clear
function xcalc.clear()
	xcalc.RunningTotal = ""
	xcalc.PreviousKeyType = "none"
	xcalc.PreviousOP = ""
	xcalc.display("0")
end

-- Button CE
function xcalc.ce()
	xcalc.display("0")
end

-- Button Backspace
function xcalc.backspace()
	local currText = xcalc.NumberDisplay
	if (currText == "0") then
		return
	else
		local length = string.len(currText)-1
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

-- Button Plus Minus Key
function xcalc.plusminus()
	local currText = xcalc.NumberDisplay
	if (currText ~= "0") then
		if (string.find(currText, "-")) then
			currText = string.sub(currText, 2)
		else
			currText = ("-%s"):format(currText)
		end
	end
	xcalc.PreviousKeyType = "state"
	xcalc.display(currText)
end

-- Button Gold (state)
function xcalc.stategold()
	local currText = xcalc.NumberDisplay
	if (string.find(currText, "[csg]") == nil) then
		currText = ("%sg"):format(currText)
	end
	xcalc.PreviousKeyType = "state"
	xcalc.display(currText)
end

-- Button Silver (state)
function xcalc.statesilver()
	local currText = xcalc.NumberDisplay
	if (string.find(currText, "[cs]") == nil) then
		currText = ("%ss"):format(currText)
	end
	xcalc.PreviousKeyType = "state"
	xcalc.display(currText)
end

-- Button Copper (state)
function xcalc.statecopper()
	local currText = xcalc.NumberDisplay
	if (string.find(currText, "c") == nil) then
		currText = ("%sc"):format(currText)
	end
	xcalc.PreviousKeyType = "state"
	xcalc.display(currText)
end

-- Button Memory Clear
function xcalc.mc()
	xcalc.MemoryNumber = "0"
	xcalc.display(xcalc.NumberDisplay, "0")
end

-- Button Memory Add
function xcalc.ma()
	local temp = xcalc.parse(("%s+%s"):format(xcalc.MemoryNumber,xcalc.NumberDisplay))
	xcalc.MemoryNumber = xcalc.xcalculate(temp)
	xcalc.display("0","1")
	xcalc.clear()
end

-- Button Memory Store
function xcalc.ms()
	xcalc.MemoryNumber = xcalc.parse(xcalc.NumberDisplay)
	xcalc.display("0","1")
	xcalc.clear()
end

-- Button Memory Recall
function xcalc.mr()
	xcalc.display(xcalc.MemoryNumber)
end

-- Sets up the function keys ie, + - * / =
function xcalc.funckey(key)
	local currText = xcalc.NumberDisplay
	if ( IsShiftKeyDown() and key == "=" ) then
		ChatFrame_OpenChat("")
		return
	end
	if (xcalc.PreviousKeyType=="none" or xcalc.PreviousKeyType=="num" or xcalc.PreviousKeyType=="state") then
			if (key == "/" or key == "*" or key == "-" or key == "-" or key == "+" or key == "^") then
					
				if (xcalc.PreviousOP~="" and xcalc.PreviousOP ~= "=") then
					local temp = xcalc.parse(("%s%s%s"):format(xcalc.RunningTotal,xcalc.PreviousOP,currText))
					currText = xcalc.xcalculate(temp)
				end
				xcalc.RunningTotal = currText
				xcalc.PreviousOP = key
			elseif (key == "=") then
				if xcalc.PreviousOP ~= "=" and	xcalc.PreviousOP ~= "" then
					local temp = xcalc.parse(("%s%s%s"):format(xcalc.RunningTotal,xcalc.PreviousOP,currText))
					currText = xcalc.xcalculate(temp)
					xcalc.RunningTotal = currText
					xcalc.PreviousOP="="
				end
			end
				
	else -- must be a func key, a second+ time
		if (key == "/" or key == "*" or key == "-" or key == "-" or key == "+" or key == "^") then
			xcalc.PreviousOP=key
		else
			xcalc.PreviousOP=""
		end 
	end
	xcalc.PreviousKeyType = "func"
	xcalc.display(currText)
end

-- Manage Number Inputs
function xcalc.numkey(key)
	local currText = xcalc.NumberDisplay
	
	if (xcalc.PreviousKeyType=="none" or xcalc.PreviousKeyType=="num" or xcalc.PreviousKeyType=="state")then
		if (key == ".") then
			if (string.find(currText, "[csg%.]") == nil) then
				currText = ("%s."):format(currText)
			end
		else
			if (currText == "0") then
				currText = ""
			end	

			currText = ("%s%s"):format(currText,key)
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

-- Send the number display to an open chatbox
function xcalc.numberdisplay_click(frame,button,down)
	if ( button == "LeftButton" ) then
		if ( IsShiftKeyDown() ) then
			local activeEdit = ChatEdit_GetActiveWindow()
			if (activeEdit) then
				activeEdit:Insert(xcalc.NumberDisplay)
			end
		end
	end
end

-- Tooltip hint for linking result to chat
function xcalc.numberdisplay_enter(frame)
	GameTooltip:SetOwner(frame,"ANCHOR_TOP")	
	GameTooltip:SetText("Shift-click inserts to an open chat")
	GameTooltip:Show()
end


--[[----------------------------------------------------------------------------------- 
	Where the Calculations occur
	On a side note, Simple is easier, getting into complex if/then/elseif/else statements
	to perform math functions may introduce unexpected results... maybe.
	----------------------------------------------------------------------------------- ]]
function xcalc.xcalculate(expression)
	local tempvar = "QCExpVal"

	_G[tempvar] = nil
	RunScript(("%s=(%s)"):format(tempvar,expression))
	local result = _G[tempvar]

	return result
end

-- This function parses the input for the money functions
function xcalc.parse(expression)
	local ismoney = false

	local newexpression = expression

	newexpression = string.gsub(newexpression, "ans", xcalc.ConsoleLastAns)

	-- g s c
	newexpression = string.gsub(newexpression, "%d+g%d+s%d+c", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )

	-- g s
	newexpression = string.gsub(newexpression, "%d+g%d+s", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )


	-- g	 c
	newexpression = string.gsub(newexpression, "%d+g%d+c", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )

	-- g		 allows #.#
	newexpression = string.gsub(newexpression, "%d+%.?%d*g", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )

	--	 s c
	newexpression = string.gsub(newexpression, "%d+s%d+c", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )

	--	 s		 allows #.#
	newexpression = string.gsub(newexpression, "%d+%.?%d*s", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )

	--	 c
	newexpression = string.gsub(newexpression, "%d+c", function (a)
			ismoney = true
			return xcalc.FromGSC(a)
		end )


	if (ismoney) then
		newexpression = ("xcalc.ToGSC(%s)"):format(newexpression)
	end

	return newexpression
end

-- The following two functions do the to and from gold calculations
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
		temp = ("%s%sg"):format(temp,gold)
	end
	if (silver > 0 or (gold > 0 and copper > 0)) then
		temp = ("%s%ss"):format(temp,silver)
	end
	if (copper > 0) then
		temp = ("%s%sc"):format(temp,copper)
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
		
		local golds,golde = string.find(temp, "%d*%.?%d*g")
		if (golds == nil) then
			gold = 0
		else
			gold = string.sub(temp, golds, golde - 1)
		end
	
		local silvers,silvere = string.find(temp, "%d*%.?%d*s")
		if (silvers == nil) then
			silver = 0
		else
			silver = string.sub(temp, silvers, silvere - 1)
		end

		local coppers,coppere = string.find(temp, "%d*c")
		if (coppers == nil) then
			copper = 0
		else
			copper = string.sub(temp, coppers, coppere - 1)
		end
	end

	total = total + copper
	total = total + (silver * 100)
	total = total + (gold * 10000)

	return ("%s"):format(total)
end

_G[NAME] = xcalc
