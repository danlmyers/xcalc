local AceGUI = LibStub("AceGUI-3.0")


function xcalc.display(displaynumber)
	if not displaynumber then
		displaynumber = "0"
	end

	xcalc.editbox:SetText( displaynumber )
end

function xcalc.displayhistory()
	xcalc.scrollframe:ReleaseChildren()
	local history = xcalc:GetHistory()
	for i=1,#history do
		local displaylabel = AceGUI:Create("Label")
		displaylabel:SetFullWidth(true)
		displaylabel:SetJustifyH("RIGHT")
		displaylabel:SetFont(STANDARD_TEXT_FONT,16,"")
		displaylabel:SetText(history[#history+1-i])
		xcalc.scrollframe:AddChild(displaylabel)
	end
	xcalc.scrollframe:SetScroll(1000)
end

function xcalc:WindowFrame()
	if not xcalc.MainFrame then
		xcalc.MainFrame = AceGUI:Create("Frame")
		xcalc.MainFrame:SetTitle("xcalc " .. xcalc.VERSION)
		xcalc.MainFrame:SetWidth(420)
		xcalc.MainFrame:SetHeight(400)
		xcalc.MainFrame:SetLayout("List")
		xcalc.MainFrame:SetCallback("OnClose", function() xcalc.unbind() end)
		xcalc.MainFrame:SetCallback("OnShow", function() xcalc.rebind()  end)
		-- Allows us to close the window with Escape Key properly
		_G["XCALC_MAIN_WINDOW"] = xcalc.MainFrame.frame
		tinsert(UISpecialFrames, "XCALC_MAIN_WINDOW")

		local scrollcontainer = AceGUI:Create("InlineGroup")
		scrollcontainer:SetFullWidth(true)
		scrollcontainer:SetHeight(120)
		scrollcontainer:SetLayout("Fill")
		xcalc.MainFrame:AddChild(scrollcontainer)

		xcalc.scrollframe = AceGUI:Create("ScrollFrame")
		xcalc.scrollframe:SetLayout("Flow")
		scrollcontainer:AddChild(xcalc.scrollframe)

		local row0 = AceGUI:Create("SimpleGroup")
		row0:SetFullWidth(true)
		row0:SetLayout("Flow")
		xcalc.MainFrame:AddChild(row0)

		xcalc.editbox = AceGUI:Create("EditBox")
		xcalc.editbox:SetFullWidth(true)
		xcalc.editbox:SetLabel("")
		xcalc.editbox:SetFocus()
		xcalc.editbox:SetCallback("OnEnterPressed", function() xcalc:equalsbutton() end)
		row0:AddChild(xcalc.editbox)


		local row1 = AceGUI:Create("SimpleGroup")
		row1:SetFullWidth(true)
		row1:SetLayout("Flow")
		xcalc.MainFrame:AddChild(row1)

		local backspacebutton = AceGUI:Create("Button")
		backspacebutton:SetText("Backspace")
		backspacebutton:SetRelativeWidth(.4)
		backspacebutton:SetCallback("OnClick", function() xcalc.backspace()  end)
		row1:AddChild(backspacebutton)

		local cbutton = AceGUI:Create("Button")
		cbutton:SetText("C")
		cbutton:SetRelativeWidth(.2)
		cbutton:SetCallback("OnClick", function() xcalc.display(0)  end)
		row1:AddChild(cbutton)

		local leftparentbutton = AceGUI:Create("Button")
		leftparentbutton:SetText("(")
		leftparentbutton:SetRelativeWidth(.2)
		leftparentbutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("(")  end)
		row1:AddChild(leftparentbutton)

		local rightparentbutton = AceGUI:Create("Button")
		rightparentbutton:SetText(")")
		rightparentbutton:SetRelativeWidth(.2)
		rightparentbutton:SetCallback("OnClick", function() xcalc:UpdateEditBox(")")  end)
		row1:AddChild(rightparentbutton)

		local row2 = AceGUI:Create("SimpleGroup")
		row2:SetFullWidth(true)
		row2:SetLayout("Flow")
		xcalc.MainFrame:AddChild(row2)

		local sevenbutton = AceGUI:Create("Button")
		sevenbutton:SetText("7")
		sevenbutton:SetRelativeWidth(.2)
		sevenbutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("7")  end)
		row2:AddChild(sevenbutton)

		local eightbutton = AceGUI:Create("Button")
		eightbutton:SetText("8")
		eightbutton:SetRelativeWidth(.2)
		eightbutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("8")  end)
		row2:AddChild(eightbutton)

		local ninebutton = AceGUI:Create("Button")
		ninebutton:SetText("9")
		ninebutton:SetRelativeWidth(.2)
		ninebutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("9")  end)
		row2:AddChild(ninebutton)

		local dividebutton = AceGUI:Create("Button")
		dividebutton:SetText("/")
		dividebutton:SetRelativeWidth(.2)
		dividebutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("/")  end)
		row2:AddChild(dividebutton)

		local sqrtbutton = AceGUI:Create("Button")
		sqrtbutton:SetText("√")
		sqrtbutton:SetRelativeWidth(.2)
		sqrtbutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("√")  end)
		row2:AddChild(sqrtbutton)

		local row3 = AceGUI:Create("SimpleGroup")
		row3:SetFullWidth(true)
		row3:SetLayout("Flow")
		xcalc.MainFrame:AddChild(row3)

		local fourbutton = AceGUI:Create("Button")
		fourbutton:SetText("4")
		fourbutton:SetRelativeWidth(.2)
		fourbutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("4")  end)
		row3:AddChild(fourbutton)

		local fivebutton = AceGUI:Create("Button")
		fivebutton:SetText("5")
		fivebutton:SetRelativeWidth(.2)
		fivebutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("5")  end)
		row3:AddChild(fivebutton)

		local sixbutton = AceGUI:Create("Button")
		sixbutton:SetText("6")
		sixbutton:SetRelativeWidth(.2)
		sixbutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("6")  end)
		row3:AddChild(sixbutton)

		local timesbutton = AceGUI:Create("Button")
		timesbutton:SetText("x")
		timesbutton:SetRelativeWidth(.2)
		timesbutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("*")  end)
		row3:AddChild(timesbutton)

		local negativebutton = AceGUI:Create("Button")
		negativebutton:SetText("+/-")
		negativebutton:SetRelativeWidth(.2)
		negativebutton:SetCallback("OnClick", function() xcalc.plusminus()  end)
		row3:AddChild(negativebutton)

		local row4 = AceGUI:Create("SimpleGroup")
		row4:SetFullWidth(true)
		row4:SetLayout("Flow")
		xcalc.MainFrame:AddChild(row4)

		local onebutton = AceGUI:Create("Button")
		onebutton:SetText("1")
		onebutton:SetRelativeWidth(.2)
		onebutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("1")  end)
		row4:AddChild(onebutton)

		local twobutton = AceGUI:Create("Button")
		twobutton:SetText("2")
		twobutton:SetRelativeWidth(.2)
		twobutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("2")  end)
		row4:AddChild(twobutton)

		local threebutton = AceGUI:Create("Button")
		threebutton:SetText("3")
		threebutton:SetRelativeWidth(.2)
		threebutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("3")  end)
		row4:AddChild(threebutton)

		local minusbutton = AceGUI:Create("Button")
		minusbutton:SetText("-")
		minusbutton:SetRelativeWidth(.2)
		minusbutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("-")  end)
		row4:AddChild(minusbutton)

		local exponentbutton = AceGUI:Create("Button")
		exponentbutton:SetText("^")
		exponentbutton:SetRelativeWidth(.2)
		exponentbutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("^")  end)
		row4:AddChild(exponentbutton)

		local row5 = AceGUI:Create("SimpleGroup")
		row5:SetFullWidth(true)
		row5:SetLayout("Flow")
		xcalc.MainFrame:AddChild(row5)

		local zerobutton = AceGUI:Create("Button")
		zerobutton:SetText("0")
		zerobutton:SetRelativeWidth(.2)
		zerobutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("0")  end)
		row5:AddChild(zerobutton)

		local decimalbutton = AceGUI:Create("Button")
		decimalbutton:SetText(".")
		decimalbutton:SetRelativeWidth(.2)
		decimalbutton:SetCallback("OnClick", function() xcalc:UpdateEditBox(".") end)
		row5:AddChild(decimalbutton)

		local percentbutton = AceGUI:Create("Button")
		percentbutton:SetText("%")
		percentbutton:SetRelativeWidth(.2)
		percentbutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("%")  end)
		row5:AddChild(percentbutton)

		local plusbutton = AceGUI:Create("Button")
		plusbutton:SetText("+")
		plusbutton:SetRelativeWidth(.2)
		plusbutton:SetCallback("OnClick", function() xcalc:UpdateEditBox("+")  end)
		row5:AddChild(plusbutton)

		local equalsbutton = AceGUI:Create("Button")
		equalsbutton:SetText("=")
		equalsbutton:SetRelativeWidth(.2)
		equalsbutton:SetCallback("OnClick", function() xcalc:equalsbutton() end)
		row5:AddChild(equalsbutton)

		local row6 = AceGUI:Create("SimpleGroup")
		row6:SetFullWidth(true)
		row6:SetLayout("Flow")
		xcalc.MainFrame:AddChild(row6)

		local goldbutton = AceGUI:Create("Button")
		goldbutton:SetText("g")
		goldbutton:SetRelativeWidth(.33)
		goldbutton:SetCallback("OnClick", function() xcalc.stategold()  end)
		row6:AddChild(goldbutton)

		local silverbutton = AceGUI:Create("Button")
		silverbutton:SetText("s")
		silverbutton:SetRelativeWidth(.33)
		silverbutton:SetCallback("OnClick", function() xcalc.statesilver()  end)
		row6:AddChild(silverbutton)

		local copperbutton = AceGUI:Create("Button")
		copperbutton:SetText("c")
		copperbutton:SetRelativeWidth(.33)
		copperbutton:SetCallback("OnClick", function() xcalc.statecopper()  end)
		row6:AddChild(copperbutton)

	else
		xcalc.MainFrame:Show()
	end

	xcalc.displayhistory()
end
