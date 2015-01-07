
---- VGUI panel version of the scoreboard, based on TEAM GARRY's sandbox mode
---- scoreboard.

local surface = surface
local draw = draw
local math = math
local string = string
local vgui = vgui

local inputColor = {255, 0, 0}

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation

local showStaff = false
local showWebpage = false
local notYetMoved = true

include("sb_team.lua")

surface.CreateFont("cool_small", {font = "coolvetica",
                                  size = 20,
                                  weight = 400})
surface.CreateFont("cool_large", {font = "coolvetica",
                                  size = 24,
                                  weight = 400})
surface.CreateFont("treb_small", {font = "Trebuchet18",
                                  size = 14,
                                  weight = 700})
surface.CreateFont("BFSB16",   {font = "BFHud SemiBold",
                                    size = 16,
                                    weight = 50})
surface.CreateFont("BFSB20",   {font = "BFHud SemiBold",
                                    size = 20,
                                    weight = 10})
surface.CreateFont("BFSB22",   {font = "BFHud SemiBold",
                                    size = 22,
                                    weight = 10})
surface.CreateFont("BFSB24",   {font = "BFHud SemiBold",
                                    size = 24,
                                    weight = 10})
surface.CreateFont("BFSB84",   {font = "BFHud SemiBold",
                                    size = 84,
                                    weight = 750})

local logo = surface.GetTextureID("VGUI/ttt/score_logo")

local PANEL = {}

local max = math.max
local floor = math.floor
local function UntilMapChange()
   local rounds_left = max(0, GetGlobalInt("ttt_rounds_left", 6))
   local time_left = floor(max(0, ((GetGlobalInt("ttt_time_limit_minutes") or 60) * 60) - CurTime()))

   local h = floor(time_left / 3600)
   time_left = time_left - floor(h * 3600)
   local m = floor(time_left / 60)
   time_left = time_left - floor(m * 60)
   local s = floor(time_left)

   return rounds_left, string.format("%02i:%02i:%02i", h, m, s)
end


GROUP_TERROR = 1
GROUP_NOTFOUND = 2
GROUP_FOUND = 3
GROUP_SPEC = 4

GROUP_COUNT = 4

function ScoreGroup(p)
   if not IsValid(p) then return -1 end -- will not match any group panel

   if DetectiveMode() then
      if p:IsSpec() and (not p:Alive()) then
         if p:GetNWBool("body_found", false) then
            return GROUP_FOUND
         else
            local client = LocalPlayer()
            -- To terrorists, missing players show as alive
            if client:IsSpec() or
               client:IsActiveTraitor() or
               ((GAMEMODE.round_state != ROUND_ACTIVE) and client:IsTerror()) then
               return GROUP_NOTFOUND
            else
               return GROUP_TERROR
            end
         end
      end
   end

   return p:IsTerror() and GROUP_TERROR or GROUP_SPEC
end

