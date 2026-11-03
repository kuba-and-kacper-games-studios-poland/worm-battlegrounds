--%%%%%%%%%%%%%%%%%%%% Gui Module

--- @class UmeGui_Gui
---
--- # General #
---
--- @field Name string | nil
--- @field Kind UmeGui_Kind | nil
--- @field Mappings string | nil
--- @field Theme string | nil
--- @field Mode UmeGui_Mode | nil
--- @field Modes { UmeGui_Mode } | nil
--- @field Devices { UmeGui_Device } | nil
---
--- # Tree #
---
--- @field Root UmeGui_Node
--- @field Templates { [string]: UmeGui_Node } | nil
---
--- # Export #
---
--- @field Screen { [string]: any } | nil
--- @field ScreenTags { [string]: { [string]: any } } | nil
---
--- # Preview #
---
--- @field Preview UmeGui_GuiPreview | nil
local _umeGui_Gui = {}

--- @class UmeGui_GuiPreview
---
--- # Size #
---
--- @field Width number
--- @field Height number
local _umeGui_GuiPreview = {}

--%%%%%%%%%%%%%%%%%%%% Preview Module

--- @class UmeGui_PreviewModule
---
--- # Settings #
---
--- @field Settings { UmeGui_Node } | nil
---
--- # Hooks #
---
--- @field Apply ((preview: UmeGui_Preview) -> ()) | nil
--- @field Action ((preview: UmeGui_Preview, id: string) -> ()) | nil
local _umeGui_PreviewModule = {}

--- @class UmeGui_Preview
---
--- # General #
---
--- @field View UmeGui_View
--- @field Mode UmeGui_Mode
--- @field Device UmeGui_Device
--- @field Pad UmeGui_Pad
---
--- # Settings #
---
--- @field Values { [string]: any }
---
--- # Methods #
---
--- @field Fill (templateName: string, items: number | { { [string]: any } }, parent: string | UmeGui_Handle | Instance | nil) -> { UmeGui_Subview }
--- @field PlayPress ((button: GuiButton) -> ()) | nil
local _umeGui_Preview = {}

--- @class UmeGui_PromptMapping
---
--- # Gamepad #
---
--- @field GamepadButtonImage { [Enum.KeyCode]: string }
--- @field PlayStationButtonImage { [Enum.KeyCode]: string }
---
--- # Keyboard #
---
--- @field KeyboardButtonImage { [Enum.KeyCode]: string }
--- @field KeyboardButtonIconMapping { [string]: string }
--- @field KeyCodeToTextMapping { [Enum.KeyCode]: string }
---
--- # Prompt #
---
--- @field KeyCapImage string
--- @field TouchTapImage string
--- @field RadialFillImage string
local _umeGui_PromptMapping = {}

--- @class UmeGui_Node
---
--- # General #
---
--- @field Control string | nil
--- @field Primitive string | nil
--- @field Id string | nil
---
--- # Look #
---
--- @field Style string | { [any]: any } | nil
--- @field Props { [string]: any } | nil
---
--- # Layout #
---
--- @field Grow number | nil
--- @field Visible boolean | nil
--- @field Children { UmeGui_Node } | nil
---
--- # Tags #
---
--- @field Tags { [string]: { [string]: any } } | nil
--- @field Attributes { [string]: any } | nil
---
--- # Prefab #
---
--- @field Parent string | nil
local _umeGui_Node = {}

--- @alias UmeGui_Kind "Default" | "Surface" | "Billboard" | "Prompt"
local _umeGui_Kind = {}

--- @alias UmeGui_Mode "Night" | "Light"
local _umeGui_Mode = {}

--- @alias UmeGui_Device "Desktop" | "Mobile" | "Console" | "VR"
local _umeGui_Device = {}

--- @alias UmeGui_Pad "Xbox" | "PlayStation"
local _umeGui_Pad = {}

--%%%%%%%%%%%%%%%%%%%% Build

--- @class UmeGui_BuildOptions
---
--- # General #
---
--- @field Mode UmeGui_Mode | nil
--- @field Interactive boolean | nil
--- @field Tokens { [string]: Color3 } | nil
local _umeGui_BuildOptions = {}

--- @class UmeGui_View
---
--- # General #
---
--- @field Gui UmeGui_Gui
--- @field Theme UmeGui_Theme
--- @field Root Folder
--- @field RootHandle UmeGui_Handle
--- @field Ids { [string]: UmeGui_Handle }
--- @field Scoped { [string]: { [string]: UmeGui_Handle } }
---
--- # Events #
---
--- @field ModeChanged UmeGui_Signal
---
--- # State #
---
--- @field Mode UmeGui_Mode
--- @field Device UmeGui_Device | nil
--- @field Pad UmeGui_Pad | nil
--- @field Interactive boolean
--- @field Tokens { [string]: Color3 }
---
--- # Methods #
---
--- @field Get (self: UmeGui_View, id: string, scopedId: string | nil) -> UmeGui_Handle
--- @field Build (self: UmeGui_View, templateName: string, parent: string | UmeGui_Handle | Instance | nil, params: { [string]: any } | nil) -> UmeGui_Subview
--- @field SetMode (self: UmeGui_View, mode: UmeGui_Mode) -> ()
--- @field SetToken (self: UmeGui_View, tokenName: string, color: Color3 | nil) -> ()
--- @field Destroy (self: UmeGui_View) -> ()
local _umeGui_View = {}

