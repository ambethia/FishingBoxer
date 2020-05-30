local ADDON, NS = ...
local FRAME = CreateFrame("Frame", ADDON .. "Frame")

FRAME:SetScript(
  "OnEvent",
  function(self, event, ...)
    if self[event] then
      return self[event](self, ...)
    end
  end
)

FRAME:SetSize(320, 320)
FRAME:SetPoint("CENTER", 0, 0)
FRAME.texture = FRAME:CreateTexture(nil, "BACKGROUND")
FRAME.texture:SetAllPoints(FRAME)
FRAME.texture:SetColorTexture(1, 0, 0)
FRAME.mask = FRAME:CreateMaskTexture()
FRAME.mask:SetTexture("Interface\\Addons\\" .. ADDON .. "\\mask.tga")
FRAME.mask:SetAllPoints(FRAME)
FRAME.texture:AddMaskTexture(FRAME.mask)

function FRAME:PLAYER_ENTERING_WORLD()
  FRAME:Disable()
end
FRAME:RegisterEvent("PLAYER_ENTERING_WORLD")

function FRAME:UNIT_SPELLCAST_CHANNEL_START(unit)
  if unit == "player" then
    local name, _, _, startTime, endTime = UnitChannelInfo(unit)
    if name == "Fishing" then
      self.fishing = true
      self.texture:SetColorTexture(0, 0.5, 0)
      self.value = ((endTime / 1000) - GetTime())
      self.maxValue = (endTime - startTime) / 1000
    end
  end
end

function FRAME:UNIT_SPELLCAST_CHANNEL_STOP(unit)
  if unit == "player" then
    FRAME.texture:SetColorTexture(1, 0, 0)
    self.fishing = false
  end
end

function FRAME:HandleUpdate(elapsed)
  if self.fishing then
    self.value = self.value - elapsed
    self.texture:SetColorTexture(1 - PercentageBetween(self.value, 0, self.maxValue), 0.5, 0)
  end
end

function FRAME:Enable()
  self:Show()
  self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
  self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
  self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
  self:SetScript("OnUpdate", self.HandleUpdate)
end

function FRAME:Disable()
  self:Hide()
  self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
  self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
  self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
  self:SetScript("OnUpdate", nil)
end

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
ldb:NewDataObject(
  ADDON,
  {
    type = "launcher",
    icon = "Interface\\Icons\\Trade_Fishing",
    OnClick = function(clickedframe, button)
      if FRAME:IsVisible() then
        FRAME:Disable()
      else
        FRAME:Enable()
      end
    end
  }
)