function PANEL:Init()

   self.hostname = vgui.Create( "DLabel", self )
   self.hostname:SetText( GetHostName() )
   self.hostname:SetContentAlignment(5)

   self.totalTime = vgui.Create( "DLabel", self )
   self.totalTime:SetText( string.upper(game.GetMap().." - Total Time: 00:00 - Trouble in Terrorist Town" ) )
   self.totalTime:SetContentAlignment(5)

   self.mapchange = vgui.Create("DLabel", self)
   self.mapchange:SetText(string.upper("Map changes in 00 rounds or in 00:00:00"))
   self.mapchange:SetContentAlignment(5)

   self.mapchange.Think = function (sf)
      local r, t = UntilMapChange()

      sf:SetText(string.upper(GetPTranslation("sb_mapchange",
                                {num = r, time = t})))
      sf:SizeToContents()
   end       

   self.ply_frame = vgui.Create( "TTTPlayerFrame", self )

   self.ply_groups = {}

   local t = vgui.Create("TTTScoreGroup", self.ply_frame:GetCanvas())
   t:SetGroupInfo(GetTranslation("terrorists"), bfscoreboard.terroristsBGColor, GROUP_TERROR)
   self.ply_groups[GROUP_TERROR] = t

   t = vgui.Create("TTTScoreGroup", self.ply_frame:GetCanvas())
   t:SetGroupInfo(GetTranslation("spectators"), bfscoreboard.spectatorsBGColor, GROUP_SPEC)
   self.ply_groups[GROUP_SPEC] = t

   if DetectiveMode() then
      t = vgui.Create("TTTScoreGroup", self.ply_frame:GetCanvas())
      t:SetGroupInfo(GetTranslation("sb_mia"), bfscoreboard.missingBGColor, GROUP_NOTFOUND)
      self.ply_groups[GROUP_NOTFOUND] = t

      t = vgui.Create("TTTScoreGroup", self.ply_frame:GetCanvas())
      t:SetGroupInfo(GetTranslation("sb_confirmed"), bfscoreboard.confirmedBGColor, GROUP_FOUND)
      self.ply_groups[GROUP_FOUND] = t
   end

   -- Buttons
   self.pointShopButton = vgui.Create( "DButton", self)
   self.pointShopButton:SetText( "" )
   self.pointShopButton.DoClick = function()
       RunConsoleCommand("ps_shop", "1");
   end

   self.websiteButton = vgui.Create( "DButton", self)
   self.websiteButton:SetText( "" )
   self.websiteButton.DoClick = function()
      if showWebpage then
         print(showWebpageDRecent)
         if not showWebpageDRecent then
            showWebpage = false
            notYetMoved = true
         else
            self.webBrowser:OpenURL(bfscoreboard.websiteURL)
            showWebpageDRecent = false
         end
      else
         showWebpage = true
         notYetMoved = true
         showWebpageWRecent = true
         self.webBrowser:OpenURL(bfscoreboard.websiteURL)
      end
   end

   self.donateButton = vgui.Create( "DButton", self)
   self.donateButton:SetText( "" )
   self.donateButton.DoClick = function()
      if showWebpage then
         if not showWebpageWRecent then
            showWebpage = false
            notYetMoved = true
         else
            self.webBrowser:OpenURL(bfscoreboard.donateURL)
            showWebpageWRecent = false
         end
      else
         showWebpage = true
         notYetMoved = true
         showWebpageDRecent = true
         self.webBrowser:OpenURL(bfscoreboard.donateURL)
      end
   end

   self.staffButton = vgui.Create( "DButton", self)
   self.staffButton:SetText( "" )
   self.staffButton.DoClick = function()
      if showStaff then
         showStaff = false
         notYetMoved = true
      else
         showStaff = true
         notYetMoved = true
      end
   end

   if bfscoreboard.serverImageEnabled then
      self.serverImage = vgui.Create( "DImageButton", self )
      self.serverImage.DoClick = function()
         showWebpage = false
         notYetMoved = true
      end
   end

   -- Staff Panel
   self.staffFrame = vgui.Create( "DFrame", self )
   self.staffFrame:SetVisible( false )
   self.staffList = vgui.Create("DListView")
   self.staffList:SetParent(self.staffFrame)
   self.staffList:SetSortable( true )
   self.staffListNameCol = self.staffList:AddColumn("Player Name")
   self.staffListSteamIDCol = self.staffList:AddColumn("SteamID")
   self.staffListRankCol = self.staffList:AddColumn("Rank")
   self.staffListStatusCol = self.staffList:AddColumn("Status")

   self.staffListSteamIDCol:SetMaxWidth(150)
   self.staffListRankCol:SetMaxWidth(80)
   self.staffListStatusCol:SetFixedWidth(50)
   for k, ply in ipairs( player.GetAll() ) do
      for k, v in pairs(bfscoreboard.ulxGroups) do
         if ply:IsUserGroup( v[1] ) then
            if v[4] then
               currentLine = self.staffList:AddLine(ply:Nick(), ply:SteamID(), v[2], "ONLINE")

               currentLine.Columns[1]:SetTextColor( Color(245, 245, 255) )
               currentLine.Columns[1]:SetFont( 'BFSB16' )

               currentLine.Columns[2]:SetTextColor( Color(245, 245, 255) )
               currentLine.Columns[2]:SetFont( 'BFSB16' )

               currentLine.Columns[3]:SetTextColor( Color(245, 245, 255) )
               currentLine.Columns[3]:SetFont( 'BFSB16' )

               currentLine.Columns[4]:SetTextColor( Color(100, 255, 100) )
               currentLine.Columns[4]:SetFont( 'BFSB16' )
            end
         end
      end
   end

   -- Open Website
   self.webBrowser = vgui.Create( "HTML", self )
   self.webBrowser:OpenURL( "" )
   self.webBrowser:SetVisible( false )

   self:UpdateScoreboard()
   self:StartUpdateTimer()