--- @class UmeGui_Subview
---
--- # General #
---
--- @field Root UmeGui_Handle
--- @field Ids { [string]: UmeGui_Handle }
---
--- # Methods #
---
--- @field Get (self: UmeGui_Subview, id: string) -> UmeGui_Handle
--- @field Destroy (self: UmeGui_Subview) -> ()
local _umeGui_Subview = {}

--- @class UmeGui_IdScope
---
--- # General #
---
--- @field Unique { [string]: string }
--- @field Local { [string]: string } | nil
--- @field Owner string | nil
--- @field Prefab boolean
local _umeGui_IdScope = {}

--- @class UmeGui_Scope
---
--- # State #
---
--- @field Refreshers { () -> () }
--- @field Connections { RBXScriptConnection | UmeGui_Signal_Connection }
--- @field Destroyed boolean
--- @field Settled boolean
local _umeGui_Scope = {}

--- @class UmeGui_DeviceDefaults
---
--- # Layout #
---
--- @field Size UDim2 | nil
--- @field Visible boolean | nil
--- @field Image string | nil
---
--- # Scale #
---
--- @field Scale number
--- @field UIScale UIScale | nil
--- @field Added boolean
local _umeGui_DeviceDefaults = {}

--- @class UmeGui_GamepadIcon
---
--- # General #
---
--- @field Style string
--- @field Key string
local _umeGui_GamepadIcon = {}

--- @class UmeGui_Handle
---
--- # General #
---
--- @field Instance GuiObject
--- @field Slot GuiObject | nil
--- @field Button ImageButton | nil
--- @field Siblings { Instance } | nil
---
--- # Children #
---
--- @field AddChild ((child: UmeGui_Handle, node: UmeGui_Node) -> ()) | nil
---
--- # Value #
---
--- @field Changed UmeGui_Signal | nil
--- @field Get (() -> any) | nil
--- @field Set ((value: any) -> ()) | nil
local _umeGui_Handle = {}

--%%%%%%%%%%%%%%%%%%%% Controls

--- @class UmeGui_Control
---
--- # Schema #
---
--- @field Params { [string]: string }
--- @field Children boolean | nil
---
--- # Building #
---
--- @field Build (node: UmeGui_Node, style: UmeGui_Style, ctx: UmeGui_Context) -> UmeGui_Handle
local _umeGui_Control = {}

--- @class UmeGui_FieldTitle
---
--- # Structure #
---
--- @field Row Frame
--- @field Label TextLabel
---
--- # Modified #
---
--- @field Restore UmeGui_Signal
--- @field SetModified (modified: boolean) -> ()
---
--- # Icon #
---
--- @field SetIcon (image: string | nil, rectOffset: Vector2 | nil, rectSize: Vector2 | nil) -> ()
local _umeGui_FieldTitle = {}

--- @class UmeGui_Pressable
---
--- # Structure #
---
--- @field Container Frame
--- @field Button ImageButton
--- @field Background Frame
--- @field Content Frame
---
--- # Text #
---
--- @field Text TextLabel | nil
local _umeGui_Pressable = {}

--- @class UmeGui_Surface
---
--- # Structure #
---
--- @field Root Frame
--- @field Background Frame
--- @field Content Frame
local _umeGui_Surface = {}

--- @alias UmeGui_Style { [string]: any }
local _umeGui_Style = {}

--- @class UmeGui_StateTarget
---
--- # General #
---
--- @field Instance Instance
--- @field Property string
local _umeGui_StateTarget = {}

--- @class UmeGui_States
---
--- # Control #
---
--- @field Set (stateName: string, active: boolean) -> ()
--- @field SetBase (styleKey: string, value: any) -> ()
--- @field Refresh (instant: boolean | nil) -> ()
---
--- # Methods #
---
--- @field IsActive (stateName: string) -> boolean
local _umeGui_States = {}

