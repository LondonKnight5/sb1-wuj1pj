-- Open shop menu
concommand.Add("ps_shop", function()
    if IsValid(PS.ShopMenu) then
        PS.ShopMenu:Remove()
    end
    
    PS.ShopMenu = vgui.Create("PointShopMenu")
    PS.ShopMenu:SetSize(800, 600)
    PS.ShopMenu:Center()
    PS.ShopMenu:MakePopup()
end)

-- Bind shop menu to F4
hook.Add("Initialize", "PS_BindKeys", function()
    bind.Register("ps_shop", function()
        RunConsoleCommand("ps_shop")
    end)
end)