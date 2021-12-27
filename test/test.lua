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
	WildImps.summonCount = 0
	--WildImps_ImpCountBar.Hide()
	WildImps.OnLoad()
	WildImps.PLAYER_ENTERING_WORLD()
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
function test.test_SummonImp_Mine_setTime()
	CombatLogCurrentEventInfo = { 2876, "SPELL_SUMMON", true, "playerGUID", "testPlayer", 1297, 0, "Creature-0", "Wild Imp", 68136, 0x0, 104317, "sn" }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED( )

	assertEquals( 2876+40, WildImps.impInfo["Creature-0"]["time"])
end
function test.test_SummonImp_Mine_setCasts()
	CombatLogCurrentEventInfo = { 2876, "SPELL_SUMMON", true, "playerGUID", "testPlayer", 1297, 0, "Creature-0", "Wild Imp", 68136, 0x0, 104317, "sn" }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED( )

	assertEquals( 5, WildImps.impInfo["Creature-0"]["casts"])
end
function test.test_SummonImp_Mine_setCount()
	CombatLogCurrentEventInfo = { 2876, "SPELL_SUMMON", true, "playerGUID", "testPlayer", 1297, 0, "Creature-0", "Wild Imp", 68136, 0x0, 104317, "sn" }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED( )

	assertEquals( 1, WildImps.impCount )
end
function test.test_SummonImp_Mine_setMax()
	CombatLogCurrentEventInfo = { 2876, "SPELL_SUMMON", true, "playerGUID", "testPlayer", 1297, 0, "Creature-0", "Wild Imp", 68136, 0x0, 104317, "sn" }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED( )

	assertEquals( 1, WildImps.maxImps )
end
function test.test_SummonImp_Mine_setSummonCount()
	CombatLogCurrentEventInfo = { 2876, "SPELL_SUMMON", true, "playerGUID", "testPlayer", 1297, 0, "Creature-0", "Wild Imp", 68136, 0x0, 104317, "sn" }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED( )

	assertEquals( 1, WildImps.summonCount )
end
function test.test_SummonImp_NotMine()
	-- Don't track imps if not yours
	CombatLogCurrentEventInfo = { 2876, "SPELL_SUMMON", true, "otherGUID", "miscPlayer", 1297, 0, "Creature-0", "Wild Imp", 68136, 0x0, 104317, "sn" }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED( )

	assertIsNil( WildImps.impInfo["Creature-0"] )
	assertEquals( 0, WildImps.impCount )
end
function test.test_TimedOut_removesImp_NilTable()
	WildImps.impCount = 1
	WildImps.impInfo["Creature-0"]={["time"]=time()-41, ["casts"]=5}
	CombatLogCurrentEventInfo = { time(), "Some event", true, "blah", "blah", 1297, 0, "blah", "blah", 68136, 0x0, 0 }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED()

	assertIsNil( WildImps.impInfo["Creature-0"] )
end
function test.test_TimedOut_removesImp_0Count()
	WildImps.impCount = 1
	WildImps.impInfo["Creature-0"]={["time"]=time()-41, ["casts"]=5}
	CombatLogCurrentEventInfo = { time(), "Some event", true, "blah", "blah", 1297, 0, "blah", "blah", 68136, 0x0, 0 }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED()

	assertEquals( 0, WildImps.impCount )
end
function test.test_LastCast_removesImp_NilTable()
	WildImps.impCount = 1
	WildImps.impInfo["Creature-0"]={["time"]=time(), ["casts"]=1}
	CombatLogCurrentEventInfo = { time(), "SPELL_CAST_SUCCESS", true, "Creature-0", "Wild Imp", 1297, 0, "blah", "blah", 68136, 0x0, 0 }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED()

	assertIsNil( WildImps.impInfo["Creature-0"] )
end
function test.test_LastCast_removesImp_0Count()
	WildImps.impCount = 1
	WildImps.impInfo["Creature-0"]={["time"]=time(), ["casts"]=1}
	CombatLogCurrentEventInfo = { time(), "SPELL_CAST_SUCCESS", true, "Creature-0", "Wild Imp", 1297, 0, "blah", "blah", 68136, 0x0, 0 }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED()

	assertEquals( 0, WildImps.impCount )
end
function test.test_Implosion_NilTable()
	WildImps.impCount = 2
	WildImps.impInfo["Creature-0"]={["time"]=time(), ["casts"]=10}
	WildImps.impInfo["Creature-1"]={["time"]=time(), ["casts"]=10}
	CombatLogCurrentEventInfo = { time(), "SPELL_CAST_SUCCESS", true, "playerGUID", "testPlayer", 1297, 0, "blah", "blah", 68136, 0x0, 0, "Implosion" }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED()

	assertIsNil( WildImps.impInfo["Creature-0"] )
end
function test.test_Implosion_0Count()
	WildImps.impCount = 2
	WildImps.impInfo["Creature-0"]={["time"]=time(), ["casts"]=10}
	WildImps.impInfo["Creature-1"]={["time"]=time(), ["casts"]=10}
	CombatLogCurrentEventInfo = { time(), "SPELL_CAST_SUCCESS", true, "playerGUID", "testPlayer", 1297, 0, "blah", "blah", 68136, 0x0, 0, "Implosion" }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED()

	assertEquals( 0, WildImps.impCount )
end
function test.test_SummonImp_Mine_Talent_setTime()
	CombatLogCurrentEventInfo = { 2876, "SPELL_SUMMON", true, "playerGUID", "testPlayer", 1297, 0, "Creature-0", "Wild Imp", 68136, 0x0, 279910, "sn" }
	WildImps.COMBAT_LOG_EVENT_UNFILTERED( )

	assertEquals( 2876+24, WildImps.impInfo["Creature-0"]["time"])
end

test.run()
