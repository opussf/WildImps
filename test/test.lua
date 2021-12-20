#!/usr/bin/env lua

require "wowTest"

test.outFileName = "testOut.xml"

ParseTOC( "../src/WildImps.toc" )

WildImpsFrame = CreateFrame()

-- addon setup

function test.before()
	WildImps.impInfo = {}
	WildImps.impCount = 0
	WildImps.maxImps = 0
end
function test.after()
end

function test.test_SLUG()
	assert( WILDIMPS_SLUG )
end
function test.test_Table()
	assert( WildImps )
end
function test.test_MSG_ADDONNAME()
	assert( WILDIMPS_MSG_ADDONNAME )
end
function test.test_MSG_AUTHOR()
	-- just make sure this is assigned
	assert( WILDIMPS_MSG_AUTHOR )
end
function test.test_MSG_VERSION()
	-- just make sure this is assigned
	assert( WILDIMPS_MSG_VERSION )
end
function test.test_OnLoad()
	WildImps.OnLoad()
	assertEquals( "Warlock", WildImps.class )
	assertEquals( "playerGUID", WildImps.playerGUID )
	assertTrue( WildImpsFrame.Events["PLAYER_SPECIALIZATION_CHANGED"], "PLAYER_SPECIALIZATION_CHANGED should be registered.")
	assertTrue( WildImpsFrame.Events["COMBAT_LOG_EVENT_UNFILTERED"], "COMBAT_LOG_EVENT_UNFILTERED should be registered.")
end
function test.test_ChangeSpecialization()
	WildImps.PLAYER_SPECIALIZATION_CHANGED()
end

function test.test_SummonImp_Mine()

	CombatLogCurrentEventInfo = { 2876, "SPELL_SUMMON", "playerGUID", "testPlayer", 1297, 0,
			"Creature-0", "Wild Imp", 68136, 0x0, 0 }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED( )
	for k,v in pairs( WildImps.impInfo ) do
		print( k )
	end
	--assertEquals( 0, WildImps.impInfo["Creature-0"]["time"])
	--assertEquals( 10, WildImps.impInfo["Creature-0"]["casts"])
	--assertEquals( 1, WildImps.impCount )

end

test.run()
