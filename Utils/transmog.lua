--- transmog.lua Contains everything related to transmog
-- @author	Urtgard
-- Create Date : 26/5/2023

function RCLootCouncil:IsTransmogable(link)
    if CanIMogIt then
        return CanIMogIt:IsTransmogable(link)
    end

    return C_TransmogCollection.GetItemInfo(link)
end

function RCLootCouncil:PlayerKnowsTransmog(link, checkSource)
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

function RCLootCouncil:PlayerKnowsTransmogFromItem(link)
    return self:PlayerKnowsTransmog(link, true)
end

function RCLootCouncil:CharacterCanLearnTransmog(link)
    if CanIMogIt then
        return CanIMogIt:CharacterCanLearnTransmog(link)
    end

    local sourceID = select(2, C_TransmogCollection.GetItemInfo(link))
    return select(2, C_TransmogCollection.PlayerCanCollectSource(sourceID))
end
