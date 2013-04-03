--[[
	This file contains all the GUI instructions.
	The idea of using lua to do all the drawing makes sense to me
	even if it is potentially slower than xml to do the same.  Figure
	that most people are not going to need the calculator to open and
	run the whatever speed increase is of using xml.  I haven't noticed
	much difference between loading it via lua vs other mods that use xml
]]


-- Display Main calculator Window
function xcalc.windowdisplay()
	if (xcalc_window == nil) then
		xcalc.windowframe()
		xcalc_window:Show()
	elseif (xcalc_window:IsVisible()) then
		xcalc_window:Hide()
	else
		xcalc_window:Show()
		xcalc.clear()
	end
end

-- Display options window
function xcalc.optiondisplay()
	if (xcalc_optionwindow == nil) then
		xcalc.optionframe()
		xcalc_optionwindow:Show()
	elseif (xcalc_optionwindow:IsVisible()) then
		xcalc_optionwindow:Hide()
	else
		xcalc_optionwindow:Show()
	end
end


function xcalc.display(displaynumber, memoryset)
	if ( displaynumber == nil or displaynumber == "" ) then
		displaynumber = "0"
	elseif ( memoryset == "1" ) then
		xcalc_memorydisplay:SetText ( xcalc.MemoryIndicatorON )
	elseif ( memoryset == "0" ) then
		xcalc_memorydisplay:SetText( xcalc.MemoryIndicator )
	end
	xcalc.NumberDisplay = displaynumber
	xcalc_numberdisplay:SetText( displaynumber )
end

function xcalc.minimap_init()
	if (Xcalc_Settings.Minimapdisplay == 1) then
		local frame = CreateFrame("Button","xcalc_minimap_button",Minimap)
		frame:SetWidth(34)
		frame:SetHeight(34)
		frame:SetFrameStrata("LOW")
		frame:SetToplevel(1)
		frame:SetNormalTexture("Interface\\AddOns\\xcalc\\xcalc_ButtonRoundNormal.tga")
		frame:SetPushedTexture("Interface\\AddOns\\xcalc\\xcalc_ButtonRoundPushed.tga")
		frame:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight")
		frame:RegisterForClicks("AnyUp")
		frame:SetScript("OnClick", function(self, button, down)
			if (button == "LeftButton") then
				xcalc.windowdisplay()
			elseif (button == "RightButton") then
				xcalc.optiondisplay()
			end
		end)
		frame:SetScript("OnEnter", function() xcalc.tooltip("minimap") end)
		frame:SetScript("OnLeave", function() xcalc.tooltip("hide") end)
		xcalc.minimapbutton_updateposition()
		frame:Show()
	end
end

-- Minimap button Position
function xcalc.minimapbutton_updateposition()

	xcalc_minimap_button:SetPoint("TOPLEFT", "Minimap", "TOPLEFT",
	54 - (78 * cos(Xcalc_Settings.Minimappos)),
	(78 * sin(Xcalc_Settings.Minimappos)) - 55)

end


-- Tooltip display
function xcalc.tooltip(mouseover)
	if ( mouseover == "minimap" ) then
		GameTooltip:SetOwner(xcalc_minimap_button , "ANCHOR_BOTTOMLEFT")
		GameTooltip:SetText("Show/Hide xcalc")
	else
		GameTooltip : Hide ()
	end
end

-- Function for handeling Binding checkbox
function xcalc.options_binding()
	if (xcalc_options_bindcheckbox:GetChecked() == 1) then
		Xcalc_Settings.Binding = 1
	else
		xcalc.unbind()
		Xcalc_Settings.Binding = 0
	end
end

-- Function for Handeling Minimap Display checkbox
function xcalc.options_minimapdisplay()
	if (xcalc_options_minimapcheckbox:GetChecked() == 1) then
		Xcalc_Settings.Minimapdisplay = 1
		if (xcalc_minimap_button == nil) then
			xcalc.minimap_init()
		else
			xcalc_minimap_button:Show()
		end
	else
		Xcalc_Settings.Minimapdisplay = 0
		xcalc_minimap_button:Hide()
	end
end

-- Function for managing options slider
function xcalc.options_minimapslidercontrol()
	if (Xcalc_Settings.Minimapdisplay == 1) then
		Xcalc_Settings.Minimappos = xcalc_options_minimapslider:GetValue()
		xcalc.minimapbutton_updateposition()
	else
		xcalc_options_minimapslider:SetValue(Xcalc_Settings.Minimappos)
		return
	end
end

