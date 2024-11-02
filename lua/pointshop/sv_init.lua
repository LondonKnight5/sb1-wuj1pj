util.AddNetworkString("PS_Purchase")
util.AddNetworkString("PS_UpdatePoints")

-- Currency Management
function PS:GetPlayerCurrency(ply, currency)
    if currency == "DarkRP" and DarkRP then
        return ply:getDarkRPVar("money") or 0
    else
        return ply:GetNWInt("PS_" .. currency, 0)
    end
end

function PS:GiveCurrency(ply, currency, amount)
    if currency == "DarkRP" and DarkRP then
        ply:addMoney(amount)
    else
        ply:SetNWInt("PS_" .. currency, self:GetPlayerCurrency(ply, currency) + amount)
    end
    self:SavePlayerData(ply)
end

function PS:TakeCurrency(ply, currency, amount)
    if currency == "DarkRP" and DarkRP then
        ply:addMoney(-amount)
        return true
    else
        local current = self:GetPlayerCurrency(ply, currency)
        if current >= amount then
            ply:SetNWInt("PS_" .. currency, current - amount)
            self:SavePlayerData(ply)
            return true
        end
    end
    return false
end

-- Database Management
function PS:SavePlayerData(ply)
    local steamid64 = ply:SteamID64()
    
    for currency, data in pairs(PS.Config.Currencies) do
        if data.Enabled and currency != "DarkRP" then
            local amount = ply:GetNWInt("PS_" .. currency, 0)
            sql.Query(string.format([[
                INSERT OR REPLACE INTO ps_players (steamid64, currency, amount)
                VALUES ('%s', '%s', %d)
            ]], steamid64, currency, amount))
        end
    end
end

-- Purchase Handler
net.Receive("PS_Purchase", function(len, ply)
    local itemId = net.ReadString()
    local currency = net.ReadString()
    
    local item = PS.Items[itemId]
    if not item or not item.prices[currency] then return end
    
    local price = item.prices[currency]
    if PS:TakeCurrency(ply, currency, price) then
        if item.command then
            item.command(ply)
        end
        -- Log purchase
        sql.Query(string.format([[
            INSERT INTO ps_purchases (steamid64, item_id, currency, amount, purchase_date)
            VALUES ('%s', '%s', '%s', %d, CURRENT_TIMESTAMP)
        ]], ply:SteamID64(), itemId, currency, price))
        
        -- Notify success
        ply:ChatPrint(string.format("Successfully purchased %s for %s%s", item.name, PS.Config.Currencies[currency].Symbol, price))
    else
        -- Notify insufficient funds
        ply:ChatPrint(string.format("Insufficient %s!", PS.Config.Currencies[currency].Name))
    end
end)