-- define class
local Class = require "class"
local ObjHost = require "obj_host"
local enterprise_shop = Class.NewClass(ObjHost)

--[[
    The enterprise_shop is a ObjHost. It hosts one ItemSupplier Shop to provide items.
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

local ObjArray = require "obj_array"
local URL = require "obj_url"

local Shop = require "shop"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enterprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
enterprise_shop._hostName   = "enterprise_shop"

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function enterprise_shop:getClassName()
    return "enterprise_shop"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

-- ToDo: consider allowing multiple Shop's in the future, and hence do this and it's usage different.
function enterprise_shop:getShop()
    --[[
        This function returns the Shop.

        In the current implementation there should be only 1 Shop in the world. If none is found a new default Shop is created and saved.

        Return value:
            shop                    - (Shop) the Shop
    --]]

    -- check there is a Shop
    local shop = nil
    local nShops = self:getNumberOfObjects("Shop")
    if nShops == 0 then
        -- the Shop is not there yet => create it
        shop = Shop:newInstance(coreutils.NewId(), ObjArray:newInstance(URL:getClassName()))
        corelog.WriteToLog("Creating Shop "..shop:getId())

        -- save it
        local objLocator = self:saveObject(shop)
        if not objLocator then corelog.Error("enterprise_shop:getShop: Failed saving Shop") return nil end
    else
        -- check exactly 1 Shop
        if nShops ~= 1 then
            corelog.Warning("enterprise_shop:getShop: there are "..nShops.." Shop's in the world while we expected 1.")
        end

        -- get locator of (first) Shop
        local shops = self:getObjects("Shop")
        if not shops then corelog.Error("enterprise_shop:getShop: Failed obtaining Shop's") return nil end
        for k, objTable in pairs(shops) do -- use next(shops)
            shop = Shop:new(objTable)
            break
        end
    end

    -- end
    return shop
end

function enterprise_shop.GetShopLocator()
    --[[
        This function returns the Shop locator.

        Return value:
            shopLocator             - (URL) locating the Shop
    --]]

    -- get Shop
    local shop = enterprise_shop:getShop()

    -- get locator
    local shopLocator = enterprise_shop:getObjectLocator(shop)
    if not shopLocator then corelog.Error("enterprise_shop.GetShopLocator: Failed getting shopLocator") return nil end

    -- end
    return shopLocator
end

function enterprise_shop:deleteShop()
    enterprise_shop:deleteObjects("Shop")
end

function enterprise_shop:reset()
    -- get Shop
    local shop = enterprise_shop:getShop()
    if not shop then corelog.Error("enterprise_shop:reset: Failed getting Shop") return nil end

    -- delist Suppliers
    shop:delistAllItemSuppliers()
end

return enterprise_shop
