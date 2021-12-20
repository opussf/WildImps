-- WildImps @VERSION@
WILDIMPS_SLUG, WildImps = ...
WILDIMPS_MSG_VERSION = GetAddOnMetadata( IWILDIMPS_SLUG, "Version" )
WILDIMPS_MSG_ADDONNAME = GetAddOnMetadata( IWILDIMPS_SLUG, "Title" )
WILDIMPS_MSG_AUTHOR = GetAddOnMetadata( WILDIMPS_SLUG, "Author" )

WildImps = {}

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
	if WildImps.class == "WARLOCK" then
		WildImpsFrame:RegisterEvent( "CHARACTER_POINTS_CHANGED" )
		WildImpsFrame:RegisterEvent( "PLAYER_TALENT_UPDATE" )
		WildImpsFrame:RegisterEvent( "ACTIVE_TALENT_GROUP_CHANGED" )
		if GetSpecialization() == 2 then  -- 2 = Demo
			WildImpsFrame:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED")
		else
			WildImpsFrame:UnregisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" )
		end
	else
		WildImps.Print( "Silly "..class..", you are not a Warlock." )
		DisableAddOn( WILDIMPS_SLUG )
	end
end

function WildImps.CHARACTER_POINTS_CHANGED()
end

function WildImps.PLAYER_TALENT_UPDATE()
end
function WildImps.ACTIVE_TALENT_GROUP_CHANGED()
end
function WildImps.COMBAT_LOG_EVENT_UNFILTERED()
end
