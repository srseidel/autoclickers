-- ============================================================
-- Mouse Jiggler — moves the mouse back and forth
-- ============================================================
-- Requires cliclick (a tiny command-line mouse tool).
-- Install once with Homebrew:   brew install cliclick
-- ============================================================

-- ===================== SETTINGS =============================
-- Starting X / Y position of the mouse (in screen pixels).
-- Set startX/startY to "center" to auto-use the screen center.
property startX : "center"
property startY : "center"

-- How far the mouse moves from the start point (in pixels).
property moveDistance : 100

-- How many seconds to wait between each move.
property intervalSeconds : 5

-- Direction of travel: "horizontal" or "vertical"
property moveDirection : "horizontal"
-- ============================================================


-- Figure out the screen center (used if startX/startY = "center")
tell application "Finder"
	set screenBounds to bounds of window of desktop
end tell
set screenWidth to item 3 of screenBounds
set screenHeight to item 4 of screenBounds

set centerX to screenWidth div 2
set centerY to screenHeight div 2

-- Resolve the actual starting coordinates
if startX is "center" then
	set baseX to centerX
else
	set baseX to startX
end if

if startY is "center" then
	set baseY to centerY
else
	set baseY to startY
end if

-- Precompute the two positions we bounce between
if moveDirection is "horizontal" then
	set posA_X to baseX
	set posA_Y to baseY
	set posB_X to baseX + moveDistance
	set posB_Y to baseY
else
	set posA_X to baseX
	set posA_Y to baseY
	set posB_X to baseX
	set posB_Y to baseY + moveDistance
end if

-- Main loop: bounce forever (stop with Cmd-. or by quitting the script)
set atA to true
repeat
	if atA then
		do shell script "cliclick m:" & posB_X & "," & posB_Y
		set atA to false
	else
		do shell script "cliclick m:" & posA_X & "," & posA_Y
		set atA to true
	end if
	delay intervalSeconds
end repeat
