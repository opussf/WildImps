#!/usr/bin/env lua

require "wowTest"

test.outFileName = "testOut.xml"

ParseTOC( "../src/WildImps.toc" )

-- addon setup

function test.before()
end
function test.after()
end

function test.test_1()
end

test.run()
