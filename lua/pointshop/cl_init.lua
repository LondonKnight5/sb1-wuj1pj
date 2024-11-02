local PANEL = {}

-- Colors
local COLORS = {
    background = Color(40, 41, 45),
    header = Color(51, 52, 57),
    item = Color(58, 59, 65),
    highlight = Color(66, 139, 202),
    text = Color(255, 255, 255),
    price = Color(95, 211, 107)
}

function PANEL:Init()
    self:SetTitle("PointShop")
    self:SetDraggable(true)
    self:ShowCloseButton(true)
    
    self.Tabs = vgui.Create("DPropertySheet", self)
    self.Tabs:Dock(FILL)
    self.Tabs:DockMargin(5, 5, 5, 5)
    
    -- Main Shop Tab
    self:CreateShopTab()
    
    -- Inventory Tab
    self:CreateInventoryTab()
    
    -- Settings Tab (Admin Only)
    if LocalPlayer():IsAdmin() then
        self:CreateAdminTab()
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, COLORS.background)
    draw.RoundedBox(4, 0, 0, w, 25, COLORS.header)
end

function PANEL:CreateItemPanel(parent, itemId, itemData)
    local item = vgui.Create("DPanel", parent)
    item:SetSize(180, 200)
    
    function item:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, COLORS.item)
    end
    
    -- Icon
    local icon = vgui.Create("DImage", item)
    icon:SetSize(64, 64)
    icon:SetPos(58, 10)
    icon:SetImage(itemData.icon or "icon16/box.png")
    
    -- Name
    local name = vgui.Create("DLabel", item)
    name:SetPos(10, 80)
    name:SetSize(160, 20)
    name:SetText(itemData.name)
    name:SetTextColor(COLORS.text)
    name:SetFont("DermaLarge")
    name:SetContentAlignment(5)
    
    -- Description
    local desc = vgui.Create("DLabel", item)
    desc:SetPos(10, 105)
    desc:SetSize(160, 40)
    desc:SetText(itemData.description)
    desc:SetTextColor(COLORS.text)
    desc:SetContentAlignment(5)
    desc:SetWrap(true)
    
    -- Prices
    local yPos = 150
    for currency, price in pairs(itemData.prices) do
        if PS.Config.Currencies[currency].Enabled then
            local priceLabel = vgui.Create("DLabel", item)
            priceLabel:SetPos(10, yPos)
            priceLabel:SetSize(160, 20)
            priceLabel:SetText(PS.Config.Currencies[currency].Symbol .. " " .. string.Comma(price))
            priceLabel:SetTextColor(COLORS.price)
            priceLabel:SetContentAlignment(5)
            yPos = yPos + 20
        end
    end
    
    -- Buy Button
    local buy = vgui.Create("DButton", item)
    buy:SetPos(10, 170)
    buy:SetSize(160, 25)
    buy:SetText("Buy")
    buy.DoClick = function()
        self:CreatePurchaseMenu(itemId, itemData)
    end
end

function PANEL:CreatePurchaseMenu(itemId, itemData)
    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 150)
    frame:Center()
    frame:SetTitle("Select Payment Method")
    frame:MakePopup()
    
    local y = 30
    for currency, data in pairs(PS.Config.Currencies) do
        if data.Enabled and itemData.prices[currency] then
            local btn = vgui.Create("DButton", frame)
            btn:SetPos(10, y)
            btn:SetSize(280, 30)
            btn:SetText(string.format("Pay with %s (%s%s)", data.Name, data.Symbol, string.Comma(itemData.prices[currency])))
            btn.DoClick = function()
                net.Start("PS_Purchase")
                net.WriteString(itemId)
                net.WriteString(currency)
                net.SendToServer()
                frame:Close()
            end
            y = y + 35
        end
    end
end

function PANEL:CreateShopTab()
    local shop = vgui.Create("DScrollPanel")
    
    local layout = vgui.Create("DIconLayout", shop)
    layout:Dock(FILL)
    layout:SetSpaceX(5)
    layout:SetSpaceY(5)
    layout:DockMargin(5, 5, 5, 5)
    
    -- Category Buttons
    local categories = vgui.Create("DPanel", shop)
    categories:Dock(TOP)
    categories:SetHeight(40)
    categories:DockMargin(5, 5, 5, 5)
    
    local x = 5
    for catName, catData in pairs(PS.Config.Categories) do
        local catBtn = vgui.Create("DButton", categories)
        catBtn:SetPos(x, 5)
        catBtn:SetSize(100, 30)
        catBtn:SetText(catName)
        catBtn.DoClick = function()
            layout:Clear()
            for itemId, itemData in pairs(PS.Items) do
                if itemData.category == catName then
                    self:CreateItemPanel(layout, itemId, itemData)
                end
            end
        end
        x = x + 105
    end
    
    -- Show all items initially
    for itemId, itemData in pairs(PS.Items) do
        self:CreateItemPanel(layout, itemId, itemData)
    end
    
    self.Tabs:AddSheet("Shop", shop, "icon16/cart.png")
end

function PANEL:CreateInventoryTab()
    local inventory = vgui.Create("DScrollPanel")
    
    -- Currency Display
    local currencyPanel = vgui.Create("DPanel", inventory)
    currencyPanel:Dock(TOP)
    currencyPanel:SetHeight(60)
    currencyPanel:DockMargin(5, 5, 5, 5)
    
    local x = 10
    for currency, data in pairs(PS.Config.Currencies) do
        if data.Enabled then
            local label = vgui.Create("DLabel", currencyPanel)
            label:SetPos(x, 20)
            label:SetText(string.format("%s %s", data.Symbol, LocalPlayer():GetNWInt("PS_" .. currency, 0)))
            label:SetFont("DermaLarge")
            label:SizeToContents()
            x = x + 150
        end
    end
    
    self.Tabs:AddSheet("Inventory", inventory, "icon16/box.png")
end

function PANEL:CreateAdminTab()
    local admin = vgui.Create("DScrollPanel")
    -- Admin controls here
    self.Tabs:AddSheet("Admin", admin, "icon16/shield.png")
end

vgui.Register("PointShopMenu", PANEL)