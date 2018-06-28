math.randomseed(os.time())

function Menu:Load()
	self:InitVars()
	self:UpdateBackground()
	self:Update()
end

function Menu:InitVars()
	-- Background Config
	self.backgroundSwitchStart = 10000 -- Time in ms until background switch
	self.backgroundSwitchTime = 2000 -- Fade-out time in ms
	-- JC2MP Logo
	self.logoMargin = 30 -- Top margin of logo
	self.logoWidth = 450 -- Width of logo
	self.logoHeight = 90 -- Height of logo
	-- Sidebar Config
	self.sidebarPadding = 20 -- Padding of sidebar
	self.sidebarExtraSpacing = 5 -- Extra space to the right of menu
	-- Icons Config
	self.iconMargin = 20 -- Right margin of an icon
	self.iconFontSize = 35 -- Font size of an icon
	self.iconSmallFontSize = 20 -- Font size of an icon
	-- Featured Widget Config
	self.featuredFrameMargin = 8 -- Bottom margin of image frame
	self.featuredNameFontSize = 20 -- Font size of featured server name
	self.featuredNameMargin = 2 -- Bottom margin of server name text
	self.featuredCountFontSize = 20 -- Font size of featured server name
	self.featuredCountMargin = 5 -- Bottom margin of player count text
	self.featuredLineSpacing = 4 -- Horizontal spacing in player count row
	self.featuredDescriptionFontSize = 14 -- Font size of featured server description
	self.featuredDescriptionLineMargin = 3 -- Bottom margin of description text line
	self.featuredDescriptionMaxLines = 4 -- Max amount of description lines
	self.featuredDescriptionExtraMargin = 10 -- Padding after last line of featured server description
	self.featuredSwitchInterval = 15000 -- Time in ms between featured server switches
	self.featuredSwitchAlphaStep = 0.05 -- Alpha changing step
	self.featuredViewAllFontSize = 14 -- Font size of view all button in Featured widget
	-- Favorites Widget Config
	self.favoriteMargin = 4 -- Margin between server name and player count
	self.favoriteNameFontSize = self.featuredNameFontSize -- Font size of favorite server name
	self.favoriteCountFontSize = self.featuredCountFontSize -- Font size of favorite server name
	self.favoriteCountExtraMargin = 5 -- Additional bottom margin to player count row
	self.favoriteLineSpacing = self.featuredLineSpacing -- Horizontal spacing in player count row
	self.favoriteViewAllFontSize = self.featuredViewAllFontSize -- Font size of view all button in Favorites widget
	self.favoriteViewAllMargin = 2 -- Top margin of view all button
	-- Menu Config
	self.menuButtonFontSize = 32 -- Font size of a menu button
	self.menuMargin = 25 -- Bottom margin of menu
	self.menuButtonMargin = 10 -- Top margin of a menu button
	-- Server Info Config
	self.infoNameFontSize = self.menuButtonFontSize -- Font size of server name
	self.infoCountFontSize = self.infoNameFontSize - 6
	-- Main Menu Buttons
	self.mainMenuButtons =
	{
		{"Quick Connect", Menu.QuickConnect},
		{"Server Browser", Menu.ServerBrowser},
		{"Achievements", Menu.Achievements},
		{"Settings", Menu.Settings},
		{"Quit", Menu.Quit}
	}
	-- Pause Menu Buttons
	self.pauseMenuButtons = {}
	self.pauseMenuButtons[1] =
	{
		{"Resume", Menu.Resume},
		{"Add to Favorites", Menu.AddToFavorites},
		{"Disconnect", Menu.Disconnect},
		{"Quick Connect", Menu.QuickConnect},
		{"Server Browser", Menu.ServerBrowser},
		{"Achievements", Menu.Achievements},
		{"Settings", Menu.Settings},
		{"Quit", Menu.Quit}
	}
	self.pauseMenuButtons[2] = {}
	for k, v in pairs(self.pauseMenuButtons[1]) do
		self.pauseMenuButtons[2][k] = v
	end
	table.remove(self.pauseMenuButtons[2], 2)
	-- Icons
	self.icons = {}
	self.icons["Friends"] = ""
	-- Fonts
	self.fonts = {}
	self.fonts["Main"] = "YanoneKaffeesatz-Bold.ttf"
	self.fonts["Text"] = "Archivo.ttf"
	self.fonts["Icons"] = "FontAwesome.ttf"
	-- Colors
	self.colors = {}
	self.colors["Overlay"] = Color(0, 0, 0, 150)
	self.colors["Sidebar"] = Color(0, 0, 0, 210)
	self.colors["White"] = Color(250, 250, 250)
	self.colors["Red"] = Color(190, 30, 30)
	self.colors["Orange"] = Color(214, 126, 61)
	self.colors["Blue"] = Color(61, 176, 214)
	self.colors["Gray"] = Color(125, 125, 125)
	self.colors["GrayAlpha"] = Color( 165, 165, 165, 250 )
	self.colors["Alpha"] = Color(255, 255, 255, 100)	
	self.colors["Inactive"] = Color(70, 70, 70, 200)
	self.colors["Frame"] = Color(91, 206, 244, 150)
	self.colors["Green"] = Color(67, 254, 101)
	-- Misc Variables
	self.screenWidth = Render.Width -- Screen width
	self.screenHeight = Render.Height -- Screen height
	self.freeHeight = self.screenHeight -- Available screen height
	self.trimTextAttempts = 1000 -- Amount of attempts to trim server text
	self.backgroundSwitchEnd = self.backgroundSwitchStart + self.backgroundSwitchTime
	self.backgroundSwitchMult = self.backgroundSwitchTime / 1
	self.logo = Menu:CreateImage(AssetLocation.Disk, "logo.png")
	self.logoScreenWidth = 0 -- Recalculated later
	self.sidebarWidth = 255 -- Recalculated later
	self.featuredActiveServer = 1
	self.featuredActiveHistory = {[1] = 1}
	self.featuredSwitchTimer = Timer()
	self.featuredInit = Timer()
	self.sidebarDoublePadding = 2 * self.sidebarPadding
	self.featuredDoubleLineSpacing = 2 * self.featuredLineSpacing
	self.favoriteDoubleLineSpacing = 2 * self.favoriteLineSpacing
	self.hitboxes = {}
	self.initialized = true