-- Draw the main window
function xcalc.windowframe()
	-- Main Window Frame (container) and title bar
	local frame = CreateFrame("Frame","xcalc_window",UIParent)
	frame:SetFrameStrata("HIGH")
	frame:EnableMouse(true)
	frame:EnableKeyboard(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:SetHeight(307)
	frame:SetWidth(240)
	frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
	frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
	frame:SetScript("OnShow", function() xcalc.rebind() end)
	frame:SetScript("OnHide", function() xcalc.unbind() end)
	frame:SetBackdrop({bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 }})
	frame:SetPoint("CENTER",0,0)
	local titletexture = frame:CreateTexture("xcalc_window_titletexture")
	titletexture:SetHeight(32)
	titletexture:SetWidth(160)
	titletexture:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")
	titletexture:SetTexCoord(0.2, 0.8, 0, 0.6)
	titletexture:SetPoint("TOP",0,5)
	local titlefont = frame:CreateFontString("xcalc_windowtest_titlefont")
	titlefont:SetHeight(0)
	titlefont:SetWidth(140)
	titlefont:SetFont(STANDARD_TEXT_FONT,12)
	titlefont:SetPoint("TOP",0,-4)
	titlefont:SetTextColor(1,0.8196079,0)
	titlefont:SetText("xcalc " .. xcalc.VERSION)
	-- Number Display box
	local numberdisplaybackground = frame:CreateTexture("xcalc_numberdisplaybackground")
	numberdisplaybackground:SetHeight(34)
	numberdisplaybackground:SetWidth(215)
	numberdisplaybackground:SetTexture("interface/chatframe/ui-chatinputborder")
	numberdisplaybackground:SetPoint("TOPLEFT",10,-33)
	local numberdisplay = frame:CreateFontString("xcalc_numberdisplay",nil,"NumberFont_OutlineThick_Mono_Small")
	numberdisplay:SetHeight(34)
	numberdisplay:SetWidth(205)
	numberdisplay:SetJustifyH("RIGHT")
	numberdisplay:SetPoint("TOPLEFT",10,-33)
	numberdisplay:SetText(xcalc.NumberDisplay)
	local numberdisplayclickoverlay = CreateFrame("Button","xcalc_numberdisplayclickoverlay",frame)
	numberdisplayclickoverlay:SetAllPoints(numberdisplay)
	numberdisplayclickoverlay:Show()
	numberdisplayclickoverlay:EnableMouse(true)
	numberdisplayclickoverlay:SetScript("OnClick",xcalc.numberdisplay_click)
	numberdisplayclickoverlay:SetScript("OnEnter",xcalc.numberdisplay_enter)
	numberdisplayclickoverlay:SetScript("OnLeave",GameTooltip_Hide)
	-- Memory Display
	local memorydisplay = frame:CreateFontString("xcalc_memorydisplay","GameFontNormal")
	memorydisplay:SetWidth(29)
	memorydisplay:SetHeight(29)
	memorydisplay:SetFont(STANDARD_TEXT_FONT,12)
	memorydisplay:SetPoint("TOPLEFT",15,-73)
	-- memorydisplay:SetText("M")
	-- ExitButton
	local exitbutton = CreateFrame("Button", "xcalc_exitbutton",frame,"UIPanelCloseButton")
	exitbutton:SetPoint("TOPRIGHT",-4,-4)
	exitbutton:SetScript("OnClick", function() xcalc.windowdisplay() end)

	-- Main calculator buttons
	xcalc.button(75,29,50,-73,"Backspace","BS")
	xcalc.button(41,29,131,-73,"CE","CE")
	xcalc.button(41,29,178,-73,"C","CL")
	xcalc.button(29,70,190,-183,"=","=")
	xcalc.button(29,32,190,-146,"^","^")
	xcalc.button(29,32,190,-108,"+/-","PM")
	xcalc.button(29,32,155,-221,"+","+")
	xcalc.button(29,32,155,-183,"-","-")
	xcalc.button(29,32,155,-145,"*","*")
	xcalc.button(29,32,155,-108,"/","/")
	xcalc.button(29,32,120,-259,"c","COPPER")
	xcalc.button(29,32,85,-259,"s","SILVER")
	xcalc.button(29,32,50,-259,"g","GOLD")
	xcalc.button(29,32,120,-221,".",".")
	xcalc.button(64,32,50,-222,"0","0")
	xcalc.button(29,32,50,-184,"1","1")
	xcalc.button(29,32,85,-183,"2","2")
	xcalc.button(29,32,120,-183,"3","3")
	xcalc.button(29,32,50,-146,"4","4")
	xcalc.button(29,32,85,-146,"5","5")
	xcalc.button(29,32,120,-146,"6","6")
	xcalc.button(29,32,50,-108,"7","7")
	xcalc.button(29,32,85,-108,"8","8")
	xcalc.button(29,32,120,-108,"9","9")
	xcalc.button(29,32,15,-221,"MA","MA")
	xcalc.button(29,32,15,-183,"MS","MS")
	xcalc.button(29,32,15,-146,"MR","MR")
	xcalc.button(29,32,15,-108,"MC","MC")

	-- Option show button
	local optionbutton = CreateFrame("Button", "xcalc_optionwindow_button",frame,"UIPanelButtonTemplate")
	optionbutton:SetWidth(70)
	optionbutton:SetHeight(25)
	optionbutton:SetPoint("BOTTOMRIGHT",-15,15)
	optionbutton:SetText("Options")
	optionbutton:SetScript("OnClick", function() xcalc.optiondisplay() end)
	xcalc.rebind()
	tinsert(UISpecialFrames,"xcalc_window")