end

function PANEL:StartUpdateTimer()
   if not timer.Exists("TTTScoreboardUpdater") then
      timer.Create( "TTTScoreboardUpdater", 0.3, 0,
                    function()
                       local pnl = GAMEMODE:GetScoreboardPanel()
                       if IsValid(pnl) then
                          pnl:UpdateScoreboard()
                       end
                    end)
   end
end

local y_logo_off = 92

function PANEL:Paint()
   draw.RoundedBox( 0, 7, y_logo_off, self:GetWide()-14, y_logo_off, bfscoreboard.titleBGColor)
end

function PANEL:PerformLayout()
   -- position groups and find their total size
   local gy = 0
   if not showWebpage then
      -- can't just use pairs (undefined ordering) or ipairs (group 2 and 3 might not exist)
      for i=1, GROUP_COUNT do
         local group = self.ply_groups[i]
         if ValidPanel(group) then
            if group:HasRows() then
               group:SetVisible(true)
               group:SetPos(0, gy)
               group:SetSize(self.ply_frame:GetWide(), group:GetTall())
               group:InvalidateLayout()
               gy = gy + group:GetTall() + 5
            else
               group:SetVisible(false)
            end
         end
      end
   end

   if not showWebpage then
      self.ply_frame:GetCanvas():SetSize(self.ply_frame:GetCanvas():GetWide(), gy)
   end

   local h = y_logo_off + 110 + self.ply_frame:GetCanvas():GetTall()

   -- if we will have to clamp our height, enable the mouse so player can scroll
   local scrolling = h > ScrH() * 0.95
--   gui.EnableScreenClicker(scrolling)
   self.ply_frame:SetScroll(scrolling)

   h = ScrH() - y_logo_off --math.Clamp(h, 110 + y_logo_off, ScrH() * 0.95)

   local w = math.max(ScrW() * 0.6, 640)

   self:SetSize(w, h)
   self:SetPos( (ScrW() - w) / 2, math.min(72, (ScrH() - h) / 4))

   if showWebpage then
      if notYetMoved then
         self.ply_frame:MoveTo(-self:GetWide(), y_logo_off + 109, 1, 0, 2, function()
            self.ply_frame:SetVisible( false )
            self.webBrowser:SetVisible( true )
            self.webBrowser:SetPos( 8, y_logo_off + 109 )
            self.webBrowser:SetSize( self.ply_frame:GetCanvas():GetWide(), self:GetTall() - 109 - y_logo_off - 5 )
         end)
         notYetMoved = false
      end 
   else
      if notYetMoved then
         self.ply_frame:SetVisible( true )
         self.webBrowser:SetVisible( false )
         self.ply_frame:MoveTo(8, y_logo_off + 109, 1, 0, 2, function()
         end)
         notYetMoved = false
      else
         self.ply_frame:SetPos(8, y_logo_off + 109)
      end
   end
   if not showWebpage then
      self.ply_frame:SetSize(self:GetWide() - 16, self:GetTall() - 109 - y_logo_off - 5)
   end
         
   -- server stuff
   local hw = w - 180 - 8
   self.hostname:SetSize(hw, 150)
   self.hostname:SetPos(0, y_logo_off - 34)
   self.hostname:CenterHorizontal()

   hname = ""
   if bfscoreboard.titleAuto then
      hname = self.hostname:GetValue()
   else
      hname = bfscoreboard.titleName
   end
   local tw, _ = surface.GetTextSize(hname)
   while tw > hw do
      hname = string.sub(hname, 1, -6) .. "..."
      tw, th = surface.GetTextSize(hname)
   end

   self.hostname:SetText(string.upper(hname))

   self.mapchange:SizeToContents()
   self.mapchange:SetPos(w - self.mapchange:GetWide() - 8, y_logo_off)
   self.mapchange:CenterHorizontal()

   self.totalTime:SizeToContents()
   self.totalTime:SetPos(w - self.totalTime:GetWide() - 8, y_logo_off + 68)
   self.totalTime:CenterHorizontal()

   self.pointShopButton:SetSize( 100, 22 )
   self.pointShopButton:SetPos( w - self.pointShopButton:GetWide() - 8, y_logo_off + 70 )

   self.websiteButton:SetSize( 100, 22 )
   self.websiteButton:SetPos( w - self.pointShopButton:GetWide() - 8, y_logo_off - self.pointShopButton:GetTall() + 69 )

   self.donateButton:SetSize( 100, 22 )
   self.donateButton:SetPos( w - self.pointShopButton:GetWide() - 8, y_logo_off - (self.pointShopButton:GetTall()*2) + 68 )

   self.staffButton:SetSize( 100, 22 )
   self.staffButton:SetPos( w - self.pointShopButton:GetWide() - 8, y_logo_off - (self.pointShopButton:GetTall()*3) + 67 )

   if bfscoreboard.serverImageEnabled then
      self.serverImage:SetPos( 9, y_logo_off + 2 )
      self.serverImage:SetSize( y_logo_off - 4, y_logo_off - 4 )
   end

   if showStaff then
      self.staffFrame:SetVisible( true )
      self.staffFrame:SetPos( -self:GetWide()-14, 0 )
      self.staffFrame:MoveTo(7, 0, 500, 0, .1)
      self.staffFrame:SetSize( self:GetWide()-14, y_logo_off-5 )
      self.staffFrame:SetTitle( "" )
      self.staffFrame:ShowCloseButton( false )
      self.staffList:SetPos(180, 0)
      self.staffList:SetSize( (self:GetWide()-14) - 360, y_logo_off-5)
      self.staffList:SetMultiSelect(false)
   else
      self.staffFrame:MoveTo(-self:GetWide()-14, 0, 500, 0, .1, function()
         self.staffFrame:SetVisible( false )
      end)
   end

