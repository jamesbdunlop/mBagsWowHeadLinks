local AceGUI = LibStub("AceGUI-3.0")

--# TODO take all the bank items even if soulbound or not into the cache!

function mBagsWowHeadLinks:OnInitialize()
end

function mBagsWowHeadLinks:OnEnable()
    if MBagsWowHeadLinksVariables == nil then
        MBagsWowHeadLinksVariables = {}
    end
    
    local playerName = UnitName("player")
    if not MBagsWowHeadLinksVariables[playerName] then
        -- print("init player entry")
        MBagsWowHeadLinksVariables[playerName] = {}
    end
    if not MBagsWowHeadLinksVariables[playerName]["bankitems"] then
        -- print("init bank cache")
        MBagsWowHeadLinksVariables[playerName]["bankitems"] = {}
    end
    if not MBagsWowHeadLinksVariables[playerName]["bankreagentitems"] then
        -- print("init reagent cache")
        MBagsWowHeadLinksVariables[playerName]["bankreagentitems"] = {}
    end

    -- MBagsWowHeadLinksVariables[playerName]["bankitems"] = {}
    -- MBagsWowHeadLinksVariables[playerName]["bankreagentitems"] = {}
    mBankItemsCurrentCache = MBagsWowHeadLinksVariables[playerName]["bankitems"]
    mBankRegItemsCurrentCache = MBagsWowHeadLinksVariables[playerName]["bankreagentitems"]

    if not MBagsWowHeadLinksVariables[playerName]["iconSize"] then
        -- print("Setting default iconSize to 24")
        MBagsWowHeadLinksVariables[playerName]["iconSize"] = 24
    end

end

function mBagsWowHeadLinks:OnDisable()
end

function mBagsWowHeadLinks:AddItemInfoToTable(itemName, itemInfo, datatable, ignoreSoulBound, itemLink)
    local _, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemLink)
    local url = "https://www.wowhead.com/item="..itemInfo["itemID"].."#comments"
    local finalurl = "|Hurl:" ..url .. "|h[" .. itemName .. "]|h"
    local isBound = itemInfo['isBound']
    if not ignoreSoulBound then
        datatable[itemName] = {itemName, itemInfo["iconFileID"], finalurl, url, itemInfo["hyperlink"], itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent}
    elseif ignoreSoulBound and not isBound then
        datatable[itemName] = {itemName, itemInfo["iconFileID"], finalurl, url, itemInfo["hyperlink"], itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent}
    end
end

-- Function to get sorted keys
function getSortedKeys(tbl)
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

function mBagsWowHeadLinks:listBagItems(ignoreSoulBound, seachString)
    BAGDUMPV1 = {}
    for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
                itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
                expacID, setID, isCraftingReagent = GetItemInfo(itemLink)                
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                if itemName ~= nil and itemInfo ~= nil and string.find(itemName, seachString) ~= nil then
                    mBagsWowHeadLinks:AddItemInfoToTable(itemName, itemInfo, BAGDUMPV1, ignoreSoulBound, itemLink)
                end
            end
        end
    end
    -- SendSystemMessage("Swapped to player inventory!")
    return BAGDUMPV1
end

function mBagsWowHeadLinks:listBankItems(ignoreSoulBound, seachString)
    -- (You need to be at the bank for bank inventory IDs to return valid results) WTF!
    BANKDUMPV1 = {}
    -- DO THE BASE BANK BAG FIRST
    for slot = 1, C_Container.GetContainerNumSlots(BANK_CONTAINER) do
        local itemLink = C_Container.GetContainerItemLink(BANK_CONTAINER, slot)
        if itemLink then
            local itemName = GetItemInfo(itemLink)
            local itemInfo = C_Container.GetContainerItemInfo(BANK_CONTAINER, slot)
            if itemName ~= nil and itemInfo ~= nil and string.find(itemName, seachString) ~= nil then
                mBagsWowHeadLinks:AddItemInfoToTable(itemName, itemInfo, BANKDUMPV1, ignoreSoulBound, itemLink)
            end
        end
    end
    -- Now do the rest of the bank bags..
    for bag = 6, 13 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                local itemName = GetItemInfo(itemLink)
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                if itemName ~= nil and itemInfo ~= nil and string.find(itemName, seachString) ~= nil then
                    mBagsWowHeadLinks:AddItemInfoToTable(itemName, itemInfo, BANKDUMPV1, ignoreSoulBound, itemLink)
                end
            end
        end
    end

    -- Hacky shit cause #BANKDUMPV1 constantly returns 0
    local lengthNum = 0
    for k, v in pairs(BANKDUMPV1) do
        lengthNum = lengthNum + 1
    end
    if lengthNum == 0 then
        -- print("Using bank cache.")
        local searched = {}
        for itemName, data in pairs(mBankItemsCurrentCache) do
            if itemName ~= nil and string.find(itemName, seachString) ~= nil then
                searched[itemName] = data
            end
        end
        return searched
    end
    
    -- print("Using open bank. Caching items now.")
    for itemName, data in pairs(BANKDUMPV1) do
        mBankItemsCurrentCache[itemName] = data
    end
    return BANKDUMPV1
