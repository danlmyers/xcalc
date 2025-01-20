--[[
	Xcalc see version in xcalc.toc.
	author: moird
]]

xcalc = LibStub("AceAddon-3.0"):NewAddon("xcalc", "AceConsole-3.0", "AceEvent-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
XcalcMinimapButton = LibStub("LibDBIcon-1.0", true)

local defaults = {
	profile = {
		minimap = {
			hide = false,
		},
		binding = true,
		historymax = 30,
		history = {},
	},
}

local options = {
	name = "xcalc",
	handler = xcalc,
	type = "group",
	args = {
		binding = {
			type = "toggle",
			name = "AutoBinding",
			desc = "Use Automatic Bindings",
			get = "IsAutoBinding",
			set = "ToggleAutoBinding",
		},
		history = {
			type = "range",
			name = "Calculation History",
			desc = "Number of calculations to keep in history",
			get = "GetHistoryMax",
			set = "SetHistoryMax",
			min = 1,
			max = 100,
			step = 1,
		}
	},
}

local frame = CreateFrame("Frame")
local overrideOn = false

-- Sudo General Namespaces and globals
xcalc.events = {}
xcalc.BindingMap = {}

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


local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("xcalc", {
	type = "data source",
	text = "xcalc",
	icon = "Interface\\AddOns\\xcalc\\xcalc_ButtonRoundNormal.tga",
	OnClick = function(self, btn)
		if btn == "LeftButton" then
			xcalc.WindowFrame()
		elseif btn == "RightButton" then
			xcalc.optiondisplay()
		end
	end,

	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then
			return
		end

		tooltip:AddLine("xcalc\n\nLeft-click: Open xcalc\nRight-click: Open xcalc Settings", nil, nil, nil, nil)
	end,
})

function xcalc:IsAutoBinding(info)
	return self.db.profile.binding
end

function xcalc:ToggleAutoBinding(info, value)
	if not value then
		xcalc.unbind()
	end
	self.db.profile.binding = value
end

function xcalc:GetHistoryMax(info)
	return self.db.profile.historymax
end

function xcalc:SetHistoryMax(info, value)
	self.db.profile.historymax = value
end

function xcalc:GetHistory()
	return self.db.profile.history
end

function xcalc:GetHistoryConsole()
	local historystring = ""
	for i=1, #self.db.profile.history do
		if self.db.profile.history[#self.db.profile.history +1 -i] then
			historystring = historystring .. "\n" .. self.db.profile.history[#self.db.profile.history +1 - i]
		else
			historystring = ""
		end

	end
	return historystring
end

function xcalc:SetHistory(line)
	if line then
		table.insert(self.db.profile.history, 1, line)
	end

	if #self.db.profile.history >= self.db.profile.historymax then
		for i=1, #self.db.profile.history - self.db.profile.historymax do
			self.db.profile.history[#self.db.profile.history +1 - i] = nil
		end
	end
end

function xcalc:SlashCommand(msg)
	if not msg or msg:trim() == "" then
		self:WindowFrame()
	elseif msg == "history" then
		self:Print(xcalc:GetHistoryConsole())
	else
		local result = xcalc.xcalculate(xcalc.parse(msg))
		if result then
			self:SetHistory(msg .. " = " .. result)
		else
			result = 'nil'
		end
		self:Print(msg .. " = " .. result)
	end
end

function xcalc:PLAYER_REGEN_ENABLED()
	if xcalc.MainFrame and xcalc:IsAutoBinding() then
		if xcalc.MainFrame:IsShown() and not overrideOn then
			xcalc.rebind()
		elseif not xcalc.MainFrame:IsShown() and overrideOn then
			xcalc.unbind()
		end
	end
end
xcalc:RegisterEvent("PLAYER_REGEN_ENABLED")

function xcalc:PLAYER_REGEN_DISABLED()
	if xcalc:IsAutoBinding() and overrideOn then
		xcalc.unbind() -- unconditionally remove our overrides on combat, we don' want to be hogging keys when someone's jumped.
	end
end
xcalc:RegisterEvent("PLAYER_REGEN_DISABLED")

-- Processes for binding and unbinding numberpad keys to Xcalc
function xcalc.rebind()
	if xcalc:IsAutoBinding() and not InCombatLockdown() then

		for key,value in pairs(xcalc.BindingMap) do
			SetOverrideBinding(frame,false,key,value)
		end
		overrideOn = true
	end
end

function xcalc.unbind()
	if xcalc:IsAutoBinding() and not InCombatLockdown() then
		ClearOverrideBindings(frame)
		overrideOn = false
	end
end

-- Button Backspace
function xcalc.backspace()
	local currText = xcalc.editbox:GetText()
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
	local currText = xcalc.editbox:GetText()
	if (currText ~= "0") then
		if (string.find(currText, "-")) then
			currText = string.sub(currText, 2)
		else
			currText = ("-%s"):format(currText)
		end
	end
	xcalc.display(currText)
end

-- Button Gold (state)
function xcalc.stategold()
	local currText = xcalc.editbox:GetText()
	if not string.find(currText, "[csg]") then
		currText = ("%sg"):format(currText)
	end
	xcalc.display(currText)
end

-- Button Silver (state)
function xcalc.statesilver()
	local currText = xcalc.editbox:GetText()
	if not string.find(currText, "[cs]") then
		currText = ("%ss"):format(currText)
	end
	xcalc.display(currText)
end

-- Button Copper (state)
function xcalc.statecopper()
	local currText = xcalc.editbox:GetText()
	if not string.find(currText, "c") then
		currText = ("%sc"):format(currText)
	end
	xcalc.display(currText)
end

function xcalc:equalsbutton()
	local problem = xcalc.editbox:GetText()
	local result = xcalc.xcalculate(xcalc.parse(problem))
	if result then
		self:SetHistory(problem .. " = " .. result)
		xcalc.displayhistory()
		xcalc.display(result)
	end
end

function xcalc:UpdateEditBox(numkey)
	local currentText = xcalc.editbox:GetText()
	xcalc.display(currentText .. numkey)
end


--[[----------------------------------------------------------------------------------- 
	Yup it is a total cheap and perfect way to run calculations by leveraging the LUA
	interpreter for doing the actual math.
	----------------------------------------------------------------------------------- ]]
function xcalc.xcalculate(expression)
	local tempvar = "QCExpVal"

	_G[tempvar] = nil
	RunScript(("%s=(%s)"):format(tempvar,expression))
	local result = _G[tempvar]

	return result
end

-- Parse the expression for gold or other math functions like sqrt
function xcalc.parse(expression)
	local ismoney = false

	local newexpression = expression

	newexpression = string.gsub(newexpression, "%%", "*.01")
	newexpression = string.gsub(newexpression, "√%d+%.?%d*", function(a)
		return "math.sqrt(" .. string.sub(a,4) .. ")"
	end)

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
	if not gold then
		return ""
	end

	local total = 0

	if (type(gold) == "string" and (not silver or type(silver) == "nil") and (not copper or type(copper) == "nil")) then
		local temp = gold
		
		local golds,golde = string.find(temp, "%d*%.?%d*g")
		if not golds then
			gold = 0
		else
			gold = string.sub(temp, golds, golde - 1)
		end
	
		local silvers,silvere = string.find(temp, "%d*%.?%d*s")
		if not silvers then
			silver = 0
		else
			silver = string.sub(temp, silvers, silvere - 1)
		end

		local coppers,coppere = string.find(temp, "%d*c")
		if not coppers then
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

function xcalc:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("xcalcDB", defaults, true)
	AC:RegisterOptionsTable("xcalc_options", options)
	self.optionsFrame = ACD:AddToBlizOptions("xcalc_options", "xcalc")

	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable("xcalc_Profiles", profiles)
	ACD:AddToBlizOptions("xcalc_Profiles", "Profiles", "xcalc")
	XcalcMinimapButton:Register("xcalc", miniButton, self.db.profile.minimap)
	xcalc.VERSION = C_AddOns.GetAddOnMetadata("xcalc", "Version")

	self:RegisterChatCommand("xcalc", "SlashCommand")
	self:RegisterChatCommand("calc", "SlashCommand")
	self:RegisterChatCommand("=", "SlashCommand")
end
XcalcMinimapButton:Show("xcalc")
