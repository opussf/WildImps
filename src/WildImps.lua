-- WildImps @VERSION@
WILDIMPS_SLUG, WildImps = ...
WILDIMPS_MSG_ADDONNAME = GetAddOnMetadata( WILDIMPS_SLUG, "Title" )
WILDIMPS_MSG_AUTHOR = GetAddOnMetadata( WILDIMPS_SLUG, "Author" )
WILDIMPS_MSG_VERSION = GetAddOnMetadata( WILDIMPS_SLUG, "Version" )

COLOR_RED = "|cffff0000";
COLOR_END = "|r";

WildImps.impInfo = {}
WildImps.impCount = 0
WildImps.maxImps = 0

-- Support code
function WildImps.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_RED.."WildImps".."> "..COLOR_END..msg;
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg );
end

-- Event code
function WildImps.OnLoad()
	WildImps.class = UnitClass( "player" )
	WildImps.playerGUID = UnitGUID( "player" )
	if WildImps.class == "Warlock" then
		WildImpsFrame:RegisterEvent( "PLAYER_SPECIALIZATION_CHANGED" )
		if GetSpecialization() == 2 then  -- 2 = Demo
			WildImpsFrame:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED")
		else
			WildImpsFrame:UnregisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" )
		end
	else
		WildImps.Print( "Silly "..WildImps.class..", you are not a Warlock." )
		DisableAddOn( WILDIMPS_SLUG )
	end
end

function WildImps.PLAYER_SPECIALIZATION_CHANGED()
	WildImps.OnLoad()
end

function WildImps.COMBAT_LOG_EVENT_UNFILTERED()
	local ets, subEvent, _, sourceID, sourceName, sourceFlags, sourceRaidFlags,
			destID, destName, destFlags, _, spellID, spName, _, ext1, ext2, ext3 = CombatLogGetCurrentEventInfo()

	-- New imp, lasts for 10 casts, or 12 seconds.
	if subEvent == "SPELL_SUMMON" and destName == "Wild Imp" and sourceID == WildImps.playerGUID then
		WildImps.impInfo[destID] = {["time"]=ets, ["casts"]=10}
		WildImps.impCount = WildImps.impCount + 1
		WildImps.Print( "Imp ("..destID..") summonned: "..WildImps.impCount )
	end

end


--[[
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

]]