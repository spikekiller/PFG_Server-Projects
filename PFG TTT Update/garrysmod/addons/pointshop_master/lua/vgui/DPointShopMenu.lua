surface.CreateFont('PS_Heading', { font = 'coolvetica', size = 64 })
surface.CreateFont('PS_Heading2', { font = 'coolvetica', size = 24 })
surface.CreateFont('PS_Heading3', { font = 'coolvetica', size = 19 })

local ALL_ITEMS = 1
local OWNED_ITEMS = 2
local UNOWNED_ITEMS = 3

local EquippedIcon = Material("icon16/accept.png")
local ModifierIcon = Material("icon16/cog.png")

local function AutoSizeIcon(ListerWide,ListerSpacing)
	local Wide_M = 200
	
	ListerWide = ListerWide-30
	
	local Cal1 = ListerWide / (Wide_M+ListerSpacing)
	Cal1 = math.Round(Cal1)
	Cal1 = ListerWide / Cal1
	Cal1 = Cal1 - ListerSpacing
	
	return Cal1 , Cal1
end

hook.Add("PS_ItemAdjusted","PS_Item_Adjusted",function()
	if PS.ShopMenu and PS.ShopMenu:IsValid() then
		PS.ShopMenu:UpdateCurrentScreen()
	end
end)

local function BuildItemMenu(menu, ply, itemstype, callback)
	local plyitems = ply:PS_GetItems()
	
	for category_id, CATEGORY in pairs(PS.Categories) do
		
		local catmenu = menu:AddSubMenu(CATEGORY.Name)
		
		table.SortByMember(PS.Items, PS.Config.SortItemsBy, function(a, b) return a > b end)
		
		for item_id, ITEM in pairs(PS.Items) do
			if ITEM.Category == CATEGORY.Name then
				if itemstype == ALL_ITEMS or (itemstype == OWNED_ITEMS and plyitems[item_id]) or (itemstype == UNOWNED_ITEMS and not plyitems[item_id]) then
					catmenu:AddOption(ITEM.Name, function() callback(item_id) end)
				end
			end
		end
	end
end

local PANEL = {}

function PANEL:UpdateCurrentScreen()
	if self.SHOPList and self.SHOPList:IsValid() then
		self.SHOPList:Refresh()
	end
	if self.LastFilterName then
		self:UpdateSemiFilterList(self.LastFilterName)
	end
	--self.SHOPList:UpdateList(FilterName,CategoryName,DB)
end

function PANEL:ReBulidCanvas()
	if self.Canvas then
		self.Canvas:Remove()
	end
	self.Canvas = vgui.Create("DPanel",self)
	self.Canvas:SetPos(250,0)
	self.Canvas:SetSize(self:GetWide()-250,self:GetTall())
	self.Canvas.Paint = function(slf)
		surface.SetDrawColor(Color(10,10,10,255))
		surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
	end
	return self.Canvas
end

function PANEL:Init()
	PS_ShopMenu = self
	
	self.Mode = "All" -- "Inventory"
	self.SemiFilter = "All"
	
	self.CreatedTime = CurTime()
end

function PANEL:ShowShop(MainCategory,SubCategory)
	SubCategory = SubCategory or "All"
	self.SelectedCategory = MainCategory
	self.SelectedSubCategory = SubCategory
	
	local Canvas = self:ReBulidCanvas()
	
	local previewpanel = vgui.Create('DPointShopPreview', Canvas) self.previewpanel = previewpanel
	previewpanel:SetSize(300,Canvas:GetTall())
	previewpanel:SetPos(Canvas:GetWide()-305,0)
	
	local TopPanel = vgui.Create("DPanel",Canvas)
	TopPanel:SetPos(0,0)
	TopPanel:SetSize(Canvas:GetWide()-300,40)
	TopPanel.Paint = function(slf)
		surface.SetDrawColor(EPS_Config.Color.MS.LC.ShopTopBackGround)
		surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
		
		surface.SetDrawColor(EPS_Config.Color.MS.LC.TopLine)
		surface.DrawRect(0,slf:GetTall()-2,slf:GetWide(),2)
		draw.SimpleText(MainCategory, 'EPSF_Verd_S30', 10, 5, EPS_Config.Color.MS.LC.TopText)
		draw.SimpleText(self.SelectedSubCategory, 'EPSF_Verd_S20', slf:GetWide()-10, 20, EPS_Config.Color.MS.LC.TopTextFilter,TEXT_ALIGN_RIGHT)
	end
	
	local SemiFilterBG = vgui.Create("DPanel",Canvas)
	SemiFilterBG:SetPos(0,40)
	SemiFilterBG:SetSize(Canvas:GetWide()-300,60)
	SemiFilterBG.Paint = function(slf)
		surface.SetDrawColor(EPS_Config.Color.MS.LC.SemiBackGround)
		surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
	end
	
	local Modes = {"All","Shop","Inventory"}
	
	for k,v in pairs(Modes) do
		local SemiButton = vgui.Create("DButton",SemiFilterBG)
		SemiButton:SetPos(10+(120*(k-1)),10)
		SemiButton:SetSize(120,50)
		SemiButton:SetText("")
		SemiButton.Mode = v
		SemiButton.Paint = function(slf)
			surface.SetDrawColor(EPS_Config.Color.MS.LC.SemiLines)
			if self.SemiFilter == slf.Mode then
				surface.DrawRect(0,0,2,slf:GetTall())
				surface.DrawRect(0,0,slf:GetWide()-2,2)
				surface.DrawRect(slf:GetWide()-2,0,2,slf:GetTall())
				
				surface.SetDrawColor(Color(0,0,0,200))
				surface.DrawRect(2,2,slf:GetWide()-4,slf:GetTall()-2)
				
				draw.SimpleText(slf.Mode, 'EPSF_Verd_S20', slf:GetWide()/2, 25, EPS_Config.Color.MS.LC.SemiButtonText_Selected,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			else
				surface.DrawRect(0,slf:GetTall()-2,slf:GetWide(),2)
				draw.SimpleText(slf.Mode, 'EPSF_Verd_S20', slf:GetWide()/2, 25, EPS_Config.Color.MS.LC.SemiButtonText_NotSelected,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			end
		end
		SemiButton.DoClick = function(slf)
			self.SemiFilter = slf.Mode
			self:ShowShop(MainCategory,SubCategory)
		end
	end
	local Else = vgui.Create("DPanel",SemiFilterBG)
	Else:SetPos(10+(120*#Modes),10)
	Else:SetSize((SemiFilterBG:GetWide()-20) - 120*#Modes,50)
	Else.Paint = function(slf)
		surface.SetDrawColor(EPS_Config.Color.MS.LC.SemiLines)
		surface.DrawRect(0,slf:GetTall()-2,slf:GetWide(),2)
		
		if self.FoundedItems then
			draw.SimpleText(self.FoundedItems .. " Items", 'EPSF_Verd_S20', slf:GetWide()-10, 28, EPS_Config.Color.MS.LC.ItemsFoundAmount,TEXT_ALIGN_RIGHT)
			
		end
	end
	
	local Lister = vgui.Create("DPanelList",Canvas)
	Lister:SetPos(10,110)
	Lister:SetSize(Canvas:GetWide()-320,Canvas:GetTall()-120)
	Lister:SetSpacing(10);
	Lister:SetPadding(3);
	Lister:EnableVerticalScrollbar(true);
	Lister:EnableHorizontal(true);
	Lister.Paint = function(slf)
		surface.SetDrawColor(EPS_Config.Color.MS.LC.ListBackGround)
		surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
	end
	
	------
	local function SemiCheck(i)
		if self.SemiFilter == "All" then return true end
		if self.SemiFilter == "Shop" then
			if !LocalPlayer():PS_HasItem(i.ID) then return true end
		end
		if self.SemiFilter == "Inventory" then
			if LocalPlayer():PS_HasItem(i.ID) then return true end
		end
		return false
	end
	
	local Items2Show = {}
	for _,i in pairs(PS.Items) do
		if i.Category == MainCategory then
			if SubCategory and SubCategory !="All" then
				if i.SubCategoryName == SubCategory then
					if SemiCheck(i) then
						table.insert(Items2Show,i)
					end
				end
			else
				if SemiCheck(i) then
					table.insert(Items2Show,i)
				end
			end
		end
	end
	self.FoundedItems = #Items2Show
	table.SortByMember(Items2Show, "Name", function(a, b) return a > b end)
					
	for k,v in pairs(Items2Show) do
		local SX,SY = AutoSizeIcon(Lister:GetWide(),Lister:GetSpacing())
		
		local Price = PS.Config.CalculateBuyPrice(LocalPlayer(), v)
		local Refund = PS.Config.CalculateSellPrice(LocalPlayer(), v)
		
		local IconBG = vgui.Create("DButton") Lister:AddItem(IconBG)
		IconBG:SetText("")
		IconBG:SetSize(SX,SY)
		IconBG.Paint = function(slf)	
			surface.SetDrawColor(EPS_Config.Color.MS.LC.IconBackGround)
			surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
			
			if slf:IsHovered() then
				surface.SetDrawColor(Color(255,255,255,3))
				surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
			end
			
			surface.SetDrawColor(EPS_Config.Color.MS.LC.IconTopBox)
			surface.DrawRect(0,0,slf:GetWide(),20)
			draw.SimpleText(v.Name, 'EPSF_VerdOut_S18', slf:GetWide()/2, 10, EPS_Config.Color.MS.LC.Text_ItemName,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			
			surface.SetDrawColor(EPS_Config.Color.MS.LC.IconBottomBox)
			surface.DrawRect(0,slf:GetTall()-20,slf:GetWide(),20)
			
			if !LocalPlayer():PS_HasItem(v.ID) then
				if slf:IsHovered() then
					draw.SimpleText("Buy : " .. Price .. " $", 'EPSF_VerdOut_S20', slf:GetWide()/2, slf:GetTall()-10, EPS_Config.Color.MS.LC.Text_Purchase,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				else
					draw.SimpleText("Purchase", 'EPSF_VerdOut_S20', slf:GetWide()/2, slf:GetTall()-10, EPS_Config.Color.MS.LC.Text_Purchase,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				end
			else
				
				if slf:IsHovered() then
					draw.SimpleText("Refund : " .. Refund .. " $", 'EPSF_VerdOut_S20', slf:GetWide()/2, slf:GetTall()-10, EPS_Config.Color.MS.LC.Text_Refund,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				else
					if LocalPlayer():PS_HasItemEquipped(v.ID) then
						draw.SimpleText("Holster", 'EPSF_VerdOut_S20', slf:GetWide()/2, slf:GetTall()-10, EPS_Config.Color.MS.LC.Text_Holster,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					else
						draw.SimpleText("Equip", 'EPSF_VerdOut_S20', slf:GetWide()/2, slf:GetTall()-10, EPS_Config.Color.MS.LC.Text_Equip,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					end
				end
				

			end
		end
		
		local model
		
		if (v.Attachment or v.Bone) and v.Model then
			model = vgui.Create('DPointShopItemModelGenerator',IconBG)
		else
			model = vgui.Create('DPointShopItem',IconBG)
		end
		IconBG.ModelPanel = model
		 
		model:SetData(v)
		model:SetPos(20,20)
		model:SetSize(IconBG:GetWide()-40, IconBG:GetTall()-40)
		model:SetMouseInputEnabled(false)
		
		IconBG.OnCursorExited = function(slf) model:OnCursorExited() end
		IconBG.OnCursorEntered = function(slf) model:OnCursorEntered() end
		
		function IconBG:OnMousePressed(MC)
			if MC == MOUSE_LEFT then
				model:DoClick()
			end
			if MC == MOUSE_RIGHT then
				if !LocalPlayer():PS_HasItem(v.ID) then
					Derma_Query('Are you sure you want to buy ' .. v.Name .. '?', 'Buy Item',
						'Yes', function() LocalPlayer():PS_BuyItem(v.ID) end,
						'No', function() end
					)
				else
					if LocalPlayer():PS_HasItemEquipped(v.ID) then
						LocalPlayer():PS_HolsterItem(v.ID)
					else
						LocalPlayer():PS_EquipItem(v.ID)
					end
				end
			end
		end
	
	
		local Mask = vgui.Create("DPanel",IconBG)
		Mask:SetMouseInputEnabled(false)
		Mask:SetSize(IconBG:GetSize())
		Mask.Paint = function(slf)
			if LocalPlayer():PS_HasItemEquipped(v.ID) then
				surface.SetMaterial(EquippedIcon)
				surface.SetDrawColor(255,255,255,255)
				surface.DrawTexturedRect(5,25,16,16)
			end 
			if PS_RXModifier_CanModify(v) then
				surface.SetMaterial(ModifierIcon)
				surface.SetDrawColor(255,255,255,255)
				surface.DrawTexturedRect(25,25,16,16)
			end
			
		end
	end
end

function PANEL:Install_Left()
local MainPanel = self
	if self.LeftMain and self.LeftMain:IsValid() then
		self.LeftMain:Remove()
	end
	
	self.ListerTall = self:GetTall() - 160 - 60
	
	self.LeftMain = vgui.Create("DPanel",self)
	self.LeftMain:SetPos(0,0)
	self.LeftMain:SetSize(250,self:GetTall())
	self.LeftMain.Paint = function(slf)
		surface.SetDrawColor(EPS_Config.Color.MS.LC.BackGround)
		surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
		
		surface.SetDrawColor(EPS_Config.Color.MS.LC.TopBackGround)
		surface.DrawRect(0,0,slf:GetWide(),160)
		
		draw.SimpleText("PSG PShop", 'EPSF_Verd_S40', slf:GetWide()/2, 0, EPS_Config.Color.MS.LC.Text_Pointshop,TEXT_ALIGN_CENTER)
		draw.SimpleText("Redone by Swamp", 'EPSF_Cour_S20', slf:GetWide()/2, 30, EPS_Config.Color.MS.LC.Text_Extreme,TEXT_ALIGN_CENTER)
		draw.SimpleText(LocalPlayer():Nick(), 'EPSF_Verd_S20', slf:GetWide()/2, 115, EPS_Config.Color.MS.LC.MyInfo,TEXT_ALIGN_CENTER)
		
		
		surface.SetDrawColor(200,200,200,20)
		surface.DrawRect(10,159,slf:GetWide()-20,2)
		surface.DrawRect(10,self.ListerTall+160-2,slf:GetWide()-20,2)
	end
	
	local PointGift = vgui.Create("DButton",self.LeftMain)
	PointGift:SetPos(0,136)
	PointGift:SetSize(self.LeftMain:GetWide(),20)
	PointGift:SetText("")
	PointGift.Paint = function(slf)
		if slf:IsHovered() then
			surface.SetDrawColor(150,150,150,10)
			surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
		end
		draw.SimpleText("Point : " .. LocalPlayer():PS_GetPoints(), 'EPSF_CourOut_S20', slf:GetWide()/2, 10, EPS_Config.Color.MS.LC.MyInfo,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	PointGift.DoClick = function(slf)
		PS:ShowGivePointMenu()
	end
	PointGift:SetToolTip("Give Points to other players")
	
	
	local Avatar = vgui.Create( "AvatarImage", self.LeftMain )
	Avatar:SetSize( 64, 64 )
	Avatar:SetPos( self.LeftMain:GetWide()/2-32, 50 )
	Avatar:SetPlayer( LocalPlayer(), 64 )
	
	local CloseButton = vgui.Create("EPS_CategoryButtons",self.LeftMain)
	CloseButton:SetSize(self.LeftMain:GetWide(),60)
	CloseButton:SetPos(0,self.LeftMain:GetTall() - CloseButton:GetTall())
	CloseButton:SetTexts("Close","Close Pointshop")
	CloseButton.Click = function(slf)
		PS:ToggleMenu()
	end
	
	-- ADMIN
	if ((PS.Config.AdminCanAccessAdminTab and LocalPlayer():IsAdmin()) or (PS.Config.SuperAdminCanAccessAdminTab and LocalPlayer():IsSuperAdmin())) then
		self.ListerTall = self.ListerTall - 60
		local AdminButton = vgui.Create("EPS_CategoryButtons",self.LeftMain)
		AdminButton:SetSize(self.LeftMain:GetWide(),60)
		AdminButton:SetPos(0,self.LeftMain:GetTall() - AdminButton:GetTall()*2)
		AdminButton:SetTexts("Admin","Manage Players")
		AdminButton.Click = function(slf)
			self:CanvasBuild_Admin()
		end
	end
	
	local Lister = vgui.Create("DPanelList",self.LeftMain)
	Lister:SetPos(0,165)
	Lister:SetSize(self.LeftMain:GetWide(),self.ListerTall-10)
	Lister.Paint = function(slf)
	end
	function Lister:RebulidCategory()
		self:Clear()
		-- sorting
		local categories = {}
		for _, i in pairs(PS.Categories) do
			table.insert(categories, i)
		end
		table.sort(categories, function(a, b) 
			if a.Order == b.Order then 
				return a.Name < b.Name
			else
				return a.Order < b.Order
			end
		end)
		
		for k,v in pairs(categories) do
			local CategoryButton = vgui.Create("EPS_CategoryButtons")
			CategoryButton:SetTall(50)
			CategoryButton:SetTexts(v.Name,v.Description or v.Name)
			CategoryButton.MainFont = "EPSF_CourOut_S23"
			CategoryButton.DescFont = "EPSF_CourOut_S18"
			CategoryButton:SetIcon(v.Icon)
			CategoryButton.PaintBackGround = function(slf)
				if MainPanel.SelectedCategory == v.Name then
					surface.SetDrawColor(200,200,200,10)
					surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
					
					if MainPanel.SelectedSubCategory == "All" then
						surface.SetDrawColor(200,200,200,120)
						surface.DrawRect(0,0,4,slf:GetTall())
					end
				end
			end
			CategoryButton.Click = function(slf)
				MainPanel:ShowShop(v.Name,"All")
				MainPanel:Install_Left()
			end
			self:AddItem(CategoryButton)
			
			if !MainPanel.FirstSelect then
				MainPanel.FirstSelect = true
				timer.Simple(0.1,function()
					CategoryButton:Click()
				end)
			end
			
			if MainPanel.SelectedCategory == v.Name then
				local CreatedTime = CurTime()
				for _,DB in pairs(v.SubCategorys or {}) do
					---
					local SubCategoryButton = vgui.Create("EPS_CategoryButtons")
					SubCategoryButton.MoveRight = 20
					SubCategoryButton:SetTall(40)
					SubCategoryButton:SetTexts(DB.Name,DB.Desc or DB.Name)
					SubCategoryButton.MainFont = "EPSF_CourOut_S23"
					SubCategoryButton.DescFont = "EPSF_CourOut_S18"
					SubCategoryButton:SetIcon(v.Icon)
					SubCategoryButton.PaintBackGround = function(slf)
						surface.SetDrawColor(200,200,200,3)
						surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
						
						if MainPanel.SelectedCategory == v.Name then
							if MainPanel.SelectedSubCategory and MainPanel.SelectedSubCategory == DB.Name then
								surface.SetDrawColor(200,200,200,120)
								surface.DrawRect(0,0,4,slf:GetTall())
							end
						end
						
						draw.SimpleText("└", 'EPSF_CourOut_S20', 2, 10, Color(230,230,230,255))
					end
					SubCategoryButton.Click = function(slf)
						MainPanel:ShowShop(v.Name,DB.Name)
					end
					self:AddItem(SubCategoryButton)
					---
				end
			end
		end
	end
	Lister:RebulidCategory()
end

function PANEL:Install()
local MotherPanel = self
	self:SetSize( ScrW() * EPS_Config.Size[1],ScrH() * EPS_Config.Size[2] )
	self:Center()
	
	self:Install_Left()
	
	self:ReBulidCanvas()
end

function PANEL:Think_BindKey2Close()
	if CurTime() > self.CreatedTime +0.5 then
		local ShopKey = PS.Config.ShopKey
		
		local Key2Var = {}
		Key2Var["F1"] = KEY_F1
		Key2Var["F2"] = KEY_F2
		Key2Var["F3"] = KEY_F3
		Key2Var["F4"] = KEY_F4
		
		
		if !input.IsKeyDown(Key2Var[ShopKey]) then
			FK = true
		else
			if FK then
				self:Remove()
				PS:ToggleMenu()
			end
		end
	end
end

function PANEL:Think()
	
	if self.ClientsList and self.ClientsList:IsValid() then
		local lines = self.ClientsList:GetLines()
		
		for _, ply in pairs(player.GetAll()) do
			local found = false
			
			for _, line in pairs(lines) do
				if line.Player == ply then
					found = true
				end
			end
			
			if not found then
				self.ClientsList:AddLine(ply:GetName(), ply:PS_GetPoints(), table.Count(ply:PS_GetItems())).Player = ply
			end
		end
		
		for i, line in pairs(lines) do
			if IsValid(line.Player) then
				local ply = line.Player
				
				line:SetValue(1, ply:GetName())
				line:SetValue(2, ply:PS_GetPoints())
				line:SetValue(3, table.Count(ply:PS_GetItems()))
			else
				self.ClientsList:RemoveLine(i)
			end
		end
	end
end

function PANEL:Paint()
	self:Think_BindKey2Close()
end

function PANEL:CanvasBuild_Admin()
	local Canvas = self:ReBulidCanvas()

		local Title = vgui.Create("DPanel",Canvas)
		Title:SetPos(20,5)
		Title:SetSize(Canvas:GetWide() -40,40)
		Title.Paint = function(slf)
			surface.SetDrawColor(EPS_Config.Color.MS.LC.ShopTopBackGround)
			surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
			
			surface.SetDrawColor(EPS_Config.Color.MS.LC.TopLine)
			surface.DrawRect(0,slf:GetTall()-2,slf:GetWide(),2)
			draw.SimpleText("Admin Panel", 'EPSF_Verd_S30', 10, 5, EPS_Config.Color.MS.LC.TopText)
		end


		local FilterTitle = vgui.Create("DPanel",Canvas)
		FilterTitle:SetPos(20,50)
		FilterTitle:SetSize(Canvas:GetWide()-40,40)
		FilterTitle.Paint = function(slf)
			surface.SetDrawColor(EPS_Config.Color.MS.LC.SemiBackGround)
			surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
		end
		
			local PlayerClick = function() end -- Precache
			local PlayerList = vgui.Create("DPanelList", Canvas) -- Precache
		
				local Button = vgui.Create("EPS_CategoryButtons",FilterTitle)
				Button:SetSize(100,40)
				Button:SetPos(0,0)
				Button:SetTexts("No.")
				Button.MainFont = "EPSF_Treb_S25"
				Button.TextCol = EPS_Config.Color.AM.SortText
				Button.BoarderCol = Color(0,0,0,0)
				Button.Click = function(slf)
					PlayerList:ReBuild("Num")
				end
			
				local Button = vgui.Create("EPS_CategoryButtons",FilterTitle)
				Button:SetSize(FilterTitle:GetWide()-300,40)
				Button:SetPos(100,0)
				Button:SetTexts("Nick Name")
				Button.TextCol = EPS_Config.Color.AM.SortText
				Button.MainFont = "EPSF_Treb_S25"
				Button.BoarderCol = Color(0,0,0,0)
				Button.Click = function(slf)
					PlayerList:ReBuild("Nick")
				end
			
				local Button = vgui.Create("EPS_CategoryButtons",FilterTitle)
				Button:SetSize(100,40)
				Button:SetPos(FilterTitle:GetWide()-200,0)
				Button:SetTexts("Points")
				Button.TextCol = EPS_Config.Color.AM.SortText
				Button.MainFont = "EPSF_Treb_S25"
				Button.BoarderCol = Color(0,0,0,0)
				Button.Click = function(slf)
					PlayerList:ReBuild("Points")
				end
			
				local Button = vgui.Create("EPS_CategoryButtons",FilterTitle)
				Button:SetSize(100,40)
				Button:SetPos(FilterTitle:GetWide()-100,0)
				Button:SetTexts("Items")
				Button.TextCol = EPS_Config.Color.AM.SortText
				Button.MainFont = "EPSF_Treb_S25"
				Button.BoarderCol = Color(0,0,0,0)
				Button.Click = function(slf)
					PlayerList:ReBuild("Items")
				end
			
				
		

			PlayerList:SetPos(20,100);
			PlayerList:SetSize(Canvas:GetWide()-40, Canvas:GetTall()-120);
			PlayerList:SetSpacing(0);
			PlayerList:SetPadding(0);
			PlayerList:EnableVerticalScrollbar(true);
			PlayerList:EnableHorizontal(true)
			PlayerList.Paint = function(slf) --
			end
			local Dir = true
			
			PlayerList.ReBuild = function(slf,Order)
				local LIST = {}
				for k,v in pairs(player.GetAll()) do
					local TB2Insert = {}
					TB2Insert.Num = k
					TB2Insert.Points = v:PS_GetPoints()
					TB2Insert.Items = table.Count(v:PS_GetItems())
					TB2Insert.Nick = v:Nick()
					TB2Insert.Ply = v
					table.insert(LIST,TB2Insert)
				end
				slf:Clear()
				
				slf.Order = slf.Order or Order
				
				if Order == slf.Order then
					if !Dir then 
						Dir = true 
					else 
						Dir = false 
					end
				end
				slf.Order = Order
				
				if Dir then
					table.SortByMember(LIST, Order)
				else
					table.SortByMember(LIST, Order, function(a, b) return a < b end)
				end
				
				for k,DB in pairs(LIST) do
							local BGP = vgui.Create("EPS_CategoryButtons")
							BGP:SetSize(PlayerList:GetWide(), 30)
							BGP:SetTexts("")
							BGP.BoarderCol = Color(0,0,0,0)
							BGP.Count = k%2
							BGP.Click = function(slf)
								PlayerClick(DB.Ply)
							end
							BGP.Think = function(slf)
								if !DB.Ply or !DB.Ply:IsValid() then
									slf:Remove()
								end
							end
							BGP.PaintOverlay = function(slf)
								draw.SimpleText("No." .. DB.Num, 'EPSF_Treb_S22', 20, 2, EPS_Config.Color.AM.PlayerText)
								draw.SimpleText(DB.Ply:Nick(), 'EPSF_Treb_S22', 120, 2, EPS_Config.Color.AM.PlayerText)
								draw.SimpleText(DB.Ply:PS_GetPoints(), 'EPSF_Treb_S22', slf:GetWide()-150, 2, EPS_Config.Color.AM.PlayerText,TEXT_ALIGN_CENTER)
								draw.SimpleText(table.Count(DB.Ply:PS_GetItems()), 'EPSF_Treb_S22', slf:GetWide()-50, 2, EPS_Config.Color.AM.PlayerText,TEXT_ALIGN_CENTER)
							end
							BGP.PaintBackGround = function(slf)
								surface.SetDrawColor( Color(0,10,slf.Count*10+10,120) )
								surface.DrawRect( 1, 1, slf:GetWide()-2, slf:GetTall()-2 )
							end
						PlayerList:AddItem(BGP)
				end
				
			end
		
			PlayerList:ReBuild("Num")


		PlayerClick = function(ply)
			local menu = DermaMenu()
			
			menu:AddOption('Set '..PS.Config.PointsName..'...', function()
				Derma_StringRequest(
					"Set "..PS.Config.PointsName.." for " .. ply:GetName(),
					"Set "..PS.Config.PointsName.." to...",
					"",
					function(str)
						if not str or not tonumber(str) then return end
						
						net.Start('PS_SetPoints')
							net.WriteEntity(ply)
							net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end
				)
			end)
			
			menu:AddOption('Give '..PS.Config.PointsName..'...', function()
				Derma_StringRequest(
					"Give "..PS.Config.PointsName.." to " .. ply:GetName(),
					"Give "..PS.Config.PointsName.."...",
					"",
					function(str)
						if not str or not tonumber(str) then return end
						
						net.Start('PS_GivePoints')
							net.WriteEntity(ply)
							net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end
				)
			end)
			
			menu:AddOption('Take '..PS.Config.PointsName..'...', function()
				Derma_StringRequest(
					"Take "..PS.Config.PointsName.." from " .. ply:GetName(),
					"Take "..PS.Config.PointsName.."...",
					"",
					function(str)
						if not str or not tonumber(str) then return end
						
						net.Start('PS_TakePoints')
							net.WriteEntity(ply)
							net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end
				)
			end)
			
			menu:AddSpacer()
			
			BuildItemMenu(menu:AddSubMenu('Give Item'), ply, UNOWNED_ITEMS, function(item_id)
				net.Start('PS_GiveItem')
					net.WriteEntity(ply)
					net.WriteString(item_id)
				net.SendToServer()
			end)
			
			BuildItemMenu(menu:AddSubMenu('Take Item'), ply, OWNED_ITEMS, function(item_id)
				net.Start('PS_TakeItem')
					net.WriteEntity(ply)
					net.WriteString(item_id)
				net.SendToServer()
			end)
			
			menu:Open()
		end
end
vgui.Register('DPointShopMenu', PANEL)