end

function PANEL:ApplySchemeSettings()
   self.hostname:SetFont("BFSB84")
   self.mapchange:SetFont("BFSB20")
   self.totalTime:SetFont("BFSB20")

   self.hostname:SetTextColor(bfscoreboard.titleColor)
   self.mapchange:SetTextColor(COLOR_WHITE)
   self.totalTime:SetTextColor(COLOR_WHITE)

   self.pointShopButton.Paint = function(slf, w, h)
      surface.SetDrawColor( Color(0, 0, 0, 200) )
      surface.DrawRect(0, 0, w, h)
      surface.SetDrawColor( Color(94, 94, 94, 255) )
      surface.DrawRect(0, 0, w, 1)
      surface.DrawRect(0, h-1, w, 1)
      surface.DrawRect(0, 0, 1, h)
      surface.DrawRect(w-1, 0, 1, h)
      surface.SetTextColor( COLOR_WHITE )
      surface.SetFont("BFSB16")
      surface.SetTextPos( 22, 2 ) 
      surface.DrawText( "POINTSHOP" )
   end
   self.websiteButton.Paint = function(slf, w, h)
      surface.SetDrawColor( Color(0, 0, 0, 200) )
      surface.DrawRect(0, 0, w, h)
      surface.SetDrawColor( Color(94, 94, 94, 255) )
      surface.DrawRect(0, 0, w, 1)
      surface.DrawRect(0, h-1, w, 1)
      surface.DrawRect(0, 0, 1, h)
      surface.DrawRect(w-1, 0, 1, h)
      surface.SetTextColor( COLOR_WHITE )
      surface.SetFont("BFSB16")
      surface.SetTextPos( 27, 2 ) 
      surface.DrawText( "WEBSITE" )
   end

   self.donateButton.Paint = function(slf, w, h)
      surface.SetDrawColor( Color(0, 0, 0, 200) )
      surface.DrawRect(0, 0, w, h)
      surface.SetDrawColor( Color(94, 94, 94, 255) )
      surface.DrawRect(0, 0, w, 1)
      surface.DrawRect(0, h-1, w, 1)
      surface.DrawRect(0, 0, 1, h)
      surface.DrawRect(w-1, 0, 1, h)
      surface.SetTextColor( COLOR_WHITE )
      surface.SetFont("BFSB16")
      surface.SetTextPos( 29, 2 ) 
      surface.DrawText( "DONATE" )
   end

   self.staffButton.Paint = function(slf, w, h)
      surface.SetDrawColor( Color(0, 0, 0, 200) )
      surface.DrawRect(0, 0, w, h)
      surface.SetDrawColor( Color(94, 94, 94, 255) )
      surface.DrawRect(0, 0, w, 1)
      surface.DrawRect(0, h-1, w, 1)
      surface.DrawRect(0, 0, 1, h)
      surface.DrawRect(w-1, 0, 1, h)
      surface.SetTextColor( COLOR_WHITE )
      surface.SetFont("BFSB16")
      surface.SetTextPos( 34, 2 ) 
      surface.DrawText( "STAFF" )
   end

   if bfscoreboard.serverImageEnabled then
      self.serverImage.Paint = function(slf, w, h)
         local serverMaterial = Material( "bfscoreboard/sblogo.png" )
         surface.SetMaterial( serverMaterial )
         surface.SetDrawColor(255, 255, 255, 255)
         surface.DrawTexturedRect(0, 0, w, h)
      end
   end

   self.staffFrame.Paint = function(slf, w, h)
      draw.RoundedBox( 0, 0, 0, self:GetWide()-14, y_logo_off-5, bfscoreboard.titleBGColor)
   end

   self.staffList.VBar.Paint = function( s, w, h )
      surface.SetDrawColor( bfscoreboard.rowBGColor )
      surface.DrawRect( 0, 0, w, h )
   end

   self.staffList.VBar.btnUp.Paint = function( s, w, h ) 
      surface.SetDrawColor( Color(17, 24, 30) )
      surface.DrawRect( 0, 0, w-1, h )
      surface.SetDrawColor( Color(207, 203, 200) )
      surface.DrawRect( 1, 1, w-3, h-2 )
   end

   self.staffList.VBar.btnDown.Paint = function( s, w, h ) 
      surface.SetDrawColor( Color(17, 24, 30) )
      surface.DrawRect( 0, 0, w-1, h )
      surface.SetDrawColor( Color(207, 203, 200) )
      surface.DrawRect( 1, 1, w-3, h-2 )
   end

   self.staffList.VBar.btnGrip.Paint = function( s, w, h )
      surface.SetDrawColor( Color(17, 24, 30) )
      surface.DrawRect( 0, 0, w-1, h )
      surface.SetDrawColor( Color(207, 203, 200) )
      surface.DrawRect( 1, 1, w-3, h-2 )
   end
   
   self.staffList.Paint = function(self, w, h)
      draw.RoundedBox( 0, 0, 0, w, h,  Color(34, 34, 34, 200) )
   end

   self.staffListNameCol.Header:SetDisabled(true)
   self.staffListNameCol.Header:SetTextColor( Color(255, 255, 255) )
   self.staffListNameCol.Header:SetFont( "BFSB16" )
   self.staffListNameCol.Header.Paint = function(self, w, h)
      draw.RoundedBox( 0, 0, 0, w, h,  Color(0, 0, 0, 245) )
      draw.RoundedBox( 0, 1, 1, w-2, h-2,  Color(34, 34, 34, 255) )
      draw.RoundedBox( 0, 0, 0, w, h/2,  Color(255, 255, 255, 2) )
   end

   self.staffListSteamIDCol.Header:SetDisabled(true)
   self.staffListSteamIDCol.Header:SetTextColor( Color(255, 255, 255) )
   self.staffListSteamIDCol.Header:SetFont( "BFSB16" )
   self.staffListSteamIDCol.Header.Paint = function(self, w, h)
      draw.RoundedBox( 0, 0, 0, w, h,  Color(0, 0, 0, 245) )
      draw.RoundedBox( 0, 1, 1, w-2, h-2,  Color(34, 34, 34, 255) )
      draw.RoundedBox( 0, 0, 0, w, h/2,  Color(255, 255, 255, 2) )
   end

   self.staffListRankCol.Header:SetDisabled(true)
   self.staffListRankCol.Header:SetTextColor( Color(255, 255, 255) )
   self.staffListRankCol.Header:SetFont( "BFSB16" )
   self.staffListRankCol.Header.Paint = function(self, w, h)
      draw.RoundedBox( 0, 0, 0, w, h,  Color(0, 0, 0, 245) )
      draw.RoundedBox( 0, 1, 1, w-2, h-2,  Color(34, 34, 34, 255) )
      draw.RoundedBox( 0, 0, 0, w, h/2,  Color(255, 255, 255, 2) )
   end

   self.staffListStatusCol.Header:SetDisabled(true)
   self.staffListStatusCol.Header:SetTextColor( Color(255, 255, 255) )
   self.staffListStatusCol.Header:SetFont( "BFSB16" )
   self.staffListStatusCol.Header.Paint = function(self, w, h)
      draw.RoundedBox( 0, 0, 0, w, h,  Color(0, 0, 0, 245) )
      draw.RoundedBox( 0, 1, 1, w-2, h-2,  Color(34, 34, 34, 255) )
      draw.RoundedBox( 0, 0, 0, w, h/2,  Color(255, 255, 255, 2) )
   end