end

-- Events
function Menu:Render()
	if not self.initialized then return end
	self.freeHeight = self.screenHeight - (self.sidebarPadding + self.menuMargin + #self:GetMenuItems() * self.menuButtonFullHeight)
	self.hitboxes = {}
	self:RenderBackground()
	self:RenderLogo()
	self:RenderInfo()
	self:RenderSidebar()
	self:RenderMenu()
	self:RenderFeatured()
	self:RenderFavorites()
end

function Menu:MouseMove(args)
	if not self.initialized then return end
	self.hitboxAction = nil
	self.hitboxArgs = nil
	local mouse = args.position
	for _, hitbox in pairs(self.hitboxes) do
		if (mouse.x >= hitbox.x1 and mouse.x <= hitbox.x2) and (mouse.y >= hitbox.y1 and mouse.y <= hitbox.y2) then
			self.hitboxAction = hitbox.action
			self.hitboxArgs = hitbox.args
			Mouse:SetCursor(CursorType.Hand)
		end
	end
	if self.featuredCurrentFullHeight then
		self.featuredMouseNearby = (mouse.x > self.sidebar.x and mouse.y < self.featuredCurrentFullHeight)
	end
	if self.hitboxAction then return end
	Mouse:SetCursor(CursorType.Arrow)
end

function Menu:MouseDown(args)
	if not self.hitboxAction then return end
	if self.hitboxArgs then
		self.hitboxAction(self, self.hitboxArgs)
		return
	end
	self.hitboxAction(self)
end

function Menu:FeaturedServersUpdate()
	table.sortrandom(FeaturedServers)
	self.featuredInit:Restart()
	if not self.initialized then return end
	self:UpdateTrim()
end

function Menu:FavoriteServersUpdate()
	if not self.initialized then return end
	self:UpdateTrim()
end

function Menu:ResolutionChange(args)
	if not self.initialized then return end
	self.screenWidth = args.size.x
	self.screenHeight = args.size.y
	self:Update()
	self:ResizeBackground()
end

function Menu:SettingsChange()
	if not self.initialized then return end
	self:Update()
end

-- Methods
function Menu:Update()
	self:UpdateLogo()
	self:UpdateIcons()
	self:UpdateSidebar()
	self:UpdateMenu()
	self:UpdateTrim()
	self:UpdateFeatured()
	self:UpdateFavorites()
end

function Menu:UpdateBackground()
	self.backgroundCount = #Backgrounds
	if self.backgroundCount < 1 then return end
	self.background = Backgrounds[math.random(self.backgroundCount)]
	self:ResizeBackground()
end

function Menu:UpdateLogo()
	if not self.logo then return end
	self.logo:SetPosition(Vector2(((self.screenWidth - self.sidebarWidth) / 15 - self.logoWidth / 15), self.logoMargin))
	self.logo:SetSize(Vector2(self.logoWidth, self.logoHeight))
end

function Menu:UpdateIcons()
	Render:SetFont(AssetLocation.Disk, self.fonts["Icons"])
	local height = Render:GetTextHeight(self.icons["Friends"], self.iconFontSize)
	self.iconWidth = height - 2 -- Width of an icon
	self.iconHeight = self.iconWidth -- Height of an icon
	self.smallIconWidth = self.iconWidth / 2 - 1 -- Width of friend icon
	self.smallIconHeight = self.smallIconWidth -- Height of friend icon
	self.iconFullWidth = self.iconWidth + self.iconMargin
	Render:ResetFont()
end

function Menu:UpdateSidebar()
	local maxWidth = 0
	Render:SetFont(AssetLocation.Disk, self.fonts["Main"])
	for _, item in pairs(self:GetMenuItems()) do
		maxWidth = math.max(maxWidth, Render:GetTextWidth(item[1], self.menuButtonFontSize))
	end
	self.menuIconMargin = maxWidth + self.sidebarExtraSpacing + self.sidebarPadding
	self.sidebarWidth = self.sidebarDoublePadding + self.iconFullWidth + maxWidth + self.sidebarExtraSpacing
	self.logoScreenWidth = self.logoWidth + self.sidebarDoublePadding + self.sidebarWidth
	self.sidebarContentWidth = self.sidebarWidth - self.sidebarDoublePadding
	Render:ResetFont()
end

function Menu:UpdateMenu()
	Render:SetFont(AssetLocation.Disk, self.fonts["Main"])
	local height = Render:GetTextHeight("A", self.menuButtonFontSize)
	self.menuButtonHeight = height -- Height of a menu button
	self.menuButtonVerticalAlign = height * 0.15
	self.menuButtonFullHeight = self.menuButtonHeight  + self.menuButtonMargin
	self.infoNameFullHeight = 0.9 * self.menuButtonFullHeight -- Height and bottom margin of server name
	Render:ResetFont()
end

function Menu:UpdateTrim()
	if not self.sidebarContentWidth then return end
	for i, featured in pairs(FeaturedServers) do
		FeaturedServers[i].trimmedName = self:TrimText(featured.name, self.featuredNameFontSize, self.sidebarContentWidth, "Main")
		FeaturedServers[i].trimmedDescription = self:TrimDescription(featured.description, self.featuredDescriptionFontSize, self.sidebarContentWidth, self.featuredDescriptionMaxLines)
	end
	for i, favorite in pairs(FavoriteServers) do
		FavoriteServers[i].trimmedName = self:TrimText(favorite.name, self.favoriteNameFontSize, self.sidebarContentWidth, "Main")
	end
	Render:ResetFont()
end

function Menu:UpdateFeatured()
	self.featuredImageWidth = self.sidebarContentWidth -- Width of the image
	self.featuredImageHeight = self.featuredImageWidth * 0.56 -- Height of the image
	self.featuredFrameWidth = self.featuredImageWidth + 2 -- Width of the image frame
	self.featuredFrameHeight = self.featuredImageHeight + 2 -- Height of the image frame
	Render:SetFont(AssetLocation.Disk, self.fonts["Main"])
	local height = Render:GetTextHeight("A", self.featuredNameFontSize)
	self.featuredNameFullHeight = height + self.featuredNameMargin -- Height and bottom margin of server name
	self.featuredDescScreenHeight = 800 * (height / self.featuredNameFontSize) -- Min screen height to always use full variant of Featured widget
	height = Render:GetTextHeight("A", self.featuredCountFontSize)
	self.featuredCountFullHeight = height + self.featuredCountMargin -- Height and bottom margin of player count
	height = Render:GetTextHeight("A", self.featuredDescriptionFontSize)
	self.featuredIconVerticalAlign = height * 0.05
	self.featuredDescriptionLineFullHeight = height + self.featuredDescriptionLineMargin -- Height and bottom margin of server description
	self.featuredNavCircleRadius = self.iconSmallFontSize / 2.6 -- Radius of item circle in navigation
	self.featuredDoubledNavCircleRadius = 2* self.featuredNavCircleRadius
	self.featuredNavCircleSpacing = self.featuredNavCircleRadius + 12 -- Horizontal spacing betwen navigation item circles
	Render:SetFont(AssetLocation.Disk, self.fonts["Text"])
	local width = Render:GetTextHeight("View all", self.featuredViewAllFontSize) + self.featuredNavCircleSpacing + 15
	self.featuredNavCircleAmount = math.floor((self.sidebarContentWidth - width) / self.featuredNavCircleSpacing) -- Amount of item circles in navigation
	height = Render:GetTextHeight("A", self.featuredViewAllFontSize)
	self.featuredViewAllVerticalAlign = height * 0.51
	self.featuredFrameFullHeight = self.featuredFrameHeight + self.featuredFrameMargin
	self.featuredDescriptionFullHeight = self.featuredDescriptionMaxLines * self.featuredDescriptionLineFullHeight + self.featuredDescriptionExtraMargin
	self.featuredNoDescFullHeight = self.featuredFrameFullHeight + self.featuredNameFullHeight + self.featuredCountFullHeight + self.sidebarDoublePadding
	self.featuredDescFullHeight = self.featuredNoDescFullHeight + self.featuredDescriptionFullHeight
	Render:ResetFont()
end

function Menu:UpdateFavorites()
	self.favoriteNameFullHeight = self.featuredNameFullHeight -- Height and bottom margin of server name
	self.favoriteCountFullHeight = self.featuredCountFullHeight + self.favoriteCountExtraMargin -- Height and bottom margin of player count
	self.favoriteIconVerticalAlign = self.featuredIconVerticalAlign
	Render:SetFont(AssetLocation.Disk, self.fonts["Text"])
	height = Render:GetTextHeight("A", self.favoriteViewAllFontSize)
	self.favoriteViewAllFullHeight = height + self.favoriteViewAllMargin -- Height and bottom margin of view all button under last favorite server
	self.favoriteServerFullHeight = self.favoriteNameFullHeight + self.favoriteCountFullHeight
	Render:ResetFont()
end

function Menu:RenderBackground()
	if self:InGame() then
		Render:FillArea(Vector2.Zero, Render.Size, self.colors["Overlay"])

		local message1 = os.date("%H:%M:%S")

		local time1 = os.date("%d/%m/%Y")

		local position = Vector2( 20, Render.Height * 0.46 )
		local text = tostring(message1)
		local textTw = tostring(time1)

		local text_width = Render:GetTextWidth(text)
		Render:SetFont(AssetLocation.Disk, self.fonts["Text"])

		Render:DrawText( position, text, self.colors["White"], 24 )

		local height = Render:GetTextHeight("A") * 1.5
		position.y = position.y + height
		Render:DrawText( position, textTw, self.colors["GrayAlpha"], 16 )
		return
	end
	if not self.background then return end
	if not self.backgroundTimersInitialized then
		self.backgroundTimer = Timer()
		self.backgroundMoveTimer = Timer()
		self.backgroundTimersInitialized = true
	end
	local position = self.background:GetPosition() + 0.05 * Vector2(-1 + 2 * math.sin(self.backgroundMoveTimer:GetMilliseconds() / self.backgroundSwitchStart), 0)
	position.x = math.min(position.x, 0)
	self.background:SetPosition(position)
	self.background:Draw()
	if self.backgroundTimer:GetMilliseconds() < self.backgroundSwitchStart then return end
	if not self.backgroundSwitching then
		self.backgroundSwitching = true
		self.previousBackground = self.background
		self.backgroundMoveTimer:Restart()
		repeat
			self.background = Backgrounds[math.random(self.backgroundCount)]
		until
			self.backgroundCount < 2 or self.background ~= self.previousBackground
		self:ResizeBackground()
	end
	local alpha = math.clamp(1 - (self.backgroundTimer:GetMilliseconds() - self.backgroundSwitchStart) / self.backgroundSwitchMult, 0, 1)
	local previousPos = self.previousBackground:GetPosition() + 0.05 * Vector2(-1 + 2 * math.sin(self.backgroundTimer:GetMilliseconds() / self.backgroundSwitchStart), 0)
	previousPos.x = math.min(previousPos.x, 0)
	self.previousBackground:SetPosition(previousPos)
	self.previousBackground:SetAlpha(alpha)
	self.previousBackground:Draw()
	if self.backgroundTimer:GetMilliseconds() < self.backgroundSwitchEnd then return end
	self.backgroundTimer:Restart()
	self.backgroundSwitching = false
end

function Menu:RenderLogo()
	if self:InGame() then return end
	if not self.logo then return end
	if self.screenWidth < self.logoScreenWidth then return end
	self.logo:Draw()
	Render:DrawText( Vector2( (15), (Render.Height - 25) ), "Metro Interface by Hallkezz v3", self.colors["Alpha"], 14 )
end

function Menu:RenderInfo()
	if not self:InGame() then return end
	if not CurrentServer then return end
	local current = CurrentServer
	Render:SetFont(AssetLocation.Disk, self.fonts["Main"])
	Render:DrawText(Vector2.Zero + Vector2(self.sidebarPadding, self.sidebarPadding), current.name or "Server", self.colors["White"], self.infoNameFontSize)
	Render:DrawText(Vector2.Zero + Vector2(self.sidebarPadding, self.sidebarPadding + self.infoNameFullHeight), "Players Online: ", self.colors["Blue"], self.infoCountFontSize)
	local width = Render:GetTextWidth("Players Online: ", self.infoCountFontSize)
	local players = tostring(current.players or 1)
	Render:DrawText(Vector2.Zero + Vector2(self.sidebarPadding + width, self.sidebarPadding + self.infoNameFullHeight), players, self.colors["White"], self.infoCountFontSize)
end

function Menu:RenderSidebar()
	self.sidebar = Vector2(self.screenWidth - self.sidebarWidth, 0)
	Render:FillArea(self.sidebar, Vector2(self.sidebarWidth, self.screenWidth), self.colors["Sidebar"])
	self.sidebar = self.sidebar + Vector2(self.sidebarPadding, self.sidebarPadding)
end

function Menu:RenderMenu()
	local textOffset = self.sidebar + Vector2(0, self.screenHeight - self.sidebarPadding - self.menuButtonHeight - self.menuMargin + self.menuButtonVerticalAlign)
	local mouse = Mouse:GetPosition()
	local items = self:GetMenuItems()
	Render:SetFont(AssetLocation.Disk, self.fonts["Main"])
	for i in pairs(items) do
		local color = self.colors["White"]
		local size = Render:GetTextSize(items[#items - i + 1][1], self.menuButtonFontSize)
		if (mouse.x >= textOffset.x and mouse.x <= textOffset.x + size.x) and
			(mouse.y >= textOffset.y and mouse.y <= textOffset.y + size.y) then
			color = self.colors["Gray"]
		end
		Render:DrawText(textOffset, items[#items - i + 1][1], color, self.menuButtonFontSize)
		self:AddHitbox(textOffset, size, items[#items - i + 1][2])
		textOffset.y = textOffset.y - self.menuButtonFullHeight
	end
end

function Menu:RenderFeatured()
	if self.featuredInit:GetSeconds() < 1 then return false end
	if #FeaturedServers == 0 then return false end
	local drawDescription = false
	-- If no servers in favorites or screen height is high enough to show description
	if #FavoriteServers == 0 or self.screenHeight > self.featuredDescScreenHeight then
		-- If enough space to display featured servers with description
		if self.featuredDescFullHeight < self.freeHeight then
			drawDescription = true
		elseif self.featuredNoDescFullHeight > self.freeHeight then
			-- Not enough space to display even description-less version
			 return false
		end
	else
		-- If there are servers in favorites but not enough space to show featured servers along with a single favorite server
		if #FavoriteServers ~= 0 and (self.featuredNoDescFullHeight + self.favoriteServerFullHeight + self.favoriteViewAllFullHeight) > self.freeHeight then return false end
	end
	local featured = FeaturedServers[self.featuredActiveServer]
	local iconOffset = Copy(self.sidebar)
	self.contentOffset = Copy(iconOffset)
	self.contentOffset.x = self.contentOffset.x + 1
	Render:FillArea(self.contentOffset - Vector2.One, Vector2(self.featuredFrameWidth, self.featuredFrameHeight), self.colors["Frame"])
	featured.image:Draw(self.contentOffset, Vector2(self.featuredImageWidth, self.featuredImageHeight), Vector2.Zero, Vector2.One)
	self.contentOffset.x = self.contentOffset.x - 1
	self:AddHitbox(self.contentOffset, Vector2(self.featuredImageWidth, self.featuredImageHeight), Menu.JoinServer, featured.ip)
	self.contentOffset.y = self.contentOffset.y + self.featuredFrameFullHeight
	local serverName = featured.trimmedName
	Render:SetFont(AssetLocation.Disk, self.fonts["Main"])
	Render:DrawText(self.contentOffset, serverName, self.colors["Blue"], self.featuredNameFontSize)
	self:AddHitbox(self.contentOffset, Render:GetTextSize(serverName, self.featuredNameFontSize), Menu.JoinServer, featured.ip)
	self.contentOffset.y = self.contentOffset.y + self.featuredNameFullHeight
	local playerCount = featured.players
	Render:DrawText(self.contentOffset, playerCount, self.colors["White"], self.featuredCountFontSize)
	if featured.friends > 0 then
		local lineOffset = self.contentOffset + Vector2(Render:GetTextWidth(playerCount, self.featuredCountFontSize) + self.featuredDoubleLineSpacing, 0)
		Render:SetFont(AssetLocation.Disk, self.fonts["Icons"])
		Render:DrawText(lineOffset - Vector2(0, self.featuredIconVerticalAlign), self.icons["Friends"], self.colors["White"], self.iconSmallFontSize)
		lineOffset.x = lineOffset.x + self.smallIconWidth + self.featuredLineSpacing
		local friendCount = tostring(featured.friends)
		Render:SetFont(AssetLocation.Disk, self.fonts["Main"])
		Render:DrawText(lineOffset, friendCount, self.colors["White"], self.featuredCountFontSize)
	end
	self.contentOffset.y = self.contentOffset.y + self.featuredCountFullHeight
	if drawDescription then
		Render:SetFont(AssetLocation.Disk, self.fonts["Text"])
		local descriptionOffset = Copy(self.contentOffset)
		for _, descriptionLine in pairs(featured.trimmedDescription) do
			Render:DrawText(descriptionOffset, descriptionLine, self.colors["White"], self.featuredDescriptionFontSize)
			descriptionOffset.y = descriptionOffset.y + self.featuredDescriptionLineFullHeight
		end
		self.contentOffset.y = self.contentOffset.y + self.featuredDescriptionFullHeight
		self.freeHeight = self.freeHeight - self.featuredDescFullHeight
		self.featuredCurrentFullHeight = self.featuredDescFullHeight
		Render:SetFont(AssetLocation.Disk, self.fonts["Main"])
	else
		self.freeHeight = self.freeHeight - self.featuredNoDescFullHeight
		self.featuredCurrentFullHeight = self.featuredNoDescFullHeight
	end
	lineOffset = self.contentOffset + Vector2(self.featuredNavCircleRadius, self.featuredNavCircleRadius)
	local size = Vector2(self.featuredDoubledNavCircleRadius, self.featuredDoubledNavCircleRadius)
	local displayedCount = math.min(#FeaturedServers, self.featuredNavCircleAmount)
	for i = 1, displayedCount do
		local color = self.colors["Inactive"]
		if i == self.featuredActiveServer and (self.featuredActiveHistory[i] or 0) < 1 then
			self.featuredActiveHistory[i] = (self.featuredActiveHistory[i] or 0) + self.featuredSwitchAlphaStep
		end
		if (self.featuredActiveHistory[i] or 0) > 0 then
			color = math.lerp(self.colors["Inactive"], self.colors["Blue"], self.featuredActiveHistory[i])
			if i ~= self.featuredActiveServer then
				self.featuredActiveHistory[i] = self.featuredActiveHistory[i] - self.featuredSwitchAlphaStep
			end
		end
		Render:FillCircle(lineOffset, self.featuredNavCircleRadius, color)
		self:AddHitbox(lineOffset - Vector2(self.featuredNavCircleRadius, self.featuredNavCircleRadius), size, Menu.FeaturedSelect, i)
		lineOffset.x = lineOffset.x + self.featuredNavCircleSpacing
	end
	lineOffset.y = lineOffset.y - self.featuredViewAllVerticalAlign
	Render:SetFont(AssetLocation.Disk, self.fonts["Text"])
	Render:DrawText(lineOffset, "View all", self.colors["Blue"], self.featuredViewAllFontSize)
	self:AddHitbox(lineOffset, Render:GetTextSize("View all", self.featuredViewAllFontSize), Menu.ServerBrowser, ServerBrowserPage.Featured)
	self.contentOffset.y = self.contentOffset.y + self.sidebarDoublePadding
	if self.featuredMouseNearby then self.featuredSwitchTimer:Restart() end
	if self.featuredSwitchTimer:GetMilliseconds() < self.featuredSwitchInterval then return end
	self.featuredSwitchTimer:Restart()
	self.featuredActiveServer = self.featuredActiveServer % displayedCount + 1
end

function Menu:RenderFavorites()
	if #FavoriteServers == 0 then return false end
	-- If there's not enough space even for a single server
	if (self.favoriteServerFullHeight + self.favoriteViewAllFullHeight) > self.freeHeight then return false end
	self.freeHeight = self.freeHeight - self.favoriteViewAllFullHeight
	-- Determine amount of favorite servers that should be displayed
	local displayedCount = math.min(#FavoriteServers, math.floor(self.freeHeight / self.favoriteServerFullHeight))
	self.contentOffset = self.contentOffset or Copy(self.sidebar)
	for i = 1, displayedCount do
		local favorite = FavoriteServers[i]
		local iconOffset = Copy(self.contentOffset)
		local serverName = favorite.trimmedName
		Render:SetFont(AssetLocation.Disk, self.fonts["Main"])
		Render:DrawText(self.contentOffset - Vector2(0, self.favoriteMargin), serverName, self.colors["Green"], self.favoriteNameFontSize)
		self:AddHitbox(self.contentOffset, Render:GetTextSize(serverName, self.favoriteNameFontSize), Menu.JoinServer, favorite.ip)
		self.contentOffset.y = self.contentOffset.y + self.favoriteNameFullHeight - self.favoriteMargin
		local playerCount = favorite.players
		Render:DrawText(self.contentOffset, playerCount, self.colors["White"], self.favoriteCountFontSize)
		if favorite.friends > 0 then
			local lineOffset = self.contentOffset + Vector2(Render:GetTextWidth(playerCount, self.favoriteCountFontSize) + self.favoriteDoubleLineSpacing, 0)
			Render:SetFont(AssetLocation.Disk, self.fonts["Icons"])
			Render:DrawText(lineOffset - Vector2(0, self.favoriteIconVerticalAlign), self.icons["Friends"], self.colors["White"], self.iconSmallFontSize)
			lineOffset.x = lineOffset.x + self.smallIconWidth + self.favoriteLineSpacing
			local friendCount = tostring(favorite.friends)
			Render:SetFont(AssetLocation.Disk, self.fonts["Main"])
			Render:DrawText(lineOffset, friendCount, self.colors["White"], self.favoriteCountFontSize)
		end
		self.contentOffset.y = self.contentOffset.y + self.favoriteCountFullHeight + self.favoriteMargin
		self.freeHeight = self.freeHeight - self.favoriteServerFullHeight
	end
	self.contentOffset.y = self.contentOffset.y + self.favoriteViewAllMargin
	Render:SetFont(AssetLocation.Disk, self.fonts["Text"])
	Render:DrawText(self.contentOffset, "View all", self.colors["Orange"], self.favoriteViewAllFontSize)
	self:AddHitbox(self.contentOffset, Render:GetTextSize("View all", self.favoriteViewAllFontSize), Menu.ServerBrowser, ServerBrowserPage.Favorites)
	self.contentOffset = nil
end

function Menu:GetMenuItems()
	if self:InGame() then
		if not self:GetServerFavorited() then
			return self.pauseMenuButtons[1]
		else
			return self.pauseMenuButtons[2]
		end
	else
		return self.mainMenuButtons
	end
end

function Menu:ResizeBackground()
	if not self.background then return end
	local pixelSize = self.background:GetPixelSize()
	local sizeRatio = pixelSize.x / pixelSize.y
	local alteredWidth = self.screenWidth + 20
	local screenRatio = alteredWidth / self.screenHeight
	local backgroundWidth = alteredWidth
	local backgroundHeight = self.screenHeight
	if screenRatio < sizeRatio then
		backgroundWidth = sizeRatio * self.screenHeight
	elseif screenRatio > sizeRatio then
		backgroundHeight = (1 / sizeRatio) * alteredWidth
	end
	self.background:SetPosition(Vector2.Zero)
	self.background:SetSize(Vector2(backgroundWidth, backgroundHeight))
	self.background:SetAlpha(1)
end

function Menu:AddHitbox(position, size, action, args)
	table.insert(self.hitboxes, {["x1"] = position.x, ["x2"] = position.x + size.x, ["y1"] = position.y, ["y2"] = position.y + size.y, ["action"] = action, ["args"] = args})
end

function Menu:FeaturedSelect(selected)
	self.featuredActiveServer = selected
end

function Menu:TrimText(text, fontSize, maxWidth, fontName)
	Render:SetFont(AssetLocation.Disk, self.fonts[fontName])
	local textWidth = Render:GetTextWidth(text, fontSize)
	local attempts = self.trimTextAttempts
	if textWidth > maxWidth then maxWidth = maxWidth - Render:GetTextWidth("...", fontSize) end
	while textWidth > maxWidth and attempts > 0 do
		text = text:sub(1, -2)
		textWidth = Render:GetTextWidth(text, fontSize)
		attempts = attempts - 1
	end
	if attempts ~= self.trimTextAttempts then text = text .. "..." end
	return text
end

function Menu:TrimDescription(text, fontSize, lineWidth, lineCount)
	local words = text:split(" ")
	local currentLine = 1
	local freeWidth = lineWidth
	Render:SetFont(AssetLocation.Disk, self.fonts["Text"])
	local spaceWidth = Render:GetTextWidth(" ", fontSize)
	local description = {}
	for _, word in pairs(words) do
		local wordWidth = Render:GetTextWidth(word, fontSize)
		if wordWidth > lineWidth then
			table.insert(description, self:TrimText(word, fontSize, lineWidth, "Text"))
			return description
		end
		if wordWidth >= freeWidth and currentLine < lineCount then
			currentLine = currentLine + 1
			freeWidth = lineWidth
		end
		if not description[currentLine] then
			description[currentLine] = word
		else
			description[currentLine] = description[currentLine] .. " " .. word
			freeWidth = freeWidth - spaceWidth
		end
		freeWidth = freeWidth - wordWidth
	end
	if description[lineCount] then
		description[lineCount] = self:TrimText(description[lineCount], fontSize, lineWidth, "Text")
	end
	return description
end

table.sortrandom = function(t)
	local randomIndex
	for index = #t , 2 , -1 do
		randomIndex = math.random(index)
		t[index] , t[randomIndex] = t[randomIndex] , t[index]
	end
end
