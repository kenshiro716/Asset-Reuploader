--!strict
local reuploadIds = require("../ReuploadIds")
local UiLibrary = require("../../UiLibrary")

local Selection = game:GetService("Selection")

-- Developer product ids only live in scripts and value objects, so these are
-- always scanned regardless of the Filter tab.
local PRODUCT_ID_HOLDERS = { "LuaSourceContainer", "StringValue", "NumberValue", "IntValue" }

return function(ui: UiLibrary.Ui, plugin: Plugin)
    local tab = ui:CreateTab("Products")

    tab:CreateButton("Reupload", function()
        local filter = {
            WhitelistedInstances = PRODUCT_ID_HOLDERS,
            Instances = game:GetDescendants(),
        }

        reuploadIds(plugin, ui, filter, "DeveloperProduct")
    end)

    tab:CreateButton("Reupload Selected", function()
        local filter = {
            WhitelistedInstances = PRODUCT_ID_HOLDERS,
            Instances = Selection:Get(),
        }

        reuploadIds(plugin, ui, filter, "DeveloperProduct")
    end)
end
