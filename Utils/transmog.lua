--- transmog.lua Contains everything related to transmog
-- @author	Urtgard
-- Create Date : 26/5/2023

-- Returns whether the item is transmoggable or not.
function RCLootCouncil:IsTransmoggable(link)
    if CanIMogIt then
        return CanIMogIt:IsTransmogable(link)
    end

    return C_TransmogCollection.GetItemInfo(link)
end

local function PlayerKnowsTransmogInternal(link, checkSource)
    if CanIMogIt then
        if checkSource then
            return CanIMogIt:PlayerKnowsTransmogFromItem(link)
        else
            return CanIMogIt:PlayerKnowsTransmog(link)
        end
    end

    local itemAppearanceID, itemModifiedAppearanceID = C_TransmogCollection.GetItemInfo(link)

    local sourceIDs = C_TransmogCollection.GetAllAppearanceSources(itemAppearanceID)
    if sourceIDs then
        for _, sourceID in ipairs(sourceIDs) do
            local playerKnowsTransmog = select(5, C_TransmogCollection.GetAppearanceSourceInfo(sourceID))
            if playerKnowsTransmog and (not checkSource or itemModifiedAppearanceID == sourceID) then
                return true
            end
        end
    end

    return false
end

-- Returns whether this item's appearance is already known by the player.
function RCLootCouncil:PlayerKnowsTransmog(link)
    return PlayerKnowsTransmogInternal(link, false)
end

-- Returns whether the transmog is known from this item specifically.
function RCLootCouncil:PlayerKnowsTransmogFromItem(link)
    return  PlayerKnowsTransmogInternal(link, true)
end

-- Returns whether the player can learn the item or not.
function RCLootCouncil:CharacterCanLearnTransmog(link)
    if CanIMogIt then
        return CanIMogIt:CharacterCanLearnTransmog(link)
    end

    local sourceID = select(2, C_TransmogCollection.GetItemInfo(link))
    return select(2, C_TransmogCollection.PlayerCanCollectSource(sourceID))
end