end

function mBagsWowHeadLinks:listBankReagentItems(ignoreSoulBound, seachString)
    BANKRDUMPV1 = {}
    -- (You need to be at the bank for bank inventory IDs to return valid results) WTF!
    for slot = 1, C_Container.GetContainerNumSlots(REAGENTBANK_CONTAINER) do
        local itemLink = C_Container.GetContainerItemLink(REAGENTBANK_CONTAINER, slot)
        if itemLink then
            local itemName = GetItemInfo(itemLink)
            local itemInfo = C_Container.GetContainerItemInfo(REAGENTBANK_CONTAINER, slot)
            if itemName ~= nil and itemInfo ~= nil and string.find(itemName, seachString) ~= nil then
                mBagsWowHeadLinks:AddItemInfoToTable(itemName, itemInfo, BANKRDUMPV1, ignoreSoulBound, itemLink)
            end
        end
    end

    -- Hacky shit cause #BANKRDUMPV1 constantly returns 0
    local lengthNum = 0
    for k, v in pairs(BANKRDUMPV1) do 
        lengthNum = lengthNum + 1
    end
    if lengthNum == 0 then
        -- print("Using reagent bank cache.")
        local searched = {}
        for itemName, data in pairs(mBankRegItemsCurrentCache) do
            if itemName ~= nil and string.find(itemName, seachString) ~= nil then
                searched[itemName] = data
            end
        end
        return searched
    end
    
    -- print("Using open reagent bank. Caching items now.")
    for itemName, data in pairs(BANKRDUMPV1) do
        mBankRegItemsCurrentCache[itemName] = data
    end
    return BANKRDUMPV1
end

local function fixScrollBoxHeight(scrollFrame)
    local height = MBagPane.frame:GetHeight()
    local newHeight = (height-235)
    scrollFrame:SetHeight(newHeight)
end

function mBagsWowHeadLinks:TableContains(myTable, value)
    for _, v in ipairs(myTable) do
        if v == value then
            return true
        end
    end

    return false
end

WHB_EXPANSIONS = {}
WHB_EXPANSIONS[1] =	"The Burning Crusade"
WHB_EXPANSIONS[2] =	"Wrath of the Lich King"
WHB_EXPANSIONS[3] =	"Cataclysm"
WHB_EXPANSIONS[4] =	"Mists of Pandaria"
WHB_EXPANSIONS[5] =	"Warlords of Draenor"
WHB_EXPANSIONS[6] =	"Legion"
WHB_EXPANSIONS[7] =	"Battle for Azeroth"
WHB_EXPANSIONS[8] =	"Shadowlands"
WHB_EXPANSIONS[9] =	"Dragonflight"
local CURRENTEXPAC = "Dragonflight"

