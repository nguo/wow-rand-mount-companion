local rmcFrame = CreateFrame("Frame", "rmcFrame", UIParent)
local rmcMountButton = CreateFrame("Button", "rmcMountButton", nil, "SecureActionButtonTemplate")
local rmcCompanionButton = CreateFrame("Button", "rmcCompanionButton", nil, "SecureActionButtonTemplate")
rmcMountButton:SetAttribute("type", "item")
rmcCompanionButton:SetAttribute("type", "item")

local groundMounts = {}
local flyingMounts = {}
local companions = {}

local randomMount, randomCompanion

-- certain companions, especially ones from quests / events/ dungeons, are categorized as "Junk" and need special whitelisting
local specialCompanions = { "Scorched Stone", "Magical Crawdad Box", "Miniwing", "Smolderweb Carrier",
  "Chicken Egg", "Mechanical Chicken", "Worg Carrier", "Parrot Cage (Green Wing Macaw)", "Cat Carrier (Siamese)",
  "Wood Frog Box", "Tree Frog Box", "Truesilver Shafted Arrow", "A Jubling's Tiny Home",
  "Piglet's Collar", "Rat Cage", "Turtle Box", "Sleepy Willy", "Elekk Training Collar", "Egbert's Egg",
  "Captured Flame", "Wolpertinger's Tankard", "Pint-Sized Pink Pachyderm", "Sinister Squashling", "Phoenix Hatchling", "Mojo" }
local deviceMounts = { "Turbo-Charged Flying Machine Control", "Flying Machine Control" }
local lvl70GroundMounts = { "Amani War Bear", "Fiery Warhorse's Reins" }

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
          if minLevel == 70 and not contains(lvl70GroundMounts, name) then
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

local function forceGroundMount()
  return GetSubZoneText() == "Throne of Kil'jaeden" and C_QuestLog.IsOnQuest(11516) and not IsQuestComplete(11516)
end

local function skipPet()
  return GetSubZoneText() == "Throne of Kil'jaeden" and C_QuestLog.IsOnQuest(11516) and not IsQuestComplete(11516)
end

function rmcSetRandom(force)
  if IsMounted() and not force then
    return
  end

  if IsFlyableArea() and not forceGroundMount() and #flyingMounts > 0 then
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
  if skipPet() then
    rmcCompanionButton:SetAttribute("item", "")
    return
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
