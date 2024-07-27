-- WildImps @VERSION@
WILDIMPS_SLUG, WildImps = ...
WILDIMPS_MSG_ADDONNAME = GetAddOnMetadata( WILDIMPS_SLUG, "Title" )
WILDIMPS_MSG_AUTHOR = GetAddOnMetadata( WILDIMPS_SLUG, "Author" )
WILDIMPS_MSG_VERSION = GetAddOnMetadata( WILDIMPS_SLUG, "Version" )

COLOR_RED = "|cffff0000"
COLOR_END = "|r"

WildImps.impInfo = {}
WildImps.impCount = 0
WildImps.maxImps = 3
WildImps.summonCount = 0
WildImps.TTLBySpell = {[104317]=40, [279910]=14}

-- Support code
function WildImps.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_RED..WILDIMPS_MSG_ADDONNAME.."> "..COLOR_END..msg;
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg );
end

-- Event code
function WildImps.OnLoad()
	WildImpsFrame:RegisterEvent( "PLAYER_ENTERING_WORLD" )
end
function WildImps.PLAYER_ENTERING_WORLD()
	WildImpsFrame:UnregisterEvent( "PLAYER_ENTERING_WORLD" )
	WildImps.class, _, classindex = UnitClass( "player" )
	if classindex == 9 then
		WildImps.playerGUID = UnitGUID( "player" )
		WildImpsFrame:RegisterEvent( "PLAYER_SPECIALIZATION_CHANGED" )
		if GetSpecialization() == 2 then  -- 2 = Demo
			WildImpsFrame:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED")
		else
			WildImpsFrame:UnregisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" )
		end
	else
		WildImps.Print( "Silly "..WildImps.class..", you are not a Warlock." )
		DisableAddOn( WILDIMPS_SLUG, UnitName("player") )
	end
end

function WildImps.OnUpdate()
	if WildImps.impCount > 0 then
		WildImps_ImpCountBar:Show()
		WildImps_ImpCountBar:SetMinMaxValues( 0, WildImps.maxImps )
		WildImps_ImpCountBar:SetValue( WildImps.impCount )
		WildImps_ImpCountBarText:SetText( WildImps.impCount.." / "..WildImps.maxImps.." :: "..WildImps.summonCount )
	else
		WildImps_ImpCountBar:Hide()
	end
end

function WildImps.PLAYER_SPECIALIZATION_CHANGED()
	WildImps.PLAYER_ENTERING_WORLD()
end

function WildImps.COMBAT_LOG_EVENT_UNFILTERED()
	local ets, subEvent, _, sourceID, sourceName, sourceFlags, sourceRaidFlags,
			destID, destName, destFlags, _, spellID, spName, _, ext1, ext2, ext3 = CombatLogGetCurrentEventInfo()

	-- New imp, lasts for 5 casts, or seconds defined by which spell summons them.
	if destName and subEvent == "SPELL_SUMMON" and destName == "Wild Imp" and sourceID == WildImps.playerGUID then
		WildImps.impInfo[destID] = {["time"]=ets+WildImps.TTLBySpell[spellID], ["casts"]=5}
		WildImps.impCount = WildImps.impCount + 1
		WildImps.summonCount = WildImps.summonCount + 1
		if WildImps.impCount > WildImps.maxImps then
			WildImps.maxImps = WildImps.impCount
			local msg = WildImps.impCount.." Wild Imps!   MUHAHAHA"
			SendChatMessage( msg, "SAY" )
		end
		--WildImps.Print( "Imp ("..destID..") summonned: "..WildImps.impCount )
		--WildImps.Print( "Imp Up ( "..WildImps.impCount.." / "..WildImps.maxImps.." / "..WildImps.summonCount.." )" )
	end

	-- Remove Imps (lower the count)
	-- imp casts
	if subEvent == "SPELL_CAST_SUCCESS" and sourceName and sourceName == "Wild Imp" and WildImps.impInfo[sourceID] ~= nil then
		WildImps.impInfo[sourceID]["casts"] = WildImps.impInfo[sourceID]["casts"] - 1
		--WildImps.Print( "Imp ("..sourceID..") successfuly cast a spell, has "..WildImps.impInfo[sourceID]["casts"].." casts left.")
	end

	-- imp times out
	-- imp imploded
	if subEvent == "SPELL_CAST_SUCCESS" and spName == "Implosion" and sourceID == WildImps.playerGUID then
		--WildImps.Print("IMPLOSION!")
		WildImps.impInfo = {}
		WildImps.impCount = 0
		--WildImps.Print( "IMP ZERO! ("..WildImps.summonCount..")" )
	end

	-- Remove Imps
	-- imp times out - no special event for this?
	for impID, impData in pairs( WildImps.impInfo ) do
		if (impData["time"] < ets) or impData["casts"] == 0 then
			WildImps.impInfo[impID] = nil
			WildImps.impCount = WildImps.impCount - 1
			--if WildImps.impCount == 0 then
			--	WildImps.Print( "IMP ZERO! ("..WildImps.summonCount..")" )
			--end
			--WildImps.Print( "Imp Down ("..WildImps.impCount..")" )
		end
	end
end