end

function PANEL:UpdateScoreboard( force )
   if not force and not self:IsVisible() then return end

   local layout = false

   -- Put players where they belong. Groups will dump them as soon as they don't
   -- anymore.
   for k, p in pairs(player.GetAll()) do
      if IsValid(p) then
         local group = ScoreGroup(p)
         if self.ply_groups[group] and not self.ply_groups[group]:HasPlayerRow(p) then
            self.ply_groups[group]:AddPlayerRow(p)
            layout = true
         end
      end
   end

   for k, group in pairs(self.ply_groups) do
      if ValidPanel(group) then
         group:SetVisible( group:HasRows() )
         group:UpdatePlayerData()
      end
   end

   if layout then
      self:PerformLayout()
   else
      self:InvalidateLayout()
   end

   self.totalTime.Think = function (sf)
      sf:SetText(string.upper(game.GetMap().." - Total Time: "..util.SimpleTime(totalTimeTTT, "%02i:%02i").." - Trouble in Terrorist Town"))
      sf:SizeToContents()
   end
end

vgui.Register( "TTTScoreboard", PANEL, "Panel" )

---- PlayerFrame is defined in sandbox and is basically a little scrolling
---- hack. Just putting it here (slightly modified) because it's tiny.

local PANEL = {}
function PANEL:Init()
   self.pnlCanvas  = vgui.Create( "Panel", self )
   self.YOffset = 0

   self.scroll = vgui.Create("DVScrollBar", self)
   self.scroll.Paint = function( s, w, h )
      surface.SetDrawColor( bfscoreboard.rowBGColor )
      surface.DrawRect( 0, 0, w, h )
   end
   self.scroll.btnUp.Paint = function( s, w, h ) 
      surface.SetDrawColor( Color(17, 24, 30) )
      surface.DrawRect( 0, 0, w-1, h )
      surface.SetDrawColor( Color(207, 203, 200) )
      surface.DrawRect( 1, 1, w-3, h-2 )
   end
   self.scroll.btnDown.Paint = function( s, w, h ) 
      surface.SetDrawColor( Color(17, 24, 30) )
      surface.DrawRect( 0, 0, w-1, h )
      surface.SetDrawColor( Color(207, 203, 200) )
      surface.DrawRect( 1, 1, w-3, h-2 )
   end
   self.scroll.btnGrip.Paint = function( s, w, h )
      surface.SetDrawColor( Color(17, 24, 30) )
      surface.DrawRect( 0, 0, w-1, h )
      surface.SetDrawColor( Color(207, 203, 200) )
      surface.DrawRect( 1, 1, w-3, h-2 )
   end
end

function PANEL:GetCanvas() return self.pnlCanvas end

function PANEL:OnMouseWheeled( dlta )
   self.scroll:AddScroll(dlta * -2)

   self:InvalidateLayout()
end

function PANEL:SetScroll(st)
   self.scroll:SetEnabled(st)
end

function PANEL:PerformLayout()
   self.pnlCanvas:SetVisible(self:IsVisible())

   -- scrollbar
   scrollOnBarSize = 16
   self.scroll:SetPos(self:GetWide() - 16, 0)
   self.scroll:SetSize(scrollOnBarSize, self:GetTall())

   scrollOnFlag = self.scroll.Enabled
   self.scroll:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
   self.scroll:SetEnabled(scrollOnFlag) -- setup mangles enabled state

   self.YOffset = self.scroll:GetOffset()

   self.pnlCanvas:SetPos( 0, self.YOffset )
   self.pnlCanvas:SetSize( self:GetWide() - (self.scroll.Enabled and 16 or 0), self.pnlCanvas:GetTall() )
end
vgui.Register( "TTTPlayerFrame", PANEL, "Panel" )