end

function xcalc.button(width, height, x, y, text, cmd)
	local button = CreateFrame("Button", "xcalc." .. text, xcalc_window ,"UIPanelButtonTemplate")
	button:SetWidth(width)
	button:SetHeight(height)
	button:SetPoint("TOPLEFT",x,y)
	button:SetText(text)
	button:SetScript("OnClick", function() xcalc.buttoninput(cmd) end)
	xcalc.buttons = xcalc.buttons or {}
	tinsert(xcalc.buttons,button)
end

-- Draw the Option window
function xcalc.optionframe()
	-- Options window Frame
	local frame = CreateFrame("Frame","xcalc_optionwindow",UIParent)
	frame:SetFrameStrata("HIGH")
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:SetWidth(220)
	frame:SetHeight(200)
	frame:SetBackdrop({bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 }})
	frame:SetPoint("CENTER",230,0)
	local titletexture = frame:CreateTexture("xcalc_optionwindow_titletexture")
	titletexture:SetHeight(32)
	titletexture:SetWidth(160)
	titletexture:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")
	titletexture:SetTexCoord(0.2, 0.8, 0, 0.6)
	titletexture:SetPoint("TOP",0,5)
	local titlefont = frame:CreateFontString("xcalc_optionwindow_titlefont")
	titlefont:SetHeight(0)
	titlefont:SetWidth(140)
	titlefont:SetFont(STANDARD_TEXT_FONT,12)
	titlefont:SetPoint("TOP",0,-4)
	titlefont:SetTextColor(1,0.8196079,0)
	titlefont:SetText("Xcalc Options")
	-- Options Okay Button
	local okaybutton = CreateFrame("Button", "xcalc_optionokaybutton",frame,"UIPanelButtonTemplate")
	okaybutton:SetWidth(70)
	okaybutton:SetHeight(29)
	okaybutton:SetPoint("BOTTOM",0,20)
	okaybutton:SetText("Okay")
	okaybutton:SetScript("OnClick", function() xcalc.optiondisplay() end)
	-- Binding Check box
	local bindingcheckbox = CreateFrame("CheckButton","xcalc_options_bindcheckbox",frame,"OptionsCheckButtonTemplate")
	bindingcheckbox:SetPoint("TOPLEFT",15,-40)
	bindingcheckbox:SetChecked(Xcalc_Settings.Binding)
	bindingcheckbox:SetScript("OnClick", function() xcalc.options_binding() end)
	local bindingcheckboxtext = frame:CreateFontString("xcalc_options_bindcheckboxtext")
	bindingcheckboxtext:SetWidth(200)
	bindingcheckboxtext:SetHeight(0)
	bindingcheckboxtext:SetFont(STANDARD_TEXT_FONT,10)
	bindingcheckboxtext:SetTextColor(1,0.8196079,0)
	bindingcheckboxtext:SetJustifyH("LEFT")
	bindingcheckboxtext:SetText("Use Automatic Key Bindings")
	bindingcheckboxtext:SetPoint("LEFT","xcalc_options_bindcheckbox",30,0)
	-- Display Minimap Check Box
	local minimapcheckbox = CreateFrame("CheckButton","xcalc_options_minimapcheckbox",frame,"OptionsCheckButtonTemplate")
	minimapcheckbox:SetPoint("TOPLEFT",15,-70)
	minimapcheckbox:SetChecked(Xcalc_Settings.Minimapdisplay)
	minimapcheckbox:SetScript("OnClick", function() xcalc.options_minimapdisplay() end)
	local minimapcheckboxtext = minimapcheckbox:CreateFontString("xcalc_options_minimapcheckboxtext")
	minimapcheckboxtext:SetWidth(200)
	minimapcheckboxtext:SetHeight(0)
	minimapcheckboxtext:SetFont(STANDARD_TEXT_FONT,10)
	minimapcheckboxtext:SetTextColor(1,0.8196079,0)
	minimapcheckboxtext:SetJustifyH("LEFT")
	minimapcheckboxtext:SetText("Display Minimap Icon")
	minimapcheckboxtext:SetPoint("LEFT","xcalc_options_minimapcheckbox",30,0)
	-- Minimap Position Slider
	local minimapslider = CreateFrame("Slider","xcalc_options_minimapslider",frame,"OptionsSliderTemplate")
	minimapslider:SetWidth(180)
	minimapslider:SetHeight(16)
	minimapslider:SetMinMaxValues(0, 360)
	minimapslider:SetValueStep(1)
	minimapslider:SetScript("OnValueChanged", function() xcalc.options_minimapslidercontrol() end)
	xcalc_options_minimapsliderHigh:SetText()
	xcalc_options_minimapsliderLow:SetText()
	xcalc_options_minimapsliderText:SetText("Minimap Button Position")
	minimapslider:SetPoint("TOPLEFT",15,-120)
	minimapslider:SetValue(Xcalc_Settings.Minimappos)

end