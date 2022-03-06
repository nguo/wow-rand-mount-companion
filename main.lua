local rmcFrame = CreateFrame("Frame", "rmcFrame", UIParent)
local rmcMountButton = CreateFrame("Button", "rmcMountButton", nil, "SecureActionButtonTemplate")
local rmcCompanionButton = CreateFrame("Button", "rmcCompanionButton", nil, "SecureActionButtonTemplate")
rmcMountButton:SetAttribute("type", "item")
rmcCompanionButton:SetAttribute("type", "item")

local groundMounts = {}
local flyingMounts = {}
local companions = {}

local randomMount, randomCompanion

local specialCompanions = { "Scorched Stone" } --"Clockwork Rocket Bot", 
local deviceMounts = { "Turbo-Charged Flying Machine Control", "Flying Machine Control" }

local function contains(items, value)
  for _,v in pairs(items) do
    if (v == value) then
        return true
    end
  end
  return false
end

local function rmcRefreshData()
  local bag
  local slot
  local item

  local newGroundMounts = {}
  local newFlyingMounts = {}
  local newCompanions = {}

  for bag = 0, NUM_BAG_SLOTS do
    for slot = 1, GetContainerNumSlots(bag) do
      item = GetContainerItemID(bag, slot)
      if item ~= nil then
        local name, _, quality, _, minLevel, itype, subtype, _, equipLoc = GetItemInfo(item)
        if quality and quality >= 3 and equipLoc == "" and (subtype == "Mount" or (subtype == "Devices" and contains(deviceMounts, name))) and C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(bag, slot)) then
          if minLevel == 70 then
              table.insert(newFlyingMounts, name)
          else
              table.insert(newGroundMounts, name)
          end
        elseif subtype == "Pet" or contains(specialCompanions, name) then
          table.insert(newCompanions, name)
        end
      end
    end
  end

  groundMounts = newGroundMounts
  flyingMounts = newFlyingMounts
  companions = newCompanions

  rmcSetRandom(true)
end

function rmcSetRandom(force)
  if IsMounted() and not force then
    return
  end

  if IsFlyableArea() and #flyingMounts > 0 then
    mounts = flyingMounts
  else
    mounts = groundMounts
  end

  local numMounts = #mounts
  local numCompanions = #companions

  if numMounts > 0 then
    randomMount = mounts[math.random(numMounts)]
    rmcMountButton:SetAttribute("item", randomMount)
  end
  if numCompanions > 0 then
    lastRandomCompanion = randomCompanion
    randomIndex = math.random(numCompanions)
    randomCompanion = companions[math.random(numCompanions)]
    -- try not to summon the same campanion
    if numCompanions > 1 and lastRandomCompanion == randomCompanion then
      if randomIndex == numCompanions then
        randomCompanion = companions[randomIndex - 1]
      else
        randomCompanion = companions[randomIndex + 1]
      end
    end
    rmcCompanionButton:SetAttribute("item", randomCompanion)
  end
end

rmcFrame:RegisterEvent("BAG_UPDATE_DELAYED")
rmcFrame:SetScript("OnEvent", rmcRefreshData)