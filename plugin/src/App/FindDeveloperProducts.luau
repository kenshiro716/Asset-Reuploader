--!strict
local MarketplaceService = game:GetService("MarketplaceService")

export type ProductInfo = {
    id: number,
    name: string,
    description: string,
    price: number,
    iconImageAssetId: number,
}

local CONCURRENCY = 6
local TRIES = 3

local function lookup(id: number): ProductInfo?
    for attempt = 1, TRIES do
        local success, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id, Enum.InfoType.Product)
        if success then
            local productInfo = info :: any
            if type(productInfo) ~= "table" or type(productInfo.Name) ~= "string" then return nil end

            return {
                id = id,
                name = productInfo.Name,
                description = productInfo.Description or "",
                price = tonumber(productInfo.PriceInRobux) or 0,
                iconImageAssetId = tonumber(productInfo.IconImageAssetId) or 0,
            }
        end

        -- Ids that are not developer products fail straight away; anything else
        -- (throttling, network) is worth another try.
        local message = string.lower(tostring(info))
        if string.find(message, "not found", 1, true) or string.find(message, "invalid", 1, true) then
            return nil
        end
        task.wait(attempt * 2)
    end
    return nil
end

-- Checks which of the given ids are developer products and returns their info.
return function(ids: { number }, onProgress: ((checked: number, total: number) -> ())?): { [number]: ProductInfo }
    local found: { [number]: ProductInfo } = {}
    local total = #ids
    local nextIndex, checked, running = 1, 0, 0

    local function worker()
        while nextIndex <= total do
            local id = ids[nextIndex]
            nextIndex += 1

            local info = lookup(id)
            if info then found[id] = info end

            checked += 1
            if onProgress and checked % 25 == 0 then onProgress(checked, total) end
        end
        running -= 1
    end

    for _ = 1, math.min(CONCURRENCY, total) do
        running += 1
        task.spawn(worker)
    end
    while running > 0 do
        task.wait()
    end

    return found
end
