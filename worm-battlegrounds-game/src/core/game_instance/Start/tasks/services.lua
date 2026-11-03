--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task

--- @class Ume_Task_Services
local _task = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Load

--[[
	Creates and assigns the `Service` metatable to the Ume framework.
]]
function _task.Load(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	-- Metatable for accessing Roblox services.
	--- @class Services
	--- @field AnalyticsService AnalyticsService
	--- @field AnimationClipProvider AnimationClipProvider
	--- @field AssetService AssetService
	--- @field AvatarCreationService AvatarCreationService
	--- @field AvatarEditorService AvatarEditorService
	--- @field BadgeService BadgeService
	--- @field CaptureService CaptureService
	--- @field Chat Chat
	--- @field CollectionService CollectionService
	--- @field ConfigService ConfigService
	--- @field ContentProvider ContentProvider
	--- @field ContextActionService ContextActionService
	--- @field ControllerService ControllerService
	--- @field DataStoreService DataStoreService
	--- @field Debris Debris
	--- @field ExperienceNotificationService ExperienceNotificationService
	--- @field GamepadService GamepadService
	--- @field GamePassService GamePassService
	--- @field GroupService GroupService
	--- @field GuiService GuiService
	--- @field HapticService HapticService
	--- @field HttpService HttpService
	--- @field InsertService InsertService
	--- @field JointsService JointsService
	--- @field KeyframeSequenceProvider KeyframeSequenceProvider
	--- @field Lighting Lighting
	--- @field LocalizationService LocalizationService
	--- @field LogService LogService
	--- @field MarketplaceService MarketplaceService
	--- @field MaterialService MaterialService
	--- @field MemoryStoreService MemoryStoreService
	--- @field MessagingService MessagingService
	--- @field PathfindingService PathfindingService
	--- @field PhysicsService PhysicsService
	--- @field Players Players
	--- @field PolicyService PolicyService
	--- @field ProximityPromptService ProximityPromptService
	--- @field ReplicatedFirst ReplicatedFirst
	--- @field ReplicatedStorage ReplicatedStorage
	--- @field RunService RunService
	--- @field ScriptContext ScriptContext
	--- @field ServerScriptService ServerScriptService
	--- @field ServerStorage ServerStorage
	--- @field SharedTableRegistry SharedTableRegistry
	--- @field SocialService SocialService
	--- @field SoundService SoundService
	--- @field StarterGui StarterGui
	--- @field StarterPack StarterPack
	--- @field StarterPlayer StarterPlayer
	--- @field Stats Stats
	--- @field Teams Teams
	--- @field TeleportService TeleportService
	--- @field TextChatService TextChatService
	--- @field TextService TextService
	--- @field TweenService TweenService
	--- @field UserInputService UserInputService
	--- @field UserService UserService
	--- @field VoiceChatService VoiceChatService
	--- @field VRService VRService
	--- @field Workspace Workspace
	I.S = setmetatable({}, {
		__index = function(self, serviceName: string)
			local service: Instance = game:GetService(serviceName)
			rawset(self, serviceName, service)
			return service
		end,
	})
end

return _task
