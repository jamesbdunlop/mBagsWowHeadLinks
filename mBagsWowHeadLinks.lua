local AceGUI = LibStub("AceGUI-3.0")

MBagsWowHeadLinksVariables = {}
local playerName = UnitName("player")
mBagPlayerCache = MBagsWowHeadLinksVariables[playerName] or {}
mBankItemsCurrentCache = mBagPlayerCache["bankitems"] or {}
mBankRegItemsCurrentCache = mBagPlayerCache["bankreagentitems"] or {}

function mBagsWowHeadLinks:OnInitialize()
end

function mBagsWowHeadLinks:OnEnable()
end

function mBagsWowHeadLinks:OnDisable()
end

function mBagsWowHeadLinks:AddItemInfoToTable(itemName, itemInfo, datatable, ignoreSoulBound)
    local url = "https://www.wowhead.com/item="..itemInfo["itemID"]
    local finalurl = "|Hurl:" ..url .. "|h[" .. itemName .. "]|h"
    local isBound = itemInfo['isBound']
    if not ignoreSoulBound and isBound then
        table.insert(datatable, {itemName, itemInfo["iconFileID"], finalurl, url, itemInfo["hyperlink"]})
    elseif ignoreSoulBound and isBound then
    else
        table.insert(datatable, {itemName, itemInfo["iconFileID"], finalurl, url, itemInfo["hyperlink"]})
    end
end

function mBagsWowHeadLinks:listBagItems(ignoreSoulBound, seachString)
    BAGDUMPV1 = {}
    for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                local itemName = GetItemInfo(itemLink)
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                if itemName ~= nil and itemInfo ~= nil and string.find(itemName, seachString) ~= nil then
                    mBagsWowHeadLinks:AddItemInfoToTable(itemName, itemInfo, BAGDUMPV1, ignoreSoulBound)
                end
            end
        end
    end
    -- SendSystemMessage("Swapped to player inventory!")
    return BAGDUMPV1
end

function mBagsWowHeadLinks:listBankItems(ignoreSoulBound, seachString)
    BANKDUMPV1 = {}
    -- (You need to be at the bank for bank inventory IDs to return valid results) WTF!
    
    -- DO THE BASE BANK BAG FIRST
    for slot = 1, C_Container.GetContainerNumSlots(BANK_CONTAINER) do
        local itemLink = C_Container.GetContainerItemLink(BANK_CONTAINER, slot)
        if itemLink then
            local itemName = GetItemInfo(itemLink)
            local itemInfo = C_Container.GetContainerItemInfo(BANK_CONTAINER, slot)
            if itemName ~= nil and itemInfo ~= nil and string.find(itemName, seachString) ~= nil then
                mBagsWowHeadLinks:AddItemInfoToTable(itemName, itemInfo, BANKDUMPV1, ignoreSoulBound)
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
                    mBagsWowHeadLinks:AddItemInfoToTable(itemName, itemInfo, BANKDUMPV1, ignoreSoulBound)
                end
            end
        end
    end
    SendSystemMessage("Swapped to open bank bags! If you don't see anything, open your bank!")
    if #BANKDUMPV1 == 0 then
        local searched = {}
        for x, data in ipairs(mBankItemsCurrentCache) do
            local itemName = data[1]
            local itemInfo = data[2]
            if itemName ~= nil and string.find(itemName, seachString) ~= nil then
                table.insert(searched, data)
            end
        end
        return searched
    end
    mBankItemsCurrentCache = BANKDUMPV1
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
                mBagsWowHeadLinks:AddItemInfoToTable(itemName, itemInfo, BANKRDUMPV1, ignoreSoulBound)
            end
        end
    end
    SendSystemMessage("Swapped to Bank reagent bag! If you don't see anything, open your bank!")
    if #BANKRDUMPV1 == 0 then
        local searched = {}
        for x, data in ipairs(mBankRegItemsCurrentCache) do
            local itemName = data[1]
            local itemInfo = data[2]
            if itemName ~= nil and string.find(itemName, seachString) ~= nil then
                table.insert(searched, data)
            end
        end
        return searched
    end
    mBankRegItemsCurrentCache = BANKRDUMPV1
    return BANKRDUMPV1
end

local function fixScrollBoxHeight(scrollFrame)
    local height = MBagPane.frame:GetHeight()
    local newHeight = (height-300)
    scrollFrame:SetHeight(newHeight)
end

