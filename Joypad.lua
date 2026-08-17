-- Joypad
-- Standalone Wrath 3.3.5a-safe action button display.
-- Creates Joypad-owned protected action buttons instead of moving Blizzard frames.
-- Row 1: ACTIONBUTTON1-12          -> Joypad slots 1-12
-- Row 2: MULTIACTIONBAR3BUTTON1-12 -> Joypad slots 13-24
-- Each Joypad slot can have Base, Shift, Ctrl, and Shift+Ctrl assignments.

local ADDON_NAME = "Joypad"
local VERSION = "0.44.91-p6z17-keybind-icon-cache-fix"


-- Blizzard Key Bindings screen labels. CLICK binding globals are stored through _G because the keys contain spaces/colons.
BINDING_HEADER_JOYPAD = "Joypad"
_G["BINDING_NAME_CLICK JoypadButton1:LeftButton"] = "Joypad 1 - A"
_G["BINDING_NAME_CLICK JoypadButton2:LeftButton"] = "Joypad 2 - B"
_G["BINDING_NAME_CLICK JoypadButton3:LeftButton"] = "Joypad 3 - X"
_G["BINDING_NAME_CLICK JoypadButton4:LeftButton"] = "Joypad 4 - Y"
_G["BINDING_NAME_CLICK JoypadButton5:LeftButton"] = "Joypad 5 - ^"
_G["BINDING_NAME_CLICK JoypadButton6:LeftButton"] = "Joypad 6 - <"
_G["BINDING_NAME_CLICK JoypadButton7:LeftButton"] = "Joypad 7 - >"
_G["BINDING_NAME_CLICK JoypadButton8:LeftButton"] = "Joypad 8 - v"
_G["BINDING_NAME_CLICK JoypadButton9:LeftButton"] = "Joypad 9 - L1"
_G["BINDING_NAME_CLICK JoypadButton10:LeftButton"] = "Joypad 10 - R1"
_G["BINDING_NAME_CLICK JoypadButton11:LeftButton"] = "Joypad 11 - SELECT"
_G["BINDING_NAME_CLICK JoypadButton12:LeftButton"] = "Joypad 12 - START"
_G["BINDING_NAME_CLICK JoypadButton13:LeftButton"] = "Joypad 13 - L^"
_G["BINDING_NAME_CLICK JoypadButton14:LeftButton"] = "Joypad 14 - L<"
_G["BINDING_NAME_CLICK JoypadButton15:LeftButton"] = "Joypad 15 - L>"
_G["BINDING_NAME_CLICK JoypadButton16:LeftButton"] = "Joypad 16 - Lv"
_G["BINDING_NAME_CLICK JoypadButton17:LeftButton"] = "Joypad 17 - R^"
_G["BINDING_NAME_CLICK JoypadButton18:LeftButton"] = "Joypad 18 - R<"
_G["BINDING_NAME_CLICK JoypadButton19:LeftButton"] = "Joypad 19 - R>"
_G["BINDING_NAME_CLICK JoypadButton20:LeftButton"] = "Joypad 20 - Rv"
_G["BINDING_NAME_CLICK JoypadButton21:LeftButton"] = "Joypad 21 - L4"
_G["BINDING_NAME_CLICK JoypadButton22:LeftButton"] = "Joypad 22 - R4"
_G["BINDING_NAME_CLICK JoypadButton23:LeftButton"] = "Joypad 23 - L5"
_G["BINDING_NAME_CLICK JoypadButton24:LeftButton"] = "Joypad 24 - R5"

local BUTTON_SIZE = 50
local ALT_TEXT_BASE_FONT = "Fonts\\FRIZQT__.TTF"
local ALT_TEXT_BASE_FONT_SIZE = 12
local ALT_TEXT_FONT_FLAGS = "THICKOUTLINE"
local BUTTON_GAP = 3
local BAR_GAP = 4
local ROW2_DEFAULT_Y = -47
local BUTTONS_PER_BAR = 12
local GRID_STEP = 50

-- Cooldown text overlay is defined on the Joypad frame later in the file to
-- avoid Wrath Lua's very small top-level local-variable limit.

local SETTINGS_BOTTOM_INSET = 28
local SETTINGS_BOTTOM_PADDING = 44

local X_OFFSET = 0
local Y_OFFSET = 0

-- Wrath action slot mapping:
-- Main action bar:      1-12
-- MultiActionBar 3:     25-36 (Blizzard frame family: MultiBarRightButton1-12)
local BAR_DEFS = {
    {
        name = "ACTIONBUTTON",
        bindingPrefix = "ACTIONBUTTON",
        firstActionSlot = 1,
        row = 1,
    },
    {
        name = "MULTIACTIONBAR3BUTTON",
        bindingPrefix = "MULTIACTIONBAR3BUTTON",
        firstActionSlot = 25,
        row = 2,
    },
}

-- Keybind command presets for Bindings -> Keybind mode.
-- The command values are Blizzard binding command names used by SetOverrideBinding.
local KEYBIND_COMMAND_PRESETS = {
    { label = "JUMP",       command = "JUMP" },
    { label = "TARGET",     command = "TARGETNEARESTENEMY" },
    { label = "INTERACT",   command = "INTERACTIONKEYBIND" },
    { label = "FRIEND",     command = "TARGETNEARESTFRIEND" },
    { label = "FOCUS",      command = "TARGETFOCUS" },
    { label = "SELF",       command = "TARGETSELF" },
    { label = "P1",         command = "TARGETPARTYMEMBER1" },
    { label = "P2",         command = "TARGETPARTYMEMBER2" },
    { label = "P3",         command = "TARGETPARTYMEMBER3" },
    { label = "P4",         command = "TARGETPARTYMEMBER4" },
    { label = "PET1",       command = "TARGETPARTYPET1" },
    { label = "PET2",       command = "TARGETPARTYPET2" },
    { label = "PET3",       command = "TARGETPARTYPET3" },
    { label = "PET4",       command = "TARGETPARTYPET4" },
    { label = "PET ATTACK", command = "PETATTACK" },
    { label = "PET STAY",   command = "PETSTAY" },
    { label = "PET",        command = "TARGETPET" },
    { label = "PET ACT 4",  command = "BONUSACTIONBUTTON4" },
    { label = "PET ACT 5",  command = "BONUSACTIONBUTTON5" },
    { label = "PET ACT 6",  command = "BONUSACTIONBUTTON6" },
    { label = "PET ACT 7",  command = "BONUSACTIONBUTTON7" },
    { label = "DISMOUNT",   command = "DISMOUNT" },
    { label = "STOP",       command = "STOPATTACK" },
    { label = "SIT/STAND",  command = "SITORSTAND" },
    { label = "MAP",        command = "TOGGLEWORLDMAP" },
    { label = "CHARACTER",  command = "TOGGLECHARACTER0" },
    { label = "ACHIEVE",    command = "TOGGLEACHIEVEMENT" },
    { label = "LOG",        command = "TOGGLEQUESTLOG" },
    { label = "FRIENDS",    command = "TOGGLEFRIENDSTAB" },
    { label = "GUILD",      command = "TOGGLEGUILDTAB" },
    { label = "RAID",       command = "TOGGLERAIDTAB" },
    { label = "LFG",        command = "TOGGLELFGPARENT" },
    { label = "MENU",       command = "TOGGLEGAMEMENU" },
    { label = "BAGS",       command = "OPENALLBAGS" },
    { label = "SPELLS",     command = "TOGGLESPELLBOOK" },
    { label = "TALENTS",    command = "TOGGLETALENTS" },
    { label = "PET BOOK",   command = "TOGGLEPETBOOK" },
    { label = "CURRENCY",   command = "TOGGLECURRENCY" },
    { label = "CHAT UP",    command = "CHATPAGEUP" },
    { label = "CHAT DOWN",  command = "CHATPAGEDOWN" },
    { label = "SCREENSHOT", command = "SCREENSHOT" },
    { label = "ZOOM IN",    command = "CAMERAZOOMIN" },
    { label = "ZOOM OUT",   command = "CAMERAZOOMOUT" },
    { label = "RUN",        command = "TOGGLEAUTORUN" },
    { label = "FOLLOW",     command = "FOLLOWTARGET" },
}

local KEYBIND_COMMAND_ICONS = {
    -- controller-style custom icons copied into Joypad/Textures/Icons.
    JUMP = "Interface\\AddOns\\Joypad\\Textures\\Icons\\Jump",
    TOGGLEAUTORUN = "Interface\\AddOns\\Joypad\\Textures\\Icons\\Run",
    OPENALLBAGS = "Interface\\AddOns\\Joypad\\Textures\\Icons\\Bags",
    TOGGLEGAMEMENU = "Interface\\AddOns\\Joypad\\Textures\\Icons\\Menu",
    TOGGLEWORLDMAP = "Interface\\AddOns\\Joypad\\Textures\\Icons\\Map",
    TARGETNEARESTENEMY = "Interface\\AddOns\\Joypad\\Textures\\Icons\\Target",
    TARGETNEARESTFRIEND = "Interface\\AddOns\\Joypad\\Textures\\Icons\\Target",
    JOYPAD = "Interface\\AddOns\\Joypad\\Textures\\JoypadIcon",

    -- AwesomeWotLK native smart interaction. Use WoW's stock interact cursor
    -- artwork so the controller overlay keeps the familiar interaction visual
    -- without depending on any ConsoleXP addon assets. Legacy aliases share it.
    INTERACTIONKEYBIND = "Interface\\Cursor\\Interact",
    INTERACTTARGET = "Interface\\Cursor\\Interact",
    CXPINTERACT = "Interface\\Cursor\\Interact",

    -- Blizzard client icons matching ConsolePortBar/Core/Lookup.lua where available.
    FOLLOWTARGET = "Interface\\Icons\\Ability_Hunter_MarkedForDeath",
    TOGGLEQUESTLOG = "Interface\\Icons\\INV_Misc_Note_02",
    TOGGLECHARACTER0 = "Interface\\Icons\\INV_Chest_Cloth_17",
    TOGGLESPELLBOOK = "Interface\\Icons\\INV_Misc_Book_09",
    TOGGLETALENTS = "Interface\\Icons\\Ability_Marksmanship",
    CAMERAZOOMIN = "Interface\\Icons\\INV_Misc_Spyglass_02",
    CAMERAZOOMOUT = "Interface\\Icons\\INV_Misc_Spyglass_03",
    PETATTACK = "Interface\\Icons\\ABILITY_HUNTER_INVIGERATION",
    PETSTAY = "Interface\\Icons\\Ability_Hunter_BeastCall",
    TARGETPET = "Interface\\Icons\\Spell_Magic_PolymorphRabbit",
    BONUSACTIONBUTTON4 = "Interface\\Icons\\Ability_Hunter_BeastCall",
    BONUSACTIONBUTTON5 = "Interface\\Icons\\Ability_Hunter_BeastCall",
    BONUSACTIONBUTTON6 = "Interface\\Icons\\Ability_Hunter_BeastCall",
    BONUSACTIONBUTTON7 = "Interface\\Icons\\Ability_Hunter_BeastCall",
    STOPATTACK = "Interface\\Icons\\Ability_SteelMelee",
    TARGETFOCUS = "Interface\\Icons\\Ability_Hunter_MasterMarksman",

    -- Useful Joypad defaults not explicitly covered by the ConsolePortBar snippet.
    TARGETPARTYMEMBER1 = "Interface\\Icons\\Spell_Misc_EmotionAfraid",
    TARGETPARTYMEMBER2 = "Interface\\Icons\\Spell_Misc_EmotionAngry",
    TARGETPARTYMEMBER3 = "Interface\\Icons\\Spell_Misc_EmotionHappy",
    TARGETPARTYMEMBER4 = "Interface\\Icons\\Spell_Misc_EmotionSad",
    TARGETSELF = "Interface\\Icons\\Spell_DeathKnight_IceBoundFortitude",
    TARGETPARTYPET1 = "Interface\\Icons\\Spell_Nature_Polymorph_Cow",
    TARGETPARTYPET2 = "Interface\\Icons\\Spell_Nature_Polymorph",
    TARGETPARTYPET3 = "Interface\\Icons\\Spell_Magic_PolymorphPig",
    TARGETPARTYPET4 = "Interface\\Icons\\Spell_Magic_PolymorphChicken",
    TOGGLEACHIEVEMENT = "Interface\\Icons\\Achievement_General",
    TOGGLEGUILDTAB = "Interface\\Icons\\INV_BannerPVP_02",
    TOGGLERAIDTAB = "Interface\\Icons\\INV_Misc_GroupLooking",
    -- Wrath 3.3.5a Looking For Group icon.  If a private client skin replaces it,
    -- external addons still get the stable LFG command/text through JoypadAPI.
    TOGGLELFGPARENT = "Interface\\Icons\\INV_Misc_GroupLooking",
    CHATPAGEUP = "Interface\\Icons\\INV_Misc_Note_01",
    CHATPAGEDOWN = "Interface\\Icons\\INV_Misc_Note_01",
    TOGGLECURRENCY = "Interface\\Icons\\INV_Misc_Coin_01",
    TOGGLEPETBOOK = "Interface\\Icons\\Ability_Hunter_BeastTraining",
    DISMOUNT = "Interface\\Icons\\Ability_Mount_RidingHorse",
    SITORSTAND = "Interface\\Icons\\Spell_Nature_Sleep",
    TOGGLEFRIENDSTAB = "Interface\\Icons\\INV_Misc_GroupNeedMore",
}

-- Blizzard's original visible action-button families.
-- The Hide Blizzard bars option uses this single list, so it is easy to refine later.
local BLIZZARD_ACTION_BUTTON_PREFIXES = {
    "ActionButton",              -- Main Action Bar, slots 1-12
    "MultiBarRightButton",       -- Right Bar, slots 25-36
    "MultiBarLeftButton",        -- Right Bar 2, slots 37-48
    "MultiBarBottomRightButton", -- Bottom Right Bar, slots 49-60
    "MultiBarBottomLeftButton",  -- Bottom Left Bar, slots 61-72
}

-- Extra Blizzard art/background objects that are visually part of the default
-- action-bar shell.  We intentionally do not hide MicroButtonAndBagsBar,
-- MainMenuBarBackpackButton, CharacterBag*Slot, the micro-menu buttons,
-- MainMenuExpBar, or XP/reputation progress bar textures.
local BLIZZARD_ACTION_ART_OBJECTS = {
    -- Main bar griffins and grey action-bar backing.
    -- XP / reputation / max-level progress bars are deliberately left alone.
    "MainMenuBarLeftEndCap",
    "MainMenuBarRightEndCap",
    "MainMenuBarTexture0",
    "MainMenuBarTexture1",
    "MainMenuBarTexture2",
    "MainMenuBarTexture3",
    "MainMenuBarTextureExtender",
    "ActionBarUpButton",
    "ActionBarDownButton",
    "MainMenuBarPageNumber",
}


-- Single source of truth for the controller-style Alt labels and their renderer.
--
-- Alt labels are grouped and auto-fitted instead of hand-tuned as fixed whole
-- string percentages.  Each group defines how much of the parent button width
-- the label should occupy and how tall it may become.
--
-- Each ALT_LABELS entry can be a normal one-part label or a split/multi-part
-- label.  Split labels such as L^ and Rv stay as separate FontStrings so the
-- L/R prefix and direction marker can be balanced independently, then fitted
-- together as one combined visual label.
--
-- Only use glyphs that are known to render in this Wrath client/font.  The
-- Unicode chevrons ˄ and ˅ render as ? for this user, so keep ^, ‹, ›, and v.
local ALT_LABEL_GROUPS = {
    face = {
        targetWidthPct = 0.76,
        maxHeightPct = 0.36,
        minScale = 0.50,
        maxScale = 2.40,
    },
    dpadDirection = {
        targetWidthPct = 0.88,
        maxHeightPct = 0.48,
        minScale = 0.50,
        maxScale = 8.00,
    },
    shoulderRear = {
        targetWidthPct = 0.84,
        maxHeightPct = 0.36,
        minScale = 0.50,
        maxScale = 2.60,
    },
    centreWord = {
        targetWidthPct = 0.92,
        maxHeightPct = 0.28,
        minScale = 0.35,
        maxScale = 1.90,
    },
    splitDirection = {
        targetWidthPct = 0.90,
        maxHeightPct = 0.48,
        minScale = 0.50,
        maxScale = 8.00,
    },
}

local ALT_LABELS = {
    -- Joypad row 1, slots 1-12
    [1] = { label = "A",      group = "face",          parts = { { text = "A",      scale = 1.00, x = 0,  y = 0  } } },
    [2] = { label = "B",      group = "face",          parts = { { text = "B",      scale = 1.00, x = 0,  y = 0  } } },
    [3] = { label = "X",      group = "face",          parts = { { text = "X",      scale = 1.00, x = 0,  y = 0  } } },
    [4] = { label = "Y",      group = "face",          parts = { { text = "Y",      scale = 1.00, x = 0,  y = 0  } } },
    [5] = { label = "^",      group = "dpadDirection", parts = { { text = "^",      scale = 7.75, x = 0,  y = -1 } } },
    [6] = { label = "<",      group = "dpadDirection", parts = { { text = "<",      scale = 6.75, x = 0,  y = 0  } } },
    [7] = { label = ">",      group = "dpadDirection", parts = { { text = ">",      scale = 6.75, x = 0,  y = 0  } } },
    [8] = { label = "v",      group = "dpadDirection", parts = { { text = "v",      scale = 6.75, x = 0,  y = 1  } } },
    [9] = { label = "L1",     group = "shoulderRear",  parts = { { text = "L1",     scale = 1.00, x = 0,  y = 0  } } },
    [10] = { label = "R1",    group = "shoulderRear",  parts = { { text = "R1",    scale = 1.00, x = 0,  y = 0  } } },
    [11] = { label = "SELECT", group = "centreWord",   parts = { { text = "SELECT", scale = 1.00, x = 0,  y = 0  } } },
    [12] = { label = "START", group = "centreWord",    parts = { { text = "START",  scale = 1.00, x = 0,  y = 0  } } },

    -- Joypad row 2, slots 13-24
    -- Diamond positioning:
    --   ^  = top, slight nudge left
    --   <  = middle-left
    --   >  = middle-right
    --   v  = bottom-centre
    [13] = { label = "L^", group = "splitDirection", parts = { { text = "L", scale = 0.70, x = -7, y = 0, colorRole = "leftTrackpadPrefix",  diamondX = -4,  diamondY = -5  }, { text = "^", scale = 2.20, x = 4, y = -1, diamondX = -4,  diamondY = -5  } } },
    [14] = { label = "L<", group = "splitDirection", parts = { { text = "L", scale = 0.70, x = -7, y = 0, colorRole = "leftTrackpadPrefix",  diamondX = -22, diamondY = -25 }, { text = "<", scale = 2.05, x = 5, y = 0,  diamondX = -22, diamondY = -25 } } },
    [15] = { label = "L>", group = "splitDirection", parts = { { text = "L", scale = 0.70, x = -7, y = 0, colorRole = "leftTrackpadPrefix",  diamondX = 18,  diamondY = -25 }, { text = ">", scale = 2.05, x = 5, y = 0,  diamondX = 18,  diamondY = -25 } } },
    [16] = { label = "Lv", group = "splitDirection", parts = { { text = "L", scale = 0.70, x = -7, y = 0, colorRole = "leftTrackpadPrefix",  diamondX = -2,  diamondY = -43 }, { text = "v", scale = 1.95, x = 4, y = 1,  diamondX = -2,  diamondY = -43 } } },

    [17] = { label = "R^", group = "splitDirection", parts = { { text = "R", scale = 0.70, x = -7, y = 0, colorRole = "rightTrackpadPrefix", diamondX = -4,  diamondY = -5  }, { text = "^", scale = 2.20, x = 4, y = -1, diamondX = -4,  diamondY = -5  } } },
    [18] = { label = "R<", group = "splitDirection", parts = { { text = "R", scale = 0.70, x = -7, y = 0, colorRole = "rightTrackpadPrefix", diamondX = -22, diamondY = -25 }, { text = "<", scale = 2.05, x = 5, y = 0,  diamondX = -22, diamondY = -25 } } },
    [19] = { label = "R>", group = "splitDirection", parts = { { text = "R", scale = 0.70, x = -7, y = 0, colorRole = "rightTrackpadPrefix", diamondX = 18,  diamondY = -25 }, { text = ">", scale = 2.05, x = 5, y = 0,  diamondX = 18,  diamondY = -25 } } },
    [20] = { label = "Rv", group = "splitDirection", parts = { { text = "R", scale = 0.70, x = -7, y = 0, colorRole = "rightTrackpadPrefix", diamondX = -2,  diamondY = -43 }, { text = "v", scale = 1.95, x = 4, y = 1,  diamondX = -2,  diamondY = -43 } } },

    [21] = { label = "L4", group = "shoulderRear", parts = { { text = "L4", scale = 1.00, x = 0, y = 0 } } },
    [22] = { label = "R4", group = "shoulderRear", parts = { { text = "R4", scale = 1.00, x = 0, y = 0 } } },
    [23] = { label = "L5", group = "shoulderRear", parts = { { text = "L5", scale = 1.00, x = 0, y = 0 } } },
    [24] = { label = "R5", group = "shoulderRear", parts = { { text = "R5", scale = 1.00, x = 0, y = 0 } } },
}

-- Optional alternate face-button display modes.  Xbox and Steam preserve the
-- current A/B/X/Y display.  PlayStation and Nintendo only change the four
-- face-button visual labels and their default colours; action slots and
-- bindings stay the same.
JOYPAD_PLAYSTATION_ALT_LABELS = {
    [1] = { label = "X",  group = "face", parts = { { text = "X",  scale = 1.00, x = 0, y = 0 } } }, -- A / Cross
    [2] = { label = "O",  group = "face", parts = { { text = "O",  scale = 1.00, x = 0, y = 0 } } }, -- B / Circle
    [3] = { label = "[]", group = "face", parts = { { text = "[]", scale = 0.82, x = 0, y = 0 } } }, -- X / Square
    [4] = { label = "^",  group = "face", parts = { { text = "^",  scale = 0.95, x = 0, y = 0 } } }, -- Y / Triangle
}

JOYPAD_PLAYSTATION_ALT_TEXT_COLORS = {
    [1] = { r = 0.18, g = 0.55, b = 1.00, a = 1.0 }, -- Cross / X
    [2] = { r = 1.00, g = 0.22, b = 0.22, a = 1.0 }, -- Circle / O
    [3] = { r = 1.00, g = 0.27, b = 0.75, a = 1.0 }, -- Square / []
    [4] = { r = 0.27, g = 0.90, b = 0.35, a = 1.0 }, -- Triangle / ^
}

JOYPAD_NINTENDO_ALT_LABELS = {
    [1] = { label = "B", group = "face", parts = { { text = "B", scale = 1.00, x = 0, y = 0 } } }, -- A button shows Nintendo B
    [2] = { label = "A", group = "face", parts = { { text = "A", scale = 1.00, x = 0, y = 0 } } }, -- B button shows Nintendo A
    [3] = { label = "Y", group = "face", parts = { { text = "Y", scale = 1.00, x = 0, y = 0 } } }, -- X button shows Nintendo Y
    [4] = { label = "X", group = "face", parts = { { text = "X", scale = 1.00, x = 0, y = 0 } } }, -- Y button shows Nintendo X
}

JOYPAD_NINTENDO_ALT_TEXT_COLORS = {
    [1] = { r = 1.00, g = 0.78, b = 0.00, a = 1.0 }, -- B / Yellow
    [2] = { r = 0.92, g = 0.16, b = 0.16, a = 1.0 }, -- A / Red
    [3] = { r = 0.10, g = 0.78, b = 0.28, a = 1.0 }, -- Y / Green
    [4] = { r = 0.18, g = 0.45, b = 1.00, a = 1.0 }, -- X / Blue
}

JOYPAD_PLAYSTATION_DIRECTION_TEXT_COLORS = {
    up = { r = 0.27, g = 0.90, b = 0.35, a = 1.0 },    -- ^ / Triangle
    left = { r = 1.00, g = 0.27, b = 0.75, a = 1.0 },  -- < / Square
    right = { r = 1.00, g = 0.22, b = 0.22, a = 1.0 }, -- > / Circle
    down = { r = 0.18, g = 0.55, b = 1.00, a = 1.0 },  -- v / Cross
}

JOYPAD_NINTENDO_DIRECTION_TEXT_COLORS = {
    up = { r = 0.18, g = 0.45, b = 1.00, a = 1.0 },    -- X / Blue
    left = { r = 0.10, g = 0.78, b = 0.28, a = 1.0 },  -- Y / Green
    right = { r = 0.92, g = 0.16, b = 0.16, a = 1.0 }, -- A / Red
    down = { r = 1.00, g = 0.78, b = 0.00, a = 1.0 },  -- B / Yellow
}

function JoypadGetDirectionColorKeyForSlot(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0

    if joypadSlot == 5 or joypadSlot == 13 or joypadSlot == 17 then
        return "up"
    elseif joypadSlot == 6 or joypadSlot == 14 or joypadSlot == 18 then
        return "left"
    elseif joypadSlot == 7 or joypadSlot == 15 or joypadSlot == 19 then
        return "right"
    elseif joypadSlot == 8 or joypadSlot == 16 or joypadSlot == 20 then
        return "down"
    end

    return nil
end

-- Optional per-slot Alt % remains as a user modifier on top of the group
-- auto-fit result.  Default 100 means use the auto-fit size exactly.
JOYPAD_DEFAULT_SLOT_POSITIONS = {
    [1] = { x = 247, y = -333 },
    [2] = { x = 297, y = -283 },
    [3] = { x = 197, y = -283 },
    [4] = { x = 247, y = -233 },
    [5] = { x = -247, y = -233 },
    [6] = { x = -297, y = -283 },
    [7] = { x = -197, y = -283 },
    [8] = { x = -247, y = -333 },
    [9] = { x = -247, y = -283 },
    [10] = { x = 247, y = -283 },
    [11] = { x = -162, y = -217 },
    [12] = { x = 162, y = -217 },
    [13] = { x = -96, y = -284 },
    [14] = { x = -126, y = -313 },
    [15] = { x = -67, y = -313 },
    [16] = { x = -96, y = -342 },
    [17] = { x = 96, y = -284 },
    [18] = { x = 67, y = -313 },
    [19] = { x = 126, y = -313 },
    [20] = { x = 96, y = -342 },
    [21] = { x = -316, y = -212 },
    [22] = { x = 316, y = -212 },
    [23] = { x = -316, y = -350 },
    [24] = { x = 316, y = -350 },
}

JOYPAD_DEFAULT_SLOT_SCALES = {
    [1] = 82,
    [2] = 82,
    [3] = 82,
    [4] = 82,
    [5] = 82,
    [6] = 82,
    [7] = 82,
    [8] = 82,
    [9] = 82,
    [10] = 82,
    [11] = 82,
    [12] = 82,
    [13] = 82,
    [14] = 82,
    [15] = 82,
    [16] = 82,
    [17] = 82,
    [18] = 82,
    [19] = 82,
    [20] = 82,
    [21] = 82,
    [22] = 82,
    [23] = 82,
    [24] = 82,
}

local DEFAULT_ALT_TEXT_SCALES = {
    [1] = 100,
    [2] = 100,
    [3] = 100,
    [4] = 100,
    [5] = 100,
    [6] = 100,
    [7] = 100,
    [8] = 100,
    [9] = 100,
    [10] = 100,
    [11] = 100,
    [12] = 100,
    [13] = 100,
    [14] = 100,
    [15] = 100,
    [16] = 100,
    [17] = 100,
    [18] = 100,
    [19] = 100,
    [20] = 100,
    [21] = 100,
    [22] = 100,
    [23] = 100,
    [24] = 100,
}

JOYPAD_DEFAULT_ALT_TEXT_COLORS = {
    -- ==========================================
    -- FACE BUTTONS (Core Palette)
    -- ==========================================
    [1]  = { r = 0.00, g = 1.00, b = 0.20, a = 1.0 }, -- A
    [2]  = { r = 1.00, g = 0.05, b = 0.05, a = 1.0 }, -- B
    [3]  = { r = 0.10, g = 0.50, b = 1.00, a = 1.0 }, -- X
    [4]  = { r = 1.00, g = 0.85, b = 0.00, a = 1.0 }, -- Y

    -- ==========================================
    -- MAIN D-PAD (Matched to Face Buttons)
    -- ==========================================
    [5]  = { r = 1.00, g = 0.85, b = 0.00, a = 1.0 }, -- ^
    [6]  = { r = 0.10, g = 0.50, b = 1.00, a = 1.0 }, -- <
    [7]  = { r = 1.00, g = 0.05, b = 0.05, a = 1.0 }, -- >
    [8]  = { r = 0.00, g = 1.00, b = 0.20, a = 1.0 }, -- v

    -- ==========================================
    -- MAIN BUMPERS (L1 / R1)
    -- ==========================================
    [9]  = { r = 1.00, g = 0.00, b = 0.65, a = 1.0 }, -- L1
    [10] = { r = 0.00, g = 1.00, b = 1.00, a = 1.0 }, -- R1

    -- ==========================================
    -- SYSTEM BUTTONS (SELECT / START)
    -- ==========================================
    [11] = { r = 1.00, g = 0.50, b = 0.00, a = 1.0 }, -- SELECT (VIEW)
    [12] = { r = 0.78, g = 0.20, b = 1.00, a = 1.0 }, -- START (MENU)

    -- ==========================================
    -- LEFT TRACKPAD DIRECTIONS (Matched to Face)
    -- ==========================================
    [13] = { r = 1.00, g = 0.85, b = 0.00, a = 1.0 }, -- L^
    [14] = { r = 0.10, g = 0.50, b = 1.00, a = 1.0 }, -- L‹
    [15] = { r = 1.00, g = 0.05, b = 0.05, a = 1.0 }, -- L›
    [16] = { r = 0.00, g = 1.00, b = 0.20, a = 1.0 }, -- Lv

    -- ==========================================
    -- RIGHT TRACKPAD DIRECTIONS (Matched to Face)
    -- ==========================================
    [17] = { r = 1.00, g = 0.85, b = 0.00, a = 1.0 }, -- R^
    [18] = { r = 0.10, g = 0.50, b = 1.00, a = 1.0 }, -- R‹
    [19] = { r = 1.00, g = 0.05, b = 0.05, a = 1.0 }, -- R›
    [20] = { r = 0.00, g = 1.00, b = 0.20, a = 1.0 }, -- Rv

    -- ==========================================
    -- BACK GRIP KEYS (L4 / L5 & R4 / R5)
    -- ==========================================
    [21] = { r = 1.00, g = 0.35, b = 0.55, a = 1.0 }, -- L4
    [22] = { r = 1.00, g = 0.65, b = 0.40, a = 1.0 }, -- R4
    [23] = { r = 0.55, g = 0.75, b = 1.00, a = 1.0 }, -- L5
    [24] = { r = 0.40, g = 1.00, b = 0.70, a = 1.0 }, -- R5
}

JOYPAD_DEFAULT_ALT_PART_TEXT_COLORS = {
    -- ==========================================
    -- PREFIX KEYS (L / R)
    -- ==========================================
    leftTrackpadPrefix  = { r = 0.00, g = 0.75, b = 1.00, a = 1.0 }, -- L
    rightTrackpadPrefix = { r = 1.00, g = 0.30, b = 0.30, a = 1.0 }, -- R
}

JOYPAD_ALT_PART_COLOR_LABELS = {
    leftTrackpadPrefix = "Left trackpad L prefix",
    rightTrackpadPrefix = "Right trackpad R prefix",
}

JOYPAD_DEFAULT_DIAMOND_SLOTS = {
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [17] = true,
    [18] = true,
    [19] = true,
    [20] = true,
}

-- Standalone Touch Bar.  This is deliberately outside the 1-24 Joypad map.
-- It uses fixed Blizzard action slots, has no Joypad modifier layers, and is not
-- listed in the Joypad slot table or binding picker.
JOYPAD_STANCE_ACTION_SLOTS = {
    [1] = 54, -- Bottom Right Button 6
    [2] = 55, -- Bottom Right Button 7
    [3] = 56, -- Bottom Right Button 8
    [4] = 57, -- Bottom Right Button 9
    [5] = 26, -- Right Bar Button 2
}
JOYPAD_STANCE_DEFAULT_VISIBLE = false
JOYPAD_STANCE_DEFAULT_SCALE = 50
JOYPAD_STANCE_DEFAULT_X = 0
JOYPAD_STANCE_DEFAULT_Y = -634
JOYPAD_STANCE_BUTTON_GAP = 3

JOYPAD_LAYOUT_PROFILES = JOYPAD_LAYOUT_PROFILES or {}
JOYPAD_LAYOUT_PROFILES.Scuz = {
    name = "Scuz",
    theme = "elvui",
    displayMode = "steam",
    layoutMode = "gamepad",
    barsVisible = true,
    hideBlizzardBars = false,
    hideKeybindText = true,
    showCooldownText = true,
    showReadyFlash = true,
    readyFlashStrength = "medium",
    readyFlashDuration = "normal",
    showActiveBorder = true,
    stanceBarVisible = true,
    stanceBarX = 0,
    stanceBarY = -695,
    stanceBarScale = 50,
    snapToGrid = true,
    snapToGridThreshold = 10,
    uiCursorEnabled = true,
    uiCursorPanelsOnly = true,
    uiCursorShowPointer = true,
    uiCursorShowHighlight = true,
    uiCursorHideHardwareCursor = false,
    hideMouseWhileMoving = true,
    smartMouselookEnabled = true,
    smartMouselookOnMove = true,
    smartMouselookOnTarget = true,
    smartMouselookOnSpell = true,
    smartMouselookOnNPC = false,
    smartMouselookOnQuest = true,
    smartMouselookOnLoot = true,
    smartMouselookOnJump = false,
    smartMouselookOnCenter = false,
    smartMouselookCenterScale = 100,
    smartMouselookCenterDelay = "normal",
    smartMouselookCenterPreview = false,
    smartMouselookBlocker = true,
    smartMouselookForceTooltip = false,
    smartMouselookTooltipAnchor = "elvui",
    smartMouselookTooltipPoint = "TOPRIGHT",
    smartMouselookTooltipRelativePoint = "TOPRIGHT",
    smartMouselookTooltipX = -230,
    smartMouselookTooltipY = -4,
    smartMouselookMouseoverHint = false,
    smartMouselookPreferAwesomeTarget = true,
    smartMouselookUseSelectedTarget = true,
    smartMouselookTestTooltip = false,
    smartMouselookPauseOnModifier = true,
    raidCursorEnabled = true,
    raidCursorTargetOnMove = true,
    raidCursorAFallback = false,
    raidCursorLogEnabled = true,
    raidCursorHighlightPadding = 3,
    raidCursorHighlightBorderSize = 2,
    raidCursorHighlightAlpha = 0.95,
    raidCursorHighlightFillAlpha = 0.08,
    raidCursorShowLabel = false,
    raidTargetSteeringEnabled = true,
    raidTargetSteeringEveryHeal = true,
    raidTargetSteeringLogEnabled = true,
    inputLogEnabled = true,
    warnMissingKeybinds = true,
    slotEnabled = {
        [1] = true, [2] = true, [3] = true, [4] = true,
        [5] = true, [6] = true, [7] = true, [8] = true,
        [9] = true, [10] = true, [11] = true, [12] = true,
        [13] = true, [14] = true, [15] = true, [16] = true,
        [17] = true, [18] = true, [19] = true, [20] = true,
        [21] = true, [22] = true, [23] = true, [24] = true,
    },
    scales = {
        [1] = 70, [2] = 70, [3] = 70, [4] = 70,
        [5] = 70, [6] = 70, [7] = 70, [8] = 70,
        [9] = 70, [10] = 70, [11] = 70, [12] = 70,
        [13] = 70, [14] = 70, [15] = 70, [16] = 70,
        [17] = 70, [18] = 70, [19] = 70, [20] = 70,
        [21] = 70, [22] = 70, [23] = 70, [24] = 70,
    },
    altTextScales = {
        [1] = 100, [2] = 100, [3] = 100, [4] = 100,
        [5] = 100, [6] = 100, [7] = 100, [8] = 100,
        [9] = 100, [10] = 100, [11] = 100, [12] = 100,
        [13] = 100, [14] = 100, [15] = 100, [16] = 100,
        [17] = 100, [18] = 100, [19] = 100, [20] = 100,
        [21] = 100, [22] = 100, [23] = 100, [24] = 100,
    },
    diamondSlots = {
        [13] = true, [14] = true, [15] = true, [16] = true,
        [17] = true, [18] = true, [19] = true, [20] = true,
    },
    positions = {
        [1] = { x = 293, y = -463 },
        [2] = { x = 334, y = -416 },
        [3] = { x = 241, y = -416 },
        [4] = { x = 293, y = -364 },
        [5] = { x = -293, y = -364 },
        [6] = { x = -344, y = -416 },
        [7] = { x = -241, y = -416 },
        [8] = { x = -293, y = -463 },
        [9] = { x = -293, y = -416 },
        [10] = { x = 293, y = -416 },
        [11] = { x = -213, y = -348 },
        [12] = { x = 213, y = -348 },
        [13] = { x = -188, y = -453 },
        [14] = { x = -221, y = -478 },
        [15] = { x = -154, y = -478 },
        [16] = { x = -188, y = -503 },
        [17] = { x = 188, y = -453 },
        [18] = { x = 154, y = -478 },
        [19] = { x = 221, y = -478 },
        [20] = { x = 188, y = -503 },
        [21] = { x = -416, y = -402 },
        [22] = { x = 416, y = -402 },
        [23] = { x = -416, y = -482 },
        [24] = { x = 416, y = -482 },
    },
    actionSlots = {},
    bindingModes = {},
    keybindCommands = {},
    altTextColors = {},
    altPartTextColors = {},
    showAltScaleControls = false,
    showAltColorControls = false,
    minimapAngle = 225,
    layerAssignments = {},
}

-- Generic class/form paging for the 12 Joypad slots that act like the default
-- main action bar. Utility, targeting, party, extra, and Touch Bar controls stay
-- fixed. The secure driver is class-specific, but Joypad stores the result as
-- generic class pages so Druid, Warrior, Rogue, and Priest can share the model.
JOYPAD_CLASS_PAGED_SLOTS = {
    -- p6z13: physical Joypad buttons now follow the raid-throughput row order
    -- rather than raw ActionButton order.  These values are action-page button
    -- indices, so the same physical remap also applies to Cat/Bear/Moonkin and
    -- vehicle/possess page-11 routing.
    [2] = 2,   -- B      -> Action Button 2
    [3] = 1,   -- X      -> Action Button 1
    [4] = 3,   -- Y      -> Action Button 3
    [5] = 9,   -- D-Up   -> Action Button 9
    [6] = 7,   -- D-Left -> Action Button 7
    [7] = 8,   -- D-Right-> Action Button 8
    [8] = 10,  -- D-Down -> Action Button 10
    [10] = 4,  -- R1     -> Action Button 4
    [11] = 5,  -- Select -> Action Button 5
    [12] = 6,  -- Start  -> Action Button 6
    [17] = 11,
    [18] = 12,
}

JOYPAD_CLASS_PAGE_ACTION_STARTS = {
    page7 = 73,
    page8 = 85,
    page9 = 97,
    page10 = 109,
    page11 = 121,
}

-- Backwards-compatible aliases for older Shifty/Joypad helpers.
JOYPAD_DRUID_PAGED_SLOTS = JOYPAD_CLASS_PAGED_SLOTS
JOYPAD_DRUID_CAT_START = JOYPAD_CLASS_PAGE_ACTION_STARTS.page7
JOYPAD_DRUID_PROWL_START = JOYPAD_CLASS_PAGE_ACTION_STARTS.page8
JOYPAD_DRUID_BEAR_START = JOYPAD_CLASS_PAGE_ACTION_STARTS.page9
JOYPAD_DRUID_MOONKIN_START = JOYPAD_CLASS_PAGE_ACTION_STARTS.page10
JOYPAD_VEHICLE_PAGE_START = JOYPAD_CLASS_PAGE_ACTION_STARTS.page11

JOYPAD_BASE_SECURE_ACTION_STATE_DRIVER = "[bonusbar:5] page11; [mod:shift,mod:ctrl] shiftctrl; [mod:ctrl] ctrl; [mod:shift] shift; base"
JOYPAD_CLASS_SECURE_ACTION_STATE_DRIVERS = {
    DRUID = "[bonusbar:5] page11; [mod:shift,mod:ctrl] shiftctrl; [mod:ctrl] ctrl; [mod:shift] shift; [bonusbar:1,stealth] page8; [bonusbar:1] page7; [bonusbar:3] page9; [bonusbar:4] page10; base",
    WARRIOR = "[bonusbar:5] page11; [mod:shift,mod:ctrl] shiftctrl; [mod:ctrl] ctrl; [mod:shift] shift; [bonusbar:1] page7; [bonusbar:2] page8; [bonusbar:3] page9; base",
    ROGUE = "[bonusbar:5] page11; [mod:shift,mod:ctrl] shiftctrl; [mod:ctrl] ctrl; [mod:shift] shift; [bonusbar:1] page7; [form:3] page7; base",
    PRIEST = "[bonusbar:5] page11; [mod:shift,mod:ctrl] shiftctrl; [mod:ctrl] ctrl; [mod:shift] shift; [bonusbar:1] page7; base",
}
JOYPAD_DRUID_PAGE_DRIVER = JOYPAD_CLASS_SECURE_ACTION_STATE_DRIVERS.DRUID
JOYPAD_SECURE_ACTION_STATE_DRIVER = JOYPAD_BASE_SECURE_ACTION_STATE_DRIVER

function JoypadGetPlayerClassFile()
    if UnitClass then
        local _, classFile = UnitClass("player")
        return classFile
    end
    return nil
end

function JoypadGetSecureActionStateDriver()
    local classFile = JoypadGetPlayerClassFile()
    return (JOYPAD_CLASS_SECURE_ACTION_STATE_DRIVERS and JOYPAD_CLASS_SECURE_ACTION_STATE_DRIVERS[classFile]) or JOYPAD_BASE_SECURE_ACTION_STATE_DRIVER
end


function JoypadSafePCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    if pcall then
        local ok, a = pcall(fn, ...)
        if ok then return a end
        return nil
    end
    return fn(...)
end

function JoypadGetBonusBarOffsetValue()
    if GetBonusBarOffset then
        return tonumber(GetBonusBarOffset() or 0) or 0
    end
    return 0
end

function JoypadIsVehicleOrEncounterActionBarActive()
    -- Wrath/3.3.5a vehicle/possess/encounter takeover bars generally surface
    -- as bonusbar 5, which ElvUI pages to action page 11.  Keep the auxiliary
    -- vehicle APIs as diagnostics only so the visual/action routing stays in
    -- lockstep with the secure [bonusbar:5] state driver.
    return JoypadGetBonusBarOffsetValue() == 5
end

function JoypadGetVehicleActionSlotForJoypadSlot(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    local pageButton = JOYPAD_CLASS_PAGED_SLOTS and JOYPAD_CLASS_PAGED_SLOTS[joypadSlot]
    if not pageButton then return nil end
    local start = JOYPAD_CLASS_PAGE_ACTION_STARTS and JOYPAD_CLASS_PAGE_ACTION_STARTS.page11 or 121
    return start + pageButton - 1
end

function JoypadGetVehicleStatusText()
    local slot2 = JoypadGetVehicleActionSlotForJoypadSlot and JoypadGetVehicleActionSlotForJoypadSlot(2) or nil
    local tex = slot2 and GetActionTexture and GetActionTexture(slot2) or nil
    return "vehicle=" .. tostring(JoypadIsVehicleOrEncounterActionBarActive())
        .. " bonusOffset=" .. tostring(JoypadGetBonusBarOffsetValue())
        .. " canExit=" .. tostring(CanExitVehicle and JoypadSafePCall(CanExitVehicle) or false)
        .. " unitVehicle=" .. tostring(UnitUsingVehicle and JoypadSafePCall(UnitUsingVehicle, "player") or false)
        .. " hasVehicleUI=" .. tostring(UnitHasVehicleUI and JoypadSafePCall(UnitHasVehicleUI, "player") or false)
        .. " page11Start=" .. tostring(JOYPAD_CLASS_PAGE_ACTION_STARTS and JOYPAD_CLASS_PAGE_ACTION_STARTS.page11 or 121)
        .. " slot2Action=" .. tostring(slot2 or "?")
        .. " slot2Texture=" .. tostring(tex or "nil")
end

-- Event-driven action-slot cache.  Visual refreshes can happen often, but action
-- texture/name/count/equipped state only needs to be refreshed after action-bar,
-- bag, equipment, stance, or vehicle events.  Cooldown/usable/range remain live.
JoypadActionSlotCache = {}

function JoypadInvalidateActionSlotCache(actionSlot)
    if actionSlot then
        JoypadActionSlotCache[tonumber(actionSlot) or actionSlot] = nil
        return
    end
    JoypadActionSlotCache = {}
end

function JoypadGetCachedActionSlotInfo(actionSlot)
    actionSlot = tonumber(actionSlot or 0) or 0
    if actionSlot <= 0 then
        return nil
    end

    local cached = JoypadActionSlotCache[actionSlot]
    if cached then
        return cached
    end

    cached = {
        texture = GetActionTexture and GetActionTexture(actionSlot) or nil,
        hasAction = HasAction and HasAction(actionSlot) or false,
        actionText = GetActionText and GetActionText(actionSlot) or nil,
        count = GetActionCount and GetActionCount(actionSlot) or 0,
        equipped = IsEquippedAction and IsEquippedAction(actionSlot) or false,
    }
    JoypadActionSlotCache[actionSlot] = cached
    return cached
end

function JoypadPlayerIsDruid()
    return JoypadGetPlayerClassFile() == "DRUID"
end

function JoypadGetClassPagingState()
    local classFile = JoypadGetPlayerClassFile()
    local bonusOffset = JoypadGetBonusBarOffsetValue and JoypadGetBonusBarOffsetValue() or 0

    if bonusOffset == 5 then
        return "page11", "vehicle", classFile
    end

    if classFile == "DRUID" then
        if bonusOffset == 1 then
            if IsStealthed and IsStealthed() then
                return "page8", "prowl", classFile
            end
            return "page7", "cat", classFile
        elseif bonusOffset == 3 then
            return "page9", "bear", classFile
        elseif bonusOffset == 4 then
            return "page10", "moonkin", classFile
        end

        -- Tree Form does not page Joypad's main action slots, but expose it for
        -- external sanity checks when it can be identified.
        if GetNumShapeshiftForms and GetShapeshiftFormInfo then
            local count = GetNumShapeshiftForms() or 0
            for index = 1, count do
                local icon, name, active = GetShapeshiftFormInfo(index)
                if active and name and string.find(string.lower(tostring(name)), "tree", 1, true) then
                    return "base", "tree", classFile
                end
            end
        end

        return "base", "caster", classFile
    elseif classFile == "WARRIOR" then
        if bonusOffset == 1 then
            return "page7", "battle", classFile
        elseif bonusOffset == 2 then
            return "page8", "defensive", classFile
        elseif bonusOffset == 3 then
            return "page9", "berserker", classFile
        end
        return "base", "base", classFile
    elseif classFile == "ROGUE" then
        if bonusOffset == 1 then
            return "page7", "stealth", classFile
        end
        if GetShapeshiftForm and tonumber(GetShapeshiftForm() or 0) == 3 then
            return "page7", "stealth", classFile
        end
        return "base", "base", classFile
    elseif classFile == "PRIEST" then
        if bonusOffset == 1 then
            return "page7", "shadow", classFile
        end
        return "base", "base", classFile
    end

    return "base", "base", classFile
end

function JoypadGetDruidPagingState()
    local pageState, form, classFile = JoypadGetClassPagingState()
    if classFile ~= "DRUID" then
        return "caster"
    end
    return form or "caster"
end

function JoypadGetClassPagedActionSlot(joypadSlot, layerKey, casterActionSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    layerKey = string.lower(tostring(layerKey or "base"))
    if layerKey ~= "shift" and layerKey ~= "ctrl" and layerKey ~= "shiftctrl" then
        layerKey = "base"
    end

    local pageButton = JOYPAD_CLASS_PAGED_SLOTS and JOYPAD_CLASS_PAGED_SLOTS[joypadSlot]
    if not pageButton then
        return casterActionSlot
    end

    if JoypadIsVehicleOrEncounterActionBarActive and JoypadIsVehicleOrEncounterActionBarActive() then
        local vehicleSlot = JoypadGetVehicleActionSlotForJoypadSlot and JoypadGetVehicleActionSlotForJoypadSlot(joypadSlot)
        return vehicleSlot or casterActionSlot
    end

    if layerKey ~= "base" then
        return casterActionSlot
    end

    local pageState = JoypadGetClassPagingState()
    local pageStart = JOYPAD_CLASS_PAGE_ACTION_STARTS and JOYPAD_CLASS_PAGE_ACTION_STARTS[pageState]
    if not pageStart then
        return casterActionSlot
    end

    return pageStart + pageButton - 1
end

function JoypadGetDruidPagedActionSlot(joypadSlot, layerKey, casterActionSlot)
    return JoypadGetClassPagedActionSlot(joypadSlot, layerKey, casterActionSlot)
end

local ALT_LABEL_GROUP_SLOTS = {}
for joypadSlot = 1, 24 do
    local def = ALT_LABELS[joypadSlot]
    local groupName = type(def) == "table" and def.group or "face"
    if not ALT_LABEL_GROUP_SLOTS[groupName] then
        ALT_LABEL_GROUP_SLOTS[groupName] = {}
    end
    table.insert(ALT_LABEL_GROUP_SLOTS[groupName], joypadSlot)
end

local function GetAltLabelDef(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    local displayMode = JoypadGetDisplayMode() or "steam"
    local cacheKey = tostring(displayMode) .. ":" .. tostring(joypadSlot)
    if JoypadAltLabelDefCache and JoypadAltLabelDefCache[cacheKey] then
        return JoypadAltLabelDefCache[cacheKey]
    end

    local def = ALT_LABELS[joypadSlot]

    if displayMode == "playstation" and JOYPAD_PLAYSTATION_ALT_LABELS then
        local displayDef = JOYPAD_PLAYSTATION_ALT_LABELS[joypadSlot]
        if type(displayDef) == "table" then
            def = displayDef
        end
    elseif displayMode == "nintendo" and JOYPAD_NINTENDO_ALT_LABELS then
        local displayDef = JOYPAD_NINTENDO_ALT_LABELS[joypadSlot]
        if type(displayDef) == "table" then
            def = displayDef
        end
    end

    if type(def) ~= "table" then
        local label = type(def) == "string" and def or "-"
        def = { label = label, parts = { { text = label, scale = 100, x = 0, y = 0 } } }
    end

    JoypadAltLabelDefCache[cacheKey] = def
    return def
end

local function GetAltLabel(joypadSlot)
    local def = GetAltLabelDef(joypadSlot)
    return def.label or "-"
end

local function GetAltRenderParts(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    local displayMode = JoypadGetDisplayMode() or "steam"
    local cacheKey = tostring(displayMode) .. ":" .. tostring(joypadSlot)
    if JoypadAltRenderPartsCache and JoypadAltRenderPartsCache[cacheKey] then
        return JoypadAltRenderPartsCache[cacheKey]
    end

    local def = GetAltLabelDef(joypadSlot)
    local parts = nil
    if type(def.parts) == "table" and #def.parts > 0 then
        parts = def.parts
    else
        parts = { { text = GetAltLabel(joypadSlot), scale = tonumber(def.scale) or 100, x = 0, y = 0 } }
    end
    JoypadAltRenderPartsCache[cacheKey] = parts
    return parts
end

function JoypadGetAltPartDiamondOffset(joypadSlot, part)
    joypadSlot = tonumber(joypadSlot or 0) or 0

    if type(part) ~= "table" then
        return 0, 0
    end

    if not JoypadIsDiamondViewportEnabled or not JoypadIsDiamondViewportEnabled(joypadSlot) then
        return 0, 0
    end

    local x = tonumber(part.diamondX or 0) or 0
    local y = tonumber(part.diamondY or 0) or 0
    return x, y
end

local function IsSlotEnabled(joypadSlot)
    if type(JoypadDB) ~= "table" or type(JoypadDB.slotEnabled) ~= "table" then
        return true
    end

    joypadSlot = tonumber(joypadSlot or 0) or 0
    return JoypadDB.slotEnabled[joypadSlot] ~= false
end

-- Joypad layer model.
-- Each of the 24 visual Joypad slots has four assignments:
--   Base, Shift, Ctrl, and Shift+Ctrl.
-- The physical/listening binding remains tied to the visual row so key 1 still
-- drives Joypad slot 1, key 2 still drives Joypad slot 2, and so on.  Layers
-- only change what that Joypad slot does once activated.
local JOYPAD_LAYERS = {
    { key = "base",      label = "Base",       modifierPrefixes = { "" } },
    { key = "shift",     label = "Shift",      modifierPrefixes = { "SHIFT-" } },
    { key = "ctrl",      label = "Ctrl",       modifierPrefixes = { "CTRL-" } },
    { key = "shiftctrl", label = "Shift+Ctrl", modifierPrefixes = { "SHIFT-CTRL-", "CTRL-SHIFT-" } },
}

local JOYPAD_LAYER_INDEX = {}
for index, layer in ipairs(JOYPAD_LAYERS) do
    JOYPAD_LAYER_INDEX[layer.key] = index
end

local function ActionAssignment(actionSlot)
    return { type = "action", actionSlot = actionSlot }
end

local function KeybindAssignment(command)
    return { type = "keybind", command = command }
end

local DEFAULT_JOYPAD_LAYER_ASSIGNMENTS = {
    [1]  = { base = KeybindAssignment("JUMP"),                  shift = ActionAssignment(63), ctrl = ActionAssignment(54), shiftctrl = ActionAssignment(33) },
    [2]  = { base = ActionAssignment(2),                         shift = ActionAssignment(64), ctrl = ActionAssignment(55), shiftctrl = ActionAssignment(34) },
    [3]  = { base = ActionAssignment(1),                         shift = ActionAssignment(65), ctrl = ActionAssignment(56), shiftctrl = ActionAssignment(35) },
    [4]  = { base = ActionAssignment(3),                         shift = ActionAssignment(66), ctrl = ActionAssignment(57), shiftctrl = ActionAssignment(36) },
    [5]  = { base = ActionAssignment(9),                         shift = ActionAssignment(67), ctrl = ActionAssignment(58), shiftctrl = ActionAssignment(37) },
    [6]  = { base = ActionAssignment(7),                         shift = ActionAssignment(68), ctrl = ActionAssignment(59), shiftctrl = ActionAssignment(38) },
    [7]  = { base = ActionAssignment(8),                         shift = ActionAssignment(69), ctrl = ActionAssignment(60), shiftctrl = ActionAssignment(39) },
    [8]  = { base = ActionAssignment(10),                        shift = ActionAssignment(70), ctrl = ActionAssignment(25), shiftctrl = ActionAssignment(40) },
    [9]  = { base = KeybindAssignment("TARGETNEARESTENEMY"),    shift = KeybindAssignment("TOGGLEACHIEVEMENT"), ctrl = KeybindAssignment("INTERACTIONKEYBIND"), shiftctrl = KeybindAssignment("TARGETFOCUS") },
    [10] = { base = ActionAssignment(4),                         shift = ActionAssignment(71), ctrl = ActionAssignment(26), shiftctrl = ActionAssignment(41) },
    [11] = { base = ActionAssignment(5),                         shift = ActionAssignment(72), ctrl = ActionAssignment(27), shiftctrl = ActionAssignment(42) },
    [12] = { base = ActionAssignment(6),                         shift = ActionAssignment(49), ctrl = ActionAssignment(28), shiftctrl = ActionAssignment(43) },
    [13] = { base = KeybindAssignment("TARGETPARTYMEMBER1"),    shift = KeybindAssignment("BONUSACTIONBUTTON4"), ctrl = KeybindAssignment("TARGETPARTYPET1"), shiftctrl = KeybindAssignment("TOGGLEGUILDTAB") },
    [14] = { base = KeybindAssignment("TARGETPARTYMEMBER2"),    shift = KeybindAssignment("BONUSACTIONBUTTON5"), ctrl = KeybindAssignment("TARGETPARTYPET2"), shiftctrl = KeybindAssignment("TOGGLECURRENCY") },
    [15] = { base = KeybindAssignment("TARGETPARTYMEMBER3"),    shift = KeybindAssignment("BONUSACTIONBUTTON6"), ctrl = KeybindAssignment("TARGETPARTYPET3"), shiftctrl = KeybindAssignment("TOGGLELFGPARENT") },
    [16] = { base = KeybindAssignment("TARGETPARTYMEMBER4"),    shift = KeybindAssignment("BONUSACTIONBUTTON7"), ctrl = KeybindAssignment("TARGETPARTYPET4"), shiftctrl = KeybindAssignment("TOGGLEPETBOOK") },
    [17] = { base = ActionAssignment(11),                        shift = ActionAssignment(50), ctrl = ActionAssignment(29), shiftctrl = ActionAssignment(44) },
    [18] = { base = ActionAssignment(12),                        shift = ActionAssignment(51), ctrl = ActionAssignment(30), shiftctrl = ActionAssignment(45) },
    [19] = { base = ActionAssignment(61),                        shift = ActionAssignment(52), ctrl = ActionAssignment(31), shiftctrl = ActionAssignment(46) },
    [20] = { base = ActionAssignment(62),                        shift = ActionAssignment(53), ctrl = ActionAssignment(32), shiftctrl = ActionAssignment(47) },
    [21] = { base = KeybindAssignment("TOGGLEWORLDMAP"),        shift = KeybindAssignment("TOGGLECHARACTER0"), ctrl = KeybindAssignment("TOGGLEQUESTLOG"), shiftctrl = KeybindAssignment("TOGGLEFRIENDSTAB") },
    [22] = { base = KeybindAssignment("TOGGLEGAMEMENU"),        shift = KeybindAssignment("OPENALLBAGS"), ctrl = KeybindAssignment("TOGGLESPELLBOOK"), shiftctrl = KeybindAssignment("TOGGLETALENTS") },
    [23] = { base = KeybindAssignment("TARGETSELF"),            shift = KeybindAssignment("PETATTACK"), ctrl = KeybindAssignment("TARGETPET"), shiftctrl = KeybindAssignment("CAMERAZOOMIN") },
    [24] = { base = KeybindAssignment("TOGGLEAUTORUN"),         shift = KeybindAssignment("PETSTAY"), ctrl = KeybindAssignment("FOLLOWTARGET"), shiftctrl = KeybindAssignment("CAMERAZOOMOUT") },
}

local function NormalizeJoypadLayerKey(layerKey)
    layerKey = string.lower(tostring(layerKey or "base"))
    if layerKey == "shift" or layerKey == "ctrl" or layerKey == "shiftctrl" then
        return layerKey
    end
    return "base"
end

local function GetActiveJoypadLayerKey()
    local shiftDown = IsShiftKeyDown and IsShiftKeyDown()
    local ctrlDown = IsControlKeyDown and IsControlKeyDown()

    if shiftDown and ctrlDown then
        return "shiftctrl"
    end
    if ctrlDown then
        return "ctrl"
    end
    if shiftDown then
        return "shift"
    end
    return "base"
end

local function GetJoypadLayerLabel(layerKey)
    layerKey = NormalizeJoypadLayerKey(layerKey)
    local layer = JOYPAD_LAYERS[JOYPAD_LAYER_INDEX[layerKey] or 1]
    return layer and layer.label or "Base"
end

local function GetJoypadListeningBindingCommand(joypadSlot)
    joypadSlot = tonumber(joypadSlot) or 1

    local barIndex = math.floor((joypadSlot - 1) / BUTTONS_PER_BAR) + 1
    local indexOnBar = ((joypadSlot - 1) % BUTTONS_PER_BAR) + 1
    local barDef = BAR_DEFS[barIndex]

    if not barDef then
        return nil, nil, nil
    end

    return "CLICK JoypadButton" .. tostring(joypadSlot) .. ":LeftButton", barDef.row, indexOnBar
end

local function GetDefaultJoypadAssignment(joypadSlot, layerKey)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    layerKey = NormalizeJoypadLayerKey(layerKey)

    local slotAssignments = DEFAULT_JOYPAD_LAYER_ASSIGNMENTS[joypadSlot]
    if type(slotAssignments) == "table" and type(slotAssignments[layerKey]) == "table" then
        return slotAssignments[layerKey]
    end

    local bindingCommand, row, indexOnBar = GetJoypadListeningBindingCommand(joypadSlot)
    if bindingCommand then
        if row == 1 then
            return ActionAssignment(indexOnBar)
        end
        return ActionAssignment(24 + indexOnBar)
    end

    return nil
end

local function GetDefaultJoypadSlotInfo(joypadSlot)
    joypadSlot = tonumber(joypadSlot) or 1

    local bindingCommand, row, indexOnBar = GetJoypadListeningBindingCommand(joypadSlot)
    if not bindingCommand then
        return nil, nil, nil, nil
    end

    local assignment = GetDefaultJoypadAssignment(joypadSlot, "base")
    local actionSlot = assignment and assignment.actionSlot
    return actionSlot, bindingCommand, row, indexOnBar
end

local function GetSavedJoypadLayerAssignment(joypadSlot, layerKey)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    layerKey = NormalizeJoypadLayerKey(layerKey)

    if type(JoypadDB) ~= "table" or type(JoypadDB.layerAssignments) ~= "table" then
        return nil
    end

    local slotAssignments = JoypadDB.layerAssignments[joypadSlot]
    if type(slotAssignments) ~= "table" then
        return nil
    end

    local assignment = slotAssignments[layerKey]
    if type(assignment) ~= "table" then
        return nil
    end

    if assignment.type == "action" then
        local actionSlot = tonumber(assignment.actionSlot)
        if actionSlot then
            actionSlot = math.floor(actionSlot + 0.5)
            if actionSlot >= 1 and actionSlot <= 120 then
                return { type = "action", actionSlot = actionSlot }
            end
        end
    elseif assignment.type == "keybind" then
        local command = tostring(assignment.command or "")
        if command ~= "" then
            return { type = "keybind", command = command }
        end
    end

    return nil
end

local function GetJoypadSlotInfo(joypadSlot, layerKey)
    local defaultActionSlot, bindingCommand, row, indexOnBar = GetDefaultJoypadSlotInfo(joypadSlot)
    local actionSlot = defaultActionSlot

    joypadSlot = tonumber(joypadSlot or 0) or 0
    layerKey = NormalizeJoypadLayerKey(layerKey)

    local assignment = GetDefaultJoypadAssignment(joypadSlot, layerKey)
    if assignment and assignment.type == "action" and assignment.actionSlot then
        actionSlot = assignment.actionSlot
    elseif assignment and assignment.type == "keybind" then
        actionSlot = nil
    end

    local savedLayerAssignment = GetSavedJoypadLayerAssignment(joypadSlot, layerKey)
    if savedLayerAssignment and savedLayerAssignment.type == "action" then
        actionSlot = savedLayerAssignment.actionSlot
    elseif savedLayerAssignment and savedLayerAssignment.type == "keybind" then
        actionSlot = nil
    elseif layerKey == "base" and type(JoypadDB) == "table" and type(JoypadDB.actionSlots) == "table" then
        local savedActionSlot = tonumber(JoypadDB.actionSlots[joypadSlot])
        if savedActionSlot then
            savedActionSlot = math.floor(savedActionSlot + 0.5)
            if savedActionSlot >= 1 and savedActionSlot <= 120 then
                actionSlot = savedActionSlot
            end
        end
    end

    return actionSlot, bindingCommand, row, indexOnBar, defaultActionSlot
end

local function NormalizeJoypadBindingMode(mode)
    mode = string.lower(tostring(mode or "action"))
    if mode == "keybind" or mode == "key" or mode == "command" then
        return "keybind"
    end
    return "action"
end

local function GetJoypadBindingMode(joypadSlot, layerKey)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    layerKey = NormalizeJoypadLayerKey(layerKey)

    local savedLayerAssignment = GetSavedJoypadLayerAssignment(joypadSlot, layerKey)
    if savedLayerAssignment then
        if savedLayerAssignment.type == "keybind" then
            return "keybind"
        end
        return "action"
    end

    if layerKey == "base" and type(JoypadDB) == "table" and type(JoypadDB.bindingModes) == "table" and JoypadDB.bindingModes[joypadSlot] ~= nil then
        return NormalizeJoypadBindingMode(JoypadDB.bindingModes[joypadSlot])
    end

    local assignment = GetDefaultJoypadAssignment(joypadSlot, layerKey)
    if assignment and assignment.type == "keybind" then
        return "keybind"
    end

    return "action"
end

local function GetActionSlotChoiceLabel(actionSlot)
    actionSlot = tonumber(actionSlot or 0) or 0

    if actionSlot >= 1 and actionSlot <= 12 then
        return "Action Button " .. tostring(actionSlot)
    end

    if actionSlot >= 25 and actionSlot <= 36 then
        return "Right Bar Button " .. tostring(actionSlot - 24)
    end

    if actionSlot >= 37 and actionSlot <= 48 then
        return "Right Bar 2 Button " .. tostring(actionSlot - 36)
    end

    if actionSlot >= 49 and actionSlot <= 60 then
        return "Bottom Right Button " .. tostring(actionSlot - 48)
    end

    if actionSlot >= 61 and actionSlot <= 72 then
        return "Bottom Left Button " .. tostring(actionSlot - 60)
    end

    return "Action Slot " .. tostring(actionSlot)
end

local function GetJoypadActionChoiceLabel(joypadSlot, layerKey)
    local actionSlot = GetJoypadSlotInfo(joypadSlot, layerKey)
    return GetActionSlotChoiceLabel(actionSlot)
end

local function GetJoypadDisplayedActionSlot(joypadSlot, layerKey)
    local actionSlot = GetJoypadSlotInfo(joypadSlot, layerKey)
    return JoypadGetClassPagedActionSlot(joypadSlot, layerKey, actionSlot)
end





local function NormalizeKeybindCommand(command)
    command = tostring(command or "")
    command = string.gsub(command, "^%s+", "")
    command = string.gsub(command, "%s+$", "")

    local upper = string.upper(command)
    for _, preset in ipairs(KEYBIND_COMMAND_PRESETS) do
        if upper == string.upper(preset.label) or upper == string.upper(preset.command) then
            return preset.command
        end
    end

    return upper
end

local function GetJoypadKeybindCommand(joypadSlot, layerKey)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    layerKey = NormalizeJoypadLayerKey(layerKey)

    local savedLayerAssignment = GetSavedJoypadLayerAssignment(joypadSlot, layerKey)
    if savedLayerAssignment then
        if savedLayerAssignment.type == "keybind" then
            return NormalizeKeybindCommand(savedLayerAssignment.command or "")
        end
        return ""
    end

    if layerKey == "base" and type(JoypadDB) == "table" and type(JoypadDB.keybindCommands) == "table" and JoypadDB.keybindCommands[joypadSlot] ~= nil then
        return NormalizeKeybindCommand(JoypadDB.keybindCommands[joypadSlot])
    end

    local assignment = GetDefaultJoypadAssignment(joypadSlot, layerKey)
    if assignment and assignment.type == "keybind" then
        return NormalizeKeybindCommand(assignment.command or "")
    end

    return ""
end

local function GetJoypadBindingValueText(joypadSlot, layerKey)
    if GetJoypadBindingMode(joypadSlot, layerKey) == "keybind" then
        return GetJoypadKeybindCommand(joypadSlot, layerKey)
    end

    local actionSlot = GetJoypadSlotInfo(joypadSlot, layerKey)
    return tostring(actionSlot or "")
end

local function GetJoypadBindingModeLabel(joypadSlot, layerKey)
    if GetJoypadBindingMode(joypadSlot, layerKey) == "keybind" then
        return "Keybind"
    end
    return "Action"
end

local RAID_CURSOR_KEYBIND_LABELS = {
    TARGETPARTYMEMBER1 = "^",
    TARGETPARTYMEMBER2 = "<",
    TARGETPARTYMEMBER3 = ">",
    TARGETPARTYMEMBER4 = "v",
}

local RAID_CURSOR_KEYBIND_ICONS = {
    TARGETPARTYMEMBER1 = "Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up",
    TARGETPARTYMEMBER2 = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up",
    TARGETPARTYMEMBER3 = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up",
    TARGETPARTYMEMBER4 = "Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up",
}

local function IsRaidCursorVisualModeActive()
    if type(JoypadDB) ~= "table" or JoypadDB.raidCursorEnabled ~= true then
        return false
    end
    if GetNumRaidMembers then
        return (tonumber(GetNumRaidMembers() or 0) or 0) > 0
    end
    return false
end

local function GetKeybindPresetLabel(command)
    command = NormalizeKeybindCommand(command)

    if IsRaidCursorVisualModeActive() and RAID_CURSOR_KEYBIND_LABELS[command] then
        return RAID_CURSOR_KEYBIND_LABELS[command]
    end

    for _, preset in ipairs(KEYBIND_COMMAND_PRESETS) do
        if preset.command == command then
            return preset.label
        end
    end

    if command and command ~= "" then
        return command
    end

    return "Use action slot"
end

-- Keybind icon lookup is based on ConsolePortBar/Core/Lookup.lua where possible.
local function GetKeybindPresetIcon(command)
    command = NormalizeKeybindCommand(command)
    if IsRaidCursorVisualModeActive() and RAID_CURSOR_KEYBIND_ICONS[command] then
        return RAID_CURSOR_KEYBIND_ICONS[command]
    end
    return KEYBIND_COMMAND_ICONS[command] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

local BINDING_HEADER_OVERRIDES = {
    ACTIONBAR = "Action Bar",
    BAGS = "Bags",
    CAMERA = "Camera",
    CHAT = "Chat",
    COMBAT = "Combat",
    AWESOME_WOTLK_KEYBINDS = "Awesome WotLK",
    INTERFACE = "Interface",
    MISC = "Misc",
    MISCELLANEOUS = "Miscellaneous",
    MOVEMENT = "Movement",
    MULTIACTIONBAR = "Multi Action Bar",
    PET = "Pet",
    RAID_TARGET = "Raid Target",
    SHAPESHIFT = "Shapeshift",
    TARGETING = "Targeting",
    VEHICLE = "Vehicle",
    WIM = "WIM",
}

local function StripJoypadColorCodes(text)
    text = tostring(text or "")
    text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")
    return text
end

local function TitleCaseBindingWord(word)
    word = tostring(word or "")
    if word == "" then
        return ""
    end

    if BINDING_HEADER_OVERRIDES[word] then
        return BINDING_HEADER_OVERRIDES[word]
    end

    if string.len(word) <= 4 then
        return word
    end

    return string.upper(string.sub(word, 1, 1)) .. string.lower(string.sub(word, 2))
end

local function PrettyBindingHeaderName(command)
    local suffix = tostring(command or "")
    suffix = string.gsub(suffix, "^HEADER_", "")

    if BINDING_HEADER_OVERRIDES[suffix] then
        return BINDING_HEADER_OVERRIDES[suffix]
    end

    local globalName = _G["BINDING_HEADER_" .. suffix] or _G["BINDING_" .. command] or _G[command]
    if globalName and globalName ~= "" and globalName ~= command then
        return StripJoypadColorCodes(globalName)
    end

    local pretty = ""
    for word in string.gmatch(suffix, "[^_]+") do
        if pretty ~= "" then
            pretty = pretty .. " "
        end
        pretty = pretty .. TitleCaseBindingWord(word)
    end

    if pretty == "" then
        pretty = suffix
    end

    return pretty
end

local function GetBindingDisplayName(command)
    command = tostring(command or "")
    if command == "" then
        return ""
    end

    if string.sub(command, 1, 7) == "HEADER_" then
        return PrettyBindingHeaderName(command)
    end

    local name = nil
    if GetBindingText then
        name = GetBindingText(command, "BINDING_NAME_")
    end

    if not name or name == "" then
        name = _G["BINDING_NAME_" .. command]
    end

    if not name or name == "" then
        name = command
    end

    return StripJoypadColorCodes(name)
end

local function AddJoypadDropdownTitle(text, level)
    if not UIDropDownMenu_CreateInfo or not UIDropDownMenu_AddButton then
        return
    end

    local info = UIDropDownMenu_CreateInfo()
    info.text = tostring(text or "")
    info.isTitle = true
    info.notCheckable = true
    info.disabled = true
    UIDropDownMenu_AddButton(info, level)
end

local function AddJoypadDropdownCommand(dropdownFrame, label, command, level, seenCommands)
    command = NormalizeKeybindCommand(command)
    if command == "" then
        return
    end

    if seenCommands and seenCommands[command] then
        return
    end
    if seenCommands then
        seenCommands[command] = true
    end

    if not UIDropDownMenu_CreateInfo or not UIDropDownMenu_AddButton then
        return
    end

    local joypadSlot = tonumber(dropdownFrame and dropdownFrame.joypadSlot or 0) or 0
    local selectedCommand = command

    local info = UIDropDownMenu_CreateInfo()
    info.text = tostring(label or command)
    info.value = selectedCommand
    info.checked = GetJoypadKeybindCommand(joypadSlot) == selectedCommand
    info.func = function()
        if joypadSlot >= 1 and joypadSlot <= 24 and selectedCommand ~= "" then
            Joypad:SelectKeybindPreset(joypadSlot, selectedCommand, false)
        end

        if dropdownFrame and UIDropDownMenu_SetText then
            UIDropDownMenu_SetText(dropdownFrame, GetJoypadPresetDisplayText(joypadSlot))
        end

        if CloseDropDownMenus then
            CloseDropDownMenus()
        elseif HideDropDownMenu then
            HideDropDownMenu(1)
        end
    end
    UIDropDownMenu_AddButton(info, level)
end

local function AddJoypadLiveBindingDropdownCommands(dropdownFrame, level, seenCommands)
    if not GetNumBindings or not GetBinding then
        return
    end

    AddJoypadDropdownTitle("WoW binding list", level)

    local count = GetNumBindings() or 0
    local added = 0

    for i = 1, count do
        local command = GetBinding(i)
        if command and command ~= "" then
            if string.sub(command, 1, 7) == "HEADER_" then
                AddJoypadDropdownTitle(GetBindingDisplayName(command), level)
            else
                AddJoypadDropdownCommand(dropdownFrame, GetBindingDisplayName(command), command, level, seenCommands)
                added = added + 1
            end
        end
    end

    if added == 0 then
        AddJoypadDropdownTitle("No live bindings found", level)
    end
end

local function GetJoypadBindingDisplayText(joypadSlot, layerKey)
    if GetJoypadBindingMode(joypadSlot, layerKey) == "keybind" then
        return GetKeybindPresetLabel(GetJoypadKeybindCommand(joypadSlot, layerKey))
    end

    return GetJoypadBindingValueText(joypadSlot, layerKey)
end

local function GetJoypadPresetDisplayText(joypadSlot, layerKey)
    if GetJoypadBindingMode(joypadSlot, layerKey) == "keybind" then
        return GetKeybindPresetLabel(GetJoypadKeybindCommand(joypadSlot, layerKey))
    end

    return GetJoypadActionChoiceLabel(joypadSlot, layerKey)
end

local function Round(value)
    value = tonumber(value or 0) or 0
    if value >= 0 then
        return math.floor(value + 0.5)
    end
    return math.ceil(value - 0.5)
end

function JoypadGetGridSnapStep()
    return tonumber(GRID_STEP or 50) or 50
end

function JoypadGetGridSnapThreshold()
    if type(JoypadDB) == "table" then
        return tonumber(JoypadDB.snapToGridThreshold or 10) or 10
    end
    return 10
end

function JoypadIsGridSnapEnabled()
    return type(JoypadDB) == "table" and JoypadDB.snapToGrid ~= false
end

function JoypadSnapCoordinateToGrid(value)
    value = tonumber(value or 0) or 0

    if not JoypadIsGridSnapEnabled() then
        return Round(value), false
    end

    local step = JoypadGetGridSnapStep()
    if not step or step <= 0 then
        return Round(value), false
    end

    local nearest = Round(value / step) * step
    local threshold = JoypadGetGridSnapThreshold()
    if math.abs(value - nearest) <= threshold then
        return Round(nearest), true
    end

    return Round(value), false
end

function JoypadSnapPointToGrid(x, y)
    local snappedX, didX = JoypadSnapCoordinateToGrid(x)
    local snappedY, didY = JoypadSnapCoordinateToGrid(y)
    return snappedX, snappedY, didX or didY
end

function JoypadAdjustDeltaForGridSnap(originX, originY, deltaX, deltaY)
    if not JoypadIsGridSnapEnabled() then
        return Round(deltaX), Round(deltaY), false
    end

    local targetX = (tonumber(originX or 0) or 0) + (tonumber(deltaX or 0) or 0)
    local targetY = (tonumber(originY or 0) or 0) + (tonumber(deltaY or 0) or 0)
    local snappedX, snappedY, didSnap = JoypadSnapPointToGrid(targetX, targetY)

    if didSnap then
        return Round(snappedX - (tonumber(originX or 0) or 0)), Round(snappedY - (tonumber(originY or 0) or 0)), true
    end

    return Round(deltaX), Round(deltaY), false
end

local function GetDefaultSlotPosition(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0

    local position = JOYPAD_DEFAULT_SLOT_POSITIONS and JOYPAD_DEFAULT_SLOT_POSITIONS[joypadSlot]
    if type(position) == "table" and type(position.x) == "number" and type(position.y) == "number" then
        return position.x, position.y
    end

    local _, _, row, indexOnBar = GetJoypadSlotInfo(joypadSlot)
    row = row or 1
    indexOnBar = indexOnBar or 1

    local totalWidth = (BUTTON_SIZE * BUTTONS_PER_BAR) + (BUTTON_GAP * (BUTTONS_PER_BAR - 1))
    local x = (0 - (totalWidth / 2)) + (BUTTON_SIZE / 2) + ((indexOnBar - 1) * (BUTTON_SIZE + BUTTON_GAP))
    local y = (BUTTON_SIZE + BAR_GAP) / 2
    if row == 2 then
        y = ROW2_DEFAULT_Y
    end

    return Round(x), Round(y)
end

local function GetSlotPosition(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0

    if type(JoypadDB) == "table" and type(JoypadDB.positions) == "table" then
        local position = JoypadDB.positions[joypadSlot]
        if type(position) == "table" and type(position.x) == "number" and type(position.y) == "number" then
            return position.x, position.y
        end
    end

    return GetDefaultSlotPosition(joypadSlot)
end

local function Clamp(value, minValue, maxValue)
    value = tonumber(value or 0) or 0
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function GetDefaultSlotScale(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    return JOYPAD_DEFAULT_SLOT_SCALES and JOYPAD_DEFAULT_SLOT_SCALES[joypadSlot] or 100
end

local function GetSlotScale(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0

    if type(JoypadDB) == "table" and type(JoypadDB.scales) == "table" then
        local scale = tonumber(JoypadDB.scales[joypadSlot])
        if scale then
            return Clamp(Round(scale), 25, 300)
        end
    end

    return GetDefaultSlotScale(joypadSlot)
end

local function GetDefaultAltTextScale(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    return DEFAULT_ALT_TEXT_SCALES[joypadSlot] or 100
end

local function GetAltTextScale(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0

    if type(JoypadDB) == "table" and type(JoypadDB.altTextScales) == "table" then
        local scale = tonumber(JoypadDB.altTextScales[joypadSlot])
        if scale then
            return Clamp(Round(scale), 25, 300)
        end
    end

    return GetDefaultAltTextScale(joypadSlot)
end

local function GetDefaultAltTextColor(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    local color = JoypadGetDisplayModeAltTextColor(joypadSlot)
    if type(color) ~= "table" then
        color = JOYPAD_DEFAULT_ALT_TEXT_COLORS and JOYPAD_DEFAULT_ALT_TEXT_COLORS[joypadSlot]
    end
    if type(color) == "table" then
        return color.r or 1.0, color.g or 0.82, color.b or 0.0, color.a or 1.0
    end
    return 1.0, 0.82, 0.0, 1.0
end

local function GetAltTextColor(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0

    if type(JoypadDB) == "table" and type(JoypadDB.altTextColors) == "table" then
        local color = JoypadDB.altTextColors[joypadSlot]
        if type(color) == "table" then
            local r = tonumber(color.r)
            local g = tonumber(color.g)
            local b = tonumber(color.b)
            local a = tonumber(color.a) or 1.0
            if r and g and b then
                return Clamp(r, 0, 1), Clamp(g, 0, 1), Clamp(b, 0, 1), Clamp(a, 0, 1)
            end
        end
    end

    return GetDefaultAltTextColor(joypadSlot)
end

local function GetAltTextColorHex(joypadSlot)
    local r, g, b = GetAltTextColor(joypadSlot)
    return string.format("#%02X%02X%02X", Round(Clamp(r, 0, 1) * 255), Round(Clamp(g, 0, 1) * 255), Round(Clamp(b, 0, 1) * 255))
end

function JoypadGetDefaultAltPartTextColor(colorRole)
    colorRole = tostring(colorRole or "")
    local color = JOYPAD_DEFAULT_ALT_PART_TEXT_COLORS and JOYPAD_DEFAULT_ALT_PART_TEXT_COLORS[colorRole]
    if type(color) == "table" then
        return color.r or 1.0, color.g or 0.82, color.b or 0.0, color.a or 1.0
    end
    return 1.0, 0.82, 0.0, 1.0
end

function JoypadGetAltPartTextColor(colorRole)
    colorRole = tostring(colorRole or "")

    if type(JoypadDB) == "table" and type(JoypadDB.altPartTextColors) == "table" then
        local color = JoypadDB.altPartTextColors[colorRole]
        if type(color) == "table" then
            local r = tonumber(color.r)
            local g = tonumber(color.g)
            local b = tonumber(color.b)
            local a = tonumber(color.a) or 1.0
            if r and g and b then
                return Clamp(r, 0, 1), Clamp(g, 0, 1), Clamp(b, 0, 1), Clamp(a, 0, 1)
            end
        end
    end

    return JoypadGetDefaultAltPartTextColor(colorRole)
end

function JoypadGetAltPartTextColorHex(colorRole)
    local r, g, b = JoypadGetAltPartTextColor(colorRole)
    return string.format("#%02X%02X%02X", Round(Clamp(r, 0, 1) * 255), Round(Clamp(g, 0, 1) * 255), Round(Clamp(b, 0, 1) * 255))
end

function JoypadGetAltTextPartColor(joypadSlot, part)
    if type(part) == "table" and part.colorRole then
        return JoypadGetAltPartTextColor(part.colorRole)
    end
    return GetAltTextColor(joypadSlot)
end

local altMeasureFrame = nil
local altMeasureStrings = {}

local function GetAltLabelGroup(joypadSlot)
    local def = GetAltLabelDef(joypadSlot)
    local groupName = def.group or "face"
    local group = ALT_LABEL_GROUPS[groupName] or ALT_LABEL_GROUPS.face
    return group, groupName
end

local function GetAltPartBaseScale(part)
    local scale = 1.0
    if type(part) == "table" then
        scale = tonumber(part.scale or part.scaleMultiplier or 1.0) or 1.0
    end

    -- Backwards compatible with older percent-style part data if any is added later.
    if scale > 10 then
        scale = scale / 100
    end

    return Clamp(scale, 0.10, 5.00)
end

local function GetAltMeasureString(index)
    index = tonumber(index or 1) or 1

    if not altMeasureFrame then
        altMeasureFrame = CreateFrame("Frame", nil, UIParent)
        altMeasureFrame:Hide()
    end

    if not altMeasureStrings[index] then
        local fontString = altMeasureFrame:CreateFontString(nil, "ARTWORK")
        fontString:SetJustifyH("CENTER")
        fontString:SetJustifyV("MIDDLE")
        fontString:Hide()
        altMeasureStrings[index] = fontString
    end

    return altMeasureStrings[index]
end

local function MeasureAltString(text, fontSize, index)
    text = tostring(text or "")
    fontSize = Clamp(Round(fontSize or ALT_TEXT_BASE_FONT_SIZE), 4, 96)

    local fontString = GetAltMeasureString(index)
    fontString:SetFont(ALT_TEXT_BASE_FONT, fontSize, ALT_TEXT_FONT_FLAGS)
    fontString:SetText(text)

    local width = 0
    local height = 0

    if fontString.GetStringWidth then
        width = tonumber(fontString:GetStringWidth() or 0) or 0
    end
    if fontString.GetStringHeight then
        height = tonumber(fontString:GetStringHeight() or 0) or 0
    end

    -- Fallbacks for early-load or odd clients where string measurement returns 0.
    if width <= 0 then
        width = string.len(text) * fontSize * 0.62
    end
    if height <= 0 then
        height = fontSize
    end

    return width, height
end

local function MeasureAltPartsBounds(parts)
    local minX, maxX, minY, maxY = nil, nil, nil, nil
    local maxBaseFontSize = ALT_TEXT_BASE_FONT_SIZE

    for index, part in ipairs(parts) do
        if type(part) == "table" then
            local partScale = GetAltPartBaseScale(part)
            local fontSize = Clamp(Round(ALT_TEXT_BASE_FONT_SIZE * partScale), 4, 96)
            local width, height = MeasureAltString(part.text or "", fontSize, index)
            local x = tonumber(part.x or 0) or 0
            local y = tonumber(part.y or 0) or 0

            local left = x - (width / 2)
            local right = x + (width / 2)
            local bottom = y - (height / 2)
            local top = y + (height / 2)

            if not minX or left < minX then minX = left end
            if not maxX or right > maxX then maxX = right end
            if not minY or bottom < minY then minY = bottom end
            if not maxY or top > maxY then maxY = top end
            if fontSize > maxBaseFontSize then maxBaseFontSize = fontSize end
        end
    end

    local baseWidth = 1
    local baseHeight = 1
    if minX and maxX then
        baseWidth = math.max(1, maxX - minX)
    end
    if minY and maxY then
        baseHeight = math.max(1, maxY - minY)
    end

    return baseWidth, baseHeight, maxBaseFontSize
end

local altGroupLayoutCache = {}
JoypadAltAutoLayoutCache = {}
JoypadAltLabelDefCache = {}
JoypadAltRenderPartsCache = {}

function JoypadClearAltLayoutCache()
    altGroupLayoutCache = {}
    JoypadAltAutoLayoutCache = {}
    JoypadAltLabelDefCache = {}
    JoypadAltRenderPartsCache = {}
end

local function GetAltGroupAutoMultiplier(groupName, referenceWidth, referenceHeight)
    groupName = tostring(groupName or "face")
    referenceWidth = tonumber(referenceWidth or BUTTON_SIZE) or BUTTON_SIZE
    referenceHeight = tonumber(referenceHeight or BUTTON_SIZE) or BUTTON_SIZE

    local cacheKey = string.format("%s:%d:%d", groupName, Round(referenceWidth * 100), Round(referenceHeight * 100))
    if altGroupLayoutCache[cacheKey] then
        return altGroupLayoutCache[cacheKey]
    end

    local group = ALT_LABEL_GROUPS[groupName] or ALT_LABEL_GROUPS.face
    local targetWidth = referenceWidth * (tonumber(group.targetWidthPct) or 0.70)
    local maxHeight = referenceHeight * (tonumber(group.maxHeightPct) or 0.34)
    local slotList = ALT_LABEL_GROUP_SLOTS[groupName] or {}

    local sharedMultiplier = nil
    local widestBase = 1
    local tallestBase = 1

    for _, slot in ipairs(slotList) do
        local parts = GetAltRenderParts(slot)
        local baseWidth, baseHeight = MeasureAltPartsBounds(parts)
        widestBase = math.max(widestBase, baseWidth)
        tallestBase = math.max(tallestBase, baseHeight)

        local widthFit = targetWidth / math.max(1, baseWidth)
        local heightFit = maxHeight / math.max(1, baseHeight)
        local candidate = math.min(widthFit, heightFit)

        if not sharedMultiplier or candidate < sharedMultiplier then
            sharedMultiplier = candidate
        end
    end

    if not sharedMultiplier then
        sharedMultiplier = 1.0
    end

    sharedMultiplier = Clamp(sharedMultiplier, tonumber(group.minScale) or 0.35, tonumber(group.maxScale) or 3.00)

    local result = {
        group = group,
        groupName = groupName,
        targetWidth = targetWidth,
        maxHeight = maxHeight,
        autoMultiplier = sharedMultiplier,
        widestBase = widestBase,
        tallestBase = tallestBase,
    }
    altGroupLayoutCache[cacheKey] = result
    return result
end

local function GetAltAutoLayout(joypadSlot, referenceWidth, referenceHeight)
    joypadSlot = tonumber(joypadSlot or 0) or 0

    referenceWidth = tonumber(referenceWidth or BUTTON_SIZE) or BUTTON_SIZE
    referenceHeight = tonumber(referenceHeight or BUTTON_SIZE) or BUTTON_SIZE
    if referenceWidth <= 0 then referenceWidth = BUTTON_SIZE end
    if referenceHeight <= 0 then referenceHeight = BUTTON_SIZE end

    local displayMode = JoypadGetDisplayMode() or "steam"
    local userScale = GetAltTextScale(joypadSlot)
    local cacheKey = tostring(displayMode) .. ":" .. tostring(joypadSlot) .. ":" .. tostring(Round(referenceWidth * 100)) .. ":" .. tostring(Round(referenceHeight * 100)) .. ":" .. tostring(userScale)
    if JoypadAltAutoLayoutCache and JoypadAltAutoLayoutCache[cacheKey] then
        return JoypadAltAutoLayoutCache[cacheKey]
    end

    local group, groupName = GetAltLabelGroup(joypadSlot)
    local parts = GetAltRenderParts(joypadSlot)
    local baseWidth, baseHeight, maxBaseFontSize = MeasureAltPartsBounds(parts)
    local groupLayout = GetAltGroupAutoMultiplier(groupName, referenceWidth, referenceHeight)

    local userMultiplier = userScale / 100
    local finalMultiplier = (tonumber(groupLayout.autoMultiplier) or 1) * userMultiplier

    local result = {
        group = group,
        groupName = groupName,
        parts = parts,
        baseWidth = baseWidth,
        baseHeight = baseHeight,
        targetWidth = groupLayout.targetWidth,
        maxHeight = groupLayout.maxHeight,
        autoMultiplier = groupLayout.autoMultiplier,
        userMultiplier = userMultiplier,
        multiplier = finalMultiplier,
        maxFontSize = Clamp(Round(maxBaseFontSize * finalMultiplier), 6, 72),
    }
    JoypadAltAutoLayoutCache[cacheKey] = result
    return result
end

local function GetAltPartFontSize(joypadSlot, part, layout)
    if type(layout) ~= "table" then
        layout = GetAltAutoLayout(joypadSlot)
    end

    local partScale = GetAltPartBaseScale(part)
    local fontSize = Round(ALT_TEXT_BASE_FONT_SIZE * partScale * (tonumber(layout.multiplier) or 1))
    return Clamp(fontSize, 6, 72)
end

local function GetAltTextFontSize(joypadSlot)
    local layout = GetAltAutoLayout(joypadSlot)
    return layout.maxFontSize or ALT_TEXT_BASE_FONT_SIZE
end

local function ApplyAltTextAppearance(fontString, joypadSlot)
    if not fontString then
        return
    end

    joypadSlot = tonumber(joypadSlot or 0) or 0

    local fontSize = GetAltTextFontSize(joypadSlot)

    if fontString.SetFont then
        fontString:SetFont(ALT_TEXT_BASE_FONT, fontSize, ALT_TEXT_FONT_FLAGS)
    end

    if fontString.SetHeight then
        fontString:SetHeight(fontSize + 6)
    end

    local r, g, b, a = GetAltTextColor(joypadSlot)
    fontString:SetTextColor(r, g, b, a)
    fontString:SetText(GetAltLabel(joypadSlot))
end

local function ApplyAltTextPartAppearance(fontString, joypadSlot, part, layout)
    if not fontString or type(part) ~= "table" then
        return
    end

    joypadSlot = tonumber(joypadSlot or 0) or 0

    local fontSize = GetAltPartFontSize(joypadSlot, part, layout)
    if fontString.SetFont then
        fontString:SetFont(ALT_TEXT_BASE_FONT, fontSize, ALT_TEXT_FONT_FLAGS)
    end

    if fontString.SetHeight then
        fontString:SetHeight(fontSize + 8)
    end

    local r, g, b, a = JoypadGetAltTextPartColor(joypadSlot, part)
    fontString:SetTextColor(r, g, b, a)
    fontString:SetText(tostring(part.text or ""))
end

local function ApplyAltPartsAppearance(button)
    if not button or not button.altParts then
        return
    end

    local joypadSlot = tonumber(button.joypadSlot or 0) or 0
    local referenceWidth = BUTTON_SIZE
    local referenceHeight = BUTTON_SIZE

    if button.GetWidth then
        referenceWidth = tonumber(button:GetWidth() or BUTTON_SIZE) or BUTTON_SIZE
    end
    if button.GetHeight then
        referenceHeight = tonumber(button:GetHeight() or BUTTON_SIZE) or BUTTON_SIZE
    end

    local layout = GetAltAutoLayout(joypadSlot, referenceWidth, referenceHeight)
    local parts = layout.parts or GetAltRenderParts(joypadSlot)
    local finalMultiplier = tonumber(layout.multiplier) or 1

    for index, fontString in ipairs(button.altParts) do
        local part = parts[index]
        if type(part) == "table" then
            local diamondX, diamondY = JoypadGetAltPartDiamondOffset(joypadSlot, part)
            local x = ((tonumber(part.x or 0) or 0) + diamondX) * finalMultiplier
            local y = ((tonumber(part.y or 0) or 0) + diamondY) * finalMultiplier
            local fontSize = GetAltPartFontSize(joypadSlot, part, layout)

            fontString:ClearAllPoints()
            fontString:SetPoint("CENTER", button, "TOP", x, y)
            fontString:SetWidth((referenceWidth * 2.5) + 40)
            fontString:SetHeight(fontSize + 8)
            fontString:SetJustifyH("CENTER")
            fontString:SetJustifyV("MIDDLE")
            fontString:SetShadowColor(0, 0, 0, 1)
            fontString:SetShadowOffset(1, -1)
            ApplyAltTextPartAppearance(fontString, joypadSlot, part, layout)
            fontString:Show()
        else
            fontString:SetText("")
            fontString:Hide()
        end
    end
end

local holder = CreateFrame("Frame", "JoypadHolder", UIParent)
holder:SetWidth((BUTTON_SIZE * BUTTONS_PER_BAR) + (BUTTON_GAP * (BUTTONS_PER_BAR - 1)))
holder:SetHeight((BUTTON_SIZE * 2) + BAR_GAP)
holder:SetPoint("CENTER", UIParent, "CENTER", X_OFFSET, Y_OFFSET)
holder:Show()

local Joypad = CreateFrame("Frame")
Joypad.buttons = {}
Joypad.COOLDOWN_TEXT_MIN_DURATION = 1.5
Joypad.COOLDOWN_TEXT_UPDATE_INTERVAL = 0.10
Joypad.COOLDOWN_TEXT_EXPIRING_THRESHOLD = 3.0
Joypad.activeCooldownTextButtons = {}
Joypad.readyFlashWatches = {}
Joypad.activeReadyFlashButtons = {}
Joypad.READY_FLASH_MIN_DURATION = 1.5
Joypad.READY_FLASH_WATCH_INTERVAL = 0.05
Joypad.READY_FLASH_DURATION = 0.65
Joypad.readyFlashColor = { r = 1.00, g = 0.90, b = 0.35, a = 0.75 }
Joypad.readyFlashStrengths = {
    low = { label = "Low", alpha = 0.45 },
    medium = { label = "Medium", alpha = 0.75 },
    high = { label = "High", alpha = 1.00 },
}
Joypad.readyFlashDurations = {
    short = { label = "Short", seconds = 0.45 },
    normal = { label = "Normal", seconds = 0.65 },
    long = { label = "Long", seconds = 0.90 },
}
Joypad.SMART_MOUSELOOK_CENTER_CHECK_INTERVAL = 0.04
Joypad.smartMouselookCenterDelays = {
    instant = { label = "Instant", seconds = 0.00 },
    short = { label = "Short", seconds = 0.10 },
    normal = { label = "Normal", seconds = 0.20 },
    long = { label = "Long", seconds = 0.35 },
}
Joypad.activeBorderColor = { r = 1.00, g = 0.82, b = 0.00, a = 1.00 }
Joypad.actionStateColors = {
    usable = { r = 1.00, g = 1.00, b = 1.00, a = 1.00 },
    notUsable = { r = 0.40, g = 0.40, b = 0.40, a = 1.00 },
    noPower = { r = 0.50, g = 0.50, b = 1.00, a = 1.00 },
    outOfRange = { r = 0.80, g = 0.10, b = 0.10, a = 1.00 },
    equippedBorder = { r = 0.40, g = 1.00, b = 0.40, a = 1.00 },
}
Joypad.cooldownTextColors = {
    expiring = { r = 1.00, g = 0.00, b = 0.00, a = 1.00 },
    seconds = { r = 1.00, g = 1.00, b = 0.00, a = 1.00 },
    minutes = { r = 1.00, g = 1.00, b = 1.00, a = 1.00 },
    hours = { r = 0.40, g = 1.00, b = 1.00, a = 1.00 },
    days = { r = 0.40, g = 0.40, b = 1.00, a = 1.00 },
}
Joypad.elapsed = 0
Joypad.settingsRows = nil
Joypad.gridOverlay = nil
Joypad.positionPopup = nil
Joypad.groupOverlay = nil
Joypad.groupPopup = nil
Joypad.lockButton = nil
Joypad.resetButton = nil
Joypad.colorPickerSlot = nil
Joypad.uiCursorFrame = nil
Joypad.uiCursorHighlight = nil
Joypad.uiCursorPanel = nil
Joypad.uiCursorSelected = nil
Joypad.uiCursorActive = false
Joypad.uiCursorBindingsApplied = false
Joypad.stanceHolder = nil
Joypad.stanceButtons = {}

local UpdateSettingsRows
local UpdateEditMode
local UpdateSettingsControls

local function Print(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff66ccff" .. ADDON_NAME .. ":|r " .. tostring(message))
    end
end

local function InCombat()
    return InCombatLockdown and InCombatLockdown()
end

-- p6z10 performance helpers: avoid repeatedly committing identical visual
-- state during OnUpdate/event refreshes.  Wrath's UI engine still does work for
-- no-op SetAlpha/SetText/SetTexture calls, so guard hot paths cheaply.
JOYPAD_VISUAL_EPSILON = 0.001

function JoypadSetAlphaIfChanged(object, alpha)
    if not object or not object.SetAlpha then
        return
    end
    alpha = tonumber(alpha or 0) or 0
    local current = object.joypadLastAlpha
    if current == nil and object.GetAlpha then
        current = tonumber(object:GetAlpha() or 0) or 0
    end
    if current == nil or math.abs((tonumber(current) or 0) - alpha) > JOYPAD_VISUAL_EPSILON then
        object:SetAlpha(alpha)
        object.joypadLastAlpha = alpha
    end
end

function JoypadShowIfHidden(object)
    if object and object.Show and (not object.IsShown or not object:IsShown()) then
        object:Show()
    end
end

function JoypadHideIfShown(object)
    if object and object.Hide and (not object.IsShown or object:IsShown()) then
        object:Hide()
    end
end

function JoypadSetTextIfChanged(fontString, text)
    if not fontString or not fontString.SetText then
        return
    end
    text = tostring(text or "")
    if fontString.joypadLastText ~= text then
        fontString:SetText(text)
        fontString.joypadLastText = text
    end
end

function JoypadSetTextureIfChanged(textureObject, texture)
    if not textureObject or not textureObject.SetTexture then
        return
    end
    if textureObject.joypadLastTexture ~= texture then
        textureObject:SetTexture(texture)
        textureObject.joypadLastTexture = texture
    end
end

function JoypadSetVertexColorIfChanged(textureObject, r, g, b, a)
    if not textureObject or not textureObject.SetVertexColor then
        return
    end
    r = tonumber(r or 1) or 1
    g = tonumber(g or 1) or 1
    b = tonumber(b or 1) or 1
    a = tonumber(a or 1) or 1
    if textureObject.joypadLastVR ~= r or textureObject.joypadLastVG ~= g or textureObject.joypadLastVB ~= b or textureObject.joypadLastVA ~= a then
        textureObject:SetVertexColor(r, g, b, a)
        textureObject.joypadLastVR = r
        textureObject.joypadLastVG = g
        textureObject.joypadLastVB = b
        textureObject.joypadLastVA = a
    end
end

function JoypadGetPlayerClassColor()
    local r, g, b, a = 0.0, 0.85, 1.0, 1.0
    local classFile = nil

    if UnitClass then
        local _, detectedClassFile = UnitClass("player")
        classFile = detectedClassFile
    end

    if classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile] then
        local color = RAID_CLASS_COLORS[classFile]
        r = color.r or r
        g = color.g or g
        b = color.b or b
    end

    return r, g, b, a
end

function JoypadNormalizeTheme(theme)
    theme = string.lower(tostring(theme or "classic"))
    if theme == "elvui" or theme == "elv" then
        return "elvui"
    end
    if theme == "classic" or theme == "none" then
        return "none"
    end
    return "none"
end

function JoypadGetThemeLabel(theme)
    theme = JoypadNormalizeTheme(theme)
    if theme == "elvui" then
        return "ElvUI"
    end
    return "Classic"
end

function JoypadNormalizeDisplayMode(displayMode)
    displayMode = string.lower(tostring(displayMode or "steam"))

    if displayMode == "xbox" or displayMode == "xb" or displayMode == "xbox360" then
        return "xbox"
    end
    if displayMode == "steam" or displayMode == "deck" or displayMode == "steamdeck" or displayMode == "xboxsteam" or displayMode == "xbox/steam" then
        return "steam"
    end
    if displayMode == "playstation" or displayMode == "ps" or displayMode == "psx" then
        return "playstation"
    end
    if displayMode == "nintendo" or displayMode == "switch" or displayMode == "ns" then
        return "nintendo"
    end

    return "steam"
end

function JoypadGetDisplayMode()
    if type(JoypadDB) == "table" then
        return JoypadNormalizeDisplayMode(JoypadDB.displayMode)
    end
    return "steam"
end

function JoypadGetDisplayModeLabel(displayMode)
    displayMode = JoypadNormalizeDisplayMode(displayMode)
    if displayMode == "xbox" then
        return "Xbox"
    elseif displayMode == "steam" then
        return "Steam"
    elseif displayMode == "playstation" then
        return "PlayStation"
    elseif displayMode == "nintendo" then
        return "Nintendo"
    end
    return "Steam"
end

function JoypadGetDisplayModeAltTextColor(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0

    local displayMode = JoypadGetDisplayMode()
    if displayMode == "playstation" and JOYPAD_PLAYSTATION_ALT_TEXT_COLORS then
        local faceColor = JOYPAD_PLAYSTATION_ALT_TEXT_COLORS[joypadSlot]
        if faceColor then
            return faceColor
        end

        local directionKey = JoypadGetDirectionColorKeyForSlot(joypadSlot)
        if directionKey and JOYPAD_PLAYSTATION_DIRECTION_TEXT_COLORS then
            return JOYPAD_PLAYSTATION_DIRECTION_TEXT_COLORS[directionKey]
        end
    elseif displayMode == "nintendo" and JOYPAD_NINTENDO_ALT_TEXT_COLORS then
        local faceColor = JOYPAD_NINTENDO_ALT_TEXT_COLORS[joypadSlot]
        if faceColor then
            return faceColor
        end

        local directionKey = JoypadGetDirectionColorKeyForSlot(joypadSlot)
        if directionKey and JOYPAD_NINTENDO_DIRECTION_TEXT_COLORS then
            return JOYPAD_NINTENDO_DIRECTION_TEXT_COLORS[directionKey]
        end
    end

    return nil
end

JOYPAD_DISPLAY_MODE_SLOT_ENABLED = {
    xbox = {
        [1] = true, [2] = true, [3] = true, [4] = true,
        [5] = true, [6] = true, [7] = true, [8] = true,
        [9] = true, [10] = true, [11] = true, [12] = true,
        [13] = false, [14] = false, [15] = false, [16] = false,
        [17] = false, [18] = false, [19] = false, [20] = false,
        [21] = true, [22] = true, [23] = true, [24] = true,
    },
    steam = {
        [1] = true, [2] = true, [3] = true, [4] = true,
        [5] = true, [6] = true, [7] = true, [8] = true,
        [9] = true, [10] = true, [11] = true, [12] = true,
        [13] = true, [14] = true, [15] = true, [16] = true,
        [17] = true, [18] = true, [19] = true, [20] = true,
        [21] = true, [22] = true, [23] = true, [24] = true,
    },
    playstation = {
        [1] = true, [2] = true, [3] = true, [4] = true,
        [5] = true, [6] = true, [7] = true, [8] = true,
        [9] = true, [10] = true, [11] = true, [12] = true,
        [13] = true, [14] = true, [15] = true, [16] = true,
        [17] = false, [18] = false, [19] = false, [20] = false,
        [21] = false, [22] = false, [23] = false, [24] = false,
    },
    nintendo = {
        [1] = true, [2] = true, [3] = true, [4] = true,
        [5] = true, [6] = true, [7] = true, [8] = true,
        [9] = true, [10] = true, [11] = true, [12] = true,
        [13] = false, [14] = false, [15] = false, [16] = false,
        [17] = false, [18] = false, [19] = false, [20] = false,
        [21] = true, [22] = true, [23] = false, [24] = false,
    },
}

function JoypadGetDisplayModeSlotEnabled(displayMode, joypadSlot)
    displayMode = JoypadNormalizeDisplayMode(displayMode)
    joypadSlot = tonumber(joypadSlot or 0) or 0

    local profile = JOYPAD_DISPLAY_MODE_SLOT_ENABLED and JOYPAD_DISPLAY_MODE_SLOT_ENABLED[displayMode]
    if type(profile) == "table" and profile[joypadSlot] == false then
        return false
    end

    return true
end

function JoypadApplyDisplayModeSlotProfile(displayMode, silent)
    if type(JoypadDB) ~= "table" then
        return
    end

    if type(JoypadDB.slotEnabled) ~= "table" then
        JoypadDB.slotEnabled = {}
    end

    displayMode = JoypadNormalizeDisplayMode(displayMode)

    for joypadSlot = 1, 24 do
        JoypadDB.slotEnabled[joypadSlot] = JoypadGetDisplayModeSlotEnabled(displayMode, joypadSlot)
    end

    if not silent then
        Print("applied " .. JoypadGetDisplayModeLabel(displayMode) .. " slot visibility profile.")
    end
end

function JoypadApplyDisplayModeSlotVisibility()
    if not Joypad or type(Joypad.buttons) ~= "table" then
        return
    end

    if InCombat() then
        Joypad.pendingSlotVisibility = true
        return
    end

    for _, button in ipairs(Joypad.buttons) do
        if button and button.joypadSlot then
            if IsSlotEnabled(button.joypadSlot) then
                button:Show()
            else
                button:Hide()
            end
        end
    end

    if UpdateEditMode then
        UpdateEditMode()
    end
end

local function EnsureDB()
    if type(JoypadDB) ~= "table" then
        JoypadDB = {}
    end

    if JoypadDB.barsVisible == nil then
        JoypadDB.barsVisible = true
    end

    if JoypadDB.hideBlizzardBars == nil then
        JoypadDB.hideBlizzardBars = false
    end

    if JoypadDB.hideKeybindText == nil then
        JoypadDB.hideKeybindText = true
    end

    if JoypadDB.showCooldownText == nil then
        JoypadDB.showCooldownText = true
    end

    if JoypadDB.showReadyFlash == nil then
        JoypadDB.showReadyFlash = true
    end

    if JoypadDB.readyFlashStrength ~= "low" and JoypadDB.readyFlashStrength ~= "medium" and JoypadDB.readyFlashStrength ~= "high" then
        JoypadDB.readyFlashStrength = "medium"
    end

    if JoypadDB.readyFlashDuration ~= "short" and JoypadDB.readyFlashDuration ~= "normal" and JoypadDB.readyFlashDuration ~= "long" then
        JoypadDB.readyFlashDuration = "normal"
    end

    if JoypadDB.showActiveBorder == nil then
        JoypadDB.showActiveBorder = true
    end

    if JoypadDB.shiftySuggestionHighlights == nil then
        JoypadDB.shiftySuggestionHighlights = true
    end

    if JoypadDB.layoutMode ~= "desktop" and JoypadDB.layoutMode ~= "gamepad" then
        JoypadDB.layoutMode = "gamepad"
    end

    if JoypadDB.theme == nil then
        JoypadDB.theme = "none"
    else
        JoypadDB.theme = JoypadNormalizeTheme(JoypadDB.theme)
    end

    JoypadDB.displayMode = JoypadNormalizeDisplayMode(JoypadDB.displayMode)

    if JoypadDB.uiCursorEnabled == nil then
        JoypadDB.uiCursorEnabled = true
    end

    if JoypadDB.uiCursorPanelsOnly == nil then
        JoypadDB.uiCursorPanelsOnly = true
    end

    if JoypadDB.uiCursorShowHighlight == nil then
        JoypadDB.uiCursorShowHighlight = true
    end

    if JoypadDB.uiCursorShowPointer == nil then
        JoypadDB.uiCursorShowPointer = true
    end

    if JoypadDB.uiCursorHideHardwareCursor == nil then
        JoypadDB.uiCursorHideHardwareCursor = false
    end

    if JoypadDB.hideMouseWhileMoving == nil then
        JoypadDB.hideMouseWhileMoving = true
    end

    if JoypadDB.smartMouselookEnabled == nil then
        JoypadDB.smartMouselookEnabled = JoypadDB.hideMouseWhileMoving ~= false
    end
    if JoypadDB.smartMouselookOnMove == nil then JoypadDB.smartMouselookOnMove = true end
    if JoypadDB.smartMouselookOnTarget == nil then JoypadDB.smartMouselookOnTarget = true end
    if JoypadDB.smartMouselookOnSpell == nil then JoypadDB.smartMouselookOnSpell = true end
    if JoypadDB.smartMouselookOnNPC == nil then JoypadDB.smartMouselookOnNPC = false end
    if JoypadDB.smartMouselookOnQuest == nil then JoypadDB.smartMouselookOnQuest = true end
    if JoypadDB.smartMouselookOnLoot == nil then JoypadDB.smartMouselookOnLoot = true end
    if JoypadDB.smartMouselookOnJump == nil then JoypadDB.smartMouselookOnJump = false end
    if JoypadDB.smartMouselookOnCenter == nil then JoypadDB.smartMouselookOnCenter = false end
    if JoypadDB.smartMouselookCenterPreview == nil then JoypadDB.smartMouselookCenterPreview = false end
    JoypadDB.smartMouselookCenterScale = tonumber(JoypadDB.smartMouselookCenterScale or 100) or 100
    if JoypadDB.smartMouselookCenterScale < 50 then JoypadDB.smartMouselookCenterScale = 50 end
    if JoypadDB.smartMouselookCenterScale > 250 then JoypadDB.smartMouselookCenterScale = 250 end
    JoypadDB.smartMouselookCenterDelay = Joypad.NormalizeSmartMouselookCenterDelay and Joypad.NormalizeSmartMouselookCenterDelay(JoypadDB.smartMouselookCenterDelay) or tostring(JoypadDB.smartMouselookCenterDelay or "normal")
    if JoypadDB.smartMouselookBlocker == nil then JoypadDB.smartMouselookBlocker = true end
    if JoypadDB.smartMouselookForceTooltip == nil then JoypadDB.smartMouselookForceTooltip = false end
    if JoypadDB.smartMouselookTooltipAnchor ~= "cursor" and JoypadDB.smartMouselookTooltipAnchor ~= "elvui" and JoypadDB.smartMouselookTooltipAnchor ~= "manual" and JoypadDB.smartMouselookTooltipAnchor ~= "topright" then
        JoypadDB.smartMouselookTooltipAnchor = "elvui"
    end
    if JoypadDB.smartMouselookTooltipPoint == nil then JoypadDB.smartMouselookTooltipPoint = "TOPRIGHT" end
    if JoypadDB.smartMouselookTooltipRelativePoint == nil then JoypadDB.smartMouselookTooltipRelativePoint = "TOPRIGHT" end
    JoypadDB.smartMouselookTooltipX = tonumber(JoypadDB.smartMouselookTooltipX or -230) or -230
    JoypadDB.smartMouselookTooltipY = tonumber(JoypadDB.smartMouselookTooltipY or -4) or -4
    if JoypadDB.smartMouselookMouseoverHint == nil then JoypadDB.smartMouselookMouseoverHint = false end
    if JoypadDB.hideJoypadTargetHint04472 ~= true then
        JoypadDB.smartMouselookMouseoverHint = false
        JoypadDB.smartMouselookTestTooltip = false
        JoypadDB.hideJoypadTargetHint04472 = true
    end
    if JoypadDB.smartMouselookPreferAwesomeTarget == nil then JoypadDB.smartMouselookPreferAwesomeTarget = true end
    -- p6z14: ConsoleXP actiontarget support was removed. Keep no stale runtime
    -- dependency or preference flag in SavedVariables.
    JoypadDB.smartMouselookPreferActionTarget = nil
    if JoypadDB.smartMouselookUseSelectedTarget == nil then JoypadDB.smartMouselookUseSelectedTarget = true end
    if JoypadDB.smartMouselookTestTooltip == nil then JoypadDB.smartMouselookTestTooltip = false end
    if JoypadDB.smartMouselookTooltipOff04448 ~= true then
        JoypadDB.smartMouselookForceTooltip = false
        JoypadDB.smartMouselookTooltipOff04448 = true
    end
    if JoypadDB.smartMouselookPauseOnModifier == nil then JoypadDB.smartMouselookPauseOnModifier = true end
    if JoypadDB.raidCursorEnabled == nil then JoypadDB.raidCursorEnabled = true end
    if JoypadDB.raidCursorTargetOnMove == nil then JoypadDB.raidCursorTargetOnMove = true end
    if JoypadDB.raidCursorAFallback == nil then JoypadDB.raidCursorAFallback = false end
    if JoypadDB.raidCursorLogEnabled == nil then JoypadDB.raidCursorLogEnabled = true end
    JoypadDB.raidCursorHighlightPadding = tonumber(JoypadDB.raidCursorHighlightPadding or 3) or 3
    JoypadDB.raidCursorHighlightBorderSize = tonumber(JoypadDB.raidCursorHighlightBorderSize or 2) or 2
    JoypadDB.raidCursorHighlightAlpha = tonumber(JoypadDB.raidCursorHighlightAlpha or 0.95) or 0.95
    JoypadDB.raidCursorHighlightFillAlpha = tonumber(JoypadDB.raidCursorHighlightFillAlpha or 0.08) or 0.08
    if JoypadDB.raidCursorShowLabel == nil then JoypadDB.raidCursorShowLabel = false end
    if JoypadDB.raidTargetSteeringEnabled == nil then JoypadDB.raidTargetSteeringEnabled = true end
    if JoypadDB.raidTargetSteeringEveryHeal == nil then JoypadDB.raidTargetSteeringEveryHeal = true end
    if JoypadDB.raidTargetSteeringLogEnabled == nil then JoypadDB.raidTargetSteeringLogEnabled = true end
    JoypadDB.raidCursorLog = JoypadDB.raidCursorLog or {}
    if JoypadDB.raidCursorAutoRaid04475 ~= true then
        JoypadDB.raidCursorEnabled = true
        JoypadDB.raidCursorTargetOnMove = true
        JoypadDB.raidCursorAFallback = false
        JoypadDB.raidCursorLogEnabled = true
        JoypadDB.raidCursorAutoRaid04475 = true
    end
    if JoypadDB.raidCursorNoASteal04478 ~= true then
        JoypadDB.raidCursorAFallback = false
        JoypadDB.raidCursorNoASteal04478 = true
    end
    if JoypadDB.raidCursorElvUIHighlight04479 ~= true then
        JoypadDB.raidCursorShowLabel = false
        JoypadDB.raidCursorHighlightPadding = 3
        JoypadDB.raidCursorHighlightBorderSize = 2
        JoypadDB.raidCursorHighlightAlpha = 0.95
        JoypadDB.raidCursorHighlightFillAlpha = 0.08
        JoypadDB.raidCursorElvUIHighlight04479 = true
    end
    if JoypadDB.raidTargetSteering04481 ~= true then
        JoypadDB.raidTargetSteeringEnabled = true
        JoypadDB.raidTargetSteeringEveryHeal = true
        JoypadDB.raidTargetSteeringLogEnabled = true
        JoypadDB.raidTargetSteering04481 = true
    end

    -- v0.44.36: the UI cursor scanner and combat-start binding cleanup are now
    -- hardened, so make UI Cursor the default again. This one-time migration also
    -- re-enables it for users who received the temporary v0.44.33 safety disable.
    if JoypadDB.uiCursorDefaultOn04436 ~= true then
        JoypadDB.uiCursorDefaultOn04436 = true
    end
    if JoypadDB.uiCursorTargetedSafe04463 ~= true then
        JoypadDB.uiCursorEnabled = true
        JoypadDB.uiCursorTargetedSafe04463 = true
    end

    if JoypadDB.uiCursorDebugEnabled == nil then
        JoypadDB.uiCursorDebugEnabled = false
    end

    if JoypadDB.uiCursorDebugChat == nil then
        JoypadDB.uiCursorDebugChat = true
    end

    if JoypadDB.showAltScaleControls == nil then
        JoypadDB.showAltScaleControls = false
    end

    if JoypadDB.showAltColorControls == nil then
        JoypadDB.showAltColorControls = false
    end

    -- v0.44.13: default optional Appearance clutter off.
    -- Apply once for existing users so the Touch Bar and optional Alt columns
    -- start hidden unless the user later turns them back on.
    if JoypadDB.optionalAppearanceDefaults04413 ~= true then
        JoypadDB.showAltScaleControls = false
        JoypadDB.showAltColorControls = false
        JoypadDB.stanceBarVisible = false
        JoypadDB.optionalAppearanceDefaults04413 = true
    end

    if JoypadDB.unlocked == nil then
        JoypadDB.unlocked = false
    end

    if JoypadDB.snapToGrid == nil then
        JoypadDB.snapToGrid = true
    end

    if JoypadDB.snapToGridThreshold == nil then
        JoypadDB.snapToGridThreshold = 10
    end

    if JoypadDB.stanceBarVisible == nil then
        JoypadDB.stanceBarVisible = JOYPAD_STANCE_DEFAULT_VISIBLE ~= false
    end

    if JoypadDB.stanceBarScale == nil then
        JoypadDB.stanceBarScale = JOYPAD_STANCE_DEFAULT_SCALE or 70
    end

    if JoypadDB.stanceBarX == nil then
        JoypadDB.stanceBarX = JOYPAD_STANCE_DEFAULT_X or 0
    end

    if JoypadDB.stanceBarY == nil then
        JoypadDB.stanceBarY = JOYPAD_STANCE_DEFAULT_Y or -460
    end

    if type(JoypadDB.diamondSlots) ~= "table" then
        JoypadDB.diamondSlots = {}
        for slot, enabled in pairs(JOYPAD_DEFAULT_DIAMOND_SLOTS or {}) do
            JoypadDB.diamondSlots[slot] = enabled and true or nil
        end
    end

    if type(JoypadDB.positions) ~= "table" then
        JoypadDB.positions = {}
    end

    if type(JoypadDB.scales) ~= "table" then
        JoypadDB.scales = {}
    end

    if type(JoypadDB.altTextScales) ~= "table" then
        JoypadDB.altTextScales = {}
    end

    if type(JoypadDB.altTextColors) ~= "table" then
        JoypadDB.altTextColors = {}
    end

    if type(JoypadDB.altPartTextColors) ~= "table" then
        JoypadDB.altPartTextColors = {}
    end

    if JoypadDB.minimapAngle == nil then
        JoypadDB.minimapAngle = 225
    end

    if type(JoypadDB.slotEnabled) ~= "table" then
        JoypadDB.slotEnabled = {}
    end

    if type(JoypadDB.actionSlots) ~= "table" then
        JoypadDB.actionSlots = {}
    end

    if type(JoypadDB.bindingModes) ~= "table" then
        JoypadDB.bindingModes = {}
    end

    if type(JoypadDB.keybindCommands) ~= "table" then
        JoypadDB.keybindCommands = {}
    end

    if type(JoypadDB.layerAssignments) ~= "table" then
        JoypadDB.layerAssignments = {}
    end

    -- p6z16: AwesomeWotLK-native interaction. Migrate legacy ConsoleXP
    -- interaction assignments, and undo p6z15's temporary INTERACTTARGET
    -- fallback only for profiles that actually received that migration.
    if JoypadDB.awesomeInteractMigrationP6z16 ~= true and not InCombat() then
        local undoP6z15StockFallback = JoypadDB.stockInteractMigrationP6z15 == true
        if type(JoypadDB.keybindCommands) == "table" then
            for slot, command in pairs(JoypadDB.keybindCommands) do
                if command == "CXPINTERACT" or (undoP6z15StockFallback and command == "INTERACTTARGET") then
                    JoypadDB.keybindCommands[slot] = "INTERACTIONKEYBIND"
                end
            end
        end
        if type(JoypadDB.layerAssignments) == "table" then
            for _, slotAssignments in pairs(JoypadDB.layerAssignments) do
                if type(slotAssignments) == "table" then
                    for _, assignment in pairs(slotAssignments) do
                        if type(assignment) == "table" and assignment.type == "keybind" then
                            local command = assignment.command
                            if command == "CXPINTERACT" or (undoP6z15StockFallback and command == "INTERACTTARGET") then
                                assignment.command = "INTERACTIONKEYBIND"
                            end
                        end
                    end
                end
            end
        end
        JoypadDB.awesomeInteractMigrationP6z16 = true
    end

    -- p6z13: remap the base action row so the most-used raid-throughput
    -- actions sit closer to the start of the physical controller row:
    -- B=2, X=1, Y=3, DUp=9, DLeft=7, DRight=8, DDown=10,
    -- R1=4, Select=5, Start=6.  Clear saved base-layer overrides for the
    -- affected slots once so existing characters receive the new default while
    -- preserving their Shift/Ctrl/Shift+Ctrl layer assignments.
    if JoypadDB.raidRowRemapP6z13 ~= true and not InCombat() then
        local remapSlots = { 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }
        for _, joypadSlot in ipairs(remapSlots) do
            if type(JoypadDB.layerAssignments[joypadSlot]) == "table" then
                JoypadDB.layerAssignments[joypadSlot].base = nil
            end
            if type(JoypadDB.actionSlots) == "table" then
                JoypadDB.actionSlots[joypadSlot] = nil
            end
            if type(JoypadDB.bindingModes) == "table" then
                JoypadDB.bindingModes[joypadSlot] = nil
            end
        end
        JoypadDB.raidRowRemapP6z13 = true
    end

    if JoypadDB.inputLogEnabled == nil then
        JoypadDB.inputLogEnabled = true
    end
    if type(JoypadDB.inputLog) ~= "table" then
        JoypadDB.inputLog = {}
    end
    if type(JoypadDB.inputLogMeta) ~= "table" then
        JoypadDB.inputLogMeta = {}
    end
    if JoypadDB.warnMissingKeybinds == nil then
        JoypadDB.warnMissingKeybinds = true
    end

    if JoypadDB.petUtilityDefaults04449 ~= true and not InCombat() then
        for _, joypadSlot in ipairs({ 13, 14, 15, 16, 21, 22, 23, 24 }) do
            JoypadDB.layerAssignments[joypadSlot] = nil
        end
        JoypadDB.petUtilityDefaults04449 = true
    end

    for i = 1, 24 do
        if JoypadDB.slotEnabled[i] == nil then
            JoypadDB.slotEnabled[i] = JoypadGetDisplayModeSlotEnabled(JoypadDB.displayMode, i)
        end
        if JoypadDB.altTextScales[i] == nil then
            JoypadDB.altTextScales[i] = GetDefaultAltTextScale(i)
        end
    end

    -- v0.44.12: display modes now have default on/off button profiles.
    -- Apply the current profile once for existing users, and apply it every time
    -- the user changes display mode below.
    if JoypadDB.displayModeSlotProfileVersion ~= "0.44.12" then
        JoypadApplyDisplayModeSlotProfile(JoypadDB.displayMode, true)
        JoypadDB.displayModeSlotProfileVersion = "0.44.12"
    end

    -- v0.40: Alt labels now auto-fit by visual group.  Reset the optional
    -- per-slot Alt % modifier once so older fixed-tuning values do not fight
    -- the group fitter.
    if JoypadDB.altTextDefaultScaleProfile ~= "0.40.0" then
        for i = 1, 24 do
            JoypadDB.altTextScales[i] = GetDefaultAltTextScale(i)
        end
        JoypadDB.altTextDefaultScaleProfile = "0.40.0"
    end

    -- v0.43.1: copy the user's tuned standalone D-pad Alt % values onto
    -- the matching L/R split-direction arrows once.  This keeps the current
    -- hand-tuned values without needing to know them in the addon code.
    if JoypadDB.lrArrowAltScaleSyncProfile ~= "0.43.1" then
        JoypadDB.altTextScales[13] = GetAltTextScale(5)  -- L^ follows ^
        JoypadDB.altTextScales[17] = GetAltTextScale(5)  -- R^ follows ^
        JoypadDB.altTextScales[14] = GetAltTextScale(6)  -- L‹ follows ‹
        JoypadDB.altTextScales[18] = GetAltTextScale(6)  -- R‹ follows ‹
        JoypadDB.altTextScales[15] = GetAltTextScale(7)  -- L› follows ›
        JoypadDB.altTextScales[19] = GetAltTextScale(7)  -- R› follows ›
        JoypadDB.altTextScales[16] = GetAltTextScale(8)  -- Lv follows v
        JoypadDB.altTextScales[20] = GetAltTextScale(8)  -- Rv follows v
        JoypadDB.lrArrowAltScaleSyncProfile = "0.43.1"
    end
end

function JoypadIsDiamondViewportEnabled(joypadSlot)
    EnsureDB()
    joypadSlot = tonumber(joypadSlot or 0) or 0
    return JoypadDB.diamondSlots and JoypadDB.diamondSlots[joypadSlot] == true
end

local function ShortKey(key)
    if not key or key == "" then
        return ""
    end

    key = string.upper(key)

    key = string.gsub(key, "CTRL%-", "C+")
    key = string.gsub(key, "SHIFT%-", "S+")
    key = string.gsub(key, "ALT%-", "A+")

    key = string.gsub(key, "MOUSEWHEELUP", "MWU")
    key = string.gsub(key, "MOUSEWHEELDOWN", "MWD")
    key = string.gsub(key, "MIDDLEMOUSE", "M3")
    key = string.gsub(key, "BUTTON", "M")
    key = string.gsub(key, "NUMPAD", "N")
    key = string.gsub(key, "SPACE", "Sp")
    key = string.gsub(key, "ESCAPE", "Esc")
    key = string.gsub(key, "BACKSPACE", "Bk")
    key = string.gsub(key, "DELETE", "Del")
    key = string.gsub(key, "INSERT", "Ins")
    key = string.gsub(key, "HOME", "Hm")
    key = string.gsub(key, "END", "End")
    key = string.gsub(key, "PAGEUP", "PgU")
    key = string.gsub(key, "PAGEDOWN", "PgD")
    key = string.gsub(key, "PLUS", "+")
    key = string.gsub(key, "MINUS", "-")

    return key
end

local function GetBindingLabel(command)
    if not command or not GetBindingKey then
        return ""
    end

    local key1 = GetBindingKey(command)
    return ShortKey(key1)
end

local function GetLayerBindingLabel(command, layerKey)
    local label = GetBindingLabel(command)
    layerKey = NormalizeJoypadLayerKey(layerKey)

    if label == "" or layerKey == "base" then
        return label
    end

    if layerKey == "shift" then
        return "L2+" .. label
    elseif layerKey == "ctrl" then
        return "R2+" .. label
    elseif layerKey == "shiftctrl" then
        return "L2+R2+" .. label
    end

    return label
end

local function ShowFrame(frame, show)
    if not frame then
        return
    end
    if show then
        frame:Show()
    else
        frame:Hide()
    end
end

local function ClearAndSetLeft(frame, parent, x, width)
    if not frame or not parent then
        return
    end
    frame:ClearAllPoints()
    frame:SetPoint("LEFT", parent, "LEFT", x, 0)
    if width and frame.SetWidth then
        frame:SetWidth(width)
    end
end

UpdateSettingsControls = function()
    EnsureDB()

    local panel = Joypad.settingsPanel
    local showAltScale = JoypadDB.showAltScaleControls == true
    local showAltColor = JoypadDB.showAltColorControls == true

    if panel then
        if panel.showBars then
            panel.showBars:SetChecked(JoypadDB.barsVisible and true or false)
        end
        if panel.showStanceBar then
            panel.showStanceBar:SetChecked(JoypadDB.stanceBarVisible ~= false)
        end
        if panel.stanceScaleBox and not panel.stanceScaleBox:HasFocus() then
            panel.stanceScaleBox:SetText(tostring(Joypad:GetStanceBarScale()))
            if panel.stanceScaleBox.SetCursorPosition then
                panel.stanceScaleBox:SetCursorPosition(0)
            end
        end
        if panel.hideBlizzardBars then
            panel.hideBlizzardBars:SetChecked(JoypadDB.hideBlizzardBars and true or false)
        end
        if panel.hideKeybindText then
            panel.hideKeybindText:SetChecked(JoypadDB.hideKeybindText and true or false)
        end
        if panel.showCooldownText then
            panel.showCooldownText:SetChecked(JoypadDB.showCooldownText ~= false)
        end
        if panel.showReadyFlash then
            panel.showReadyFlash:SetChecked(JoypadDB.showReadyFlash ~= false)
        end
        if panel.readyFlashStrengthDropdown and UIDropDownMenu_SetText then
            UIDropDownMenu_SetText(panel.readyFlashStrengthDropdown, Joypad.GetReadyFlashStrengthLabel(JoypadDB.readyFlashStrength))
        end
        if panel.readyFlashDurationDropdown and UIDropDownMenu_SetText then
            UIDropDownMenu_SetText(panel.readyFlashDurationDropdown, Joypad.GetReadyFlashDurationLabel(JoypadDB.readyFlashDuration))
        end
        if panel.showActiveBorder then
            panel.showActiveBorder:SetChecked(JoypadDB.showActiveBorder ~= false)
        end
        if panel.unlockPositioning then
            panel.unlockPositioning:SetChecked(JoypadDB.unlocked and true or false)
        end
        if panel.themeDropdown and UIDropDownMenu_SetText then
            UIDropDownMenu_SetText(panel.themeDropdown, JoypadGetThemeLabel(JoypadDB.theme))
        end
        if panel.snapToGrid then
            panel.snapToGrid:SetChecked(JoypadDB.snapToGrid ~= false)
        end
        if panel.gamepadLayoutButton then
            panel.gamepadLayoutButton:SetText("Gamepad")
        end
        if panel.desktopLayoutButton then
            panel.desktopLayoutButton:SetText("Desktop")
        end
        local displayMode = JoypadGetDisplayMode()
        if panel.xboxDisplayButton then
            if displayMode == "xbox" then
                panel.xboxDisplayButton:SetText("[Xbox]")
            else
                panel.xboxDisplayButton:SetText("Xbox")
            end
        end
        if panel.steamDisplayButton then
            if displayMode == "steam" then
                panel.steamDisplayButton:SetText("[Steam]")
            else
                panel.steamDisplayButton:SetText("Steam")
            end
        end
        if panel.playStationDisplayButton then
            if displayMode == "playstation" then
                panel.playStationDisplayButton:SetText("[PlayStation]")
            else
                panel.playStationDisplayButton:SetText("PlayStation")
            end
        end
        if panel.nintendoDisplayButton then
            if displayMode == "nintendo" then
                panel.nintendoDisplayButton:SetText("[Nintendo]")
            else
                panel.nintendoDisplayButton:SetText("Nintendo")
            end
        end
        if panel.showAltScaleControls then
            panel.showAltScaleControls:SetChecked(showAltScale and true or false)
        end
        if panel.showAltColorControls then
            panel.showAltColorControls:SetChecked(showAltColor and true or false)
        end
        if panel.leftTrackpadPrefixSwatch then
            local r, g, b = JoypadGetAltPartTextColor("leftTrackpadPrefix")
            panel.leftTrackpadPrefixSwatch:SetTexture(r, g, b, 1)
        end
        if panel.rightTrackpadPrefixSwatch then
            local r, g, b = JoypadGetAltPartTextColor("rightTrackpadPrefix")
            panel.rightTrackpadPrefixSwatch:SetTexture(r, g, b, 1)
        end
    end

    local uiPanel = Joypad.uiCursorPanel
    if uiPanel then
        if uiPanel.enableCursor then
            uiPanel.enableCursor:SetChecked(JoypadDB.uiCursorEnabled and true or false)
        end
        if uiPanel.panelsOnly then
            uiPanel.panelsOnly:SetChecked(JoypadDB.uiCursorPanelsOnly ~= false)
        end
        if uiPanel.showHighlight then
            uiPanel.showHighlight:SetChecked(JoypadDB.uiCursorShowHighlight ~= false)
        end
        if uiPanel.showPointer then
            uiPanel.showPointer:SetChecked(JoypadDB.uiCursorShowPointer ~= false)
        end
        if uiPanel.hideHardware then
            uiPanel.hideHardware:SetChecked(JoypadDB.uiCursorHideHardwareCursor == true)
        end
    end

    if panel then
        local nextX = panel.columnBaseX or 166
        local altScaleX = nextX
        if showAltScale then
            nextX = nextX + 60
        end

        local altColorX = nextX
        if showAltColor then
            nextX = nextX + 76
        end

        local keyX = nextX
        local modeX = keyX + 38
        local presetX = keyX + (panel.presetXOffsetNoMode or 58)
        if panel.hasModeColumn then
            presetX = modeX + 70
        end
        local actionSlotX = modeX
        if panel.hasModeColumn then
            actionSlotX = modeX + 74
        end
        if panel.hasKeybindPresetColumn then
            actionSlotX = presetX + 132
        end
        local actionX = actionSlotX + 78
        if not panel.hasActionSlotColumn then
            actionX = keyX + 112
        end

        ShowFrame(panel.altScaleHeader, showAltScale)
        ShowFrame(panel.altColorHeader, showAltColor)

        if panel.altScaleHeader and panel.header then
            ClearAndSetLeft(panel.altScaleHeader, panel.header, altScaleX, 58)
        end
        if panel.altColorHeader and panel.header then
            ClearAndSetLeft(panel.altColorHeader, panel.header, altColorX, 70)
        end
        ShowFrame(panel.slotHeader, not (panel.hideSlotColumn and true or false))
        ShowFrame(panel.diamondHeader, not (panel.hideDiamondColumn and true or false))
        if panel.diamondHeader and panel.header and not panel.hideDiamondColumn then
            ClearAndSetLeft(panel.diamondHeader, panel.header, 94, 26)
        end
        ShowFrame(panel.altHeader, not (panel.hideAltHeader and true or false))
        if panel.altHeader and panel.header then
            ClearAndSetLeft(panel.altHeader, panel.header, 128, 54)
        end
        ShowFrame(panel.keyHeader, not (panel.hideKeyHeader and true or false))
        if panel.keyHeader and panel.header then
            ClearAndSetLeft(panel.keyHeader, panel.header, keyX, 100)
        end
        ShowFrame(panel.modeHeader, panel.hasModeColumn and true or false)
        if panel.modeHeader and panel.header and panel.hasModeColumn then
            ClearAndSetLeft(panel.modeHeader, panel.header, modeX, 68)
        end
        ShowFrame(panel.keybindPresetHeader, panel.hasKeybindPresetColumn and true or false)
        if panel.keybindPresetHeader and panel.header and panel.hasKeybindPresetColumn then
            ClearAndSetLeft(panel.keybindPresetHeader, panel.header, presetX, 126)
        end
        ShowFrame(panel.actionSlotHeader, panel.hasActionSlotColumn and true or false)
        if panel.actionSlotHeader and panel.header and panel.hasActionSlotColumn then
            ClearAndSetLeft(panel.actionSlotHeader, panel.header, actionSlotX, 72)
        end
        ShowFrame(panel.actionHeader, not (panel.hideActionColumn and true or false))
        if panel.actionHeader and panel.header and not panel.hideActionColumn then
            ClearAndSetLeft(panel.actionHeader, panel.header, actionX, 80)
        end

        if Joypad.settingsRows then
            for _, row in ipairs(Joypad.settingsRows) do
                ShowFrame(row.altScaleBox, showAltScale)
                ShowFrame(row.altColorButton, showAltColor)
                if row.altScaleBox then
                    ClearAndSetLeft(row.altScaleBox, row, altScaleX, 44)
                end
                if row.altColorButton then
                    ClearAndSetLeft(row.altColorButton, row, altColorX, 24)
                end
                ShowFrame(row.slotText, not (panel.hideSlotColumn and true or false))
                ShowFrame(row.diamondCheck, not (panel.hideDiamondColumn and true or false))
                if row.diamondCheck and not panel.hideDiamondColumn then
                    ClearAndSetLeft(row.diamondCheck, row, 92, 20)
                end
                if row.altText then
                    ClearAndSetLeft(row.altText, row, 128, 54)
                end
                ShowFrame(row.keyText, not (panel.hideKeyHeader and true or false))
                if row.keyText and not panel.hideKeyHeader then
                    ClearAndSetLeft(row.keyText, row, keyX, 100)
                end
                ShowFrame(row.modeButton, panel.hasModeColumn and true or false)
                if row.modeButton and panel.hasModeColumn then
                    ClearAndSetLeft(row.modeButton, row, modeX, 64)
                end
                ShowFrame(row.keybindDropdown, panel.hasKeybindPresetColumn and true or false)
                if row.keybindDropdown and panel.hasKeybindPresetColumn then
                    ClearAndSetLeft(row.keybindDropdown, row, presetX, 126)
                end
                ShowFrame(row.actionSlotBox, panel.hasActionSlotColumn and true or false)
                if row.actionSlotBox and panel.hasActionSlotColumn then
                    ClearAndSetLeft(row.actionSlotBox, row, actionSlotX, 64)
                end
                ShowFrame(row.iconButton, not (panel.hideActionColumn and true or false))
                if row.iconButton and not panel.hideActionColumn then
                    ClearAndSetLeft(row.iconButton, row, actionX, 18)
                end
            end
        end
    end
end

function JoypadIsSettingsPanelVisible()
    local panel = Joypad and Joypad.settingsPanel
    if panel and panel.IsShown and panel:IsShown() then
        return true
    end

    panel = Joypad and Joypad.bindingsPanel
    if panel and panel.IsShown and panel:IsShown() then
        return true
    end

    panel = Joypad and Joypad.uiCursorPanel
    if panel and panel.IsShown and panel:IsShown() then
        return true
    end

    return false
end

UpdateSettingsRows = function()
    if not JoypadIsSettingsPanelVisible() then
        return
    end

    local function UpdateRowCollection(rows, panel, contentHeightBase)
        if not rows then
            return 0
        end

        local totalRowsHeight = 0

        for collectionIndex, row in ipairs(rows) do
            local joypadSlot = tonumber(row.joypadSlot or collectionIndex) or collectionIndex
            local layerKey = NormalizeJoypadLayerKey(row.layerKey or "base")
            local actionSlot, bindingCommand, joypadRow, indexOnBar = GetJoypadSlotInfo(joypadSlot, layerKey)
            local bindingMode = GetJoypadBindingMode(joypadSlot, layerKey)
            local texture = nil
            if bindingMode == "action" then
                texture = actionSlot and GetActionTexture and GetActionTexture(actionSlot)
            else
                texture = GetKeybindPresetIcon(GetJoypadKeybindCommand(joypadSlot, layerKey))
            end

            row.actionSlot = actionSlot
            row.bindingMode = bindingMode
            row.bindingCommand = bindingCommand
            row.joypadSlot = joypadSlot
            row.layerKey = layerKey
            row.joypadRow = joypadRow
            row.indexOnBar = indexOnBar

            local enabled = IsSlotEnabled(joypadSlot)

            if row.slotText then
                row.slotText:SetText(tostring(joypadSlot))
                ShowFrame(row.slotText, not (panel and panel.hideSlotColumn and true or false))
            end

            if row.enabledCheck then
                row.enabledCheck:SetChecked(enabled and true or false)
            end

            if row.diamondCheck then
                row.diamondCheck:SetChecked(JoypadIsDiamondViewportEnabled(joypadSlot) and true or false)
            end

            local altFontSize = GetAltTextFontSize(joypadSlot)
            local rowHeight = math.max(18, altFontSize + 6)
            if panel and panel.fixedRowHeight then
                rowHeight = panel.fixedRowHeight
            end
            row:SetHeight(rowHeight)

            if row.altText then
                ApplyAltTextAppearance(row.altText, joypadSlot)
                if row.altTextOverride then
                    row.altText:SetText(row.altTextOverride)
                elseif layerKey == "shift" then
                    row.altText:SetText("L2+" .. tostring(GetAltLabel(joypadSlot) or ""))
                elseif layerKey == "ctrl" then
                    row.altText:SetText("R2+" .. tostring(GetAltLabel(joypadSlot) or ""))
                elseif layerKey == "shiftctrl" then
                    row.altText:SetText("L2+R2+" .. tostring(GetAltLabel(joypadSlot) or ""))
                end
                row.altText:SetWidth(row.altTextWidth or 54)
                row.altText:SetJustifyH(row.altTextJustifyH or "CENTER")
                row.altText:SetJustifyV("MIDDLE")
            end

            if row.altScaleBox and not row.altScaleBox:HasFocus() then
                row.altScaleBox:SetText(tostring(GetAltTextScale(joypadSlot)))
                if row.altScaleBox.SetCursorPosition then
                    row.altScaleBox:SetCursorPosition(0)
                end
            end

            if row.altColorSwatch then
                local r, g, b = GetAltTextColor(joypadSlot)
                row.altColorSwatch:SetTexture(r, g, b, 1)
            end

            if row.altColorButton then
                row.altColorButton.altColorHex = GetAltTextColorHex(joypadSlot)
            end

            if row.keyText then
                local label = GetLayerBindingLabel(bindingCommand, layerKey)
                if label == "" then
                    label = "-"
                end
                row.keyText:SetText(label)
            end

            if row.modeButton then
                row.modeButton:SetText(GetJoypadBindingModeLabel(joypadSlot, layerKey))
            end

            if row.keybindDropdown then
                row.keybindDropdown:SetText(GetJoypadPresetDisplayText(joypadSlot, layerKey))
            end
            if row.keybindDropdownText then
                row.keybindDropdownText:SetText(GetJoypadPresetDisplayText(joypadSlot, layerKey))
            end
            if row.presetText then
                row.presetText:SetText(GetJoypadPresetDisplayText(joypadSlot, layerKey))
            end

            if row.actionSlotBox then
                if panel and panel.hasActionSlotColumn == false then
                    row.actionSlotBox:Hide()
                elseif not row.actionSlotBox:HasFocus() then
                    row.actionSlotBox:SetText(GetJoypadBindingDisplayText(joypadSlot, layerKey))
                    if row.actionSlotBox.SetCursorPosition then
                        row.actionSlotBox:SetCursorPosition(0)
                    end
                end
            end

            if row.icon then
                if texture then
                    row.icon:SetTexture(texture)
                    row.icon:Show()
                else
                    row.icon:SetTexture(nil)
                    row.icon:Hide()
                end
            end

            if row.emptyIcon then
                if texture then
                    row.emptyIcon:Hide()
                else
                    row.emptyIcon:Show()
                end
            end

            local alpha = enabled and 1 or 0.45
            if row.slotText then row.slotText:SetAlpha(alpha) end
            if row.enabledCheck then row.enabledCheck:SetAlpha(alpha) end
            if row.altText then row.altText:SetAlpha(alpha) end
            if row.altScaleBox then row.altScaleBox:SetAlpha(alpha) end
            if row.altColorButton then row.altColorButton:SetAlpha(alpha) end
            if row.keyText then row.keyText:SetAlpha(alpha) end
            if row.modeButton then row.modeButton:SetAlpha(alpha) end
            if row.keybindDropdown then row.keybindDropdown:SetAlpha(alpha) end
            if row.presetText then row.presetText:SetAlpha(alpha) end
            if row.actionSlotBox then row.actionSlotBox:SetAlpha(alpha) end
            if row.iconButton then row.iconButton:SetAlpha(alpha) end

            totalRowsHeight = totalRowsHeight + row:GetHeight() + 2
        end

        if panel and panel.scrollContent then
            panel.scrollContent:SetHeight((contentHeightBase or 250) + totalRowsHeight + SETTINGS_BOTTOM_PADDING)
        end

        return totalRowsHeight
    end

    UpdateRowCollection(Joypad.settingsRows, Joypad.settingsPanel, 250)
    UpdateRowCollection(Joypad.bindingRows, Joypad.bindingsPanel, 320)

    UpdateSettingsControls()
end

function Joypad.FormatCooldownText(remaining)
    remaining = tonumber(remaining or 0) or 0

    if remaining <= 0 then
        return ""
    end

    if remaining >= 86400 then
        return tostring(math.ceil(remaining / 86400)) .. "d"
    elseif remaining >= 3600 then
        return tostring(math.ceil(remaining / 3600)) .. "h"
    elseif remaining >= 60 then
        return tostring(math.ceil(remaining / 60)) .. "m"
    elseif remaining < 3 then
        return string.format("%.1f", remaining)
    end

    return tostring(math.ceil(remaining))
end

function Joypad.ApplyCooldownTextColor(text, remaining)
    if not text then
        return
    end

    remaining = tonumber(remaining or 0) or 0
    local colors = Joypad.cooldownTextColors or {}
    local color = colors.minutes or { r = 1, g = 1, b = 1, a = 1 }

    if remaining < (Joypad.COOLDOWN_TEXT_EXPIRING_THRESHOLD or 3) then
        color = colors.expiring or color
    elseif remaining >= 86400 then
        color = colors.days or color
    elseif remaining >= 3600 then
        color = colors.hours or color
    elseif remaining >= 60 then
        color = colors.minutes or color
    else
        color = colors.seconds or color
    end

    text:SetTextColor(color.r or 1, color.g or 1, color.b or 1, color.a or 1)
end

function Joypad.HideCooldownText(button)
    if not button then
        return
    end

    Joypad.activeCooldownTextButtons[button] = nil
    button.cooldownTextActive = nil
    button.cooldownTextStart = nil
    button.cooldownTextDuration = nil

    if button.cooldownText then
        button.cooldownText:SetText("")
        button.cooldownText:Hide()
    end
end

function Joypad.UpdateCooldownText(button, now)
    if not button or not button.cooldownText then
        return false
    end

    if type(JoypadDB) == "table" and JoypadDB.showCooldownText == false then
        Joypad.HideCooldownText(button)
        return false
    end

    local start = tonumber(button.cooldownTextStart or 0) or 0
    local duration = tonumber(button.cooldownTextDuration or 0) or 0
    if start <= 0 or duration <= Joypad.COOLDOWN_TEXT_MIN_DURATION then
        Joypad.HideCooldownText(button)
        return false
    end

    now = now or (GetTime and GetTime()) or 0
    local remaining = (start + duration) - now
    if remaining <= 0 then
        Joypad.HideCooldownText(button)
        return false
    end

    button.cooldownText:SetText(Joypad.FormatCooldownText(remaining))
    Joypad.ApplyCooldownTextColor(button.cooldownText, remaining)
    button.cooldownText:Show()
    return true
end

function Joypad.RegisterCooldownText(button, start, duration, enable)
    if not button or not button.cooldownText then
        return
    end

    start = tonumber(start or 0) or 0
    duration = tonumber(duration or 0) or 0

    if (type(JoypadDB) == "table" and JoypadDB.showCooldownText == false) or start <= 0 or duration <= Joypad.COOLDOWN_TEXT_MIN_DURATION or enable == 0 then
        Joypad.HideCooldownText(button)
        return
    end

    button.cooldownTextStart = start
    button.cooldownTextDuration = duration
    button.cooldownTextActive = true
    Joypad.activeCooldownTextButtons[button] = true
    Joypad.UpdateCooldownText(button)
end

function Joypad.UpdateActiveCooldownTexts(elapsed)
    Joypad.cooldownTextElapsed = (Joypad.cooldownTextElapsed or 0) + (elapsed or 0)
    if Joypad.cooldownTextElapsed < Joypad.COOLDOWN_TEXT_UPDATE_INTERVAL then
        return
    end
    Joypad.cooldownTextElapsed = 0

    local now = (GetTime and GetTime()) or 0
    for button in pairs(Joypad.activeCooldownTextButtons) do
        Joypad.UpdateCooldownText(button, now)
    end
end


function Joypad.NormalizeReadyFlashStrength(value)
    value = tostring(value or "")
    if value == "low" or value == "medium" or value == "high" then
        return value
    end
    return "medium"
end

function Joypad.NormalizeReadyFlashDuration(value)
    value = tostring(value or "")
    if value == "short" or value == "normal" or value == "long" then
        return value
    end
    return "normal"
end

function Joypad.GetReadyFlashStrengthLabel(value)
    value = Joypad.NormalizeReadyFlashStrength(value)
    return ((Joypad.readyFlashStrengths or {})[value] or {}).label or "Medium"
end

function Joypad.GetReadyFlashDurationLabel(value)
    value = Joypad.NormalizeReadyFlashDuration(value)
    return ((Joypad.readyFlashDurations or {})[value] or {}).label or "Normal"
end

function Joypad.GetReadyFlashDuration()
    local value = Joypad.NormalizeReadyFlashDuration(type(JoypadDB) == "table" and JoypadDB.readyFlashDuration or nil)
    return ((Joypad.readyFlashDurations or {})[value] or {}).seconds or (Joypad.READY_FLASH_DURATION or 0.65)
end

function Joypad.GetReadyFlashColor()
    local base = Joypad.readyFlashColor or { r = 1, g = 0.9, b = 0.35, a = 0.75 }
    local value = Joypad.NormalizeReadyFlashStrength(type(JoypadDB) == "table" and JoypadDB.readyFlashStrength or nil)
    local strength = ((Joypad.readyFlashStrengths or {})[value] or {}).alpha or (base.a or 0.75)
    return { r = base.r or 1, g = base.g or 0.9, b = base.b or 0.35, a = strength }
end

function Joypad.ClearReadyFlash(button)
    if not button then
        return
    end

    Joypad.activeReadyFlashButtons[button] = nil
    button.readyFlashElapsed = nil

    if button.readyFlash then
        JoypadSetAlphaIfChanged(button.readyFlash, 0)
        JoypadHideIfShown(button.readyFlash)
    end
end

function Joypad.TriggerReadyFlash(button)
    if not button or not button.readyFlash then
        return
    end

    if type(JoypadDB) == "table" and JoypadDB.showReadyFlash == false then
        Joypad.ClearReadyFlash(button)
        return
    end

    local color = Joypad.GetReadyFlashColor()
    button.readyFlashElapsed = 0
    button.readyFlash:SetVertexColor(color.r or 1, color.g or 0.9, color.b or 0.35, color.a or 0.75)
    JoypadSetAlphaIfChanged(button.readyFlash, color.a or 0.75)
    JoypadShowIfHidden(button.readyFlash)
    Joypad.activeReadyFlashButtons[button] = true
end

function Joypad.ClearReadyFlashWatch(button)
    if not button then
        return
    end

    Joypad.readyFlashWatches[button] = nil
    button.readyFlashStart = nil
    button.readyFlashDuration = nil
    button.readyFlashEnd = nil
    button.readyFlashActionSlot = nil
end

function Joypad.MaybeFinishReadyFlashWatch(button, actionSlot)
    if not button then
        return
    end

    local watchedEnd = tonumber(button.readyFlashEnd or 0) or 0
    local watchedActionSlot = tonumber(button.readyFlashActionSlot or 0) or 0
    Joypad.ClearReadyFlashWatch(button)

    if watchedEnd <= 0 then
        return
    end

    if type(JoypadDB) == "table" and JoypadDB.showReadyFlash == false then
        return
    end

    actionSlot = tonumber(actionSlot or 0) or 0
    if actionSlot > 0 and watchedActionSlot > 0 and actionSlot ~= watchedActionSlot then
        return
    end

    local now = (GetTime and GetTime()) or 0
    if now + 0.20 >= watchedEnd then
        Joypad.TriggerReadyFlash(button)
    end
end

function Joypad.RegisterReadyFlashWatch(button, start, duration, enable, actionSlot)
    if not button then
        return
    end

    start = tonumber(start or 0) or 0
    duration = tonumber(duration or 0) or 0
    actionSlot = tonumber(actionSlot or button.displayActionSlot or button.actionSlot or 0) or 0

    if (type(JoypadDB) == "table" and JoypadDB.showReadyFlash == false) or start <= 0 or duration <= (Joypad.READY_FLASH_MIN_DURATION or 1.5) or enable == 0 or actionSlot <= 0 then
        Joypad.ClearReadyFlashWatch(button)
        return
    end

    button.readyFlashStart = start
    button.readyFlashDuration = duration
    button.readyFlashEnd = start + duration
    button.readyFlashActionSlot = actionSlot
    Joypad.readyFlashWatches[button] = true
end

function Joypad.UpdateReadyFlashWatches(elapsed)
    if not Joypad.readyFlashWatches then
        return
    end

    if type(JoypadDB) == "table" and JoypadDB.showReadyFlash == false then
        for button in pairs(Joypad.readyFlashWatches) do
            Joypad.ClearReadyFlashWatch(button)
        end
        return
    end

    Joypad.readyFlashWatchElapsed = (Joypad.readyFlashWatchElapsed or 0) + (elapsed or 0)
    if Joypad.readyFlashWatchElapsed < (Joypad.READY_FLASH_WATCH_INTERVAL or 0.05) then
        return
    end
    Joypad.readyFlashWatchElapsed = 0

    local now = (GetTime and GetTime()) or 0
    for button in pairs(Joypad.readyFlashWatches) do
        local endTime = tonumber(button.readyFlashEnd or 0) or 0
        if endTime <= 0 then
            Joypad.ClearReadyFlashWatch(button)
        elseif now >= endTime then
            local watchedActionSlot = tonumber(button.readyFlashActionSlot or 0) or 0
            local currentActionSlot = tonumber(button.displayActionSlot or button.actionSlot or 0) or 0
            Joypad.ClearReadyFlashWatch(button)
            if watchedActionSlot > 0 and (currentActionSlot <= 0 or watchedActionSlot == currentActionSlot) then
                if not button.IsShown or button:IsShown() then
                    Joypad.TriggerReadyFlash(button)
                end
            end
        end
    end
end

function Joypad.UpdateActiveReadyFlashes(elapsed)
    if not Joypad.activeReadyFlashButtons then
        return
    end

    local duration = Joypad.GetReadyFlashDuration()
    local color = Joypad.GetReadyFlashColor()

    for button in pairs(Joypad.activeReadyFlashButtons) do
        if not button or not button.readyFlash then
            Joypad.activeReadyFlashButtons[button] = nil
        else
            button.readyFlashElapsed = (button.readyFlashElapsed or 0) + (elapsed or 0)
            local progress = button.readyFlashElapsed / duration
            if progress >= 1 then
                Joypad.ClearReadyFlash(button)
            else
                local pulse = 1.0
                if math and math.sin then
                    pulse = 0.72 + (0.28 * math.abs(math.sin(button.readyFlashElapsed * 22)))
                end
                JoypadSetAlphaIfChanged(button.readyFlash, (color.a or 0.75) * (1 - progress) * pulse)
                JoypadShowIfHidden(button.readyFlash)
            end
        end
    end
end


-- ---------------------------------------------------------------------------
-- Shifty suggestion highlight bridge.
-- Shifty exposes a read-only decision API; Joypad passively consumes it and
-- paints the physical controller buttons that match the current suggestion.
-- This is a visual-only overlay and never changes secure action attributes.
--
-- 0.44.74: diff/throttle the visual work.  The previous build cleared and
-- rebuilt every Shifty highlight on every decision callback, even if the same
-- spell/target was still recommended.  That was safe, but allocation-heavy in
-- combat.  This version resolves the desired slots, builds a compact signature,
-- skips unchanged updates, and only hides/repaints changed buttons.
-- ---------------------------------------------------------------------------
function Joypad:EnsureShiftySuggestionOverlay(button)
    if not button then return nil end
    if button.shiftySuggestionHolder then return button.shiftySuggestionHolder end

    local holderFrame = CreateFrame("Frame", nil, button)
    holderFrame:SetAllPoints(button)
    holderFrame:SetFrameStrata(button:GetFrameStrata())
    holderFrame:SetFrameLevel(button:GetFrameLevel() + 11)

    local fill = holderFrame:CreateTexture(nil, "OVERLAY")
    fill:SetAllPoints(holderFrame)
    fill:SetTexture("Interface\\Buttons\\WHITE8X8")
    fill:SetBlendMode("ADD")
    fill:SetVertexColor(0.10, 1.00, 0.35, 0.22)
    fill:Hide()
    holderFrame.fill = fill

    local top = holderFrame:CreateTexture(nil, "OVERLAY")
    top:SetTexture("Interface\\Buttons\\WHITE8X8")
    top:SetPoint("TOPLEFT", holderFrame, "TOPLEFT", -3, 3)
    top:SetPoint("TOPRIGHT", holderFrame, "TOPRIGHT", 3, 3)
    top:SetHeight(3)
    holderFrame.top = top

    local bottom = holderFrame:CreateTexture(nil, "OVERLAY")
    bottom:SetTexture("Interface\\Buttons\\WHITE8X8")
    bottom:SetPoint("BOTTOMLEFT", holderFrame, "BOTTOMLEFT", -3, -3)
    bottom:SetPoint("BOTTOMRIGHT", holderFrame, "BOTTOMRIGHT", 3, -3)
    bottom:SetHeight(3)
    holderFrame.bottom = bottom

    local left = holderFrame:CreateTexture(nil, "OVERLAY")
    left:SetTexture("Interface\\Buttons\\WHITE8X8")
    left:SetPoint("TOPLEFT", holderFrame, "TOPLEFT", -3, 3)
    left:SetPoint("BOTTOMLEFT", holderFrame, "BOTTOMLEFT", -3, -3)
    left:SetWidth(3)
    holderFrame.left = left

    local right = holderFrame:CreateTexture(nil, "OVERLAY")
    right:SetTexture("Interface\\Buttons\\WHITE8X8")
    right:SetPoint("TOPRIGHT", holderFrame, "TOPRIGHT", 3, 3)
    right:SetPoint("BOTTOMRIGHT", holderFrame, "BOTTOMRIGHT", 3, -3)
    right:SetWidth(3)
    holderFrame.right = right

    holderFrame:Hide()
    button.shiftySuggestionHolder = holderFrame
    return holderFrame
end

function Joypad:SetShiftySuggestionButtonHighlight(button, kind, label, reason)
    if not button then return false end
    local overlay = self:EnsureShiftySuggestionOverlay(button)
    if not overlay then return false end

    kind = tostring(kind or "main")
    local r, g, b = 0.10, 1.00, 0.35
    local fillAlpha = 0.20
    local edgeAlpha = 0.95
    if kind == "target" then
        r, g, b = 0.20, 0.65, 1.00
        fillAlpha = 0.18
    elseif kind == "side" or kind == "cue" then
        r, g, b = 1.00, 0.82, 0.20
        fillAlpha = 0.16
        edgeAlpha = 0.82
    elseif kind == "next" then
        r, g, b = 0.55, 0.75, 1.00
        fillAlpha = 0.14
        edgeAlpha = 0.70
    elseif kind == "raidsteer" then
        r, g, b = 0.10, 0.80, 1.00
        fillAlpha = 0.24
        edgeAlpha = 1.00
    elseif kind == "ack" then
        r, g, b = 0.20, 1.00, 0.60
        fillAlpha = 0.30
        edgeAlpha = 1.00
    end

    -- Skip repainting unchanged overlays.  Texture SetVertexColor calls are not
    -- massive alone, but avoiding them every decision helps keep combat steady.
    if overlay:IsShown()
        and overlay.kind == kind
        and overlay.label == label
        and overlay.reason == reason then
        if type(self._shiftyHighlightedButtons) ~= "table" then self._shiftyHighlightedButtons = {} end
        self._shiftyHighlightedButtons[button] = true
        return true
    end

    overlay.fill:SetVertexColor(r, g, b, fillAlpha)
    overlay.fill:Show()
    overlay.top:SetVertexColor(r, g, b, edgeAlpha)
    overlay.bottom:SetVertexColor(r, g, b, edgeAlpha)
    overlay.left:SetVertexColor(r, g, b, edgeAlpha)
    overlay.right:SetVertexColor(r, g, b, edgeAlpha)
    overlay.top:Show(); overlay.bottom:Show(); overlay.left:Show(); overlay.right:Show()
    overlay.kind = kind
    overlay.label = label
    overlay.reason = reason
    overlay:Show()

    if type(self._shiftyHighlightedButtons) ~= "table" then self._shiftyHighlightedButtons = {} end
    self._shiftyHighlightedButtons[button] = true
    return true
end

function Joypad:ClearShiftySuggestionHighlights(reason)
    if type(self._shiftyHighlightedButtons) == "table" then
        for button in pairs(self._shiftyHighlightedButtons) do
            if button and button.shiftySuggestionHolder then
                button.shiftySuggestionHolder:Hide()
            end
        end
        wipe(self._shiftyHighlightedButtons)
    end
    if type(self._shiftyHighlightDesiredButtons) == "table" then
        wipe(self._shiftyHighlightDesiredButtons)
    end
    if type(self._shiftyHighlightScratch) == "table" then
        for i = #self._shiftyHighlightScratch, 1, -1 do
            self._shiftyHighlightScratch[i] = nil
        end
    end
    if type(self._shiftyHighlightScratchPool) == "table" then
        for i = #self._shiftyHighlightScratchPool, 1, -1 do
            self._shiftyHighlightScratchPool[i] = nil
        end
    end
    self._shiftyHighlightSignature = nil
    self._shiftyHighlightExpires = nil
end

function Joypad:ResolveShiftyHighlightButtonInfo(entry)
    if type(entry) ~= "table" then return nil end
    if type(entry.buttonInfo) == "table" and entry.buttonInfo.found ~= false then return entry.buttonInfo end

    if entry.bindingCommand or entry.command then
        local ok, info = pcall(JoypadAPI.GetButtonForBindingCommand, entry.bindingCommand or entry.command)
        if ok and type(info) == "table" and info.found == true then return info end
    end

    if entry.targetUnit and type(JoypadAPI.GetButtonForTargetUnit) == "function" then
        local ok, info = pcall(JoypadAPI.GetButtonForTargetUnit, entry.targetUnit)
        if ok and type(info) == "table" and info.found == true then return info end
    end

    if entry.macroName or entry.macro then
        local ok, info = pcall(JoypadAPI.GetButtonForMacro, entry.macroName or entry.macro)
        if ok and type(info) == "table" and info.found == true then return info end
    end

    local spell = entry.bindSpell or entry.spell or entry.primarySpell or entry.mainSpell
    if spell and type(JoypadAPI.GetButtonForSpell) == "function" then
        local ok, info = pcall(JoypadAPI.GetButtonForSpell, spell)
        if ok and type(info) == "table" and info.found == true then return info end
    end

    return nil
end

function Joypad:ApplyShiftySuggestionHighlights(list, reason)
    EnsureDB()
    if JoypadDB.shiftySuggestionHighlights == false then
        self:ClearShiftySuggestionHighlights("disabled")
        return 0
    end

    if type(list) ~= "table" or #list <= 0 then
        self:ClearShiftySuggestionHighlights("empty")
        return 0
    end

    if type(self._shiftyHighlightDesiredButtons) ~= "table" then self._shiftyHighlightDesiredButtons = {} end
    if type(self._shiftyHighlightScratch) ~= "table" then self._shiftyHighlightScratch = {} end
    if type(self._shiftyHighlightScratchPool) ~= "table" then self._shiftyHighlightScratchPool = {} end
    if type(self._shiftyHighlightedButtons) ~= "table" then self._shiftyHighlightedButtons = {} end

    local desired = self._shiftyHighlightDesiredButtons
    local scratch = self._shiftyHighlightScratch
    local pool = self._shiftyHighlightScratchPool
    wipe(desired)
    for i = #scratch, 1, -1 do
        local row = scratch[i]
        scratch[i] = nil
        if type(row) == "table" then pool[#pool + 1] = row end
    end

    local applied = 0
    local sig = ""
    for index = 1, math.min(#list, 8) do
        local entry = list[index]
        local info = self:ResolveShiftyHighlightButtonInfo(entry)
        local joypadSlot = info and tonumber(info.joypadSlot or 0) or 0
        local button = joypadSlot > 0 and self.buttons and self.buttons[joypadSlot] or nil
        if button and not desired[button] then
            local kind = tostring(entry.kind or "main")
            local label = entry.label or entry.spell or entry.bindSpell or entry.targetUnit or ""
            local entryReason = entry.reason or ""
            local row = pool[#pool]
            if row then
                pool[#pool] = nil
            else
                row = {}
            end
            row.button = button
            row.slot = joypadSlot
            row.kind = kind
            row.label = label
            row.reason = entryReason
            desired[button] = true
            scratch[#scratch + 1] = row
            sig = sig .. tostring(joypadSlot) .. ":" .. kind .. ":" .. tostring(label) .. ":" .. tostring(entryReason) .. ";"
        end
    end

    if sig == self._shiftyHighlightSignature then
        if GetTime and sig ~= "" then self._shiftyHighlightExpires = GetTime() + 2.50 end
        return #scratch
    end
    self._shiftyHighlightSignature = sig

    for button in pairs(self._shiftyHighlightedButtons) do
        if button and not desired[button] and button.shiftySuggestionHolder then
            button.shiftySuggestionHolder:Hide()
        end
    end
    wipe(self._shiftyHighlightedButtons)

    for i = 1, #scratch do
        local row = scratch[i]
        if row and row.button and self:SetShiftySuggestionButtonHighlight(row.button, row.kind, row.label, row.reason) then
            applied = applied + 1
        end
        scratch[i] = nil
    end

    if applied > 0 and GetTime then
        self._shiftyHighlightExpires = GetTime() + 2.50
    elseif applied <= 0 then
        self._shiftyHighlightExpires = nil
    end
    return applied
end

function Joypad:HandleShiftyDecision(decision, reason)
    if type(ShiftyAPI) ~= "table" then return end

    -- At most one highlight rebuild per frame-ish interval.  If Shifty emits
    -- several decision notifications from the same update path, the newest one
    -- wins and the visual work runs once.
    local t = GetTime and GetTime() or 0
    if self._shiftyLastHighlightAt and (t - self._shiftyLastHighlightAt) < 0.05 then
        self._shiftyPendingDecision = decision
        self._shiftyPendingReason = reason or "decision"
        return
    end
    self._shiftyLastHighlightAt = t

    local list = nil
    if type(ShiftyAPI.GetJoypadSuggestionHighlights) == "function" then
        local ok, value = pcall(ShiftyAPI.GetJoypadSuggestionHighlights, decision)
        if ok then list = value end
    end
    if type(list) ~= "table" then return end

    local steeringEntry = nil
    if self.BuildRaidTargetSteeringHighlight then
        local okSteer, entry = pcall(function() return self:BuildRaidTargetSteeringHighlight(decision) end)
        if okSteer and type(entry) == "table" then
            steeringEntry = entry
        end
    end

    if steeringEntry then
        self:ApplyShiftySuggestionHighlights({ steeringEntry }, reason or "raid-steering")
    else
        self:ApplyShiftySuggestionHighlights(list, reason or "decision")
    end
end

function Joypad:SetupShiftySuggestionHighlights()
    EnsureDB()
    if type(ShiftyAPI) ~= "table" or type(ShiftyAPI.RegisterDecisionLogger) ~= "function" then
        return false
    end
    if self._shiftySuggestionCallback then
        return true
    end
    self._shiftySuggestionCallback = function(decision, reason)
        if Joypad and Joypad.HandleShiftyDecision then
            Joypad:HandleShiftyDecision(decision, reason)
        end
    end
    local ok, result = pcall(ShiftyAPI.RegisterDecisionLogger, self._shiftySuggestionCallback)
    if ok and result ~= false then
        if type(ShiftyAPI.GetLastDecisionSnapshot) == "function" then
            local okSnap, snap = pcall(ShiftyAPI.GetLastDecisionSnapshot)
            if okSnap and snap then self:HandleShiftyDecision(snap, "register") end
        end
        return true
    end
    self._shiftySuggestionCallback = nil
    return false
end

function Joypad:UpdateShiftySuggestionHighlightTimeout(elapsed)
    if self._shiftyPendingDecision then
        local decision = self._shiftyPendingDecision
        local reason = self._shiftyPendingReason or "decision"
        self._shiftyPendingDecision = nil
        self._shiftyPendingReason = nil
        self:HandleShiftyDecision(decision, reason)
    end
    if not self._shiftyHighlightExpires or not GetTime then return end
    if GetTime() >= self._shiftyHighlightExpires then
        self:ClearShiftySuggestionHighlights("timeout")
    end
end

function Joypad:SetShiftySuggestionHighlightsEnabled(enabled, silent)
    EnsureDB()
    JoypadDB.shiftySuggestionHighlights = enabled and true or false
    if JoypadDB.shiftySuggestionHighlights == false then
        self:ClearShiftySuggestionHighlights("disabled")
    else
        self:SetupShiftySuggestionHighlights()
        if type(ShiftyAPI) == "table" and type(ShiftyAPI.GetLastDecisionSnapshot) == "function" then
            local ok, snap = pcall(ShiftyAPI.GetLastDecisionSnapshot)
            if ok and snap then self:HandleShiftyDecision(snap, "enabled") end
        end
    end
    if not silent then
        Print("Shifty suggestion highlights " .. (JoypadDB.shiftySuggestionHighlights ~= false and "enabled" or "disabled") .. ".")
    end
end

function Joypad.IsActionActive(actionSlot)
    actionSlot = tonumber(actionSlot or 0) or 0
    if actionSlot <= 0 then
        return false
    end

    if IsCurrentAction and IsCurrentAction(actionSlot) then
        return true
    end

    if IsAutoRepeatAction and IsAutoRepeatAction(actionSlot) then
        return true
    end

    return false
end

function Joypad.GetActionStateColor(actionSlot, hasAction)
    local colors = Joypad.actionStateColors or {}
    local usableColor = colors.usable or { r = 1, g = 1, b = 1, a = 1 }

    if not actionSlot or not hasAction then
        return usableColor.r or 1, usableColor.g or 1, usableColor.b or 1, usableColor.a or 1, "empty"
    end

    local isUsable, notEnoughMana = true, false
    if IsUsableAction then
        isUsable, notEnoughMana = IsUsableAction(actionSlot)
    end

    local inRange = nil
    if IsActionInRange then
        inRange = IsActionInRange(actionSlot)
    end

    local color = usableColor
    local state = "usable"
    if inRange == 0 then
        color = colors.outOfRange or color
        state = "outOfRange"
    elseif notEnoughMana then
        color = colors.noPower or color
        state = "noPower"
    elseif not isUsable then
        color = colors.notUsable or color
        state = "notUsable"
    end

    return color.r or 1, color.g or 1, color.b or 1, color.a or 1, state
end


function Joypad.EnsureActiveBorder(button)
    if not button or button.activeBorderTextures then
        return
    end

    button.activeBorderHolder = CreateFrame("Frame", nil, button)
    button.activeBorderHolder:SetAllPoints(button)
    button.activeBorderHolder:SetFrameStrata(button:GetFrameStrata())
    button.activeBorderHolder:SetFrameLevel(button:GetFrameLevel() + 11)

    button.activeBorderTextures = {}
    for index = 1, 4 do
        local texture = button.activeBorderHolder:CreateTexture(nil, "OVERLAY")
        texture:SetTexture("Interface\\Buttons\\WHITE8X8")
        texture:Hide()
        if texture.SetDrawLayer then
            texture:SetDrawLayer("OVERLAY", 7)
        end
        button.activeBorderTextures[index] = texture
    end
end

function Joypad.SetButtonActiveBorderShown(button, shown)
    if not button then
        return
    end

    if type(JoypadDB) == "table" and JoypadDB.showActiveBorder == false then
        shown = false
    end

    if not shown then
        if button.activeBorderTextures then
            for _, texture in ipairs(button.activeBorderTextures) do
                if texture then
                    texture:Hide()
                end
            end
        end
        return
    end

    Joypad.EnsureActiveBorder(button)

    local color = Joypad.activeBorderColor or { r = 1, g = 0.82, b = 0, a = 1 }
    local textures = button.activeBorderTextures
    if not textures then
        return
    end

    if textures[1] then
        textures[1]:ClearAllPoints()
        textures[1]:SetPoint("TOPLEFT", button, "TOPLEFT", -4, 4)
        textures[1]:SetPoint("TOPRIGHT", button, "TOPRIGHT", 4, 4)
        textures[1]:SetHeight(3)
    end
    if textures[2] then
        textures[2]:ClearAllPoints()
        textures[2]:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -4, -4)
        textures[2]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -4)
        textures[2]:SetHeight(3)
    end
    if textures[3] then
        textures[3]:ClearAllPoints()
        textures[3]:SetPoint("TOPLEFT", button, "TOPLEFT", -4, 4)
        textures[3]:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -4, -4)
        textures[3]:SetWidth(3)
    end
    if textures[4] then
        textures[4]:ClearAllPoints()
        textures[4]:SetPoint("TOPRIGHT", button, "TOPRIGHT", 4, 4)
        textures[4]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -4)
        textures[4]:SetWidth(3)
    end

    for _, texture in ipairs(textures) do
        if texture then
            texture:SetVertexColor(color.r or 1, color.g or 0.82, color.b or 0, color.a or 1)
            texture:Show()
        end
    end
end

function Joypad.EnsureEquippedBorder(button)
    if not button or button.equippedBorderTextures then
        return
    end

    button.equippedBorderTextures = {}
    for index = 1, 4 do
        local texture = button:CreateTexture(nil, "OVERLAY")
        texture:SetTexture("Interface\\Buttons\\WHITE8X8")
        texture:Hide()
        if texture.SetDrawLayer then
            texture:SetDrawLayer("OVERLAY", 5)
        end
        button.equippedBorderTextures[index] = texture
    end
end

function Joypad.SetEquippedBorderShown(button, shown)
    if not button then
        return
    end

    if shown and JoypadIsDiamondViewportEnabled and JoypadIsDiamondViewportEnabled(button.joypadSlot) then
        shown = false
    end

    if not shown then
        if button.equippedBorderTextures then
            for _, texture in ipairs(button.equippedBorderTextures) do
                if texture then
                    texture:Hide()
                end
            end
        end
        return
    end

    Joypad.EnsureEquippedBorder(button)

    local color = (Joypad.actionStateColors and Joypad.actionStateColors.equippedBorder) or { r = 0.4, g = 1, b = 0.4, a = 1 }
    local textures = button.equippedBorderTextures
    if not textures then
        return
    end

    if textures[1] then
        textures[1]:ClearAllPoints()
        textures[1]:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
        textures[1]:SetPoint("TOPRIGHT", button, "TOPRIGHT", 3, 3)
        textures[1]:SetHeight(2)
    end
    if textures[2] then
        textures[2]:ClearAllPoints()
        textures[2]:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -3, -3)
        textures[2]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
        textures[2]:SetHeight(2)
    end
    if textures[3] then
        textures[3]:ClearAllPoints()
        textures[3]:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
        textures[3]:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -3, -3)
        textures[3]:SetWidth(2)
    end
    if textures[4] then
        textures[4]:ClearAllPoints()
        textures[4]:SetPoint("TOPRIGHT", button, "TOPRIGHT", 3, 3)
        textures[4]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
        textures[4]:SetWidth(2)
    end

    for _, texture in ipairs(textures) do
        if texture then
            texture:SetVertexColor(color.r or 0.4, color.g or 1, color.b or 0.4, color.a or 1)
            texture:Show()
        end
    end
end

function Joypad.ApplyActionStateVisuals(button, actionSlot, texture, hasAction)
    if not button then
        return
    end

    if texture and hasAction and button.icon then
        local r, g, b, a, state = Joypad.GetActionStateColor(actionSlot, hasAction)
        JoypadSetVertexColorIfChanged(button.icon, r, g, b, a)
        button.joypadActionState = state
        button.joypadActionStateR = r
        button.joypadActionStateG = g
        button.joypadActionStateB = b
        button.joypadActionStateA = a
    elseif button.icon then
        JoypadSetVertexColorIfChanged(button.icon, 1.0, 1.0, 1.0, 1.0)
        button.joypadActionState = "empty"
    end

    local actionInfo = JoypadGetCachedActionSlotInfo and JoypadGetCachedActionSlotInfo(actionSlot) or nil
    if actionSlot and hasAction and ((actionInfo and actionInfo.equipped) or (not actionInfo and IsEquippedAction and IsEquippedAction(actionSlot))) then
        Joypad.SetEquippedBorderShown(button, true)
    else
        Joypad.SetEquippedBorderShown(button, false)
    end
end

local function SetCooldown(cooldown, start, duration, enable, actionSlot)
    if not cooldown then
        return
    end

    start = start or 0
    duration = duration or 0
    actionSlot = tonumber(actionSlot or cooldown.ownerActionSlot or 0) or 0
    cooldown.ownerActionSlot = actionSlot

    if duration > 0 and start > 0 then
        if CooldownFrame_SetTimer then
            CooldownFrame_SetTimer(cooldown, start, duration, enable or 1)
        elseif cooldown.SetCooldown then
            cooldown:SetCooldown(start, duration)
        end
        cooldown:Show()
        Joypad.RegisterCooldownText(cooldown.ownerButton, start, duration, enable)
        Joypad.RegisterReadyFlashWatch(cooldown.ownerButton, start, duration, enable, actionSlot)
    else
        if CooldownFrame_SetTimer then
            CooldownFrame_SetTimer(cooldown, 0, 0, 0)
        elseif cooldown.SetCooldown then
            cooldown:SetCooldown(0, 0)
        end
        Joypad.HideCooldownText(cooldown.ownerButton)
        Joypad.MaybeFinishReadyFlashWatch(cooldown.ownerButton, actionSlot)
    end
end

local function PositionEditOverlay(button)
    if not button or not button.editOverlay then
        return
    end

    button.editOverlay:ClearAllPoints()
    button.editOverlay:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.editOverlay:SetWidth(BUTTON_SIZE)
    button.editOverlay:SetHeight(BUTTON_SIZE)
    if button.editOverlay.SetScale then
        button.editOverlay:SetScale(GetSlotScale(button.joypadSlot) / 100)
    end
end

local function GetGroupBounds(enabledOnly)
    local minX, maxX, minY, maxY
    local count = 0

    for i = 1, 24 do
        if not enabledOnly or IsSlotEnabled(i) then
            local x, y = GetSlotPosition(i)
            local scale = GetSlotScale(i) / 100
            local size = BUTTON_SIZE * scale
            local left = x - (size / 2)
            local right = x + (size / 2)
            local bottom = y - (size / 2)
            local top = y + (size / 2)

            if not minX or left < minX then minX = left end
            if not maxX or right > maxX then maxX = right end
            if not minY or bottom < minY then minY = bottom end
            if not maxY or top > maxY then maxY = top end
            count = count + 1
        end
    end

    if count == 0 then
        return nil
    end

    return minX, maxX, minY, maxY, count
end

local function GetGroupCenter()
    local minX, maxX, minY, maxY = GetGroupBounds(true)
    if not minX then
        minX, maxX, minY, maxY = GetGroupBounds(false)
    end

    if not minX then
        return 0, 0
    end

    return Round((minX + maxX) / 2), Round((minY + maxY) / 2)
end

local function GetGroupScale()
    local total = 0
    local count = 0

    for i = 1, 24 do
        if IsSlotEnabled(i) then
            total = total + GetSlotScale(i)
            count = count + 1
        end
    end

    if count == 0 then
        for i = 1, 24 do
            total = total + GetSlotScale(i)
            count = count + 1
        end
    end

    if count == 0 then
        return GetDefaultSlotScale()
    end

    return Clamp(Round(total / count), 25, 300)
end

local function LayoutGroupOverlay()
    local overlay = Joypad.groupOverlay
    if not overlay or not UIParent then
        return
    end

    local minX, maxX, minY, maxY = GetGroupBounds(true)
    if not minX then
        overlay:Hide()
        return
    end

    local padding = 8
    local width = Round((maxX - minX) + (padding * 2))
    local height = Round((maxY - minY) + (padding * 2))
    local centerX = Round((minX + maxX) / 2)
    local centerY = Round((minY + maxY) / 2)

    overlay:ClearAllPoints()
    overlay:SetPoint("CENTER", UIParent, "CENTER", centerX, centerY)
    overlay:SetWidth(width)
    overlay:SetHeight(height)

    if overlay.label then
        overlay.label:SetText("Joypad group  X " .. tostring(centerX) .. " / Y " .. tostring(centerY))
    end
end

function JoypadLayoutGridOverlay()
    local grid = Joypad.gridOverlay
    if not grid or not UIParent then
        return
    end

    local width = UIParent:GetWidth() or 1024
    local height = UIParent:GetHeight() or 768
    local halfWidth = width / 2
    local halfHeight = height / 2
    local step = GRID_STEP or 50

    grid.lines = grid.lines or {}
    local lineIndex = 1

    local function GetLine()
        local line = grid.lines[lineIndex]
        if not line then
            line = grid:CreateTexture(nil, "BACKGROUND")
            grid.lines[lineIndex] = line
        end
        lineIndex = lineIndex + 1
        line:ClearAllPoints()
        line:Show()
        return line
    end

    local startX = 0 - (math.floor(halfWidth / step) * step)
    local endX = math.floor(halfWidth / step) * step
    local x = startX
    while x <= endX do
        local line = GetLine()
        line:SetWidth(x == 0 and 2 or 1)
        line:SetHeight(height)
        if x == 0 then
            line:SetTexture(1, 0.82, 0, 0.50)
        else
            line:SetTexture(0.35, 0.65, 1, 0.18)
        end
        line:SetPoint("CENTER", UIParent, "CENTER", x, 0)
        x = x + step
    end

    local startY = 0 - (math.floor(halfHeight / step) * step)
    local endY = math.floor(halfHeight / step) * step
    local y = startY
    while y <= endY do
        local line = GetLine()
        line:SetWidth(width)
        line:SetHeight(y == 0 and 2 or 1)
        if y == 0 then
            line:SetTexture(1, 0.82, 0, 0.50)
        else
            line:SetTexture(0.35, 0.65, 1, 0.18)
        end
        line:SetPoint("CENTER", UIParent, "CENTER", 0, y)
        y = y + step
    end

    while grid.lines[lineIndex] do
        grid.lines[lineIndex]:Hide()
        lineIndex = lineIndex + 1
    end

    if grid.label then
        grid.label:SetPoint("CENTER", UIParent, "CENTER", 0, 18)
    end
end

function Joypad:CreateGridOverlay()
    if self.gridOverlay or not UIParent then
        return
    end

    local grid = CreateFrame("Frame", "JoypadGridOverlay", UIParent)
    grid:SetAllPoints(UIParent)
    grid:SetFrameStrata("LOW")
    grid:SetFrameLevel(1)
    grid:EnableMouse(false)
    grid:Hide()

    grid.label = grid:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    grid.label:SetText("Joypad unlocked - drag buttons snap near grid lines; wheel scales; right-click for coordinates")
    grid.label:SetTextColor(1, 0.82, 0, 1)
    grid.label:SetShadowColor(0, 0, 0, 1)
    grid.label:SetShadowOffset(1, -1)

    self.gridOverlay = grid
end

function Joypad:ShowGridOverlay()
    self:CreateGridOverlay()
    if not self.gridOverlay then
        return
    end

    JoypadLayoutGridOverlay()
    self.gridOverlay:Show()
end

function Joypad:HideGridOverlay()
    if self.gridOverlay then
        self.gridOverlay:Hide()
    end
end


function Joypad:CreateGroupOverlay()
    if self.groupOverlay or not UIParent then
        return
    end

    local overlay = CreateFrame("Button", "JoypadGroupOverlay", UIParent)
    overlay:SetFrameStrata("HIGH")
    overlay:SetFrameLevel(6)
    overlay:EnableMouse(true)
    overlay:RegisterForClicks("RightButtonUp")
    overlay:RegisterForDrag("LeftButton")
    overlay:Hide()

    overlay.fill = overlay:CreateTexture(nil, "BACKGROUND")
    overlay.fill:SetAllPoints(overlay)
    overlay.fill:SetTexture(0, 0, 0, 0.08)

    overlay.edgeTop = overlay:CreateTexture(nil, "OVERLAY")
    overlay.edgeTop:SetTexture(1, 0.82, 0, 0.95)
    overlay.edgeTop:SetHeight(2)
    overlay.edgeTop:SetPoint("TOPLEFT", overlay, "TOPLEFT", 0, 0)
    overlay.edgeTop:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", 0, 0)

    overlay.edgeBottom = overlay:CreateTexture(nil, "OVERLAY")
    overlay.edgeBottom:SetTexture(1, 0.82, 0, 0.95)
    overlay.edgeBottom:SetHeight(2)
    overlay.edgeBottom:SetPoint("BOTTOMLEFT", overlay, "BOTTOMLEFT", 0, 0)
    overlay.edgeBottom:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", 0, 0)

    overlay.edgeLeft = overlay:CreateTexture(nil, "OVERLAY")
    overlay.edgeLeft:SetTexture(1, 0.82, 0, 0.95)
    overlay.edgeLeft:SetWidth(2)
    overlay.edgeLeft:SetPoint("TOPLEFT", overlay, "TOPLEFT", 0, 0)
    overlay.edgeLeft:SetPoint("BOTTOMLEFT", overlay, "BOTTOMLEFT", 0, 0)

    overlay.edgeRight = overlay:CreateTexture(nil, "OVERLAY")
    overlay.edgeRight:SetTexture(1, 0.82, 0, 0.95)
    overlay.edgeRight:SetWidth(2)
    overlay.edgeRight:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", 0, 0)
    overlay.edgeRight:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", 0, 0)

    overlay.label = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    overlay.label:SetPoint("BOTTOM", overlay, "TOP", 0, 3)
    overlay.label:SetTextColor(1, 0.82, 0, 1)
    overlay.label:SetShadowColor(0, 0, 0, 1)
    overlay.label:SetShadowOffset(1, -1)
    overlay.label:SetText("Joypad group")

    overlay:SetScript("OnEnter", function(selfOverlay)
        if GameTooltip then
            GameTooltip:SetOwner(selfOverlay, "ANCHOR_RIGHT")
            GameTooltip:SetText("Joypad group")
            GameTooltip:AddLine("Unlocked positioning mode", 1, 0.82, 0)
            GameTooltip:AddLine("Left-drag: move all 24 slots together", 1, 1, 1)
            GameTooltip:AddLine("Right-click: set group X/Y/Scale from screen centre", 1, 1, 1)
            local x, y = GetGroupCenter()
            GameTooltip:AddLine("Group centre X " .. tostring(x) .. " / Y " .. tostring(y) .. " / Scale " .. tostring(GetGroupScale()) .. "%", 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end
    end)
    overlay:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    overlay:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            Joypad:OpenGroupPopup()
        end
    end)
    overlay:SetScript("OnDragStart", function(selfOverlay)
        Joypad:StartDragGroup(selfOverlay)
    end)
    overlay:SetScript("OnDragStop", function(selfOverlay)
        Joypad:StopDragGroup(selfOverlay)
    end)

    self.groupOverlay = overlay
end

function Joypad:ShowGroupOverlay()
    self:CreateGroupOverlay()
    if not self.groupOverlay then
        return
    end

    LayoutGroupOverlay()
    self.groupOverlay:Show()
end

function Joypad:HideGroupOverlay()
    if self.groupOverlay then
        self.groupOverlay:Hide()
        self.groupOverlay:SetScript("OnUpdate", nil)
    end
end

function Joypad:CreateLockButton()
    if self.lockButton or not UIParent then
        return
    end

    local button = CreateFrame("Button", "JoypadLockButton", UIParent, "UIPanelButtonTemplate")
    button:SetWidth(118)
    button:SetHeight(24)
    button:SetPoint("TOP", UIParent, "TOP", 0, -105)
    button:SetFrameStrata("DIALOG")
    button:SetFrameLevel(60)
    button:SetText("Lock Joypad")
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp")
    button:SetScript("OnClick", function()
        Joypad:SetUnlocked(false, false)
    end)
    button:SetScript("OnEnter", function(selfButton)
        if GameTooltip then
            GameTooltip:SetOwner(selfButton, "ANCHOR_BOTTOM")
            GameTooltip:SetText("Lock Joypad")
            GameTooltip:AddLine("Click to leave unlocked positioning mode.", 1, 1, 1)
            GameTooltip:AddLine("You can also use /joypad lock or the settings panel.", 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    button:Hide()

    self.lockButton = button
end

function Joypad:ShowLockButton()
    self:CreateLockButton()
    if self.lockButton then
        self.lockButton:Show()
    end
end

function Joypad:HideLockButton()
    if self.lockButton then
        self.lockButton:Hide()
    end
end

function Joypad:CreateResetButton()
    if self.resetButton or not UIParent then
        return
    end

    self:CreateLockButton()

    local button = CreateFrame("Button", "JoypadResetLayoutButton", UIParent, "UIPanelButtonTemplate")
    button:SetWidth(118)
    button:SetHeight(24)
    if self.lockButton then
        button:SetPoint("LEFT", self.lockButton, "RIGHT", 8, 0)
    else
        button:SetPoint("TOP", UIParent, "TOP", 126, -105)
    end
    button:SetFrameStrata("DIALOG")
    button:SetFrameLevel(60)
    button:SetText("Reset Layout")
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp")
    button:SetScript("OnClick", function()
        Joypad:ResetAllLayout(false)
    end)
    button:SetScript("OnEnter", function(selfButton)
        if GameTooltip then
            GameTooltip:SetOwner(selfButton, "ANCHOR_BOTTOM")
            GameTooltip:SetText("Reset Layout")
            GameTooltip:AddLine("Reset all Joypad slot positions and scales to default.", 1, 1, 1)
            GameTooltip:AddLine("This resets X/Y, button Scale %, Alt % modifier, and Alt colours. Slot on/off settings are left alone.", 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    button:Hide()

    self.resetButton = button
end

function Joypad:ShowResetButton()
    self:CreateResetButton()
    if self.resetButton then
        self.resetButton:Show()
    end
end

function Joypad:HideResetButton()
    if self.resetButton then
        self.resetButton:Hide()
    end
end

function JoypadEnsureThemeBorder(button)
    if not button or button.themeBorderTextures then
        return
    end

    button.themeBorderTextures = {}
    for index = 1, 12 do
        local texture = button:CreateTexture(nil, "OVERLAY")
        texture:SetTexture("Interface\\Buttons\\WHITE8X8")
        texture:Hide()
        button.themeBorderTextures[index] = texture
    end
end

function JoypadPlaceThemeBorderPiece(texture, button, side, offset, thickness)
    if not texture or not button then
        return
    end

    texture:ClearAllPoints()

    if side == "top" then
        texture:SetPoint("TOPLEFT", button, "TOPLEFT", -offset, offset)
        texture:SetPoint("TOPRIGHT", button, "TOPRIGHT", offset, offset)
        texture:SetHeight(thickness)
    elseif side == "bottom" then
        texture:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -offset, -offset)
        texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", offset, -offset)
        texture:SetHeight(thickness)
    elseif side == "left" then
        texture:SetPoint("TOPLEFT", button, "TOPLEFT", -offset, offset)
        texture:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -offset, -offset)
        texture:SetWidth(thickness)
    elseif side == "right" then
        texture:SetPoint("TOPRIGHT", button, "TOPRIGHT", offset, offset)
        texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", offset, -offset)
        texture:SetWidth(thickness)
    end
end

function JoypadApplyThemeRing(button, startIndex, offset, thickness, r, g, b, a)
    if not button or not button.themeBorderTextures then
        return
    end

    local textures = button.themeBorderTextures
    local sides = { "top", "bottom", "left", "right" }

    for sideIndex = 1, 4 do
        local texture = textures[startIndex + sideIndex - 1]
        if texture then
            texture:SetTexture("Interface\\Buttons\\WHITE8X8")
            texture:SetVertexColor(r, g, b, a)
            JoypadPlaceThemeBorderPiece(texture, button, sides[sideIndex], offset, thickness)
            texture:Show()
        end
    end
end

function JoypadHideThemeBorder(button)
    if not button or not button.themeBorderTextures then
        return
    end

    for _, texture in ipairs(button.themeBorderTextures) do
        if texture then
            texture:Hide()
        end
    end
end

function JoypadEnsureDiamondThemeBorder(button)
    if not button then
        return
    end

    if not button.diamondThemeBorders then
        button.diamondThemeBorders = {}
        for index = 1, 3 do
            local texture = button:CreateTexture(nil, "OVERLAY")
            texture:SetTexture(JOYPAD_DIAMOND_BORDER_TEXTURE)
            texture:Hide()
            button.diamondThemeBorders[index] = texture
        end
    end
end

function JoypadShowDiamondThemeBorder(button)
    if not button then
        return
    end

    JoypadEnsureDiamondThemeBorder(button)

    local borders = button.diamondThemeBorders
    if not borders then
        return
    end

    borders[1]:ClearAllPoints()
    borders[1]:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
    borders[1]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
    borders[1]:SetVertexColor(0.0, 0.0, 0.0, 1.0)
    borders[1]:Show()

    borders[2]:ClearAllPoints()
    borders[2]:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 1)
    borders[2]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
    borders[2]:SetVertexColor(0.0745098, 0.0745098, 0.0705882, 1.0)
    borders[2]:Show()

    borders[3]:ClearAllPoints()
    borders[3]:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    borders[3]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
    borders[3]:SetVertexColor(0.0, 0.0, 0.0, 1.0)
    borders[3]:Show()
end

function JoypadHideDiamondThemeBorder(button)
    if not button or not button.diamondThemeBorders then
        return
    end

    for _, texture in ipairs(button.diamondThemeBorders) do
        if texture then
            texture:Hide()
        end
    end
end


JOYPAD_CLASSIC_BUTTON_BACKGROUND = "Interface\\Buttons\\WHITE8X8"
JOYPAD_CLASSIC_BUTTON_BORDER = "Interface\\Buttons\\UI-Quickslot2"
JOYPAD_CLASSIC_BUTTON_PRESSED = "Interface\\Buttons\\UI-Quickslot-Depress"
JOYPAD_CLASSIC_BUTTON_HIGHLIGHT = "Interface\\Buttons\\ButtonHilight-Square"
JOYPAD_CLASSIC_BUTTON_CHECKED = "Interface\\Buttons\\CheckButtonHilight"
JOYPAD_CLASSIC_BUTTON_INVISIBLE = "Interface\\Buttons\\WHITE8X8"

function JoypadSetIconRegionFull(button)
    if not button or not button.icon then
        return
    end

    button.icon:ClearAllPoints()
    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
end

function JoypadSetIconRegionClassic(button)
    if not button or not button.icon then
        return
    end

    button.icon:ClearAllPoints()
    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 6, -6)
    button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -6, 6)
end

function JoypadEnsureClassicTheme(button)
    if not button then
        return
    end

    if not button.classicBackground then
        local background = button:CreateTexture(nil, "BACKGROUND")
        background:SetTexture(JOYPAD_CLASSIC_BUTTON_BACKGROUND)
        background:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4)
        background:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 4)
        background:SetVertexColor(0.022, 0.022, 0.028, 1.0)
        background:Hide()
        button.classicBackground = background
    end

    if not button.classicShade then
        local shade = button:CreateTexture(nil, "BORDER")
        shade:SetTexture(JOYPAD_CLASSIC_BUTTON_BACKGROUND)
        shade:SetPoint("TOPLEFT", button, "TOPLEFT", 5, -5)
        shade:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 5)
        shade:SetVertexColor(0.07, 0.07, 0.09, 0.70)
        shade:Hide()
        button.classicShade = shade
    end

    if not button.classicTopLight then
        local topLight = button:CreateTexture(nil, "ARTWORK")
        topLight:SetTexture(JOYPAD_CLASSIC_BUTTON_BACKGROUND)
        topLight:SetPoint("TOPLEFT", button, "TOPLEFT", 5, -5)
        topLight:SetPoint("TOPRIGHT", button, "TOPRIGHT", -5, -5)
        topLight:SetHeight(7)
        topLight:SetVertexColor(0.30, 0.30, 0.34, 0.16)
        topLight:Hide()
        button.classicTopLight = topLight
    end

    if not button.classicBottomShadow then
        local bottomShadow = button:CreateTexture(nil, "ARTWORK")
        bottomShadow:SetTexture(JOYPAD_CLASSIC_BUTTON_BACKGROUND)
        bottomShadow:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 5, 5)
        bottomShadow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 5)
        bottomShadow:SetHeight(10)
        bottomShadow:SetVertexColor(0.0, 0.0, 0.0, 0.32)
        bottomShadow:Hide()
        button.classicBottomShadow = bottomShadow
    end
end

function JoypadHideClassicTheme(button)
    if not button then
        return
    end

    if button.classicBackground then
        button.classicBackground:Hide()
    end
    if button.classicShade then
        button.classicShade:Hide()
    end
    if button.classicTopLight then
        button.classicTopLight:Hide()
    end
    if button.classicBottomShadow then
        button.classicBottomShadow:Hide()
    end

    if button.SetNormalTexture then
        button:SetNormalTexture(JOYPAD_CLASSIC_BUTTON_INVISIBLE)
        local normal = button:GetNormalTexture()
        if normal then
            normal:ClearAllPoints()
            normal:SetAllPoints(button)
            normal:SetVertexColor(1, 1, 1, 0)
        end
    end
    if button.SetHighlightTexture then
        button:SetHighlightTexture(JOYPAD_CLASSIC_BUTTON_INVISIBLE, "ADD")
        local highlight = button:GetHighlightTexture()
        if highlight then
            highlight:SetAllPoints(button)
            highlight:SetVertexColor(1, 1, 1, 0)
        end
    end
    if button.SetPushedTexture then
        button:SetPushedTexture(JOYPAD_CLASSIC_BUTTON_INVISIBLE)
        local pushed = button:GetPushedTexture()
        if pushed then
            pushed:SetAllPoints(button)
            pushed:SetVertexColor(1, 1, 1, 0)
        end
    end
    if button.SetCheckedTexture then
        button:SetCheckedTexture(JOYPAD_CLASSIC_BUTTON_INVISIBLE)
        local checked = button:GetCheckedTexture()
        if checked then
            checked:SetAllPoints(button)
            checked:SetVertexColor(1, 1, 1, 0)
        end
    end

    JoypadSetIconRegionFull(button)
end

function JoypadShowClassicTheme(button)
    if not button then
        return
    end

    JoypadEnsureClassicTheme(button)

    if button.classicBackground then
        button.classicBackground:Show()
    end
    if button.classicShade then
        button.classicShade:Show()
    end
    if button.classicTopLight then
        button.classicTopLight:Show()
    end
    if button.classicBottomShadow then
        button.classicBottomShadow:Show()
    end

    if button.SetNormalTexture then
        button:SetNormalTexture(JOYPAD_CLASSIC_BUTTON_BORDER)
        local normal = button:GetNormalTexture()
        if normal then
            normal:ClearAllPoints()
            normal:SetPoint("CENTER", button, "CENTER", 0, 0)
            normal:SetWidth(BUTTON_SIZE + 22)
            normal:SetHeight(BUTTON_SIZE + 22)
            normal:SetVertexColor(1, 1, 1, 1)
        end
    end
    if button.SetHighlightTexture then
        button:SetHighlightTexture(JOYPAD_CLASSIC_BUTTON_HIGHLIGHT, "ADD")
        local highlight = button:GetHighlightTexture()
        if highlight then
            highlight:ClearAllPoints()
            highlight:SetPoint("CENTER", button, "CENTER", 0, 0)
            highlight:SetWidth(BUTTON_SIZE + 8)
            highlight:SetHeight(BUTTON_SIZE + 8)
            highlight:SetVertexColor(1, 1, 1, 0.35)
        end
    end
    if button.SetPushedTexture then
        button:SetPushedTexture(JOYPAD_CLASSIC_BUTTON_PRESSED)
        local pushed = button:GetPushedTexture()
        if pushed then
            pushed:ClearAllPoints()
            pushed:SetPoint("CENTER", button, "CENTER", 0, 0)
            pushed:SetWidth(BUTTON_SIZE + 4)
            pushed:SetHeight(BUTTON_SIZE + 4)
            pushed:SetVertexColor(1, 1, 1, 1)
        end
    end
    if button.SetCheckedTexture then
        button:SetCheckedTexture(JOYPAD_CLASSIC_BUTTON_CHECKED)
        local checked = button:GetCheckedTexture()
        if checked then
            checked:ClearAllPoints()
            checked:SetPoint("CENTER", button, "CENTER", 0, 0)
            checked:SetWidth(BUTTON_SIZE + 12)
            checked:SetHeight(BUTTON_SIZE + 12)
            if checked.SetBlendMode then
                checked:SetBlendMode("ADD")
            end
            checked:SetVertexColor(1, 1, 1, 0.70)
        end
    end

    JoypadSetIconRegionClassic(button)
end

function JoypadEnsureDiamondViewport(button)
    if not button or button.diamondBorder then
        return
    end

    button.diamondFill = button:CreateTexture(nil, "BACKGROUND")
    button.diamondFill:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
    button.diamondFill:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    button.diamondFill:SetTexture(JOYPAD_DIAMOND_FILL_TEXTURE)
    button.diamondFill:Hide()

    button.diamondIconStrips = {}
    for stripIndex = 1, 18 do
        local strip = button:CreateTexture(nil, "ARTWORK")
        strip:SetTexture(nil)
        strip:Hide()
        button.diamondIconStrips[stripIndex] = strip
    end

    -- Kept for old saved layouts, but no longer shown. A square corner mask was
    -- the source of the visible non-rotated black square.
    button.diamondMask = button:CreateTexture(nil, "OVERLAY")
    button.diamondMask:SetAllPoints(button)
    button.diamondMask:SetTexture(nil)
    button.diamondMask:Hide()

    button.diamondBorder = button:CreateTexture(nil, "OVERLAY")
    button.diamondBorder:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
    button.diamondBorder:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
    button.diamondBorder:SetTexture(JOYPAD_DIAMOND_BORDER_TEXTURE)
    button.diamondBorder:Hide()

    JoypadEnsureDiamondThemeBorder(button)
end

function JoypadHideDiamondIconStrips(button)
    if not button or not button.diamondIconStrips then
        return
    end

    for _, strip in ipairs(button.diamondIconStrips) do
        if strip then
            strip:Hide()
        end
    end
end

function JoypadUpdateDiamondIconStrips(button)
    if not button or not button.icon or not button.diamondIconStrips then
        return
    end

    local texture = button.icon:GetTexture()
    if not texture then
        JoypadHideDiamondIconStrips(button)
        return
    end

    local r, g, b, a = 1, 1, 1, 1
    if button.icon.GetVertexColor then
        r, g, b, a = button.icon:GetVertexColor()
        r = r or 1
        g = g or 1
        b = b or 1
        a = a or 1
    end

    local strips = button.diamondIconStrips
    local stripCount = table.getn(strips)
    local buttonSize = BUTTON_SIZE
    local sourceLeft, sourceRight = 0.08, 0.92
    local sourceTop, sourceBottom = 0.08, 0.92
    local sourceHeight = sourceBottom - sourceTop

    for stripIndex, strip in ipairs(strips) do
        local topFrac = (stripIndex - 1) / stripCount
        local bottomFrac = stripIndex / stripCount
        local midFrac = (topFrac + bottomFrac) / 2
        local yNorm = (midFrac * 2) - 1
        local widthFrac = 1 - math.abs(yNorm)

        local stripWidth = math.max(2, buttonSize * widthFrac)
        local stripHeight = math.ceil(buttonSize / stripCount) + 1
        local yOffset = (buttonSize / 2) - (midFrac * buttonSize)

        strip:ClearAllPoints()
        strip:SetPoint("CENTER", button, "CENTER", 0, yOffset)
        strip:SetWidth(stripWidth)
        strip:SetHeight(stripHeight)
        strip:SetTexture(texture)
        strip:SetTexCoord(sourceLeft, sourceRight, sourceTop + (sourceHeight * topFrac), sourceTop + (sourceHeight * bottomFrac))
        strip:SetVertexColor(r, g, b, a)
        strip:Show()
    end
end

function JoypadApplyDiamondViewport(button)
    if not button then
        return
    end

    JoypadEnsureDiamondViewport(button)

    if JoypadIsDiamondViewportEnabled(button.joypadSlot) then
        if button.icon then
            button.icon:Hide()
        end
        if button.diamondFill then
            button.diamondFill:Show()
        end
        if button.diamondMask then
            button.diamondMask:Hide()
        end
        JoypadUpdateDiamondIconStrips(button)
        if JoypadDB and JoypadDB.theme == "elvui" then
            if button.diamondBorder then
                button.diamondBorder:Hide()
            end
            JoypadShowDiamondThemeBorder(button)
        else
            JoypadHideDiamondThemeBorder(button)
            if button.diamondBorder then
                button.diamondBorder:Show()
            end
        end
    else
        JoypadHideDiamondIconStrips(button)
        JoypadHideDiamondThemeBorder(button)
        if button.icon then
            button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            if JoypadDB and JoypadNormalizeTheme(JoypadDB.theme) == "none" then
                JoypadSetIconRegionClassic(button)
            else
                JoypadSetIconRegionFull(button)
            end
            if button.icon:GetTexture() then
                button.icon:Show()
            end
        end
        if button.diamondFill then
            button.diamondFill:Hide()
        end
        if button.diamondMask then
            button.diamondMask:Hide()
        end
        if button.diamondBorder then
            button.diamondBorder:Hide()
        end
    end
end

function JoypadApplyButtonTheme(button)
    if not button then
        return
    end

    EnsureDB()

    local theme = JoypadNormalizeTheme(JoypadDB and JoypadDB.theme)
    local diamondEnabled = JoypadIsDiamondViewportEnabled(button.joypadSlot)

    if theme == "elvui" then
        JoypadHideClassicTheme(button)

        if diamondEnabled then
            JoypadHideThemeBorder(button)
            JoypadShowDiamondThemeBorder(button)
            if button.diamondBorder then
                button.diamondBorder:Hide()
            end
            return
        end

        JoypadHideDiamondThemeBorder(button)
        JoypadEnsureThemeBorder(button)

        -- ElvUI-style layered border:
        -- thin black outer, thin grey middle, thin black inner, with no gaps.
        JoypadApplyThemeRing(button, 1, 2, 2, 0.0, 0.0, 0.0, 1.0)
        JoypadApplyThemeRing(button, 5, 0, 2, 0.0745098, 0.0745098, 0.0705882, 1.0)
        JoypadApplyThemeRing(button, 9, -2, 2, 0.0, 0.0, 0.0, 1.0)
        return
    end

    JoypadHideThemeBorder(button)
    JoypadHideDiamondThemeBorder(button)

    if diamondEnabled then
        JoypadHideClassicTheme(button)
        if button.diamondBorder then
            button.diamondBorder:Show()
        end
        return
    end

    JoypadShowClassicTheme(button)
end

function Joypad:ApplyThemeToButtons()
    for _, button in ipairs(self.buttons or {}) do
        JoypadApplyButtonTheme(button)
        JoypadApplyDiamondViewport(button)
    end
    for _, button in ipairs(self.stanceButtons or {}) do
        JoypadApplyButtonTheme(button)
        JoypadApplyDiamondViewport(button)
    end
end

function Joypad:SetTheme(theme, silent)
    EnsureDB()

    JoypadDB.theme = JoypadNormalizeTheme(theme)
    self:ApplyThemeToButtons()
    UpdateSettingsControls()

    if not silent then
        Print("Theme set to " .. JoypadGetThemeLabel(JoypadDB.theme) .. ".")
    end
end

function Joypad:SetDisplayMode(displayMode, silent)
    EnsureDB()

    JoypadDB.displayMode = JoypadNormalizeDisplayMode(displayMode)
    JoypadApplyDisplayModeSlotProfile(JoypadDB.displayMode, true)
    JoypadApplyDisplayModeSlotVisibility()
    if JoypadClearAltLayoutCache then
        JoypadClearAltLayoutCache()
    end
    JoypadQueueRefresh("all")
    JoypadProcessRefreshQueue(true)
    UpdateSettingsRows()
    UpdateSettingsControls()

    if not silent then
        Print("Display mode set to " .. JoypadGetDisplayModeLabel(JoypadDB.displayMode) .. ".")
    end
end

UpdateEditMode = function()
    EnsureDB()

    local unlocked = JoypadDB.unlocked == true
    local barsShown = holder and holder:IsShown()
    local stanceShown = JoypadDB.stanceBarVisible ~= false and Joypad.stanceHolder and Joypad.stanceHolder:IsShown()

    if unlocked and (barsShown or stanceShown) then
        Joypad:ShowGridOverlay()
        if barsShown then
            Joypad:ShowGroupOverlay()
        else
            Joypad:HideGroupOverlay()
        end
        Joypad:ShowLockButton()
        Joypad:ShowResetButton()
    else
        Joypad:HideGridOverlay()
        Joypad:HideGroupOverlay()
        Joypad:HideLockButton()
        Joypad:HideResetButton()
    end

    for _, button in ipairs(Joypad.buttons) do
        if button.editOverlay then
            PositionEditOverlay(button)
            if unlocked and barsShown and IsSlotEnabled(button.joypadSlot) then
                button.editOverlay:Show()
            else
                button.editOverlay:Hide()
            end
        end
    end

    if unlocked and stanceShown then
        Joypad:ShowStanceEditOverlay()
    else
        Joypad:HideStanceEditOverlay()
    end
end

local function UpdateButtonVisual(button)
    if not button then
        return
    end

    local layerKey = GetActiveJoypadLayerKey()
    local bindingMode = GetJoypadBindingMode(button.joypadSlot, layerKey)

    if bindingMode == "keybind" then
        local command = GetJoypadKeybindCommand(button.joypadSlot, layerKey)
        local texture = GetKeybindPresetIcon(command)

        if button.icon then
            -- p6z17: keep the shared texture cache synchronized when a button
            -- switches between a keybind layer (for example JUMP) and an
            -- action-slot layer.  Direct SetTexture() left joypadLastTexture
            -- pointing at the previous action icon, so returning to that
            -- modifier could incorrectly leave the keybind icon visible.
            JoypadSetTextureIfChanged(button.icon, texture)
            button.icon:Show()
            button.icon:SetVertexColor(1.0, 1.0, 1.0)
        end

        JoypadSetAlphaIfChanged(button, 1)

        if button.altParts then
            ApplyAltPartsAppearance(button)
        end

        if button.hotkey then
            if type(JoypadDB) == "table" and JoypadDB.hideKeybindText == true then
                button.hotkey:SetText("")
                button.hotkey:Hide()
            else
                button.hotkey:SetText(GetBindingLabel(button.bindingCommand))
                button.hotkey:Show()
            end
        end

        if button.macroText then
            if command and command ~= "" then
                button.macroText:SetText(GetKeybindPresetLabel(command))
                button.macroText:Show()
            else
                button.macroText:SetText("")
                button.macroText:Hide()
            end
        end

        if button.count then
            button.count:SetText("")
            button.count:Hide()
        end

        SetCooldown(button.cooldown, 0, 0, 0, nil)
        Joypad.SetEquippedBorderShown(button, false)
        Joypad.SetButtonActiveBorderShown(button, false)

        if button.SetChecked then
            button:SetChecked(0)
        end

        JoypadApplyButtonTheme(button)
        JoypadApplyDiamondViewport(button)
        return
    end

    local actionSlot = GetJoypadDisplayedActionSlot(button.joypadSlot, layerKey)
    if not actionSlot then
        return
    end

    button.displayActionSlot = actionSlot

    local actionInfo = JoypadGetCachedActionSlotInfo and JoypadGetCachedActionSlotInfo(actionSlot) or nil
    local texture = actionInfo and actionInfo.texture or (GetActionTexture and GetActionTexture(actionSlot) or nil)
    local hasAction = actionInfo and actionInfo.hasAction or (HasAction and HasAction(actionSlot) or false)

    if texture then
        JoypadSetTextureIfChanged(button.icon, texture)
        JoypadShowIfHidden(button.icon)
    else
        JoypadSetTextureIfChanged(button.icon, nil)
        JoypadHideIfShown(button.icon)
    end

    JoypadSetAlphaIfChanged(button, hasAction and 1 or 0.45)

    if button.altParts then
        ApplyAltPartsAppearance(button)
    end

    if button.hotkey then
        if type(JoypadDB) == "table" and JoypadDB.hideKeybindText == true then
            button.hotkey:SetText("")
            button.hotkey:Hide()
        else
            button.hotkey:SetText(GetBindingLabel(button.bindingCommand))
            button.hotkey:Show()
        end
    end

    if button.macroText then
        local actionText = actionInfo and actionInfo.actionText or nil
        if not actionText and GetActionText then
            actionText = GetActionText(actionSlot)
        end
        if actionText and actionText ~= "" then
            JoypadSetTextIfChanged(button.macroText, actionText)
            JoypadShowIfHidden(button.macroText)
        else
            JoypadSetTextIfChanged(button.macroText, "")
            JoypadHideIfShown(button.macroText)
        end
    end

    if button.count then
        local count = actionInfo and actionInfo.count or 0
        if not actionInfo and GetActionCount then
            count = GetActionCount(actionSlot) or 0
        end

        if count and count > 1 then
            JoypadSetTextIfChanged(button.count, count)
            JoypadShowIfHidden(button.count)
        else
            JoypadSetTextIfChanged(button.count, "")
            JoypadHideIfShown(button.count)
        end
    end

    if GetActionCooldown then
        local start, duration, enable = GetActionCooldown(actionSlot)
        SetCooldown(button.cooldown, start, duration, enable, actionSlot)
    end

    local actionActive = hasAction and Joypad.IsActionActive(actionSlot)

    if button.SetChecked then
        if actionActive then
            button:SetChecked(1)
        else
            button:SetChecked(0)
        end
    end

    Joypad.SetButtonActiveBorderShown(button, actionActive)
    Joypad.ApplyActionStateVisuals(button, actionSlot, texture, hasAction)

    JoypadApplyButtonTheme(button)
    JoypadApplyDiamondViewport(button)
end

local function UpdateAllButtons(skipSettings)
    for _, button in ipairs(Joypad.buttons) do
        UpdateButtonVisual(button)
    end

    if Joypad.UpdateStanceBarVisuals then
        Joypad:UpdateStanceBarVisuals()
    end

    if not skipSettings then
        UpdateSettingsRows()
    end
end

function JoypadQueueRefresh(kind)
    kind = tostring(kind or "buttons")

    if not Joypad then
        return
    end

    if kind == "settings" then
        Joypad.settingsDirty = true
    elseif kind == "all" then
        Joypad.buttonsDirty = true
        Joypad.settingsDirty = true
    else
        Joypad.buttonsDirty = true
    end
end

function JoypadProcessRefreshQueue(force)
    if not Joypad then
        return
    end

    if force then
        Joypad.buttonsDirty = true
    end

    if Joypad.buttonsDirty then
        Joypad.buttonsDirty = nil
        UpdateAllButtons(true)
    end

    if Joypad.settingsDirty then
        Joypad.settingsDirty = nil
        UpdateSettingsRows()
    end
end


function Joypad:RefreshAll()
    JoypadQueueRefresh("all")
    JoypadProcessRefreshQueue(true)
    UpdateSettingsRows()
end

function Joypad:RefreshAfterSpecOrSpellChange(reason)
    -- Dual-spec swaps in Wrath can restore action-bar contents after the first
    -- talent/spec event has already fired.  Do an immediate refresh plus a few
    -- delayed refreshes so Joypad icons/settings/API lookups see the finished
    -- action-bar state.
    JoypadQueueRefresh("all")
    JoypadProcessRefreshQueue(true)

    if InCombat() then
        self.pendingApply = true
        self.pendingBindingOverrides = true
        return
    end

    if self.Apply then
        self:Apply(true)
    end

    local delays = { 0.20, 0.75, 1.50 }
    for _, delay in ipairs(delays) do
        JoypadTimerAfter(delay, function()
            if Joypad then
                JoypadQueueRefresh("all")
                JoypadProcessRefreshQueue(true)
                if Joypad.Apply and not InCombat() then
                    Joypad:Apply(true)
                end
            end
        end)
    end
end


function Joypad:SetDiamondViewport(joypadSlot, enabled, silent)
    EnsureDB()
    joypadSlot = tonumber(joypadSlot or 0) or 0
    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    JoypadDB.diamondSlots[joypadSlot] = enabled and true or nil
    UpdateAllButtons()
    UpdateSettingsRows()

    if not silent then
        Print("Joypad slot " .. tostring(joypadSlot) .. " diamond viewport " .. (enabled and "enabled" or "disabled") .. ".")
    end
end

local function ApplyButtonSlotVisibility(joypadSlot)
    if InCombat() then
        Joypad.pendingSlotVisibility = true
        return
    end

    for _, button in ipairs(Joypad.buttons) do
        if not joypadSlot or button.joypadSlot == joypadSlot then
            if IsSlotEnabled(button.joypadSlot) then
                button:Show()
            else
                button:Hide()
            end
        end
    end

    UpdateEditMode()
end

local function GetLayerModifiedKeys(baseKey, layerKey)
    layerKey = NormalizeJoypadLayerKey(layerKey)
    local layer = JOYPAD_LAYERS[JOYPAD_LAYER_INDEX[layerKey] or 1]
    local keys = {}

    if not baseKey or baseKey == "" then
        return keys
    end

    if not layer or type(layer.modifierPrefixes) ~= "table" then
        table.insert(keys, baseKey)
        return keys
    end

    for _, prefix in ipairs(layer.modifierPrefixes) do
        table.insert(keys, tostring(prefix or "") .. baseKey)
    end

    return keys
end

local function ApplyJoypadBindingOverrides(silent)
    EnsureDB()

    if InCombat() then
        Joypad.pendingBindingOverrides = true
        if not silent then
            Print("binding override update queued until combat ends.")
        end
        return
    end

    if ClearOverrideBindings then
        ClearOverrideBindings(Joypad)
    end

    if not GetBindingKey then
        return
    end

    local applied = 0

    for joypadSlot = 1, 24 do
        local _, bindingCommand = GetJoypadSlotInfo(joypadSlot, "base")

        if bindingCommand then
            local keys = { GetBindingKey(bindingCommand) }
            local button = Joypad.buttons and Joypad.buttons[joypadSlot]
            local buttonName = button and button.GetName and button:GetName()

            for _, baseKey in ipairs(keys) do
                if baseKey and baseKey ~= "" then
                    for _, layer in ipairs(JOYPAD_LAYERS) do
                        local bindingMode = GetJoypadBindingMode(joypadSlot, layer.key)
                        local modifiedKeys = GetLayerModifiedKeys(baseKey, layer.key)

                        for _, modifiedKey in ipairs(modifiedKeys) do
                            if bindingMode == "keybind" then
                                local command = GetJoypadKeybindCommand(joypadSlot, layer.key)
                                if command and command ~= "" and SetOverrideBinding then
                                    SetOverrideBinding(Joypad, true, modifiedKey, command)
                                    applied = applied + 1
                                end
                            else
                                if buttonName and SetOverrideBindingClick then
                                    SetOverrideBindingClick(Joypad, true, modifiedKey, buttonName, "LeftButton")
                                    applied = applied + 1
                                elseif SetOverrideBinding then
                                    -- Fallback for clients without SetOverrideBindingClick.
                                    SetOverrideBinding(Joypad, true, modifiedKey, bindingCommand)
                                    applied = applied + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if not silent then
        Print("applied " .. tostring(applied) .. " Joypad binding override(s) across Base/Shift/Ctrl/Shift+Ctrl.")
    end
end

local function IterateBlizzardActionButtons(callback)
    if type(callback) ~= "function" then
        return
    end

    for _, prefix in ipairs(BLIZZARD_ACTION_BUTTON_PREFIXES) do
        for i = 1, 12 do
            local frame = _G[prefix .. i]
            if frame then
                callback(frame, prefix, i)
            end
        end
    end
end

local function IterateBlizzardActionArt(callback)
    if type(callback) ~= "function" then
        return
    end

    for _, objectName in ipairs(BLIZZARD_ACTION_ART_OBJECTS) do
        local object = _G[objectName]
        if object then
            callback(object, objectName)
        end
    end
end

local function HideBlizzardObject(object, objectName)
    if not object then
        return
    end

    objectName = objectName or (object.GetName and object:GetName())

    if objectName and Joypad.blizzardWasShown[objectName] == nil and object.IsShown then
        Joypad.blizzardWasShown[objectName] = object:IsShown() and true or false
    end

    if object.SetAlpha then
        object:SetAlpha(0)
    end

    if object.EnableMouse then
        object:EnableMouse(false)
    end

    if object.Hide then
        object:Hide()
    end

    if objectName and object.HookScript and not Joypad.blizzardHooks[objectName] then
        Joypad.blizzardHooks[objectName] = true
        object:HookScript("OnShow", function(selfObject)
            if type(JoypadDB) == "table" and JoypadDB.hideBlizzardBars == true then
                if InCombat() then
                    Joypad.pendingBlizzardBars = true
                    return
                end

                if selfObject.SetAlpha then
                    selfObject:SetAlpha(0)
                end
                if selfObject.EnableMouse then
                    selfObject:EnableMouse(false)
                end
                if selfObject.Hide then
                    selfObject:Hide()
                end
            end
        end)
    end
end

local function ShowBlizzardObject(object, objectName)
    if not object then
        return
    end

    objectName = objectName or (object.GetName and object:GetName())

    if object.SetAlpha then
        object:SetAlpha(1)
    end

    if object.EnableMouse then
        object:EnableMouse(true)
    end

    if object.Show then
        if objectName then
            if Joypad.blizzardWasShown[objectName] ~= false then
                object:Show()
            end
            Joypad.blizzardWasShown[objectName] = nil
        else
            object:Show()
        end
    end
end

local function ApplyBlizzardBarsVisibility()
    EnsureDB()

    if InCombat() then
        Joypad.pendingBlizzardBars = true
        return
    end

    Joypad.blizzardWasShown = Joypad.blizzardWasShown or {}
    Joypad.blizzardHooks = Joypad.blizzardHooks or {}

    local hideBlizzard = JoypadDB.hideBlizzardBars == true

    IterateBlizzardActionButtons(function(frame)
        local frameName = frame.GetName and frame:GetName()
        if hideBlizzard then
            HideBlizzardObject(frame, frameName)
        else
            ShowBlizzardObject(frame, frameName)
        end
    end)

    IterateBlizzardActionArt(function(object, objectName)
        if hideBlizzard then
            HideBlizzardObject(object, objectName)
        else
            ShowBlizzardObject(object, objectName)
        end
    end)
end

local function GetActiveJoypadActionSlot(button)
    if not button then
        return nil, "base", "missing button"
    end

    local layerKey = GetActiveJoypadLayerKey()
    if GetJoypadBindingMode(button.joypadSlot, layerKey) ~= "action" then
        return nil, layerKey, "current Joypad layer is a keybind"
    end

    local actionSlot = GetJoypadDisplayedActionSlot(button.joypadSlot, layerKey)
    if not actionSlot then
        return nil, layerKey, "current Joypad layer has no action slot"
    end

    return actionSlot, layerKey, nil
end

local function PlaceOrPickupAction(button)
    if not button or InCombat() then
        return
    end

    local actionSlot, layerKey, reason = GetActiveJoypadActionSlot(button)
    if not actionSlot then
        if CursorHasItem and CursorHasItem() or CursorHasSpell and CursorHasSpell() or CursorHasMacro and CursorHasMacro() then
            Print("cannot place on " .. GetJoypadLayerLabel(layerKey) .. ": " .. tostring(reason or "no action slot") .. ".")
        end
        return
    end

    if CursorHasItem and CursorHasItem() then
        PlaceAction(actionSlot)
        ClearCursor()
    elseif CursorHasSpell and CursorHasSpell() then
        PlaceAction(actionSlot)
        ClearCursor()
    elseif CursorHasMacro and CursorHasMacro() then
        PlaceAction(actionSlot)
        ClearCursor()
    elseif PickupAction then
        PickupAction(actionSlot)
    end

    UpdateButtonVisual(button)
end

local function OnEnter(button)
    if not button then
        return
    end

    if GameTooltip then
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        local activeActionSlot, activeLayerKey = GetActiveJoypadActionSlot(button)
        if activeActionSlot and HasAction and HasAction(activeActionSlot) and GameTooltip.SetAction then
            GameTooltip:SetAction(activeActionSlot)
        else
            GameTooltip:SetText(button.bindingCommand or ADDON_NAME)
            if activeActionSlot then
                GameTooltip:AddLine(GetJoypadLayerLabel(activeLayerKey) .. " action slot " .. activeActionSlot, 0.7, 0.7, 0.7)
            elseif activeLayerKey then
                GameTooltip:AddLine(GetJoypadLayerLabel(activeLayerKey) .. " layer has no action slot", 0.7, 0.7, 0.7)
            end
        end
        GameTooltip:Show()
    end
end

local function OnLeave()
    if GameTooltip then
        GameTooltip:Hide()
    end
end

local function UpdatePositionPopupFields()
    local popup = Joypad.positionPopup
    if not popup or not popup.joypadSlot then
        return
    end

    local x, y = GetSlotPosition(popup.joypadSlot)
    if popup.xBox and not popup.xBox:HasFocus() then
        popup.xBox:SetText(tostring(x))
    end
    if popup.yBox and not popup.yBox:HasFocus() then
        popup.yBox:SetText(tostring(y))
    end
    if popup.scaleBox and not popup.scaleBox:HasFocus() then
        popup.scaleBox:SetText(tostring(GetSlotScale(popup.joypadSlot)))
    end
    if popup.slotText then
        popup.slotText:SetText("Joypad slot " .. tostring(popup.joypadSlot) .. "  Alt: " .. GetAltLabel(popup.joypadSlot))
    end
end

function Joypad:CreatePositionPopup()
    if self.positionPopup then
        return
    end

    local frame = CreateFrame("Frame", "JoypadPositionPopup", UIParent)
    frame:SetWidth(330)
    frame:SetHeight(195)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(50)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(selfFrame) selfFrame:StartMoving() end)
    frame:SetScript("OnDragStop", function(selfFrame) selfFrame:StopMovingOrSizing() end)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    frame:Hide()

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -16)
    title:SetText("Joypad Position")

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

    frame.slotText = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    frame.slotText:SetPoint("TOP", title, "BOTTOM", 0, -10)
    frame.slotText:SetWidth(240)
    frame.slotText:SetJustifyH("CENTER")
    frame.slotText:SetText("Joypad slot")

    local xLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    xLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 42, -68)
    xLabel:SetText("X")

    local yLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    yLabel:SetPoint("LEFT", xLabel, "LEFT", 90, 0)
    yLabel:SetText("Y")

    local scaleLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    scaleLabel:SetPoint("LEFT", xLabel, "LEFT", 180, 0)
    scaleLabel:SetText("Scale %")

    frame.xBox = CreateFrame("EditBox", "JoypadPositionPopupX", frame, "InputBoxTemplate")
    frame.xBox:SetWidth(68)
    frame.xBox:SetHeight(20)
    frame.xBox:SetPoint("TOPLEFT", xLabel, "BOTTOMLEFT", 0, -6)
    frame.xBox:SetAutoFocus(false)

    frame.yBox = CreateFrame("EditBox", "JoypadPositionPopupY", frame, "InputBoxTemplate")
    frame.yBox:SetWidth(68)
    frame.yBox:SetHeight(20)
    frame.yBox:SetPoint("TOPLEFT", yLabel, "BOTTOMLEFT", 0, -6)
    frame.yBox:SetAutoFocus(false)

    frame.scaleBox = CreateFrame("EditBox", "JoypadPositionPopupScale", frame, "InputBoxTemplate")
    frame.scaleBox:SetWidth(68)
    frame.scaleBox:SetHeight(20)
    frame.scaleBox:SetPoint("TOPLEFT", scaleLabel, "BOTTOMLEFT", 0, -6)
    frame.scaleBox:SetAutoFocus(false)

    local function ApplyPopupPosition()
        local joypadSlot = frame.joypadSlot
        local x = tonumber(frame.xBox:GetText() or "")
        local y = tonumber(frame.yBox:GetText() or "")
        local scale = tonumber(frame.scaleBox:GetText() or "")

        if not joypadSlot or not x or not y or not scale then
            Print("enter numeric X, Y, and Scale % values.")
            return
        end

        Joypad:SetSlotPosition(joypadSlot, x, y, true)
        Joypad:SetSlotScale(joypadSlot, scale, false)
        frame:Hide()
    end

    frame.xBox:SetScript("OnEnterPressed", ApplyPopupPosition)
    frame.yBox:SetScript("OnEnterPressed", ApplyPopupPosition)
    frame.scaleBox:SetScript("OnEnterPressed", ApplyPopupPosition)
    frame.xBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.yBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.scaleBox:SetScript("OnEscapePressed", function() frame:Hide() end)

    local apply = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    apply:SetWidth(72)
    apply:SetHeight(22)
    apply:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -24, 18)
    apply:SetText("Apply")
    apply:SetScript("OnClick", ApplyPopupPosition)

    local reset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    reset:SetWidth(72)
    reset:SetHeight(22)
    reset:SetPoint("RIGHT", apply, "LEFT", -8, 0)
    reset:SetText("Reset")
    reset:SetScript("OnClick", function()
        if not frame.joypadSlot then
            return
        end
        local x, y = GetDefaultSlotPosition(frame.joypadSlot)
        Joypad:SetSlotPosition(frame.joypadSlot, x, y, true)
        Joypad:SetSlotScale(frame.joypadSlot, GetDefaultSlotScale(), false)
        UpdatePositionPopupFields()
    end)

    self.positionPopup = frame
end

function Joypad:OpenPositionPopup(joypadSlot)
    EnsureDB()
    if JoypadDB.unlocked ~= true then
        return
    end

    self:CreatePositionPopup()
    if not self.positionPopup then
        return
    end

    self.positionPopup.joypadSlot = tonumber(joypadSlot or 0) or 0
    UpdatePositionPopupFields()
    self.positionPopup:Show()
end


local function UpdateGroupPopupFields()
    local popup = Joypad.groupPopup
    if not popup then
        return
    end

    local x, y = GetGroupCenter()
    if popup.xBox and not popup.xBox:HasFocus() then
        popup.xBox:SetText(tostring(x))
    end
    if popup.yBox and not popup.yBox:HasFocus() then
        popup.yBox:SetText(tostring(y))
    end
    if popup.scaleBox and not popup.scaleBox:HasFocus() then
        popup.scaleBox:SetText(tostring(GetGroupScale()))
    end
    if popup.groupText then
        popup.groupText:SetText("All Joypad slots  X " .. tostring(x) .. " / Y " .. tostring(y) .. " / Scale " .. tostring(GetGroupScale()) .. "%")
    end
end

function Joypad:CreateGroupPopup()
    if self.groupPopup then
        return
    end

    local frame = CreateFrame("Frame", "JoypadGroupPositionPopup", UIParent)
    frame:SetWidth(330)
    frame:SetHeight(195)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(50)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(selfFrame) selfFrame:StartMoving() end)
    frame:SetScript("OnDragStop", function(selfFrame) selfFrame:StopMovingOrSizing() end)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    frame:Hide()

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -16)
    title:SetText("Joypad Group Position")

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

    frame.groupText = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    frame.groupText:SetPoint("TOP", title, "BOTTOM", 0, -10)
    frame.groupText:SetWidth(240)
    frame.groupText:SetJustifyH("CENTER")
    frame.groupText:SetText("All Joypad slots")

    local xLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    xLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 42, -68)
    xLabel:SetText("X")

    local yLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    yLabel:SetPoint("LEFT", xLabel, "LEFT", 90, 0)
    yLabel:SetText("Y")

    local scaleLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    scaleLabel:SetPoint("LEFT", xLabel, "LEFT", 180, 0)
    scaleLabel:SetText("Scale %")

    frame.xBox = CreateFrame("EditBox", "JoypadGroupPositionPopupX", frame, "InputBoxTemplate")
    frame.xBox:SetWidth(68)
    frame.xBox:SetHeight(20)
    frame.xBox:SetPoint("TOPLEFT", xLabel, "BOTTOMLEFT", 0, -6)
    frame.xBox:SetAutoFocus(false)

    frame.yBox = CreateFrame("EditBox", "JoypadGroupPositionPopupY", frame, "InputBoxTemplate")
    frame.yBox:SetWidth(68)
    frame.yBox:SetHeight(20)
    frame.yBox:SetPoint("TOPLEFT", yLabel, "BOTTOMLEFT", 0, -6)
    frame.yBox:SetAutoFocus(false)

    frame.scaleBox = CreateFrame("EditBox", "JoypadGroupPositionPopupScale", frame, "InputBoxTemplate")
    frame.scaleBox:SetWidth(68)
    frame.scaleBox:SetHeight(20)
    frame.scaleBox:SetPoint("TOPLEFT", scaleLabel, "BOTTOMLEFT", 0, -6)
    frame.scaleBox:SetAutoFocus(false)

    local function ApplyGroupPopupPosition()
        local x = tonumber(frame.xBox:GetText() or "")
        local y = tonumber(frame.yBox:GetText() or "")
        local scale = tonumber(frame.scaleBox:GetText() or "")

        if not x or not y or not scale then
            Print("enter numeric group X, Y, and Scale % values.")
            return
        end

        Joypad:SetAllSlotScales(scale, true)
        Joypad:SetGroupCenter(x, y, false)
        frame:Hide()
    end

    frame.xBox:SetScript("OnEnterPressed", ApplyGroupPopupPosition)
    frame.yBox:SetScript("OnEnterPressed", ApplyGroupPopupPosition)
    frame.scaleBox:SetScript("OnEnterPressed", ApplyGroupPopupPosition)
    frame.xBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.yBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.scaleBox:SetScript("OnEscapePressed", function() frame:Hide() end)

    local apply = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    apply:SetWidth(72)
    apply:SetHeight(22)
    apply:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -24, 18)
    apply:SetText("Apply")
    apply:SetScript("OnClick", ApplyGroupPopupPosition)

    local reset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    reset:SetWidth(72)
    reset:SetHeight(22)
    reset:SetPoint("RIGHT", apply, "LEFT", -8, 0)
    reset:SetText("Center")
    reset:SetScript("OnClick", function()
        Joypad:SetGroupCenter(0, 0, true)
        UpdateGroupPopupFields()
    end)

    self.groupPopup = frame
end

function Joypad:OpenGroupPopup()
    EnsureDB()
    if JoypadDB.unlocked ~= true then
        return
    end

    self:CreateGroupPopup()
    if not self.groupPopup then
        return
    end

    UpdateGroupPopupFields()
    self.groupPopup:Show()
end

function Joypad:StartDragButton(button, overlay)
    EnsureDB()

    if JoypadDB.unlocked ~= true or not button or not overlay then
        return
    end

    if InCombat() then
        Print("button positioning is locked during combat.")
        return
    end

    overlay:SetScript("OnUpdate", function()
        if not GetCursorPosition or not UIParent then
            return
        end

        local uiScale = UIParent:GetEffectiveScale() or 1
        local cursorX, cursorY = GetCursorPosition()
        cursorX = cursorX / uiScale
        cursorY = cursorY / uiScale

        local centerX, centerY = UIParent:GetCenter()
        if not centerX or not centerY then
            return
        end

        local targetX, targetY = JoypadSnapPointToGrid(cursorX - centerX, cursorY - centerY)
        Joypad:SetSlotPosition(button.joypadSlot, targetX, targetY, true)
    end)
end

function Joypad:StopDragButton(overlay)
    if overlay then
        overlay:SetScript("OnUpdate", nil)
    end
    UpdatePositionPopupFields()
end


local function ClearButtonSecureActionAttributes(button)
    if not button then
        return
    end
    if InCombat() then
        if Joypad then Joypad.pendingApply = true end
        return
    end

    if UnregisterStateDriver then
        UnregisterStateDriver(button, "joypaddruidpage")
        UnregisterStateDriver(button, "joypadclasspage")
        UnregisterStateDriver(button, "joypadlayer")
    end

    button:SetAttribute("_onstate-joypaddruidpage", nil)
    button:SetAttribute("_onstate-joypadclasspage", nil)
    button:SetAttribute("_onstate-joypadlayer", nil)
    button:SetAttribute("joypad-druid-caster-action", nil)
    button:SetAttribute("joypad-druid-cat-action", nil)
    button:SetAttribute("joypad-druid-prowl-action", nil)
    button:SetAttribute("joypad-druid-bear-action", nil)
    button:SetAttribute("joypad-druid-moonkin-action", nil)
    button:SetAttribute("joypad-page7-action", nil)
    button:SetAttribute("joypad-page8-action", nil)
    button:SetAttribute("joypad-page9-action", nil)
    button:SetAttribute("joypad-page10-action", nil)
    button:SetAttribute("joypad-page11-action", nil)

    local layerKeys = { "base", "shift", "ctrl", "shiftctrl" }
    for _, layerKey in ipairs(layerKeys) do
        button:SetAttribute("joypad-" .. layerKey .. "-action", nil)
    end

    local prefixes = { "", "shift-", "ctrl-", "shift-ctrl-", "ctrl-shift-" }
    for _, prefix in ipairs(prefixes) do
        button:SetAttribute(prefix .. "type1", nil)
        button:SetAttribute(prefix .. "action1", nil)
    end

    button:SetAttribute("type", nil)
    button:SetAttribute("action", nil)
end

function JoypadApplyClassPagingAttributes(button)
    if not button or not button.SetAttribute then
        return
    end
    if InCombat() then
        if Joypad then Joypad.pendingApply = true end
        return
    end

    local pageButton = JOYPAD_CLASS_PAGED_SLOTS and JOYPAD_CLASS_PAGED_SLOTS[button.joypadSlot]
    if not pageButton then
        return
    end

    if GetJoypadBindingMode(button.joypadSlot, "base") ~= "action" then
        return
    end

    local casterActionSlot = GetJoypadSlotInfo(button.joypadSlot, "base")
    if not casterActionSlot then
        return
    end

    button:SetAttribute("joypad-base-action", casterActionSlot)
    button:SetAttribute("joypad-page7-action", (JOYPAD_CLASS_PAGE_ACTION_STARTS.page7 or 73) + pageButton - 1)
    button:SetAttribute("joypad-page8-action", (JOYPAD_CLASS_PAGE_ACTION_STARTS.page8 or 85) + pageButton - 1)
    button:SetAttribute("joypad-page9-action", (JOYPAD_CLASS_PAGE_ACTION_STARTS.page9 or 97) + pageButton - 1)
    button:SetAttribute("joypad-page10-action", (JOYPAD_CLASS_PAGE_ACTION_STARTS.page10 or 109) + pageButton - 1)
    button:SetAttribute("joypad-page11-action", (JOYPAD_CLASS_PAGE_ACTION_STARTS.page11 or 121) + pageButton - 1)

    -- Backwards-compatible Druid attribute names for older debug/API expectations.
    button:SetAttribute("joypad-druid-caster-action", casterActionSlot)
    button:SetAttribute("joypad-druid-cat-action", (JOYPAD_CLASS_PAGE_ACTION_STARTS.page7 or 73) + pageButton - 1)
    button:SetAttribute("joypad-druid-prowl-action", (JOYPAD_CLASS_PAGE_ACTION_STARTS.page8 or 85) + pageButton - 1)
    button:SetAttribute("joypad-druid-bear-action", (JOYPAD_CLASS_PAGE_ACTION_STARTS.page9 or 97) + pageButton - 1)
    button:SetAttribute("joypad-druid-moonkin-action", (JOYPAD_CLASS_PAGE_ACTION_STARTS.page10 or 109) + pageButton - 1)
end

function JoypadApplyDruidPagingAttributes(button)
    return JoypadApplyClassPagingAttributes(button)
end

function JoypadSetButtonCurrentAction(button, actionSlot)
    if not button or not button.SetAttribute then
        return
    end
    if InCombat() then
        if Joypad then Joypad.pendingApply = true end
        return
    end

    if actionSlot then
        button:SetAttribute("type", "action")
        button:SetAttribute("action", actionSlot)
        button:SetAttribute("type1", "action")
        button:SetAttribute("action1", actionSlot)
    else
        button:SetAttribute("type", nil)
        button:SetAttribute("action", nil)
        button:SetAttribute("type1", nil)
        button:SetAttribute("action1", nil)
    end
end

function JoypadGetButtonInitialSecureAction(button)
    if not button then
        return nil
    end

    local layerKey = GetActiveJoypadLayerKey()
    local actionSlot = nil

    if layerKey == "shift" or layerKey == "ctrl" or layerKey == "shiftctrl" then
        if GetJoypadBindingMode(button.joypadSlot, layerKey) == "action" then
            actionSlot = GetJoypadSlotInfo(button.joypadSlot, layerKey)
        end
        return actionSlot
    end

    if GetJoypadBindingMode(button.joypadSlot, "base") == "action" then
        actionSlot = GetJoypadSlotInfo(button.joypadSlot, "base")
        actionSlot = JoypadGetClassPagedActionSlot(button.joypadSlot, "base", actionSlot)
    end

    return actionSlot
end

function JoypadApplySecureLayerStateDriver(button)
    if not button or not button.SetAttribute then
        return
    end
    if InCombat() then
        if Joypad then Joypad.pendingApply = true end
        return
    end

    -- The keybind decides only which Joypad button is clicked.  This secure
    -- state decides what action that button currently represents.  This avoids
    -- relying on fragile SHIFT-; / SHIFT-' style bindings on punctuation keys.
    button:SetAttribute("_onstate-joypadlayer", [[
        local action = nil

        if newstate == "shift" then
            action = self:GetAttribute("joypad-shift-action")
        elseif newstate == "ctrl" then
            action = self:GetAttribute("joypad-ctrl-action")
        elseif newstate == "shiftctrl" then
            action = self:GetAttribute("joypad-shiftctrl-action")
        elseif newstate == "page7" then
            action = self:GetAttribute("joypad-page7-action")
        elseif newstate == "page8" then
            action = self:GetAttribute("joypad-page8-action")
        elseif newstate == "page9" then
            action = self:GetAttribute("joypad-page9-action")
        elseif newstate == "page10" then
            action = self:GetAttribute("joypad-page10-action")
        elseif newstate == "page11" then
            action = self:GetAttribute("joypad-page11-action")
        elseif newstate == "vehicle" or newstate == "possess" or newstate == "override" then
            action = self:GetAttribute("joypad-page11-action")
        elseif newstate == "cat" then
            action = self:GetAttribute("joypad-page7-action")
        elseif newstate == "prowl" then
            action = self:GetAttribute("joypad-page8-action")
        elseif newstate == "bear" then
            action = self:GetAttribute("joypad-page9-action")
        elseif newstate == "moonkin" then
            action = self:GetAttribute("joypad-page10-action")
        else
            action = self:GetAttribute("joypad-base-action")
        end

        if not action then
            action = self:GetAttribute("joypad-base-action")
        end

        if action then
            self:SetAttribute("type", "action")
            self:SetAttribute("action", action)
            self:SetAttribute("type1", "action")
            self:SetAttribute("action1", action)
        else
            self:SetAttribute("type", nil)
            self:SetAttribute("action", nil)
            self:SetAttribute("type1", nil)
            self:SetAttribute("action1", nil)
        end
    ]])

    if RegisterStateDriver then
        RegisterStateDriver(button, "joypadlayer", JoypadGetSecureActionStateDriver())
    else
        JoypadSetButtonCurrentAction(button, JoypadGetButtonInitialSecureAction(button))
    end
end

local function ApplyButtonSecureLayerAttributes(button)
    if not button then
        return
    end
    if InCombat() then
        if Joypad then Joypad.pendingApply = true end
        return
    end

    ClearButtonSecureActionAttributes(button)

    for _, layer in ipairs(JOYPAD_LAYERS) do
        if GetJoypadBindingMode(button.joypadSlot, layer.key) == "action" then
            local actionSlot = GetJoypadSlotInfo(button.joypadSlot, layer.key)
            if actionSlot then
                button:SetAttribute("joypad-" .. layer.key .. "-action", actionSlot)

                -- Keep the old modifier-specific attributes too, so normal
                -- modified clicks still work.  The new state driver covers the
                -- case where punctuation keys fall through as the base click.
                if layer.key == "base" then
                    button:SetAttribute("type", "action")
                    button:SetAttribute("action", actionSlot)
                    button:SetAttribute("type1", "action")
                    button:SetAttribute("action1", actionSlot)
                elseif layer.key == "shift" then
                    button:SetAttribute("shift-type1", "action")
                    button:SetAttribute("shift-action1", actionSlot)
                elseif layer.key == "ctrl" then
                    button:SetAttribute("ctrl-type1", "action")
                    button:SetAttribute("ctrl-action1", actionSlot)
                elseif layer.key == "shiftctrl" then
                    button:SetAttribute("shift-ctrl-type1", "action")
                    button:SetAttribute("shift-ctrl-action1", actionSlot)
                    button:SetAttribute("ctrl-shift-type1", "action")
                    button:SetAttribute("ctrl-shift-action1", actionSlot)
                end
            end
        end
    end

    JoypadApplyClassPagingAttributes(button)
    JoypadSetButtonCurrentAction(button, JoypadGetButtonInitialSecureAction(button))
    JoypadApplySecureLayerStateDriver(button)

    button:SetAttribute("checkselfcast", true)
    button:SetAttribute("checkfocuscast", true)
end

function Joypad:GetExpectedInputResult(joypadSlot)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    local layerKey = GetActiveJoypadLayerKey()
    local pageState, form, classFile = JoypadGetClassPagingState and JoypadGetClassPagingState() or "base", "base", nil
    local effectiveLayer = layerKey

    if layerKey == "base" and pageState and pageState ~= "base" then
        effectiveLayer = pageState
    end

    local mode = GetJoypadBindingMode(joypadSlot, layerKey)
    local actionSlot, bindingCommand = GetJoypadSlotInfo(joypadSlot, layerKey)
    local rawActionSlot = actionSlot

    if mode == "action" and layerKey == "base" and JoypadGetClassPagedActionSlot then
        actionSlot = JoypadGetClassPagedActionSlot(joypadSlot, layerKey, actionSlot)
    end

    local actionType, actionID, actionSubType = nil, nil, nil
    local hasAction = false
    local actionName = nil
    if mode == "action" and actionSlot then
        if HasAction then
            hasAction = HasAction(actionSlot) and true or false
        end
        if GetActionInfo then
            actionType, actionID, actionSubType = GetActionInfo(actionSlot)
        end
        if GetActionText then
            actionName = GetActionText(actionSlot)
        end
        if (not actionName or actionName == "") and actionType == "spell" and GetSpellInfo then
            actionName = GetSpellInfo(actionID)
        elseif (not actionName or actionName == "") and actionType == "item" and GetItemInfo then
            actionName = GetItemInfo(actionID)
        end
    elseif mode == "keybind" then
        bindingCommand = GetJoypadKeybindCommand(joypadSlot, layerKey)
    end

    return {
        layerKey = layerKey,
        effectiveLayer = effectiveLayer,
        page = pageState or "base",
        form = form or "base",
        class = classFile,
        mode = mode,
        actionSlot = actionSlot,
        rawActionSlot = rawActionSlot,
        hasAction = hasAction,
        actionType = actionType,
        actionID = actionID,
        actionSubType = actionSubType,
        actionName = actionName,
        bindingCommand = bindingCommand,
    }
end

function Joypad:LogButtonInput(button, mouseButton, source)
    EnsureDB()

    if JoypadDB.inputLogEnabled ~= true then
        return
    end

    local joypadSlot = tonumber(button and button.joypadSlot or 0) or 0
    if joypadSlot <= 0 then
        return
    end

    local expected = self:GetExpectedInputResult(joypadSlot) or {}
    local listeningCommand = GetJoypadListeningBindingCommand(joypadSlot)
    local expectedKey = GetJoypadDefaultKeyForCommand and GetJoypadDefaultKeyForCommand(listeningCommand) or nil
    local boundKeys = {}
    if GetBindingKey and listeningCommand then
        boundKeys = { GetBindingKey(listeningCommand) }
    end

    local entry = {
        t = GetTime and GetTime() or 0,
        slot = joypadSlot,
        label = tostring(GetAltLabel(joypadSlot) or ""),
        mouseButton = tostring(mouseButton or ""),
        source = tostring(source or "button"),
        expectedKey = expectedKey,
        expectedKeyAliases = JoypadCandidateKeysText(expectedKey),
        listeningCommand = listeningCommand,
        boundKeys = table.concat(boundKeys, ", "),
        layer = expected.layerKey,
        effectiveLayer = expected.effectiveLayer,
        page = expected.page,
        form = expected.form,
        class = expected.class,
        mode = expected.mode,
        actionSlot = expected.actionSlot,
        rawActionSlot = expected.rawActionSlot,
        hasAction = expected.hasAction,
        actionType = expected.actionType,
        actionID = expected.actionID,
        actionSubType = expected.actionSubType,
        actionName = expected.actionName,
        bindingCommand = expected.bindingCommand,
        combat = InCombat() and true or false,
        target = UnitExists and UnitExists("target") and UnitName and UnitName("target") or nil,
    }

    JoypadDB.inputLog = JoypadDB.inputLog or {}
    table.insert(JoypadDB.inputLog, entry)
    while #JoypadDB.inputLog > 200 do
        table.remove(JoypadDB.inputLog, 1)
    end

    JoypadDB.inputLogMeta = JoypadDB.inputLogMeta or {}
    JoypadDB.inputLogMeta.lastVersion = tostring(VERSION or "")
    JoypadDB.inputLogMeta.lastUpdated = entry.t
    JoypadDB.inputLogMeta.count = #JoypadDB.inputLog
end

function Joypad:ClearInputLog(silent)
    EnsureDB()

    JoypadDB.inputLog = {}
    JoypadDB.inputLogMeta = {
        lastVersion = tostring(VERSION or ""),
        lastCleared = GetTime and GetTime() or 0,
        count = 0,
    }

    if not silent then
        Print("Joypad input log cleared.")
    end
end

function Joypad:PrintRecentInputLog(limit)
    EnsureDB()

    limit = tonumber(limit or 12) or 12
    if limit < 1 then limit = 1 end
    if limit > 30 then limit = 30 end

    local log = JoypadDB.inputLog or {}
    local total = #log
    Print("Joypad input log: " .. tostring(total) .. " saved input(s), showing last " .. tostring(math.min(limit, total)) .. ".")

    local startIndex = total - limit + 1
    if startIndex < 1 then startIndex = 1 end

    for index = startIndex, total do
        local e = log[index] or {}
        local result = e.bindingCommand
        if e.mode == "action" then
            result = "action " .. tostring(e.actionSlot or "?")
            if e.actionName and e.actionName ~= "" then
                result = result .. " " .. tostring(e.actionName)
            elseif e.actionType then
                result = result .. " " .. tostring(e.actionType)
            end
            if e.hasAction == false then
                result = result .. " (empty)"
            end
        end

        Print(string.format("#%d [%02d %s] key=%s layer=%s page=%s -> %s", index, tonumber(e.slot or 0) or 0, tostring(e.label or "?"), tostring(e.expectedKeyAliases or e.expectedKey or "?"), tostring(e.layer or "?"), tostring(e.page or "?"), tostring(result or "?")))
    end
end

local function CreateJoypadButton(index, barDef, buttonIndex)
    local name = "JoypadButton" .. index
    local button = CreateFrame("CheckButton", name, holder, "SecureActionButtonTemplate,SecureHandlerStateTemplate")
    button:SetWidth(BUTTON_SIZE)
    button:SetHeight(BUTTON_SIZE)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(holder:GetFrameLevel() + 5)
    button:RegisterForClicks("AnyUp")
    button:RegisterForDrag("LeftButton")
    button:EnableMouse(true)
    button:SetScript("PostClick", function(selfButton, mouseButton)
        if Joypad and Joypad.LogButtonInput then
            Joypad:LogButtonInput(selfButton, mouseButton, "joypad")
        end
    end)

    local assignedActionSlot, assignedBindingCommand = GetJoypadSlotInfo(index, "base")
    button.actionSlot = assignedActionSlot or (barDef.firstActionSlot + buttonIndex - 1)
    button.bindingCommand = assignedBindingCommand or (barDef.bindingPrefix .. buttonIndex)
    button.joypadBarName = barDef.name
    button.joypadButtonIndex = buttonIndex
    button.joypadRow = barDef.row
    button.joypadSlot = index

    ApplyButtonSecureLayerAttributes(button)

    -- Stripped-back visual style: no Blizzard quickslot border, pushed texture,
    -- checked texture, or square highlight.  The action icon fills the button;
    -- only the Alt label and keybind text are drawn over it.
    button.icon = button:CreateTexture(name .. "Icon", "ARTWORK")
    button.icon:SetAllPoints(button)
    button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    JoypadEnsureDiamondViewport(button)

    button.cooldown = CreateFrame("Cooldown", name .. "Cooldown", button, "CooldownFrameTemplate")
    button.cooldown:SetAllPoints(button.icon)
    button.cooldown.ownerButton = button

    button.cooldownTextHolder = CreateFrame("Frame", nil, button)
    button.cooldownTextHolder:SetAllPoints(button)
    button.cooldownTextHolder:SetFrameStrata(button:GetFrameStrata())
    button.cooldownTextHolder:SetFrameLevel(button:GetFrameLevel() + 10)

    button.cooldownText = button.cooldownTextHolder:CreateFontString(name .. "CooldownText", "OVERLAY", "NumberFontNormalLarge")
    do
        local fontPath, fontSize = NumberFontNormalLarge:GetFont()
        button.cooldownText:SetFont(fontPath or "Fonts\\ARIALN.TTF", fontSize or 18, "THICKOUTLINE")
    end
    button.cooldownText:SetPoint("CENTER", button.cooldownTextHolder, "CENTER", 0, 0)
    button.cooldownText:SetWidth(BUTTON_SIZE + 18)
    button.cooldownText:SetHeight(24)
    button.cooldownText:SetJustifyH("CENTER")
    button.cooldownText:SetJustifyV("MIDDLE")
    button.cooldownText:SetTextColor(1, 1, 1, 1)
    button.cooldownText:SetShadowColor(0, 0, 0, 1)
    button.cooldownText:SetShadowOffset(1, -1)
    if button.cooldownText.SetDrawLayer then
        button.cooldownText:SetDrawLayer("OVERLAY", 6)
    end
    button.cooldownText:Hide()

    button.readyFlashHolder = CreateFrame("Frame", nil, button)
    button.readyFlashHolder:SetAllPoints(button)
    button.readyFlashHolder:SetFrameStrata(button:GetFrameStrata())
    button.readyFlashHolder:SetFrameLevel(button:GetFrameLevel() + 9)

    button.readyFlash = button.readyFlashHolder:CreateTexture(name .. "ReadyFlash", "OVERLAY")
    button.readyFlash:SetAllPoints(button.readyFlashHolder)
    button.readyFlash:SetTexture("Interface\\Buttons\\WHITE8X8")
    button.readyFlash:SetBlendMode("ADD")
    button.readyFlash:SetVertexColor(1.00, 0.90, 0.35, 0.75)
    if button.readyFlash.SetDrawLayer then
        button.readyFlash:SetDrawLayer("OVERLAY", 5)
    end
    JoypadSetAlphaIfChanged(button.readyFlash, 0)
    JoypadHideIfShown(button.readyFlash)

    button.altParts = {}
    for partIndex = 1, 4 do
        local altPart = button:CreateFontString(name .. "AltPart" .. partIndex, "OVERLAY", "NumberFontNormalSmall")
        altPart:SetPoint("CENTER", button, "TOP", 0, 0)
        altPart:SetWidth(BUTTON_SIZE + 30)
        altPart:SetHeight(18)
        altPart:SetJustifyH("CENTER")
        altPart:SetJustifyV("MIDDLE")
        altPart:SetShadowColor(0, 0, 0, 1)
        altPart:SetShadowOffset(1, -1)
        if altPart.SetDrawLayer then
            altPart:SetDrawLayer("OVERLAY", 8)
        end
        altPart:Hide()
        button.altParts[partIndex] = altPart
    end
    ApplyAltPartsAppearance(button)

    button.hotkey = button:CreateFontString(name .. "HotKey", "OVERLAY", "NumberFontNormalLarge")
    do
        local fontPath, fontSize = NumberFontNormalLarge:GetFont()
        button.hotkey:SetFont(fontPath or "Fonts\\ARIALN.TTF", fontSize or 14, "THICKOUTLINE")
    end
    button.hotkey:SetPoint("BOTTOM", button, "BOTTOM", 0, 1)
    button.hotkey:SetWidth(BUTTON_SIZE + 18)
    button.hotkey:SetJustifyH("CENTER")
    button.hotkey:SetJustifyV("BOTTOM")
    button.hotkey:SetTextColor(1, 1, 1, 1)
    button.hotkey:SetShadowColor(0, 0, 0, 1)
    button.hotkey:SetShadowOffset(1, -1)
    if button.hotkey.SetDrawLayer then
        button.hotkey:SetDrawLayer("OVERLAY", 8)
    end

    button.macroText = button:CreateFontString(name .. "MacroText", "OVERLAY", "NumberFontNormalSmall")
    button.macroText:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.macroText:SetWidth(BUTTON_SIZE + 18)
    button.macroText:SetHeight(BUTTON_SIZE)
    button.macroText:SetJustifyH("CENTER")
    button.macroText:SetJustifyV("MIDDLE")
    button.macroText:SetTextColor(1, 1, 1, 1)
    button.macroText:SetShadowColor(0, 0, 0, 1)
    button.macroText:SetShadowOffset(1, -1)
    if button.macroText.SetDrawLayer then
        button.macroText:SetDrawLayer("OVERLAY", 4)
    end
    button.macroText:Hide()

    button.count = button:CreateFontString(name .. "Count", "OVERLAY", "NumberFontNormalSmall")
    button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
    button.count:SetJustifyH("RIGHT")
    button.count:SetTextColor(1, 1, 1, 1)
    button.count:SetShadowColor(0, 0, 0, 1)
    button.count:SetShadowOffset(1, -1)
    if button.count.SetDrawLayer then
        button.count:SetDrawLayer("OVERLAY", 8)
    end

    button:SetScript("OnEnter", OnEnter)
    button:SetScript("OnLeave", OnLeave)
    button:SetScript("OnDragStart", PlaceOrPickupAction)
    button:SetScript("OnReceiveDrag", PlaceOrPickupAction)

    local overlay = CreateFrame("Button", name .. "EditOverlay", holder)
    overlay:SetWidth(BUTTON_SIZE)
    overlay:SetHeight(BUTTON_SIZE)
    overlay:SetFrameStrata("HIGH")
    overlay:SetFrameLevel(button:GetFrameLevel() + 20)
    overlay:EnableMouse(true)
    overlay:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    overlay:RegisterForDrag("LeftButton")
    overlay:EnableMouseWheel(true)
    overlay.ownerButton = button

    overlay.tint = overlay:CreateTexture(nil, "OVERLAY")
    overlay.tint:SetAllPoints(overlay)
    overlay.tint:SetTexture(1, 0.82, 0, 0.16)

    overlay.edgeTop = overlay:CreateTexture(nil, "OVERLAY")
    overlay.edgeTop:SetTexture(1, 0.82, 0, 0.85)
    overlay.edgeTop:SetHeight(1)
    overlay.edgeTop:SetPoint("TOPLEFT", overlay, "TOPLEFT", 0, 0)
    overlay.edgeTop:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", 0, 0)

    overlay.edgeBottom = overlay:CreateTexture(nil, "OVERLAY")
    overlay.edgeBottom:SetTexture(1, 0.82, 0, 0.85)
    overlay.edgeBottom:SetHeight(1)
    overlay.edgeBottom:SetPoint("BOTTOMLEFT", overlay, "BOTTOMLEFT", 0, 0)
    overlay.edgeBottom:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", 0, 0)

    overlay.edgeLeft = overlay:CreateTexture(nil, "OVERLAY")
    overlay.edgeLeft:SetTexture(1, 0.82, 0, 0.85)
    overlay.edgeLeft:SetWidth(1)
    overlay.edgeLeft:SetPoint("TOPLEFT", overlay, "TOPLEFT", 0, 0)
    overlay.edgeLeft:SetPoint("BOTTOMLEFT", overlay, "BOTTOMLEFT", 0, 0)

    overlay.edgeRight = overlay:CreateTexture(nil, "OVERLAY")
    overlay.edgeRight:SetTexture(1, 0.82, 0, 0.85)
    overlay.edgeRight:SetWidth(1)
    overlay.edgeRight:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", 0, 0)
    overlay.edgeRight:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", 0, 0)

    overlay:SetScript("OnEnter", function(selfOverlay)
        local owner = selfOverlay.ownerButton
        if GameTooltip and owner then
            GameTooltip:SetOwner(selfOverlay, "ANCHOR_RIGHT")
            GameTooltip:SetText("Joypad slot " .. tostring(owner.joypadSlot))
            GameTooltip:AddLine("Unlocked positioning mode", 1, 0.82, 0)
            GameTooltip:AddLine("Left-drag: move this button", 1, 1, 1)
            GameTooltip:AddLine("Mouse wheel: scale this button", 1, 1, 1)
            GameTooltip:AddLine("Right-click: set X/Y/Scale", 1, 1, 1)
            GameTooltip:AddLine("Group border: drag all slots together", 0.7, 0.7, 0.7)
            local x, y = GetSlotPosition(owner.joypadSlot)
            GameTooltip:AddLine("X " .. tostring(x) .. " / Y " .. tostring(y) .. " / Scale " .. tostring(GetSlotScale(owner.joypadSlot)) .. "%", 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end
    end)
    overlay:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    overlay:SetScript("OnClick", function(selfOverlay, mouseButton)
        local owner = selfOverlay.ownerButton
        if owner and mouseButton == "RightButton" then
            Joypad:OpenPositionPopup(owner.joypadSlot)
        end
    end)
    overlay:SetScript("OnMouseWheel", function(selfOverlay, delta)
        local owner = selfOverlay.ownerButton
        if owner and JoypadDB and JoypadDB.unlocked == true then
            Joypad:AdjustSlotScale(owner.joypadSlot, delta or 0)
        end
    end)
    overlay:SetScript("OnDragStart", function(selfOverlay)
        Joypad:StartDragButton(selfOverlay.ownerButton, selfOverlay)
    end)
    overlay:SetScript("OnDragStop", function(selfOverlay)
        Joypad:StopDragButton(selfOverlay)
    end)
    overlay:Hide()
    button.editOverlay = overlay

    JoypadApplyButtonTheme(button)

    Joypad.buttons[index] = button
    return button
end

local function LayoutButton(button, row, index)
    if not button then
        return
    end

    local x, y = GetSlotPosition(button.joypadSlot)
    local scale = GetSlotScale(button.joypadSlot) / 100

    button:SetWidth(BUTTON_SIZE)
    button:SetHeight(BUTTON_SIZE)
    if button.SetScale then
        button:SetScale(scale)
    end

    button:ClearAllPoints()
    button:SetPoint("CENTER", UIParent, "CENTER", x, y)

    PositionEditOverlay(button)

    if IsSlotEnabled(button.joypadSlot) then
        button:Show()
    else
        button:Hide()
    end
end

local function CreateButtonsOnce()
    if Joypad.created then
        return
    end

    local globalIndex = 1
    for _, barDef in ipairs(BAR_DEFS) do
        for i = 1, BUTTONS_PER_BAR do
            local button = CreateJoypadButton(globalIndex, barDef, i)
            LayoutButton(button, barDef.row, i)
            globalIndex = globalIndex + 1
        end
    end

    Joypad.created = true
end

function Joypad:GetStanceBarScale()
    EnsureDB()
    return Clamp(Round(tonumber(JoypadDB.stanceBarScale or JOYPAD_STANCE_DEFAULT_SCALE) or JOYPAD_STANCE_DEFAULT_SCALE), 25, 300)
end

function Joypad:GetStanceBarPosition()
    EnsureDB()
    local x = Round(tonumber(JoypadDB.stanceBarX or JOYPAD_STANCE_DEFAULT_X) or (JOYPAD_STANCE_DEFAULT_X or 0))
    local y = Round(tonumber(JoypadDB.stanceBarY or JOYPAD_STANCE_DEFAULT_Y) or (JOYPAD_STANCE_DEFAULT_Y or -460))
    return x, y
end

function Joypad:LayoutStanceEditOverlay()
    local overlay = self.stanceEditOverlay
    if not overlay or not self.stanceHolder then
        return
    end

    overlay:ClearAllPoints()
    overlay:SetAllPoints(self.stanceHolder)

    if overlay.label then
        local x, y = self:GetStanceBarPosition()
        overlay.label:SetText("Stance  X " .. tostring(x) .. " / Y " .. tostring(y) .. " / Scale " .. tostring(self:GetStanceBarScale()) .. "%")
    end
end

function Joypad:LayoutStanceBar()
    if not self.stanceHolder then
        return
    end

    EnsureDB()

    local scale = self:GetStanceBarScale() / 100
    local count = table.getn(JOYPAD_STANCE_ACTION_SLOTS or {})
    local gap = JOYPAD_STANCE_BUTTON_GAP or 3
    local width = (BUTTON_SIZE * count) + (gap * math.max(0, count - 1))
    local x, y = self:GetStanceBarPosition()

    self.stanceHolder:SetWidth(width)
    self.stanceHolder:SetHeight(BUTTON_SIZE)
    self.stanceHolder:ClearAllPoints()
    self.stanceHolder:SetPoint("CENTER", UIParent, "CENTER", x, y)
    if self.stanceHolder.SetScale then
        self.stanceHolder:SetScale(scale)
    end

    for index, button in ipairs(self.stanceButtons or {}) do
        button:ClearAllPoints()
        button:SetWidth(BUTTON_SIZE)
        button:SetHeight(BUTTON_SIZE)
        button:SetPoint("LEFT", self.stanceHolder, "LEFT", (index - 1) * (BUTTON_SIZE + gap), 0)
        JoypadApplyButtonTheme(button)
    end

    self:LayoutStanceEditOverlay()
end

function Joypad:PlaceOrPickupStanceAction(button)
    if not button or InCombat() then
        return
    end

    local actionSlot = tonumber(button.actionSlot)
    if not actionSlot then
        return
    end

    if CursorHasItem and CursorHasItem() then
        PlaceAction(actionSlot)
        ClearCursor()
    elseif CursorHasSpell and CursorHasSpell() then
        PlaceAction(actionSlot)
        ClearCursor()
    elseif CursorHasMacro and CursorHasMacro() then
        PlaceAction(actionSlot)
        ClearCursor()
    elseif PickupAction then
        PickupAction(actionSlot)
    end

    self:UpdateStanceButtonVisual(button)
end

function Joypad:UpdateStanceButtonVisual(button)
    if not button then
        return
    end

    local actionSlot = tonumber(button.actionSlot)
    local actionInfo = actionSlot and JoypadGetCachedActionSlotInfo and JoypadGetCachedActionSlotInfo(actionSlot) or nil
    local texture = actionInfo and actionInfo.texture or (actionSlot and GetActionTexture and GetActionTexture(actionSlot))
    local hasAction = actionInfo and actionInfo.hasAction or (actionSlot and HasAction and HasAction(actionSlot))

    if button.icon then
        if texture then
            JoypadSetTextureIfChanged(button.icon, texture)
            JoypadShowIfHidden(button.icon)
        else
            JoypadSetTextureIfChanged(button.icon, nil)
            JoypadHideIfShown(button.icon)
        end
    end

    JoypadSetAlphaIfChanged(button, hasAction and 1 or 0.45)

    if button.count then
        local count = actionInfo and actionInfo.count or 0
        if not actionInfo and actionSlot and GetActionCount then
            count = GetActionCount(actionSlot) or 0
        end
        if count and count > 1 then
            JoypadSetTextIfChanged(button.count, count)
            JoypadShowIfHidden(button.count)
        else
            JoypadSetTextIfChanged(button.count, "")
            JoypadHideIfShown(button.count)
        end
    end

    if button.cooldown and actionSlot and GetActionCooldown then
        local start, duration, enable = GetActionCooldown(actionSlot)
        SetCooldown(button.cooldown, start, duration, enable, actionSlot)
    elseif button.cooldown then
        SetCooldown(button.cooldown, 0, 0, 0, nil)
    end

    local actionActive = hasAction and Joypad.IsActionActive(actionSlot)

    if button.SetChecked then
        if actionActive then
            button:SetChecked(1)
        else
            button:SetChecked(0)
        end
    end

    Joypad.SetButtonActiveBorderShown(button, actionActive)
    Joypad.ApplyActionStateVisuals(button, actionSlot, texture, hasAction)

    JoypadApplyButtonTheme(button)
end

function Joypad:UpdateStanceBarVisuals()
    for _, button in ipairs(self.stanceButtons or {}) do
        self:UpdateStanceButtonVisual(button)
    end
end

function Joypad:CreateStanceBar()
    if self.stanceHolder then
        return
    end

    local frame = CreateFrame("Frame", "JoypadStanceHolder", UIParent)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(holder:GetFrameLevel() + 4)
    frame:Show()
    self.stanceHolder = frame
    self.stanceButtons = {}

    for index, actionSlot in ipairs(JOYPAD_STANCE_ACTION_SLOTS or {}) do
        local name = "JoypadStanceButton" .. tostring(index)
        local button = CreateFrame("CheckButton", name, frame, "SecureActionButtonTemplate")
        button:SetWidth(BUTTON_SIZE)
        button:SetHeight(BUTTON_SIZE)
        button:SetFrameStrata("MEDIUM")
        button:SetFrameLevel(frame:GetFrameLevel() + 5)
        button:RegisterForClicks("AnyUp")
        button:RegisterForDrag("LeftButton")
        button:EnableMouse(true)
        button:SetScript("PostClick", function(selfButton, mouseButton)
            if Joypad and Joypad.LogButtonInput then
                Joypad:LogButtonInput(selfButton, mouseButton, "touchbar")
            end
        end)
        button.actionSlot = actionSlot
        button.stanceIndex = index
        button:SetAttribute("type", "action")
        button:SetAttribute("action", actionSlot)
        button:SetAttribute("type1", "action")
        button:SetAttribute("action1", actionSlot)

        button.icon = button:CreateTexture(name .. "Icon", "ARTWORK")
        button.icon:SetAllPoints(button)
        button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        button.cooldown = CreateFrame("Cooldown", name .. "Cooldown", button, "CooldownFrameTemplate")
        button.cooldown:SetAllPoints(button.icon)
        button.cooldown.ownerButton = button

        button.cooldownTextHolder = CreateFrame("Frame", nil, button)
        button.cooldownTextHolder:SetAllPoints(button)
        button.cooldownTextHolder:SetFrameStrata(button:GetFrameStrata())
        button.cooldownTextHolder:SetFrameLevel(button:GetFrameLevel() + 10)

        button.cooldownText = button.cooldownTextHolder:CreateFontString(name .. "CooldownText", "OVERLAY", "NumberFontNormalLarge")
        do
            local fontPath, fontSize = NumberFontNormalLarge:GetFont()
            button.cooldownText:SetFont(fontPath or "Fonts\\ARIALN.TTF", fontSize or 18, "THICKOUTLINE")
        end
        button.cooldownText:SetPoint("CENTER", button.cooldownTextHolder, "CENTER", 0, 0)
        button.cooldownText:SetWidth(BUTTON_SIZE + 18)
        button.cooldownText:SetHeight(24)
        button.cooldownText:SetJustifyH("CENTER")
        button.cooldownText:SetJustifyV("MIDDLE")
        button.cooldownText:SetTextColor(1, 1, 1, 1)
        button.cooldownText:SetShadowColor(0, 0, 0, 1)
        button.cooldownText:SetShadowOffset(1, -1)
        if button.cooldownText.SetDrawLayer then
            button.cooldownText:SetDrawLayer("OVERLAY", 6)
        end
        button.cooldownText:Hide()

        button.readyFlashHolder = CreateFrame("Frame", nil, button)
        button.readyFlashHolder:SetAllPoints(button)
        button.readyFlashHolder:SetFrameStrata(button:GetFrameStrata())
        button.readyFlashHolder:SetFrameLevel(button:GetFrameLevel() + 9)

        button.readyFlash = button.readyFlashHolder:CreateTexture(name .. "ReadyFlash", "OVERLAY")
        button.readyFlash:SetAllPoints(button.readyFlashHolder)
        button.readyFlash:SetTexture("Interface\\Buttons\\WHITE8X8")
        button.readyFlash:SetBlendMode("ADD")
        button.readyFlash:SetVertexColor(1.00, 0.90, 0.35, 0.75)
        if button.readyFlash.SetDrawLayer then
            button.readyFlash:SetDrawLayer("OVERLAY", 5)
        end
        JoypadSetAlphaIfChanged(button.readyFlash, 0)
        JoypadHideIfShown(button.readyFlash)

        button.count = button:CreateFontString(name .. "Count", "OVERLAY", "NumberFontNormalSmall")
        button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
        button.count:SetJustifyH("RIGHT")
        button.count:SetTextColor(1, 1, 1, 1)
        button.count:SetShadowColor(0, 0, 0, 1)
        button.count:SetShadowOffset(1, -1)
        if button.count.SetDrawLayer then
            button.count:SetDrawLayer("OVERLAY", 8)
        end

        button:SetScript("OnEnter", function(selfButton)
            if GameTooltip then
                GameTooltip:SetOwner(selfButton, "ANCHOR_RIGHT")
                if selfButton.actionSlot and HasAction and HasAction(selfButton.actionSlot) and GameTooltip.SetAction then
                    GameTooltip:SetAction(selfButton.actionSlot)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("Stance slot " .. tostring(selfButton.stanceIndex) .. " / action slot " .. tostring(selfButton.actionSlot), 0.7, 0.7, 0.7)
                else
                    GameTooltip:SetText("Stance slot " .. tostring(selfButton.stanceIndex))
                    GameTooltip:AddLine("Action slot " .. tostring(selfButton.actionSlot), 0.7, 0.7, 0.7)
                    GameTooltip:AddLine("No spell, item, or macro in this slot.", 0.7, 0.7, 0.7)
                end
                GameTooltip:Show()
            end
        end)
        button:SetScript("OnLeave", function()
            if GameTooltip then
                GameTooltip:Hide()
            end
        end)
        button:SetScript("OnDragStart", function(selfButton)
            Joypad:PlaceOrPickupStanceAction(selfButton)
        end)
        button:SetScript("OnReceiveDrag", function(selfButton)
            Joypad:PlaceOrPickupStanceAction(selfButton)
        end)

        JoypadApplyButtonTheme(button)
        self.stanceButtons[index] = button
    end

    self:CreateStanceEditOverlay()
    self:LayoutStanceBar()
    self:UpdateStanceBarVisuals()
end

function Joypad:CreateStanceEditOverlay()
    if self.stanceEditOverlay or not self.stanceHolder then
        return
    end

    local overlay = CreateFrame("Button", "JoypadStanceEditOverlay", self.stanceHolder)
    overlay:SetFrameStrata("HIGH")
    overlay:SetFrameLevel(self.stanceHolder:GetFrameLevel() + 40)
    overlay:EnableMouse(true)
    overlay:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    overlay:RegisterForDrag("LeftButton")
    overlay:EnableMouseWheel(true)
    overlay:Hide()

    overlay.tint = overlay:CreateTexture(nil, "OVERLAY")
    overlay.tint:SetAllPoints(overlay)
    overlay.tint:SetTexture(1, 0.82, 0, 0.11)

    overlay.edgeTop = overlay:CreateTexture(nil, "OVERLAY")
    overlay.edgeTop:SetTexture(1, 0.82, 0, 0.9)
    overlay.edgeTop:SetHeight(2)
    overlay.edgeTop:SetPoint("TOPLEFT", overlay, "TOPLEFT", 0, 0)
    overlay.edgeTop:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", 0, 0)

    overlay.edgeBottom = overlay:CreateTexture(nil, "OVERLAY")
    overlay.edgeBottom:SetTexture(1, 0.82, 0, 0.9)
    overlay.edgeBottom:SetHeight(2)
    overlay.edgeBottom:SetPoint("BOTTOMLEFT", overlay, "BOTTOMLEFT", 0, 0)
    overlay.edgeBottom:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", 0, 0)

    overlay.edgeLeft = overlay:CreateTexture(nil, "OVERLAY")
    overlay.edgeLeft:SetTexture(1, 0.82, 0, 0.9)
    overlay.edgeLeft:SetWidth(2)
    overlay.edgeLeft:SetPoint("TOPLEFT", overlay, "TOPLEFT", 0, 0)
    overlay.edgeLeft:SetPoint("BOTTOMLEFT", overlay, "BOTTOMLEFT", 0, 0)

    overlay.edgeRight = overlay:CreateTexture(nil, "OVERLAY")
    overlay.edgeRight:SetTexture(1, 0.82, 0, 0.9)
    overlay.edgeRight:SetWidth(2)
    overlay.edgeRight:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", 0, 0)
    overlay.edgeRight:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", 0, 0)

    overlay.label = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    overlay.label:SetPoint("BOTTOM", overlay, "TOP", 0, 3)
    overlay.label:SetTextColor(1, 0.82, 0, 1)
    overlay.label:SetShadowColor(0, 0, 0, 1)
    overlay.label:SetShadowOffset(1, -1)
    overlay.label:SetText("Stance")

    overlay:SetScript("OnEnter", function(selfOverlay)
        if GameTooltip then
            local x, y = Joypad:GetStanceBarPosition()
            GameTooltip:SetOwner(selfOverlay, "ANCHOR_RIGHT")
            GameTooltip:SetText("Touch Bar")
            GameTooltip:AddLine("Unlocked positioning mode", 1, 0.82, 0)
            GameTooltip:AddLine("Left-drag: move Touch Bar", 1, 1, 1)
            GameTooltip:AddLine("Mouse wheel: scale Touch Bar", 1, 1, 1)
            GameTooltip:AddLine("Right-click: set X/Y/Scale", 1, 1, 1)
            GameTooltip:AddLine("X " .. tostring(x) .. " / Y " .. tostring(y) .. " / Scale " .. tostring(Joypad:GetStanceBarScale()) .. "%", 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end
    end)
    overlay:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    overlay:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            Joypad:OpenStancePopup()
        end
    end)
    overlay:SetScript("OnMouseWheel", function(_, delta)
        Joypad:AdjustStanceBarScale(delta or 0)
    end)
    overlay:SetScript("OnDragStart", function(selfOverlay)
        Joypad:StartDragStanceBar(selfOverlay)
    end)
    overlay:SetScript("OnDragStop", function(selfOverlay)
        Joypad:StopDragStanceBar(selfOverlay)
    end)

    self.stanceEditOverlay = overlay
end

function Joypad:ShowStanceEditOverlay()
    self:CreateStanceEditOverlay()
    if not self.stanceEditOverlay then
        return
    end

    self:LayoutStanceEditOverlay()
    self.stanceEditOverlay:Show()
end

function Joypad:HideStanceEditOverlay()
    if self.stanceEditOverlay then
        self.stanceEditOverlay:Hide()
        self.stanceEditOverlay:SetScript("OnUpdate", nil)
    end
end

function Joypad:SetStanceBarVisible(visible, silent)
    EnsureDB()
    visible = visible and true or false
    JoypadDB.stanceBarVisible = visible

    if InCombat() then
        self.pendingStanceVisibility = true
        if not silent then
            Print("Touch Bar visibility update queued until combat ends.")
        end
        UpdateSettingsControls()
        return
    end

    self:CreateStanceBar()
    if self.stanceHolder then
        if visible then
            self.stanceHolder:Show()
        else
            self.stanceHolder:Hide()
        end
    end

    UpdateSettingsControls()

    if not silent then
        Print("Touch Bar " .. (visible and "shown" or "hidden") .. ".")
    end
end

local function UpdateStancePopupFields()
    local popup = Joypad.stancePopup
    if not popup then
        return
    end

    local x, y = Joypad:GetStanceBarPosition()
    if popup.xBox and not popup.xBox:HasFocus() then
        popup.xBox:SetText(tostring(x))
    end
    if popup.yBox and not popup.yBox:HasFocus() then
        popup.yBox:SetText(tostring(y))
    end
    if popup.scaleBox and not popup.scaleBox:HasFocus() then
        popup.scaleBox:SetText(tostring(Joypad:GetStanceBarScale()))
    end
    if popup.stanceText then
        popup.stanceText:SetText("Touch Bar  X " .. tostring(x) .. " / Y " .. tostring(y) .. " / Scale " .. tostring(Joypad:GetStanceBarScale()) .. "%")
    end
end

function Joypad:SetStanceBarScale(scale, silent)
    EnsureDB()
    scale = Clamp(Round(tonumber(scale or JOYPAD_STANCE_DEFAULT_SCALE) or JOYPAD_STANCE_DEFAULT_SCALE), 25, 300)
    JoypadDB.stanceBarScale = scale

    if InCombat() then
        self.pendingStanceLayout = true
        if not silent then
            Print("Touch Bar scale update queued until combat ends.")
        end
        UpdateSettingsControls()
        return
    end

    self:CreateStanceBar()
    self:LayoutStanceBar()
    self:UpdateStanceBarVisuals()
    UpdateSettingsControls()
    UpdateStancePopupFields()

    if not silent then
        Print("Touch Bar scale set to " .. tostring(scale) .. "%.")
    end
end

function Joypad:AdjustStanceBarScale(wheelDelta)
    EnsureDB()

    if JoypadDB.unlocked ~= true then
        return
    end

    if InCombat() then
        Print("Touch Bar scaling is locked during combat.")
        return
    end

    local direction = 1
    if tonumber(wheelDelta or 0) < 0 then
        direction = -1
    end

    self:SetStanceBarScale(self:GetStanceBarScale() + (direction * 5), true)
end

function Joypad:SetStanceBarPosition(x, y, silent)
    EnsureDB()

    x = Round(tonumber(x or JOYPAD_STANCE_DEFAULT_X) or (JOYPAD_STANCE_DEFAULT_X or 0))
    y = Round(tonumber(y or JOYPAD_STANCE_DEFAULT_Y) or (JOYPAD_STANCE_DEFAULT_Y or -460))

    JoypadDB.stanceBarX = x
    JoypadDB.stanceBarY = y

    if InCombat() then
        self.pendingStanceLayout = true
        if not silent then
            Print("Touch Bar position update queued until combat ends.")
        end
        return
    end

    self:CreateStanceBar()
    self:LayoutStanceBar()
    UpdateStancePopupFields()

    if not silent then
        Print("Touch Bar moved to X " .. tostring(x) .. ", Y " .. tostring(y) .. ".")
    end
end

function Joypad:StartDragStanceBar(overlay)
    EnsureDB()

    if JoypadDB.unlocked ~= true or not overlay then
        return
    end

    if InCombat() then
        Print("Touch Bar positioning is locked during combat.")
        return
    end

    overlay:SetScript("OnUpdate", function()
        if not GetCursorPosition or not UIParent then
            return
        end

        local uiScale = UIParent:GetEffectiveScale() or 1
        local cursorX, cursorY = GetCursorPosition()
        cursorX = cursorX / uiScale
        cursorY = cursorY / uiScale

        local centerX, centerY = UIParent:GetCenter()
        if not centerX or not centerY then
            return
        end

        local targetX, targetY = JoypadSnapPointToGrid(cursorX - centerX, cursorY - centerY)
        Joypad:SetStanceBarPosition(targetX, targetY, true)
    end)
end

function Joypad:StopDragStanceBar(overlay)
    if overlay then
        overlay:SetScript("OnUpdate", nil)
    end
    UpdateStancePopupFields()
end

function Joypad:ResetStanceBarLayout(silent)
    EnsureDB()

    if InCombat() then
        if not silent then
            Print("Touch Bar reset is locked during combat.")
        end
        return
    end

    JoypadDB.stanceBarX = JOYPAD_STANCE_DEFAULT_X or 0
    JoypadDB.stanceBarY = JOYPAD_STANCE_DEFAULT_Y or -460
    JoypadDB.stanceBarScale = JOYPAD_STANCE_DEFAULT_SCALE or 70

    self:CreateStanceBar()
    self:LayoutStanceBar()
    self:UpdateStanceBarVisuals()
    UpdateSettingsControls()
    UpdateStancePopupFields()

    if not silent then
        Print("Touch Bar layout reset.")
    end
end

function Joypad:CreateStancePopup()
    if self.stancePopup then
        return
    end

    local frame = CreateFrame("Frame", "JoypadStancePositionPopup", UIParent)
    frame:SetWidth(330)
    frame:SetHeight(195)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(50)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(selfFrame) selfFrame:StartMoving() end)
    frame:SetScript("OnDragStop", function(selfFrame) selfFrame:StopMovingOrSizing() end)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    frame:Hide()

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -16)
    title:SetText("Touch Bar Position")

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

    frame.stanceText = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    frame.stanceText:SetPoint("TOP", title, "BOTTOM", 0, -10)
    frame.stanceText:SetWidth(240)
    frame.stanceText:SetJustifyH("CENTER")
    frame.stanceText:SetText("Touch Bar")

    local xLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    xLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 42, -68)
    xLabel:SetText("X")

    local yLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    yLabel:SetPoint("LEFT", xLabel, "LEFT", 90, 0)
    yLabel:SetText("Y")

    local scaleLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    scaleLabel:SetPoint("LEFT", xLabel, "LEFT", 180, 0)
    scaleLabel:SetText("Scale %")

    frame.xBox = CreateFrame("EditBox", "JoypadStancePositionPopupX", frame, "InputBoxTemplate")
    frame.xBox:SetWidth(68)
    frame.xBox:SetHeight(20)
    frame.xBox:SetPoint("TOPLEFT", xLabel, "BOTTOMLEFT", 0, -6)
    frame.xBox:SetAutoFocus(false)

    frame.yBox = CreateFrame("EditBox", "JoypadStancePositionPopupY", frame, "InputBoxTemplate")
    frame.yBox:SetWidth(68)
    frame.yBox:SetHeight(20)
    frame.yBox:SetPoint("TOPLEFT", yLabel, "BOTTOMLEFT", 0, -6)
    frame.yBox:SetAutoFocus(false)

    frame.scaleBox = CreateFrame("EditBox", "JoypadStancePositionPopupScale", frame, "InputBoxTemplate")
    frame.scaleBox:SetWidth(68)
    frame.scaleBox:SetHeight(20)
    frame.scaleBox:SetPoint("TOPLEFT", scaleLabel, "BOTTOMLEFT", 0, -6)
    frame.scaleBox:SetAutoFocus(false)

    local function ApplyStancePopupPosition()
        local x = tonumber(frame.xBox:GetText() or "")
        local y = tonumber(frame.yBox:GetText() or "")
        local scale = tonumber(frame.scaleBox:GetText() or "")

        if not x or not y or not scale then
            Print("enter numeric Stance X, Y, and Scale % values.")
            return
        end

        Joypad:SetStanceBarScale(scale, true)
        Joypad:SetStanceBarPosition(x, y, false)
        frame:Hide()
    end

    frame.xBox:SetScript("OnEnterPressed", ApplyStancePopupPosition)
    frame.yBox:SetScript("OnEnterPressed", ApplyStancePopupPosition)
    frame.scaleBox:SetScript("OnEnterPressed", ApplyStancePopupPosition)
    frame.xBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.yBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.scaleBox:SetScript("OnEscapePressed", function() frame:Hide() end)

    local apply = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    apply:SetWidth(72)
    apply:SetHeight(22)
    apply:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -24, 18)
    apply:SetText("Apply")
    apply:SetScript("OnClick", ApplyStancePopupPosition)

    local reset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    reset:SetWidth(72)
    reset:SetHeight(22)
    reset:SetPoint("RIGHT", apply, "LEFT", -8, 0)
    reset:SetText("Reset")
    reset:SetScript("OnClick", function()
        Joypad:ResetStanceBarLayout(true)
        UpdateStancePopupFields()
    end)

    self.stancePopup = frame
end

function Joypad:OpenStancePopup()
    EnsureDB()
    if JoypadDB.unlocked ~= true then
        return
    end

    self:CreateStancePopup()
    if not self.stancePopup then
        return
    end

    UpdateStancePopupFields()
    self.stancePopup:Show()
end

local function GetAngleRadians(angle)
    return (angle or 0) * math.pi / 180
end

local function Atan2(y, x)
    if math.atan2 then
        return math.atan2(y, x)
    end

    if x > 0 then
        return math.atan(y / x)
    elseif x < 0 and y >= 0 then
        return math.atan(y / x) + math.pi
    elseif x < 0 and y < 0 then
        return math.atan(y / x) - math.pi
    elseif x == 0 and y > 0 then
        return math.pi / 2
    elseif x == 0 and y < 0 then
        return -math.pi / 2
    end

    return 0
end

function Joypad:UpdateMinimapButtonPosition()
    if not self.minimapButton or not Minimap then
        return
    end

    EnsureDB()

    local angle = GetAngleRadians(JoypadDB.minimapAngle or 225)
    local radius = 80
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius

    self.minimapButton:ClearAllPoints()
    self.minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function Joypad:CreateMinimapButton()
    if self.minimapButton or not Minimap then
        return
    end

    EnsureDB()

    local button = CreateFrame("Button", "JoypadMinimapButton", Minimap)
    button:SetWidth(31)
    button:SetHeight(31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:EnableMouse(true)

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetWidth(20)
    background:SetHeight(20)
    background:SetPoint("CENTER", button, "CENTER", 0, 0)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\AddOns\\Joypad\\Textures\\JoypadIcon")
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    icon:SetTexCoord(0.00, 1.00, 0.00, 1.00)
    button.icon = icon

    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetWidth(53)
    overlay:SetHeight(53)
    overlay:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    button:SetScript("OnEnter", function(selfButton)
        if GameTooltip then
            GameTooltip:SetOwner(selfButton, "ANCHOR_LEFT")
            GameTooltip:SetText("Joypad")
            GameTooltip:AddLine("Left-click: show/hide bars", 1, 1, 1)
            GameTooltip:AddLine("Right-click: settings", 1, 1, 1)
            GameTooltip:AddLine("Drag: move minimap button", 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end
    end)

    button:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            Joypad:ToggleSettingsPanel()
        else
            Joypad:ToggleBars()
        end
    end)

    button:SetScript("OnDragStart", function(selfButton)
        selfButton:SetScript("OnUpdate", function()
            if not Minimap or not GetCursorPosition then
                return
            end

            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = UIParent and UIParent:GetEffectiveScale() or 1
            if scale and scale ~= 0 then
                px = px / scale
                py = py / scale
            end

            JoypadDB.minimapAngle = math.deg(Atan2(py - my, px - mx))
            Joypad:UpdateMinimapButtonPosition()
        end)
    end)

    button:SetScript("OnDragStop", function(selfButton)
        selfButton:SetScript("OnUpdate", nil)
        Joypad:UpdateMinimapButtonPosition()
    end)

    self.minimapButton = button
    self:UpdateMinimapButtonPosition()
end



local JOYPAD_BLANK_CURSOR_TEXTURE = "Interface\\AddOns\\Joypad\\Textures\\Cursor\\Blank"
local JOYPAD_POINTER_CURSOR_TEXTURE = "Interface\\Cursor\\Point"
JOYPAD_DIAMOND_CLIP_TEXTURE = "Interface\\AddOns\\Joypad\\Textures\\Diamond\\ClipMask"
JOYPAD_DIAMOND_BORDER_TEXTURE = "Interface\\AddOns\\Joypad\\Textures\\Diamond\\Border"
JOYPAD_DIAMOND_FILL_TEXTURE = "Interface\\AddOns\\Joypad\\Textures\\Diamond\\Fill"

local JOYPAD_UI_CURSOR_CONTROLS = {
    -- UI cursor input should follow Joypad's physical buttons, not Blizzard's
    -- old ACTIONBUTTON bindings.  The new default key pool binds keys to
    -- CLICK JoypadButtonX:LeftButton, so reading ACTIONBUTTON5/etc. leaves the
    -- UI cursor with no override bindings.  Keep the old ACTIONBUTTON commands
    -- as fallbacks for users who still have legacy/default bar binds.
    { name = "MoveUp",      bindingCommand = "CLICK JoypadButton5:LeftButton",  fallbackCommands = { "ACTIONBUTTON5" },  direction = "UP" },
    { name = "MoveLeft",    bindingCommand = "CLICK JoypadButton6:LeftButton",  fallbackCommands = { "ACTIONBUTTON6" },  direction = "LEFT" },
    { name = "MoveRight",   bindingCommand = "CLICK JoypadButton7:LeftButton",  fallbackCommands = { "ACTIONBUTTON7" },  direction = "RIGHT" },
    { name = "MoveDown",    bindingCommand = "CLICK JoypadButton8:LeftButton",  fallbackCommands = { "ACTIONBUTTON8" },  direction = "DOWN" },
    { name = "LeftClick",   bindingCommand = "CLICK JoypadButton1:LeftButton",  fallbackCommands = { "ACTIONBUTTON1" },  clickButton = "LeftButton" },
    { name = "BackClose",   bindingCommand = "CLICK JoypadButton2:LeftButton",  fallbackCommands = { "ACTIONBUTTON2" },  closeWindow = true },
    { name = "ScrollUp",    bindingCommand = "CLICK JoypadButton4:LeftButton",  fallbackCommands = { "ACTIONBUTTON4" },  scroll = -45 },
    { name = "ScrollDown",  bindingCommand = "CLICK JoypadButton3:LeftButton",  fallbackCommands = { "ACTIONBUTTON3" },  scroll = 45 },
    { name = "PageUp",      bindingCommand = "CLICK JoypadButton12:LeftButton", fallbackCommands = { "ACTIONBUTTON10" }, scroll = -180 },
    { name = "PageDown",    bindingCommand = "CLICK JoypadButton11:LeftButton", fallbackCommands = { "ACTIONBUTTON9" },  scroll = 180 },
}

local JOYPAD_UI_VISIBLE_PANEL_NAMES = {
    -- This is intentionally modelled on ConsolePort's default UIStack.
    "AddonList",
    "AudioOptionsFrame",
    "BagHelpBox",
    "BankFrame",
    "BasicScriptErrors",
    "CharacterFrame",
    "ChatConfigFrame",
    "ChatMenu",
    "CinematicFrameCloseDialog",
    "ContainerFrame1",
    "ContainerFrame2",
    "ContainerFrame3",
    "ContainerFrame4",
    "ContainerFrame5",
    "ContainerFrame6",
    "ContainerFrame7",
    "ContainerFrame8",
    "ContainerFrame9",
    "ContainerFrame10",
    "ContainerFrame11",
    "ContainerFrame12",
    "ContainerFrame13",
    "AdiBagsContainer1",
    "AdiBagsContainer2",
    "AdiBagsContainerBackpack",
    "AdiBagsContainerBank",
    "AdiBagsBackpack",
    "AdiBagsBank",
    "DressUpFrame",
    "DropDownList1",
    "DropDownList2",
    "FriendsFrame",
    "GameMenuFrame",
    "GossipFrame",
    "GuildInviteFrame",
    "InterfaceOptionsFrame",
    "ItemRefTooltip",
    "ItemTextFrame",
    "LFDRoleCheckPopup",
    "LFGDungeonReadyDialog",
    "LFGInvitePopup",
    "LootFrame",
    "MailFrame",
    "MerchantFrame",
    "OpenMailFrame",
    "PetitionFrame",
    "PVPReadyDialog",
    "QuestFrame",
    "QuestLogPopupDetailFrame",
    "RecruitAFriendFrame",
    "ReadyCheckFrame",
    "SpellBookFrame",
    "StackSplitFrame",
    "StaticPopup1",
    "StaticPopup2",
    "StaticPopup3",
    "StaticPopup4",
    "TaxiFrame",
    "HelpFrame",
    "HelpMenuFrame",
    "CoinPickupFrame",
    "PVPParentFrame",
    "QuestLogFrame",
    "LFDQueueFrame",
    "TimeManagerFrame",
    "TradeFrame",
    "TradeSkillFrame",
    "CraftFrame",
    "AuctionFrame",
    "ClassTrainerFrame",
    "MacroFrame",
    "VideoOptionsFrame",
    "WorldMapFrame",
    "GroupLootFrame1",
    "GroupLootFrame2",
    "GroupLootFrame3",
    "GroupLootFrame4",
    "AchievementFrame",
    "InspectFrame",
    "GuildFrame",
    "RaidParentFrame",
    "LFGParentFrame",
    "PVEFrame",
}

local JOYPAD_UI_CURSOR_PRIORITY_NODE_NAMES = {
    "GossipTitleButton1",
    "HonorFrameSoloQueueButton",
    "LFDQueueFrameFindGroupButton",
    "MerchantItem1ItemButton",
    "MerchantRepairAllButton",
    "InterfaceOptionsFrameCancel",
    "PaperDollSidebarTab3",
    "QuestFrameAcceptButton",
    "QuestFrameCompleteButton",
    "QuestFrameCompleteQuestButton",
    "QuestTitleButton1",
}

local JOYPAD_UI_CURSOR_IGNORE_NODE_NAMES = {
    "LootFrameCloseButton",
    "SpellFlyout",
    "WorldMapTitleButton",
    "MinimapZoomIn",
    "MinimapZoomOut",
}

local JOYPAD_UI_CURSOR_INCLUDE_CHILDREN_NAMES = {
    "DropDownList1",
    "DropDownList2",
}

local JOYPAD_UI_CURSOR_NAME_PATTERNS = {
    "Button$",
    "CloseButton$",
    "CancelButton$",
    "OkayButton$",
    "OKButton$",
    "AcceptButton$",
    "DeclineButton$",
    "CompleteButton$",
    "CreateButton$",
    "CreateAllButton$",
    "IncrementButton$",
    "DecrementButton$",
    "UpButton$",
    "DownButton$",
    "LeftButton$",
    "RightButton$",
    "Tab%d+$",
    "Slot$",
    "Slot%d+$",
    "Item%d+$",
    "Skill%d+$",
    "Recipe%d+$",
    "Entry%d+$",
    "CheckButton$",
    "CheckBox$",
    "DropDownButton$",
    "DropdownButton$",
    "ScrollBar$",
}

local JOYPAD_UI_STRATA_LEVELS = {
    BACKGROUND = 0,
    LOW = 10000,
    MEDIUM = 20000,
    HIGH = 30000,
    DIALOG = 40000,
    FULLSCREEN = 50000,
    FULLSCREEN_DIALOG = 60000,
    TOOLTIP = 70000,
}

local JOYPAD_UI_CURSOR_NODE = {
    cache = {},
    rects = {},
    usable = {
        Button = true,
        CheckButton = true,
        EditBox = true,
        Slider = true,
    },
    scalar = 3,
}

local JOYPAD_UI_CURSOR_STACK = {
    frames = {},
    visible = {},
    trackers = {},
    hooked = {},
    initialized = false,
}

local function JoypadFrameHasMethod(frame, methodName)
    if not frame or not methodName then
        return false
    end

    if pcall then
        local ok, method = pcall(function() return frame[methodName] end)
        return ok and type(method) == "function"
    end

    return type(frame[methodName]) == "function"
end

local function JoypadFrameCall(frame, methodName, ...)
    if not JoypadFrameHasMethod(frame, methodName) then
        return false, nil
    end
    return pcall(frame[methodName], frame, ...)
end

local function JoypadFrameIsShown(frame)
    if not frame then
        return false
    end

    local visible = true
    if JoypadFrameHasMethod(frame, "IsVisible") then
        local ok, result = JoypadFrameCall(frame, "IsVisible")
        visible = ok and result and true or false
    elseif JoypadFrameHasMethod(frame, "IsShown") then
        local ok, result = JoypadFrameCall(frame, "IsShown")
        visible = ok and result and true or false
    end

    if not visible then
        return false
    end

    if JoypadFrameHasMethod(frame, "GetPoint") then
        local ok, point = JoypadFrameCall(frame, "GetPoint")
        return ok and point and true or false
    end

    return true
end

local function JoypadFrameObjectType(frame)
    if JoypadFrameHasMethod(frame, "GetObjectType") then
        local ok, objectType = JoypadFrameCall(frame, "GetObjectType")
        if ok and objectType then
            return objectType
        end
    end

    if JoypadFrameHasMethod(frame, "IsObjectType") then
        for objectType in pairs(JOYPAD_UI_CURSOR_NODE.usable) do
            local ok, isType = JoypadFrameCall(frame, "IsObjectType", objectType)
            if ok and isType then
                return objectType
            end
        end
        local ok, isScroll = JoypadFrameCall(frame, "IsObjectType", "ScrollFrame")
        if ok and isScroll then
            return "ScrollFrame"
        end
    end

    return "Frame"
end

local function JoypadFrameIsObjectType(frame, objectType)
    if JoypadFrameHasMethod(frame, "IsObjectType") then
        local ok, result = JoypadFrameCall(frame, "IsObjectType", objectType)
        if ok then
            return result and true or false
        end
    end

    return JoypadFrameObjectType(frame) == objectType
end

local function JoypadFrameIsMouseEnabled(frame)
    local ok, enabled = JoypadFrameCall(frame, "IsMouseEnabled")
    return ok and enabled and true or false
end

local function JoypadGetFrameLevelScore(frame)
    local strata = "MEDIUM"
    local level = 0

    local okStrata, detectedStrata = JoypadFrameCall(frame, "GetFrameStrata")
    if okStrata and detectedStrata then
        strata = detectedStrata
    end

    local okLevel, detectedLevel = JoypadFrameCall(frame, "GetFrameLevel")
    if okLevel and detectedLevel then
        level = detectedLevel
    end

    return (JOYPAD_UI_STRATA_LEVELS[strata] or JOYPAD_UI_STRATA_LEVELS.MEDIUM) + (level or 0)
end

local function JoypadPointInRange(value, low, high)
    return value and low and high and value >= low and value <= high
end

local function JoypadFramesIntersect(a, b)
    if not a or not b or not JoypadFrameHasMethod(a, "GetLeft") or not JoypadFrameHasMethod(b, "GetLeft") then
        return false
    end

    local okAL, al = JoypadFrameCall(a, "GetLeft")
    local okAR, ar = JoypadFrameCall(a, "GetRight")
    local okAT, at = JoypadFrameCall(a, "GetTop")
    local okAB, ab = JoypadFrameCall(a, "GetBottom")
    local okBL, bl = JoypadFrameCall(b, "GetLeft")
    local okBR, br = JoypadFrameCall(b, "GetRight")
    local okBT, bt = JoypadFrameCall(b, "GetTop")
    local okBB, bb = JoypadFrameCall(b, "GetBottom")
    if not okAL or not okAR or not okAT or not okAB or not okBL or not okBR or not okBT or not okBB then
        return false
    end
    if not al or not ar or not at or not ab or not bl or not br or not bt or not bb then
        return false
    end

    return not (ar < bl or br < al or ab > bt or bb > at)
end

local function IsJoypadUICursorExcludedFrame(frame)
    if not JoypadFrameHasMethod(frame, "GetName") then
        return false
    end

    local okName, name = JoypadFrameCall(frame, "GetName")
    if not okName then
        name = nil
    end
    if not name then
        name = ""
    end

    if string.find(name, "^JoypadButton%d+$") then
        return true
    end
    if string.find(name, "^JoypadUICursor") then
        return true
    end
    if name == "JoypadHolder" or name == "JoypadGroupOverlay" or name == "JoypadRootOptionsPanel" or name == "JoypadAppearanceOptionsPanel" or name == "JoypadBindingsOptionsPanel" then
        return true
    end

    -- Game-world helper overlays are not menu/UI controls, so Joypad's UI
    -- cursor should never select or highlight them. Keep this generic so the
    -- UI cursor has no dependency on a particular client enhancement.
    local function IsWorldHelperName(n)
        n = tostring(n or "")
        if n == "" then return false end
        if string.find(n, "Crosshair") then return true end
        if string.find(n, "TargetCircle") then return true end
        if string.find(n, "WorldTarget") then return true end
        return false
    end

    if IsWorldHelperName(name) then
        return true
    end

    local function IsAdiBagsUnsafeName(n)
        n = tostring(n or "")
        if n == "" then return false end
        -- Do not exclude real AdiBags containers/buttons. Only skip helper
        -- tooltip/money/scanner frames that are not player-facing controls and
        -- have caused userdata/library errors on Wrath clients.
        if string.find(n, "^AdiBagsAQI") then return true end
        if string.find(n, "ScanTooltip") then return true end
        if string.find(n, "ScanningTooltip") then return true end
        if string.find(n, "Tooltip") then return true end
        if string.find(n, "MoneyFrame") then return true end
        return false
    end

    if IsAdiBagsUnsafeName(name) then
        return true
    end

    local parent = nil
    if JoypadFrameHasMethod(frame, "GetParent") then
        local okParent, detectedParent = JoypadFrameCall(frame, "GetParent")
        if okParent then parent = detectedParent end
    end
    local depth = 0
    while parent and depth < 12 do
        local parentName = nil
        if JoypadFrameHasMethod(parent, "GetName") then
            local okParentName, detectedParentName = JoypadFrameCall(parent, "GetName")
            if okParentName then parentName = detectedParentName end
        end
        if IsWorldHelperName(parentName) or IsAdiBagsUnsafeName(parentName) then
            return true
        end
        if JoypadFrameHasMethod(parent, "GetParent") then
            local okParent, detectedParent = JoypadFrameCall(parent, "GetParent")
            parent = okParent and detectedParent or nil
        else
            parent = nil
        end
        depth = depth + 1
    end

    return false
end

local function IsJoypadUICursorLikelyNamedControl(frame)
    if not JoypadFrameHasMethod(frame, "GetName") then
        return false
    end

    local okName, name = JoypadFrameCall(frame, "GetName")
    if not okName then
        name = nil
    end
    if not name or name == "" then
        return false
    end

    for _, pattern in ipairs(JOYPAD_UI_CURSOR_NAME_PATTERNS) do
        if string.find(name, pattern) then
            return true
        end
    end

    return false
end

local function JoypadApplyUICursorNodeFlags()
    for _, frameName in ipairs(JOYPAD_UI_CURSOR_PRIORITY_NODE_NAMES) do
        local frame = _G[frameName]
        if frame then
            frame.hasPriority = true
        end
    end

    for _, frameName in ipairs(JOYPAD_UI_CURSOR_IGNORE_NODE_NAMES) do
        local frame = _G[frameName]
        if frame then
            frame.ignoreNode = true
        end
    end

    for _, frameName in ipairs(JOYPAD_UI_CURSOR_INCLUDE_CHILDREN_NAMES) do
        local frame = _G[frameName]
        if frame then
            frame.includeChildren = true
        end
    end
end

local function JoypadUpdateUICursorStackVisible(frame)
    if frame and JOYPAD_UI_CURSOR_STACK.frames[frame] then
        JOYPAD_UI_CURSOR_STACK.visible[frame] = JoypadFrameIsShown(frame) and true or nil
    end
end

local function JoypadAddUICursorFrame(frameOrName)
    local frame = nil

    if type(frameOrName) == "string" then
        frame = _G[frameOrName]
    else
        frame = frameOrName
    end

    if frame and JoypadFrameHasMethod(frame, "GetChildren") and (JoypadFrameHasMethod(frame, "IsVisible") or JoypadFrameHasMethod(frame, "IsShown")) then
        if not JOYPAD_UI_CURSOR_STACK.frames[frame] then
            JOYPAD_UI_CURSOR_STACK.frames[frame] = true

            if frame.HookScript and not JOYPAD_UI_CURSOR_STACK.hooked[frame] then
                frame:HookScript("OnShow", function(selfFrame)
                    JoypadUpdateUICursorStackVisible(selfFrame)
                    if Joypad and Joypad.UpdateUICursorActivation then
                        Joypad:UpdateUICursorActivation(false)
                    end
                end)
                frame:HookScript("OnHide", function(selfFrame)
                    JOYPAD_UI_CURSOR_STACK.visible[selfFrame] = nil
                    if Joypad and Joypad.UpdateUICursorActivation then
                        Joypad:UpdateUICursorActivation(false)
                    end
                end)
                JOYPAD_UI_CURSOR_STACK.hooked[frame] = true
            end
        end

        JoypadUpdateUICursorStackVisible(frame)
        return true
    end

    if frameOrName then
        JOYPAD_UI_CURSOR_STACK.trackers[frameOrName] = true
    end

    return false
end

local function JoypadInitializeUICursorFrameStack()
    if JOYPAD_UI_CURSOR_STACK.initialized then
        return
    end

    JOYPAD_UI_CURSOR_STACK.initialized = true

    for _, frameName in ipairs(JOYPAD_UI_VISIBLE_PANEL_NAMES) do
        JoypadAddUICursorFrame(frameName)
    end
end

local function JoypadUpdateUICursorFrameStack()
    JoypadInitializeUICursorFrameStack()
    JoypadApplyUICursorNodeFlags()

    if type(UISpecialFrames) == "table" then
        for _, frameName in ipairs(UISpecialFrames) do
            JoypadAddUICursorFrame(frameName)
        end
    end

    for frameOrName in pairs(JOYPAD_UI_CURSOR_STACK.trackers) do
        if JoypadAddUICursorFrame(frameOrName) then
            JOYPAD_UI_CURSOR_STACK.trackers[frameOrName] = nil
        end
    end

    for frame in pairs(JOYPAD_UI_CURSOR_STACK.frames) do
        JoypadUpdateUICursorStackVisible(frame)
    end

    if UIDROPDOWNMENU_OPEN_MENU and JoypadFrameIsShown(UIDROPDOWNMENU_OPEN_MENU) then
        JoypadAddUICursorFrame(UIDROPDOWNMENU_OPEN_MENU)
        JOYPAD_UI_CURSOR_STACK.visible[UIDROPDOWNMENU_OPEN_MENU] = true
    end
end

function JoypadTimerAfter(delay, callback)
    if C_Timer and C_Timer.After then
        C_Timer.After(delay, callback)
        return
    end

    local frame = CreateFrame("Frame")
    local elapsedTotal = 0
    frame:SetScript("OnUpdate", function(selfFrame, elapsed)
        elapsedTotal = elapsedTotal + elapsed
        if elapsedTotal >= delay then
            selfFrame:SetScript("OnUpdate", nil)
            callback()
        end
    end)
end

local function JoypadGetAdiBags()
    if LibStub then
        local ok, addon = pcall(function()
            return LibStub("AceAddon-3.0"):GetAddon("AdiBags", true)
        end)
        if ok and addon then
            return addon
        end
    end

    return _G.AdiBags
end

local function JoypadGetFrameName(frameOrName)
    if type(frameOrName) == "string" then
        return frameOrName
    end
    if JoypadFrameHasMethod(frameOrName, "GetName") then
        local okName, name = JoypadFrameCall(frameOrName, "GetName")
        if okName then
            return name
        end
    end
    return nil
end

-- v0.44.66: these AdiBags helper functions are intentionally
-- non-local to stay below Wrath Lua's 200-local-per-chunk limit.
function JoypadIsSafeAdiBagsRootName(name)
    name = tostring(name or "")
    if name == "" then return false end
    if string.find(name, "^AdiBagsContainerFrame%d+$") then return true end
    if string.find(name, "^AdiBagsItemContainer") then return true end
    if name == "AdiBagsBackpack" or name == "AdiBagsBank" then return true end
    return false
end

function JoypadRegisterAdiBagsFrame(frameOrName)
    if not frameOrName then
        return false
    end

    local name = JoypadGetFrameName(frameOrName)
    if type(frameOrName) == "string" then
        name = frameOrName
        frameOrName = _G[name] or frameOrName
    end
    name = tostring(name or "")

    if not JoypadIsSafeAdiBagsRootName(name) then
        -- Module frames are named AdiBagsContainerFrame# but keep a fallback for
        -- AdiBags fork variants that store logical .name = Backpack/Bank.
        local logical = nil
        if frameOrName and type(frameOrName) ~= "string" then
            local ok, value = pcall(function() return frameOrName.name end)
            if ok then logical = value end
        end
        if logical ~= "Backpack" and logical ~= "Bank" then
            return false
        end
    end

    local ok = JoypadAddUICursorFrame(frameOrName)
    if ok and Joypad and Joypad.UIDebugLog then
        Joypad:UIDebugLog("AdiBags root tracked: " .. tostring(name))
    end
    return ok
end

function JoypadRegisterAdiBagsModuleFrame(addon, moduleName)
    if not addon or type(moduleName) ~= "string" then
        return false
    end

    local module = nil
    if addon.GetModule then
        local ok, result = pcall(function() return addon:GetModule(moduleName, true) end)
        if ok then module = result end
    end

    if module and module.frame then
        return JoypadRegisterAdiBagsFrame(module.frame)
    end

    return false
end

function JoypadRegisterAdiBagsItemParentFrames(addon)
    if not addon then
        return 0
    end

    local count = 0
    local ok, parents = pcall(function() return addon.itemParentFrames end)
    if ok and type(parents) == "table" then
        for _, frame in pairs(parents) do
            if JoypadRegisterAdiBagsFrame(frame) then
                count = count + 1
            end
        end
    end
    return count
end

function JoypadRegisterKnownAdiBagsFrames()
    local addon = JoypadGetAdiBags()

    -- Actual AdiBags container frames are created by OO.lua as:
    -- AdiBags + "ContainerFrame" + serial.
    for i = 1, 8 do
        JoypadRegisterAdiBagsFrame(_G["AdiBagsContainerFrame" .. tostring(i)] or ("AdiBagsContainerFrame" .. tostring(i)))
    end

    JoypadRegisterAdiBagsModuleFrame(addon, "Backpack")
    JoypadRegisterAdiBagsModuleFrame(addon, "Bank")
    JoypadRegisterAdiBagsItemParentFrames(addon)
end

function JoypadRegisterExistingAdiBagsGlobals()
    -- v0.44.64: intentionally disabled. The AdiBags source shows real roots
    -- are AdiBagsContainerFrame# plus addon.itemParentFrames; scanning every
    -- AdiBags* global can pull in scan-tooltip/money/userdata helper frames.
    return
end

function JoypadSafeFrameField(frame, field)
    if not frame or not field then
        return nil
    end
    if pcall then
        local ok, value = pcall(function() return frame[field] end)
        if ok then
            return value
        end
        return nil
    end
    return frame[field]
end

function JoypadIsAdiBagsNode(node)
    if not node or not JoypadFrameHasMethod(node, "GetParent") then
        return false
    end

    local parent = node
    local hasAdiBagsParent = false
    for i = 1, 10 do
        if not JoypadFrameHasMethod(parent, "GetParent") then
            break
        end

        local okParent, detectedParent = JoypadFrameCall(parent, "GetParent")
        parent = okParent and detectedParent or nil
        if not parent then
            break
        end

        local parentName = nil
        if JoypadFrameHasMethod(parent, "GetName") then
            local okParentName, detectedParentName = JoypadFrameCall(parent, "GetName")
            if okParentName then parentName = detectedParentName end
        end
        if parentName and string.find(tostring(parentName), "AdiBags") then
            hasAdiBagsParent = true
            break
        end
    end

    if not hasAdiBagsParent then
        return false
    end

    local objectType = JoypadFrameObjectType(node)
    local nodeName = nil
    if JoypadFrameHasMethod(node, "GetName") then
        local okName, detectedName = JoypadFrameCall(node, "GetName")
        if okName then nodeName = detectedName end
    end
    nodeName = tostring(nodeName or "")

    -- Allow actual item/buttons/controls inside the known AdiBags root only.
    if objectType == "Button" or objectType == "CheckButton" then
        return true
    end
    if string.find(nodeName, "Item") or string.find(nodeName, "Button") or string.find(nodeName, "Slot") then
        return true
    end
    if JoypadSafeFrameField(node, "bag") or JoypadSafeFrameField(node, "slot") or JoypadSafeFrameField(node, "itemId") or JoypadSafeFrameField(node, "itemID") then
        return true
    end

    return false
end

function JoypadHookAdiBagsFrameCreation()
    -- We deliberately avoid deep hooks. A light delayed refresh after bag events is
    -- enough to pick up known roots without touching internal AdiBags userdata.
    return true
end

function Joypad:RefreshAdiBagsCompatibility()
    JoypadRegisterKnownAdiBagsFrames()
    JoypadUpdateUICursorFrameStack()
    self:UpdateUICursorActivation(false)
end

function Joypad:SetupAdiBagsCompatibility()
    if self.adiBagsCompatStarted then
        return
    end

    self.adiBagsCompatStarted = true
    self:RefreshAdiBagsCompatibility()

    local frame = CreateFrame("Frame", "JoypadAdiBagsCompatibilityFrame", UIParent)
    frame.timer = 0
    frame.total = 0
    frame:RegisterEvent("ADDON_LOADED")
    frame:RegisterEvent("BAG_UPDATE")
    frame:RegisterEvent("BANKFRAME_OPENED")
    frame:RegisterEvent("BANKFRAME_CLOSED")
    frame:SetScript("OnEvent", function(selfFrame, event, addonName)
        if event == "ADDON_LOADED" and addonName ~= "AdiBags" then
            return
        end
        if JoypadTimerAfter then
            JoypadTimerAfter(0.25, function()
                if Joypad and Joypad.RefreshAdiBagsCompatibility then
                    Joypad:RefreshAdiBagsCompatibility()
                end
            end)
        elseif Joypad and Joypad.RefreshAdiBagsCompatibility then
            Joypad:RefreshAdiBagsCompatibility()
        end
    end)

    self.adiBagsCompatFrame = frame
end

local function IsJoypadUIPanelVisible()
    JoypadUpdateUICursorFrameStack()
    return next(JOYPAD_UI_CURSOR_STACK.visible) and true or false
end

local function GetJoypadUICursorPanelRoots()
    JoypadUpdateUICursorFrameStack()

    local roots, seen = {}, {}
    for frame in pairs(JOYPAD_UI_CURSOR_STACK.visible) do
        if frame and not seen[frame] and JoypadFrameIsShown(frame) then
            seen[frame] = true
            table.insert(roots, frame)
        end
    end

    return roots
end

local function JoypadUINodeIsRelevant(node)
    return node and not node.ignoreNode and JoypadFrameIsShown(node) and not IsJoypadUICursorExcludedFrame(node)
end

local function JoypadUINodeIsTree(node)
    return node and not node.ignoreChildren
end

local function JoypadUINodeIsMouseEvent(node)
    if not JoypadFrameHasMethod(node, "GetScript") then
        return false
    end
    local okEnter, onEnter = JoypadFrameCall(node, "GetScript", "OnEnter")
    local okDown, onMouseDown = JoypadFrameCall(node, "GetScript", "OnMouseDown")
    local okUp, onMouseUp = JoypadFrameCall(node, "GetScript", "OnMouseUp")
    return ((okEnter and onEnter) or (okDown and onMouseDown) or (okUp and onMouseUp)) and true or false
end

local function JoypadUINodeIsUsableObject(objectType)
    return JOYPAD_UI_CURSOR_NODE.usable[objectType] and true or false
end

local function JoypadUINodeIsInteractive(node, objectType)
    if not node or node.includeChildren then
        return false
    end

    return JoypadFrameIsMouseEnabled(node) and (JoypadUINodeIsUsableObject(objectType) or JoypadUINodeIsMouseEvent(node) or IsJoypadUICursorLikelyNamedControl(node) or JoypadIsAdiBagsNode(node))
end

local function JoypadUINodeGetSuperNode(super, node)
    if node and JoypadFrameIsObjectType(node, "ScrollFrame") then
        return node
    end
    return super
end

local function JoypadUINodeIsDrawn(node, super)
    if not node or not JoypadFrameHasMethod(node, "GetCenter") then
        return false
    end

    local okCenter, x, y = JoypadFrameCall(node, "GetCenter")
    if not okCenter then
        return false
    end
    local maxX = GetScreenWidth and GetScreenWidth() or 4096
    local maxY = GetScreenHeight and GetScreenHeight() or 4096

    if not JoypadPointInRange(x, 0, maxX) or not JoypadPointInRange(y, 0, maxY) then
        return false
    end

    local hasScrollChild = false
    if JoypadFrameHasMethod(super, "GetScrollChild") then
        local okScrollChild, scrollChild = JoypadFrameCall(super, "GetScrollChild")
        hasScrollChild = okScrollChild and scrollChild and true or false
    end
    if super and hasScrollChild and not JoypadFrameIsObjectType(node, "Slider") then
        if UIDoFramesIntersect then
            return UIDoFramesIntersect(node, super)
        end
        return JoypadFramesIntersect(node, super)
    end

    return true
end

local function JoypadUINodeCacheRect(node, level)
    local rects = JOYPAD_UI_CURSOR_NODE.rects
    local insertAt = table.getn(rects) + 1

    for i, rect in ipairs(rects) do
        if rect.level < level then
            insertAt = i
            break
        end
    end

    table.insert(rects, insertAt, { node = node, level = level })
end

local function JoypadUINodeCacheItem(node, objectType, super, level)
    JoypadUINodeCacheRect(node, level)

    local item = {
        node = node,
        object = objectType,
        super = super,
        level = level,
    }

    if node.hasPriority then
        table.insert(JOYPAD_UI_CURSOR_NODE.cache, 1, item)
    else
        table.insert(JOYPAD_UI_CURSOR_NODE.cache, item)
    end
end

local function JoypadUINodeCanLevelsIntersect(level1, level2)
    return level1 < level2
end

local function JoypadUINodeDoNodeAndRectIntersect(node, rect)
    if not node or not rect then
        return false
    end
    if UIDoFramesIntersect then
        return UIDoFramesIntersect(node, rect)
    end
    return JoypadFramesIntersect(node, rect)
end

local function JoypadUINodeScrubCache()
    local i = 1
    while i <= table.getn(JOYPAD_UI_CURSOR_NODE.cache) do
        local item = JOYPAD_UI_CURSOR_NODE.cache[i]
        local remove = false

        for _, rect in ipairs(JOYPAD_UI_CURSOR_NODE.rects) do
            if not JoypadUINodeCanLevelsIntersect(item.level, rect.level) then
                break
            end

            if rect.node ~= item.node and JoypadUINodeDoNodeAndRectIntersect(item.node, rect.node) then
                remove = true
                break
            end
        end

        if remove then
            table.remove(JOYPAD_UI_CURSOR_NODE.cache, i)
        else
            i = i + 1
        end
    end
end

local function JoypadUINodeClearCache()
    JOYPAD_UI_CURSOR_NODE.cache = {}
    JOYPAD_UI_CURSOR_NODE.rects = {}
end

local function JoypadUINodeScan(super, node, sibling, ...)
    if node and JoypadUINodeIsRelevant(node) then
        local objectType = JoypadFrameObjectType(node)
        local level = JoypadGetFrameLevelScore(node)

        if JoypadUINodeIsDrawn(node, super) then
            if JoypadUINodeIsInteractive(node, objectType) then
                JoypadUINodeCacheItem(node, objectType, super, level)
            elseif JoypadFrameIsMouseEnabled(node) then
                JoypadUINodeCacheRect(node, level)
            end
        end

        if JoypadUINodeIsTree(node) and JoypadFrameHasMethod(node, "GetChildren") then
            local ok, child1, child2, child3, child4, child5, child6, child7, child8, child9, child10 = pcall(node.GetChildren, node)
            if ok then
                JoypadUINodeScan(JoypadUINodeGetSuperNode(super, node), child1, child2, child3, child4, child5, child6, child7, child8, child9, child10)
            end
        end
    end

    if sibling then
        JoypadUINodeScan(super, sibling, ...)
    end
end

local function JoypadUINodeRunScan(...)
    JoypadUINodeClearCache()
    JoypadUINodeScan(nil, ...)
    JoypadUINodeScrubCache()
    return JOYPAD_UI_CURSOR_NODE.cache
end

local function FrameBelongsToJoypadOpenUIPanel(frame, panelRoots)
    if not frame or type(panelRoots) ~= "table" then
        return false
    end

    for _, root in ipairs(panelRoots) do
        local current = frame
        while current do
            if current == root then
                return true
            end
            if not JoypadFrameHasMethod(current, "GetParent") then
                break
            end
            local okParent, parent = JoypadFrameCall(current, "GetParent")
            if not okParent then
                break
            end
            current = parent
        end
    end

    return false
end

local function FrameIsInsideJoypadOpenUIPanel(frame, panelRoots)
    if not frame or type(panelRoots) ~= "table" or not JoypadFrameHasMethod(frame, "GetCenter") then
        return false
    end

    local okCenter, x, y = JoypadFrameCall(frame, "GetCenter")
    if not okCenter or not x or not y then
        return false
    end

    for _, root in ipairs(panelRoots) do
        if root and JoypadFrameHasMethod(root, "GetLeft") and JoypadFrameHasMethod(root, "GetRight") and JoypadFrameHasMethod(root, "GetTop") and JoypadFrameHasMethod(root, "GetBottom") then
            local okLeft, left = JoypadFrameCall(root, "GetLeft")
            local okRight, right = JoypadFrameCall(root, "GetRight")
            local okTop, top = JoypadFrameCall(root, "GetTop")
            local okBottom, bottom = JoypadFrameCall(root, "GetBottom")
            if okLeft and okRight and okTop and okBottom and left and right and top and bottom then
                left = left - 12
                right = right + 12
                top = top + 12
                bottom = bottom - 12
                if x >= left and x <= right and y <= top and y >= bottom then
                    return true
                end
            end
        end
    end

    return false
end

local function FrameIsRelevantToJoypadOpenUIPanel(frame, panelRoots)
    return FrameBelongsToJoypadOpenUIPanel(frame, panelRoots) or FrameIsInsideJoypadOpenUIPanel(frame, panelRoots)
end

local function IsJoypadUICursorCompatibilityCandidate(frame)
    if not JoypadFrameIsShown(frame) then
        return false
    end
    if IsJoypadUICursorExcludedFrame(frame) then
        return false
    end

    local objectType = JoypadFrameObjectType(frame)
    if objectType == "Texture" or objectType == "FontString" then
        return false
    end

    local okWidth, width = JoypadFrameCall(frame, "GetWidth")
    local okHeight, height = JoypadFrameCall(frame, "GetHeight")
    if not okWidth then width = 0 end
    if not okHeight then height = 0 end
    if not width or not height or width < 6 or height < 6 or width > 360 or height > 360 then
        return false
    end

    local okCenter, centerX, centerY = JoypadFrameCall(frame, "GetCenter")
    if not okCenter or not centerX or not centerY then
        return false
    end

    return JoypadUINodeIsInteractive(frame, objectType) or JoypadIsAdiBagsNode(frame) or IsJoypadUICursorLikelyNamedControl(frame) or (width <= 96 and height <= 96)
end

function JoypadAddScopedCandidate(results, seen, frame)
    if not frame or seen[frame] then
        return false
    end

    if IsJoypadUICursorCompatibilityCandidate(frame) then
        seen[frame] = true
        table.insert(results, frame)
        return true
    end

    return false
end

function JoypadScanScopedChildrenForCandidates(results, seen, frame, depth)
    if not frame or depth > 8 then
        return
    end
    if not JoypadFrameIsShown(frame) then
        return
    end

    JoypadAddScopedCandidate(results, seen, frame)

    if not JoypadFrameHasMethod(frame, "GetChildren") then
        return
    end

    local ok, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 = pcall(frame.GetChildren, frame)
    if not ok then
        return
    end

    JoypadScanScopedChildrenForCandidates(results, seen, c1, depth + 1)
    JoypadScanScopedChildrenForCandidates(results, seen, c2, depth + 1)
    JoypadScanScopedChildrenForCandidates(results, seen, c3, depth + 1)
    JoypadScanScopedChildrenForCandidates(results, seen, c4, depth + 1)
    JoypadScanScopedChildrenForCandidates(results, seen, c5, depth + 1)
    JoypadScanScopedChildrenForCandidates(results, seen, c6, depth + 1)
    JoypadScanScopedChildrenForCandidates(results, seen, c7, depth + 1)
    JoypadScanScopedChildrenForCandidates(results, seen, c8, depth + 1)
    JoypadScanScopedChildrenForCandidates(results, seen, c9, depth + 1)
    JoypadScanScopedChildrenForCandidates(results, seen, c10, depth + 1)
end

function JoypadCollectScopedAdiBagsCandidates(results, seen, panelRoots)
    local found = 0
    if type(panelRoots) ~= "table" then
        return found
    end

    for _, root in ipairs(panelRoots) do
        local rootName = nil
        if JoypadFrameHasMethod(root, "GetName") then
            local okName, detectedName = JoypadFrameCall(root, "GetName")
            if okName then rootName = detectedName end
        end
        rootName = tostring(rootName or "")

        local logical = nil
        if root and type(root) ~= "string" then
            local ok, value = pcall(function() return root.name end)
            if ok then logical = value end
        end

        if (string.find(rootName, "^AdiBagsContainerFrame%d+$")
            or string.find(rootName, "^AdiBagsItemContainer")
            or logical == "Backpack" or logical == "Bank")
            and JoypadFrameIsShown(root) then
            local before = table.getn(results)
            JoypadScanScopedChildrenForCandidates(results, seen, root, 0)
            found = found + (table.getn(results) - before)
        end
    end

    return found
end

local function CollectJoypadCompatibilityCandidates(results, seen, panelRoots)
    -- v0.44.62: disabled. Walking _G for arbitrary addon frames is too risky on
    -- Wrath clients with userdata-heavy addons such as AdiBags.
    return
end

local function GetJoypadUICursorCandidates()
    local results = {}
    local seen = {}
    local panelRoots = GetJoypadUICursorPanelRoots()

    Joypad.uiCursorLastPanelRootCount = table.getn(panelRoots)
    Joypad.uiCursorLastRecursiveCandidateCount = 0
    Joypad.uiCursorLastGlobalSeen = 0
    Joypad.uiCursorLastGlobalVisible = 0
    Joypad.uiCursorLastGlobalRelevant = 0
    Joypad.uiCursorLastFallbackCandidates = 0
    Joypad.uiCursorLastAdiBagsCandidates = 0

    if table.getn(panelRoots) > 0 then
        local cache = JoypadUINodeRunScan(unpack(panelRoots))
        for _, item in ipairs(cache) do
            if item and item.node and not seen[item.node] then
                seen[item.node] = true
                table.insert(results, item.node)
            end
        end

        Joypad.uiCursorLastRecursiveCandidateCount = table.getn(results)
        Joypad.uiCursorLastAdiBagsCandidates = JoypadCollectScopedAdiBagsCandidates(results, seen, panelRoots)

        -- Compatibility fallback only when the ConsolePort-style recursive node scan found nothing.
        if table.getn(results) == 0 then
            CollectJoypadCompatibilityCandidates(results, seen, panelRoots)
        end
    elseif UIParent then
        -- v0.44.63: no open panel roots, no UI cursor candidates. Scanning the
        -- whole UIParent tree is too broad and can touch game-world/actiontarget
        -- helper frames from other addons.
        Joypad.uiCursorLastRecursiveCandidateCount = 0
    end

    Joypad.uiCursorLastCandidateCount = table.getn(results)
    Joypad.uiCursorLastRectCount = table.getn(JOYPAD_UI_CURSOR_NODE.rects)
    return results
end

local function GetJoypadFrameCenter(frame)
    local ok, x, y = JoypadFrameCall(frame, "GetCenter")
    if ok and x and y then
        return x, y
    end
    return nil, nil
end

local function IsJoypadUICursorSelectedValid()
    local frame = Joypad.uiCursorSelected
    return JoypadFrameIsShown(frame) and not IsJoypadUICursorExcludedFrame(frame)
end

local function GetJoypadDebugFrameName(frame)
    if not frame then
        return "nil"
    end

    local objectType = JoypadFrameObjectType(frame)
    local name = nil
    if JoypadFrameHasMethod(frame, "GetName") then
        local okName, detectedName = JoypadFrameCall(frame, "GetName")
        if okName then name = detectedName end
    end
    if name and name ~= "" then
        return tostring(name) .. " [" .. tostring(objectType) .. "]"
    end

    local parentName = nil
    local parent = nil
    if JoypadFrameHasMethod(frame, "GetParent") then
        local okParent, detectedParent = JoypadFrameCall(frame, "GetParent")
        if okParent then parent = detectedParent end
    end
    if JoypadFrameHasMethod(parent, "GetName") then
        local okParentName, detectedParentName = JoypadFrameCall(parent, "GetName")
        if okParentName then parentName = detectedParentName end
    end

    local x, y = GetJoypadFrameCenter(frame)
    if parentName and parentName ~= "" then
        return tostring(objectType) .. " under " .. tostring(parentName)
    end
    if x and y then
        return tostring(objectType) .. " @" .. tostring(math.floor(x + 0.5)) .. "," .. tostring(math.floor(y + 0.5))
    end

    return tostring(objectType)
end

local function GetJoypadVisiblePanelDebugList()
    local names = {}

    for _, frameName in ipairs(JOYPAD_UI_VISIBLE_PANEL_NAMES) do
        if JoypadFrameIsShown(_G[frameName]) then
            table.insert(names, frameName)
        end
    end

    if type(UIPanelWindows) == "table" then
        for frameName in pairs(UIPanelWindows) do
            if JoypadFrameIsShown(_G[frameName]) then
                local already = false
                for _, existing in ipairs(names) do
                    if existing == frameName then
                        already = true
                        break
                    end
                end
                if not already then
                    table.insert(names, frameName)
                end
            end
        end
    end

    if UIDROPDOWNMENU_OPEN_MENU and JoypadFrameIsShown(UIDROPDOWNMENU_OPEN_MENU) then
        table.insert(names, "UIDropDown")
    end

    if #names == 0 then
        return "none"
    end

    return table.concat(names, ", ")
end

local function GetJoypadUICursorScanDebugText()
    return "panels=" .. GetJoypadVisiblePanelDebugList()
        .. ", roots=" .. tostring(Joypad.uiCursorLastPanelRootCount or 0)
        .. ", recursive=" .. tostring(Joypad.uiCursorLastRecursiveCandidateCount or 0)
        .. ", adibags=" .. tostring(Joypad.uiCursorLastAdiBagsCandidates or 0)
        .. ", globalSeen=" .. tostring(Joypad.uiCursorLastGlobalSeen or 0)
        .. ", globalVisible=" .. tostring(Joypad.uiCursorLastGlobalVisible or 0)
        .. ", globalRelevant=" .. tostring(Joypad.uiCursorLastGlobalRelevant or 0)
        .. ", fallback=" .. tostring(Joypad.uiCursorLastFallbackCandidates or 0)
        .. ", candidates=" .. tostring(Joypad.uiCursorLastCandidateCount or 0)
end

function Joypad:CreateUICursorDebugWindow()
    if self.uiCursorDebugWindow or not UIParent then
        return
    end

    local frame = CreateFrame("Frame", "JoypadUICursorDebugWindow", UIParent)
    frame:SetWidth(470)
    frame:SetHeight(265)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(850)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(selfFrame)
        if selfFrame.StartMoving then
            selfFrame:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(selfFrame)
        if selfFrame.StopMovingOrSizing then
            selfFrame:StopMovingOrSizing()
        end
    end)

    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        frame:SetBackdropColor(0, 0, 0, 0.92)
        frame:SetBackdropBorderColor(0.0, 0.85, 1.0, 1.0)
    end

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -10)
    title:SetText("Joypad UI Cursor Debug")
    frame.title = title

    local close = CreateFrame("Button", "JoypadUICursorDebugCloseButton", frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)
    close:SetScript("OnClick", function()
        Joypad:SetUICursorDebugEnabled(false, false)
    end)
    frame.close = close

    local clear = CreateFrame("Button", "JoypadUICursorDebugClearButton", frame, "UIPanelButtonTemplate")
    clear:SetWidth(70)
    clear:SetHeight(20)
    clear:SetPoint("TOPRIGHT", close, "TOPLEFT", -6, -4)
    clear:SetText("Clear")
    clear:SetScript("OnClick", function()
        Joypad.uiCursorDebugLines = {}
        Joypad:UpdateUICursorDebugWindow()
    end)
    frame.clear = clear

    local hint = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    hint:SetWidth(440)
    hint:SetJustifyH("LEFT")
    hint:SetText("/joypad uidebug toggles this window. Logs only update when UI cursor controls are pressed.")
    frame.hint = hint

    local textFrame = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    textFrame:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -10)
    textFrame:SetWidth(444)
    textFrame:SetHeight(190)
    textFrame:SetJustifyH("LEFT")
    textFrame:SetJustifyV("TOP")
    textFrame:SetText("")
    frame.logText = textFrame

    frame:Hide()
    self.uiCursorDebugWindow = frame
end

function Joypad:UpdateUICursorDebugWindow()
    self:CreateUICursorDebugWindow()
    local frame = self.uiCursorDebugWindow
    if not frame or not frame.logText then
        return
    end

    local lines = self.uiCursorDebugLines or {}
    frame.logText:SetText(table.concat(lines, "\n"))
end

function Joypad:UIDebugLog(message)
    EnsureDB()
    if JoypadDB.uiCursorDebugEnabled ~= true then
        return
    end

    self.uiCursorDebugLines = self.uiCursorDebugLines or {}

    local stamp = ""
    if date then
        stamp = date("%H:%M:%S") .. " "
    end

    table.insert(self.uiCursorDebugLines, stamp .. tostring(message or ""))
    while #self.uiCursorDebugLines > 18 do
        table.remove(self.uiCursorDebugLines, 1)
    end

    self:UpdateUICursorDebugWindow()
    if self.uiCursorDebugWindow then
        self.uiCursorDebugWindow:Show()
    end

    if JoypadDB.uiCursorDebugChat ~= false then
        Print("UI debug: " .. tostring(message or ""))
    end
end

function Joypad:SetUICursorDebugEnabled(enabled, silent)
    EnsureDB()
    JoypadDB.uiCursorDebugEnabled = enabled and true or false

    self:CreateUICursorDebugWindow()
    if self.uiCursorDebugWindow then
        if JoypadDB.uiCursorDebugEnabled then
            self.uiCursorDebugWindow:Show()
        else
            self.uiCursorDebugWindow:Hide()
        end
    end

    if JoypadDB.uiCursorDebugEnabled then
        self.uiCursorDebugLines = self.uiCursorDebugLines or {}
        self:UIDebugLog("debug enabled; waiting for UI cursor button input")
    elseif not silent then
        Print("UI cursor debug disabled.")
    end

    if not silent and JoypadDB.uiCursorDebugEnabled then
        Print("UI cursor debug enabled.")
    end
end

function Joypad:ToggleUICursorDebug()
    EnsureDB()
    self:SetUICursorDebugEnabled(not JoypadDB.uiCursorDebugEnabled, false)
end

function Joypad:CreateUICursorHighlight()
    if self.uiCursorHighlight then
        return
    end

    local frame = CreateFrame("Frame", "JoypadUICursorHighlight", UIParent)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(900)
    frame:SetWidth(32)
    frame:SetHeight(32)
    frame:Hide()

    if frame.SetBackdrop then
        frame:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 14,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        frame:SetBackdropBorderColor(0.0, 0.85, 1.0, 1.0)
    end

    self.uiCursorHighlight = frame
    self:ApplyUICursorClassColor()
end

function Joypad:ApplyUICursorClassColor()
    local r, g, b, a = JoypadGetPlayerClassColor()

    if self.uiCursorHighlight and self.uiCursorHighlight.SetBackdropBorderColor then
        self.uiCursorHighlight:SetBackdropBorderColor(r, g, b, a)
    end

    if self.uiCursorPointer then
        if self.uiCursorPointer.texture then
            self.uiCursorPointer.texture:SetVertexColor(r, g, b, a)
        end
        if self.uiCursorPointer.glyph then
            self.uiCursorPointer.glyph:SetTextColor(r, g, b, a)
        end
    end
end

function Joypad:CreateUICursorPointer()
    if self.uiCursorPointer then
        return
    end

    local pointer = CreateFrame("Frame", "JoypadUICursorPointer", UIParent)
    pointer:SetFrameStrata("TOOLTIP")
    pointer:SetFrameLevel(910)
    pointer:SetWidth(34)
    pointer:SetHeight(34)
    pointer:EnableMouse(false)

    local texture = pointer:CreateTexture(nil, "OVERLAY")
    texture:SetTexture(JOYPAD_POINTER_CURSOR_TEXTURE)
    texture:SetAllPoints(pointer)
    texture:SetTexCoord(0, 1, 0, 1)
    pointer.texture = texture

    local shadow = pointer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    shadow:SetPoint("CENTER", pointer, "CENTER", 2, -2)
    shadow:SetTextColor(0, 0, 0, 0.95)
    shadow:SetText(">")
    pointer.shadow = shadow

    local glyph = pointer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    glyph:SetPoint("CENTER", pointer, "CENTER", 0, 0)
    glyph:SetText(">")
    pointer.glyph = glyph

    pointer:Hide()
    self.uiCursorPointer = pointer
    self:ApplyUICursorClassColor()
end

function Joypad:HideHardwareCursor(reason)
    if not SetCursor then
        return
    end

    reason = tostring(reason or "generic")
    self.hardwareCursorHiddenReasons = self.hardwareCursorHiddenReasons or {}
    self.hardwareCursorHiddenReasons[reason] = true

    if self.uiCursorHardwareHidden then
        return
    end

    local ok = pcall(SetCursor, JOYPAD_BLANK_CURSOR_TEXTURE)
    if ok then
        self.uiCursorHardwareHidden = true
    end
end

function Joypad:RestoreHardwareCursor(reason)
    if reason and self.hardwareCursorHiddenReasons then
        self.hardwareCursorHiddenReasons[tostring(reason)] = nil
    elseif not reason then
        self.hardwareCursorHiddenReasons = {}
    end

    if self.hardwareCursorHiddenReasons then
        for _, active in pairs(self.hardwareCursorHiddenReasons) do
            if active then
                return
            end
        end
    end

    if not self.uiCursorHardwareHidden then
        return
    end

    if SetCursor then
        pcall(SetCursor, nil)
    end

    self.uiCursorHardwareHidden = nil
end

function Joypad:TryHideHardwareCursor()
    EnsureDB()

    if JoypadDB.uiCursorHideHardwareCursor ~= true then
        return
    end

    self:HideHardwareCursor("uiCursor")
end

function Joypad:IsSmartMouselookTriggerEnabled(trigger)
    EnsureDB()

    trigger = tostring(trigger or "move")
    if trigger == "move" or trigger == "turn" or trigger == "strafe" or trigger == "vertical" or trigger == "look" then
        return JoypadDB.smartMouselookOnMove ~= false
    elseif trigger == "target" then
        return JoypadDB.smartMouselookOnTarget ~= false
    elseif trigger == "spell" then
        return JoypadDB.smartMouselookOnSpell ~= false
    elseif trigger == "npc" then
        return JoypadDB.smartMouselookOnNPC == true
    elseif trigger == "quest" then
        return JoypadDB.smartMouselookOnQuest ~= false
    elseif trigger == "loot" then
        return JoypadDB.smartMouselookOnLoot ~= false
    elseif trigger == "jump" then
        return JoypadDB.smartMouselookOnJump == true
    elseif trigger == "center" then
        return JoypadDB.smartMouselookOnCenter == true
    end

    return true
end

function Joypad:SetSmartMouselookTrigger(trigger, enabled, silent)
    EnsureDB()

    trigger = tostring(trigger or "")
    enabled = enabled and true or false

    if trigger == "move" then JoypadDB.smartMouselookOnMove = enabled
    elseif trigger == "target" then JoypadDB.smartMouselookOnTarget = enabled
    elseif trigger == "spell" then JoypadDB.smartMouselookOnSpell = enabled
    elseif trigger == "npc" then JoypadDB.smartMouselookOnNPC = enabled
    elseif trigger == "quest" then JoypadDB.smartMouselookOnQuest = enabled
    elseif trigger == "loot" then JoypadDB.smartMouselookOnLoot = enabled
    elseif trigger == "jump" then JoypadDB.smartMouselookOnJump = enabled
    elseif trigger == "center" then JoypadDB.smartMouselookOnCenter = enabled
    end

    if not enabled then
        self:StopSmartMouselookReason(trigger)
    end

    UpdateSettingsControls()
    if self.NotifyAceOptionsChanged then
        self:NotifyAceOptionsChanged()
    end

    if not silent then
        Print("smart mouselook trigger " .. tostring(trigger) .. " " .. (enabled and "enabled." or "disabled."))
    end
end

function Joypad:CreateSmartMouselookBlocker()
    if self.smartMouselookBlocker then
        return
    end

    local blocker = CreateFrame("Button", "JoypadSmartMouselookBlocker", UIParent)
    blocker:SetAllPoints(UIParent)
    blocker:SetFrameStrata("FULLSCREEN_DIALOG")
    blocker:SetFrameLevel(999)
    blocker:EnableMouse(true)
    blocker:RegisterForClicks("AnyUp")
    blocker:SetScript("OnClick", function()
        if Joypad then
            Joypad:StopSmartMouselook()
        end
    end)
    blocker:Hide()
    self.smartMouselookBlocker = blocker
end

function Joypad:ShowSmartMouselookBlocker()
    EnsureDB()
    if JoypadDB.smartMouselookBlocker == false then
        return
    end
    self:CreateSmartMouselookBlocker()
    if self.smartMouselookBlocker then
        self.smartMouselookBlocker:Show()
    end
end

function Joypad:HideSmartMouselookBlocker()
    if self.smartMouselookBlocker then
        self.smartMouselookBlocker:Hide()
    end
end

function Joypad:IsSmartMouselookReasonActive()
    local reasons = self.smartMouselookReasons
    if type(reasons) ~= "table" then
        return false
    end

    for _, active in pairs(reasons) do
        if active then
            return true
        end
    end

    return false
end

function Joypad:IsSmartMouselookMovementReason(trigger)
    trigger = tostring(trigger or "")
    return trigger == "move" or trigger == "turn" or trigger == "strafe" or trigger == "vertical" or trigger == "look" or trigger == "jump"
end

function Joypad:IsRealMouselookActive()
    if IsMouselooking then
        local ok, active = pcall(IsMouselooking)
        return ok and active and true or false
    end
    return false
end

function Joypad:IsSmartMouselookModifierHeld()
    return (IsControlKeyDown and IsControlKeyDown()) or false
end

function JoypadHasAwesomeWotLKNameplates()
    return C_NamePlate and type(C_NamePlate.GetNamePlates) == "function"
end

-- AwesomeWotLK exposes real nameplateN unit tokens on every visible nameplate.
-- For Smart Mouselook hints we can approximate the old centre-of-view helper by
-- choosing the visible nameplate nearest the screen centre. This is display/
-- tooltip guidance only: it never changes the player's target and never drives
-- secure spell execution.
function JoypadGetAwesomeCenterNameplateUnit()
    if not JoypadHasAwesomeWotLKNameplates() or not UIParent then
        return nil
    end

    local okPlates, plates = pcall(C_NamePlate.GetNamePlates)
    if not okPlates or type(plates) ~= "table" then
        return nil
    end

    local centerX, centerY = nil, nil
    if UIParent.GetCenter then
        local okCenter, x, y = pcall(UIParent.GetCenter, UIParent)
        if okCenter then
            centerX, centerY = x, y
        end
    end
    if not centerX or not centerY then
        local width = (GetScreenWidth and GetScreenWidth()) or 1024
        local height = (GetScreenHeight and GetScreenHeight()) or 768
        centerX, centerY = width / 2, height / 2
    end

    -- Nameplates sit above the world unit, so bias the aim point slightly above
    -- exact screen centre. The acceptance radius is deliberately conservative;
    -- a selected target/mouseover remains the fallback if no plate is near aim.
    local screenHeight = 768
    if UIParent.GetHeight then
        local okHeight, uiHeight = pcall(UIParent.GetHeight, UIParent)
        if okHeight and uiHeight and uiHeight > 0 then screenHeight = uiHeight end
    end
    local aimY = centerY + math.max(45, screenHeight * 0.08)
    local radius = math.max(120, screenHeight * 0.20)
    local bestUnit, bestScore = nil, radius * radius

    for _, plate in pairs(plates) do
        local unit = plate and plate.unit
        if unit and UnitExists and UnitExists(unit) and plate.GetCenter then
            local shown = true
            if plate.IsShown then
                local okShown, isShown = pcall(plate.IsShown, plate)
                shown = okShown and isShown and true or false
            end
            if shown then
                local okCenter, x, y = pcall(plate.GetCenter, plate)
                if okCenter and x and y then
                    local dx = x - centerX
                    local dy = y - aimY
                    -- Horizontal alignment matters slightly more than vertical
                    -- because stacked nameplates can be displaced upward.
                    local score = (dx * dx * 1.35) + (dy * dy * 0.75)
                    if score < bestScore then
                        bestScore = score
                        bestUnit = unit
                    end
                end
            end
        end
    end

    return bestUnit
end

function Joypad:GetSmartMouselookTargetUnit()
    EnsureDB()

    if JoypadDB.smartMouselookPreferAwesomeTarget == true then
        local unit = JoypadGetAwesomeCenterNameplateUnit()
        if unit then
            return unit, "Aim nameplate"
        end
    end

    if JoypadDB.smartMouselookUseSelectedTarget == true and UnitExists and UnitExists("target") then
        return "target", "Selected target"
    end

    if UnitExists and UnitExists("mouseover") then
        return "mouseover", "Mouseover"
    end

    return nil, nil
end

function Joypad:GetSmartMouselookUnitHint(unit, sourceLabel)
    if not unit or not UnitExists or not UnitExists(unit) then
        return nil
    end

    local name = UnitName and UnitName(unit) or sourceLabel or "Target"
    if type(name) == "table" then
        name = name[1]
    end
    name = tostring(name or sourceLabel or "Target")

    local action = tostring(sourceLabel or "Target")
    if UnitIsDead and UnitIsDead(unit) then
        if UnitCanAttack and UnitCanAttack("player", unit) then
            action = "Dead / loot"
        else
            action = "Dead"
        end
    elseif UnitCanAttack and UnitCanAttack("player", unit) then
        action = "Attack"
    elseif UnitCanAssist and UnitCanAssist("player", unit) then
        action = "Friendly"
    elseif UnitIsPlayer and UnitIsPlayer(unit) then
        action = "Player"
    else
        action = "Interact"
    end

    if sourceLabel and sourceLabel ~= "" and sourceLabel ~= "Mouseover" then
        action = tostring(sourceLabel) .. " - " .. action
    end

    local detail = nil
    if UnitLevel then
        local level = UnitLevel(unit)
        if level and level > 0 then
            detail = "Level " .. tostring(level)
        elseif level and level < 0 then
            detail = "Boss"
        end
    end
    if UnitCreatureType then
        local creatureType = UnitCreatureType(unit)
        if creatureType and creatureType ~= "" then
            detail = detail and (detail .. " " .. tostring(creatureType)) or tostring(creatureType)
        end
    end

    if detail and detail ~= "" then
        action = action .. " - " .. detail
    end

    return name, action, unit
end

function Joypad:CreateSmartMouselookTestTooltip()
    if self.smartMouselookTestTooltipFrame then
        return
    end

    local frame = CreateFrame("Frame", "JoypadSmartMouselookTestTooltip", UIParent)
    frame:SetWidth(330)
    frame:SetHeight(104)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, -225)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(1200)
    frame:EnableMouse(false)

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetTexture(0, 0, 0, 0.86)
    frame.bg = bg

    local border = frame:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    border:SetTexture(1, 0.82, 0, 0.38)
    frame.border = border

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -8)
    title:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
    title:SetJustifyH("LEFT")
    title:SetText("Joypad test tooltip")
    frame.title = title

    local line1 = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    line1:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    line1:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
    line1:SetJustifyH("LEFT")
    line1:SetText("")
    frame.line1 = line1

    local line2 = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line2:SetPoint("TOPLEFT", line1, "BOTTOMLEFT", 0, -6)
    line2:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
    line2:SetJustifyH("LEFT")
    line2:SetText("")
    frame.line2 = line2

    local line3 = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line3:SetPoint("TOPLEFT", line2, "BOTTOMLEFT", 0, -5)
    line3:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
    line3:SetJustifyH("LEFT")
    line3:SetText("")
    frame.line3 = line3

    local line4 = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    line4:SetPoint("TOPLEFT", line3, "BOTTOMLEFT", 0, -5)
    line4:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
    line4:SetJustifyH("LEFT")
    line4:SetText("")
    frame.line4 = line4

    frame:Hide()
    self.smartMouselookTestTooltipFrame = frame
end

function Joypad:HideSmartMouselookTestTooltip()
    if self.smartMouselookTestTooltipFrame then
        self.smartMouselookTestTooltipFrame:Hide()
    end
end

function Joypad:UpdateSmartMouselookTestTooltip(elapsed, force)
    EnsureDB()

    if JoypadDB.smartMouselookTestTooltip ~= true then
        self:HideSmartMouselookTestTooltip()
        return
    end

    self.smartMouselookTestTooltipElapsed = (self.smartMouselookTestTooltipElapsed or 0) + (elapsed or 0)
    if not force and self.smartMouselookTestTooltipElapsed < 0.05 then
        return
    end
    self.smartMouselookTestTooltipElapsed = 0

    local awesomeAvailable = JoypadHasAwesomeWotLKNameplates() and true or false
    local aimUnit = JoypadGetAwesomeCenterNameplateUnit()
    local targetExists = UnitExists and UnitExists("target") and true or false
    local mouseExists = UnitExists and UnitExists("mouseover") and true or false
    local unit, sourceLabel = self:GetSmartMouselookTargetUnit()
    local name, action, chosenUnit = self:GetSmartMouselookMouseoverHint()

    self:CreateSmartMouselookTestTooltip()
    local frame = self.smartMouselookTestTooltipFrame
    if not frame then
        return
    end

    frame.title:SetText("Joypad test tooltip")
    if name then
        frame.line1:SetText(tostring(name))
        frame.line2:SetText(tostring(action or ""))
    else
        frame.line1:SetText("No Joypad target unit")
        frame.line2:SetText("Aim at a visible nameplate, select a target, or mouse over a unit.")
    end
    frame.line3:SetText("chosen=" .. tostring(chosenUnit or unit or "nil") .. " / awesome=" .. tostring(awesomeAvailable) .. " / aim=" .. tostring(aimUnit or "nil") .. " / target=" .. tostring(targetExists) .. " / mouseover=" .. tostring(mouseExists))
    frame.line4:SetText("Smart=" .. tostring(self.smartMouselookActive and true or false) .. "  Mouselook=" .. tostring(self:IsRealMouselookActive() and true or false))
    frame:Show()
end

function Joypad:SetSmartMouselookTestTooltip(enabled, silent)
    EnsureDB()

    JoypadDB.smartMouselookTestTooltip = enabled and true or false
    if not JoypadDB.smartMouselookTestTooltip then
        self:HideSmartMouselookTestTooltip()
    else
        self:UpdateSmartMouselookTestTooltip(0, true)
    end

    if self.NotifyAceOptionsChanged then
        self:NotifyAceOptionsChanged()
    end

    if not silent then
        Print(JoypadDB.smartMouselookTestTooltip and "Joypad test tooltip enabled." or "Joypad test tooltip disabled.")
    end
end


function JoypadRaidCursorNow()
    if GetTime then return GetTime() end
    return 0
end

function JoypadRaidCursorWallTime()
    if date then return date("%Y-%m-%d %H:%M:%S") end
    return tostring(JoypadRaidCursorNow())
end

function JoypadRaidCursorRound(value, digits)
    value = tonumber(value)
    if not value then return nil end
    local mult = 10 ^ (tonumber(digits or 0) or 0)
    return math.floor(value * mult + 0.5) / mult
end

function JoypadRaidCursorUnitHP(unit)
    if not unit or not UnitExists or not UnitExists(unit) then return nil end
    if not UnitHealth or not UnitHealthMax then return nil end
    local hp = tonumber(UnitHealth(unit) or 0) or 0
    local maxHP = tonumber(UnitHealthMax(unit) or 0) or 0
    if maxHP <= 0 then return nil end
    return JoypadRaidCursorRound((hp / maxHP) * 100, 1)
end

function JoypadRaidCursorUnitName(unit)
    if not unit or not UnitExists or not UnitExists(unit) or not UnitName then return nil end
    local name = UnitName(unit)
    if type(name) == "table" then name = name[1] end
    if name and tostring(name) ~= "" then return tostring(name) end
    return nil
end

function JoypadRaidCursorGroupCounts()
    local party = 0
    local raid = 0
    if GetNumPartyMembers then party = tonumber(GetNumPartyMembers() or 0) or 0 end
    if GetNumRaidMembers then raid = tonumber(GetNumRaidMembers() or 0) or 0 end
    return party, raid
end

function Joypad:IsRaidCursorRaidActive()
    local _, raid = JoypadRaidCursorGroupCounts()
    return raid and raid > 0
end

function JoypadRaidCursorInputLabel(input)
    input = tostring(input or "")
    if input == "13" then return "up" end
    if input == "14" then return "left" end
    if input == "15" then return "right" end
    if input == "16" then return "down" end
    if input == "1" then return "a-fallback" end
    if input == "0" then return "refresh" end
    return input
end

function JoypadRaidCursorCopySmall(data)
    if type(data) ~= "table" then return {} end
    local out = {}
    local count = 0
    for k, v in pairs(data) do
        count = count + 1
        if count > 64 then break end
        local tv = type(v)
        if tv == "string" or tv == "number" or tv == "boolean" or v == nil then
            out[k] = v
        else
            out[k] = tostring(v)
        end
    end
    return out
end

JOYPAD_RAID_STEER_DIRECTIONS = {
    up = { slot = 13, bindingCommand = "TARGETPARTYMEMBER1", label = "L^", shortLabel = "^" },
    left = { slot = 14, bindingCommand = "TARGETPARTYMEMBER2", label = "L<", shortLabel = "<" },
    right = { slot = 15, bindingCommand = "TARGETPARTYMEMBER3", label = "L>", shortLabel = ">" },
    down = { slot = 16, bindingCommand = "TARGETPARTYMEMBER4", label = "Lv", shortLabel = "v" },
}

function JoypadRaidSteeringIsRaidUnit(unit)
    unit = tostring(unit or "")
    return string.match(unit, "^raid%d+$") ~= nil
end

function JoypadRaidSteeringDistance(ax, ay, bx, by)
    ax = tonumber(ax or 0) or 0
    ay = tonumber(ay or 0) or 0
    bx = tonumber(bx or 0) or 0
    by = tonumber(by or 0) or 0
    local dx = ax - bx
    if dx < 0 then dx = -dx end
    local dy = ay - by
    if dy < 0 then dy = -dy end
    return dx + dy
end

function JoypadRaidSteeringGUIDFromUnitOrGUID(value)
    value = tostring(value or "")
    if value == "" then return nil end
    if string.find(value, "^0x") then return value end
    if UnitExists and UnitExists(value) and UnitGUID then
        return UnitGUID(value)
    end
    return nil
end

function Joypad:GetRaidUnitForGUID(guid)
    guid = tostring(guid or "")
    if guid == "" then return nil end
    for i = 1, 40 do
        local unit = "raid" .. tostring(i)
        if UnitExists and UnitExists(unit) and UnitGUID and UnitGUID(unit) == guid then
            return unit
        end
    end
    return nil
end

function Joypad:NormalizeRaidSteeringUnit(value)
    value = tostring(value or "")
    if value == "" then return nil end
    if JoypadRaidSteeringIsRaidUnit(value) and UnitExists and UnitExists(value) then
        return value
    end
    local guid = JoypadRaidSteeringGUIDFromUnitOrGUID(value)
    if guid then
        return self:GetRaidUnitForGUID(guid)
    end
    return nil
end

function Joypad:GetCurrentRaidCursorUnit()
    local cursor = self.raidCursor
    if cursor and cursor.GetAttribute then
        local ok, unit = pcall(function() return cursor:GetAttribute("cursorunit") end)
        if ok and unit then return tostring(unit) end
    end
    return nil
end

function Joypad:IsDecisionRaidHealCandidate(decision)
    if type(decision) ~= "table" then return false end
    if JoypadDB and JoypadDB.raidTargetSteeringEveryHeal ~= true then
        local urgent = decision.isUrgent or decision.selfPanic or decision.emergencyTargetTakeoverShown or decision.targetTakeoverUnit
        if not urgent then return false end
    end

    local role = tostring(decision.role or decision.context or "")
    if not string.find(role, "Healer", 1, true) and not string.find(role, "raid", 1, true) and not string.find(tostring(decision.context or ""), "raid", 1, true) then
        return false
    end

    local label = tostring(decision.mainLabel or decision.label or decision.spell or decision.bindSpell or decision.mainBindSpell or "")
    local bind = tostring(decision.mainBindSpell or decision.bindSpell or decision.cueSpell or decision.spell or decision.mainSpell or label)
    if label == "" and bind == "" then return false end
    if label == "Ready" or bind == "Ready" then return false end
    if tostring(decision.mainReason or decision.reason or "") == "No healing needed" then return false end

    if decision.targetCanAssist == false and not decision.healTargetUnit and not decision.triagePrimaryUnit and not decision.lowestUnit and not decision.expectedTargetUnit then
        return false
    end

    return true
end

function Joypad:GetRaidSteeringTargetFromDecision(decision)
    if type(decision) ~= "table" then return nil end
    if not self:IsDecisionRaidHealCandidate(decision) then return nil end

    local candidates = {
        decision.targetTakeoverUnit,
        decision.healTargetUnit,
        decision.triagePrimaryUnit,
        decision.targetLockUnit,
        decision.expectedTargetUnit,
        decision.lowestUnit,
        decision.targetUnit,
        decision.unit,
    }

    for _, unit in ipairs(candidates) do
        local raidUnit = self:NormalizeRaidSteeringUnit(unit)
        if raidUnit and UnitExists and UnitExists(raidUnit) and UnitCanAssist and UnitCanAssist("player", raidUnit) then
            return raidUnit
        end
    end

    local guidCandidates = {
        decision.targetTakeoverGUID,
        decision.healTargetGUID,
        decision.triagePrimaryGUID,
        decision.expectedTargetGUID,
        decision.lowestGUID,
        decision.targetGUID,
        decision.guid,
    }
    for _, guid in ipairs(guidCandidates) do
        local raidUnit = guid and self:GetRaidUnitForGUID(guid)
        if raidUnit and UnitExists and UnitExists(raidUnit) and UnitCanAssist and UnitCanAssist("player", raidUnit) then
            return raidUnit
        end
    end

    return nil
end

function JoypadRaidSteeringSafeFrameName(frame)
    if frame and frame.GetName then
        local ok, name = pcall(frame.GetName, frame)
        if ok and name then return tostring(name) end
    end
    return nil
end

function JoypadRaidSteeringAddNode(self, frame, nodes, byUnit)
    if not frame or not frame.GetAttribute or not frame.GetRect then return end
    local okUnit, unit = pcall(function() return frame:GetAttribute("unit") end)
    if not okUnit or not JoypadRaidSteeringIsRaidUnit(unit) then return end
    if not UnitExists or not UnitExists(unit) then return end
    if UnitCanAssist and not UnitCanAssist("player", unit) then return end

    local okVisible = true
    if frame.IsVisible then
        okVisible = pcall(function() return frame:IsVisible() end)
    elseif frame.IsShown then
        okVisible = pcall(function() return frame:IsShown() end)
    end
    if okVisible == false then return end

    local okRect, left, bottom, width, height = pcall(frame.GetRect, frame)
    if not okRect or not left or not bottom or not width or not height or width <= 0 or height <= 0 then return end

    if byUnit[unit] then return end
    local node = {
        frame = frame,
        frameName = JoypadRaidSteeringSafeFrameName(frame),
        unit = tostring(unit),
        x = left + width / 2,
        y = bottom + height / 2,
        width = width,
        height = height,
    }
    nodes[#nodes + 1] = node
    byUnit[node.unit] = node
end

function JoypadRaidSteeringScanFrame(self, frame, nodes, byUnit, visited, depth)
    if not frame or visited[frame] or depth > 7 then return end
    visited[frame] = true

    JoypadRaidSteeringAddNode(self, frame, nodes, byUnit)

    if frame.GetChildren then
        local ok, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 = pcall(frame.GetChildren, frame)
        if ok then
            local children = { c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 }
            for _, child in ipairs(children) do
                if child then
                    JoypadRaidSteeringScanFrame(self, child, nodes, byUnit, visited, depth + 1)
                end
            end
        end
    end
end

function Joypad:ScanRaidSteeringNodes(force)
    local now = GetTime and GetTime() or 0
    if not force and self._raidSteeringNodeCache and self._raidSteeringNodeCacheAt and (now - self._raidSteeringNodeCacheAt) < 0.15 then
        return self._raidSteeringNodeCache, self._raidSteeringNodeByUnit
    end

    local nodes = {}
    local byUnit = {}
    if UIParent then
        JoypadRaidSteeringScanFrame(self, UIParent, nodes, byUnit, {}, 0)
    end

    self._raidSteeringNodeCache = nodes
    self._raidSteeringNodeByUnit = byUnit
    self._raidSteeringNodeCacheAt = now
    return nodes, byUnit
end

function Joypad:ChooseRaidSteeringNode(currentNode, nodes, direction)
    if not currentNode or type(nodes) ~= "table" then return nil end

    local best, bestScore = nil, nil
    local thisX, thisY = currentNode.x or 0, currentNode.y or 0
    for _, node in ipairs(nodes) do
        if node and node ~= currentNode and node.unit then
            local dx = (node.x or 0) - thisX
            local dy = (node.y or 0) - thisY
            local adx = dx < 0 and -dx or dx
            local ady = dy < 0 and -dy or dy
            local ok = false
            if direction == "up" then
                ok = dy > 1 and ady >= adx
            elseif direction == "down" then
                ok = dy < -1 and ady >= adx
            elseif direction == "left" then
                ok = dx < -1 and adx >= ady
            elseif direction == "right" then
                ok = dx > 1 and adx >= ady
            end
            if ok then
                local score = adx + ady
                if not bestScore or score < bestScore then
                    best = node
                    bestScore = score
                end
            end
        end
    end
    return best
end

function Joypad:GetRaidTargetSteeringCue(targetOrDecision)
    EnsureDB()
    local _, raidCount = JoypadRaidCursorGroupCounts()
    if JoypadDB.raidTargetSteeringEnabled ~= true then
        return { found = false, reason = "disabled" }
    end
    if not raidCount or raidCount <= 0 then
        return { found = false, reason = "not_in_raid" }
    end
    if JoypadDB.raidCursorEnabled ~= true or not self.raidCursorBindingsActive then
        return { found = false, reason = "raid_cursor_inactive" }
    end

    local targetUnit = nil
    local spell = nil
    local reason = nil
    if type(targetOrDecision) == "table" then
        targetUnit = self:GetRaidSteeringTargetFromDecision(targetOrDecision)
        spell = targetOrDecision.mainBindSpell or targetOrDecision.bindSpell or targetOrDecision.cueSpell or targetOrDecision.spell or targetOrDecision.mainSpell or targetOrDecision.mainLabel
        reason = targetOrDecision.mainReason or targetOrDecision.reason
    else
        targetUnit = self:NormalizeRaidSteeringUnit(targetOrDecision)
    end

    if not targetUnit then
        return { found = false, reason = "no_raid_target" }
    end

    local currentUnit = self:GetCurrentRaidCursorUnit()
    if currentUnit == targetUnit then
        return {
            found = true,
            arrived = true,
            targetUnit = targetUnit,
            currentUnit = currentUnit,
            targetName = JoypadRaidCursorUnitName(targetUnit),
            spell = spell,
            reason = "arrived",
        }
    end

    local nodes, byUnit = self:ScanRaidSteeringNodes(false)
    local currentNode = currentUnit and byUnit and byUnit[currentUnit] or nil
    local targetNode = byUnit and byUnit[targetUnit] or nil
    if not currentNode then
        return { found = false, reason = "no_current_raid_frame", targetUnit = targetUnit, currentUnit = currentUnit }
    end
    if not targetNode then
        return { found = false, reason = "target_frame_not_visible", targetUnit = targetUnit, currentUnit = currentUnit }
    end

    local currentDistance = JoypadRaidSteeringDistance(currentNode.x, currentNode.y, targetNode.x, targetNode.y)
    local bestDirection, bestNode, bestDistance = nil, nil, nil
    for direction, info in pairs(JOYPAD_RAID_STEER_DIRECTIONS) do
        local candidate = self:ChooseRaidSteeringNode(currentNode, nodes, direction)
        if candidate then
            local distance = JoypadRaidSteeringDistance(candidate.x, candidate.y, targetNode.x, targetNode.y)
            if candidate.unit == targetUnit then
                bestDirection, bestNode, bestDistance = direction, candidate, distance
                break
            elseif distance < currentDistance and (not bestDistance or distance < bestDistance) then
                bestDirection, bestNode, bestDistance = direction, candidate, distance
            end
        end
    end

    if not bestDirection then
        return {
            found = false,
            reason = "no_path",
            targetUnit = targetUnit,
            currentUnit = currentUnit,
            targetName = JoypadRaidCursorUnitName(targetUnit),
            currentName = JoypadRaidCursorUnitName(currentUnit),
        }
    end

    local dirInfo = JOYPAD_RAID_STEER_DIRECTIONS[bestDirection]
    local buttonInfo = nil
    if JoypadAPI and JoypadAPI.GetButtonForBindingCommand then
        local ok, info = pcall(JoypadAPI.GetButtonForBindingCommand, dirInfo.bindingCommand)
        if ok then buttonInfo = info end
    end

    return {
        found = true,
        arrived = false,
        targetUnit = targetUnit,
        targetName = JoypadRaidCursorUnitName(targetUnit),
        currentUnit = currentUnit,
        currentName = JoypadRaidCursorUnitName(currentUnit),
        spell = spell,
        shiftyReason = reason,
        nextDirection = bestDirection,
        nextUnit = bestNode and bestNode.unit or nil,
        nextName = bestNode and JoypadRaidCursorUnitName(bestNode.unit) or nil,
        label = dirInfo.label,
        shortLabel = dirInfo.shortLabel,
        bindingCommand = dirInfo.bindingCommand,
        joypadSlot = dirInfo.slot,
        buttonInfo = buttonInfo,
        distanceBefore = currentDistance,
        distanceAfter = bestDistance,
        reason = "steer",
    }
end

function Joypad:LogRaidTargetSteeringEvent(kind, cue, extra)
    EnsureDB()
    if JoypadDB.raidTargetSteeringLogEnabled ~= true then return end
    cue = type(cue) == "table" and cue or {}
    extra = type(extra) == "table" and extra or {}

    if (kind == "raid-steering-unavailable")
        and (cue.reason == "not_in_raid" or cue.reason == "raid_cursor_inactive" or cue.reason == "disabled" or cue.reason == "no_raid_target") then
        return
    end

    self:LogRaidCursorEvent(kind or "raid-steering", {
        input = extra.input or cue.nextDirection,
        direction = extra.direction or cue.nextDirection,
        selectedUnit = cue.currentUnit or self:GetCurrentRaidCursorUnit(),
        targetBeforeUnit = cue.currentUnit,
        wantedUnit = cue.targetUnit,
        wantedName = cue.targetName,
        steeringTargetUnit = cue.targetUnit,
        steeringTargetName = cue.targetName,
        steeringCurrentUnit = cue.currentUnit,
        steeringCurrentName = cue.currentName,
        steeringNextDirection = cue.nextDirection,
        steeringNextUnit = cue.nextUnit,
        steeringNextName = cue.nextName,
        steeringArrived = cue.arrived and true or false,
        shiftySpell = cue.spell,
        shiftyReason = cue.shiftyReason,
        failure = cue.found == false and cue.reason or extra.failure,
        note = extra.note,
    })
end

function Joypad:BuildRaidTargetSteeringHighlight(decision)
    local cue = self:GetRaidTargetSteeringCue(decision)
    if not cue or cue.found ~= true then
        -- Normal idle states are not useful diagnostics and can be very noisy
        -- because Shifty emits healer decisions outside raids too.
        local reason = cue and cue.reason or nil
        if cue and reason
            and reason ~= "no_raid_target"
            and reason ~= "not_in_raid"
            and reason ~= "raid_cursor_inactive"
            and reason ~= "disabled" then
            self:LogRaidTargetSteeringEvent("raid-steering-unavailable", cue)
        end
        self._raidSteeringActiveCue = nil
        return nil, cue
    end
    if cue.arrived then
        self._raidSteeringActiveCue = nil
        self:LogRaidTargetSteeringEvent("raid-steering-arrived", cue)
        return nil, cue
    end

    self._raidSteeringActiveCue = cue
    self:LogRaidTargetSteeringEvent("raid-steering-cue", cue)
    return {
        kind = "raidsteer",
        bindingCommand = cue.bindingCommand,
        buttonInfo = cue.buttonInfo,
        label = cue.label,
        reason = "Raid target: " .. tostring(cue.targetName or cue.targetUnit or "?"),
        raidSteering = true,
        targetUnit = cue.targetUnit,
        spell = cue.spell,
    }, cue
end

function Joypad:HandleRaidSteeringInput(direction, selectedUnit)
    local cue = self._raidSteeringActiveCue
    if type(cue) ~= "table" or not direction then return end
    if direction ~= cue.nextDirection then return end

    self:LogRaidTargetSteeringEvent("raid-steering-ack", cue, {
        input = direction,
        direction = direction,
        note = "correct-direction-pressed",
    })

    local dirInfo = JOYPAD_RAID_STEER_DIRECTIONS[direction]
    local button = dirInfo and self.buttons and self.buttons[dirInfo.slot] or nil
    if button and self.SetShiftySuggestionButtonHighlight then
        self:SetShiftySuggestionButtonHighlight(button, "ack", dirInfo.label or direction, "ack")
        if GetTime then self._shiftyHighlightExpires = GetTime() + 0.16 end
    end
end

function Joypad:BuildRaidCursorLogEntry(kind, data)
    data = JoypadRaidCursorCopySmall(data)
    local party, raid = JoypadRaidCursorGroupCounts()
    local selectedUnit = data.selectedUnit
    if not selectedUnit and self.raidCursor and self.raidCursor.GetAttribute then
        local ok, value = pcall(function() return self.raidCursor:GetAttribute("cursorunit") end)
        if ok then selectedUnit = value end
    end

    local nodeName = data.selectedFrameName or data.selectedFrame
    if not nodeName and self.raidCursor and self.raidCursor.GetAttribute then
        local ok, node = pcall(function() return self.raidCursor:GetAttribute("node") end)
        if ok and node and node.GetName then
            local okName, name = pcall(node.GetName, node)
            if okName then nodeName = name end
        end
    end

    local _, _, instanceType, inInstance = nil, nil, nil, nil
    if IsInInstance then
        local ok, a, b, c, d = pcall(IsInInstance)
        if ok then
            inInstance = a
            instanceType = b
        end
    end

    local entry = {
        kind = tostring(kind or data.kind or "raid-cursor"),
        source = "Joypad",
        joypadVersion = VERSION,
        t = JoypadRaidCursorRound(JoypadRaidCursorNow(), 2) or 0,
        wall = JoypadRaidCursorWallTime(),
        inCombat = InCombat and InCombat() and true or false,
        inRaid = raid > 0,
        partyCount = party,
        raidCount = raid,
        active = self.raidCursorBindingsActive and true or false,
        enabled = JoypadDB and JoypadDB.raidCursorEnabled and true or false,
        selectedUnit = selectedUnit and tostring(selectedUnit) or nil,
        selectedName = selectedUnit and JoypadRaidCursorUnitName(selectedUnit) or nil,
        raidOnly = true,
        selectedGUID = selectedUnit and UnitGUID and UnitGUID(selectedUnit) or nil,
        selectedHP = selectedUnit and JoypadRaidCursorUnitHP(selectedUnit) or nil,
        selectedExists = selectedUnit and UnitExists and UnitExists(selectedUnit) and true or false,
        selectedFrameName = nodeName and tostring(nodeName) or nil,
        targetAfterName = UnitExists and UnitExists("target") and JoypadRaidCursorUnitName("target") or nil,
        targetAfterGUID = UnitExists and UnitExists("target") and UnitGUID and UnitGUID("target") or nil,
        zone = GetRealZoneText and GetRealZoneText() or nil,
        instanceType = instanceType,
    }

    for k, v in pairs(data) do
        if entry[k] == nil then entry[k] = v end
    end

    if entry.selectedGUID and entry.targetAfterGUID then
        entry.targetMatchesSelected = entry.selectedGUID == entry.targetAfterGUID
    end

    return entry
end

function Joypad:LogRaidCursorEvent(kind, data)
    EnsureDB()
    if JoypadDB.raidCursorLogEnabled ~= true then return end

    data = type(data) == "table" and data or {}

    -- Drop the old source of log spam entirely. Outside-raid inactive checks are
    -- normal idle state, not diagnostic events.
    if kind == "bindings-off" and data.failure == "not_in_raid" and self.raidCursorBindingsActive ~= true then
        return
    end

    local now = GetTime and GetTime() or 0
    local sig = tostring(kind or "?")
        .. "|" .. tostring(data.failure or "")
        .. "|" .. tostring(data.input or data.direction or "")
        .. "|" .. tostring(data.wantedUnit or data.steeringTargetUnit or "")
        .. "|" .. tostring(data.steeringNextDirection or "")
    if self._raidCursorLastLogSig == sig and self._raidCursorLastLogAt and (now - self._raidCursorLastLogAt) < 1.00 then
        return
    end
    self._raidCursorLastLogSig = sig
    self._raidCursorLastLogAt = now

    local entry = self:BuildRaidCursorLogEntry(kind, data)
    JoypadDB.raidCursorLog = JoypadDB.raidCursorLog or {}
    table.insert(JoypadDB.raidCursorLog, entry)
    while #JoypadDB.raidCursorLog > 300 do
        table.remove(JoypadDB.raidCursorLog, 1)
    end

    if type(ShiftyLogs_RecordJoypadRaidCursorEvent) == "function" then
        pcall(ShiftyLogs_RecordJoypadRaidCursorEvent, entry)
    elseif type(ShiftyLogs) == "table" and type(ShiftyLogs.RecordJoypadRaidCursorEvent) == "function" then
        pcall(ShiftyLogs.RecordJoypadRaidCursorEvent, entry)
    end
end

function Joypad:ApplyRaidCursorHighlightStyle()
    EnsureDB()
    local cursor = self.raidCursor
    if not cursor then return end

    local pad = tonumber(JoypadDB.raidCursorHighlightPadding or 3) or 3
    local border = tonumber(JoypadDB.raidCursorHighlightBorderSize or 2) or 2
    local alpha = tonumber(JoypadDB.raidCursorHighlightAlpha or 0.95) or 0.95
    local fill = tonumber(JoypadDB.raidCursorHighlightFillAlpha or 0.08) or 0.08

    if pad < 0 then pad = 0 elseif pad > 20 then pad = 20 end
    if border < 1 then border = 1 elseif border > 8 then border = 8 end
    if alpha < 0 then alpha = 0 elseif alpha > 1 then alpha = 1 end
    if fill < 0 then fill = 0 elseif fill > 0.5 then fill = 0.5 end

    if cursor.SetAttribute then
        cursor:SetAttribute("highlightPadding", pad)
    end

    local r, g, b = 0.10, 0.70, 1.00
    if cursor.raidBg then cursor.raidBg:SetVertexColor(r, g, b, fill) end
    if cursor.raidTop then cursor.raidTop:SetVertexColor(r, g, b, alpha); cursor.raidTop:SetHeight(border) end
    if cursor.raidBottom then cursor.raidBottom:SetVertexColor(r, g, b, alpha); cursor.raidBottom:SetHeight(border) end
    if cursor.raidLeft then cursor.raidLeft:SetVertexColor(r, g, b, alpha); cursor.raidLeft:SetWidth(border) end
    if cursor.raidRight then cursor.raidRight:SetVertexColor(r, g, b, alpha); cursor.raidRight:SetWidth(border) end

    if cursor.text then
        if JoypadDB.raidCursorShowLabel == true then
            cursor.text:Show()
        else
            cursor.text:SetText("")
            cursor.text:Hide()
        end
    end
end

function Joypad:CreateRaidCursor()
    if self.raidCursor or not CreateFrame or not UIParent then
        return self.raidCursor
    end

    local cursor = CreateFrame("Button", "JoypadRaidCursor", UIParent, "SecureHandlerStateTemplate,SecureActionButtonTemplate")
    cursor:SetWidth(72)
    cursor:SetHeight(72)
    cursor:SetFrameStrata("TOOLTIP")
    cursor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    cursor:RegisterForClicks("AnyDown")
    cursor:SetAttribute("type", "target")
    cursor:SetAttribute("_onstate-unitexists", "control:Run(UpdateUnitExists, newstate)")

    local bg = cursor:CreateTexture("JoypadRaidCursorFill", "BACKGROUND")
    bg:SetAllPoints(cursor)
    bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    cursor.raidBg = bg

    local top = cursor:CreateTexture("JoypadRaidCursorTop", "OVERLAY")
    top:SetTexture("Interface\\Buttons\\WHITE8X8")
    top:SetPoint("TOPLEFT", cursor, "TOPLEFT", 0, 0)
    top:SetPoint("TOPRIGHT", cursor, "TOPRIGHT", 0, 0)
    cursor.raidTop = top

    local bottom = cursor:CreateTexture("JoypadRaidCursorBottom", "OVERLAY")
    bottom:SetTexture("Interface\\Buttons\\WHITE8X8")
    bottom:SetPoint("BOTTOMLEFT", cursor, "BOTTOMLEFT", 0, 0)
    bottom:SetPoint("BOTTOMRIGHT", cursor, "BOTTOMRIGHT", 0, 0)
    cursor.raidBottom = bottom

    local left = cursor:CreateTexture("JoypadRaidCursorLeft", "OVERLAY")
    left:SetTexture("Interface\\Buttons\\WHITE8X8")
    left:SetPoint("TOPLEFT", cursor, "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMLEFT", cursor, "BOTTOMLEFT", 0, 0)
    cursor.raidLeft = left

    local right = cursor:CreateTexture("JoypadRaidCursorRight", "OVERLAY")
    right:SetTexture("Interface\\Buttons\\WHITE8X8")
    right:SetPoint("TOPRIGHT", cursor, "TOPRIGHT", 0, 0)
    right:SetPoint("BOTTOMRIGHT", cursor, "BOTTOMRIGHT", 0, 0)
    cursor.raidRight = right

    local text = cursor:CreateFontString("JoypadRaidCursorText", "OVERLAY", "NumberFontNormalSmall")
    text:SetPoint("CENTER", cursor, "CENTER", 0, 0)
    text:SetWidth(160)
    text:SetJustifyH("CENTER")
    text:SetTextColor(0.65, 0.95, 1.0, 1)
    text:SetShadowColor(0, 0, 0, 1)
    text:SetShadowOffset(1, -1)
    text:SetText("")
    text:Hide()
    cursor.text = text

    cursor:Hide()
    self.raidCursor = cursor
    self:ApplyRaidCursorHighlightStyle()

    if SecureHandlerExecute then
        SecureHandlerExecute(cursor, [[
            Key = newtable()
            Key.Up = 13
            Key.Left = 14
            Key.Right = 15
            Key.Down = 16
            Key.Target = 1

            IsRaidCursorUnit = [=[
                local unit = ...
                if not unit then return nil end
                unit = tostring(unit)
                if unit == 'player' or unit == 'target' or unit == 'focus' or unit == 'pet' or unit == 'mouseover' then
                    return nil
                end
                if string.find(unit, '^raid%d+$') then
                    return true
                end
                return nil
            ]=]

            Units = newtable()
            Cache = newtable()
            Cache[self] = true
            current = nil
            old = nil
            CurrentNode = nil
            SEQ = 0

            GetNodes = [=[
                local node = CurrentNode
                if not node then return end

                local isProtected = node:IsProtected()
                local unit = isProtected and node:GetAttribute('unit')
                local action = isProtected and node:GetAttribute('action')
                local children = isProtected and newtable(self.GetChildren(node))
                local childUnit

                if children then
                    for i, child in pairs(children) do
                        if child:IsProtected() then
                            childUnit = child:GetAttribute('unit')
                            if childUnit == nil or childUnit ~= unit then
                                CurrentNode = child
                                control:Run(GetNodes)
                            end
                        end
                    end
                end

                if isProtected then
                    if Cache[node] then
                        return
                    else
                        if unit and not action and control:Run(IsRaidCursorUnit, unit) then
                            local left, bottom, width, height = node:GetRect()
                            if left and bottom and width and height then
                                Units[node] = true
                                Cache[node] = true
                            end
                        elseif unit and not control:Run(IsRaidCursorUnit, unit) then
                            Cache[node] = true
                        elseif action and tonumber(action) then
                            Cache[node] = true
                        end
                    end
                end
            ]=]

            SetCurrent = [=[
                if old and old:IsVisible() and UnitExists(old:GetAttribute('unit')) then
                    current = old
                elseif (not current and next(Units)) or (current and next(Units) and not current:IsVisible()) then
                    local thisX, thisY = self:GetRect()
                    if thisX and thisY then
                        local node, dist
                        for Node in pairs(Units) do
                            if Node ~= old and Node:IsVisible() and UnitExists(Node:GetAttribute('unit')) then
                                local left, bottom, width, height = Node:GetRect()
                                if left and bottom and width and height then
                                    local dx = thisX - (left + width / 2)
                                    if dx < 0 then dx = -dx end
                                    local dy = thisY - (bottom + height / 2)
                                    if dy < 0 then dy = -dy end
                                    local destDistance = dx + dy
                                    if not dist or destDistance < dist then
                                        node = Node
                                        dist = destDistance
                                    end
                                end
                            end
                        end
                        if node then current = node end
                    else
                        for Node in pairs(Units) do
                            if Node:IsVisible() and UnitExists(Node:GetAttribute('unit')) then
                                current = Node
                                break
                            end
                        end
                    end
                end
            ]=]

            FindClosestNode = [=[
                if current and key ~= 0 and key ~= Key.Target then
                    local left, bottom, width, height = current:GetRect()
                    if not left or not bottom or not width or not height then return end

                    local thisY = bottom + height / 2
                    local thisX = left + width / 2
                    local nodeY, nodeX = 10000, 10000
                    local destY, destX, diffY, diffX, total, swap

                    for destination in pairs(Units) do
                        if destination:IsVisible() and UnitExists(destination:GetAttribute('unit')) then
                            left, bottom, width, height = destination:GetRect()
                            if left and bottom and width and height then
                                destY = bottom + height / 2
                                destX = left + width / 2
                                diffY = thisY - destY
                                if diffY < 0 then diffY = -diffY end
                                diffX = thisX - destX
                                if diffX < 0 then diffX = -diffX end
                                total = diffX + diffY

                                if total < nodeX + nodeY then
                                    if key == Key.Up then
                                        if diffY > diffX and destY > thisY then swap = true end
                                    elseif key == Key.Down then
                                        if diffY > diffX and destY < thisY then swap = true end
                                    elseif key == Key.Left then
                                        if diffY < diffX and destX < thisX then swap = true end
                                    elseif key == Key.Right then
                                        if diffY < diffX and destX > thisX then swap = true end
                                    end
                                end

                                if swap then
                                    nodeX = diffX
                                    nodeY = diffY
                                    current = destination
                                    swap = false
                                end
                            end
                        end
                    end
                end
            ]=]

            UpdateRouting = [=[
                local unit = current and current:GetAttribute('unit')
                if unit and control:Run(IsRaidCursorUnit, unit) and UnitExists(unit) then
                    self:Show()
                    RegisterStateDriver(self, 'unitexists', '[@'..unit..',exists] true; nil')
                    local left, bottom, width, height = current:GetRect()
                    local pad = tonumber(self:GetAttribute('highlightPadding') or 3) or 3
                    if width and height then
                        self:SetWidth(width + pad + pad)
                        self:SetHeight(height + pad + pad)
                    end
                    self:ClearAllPoints()
                    self:SetPoint('CENTER', current, 'CENTER', 0, 0)
                    self:SetAttribute('node', current)
                    self:SetAttribute('cursorunit', unit)
                else
                    UnregisterStateDriver(self, 'unitexists')
                    self:SetAttribute('node', nil)
                    self:SetAttribute('cursorunit', nil)
                    self:SetAttribute('unit', nil)
                    self:Hide()
                end
            ]=]

            SelectNode = [=[
                key = tonumber(...) or 0
                if current then old = current end
                control:Run(SetCurrent)
                control:Run(FindClosestNode)
                control:Run(UpdateRouting)
            ]=]

            UpdateFrameStack = [=[
                local frames = newtable(self:GetParent():GetChildren())
                for i, frame in pairs(frames) do
                    if frame:IsProtected() and not Cache[frame] then
                        CurrentNode = frame
                        control:Run(GetNodes)
                    end
                end
                if next(Units) then
                    control:Run(SelectNode, 0)
                end
            ]=]

            UpdateUnitExists = [=[
                local exists = ...
                if not exists then
                    control:Run(SelectNode, 0)
                end
            ]=]
        ]])
    end

    local wrapOK = false
    local wrapErr = nil
    if cursor.WrapScript then
        wrapOK, wrapErr = pcall(function()
            cursor:WrapScript(cursor, "OnClick", [[
                local rawButton = button
                local key = tonumber(rawButton) or 0
                local before = self:GetAttribute('cursorunit')
                SEQ = (SEQ or 0) + 1
                self:SetAttribute('lastinput', rawButton)
                self:SetAttribute('targetBeforeUnit', before)

                if not next(Units) then
                    control:Run(UpdateFrameStack)
                end

                control:Run(SelectNode, key)

                local unit = self:GetAttribute('cursorunit')
                local isMove = (key == Key.Up or key == Key.Down or key == Key.Left or key == Key.Right)
                local noTargetOnMove = self:GetAttribute('noTargetOnMove')

                if unit and control:Run(IsRaidCursorUnit, unit) and (key == Key.Target or not (isMove and noTargetOnMove)) then
                    self:SetAttribute('unit', unit)
                else
                    self:SetAttribute('unit', nil)
                end

                self:SetAttribute('lastselectedunit', unit)
                self:SetAttribute('inputseq', SEQ)
            ]])
        end)
    elseif SecureHandlerWrapScript then
        wrapOK, wrapErr = pcall(SecureHandlerWrapScript, cursor, "OnClick", [[
            local rawButton = button
            local key = tonumber(rawButton) or 0
            local before = self:GetAttribute('cursorunit')
            SEQ = (SEQ or 0) + 1
            self:SetAttribute('lastinput', rawButton)
            self:SetAttribute('targetBeforeUnit', before)

            if not next(Units) then
                control:Run(UpdateFrameStack)
            end

            control:Run(SelectNode, key)

            local unit = self:GetAttribute('cursorunit')
            local isMove = (key == Key.Up or key == Key.Down or key == Key.Left or key == Key.Right)
            local noTargetOnMove = self:GetAttribute('noTargetOnMove')

            if unit and (key == Key.Target or not (isMove and noTargetOnMove)) then
                self:SetAttribute('unit', unit)
            else
                self:SetAttribute('unit', nil)
            end

            self:SetAttribute('lastselectedunit', unit)
            self:SetAttribute('inputseq', SEQ)
        ]])
    end

    self.raidCursorSecureWrapOK = wrapOK and true or false
    if not wrapOK then
        self.raidCursorSecureWrapFailed = true
        self:LogRaidCursorEvent("wrap-failed", {
            failure = "secure_wrap_failed",
            note = tostring(wrapErr or "no_secure_wrap_api"),
        })
    end

    cursor:SetScript("OnAttributeChanged", function(frame, attribute, value)
        if not Joypad or not Joypad.LogRaidCursorEvent then return end
        if attribute == "cursorunit" then
            Joypad:UpdateRaidCursorText(value)
            local nodeName = nil
            local node = frame:GetAttribute("node")
            if node and node.GetName then
                local okName, name = pcall(node.GetName, node)
                if okName then nodeName = name end
            end
            Joypad:LogRaidCursorEvent("select", {
                selectedUnit = value,
                selectedFrameName = nodeName,
            })
        elseif attribute == "inputseq" then
            local inputLabel = JoypadRaidCursorInputLabel(frame:GetAttribute("lastinput"))
            Joypad:LogRaidCursorEvent("input", {
                input = inputLabel,
                button = tostring(frame:GetAttribute("lastinput") or ""),
                selectedUnit = frame:GetAttribute("lastselectedunit"),
                targetBeforeUnit = frame:GetAttribute("targetBeforeUnit"),
            })
            if Joypad.HandleRaidSteeringInput then
                Joypad:HandleRaidSteeringInput(inputLabel, frame:GetAttribute("lastselectedunit"))
            end
        elseif attribute == "node" then
            local nodeName = nil
            if value and value.GetName then
                local ok, name = pcall(value.GetName, value)
                if ok then nodeName = name end
            end
            Joypad:LogRaidCursorEvent("node", {
                selectedFrameName = nodeName,
                selectedUnit = frame:GetAttribute("cursorunit"),
            })
        end
    end)

    self:LogRaidCursorEvent("create", { note = "raid cursor created" })
    return cursor
end

function Joypad:UpdateRaidCursorText(unit)
    local cursor = self.raidCursor
    if not cursor or not cursor.text then return end
    if JoypadDB and JoypadDB.raidCursorShowLabel == true then
        local label = unit and tostring(unit) or "RAID"
        local name = unit and JoypadRaidCursorUnitName(unit) or nil
        cursor.text:SetText(name or label)
        cursor.text:Show()
    else
        cursor.text:SetText("")
        cursor.text:Hide()
    end
end

function Joypad:RefreshRaidCursorFrameStack(reason)
    local cursor = self:CreateRaidCursor()
    if not cursor or not SecureHandlerExecute then return false end

    local ok = pcall(function()
        SecureHandlerExecute(cursor, [[
            if UpdateFrameStack then
                control:Run(UpdateFrameStack)
            end
        ]])
    end)

    self:LogRaidCursorEvent(ok and "scan" or "scan-failed", {
        reason = reason,
        failure = ok and nil or "secure-execute-failed",
    })
    return ok
end

function Joypad:GetRaidCursorPhysicalKeys(slot)
    local command = "CLICK JoypadButton" .. tostring(slot) .. ":LeftButton"
    local keys = {}
    if GetBindingKey then
        local k1, k2, k3, k4 = GetBindingKey(command)
        if k1 then keys[#keys + 1] = k1 end
        if k2 then keys[#keys + 1] = k2 end
        if k3 then keys[#keys + 1] = k3 end
        if k4 then keys[#keys + 1] = k4 end
    end
    return keys, command
end

function Joypad:BindRaidCursorSlot(cursor, joypadSlot, clickButton)
    if not cursor or not SetOverrideBindingClick then return 0, "no_binding_api" end

    local keys, command = self:GetRaidCursorPhysicalKeys(joypadSlot)
    if not keys or #keys <= 0 then
        return 0, command
    end

    local count = 0
    for _, key in ipairs(keys) do
        if key then
            local ok = pcall(SetOverrideBindingClick, cursor, true, key, "JoypadRaidCursor", tostring(clickButton))
            if ok then count = count + 1 end
        end
    end
    return count, command
end

function Joypad:UpdateRaidCursorBindings(reason)
    EnsureDB()

    local inRaid = self:IsRaidCursorRaidActive()
    local shouldBeActive = JoypadDB.raidCursorEnabled == true and inRaid
    local cursor = self.raidCursor

    -- Cheap/quiet path: outside raids, do not create the secure cursor, do not
    -- refresh Joypad buttons, and do not spam ShiftyLogs with repeated
    -- bindings-off/not_in_raid events. Only log a transition if bindings were
    -- actually active and are now being removed.
    if not shouldBeActive then
        local wasActive = self.raidCursorBindingsActive == true
        if cursor and ClearOverrideBindings then
            pcall(ClearOverrideBindings, cursor)
        end
        self.raidCursorBindingsActive = false
        self._raidSteeringActiveCue = nil
        if cursor and cursor.Hide then cursor:Hide() end

        if wasActive then
            self:LogRaidCursorEvent("bindings-off", {
                reason = reason,
                active = false,
                failure = JoypadDB.raidCursorEnabled ~= true and "disabled" or "not_in_raid",
            })
            if UpdateAllButtons then
                UpdateAllButtons(true)
            else
                JoypadQueueRefresh("buttons")
            end
        end
        return true
    end

    cursor = self:CreateRaidCursor()
    if not cursor then return false end

    if InCombat and InCombat() then
        self.pendingRaidCursorBindings = true
        self:LogRaidCursorEvent("bindings-pending", { reason = reason, queued = true })
        return false
    end

    if ClearOverrideBindings then
        pcall(ClearOverrideBindings, cursor)
    end
    self.raidCursorBindingsActive = false

    if self.raidCursorSecureWrapFailed then
        self:LogRaidCursorEvent("bindings-off", {
            reason = reason,
            active = false,
            failure = "secure_wrap_failed",
        })
        return false
    end

    if cursor.SetAttribute then
        if JoypadDB.raidCursorTargetOnMove == true then
            cursor:SetAttribute("noTargetOnMove", nil)
        else
            cursor:SetAttribute("noTargetOnMove", true)
        end
    end

    local total = 0
    local missing = {}

    local c, cmd = self:BindRaidCursorSlot(cursor, 13, "13")
    total = total + (tonumber(c or 0) or 0)
    if not c or c <= 0 then missing[#missing + 1] = cmd or "slot13" end

    c, cmd = self:BindRaidCursorSlot(cursor, 14, "14")
    total = total + (tonumber(c or 0) or 0)
    if not c or c <= 0 then missing[#missing + 1] = cmd or "slot14" end

    c, cmd = self:BindRaidCursorSlot(cursor, 15, "15")
    total = total + (tonumber(c or 0) or 0)
    if not c or c <= 0 then missing[#missing + 1] = cmd or "slot15" end

    c, cmd = self:BindRaidCursorSlot(cursor, 16, "16")
    total = total + (tonumber(c or 0) or 0)
    if not c or c <= 0 then missing[#missing + 1] = cmd or "slot16" end

    if JoypadDB.raidCursorAFallback == true then
        c, cmd = self:BindRaidCursorSlot(cursor, 1, "1")
        total = total + (tonumber(c or 0) or 0)
        if not c or c <= 0 then missing[#missing + 1] = cmd or "slot1" end
    end

    self.raidCursorBindingsActive = total > 0
    self:RefreshRaidCursorFrameStack(reason or "bindings")

    self:LogRaidCursorEvent(total > 0 and "bindings-on" or "bindings-missing", {
        reason = reason,
        active = total > 0,
        bindingCount = total,
        missingBindings = table.concat(missing, ","),
        failure = total > 0 and nil or "no_physical_keys",
    })

    if UpdateAllButtons then
        UpdateAllButtons(true)
    else
        JoypadQueueRefresh("buttons")
    end

    return total > 0
end

function Joypad:SetRaidCursorEnabled(enabled, silent)
    EnsureDB()
    JoypadDB.raidCursorEnabled = enabled and true or false
    self:UpdateRaidCursorBindings("setting")
    if self.NotifyAceOptionsChanged then self:NotifyAceOptionsChanged() end
    if not silent then
        Print(JoypadDB.raidCursorEnabled and "Raid Cursor enabled for raids." or "Raid Cursor disabled.")
    end
end

function Joypad:SetRaidCursorTargetOnMove(enabled, silent)
    EnsureDB()
    JoypadDB.raidCursorTargetOnMove = enabled and true or false
    self:UpdateRaidCursorBindings("target-on-move-setting")
    if self.NotifyAceOptionsChanged then self:NotifyAceOptionsChanged() end
    if not silent then
        Print(JoypadDB.raidCursorTargetOnMove and "Raid Cursor target-on-move enabled." or "Raid Cursor target-on-move disabled; A targets highlighted raid frame.")
    end
end

function Joypad:SetRaidCursorAFallback(enabled, silent)
    EnsureDB()
    JoypadDB.raidCursorAFallback = enabled and true or false
    self:UpdateRaidCursorBindings("a-fallback-setting")
    if self.NotifyAceOptionsChanged then self:NotifyAceOptionsChanged() end
    if not silent then
        Print(JoypadDB.raidCursorAFallback and "Raid Cursor A fallback enabled; A targets highlighted raid frame." or "Raid Cursor A fallback disabled; A remains normal Jump.")
    end
end

function Joypad:PrintRaidCursorStatus()
    EnsureDB()
    local party, raid = JoypadRaidCursorGroupCounts()
    local cursor = self:CreateRaidCursor()
    local unit = cursor and cursor.GetAttribute and cursor:GetAttribute("cursorunit") or nil
    local keys13 = self:GetRaidCursorPhysicalKeys(13)
    local keys14 = self:GetRaidCursorPhysicalKeys(14)
    local keys15 = self:GetRaidCursorPhysicalKeys(15)
    local keys16 = self:GetRaidCursorPhysicalKeys(16)
    local keys1 = self:GetRaidCursorPhysicalKeys(1)
    Print("Raid Cursor: enabled=" .. tostring(JoypadDB.raidCursorEnabled)
        .. " active=" .. tostring(self.raidCursorBindingsActive)
        .. " inRaid=" .. tostring(raid > 0)
        .. " party=" .. tostring(party)
        .. " raid=" .. tostring(raid)
        .. " selected=" .. tostring(unit or "-")
        .. " targetOnMove=" .. tostring(JoypadDB.raidCursorTargetOnMove)
        .. " A=" .. tostring(JoypadDB.raidCursorAFallback)
        .. " wrapOK=" .. tostring(self.raidCursorSecureWrapOK)
        .. " wrapFailed=" .. tostring(self.raidCursorSecureWrapFailed))
    Print("Raid Cursor keys: up=" .. tostring(keys13 and keys13[1] or "-")
        .. " left=" .. tostring(keys14 and keys14[1] or "-")
        .. " right=" .. tostring(keys15 and keys15[1] or "-")
        .. " down=" .. tostring(keys16 and keys16[1] or "-")
        .. " A=" .. (JoypadDB.raidCursorAFallback == true and tostring(keys1 and keys1[1] or "-") or "normal-jump"))
end

function Joypad:GetSmartMouselookTooltipAnchorValues()
    EnsureDB()

    local mode = tostring(JoypadDB.smartMouselookTooltipAnchor or "elvui")
    local point = tostring(JoypadDB.smartMouselookTooltipPoint or "TOPRIGHT")
    local relativePoint = tostring(JoypadDB.smartMouselookTooltipRelativePoint or "TOPRIGHT")
    local x = tonumber(JoypadDB.smartMouselookTooltipX or -230) or -230
    local y = tonumber(JoypadDB.smartMouselookTooltipY or -4) or -4

    if mode == "cursor" then
        return "cursor", point, relativePoint, x, y
    end

    if mode == "topright" then
        return "manual", "TOPRIGHT", "TOPRIGHT", -230, -4
    end

    if mode == "elvui" then
        -- Matches the uploaded ElvUI saved profile:
        -- ElvTooltipMover = TOPRIGHT,ElvUIParent,TOPRIGHT,-230,-4
        return "manual", "TOPRIGHT", "TOPRIGHT", -230, -4
    end

    return "manual", point, relativePoint, x, y
end

function Joypad:ApplySmartMouselookTooltipAnchor(tooltip)
    if not tooltip then
        return
    end

    local mode, point, relativePoint, x, y = self:GetSmartMouselookTooltipAnchorValues()
    if mode == "cursor" then
        tooltip:SetOwner(UIParent or WorldFrame, "ANCHOR_CURSOR")
        return
    end

    tooltip:SetOwner(UIParent or WorldFrame, "ANCHOR_NONE")
    if tooltip.ClearAllPoints then
        tooltip:ClearAllPoints()
    end

    local relativeTo = _G.ElvUIParent or UIParent or WorldFrame
    if tooltip.SetPoint then
        tooltip:SetPoint(point or "TOPRIGHT", relativeTo, relativePoint or "TOPRIGHT", tonumber(x or 0) or 0, tonumber(y or 0) or 0)
    end
end

function Joypad:SetSmartMouselookTooltipAnchor(anchorMode, silent)
    EnsureDB()

    anchorMode = tostring(anchorMode or "elvui")
    if anchorMode ~= "cursor" and anchorMode ~= "elvui" and anchorMode ~= "manual" and anchorMode ~= "topright" then
        anchorMode = "elvui"
    end

    JoypadDB.smartMouselookTooltipAnchor = anchorMode
    if self.smartMouselookTooltipShown and GameTooltip then
        self:ApplySmartMouselookTooltipAnchor(GameTooltip)
    end

    if self.NotifyAceOptionsChanged then
        self:NotifyAceOptionsChanged()
    end

    if not silent then
        Print("Smart mouselook Blizzard tooltip anchor: " .. tostring(anchorMode))
    end
end

function Joypad:SetSmartMouselookTooltipOffset(x, y, silent)
    EnsureDB()

    JoypadDB.smartMouselookTooltipAnchor = "manual"
    JoypadDB.smartMouselookTooltipX = tonumber(x or JoypadDB.smartMouselookTooltipX or -230) or -230
    JoypadDB.smartMouselookTooltipY = tonumber(y or JoypadDB.smartMouselookTooltipY or -4) or -4

    if self.smartMouselookTooltipShown and GameTooltip then
        self:ApplySmartMouselookTooltipAnchor(GameTooltip)
    end

    if self.NotifyAceOptionsChanged then
        self:NotifyAceOptionsChanged()
    end

    if not silent then
        Print("Smart mouselook Blizzard tooltip position: TOPRIGHT " .. tostring(JoypadDB.smartMouselookTooltipX) .. ", " .. tostring(JoypadDB.smartMouselookTooltipY))
    end
end

function Joypad:ClearSmartMouselookForcedTooltip()
    if self.smartMouselookTooltipShown and GameTooltip then
        GameTooltip:Hide()
    end
    self.smartMouselookTooltipShown = nil
end

function Joypad:UpdateSmartMouselookForcedTooltip(elapsed)
    EnsureDB()

    if JoypadDB.smartMouselookForceTooltip ~= true or not self.smartMouselookActive or not GameTooltip then
        self:ClearSmartMouselookForcedTooltip()
        return
    end

    self.smartMouselookTooltipElapsed = (self.smartMouselookTooltipElapsed or 0) + (elapsed or 0)
    if self.smartMouselookTooltipElapsed < 0.10 then
        return
    end
    self.smartMouselookTooltipElapsed = 0

    local unit, sourceLabel = self:GetSmartMouselookTargetUnit()
    -- Only real unit tokens drive the Blizzard GameTooltip. AwesomeWotLK's
    -- nameplateN tokens are normal unit tokens, so the centred-nameplate hint can
    -- safely use the same tooltip path as selected target and mouseover.
    if unit and UnitExists and UnitExists(unit) then
        self:ApplySmartMouselookTooltipAnchor(GameTooltip)
        GameTooltip:SetUnit(unit)
        GameTooltip:Show()
        self.smartMouselookTooltipShown = true
        self.smartMouselookTooltipUnit = unit
        self.smartMouselookTooltipSource = sourceLabel
    else
        self:ClearSmartMouselookForcedTooltip()
    end
end

function Joypad:CreateSmartMouselookMouseoverHint()
    if self.smartMouselookMouseoverHintFrame then
        return
    end

    local frame = CreateFrame("Frame", "JoypadSmartMouselookMouseoverHint", UIParent)
    frame:SetWidth(260)
    frame:SetHeight(44)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, -165)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(1000)
    frame:EnableMouse(false)

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetTexture(0, 0, 0, 0.58)
    frame.bg = bg

    local border = frame:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    border:SetTexture(1, 0.82, 0, 0.28)
    frame.border = border

    local inner = frame:CreateTexture(nil, "ARTWORK")
    inner:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    inner:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
    inner:SetTexture(0, 0, 0, 0.76)
    frame.inner = inner

    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetWidth(32)
    icon:SetHeight(32)
    icon:SetPoint("LEFT", frame, "LEFT", 7, 0)
    icon:SetTexture("Interface\\AddOns\\Joypad\\Textures\\JoypadIcon")
    frame.icon = icon

    local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -1)
    name:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
    name:SetJustifyH("LEFT")
    name:SetText("")
    frame.nameText = name

    local action = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    action:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
    action:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
    action:SetJustifyH("LEFT")
    action:SetText("")
    frame.actionText = action

    frame:Hide()
    self.smartMouselookMouseoverHintFrame = frame
end

function Joypad:HideSmartMouselookMouseoverHint()
    if self.smartMouselookMouseoverHintFrame then
        self.smartMouselookMouseoverHintFrame:Hide()
    end
    self.smartMouselookMouseoverUnit = nil
end

function Joypad:GetSmartMouselookMouseoverHint()
    local unit, sourceLabel = self:GetSmartMouselookTargetUnit()
    local name, action, realUnit = self:GetSmartMouselookUnitHint(unit, sourceLabel)
    if name then
        return name, action, realUnit
    end

    return nil
end

function Joypad:UpdateSmartMouselookMouseoverHint(elapsed, force)
    EnsureDB()

    if JoypadDB.smartMouselookMouseoverHint ~= true or not self.smartMouselookActive then
        self:HideSmartMouselookMouseoverHint()
        return
    end

    self.smartMouselookMouseoverHintElapsed = (self.smartMouselookMouseoverHintElapsed or 0) + (elapsed or 0)
    if not force and self.smartMouselookMouseoverHintElapsed < 0.02 then
        return
    end
    self.smartMouselookMouseoverHintElapsed = 0

    local name, action, unit = self:GetSmartMouselookMouseoverHint()
    if not name then
        self:HideSmartMouselookMouseoverHint()
        return
    end

    self:CreateSmartMouselookMouseoverHint()
    local frame = self.smartMouselookMouseoverHintFrame
    if not frame then
        return
    end

    if SetPortraitTexture and frame.icon then
        pcall(SetPortraitTexture, frame.icon, unit or "mouseover")
    end

    frame.nameText:SetText(name)
    frame.actionText:SetText(action or "")
    frame:Show()
    self.smartMouselookMouseoverUnit = name
end

function Joypad:SetSmartMouselookMouseoverHint(enabled, silent)
    EnsureDB()

    JoypadDB.smartMouselookMouseoverHint = enabled and true or false
    if not JoypadDB.smartMouselookMouseoverHint then
        self:HideSmartMouselookMouseoverHint()
    end

    if self.NotifyAceOptionsChanged then
        self:NotifyAceOptionsChanged()
    end

    if not silent then
        Print(JoypadDB.smartMouselookMouseoverHint and "Joypad debug target hint enabled." or "Joypad debug target hint disabled.")
    end
end

function Joypad:ResyncSmartMouselook(reason)
    EnsureDB()

    if JoypadDB.smartMouselookEnabled ~= true then
        return
    end

    if self.smartMouselookModifierPaused then
        return
    end

    local realLooking = self:IsRealMouselookActive()

    if realLooking then
        self.smartMouselookStarted = true
        self.smartMouselookActive = true
        self:ShowSmartMouselookBlocker()
        self:RestoreHardwareCursor("smartMouselook")
        self:UpdateSmartMouselookMouseoverHint(0, true)
        return
    end

    if self.smartMouselookActive and self.smartMouselookStarted then
        self.smartMouselookStarted = false
        self:HideSmartMouselookBlocker()
        self:HideHardwareCursor("smartMouselook")
        self:UpdateSmartMouselookMouseoverHint(0, true)
    end
end

function Joypad:PauseSmartMouselookForModifier()
    if not self.smartMouselookActive then
        self.smartMouselookModifierPaused = true
        return
    end

    self.smartMouselookModifierPaused = true

    if self.smartMouselookStarted and MouselookStop then
        if not IsMouselooking or self:IsRealMouselookActive() then
            pcall(MouselookStop)
        end
    end

    self.smartMouselookStarted = nil
    self.smartMouselookActive = nil
    self:HideSmartMouselookBlocker()
    self:RestoreHardwareCursor("smartMouselook")
    self:ClearSmartMouselookForcedTooltip()

    if GetTime then
        self.smartMouselookCenterSuppressUntil = GetTime() + 0.15
    end
end

function Joypad:ResumeSmartMouselookAfterModifier()
    if not self.smartMouselookModifierPaused then
        return
    end

    self.smartMouselookModifierPaused = nil

    if JoypadDB.smartMouselookEnabled ~= true or not self:IsSmartMouselookReasonActive() then
        return
    end

    for reason, active in pairs(self.smartMouselookReasons or {}) do
        if active and self:CanStartSmartMouselook(reason) then
            self:StartSmartMouselook(reason)
            return
        end
    end
end

function Joypad:UpdateSmartMouselookModifierPause(elapsed)
    EnsureDB()

    if JoypadDB.smartMouselookPauseOnModifier ~= true then
        if self.smartMouselookModifierPaused then
            self.smartMouselookModifierPaused = nil
        end
        return
    end

    if self:IsSmartMouselookModifierHeld() then
        self:PauseSmartMouselookForModifier()
    else
        self:ResumeSmartMouselookAfterModifier()
    end
end

function Joypad:SetSmartMouselookForceTooltip(enabled, silent)
    EnsureDB()

    JoypadDB.smartMouselookForceTooltip = enabled and true or false
    if not JoypadDB.smartMouselookForceTooltip then
        self:ClearSmartMouselookForcedTooltip()
    end

    if self.NotifyAceOptionsChanged then
        self:NotifyAceOptionsChanged()
    end

    if not silent then
        Print(JoypadDB.smartMouselookForceTooltip and "Smart mouselook Blizzard target tooltip enabled." or "Smart mouselook Blizzard target tooltip disabled.")
    end
end

function Joypad:SetSmartMouselookPauseOnModifier(enabled, silent)
    EnsureDB()

    JoypadDB.smartMouselookPauseOnModifier = enabled and true or false
    if not JoypadDB.smartMouselookPauseOnModifier and self.smartMouselookModifierPaused then
        self.smartMouselookModifierPaused = nil
    end

    if self.NotifyAceOptionsChanged then
        self:NotifyAceOptionsChanged()
    end

    if not silent then
        Print(JoypadDB.smartMouselookPauseOnModifier and "Hold Ctrl now releases Smart mouselook." or "Hold Ctrl release disabled.")
    end
end

function Joypad:CanStartSmartMouselook(trigger)
    EnsureDB()

    if JoypadDB.smartMouselookEnabled ~= true then
        return false
    end
    if not self:IsSmartMouselookTriggerEnabled(trigger) then
        return false
    end
    if JoypadDB.smartMouselookPauseOnModifier == true and self:IsSmartMouselookModifierHeld() then
        return false
    end
    if SpellIsTargeting and SpellIsTargeting() then
        return false
    end

    -- Movement/turn/strafe hooks are direct input-driven attempts and should
    -- not be cancelled just because the hidden mouse happens to be over a UI
    -- frame. For softer event pulses, only avoid stealing mouselook while the
    -- Joypad UI cursor itself is active.
    if self.uiCursorActive then
        return false
    end

    return true
end

function Joypad:StartSmartMouselook(reason)
    EnsureDB()

    reason = tostring(reason or "generic")
    self.smartMouselookReasons = self.smartMouselookReasons or {}
    self.smartMouselookReasons[reason] = true

    if not self:CanStartSmartMouselook(reason) then
        return
    end
    if self.smartMouselookActive then
        return
    end

    local started = false
    if MouselookStart then
        local ok = pcall(MouselookStart)
        if ok then
            if IsMouselooking then
                local okLooking, looking = pcall(IsMouselooking)
                started = okLooking and looking and true or false
            else
                -- Older/private 3.3.5 clients may not expose IsMouselooking.
                -- Treat the call as best-effort, but do not rely on it for the
                -- blocker safety below.
                started = true
            end
        end
    end

    if started then
        self.smartMouselookStarted = true
        self.smartMouselookActive = true
        self:ShowSmartMouselookBlocker()
        self:UpdateSmartMouselookMouseoverHint(0, true)
    else
        -- If MouselookStart was refused or silently failed, still hide the
        -- hardware cursor, but do not show the full-screen blocker. The blocker
        -- is only safe when real mouselook is active.
        self.smartMouselookStarted = false
        self.smartMouselookActive = true
        self:HideSmartMouselookBlocker()
        self:HideHardwareCursor("smartMouselook")
        self:UpdateSmartMouselookMouseoverHint(0, true)
    end
end

function Joypad:StopSmartMouselook(reason)
    if (not reason or tostring(reason or "") == "center") and GetTime then
        self.smartMouselookCenterSuppressUntil = GetTime() + 1.25
    end

    if reason and self.smartMouselookReasons then
        self.smartMouselookReasons[tostring(reason)] = nil
        if self:IsSmartMouselookReasonActive() then
            return
        end
    else
        self.smartMouselookReasons = {}
    end

    if self.smartMouselookStarted and MouselookStop then
        if not IsMouselooking or self:IsRealMouselookActive() then
            pcall(MouselookStop)
        end
    end

    self.smartMouselookStarted = nil
    self.smartMouselookActive = nil
    self:HideSmartMouselookBlocker()
    self:RestoreHardwareCursor("smartMouselook")
    self:ClearSmartMouselookForcedTooltip()
    self:HideSmartMouselookMouseoverHint()
end

function Joypad:StopSmartMouselookReason(reason)
    self:StopSmartMouselook(reason)
end

function Joypad:PulseSmartMouselook(reason, duration)
    EnsureDB()

    reason = tostring(reason or "pulse")
    if JoypadDB.smartMouselookEnabled ~= true or not self:IsSmartMouselookTriggerEnabled(reason) then
        return
    end

    self.smartMouselookPulseTokens = self.smartMouselookPulseTokens or {}
    local token = (self.smartMouselookPulseTokens[reason] or 0) + 1
    self.smartMouselookPulseTokens[reason] = token

    self:StartSmartMouselook(reason)

    JoypadTimerAfter(tonumber(duration or 0.35) or 0.35, function()
        if Joypad and Joypad.smartMouselookPulseTokens and Joypad.smartMouselookPulseTokens[reason] == token then
            Joypad:StopSmartMouselookReason(reason)
        end
    end)
end

function Joypad:SetMovementCursorState(kind, active)
    kind = tostring(kind or "move")

    if active then
        self:StartSmartMouselook(kind)
    else
        self:StopSmartMouselookReason(kind)
    end
end

function Joypad:ClearMovementCursorHide()
    self.movementCursorStates = {}
    self:StopSmartMouselook()
    self:RestoreHardwareCursor("movement")
end
function Joypad.NormalizeSmartMouselookCenterDelay(value)
    value = tostring(value or "")
    if value == "instant" or value == "short" or value == "normal" or value == "long" then
        return value
    end
    return "normal"
end

function Joypad.GetSmartMouselookCenterDelayLabel(value)
    value = Joypad.NormalizeSmartMouselookCenterDelay(value)
    return ((Joypad.smartMouselookCenterDelays or {})[value] or {}).label or "Normal"
end

function Joypad:GetSmartMouselookCenterDelaySeconds()
    EnsureDB()
    local value = Joypad.NormalizeSmartMouselookCenterDelay(JoypadDB.smartMouselookCenterDelay)
    return ((Joypad.smartMouselookCenterDelays or {})[value] or {}).seconds or 0.20
end

function Joypad:SetSmartMouselookCenterDelay(value, silent)
    EnsureDB()

    value = Joypad.NormalizeSmartMouselookCenterDelay(value)
    JoypadDB.smartMouselookCenterDelay = value
    self.smartMouselookCenterStable = 0

    if self.NotifyAceOptionsChanged then
        self:NotifyAceOptionsChanged()
    end

    if not silent then
        Print("smart mouselook centre activation delay set to " .. Joypad.GetSmartMouselookCenterDelayLabel(value) .. ".")
    end
end

function Joypad:GetSmartMouselookCenterScale()
    EnsureDB()

    local value = tonumber(JoypadDB.smartMouselookCenterScale or 100) or 100
    if value < 50 then value = 50 end
    if value > 250 then value = 250 end
    return value
end

function Joypad:SetSmartMouselookCenterScale(value, silent)
    EnsureDB()

    value = tonumber(value or 100) or 100
    value = math.floor(value + 0.5)
    if value < 50 then value = 50 end
    if value > 250 then value = 250 end

    JoypadDB.smartMouselookCenterScale = value
    self:UpdateSmartMouselookCenterPreview(true)

    if self.NotifyAceOptionsChanged then
        self:NotifyAceOptionsChanged()
    end

    if not silent then
        Print("smart mouselook centre zone size set to " .. tostring(value) .. "%.")
    end
end

function Joypad:GetSmartMouselookCenterGeometry()
    local width = (GetScreenWidth and GetScreenWidth()) or 1024
    local height = (GetScreenHeight and GetScreenHeight()) or 768
    local centerX, centerY = nil, nil

    if UIParent and UIParent.GetCenter then
        local okCenter, x, y = pcall(UIParent.GetCenter, UIParent)
        if okCenter then
            centerX, centerY = x, y
        end
    end

    if not centerX or not centerY then
        centerX = width / 2
        centerY = height / 2
    end

    local baseRadius = math.max(42, math.min(width or 1024, height or 768) * 0.055)
    local radius = baseRadius * (self:GetSmartMouselookCenterScale() / 100)

    return centerX, centerY, radius, baseRadius
end

function Joypad:CreateSmartMouselookCenterPreview()
    if self.smartMouselookCenterPreview then
        return
    end

    local frame = CreateFrame("Frame", "JoypadSmartMouselookCenterPreview", UIParent)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(900)
    frame:EnableMouse(false)

    frame.fill = frame:CreateTexture(nil, "BACKGROUND")
    frame.fill:SetAllPoints(frame)
    frame.fill:SetTexture(0.0, 0.85, 1.0, 0.10)

    frame.top = frame:CreateTexture(nil, "OVERLAY")
    frame.top:SetHeight(2)
    frame.top:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)

    frame.bottom = frame:CreateTexture(nil, "OVERLAY")
    frame.bottom:SetHeight(2)
    frame.bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    frame.bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

    frame.left = frame:CreateTexture(nil, "OVERLAY")
    frame.left:SetWidth(2)
    frame.left:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)

    frame.right = frame:CreateTexture(nil, "OVERLAY")
    frame.right:SetWidth(2)
    frame.right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    frame.right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

    frame.crossH = frame:CreateTexture(nil, "OVERLAY")
    frame.crossH:SetHeight(1)
    frame.crossH:SetPoint("LEFT", frame, "LEFT", 0, 0)
    frame.crossH:SetPoint("RIGHT", frame, "RIGHT", 0, 0)

    frame.crossV = frame:CreateTexture(nil, "OVERLAY")
    frame.crossV:SetWidth(1)
    frame.crossV:SetPoint("TOP", frame, "TOP", 0, 0)
    frame.crossV:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0)

    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.label:SetPoint("BOTTOM", frame, "TOP", 0, 4)
    frame.label:SetText("Smart mouselook centre zone")
    frame.label:SetShadowColor(0, 0, 0, 1)
    frame.label:SetShadowOffset(1, -1)

    frame:Hide()
    self.smartMouselookCenterPreview = frame
end

function Joypad:UpdateSmartMouselookCenterPreview(force)
    EnsureDB()

    if JoypadDB.smartMouselookCenterPreview ~= true then
        if self.smartMouselookCenterPreview then
            self.smartMouselookCenterPreview:Hide()
        end
        return
    end

    self:CreateSmartMouselookCenterPreview()
    local frame = self.smartMouselookCenterPreview
    if not frame then
        return
    end

    local centerX, centerY, radius, baseRadius = self:GetSmartMouselookCenterGeometry()
    local size = math.floor((radius * 2) + 0.5)

    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", centerX or 0, centerY or 0)
    frame:SetWidth(size)
    frame:SetHeight(size)

    local r, g, b = JoypadGetPlayerClassColor()
    frame.top:SetTexture(r, g, b, 0.95)
    frame.bottom:SetTexture(r, g, b, 0.95)
    frame.left:SetTexture(r, g, b, 0.95)
    frame.right:SetTexture(r, g, b, 0.95)
    frame.crossH:SetTexture(1, 1, 1, 0.45)
    frame.crossV:SetTexture(1, 1, 1, 0.45)
    frame.label:SetText("Smart mouselook centre zone: " .. tostring(self:GetSmartMouselookCenterScale()) .. "% / " .. Joypad.GetSmartMouselookCenterDelayLabel(JoypadDB.smartMouselookCenterDelay))
    frame:Show()
end

function Joypad:SetSmartMouselookCenterPreviewShown(shown, silent)
    EnsureDB()

    JoypadDB.smartMouselookCenterPreview = shown and true or false
    self:UpdateSmartMouselookCenterPreview(true)

    if self.NotifyAceOptionsChanged then
        self:NotifyAceOptionsChanged()
    end

    if not silent then
        Print(JoypadDB.smartMouselookCenterPreview and "smart mouselook centre zone preview shown." or "smart mouselook centre zone preview hidden.")
    end
end

function Joypad:IsCursorCenteredForSmartMouselook()
    if not GetCursorPosition or not UIParent then
        return false
    end

    local cursorX, cursorY = GetCursorPosition()
    if not cursorX or not cursorY then
        return false
    end

    local scale = 1
    if UIParent.GetEffectiveScale then
        local okScale, detectedScale = pcall(UIParent.GetEffectiveScale, UIParent)
        if okScale and detectedScale and detectedScale ~= 0 then
            scale = detectedScale
        end
    end

    cursorX = cursorX / scale
    cursorY = cursorY / scale

    local centerX, centerY = nil, nil
    if UIParent.GetCenter then
        local okCenter, x, y = pcall(UIParent.GetCenter, UIParent)
        if okCenter then
            centerX, centerY = x, y
        end
    end
    if not centerX or not centerY then
        local width = (GetScreenWidth and GetScreenWidth()) or 0
        local height = (GetScreenHeight and GetScreenHeight()) or 0
        centerX = width / 2
        centerY = height / 2
    end

    local _, _, radius = self:GetSmartMouselookCenterGeometry()

    return math.abs(cursorX - centerX) <= radius and math.abs(cursorY - centerY) <= radius
end

function Joypad:UpdateSmartMouselookCenter(elapsed)
    EnsureDB()

    self.smartMouselookCenterElapsed = (self.smartMouselookCenterElapsed or 0) + (elapsed or 0)
    if self.smartMouselookCenterElapsed < (Joypad.SMART_MOUSELOOK_CENTER_CHECK_INTERVAL or 0.04) then
        return
    end
    local step = self.smartMouselookCenterElapsed
    self.smartMouselookCenterElapsed = 0

    self:UpdateSmartMouselookCenterPreview(false)

    if JoypadDB.smartMouselookEnabled ~= true or JoypadDB.smartMouselookOnCenter ~= true then
        self.smartMouselookCenterStable = 0
        self:StopSmartMouselookReason("center")
        return
    end

    if GetTime and self.smartMouselookCenterSuppressUntil and GetTime() < self.smartMouselookCenterSuppressUntil then
        self.smartMouselookCenterStable = 0
        return
    end

    if self:IsCursorCenteredForSmartMouselook() then
        self.smartMouselookCenterStable = (self.smartMouselookCenterStable or 0) + step
        if self.smartMouselookCenterStable >= self:GetSmartMouselookCenterDelaySeconds() then
            self:StartSmartMouselook("center")
        end
    else
        self.smartMouselookCenterStable = 0
        self:StopSmartMouselookReason("center")
    end
end


function Joypad:SetSmartMouselookEnabled(enabled, silent)
    EnsureDB()

    JoypadDB.smartMouselookEnabled = enabled and true or false
    JoypadDB.hideMouseWhileMoving = JoypadDB.smartMouselookEnabled

    if not JoypadDB.smartMouselookEnabled then
        self:StopSmartMouselook()
        self:RestoreHardwareCursor("movement")
    end

    UpdateSettingsControls()
    if self.NotifyAceOptionsChanged then
        self:NotifyAceOptionsChanged()
    end

    if not silent then
        Print(JoypadDB.smartMouselookEnabled and "smart mouselook enabled." or "smart mouselook disabled.")
    end
end

function Joypad:SetHideMouseWhileMoving(enabled, silent)
    self:SetSmartMouselookEnabled(enabled, silent)
end

function Joypad:InstallSmartMouselookHooks()
    if self.smartMouselookHooksInstalled then
        return
    end
    self.smartMouselookHooksInstalled = true

    local function HookFunction(functionName, callback)
        if not hooksecurefunc or not functionName or type(_G[functionName]) ~= "function" then
            return
        end
        pcall(function()
            hooksecurefunc(functionName, callback)
        end)
    end

    local function StartReason(reason)
        if Joypad then
            Joypad:StartSmartMouselook(reason)
        end
    end

    local function StopReason(reason)
        if Joypad then
            Joypad:StopSmartMouselookReason(reason)
        end
    end

    -- ConsolePort-style movement hooks. These are more reliable than the
    -- PLAYER_STARTED_* events on older 3.3.5 clients and run from the actual
    -- movement input path, which gives MouselookStart the best chance of
    -- succeeding.
    HookFunction("MoveForwardStart", function() StartReason("move") end)
    HookFunction("MoveBackwardStart", function() StartReason("move") end)
    HookFunction("MoveForwardStop", function() StopReason("move") end)
    HookFunction("MoveBackwardStop", function() StopReason("move") end)

    HookFunction("StrafeLeftStart", function() StartReason("strafe") end)
    HookFunction("StrafeRightStart", function() StartReason("strafe") end)
    HookFunction("StrafeLeftStop", function() StopReason("strafe") end)
    HookFunction("StrafeRightStop", function() StopReason("strafe") end)

    HookFunction("TurnLeftStart", function() StartReason("turn") end)
    HookFunction("TurnRightStart", function() StartReason("turn") end)
    HookFunction("TurnLeftStop", function() StopReason("turn") end)
    HookFunction("TurnRightStop", function() StopReason("turn") end)

    HookFunction("PitchUpStart", function() StartReason("look") end)
    HookFunction("PitchDownStart", function() StartReason("look") end)
    HookFunction("PitchUpStop", function() StopReason("look") end)
    HookFunction("PitchDownStop", function() StopReason("look") end)

    HookFunction("AscendStop", function() StopReason("vertical") end)
    HookFunction("DescendStop", function() StopReason("vertical") end)

    HookFunction("JumpOrAscendStart", function()
        if Joypad then
            Joypad:PulseSmartMouselook("jump", 0.35)
        end
    end)
end

function Joypad:UpdateUICursorPointer(target)
    EnsureDB()
    self:CreateUICursorPointer()
    self:ApplyUICursorClassColor()

    local pointer = self.uiCursorPointer
    if not pointer then
        return
    end

    if JoypadDB.uiCursorShowPointer ~= true or not target then
        pointer:Hide()
        return
    end

    pointer:ClearAllPoints()

    local okWidth, width = JoypadFrameCall(target, "GetWidth")
    local okHeight, height = JoypadFrameCall(target, "GetHeight")
    if not okWidth then width = 0 end
    if not okHeight then height = 0 end
    if (width and width < 26) or (height and height < 26) then
        pointer:SetPoint("LEFT", target, "RIGHT", -4, 0)
    else
        pointer:SetPoint("LEFT", target, "RIGHT", -2, 0)
    end

    pointer:Show()
end

function Joypad:UpdateUICursorHighlight()
    EnsureDB()
    self:CreateUICursorHighlight()
    self:ApplyUICursorClassColor()

    local frame = self.uiCursorHighlight
    local selected = self.uiCursorSelected

    if not frame then
        return
    end

    if JoypadDB.uiCursorShowHighlight == false or not self.uiCursorActive or not JoypadFrameIsShown(selected) then
        frame:Hide()
        self:UpdateUICursorPointer(nil)
        self:RestoreHardwareCursor("uiCursor")
        self:StopSmartMouselook()
        return
    end

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", selected, "TOPLEFT", -4, 4)
    frame:SetPoint("BOTTOMRIGHT", selected, "BOTTOMRIGHT", 4, -4)
    frame:Show()

    self:UpdateUICursorPointer(selected)
    self:TryHideHardwareCursor()
end

function Joypad:SelectNearestUICursorNode()
    local candidates = GetJoypadUICursorCandidates()
    if table.getn(candidates) == 0 then
        self.uiCursorSelected = nil
        self:UpdateUICursorHighlight()
        return nil
    end

    local refX, refY = nil, nil
    if JoypadFrameIsShown(self.uiCursorSelected) then
        refX, refY = GetJoypadFrameCenter(self.uiCursorSelected)
    end
    if not refX or not refY then
        refX, refY = GetCursorPosition()
        local scale = 1
        if JoypadFrameHasMethod(UIParent, "GetEffectiveScale") then
            local okScale, detectedScale = JoypadFrameCall(UIParent, "GetEffectiveScale")
            if okScale and detectedScale then scale = detectedScale end
        end
        if refX and refY and scale and scale ~= 0 then
            refX = refX / scale
            refY = refY / scale
        end
    end
    if not refX or not refY then
        refX, refY = 0, 0
        if JoypadFrameHasMethod(UIParent, "GetCenter") then
            local okCenter, x, y = JoypadFrameCall(UIParent, "GetCenter")
            if okCenter then refX, refY = x, y end
        end
        refX = refX or 0
        refY = refY or 0
    end

    local best, bestScore, bestPriority
    for _, frame in ipairs(candidates) do
        local x, y = GetJoypadFrameCenter(frame)
        if x and y then
            local dx = math.abs(x - refX)
            local dy = math.abs(y - refY)
            local score = dx + dy
            local priority = frame.hasPriority and true or false

            if priority and not bestPriority then
                best = frame
                bestScore = score
                bestPriority = true
            elseif not best or (priority == bestPriority and score < bestScore) then
                best = frame
                bestScore = score
                bestPriority = priority
            end
        end
    end

    self.uiCursorSelected = best
    self:UpdateUICursorHighlight()
    return best
end

function Joypad:MoveUICursor(direction)
    if not self.uiCursorActive then
        self:UIDebugLog("move ignored; UI cursor inactive")
        return
    end

    direction = string.upper(tostring(direction or ""))
    local candidates = GetJoypadUICursorCandidates()
    self:UIDebugLog("input: move " .. direction .. " (" .. tostring(table.getn(candidates)) .. " candidates; " .. GetJoypadUICursorScanDebugText() .. ")")
    if table.getn(candidates) == 0 then
        self.uiCursorSelected = nil
        self:UpdateUICursorHighlight()
        self:UIDebugLog("move " .. direction .. ": 0 candidates; " .. GetJoypadUICursorScanDebugText())
        return
    end

    if not IsJoypadUICursorSelectedValid() then
        self:UIDebugLog("move " .. direction .. ": selected node invalid; selecting nearest")
        local nearest = self:SelectNearestUICursorNode()
        self:UIDebugLog("move " .. direction .. ": nearest is " .. GetJoypadDebugFrameName(nearest))
        return
    end

    local current = self.uiCursorSelected
    local cx, cy = GetJoypadFrameCenter(current)
    if not cx or not cy then
        local nearest = self:SelectNearestUICursorNode()
        self:UIDebugLog("move " .. direction .. ": current had no centre; nearest is " .. GetJoypadDebugFrameName(nearest))
        return
    end

    local best, bestScore
    local fallbackBest, fallbackScore
    local scalar = JOYPAD_UI_CURSOR_NODE.scalar or 3

    for _, frame in ipairs(candidates) do
        if frame ~= current then
            local x, y = GetJoypadFrameCenter(frame)
            if x and y then
                local dx = x - cx
                local dy = y - cy
                local absX = math.abs(dx)
                local absY = math.abs(dy)
                local directionOK = false
                local distanceOK = false
                local score = nil

                if direction == "UP" and dy > 0 then
                    directionOK = true
                    distanceOK = absX < absY
                    score = (absX * scalar * absX * scalar) + (absY * absY)
                elseif direction == "DOWN" and dy < 0 then
                    directionOK = true
                    distanceOK = absX < absY
                    score = (absX * scalar * absX * scalar) + (absY * absY)
                elseif direction == "RIGHT" and dx > 0 then
                    directionOK = true
                    distanceOK = absY < absX
                    score = (absX * absX) + (absY * scalar * absY * scalar)
                elseif direction == "LEFT" and dx < 0 then
                    directionOK = true
                    distanceOK = absY < absX
                    score = (absX * absX) + (absY * scalar * absY * scalar)
                end

                if directionOK and score then
                    if distanceOK and (not bestScore or score < bestScore) then
                        best = frame
                        bestScore = score
                    end
                    if not fallbackScore or score < fallbackScore then
                        fallbackBest = frame
                        fallbackScore = score
                    end
                end
            end
        end
    end

    local target = best or fallbackBest
    if target then
        self.uiCursorSelected = target
        self:UIDebugLog("move " .. direction .. ": " .. GetJoypadDebugFrameName(current) .. " -> " .. GetJoypadDebugFrameName(target))
    else
        self:UIDebugLog("move " .. direction .. ": no node in that direction from " .. GetJoypadDebugFrameName(current))
    end

    self:UpdateUICursorHighlight()
end

function Joypad:CloseTopUICursorWindow()
    if InCombat() then
        self:UIDebugLog("close: ignored in combat")
        return false
    end

    if UIDROPDOWNMENU_OPEN_MENU and JoypadFrameIsShown(UIDROPDOWNMENU_OPEN_MENU) then
        if HideDropDownMenu then
            HideDropDownMenu(1)
        elseif UIDROPDOWNMENU_OPEN_MENU.Hide then
            UIDROPDOWNMENU_OPEN_MENU:Hide()
        end
        self.uiCursorSelected = nil
        self:UpdateUICursorActivation(true)
        self:UIDebugLog("close: dropdown menu")
        return true
    end

    if StaticPopup_EscapePressed then
        for i = 1, 4 do
            local popup = _G["StaticPopup" .. tostring(i)]
            if JoypadFrameIsShown(popup) then
                StaticPopup_EscapePressed()
                self.uiCursorSelected = nil
                self:UpdateUICursorActivation(true)
                self:UIDebugLog("close: static popup")
                return true
            end
        end
    end

    if CloseMenus then
        CloseMenus()
    end

    if CloseSpecialWindows then
        local closed = CloseSpecialWindows()
        if closed then
            self.uiCursorSelected = nil
            self:UpdateUICursorActivation(true)
            self:UIDebugLog("close: special window")
            return true
        end
    end

    JoypadUpdateUICursorFrameStack()

    local best, bestScore
    for frame in pairs(JOYPAD_UI_CURSOR_STACK.visible) do
        if frame and frame.Hide and JoypadFrameIsShown(frame) and not IsJoypadUICursorExcludedFrame(frame) then
            local score = JoypadGetFrameLevelScore(frame)
            if not bestScore or score > bestScore then
                best = frame
                bestScore = score
            end
        end
    end

    if best then
        local name = nil
        if JoypadFrameHasMethod(best, "GetName") then
            local okName, detectedName = JoypadFrameCall(best, "GetName")
            if okName then name = detectedName end
        end
        if HideUIPanel and name and UIPanelWindows and UIPanelWindows[name] then
            HideUIPanel(best)
        else
            best:Hide()
        end
        self.uiCursorSelected = nil
        self:UpdateUICursorActivation(true)
        self:UIDebugLog("close: " .. GetJoypadDebugFrameName(best))
        return true
    end

    self:UIDebugLog("close: no visible window found")
    return false
end

local function FindJoypadScrollableFrame(frame)
    local current = frame
    while current and current ~= UIParent do
        if JoypadFrameHasMethod(current, "GetVerticalScroll") and JoypadFrameHasMethod(current, "SetVerticalScroll") then
            return current, nil
        end

        local scrollBar = current.scrollBar or current.ScrollBar
        if not scrollBar and JoypadFrameHasMethod(current, "GetName") then
            local okName, name = JoypadFrameCall(current, "GetName")
            if okName and name then
                scrollBar = _G[name .. "ScrollBar"] or _G[name .. "ScrollBarScrollBar"]
            end
        end
        if scrollBar and JoypadFrameHasMethod(scrollBar, "GetValue") and JoypadFrameHasMethod(scrollBar, "SetValue") then
            return current, scrollBar
        end

        if JoypadFrameHasMethod(current, "GetParent") then
            local okParent, parent = JoypadFrameCall(current, "GetParent")
            current = okParent and parent or nil
        else
            current = nil
        end
    end

    return nil, nil
end

function Joypad:ScrollUICursorSelection(delta)
    if not self.uiCursorActive then
        self:UIDebugLog("scroll ignored; UI cursor inactive")
        return
    end

    if not IsJoypadUICursorSelectedValid() then
        self:UIDebugLog("scroll: selected node invalid; selecting nearest")
        local nearest = self:SelectNearestUICursorNode()
        self:UIDebugLog("scroll: nearest is " .. GetJoypadDebugFrameName(nearest))
    end

    local selected = self.uiCursorSelected
    local scrollFrame, scrollBar = FindJoypadScrollableFrame(selected)
    delta = tonumber(delta or 0) or 0
    local candidateCount = table.getn(GetJoypadUICursorCandidates())
    self:UIDebugLog("input: scroll " .. tostring(delta) .. " on " .. GetJoypadDebugFrameName(selected) .. " (" .. tostring(candidateCount) .. " candidates; " .. GetJoypadUICursorScanDebugText() .. ")")

    if scrollBar then
        self:UIDebugLog("scroll target: scrollbar for " .. GetJoypadDebugFrameName(scrollFrame))
        local minValue, maxValue = 0, 0
        if JoypadFrameHasMethod(scrollBar, "GetMinMaxValues") then
            local okMinMax, detectedMin, detectedMax = JoypadFrameCall(scrollBar, "GetMinMaxValues")
            if okMinMax then
                minValue, maxValue = detectedMin or 0, detectedMax or 0
            end
        end
        local okValue, detectedValue = JoypadFrameCall(scrollBar, "GetValue")
        local value = ((okValue and detectedValue) or 0) + delta
        if value < minValue then value = minValue end
        if value > maxValue then value = maxValue end
        if JoypadFrameHasMethod(scrollBar, "SetValue") then
            JoypadFrameCall(scrollBar, "SetValue", value)
        end
    elseif scrollFrame then
        self:UIDebugLog("scroll target: " .. GetJoypadDebugFrameName(scrollFrame))
        local okScroll, current = JoypadFrameCall(scrollFrame, "GetVerticalScroll")
        current = (okScroll and current) or 0
        local maxValue = 0
        if JoypadFrameHasMethod(scrollFrame, "GetVerticalScrollRange") then
            local okRange, detectedRange = JoypadFrameCall(scrollFrame, "GetVerticalScrollRange")
            maxValue = (okRange and detectedRange) or 0
        end
        local value = current + delta
        if value < 0 then value = 0 end
        if maxValue and value > maxValue then value = maxValue end
        if JoypadFrameHasMethod(scrollFrame, "SetVerticalScroll") then
            JoypadFrameCall(scrollFrame, "SetVerticalScroll", value)
        end
    else
        self:UIDebugLog("scroll: no scrollable parent found")
    end

    self:UpdateUICursorHighlight()
end

function Joypad:ClickUICursorSelection(mouseButton)
    if not self.uiCursorActive then
        self:UIDebugLog("click ignored; UI cursor inactive")
        return
    end

    if not IsJoypadUICursorSelectedValid() then
        self:UIDebugLog("click: selected node invalid; selecting nearest")
        local nearest = self:SelectNearestUICursorNode()
        self:UIDebugLog("click: nearest is " .. GetJoypadDebugFrameName(nearest))
    end

    local selected = self.uiCursorSelected
    if not selected then
        self:UIDebugLog("click: no selected node; " .. GetJoypadUICursorScanDebugText())
        return
    end

    mouseButton = mouseButton or "LeftButton"
    local candidateCount = table.getn(GetJoypadUICursorCandidates())
    self:UIDebugLog("input: " .. tostring(mouseButton) .. " click on " .. GetJoypadDebugFrameName(selected) .. " (" .. tostring(candidateCount) .. " candidates; " .. GetJoypadUICursorScanDebugText() .. ")")

    local objectType = JoypadFrameObjectType(selected)
    if objectType == "EditBox" and mouseButton == "LeftButton" and JoypadFrameHasMethod(selected, "SetFocus") then
        selected:SetFocus()
        self:UIDebugLog("focused edit box: " .. GetJoypadDebugFrameName(selected))
        self:UpdateUICursorHighlight()
        return
    end

    if JoypadFrameHasMethod(selected, "Click") then
        selected:Click(mouseButton)
    else
        local onMouseDown, onMouseUp, onClick = nil, nil, nil
        if JoypadFrameHasMethod(selected, "GetScript") then
            local okDown, detectedDown = JoypadFrameCall(selected, "GetScript", "OnMouseDown")
            local okUp, detectedUp = JoypadFrameCall(selected, "GetScript", "OnMouseUp")
            local okClick, detectedClick = JoypadFrameCall(selected, "GetScript", "OnClick")
            if okDown then onMouseDown = detectedDown end
            if okUp then onMouseUp = detectedUp end
            if okClick then onClick = detectedClick end
        end
        if onMouseDown then onMouseDown(selected, mouseButton) end
        if onMouseUp then onMouseUp(selected, mouseButton) end
        if onClick then onClick(selected, mouseButton) end
    end

    self:UpdateUICursorHighlight()
end

function Joypad:CreateUICursorBindingFrame()
    if self.uiCursorFrame then
        return
    end

    local frame = CreateFrame("Frame", "JoypadUICursorBindingFrame", UIParent)
    frame.buttons = {}

    for _, control in ipairs(JOYPAD_UI_CURSOR_CONTROLS) do
        local button = CreateFrame("Button", "JoypadUICursor" .. control.name .. "Button", UIParent)
        button:RegisterForClicks("AnyUp")
        button.control = control
        button:SetScript("OnClick", function(selfButton)
            local c = selfButton.control
            if not c then
                return
            end

            Joypad:UIDebugLog("button: " .. tostring(c.name or "?") .. " via " .. tostring(c.bindingCommand or "?"))
            if c.direction then
                Joypad:MoveUICursor(c.direction)
            elseif c.clickButton then
                Joypad:ClickUICursorSelection(c.clickButton)
            elseif c.closeWindow then
                Joypad:CloseTopUICursorWindow()
            elseif c.scroll then
                Joypad:ScrollUICursorSelection(c.scroll)
            end
        end)
        frame.buttons[control.name] = button
    end

    self.uiCursorFrame = frame
end

function Joypad:ShouldUICursorBeActive()
    EnsureDB()

    if JoypadDB.uiCursorEnabled ~= true then
        return false
    end

    if InCombat() then
        return false
    end

    if JoypadDB.uiCursorPanelsOnly ~= false and not IsJoypadUIPanelVisible() then
        return false
    end

    return true
end

function Joypad:ApplyUICursorBindings()
    self:CreateUICursorBindingFrame()

    if not self.uiCursorFrame or not ClearOverrideBindings then
        return
    end

    ClearOverrideBindings(self.uiCursorFrame)
    self.uiCursorBindingsApplied = false

    if not GetBindingKey or not SetOverrideBindingClick then
        return
    end

    local applied = 0
    for _, control in ipairs(JOYPAD_UI_CURSOR_CONTROLS) do
        local targetButton = self.uiCursorFrame.buttons and self.uiCursorFrame.buttons[control.name]
        local targetName = nil
        if JoypadFrameHasMethod(targetButton, "GetName") then
            local okName, detectedName = JoypadFrameCall(targetButton, "GetName")
            if okName then targetName = detectedName end
        end
        if targetName then
            local commands = { control.bindingCommand }
            if type(control.fallbackCommands) == "table" then
                for _, fallbackCommand in ipairs(control.fallbackCommands) do
                    table.insert(commands, fallbackCommand)
                end
            end

            local seenKeys = {}
            for _, command in ipairs(commands) do
                local keys = { GetBindingKey(command) }
                for _, key in ipairs(keys) do
                    if key and key ~= "" and not seenKeys[key] then
                        seenKeys[key] = true
                        SetOverrideBindingClick(self.uiCursorFrame, true, key, targetName, "LeftButton")
                        self.uiCursorBindingsApplied = true
                        applied = applied + 1
                        -- Quiet: binding override setup is not an input event.
                    end
                end
            end
        end
    end
    -- Quiet: binding override setup is not an input event.
end

function Joypad:ClearUICursorBindings(silent)
    if self.uiCursorFrame and ClearOverrideBindings then
        if pcall then
            local ok, err = pcall(ClearOverrideBindings, self.uiCursorFrame)
            if not ok and not silent then
                Print("could not clear UI cursor bindings: " .. tostring(err))
            end
        else
            ClearOverrideBindings(self.uiCursorFrame)
        end
    end
    self.uiCursorBindingsApplied = false
end

function Joypad:RepairInputBindings(silent)
    EnsureDB()

    -- The UI cursor intentionally captures Joypad physical keys when it is
    -- active. For input recovery, turn it off first so the action-button
    -- override owner becomes the only owner for those keys.
    JoypadDB.uiCursorEnabled = false
    JoypadDB.smartMouselookEnabled = false
    JoypadDB.hideMouseWhileMoving = false
    self.uiCursorActive = false
    self:ClearUICursorBindings(true)
    self:StopSmartMouselook()

    if InCombat() then
        self.pendingBindingOverrides = true
        if not silent then
            Print("input repair queued until combat ends; UI cursor disabled.")
        end
        return
    end

    JoypadRepairDefaultPhysicalKeybinds(true)
    ApplyJoypadBindingOverrides(true)
    self:UpdateUICursorActivation(true)

    if not silent then
        Print("input bindings repaired; UI cursor disabled.")
    end
end


function Joypad:UpdateUICursorActivation(force)
    EnsureDB()

    local wasActive = self.uiCursorActive == true

    if InCombat() then
        self.uiCursorActive = false
        if self.uiCursorBindingsApplied then
            self:ClearUICursorBindings(true)
        end
        if self.uiCursorHighlight then
            self.uiCursorHighlight:Hide()
        end
        if self.uiCursorPointer then
            self.uiCursorPointer:Hide()
        end
        self:RestoreHardwareCursor("uiCursor")
        if wasActive or force then
            -- Quiet: activation changes are not input events.
        end
        return
    end

    local active = self:ShouldUICursorBeActive()
    if active then
        if force or not self.uiCursorActive or not self.uiCursorBindingsApplied then
            self:ApplyUICursorBindings()
        end
        self.uiCursorActive = true
        if not IsJoypadUICursorSelectedValid() then
            self:SelectNearestUICursorNode()
        else
            self:UpdateUICursorHighlight()
        end
        if not wasActive or force then
            -- Quiet: activation changes are not input events.
        end
    else
        if self.uiCursorActive or self.uiCursorBindingsApplied or force then
            self:ClearUICursorBindings()
        end
        self.uiCursorActive = false
        if self.uiCursorHighlight then
            self.uiCursorHighlight:Hide()
        end
        if self.uiCursorPointer then
            self.uiCursorPointer:Hide()
        end
        self:RestoreHardwareCursor("uiCursor")
        if wasActive or force then
            -- Quiet: activation changes are not input events.
        end
    end
end

function Joypad:SetUICursorEnabled(enabled, silent)
    EnsureDB()
    JoypadDB.uiCursorEnabled = enabled and true or false
    self:UpdateUICursorActivation(true)
    UpdateSettingsControls()
    if not silent then
        Print(JoypadDB.uiCursorEnabled and "UI cursor enabled." or "UI cursor disabled.")
    end
end


JOYPAD_CORE_KEYBINDS = {
    -- Non-numpad Joypad defaults. Numpad is intentionally avoided because it
    -- conflicts on some layouts/devices.
    { key = "`", command = "CLICK JoypadButton1:LeftButton" },  -- A
    { key = "\\", command = "CLICK JoypadButton2:LeftButton" },  -- B
    { key = ";", command = "CLICK JoypadButton3:LeftButton" },  -- X
    { key = "'", command = "CLICK JoypadButton4:LeftButton" },  -- Y

    { key = ",", command = "CLICK JoypadButton5:LeftButton" },  -- D-Pad Up
    { key = ".", command = "CLICK JoypadButton6:LeftButton" },  -- D-Pad Left
    { key = "J", command = "CLICK JoypadButton7:LeftButton" },  -- D-Pad Right
    { key = "X", command = "CLICK JoypadButton8:LeftButton" },  -- D-Pad Down

    { key = "[", command = "CLICK JoypadButton9:LeftButton" },  -- L1
    { key = "]", command = "CLICK JoypadButton10:LeftButton" },  -- R1

    { key = "F6", command = "CLICK JoypadButton11:LeftButton" },  -- Select / View
    { key = "F7", command = "CLICK JoypadButton12:LeftButton" },  -- Start / Menu
}

JOYPAD_EXTENDED_KEYBINDS = {
    -- Extended Joypad defaults. These replace a few default panels/movement
    -- binds plus bag binds so the full 24-button set avoids numpad.
    { key = "Z", command = "CLICK JoypadButton13:LeftButton" },  -- Trackpad-L Up
    { key = "U", command = "CLICK JoypadButton14:LeftButton" },  -- Trackpad-L Left
    { key = "K", command = "CLICK JoypadButton15:LeftButton" },  -- Trackpad-L Right
    { key = "H", command = "CLICK JoypadButton16:LeftButton" },  -- Trackpad-L Down

    { key = "Q", command = "CLICK JoypadButton17:LeftButton" },  -- Trackpad-R Up
    { key = "E", command = "CLICK JoypadButton18:LeftButton" },  -- Trackpad-R Left
    { key = "V", command = "CLICK JoypadButton19:LeftButton" },  -- Trackpad-R Right
    { key = "F12", command = "CLICK JoypadButton20:LeftButton" },  -- Trackpad-R Down

    { key = "F8", command = "CLICK JoypadButton21:LeftButton" },  -- L4
    { key = "F9", command = "CLICK JoypadButton22:LeftButton" },  -- R4
    { key = "F10", command = "CLICK JoypadButton23:LeftButton" },  -- L5
    { key = "F11", command = "CLICK JoypadButton24:LeftButton" },  -- R5
}

JOYPAD_ALL_DEFAULT_KEYBINDS = {
    JOYPAD_CORE_KEYBINDS,
    JOYPAD_EXTENDED_KEYBINDS,
}

JOYPAD_KEY_BINDING_ALIASES = {
    [";"] = { ";", "SEMICOLON" },
    ["'"] = { "'", "APOSTROPHE" },
    ["\\"] = { "\\", "BACKSLASH" },
    [","] = { ",", "COMMA" },
    ["."] = { ".", "PERIOD" },
    ["`"] = { "`", "GRAVE" },
}

function JoypadGetKeyBindingCandidates(key)
    key = tostring(key or "")
    local aliases = JOYPAD_KEY_BINDING_ALIASES and JOYPAD_KEY_BINDING_ALIASES[key]
    if type(aliases) == "table" then
        return aliases
    end
    return { key }
end

function JoypadKeyMatchesCandidate(boundKey, expectedKey)
    boundKey = tostring(boundKey or "")
    for _, candidate in ipairs(JoypadGetKeyBindingCandidates(expectedKey)) do
        if boundKey == tostring(candidate or "") then
            return true
        end
    end
    return false
end

function JoypadCandidateKeysText(key)
    return table.concat(JoypadGetKeyBindingCandidates(key), " / ")
end

function JoypadSetBindingCandidateKeys(key, command)
    if not SetBinding or not key or not command then
        return 0
    end

    local touched = 0
    for _, candidate in ipairs(JoypadGetKeyBindingCandidates(key)) do
        if candidate and candidate ~= "" then
            if pcall then
                pcall(function() SetBinding(candidate) end)
                local ok, result = pcall(function() return SetBinding(candidate, command) end)
                if ok and result ~= false then
                    touched = touched + 1
                end
            else
                SetBinding(candidate)
                SetBinding(candidate, command)
                touched = touched + 1
            end
        end
    end
    return touched
end

-- v0.44.58: keep these helpers non-local; Wrath Lua chunks have a 200-local limit.
function JoypadIterateDefaultKeybinds(callback)
    if type(callback) ~= "function" then
        return
    end

    for _, bindingSet in ipairs(JOYPAD_ALL_DEFAULT_KEYBINDS or {}) do
        for _, binding in ipairs(bindingSet or {}) do
            callback(binding)
        end
    end
end

function GetJoypadDefaultKeyForCommand(command)
    command = tostring(command or "")
    local found = nil
    JoypadIterateDefaultKeybinds(function(binding)
        if not found and binding and binding.command == command then
            found = binding.key
        end
    end)
    return found
end

function GetJoypadDefaultKeyForSlot(joypadSlot)
    local bindingCommand = GetJoypadListeningBindingCommand(joypadSlot)
    return GetJoypadDefaultKeyForCommand(bindingCommand)
end

function JoypadHasBindingKey(command, key)
    if not GetBindingKey or not command or not key then
        return false
    end

    local keys = { GetBindingKey(command) }
    for _, boundKey in ipairs(keys) do
        if JoypadKeyMatchesCandidate(boundKey, key) then
            return true
        end
    end
    return false
end

function JoypadRepairDefaultPhysicalKeybinds(silent)
    if not SetBinding then
        if not silent then
            Print("this client does not expose the keybinding API.")
        end
        return false
    end

    local touched = 0
    JoypadIterateDefaultKeybinds(function(binding)
        if binding and binding.key and binding.command then
            ClearBindingCommandKeys(binding.command)
        end
    end)

    JoypadIterateDefaultKeybinds(function(binding)
        if binding and binding.key and binding.command then
            touched = touched + JoypadSetBindingCandidateKeys(binding.key, binding.command)
        end
    end)

    if SaveBindings then
        local bindingSet = 2
        if GetCurrentBindingSet then
            bindingSet = GetCurrentBindingSet()
        end
        SaveBindings(bindingSet)
    end

    if not silent then
        Print("repaired " .. tostring(touched) .. " Joypad physical keybind(s).")
    end

    return true
end

function ClearBindingCommandKeys(command)
    if not GetBindingKey or not SetBinding then
        return
    end

    local keys = { GetBindingKey(command) }
    for _, key in ipairs(keys) do
        if key and key ~= "" then
            SetBinding(key)
        end
    end
end

function Joypad:ClearNormalActionBars()
    if InCombat() then
        Print("cannot clear action bars while in combat.")
        return
    end

    if not PickupAction or not ClearCursor then
        Print("this client does not expose the action-bar clearing API.")
        return
    end

    ClearCursor()

    local cleared = 0
    for slot = 1, 120 do
        if not HasAction or HasAction(slot) then
            PickupAction(slot)
            ClearCursor()
            cleared = cleared + 1
        end
    end

    if self.Apply then
        self:Apply(true)
    end
    UpdateSettingsRows()

    Print("cleared action-bar slots 1-120.")
end


function Joypad:ResetAddonSettings()
    if InCombat() then
        Print("cannot reset Joypad while in combat.")
        return
    end

    JoypadDB = {}
    EnsureDB()

    if self.Apply then
        self:Apply(true)
    end
    UpdateSettingsRows()
    UpdateSettingsControls()
    UpdateEditMode()

    Print("Joypad settings reset to defaults.")
end

function Joypad:ApplyJoypadKeybindSet(bindings, label)
    if InCombat() then
        Print("cannot change keybindings while in combat.")
        return
    end

    if not SetBinding then
        Print("this client does not expose the keybinding API.")
        return
    end

    if type(bindings) ~= "table" then
        return
    end

    for _, binding in ipairs(bindings) do
        if binding.command then
            ClearBindingCommandKeys(binding.command)
        end
    end

    for _, binding in ipairs(bindings) do
        if binding.key and binding.command then
            -- Clear whatever the physical key currently does, then bind it to
            -- Joypad's standard Blizzard Key Bindings entry. For punctuation keys
            -- also bind Wrath's named token aliases such as SEMICOLON.
            JoypadSetBindingCandidateKeys(binding.key, binding.command)
        end
    end

    if SaveBindings then
        local bindingSet = 2
        if GetCurrentBindingSet then
            bindingSet = GetCurrentBindingSet()
        end
        SaveBindings(bindingSet)
    end

    ApplyJoypadBindingOverrides(true)
    if self.Apply then
        self:Apply(true)
    end
    UpdateSettingsRows()

    Print("applied " .. tostring(label or "Joypad") .. " keybinds in Blizzard keybindings.")
end

function Joypad:ApplyCoreControllerKeybinds()
    self:ApplyJoypadKeybindSet(JOYPAD_CORE_KEYBINDS, "Core controller")
end

function Joypad:ApplyExtendedControllerKeybinds()
    self:ApplyJoypadKeybindSet(JOYPAD_EXTENDED_KEYBINDS, "Extended controller")
end

-- Backwards-compatible helper: apply both default groups if anything still
-- calls the old maintenance function.
function Joypad:ApplyScreenshotKeybinds()
    if InCombat() then
        Print("cannot change keybindings while in combat.")
        return
    end

    for _, bindings in ipairs(JOYPAD_ALL_DEFAULT_KEYBINDS) do
        self:ApplyJoypadKeybindSet(bindings, "Joypad default")
    end
end

local function ShowJoypadConfirmDialog(dialogKey, text, acceptText, onAccept)
    if StaticPopupDialogs and StaticPopup_Show then
        StaticPopupDialogs[dialogKey] = {
            text = text,
            button1 = acceptText or "Accept",
            button2 = "Cancel",
            OnAccept = onAccept,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1,
            preferredIndex = 3,
        }
        StaticPopup_Show(dialogKey)
    elseif type(onAccept) == "function" then
        onAccept()
    end
end

function Joypad:ConfirmClearNormalActionBars()
    ShowJoypadConfirmDialog(
        "JOYPAD_CLEAR_NORMAL_ACTION_BARS",
        "Clear action-bar slots 1-120? This removes spells, items, and macros from normal and bonus/form action slots.",
        "Clear",
        function() Joypad:ClearNormalActionBars() end
    )
end

function Joypad:ConfirmResetAddonSettings()
    ShowJoypadConfirmDialog(
        "JOYPAD_RESET_ADDON_SETTINGS",
        "Reset Joypad settings to defaults? This resets layout, visibility, colours, scales, and Joypad layer assignments.",
        "Reset",
        function() Joypad:ResetAddonSettings() end
    )
end

function Joypad:ConfirmCenterJoypadLayout()
    ShowJoypadConfirmDialog(
        "JOYPAD_CENTER_JOYPAD_LAYOUT",
        "Centre Joypad on screen?\n\nThis keeps the current button spacing and simply moves the visible Joypad layout to the centre of the screen.",
        "Centre",
        function() Joypad:CenterJoypadLayout(false) end
    )
end


function Joypad:ConfirmApplyLayoutProfile(profileName)
    ShowJoypadConfirmDialog(
        "JOYPAD_APPLY_LAYOUT_PROFILE_" .. string.upper(tostring(profileName or "")),
        "Apply " .. tostring(profileName or "") .. " profile?\n\nThis will overwrite Joypad layout, scale, visibility, Touch Bar, diamond-slot, and profile binding settings.",
        "Apply",
        function() Joypad:ApplyLayoutProfile(profileName, false) end
    )
end

function Joypad:ConfirmApplyCoreControllerKeybinds()
    ShowJoypadConfirmDialog(
        "JOYPAD_APPLY_CORE_CONTROLLER_KEYBINDS",
        "Apply Core controller keybinds?\n\nUses the 12 core non-numpad Joypad defaults.",
        "Apply",
        function() Joypad:ApplyCoreControllerKeybinds() end
    )
end

function Joypad:ConfirmApplyExtendedControllerKeybinds()
    ShowJoypadConfirmDialog(
        "JOYPAD_APPLY_EXTENDED_CONTROLLER_KEYBINDS",
        "Apply Extended controller keybinds?\n\nUses the 12 extended non-numpad Joypad defaults, including F8-F12 and selected default panel/movement binds.",
        "Apply",
        function() Joypad:ApplyExtendedControllerKeybinds() end
    )
end

-- Backwards-compatible confirmation for the previous single-button flow.
function Joypad:ConfirmApplyScreenshotKeybinds()
    ShowJoypadConfirmDialog(
        "JOYPAD_APPLY_SCREENSHOT_KEYBINDS",
        "Apply both Joypad default keybind groups?",
        "Apply",
        function() Joypad:ApplyScreenshotKeybinds() end
    )
end



function Joypad:SetLayoutMode(layoutMode, silent)
    EnsureDB()

    layoutMode = string.lower(tostring(layoutMode or ""))
    if layoutMode ~= "gamepad" and layoutMode ~= "desktop" then
        return
    end

    JoypadDB.layoutMode = layoutMode

    if layoutMode == "gamepad" then
        self:SetBarsVisible(true, true)
        self:SetBlizzardBarsHidden(true, true)
    else
        self:SetBarsVisible(false, true)
        self:SetBlizzardBarsHidden(false, true)
    end

    UpdateSettingsControls()
    UpdateEditMode()

    if not silent then
        if layoutMode == "gamepad" then
            Print("Gamepad layout enabled: Joypad bars shown and Blizzard action bars hidden.")
        else
            Print("Desktop layout enabled: Joypad bars hidden and Blizzard action bars shown.")
        end
    end
end



function Joypad:SafeOptionName(value, fallback)
    if type(value) == "string" or type(value) == "function" then
        return value
    end
    return fallback or "Option"
end

function Joypad:GetAceOptionLibraries()
    if not LibStub then
        Print("AceConfig libraries are not loaded; Joypad options child pages cannot be registered.")
        return nil, nil
    end

    local AceConfig = LibStub("AceConfig-3.0", true)
    local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)

    if not AceConfig or not AceConfigDialog then
        Print("AceConfig-3.0 and AceConfigDialog-3.0 are required for Joypad child options pages.")
        return nil, nil
    end

    return AceConfig, AceConfigDialog
end

function Joypad:NotifyAceOptionsChanged()
    if not LibStub then
        return
    end
    local AceRegistry = LibStub("AceConfigRegistry-3.0", true)
    if AceRegistry and AceRegistry.NotifyChange then
        AceRegistry:NotifyChange("Joypad")
    end
end

function Joypad:BuildAceOptionsTable()
    EnsureDB()

    local bindingPresetValues = {}
    if type(KEYBIND_COMMAND_PRESETS) == "table" then
        for _, preset in ipairs(KEYBIND_COMMAND_PRESETS) do
            if type(preset) == "table" and type(preset.command) == "string" then
                bindingPresetValues[preset.command] = Joypad:SafeOptionName(preset.label, preset.command)
            end
        end
    end

    local function getBool(key, defaultValue)
        return function()
            EnsureDB()
            if JoypadDB[key] == nil then
                return defaultValue and true or false
            end
            return JoypadDB[key] and true or false
        end
    end

    local function setBool(key, after)
        return function(info, value)
            EnsureDB()
            JoypadDB[key] = value and true or false
            if after then
                after(value and true or false)
            end
            UpdateSettingsControls()
            Joypad:NotifyAceOptionsChanged()
        end
    end

    local function safeLayerLabel(layerKey)
        layerKey = NormalizeJoypadLayerKey(layerKey)
        if layerKey == "shift" then
            return "L2"
        elseif layerKey == "ctrl" then
            return "R2"
        elseif layerKey == "shiftctrl" then
            return "L2+R2"
        end
        return "Base"
    end

    local function safeSlotName(slot)
        return "Slot " .. tostring(slot) .. " - " .. tostring(GetAltLabel(slot) or "-")
    end

    local slotControlArgs = {
        header = {
            type = "description",
            name = "Per-slot visibility, diamond clipping, scale, and position. Changes apply to Joypad immediately.",
            order = 1,
            width = "full",
        },
        allScale = {
            type = "range",
            name = "All slot scale",
            desc = "Set every Joypad button to this scale percentage.",
            min = 40,
            max = 160,
            step = 1,
            order = 2,
            get = function() return 100 end,
            set = function(info, value)
                Joypad:SetAllSlotScales(tonumber(value) or 100, false)
                Joypad:NotifyAceOptionsChanged()
            end,
        },
    }

    for slot = 1, 24 do
        local slotIndex = slot
        slotControlArgs["slot" .. tostring(slotIndex)] = {
            type = "group",
            name = safeSlotName(slotIndex),
            order = 100 + slotIndex,
            inline = true,
            args = {
                enabled = {
                    type = "toggle",
                    name = "Enabled",
                    order = 1,
                    get = function() return IsSlotEnabled(slotIndex) end,
                    set = function(info, value)
                        Joypad:SetSlotEnabled(slotIndex, value and true or false, false)
                        Joypad:NotifyAceOptionsChanged()
                    end,
                },
                diamond = {
                    type = "toggle",
                    name = "Diamond",
                    order = 2,
                    get = function() return JoypadIsDiamondViewportEnabled(slotIndex) end,
                    set = function(info, value)
                        Joypad:SetDiamondViewport(slotIndex, value and true or false, false)
                        Joypad:NotifyAceOptionsChanged()
                    end,
                },
                scale = {
                    type = "range",
                    name = "Scale %",
                    min = 40,
                    max = 160,
                    step = 1,
                    order = 3,
                    get = function() return GetSlotScale(slotIndex) end,
                    set = function(info, value)
                        Joypad:SetSlotScale(slotIndex, tonumber(value) or 100, false)
                        Joypad:NotifyAceOptionsChanged()
                    end,
                },
                x = {
                    type = "range",
                    name = "X",
                    min = -1000,
                    max = 1000,
                    step = 1,
                    order = 4,
                    get = function()
                        local x = GetSlotPosition(slotIndex)
                        return tonumber(x) or 0
                    end,
                    set = function(info, value)
                        local _, y = GetSlotPosition(slotIndex)
                        Joypad:SetSlotPosition(slotIndex, tonumber(value) or 0, tonumber(y) or 0, false)
                        Joypad:NotifyAceOptionsChanged()
                    end,
                },
                y = {
                    type = "range",
                    name = "Y",
                    min = -1000,
                    max = 1000,
                    step = 1,
                    order = 5,
                    get = function()
                        local _, y = GetSlotPosition(slotIndex)
                        return tonumber(y) or 0
                    end,
                    set = function(info, value)
                        local x = GetSlotPosition(slotIndex)
                        Joypad:SetSlotPosition(slotIndex, tonumber(x) or 0, tonumber(value) or 0, false)
                        Joypad:NotifyAceOptionsChanged()
                    end,
                },
                altScale = {
                    type = "range",
                    name = "Alt text %",
                    min = 40,
                    max = 180,
                    step = 1,
                    order = 6,
                    get = function() return GetAltTextScale(slotIndex) end,
                    set = function(info, value)
                        Joypad:SetAltTextScale(slotIndex, tonumber(value) or 100, false)
                        Joypad:NotifyAceOptionsChanged()
                    end,
                },
            },
        }
    end

    local bindingArgs = {
        help = {
            type = "description",
            name = "Each Joypad slot can be an action slot or a Blizzard keybind command on each layer. Base is unmodified, L2 is Shift, R2 is Ctrl, and L2+R2 is Shift+Ctrl.",
            order = 1,
            width = "full",
        },
        applyCore = {
            type = "execute",
            name = "Apply Core Keybinds",
            desc = "Applies the 12 core non-numpad Joypad defaults.",
            order = 2,
            func = function() Joypad:ConfirmApplyCoreControllerKeybinds() end,
        },
        applyExtended = {
            type = "execute",
            name = "Apply Extended Keybinds",
            desc = "Applies the 12 extended non-numpad Joypad defaults, including F8-F12.",
            order = 3,
            func = function() Joypad:ConfirmApplyExtendedControllerKeybinds() end,
        },
    }

    for layerOrder, layer in ipairs(JOYPAD_LAYERS or {}) do
        local layerKey = NormalizeJoypadLayerKey(layer.key)
        local layerLabel = safeLayerLabel(layerKey)
        local layerArgs = {
            help = {
                type = "description",
                name = layerLabel .. " assignments.",
                order = 1,
                width = "full",
            },
        }

        for slot = 1, 24 do
            local slotIndex = slot
            local currentLayerKey = layerKey
            local optionKey = "slot" .. tostring(slotIndex)
            layerArgs[optionKey] = {
                type = "group",
                name = safeSlotName(slotIndex),
                order = 100 + slotIndex,
                inline = true,
                args = {
                    mode = {
                        type = "select",
                        name = "Mode",
                        values = { action = "Action slot", keybind = "Keybind" },
                        order = 1,
                        get = function() return GetJoypadBindingMode(slotIndex, currentLayerKey) end,
                        set = function(info, value)
                            Joypad:SetButtonBindingMode(slotIndex, value, false, currentLayerKey)
                            Joypad:NotifyAceOptionsChanged()
                        end,
                    },
                    actionSlot = {
                        type = "range",
                        name = "Action slot",
                        desc = "WoW action slot used when this assignment is in Action slot mode.",
                        min = 1,
                        max = 120,
                        step = 1,
                        order = 2,
                        disabled = function() return GetJoypadBindingMode(slotIndex, currentLayerKey) ~= "action" end,
                        get = function()
                            local actionSlot = GetJoypadSlotInfo(slotIndex, currentLayerKey)
                            return tonumber(actionSlot) or slotIndex
                        end,
                        set = function(info, value)
                            Joypad:SelectActionSlotPreset(slotIndex, tonumber(value) or slotIndex, false, currentLayerKey)
                            Joypad:NotifyAceOptionsChanged()
                        end,
                    },
                    keybind = {
                        type = "select",
                        name = "Keybind",
                        desc = "Blizzard keybind command used when this assignment is in Keybind mode.",
                        values = bindingPresetValues,
                        order = 3,
                        disabled = function() return GetJoypadBindingMode(slotIndex, currentLayerKey) ~= "keybind" end,
                        get = function() return GetJoypadKeybindCommand(slotIndex, currentLayerKey) end,
                        set = function(info, value)
                            Joypad:SelectKeybindPreset(slotIndex, value, false, currentLayerKey)
                            Joypad:NotifyAceOptionsChanged()
                        end,
                    },
                },
            }
        end

        bindingArgs[layerKey] = {
            type = "group",
            name = layerLabel,
            order = 10 + layerOrder,
            args = layerArgs,
        }
    end

    return {
        type = "group",
        name = "Joypad",
        args = {
            general = {
                type = "group",
                name = "General",
                order = 1,
                args = {
                    intro = {
                        type = "description",
                        name = "Joypad " .. tostring(VERSION) .. "\n\n24-slot controller bars with Base, L2, R2, and L2+R2 layers. Use the child pages for layout, appearance, bindings, UI Cursor, and profiles.",
                        order = 1,
                        width = "full",
                    },
                    maintenance = { type = "header", name = "Maintenance", order = 10 },
                    applyCore = { type = "execute", name = "Apply Core Keybinds", order = 11, func = function() Joypad:ConfirmApplyCoreControllerKeybinds() end },
                    applyExtended = { type = "execute", name = "Apply Extended Keybinds", order = 12, func = function() Joypad:ConfirmApplyExtendedControllerKeybinds() end },
                    clearActions = { type = "execute", name = "Clear action slots 1-120", order = 13, func = function() Joypad:ConfirmClearNormalActionBars() end },
                    reset = { type = "execute", name = "Reset Joypad", order = 14, func = function() Joypad:ConfirmResetAddonSettings() end },
                    centre = { type = "execute", name = "Centre Joypad on screen", order = 15, func = function() Joypad:ConfirmCenterJoypadLayout() end },
                    diagnostics = { type = "header", name = "Input diagnostics", order = 16 },
                    inputLogEnabled = { type = "toggle", name = "Save last 200 button inputs", desc = "Stores recent Joypad button presses and what Joypad expected them to do in JoypadDB.inputLog, so you can upload the SavedVariables file for debugging.", order = 17, get = getBool("inputLogEnabled", true), set = function(info, value) EnsureDB(); JoypadDB.inputLogEnabled = value and true or false; Joypad:NotifyAceOptionsChanged() end },
                    warnMissingKeybinds = { type = "toggle", name = "Warn about missing Joypad keybinds", desc = "After login, checks enabled Joypad buttons and prints a warning if WoW's Key Bindings are missing any Joypad rows.", order = 18, get = getBool("warnMissingKeybinds", true), set = function(info, value) EnsureDB(); JoypadDB.warnMissingKeybinds = value and true or false; Joypad:NotifyAceOptionsChanged() end },
                    checkKeybinds = { type = "execute", name = "Check Joypad keybinds now", desc = "Checks enabled Joypad buttons and prints any missing physical keybinds.", order = 19, func = function() Joypad:CheckMissingPhysicalKeybinds(false) end },
                    inputDebug = { type = "execute", name = "Print input debug", desc = "Runs /joypad inputdebug and prints expected physical keys, bindings, and base assignments.", order = 20, func = function() Joypad:DebugInputBindings() end },
                    repairKeys = { type = "execute", name = "Repair Joypad keybinds", desc = "Runs /joypad repairkeys. Reapplies Joypad's physical keybinds and override bindings out of combat.", order = 21, func = function() Joypad:RepairPhysicalKeybinds(false) end },
                    printInputLog = { type = "execute", name = "Print recent input log", desc = "Prints the last few saved Joypad button inputs to chat.", order = 22, func = function() Joypad:PrintRecentInputLog(12) end },
                    clearInputLog = { type = "execute", name = "Clear input log", desc = "Clears JoypadDB.inputLog.", order = 23, func = function() Joypad:ClearInputLog(false) end },
                    help = { type = "header", name = "Help", order = 30 },
                    whisperScuz = {
                        type = "execute",
                        name = "Whisper Scuz for help",
                        desc = "Sends: /whisper Scuz I need help with Joypad",
                        order = 21,
                        hidden = function() return not (GetRealmName and tostring(GetRealmName() or "") == "Triumvirate") end,
                        func = function() Joypad:WhisperScuzForHelp() end,
                    },
                },
            },
            layout = {
                type = "group",
                name = "Layout",
                order = 2,
                args = {
                    bars = { type = "header", name = "Bars", order = 1 },
                    layoutMode = {
                        type = "select",
                        name = "Layout mode",
                        values = { gamepad = "Gamepad", desktop = "Desktop" },
                        order = 2,
                        get = function() EnsureDB(); return JoypadDB.layoutMode or "gamepad" end,
                        set = function(info, value) Joypad:SetLayoutMode(value, false); Joypad:NotifyAceOptionsChanged() end,
                    },
                    barsVisible = { type = "toggle", name = "Show Joypad bars", order = 3, get = getBool("barsVisible", true), set = function(info, value) Joypad:SetBarsVisible(value, false); Joypad:NotifyAceOptionsChanged() end },
                    hideBlizzardBars = { type = "toggle", name = "Hide Blizzard action bars", order = 4, get = getBool("hideBlizzardBars", true), set = function(info, value) Joypad:SetBlizzardBarsHidden(value, false); Joypad:NotifyAceOptionsChanged() end },
                    unlocked = { type = "toggle", name = "Unlock button positioning", order = 5, get = getBool("unlocked", false), set = function(info, value) Joypad:SetUnlocked(value, false); Joypad:NotifyAceOptionsChanged() end },
                    snapToGrid = { type = "toggle", name = "Snap dragged buttons to grid", order = 6, get = getBool("snapToGrid", true), set = setBool("snapToGrid") },
                    touch = { type = "header", name = "Touch Bar", order = 20 },
                    stanceVisible = { type = "toggle", name = "Show Touch Bar", order = 21, get = getBool("stanceBarVisible", false), set = function(info, value) Joypad:SetStanceBarVisible(value, false); Joypad:NotifyAceOptionsChanged() end },
                    stanceScale = { type = "range", name = "Touch Bar scale %", min = 30, max = 160, step = 1, order = 22, get = function() return Joypad:GetStanceBarScale() end, set = function(info, value) Joypad:SetStanceBarScale(tonumber(value) or 70, false); Joypad:NotifyAceOptionsChanged() end },
                    stanceX = { type = "range", name = "Touch Bar X", min = -1000, max = 1000, step = 1, order = 23, get = function() EnsureDB(); return tonumber(JoypadDB.stanceBarX) or 0 end, set = function(info, value) EnsureDB(); Joypad:SetStanceBarPosition(tonumber(value) or 0, tonumber(JoypadDB.stanceBarY) or 0, false); Joypad:NotifyAceOptionsChanged() end },
                    stanceY = { type = "range", name = "Touch Bar Y", min = -1000, max = 1000, step = 1, order = 24, get = function() EnsureDB(); return tonumber(JoypadDB.stanceBarY) or -460 end, set = function(info, value) EnsureDB(); Joypad:SetStanceBarPosition(tonumber(JoypadDB.stanceBarX) or 0, tonumber(value) or 0, false); Joypad:NotifyAceOptionsChanged() end },
                    stanceReset = { type = "execute", name = "Reset Touch Bar layout", order = 25, func = function() Joypad:ResetStanceBarLayout(false); Joypad:NotifyAceOptionsChanged() end },
                },
            },
            appearance = {
                type = "group",
                name = "Appearance",
                order = 3,
                args = {
                    style = { type = "header", name = "Style", order = 1 },
                    theme = { type = "select", name = "Theme", values = { none = "Classic", elvui = "ElvUI" }, order = 2, get = function() EnsureDB(); return JoypadNormalizeTheme(JoypadDB.theme) end, set = function(info, value) Joypad:SetTheme(value, false); Joypad:NotifyAceOptionsChanged() end },
                    displayMode = { type = "select", name = "Button labels", values = { xbox = "Xbox", steam = "Steam", playstation = "PlayStation", nintendo = "Nintendo" }, order = 3, get = function() return JoypadGetDisplayMode() end, set = function(info, value) Joypad:SetDisplayMode(value, false); Joypad:NotifyAceOptionsChanged() end },
                    hideKeybindText = { type = "toggle", name = "Hide keybind text", order = 4, get = getBool("hideKeybindText", false), set = function(info, value) Joypad:SetKeybindTextHidden(value, false); Joypad:NotifyAceOptionsChanged() end },
                    cooldowns = { type = "header", name = "Cooldowns and state", order = 10 },
                    showCooldownText = { type = "toggle", name = "Show cooldown text", order = 11, get = getBool("showCooldownText", true), set = function(info, value) Joypad:SetCooldownTextShown(value, false); Joypad:NotifyAceOptionsChanged() end },
                    showReadyFlash = { type = "toggle", name = "Flash when cooldowns finish", order = 12, get = getBool("showReadyFlash", true), set = function(info, value) Joypad:SetReadyFlashShown(value, false); Joypad:NotifyAceOptionsChanged() end },
                    readyFlashStrength = { type = "select", name = "Ready flash strength", values = { low = "Low", medium = "Medium", high = "High" }, order = 13, get = function() EnsureDB(); return Joypad.NormalizeReadyFlashStrength(JoypadDB.readyFlashStrength) end, set = function(info, value) Joypad:SetReadyFlashStrength(value, false); Joypad:NotifyAceOptionsChanged() end },
                    readyFlashDuration = { type = "select", name = "Ready flash duration", values = { short = "Short", normal = "Normal", long = "Long" }, order = 14, get = function() EnsureDB(); return Joypad.NormalizeReadyFlashDuration(JoypadDB.readyFlashDuration) end, set = function(info, value) Joypad:SetReadyFlashDuration(value, false); Joypad:NotifyAceOptionsChanged() end },
                    showActiveBorder = { type = "toggle", name = "Show active/toggled action border", order = 15, get = getBool("showActiveBorder", true), set = function(info, value) Joypad:SetActiveBorderShown(value, false); Joypad:NotifyAceOptionsChanged() end },
                    alt = { type = "header", name = "Alt label options", order = 20 },
                    showAltScaleControls = { type = "toggle", name = "Show alt scale controls", order = 21, get = getBool("showAltScaleControls", false), set = setBool("showAltScaleControls") },
                    showAltColorControls = { type = "toggle", name = "Show alt colour controls", order = 22, get = getBool("showAltColorControls", false), set = setBool("showAltColorControls") },
                    leftTrackpadPrefix = { type = "color", name = "Left trackpad prefix", order = 23, get = function() local r, g, b = JoypadGetAltPartTextColor("leftTrackpadPrefix"); return r, g, b, 1 end, set = function(info, r, g, b) Joypad:SetAltPartTextColor("leftTrackpadPrefix", r, g, b, false); Joypad:NotifyAceOptionsChanged() end },
                    rightTrackpadPrefix = { type = "color", name = "Right trackpad prefix", order = 24, get = function() local r, g, b = JoypadGetAltPartTextColor("rightTrackpadPrefix"); return r, g, b, 1 end, set = function(info, r, g, b) Joypad:SetAltPartTextColor("rightTrackpadPrefix", r, g, b, false); Joypad:NotifyAceOptionsChanged() end },
                },
            },
            slots = { type = "group", name = "Slots", order = 4, args = slotControlArgs },
            bindings = { type = "group", name = "Bindings", order = 5, args = bindingArgs },
            uiCursor = {
                type = "group",
                name = "UI Cursor",
                order = 6,
                args = {
                    intro = { type = "description", name = "Navigate clickable UI frames with Joypad controls when a panel is open. Uses targeted panel roots only; broad addon-frame scanning is disabled for stability.", order = 1, width = "full" },
                    enabled = { type = "toggle", name = "Enable UI cursor (panel navigation)", order = 2, get = getBool("uiCursorEnabled", true), set = function(info, value) Joypad:SetUICursorEnabled(value, false); Joypad:NotifyAceOptionsChanged() end },
                    panelsOnly = { type = "toggle", name = "Only capture controls while UI panels are open", order = 3, get = getBool("uiCursorPanelsOnly", true), set = function(info, value) EnsureDB(); JoypadDB.uiCursorPanelsOnly = value and true or false; Joypad:UpdateUICursorActivation(true); UpdateSettingsControls(); Joypad:NotifyAceOptionsChanged() end },
                    showHighlight = { type = "toggle", name = "Show selection highlight", order = 4, get = getBool("uiCursorShowHighlight", true), set = function(info, value) EnsureDB(); JoypadDB.uiCursorShowHighlight = value and true or false; Joypad:UpdateUICursorHighlight(); UpdateSettingsControls(); Joypad:NotifyAceOptionsChanged() end },
                    showPointer = { type = "toggle", name = "Show Joypad cursor pointer", order = 5, get = getBool("uiCursorShowPointer", true), set = function(info, value) EnsureDB(); JoypadDB.uiCursorShowPointer = value and true or false; Joypad:UpdateUICursorHighlight(); UpdateSettingsControls(); Joypad:NotifyAceOptionsChanged() end },
                    hideHardware = { type = "toggle", name = "Try to hide default mouse cursor while selecting UI", order = 6, get = getBool("uiCursorHideHardwareCursor", false), set = function(info, value) EnsureDB(); JoypadDB.uiCursorHideHardwareCursor = value and true or false; if value then Joypad:UpdateUICursorHighlight() else Joypad:RestoreHardwareCursor("uiCursor") end; UpdateSettingsControls(); Joypad:NotifyAceOptionsChanged() end },
                    smartHeader = { type = "header", name = "Smart mouselook", order = 7 },
                    smartMouselookEnabled = { type = "toggle", name = "Enable Smart mouselook", desc = "ConsolePort-style lite mouselook. Starts WoW mouselook for selected controller/gameplay events so the mouse cursor disappears and camera control feels native.", order = 8, get = getBool("smartMouselookEnabled", true), set = function(info, value) Joypad:SetSmartMouselookEnabled(value, false) end },
                    smartMouselookBlocker = { type = "toggle", name = "Block accidental UI clicks during mouselook", order = 9, get = getBool("smartMouselookBlocker", true), set = function(info, value) EnsureDB(); JoypadDB.smartMouselookBlocker = value and true or false; if not value then Joypad:HideSmartMouselookBlocker() end; Joypad:NotifyAceOptionsChanged() end },
                    smartMouselookForceTooltip = { type = "toggle", name = "Show Blizzard target tooltip", desc = "While Smart mouselook is active, shows the normal Blizzard GameTooltip for the current Joypad target source. With selected-target fallback enabled, this uses the normal target unit.", order = 9.2, get = getBool("smartMouselookForceTooltip", false), set = function(info, value) Joypad:SetSmartMouselookForceTooltip(value, false); Joypad:NotifyAceOptionsChanged() end },
                    smartMouselookTooltipAnchor = { type = "select", name = "Blizzard tooltip position", desc = "Where Joypad places the Blizzard tooltip while Smart mouselook is active.", values = { cursor = "Cursor", elvui = "ElvUI tooltip mover / near minimap", topright = "Top right near minimap", manual = "Manual top-right offset" }, order = 9.21, get = function() EnsureDB(); return JoypadDB.smartMouselookTooltipAnchor or "elvui" end, set = function(info, value) Joypad:SetSmartMouselookTooltipAnchor(value, false); Joypad:NotifyAceOptionsChanged() end },
                    smartMouselookTooltipX = { type = "range", name = "Tooltip X offset", desc = "Manual tooltip X offset from the top-right of ElvUIParent/UIParent.", min = -1000, max = 1000, step = 1, order = 9.22, get = function() EnsureDB(); return tonumber(JoypadDB.smartMouselookTooltipX or -230) or -230 end, set = function(info, value) Joypad:SetSmartMouselookTooltipOffset(value, JoypadDB.smartMouselookTooltipY, true); Joypad:NotifyAceOptionsChanged() end },
                    smartMouselookTooltipY = { type = "range", name = "Tooltip Y offset", desc = "Manual tooltip Y offset from the top-right of ElvUIParent/UIParent.", min = -1000, max = 1000, step = 1, order = 9.23, get = function() EnsureDB(); return tonumber(JoypadDB.smartMouselookTooltipY or -4) or -4 end, set = function(info, value) Joypad:SetSmartMouselookTooltipOffset(JoypadDB.smartMouselookTooltipX, value, true); Joypad:NotifyAceOptionsChanged() end },
                    smartMouselookMouseoverHint = { type = "toggle", name = "Show Joypad debug target hint", desc = "Optional debug overlay. Leave this off now that the normal Blizzard target tooltip works.", order = 9.3, get = getBool("smartMouselookMouseoverHint", false), set = function(info, value) Joypad:SetSmartMouselookMouseoverHint(value, false); Joypad:NotifyAceOptionsChanged() end },
                    smartMouselookPreferAwesomeTarget = { type = "toggle", name = "Prefer AwesomeWotLK aim nameplate", desc = "For Smart Mouselook hints/tooltips, prefers the visible AwesomeWotLK nameplate nearest screen centre before falling back to selected target and mouseover. This does not change your actual target.", order = 9.35, get = getBool("smartMouselookPreferAwesomeTarget", true), set = function(info, value) EnsureDB(); JoypadDB.smartMouselookPreferAwesomeTarget = value and true or false; Joypad:UpdateSmartMouselookMouseoverHint(0, true); Joypad:UpdateSmartMouselookTestTooltip(0, true); Joypad:NotifyAceOptionsChanged() end },
                    smartMouselookUseSelectedTarget = { type = "toggle", name = "Use selected target fallback", desc = "If no AwesomeWotLK aim nameplate is available, shows the current selected target in the mouselook hint/test tooltip.", order = 9.355, get = getBool("smartMouselookUseSelectedTarget", true), set = function(info, value) EnsureDB(); JoypadDB.smartMouselookUseSelectedTarget = value and true or false; Joypad:UpdateSmartMouselookMouseoverHint(0, true); Joypad:UpdateSmartMouselookTestTooltip(0, true); Joypad:NotifyAceOptionsChanged() end },
                    smartMouselookTestTooltip = { type = "toggle", name = "Show test tooltip frame", desc = "Debug frame: shows what Joypad can see from AwesomeWotLK aim nameplates, selected target, and mouseover without using Blizzard GameTooltip.", order = 9.36, get = getBool("smartMouselookTestTooltip", false), set = function(info, value) Joypad:SetSmartMouselookTestTooltip(value, false); Joypad:NotifyAceOptionsChanged() end },
                    smartMouselookPauseOnModifier = { type = "toggle", name = "Hold Ctrl to release mouselook", desc = "While Ctrl is held, Smart mouselook is released and suppressed so you can peek at normal mouseover UI/tooltips.", order = 9.4, get = getBool("smartMouselookPauseOnModifier", true), set = function(info, value) Joypad:SetSmartMouselookPauseOnModifier(value, false); Joypad:NotifyAceOptionsChanged() end },
                    raidCursorHeader = { type = "header", name = "Raid Cursor prototype", order = 9.6 },
                    raidCursorEnabled = { type = "toggle", name = "Enable Raid Cursor in raids", desc = "Prototype: when you are in a raid, Joypad redirects the left trackpad/D-pad party-target keys into a ConsolePort-style secure raid frame cursor.", order = 9.61, get = getBool("raidCursorEnabled", true), set = function(info, value) Joypad:SetRaidCursorEnabled(value, false) end },
                    raidCursorTargetOnMove = { type = "toggle", name = "Target on move", desc = "D-pad/left trackpad movement targets the highlighted raid frame immediately. If this is disabled, A targets the highlighted frame instead.", order = 9.62, get = getBool("raidCursorTargetOnMove", true), set = function(info, value) Joypad:SetRaidCursorTargetOnMove(value, false) end },
                    raidCursorAFallback = { type = "toggle", name = "A / Jump fallback target", desc = "Optional emergency/debug fallback. Leave this off if target-on-move works, so A remains normal Jump in raids.", order = 9.63, get = getBool("raidCursorAFallback", false), set = function(info, value) Joypad:SetRaidCursorAFallback(value, false) end },
                    raidCursorLogEnabled = { type = "toggle", name = "Log Raid Cursor diagnostics", desc = "Stores raid cursor input/selection/targeting events in JoypadDB and sends them to ShiftyLogs if installed.", order = 9.64, get = getBool("raidCursorLogEnabled", true), set = function(info, value) EnsureDB(); JoypadDB.raidCursorLogEnabled = value and true or false; Joypad:NotifyAceOptionsChanged() end },
                    raidCursorHighlightPadding = { type = "range", name = "Raid highlight padding", desc = "Extra space around the selected ElvUI raid frame.", min = 0, max = 20, step = 1, order = 9.641, get = function() EnsureDB(); return tonumber(JoypadDB.raidCursorHighlightPadding or 3) or 3 end, set = function(info, value) EnsureDB(); JoypadDB.raidCursorHighlightPadding = tonumber(value) or 3; Joypad:ApplyRaidCursorHighlightStyle(); Joypad:NotifyAceOptionsChanged() end },
                    raidCursorHighlightBorderSize = { type = "range", name = "Raid highlight border size", desc = "Thickness of the ElvUI-style raid cursor border.", min = 1, max = 8, step = 1, order = 9.642, get = function() EnsureDB(); return tonumber(JoypadDB.raidCursorHighlightBorderSize or 2) or 2 end, set = function(info, value) EnsureDB(); JoypadDB.raidCursorHighlightBorderSize = tonumber(value) or 2; Joypad:ApplyRaidCursorHighlightStyle(); Joypad:NotifyAceOptionsChanged() end },
                    raidCursorHighlightAlpha = { type = "range", name = "Raid highlight opacity", desc = "Opacity of the raid cursor border.", min = 0.1, max = 1, step = 0.05, order = 9.643, get = function() EnsureDB(); return tonumber(JoypadDB.raidCursorHighlightAlpha or 0.95) or 0.95 end, set = function(info, value) EnsureDB(); JoypadDB.raidCursorHighlightAlpha = tonumber(value) or 0.95; Joypad:ApplyRaidCursorHighlightStyle(); Joypad:NotifyAceOptionsChanged() end },
                    raidCursorHighlightFillAlpha = { type = "range", name = "Raid highlight fill opacity", desc = "Subtle fill behind the selected raid frame. Set to 0 for border only.", min = 0, max = 0.5, step = 0.01, order = 9.644, get = function() EnsureDB(); return tonumber(JoypadDB.raidCursorHighlightFillAlpha or 0.08) or 0.08 end, set = function(info, value) EnsureDB(); JoypadDB.raidCursorHighlightFillAlpha = tonumber(value) or 0.08; Joypad:ApplyRaidCursorHighlightStyle(); Joypad:NotifyAceOptionsChanged() end },
                    raidCursorShowLabel = { type = "toggle", name = "Show raid cursor label", desc = "Optional debug label. Off by default so the highlight stays clean on ElvUI raid frames.", order = 9.645, get = getBool("raidCursorShowLabel", false), set = function(info, value) EnsureDB(); JoypadDB.raidCursorShowLabel = value and true or false; Joypad:ApplyRaidCursorHighlightStyle(); Joypad:UpdateRaidCursorText(Joypad.raidCursor and Joypad.raidCursor.GetAttribute and Joypad.raidCursor:GetAttribute("cursorunit") or nil); Joypad:NotifyAceOptionsChanged() end },
                    raidTargetSteeringEnabled = { type = "toggle", name = "Shifty raid target steering", desc = "In raids, Shifty healing suggestions steer the Raid Cursor first. The main Joypad cue becomes the next direction until the requested heal target is selected.", order = 9.646, get = getBool("raidTargetSteeringEnabled", true), set = function(info, value) EnsureDB(); JoypadDB.raidTargetSteeringEnabled = value and true or false; Joypad:NotifyAceOptionsChanged() end },
                    raidTargetSteeringEveryHeal = { type = "toggle", name = "Steer every raid heal", desc = "Treat every raid healing suggestion as target-first. If off, only urgent/emergency target takeover cues steer.", order = 9.647, get = getBool("raidTargetSteeringEveryHeal", true), set = function(info, value) EnsureDB(); JoypadDB.raidTargetSteeringEveryHeal = value and true or false; Joypad:NotifyAceOptionsChanged() end },
                    raidTargetSteeringLogEnabled = { type = "toggle", name = "Log raid target steering", desc = "Log Shifty-to-Joypad raid target steering path decisions.", order = 9.648, get = getBool("raidTargetSteeringLogEnabled", true), set = function(info, value) EnsureDB(); JoypadDB.raidTargetSteeringLogEnabled = value and true or false; Joypad:NotifyAceOptionsChanged() end },
                    raidCursorStatus = { type = "execute", name = "Print Raid Cursor status", order = 9.65, func = function() Joypad:PrintRaidCursorStatus() end },
                    smartMove = { type = "toggle", name = "Starting to move / turn / strafe", order = 10, get = getBool("smartMouselookOnMove", true), set = function(info, value) Joypad:SetSmartMouselookTrigger("move", value, true); Joypad:NotifyAceOptionsChanged() end },
                    smartTarget = { type = "toggle", name = "Changing target", order = 11, get = getBool("smartMouselookOnTarget", true), set = function(info, value) Joypad:SetSmartMouselookTrigger("target", value, true); Joypad:NotifyAceOptionsChanged() end },
                    smartSpell = { type = "toggle", name = "Casting a spell", order = 12, get = getBool("smartMouselookOnSpell", true), set = function(info, value) Joypad:SetSmartMouselookTrigger("spell", value, true); Joypad:NotifyAceOptionsChanged() end },
                    smartNPC = { type = "toggle", name = "Interacting with an NPC", order = 13, get = getBool("smartMouselookOnNPC", false), set = function(info, value) Joypad:SetSmartMouselookTrigger("npc", value, true); Joypad:NotifyAceOptionsChanged() end },
                    smartQuest = { type = "toggle", name = "Popup quest appears", order = 14, get = getBool("smartMouselookOnQuest", true), set = function(info, value) Joypad:SetSmartMouselookTrigger("quest", value, true); Joypad:NotifyAceOptionsChanged() end },
                    smartLoot = { type = "toggle", name = "Looting", order = 15, get = getBool("smartMouselookOnLoot", true), set = function(info, value) Joypad:SetSmartMouselookTrigger("loot", value, true); Joypad:NotifyAceOptionsChanged() end },
                    smartJump = { type = "toggle", name = "Jumping", order = 16, get = getBool("smartMouselookOnJump", false), set = function(info, value) Joypad:SetSmartMouselookTrigger("jump", value, true); Joypad:NotifyAceOptionsChanged() end },
                    smartCenter = { type = "toggle", name = "Cursor is centered", desc = "Starts Smart mouselook if the hardware cursor rests near the centre of the screen. Off by default because it can feel aggressive on some controller layouts.", order = 17, get = getBool("smartMouselookOnCenter", false), set = function(info, value) Joypad:SetSmartMouselookTrigger("center", value, true); Joypad:NotifyAceOptionsChanged() end },
                    smartCenterDelay = { type = "select", name = "Centre activation delay", desc = "How long the cursor must stay inside the centre zone before Smart mouselook starts.", values = { instant = "Instant", short = "Short", normal = "Normal", long = "Long" }, order = 18, get = function() EnsureDB(); return Joypad.NormalizeSmartMouselookCenterDelay(JoypadDB.smartMouselookCenterDelay) end, set = function(info, value) Joypad:SetSmartMouselookCenterDelay(value, false); Joypad:NotifyAceOptionsChanged() end },
                    smartCenterPreview = { type = "toggle", name = "Show centre-zone preview", desc = "Shows the exact square area that counts as centred for Smart mouselook.", order = 19, get = getBool("smartMouselookCenterPreview", false), set = function(info, value) Joypad:SetSmartMouselookCenterPreviewShown(value, false); Joypad:NotifyAceOptionsChanged() end },
                    smartCenterScale = { type = "range", name = "Centre zone size %", desc = "Adjusts how large the centred-cursor trigger zone is. Larger is easier to trigger; smaller is stricter.", min = 50, max = 250, step = 5, order = 20, get = function() return Joypad:GetSmartMouselookCenterScale() end, set = function(info, value) Joypad:SetSmartMouselookCenterScale(value, false); Joypad:NotifyAceOptionsChanged() end },
                    smartDesc = { type = "description", name = "\nEmergency macro: /joypad mousemove off\nClick once anywhere during Smart mouselook to stop the current mouselook capture.", order = 25, width = "full" },
                    controls = { type = "description", name = "\nControls:\nD-pad: move selection\nA: confirm / left-click\nB: back / close window\nY / X: scroll up / down\nR1 / L1: page up / down", order = 30, width = "full" },
                },
            },
            profiles = {
                type = "group",
                name = "Profiles",
                order = 7,
                args = {
                    intro = { type = "description", name = "Built-in layout profiles. Applying a profile changes layout, visibility, display mode, and related Joypad settings.", order = 1, width = "full" },
                    scuz = { type = "execute", name = "Apply Scuz profile", desc = "Applies the saved Scuz layout, scale, Touch Bar, diamonds, visibility, and pet utility assignment profile.", order = 2, func = function() Joypad:ConfirmApplyLayoutProfile("Scuz") end },
                },
            },
        },
    }
end

function Joypad:CreateSettingsPanel()
    if self.settingsPanel then
        return
    end

    EnsureDB()

    local rootPanel = CreateFrame("Frame", "JoypadRootOptionsPanel")
    rootPanel.name = "Joypad"

    local icon = rootPanel:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", rootPanel, "TOPLEFT", 16, -16)
    icon:SetWidth(64)
    icon:SetHeight(64)
    icon:SetTexture("Interface\\AddOns\\Joypad\\Textures\\JoypadIcon")
    icon:SetTexCoord(0, 1, 0, 1)

    local title = rootPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, -4)
    title:SetText("Joypad")

    local version = rootPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    version:SetText("Version " .. tostring(VERSION))

    local note = rootPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -10)
    note:SetWidth(390)
    note:SetJustifyH("LEFT")
    if note.SetNonSpaceWrap then
        note:SetNonSpaceWrap(false)
    end
    note:SetText("Configure Joypad using the child pages on the left.\nThis root page stays lightweight so hidden settings UI\ncannot affect gameplay.")

    self.settingsPanel = rootPanel
    self.rootSettingsPanel = rootPanel

    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(rootPanel)
    end

    local AceConfig, AceConfigDialog = self:GetAceOptionLibraries()
    if not AceConfig or not AceConfigDialog then
        local missing = rootPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        missing:SetPoint("TOPLEFT", note, "BOTTOMLEFT", 0, -14)
        missing:SetWidth(430)
        missing:SetJustifyH("LEFT")
        missing:SetText("AceConfig-3.0/AceConfigDialog-3.0 not found. Load Ace3 to show Joypad child settings pages.")
        return
    end

    if not self.aceOptionsRegistered then
        self.aceOptionsTable = self:BuildAceOptionsTable()
        AceConfig:RegisterOptionsTable("Joypad", self.aceOptionsTable)
        self.aceOptionsRegistered = true
    end

    if not self.aceBlizzardOptionsRegistered then
        self.generalPanel = AceConfigDialog:AddToBlizOptions("Joypad", "General", "Joypad", "general")
        self.layoutPanel = AceConfigDialog:AddToBlizOptions("Joypad", "Layout", "Joypad", "layout")
        self.appearancePanel = AceConfigDialog:AddToBlizOptions("Joypad", "Appearance", "Joypad", "appearance")
        self.slotsPanel = AceConfigDialog:AddToBlizOptions("Joypad", "Slots", "Joypad", "slots")
        self.bindingsPanel = AceConfigDialog:AddToBlizOptions("Joypad", "Bindings", "Joypad", "bindings")
        self.uiCursorPanel = AceConfigDialog:AddToBlizOptions("Joypad", "UI Cursor", "Joypad", "uiCursor")
        self.profilesPanel = AceConfigDialog:AddToBlizOptions("Joypad", "Profiles", "Joypad", "profiles")
        self.aceBlizzardOptionsRegistered = true
    end
end


function Joypad:CreateUICursorPanel()
    self:CreateSettingsPanel()
end


function Joypad:CreateBindingsPanel()
    self:CreateSettingsPanel()
end


function Joypad:OpenSettingsPanel()
    self:CreateSettingsPanel()

    local panel = self.rootSettingsPanel or self.settingsPanel
    if not panel then
        return
    end

    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    elseif InterfaceOptionsFrame then
        InterfaceOptionsFrame:Show()
    end
end

function Joypad:ToggleSettingsPanel()
    self:OpenSettingsPanel()
end

function Joypad:SelectActionSlotPreset(joypadSlot, actionSlot, silent, layerKey)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    actionSlot = tonumber(actionSlot or 0) or 0
    layerKey = NormalizeJoypadLayerKey(layerKey)

    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    actionSlot = math.floor(actionSlot + 0.5)
    if actionSlot < 1 or actionSlot > 120 then
        return
    end

    local defaultAssignment = GetDefaultJoypadAssignment(joypadSlot, layerKey)
    local defaultActionSlot = nil
    if defaultAssignment and defaultAssignment.type == "action" then
        defaultActionSlot = tonumber(defaultAssignment.actionSlot)
    end

    if layerKey == "base" then
        JoypadDB.bindingModes[joypadSlot] = "action"
        if actionSlot == defaultActionSlot then
            JoypadDB.actionSlots[joypadSlot] = nil
        else
            JoypadDB.actionSlots[joypadSlot] = actionSlot
        end
        if type(JoypadDB.layerAssignments) == "table" and type(JoypadDB.layerAssignments[joypadSlot]) == "table" then
            JoypadDB.layerAssignments[joypadSlot][layerKey] = nil
        end
    else
        JoypadDB.layerAssignments[joypadSlot] = JoypadDB.layerAssignments[joypadSlot] or {}
        if actionSlot == defaultActionSlot then
            JoypadDB.layerAssignments[joypadSlot][layerKey] = nil
        else
            JoypadDB.layerAssignments[joypadSlot][layerKey] = { type = "action", actionSlot = actionSlot }
        end
    end

    if InCombat() then
        self.pendingApply = true
        self.pendingBindingOverrides = true
        UpdateSettingsRows()
        if not silent then
            Print(GetJoypadLayerLabel(layerKey) .. " action preset queued until combat ends.")
        end
        return
    end

    self:Apply(true)
    ApplyJoypadBindingOverrides(true)
    UpdateSettingsRows()

    if not silent then
        Print("Joypad slot " .. tostring(joypadSlot) .. " " .. GetJoypadLayerLabel(layerKey) .. " set to " .. GetActionSlotChoiceLabel(actionSlot) .. ".")
    end
end

function Joypad:SelectDefaultJoypadBinding(joypadSlot, silent, layerKey)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    layerKey = NormalizeJoypadLayerKey(layerKey)
    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    if layerKey == "base" then
        JoypadDB.bindingModes[joypadSlot] = nil
        if type(JoypadDB.keybindCommands) == "table" then
            JoypadDB.keybindCommands[joypadSlot] = nil
        end
        if type(JoypadDB.actionSlots) == "table" then
            JoypadDB.actionSlots[joypadSlot] = nil
        end
    end

    if type(JoypadDB.layerAssignments) == "table" and type(JoypadDB.layerAssignments[joypadSlot]) == "table" then
        JoypadDB.layerAssignments[joypadSlot][layerKey] = nil
    end

    if InCombat() then
        self.pendingApply = true
        self.pendingBindingOverrides = true
        UpdateSettingsRows()
        if not silent then
            Print("default " .. GetJoypadLayerLabel(layerKey) .. " binding queued until combat ends.")
        end
        return
    end

    self:Apply(true)
    ApplyJoypadBindingOverrides(true)
    UpdateSettingsRows()

    if not silent then
        Print("Joypad slot " .. tostring(joypadSlot) .. " " .. GetJoypadLayerLabel(layerKey) .. " restored to its default.")
    end
end

function Joypad:SelectKeybindPreset(joypadSlot, command, silent, layerKey)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    layerKey = NormalizeJoypadLayerKey(layerKey)
    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    command = NormalizeKeybindCommand(command)
    if command == "" then
        return
    end

    local defaultAssignment = GetDefaultJoypadAssignment(joypadSlot, layerKey)
    local defaultCommand = nil
    if defaultAssignment and defaultAssignment.type == "keybind" then
        defaultCommand = NormalizeKeybindCommand(defaultAssignment.command or "")
    end

    if layerKey == "base" then
        JoypadDB.bindingModes[joypadSlot] = "keybind"
        if command == defaultCommand then
            JoypadDB.keybindCommands[joypadSlot] = nil
            if type(JoypadDB.layerAssignments) == "table" and type(JoypadDB.layerAssignments[joypadSlot]) == "table" then
                JoypadDB.layerAssignments[joypadSlot][layerKey] = nil
            end
        else
            JoypadDB.keybindCommands[joypadSlot] = command
        end
    else
        JoypadDB.layerAssignments[joypadSlot] = JoypadDB.layerAssignments[joypadSlot] or {}
        if command == defaultCommand then
            JoypadDB.layerAssignments[joypadSlot][layerKey] = nil
        else
            JoypadDB.layerAssignments[joypadSlot][layerKey] = { type = "keybind", command = command }
        end
    end

    if InCombat() then
        self.pendingApply = true
        self.pendingBindingOverrides = true
        UpdateSettingsRows()
        if not silent then
            Print(GetJoypadLayerLabel(layerKey) .. " keybind preset queued until combat ends.")
        end
        return
    end

    self:Apply(true)
    ApplyJoypadBindingOverrides(true)
    UpdateSettingsRows()

    if not silent then
        Print("Joypad slot " .. tostring(joypadSlot) .. " " .. GetJoypadLayerLabel(layerKey) .. " set to keybind " .. command .. ".")
    end
end

function Joypad:SetButtonBindingMode(joypadSlot, mode, silent)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    mode = NormalizeJoypadBindingMode(mode)
    JoypadDB.bindingModes[joypadSlot] = mode

    if mode == "keybind" and GetJoypadKeybindCommand(joypadSlot) == "" then
        JoypadDB.keybindCommands[joypadSlot] = "JUMP"
    end

    if InCombat() then
        self.pendingApply = true
        self.pendingBindingOverrides = true
        UpdateSettingsRows()
        if not silent then
            Print("binding mode update queued until combat ends.")
        end
        return
    end

    self:Apply(true)
    ApplyJoypadBindingOverrides(true)
    UpdateSettingsRows()

    if not silent then
        Print("Joypad slot " .. tostring(joypadSlot) .. " mode set to " .. GetJoypadBindingModeLabel(joypadSlot) .. ".")
    end
end

function Joypad:ToggleButtonBindingMode(joypadSlot, silent)
    if GetJoypadBindingMode(joypadSlot) == "keybind" then
        self:SetButtonBindingMode(joypadSlot, "action", silent)
    else
        self:SetButtonBindingMode(joypadSlot, "keybind", silent)
    end
end

function Joypad:SetButtonKeybindCommand(joypadSlot, command, silent)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    command = NormalizeKeybindCommand(command)
    JoypadDB.keybindCommands[joypadSlot] = command

    if InCombat() then
        self.pendingBindingOverrides = true
        UpdateSettingsRows()
        if not silent then
            Print("keybind command update queued until combat ends.")
        end
        return
    end

    ApplyJoypadBindingOverrides(true)
    UpdateAllButtons()
    UpdateSettingsRows()

    if not silent then
        if command and command ~= "" then
            Print("Joypad slot " .. tostring(joypadSlot) .. " keybind command set to " .. command .. ".")
        else
            Print("Joypad slot " .. tostring(joypadSlot) .. " keybind command cleared.")
        end
    end
end

function Joypad:SetButtonActionSlot(joypadSlot, actionSlot, silent)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    actionSlot = tonumber(actionSlot or 0) or 0

    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    actionSlot = math.floor(actionSlot + 0.5)
    if actionSlot < 1 or actionSlot > 120 then
        if not silent then
            Print("action slot must be between 1 and 120.")
        end
        UpdateSettingsRows()
        return
    end

    local _, _, _, _, defaultActionSlot = GetJoypadSlotInfo(joypadSlot)

    if actionSlot == defaultActionSlot then
        JoypadDB.actionSlots[joypadSlot] = nil
    else
        JoypadDB.actionSlots[joypadSlot] = actionSlot
    end

    if InCombat() then
        self.pendingApply = true
        self.pendingBindingOverrides = true
        UpdateSettingsRows()
        if not silent then
            Print("action slot update queued until combat ends.")
        end
        return
    end

    local button = self.buttons[joypadSlot]
    if button then
        button.actionSlot = actionSlot
        if GetJoypadBindingMode(joypadSlot) == "action" then
            button:SetAttribute("type", "action")
            button:SetAttribute("action", actionSlot)
        end
        UpdateButtonVisual(button)
    end

    ApplyJoypadBindingOverrides(true)
    UpdateSettingsRows()

    if not silent then
        Print("Joypad slot " .. tostring(joypadSlot) .. " now uses action slot " .. tostring(actionSlot) .. ".")
    end
end

function Joypad:SetSlotEnabled(joypadSlot, enabled, silent)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    if enabled then
        enabled = true
    else
        enabled = false
    end

    JoypadDB.slotEnabled[joypadSlot] = enabled

    if InCombat() then
        self.pendingSlotVisibility = true
        UpdateSettingsRows()
        if not silent then
            Print("slot visibility update queued until combat ends.")
        end
        return
    end

    ApplyButtonSlotVisibility(joypadSlot)
    UpdateSettingsRows()
    UpdateEditMode()
    UpdateGroupPopupFields()

    if not silent then
        if enabled then
            Print("slot " .. joypadSlot .. " enabled.")
        else
            Print("slot " .. joypadSlot .. " disabled.")
        end
    end
end

function Joypad:SetKeybindTextHidden(hidden, silent)
    EnsureDB()

    if hidden then
        hidden = true
    else
        hidden = false
    end

    JoypadDB.hideKeybindText = hidden
    UpdateAllButtons()
    UpdateSettingsControls()

    if not silent then
        if hidden then
            Print("keybind text hidden on Joypad buttons.")
        else
            Print("keybind text shown on Joypad buttons.")
        end
    end
end

function Joypad:SetCooldownTextShown(shown, silent)
    EnsureDB()

    if shown then
        shown = true
    else
        shown = false
    end

    JoypadDB.showCooldownText = shown

    if not shown then
        for button in pairs(Joypad.activeCooldownTextButtons) do
            Joypad.HideCooldownText(button)
        end
    end

    UpdateAllButtons(true)
    UpdateSettingsControls()

    if not silent then
        if shown then
            Print("cooldown text shown on Joypad buttons.")
        else
            Print("cooldown text hidden on Joypad buttons.")
        end
    end
end


function Joypad:SetReadyFlashShown(shown, silent)
    EnsureDB()

    if shown then
        shown = true
    else
        shown = false
    end

    JoypadDB.showReadyFlash = shown

    if not shown then
        for button in pairs(Joypad.readyFlashWatches or {}) do
            Joypad.ClearReadyFlashWatch(button)
        end
        for button in pairs(Joypad.activeReadyFlashButtons or {}) do
            Joypad.ClearReadyFlash(button)
        end
    end

    UpdateSettingsControls()

    if not silent then
        if shown then
            Print("ready flash shown when cooldowns finish.")
        else
            Print("ready flash hidden.")
        end
    end
end

function Joypad:SetReadyFlashStrength(value, silent)
    EnsureDB()

    value = Joypad.NormalizeReadyFlashStrength(value)
    JoypadDB.readyFlashStrength = value
    UpdateSettingsControls()

    if not silent then
        Print("ready flash strength set to " .. Joypad.GetReadyFlashStrengthLabel(value) .. ".")
    end
end

function Joypad:SetReadyFlashDuration(value, silent)
    EnsureDB()

    value = Joypad.NormalizeReadyFlashDuration(value)
    JoypadDB.readyFlashDuration = value
    UpdateSettingsControls()

    if not silent then
        Print("ready flash duration set to " .. Joypad.GetReadyFlashDurationLabel(value) .. ".")
    end
end

function Joypad:SetActiveBorderShown(shown, silent)
    EnsureDB()

    if shown then
        shown = true
    else
        shown = false
    end

    JoypadDB.showActiveBorder = shown
    UpdateAllButtons(true)
    UpdateSettingsControls()

    if not silent then
        if shown then
            Print("active/toggled action border shown.")
        else
            Print("active/toggled action border hidden.")
        end
    end
end

function Joypad:SetAltTextScale(joypadSlot, scalePercent, silent)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    scalePercent = Clamp(Round(scalePercent or GetDefaultAltTextScale(joypadSlot)), 25, 300)
    JoypadDB.altTextScales[joypadSlot] = scalePercent

    local button = self.buttons[joypadSlot]
    if button then
        ApplyAltPartsAppearance(button)
        UpdateButtonVisual(button)
    end

    UpdateSettingsRows()

    if not silent then
        Print("slot " .. joypadSlot .. " Alt text modifier set to " .. tostring(scalePercent) .. "%.")
    end
end

function Joypad:SetAltTextColor(joypadSlot, r, g, b, silent)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    r = Clamp(tonumber(r) or 1.0, 0, 1)
    g = Clamp(tonumber(g) or 0.82, 0, 1)
    b = Clamp(tonumber(b) or 0.0, 0, 1)

    JoypadDB.altTextColors[joypadSlot] = JoypadDB.altTextColors[joypadSlot] or {}
    JoypadDB.altTextColors[joypadSlot].r = r
    JoypadDB.altTextColors[joypadSlot].g = g
    JoypadDB.altTextColors[joypadSlot].b = b
    JoypadDB.altTextColors[joypadSlot].a = 1.0

    local button = self.buttons[joypadSlot]
    if button then
        ApplyAltPartsAppearance(button)
        UpdateButtonVisual(button)
    end

    UpdateSettingsRows()

    if not silent then
        Print("slot " .. joypadSlot .. " Alt text colour set to " .. GetAltTextColorHex(joypadSlot) .. ".")
    end
end

function Joypad:SetAltPartTextColor(colorRole, r, g, b, silent)
    EnsureDB()

    colorRole = tostring(colorRole or "")
    if not JOYPAD_DEFAULT_ALT_PART_TEXT_COLORS or not JOYPAD_DEFAULT_ALT_PART_TEXT_COLORS[colorRole] then
        return
    end

    r = Clamp(tonumber(r) or 1.0, 0, 1)
    g = Clamp(tonumber(g) or 0.82, 0, 1)
    b = Clamp(tonumber(b) or 0.0, 0, 1)

    JoypadDB.altPartTextColors[colorRole] = JoypadDB.altPartTextColors[colorRole] or {}
    JoypadDB.altPartTextColors[colorRole].r = r
    JoypadDB.altPartTextColors[colorRole].g = g
    JoypadDB.altPartTextColors[colorRole].b = b
    JoypadDB.altPartTextColors[colorRole].a = 1.0

    for _, button in ipairs(self.buttons or {}) do
        if button and button.joypadSlot and button.joypadSlot >= 13 and button.joypadSlot <= 20 then
            ApplyAltPartsAppearance(button)
            UpdateButtonVisual(button)
        end
    end

    UpdateSettingsRows()
    UpdateSettingsControls()

    if not silent then
        Print((JOYPAD_ALT_PART_COLOR_LABELS[colorRole] or colorRole) .. " set to " .. JoypadGetAltPartTextColorHex(colorRole) .. ".")
    end
end

function Joypad:OpenAltPartColorPicker(colorRole)
    EnsureDB()

    colorRole = tostring(colorRole or "")
    if not JOYPAD_DEFAULT_ALT_PART_TEXT_COLORS or not JOYPAD_DEFAULT_ALT_PART_TEXT_COLORS[colorRole] then
        return
    end

    if not ColorPickerFrame then
        Print("colour picker is not available.")
        return
    end

    local r, g, b = JoypadGetAltPartTextColor(colorRole)
    local previous = { r = r, g = g, b = b }

    ColorPickerFrame.joypadAltPartColorRole = colorRole
    ColorPickerFrame.func = function()
        local newR, newG, newB = ColorPickerFrame:GetColorRGB()
        Joypad:SetAltPartTextColor(ColorPickerFrame.joypadAltPartColorRole or colorRole, newR, newG, newB, true)
    end
    ColorPickerFrame.cancelFunc = function(values)
        values = values or previous
        Joypad:SetAltPartTextColor(colorRole, values.r or values[1] or previous.r, values.g or values[2] or previous.g, values.b or values[3] or previous.b, true)
    end
    ColorPickerFrame.hasOpacity = false
    ColorPickerFrame.opacityFunc = nil
    ColorPickerFrame.previousValues = previous
    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame:Show()
end

function Joypad:OpenAltColorPicker(joypadSlot)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    if not ColorPickerFrame then
        Print("colour picker is not available.")
        return
    end

    local r, g, b = GetAltTextColor(joypadSlot)
    local previous = { r = r, g = g, b = b }

    self.colorPickerSlot = joypadSlot

    ColorPickerFrame.joypadSlot = joypadSlot
    ColorPickerFrame.func = function()
        local newR, newG, newB = ColorPickerFrame:GetColorRGB()
        Joypad:SetAltTextColor(ColorPickerFrame.joypadSlot or joypadSlot, newR, newG, newB, true)
    end
    ColorPickerFrame.cancelFunc = function(values)
        values = values or previous
        Joypad:SetAltTextColor(joypadSlot, values.r or values[1] or previous.r, values.g or values[2] or previous.g, values.b or values[3] or previous.b, true)
    end
    ColorPickerFrame.hasOpacity = false
    ColorPickerFrame.opacityFunc = nil
    ColorPickerFrame.previousValues = previous
    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame:Show()
end

function Joypad:SetSlotPosition(joypadSlot, x, y, silent)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    x = Round(x)
    y = Round(y)

    JoypadDB.positions[joypadSlot] = JoypadDB.positions[joypadSlot] or {}
    JoypadDB.positions[joypadSlot].x = x
    JoypadDB.positions[joypadSlot].y = y

    if InCombat() then
        self.pendingApply = true
        if not silent then
            Print("button position update queued until combat ends.")
        end
        return
    end

    local button = self.buttons[joypadSlot]
    if button then
        LayoutButton(button, button.joypadRow or 1, button.joypadButtonIndex or 1)
    end

    UpdateEditMode()
    UpdateGroupPopupFields()

    if not silent then
        Print("slot " .. joypadSlot .. " position set to X " .. tostring(x) .. ", Y " .. tostring(y) .. ".")
    end
end

function Joypad:SetSlotScale(joypadSlot, scalePercent, silent)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    scalePercent = Clamp(Round(scalePercent or GetDefaultSlotScale()), 25, 300)
    JoypadDB.scales[joypadSlot] = scalePercent

    if InCombat() then
        self.pendingApply = true
        if not silent then
            Print("button scale update queued until combat ends.")
        end
        return
    end

    local button = self.buttons[joypadSlot]
    if button then
        LayoutButton(button, button.joypadRow or 1, button.joypadButtonIndex or 1)
    end

    UpdateEditMode()
    UpdatePositionPopupFields()
    UpdateGroupPopupFields()

    if not silent then
        Print("slot " .. joypadSlot .. " scale set to " .. tostring(scalePercent) .. "%.")
    end
end

function Joypad:AdjustSlotScale(joypadSlot, wheelDelta)
    EnsureDB()

    joypadSlot = tonumber(joypadSlot or 0) or 0
    if joypadSlot < 1 or joypadSlot > 24 then
        return
    end

    if InCombat() then
        Print("button scaling is locked during combat.")
        return
    end

    local current = GetSlotScale(joypadSlot)
    local direction = 1
    if tonumber(wheelDelta or 0) < 0 then
        direction = -1
    end

    self:SetSlotScale(joypadSlot, current + (direction * 5), true)
end

function Joypad:SetAllSlotScales(scalePercent, silent)
    EnsureDB()

    scalePercent = Clamp(Round(scalePercent or GetDefaultSlotScale()), 25, 300)

    if InCombat() then
        self.pendingApply = true
        if not silent then
            Print("group scale update queued until combat ends.")
        end
        return
    end

    for i = 1, 24 do
        JoypadDB.scales[i] = scalePercent
    end

    for _, button in ipairs(self.buttons) do
        LayoutButton(button, button.joypadRow or 1, button.joypadButtonIndex or 1)
    end

    UpdateEditMode()
    UpdatePositionPopupFields()
    UpdateGroupPopupFields()

    if not silent then
        Print("all Joypad slots scaled to " .. tostring(scalePercent) .. "%.")
    end
end


function Joypad.CopyProfileTable(source)
    if type(source) ~= "table" then
        return nil
    end

    local result = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            result[key] = Joypad.CopyProfileTable(value)
        else
            result[key] = value
        end
    end
    return result
end

function Joypad:GetLayoutProfile(profileName)
    if type(JOYPAD_LAYOUT_PROFILES) ~= "table" then
        return nil, nil
    end

    profileName = tostring(profileName or "")
    if JOYPAD_LAYOUT_PROFILES[profileName] then
        return JOYPAD_LAYOUT_PROFILES[profileName], profileName
    end

    local requested = string.lower(profileName)
    for name, profile in pairs(JOYPAD_LAYOUT_PROFILES) do
        if string.lower(tostring(name or "")) == requested then
            return profile, name
        end
    end

    return nil, nil
end

function Joypad:ApplyLayoutProfile(profileName, silent)
    EnsureDB()

    if InCombat() then
        if not silent then
            Print("profile changes are locked during combat.")
        end
        return
    end

    local profile, canonicalName = self:GetLayoutProfile(profileName)
    if type(profile) ~= "table" then
        if not silent then
            Print("profile not found: " .. tostring(profileName or ""))
        end
        return
    end

    JoypadDB.activeProfile = tostring(canonicalName or profileName or profile.name or "")

    if profile.theme then
        JoypadDB.theme = JoypadNormalizeTheme(profile.theme)
    end
    if profile.displayMode then
        JoypadDB.displayMode = JoypadNormalizeDisplayMode(profile.displayMode)
        JoypadDB.displayModeSlotProfileVersion = "0.44.12"
    end
    if profile.layoutMode == "gamepad" or profile.layoutMode == "desktop" then
        JoypadDB.layoutMode = profile.layoutMode
    end

    if profile.barsVisible ~= nil then JoypadDB.barsVisible = profile.barsVisible and true or false end
    if profile.hideBlizzardBars ~= nil then JoypadDB.hideBlizzardBars = profile.hideBlizzardBars and true or false end
    if profile.hideKeybindText ~= nil then JoypadDB.hideKeybindText = profile.hideKeybindText and true or false end
    if profile.showCooldownText ~= nil then JoypadDB.showCooldownText = profile.showCooldownText and true or false end
    if profile.showReadyFlash ~= nil then JoypadDB.showReadyFlash = profile.showReadyFlash and true or false end
    if profile.readyFlashStrength ~= nil then JoypadDB.readyFlashStrength = Joypad.NormalizeReadyFlashStrength(profile.readyFlashStrength) end
    if profile.readyFlashDuration ~= nil then JoypadDB.readyFlashDuration = Joypad.NormalizeReadyFlashDuration(profile.readyFlashDuration) end
    if profile.showActiveBorder ~= nil then JoypadDB.showActiveBorder = profile.showActiveBorder and true or false end
    if profile.stanceBarVisible ~= nil then JoypadDB.stanceBarVisible = profile.stanceBarVisible and true or false end
    if profile.snapToGrid ~= nil then JoypadDB.snapToGrid = profile.snapToGrid and true or false end
    if profile.snapToGridThreshold ~= nil then JoypadDB.snapToGridThreshold = tonumber(profile.snapToGridThreshold) or JoypadDB.snapToGridThreshold end
    if profile.uiCursorEnabled ~= nil then JoypadDB.uiCursorEnabled = profile.uiCursorEnabled and true or false end
    if profile.uiCursorPanelsOnly ~= nil then JoypadDB.uiCursorPanelsOnly = profile.uiCursorPanelsOnly and true or false end
    if profile.uiCursorShowPointer ~= nil then JoypadDB.uiCursorShowPointer = profile.uiCursorShowPointer and true or false end
    if profile.uiCursorShowHighlight ~= nil then JoypadDB.uiCursorShowHighlight = profile.uiCursorShowHighlight and true or false end
    if profile.uiCursorHideHardwareCursor ~= nil then JoypadDB.uiCursorHideHardwareCursor = profile.uiCursorHideHardwareCursor and true or false end
    if profile.smartMouselookCenterDelay ~= nil then JoypadDB.smartMouselookCenterDelay = Joypad.NormalizeSmartMouselookCenterDelay(profile.smartMouselookCenterDelay) end
    if profile.hideMouseWhileMoving ~= nil then JoypadDB.hideMouseWhileMoving = profile.hideMouseWhileMoving and true or false end
    if profile.smartMouselookEnabled ~= nil then JoypadDB.smartMouselookEnabled = profile.smartMouselookEnabled and true or false end
    if profile.smartMouselookOnMove ~= nil then JoypadDB.smartMouselookOnMove = profile.smartMouselookOnMove and true or false end
    if profile.smartMouselookOnTarget ~= nil then JoypadDB.smartMouselookOnTarget = profile.smartMouselookOnTarget and true or false end
    if profile.smartMouselookOnSpell ~= nil then JoypadDB.smartMouselookOnSpell = profile.smartMouselookOnSpell and true or false end
    if profile.smartMouselookOnNPC ~= nil then JoypadDB.smartMouselookOnNPC = profile.smartMouselookOnNPC and true or false end
    if profile.smartMouselookOnQuest ~= nil then JoypadDB.smartMouselookOnQuest = profile.smartMouselookOnQuest and true or false end
    if profile.smartMouselookOnLoot ~= nil then JoypadDB.smartMouselookOnLoot = profile.smartMouselookOnLoot and true or false end
    if profile.smartMouselookOnJump ~= nil then JoypadDB.smartMouselookOnJump = profile.smartMouselookOnJump and true or false end
    if profile.smartMouselookOnCenter ~= nil then JoypadDB.smartMouselookOnCenter = profile.smartMouselookOnCenter and true or false end
    if profile.smartMouselookCenterScale ~= nil then JoypadDB.smartMouselookCenterScale = tonumber(profile.smartMouselookCenterScale) or 100 end
    if profile.smartMouselookCenterPreview ~= nil then JoypadDB.smartMouselookCenterPreview = profile.smartMouselookCenterPreview and true or false end
    if profile.smartMouselookBlocker ~= nil then JoypadDB.smartMouselookBlocker = profile.smartMouselookBlocker and true or false end
    if profile.smartMouselookForceTooltip ~= nil then JoypadDB.smartMouselookForceTooltip = profile.smartMouselookForceTooltip and true or false end
    if profile.smartMouselookTooltipAnchor ~= nil then JoypadDB.smartMouselookTooltipAnchor = profile.smartMouselookTooltipAnchor end
    if profile.smartMouselookTooltipX ~= nil then JoypadDB.smartMouselookTooltipX = tonumber(profile.smartMouselookTooltipX) or -230 end
    if profile.smartMouselookTooltipY ~= nil then JoypadDB.smartMouselookTooltipY = tonumber(profile.smartMouselookTooltipY) or -4 end
    -- v0.44.72: do not restore the old Joypad-owned target hint from profiles by default.
    -- The real Blizzard tooltip is now the normal gameplay path.
    if profile.smartMouselookMouseoverHint ~= nil and JoypadDB.allowProfileTargetHint == true then JoypadDB.smartMouselookMouseoverHint = profile.smartMouselookMouseoverHint and true or false end
    if profile.smartMouselookPreferAwesomeTarget ~= nil then JoypadDB.smartMouselookPreferAwesomeTarget = profile.smartMouselookPreferAwesomeTarget and true or false end
    JoypadDB.smartMouselookPreferActionTarget = nil
    if profile.smartMouselookUseSelectedTarget ~= nil then JoypadDB.smartMouselookUseSelectedTarget = profile.smartMouselookUseSelectedTarget and true or false end
    if profile.smartMouselookTestTooltip ~= nil and JoypadDB.allowProfileTargetHint == true then JoypadDB.smartMouselookTestTooltip = profile.smartMouselookTestTooltip and true or false end
    if profile.smartMouselookPauseOnModifier ~= nil then JoypadDB.smartMouselookPauseOnModifier = profile.smartMouselookPauseOnModifier and true or false end
    if profile.raidCursorEnabled ~= nil then JoypadDB.raidCursorEnabled = profile.raidCursorEnabled and true or false end
    if profile.raidCursorTargetOnMove ~= nil then JoypadDB.raidCursorTargetOnMove = profile.raidCursorTargetOnMove and true or false end
    if profile.raidCursorAFallback ~= nil and JoypadDB.allowRaidCursorAProfile == true then JoypadDB.raidCursorAFallback = profile.raidCursorAFallback and true or false end
    if profile.raidCursorLogEnabled ~= nil then JoypadDB.raidCursorLogEnabled = profile.raidCursorLogEnabled and true or false end
    if profile.raidTargetSteeringEnabled ~= nil then JoypadDB.raidTargetSteeringEnabled = profile.raidTargetSteeringEnabled and true or false end
    if profile.raidTargetSteeringEveryHeal ~= nil then JoypadDB.raidTargetSteeringEveryHeal = profile.raidTargetSteeringEveryHeal and true or false end
    if profile.raidTargetSteeringLogEnabled ~= nil then JoypadDB.raidTargetSteeringLogEnabled = profile.raidTargetSteeringLogEnabled and true or false end
    if profile.inputLogEnabled ~= nil then JoypadDB.inputLogEnabled = profile.inputLogEnabled and true or false end
    if profile.warnMissingKeybinds ~= nil then JoypadDB.warnMissingKeybinds = profile.warnMissingKeybinds and true or false end

    if profile.stanceBarX ~= nil then JoypadDB.stanceBarX = tonumber(profile.stanceBarX) or 0 end
    if profile.stanceBarY ~= nil then JoypadDB.stanceBarY = tonumber(profile.stanceBarY) or 0 end
    if profile.stanceBarScale ~= nil then JoypadDB.stanceBarScale = tonumber(profile.stanceBarScale) or JOYPAD_STANCE_DEFAULT_SCALE end

    if type(profile.positions) == "table" then JoypadDB.positions = Joypad.CopyProfileTable(profile.positions) or {} end
    if type(profile.scales) == "table" then JoypadDB.scales = Joypad.CopyProfileTable(profile.scales) or {} end
    if type(profile.slotEnabled) == "table" then JoypadDB.slotEnabled = Joypad.CopyProfileTable(profile.slotEnabled) or {} end
    if type(profile.diamondSlots) == "table" then JoypadDB.diamondSlots = Joypad.CopyProfileTable(profile.diamondSlots) or {} end
    if type(profile.altTextScales) == "table" then JoypadDB.altTextScales = Joypad.CopyProfileTable(profile.altTextScales) or {} end
    if type(profile.altTextColors) == "table" then JoypadDB.altTextColors = Joypad.CopyProfileTable(profile.altTextColors) or {} end
    if type(profile.altPartTextColors) == "table" then JoypadDB.altPartTextColors = Joypad.CopyProfileTable(profile.altPartTextColors) or {} end
    if type(profile.actionSlots) == "table" then JoypadDB.actionSlots = Joypad.CopyProfileTable(profile.actionSlots) or {} end
    if type(profile.bindingModes) == "table" then JoypadDB.bindingModes = Joypad.CopyProfileTable(profile.bindingModes) or {} end
    if type(profile.keybindCommands) == "table" then JoypadDB.keybindCommands = Joypad.CopyProfileTable(profile.keybindCommands) or {} end
    if type(profile.layerAssignments) == "table" then JoypadDB.layerAssignments = Joypad.CopyProfileTable(profile.layerAssignments) or {} end
    if profile.showAltScaleControls ~= nil then JoypadDB.showAltScaleControls = profile.showAltScaleControls and true or false end
    if profile.showAltColorControls ~= nil then JoypadDB.showAltColorControls = profile.showAltColorControls and true or false end
    if profile.minimapAngle ~= nil then JoypadDB.minimapAngle = tonumber(profile.minimapAngle) or JoypadDB.minimapAngle end

    for i = 1, 24 do
        if JoypadDB.slotEnabled[i] == nil then
            JoypadDB.slotEnabled[i] = JoypadGetDisplayModeSlotEnabled(JoypadDB.displayMode, i)
        end
        if JoypadDB.altTextScales[i] == nil then
            JoypadDB.altTextScales[i] = GetDefaultAltTextScale(i)
        end
    end

    self:Apply(true)
    UpdateSettingsRows()
    UpdateSettingsControls()
    UpdateEditMode()
    UpdatePositionPopupFields()
    UpdateGroupPopupFields()
    UpdateStancePopupFields()

    if not silent then
        Print("applied " .. tostring(profile.name or canonicalName or profileName) .. " profile.")
    end
end

function Joypad:WhisperScuzForHelp()
    if GetRealmName and tostring(GetRealmName() or "") ~= "Triumvirate" then
        Print("Scuz help whisper is only shown on Triumvirate.")
        return
    end

    if SendChatMessage then
        SendChatMessage("I need help with Joypad", "WHISPER", nil, "Scuz")
    elseif ChatFrame_OpenChat then
        ChatFrame_OpenChat("/whisper Scuz I need help with Joypad")
    end
end

function Joypad:ResetAllLayout(silent)
    EnsureDB()

    if InCombat() then
        if not silent then
            Print("layout reset is locked during combat.")
        end
        return
    end

    JoypadDB.positions = {}
    JoypadDB.scales = {}
    JoypadDB.altTextScales = {}
    JoypadDB.altTextColors = {}
    JoypadDB.altPartTextColors = {}
    JoypadDB.stanceBarX = JOYPAD_STANCE_DEFAULT_X or 0
    JoypadDB.stanceBarY = JOYPAD_STANCE_DEFAULT_Y or -460
    JoypadDB.stanceBarScale = JOYPAD_STANCE_DEFAULT_SCALE or 70
    for i = 1, 24 do
        JoypadDB.altTextScales[i] = GetDefaultAltTextScale(i)
    end

    self:LayoutStanceBar()
    self:UpdateStanceBarVisuals()

    for _, button in ipairs(self.buttons) do
        LayoutButton(button, button.joypadRow or 1, button.joypadButtonIndex or 1)
        UpdateButtonVisual(button)
    end

    UpdateSettingsRows()
    UpdateEditMode()
    UpdatePositionPopupFields()
    UpdateGroupPopupFields()

    if not silent then
        Print("Joypad layout reset to defaults: X/Y, button Scale %, Alt % modifier, Alt colours, and Touch Bar layout.")
    end
end


function Joypad:MoveAllSlotsBy(deltaX, deltaY, silent)
    EnsureDB()

    deltaX = Round(deltaX or 0)
    deltaY = Round(deltaY or 0)

    if deltaX == 0 and deltaY == 0 then
        return
    end

    if InCombat() then
        self.pendingApply = true
        if not silent then
            Print("group position update queued until combat ends.")
        end
        return
    end

    for i = 1, 24 do
        local x, y = GetSlotPosition(i)
        JoypadDB.positions[i] = JoypadDB.positions[i] or {}
        JoypadDB.positions[i].x = Round(x + deltaX)
        JoypadDB.positions[i].y = Round(y + deltaY)
    end

    for _, button in ipairs(self.buttons) do
        LayoutButton(button, button.joypadRow or 1, button.joypadButtonIndex or 1)
    end

    UpdateEditMode()
    UpdatePositionPopupFields()
    UpdateGroupPopupFields()

    if not silent then
        local x, y = GetGroupCenter()
        Print("Joypad group moved to X " .. tostring(x) .. ", Y " .. tostring(y) .. ".")
    end
end

function Joypad:SetGroupCenter(x, y, silent)
    local currentX, currentY = GetGroupCenter()
    self:MoveAllSlotsBy((tonumber(x) or 0) - currentX, (tonumber(y) or 0) - currentY, silent)
end

function Joypad:CenterJoypadLayout(silent)
    if InCombat() then
        self:SetGroupCenter(0, 0, silent)
        return
    end

    self:SetGroupCenter(0, 0, true)

    if not silent then
        Print("Joypad layout centred on screen.")
    end
end


function Joypad:ApplyGroupDragPositions(originalPositions, deltaX, deltaY)
    EnsureDB()

    deltaX = Round(deltaX or 0)
    deltaY = Round(deltaY or 0)

    if InCombat() or type(originalPositions) ~= "table" then
        return
    end

    for i = 1, 24 do
        local original = originalPositions[i]
        if original then
            JoypadDB.positions[i] = JoypadDB.positions[i] or {}
            JoypadDB.positions[i].x = Round(original.x + deltaX)
            JoypadDB.positions[i].y = Round(original.y + deltaY)
        end
    end

    for _, button in ipairs(self.buttons) do
        LayoutButton(button, button.joypadRow or 1, button.joypadButtonIndex or 1)
    end

    UpdateEditMode()
    UpdatePositionPopupFields()
    UpdateGroupPopupFields()
end

function Joypad:StartDragGroup(groupOverlay)
    EnsureDB()

    if JoypadDB.unlocked ~= true or not groupOverlay then
        return
    end

    if InCombat() then
        Print("group positioning is locked during combat.")
        return
    end

    if not GetCursorPosition or not UIParent then
        return
    end

    local uiScale = UIParent:GetEffectiveScale() or 1
    local cursorX, cursorY = GetCursorPosition()
    groupOverlay.dragStartX = cursorX / uiScale
    groupOverlay.dragStartY = cursorY / uiScale
    groupOverlay.dragStartGroupX, groupOverlay.dragStartGroupY = GetGroupCenter()
    groupOverlay.originalPositions = {}

    for i = 1, 24 do
        local x, y = GetSlotPosition(i)
        groupOverlay.originalPositions[i] = { x = x, y = y }
    end

    groupOverlay:SetScript("OnUpdate", function(selfOverlay)
        if not GetCursorPosition or not UIParent then
            return
        end

        local scale = UIParent:GetEffectiveScale() or 1
        local currentX, currentY = GetCursorPosition()
        currentX = currentX / scale
        currentY = currentY / scale

        local deltaX, deltaY = currentX - selfOverlay.dragStartX, currentY - selfOverlay.dragStartY
        deltaX, deltaY = JoypadAdjustDeltaForGridSnap(selfOverlay.dragStartGroupX or 0, selfOverlay.dragStartGroupY or 0, deltaX, deltaY)
        Joypad:ApplyGroupDragPositions(selfOverlay.originalPositions, deltaX, deltaY)
    end)
end

function Joypad:StopDragGroup(groupOverlay)
    if groupOverlay then
        groupOverlay:SetScript("OnUpdate", nil)
        groupOverlay.originalPositions = nil
        groupOverlay.dragStartGroupX = nil
        groupOverlay.dragStartGroupY = nil
    end
    UpdateGroupPopupFields()
end

function Joypad:SetUnlocked(unlocked, silent)
    EnsureDB()

    if unlocked then
        unlocked = true
    else
        unlocked = false
    end

    JoypadDB.unlocked = unlocked

    if self.settingsPanel and self.settingsPanel.unlockPositioning then
        self.settingsPanel.unlockPositioning:SetChecked(unlocked and true or false)
    end
    UpdateSettingsControls()

    if not unlocked then
        if self.positionPopup then
            self.positionPopup:Hide()
        end
        if self.groupPopup then
            self.groupPopup:Hide()
        end
    end

    UpdateEditMode()

    if not silent then
        if unlocked then
            Print("button positioning unlocked. Drag buttons near grid lines to snap, scale with mouse wheel, or use the group border to move all slots together.")
        else
            Print("button positioning locked.")
        end
    end
end

function Joypad:SetBarsVisible(visible, silent)
    EnsureDB()

    if visible then
        visible = true
    else
        visible = false
    end

    JoypadDB.barsVisible = visible

    if InCombat() then
        self.pendingVisibility = visible
        if not silent then
            Print("bar visibility update queued until combat ends.")
        end
        return
    end

    if visible then
        holder:Show()
    else
        holder:Hide()
    end

    UpdateEditMode()

    if not silent then
        if visible then
            Print("bars shown.")
        else
            Print("bars hidden.")
        end
    end
end

function Joypad:SetBlizzardBarsHidden(hidden, silent)
    EnsureDB()

    if hidden then
        hidden = true
    else
        hidden = false
    end

    JoypadDB.hideBlizzardBars = hidden

    if InCombat() then
        self.pendingBlizzardBars = true
        if not silent then
            Print("Blizzard bar visibility update queued until combat ends.")
        end
        return
    end

    ApplyBlizzardBarsVisibility()

    if not silent then
        if hidden then
            Print("Blizzard action buttons, griffins, and bar backgrounds hidden. XP bar left visible.")
        else
            Print("Blizzard action buttons, griffins, and bar backgrounds shown.")
        end
    end
end

function Joypad:ToggleBars()
    EnsureDB()
    self:SetBarsVisible(not JoypadDB.barsVisible, false)
end

function Joypad:Apply(silent)
    EnsureDB()

    if InCombat() and self.created then
        self.pendingApply = true
        UpdateAllButtons()
        if not silent then
            Print("layout update queued until combat ends.")
        end
        return
    end

    holder:ClearAllPoints()
    holder:SetPoint("CENTER", UIParent, "CENTER", X_OFFSET, Y_OFFSET)
    holder:SetWidth((BUTTON_SIZE * BUTTONS_PER_BAR) + (BUTTON_GAP * (BUTTONS_PER_BAR - 1)))
    holder:SetHeight((BUTTON_SIZE * 2) + BAR_GAP)

    CreateButtonsOnce()
    self:CreateStanceBar()
    self:LayoutStanceBar()

    for _, button in ipairs(self.buttons) do
        local actionSlot, bindingCommand = GetJoypadSlotInfo(button.joypadSlot, "base")
        button.actionSlot = actionSlot
        button.bindingCommand = bindingCommand or button.bindingCommand
        ApplyButtonSecureLayerAttributes(button)
        LayoutButton(button, button.joypadRow or 1, button.joypadButtonIndex)
    end

    ApplyJoypadBindingOverrides(true)
    self:UpdateUICursorActivation(true)
    self:UpdateSmartMouselookCenterPreview(true)
    ApplyButtonSlotVisibility()
    UpdateAllButtons()
    self:SetBarsVisible(JoypadDB.barsVisible, true)
    self:SetStanceBarVisible(JoypadDB.stanceBarVisible ~= false, true)
    ApplyBlizzardBarsVisibility()
    self:CreateMinimapButton()
    UpdateEditMode()

    if not silent then
        Print("showing standalone 50px Joypad buttons with secure state-driver layer test.")
    end
end

Joypad:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if tostring(arg1 or "") == "Shifty" then
            self:SetupShiftySuggestionHighlights()
        end
        return
    end

    if event == "PLAYER_STARTED_MOVING" then
        self:SetMovementCursorState("move", true)
        return
    end

    if event == "PLAYER_STOPPED_MOVING" then
        self:SetMovementCursorState("move", false)
        return
    end

    if event == "PLAYER_STARTED_TURNING" then
        self:SetMovementCursorState("turn", true)
        return
    end

    if event == "PLAYER_STOPPED_TURNING" then
        self:SetMovementCursorState("turn", false)
        return
    end

    if event == "PLAYER_STARTED_STRAFING" then
        self:SetMovementCursorState("strafe", true)
        return
    end

    if event == "PLAYER_STOPPED_STRAFING" then
        self:SetMovementCursorState("strafe", false)
        return
    end

    if event == "PLAYER_STARTED_ASCENDING" or event == "PLAYER_STARTED_DESCENDING" then
        self:SetMovementCursorState("vertical", true)
        return
    end

    if event == "PLAYER_STOPPED_ASCENDING" or event == "PLAYER_STOPPED_DESCENDING" then
        self:SetMovementCursorState("vertical", false)
        return
    end

    if event == "PLAYER_STARTED_LOOKING" then
        self:SetMovementCursorState("look", true)
        return
    end

    if event == "PLAYER_STOPPED_LOOKING" then
        self:SetMovementCursorState("look", false)
        return
    end

    if event == "UNIT_SPELLCAST_SENT" then
        if arg1 == "player" then
            self:PulseSmartMouselook("spell", 0.35)
        end
        return
    end

    if event == "LOOT_OPENED" then
        self:PulseSmartMouselook("loot", 0.45)
        return
    end

    if event == "LOOT_CLOSED" then
        self:StopSmartMouselookReason("loot")
        return
    end

    if event == "QUEST_GREETING" or event == "QUEST_DETAIL" or event == "QUEST_PROGRESS" or event == "QUEST_COMPLETE" or event == "QUEST_AUTOCOMPLETE" then
        self:PulseSmartMouselook("quest", 0.45)
        return
    end

    if event == "QUEST_FINISHED" then
        self:StopSmartMouselookReason("quest")
        return
    end

    if event == "GOSSIP_SHOW" or event == "MERCHANT_SHOW" or event == "TAXIMAP_OPENED" then
        self:PulseSmartMouselook("npc", 0.45)
        return
    end

    if event == "GOSSIP_CLOSED" or event == "MERCHANT_CLOSED" or event == "TAXIMAP_CLOSED" then
        self:StopSmartMouselookReason("npc")
        return
    end

    if event == "UPDATE_MOUSEOVER_UNIT" or event == "PLAYER_TARGET_CHANGED" or event == "NAME_PLATE_UNIT_ADDED" or event == "NAME_PLATE_UNIT_REMOVED" then
        self:UpdateSmartMouselookMouseoverHint(0, true)
        self:UpdateSmartMouselookTestTooltip(0, true)
        return
    end

    if event == "PLAYER_REGEN_DISABLED" then
        -- Combat safety: UI cursor override bindings intentionally reuse Joypad
        -- action keys while panels are open. Clear that temporary owner as early
        -- as possible so combat input stays on the Joypad action buttons. Smart
        -- mouselook itself is camera state, so keep/resync it instead of stopping
        -- it outright.
        self.uiCursorActive = false
        if self.uiCursorBindingsApplied then
            self:ClearUICursorBindings(true)
        end
        if self.uiCursorHighlight then
            self.uiCursorHighlight:Hide()
        end
        if self.uiCursorPointer then
            self.uiCursorPointer:Hide()
        end
        self:RestoreHardwareCursor("uiCursor")
        self:ResyncSmartMouselook("combat-start")
        return
    end

    if event == "PLAYER_REGEN_ENABLED" then
        self:ResyncSmartMouselook("combat-end")
        if self.uiCursorBindingsApplied and JoypadDB and JoypadDB.uiCursorEnabled ~= true then
            self:ClearUICursorBindings(true)
        end

        if self.pendingApply then
            self.pendingApply = nil
            self:Apply(true)
        else
            JoypadQueueRefresh("all")
        end

        if self.pendingVisibility ~= nil then
            local visible = self.pendingVisibility
            self.pendingVisibility = nil
            self:SetBarsVisible(visible, true)
        end

        if self.pendingSlotVisibility then
            self.pendingSlotVisibility = nil
            ApplyButtonSlotVisibility()
            JoypadQueueRefresh("settings")
        end

        if self.pendingBlizzardBars then
            self.pendingBlizzardBars = nil
            ApplyBlizzardBarsVisibility()
        end

        if self.pendingBindingOverrides then
            self.pendingBindingOverrides = nil
            ApplyJoypadBindingOverrides(true)
            JoypadQueueRefresh("all")
        end

        if self.pendingRaidCursorBindings then
            self.pendingRaidCursorBindings = nil
            self:UpdateRaidCursorBindings("combat-end")
        end

        if self.pendingStanceVisibility then
            self.pendingStanceVisibility = nil
            self:SetStanceBarVisible(JoypadDB.stanceBarVisible ~= false, true)
        end

        if self.pendingStanceLayout then
            self.pendingStanceLayout = nil
            self:LayoutStanceBar()
            self:UpdateStanceBarVisuals()
            UpdateStancePopupFields()
        end

        self:UpdateUICursorActivation(true)
        UpdateEditMode()
        JoypadProcessRefreshQueue(false)
        return
    end

    if event == "PLAYER_LOGIN" then
        EnsureDB()
        self:CreateMinimapButton()
        self:CreateSettingsPanel()
        self:CreateUICursorPanel()
        self:CreateBindingsPanel()
        self:SetupAdiBagsCompatibility()
        self:InstallSmartMouselookHooks()
        self:CreateRaidCursor()
        self:Apply(false)
        self:UpdateUICursorActivation(true)
        self:SetupShiftySuggestionHighlights()
        self:UpdateRaidCursorBindings("login")
        self:ScheduleMissingKeybindCheck("login", 4.0)
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        self:ClearMovementCursorHide()
        self:Apply(true)
        self:SetupShiftySuggestionHighlights()
        self:UpdateRaidCursorBindings("entering-world")
        self:ScheduleMissingKeybindCheck("entering-world", 5.0)
        return
    end

    if event == "UPDATE_BINDINGS" then
        ApplyJoypadBindingOverrides(true)
        JoypadQueueRefresh("all")
        self:UpdateRaidCursorBindings("bindings")
        self:ScheduleMissingKeybindCheck("bindings", 1.0)
        return
    end

    if event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_TALENT_UPDATE" or event == "CHARACTER_POINTS_CHANGED" or event == "SPELLS_CHANGED" then
        self:RefreshAfterSpecOrSpellChange(event)
        return
    end

    if event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
        self:UpdateRaidCursorBindings(event)
        return
    end

    if event == "ACTIONBAR_SLOT_CHANGED" then
        if JoypadInvalidateActionSlotCache then
            JoypadInvalidateActionSlotCache(arg1)
        end
        JoypadQueueRefresh("all")
        -- Action bar replacement during dual-spec swaps can arrive in waves.
        -- Queue one delayed refresh as well, but avoid a full Apply on every
        -- ordinary drag/drop by using the normal lightweight queue here.
        JoypadTimerAfter(0.25, function()
            if Joypad then
                JoypadQueueRefresh("all")
                JoypadProcessRefreshQueue(true)
            end
        end)
        return
    end

    if event == "UPDATE_SHAPESHIFT_FORM" or event == "UPDATE_BONUS_ACTIONBAR" or event == "ACTIONBAR_PAGE_CHANGED" or event == "MODIFIER_STATE_CHANGED" or event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "VEHICLE_UPDATE" or event == "UPDATE_VEHICLE_ACTIONBAR" or event == "UPDATE_POSSESS_BAR" or event == "UPDATE_OVERRIDE_ACTIONBAR" then
        if event ~= "MODIFIER_STATE_CHANGED" and JoypadInvalidateActionSlotCache then
            JoypadInvalidateActionSlotCache()
        end
        JoypadQueueRefresh("buttons")
        if event ~= "MODIFIER_STATE_CHANGED" then
            JoypadTimerAfter(0.10, function()
                if Joypad then JoypadQueueRefresh("buttons"); JoypadProcessRefreshQueue(true) end
            end)
        end
        return
    end

    if event == "ACTIONBAR_UPDATE_STATE" or event == "ACTIONBAR_UPDATE_USABLE" or event == "ACTIONBAR_UPDATE_COOLDOWN" or event == "PLAYER_TARGET_CHANGED" or event == "BAG_UPDATE" or event == "UNIT_INVENTORY_CHANGED" then
        if (event == "BAG_UPDATE" or event == "UNIT_INVENTORY_CHANGED") and JoypadInvalidateActionSlotCache then
            JoypadInvalidateActionSlotCache()
        end
        if event == "PLAYER_TARGET_CHANGED" then
            self:PulseSmartMouselook("target", 0.35)
            if self.raidCursorBindingsActive then
                self:LogRaidCursorEvent("target-changed", { reason = "PLAYER_TARGET_CHANGED" })
            end
        end
        JoypadQueueRefresh("buttons")
        return
    end

    self:Apply(true)
end)

Joypad:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 0.20 then
        self.elapsed = 0
        self:UpdateUICursorActivation(false)
        JoypadProcessRefreshQueue(false)
    end

    Joypad.UpdateActiveCooldownTexts(elapsed)
    Joypad.UpdateReadyFlashWatches(elapsed)
    Joypad.UpdateActiveReadyFlashes(elapsed)
    self:UpdateShiftySuggestionHighlightTimeout(elapsed)
    self:UpdateSmartMouselookCenter(elapsed)
    self:UpdateSmartMouselookModifierPause(elapsed)
    self:UpdateSmartMouselookForcedTooltip(elapsed)
    self:UpdateSmartMouselookMouseoverHint(elapsed, false)
    self:UpdateSmartMouselookTestTooltip(elapsed, false)

    self.safetyElapsed = (self.safetyElapsed or 0) + elapsed
    if self.safetyElapsed >= 5.00 then
        self.safetyElapsed = 0
        self:ResyncSmartMouselook("safety")
        if holder:IsShown() or (self.stanceHolder and self.stanceHolder:IsShown()) then
            JoypadQueueRefresh("buttons")
        end
    end
end)

function JoypadSafeRegisterEvent(frame, eventName)
    if not frame or not eventName then
        return
    end
    if pcall then
        local ok = pcall(function() frame:RegisterEvent(eventName) end)
        return ok
    end
    frame:RegisterEvent(eventName)
    return true
end

JoypadSafeRegisterEvent(Joypad, "ADDON_LOADED")
Joypad:RegisterEvent("PLAYER_LOGIN")
Joypad:RegisterEvent("PLAYER_ENTERING_WORLD")
Joypad:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
Joypad:RegisterEvent("ACTIONBAR_UPDATE_STATE")
Joypad:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
Joypad:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
Joypad:RegisterEvent("MODIFIER_STATE_CHANGED")
Joypad:RegisterEvent("UPDATE_BINDINGS")
JoypadSafeRegisterEvent(Joypad, "ACTIVE_TALENT_GROUP_CHANGED")
JoypadSafeRegisterEvent(Joypad, "PLAYER_TALENT_UPDATE")
JoypadSafeRegisterEvent(Joypad, "CHARACTER_POINTS_CHANGED")
JoypadSafeRegisterEvent(Joypad, "SPELLS_CHANGED")
Joypad:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
Joypad:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
Joypad:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
JoypadSafeRegisterEvent(Joypad, "UNIT_ENTERED_VEHICLE")
JoypadSafeRegisterEvent(Joypad, "UNIT_EXITED_VEHICLE")
JoypadSafeRegisterEvent(Joypad, "VEHICLE_UPDATE")
JoypadSafeRegisterEvent(Joypad, "UPDATE_VEHICLE_ACTIONBAR")
JoypadSafeRegisterEvent(Joypad, "UPDATE_POSSESS_BAR")
JoypadSafeRegisterEvent(Joypad, "UPDATE_OVERRIDE_ACTIONBAR")
Joypad:RegisterEvent("PLAYER_TARGET_CHANGED")
JoypadSafeRegisterEvent(Joypad, "UPDATE_MOUSEOVER_UNIT")
JoypadSafeRegisterEvent(Joypad, "NAME_PLATE_UNIT_ADDED")
JoypadSafeRegisterEvent(Joypad, "NAME_PLATE_UNIT_REMOVED")
JoypadSafeRegisterEvent(Joypad, "PLAYER_TARGET_CHANGED")
JoypadSafeRegisterEvent(Joypad, "RAID_ROSTER_UPDATE")
JoypadSafeRegisterEvent(Joypad, "PARTY_MEMBERS_CHANGED")
Joypad:RegisterEvent("PLAYER_REGEN_ENABLED")
JoypadSafeRegisterEvent(Joypad, "PLAYER_REGEN_DISABLED")
JoypadSafeRegisterEvent(Joypad, "PLAYER_STARTED_MOVING")
JoypadSafeRegisterEvent(Joypad, "PLAYER_STOPPED_MOVING")
JoypadSafeRegisterEvent(Joypad, "PLAYER_STARTED_TURNING")
JoypadSafeRegisterEvent(Joypad, "PLAYER_STOPPED_TURNING")
JoypadSafeRegisterEvent(Joypad, "PLAYER_STARTED_STRAFING")
JoypadSafeRegisterEvent(Joypad, "PLAYER_STOPPED_STRAFING")
JoypadSafeRegisterEvent(Joypad, "PLAYER_STARTED_ASCENDING")
JoypadSafeRegisterEvent(Joypad, "PLAYER_STOPPED_ASCENDING")
JoypadSafeRegisterEvent(Joypad, "PLAYER_STARTED_DESCENDING")
JoypadSafeRegisterEvent(Joypad, "PLAYER_STOPPED_DESCENDING")
JoypadSafeRegisterEvent(Joypad, "PLAYER_STARTED_LOOKING")
JoypadSafeRegisterEvent(Joypad, "PLAYER_STOPPED_LOOKING")
JoypadSafeRegisterEvent(Joypad, "UNIT_SPELLCAST_SENT")
JoypadSafeRegisterEvent(Joypad, "LOOT_OPENED")
JoypadSafeRegisterEvent(Joypad, "LOOT_CLOSED")
JoypadSafeRegisterEvent(Joypad, "QUEST_GREETING")
JoypadSafeRegisterEvent(Joypad, "QUEST_DETAIL")
JoypadSafeRegisterEvent(Joypad, "QUEST_PROGRESS")
JoypadSafeRegisterEvent(Joypad, "QUEST_COMPLETE")
JoypadSafeRegisterEvent(Joypad, "QUEST_FINISHED")
JoypadSafeRegisterEvent(Joypad, "QUEST_AUTOCOMPLETE")
JoypadSafeRegisterEvent(Joypad, "GOSSIP_SHOW")
JoypadSafeRegisterEvent(Joypad, "GOSSIP_CLOSED")
JoypadSafeRegisterEvent(Joypad, "MERCHANT_SHOW")
JoypadSafeRegisterEvent(Joypad, "MERCHANT_CLOSED")
JoypadSafeRegisterEvent(Joypad, "TAXIMAP_OPENED")
JoypadSafeRegisterEvent(Joypad, "TAXIMAP_CLOSED")
Joypad:RegisterEvent("BAG_UPDATE")
Joypad:RegisterEvent("UNIT_INVENTORY_CHANGED")


function Joypad:DebugInputBindings()
    EnsureDB()

    Print("Joypad input debug: expected physical key -> bound key(s) -> base assignment")

    for joypadSlot = 1, 24 do
        local listeningCommand = GetJoypadListeningBindingCommand(joypadSlot)
        local expectedKey = GetJoypadDefaultKeyForCommand(listeningCommand) or "?"
        local expectedKeyText = JoypadCandidateKeysText(expectedKey)
        local boundKeys = {}
        if GetBindingKey and listeningCommand then
            boundKeys = { GetBindingKey(listeningCommand) }
        end

        local boundText = table.concat(boundKeys, ", ")
        if boundText == "" then
            boundText = "none"
        end

        local ok = JoypadHasBindingKey(listeningCommand, expectedKey)
        local mode = GetJoypadBindingMode(joypadSlot, "base")
        local actionSlot, _, _, _, defaultActionSlot = GetJoypadSlotInfo(joypadSlot, "base")
        local command = nil
        if mode == "keybind" then
            command = GetJoypadKeybindCommand(joypadSlot, "base")
        end

        local target = nil
        if mode == "keybind" then
            target = "keybind " .. tostring(command or "?")
        else
            target = "action " .. tostring(actionSlot or "?")
        end

        local status = ok and "OK" or "MISSING"
        Print(string.format("[%02d %s] %s -> %s = %s (%s)", joypadSlot, tostring(GetAltLabel(joypadSlot) or "?"), tostring(expectedKeyText or expectedKey), tostring(listeningCommand or "?"), boundText, status))
        Print("   Base: " .. tostring(target) .. " / default action " .. tostring(defaultActionSlot or "?"))
    end
end

function Joypad:GetMissingPhysicalKeybinds()
    EnsureDB()

    local missing = {}
    for joypadSlot = 1, 24 do
        if IsSlotEnabled(joypadSlot) then
            local listeningCommand = GetJoypadListeningBindingCommand(joypadSlot)
            local expectedKey = GetJoypadDefaultKeyForCommand(listeningCommand)
            if listeningCommand and expectedKey and not JoypadHasBindingKey(listeningCommand, expectedKey) then
                local boundKeys = {}
                if GetBindingKey then
                    boundKeys = { GetBindingKey(listeningCommand) }
                end
                local boundText = table.concat(boundKeys, ", ")
                if boundText == "" then
                    boundText = "Not Bound"
                end

                table.insert(missing, {
                    slot = joypadSlot,
                    label = tostring(GetAltLabel(joypadSlot) or ""),
                    expectedKey = expectedKey,
                    expectedKeyAliases = JoypadCandidateKeysText(expectedKey),
                    listeningCommand = listeningCommand,
                    boundKeys = boundText,
                })
            end
        end
    end

    return missing
end

function Joypad:CheckMissingPhysicalKeybinds(silent, suppressSuccess)
    EnsureDB()

    local missing = self:GetMissingPhysicalKeybinds()
    JoypadDB.missingKeybinds = missing
    JoypadDB.missingKeybindMeta = {
        lastVersion = tostring(VERSION or ""),
        lastChecked = GetTime and GetTime() or 0,
        count = #missing,
    }

    if #missing <= 0 then
        if not silent and not suppressSuccess then
            Print("Joypad keybind check: all enabled buttons are bound.")
        end
        return true
    end

    if not silent then
        Print("Joypad warning: " .. tostring(#missing) .. " enabled button(s) are missing physical keybinds.")
        local maxLines = 8
        for index, item in ipairs(missing) do
            if index > maxLines then
                Print("...and " .. tostring(#missing - maxLines) .. " more. Use /joypad inputdebug for the full list.")
                break
            end
            Print(string.format("[%02d %s] expected %s -> %s, currently %s", tonumber(item.slot or 0) or 0, tostring(item.label or "?"), tostring(item.expectedKeyAliases or item.expectedKey or "?"), tostring(item.listeningCommand or "?"), tostring(item.boundKeys or "Not Bound")))
        end
        Print("Run /joypad repairkeys out of combat, or open Key Bindings -> Joypad and bind the missing row.")
    end

    return false
end

function Joypad:ScheduleMissingKeybindCheck(reason, delay)
    EnsureDB()

    if JoypadDB.warnMissingKeybinds ~= true then
        return
    end

    delay = tonumber(delay or 3.0) or 3.0
    self.missingKeybindCheckToken = (self.missingKeybindCheckToken or 0) + 1
    local token = self.missingKeybindCheckToken

    JoypadTimerAfter(delay, function()
        if Joypad and Joypad.missingKeybindCheckToken == token and JoypadDB and JoypadDB.warnMissingKeybinds == true then
            Joypad:CheckMissingPhysicalKeybinds(false, true)
        end
    end)
end

function Joypad:RepairPhysicalKeybinds(silent)
    if InCombat() then
        if not silent then
            Print("physical keybind repair is locked during combat.")
        end
        return
    end

    JoypadRepairDefaultPhysicalKeybinds(silent)
    ApplyJoypadBindingOverrides(true)

    if self.Apply then
        self:Apply(true)
    end
    UpdateSettingsRows()

    if not silent then
        Print("Joypad physical keybinds and overrides repaired.")
        self:CheckMissingPhysicalKeybinds(false)
    end
end

function Joypad:DebugDumpSlotLayout()
    EnsureDB()

    Print("slot layout debug dump: Base / Shift / Ctrl / Shift+Ctrl defaults")

    for i = 1, 24 do
        local x, y = GetSlotPosition(i)
        local scale = GetSlotScale(i)
        local enabled = IsSlotEnabled(i) and "on" or "off"
        local parts = {}
        for _, layer in ipairs(JOYPAD_LAYERS) do
            local mode = GetJoypadBindingMode(i, layer.key)
            if mode == "keybind" then
                table.insert(parts, layer.label .. "=" .. tostring(GetJoypadKeybindCommand(i, layer.key)))
            else
                local actionSlot = GetJoypadSlotInfo(i, layer.key)
                table.insert(parts, layer.label .. "=slot " .. tostring(actionSlot or 0))
            end
        end
        Print(string.format("[%02d] %s binding=%s x=%d y=%d scale=%d %s -- %s", i, tostring(GetAltLabel(i)), tostring((select(2, GetJoypadSlotInfo(i, "base")))), Round(x), Round(y), Round(scale), table.concat(parts, ", "), enabled))
    end
end

SLASH_JOYPAD1 = "/joypad"
SlashCmdList.JOYPAD = function(msg)
    msg = string.lower(msg or "")

    if msg == "" or msg == "apply" or msg == "refresh" or msg == "reload" then
        Joypad:Apply(false)
        return
    end

    if msg == "show" then
        Joypad:SetBarsVisible(true, false)
        return
    end

    if msg == "hide" then
        Joypad:SetBarsVisible(false, false)
        return
    end

    if msg == "toggle" then
        Joypad:ToggleBars()
        return
    end

    if msg == "blizzard" or msg == "hideblizzard" then
        EnsureDB()
        Joypad:SetBlizzardBarsHidden(not JoypadDB.hideBlizzardBars, false)
        return
    end

    if msg == "keybinds" or msg == "hotkeys" then
        EnsureDB()
        Joypad:SetKeybindTextHidden(not JoypadDB.hideKeybindText, false)
        return
    end

    if msg == "cooldowns" or msg == "cdtext" or msg == "cooldowntext" then
        EnsureDB()
        Joypad:SetCooldownTextShown(JoypadDB.showCooldownText == false, false)
        return
    end

    if msg == "fixinput" or msg == "input" or msg == "repairinput" then
        Joypad:RepairInputBindings(false)
        return
    end

    if msg == "uicursor off" or msg == "cursor off" or msg == "cursoroff" or msg == "uioff" then
        Joypad:SetUICursorEnabled(false, false)
        Joypad:RepairInputBindings(true)
        Print("UI cursor disabled and input bindings repaired.")
        return
    end

    if msg == "uicursor on" or msg == "cursor on" or msg == "cursoron" or msg == "uion" then
        Joypad:SetUICursorEnabled(true, false)
        return
    end

    if msg == "uicursor" or msg == "cursor" or msg == "togglecursor" then
        EnsureDB()
        Joypad:SetUICursorEnabled(JoypadDB.uiCursorEnabled ~= true, false)
        return
    end

    if msg == "centerzone on" or msg == "smartcenter preview on" or msg == "centerpreview on" then
        Joypad:SetSmartMouselookCenterPreviewShown(true, false)
        return
    end

    if msg == "centerzone off" or msg == "smartcenter preview off" or msg == "centerpreview off" then
        Joypad:SetSmartMouselookCenterPreviewShown(false, false)
        return
    end

    if msg == "centerzone" or msg == "smartcenter preview" or msg == "centerpreview" then
        EnsureDB()
        Joypad:SetSmartMouselookCenterPreviewShown(JoypadDB.smartMouselookCenterPreview ~= true, false)
        return
    end

    local centerScale = string.match(msg, "^centerzone%s+(%d+)$") or string.match(msg, "^smartcenter%s+scale%s+(%d+)$") or string.match(msg, "^centerpreview%s+scale%s+(%d+)$")
    if centerScale then
        Joypad:SetSmartMouselookCenterScale(tonumber(centerScale), false)
        return
    end

    local centerDelay = string.match(msg, "^centerdelay%s+(%a+)$") or string.match(msg, "^smartcenter%s+delay%s+(%a+)$") or string.match(msg, "^centerzone%s+delay%s+(%a+)$")
    if centerDelay then
        Joypad:SetSmartMouselookCenterDelay(centerDelay, false)
        return
    end

    if msg == "centerdelay" or msg == "smartcenter delay" or msg == "centerzone delay" then
        EnsureDB()
        Print("smart mouselook centre activation delay is " .. Joypad.GetSmartMouselookCenterDelayLabel(JoypadDB.smartMouselookCenterDelay) .. ". Use instant, short, normal, or long.")
        return
    end

    if msg == "smartcenter on" or msg == "centerlook on" or msg == "mouselook center on" then
        Joypad:SetSmartMouselookTrigger("center", true, false)
        return
    end

    if msg == "smartcenter off" or msg == "centerlook off" or msg == "mouselook center off" then
        Joypad:SetSmartMouselookTrigger("center", false, false)
        return
    end

    if msg == "smartcenter" or msg == "centerlook" or msg == "mouselook center" then
        EnsureDB()
        Joypad:SetSmartMouselookTrigger("center", JoypadDB.smartMouselookOnCenter ~= true, false)
        return
    end

    if msg == "mousemove off" or msg == "mouselook off" or msg == "smartmouse off" or msg == "hidemouse off" or msg == "mousehide off" or msg == "hidecursor off" then
        Joypad:SetSmartMouselookEnabled(false, false)
        return
    end

    if msg == "mousemove on" or msg == "mouselook on" or msg == "smartmouse on" or msg == "hidemouse on" or msg == "mousehide on" or msg == "hidecursor on" then
        Joypad:SetSmartMouselookEnabled(true, false)
        return
    end

    if msg == "mousemove" or msg == "mouselook" or msg == "smartmouse" or msg == "hidemouse" or msg == "mousehide" or msg == "hidecursor" then
        EnsureDB()
        Joypad:SetSmartMouselookEnabled(JoypadDB.smartMouselookEnabled ~= true, false)
        return
    end

    if msg == "raidcursor on" or msg == "raid cursor on" then
        Joypad:SetRaidCursorEnabled(true, false)
        return
    end

    if msg == "raidcursor off" or msg == "raid cursor off" then
        Joypad:SetRaidCursorEnabled(false, false)
        return
    end

    if msg == "raidcursor targetonmove on" or msg == "raidcursor automove on" then
        Joypad:SetRaidCursorTargetOnMove(true, false)
        return
    end

    if msg == "raidcursor targetonmove off" or msg == "raidcursor automove off" then
        Joypad:SetRaidCursorTargetOnMove(false, false)
        return
    end

    if msg == "raidcursor a on" or msg == "raidcursor fallback on" then
        Joypad:SetRaidCursorAFallback(true, false)
        return
    end

    if msg == "raidcursor a off" or msg == "raidcursor fallback off" then
        Joypad:SetRaidCursorAFallback(false, false)
        return
    end

    if msg == "raidcursor scan" then
        Joypad:RefreshRaidCursorFrameStack("slash")
        Joypad:PrintRaidCursorStatus()
        return
    end

    local raidPad = string.match(msg or "", "^raidcursor padding%s+(%d+)$")
    if raidPad then
        EnsureDB()
        JoypadDB.raidCursorHighlightPadding = tonumber(raidPad) or 3
        Joypad:ApplyRaidCursorHighlightStyle()
        Joypad:NotifyAceOptionsChanged()
        Print("Raid Cursor highlight padding: " .. tostring(JoypadDB.raidCursorHighlightPadding))
        return
    end

    local raidBorder = string.match(msg or "", "^raidcursor border%s+(%d+)$")
    if raidBorder then
        EnsureDB()
        JoypadDB.raidCursorHighlightBorderSize = tonumber(raidBorder) or 2
        Joypad:ApplyRaidCursorHighlightStyle()
        Joypad:NotifyAceOptionsChanged()
        Print("Raid Cursor highlight border size: " .. tostring(JoypadDB.raidCursorHighlightBorderSize))
        return
    end

    local raidFill = string.match(msg or "", "^raidcursor fill%s+([%d%.]+)$")
    if raidFill then
        EnsureDB()
        JoypadDB.raidCursorHighlightFillAlpha = tonumber(raidFill) or 0.08
        Joypad:ApplyRaidCursorHighlightStyle()
        Joypad:NotifyAceOptionsChanged()
        Print("Raid Cursor highlight fill opacity: " .. tostring(JoypadDB.raidCursorHighlightFillAlpha))
        return
    end

    if msg == "raidsteer on" or msg == "raid steering on" then
        EnsureDB()
        JoypadDB.raidTargetSteeringEnabled = true
        Joypad:NotifyAceOptionsChanged()
        Print("Shifty raid target steering enabled.")
        return
    end

    if msg == "raidsteer off" or msg == "raid steering off" then
        EnsureDB()
        JoypadDB.raidTargetSteeringEnabled = false
        Joypad._raidSteeringActiveCue = nil
        Joypad:NotifyAceOptionsChanged()
        Print("Shifty raid target steering disabled.")
        return
    end

    if msg == "raidsteer every on" then
        EnsureDB()
        JoypadDB.raidTargetSteeringEveryHeal = true
        Joypad:NotifyAceOptionsChanged()
        Print("Raid target steering will steer every raid heal.")
        return
    end

    if msg == "raidsteer every off" then
        EnsureDB()
        JoypadDB.raidTargetSteeringEveryHeal = false
        Joypad:NotifyAceOptionsChanged()
        Print("Raid target steering limited to urgent/emergency cues.")
        return
    end

    if msg == "raidsteer status" or msg == "raidsteer" then
        EnsureDB()
        local cue = Joypad._raidSteeringActiveCue
        Print("Raid Steering: enabled=" .. tostring(JoypadDB.raidTargetSteeringEnabled)
            .. " everyHeal=" .. tostring(JoypadDB.raidTargetSteeringEveryHeal)
            .. " activeCue=" .. tostring(cue and cue.nextDirection or "-")
            .. " target=" .. tostring(cue and (cue.targetName or cue.targetUnit) or "-")
            .. " spell=" .. tostring(cue and cue.spell or "-"))
        return
    end

    if msg == "raidcursor status" or msg == "raidcursor" or msg == "raid cursor" then
        Joypad:PrintRaidCursorStatus()
        return
    end

    if msg == "smarttooltip on" or msg == "mouselook tooltip on" or msg == "tooltippeek on" then
        Joypad:SetSmartMouselookForceTooltip(true, false)
        return
    end

    if msg == "awesometarget on" or msg == "awesomeaim on" then
        EnsureDB()
        JoypadDB.smartMouselookPreferAwesomeTarget = true
        Joypad:UpdateSmartMouselookMouseoverHint(0, true)
        Joypad:UpdateSmartMouselookTestTooltip(0, true)
        Joypad:NotifyAceOptionsChanged()
        Print("Smart mouselook now prefers the AwesomeWotLK aim-nameplate hint.")
        return
    end

    if msg == "awesometarget off" or msg == "awesomeaim off" then
        EnsureDB()
        JoypadDB.smartMouselookPreferAwesomeTarget = false
        Joypad:UpdateSmartMouselookMouseoverHint(0, true)
        Joypad:UpdateSmartMouselookTestTooltip(0, true)
        Joypad:NotifyAceOptionsChanged()
        Print("Smart mouselook AwesomeWotLK aim-nameplate hint disabled.")
        return
    end

    if msg == "targettooltip on" or msg == "selectedtarget on" then
        EnsureDB()
        JoypadDB.smartMouselookUseSelectedTarget = true
        Joypad:UpdateSmartMouselookMouseoverHint(0, true)
        Joypad:UpdateSmartMouselookTestTooltip(0, true)
        Joypad:NotifyAceOptionsChanged()
        Print("Smart mouselook selected-target fallback enabled. Use /joypad smarttooltip on to show the normal Blizzard tooltip for your selected target.")
        return
    end

    if msg == "targettooltip off" or msg == "selectedtarget off" then
        EnsureDB()
        JoypadDB.smartMouselookUseSelectedTarget = false
        Joypad:UpdateSmartMouselookMouseoverHint(0, true)
        Joypad:UpdateSmartMouselookTestTooltip(0, true)
        Joypad:NotifyAceOptionsChanged()
        Print("Smart mouselook selected-target fallback disabled.")
        return
    end

    if msg == "dummytooltip on" or msg == "testtooltip on" then
        Joypad:SetSmartMouselookTestTooltip(true, false)
        return
    end

    if msg == "dummytooltip off" or msg == "testtooltip off" then
        Joypad:SetSmartMouselookTestTooltip(false, false)
        return
    end

    if msg == "dummytooltip" or msg == "testtooltip" then
        EnsureDB()
        Joypad:SetSmartMouselookTestTooltip(JoypadDB.smartMouselookTestTooltip ~= true, false)
        return
    end

    if msg == "tooltipanchor cursor" or msg == "tooltippos cursor" then
        Joypad:SetSmartMouselookTooltipAnchor("cursor", false)
        return
    end

    if msg == "tooltipanchor elvui" or msg == "tooltippos elvui" or msg == "tooltipanchor minimap" or msg == "tooltippos minimap" then
        Joypad:SetSmartMouselookTooltipAnchor("elvui", false)
        return
    end

    if msg == "tooltipanchor topright" or msg == "tooltippos topright" then
        Joypad:SetSmartMouselookTooltipAnchor("topright", false)
        return
    end

    local tooltipX, tooltipY = string.match(msg or "", "^tooltippos%s+(-?%d+)%s+(-?%d+)$")
    if tooltipX and tooltipY then
        Joypad:SetSmartMouselookTooltipOffset(tooltipX, tooltipY, false)
        return
    end

    if msg == "blizzardtooltip on" or msg == "targetblizztooltip on" then
        Joypad:SetSmartMouselookForceTooltip(true, false)
        return
    end

    if msg == "smarttooltip off" or msg == "mouselook tooltip off" or msg == "tooltippeek off" then
        Joypad:SetSmartMouselookForceTooltip(false, false)
        return
    end

    if msg == "blizzardtooltip off" or msg == "targetblizztooltip off" then
        Joypad:SetSmartMouselookForceTooltip(false, false)
        return
    end

    if msg == "smarttooltip" or msg == "mouselook tooltip" or msg == "tooltippeek" then
        EnsureDB()
        Joypad:SetSmartMouselookForceTooltip(JoypadDB.smartMouselookForceTooltip ~= true, false)
        return
    end

    if msg == "mouseoverhint on" or msg == "mousehint on" or msg == "mouselook hint on" then
        Joypad:SetSmartMouselookMouseoverHint(true, false)
        return
    end

    if msg == "mouseoverhint off" or msg == "mousehint off" or msg == "mouselook hint off" then
        Joypad:SetSmartMouselookMouseoverHint(false, false)
        return
    end

    if msg == "mouseoverhint" or msg == "mousehint" or msg == "mouselook hint" then
        EnsureDB()
        Joypad:SetSmartMouselookMouseoverHint(JoypadDB.smartMouselookMouseoverHint ~= true, false)
        return
    end

    if msg == "modifierpeek on" or msg == "mouselook modifier on" or msg == "shiftctrlpeek on" or msg == "ctrlpeek on" or msg == "mouselook ctrl on" then
        Joypad:SetSmartMouselookPauseOnModifier(true, false)
        return
    end

    if msg == "modifierpeek off" or msg == "mouselook modifier off" or msg == "shiftctrlpeek off" or msg == "ctrlpeek off" or msg == "mouselook ctrl off" then
        Joypad:SetSmartMouselookPauseOnModifier(false, false)
        return
    end

    if msg == "modifierpeek" or msg == "mouselook modifier" or msg == "shiftctrlpeek" or msg == "ctrlpeek" or msg == "mouselook ctrl" then
        EnsureDB()
        Joypad:SetSmartMouselookPauseOnModifier(JoypadDB.smartMouselookPauseOnModifier ~= true, false)
        return
    end

    if msg == "settings" or msg == "options" then
        Joypad:ToggleSettingsPanel()
        return
    end

    if msg == "bindings" then
        Joypad:CreateSettingsPanel()
        Joypad:CreateBindingsPanel()
        if Joypad.bindingsPanel and InterfaceOptionsFrame_OpenToCategory then
            InterfaceOptionsFrame_OpenToCategory(Joypad.bindingsPanel)
            InterfaceOptionsFrame_OpenToCategory(Joypad.bindingsPanel)
        end
        return
    end

    if msg == "unlock" then
        Joypad:SetUnlocked(true, false)
        return
    end

    if msg == "lock" then
        Joypad:SetUnlocked(false, false)
        return
    end

    if msg == "gamepad" then
        Joypad:SetLayoutMode("gamepad", false)
        return
    end

    if msg == "desktop" then
        Joypad:SetLayoutMode("desktop", false)
        return
    end

    if msg == "uidebug" or msg == "cursordebug" then
        Joypad:ToggleUICursorDebug()
        return
    end

    if msg == "adibags" or msg == "adibags refresh" then
        Joypad:RefreshAdiBagsCompatibility()
        Print("AdiBags compatibility refreshed.")
        return
    end

    if msg == "inputdebug" or msg == "keysdebug" or msg == "binddebug" then
        Joypad:DebugInputBindings()
        return
    end

    if msg == "checkkeys" or msg == "checkbinds" or msg == "missingkeys" then
        Joypad:CheckMissingPhysicalKeybinds(false)
        return
    end

    if msg == "inputlog" or msg == "recentinputs" then
        Joypad:PrintRecentInputLog(12)
        return
    end

    if msg == "clearinputlog" or msg == "inputlog clear" then
        Joypad:ClearInputLog(false)
        return
    end

    if msg == "repairkeys" or msg == "fixkeys" or msg == "physicalkeys" then
        Joypad:RepairPhysicalKeybinds(false)
        return
    end

    if msg == "debug" or msg == "dump" or msg == "layout" then
        Joypad:DebugDumpSlotLayout()
        return
    end

    if msg == "scuz" or msg == "profile scuz" then
        Joypad:ApplyLayoutProfile("Scuz", false)
        return
    end

    if msg == "shifty" or msg == "shiftyhighlight" or msg == "shiftyhighlights" then
        Joypad:SetShiftySuggestionHighlightsEnabled(not (JoypadDB and JoypadDB.shiftySuggestionHighlights ~= false), false)
        return
    end

    if msg == "shifty on" or msg == "shiftyhighlight on" or msg == "shiftyhighlights on" then
        Joypad:SetShiftySuggestionHighlightsEnabled(true, false)
        return
    end

    if msg == "shifty off" or msg == "shiftyhighlight off" or msg == "shiftyhighlights off" then
        Joypad:SetShiftySuggestionHighlightsEnabled(false, false)
        return
    end

    if msg == "vehicle" or msg == "possess" or msg == "takeover" or msg == "page11" then
        Print(JoypadGetVehicleStatusText and JoypadGetVehicleStatusText() or "vehicle diagnostics unavailable")
        return
    end

    if msg == "version" then
        Print("v" .. VERSION)
        return
    end

    Print("commands: /joypad, /joypad show, /joypad hide, /joypad toggle, /joypad blizzard, /joypad keybinds, /joypad cooldowns, /joypad settings, /joypad fixinput, /joypad checkkeys, /joypad inputdebug, /joypad repairkeys, /joypad uicursor off, /joypad mousemove off, /joypad smartcenter, /joypad centerzone, /joypad unlock, /joypad lock, /joypad bindings, /joypad scuz, /joypad shifty, /joypad vehicle, /joypad version")
end


-- ---------------------------------------------------------------------------
-- Public read-only API for external addons such as ShiftyTriumvirate.
-- This API intentionally does not alter secure attributes, bindings, saved
-- variables, action slots, or protected state.  It only reads Joypad's current
-- mapping/style state and returns plain Lua tables/strings.
-- ---------------------------------------------------------------------------
JoypadAPI = JoypadAPI or {}

function JoypadAPI.IsVehicleOrEncounterActionBarActive()
    return JoypadIsVehicleOrEncounterActionBarActive and JoypadIsVehicleOrEncounterActionBarActive() or false
end

function JoypadAPI.GetVehicleActionSlotForJoypadSlot(joypadSlot)
    return JoypadGetVehicleActionSlotForJoypadSlot and JoypadGetVehicleActionSlotForJoypadSlot(joypadSlot) or nil
end

function JoypadAPI.GetVehicleStatusText()
    return JoypadGetVehicleStatusText and JoypadGetVehicleStatusText() or "vehicle diagnostics unavailable"
end

function JoypadAPI.GetVersion()
    return tostring(VERSION or "0.0.0")
end

function JoypadAPI.IsReady()
    return type(JoypadDB) == "table"
        and Joypad
        and Joypad.created == true
        and type(Joypad.buttons) == "table"
end

function JoypadAPI._NormalizeLayerKey(layerKey)
    return NormalizeJoypadLayerKey(layerKey)
end

function JoypadAPI._GetButtonName(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    if Joypad and type(Joypad.buttons) == "table" then
        local button = Joypad.buttons[joypadSlot]
        if button and button.GetName then
            local name = button:GetName()
            if name and name ~= "" then
                return name
            end
        end
    end
    return "JoypadButton" .. tostring(joypadSlot)
end

function JoypadAPI._GetLayerPrefix(layerKey)
    layerKey = NormalizeJoypadLayerKey(layerKey)
    -- Public display names use the physical Joypad controls, not the keyboard
    -- modifiers that implement them under the hood.  This keeps external
    -- addons such as Shifty showing controller-native labels.
    if layerKey == "shift" then
        return "L2+"
    elseif layerKey == "ctrl" then
        return "R2+"
    elseif layerKey == "shiftctrl" then
        return "L2+R2+"
    end
    return ""
end

function JoypadAPI._GetSlotGroup(joypadSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    if joypadSlot >= 1 and joypadSlot <= 4 then
        return "face"
    elseif joypadSlot >= 5 and joypadSlot <= 8 then
        return "dpad"
    elseif joypadSlot == 9 or joypadSlot == 10 then
        return "shoulder"
    elseif joypadSlot == 11 or joypadSlot == 12 then
        return "centre"
    elseif joypadSlot >= 13 and joypadSlot <= 20 then
        return "trackpad"
    elseif joypadSlot >= 21 and joypadSlot <= 24 then
        return "rear"
    end

    local def = GetAltLabelDef(joypadSlot)
    if type(def) == "table" and def.group then
        return tostring(def.group)
    end
    return "unknown"
end

function JoypadAPI._BuildButtonInfo(joypadSlot, layerKey, actionSlot, effectiveActionSlot)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    layerKey = NormalizeJoypadLayerKey(layerKey)

    local label = GetAltLabel(joypadSlot)
    local displayText = JoypadAPI._GetLayerPrefix(layerKey) .. tostring(label or "")

    return {
        found = true,
        joypadSlot = joypadSlot,
        buttonName = JoypadAPI._GetButtonName(joypadSlot),
        layerKey = layerKey,
        actionSlot = actionSlot,
        effectiveActionSlot = effectiveActionSlot or actionSlot,
        label = label,
        displayText = displayText,
    }
end

function JoypadAPI._ValidPositiveId(value)
    local id = tonumber(value)
    if id and id > 0 then
        return id
    end
    return nil
end

function JoypadAPI._SameText(a, b)
    if not a or not b then
        return false
    end
    return string.lower(tostring(a)) == string.lower(tostring(b))
end

function JoypadAPI._NormalizeTexturePath(path)
    if not path then
        return nil
    end
    local text = string.lower(tostring(path))
    text = string.gsub(text, "\\", "/")
    text = string.gsub(text, "%.blp$", "")
    text = string.gsub(text, "%.tga$", "")
    return text
end

function JoypadAPI._SameTexture(a, b)
    local left = JoypadAPI._NormalizeTexturePath(a)
    local right = JoypadAPI._NormalizeTexturePath(b)
    if not left or not right then
        return false
    end
    return left == right
end

local JOYPAD_API_KNOWN_SPELL_TEXTURES = {
    ["thorns"] = "Interface\\Icons\\Spell_Nature_Thorns",
    ["mark of the wild"] = "Interface\\Icons\\Spell_Nature_Regeneration",
    ["gift of the wild"] = "Interface\\Icons\\Spell_Nature_GiftoftheWild",
    ["rejuvenation"] = "Interface\\Icons\\Spell_Nature_Rejuvenation",
    ["regrowth"] = "Interface\\Icons\\Spell_Nature_ResistNature",
    ["swiftmend"] = "Interface\\Icons\\INV_Relics_IdolofRejuvenation",
    ["healing touch"] = "Interface\\Icons\\Spell_Nature_HealingTouch",
    ["lifebloom"] = "Interface\\Icons\\INV_Misc_Herb_Felblossom",
    ["nourish"] = "Interface\\Icons\\Ability_Druid_Nourish",
    ["abolish poison"] = "Interface\\Icons\\Spell_Nature_NullifyPoison_02",
    ["remove curse"] = "Interface\\Icons\\Spell_Holy_RemoveCurse",
    ["wrath"] = "Interface\\Icons\\Spell_Nature_AbolishMagic",
    ["starfire"] = "Interface\\Icons\\Spell_Arcane_StarFire",
    ["moonfire"] = "Interface\\Icons\\Spell_Nature_StarFall",
    ["insect swarm"] = "Interface\\Icons\\Spell_Nature_InsectSwarm",
    ["mangle (bear)"] = "Interface\\Icons\\Ability_Druid_Mangle2",
    ["mangle (cat)"] = "Interface\\Icons\\Ability_Druid_Mangle2",
    ["mangle"] = "Interface\\Icons\\Ability_Druid_Mangle2",
    ["rake"] = "Interface\\Icons\\Ability_Druid_Disembowel",
    ["rip"] = "Interface\\Icons\\Ability_GhoulFrenzy",
    ["swipe (bear)"] = "Interface\\Icons\\INV_Misc_MonsterClaw_03",
    ["swipe"] = "Interface\\Icons\\INV_Misc_MonsterClaw_03",
}

function JoypadAPI._KnownSpellTextureByName(name)
    if not name then
        return nil
    end
    return JOYPAD_API_KNOWN_SPELL_TEXTURES[string.lower(tostring(name))]
end

function JoypadAPI._FindSpellbookTextureByName(name)
    if not name or not GetNumSpellTabs or not GetSpellTabInfo or not GetSpellName then
        return nil
    end
    local wanted = string.lower(tostring(name))
    local bookType = BOOKTYPE_SPELL or "spell"
    local numTabs = GetNumSpellTabs() or 0
    for tab = 1, numTabs do
        local tabName, tabTexture, offset, numSpells = GetSpellTabInfo(tab)
        offset = tonumber(offset or 0) or 0
        numSpells = tonumber(numSpells or 0) or 0
        for i = offset + 1, offset + numSpells do
            local spellName = GetSpellName(i, bookType)
            if spellName and string.lower(tostring(spellName)) == wanted then
                if GetSpellTexture then
                    local texture = GetSpellTexture(i, bookType)
                    if texture then
                        return texture
                    end
                end
                if GetSpellInfo then
                    local _, _, icon = GetSpellInfo(spellName)
                    if icon then
                        return icon
                    end
                end
            end
        end
    end
    return nil
end

function JoypadAPI._GetActionTooltipName(actionSlot)
    actionSlot = tonumber(actionSlot or 0) or 0
    if actionSlot < 1 or actionSlot > 120 then
        return nil
    end
    if not CreateFrame or not UIParent then
        return nil
    end

    if not JoypadAPI._scanTooltip then
        local tooltip = CreateFrame("GameTooltip", "JoypadAPIScanTooltip", UIParent, "GameTooltipTemplate")
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        JoypadAPI._scanTooltip = tooltip
    end

    local tooltip = JoypadAPI._scanTooltip
    if not tooltip or not tooltip.SetAction then
        return nil
    end

    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:ClearLines()
    tooltip:SetAction(actionSlot)

    local line = _G and _G["JoypadAPIScanTooltipTextLeft1"] or nil
    local text = line and line.GetText and line:GetText() or nil

    tooltip:Hide()
    if text and text ~= "" then
        return text
    end
    return nil
end

function JoypadAPI.GetButtonDisplay(buttonInfo)
    if type(buttonInfo) ~= "table" or buttonInfo.found == false then
        return nil
    end

    if buttonInfo.displayText and buttonInfo.displayText ~= "" then
        return tostring(buttonInfo.displayText)
    end

    local joypadSlot = tonumber(buttonInfo.joypadSlot or 0) or 0
    if joypadSlot <= 0 then
        return nil
    end

    return JoypadAPI._GetLayerPrefix(buttonInfo.layerKey) .. tostring(GetAltLabel(joypadSlot) or "")
end

function JoypadAPI.GetCurrentClassPageState()
    local pageState, form, classFile = JoypadGetClassPagingState()
    local pageOffset = 0

    local pageStart = JOYPAD_CLASS_PAGE_ACTION_STARTS and JOYPAD_CLASS_PAGE_ACTION_STARTS[pageState]
    if pageStart then
        pageOffset = pageStart - 1
    end

    return {
        class = classFile,
        form = form or "base",
        page = pageState or "base",
        pageOffset = pageOffset,
    }
end

function JoypadAPI.GetCurrentDruidPageState()
    return JoypadAPI.GetCurrentClassPageState()
end

function JoypadAPI.GetActionSlotForButton(joypadSlot, layerKey)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    if joypadSlot < 1 or joypadSlot > 24 then
        return nil
    end

    layerKey = NormalizeJoypadLayerKey(layerKey)

    if GetJoypadBindingMode(joypadSlot, layerKey) ~= "action" then
        return nil
    end

    local actionSlot = GetJoypadSlotInfo(joypadSlot, layerKey)
    if not actionSlot then
        return nil
    end

    return JoypadGetClassPagedActionSlot(joypadSlot, layerKey, actionSlot)
end

function JoypadAPI.GetButtonForActionSlot(actionSlot)
    actionSlot = tonumber(actionSlot or 0) or 0
    if actionSlot < 1 or actionSlot > 120 then
        return { found = false, reason = "invalid_action_slot" }
    end

    for _, layer in ipairs(JOYPAD_LAYERS) do
        for joypadSlot = 1, 24 do
            if GetJoypadBindingMode(joypadSlot, layer.key) == "action" then
                local rawActionSlot = GetJoypadSlotInfo(joypadSlot, layer.key)
                local effectiveActionSlot = JoypadGetClassPagedActionSlot(joypadSlot, layer.key, rawActionSlot)

                if effectiveActionSlot == actionSlot then
                    return JoypadAPI._BuildButtonInfo(joypadSlot, layer.key, rawActionSlot, effectiveActionSlot)
                end
            end
        end
    end

    return { found = false, reason = "not_found" }
end

function JoypadAPI._NormalizeBindingCommand(command)
    if not command then
        return nil
    end
    local c = string.upper(tostring(command))
    c = string.gsub(c, "^%s+", "")
    c = string.gsub(c, "%s+$", "")
    -- Friendly aliases for common party-target commands.
    if c == "SELF" or c == "TARGETSELF" or c == "TARGET_PLAYER" then
        return "TARGETSELF"
    end
    local n = string.match(c, "^PARTY([1-4])$") or string.match(c, "^TARGETPARTY([1-4])$") or string.match(c, "^TARGETPARTYMEMBER([1-4])$")
    if n then
        return "TARGETPARTYMEMBER" .. tostring(n)
    end
    return c
end

function JoypadAPI._BuildBindingInfo(joypadSlot, layerKey, bindingCommand)
    joypadSlot = tonumber(joypadSlot or 0) or 0
    layerKey = NormalizeJoypadLayerKey(layerKey)
    local label = GetAltLabel(joypadSlot)
    local displayText = JoypadAPI._GetLayerPrefix(layerKey) .. tostring(label or "")
    return {
        found = true,
        joypadSlot = joypadSlot,
        buttonName = JoypadAPI._GetButtonName(joypadSlot),
        layerKey = layerKey,
        bindingCommand = bindingCommand,
        command = bindingCommand,
        label = label,
        displayText = displayText,
    }
end

function JoypadAPI.GetButtonForBindingCommand(command)
    local wanted = JoypadAPI._NormalizeBindingCommand(command)
    if not wanted or wanted == "" then
        return { found = false, reason = "invalid_binding_command" }
    end

    for _, layer in ipairs(JOYPAD_LAYERS) do
        for joypadSlot = 1, 24 do
            local mode = GetJoypadBindingMode(joypadSlot, layer.key)
            if mode == "keybind" then
                -- Use the Joypad action/keybind assignment command, not the
                -- physical listening binding (CLICK JoypadButtonXX).  External
                -- addons such as Shifty ask for real Blizzard commands like
                -- TARGETSELF/TARGETPARTYMEMBER1 and expect the Joypad control
                -- that represents that command.
                local bindingCommand = nil
                if GetJoypadKeybindCommand then
                    bindingCommand = GetJoypadKeybindCommand(joypadSlot, layer.key)
                end
                if not bindingCommand or bindingCommand == "" then
                    local assignment = GetDefaultJoypadAssignment(joypadSlot, layer.key)
                    if assignment and assignment.type == "keybind" then
                        bindingCommand = assignment.command
                    end
                end
                local normalized = JoypadAPI._NormalizeBindingCommand(bindingCommand)
                if normalized == wanted then
                    return JoypadAPI._BuildBindingInfo(joypadSlot, layer.key, normalized)
                end
            end
        end
    end

    return { found = false, reason = "not_found", command = wanted }
end

function JoypadAPI._ActionSlotMatchesSpell(actionSlot, spellName, spellId, spellIcon)
    actionSlot = tonumber(actionSlot or 0) or 0
    if actionSlot < 1 or actionSlot > 120 then
        return false, nil, nil, nil
    end
    if not GetActionInfo then
        return false, nil, nil, nil
    end

    local actionType, id, subType = GetActionInfo(actionSlot)
    if actionType ~= "spell" then
        return false, nil, nil, nil
    end

    local wantedId = JoypadAPI._ValidPositiveId(spellId)
    local rawActionId = JoypadAPI._ValidPositiveId(id)
    local actionSpellName, actionRank, actionIcon, actionCastTime, actionMinRange, actionMaxRange, actionSpellId = nil, nil, nil, nil, nil, nil, nil
    if GetSpellInfo then
        actionSpellName, actionRank, actionIcon, actionCastTime, actionMinRange, actionMaxRange, actionSpellId = GetSpellInfo(id)
    end
    actionSpellId = JoypadAPI._ValidPositiveId(actionSpellId)

    -- Important for 3.3.5/private-server spellbook edge cases:
    -- spellId/actionSpellId can be 0.  Lua treats 0 as truthy, so accepting it
    -- as a real ID makes every unknown spell match every other unknown spell.
    if wantedId and actionSpellId and actionSpellId == wantedId then
        return true, actionSpellName, actionSpellId, "spellId"
    end

    -- Some clients expose the raw action id as the real spell id.  Only trust it
    -- when it is positive and it does not contradict a resolved requested name.
    if wantedId and rawActionId and rawActionId == wantedId then
        if not spellName or not actionSpellName or JoypadAPI._SameText(actionSpellName, spellName) then
            return true, actionSpellName, rawActionId, "actionId"
        end
    end

    if spellName and actionSpellName and JoypadAPI._SameText(actionSpellName, spellName) then
        return true, actionSpellName, actionSpellId or rawActionId, "spellName"
    end

    local tooltipName = JoypadAPI._GetActionTooltipName(actionSlot)
    if spellName and tooltipName and JoypadAPI._SameText(tooltipName, spellName) then
        return true, tooltipName, actionSpellId or rawActionId, "tooltipName"
    end

    local actionText = nil
    if GetActionText then
        actionText = GetActionText(actionSlot)
    end
    if spellName and actionText and JoypadAPI._SameText(actionText, spellName) then
        return true, actionText, actionSpellId or rawActionId, "actionText"
    end

    -- Last-resort compatibility fallback for older clients/private servers where
    -- action spell names/IDs can resolve to hidden DND spellbook entries, while
    -- the action texture is still the player's real spell icon.  This is common
    -- on 3.3.5a custom servers where GetActionInfo returns hidden spell ids such
    -- as "Show Dot Variable" with spellId=0, but GetActionTexture is correct.
    local actionTexture = nil
    if GetActionTexture then
        actionTexture = GetActionTexture(actionSlot)
    end
    if spellName and spellIcon then
        if actionTexture and JoypadAPI._SameTexture(actionTexture, spellIcon) then
            return true, tooltipName or actionText or spellName, actionSpellId or rawActionId, "actionTexture"
        end
        if actionIcon and JoypadAPI._SameTexture(actionIcon, spellIcon) then
            return true, tooltipName or actionText or spellName, actionSpellId or rawActionId, "spellTexture"
        end
    end

    return false, tooltipName or actionText or actionSpellName, actionSpellId or rawActionId, nil
end

function JoypadAPI.GetButtonForSpell(spellNameOrId)
    if not spellNameOrId then
        return { found = false, reason = "invalid_spell" }
    end

    local wantedName, wantedId, wantedIcon = nil, nil, nil
    if type(spellNameOrId) == "number" or tonumber(spellNameOrId) then
        wantedId = JoypadAPI._ValidPositiveId(spellNameOrId)
    else
        wantedName = tostring(spellNameOrId)
    end

    if GetSpellInfo then
        local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spellNameOrId)
        if name then
            wantedName = name
        end
        if icon then
            wantedIcon = icon
        end
        wantedId = JoypadAPI._ValidPositiveId(spellId) or wantedId
    end

    -- Extra 3.3.5a/private-server compatibility: name lookups can succeed while
    -- spell id/icon lookup does not, or action slots can point at hidden DND
    -- spells with the correct visible texture.  Recover the requested icon from
    -- the player's spellbook or a small Druid icon table before scanning actions.
    if not wantedIcon and wantedName then
        wantedIcon = JoypadAPI._FindSpellbookTextureByName(wantedName) or JoypadAPI._KnownSpellTextureByName(wantedName)
    end
    if not wantedIcon and type(spellNameOrId) == "string" then
        wantedIcon = JoypadAPI._FindSpellbookTextureByName(spellNameOrId) or JoypadAPI._KnownSpellTextureByName(spellNameOrId)
    end

    for _, layer in ipairs(JOYPAD_LAYERS) do
        for joypadSlot = 1, 24 do
            if GetJoypadBindingMode(joypadSlot, layer.key) == "action" then
                local rawActionSlot = GetJoypadSlotInfo(joypadSlot, layer.key)
                local effectiveActionSlot = JoypadGetClassPagedActionSlot(joypadSlot, layer.key, rawActionSlot)
                local matches, actionSpellName, actionSpellId, matchReason = JoypadAPI._ActionSlotMatchesSpell(effectiveActionSlot, wantedName, wantedId, wantedIcon)

                if matches then
                    local info = JoypadAPI._BuildButtonInfo(joypadSlot, layer.key, rawActionSlot, effectiveActionSlot)
                    info.spellName = actionSpellName or wantedName
                    info.spellId = JoypadAPI._ValidPositiveId(actionSpellId) or wantedId
                    info.matchReason = matchReason
                    return info
                end
            end
        end
    end

    return { found = false, reason = "not_found" }
end

function JoypadAPI._ActionSlotMatchesMacro(actionSlot, macroName, macroIndex)
    actionSlot = tonumber(actionSlot or 0) or 0
    if actionSlot < 1 or actionSlot > 120 then
        return false, nil, nil
    end
    if not GetActionInfo then
        return false, nil, nil
    end

    local actionType, id, subType = GetActionInfo(actionSlot)
    if actionType ~= "macro" then
        return false, nil, nil
    end

    local actionMacroName = nil
    if GetMacroInfo and id then
        actionMacroName = GetMacroInfo(id)
    end
    if not actionMacroName and GetActionText then
        actionMacroName = GetActionText(actionSlot)
    end

    if macroIndex and tonumber(id) == tonumber(macroIndex) then
        return true, actionMacroName, id
    end

    if macroName and actionMacroName and string.lower(tostring(actionMacroName)) == string.lower(tostring(macroName)) then
        return true, actionMacroName, id
    end

    return false, actionMacroName, id
end

function JoypadAPI.GetButtonForMacro(macroNameOrIndex)
    if not macroNameOrIndex then
        return { found = false, reason = "invalid_macro" }
    end

    local macroName, macroIndex = nil, nil
    if type(macroNameOrIndex) == "number" or tonumber(macroNameOrIndex) then
        macroIndex = tonumber(macroNameOrIndex)
    else
        macroName = tostring(macroNameOrIndex)
    end

    if macroIndex and GetMacroInfo then
        local name = GetMacroInfo(macroIndex)
        if name then
            macroName = name
        end
    end

    for _, layer in ipairs(JOYPAD_LAYERS) do
        for joypadSlot = 1, 24 do
            if GetJoypadBindingMode(joypadSlot, layer.key) == "action" then
                local rawActionSlot = GetJoypadSlotInfo(joypadSlot, layer.key)
                local effectiveActionSlot = JoypadGetClassPagedActionSlot(joypadSlot, layer.key, rawActionSlot)
                local matches, actionMacroName, actionMacroId = JoypadAPI._ActionSlotMatchesMacro(effectiveActionSlot, macroName, macroIndex)

                if matches then
                    local info = JoypadAPI._BuildButtonInfo(joypadSlot, layer.key, rawActionSlot, effectiveActionSlot)
                    info.macroName = actionMacroName or macroName
                    info.macroIndex = actionMacroId or macroIndex
                    return info
                end
            end
        end
    end

    return { found = false, reason = "not_found" }
end

function JoypadAPI.GetButtonStyle(buttonInfo)
    if type(buttonInfo) ~= "table" or buttonInfo.found == false then
        return nil
    end

    local joypadSlot = tonumber(buttonInfo.joypadSlot or 0) or 0
    if joypadSlot < 1 or joypadSlot > 24 then
        return nil
    end

    local label = GetAltLabel(joypadSlot)
    local displayText = JoypadAPI.GetButtonDisplay(buttonInfo) or label
    local r, g, b, a = GetAltTextColor(joypadSlot)
    local layout = GetAltAutoLayout(joypadSlot)
    local def = GetAltLabelDef(joypadSlot)
    local parts = GetAltRenderParts(joypadSlot)
    local styleParts = {}

    for index, part in ipairs(parts) do
        if type(part) == "table" then
            local pr, pg, pb, pa = JoypadGetAltTextPartColor(joypadSlot, part)
            table.insert(styleParts, {
                text = tostring(part.text or ""),
                r = pr,
                g = pg,
                b = pb,
                a = pa,
                scale = tonumber(part.scale or 1) or 1,
                x = tonumber(part.x or 0) or 0,
                y = tonumber(part.y or 0) or 0,
                colorRole = part.colorRole,
            })
        end
    end

    return {
        text = displayText,
        altText = label,
        displayText = displayText,
        label = label,

        r = r,
        g = g,
        b = b,
        a = a,
        scale = GetSlotScale(joypadSlot) / 100,
        font = ALT_TEXT_BASE_FONT,
        fontSize = GetAltTextFontSize(joypadSlot),
        outline = ALT_TEXT_FONT_FLAGS,
        shadow = true,

        altR = r,
        altG = g,
        altB = b,
        altA = a,
        altScale = GetAltTextScale(joypadSlot) / 100,
        altLayoutScale = tonumber(layout.multiplier) or 1,
        altFontSize = GetAltTextFontSize(joypadSlot),
        altOutline = ALT_TEXT_FONT_FLAGS,
        altParts = styleParts,

        group = JoypadAPI._GetSlotGroup(joypadSlot),
        rawGroup = type(def) == "table" and def.group or nil,
        theme = JoypadGetThemeLabel and JoypadGetThemeLabel(JoypadDB and JoypadDB.theme) or "Classic",
        themeKey = JoypadNormalizeTheme and JoypadNormalizeTheme(JoypadDB and JoypadDB.theme) or "none",
        displayMode = JoypadGetDisplayMode and JoypadGetDisplayMode() or "steam",
        layerKey = NormalizeJoypadLayerKey(buttonInfo.layerKey),
        modifierPrefix = JoypadAPI._GetLayerPrefix(buttonInfo.layerKey),
        modifierPhysicalPrefix = JoypadAPI._GetLayerPrefix(buttonInfo.layerKey),
        actionStateColors = Joypad.actionStateColors,
        cooldownTextColors = Joypad.cooldownTextColors,
        cooldownTextLayer = 6,
        keybindTextLayer = 8,
    }
end

-- Optional render helpers for external addons.  These expose the same texture
-- choices Joypad uses for action and keybind buttons without requiring the
-- external addon to duplicate Joypad's private lookup tables.
function JoypadAPI.GetButtonIcon(buttonInfo)
    if type(buttonInfo) ~= "table" or buttonInfo.found == false then
        return nil
    end

    local command = buttonInfo.bindingCommand or buttonInfo.command
    if command then
        local normalized = JoypadAPI._NormalizeBindingCommand(command)
        if normalized and KEYBIND_COMMAND_ICONS and KEYBIND_COMMAND_ICONS[normalized] then
            return KEYBIND_COMMAND_ICONS[normalized]
        end
    end

    local actionSlot = JoypadAPI._ValidPositiveId(buttonInfo.effectiveActionSlot) or JoypadAPI._ValidPositiveId(buttonInfo.actionSlot)
    if actionSlot and GetActionTexture then
        local texture = GetActionTexture(actionSlot)
        if texture then return texture end
    end

    return nil
end

function JoypadAPI.GetButtonRenderInfo(buttonInfo)
    if type(buttonInfo) ~= "table" or buttonInfo.found == false then
        return { found = false, reason = buttonInfo and buttonInfo.reason or "invalid_button" }
    end

    local display = nil
    if JoypadAPI.GetButtonDisplay then
        display = JoypadAPI.GetButtonDisplay(buttonInfo)
    end

    local style = nil
    if JoypadAPI.GetButtonStyle then
        style = JoypadAPI.GetButtonStyle(buttonInfo)
    end

    return {
        found = true,
        text = display,
        displayText = display,
        label = buttonInfo.label,
        icon = JoypadAPI.GetButtonIcon(buttonInfo),
        iconTexture = JoypadAPI.GetButtonIcon(buttonInfo),
        style = style,
        buttonInfo = buttonInfo,
        joypadSlot = buttonInfo.joypadSlot,
        layerKey = buttonInfo.layerKey,
        bindingCommand = buttonInfo.bindingCommand or buttonInfo.command,
        actionSlot = buttonInfo.actionSlot,
        effectiveActionSlot = buttonInfo.effectiveActionSlot,
    }
end

local function JoypadAPIPartyPetTargetAvailable(n)
    local petUnit = "partypet" .. tostring(n or "")
    local ownerUnit = "party" .. tostring(n or "")
    if UnitExists then
        if not UnitExists(ownerUnit) then
            return false, "owner_not_in_party", petUnit, ownerUnit
        end
        if not UnitExists(petUnit) then
            return false, "party_pet_missing", petUnit, ownerUnit
        end
    end
    if UnitIsDeadOrGhost and UnitIsDeadOrGhost(petUnit) then
        return false, "party_pet_dead", petUnit, ownerUnit
    end
    return true, nil, petUnit, ownerUnit
end

function JoypadAPI.GetButtonForTargetUnit(unit)
    unit = string.lower(tostring(unit or ""))
    if unit == "player" or unit == "self" then
        return JoypadAPI.GetButtonForBindingCommand("TARGETSELF")
    end
    if unit == "pet" or unit == "playerpet" then
        local ownPet = JoypadAPI.GetButtonForBindingCommand("TARGETPET")
        if ownPet and ownPet.found then return ownPet end
        return { found = false, reason = "unsupported_target_unit", unit = unit, bindingCommand = "TARGETPET" }
    end
    local n = string.match(unit, "^party([1-4])$")
    if n then
        return JoypadAPI.GetButtonForBindingCommand("TARGETPARTYMEMBER" .. tostring(n))
    end
    n = string.match(unit, "^partypet([1-4])$")
    if n then
        local available, reason, petUnit, ownerUnit = JoypadAPIPartyPetTargetAvailable(n)
        if not available then
            return { found = false, reason = reason or "party_pet_unavailable", unit = petUnit or unit, ownerUnit = ownerUnit, bindingCommand = "TARGETPARTYPET" .. tostring(n) }
        end
        return JoypadAPI.GetButtonForBindingCommand("TARGETPARTYPET" .. tostring(n))
    end
    return { found = false, reason = "unsupported_target_unit", unit = unit }
end


function JoypadAPI.GetRaidCursorStatus()
    if Joypad and Joypad.PrintRaidCursorStatus then
        local party, raid = JoypadRaidCursorGroupCounts()
        local unit = Joypad.raidCursor and Joypad.raidCursor.GetAttribute and Joypad.raidCursor:GetAttribute("cursorunit") or nil
        return {
            enabled = JoypadDB and JoypadDB.raidCursorEnabled and true or false,
            active = Joypad and Joypad.raidCursorBindingsActive and true or false,
            inRaid = raid > 0,
            partyCount = party,
            raidCount = raid,
            selectedUnit = unit,
            selectedName = unit and JoypadRaidCursorUnitName(unit) or nil,
            targetOnMove = JoypadDB and JoypadDB.raidCursorTargetOnMove and true or false,
            aFallback = JoypadDB and JoypadDB.raidCursorAFallback and true or false,
        }
    end
    return { enabled = false, active = false, reason = "joypad_unavailable" }
end

function JoypadAPI.GetRaidTargetSteeringCue(targetOrDecision)
    if Joypad and Joypad.GetRaidTargetSteeringCue then
        return Joypad:GetRaidTargetSteeringCue(targetOrDecision)
    end
    return { found = false, reason = "joypad_unavailable" }
end

function JoypadAPI.GetRaidTargetSteeringState()
    local cue = Joypad and Joypad._raidSteeringActiveCue or nil
    if type(cue) == "table" then
        return {
            active = true,
            targetUnit = cue.targetUnit,
            targetName = cue.targetName,
            currentUnit = cue.currentUnit,
            currentName = cue.currentName,
            nextDirection = cue.nextDirection,
            label = cue.label,
            bindingCommand = cue.bindingCommand,
            spell = cue.spell,
            reason = cue.reason,
        }
    end
    return { active = false }
end

-- Optional write-light visual API for suggestion/highlight producers. This is
-- intentionally limited to textures on Joypad-owned frames; it never touches
-- secure action attributes, bindings, or action slots.
function JoypadAPI.SetSuggestionHighlights(highlights, reason)
    if Joypad and Joypad.ApplyShiftySuggestionHighlights then
        return Joypad:ApplyShiftySuggestionHighlights(highlights, reason or "api")
    end
    return 0
end

function JoypadAPI.ClearSuggestionHighlights(reason)
    if Joypad and Joypad.ClearShiftySuggestionHighlights then
        Joypad:ClearShiftySuggestionHighlights(reason or "api")
        return true
    end
    return false
end

function JoypadAPI.SetSuggestionHighlightsEnabled(enabled)
    if Joypad and Joypad.SetShiftySuggestionHighlightsEnabled then
        Joypad:SetShiftySuggestionHighlightsEnabled(enabled and true or false, true)
        return true
    end
    return false
end

