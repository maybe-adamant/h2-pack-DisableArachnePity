local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
local lib = mods['adamant-Modpack_Lib']

config = chalk.auto('config.lua')
public.config = config

local backup, restore = lib.createBackupSystem()

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    id       = "DisableArachnePity",
    name     = "Disable Arachne Pity",
    category = "RunModifiers",
    group    = "NPCs & Routing",
    tooltip  = "Disables Arachne Pity entirely for Anyfear runs.",
    default  = false,
    dataMutation = true,
}

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function apply()
    backup(RoomSetData.F.F_Story01, "ForceIfUnseenForRuns")
    RoomSetData.F.F_Story01.ForceIfUnseenForRuns = nil
end

local function registerHooks()
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.enable = apply
public.definition.disable = restore

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if lib.isEnabled(config) then apply() end
        if public.definition.dataMutation and not mods['adamant-Modpack_Core'] then
            SetupRunData()
        end
    end)
end)

local uiCallback = lib.standaloneUI(public.definition, config, apply, restore)
rom.gui.add_to_menu_bar(uiCallback)
