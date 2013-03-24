MPR_LKTimers = CreateFrame("Frame", "MPR LK Timers", UIParent)
MPR_LKTimers.TimeSinceLastUpdate = 0
MPR_LKTimers.LichKingWarnings = {
-- Will warn: "Warning: The Lich King has {%%}% HP remaining! {Message}"
--	[%%] = {Warned, Message},
	[77] = {false, nil},
	[74] = {false, "Transition soon!"},
	[47] = {false, nil},
	[44] = {false, "Transition soon!"},
}
MPR_LKTimers.QuakeCount = 0
MPR_LKTimers.DataTimers = {
-- 	{[1] = Timer, [2] = Paused, [3] = PauseInFrostmourne},
	{[1] = nil, [2] = nil, [3] = nil}, -- Summon Shadow Trap
	{[1] = nil,	[2] = nil, [3] = nil}, -- Summon Val'kyr
	{[1] = nil,	[2] = nil, [3] = true}, -- Defile
	{[1] = nil,	[2] = nil, [3] = nil}, -- Harvest Soul/Harvest Souls
}
MPR_LKTimers.TimerWarns = {
	[1] = {[5] = {false, 8}, [3] = {false, 8}},
	[2] = {[10] = {false, 4}, [5] = {false, 4}},
	[3] = {[10] = {false, 7}, [5] = {false, 7}},
	[4] = {[10] = {false, 6}, [5] = {false, 6}},
}
MPR_LKTimers.IgnoreSubZoneTimer = nil -- 10 sec timer while The Lich King is channeling Harvest Souls (6.5 sec). Ignores player not InFrostmourne check.
MPR_LKTimers.InFrostmourne = nil
MPR_LKTimers.ValkyrCount = 0
MPR_LKTimers.ValkyrTable = {} -- {IconID, Health, HealthMax, Speed}
MPR_LKTimers.ValkyrUpdated = {}
MPR_LKTimers.GrabbedPlayers = {}
MPR_LKTimers.ValkyrObjects = {}
function MPR_LKTimers:Initialize()
	MPR_LKTimers:Hide()
	MPR_LKTimers:SetBackdrop(MPR.Settings["BACKDROP"])
	MPR_LKTimers:SetBackdropColor(unpack(MPR.Settings["BACKDROPCOLOR"]))
	MPR_LKTimers:SetBackdropBorderColor(MPR.Settings["BACKDROPBORDERCOLOR"].R/255, MPR.Settings["BACKDROPBORDERCOLOR"].G/255, MPR.Settings["BACKDROPBORDERCOLOR"].B/255)
	MPR_LKTimers:SetPoint("CENTER",UIParent)
	MPR_LKTimers:SetWidth(250)
	MPR_LKTimers:SetHeight(56)
	MPR_LKTimers:EnableMouse(true)
	MPR_LKTimers:SetMovable(true)
	MPR_LKTimers:RegisterForDrag("LeftButton")
	MPR_LKTimers:SetUserPlaced(true)
	MPR_LKTimers:SetScript("OnDragStart", function(self) MPR_LKTimers:StartMoving() end)
	MPR_LKTimers:SetScript("OnDragStop", function(self) MPR_LKTimers:StopMovingOrSizing() end)
	MPR_LKTimers:SetFrameStrata("FULLSCREEN_DIALOG")
	
	MPR_LKTimers.Title = MPR_LKTimers:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	MPR_LKTimers.Title:SetPoint("TOP", 0, -8)
	MPR_LKTimers.Title:SetTextColor(190/255, 190/255, 190/255)
	MPR_LKTimers.Title:SetText("|cff"..MPR.Colors["TITLE"].."MP Reporter|r - LK Timers")
	MPR_LKTimers.Title:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
	MPR_LKTimers.Title:SetShadowOffset(1, -1)
	
	MPR_LKTimers.CloseButton = CreateFrame("button","BtnClose", MPR_LKTimers, "UIPanelButtonTemplate")
	MPR_LKTimers.CloseButton:SetHeight(14)
	MPR_LKTimers.CloseButton:SetWidth(14)
	MPR_LKTimers.CloseButton:SetPoint("TOPRIGHT", -8, -8)
	MPR_LKTimers.CloseButton:SetText("x")
	MPR_LKTimers.CloseButton:SetScript("OnClick", function(self) MPR_LKTimers_Options:Hide(); MPR_LKTimers:Hide() end)
	
	MPR_LKTimers.CloseButton = CreateFrame("button","BtnClose", MPR_LKTimers, "UIPanelButtonTemplate")
	MPR_LKTimers.CloseButton:SetHeight(14)
	MPR_LKTimers.CloseButton:SetWidth(14)
	MPR_LKTimers.CloseButton:SetPoint("TOPRIGHT", -24, -8)
	MPR_LKTimers.CloseButton:SetText("o")
	MPR_LKTimers.CloseButton:SetScript("OnClick", function(self) MPR_LKTimers_Options:Show() end)
	MPR_LKTimers.CloseButton:Disable()
	
	-- Timer Label - Left
	MPR_LKTimers.Label1 = MPR_LKTimers:CreateFontString("Label3", "OVERLAY", "GameTooltipText")
	MPR_LKTimers.Label1:SetPoint("TOPLEFT", 8, -22)
	MPR_LKTimers.Label1:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)
	MPR_LKTimers.Label1:SetText(GetSpellLink(69037)..": |cFFbebebenil|r")
	
	-- Timer Label - Right
	MPR_LKTimers.Label2 = MPR_LKTimers:CreateFontString("Label1", "OVERLAY", "GameTooltipText")
	MPR_LKTimers.Label2:SetPoint("TOPLEFT", 144, -22)
	MPR_LKTimers.Label2:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)
	MPR_LKTimers.Label2:SetText(GetSpellLink(72762).." CD: |cFFbebebenil|r")
		
	MPR_LKTimers.Label3 = MPR_LKTimers:CreateFontString("Label5", "OVERLAY", "GameTooltipText")
	MPR_LKTimers.Label3:SetPoint("TOPLEFT", 8, -36)
	MPR_LKTimers.Label3:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)
	MPR_LKTimers.Label3:SetText("Grabbed players: ")
	
	--[[
	local ValkyrIcon = select(3,GetSpellInfo(71843))
	MPR_LKTimers.Texture1 = MPR_LKTimers:CreateTexture("$parentTexture")
	MPR_LKTimers.Texture1:SetPoint('TOPLEFT', 8, -50)
	MPR_LKTimers.Texture1:SetWidth(24)
	MPR_LKTimers.Texture1:SetHeight(24)
	MPR_LKTimers.Texture1:SetTexture(ValkyrIcon)
	MPR_LKTimers.Texture1:SetAlpha(0.4)
	
	MPR_LKTimers.T1Label1 = MPR_LKTimers:CreateFontString("Label5", "OVERLAY", "GameTooltipText")
	MPR_LKTimers.T1Label1:SetPoint("TOPLEFT", MPR_LKTimers.Texture1, "TOPRIGHT", 4, 0)
	MPR_LKTimers.T1Label1:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)
	MPR_LKTimers.T1Label1:SetTextColor(1,1,1)
	MPR_LKTimers.T1Label1:SetText("Val'kyr 1")
	MPR_LKTimers.T1Label1:SetAlpha(0.4)
	
	MPR_LKTimers.T1Label2 = MPR_LKTimers:CreateFontString("Label5", "OVERLAY", "GameTooltipText")
	MPR_LKTimers.T1Label2:SetPoint("TOPLEFT", MPR_LKTimers.Texture1, "TOPRIGHT", 4, -12)
	MPR_LKTimers.T1Label2:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)
	MPR_LKTimers.T1Label2:SetTextColor(0.9,0.9,0.9)
	MPR_LKTimers.T1Label2:SetText("HP: nil")
	MPR_LKTimers.T1Label2:SetAlpha(0.4)
	
	MPR_LKTimers.Texture2 = MPR_LKTimers:CreateTexture("$parentTexture")
	MPR_LKTimers.Texture2:SetPoint('TOPLEFT', 88, -50)
	MPR_LKTimers.Texture2:SetWidth(24)
	MPR_LKTimers.Texture2:SetHeight(24)
	MPR_LKTimers.Texture2:SetTexture(ValkyrIcon)
	MPR_LKTimers.Texture2:SetAlpha(0.4)
	
	MPR_LKTimers.T2Label1 = MPR_LKTimers:CreateFontString("T2Label1", "OVERLAY", "GameTooltipText")
	MPR_LKTimers.T2Label1:SetPoint("TOPLEFT", MPR_LKTimers.Texture2, "TOPRIGHT", 4, 0)
	MPR_LKTimers.T2Label1:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)
	MPR_LKTimers.T2Label1:SetTextColor(0.9,0.9,0.9)
	MPR_LKTimers.T2Label1:SetText("Val'kyr 2")
	MPR_LKTimers.T2Label1:SetAlpha(0.4)
	
	MPR_LKTimers.T2Label2 = MPR_LKTimers:CreateFontString("T2Label2", "OVERLAY", "GameTooltipText")
	MPR_LKTimers.T2Label2:SetPoint("TOPLEFT", MPR_LKTimers.Texture2, "TOPRIGHT", 4, -12)
	MPR_LKTimers.T2Label2:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)
	MPR_LKTimers.T2Label2:SetTextColor(190/255, 190/255, 190/255)
	MPR_LKTimers.T2Label2:SetText("HP: nil")
	MPR_LKTimers.T2Label2:SetAlpha(0.4)
	
	MPR_LKTimers.Texture3 = MPR_LKTimers:CreateTexture("$parentTexture")
	MPR_LKTimers.Texture3:SetPoint('TOPLEFT', 168, -50)
	MPR_LKTimers.Texture3:SetWidth(24)
	MPR_LKTimers.Texture3:SetHeight(24)
	MPR_LKTimers.Texture3:SetTexture(ValkyrIcon)
	MPR_LKTimers.Texture3:SetAlpha(0.4)
	
	MPR_LKTimers.T3Label1 = MPR_LKTimers:CreateFontString("T3Label1", "OVERLAY", "GameTooltipText")
	MPR_LKTimers.T3Label1:SetPoint("TOPLEFT", MPR_LKTimers.Texture3, "TOPRIGHT", 4, 0)
	MPR_LKTimers.T3Label1:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)
	MPR_LKTimers.T3Label1:SetTextColor(0.9,0.9,0.9)
	MPR_LKTimers.T3Label1:SetText("Val'kyr 3")
	MPR_LKTimers.T3Label1:SetAlpha(0.4)
	
	MPR_LKTimers.T3Label2 = MPR_LKTimers:CreateFontString("T3Label2", "OVERLAY", "GameTooltipText")
	MPR_LKTimers.T3Label2:SetPoint("TOPLEFT", MPR_LKTimers.Texture3, "TOPRIGHT", 4, -12)
	MPR_LKTimers.T3Label2:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)	
	MPR_LKTimers.T3Label2:SetTextColor(190/255, 190/255, 190/255)
	MPR_LKTimers.T3Label2:SetText("HP: nil")
	MPR_LKTimers.T3Label2:SetAlpha(0.4)
	
	self.ValkyrObjects[1] = {}
	self.ValkyrObjects[1][1] = self.Texture1
	self.ValkyrObjects[1][2] = self.T1Label1
	self.ValkyrObjects[1][3] = self.T1Label2
	self.ValkyrObjects[2] = {}
	self.ValkyrObjects[2][1] = self.Texture2
	self.ValkyrObjects[2][2] = self.T2Label1
	self.ValkyrObjects[2][3] = self.T2Label2
	self.ValkyrObjects[3] = {}
	self.ValkyrObjects[3][1] = self.Texture3
	self.ValkyrObjects[3][2] = self.T3Label1
	self.ValkyrObjects[3][3] = self.T3Label2
	]]
	
	MPR_LKTimers_Options:Initialize()
