--%%%%%%%%%%%%%%%%%%%% Slot Data

--- @class BackpackPlus_SlotData
---
--- # Slot #
---
--- @field Slot Frame
--- @field LayoutOrder number
---
--- # Item #
---
--- @field Tool Tool
--- @field Elems BackpackPlus_SlotElems
--- @field Connections { [string]: RBXScriptConnection }
---
--- # Custom Display #
---
--- @field CustomDisplayData { [any]: any }
local _backpackPlus_SlotData = {}

--- @class BackpackPlus_SlotElems
---
--- # Button #
---
--- @field SlotButton ImageButton
---
--- # Item Visuals #
---
--- @field ItemViewportFrame ViewportFrame
--- @field ItemWorldModel WorldModel
--- @field ItemIcon ImageLabel
---
--- # Labels #
---
--- @field ItemNameText TextLabel
--- @field KeyCodeText TextLabel
--- @field QuantityText TextLabel
---
--- # Background #
---
--- @field Background Frame
--- @field BackgroundGlowContainer Frame
---
--- # Favorite #
---
--- @field FavoriteIconContainer GuiObject
--- @field FavoriteIcon GuiObject
--- @field FavoriteIconDefaultSize UDim2
---
--- # Hints #
---
--- @field UnequipHint ImageLabel
local _backpackPlus_SlotElems = {}

--%%%%%%%%%%%%%%%%%%%% Client Context

--- @class BackpackPlus_CreatedSlots
--- @field BySlot { [Frame]: BackpackPlus_SlotData }
--- @field ByTool { [Tool]: BackpackPlus_SlotData }
local _backpackPlus_CreatedSlots = {}

--- @class BackpackPlus_ClientContext
---
--- # Slot #
---
--- @field CreatedSlots BackpackPlus_CreatedSlots
--- @field LastLayoutOrder number
--- @field DropSlot (slotFrame: Frame, setToolbarSlotId: number | nil) -> ()
--- @field ToggleItem (slotFrame: Frame) -> ()
--- @field CompactItemsContainerLayoutOrders () -> ()
---
--- # Toolbar #
---
--- @field ToolbarSlots { Frame }
--- @field EquippedSlots { BackpackPlus_SlotData }
--- @field ToolbarSlotCount number
--- @field ToolbarServerLoaded boolean
--- @field PendingToolbarSlots { [number]: string } @ Saved Toolbar slot ids whose Tools have not arrived yet
--- @field TakePendingToolbarSlotId (tool: Tool) -> number?
--- @field GetFreeToolbarSlotIds () -> { number }
--- @field ReservedSlots { [number]: (tool: Tool) -> boolean }
--- @field GetReservedSlotIdForTool (tool: Tool) -> number?
--- @field IsToolbarSlotReserved (slotId: number) -> boolean
--- @field IsToolReservationLocked (tool: Tool) -> boolean
--- @field DoesToolMatchReservation (slotId: number, tool: Tool) -> boolean
--- @field ApplyReservations () -> ()
--- @field SaveToolbarToServer () -> ()
--- @field UpdateToolbarSlotDefaults () -> ()
--- @field _getSlotSize () -> UDim2
--- @field _getSlotAbsoluteSize () -> Vector2
---
--- # Backpack #
---
--- @field GetState () -> boolean
--- @field ForceClose () -> ()
--- @field UpdateToolbarSlotsSize () -> ()
--- @field UpdateDisplay () -> ()
---
--- # Filter #
---
--- @field UpdateSearchBar () -> ()
---
--- # Favorite #
---
--- @field IsFavoriteMode boolean
--- @field ApplyFavoriteSlot (slotData: BackpackPlus_SlotData, animate: boolean) -> ()
---
--- # Lock #
---
--- @field IsLocked boolean
---
--- # Client #
---
--- @field CurrentlyEquipped Tool?
local _backpackPlus_ClientContext = {}

--%%%%%%%%%%%%%%%%%%%% Other

--[[
    # Tool Attributes #

    BackpackPlus_DisplayType: string
    BackpackPlus_FilterCategory: string @ Category filter value (falls back to BackpackPlus_DisplayType)
    BackpackPlus_FilterText: string
    BackpackPlus_ToolbarRetrieve: string
        - nil       @ Default retrieve by checking if UUID or Name are matching
        - rbUUID    @ Retrieve only if the UUID is matching
        - rbName    @ Retrieve only if the Name is matching
]]
