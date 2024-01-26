---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CACHE_ITEM_COUNT)

---@class CraftSim.CACHE
CraftSim.CACHE = CraftSim.CACHE

---@class CraftSim.CACHE.RECIPE_DATA
CraftSim.CACHE.RECIPE_DATA = {}

---@class CraftSim.ProfessionGearCacheData
---@field cached boolean
---@field equippedGear CraftSim.ProfessionGearSet.Serialized?
---@field availableProfessionGear CraftSim.ProfessionGear.Serialized[]

---@alias CrafterUID string
---@alias RecipeID number

---@class CraftSim.RecipeDataCache
---@field cachedRecipeIDs table<CrafterUID, table<Enum.Profession, RecipeID[]>>
---@field recipeInfoCache table<CrafterUID, table<RecipeID, TradeSkillRecipeInfo>>
---@field professionInfoCache table<CrafterUID, table<RecipeID, ProfessionInfo>>
---@field operationInfoCache table<CrafterUID, table<RecipeID, CraftingOperationInfo>>
---@field specializationDataCache table<CrafterUID, table<RecipeID, CraftSim.SpecializationData.Serialized>?>
---@field professionGearCache table<CrafterUID, table<Enum.Profession, CraftSim.ProfessionGearCacheData>>
---@field altClassCache table<CrafterUID, ClassFile> table<crafterUID, ClassFile>
---@field postLoadedMulticraftInformationProfessions table<Enum.Profession, boolean>
---@field cooldownCache table<CrafterUID, table<RecipeID, CraftSim.CooldownData.Serialized>>
CraftSimRecipeDataCache = CraftSimRecipeDataCache or {
    cachedRecipeIDs = {},
    recipeInfoCache = {},
    professionInfoCache = {},
    operationInfoCache = {},
    specializationDataCache = {},
    professionGearCache = {},
    altClassCache = {},
    postLoadedMulticraftInformationProfessions = {},
    cooldownCache = {},
}

CraftSim.CACHE.RECIPE_DATA.DEFAULT_PROFESSION_GEAR_CACHE_DATA = {
    cached = false,
    equippedGear = nil,
    availableProfessionGear = {},
}

function CraftSim.CACHE.RECIPE_DATA:HandleUpdates()
    if CraftSimRecipeDataCache then
        CraftSimRecipeDataCache.cachedRecipeIDs = CraftSimRecipeDataCache.cachedRecipeIDs or {}
        CraftSimRecipeDataCache.recipeInfoCache = CraftSimRecipeDataCache.recipeInfoCache or {}
        CraftSimRecipeDataCache.professionInfoCache = CraftSimRecipeDataCache.professionInfoCache or {}
        CraftSimRecipeDataCache.operationInfoCache = CraftSimRecipeDataCache.operationInfoCache or {}
        CraftSimRecipeDataCache.specializationDataCache = CraftSimRecipeDataCache.specializationDataCache or {}
        CraftSimRecipeDataCache.professionGearCache = CraftSimRecipeDataCache.professionGearCache or {}
        CraftSimRecipeDataCache.altClassCache = CraftSimRecipeDataCache.altClassCache or {}
        CraftSimRecipeDataCache.postLoadedMulticraftInformationProfessions = CraftSimRecipeDataCache
            .postLoadedMulticraftInformationProfessions or {}
        CraftSimRecipeDataCache.cooldownCache = CraftSimRecipeDataCache.cooldownCache or {}
    end
end

--- Since Multicraft seems to be missing on operationInfo on the first call after a fresh login, and seems to be loaded in after the first call,
--- trigger it for all recipes on purpose when the profession is opened the first time in this session
function CraftSim.CACHE.RECIPE_DATA:TriggerRecipeOperationInfoLoadForProfession(professionRecipeIDs, professionID)
    if not professionID then return end
    if CraftSimRecipeDataCache.postLoadedMulticraftInformationProfessions[professionID] then return end
    if not professionRecipeIDs then
        return
    end
    print("Trigger operationInfo prefetch for: " .. #professionRecipeIDs .. " recipes")

    CraftSim.UTIL:StartProfiling("FORCE_RECIPE_OPERATION_INFOS")
    for _, recipeID in ipairs(professionRecipeIDs) do
        C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {})
    end

    CraftSim.UTIL:StopProfiling("FORCE_RECIPE_OPERATION_INFOS")

    CraftSimRecipeDataCache.postLoadedMulticraftInformationProfessions[professionID] = true
end

function CraftSim.CACHE.RECIPE_DATA:ClearAll()
    wipe(CraftSimRecipeDataCache.cachedRecipeIDs)
    wipe(CraftSimRecipeDataCache.recipeInfoCache)
    wipe(CraftSimRecipeDataCache.professionInfoCache)
    wipe(CraftSimRecipeDataCache.specializationDataCache)
    wipe(CraftSimRecipeDataCache.professionGearCache)
    wipe(CraftSimRecipeDataCache.altClassCache)
    wipe(CraftSimRecipeDataCache.postLoadedMulticraftInformationProfessions)
end