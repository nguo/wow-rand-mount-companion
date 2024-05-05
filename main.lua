local currPet = nil

local function randomPetGuid()
  local numPets, numOwned = C_PetJournal.GetNumPets()
  local favoritePets = {}
  local debugTable = {}

  for i = 1, numPets do
    local petId, _, isOwned, _, _, isFavorite, _, petName = C_PetJournal.GetPetInfoByIndex(i)
    if isFavorite and isOwned then
      table.insert(favoritePets, petId)
      debugTable[petId] = petName
    end
  end

  -- DevTools_Dump(debugTable)

  local nextPet = favoritePets[math.random(#favoritePets)]
  -- print("current pet is", currPet, "next pet will be", nextPet, "num fav", #favoritePets)
  while nextPet == currPet and #favoritePets > 1 do
    nextPet = favoritePets[math.random(#favoritePets)]
  end

  return nextPet
end

function rmcDismissPet()
  DismissCompanion("CRITTER")
end

function rmcSummonPet()
  local guid = randomPetGuid()
  if guid ~= nil then
    currPet = guid
    C_PetJournal.SummonPetByGUID(guid)
  end
end
