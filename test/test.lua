#!/usr/bin/env lua

require "wowTest"

test.outFileName = "testOut.xml"

ParseTOC( "../src/WildImps.toc" )

WildImpsFrame = CreateFrame()

-- addon setup

function test.before()
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

function test.test_1()
	CombatLogCurrentEventInfo = { 0, "SWING_DAMAGE", "unknown", "Player-3661-06DB0FE4", "testPlayer", 1297, 0,
			"Creature-0-3131-0-13377-2544-00004ACCAE", "Southern Sand Crawler", 68136, 0x0, 0 }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED( )
end

test.run()
