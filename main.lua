local rmcFrame = CreateFrame("Frame", "rmcFrame", UIParent)

local groundMounts = {}
local flyingMounts = {}
local waterMounts = {}
local critters = {}

local randomMount, randomCritter

local playerName = UnitName("player")
local playerConfig = RMCConfig.db[playerName]
local defaultConfig = RMCConfig.db["default"]

local dalaranXCutoff = .6524132
local coldWeatherFlyingSpellId = 54197
local northrendInstanceId = 571

local favGrounds
local favFlyings
local favWaters
local favCritters

if playerConfig and playerConfig.ground and #playerConfig.ground > 0 then
  favGrounds = playerConfig.ground
else
  favGrounds = defaultConfig.ground
end

if playerConfig and playerConfig.flying and #playerConfig.flying > 0 then
  favFlyings = playerConfig.flying
else
  favFlyings = defaultConfig.flying
end

if playerConfig and playerConfig.water and #playerConfig.water > 0 then
  favWaters = playerConfig.water
else
  favWaters = defaultConfig.water
end

if playerConfig and playerConfig.critter and #playerConfig.critter > 0 then
  favCritters = playerConfig.critter
else
  favCritters = defaultConfig.critter
end

local function rmcRefreshData()
  local newGroundMounts = {}
  local newFlyingMounts = {}
  local newWaterMounts = {}
  local newCritters = {}

  local numMounts = GetNumCompanions("MOUNT")
  for slot = 1, numMounts do
    local _, creatureName, _, _, isSummoned = GetCompanionInfo("MOUNT", slot)
    if tContains(favFlyings, creatureName) then
      table.insert(newFlyingMounts, slot)
    elseif tContains(favGrounds, creatureName) then
      table.insert(newGroundMounts, slot)
    elseif tContains(favWaters, creatureName) then
        table.insert(newWaterMounts, slot)
    end
  end

  local numCritters = GetNumCompanions("CRITTER")
  for slot = 1, numCritters do
    local _, creatureName, _, _, isSummoned = GetCompanionInfo("CRITTER", slot)
    if tContains(favCritters, creatureName) then
      table.insert(newCritters, slot)
    end
  end

  groundMounts = newGroundMounts
  flyingMounts = newFlyingMounts
  waterMounts = newWaterMounts
  critters = newCritters
end

local function skipPet()
  -- don't spawn pet for isle daily or venomhide hatchling quests
  return (GetSubZoneText() == "Throne of Kil'jaeden" and C_QuestLog.IsOnQuest(11516) and not IsQuestComplete(11516)) or
    C_QuestLog.IsOnQuest(13904) or C_QuestLog.IsOnQuest(13916) or C_QuestLog.IsOnQuest(13905) or C_QuestLog.IsOnQuest(13915) or
    C_QuestLog.IsOnQuest(13903) or C_QuestLog.IsOnQuest(13889) or C_QuestLog.IsOnQuest(13914) or C_QuestLog.IsOnQuest(13917)
end

local function setButton(button, type, value)
  button:SetAttribute("type", type)
  button:SetAttribute(type, value)
end

local function canFly()
  if GetSubZoneText() == "Throne of Kil'jaeden" and C_QuestLog.IsOnQuest(11516) and not IsQuestComplete(11516) then
    return false
  elseif #flyingMounts == 0 or not IsFlyableArea() then
    return false
  end

  -- if northrend and doesn't know cold weather flying, return false
  local instanceId = select(8, GetInstanceInfo())
  if instanceId == northrendInstanceId and not IsSpellKnown(coldWeatherFlyingSpellId) then
    return false
  end

  -- if in dalaran, can only fly in krasus' landing, but only in the outside area
  local inDalaran = (GetZoneText() == "Dalaran")
  if inDalaran then
    local mapId = C_Map.GetBestMapForUnit("player")
    local position = C_Map.GetPlayerMapPosition(mapId, "player")
    local inKarsus = (GetSubZoneText() == "Krasus' Landing")
    if inKarsus and position ~= nil and position.x >= dalaranXCutoff then
      return true
    end
    return false
  end

  return true
end

function rmcSetRandom(force)
  if IsMounted() and not force then
    return
  end

  rmcRefreshData()

  if canFly() then
    mounts = flyingMounts
  else
    mounts = groundMounts
  end

  local numMounts = #mounts
  local numCritters = #critters

  if not skipPet() then
    if numCritters > 0 then
      lastRandomCritter = randomCritter
      randomIndex = math.random(numCritters)
      randomCritter = critters[math.random(numCritters)]
      -- try not to summon the same campanion
      if numCritters > 1 and lastRandomCritter == randomCritter then
        if randomIndex == numCritters then
          randomCritter = critters[randomIndex - 1]
        else
          randomCritter = critters[randomIndex + 1]
        end
      end
      DismissCompanion("CRITTER")
      CallCompanion("CRITTER", randomCritter)
    end
  end

  if numMounts > 0 then
    CallCompanion("MOUNT", mounts[math.random(numMounts)])
  end
end

-- rmcFrame:RegisterEvent("COMPANION_LEARNED")
-- rmcFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- rmcFrame:SetScript("OnEvent", rmcRefreshData)
