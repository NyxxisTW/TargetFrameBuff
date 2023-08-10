local lOriginal_TargetDebuffButton_Update = nil;
local TARGETFRAMEBUFF_MAX_TARGET_BUFFS = 32;
local TARGETFRAMEBUFF_MAX_TARGET_DEBUFFS = 24;


local function TargetFrameBuff_Anchor(num)
	if (num > 20) then
		return 21
	elseif (num > 16) then
		return 17
	elseif (num > 12) then
		return 13
	elseif (num > 8) then
		return 9
	elseif (num > 4) then
		return 5
	end
	return 1
end


local function TargetFrameBuff_FixDefaultFrames()
	TargetFrameBuff5:SetPoint("TOPLEFT", TargetFrameBuff1, "BOTTOMLEFT", 0, -2)

	for i = 1, TARGETFRAMEBUFF_MAX_TARGET_DEBUFFS do
		local button = getglobal("TargetFrameDebuff"..i)
		local border = getglobal("TargetFrameDebuff"..i.."Border")
		button:SetWidth(21)
		button:SetHeight(21)
		border:SetWidth(23)
		border:SetHeight(23)
	end
end

local function IsNewLineCondition(value, conditions)
	for i = 1, table.getn(conditions) do
		if (conditions[i] == value) then
			return true
		end
	end
	return false
end


local function UpdateBuffFrameLayout(frameType, newLineConditions)
	local max = 0
	if (frameType == "Buff") then
		max = TARGETFRAMEBUFF_MAX_TARGET_BUFFS
	elseif (frameType == "Debuff") then
		max = TARGETFRAMEBUFF_MAX_TARGET_DEBUFFS
	end
	local steps = 1
	for i = 2, max do
		local button = getglobal("TargetFrame"..frameType..i)
		local border = getglobal("TargetFrame"..frameType..i.."Border")
		local relativeButton = nil
		if (IsNewLineCondition(i, newLineConditions)) then
			relativeButton = getglobal("TargetFrame"..frameType..i - steps)
			steps = 1
			button:ClearAllPoints()
			button:SetPoint("TOPLEFT", relativeButton, "BOTTOMLEFT", 0, -2)
		else
			relativeButton = getglobal("TargetFrame"..frameType..i - 1)
			button:ClearAllPoints()
			button:SetPoint("LEFT", relativeButton, "RIGHT", 3, 0)
			steps = steps + 1
		end
	end
end


local function TargetFrameBuff_Update()
	local num_buff = 0
	local num_debuff = 0
	local button, buff
	for i = 1, TARGETFRAMEBUFF_MAX_TARGET_BUFFS do
		buff = UnitBuff("target", i)
		button = getglobal("TargetFrameBuff"..i)
		if (buff) then
			getglobal("TargetFrameBuff"..i.."Icon"):SetTexture(buff)
			button:Show()
			button.id = i
			num_buff = i
		else
			button:Hide()
		end
	end

	for i = 1, TARGETFRAMEBUFF_MAX_TARGET_DEBUFFS do
		local debuff, debuffApplications, debuffType = UnitDebuff("target", i)
		button = getglobal("TargetFrameDebuff"..i)
		if (debuff ~= nil) then

			local debuffBorder = getglobal("TargetFrameDebuff"..i.."Border")
			if debuffType == nil then
				debuffBorder:SetVertexColor(1, 0, 0)
			else
				local color = DebuffTypeColor[debuffType]
				debuffBorder:SetVertexColor(color.r, color.g, color.b)
			end
			
			local debuffCount = getglobal("TargetFrameDebuff"..i.."Count")
			if (debuffApplications > 1) then
				debuffCount:SetText(debuffApplications)
				debuffCount:Show()
			else
				debuffCount:Hide()
			end
			getglobal("TargetFrameDebuff"..i.."Icon"):SetTexture(debuff)
			button:Show()
			button.id = i
			num_debuff = i
		else
			button:Hide()
		end
	end
	
	local cTop = { 5, 9, 13, 23 }
	local cBottom = { 11, 21, 31 }

	-- Position buffs depending on whether the targeted unit is friendly or not
	if (UnitIsFriend("player", "target")) then
		TargetFrameBuff1:ClearAllPoints()
		TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, 32)
		TargetFrameDebuff1:ClearAllPoints()
		TargetFrameDebuff1:SetPoint("TOPLEFT", "TargetFrameBuff"..TargetFrameBuff_Anchor(num_buff), "BOTTOMLEFT", 0, -2)

		UpdateBuffFrameLayout("Buff", cTop)
		UpdateBuffFrameLayout("Debuff", cBottom)
	else
		TargetFrameDebuff1:ClearAllPoints()
		TargetFrameDebuff1:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, 32)
		TargetFrameBuff1:ClearAllPoints()
		TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff"..TargetFrameBuff_Anchor(num_debuff), "BOTTOMLEFT", 0, -2)

		UpdateBuffFrameLayout("Debuff", cTop)
		UpdateBuffFrameLayout("Buff", cBottom)
	end
end


local function TargetFrameBuff_OnLoad()
	lOriginal_TargetDebuffButton_Update	= TargetDebuffButton_Update
	TargetDebuffButton_Update = TargetFrameBuff_Update
	TargetFrameBuff_FixDefaultFrames()
end
TargetFrameBuff_OnLoad()