--- @class UmeGui_Context
---
--- # General #
---
--- @field Theme UmeGui_Theme
--- @field Interactive boolean
--- @field Signal UmeGui_Signal
---
--- # Instances #
---
--- @field Create (className: string, props: { [string]: any } | nil) -> Instance
--- @field Build (node: UmeGui_Node, parent: Instance | nil) -> UmeGui_Handle
--- @field Tag (instance: Instance, tags: { [string]: { [string]: any } } | nil) -> ()
---
--- # Tokens #
---
--- @field Color (instance: Instance, property: string, value: any) -> ()
--- @field ResolveColor (value: any) -> Color3
--- @field Number (group: string, value: any) -> number
--- @field Font (value: any) -> Font
--- @field Icon (value: string | nil) -> string
--- @field Glyph (name: string | nil, size: number, color: any) -> ImageLabel
--- @field Typography (instance: TextLabel, font: any, textSize: any, lineHeight: boolean | nil) -> ()
--- @field Text (instance: TextLabel, font: any, textSize: any, color: any) -> ()
--- @field Corner (instance: Instance, radius: any) -> UICorner
--- @field Stroke (instance: Instance, color: any, thickness: any) -> UIStroke
--- @field Padding (instance: Instance, spacing: any, horizontal: any | nil) -> UIPadding
--- @field List (instance: Instance, direction: "Horizontal" | "Vertical", gap: any) -> UIListLayout
--- @field Pressable (size: UDim2, text: string | nil) -> UmeGui_Pressable
--- @field MeasureText (instance: TextLabel) -> number
--- @field FitWidth (parts: UmeGui_Pressable) -> ()
--- @field Surface (size: UDim2, autoHeight: boolean | nil) -> UmeGui_Surface
---
--- # Behaviour #
---
--- @field States (targets: { [string]: UmeGui_StateTarget }, style: UmeGui_Style) -> UmeGui_States
--- @field Hover (button: GuiObject, states: UmeGui_States) -> ()
--- @field Animate (instance: Instance, goals: { [string]: any }, instant: boolean | nil, speed: string | nil) -> ()
--- @field Tween (instance: Instance, goals: { [string]: any }, speed: string | nil) -> ()
--- @field Capture (onMove: (position: Vector2) -> (), onRelease: (() -> ()) | nil, source: GuiObject | nil) -> ()
--- @field Overlay (onClose: () -> ()) -> ImageButton
--- @field ContextMenu (actions: { any }, onPick: (actionId: string) -> ()) -> () -> ()
--- @field Connect (signal: RBXScriptSignal | UmeGui_Signal, callback: (...any) -> ()) -> ()
--- @field Refresh (refresher: () -> ()) -> ()
---
--- # Mode #
---
--- @field GetMode () -> UmeGui_Mode
--- @field SetMode (mode: UmeGui_Mode) -> ()
local _umeGui_Context = {}

--%%%%%%%%%%%%%%%%%%%% Themes

--- @class UmeGui_ThemeDefinition
---
--- # General #
---
--- @field Extends string | nil
--- @field Tokens UmeGui_Tokens | nil
local _umeGui_ThemeDefinition = {}

--- @class UmeGui_Theme
---
--- # General #
---
--- @field Name string
---
--- # Look #
---
--- @field Tokens UmeGui_Tokens
--- @field Styles { [string]: { [string]: UmeGui_Style } }
---
--- # Controls #
---
--- @field Controls { Instance }
---
--- # Gamepad #
---
--- @field Gamepad UmeGui_Gamepad | nil
local _umeGui_Theme = {}

--- @alias UmeGui_Gamepad { [string]: { [string]: { [string]: string } } }
local _umeGui_Gamepad = {}

--- @class UmeGui_Tokens
---
--- # Colors #
---
--- @field Palette { [string]: { [string]: Color3 } }
--- @field Swatches { [string]: { Color3 } }
---
--- # Text #
---
--- @field Font { [string]: UmeGui_FontToken }
--- @field TextSize { [string]: number }
---
--- # Icons #
---
--- @field Icons { [string]: string }
---
--- # Shape #
---
--- @field Radius { [string]: number }
--- @field Size { [string]: number }
--- @field Spacing { [string]: number }
--- @field Stroke { [string]: number }
---
--- # Motion #
---
--- @field Motion { [string]: number }
---
--- # Assets #
---
--- @field Gradients { [string]: UmeGui_Gradient } | nil
--- @field Images { [string]: string } | nil
local _umeGui_Tokens = {}

--- @class UmeGui_Gradient
---
--- # Look #
---
--- @field Color ColorSequence
--- @field Offset Vector2
--- @field Rotation number
--- @field Transparency NumberSequence
local _umeGui_Gradient = {}

--- @class UmeGui_FontToken
---
--- # General #
---
--- @field Family string
--- @field Weight string
local _umeGui_FontToken = {}

--%%%%%%%%%%%%%%%%%%%% Libs

--- @class UmeGui_SoundParams
---
--- # General #
---
--- @field Name string
--- @field SoundGroup string | nil
---
--- # Playback #
---
--- @field Volume number | nil
--- @field PlaybackSpeed number | nil
--- @field TimePosition number | nil
--- @field PitchMin number | nil
--- @field PitchMax number | nil
---
--- # Variants #
---
--- @field SoundTableIndex number | nil
--- @field Sequential boolean | nil
local _umeGui_SoundParams = {}

--- @class UmeGui_ComponentClass
---
--- # Constructor #
---
--- @field new (instance: Instance) -> UmeGui_ComponentObject
local _umeGui_ComponentClass = {}

--- @class UmeGui_ComponentObject
---
--- # General #
---
--- @field Instance Instance
--- @field _destroyed boolean
---
--- # Lifecycle #
---
--- @field Init (self: UmeGui_ComponentObject) -> ()
--- @field Destroy (self: UmeGui_ComponentObject) -> ()
local _umeGui_ComponentObject = {}