function mBagsWowHeadLinks:BagPane()
    local function updateData(groupIndex, ignoreValue, seachString)
        if seachString == nil then seachString = "" end
        local toShow
        if groupIndex == 1 then
            toShow = mBagsWowHeadLinks:listBagItems(ignoreValue, seachString)
        elseif groupIndex == 2 then
            toShow = mBagsWowHeadLinks:listBankItems(ignoreValue, seachString)
        else
            toShow = mBagsWowHeadLinks:listBankReagentItems(ignoreValue, seachString)
        end
        return toShow
    end

    local function PopulateDropdown(toShow, scrollFrame, editBox, iconSize)
        scrollFrame:ReleaseChildren()
        for _, itemInfo in ipairs(toShow) do
            local itemName = itemInfo[1]
            local icon = itemInfo[2]
            -- local clickableUrl = itemInfo[3]
            local url = itemInfo[4]
            local hyperlink = itemInfo[5]
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
                print(hyperlink)
            end)
            
            scrollFrame:AddChild(interActiveIcon)
        end
    end

    MBagPane = AceGUI:Create("Window")
    MBagPane:SetWidth(800)
    MBagPane:SetHeight(600)
    MBagPane:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    MBagPane:SetTitle("Bags: WowHead Url Generator") 
    MBagPane:SetLayout("Fill")
    MBagPane:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    local scrollFrame
    local currGroupIndex = 1
    local ignoreValue
    local currentIconSize = 24

    local base = AceGUI:Create("SimpleGroup")
    MBagPane:AddChild(base)

    local urlInput = AceGUI:Create("EditBox")
    urlInput:SetFullWidth(true)
    urlInput:SetText("")
    urlInput:SetLabel("WowHeadUrl:")

    local searchInput = AceGUI:Create("EditBox")
    -- searchInput:SetFullWidth(true)
    searchInput:SetText("")
    searchInput:SetLabel("Search:")
    searchInput:SetCallback("OnTextChanged", function(self, event, value)
        local bagData = updateData(currGroupIndex, ignoreValue, value)
        PopulateDropdown(bagData, scrollFrame, urlInput, currentIconSize)
    end)
    
    local searchInputClear = AceGUI:Create("Button")
    -- searchInputClear:SetFullWidth(true)
    searchInputClear:SetText("Clear Search")
    searchInputClear:SetCallback("OnClick", function()
        searchInput:SetText("")
        local bagData = updateData(currGroupIndex, ignoreValue, "")
        PopulateDropdown(bagData, scrollFrame, urlInput, currentIconSize)
    end)

    local iconSize = AceGUI:Create("Slider")
    -- iconSize:SetFullWidth(true)
    iconSize:SetLabel("IconSize")
    iconSize:SetSliderValues(10, 64, 1)
    iconSize:SetValue(24)
    iconSize:SetCallback("OnValueChanged", function(self, event, value) 
        local bagData = updateData(currGroupIndex, ignoreValue)
        currentIconSize = value
        PopulateDropdown(bagData, scrollFrame, urlInput, iconSize:GetValue())
    end)

    ------------------------------------------------------
    local dropDownMenu = AceGUI:Create("DropdownGroup")
    dropDownMenu:SetTitle("Select:")
    dropDownMenu:SetGroupList({"Inventory", "Bank", "Bank Reagents"})
    dropDownMenu:SetLayout("Flow")
    dropDownMenu:SetFullWidth(true)

    local scrollcontainer = AceGUI:Create("InlineGroup") -- "InlineGroup" is also good
    scrollcontainer:SetLayout("Flow")
    scrollcontainer:SetFullWidth(true)
    dropDownMenu:AddChild(scrollcontainer)
    
    scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollcontainer:AddChild(scrollFrame)
    scrollFrame.content:SetScript("OnSizeChanged", function() 
        fixScrollBoxHeight(scrollFrame)
        scrollFrame:FixScroll()
    end)

    local ignoreCBx = AceGUI:Create("CheckBox")
    ignoreValue = true
    
    ignoreCBx:SetFullWidth(true)
    ignoreCBx:SetValue(ignoreValue)
    ignoreCBx:SetLabel("Ignore SoulBound Items")
    ignoreCBx:SetCallback("OnValueChanged", function(widget, eventName, value) 
                        ignoreValue= value
                        local bagData = updateData(currGroupIndex, value)
                        PopulateDropdown(bagData, scrollFrame, urlInput, iconSize:GetValue()) end)
    
    dropDownMenu:SetCallback("OnGroupSelected", function(self, event, groupIndex)
        currGroupIndex = groupIndex
        local bagData = updateData(currGroupIndex, ignoreValue)
        PopulateDropdown(bagData, scrollFrame, urlInput, iconSize:GetValue())
    end)

    dropDownMenu:SetGroup(1)

    base:AddChild(urlInput)
    
    local searchGrp = AceGUI:Create("SimpleGroup")
    searchGrp:SetFullWidth(true)
    searchGrp:SetLayout("Flow")
    searchGrp:AddChild(searchInput)
    searchGrp:AddChild(searchInputClear)
    searchGrp:AddChild(iconSize)

    base:AddChild(searchGrp)
    base:AddChild(ignoreCBx)
    base:AddChild(dropDownMenu)
end