end
function MPR_LKTimers:Toggle()
	if MPR_LKTimers:IsVisible() then
		MPR_LKTimers:Hide()
	else
		MPR_LKTimers:Show()
	end
end

function MPR_LKTimers:OnUpdate(elapsed)
	local Seconds, Color
	local bWhite = GetTime()%1.5 < 0.75
		
	if self.DataTimers[1][1] then -- Summon Shadow Trap
		Seconds = round(self.DataTimers[1][1],0,true)
		if self.TimerWarns[1][Seconds] and not self.TimerWarns[1][Seconds][1] then
			self.TimerWarns[1][Seconds][1] = true
			MPR:HandleReport((self.TimerWarns[1][Seconds][2] and "{rt"..self.TimerWarns[1][Seconds][2].."} " or "")..GetSpellLink(73539).." CD: "..Seconds.." sec"..(self.TimerWarns[1][Seconds][2] and " {rt"..self.TimerWarns[1][Seconds][2].."}" or ""))
		elseif self.TimerWarns[1][Seconds+1] and self.TimerWarns[1][Seconds+1][1] then
			self.TimerWarns[1][Seconds+1][1] = false
		end
		Color = self.DataTimers[1][2] and bWhite and "BEBEBE" or Seconds > 12 and "00FF00" or Seconds > 9 and "FFFF00" or Seconds > 6 and "FFAA00" or Seconds > 3 and "FF7700" or "FF0000"
		MPR_LKTimers.Label1:SetText(GetSpellLink(73539).." CD: |cFF"..Color..Seconds.." sec|r")
	elseif self.DataTimers[4][1] then -- Harvest Souls
		Seconds = round(self.DataTimers[4][1],0,true)
		local HarvestSoulSpellIDByDiff = {[1] = 68980, [2] = 74325, [3] = 74296, [4] = 74297}
		if self.TimerWarns[4][Seconds] and not self.TimerWarns[4][Seconds][1] then
			self.TimerWarns[4][Seconds][1] = true
			MPR:HandleReport((self.TimerWarns[4][Seconds][2] and "{rt"..self.TimerWarns[4][Seconds][2].."} " or "")..GetSpellLink(HarvestSoulSpellIDByDiff[GetInstanceDifficulty()]).." CD: "..Seconds.." sec"..(self.TimerWarns[4][Seconds][2] and " {rt"..self.TimerWarns[4][Seconds][2].."}" or ""))
		elseif self.TimerWarns[4][Seconds+1] and self.TimerWarns[4][Seconds+1][1] then
			self.TimerWarns[4][Seconds+1][1] = false
		end
		Color = self.DataTimers[4][2] and bWhite and "BEBEBE" or Seconds > 12 and "00FF00" or Seconds > 9 and "FFFF00" or Seconds > 6 and "FFAA00" or Seconds > 3 and "FF7700" or "FF0000"
		MPR_LKTimers.Label1:SetText(GetSpellLink(HarvestSoulSpellIDByDiff[GetInstanceDifficulty()]).." CD: |cFF"..Color..Seconds.." sec|r")
	elseif self.DataTimers[2][1] then -- Summon Val'kyr timer
		Seconds = round(self.DataTimers[2][1],0,true)
		if self.TimerWarns[2][Seconds] and not self.TimerWarns[2][Seconds][1] then
			self.TimerWarns[2][Seconds][1] = true
			MPR:HandleReport((self.TimerWarns[2][Seconds][2] and "{rt"..self.TimerWarns[2][Seconds][2].."} " or "")..GetSpellLink(69037)..": "..Seconds.." sec"..(self.TimerWarns[2][Seconds][2] and " {rt"..self.TimerWarns[2][Seconds][2].."}" or ""))
		elseif self.TimerWarns[2][Seconds+1] and self.TimerWarns[2][Seconds+1][1] then
			self.TimerWarns[2][Seconds+1][1] = false
		end
		Color = self.DataTimers[2][2] and bWhite and "BEBEBE" or Seconds > 20 and "00FF00" or Seconds > 15 and "FFFF00" or Seconds > 10 and "FFAA00" or Seconds > 5 and "FF7700" or "FF0000"
		MPR_LKTimers.Label1:SetText(GetSpellLink(69037)..": |cFF"..Color..Seconds.." sec|r")
	else
		MPR_LKTimers.Label1:SetText(GetSpellLink(69037)..": |cFFbebebenil|r")
	end
	-- Defile CD timer
	if self.DataTimers[3][1] then
		Seconds = round(self.DataTimers[3][1],0,true)
		if self.TimerWarns[3][Seconds] and not self.TimerWarns[3][Seconds][1] then
			self.TimerWarns[3][Seconds][1] = true
			MPR:HandleReport((self.TimerWarns[3][Seconds][2] and "{rt"..self.TimerWarns[3][Seconds][2].."} " or "")..GetSpellLink(72762).." CD: "..Seconds.." sec"..(self.TimerWarns[3][Seconds][2] and " {rt"..self.TimerWarns[3][Seconds][2].."}" or ""))
		elseif self.TimerWarns[3][Seconds+1] and self.TimerWarns[3][Seconds+1][1] then
			self.TimerWarns[3][Seconds+1][1] = false
		end
		Color = self.DataTimers[3][2] and bWhite and "BEBEBE" or Seconds > 20 and "00FF00" or Seconds > 15 and "FFFF00" or Seconds > 10 and "FFAA00" or Seconds > 5 and "FF7700" or "FF0000"
		MPR_LKTimers.Label2:SetText(GetSpellLink(72762).." CD: |cFF"..Color..Seconds.." sec|r")
	else  
		MPR_LKTimers.Label2:SetText(GetSpellLink(72762).." CD: |cFFbebebenil|r")
	end
	
	MPR_LKTimers.TimeSinceLastUpdate = MPR_LKTimers.TimeSinceLastUpdate + elapsed
    if MPR_LKTimers.TimeSinceLastUpdate >= MPR.Settings["UPDATEFREQUENCY"] then
		local diff = MPR_LKTimers.TimeSinceLastUpdate
		MPR_LKTimers.TimeSinceLastUpdate = 0
		MPR_LKTimers:Update(diff)
    end
