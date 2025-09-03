--[[ Services ]]
local DataStoreService  = game:GetService("DataStoreService")
local HttpService       = game:GetService("HttpService")

--[[ Variables ]]
local ProfileDataStore 	= DataStoreService:GetDataStore("ProfileDataStore")
local GlobalProfileDataStore = DataStoreService:GetGlobalDataStore()
local ProfileList		= {}

--[[ Core ]]
-- table copy function
local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

-- table check function
local function deepCheck(Table,Template)
	for Key,Value in pairs(Template) do
		if typeof(Value) == "table" then
			if Table[Key] == nil then
				Table[Key] = Value
			else
				Table[Key] = deepCheck(Table[Key],Value)
			end
		else
			Table[Key] = Table[Key] or Value
		end
	end
	return Table
end

-- Main functions --------------------------------
local Profile = {}
Profile.__index = Profile

function Profile.new(Player,DataTemplate,GlobalTemplate)
	local PlayerData = ProfileDataStore:GetAsync(Player.UserId)

	local globalPlayerData = nil
	if GlobalTemplate then
		globalPlayerData = GlobalProfileDataStore:GetAsync(Player.UserId)

		if globalPlayerData == nil then
			globalPlayerData = deepCopy(GlobalTemplate)
		else
			globalPlayerData = HttpService:JSONDecode(globalPlayerData)
			globalPlayerData = deepCheck(globalPlayerData,GlobalTemplate) -- Check data
		end
	end

	if PlayerData == nil then
		PlayerData = deepCopy(DataTemplate)
	else
		PlayerData = HttpService:JSONDecode(PlayerData)
		PlayerData = deepCheck(PlayerData,DataTemplate) -- Check data
	end

	local Profile = setmetatable({
		player  = Player,
		data    = PlayerData,
		globaldata = globalPlayerData
	}, Profile)

	ProfileList[Player.UserId] = Profile

	return Profile
end

function Profile.GetById(id)
	local PlayerData = ProfileDataStore:GetAsync(id)
	local globalPlayerData = GlobalProfileDataStore:GetAsync(id)
	
	local Profile = setmetatable({
		data    = PlayerData,
		globaldata = globalPlayerData,
		userid = id,
	}, Profile)

	return Profile
end

function Profile.GetByPlayer(Player)
	return ProfileList[Player.UserId]
end

function Profile:Save()
	local Data      = self.data
	local Player    = self.player
	local Global	= self.globaldata
	
	if Player then
		ProfileDataStore:SetAsync(Player.UserId,HttpService:JSONEncode(Data))
		GlobalProfileDataStore:SetAsync(Player.UserId,HttpService:JSONEncode(Global))
	else
		ProfileDataStore:SetAsync(self.userid, HttpService:JSONEncode(Data))
		GlobalProfileDataStore:SetAsync(self.userid, HttpService:JSONEncode(Global))
	end
end

function Profile:Destroy()
	ProfileList[self.player.UserId] = nil
	self = nil
	return self
end

return Profile
