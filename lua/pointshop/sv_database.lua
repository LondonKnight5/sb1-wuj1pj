-- Initialize Database
hook.Add("Initialize", "PS_DatabaseInit", function()
    if not sql.TableExists("ps_players") then
        sql.Query([[
            CREATE TABLE ps_players (
                steamid64 TEXT,
                currency TEXT,
                amount INTEGER DEFAULT 0,
                PRIMARY KEY (steamid64, currency)
            )
        ]])
    end
    
    if not sql.TableExists("ps_purchases") then
        sql.Query([[
            CREATE TABLE ps_purchases (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                steamid64 TEXT,
                item_id TEXT,
                currency TEXT,
                amount INTEGER,
                purchase_date DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ]])
    end
end)

-- Load player data on spawn
hook.Add("PlayerInitialSpawn", "PS_LoadPlayerData", function(ply)
    local steamid64 = ply:SteamID64()
    local data = sql.Query(string.format([[
        SELECT currency, amount FROM ps_players
        WHERE steamid64 = '%s'
    ]], steamid64)) or {}
    
    for _, row in ipairs(data) do
        ply:SetNWInt("PS_" .. row.currency, tonumber(row.amount))
    end
end)