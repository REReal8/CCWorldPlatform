local t_shop = {}
-- ToDo: rename with renaming of enterprise_shop

local enterprise_shop = require "enterprise_shop"

function t_shop.T_All()
    -- initialisation

    -- specific

    -- service
end

function t_shop.T_reset()
    enterprise_shop:reset()
end

function t_shop.T_deleteShop()
    enterprise_shop:deleteShop()
end

return t_shop
