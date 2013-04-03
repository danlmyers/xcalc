local status = select(6,GetAddOnInfo("ElvUI"))
if status == "MISSING" then return end

local NAME = ...
local E, L, V, P, G, S, _ 
local xcalc_loaded, elvui_loaded, main_skinned, options_skinned, ApplySkin, ApplyOptionsSkin

local event = CreateFrame("Frame")
event.OnEvent = function(self,event,...)
	return self[event] and self[event](...)
end
event:SetScript("OnEvent",event.OnEvent)
event:RegisterEvent("PLAYER_LOGIN")

event.PLAYER_LOGIN = function(...)
	if IsAddOnLoaded(NAME) then
		event.ADDON_LOADED(NAME)
	else
		event:RegisterEvent("ADDON_LOADED")
	end
	if IsAddOnLoaded("ElvUI") then
		event.ADDON_LOADED("ElvUI")
	else
		event:RegisterEvent("ADDON_LOADED")
	end
end

event.ADDON_LOADED = function(...)
	if (...) == "ElvUI" then
		E, L, V, P, G = unpack(ElvUI)
		S = E:GetModule('Skins')
		elvui_loaded = true
	end
	if (...) == NAME then
		xcalc_loaded = true
	end
	if xcalc_loaded and elvui_loaded then
		hooksecurefunc(xcalc,"windowdisplay",ApplySkin)
		hooksecurefunc(xcalc,"optiondisplay",ApplyOptionsSkin)
		event:UnregisterEvent("ADDON_LOADED")
	end
end

ApplySkin = function()
	if main_skinned then return end
	xcalc_window:StripTextures()
	xcalc_window:SetTemplate("Transparent")
	S:HandleCloseButton(xcalc_exitbutton)
	S:HandleButton(xcalc_optionwindow_button)
	for _,button in ipairs(xcalc.buttons) do
		S:HandleButton(button)
	end
	main_skinned = true
end

ApplyOptionsSkin = function()
	if options_skinned then return end
	xcalc_optionwindow:StripTextures()
	xcalc_optionwindow:SetTemplate("Transparent")
	S:HandleButton(xcalc_optionokaybutton)
	S:HandleCheckBox(xcalc_options_bindcheckbox)
	S:HandleCheckBox(xcalc_options_minimapcheckbox)
	S:HandleSliderFrame(xcalc_options_minimapslider)
	options_skinned = true
end