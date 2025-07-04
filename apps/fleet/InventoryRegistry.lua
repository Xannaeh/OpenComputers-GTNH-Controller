local DataHelper = require("apps/DataHelper")

local InventoryRegistry = {}
InventoryRegistry.__index = InventoryRegistry

function InventoryRegistry.new()
    return setmetatable({ path = "/data/inventories.lua" }, InventoryRegistry)
end

function InventoryRegistry:load()
    local d = DataHelper.loadTable(self.path) or { inventories = {} }
    for _, inv in ipairs(d.inventories) do
        if inv.deleted == nil then inv.deleted = false end
    end
    return d
end

function InventoryRegistry:save(tbl)
    DataHelper.saveTable(self.path, tbl)
end

function InventoryRegistry:add(name, x, y, z, side)
    local d = self:load()
    table.insert(d.inventories, {
        name = name,
        x = x,
        y = y,
        z = z,
        side = side,
        deleted = false
    })
    self:save(d)
end

function InventoryRegistry:modify(name, x, y, z, side)
    local d = self:load()
    for _, inv in ipairs(d.inventories) do
        if inv.name == name then
            inv.x = x
            inv.y = y
            inv.z = z
            inv.side = side
            break
        end
    end
    self:save(d)
end

function InventoryRegistry:delete(name)
    local d = self:load()
    for _, inv in ipairs(d.inventories) do
        if inv.name == name then
            inv.deleted = true
            break
        end
    end
    self:save(d)
end

function InventoryRegistry:list()
    local d = self:load()
    for _, inv in ipairs(d.inventories) do
        if not inv.deleted then
            print(("📦 %s — (%d,%d,%d) side %d"):format(inv.name, inv.x, inv.y, inv.z, inv.side))
        end
    end
end

function InventoryRegistry:find(name)
    local d = self:load()
    for _, inv in ipairs(d.inventories) do
        if inv.name == name and not inv.deleted then
            return inv
        end
    end
    return nil
end

return InventoryRegistry