end

local ClassColors = {["DEATHKNIGHT"] = "C41F3B", ["DRUID"] = "FF7D0A", ["HUNTER"] = "ABD473", ["MAGE"] = "69CCF0", ["PALADIN"] = "F58CBA", ["PRIEST"] = "FFFFFF", ["ROGUE"] = "FFF569", ["SHAMAN"] = "0070DE", ["WARLOCK"] = "9482C9", ["WARRIOR"] = "C79C6E"}
function MPR_LKTimers:Update()
	local countValkyr = 0
	local arrayGrabbed = {}
	local Color = {R = 1, G = 1, B = 1}
	
	local LKHealthPct = nil
	for i=1,GetNumRaidMembers() do
		local UnitIDTarget = (i > 0 and "raid"..i or "").."target"
		if UnitName(UnitIDTarget) == "The Lich King" then
			LKHealthPct = round(100*UnitHealth(UnitIDTarget)/UnitHealthMax(UnitIDTarget),0,true)
			break
		end
	end
	if LKHealthPct and LKHealthPct > 40 and self.LichKingWarnings[LKHealthPct] and not self.LichKingWarnings[LKHealthPct][1] then
		self.LichKingWarnings[LKHealthPct][1] = true
		MPR:RaidReport("Warning: The Lich King has "..LKHealthPct.."% HP remaining! "..(self.LichKingWarnings[LKHealthPct][2] or ""),true)
	end
	
	if self.QuakeCount == 1 then -- During Phase 2 only
		for i=0,GetNumRaidMembers() do
			local UnitID = i == 0 and "player" or "raid"..i
			
			-- Check if grabbed
			if UnitInVehicle(UnitID) then
				if not self.GrabbedPlayers[UnitName(UnitID)] then -- Insert grabbed player
					MPR:ReportValkyrGrab(UnitName(UnitID))
					self.GrabbedPlayers[UnitName(UnitID)] = {} -- {UnitName => TargetMarker}
					self.GrabbedPlayers[UnitName(UnitID)].Name = string.format("|cFF%s%s|r",ClassColors[strupper(select(2,UnitClass(UnitID)))],UnitName(UnitID))
					self.GrabbedPlayers[UnitName(UnitID)].Icon = GetRaidTargetIndex(UnitID)
				elseif GetRaidTargetIndex(UnitID) then -- Update grabbed player's icon if we don't have it yet
					self.GrabbedPlayers[UnitName(UnitID)].Icon = GetRaidTargetIndex(UnitID)
				end
			elseif self.GrabbedPlayers[UnitName(UnitID)] then -- Remove grabbed player
				self.GrabbedPlayers[UnitName(UnitID)] = nil
			end
			
			--[[
			-- Check if targeting Valkyr and get data
			if UnitName(UnitID.."target") == "Val'kyr Shadowguard" then
				local RaidMarker = GetRaidTargetIndex(UnitID.."target")
				local GUID, Health, HealthMax, Speed = tonumber(string.sub(UnitGUID(UnitID.."target"),9,12),16).."-"..tonumber(string.sub(UnitGUID(UnitID.."target"),13),16), UnitHealth(UnitID.."target"), UnitHealthMax(UnitID.."target"), GetUnitSpeed(UnitID.."target")
				local HealthPct = round(100*Health/HealthMax,0,true) 
				if not self.ValkyrUpdated[GUID] and self.ValkyrTable[GUID] then
					self.ValkyrUpdated[GUID] = true
					if (GetInstanceDifficulty() <= 2 or HealthPct > 50) then -- Update this Val'kyr
						-- {1 => TextureID, 2 => RaidMarkerID, 3 => HealthPct, 4 => Speed}
						self.ValkyrTable[GUID][2] = RaidMarker
						self.ValkyrTable[GUID][3] = HealthPct
						self.ValkyrTable[GUID][4] = Speed
					else  -- Remove this Val'kyr
						self.ValkyrTable[GUID] = nil
					end
				end
			end
			]]
		end
		
			
		-- Print grabbed players
		for _,Unit in pairs(self.GrabbedPlayers) do
			table.insert(arrayGrabbed,(Unit.Icon and Unit.Icon > 0 and "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..Unit.Icon..":12:12|t" or "")..Unit.Name)
		end
		-- Blinking label if players are grabbed
		if #arrayGrabbed > 0 then
			if GetTime()%1.4 < 0.7 then
				Color = {R = 1, G = 0, B = 0}
			end
		end
		
		self:SetHeight(56)
		MPR_LKTimers.Label3:Show()
		--[[
		-- Print Valky data
		for GUID,Data in pairs(self.ValkyrTable) do
			if self.ValkyrUpdated[GUID] then
				local Index, RaidMarker, HealthPct, Speed = unpack(Data)
				local Color = GetInstanceDifficulty() <= 2 and (HealthPct <= 10 and "00FF00" or HealthPct <= 20 and "FFFF00" or HealthPct <= 30 and "FFAA00" or HealthPct <= 50 and "FF7700" or "FF0000") or (HealthPct <= 55 and "00FF00" or HealthPct <= 60 and "FFFF00" or HealthPct <= 65 and "FFAA00" or HealthPct <= 75 and "FF7700" or "FF0000")
				self.ValkyrObjects[Index][1]:SetAlpha(1)
				self.ValkyrObjects[Index][2]:SetAlpha(1)
				self.ValkyrObjects[Index][3]:SetAlpha(1)
				self.ValkyrObjects[Index][3]:SetText(string.format("HP: |c%s%s%%|r",Color,HealthPct))
			else -- None of members targeting this Val'kyr, so we'll just remove it.
				local Index = Data[1]
				self.ValkyrObjects[Index][1]:SetAlpha(0.4)
				self.ValkyrObjects[Index][2]:SetAlpha(0.4)
				self.ValkyrObjects[Index][3]:SetAlpha(0.4)
				self.ValkyrObjects[Index][3]:SetText("HP: |cFFbebebenil|r")
				self.ValkyrTable[GUID] = nil
			end
		end
		self.ValkyrUpdated = {}
		
		if not self.ValkyrObjects[1][1]:IsVisible() then
			MPR_LKTimers.Label3:Show()
			self:SetHeight(83)
			for i=1,3 do
				for o=1,3 do
					self.ValkyrObjects[i][o]:Show()
				end
			end
		end
		]]
	else
		self.GrabbedPlayers = {}
		self.ValkyrTable = {}
		
		self:SetHeight(43)
		MPR_LKTimers.Label3:Hide()
		--[[
		if self.ValkyrObjects[1][1]:IsVisible() then
			--MPR_LKTimers.Label3:Hide()
			for i=1,3 do
				for o=1,3 do
					self.ValkyrObjects[i][o]:Hide()
				end
			end
		end
		]]
	end
	
	self.Label3:SetTextColor(Color.R, Color.G, Color.B)
	self.Label3:SetText("Grabbed players: "..table.concat(arrayGrabbed,", "))
end
function MPR_LKTimers:SummonShadowTrap()
	self.DataTimers[1][1] = 14
end
function MPR_LKTimers:SummonValkyr(GUID)
	self.ValkyrCount = self.ValkyrCount + 1
	if self.ValkyrCount == 1 then -- First Valkyr
		self.DataTimers[2][1] = 45
	end
	--self.ValkyrTable[GUID] = {}
	--self.ValkyrTable[GUID][1] = self.ValkyrCount
	if self.ValkyrCount == (GetInstanceDifficulty()%2 == 1 and 1 or 3) then -- Last Valkyr
		self.ValkyrCount = 0
	end
end
function MPR_LKTimers:Defile()
	local Cooldown = self.QuakeCount == 1 and 31 or 32
	local activeCooldown = round(self.DataTimers[3][1],1,true)
	if activeCooldown > 0 then
		Cooldown = Cooldown - activeCooldown
		print("|cFFFF0000MP Reporter: New Defile cooldown - "..Cooldown.." seconds! QuakeCount: "..self.QuakeCount.."|r")
	end
	self.DataTimers[3][1] = Cooldown
end
function MPR_LKTimers:HarvestSoul()
	self.DataTimers[4][1] = 75
end
function MPR_LKTimers:HarvestSouls()
	MPR_LKTimers.IgnoreSubZoneTimer = 52 --10 -- temp. fix for Molten LK
	self.InFrostmourne = true
	self.DataTimers[4][1] = 120
	self.DataTimers[3][1] = 3
end
function MPR_LKTimers:RemorselessWinter()
	self.DataTimers[1][1] = nil
	self.DataTimers[2][1] = nil
	self.DataTimers[3][1] = nil
end
function MPR_LKTimers:Quake()
	self.QuakeCount = self.QuakeCount + 1
	self.DataTimers[2][1] = self.QuakeCount == 1 and 26 or nil
	self.DataTimers[3][1] = self.QuakeCount == 1 and 44 or 32
	self.DataTimers[4][1] = self.QuakeCount == 2 and 20 or nil
	
	self.Label2:Show() -- Show Defile label
end
function MPR_LKTimers:FuryOfFrostmourne()
	self:Reset()
end
function MPR_LKTimers:Reset()
	self.QuakeCount = 0
	self.ValkyrCount = 0
	self.DataTimers[1][1] = nil
	self.DataTimers[2][1] = nil
	self.DataTimers[3][1] = nil
	self.DataTimers[4][1] = nil
end
function MPR_LKTimers:EncounterStart()
	self:Reset()
	if GetInstanceDifficulty() > 2 then -- Heroic
		self.Label2:Hide() -- Hide Defile label
		self.DataTimers[1][1] = 30
	end
end

MPR_LKTimers_Updater = CreateFrame("frame", "MPR LK Timers (Updater)", UIParent)
MPR_LKTimers_Updater.Interval = 0.1
MPR_LKTimers_Updater.LastUpdate = 0
MPR_LKTimers_Updater:SetScript("OnUpdate", function(self, elapsed)
	if GetSubZoneText() ~= "The Frozen Throne" and GetSubZoneText() ~= "Frostmourne" then
		return
	end
	
	MPR_LKTimers_Updater.LastUpdate = MPR_LKTimers_Updater.LastUpdate + elapsed
	if MPR_LKTimers_Updater.LastUpdate < MPR_LKTimers_Updater.Interval then return end
	local diff = MPR_LKTimers_Updater.LastUpdate
	MPR_LKTimers_Updater.LastUpdate = 0
	
	if MPR_LKTimers.IgnoreSubZoneTimer then 
		MPR_LKTimers.IgnoreSubZoneTimer = MPR_LKTimers.IgnoreSubZoneTimer - diff
		if MPR_LKTimers.IgnoreSubZoneTimer <= 0 then MPR_LKTimers.IgnoreSubZoneTimer = nil end
	end
	-- Check if player left Frostmourne
	if MPR_LKTimers.InFrostmourne and not MPR_LKTimers.IgnoreSubZoneTimer and GetSubZoneText() ~= "Frostmourne" then
		MPR_LKTimers.InFrostmourne = nil
	end
	
	for i=1,4 do
		-- DataTimer = {1 => Timer,  2 => Paused, 3 => PauseInFrostmourne}
		local DataTimer = MPR_LKTimers.DataTimers[i]
		if not MPR_LKTimers.InFrostmourne or not DataTimer[3] then
			if DataTimer[2] then DataTimer[2] = nil end
			if DataTimer[1] and DataTimer[1] > 0 then
				DataTimer[1] = DataTimer[1] - diff
				if DataTimer[1] < 0 then DataTimer[1] = 0 end
			end
		else
			if not DataTimer[2] then DataTimer[2] = true end
		end
	end
	
	MPR_LKTimers:OnUpdate(diff)
end)

MPR_LKTimers_Options = CreateFrame("Frame", "MPR LK Timers (Options)")
function MPR_LKTimers_Options:Initialize()
	MPR_LKTimers_Options:Hide()
	MPR_LKTimers_Options:SetBackdrop(MPR.Settings["BACKDROP"])
	MPR_LKTimers_Options:SetBackdropColor(unpack(MPR.Settings["BACKDROPCOLOR"]))
	MPR_LKTimers_Options:SetBackdropBorderColor(MPR.Settings["BACKDROPBORDERCOLOR"].R/255, MPR.Settings["BACKDROPBORDERCOLOR"].G/255, MPR.Settings["BACKDROPBORDERCOLOR"].B/255)
	MPR_LKTimers_Options:SetPoint("CENTER",UIParent)
	MPR_LKTimers_Options:SetWidth(250)
	MPR_LKTimers_Options:SetHeight(56)
	MPR_LKTimers_Options:EnableMouse(true)
	MPR_LKTimers_Options:SetMovable(true)
	MPR_LKTimers_Options:RegisterForDrag("LeftButton")
	MPR_LKTimers_Options:SetUserPlaced(true)
	MPR_LKTimers_Options:SetScript("OnDragStart", function(self) MPR_LKTimers_Options:StartMoving() end)
	MPR_LKTimers_Options:SetScript("OnDragStop", function(self) MPR_LKTimers_Options:StopMovingOrSizing() end)
	MPR_LKTimers_Options:SetFrameStrata("FULLSCREEN_DIALOG")

	MPR_LKTimers_Options.Title = MPR_LKTimers_Options:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	MPR_LKTimers_Options.Title:SetPoint("TOP", 0, -8)
	MPR_LKTimers_Options.Title:SetTextColor(190/255, 190/255, 190/255)
	MPR_LKTimers_Options.Title:SetText("|cff"..MPR.Colors["TITLE"].."MP Reporter|r - LK Timers")
	MPR_LKTimers_Options.Title:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
	MPR_LKTimers_Options.Title:SetShadowOffset(1, -1)

	MPR_LKTimers_Options.CloseButton = CreateFrame("button","BtnClose", MPR_LKTimers_Options, "UIPanelButtonTemplate")
	MPR_LKTimers_Options.CloseButton:SetHeight(14)
	MPR_LKTimers_Options.CloseButton:SetWidth(14)
	MPR_LKTimers_Options.CloseButton:SetPoint("TOPRIGHT", -8, -8)
	MPR_LKTimers_Options.CloseButton:SetText("x")
	MPR_LKTimers_Options.CloseButton:SetScript("OnClick", function(self) MPR_LKTimers_Options:Hide() end)
	
	-- ...
end