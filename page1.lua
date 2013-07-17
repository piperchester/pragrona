-----------------------------------------------------------------------------------------
--
-- page1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- forward declarations and other locals
local background, pageTitleText, continueText, pageTween, fadeTween1, fadeTween2, tipText

local swipeThresh = 100		-- amount of pixels finger must travel to initiate page swipe
local tweenTime = 500
local animStep = 1
local readyToContinue = false

-- function to show next animation
local function showNext()
	if readyToContinue then

		background.touch = onBackgroundTouch

		continueText.isVisible = false
		readyToContinue = false
		
		local function repositionAndFadeIn()
			pageTitleText:setReferencePoint( display.CenterReferencePoint )
			pageTitleText.x = display.contentWidth * 0.5
			pageTitleText.y = display.contentHeight * 0.20
			pageTitleText.isVisible = true
			
			fadeTween1 = transition.to( pageTitleText, { time=tweenTime*0.5, alpha=1.0 } )
		end
		
		local function completeTween()
			animStep = animStep + 1
			if animStep > 3 then animStep = 1; end
			
			readyToContinue = true
			continueText.isVisible = true
		end
		
		if animStep == 1 then
			pageTitleText.alpha = 0
			pageTitleText.text = "Pragmatic Tips!"
			pageTitleText.size = 40
			repositionAndFadeIn()
			
		elseif animStep == 2 then
			pageTitleText.alpha = 0
			pageTitleText.text = "Easy API accessed via Lua scripting."
			repositionAndFadeIn()
		
		elseif animStep == 3 then
			pageTitleText.alpha = 0
			pageTitleText.text = "Corona SDK: Code Less. Play More."
			repositionAndFadeIn()
		end
	end
end

-- touch event listener for background object
local function onPageSwipe( self, event )
	local phase = event.phase
	if phase == "began" then
		display.getCurrentStage():setFocus( self )
		self.isFocus = true
	
	elseif self.isFocus then
		if phase == "ended" or phase == "cancelled" then
			
			local distance = event.x - event.xStart
			if distance > swipeThresh then
				-- SWIPED to right; go back to title page scene
				storyboard.gotoScene( "title", "slideRight", 800 )
			else
				-- Touch and release; initiate next animation
				showNext()
			end
			
			display.getCurrentStage():setFocus( nil )
			self.isFocus = nil
		end
	end
	return true
end

-- Touch listener function for background object
local function onBackgroundTouch( self, event )
	if event.phase == "ended" or event.phase == "cancelled" then
		-- go to page1.lua scene
		-- storyboard.gotoScene( "page1", "slideDown", 800 )

		tipText.text = "Tip #2: Don't Make Lame Excuses!"
		
		return true	-- indicates successful touch
	end
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-- create background image
	background = display.newImageRect( group, "content-background.png", display.contentWidth, display.contentHeight )
	background:setReferencePoint( display.TopLeftReferencePoint )
	background.x, background.y = 0, 0
	background.alpha = 0.5

	-- create tipText
	tipText = display.newText(self.view, "Tip #1: Care About Your Craft!", 0, 0, native.systemFontBold, 40 )
	tipText:setReferencePoint( display.CenterReferencePoint )
	tipText.x = display.contentWidth * 0.5
	tipText.y = display.contentHeight * 0.5
	tipText.isVisible = true

	
	-- create pageTitleText
	pageTitleText = display.newText( group, "", 0, 0, native.systemFontBold, 18 )
	pageTitleText:setReferencePoint( display.CenterReferencePoint )
	pageTitleText.x = display.contentWidth * 0.5
	pageTitleText.y = display.contentHeight * 0.5
	pageTitleText.isVisible = false
	
	-- create text at bottom of screen
	continueText = display.newText( group, "[ Tap screen to continue ]", 0, 0, native.systemFont, 18 )
	continueText:setReferencePoint( display.CenterReferencePoint )
	continueText.x = display.contentWidth * 0.5
	continueText.y = display.contentHeight - (display.contentHeight * 0.04 )
	continueText.isVisible = false
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	animStep = 1
	readyToContinue = true
	showNext()
	
	-- assign touch event to background to monitor page swiping
	background.touch = onBackgroundTouch -- sending event to backgroundTouch
	background:addEventListener( "touch", background )
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	pageTitleText.isVisible = false
	
	-- remove touch event listener for background
	background:removeEventListener( "touch", background )
	
	-- cancel page animations (if currently active)
	if pageTween then transition.cancel( pageTween ); pageTween = nil; end
	if fadeTween1 then transition.cancel( fadeTween1 ); fadeTween1 = nil; end
	if fadeTween2 then transition.cancel( fadeTween2 ); fadeTween2 = nil; end
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. remove listeners, remove widgets, save state variables, etc.)
	
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene
