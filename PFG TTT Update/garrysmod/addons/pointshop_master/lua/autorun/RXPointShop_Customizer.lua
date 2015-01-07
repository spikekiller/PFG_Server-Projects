EPS_Config = {}

EPS_Config.Size = {1,1} -- x,y
	-- 1 means 100%. so 1,1 makes gui to fit your screen.
	-- 0.5 , 0.5 will make gui to half size of your screen.

	
function EPS_Config:PlayerCanEnhancedModify(ply)
	return true -- return false to make ply not able to open Enhanced Modifier ( Reposition , Reangle , ReBone&Attachment )
end
	
	
	
-- Advanced Modifier
EPS_Config.Modifier = {}
EPS_Config.Modifier.Position_Min = -Vector(100,100,100)
EPS_Config.Modifier.Position_Max = Vector(100,100,100)

	
	
	
	
	
	
	
/* ========================================================
	COLOR CUSTOMIZER
========================================================= */


/* ========================================================
	COLOR CUSTOMIZER :: DARK AND WHITE
========================================================= */


EPS_Config.Color = {}

-- Model Preview
EPS_Config.Color.MP = {}

	EPS_Config.Color.MP.BackGround = Color(20,20,20,255)
	EPS_Config.Color.MP.FootRing = Color(0,150,255,255)
	EPS_Config.Color.MP.BurstRing = Color(0,255,255,255)
	
	EPS_Config.Color.MP.ZoomBar = Color(255,255,255,255)
	
-- Point Gift Menu
EPS_Config.Color.PG = {}

	EPS_Config.Color.PG.OutLine = Color(150,150,150,255)
	EPS_Config.Color.PG.BackGround = Color(30,30,30,255)
	EPS_Config.Color.PG.TitleText = Color(255,255,255,255)

-- Admin Menu
EPS_Config.Color.AM = {}

		EPS_Config.Color.AM.SortText = Color(255,255,255,255)
		EPS_Config.Color.AM.PlayerText = Color(80,150,200,255)
	
-- Main Shop
EPS_Config.Color.MS = {}

	--< Left Category >--
	EPS_Config.Color.MS.LC = {}
	
		-- Top&Main
		EPS_Config.Color.MS.LC.TopBackGround = Color(50,50,50,255)
		EPS_Config.Color.MS.LC.BackGround = Color(20,20,20,255)
		
		EPS_Config.Color.MS.LC.Text_Pointshop = Color(255,255,255,255)
		EPS_Config.Color.MS.LC.Text_Extreme = Color(0,255,255,255)
		EPS_Config.Color.MS.LC.MyInfo = Color(255,255,255,255)
		
		-- Category Menus
		EPS_Config.Color.MS.LC.CategoryName = Color(255,255,255,255)
		EPS_Config.Color.MS.LC.CategoryDesc = Color(100,100,100,255)
		
		-- Shop : Top
		EPS_Config.Color.MS.LC.ShopTopBackGround = Color(50,50,50,255)
		EPS_Config.Color.MS.LC.TopLine = Color(20,50,100,255)
		EPS_Config.Color.MS.LC.TopText = Color(255,255,255,255)
		EPS_Config.Color.MS.LC.TopTextFilter = Color(150,150,150,255)
		
		-- Shop : SemiCategory ( All,Shop,Inventory )
		EPS_Config.Color.MS.LC.SemiBackGround = Color(40,40,40,255)
		EPS_Config.Color.MS.LC.SemiLines = Color(200,200,200,255)
		EPS_Config.Color.MS.LC.SemiButtonText_Selected = Color(255,255,255,255)
		EPS_Config.Color.MS.LC.SemiButtonText_NotSelected = Color(150,150,150,255)
		EPS_Config.Color.MS.LC.ItemsFoundAmount = Color(255,255,255,255)
		
		-- Shop : Item List
		EPS_Config.Color.MS.LC.ListBackGround = Color(20,20,20,255)
		
		-- Shop : Item Icons
		EPS_Config.Color.MS.LC.IconBackGround = Color(40,40,40,255)
		EPS_Config.Color.MS.LC.Text_ItemName = Color(255,255,255,255)
		
		EPS_Config.Color.MS.LC.Text_Purchase = Color(255,0,0,255)
		EPS_Config.Color.MS.LC.Text_Holster = Color(0,255,255,255)
		EPS_Config.Color.MS.LC.Text_Equip = Color(0,255,0,255)
		EPS_Config.Color.MS.LC.Text_Refund = Color(255,255,0,255)
		
		EPS_Config.Color.MS.LC.IconTopBox = Color(200,200,200,50)
		EPS_Config.Color.MS.LC.IconBottomBox = Color(200,200,200,20)