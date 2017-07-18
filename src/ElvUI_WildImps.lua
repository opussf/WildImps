-------------------------------------------------------------------------------
-- ElvUI Wild Imps Tracker By Lockslap
-- Based on Imps by Kuni!
-------------------------------------------------------------------------------
local E, L, V, P, G, _ = unpack(ElvUI)
local LSM = LibStub("LibSharedMedia-3.0")
local impTime, impCast = {}, {}
local alreadyRegistered = false
local impCount = 0
local playerGUID

-- create the imp frame
local impGUI = CreateFrame("Frame", "impGUI", E.UIParent)
impGUI:SetBackdrop({
	bgFile = "Interface\\dialogframe\\ui-dialogbox-background-dark",
	edgeFile = "Interface\\tooltips\\UI-tooltip-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 8,
	insets = {
		left = 1,
		right = 1,
		top = 1,
		bottom = 1,
	},
})
impGUI:SetWidth(100)
impGUI:SetHeight(25)
impGUI:SetPoint("CENTER")

-- imp artwork
local impGUIImp = impGUI:CreateTexture("impGraphic")
impGUIImp:SetTexture("Interface\\AddOns\\ElvUI_WildImps\\imp")
impGUIImp:SetWidth(75)
impGUIImp:SetHeight(75)
impGUIImp:SetPoint("CENTER", -20, 0)

-- count string
local impCounter = impGUI:CreateFontString("impCounter")
impCounter:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
impCounter:SetTextColor(1, 1, 1, 1)
impCounter:SetText("0")
impCounter:SetJustifyH("CENTER")
impCounter:SetJustifyV("TOP")
impCounter:SetPoint("CENTER", impGUI, 25, 0)

-- frame movement
impGUI:EnableMouse(true)
impGUI:SetMovable(true)
impGUI:RegisterForDrag("LeftButton")
impGUI:SetScript("OnDragStart", function(self) self:StartMoving() end)
impGUI:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

local function isDemonology()
	local _, class = UnitClass("player")
	return (class == "WARLOCK" and GetSpecialization() == 2) and true or false
end

-- events
function impGUI:CHARACTER_POINTS_CHANGED(self, event, ...)
	if isDemonology() then
		if not alreadyRegistered then
			impGUI:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			alreadyRegistered = true
		end
		impGUI:Show()
	else
		if alreadyRegistered then
			impGUI:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			alreadyRegistered = false
		end
		impGUI:Hide()
	end
end

function impGUI:PLAYER_TALENT_UPDATE(self, event, ...)
	if isDemonology() then
		if not alreadyRegistered then
			impGUI:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			alreadyRegistered = true
		end
		impGUI:Show()
	else
		if alreadyRegistered then
			impGUI:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			alreadyRegistered = false
		end
		impGUI:Hide()
	end
end

function impGUI:ACTIVE_TALENT_GROUP_CHANGED(self, event, ...)
	if isDemonology() then
		if not alreadyRegistered then
			impGUI:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			alreadyRegistered = true
		end
		impGUI:Show()
	else
		if alreadyRegistered then
			impGUI:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			alreadyRegistered = false
		end
		impGUI:Hide()
	end
end

function impGUI:PLAYER_ENTERING_WORLD(self, event, ...)
	playerGUID = UnitGUID("player")

	-- skin the frame
	impGUI:SetTemplate("Default")

	-- set the font
	impCounter:SetFont(LSM:Fetch("font", "ElvUI Font"), 20, "OUTLINE")

	-- only if they pass the checks will we actually look at the combat log
	if isDemonology() then
		impGUI:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		impGUI:Show()

		alreadyRegistered = true
	else
		impGUI:Hide()
	end

	-- events to watch to see if they switched to a demo spec
	impGUI:RegisterEvent("CHARACTER_POINTS_CHANGED")
	impGUI:RegisterEvent("PLAYER_TALENT_UPDATE")
	impGUI:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

	impGUI:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function impGUI:COMBAT_LOG_EVENT_UNFILTERED(self, event, ...)
	local compTime = GetTime()
	local combatEvent = select(1, ...)
	local sourceGUID = select(3, ...)
	local sourceName = select(4, ...)
	local destGUID = select(7, ...)
	local destName = select(8, ...)

	-- time out any imps (12 seconds)
	for index, value in pairs(impTime) do
		if (value + 12) < compTime then
			impTime[index] = nil
			impCount = impCount - 1

			--print(("Imp timed out. Count: |cff00ff00%d|r"):format(impCount))
		end
	end

  -- imp imploded
	if combatEvent == "SPELL_INSTAKILL" and destName == "Wild Imp" and sourceGUID == playerGUID then
		for index, value in pairs(impTime) do
			if destGUID == index then
				impTime[index] = nil
				impCast[index] = nil
				impCount = impCount - 1

				--print(("Imp imploded. Count: |cff00ff00%d|r"):format(impCount))
			end
		end
	end


	-- imp died
	if combatEvent == "UNIT_DIED" and (sourceName == "Wild Imp" or destName == "Wild Imp") then
		for index, value in pairs(impTime) do
			if destGUID == index then
				impTime[index] = nil
				impCast[index] = nil
				impCount = impCount - 1

				--print(("Imp died. Count: |cff00ff00%d|r"):format(impCount))
			end
		end
	end

	-- imp died from casting (10 casts)
	if combatEvent == "SPELL_CAST_SUCCESS" and sourceName == "Wild Imp" then
		for index,  value in pairs(impCast) do
			if sourceGUID == index then
				-- remove cast
				impCast[index] = impCast[index] - 1

				-- wild imp has casted 10 times so it dies
				if impCast[index] == 0 then
					impCast[index] = nil
					impTime[index] = nil
					impCount = impCount - 1

					--print(("Imp casted 10 times and died. Count: |cff00ff00%d|r"):format(impCount))
				end
			end
		end
	end

	-- imp summoned
	if combatEvent == "SPELL_SUMMON" and destName == "Wild Imp" and sourceGUID == playerGUID then
		impTime[destGUID] = compTime
		impCast[destGUID] = 10	-- each imp has 10 casts
		impCount = impCount + 1

		--print(("Imp spawned. Count: |cff00ff00%d|r"):format(impCount))
	end

	impCounter:SetText(impCount)
end

impGUI:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)
impGUI:RegisterEvent("PLAYER_ENTERING_WORLD")