function mBagsWowHeadLinks:BagPane()
    local function updateData(groupIndex, ignoreValue, seachString)
        if seachString == nil then seachString = MBGSearchInput:GetText() end
        if seachString == nil then seachString = "" end
        local toShow
        
        if groupIndex == 1 then
            -- print("populating inventory items now")
            toShow = mBagsWowHeadLinks:listBagItems(ignoreValue, seachString)
        elseif groupIndex == 2 then
            -- print("populating bank items now")
            toShow = mBagsWowHeadLinks:listBankItems(ignoreValue, seachString)
        else
            -- print("populating reagent items now")
            toShow = mBagsWowHeadLinks:listBankReagentItems(ignoreValue, seachString)
        end
        return toShow
    end

    local function PopulateDropdown(toShow, scrollContainer, editBox, iconSize)
        scrollContainer:ReleaseChildren()
        sortedKeys = getSortedKeys(toShow)
        
        -- FIND EXPANSIONS ITEMS BELONG TO SO WE CAN CREATE A TAB LAYOUT FOR ITEMS BASED ON EXPAC
        local expacs = {}
        for _, key in ipairs(sortedKeys) do
            local itemInfo = toShow[key]
            local expacID = itemInfo[19]
            local expacName = WHB_EXPANSIONS[expacID]
            if not mBagsWowHeadLinks:TableContains(expacs, expacName) then
                table.insert(expacs, expacName)
            end
        end

        local tabHeaders = {}
        for _, expName in ipairs(expacs) do
            table.insert(tabHeaders, {value = expName, text = expName, userdata = { tabName = expName}})
        end

        -- CREATE THE EXPANSION TABS NOW
        local expacTabGroup = AceGUI:Create("TabGroup")
        expacTabGroup:SetTitle("Expansions")
        expacTabGroup:SetTabs(tabHeaders)
        
        scrollContainer:AddChild(expacTabGroup)
        
        -- Function to populate the tabs when they are selected.
        expacTabGroup:SetCallback("OnGroupSelected",  function(group, event, title)
            CURRENTEXPAC = title
            group:ReleaseChildren()
            for _, expacName in ipairs(expacs) do
                if expacName == CURRENTEXPAC then
                    local scrollFrm = AceGUI:Create("ScrollFrame")
                    scrollFrm:SetLayout("Flow")
                    scrollFrm:SetFullWidth(true)

                    -- print("Populating tab for expac: %s", expacName)
                    local expacInlineGroup = AceGUI:Create("SimpleGroup")
                    expacInlineGroup:SetFullWidth(true)
                    expacInlineGroup.content:SetScript("OnSizeChanged", function() 
                        fixScrollBoxHeight(expacInlineGroup)
                    end)
                    -- Crafted
                    local craftedFrame = AceGUI:Create("InlineGroup")
                    craftedFrame:SetTitle("REAGENTS")
                    craftedFrame:SetLayout("Flow")
                    craftedFrame:SetFullWidth(true)
                  
                    -- Stuff
                    local stuffFrame = AceGUI:Create("InlineGroup")
                    stuffFrame:SetTitle("ITEMS")
                    stuffFrame:SetLayout("Flow")
                    stuffFrame:SetFullWidth(true)
                    for _, key in ipairs(sortedKeys) do
                        itemInfo = toShow[key]
                        local expacID = itemInfo[19]
                        local itemExpacName = WHB_EXPANSIONS[expacID]
                        if itemExpacName == CURRENTEXPAC then 
                            local itemName = itemInfo[1]
                            local icon = itemInfo[2]
                            -- local clickableUrl = itemInfo[3]
                            local url = itemInfo[4]
                            local hyperlink = itemInfo[5]
                            local itemLink = itemInfo[6] 
                            local itemQuality = itemInfo[7] 
                            local itemLevel = itemInfo[8]
                            local itemMinLevel = itemInfo[9]
                            local itemType = itemInfo[10]
                            local itemSubType = itemInfo[11]
                            local itemStackCount = itemInfo[12]
                            local itemEquipLoc = itemInfo[13]
                            local itemTexture = itemInfo[14]
                            local sellPrice = itemInfo[15]
                            local classID = itemInfo[16]
                            local subclassID = itemInfo[17]
                            local bindType = itemInfo[18]
                            local setID = itemInfo[20]
                            local isCraftingReagent = itemInfo[21]
                            -- ICON
                            local interActiveIcon = AceGUI:Create("Icon")
                            interActiveIcon:SetLabel(itemName)
                            -- Note this doesn't work for all icons interActiveIcon:SetImage(C_Item.GetItemIconByID(icon))
                            interActiveIcon:SetImage(MWArtTexturePaths[icon])
                            interActiveIcon:SetImageSize(iconSize, iconSize)
                            interActiveIcon:SetUserData("hyperlink", hyperlink)
                            interActiveIcon:SetUserData("url", url)
                            interActiveIcon:SetCallback("OnEnter", function(widget) 
                                GameTooltip:SetOwner(widget.frame, "ANCHOR_BOTTOMRIGHT")
                                GameTooltip:SetHyperlink(widget:GetUserData("hyperlink")) 
                                GameTooltip:SetSize(80, 50) 
                                GameTooltip:SetWidth(80) GameTooltip:Show() 
                            end)
                            interActiveIcon:SetCallback("OnLeave", function() 
                                GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT")
                                GameTooltip:SetText("")
                                GameTooltip:SetSize(80, 50) 
                                GameTooltip:SetWidth(80) 
                                GameTooltip:Show() end)
                            interActiveIcon:SetCallback("OnClick", function(widget) 
                                editBox:SetText(widget:GetUserData("url"))
                                editBox:SetFocus()
                                editBox:HighlightText(1, 2500)
                                local hyperlink = "|cff007995|Hurl:" .. url .."|h[".. itemName .."]|h|r"
                                -- print(hyperlink)
                            end)
                            if isCraftingReagent then craftedFrame:AddChild(interActiveIcon) 
                            else stuffFrame:AddChild(interActiveIcon) end
                        end
                    end
                    if #craftedFrame.frame:GetChildren() >= 0 then expacInlineGroup:AddChild(craftedFrame) end
                    if #stuffFrame.frame:GetChildren() >= 0 then expacInlineGroup:AddChild(stuffFrame) end
                    
                    scrollFrm.content.obj:AddChild(expacInlineGroup)
                    group.content.obj:AddChild(scrollFrm)
                end
            end
        end)
        expacTabGroup:SelectTab(CURRENTEXPAC)
    end

    MBagPane = AceGUI:Create("Window")
    MBagPane:SetWidth(800)
    MBagPane:SetHeight(600)
    MBagPane:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    MBagPane:SetTitle("Bags: WowHead Url Generator") 
    MBagPane:SetLayout("Fill")
    MBagPane:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    
    local scrollContainer
    local currGroupIndex = 1
    local ignoreValue
    local currentIconSize = 24

    local base = AceGUI:Create("SimpleGroup")
    MBagPane:AddChild(base)

    local urlInput = AceGUI:Create("EditBox")
    urlInput:SetFullWidth(true)
    urlInput:SetText("")
    urlInput:SetLabel("WowHeadUrl:")

    MBGSearchInput = AceGUI:Create("EditBox")
    MBGSearchInput:SetText("")
    MBGSearchInput:SetLabel("Search:")
    MBGSearchInput:SetCallback("OnTextChanged", function(self, event, value)
        local bagData = updateData(currGroupIndex, ignoreValue, value)
        PopulateDropdown(bagData, scrollContainer, urlInput, currentIconSize)
    end)
    
    local searchInputClear = AceGUI:Create("Button")
    searchInputClear:SetText("Clear Search")
    searchInputClear:SetCallback("OnClick", function()
        MBGSearchInput:SetText("")
        local bagData = updateData(currGroupIndex, ignoreValue, "")
        PopulateDropdown(bagData, scrollContainer, urlInput, currentIconSize)
    end)

    local iconSize = AceGUI:Create("Slider")
    iconSize:SetLabel("IconSize")
    iconSize:SetSliderValues(10, 64, 1)
    local playerName = UnitName("player")
    local icSize = MBagsWowHeadLinksVariables[playerName]["iconSize"]
    iconSize:SetValue(icSize)
    iconSize:SetCallback("OnValueChanged", function(self, event, value) 
        local bagData = updateData(currGroupIndex, ignoreValue)
        MBagsWowHeadLinksVariables[playerName]["iconSize"] = value
        PopulateDropdown(bagData, scrollContainer, urlInput, value)
    end)

    ------------------------------------------------------
    local dropDownMenu = AceGUI:Create("DropdownGroup")
    dropDownMenu:SetTitle("Select:")
    dropDownMenu:SetGroupList({"Inventory", "Bank", "Bank Reagents"})
    dropDownMenu:SetLayout("Flow")
    dropDownMenu:SetFullWidth(true)

    -- BASE CONTAINER FOR THE TABS
    scrollContainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    scrollContainer:SetLayout("Fill")
    scrollContainer:SetFullWidth(true)
    scrollContainer.content:SetScript("OnSizeChanged", function() 
        fixScrollBoxHeight(scrollContainer)
    end)
    dropDownMenu:AddChild(scrollContainer)

    -- IGNORE SOULBOUND
    local ignoreCBx = AceGUI:Create("CheckBox")
    ignoreValue = true
    ignoreCBx:SetFullWidth(true)
    ignoreCBx:SetValue(ignoreValue)
    ignoreCBx:SetLabel("Ignore SoulBound Items")
    ignoreCBx:SetCallback("OnValueChanged", function(widget, eventName, value) 
                        ignoreValue= value
                        local bagData = updateData(currGroupIndex, value)
                        PopulateDropdown(bagData, scrollContainer, urlInput, iconSize:GetValue()) end)
    
    dropDownMenu:SetCallback("OnGroupSelected", function(self, event, groupIndex)
        currGroupIndex = groupIndex
        local bagData = updateData(currGroupIndex, ignoreValue)
        PopulateDropdown(bagData, scrollContainer, urlInput, iconSize:GetValue())
    end)
    dropDownMenu:SetGroup(1)
    -- SEARCH BOX
    local searchGrp = AceGUI:Create("SimpleGroup")
    searchGrp:SetFullWidth(true)
    searchGrp:SetLayout("Flow")
    searchGrp:AddChild(MBGSearchInput)
    searchGrp:AddChild(searchInputClear)
    searchGrp:AddChild(iconSize)
    searchGrp:SetHeight(25)
    
    base:AddChild(urlInput)
    base:AddChild(searchGrp)
    base:AddChild(ignoreCBx)
    base:AddChild(dropDownMenu)
end