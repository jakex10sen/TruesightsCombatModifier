
TCM = LibStub("AceAddon-3.0"):NewAddon("TCM", "AceConsole-3.0", "AceComm-3.0", "AceSerializer-3.0");
local AceGUI = LibStub("AceGUI-3.0");

function TCM:OnInitialize()
    TCM:InitDB();
    TCM:RegisterChatCommand("tcm", "SlashCmds");
    TCM:InitComms();
    TCM:InitButton();
end

function TCM:OnEnable()
    
end

function TCM:OnDisable()
    
end

function TCM:InitButton()
    TCM.BtnFrame = CreateFrame("Frame", "BtnFrame", UIParent);
    TCM.BtnFrame:SetMovable(true);
    TCM.BtnFrame:EnableMouse(true);
    TCM.BtnFrame:RegisterForDrag("LeftButton");
    TCM.BtnFrame:SetScript("OnDragStart", TCM.BtnFrame.StartMoving);
    TCM.BtnFrame:SetScript("OnDragStop", TCM.BtnFrame.StopMovingOrSizing);

    -- The code below makes the frame visible, and is not necessary to enable dragging.
    TCM.BtnFrame:SetPoint("CENTER");
    TCM.BtnFrame:SetWidth(50);
    TCM.BtnFrame:SetHeight(100);
    local tex = TCM.BtnFrame:CreateTexture("ARTWORK");
    tex:SetAllPoints();
    tex:SetTexture(1.0, 0.5, 0); tex:SetAlpha(0.5);
    
    local BeginBtn = CreateFrame("Button", "BeginBtn", TCM.BtnFrame, "UIPanelButtonTemplate");
    BeginBtn:SetWidth(50);
    BeginBtn:SetHeight(25);
    BeginBtn:SetPoint("TOPLEFT");
    BeginBtn:SetMovable(true);
    BeginBtn:SetText("begin");
    BeginBtn:RegisterForClicks("AnyUp");
    BeginBtn:SetScript("OnClick", function()
        TCM:BeginCmd();
    end);

    local AttackBtn = CreateFrame("Button", "AttackBtn", TCM.BtnFrame, "UIPanelButtonTemplate");
    AttackBtn:SetWidth(50);
    AttackBtn:SetHeight(25);
    AttackBtn:SetPoint("LEFT");
    AttackBtn:SetMovable(true);
    AttackBtn:SetText("attack");
    AttackBtn:RegisterForClicks("AnyUp");
    AttackBtn:SetScript("OnClick", function()
        if not UnitName("target") then
            TCM:Print("No target found");
        else
            TCM:AttackCmd(UnitName("target"));
        end
    end);

    local HealBtn = CreateFrame("Button", "HealBtn", TCM.BtnFrame, "UIPanelButtonTemplate");
    HealBtn:SetWidth(50);
    HealBtn:SetHeight(25);
    HealBtn:SetPoint("BOTTOMLEFT");
    HealBtn:SetMovable(true);
    HealBtn:SetText("heal");
    HealBtn:RegisterForClicks("AnyUp");
    HealBtn:SetScript("OnClick", function()
        if not UnitName("target") then
            TCM:Print("No target found");
        else
            TCM:HealCmd(UnitName("target"));
        end

    end);

    TCM.BtnFrame:Hide();
end

-- UI functions --
function TCM:LoadUI(number)
    
    TCM.BattleFrame = CreateFrame("Frame", "BattleFrame", UIParent);
    TCM.BattleFrame:SetMovable(true);
    TCM.BattleFrame:EnableMouse(true);
    TCM.BattleFrame:RegisterForDrag("LeftButton");
    TCM.BattleFrame:SetScript("OnDragStart", TCM.BattleFrame.StartMoving);
    TCM.BattleFrame:SetScript("OnDragStop", TCM.BattleFrame.StopMovingOrSizing);


    -- The code below makes the frame visible, and is not necessary to enable dragging.
    TCM.BattleFrame:SetPoint("CENTER");
    TCM.BattleFrame:SetWidth(100);
    TCM.BattleFrame:SetHeight(100);
    local tex = TCM.BattleFrame:CreateTexture("ARTWORK");
    tex:SetAllPoints();
    tex:SetTexture(1.0, 0.5, 0); tex:SetAlpha(0.5);

    TCM.BattleFrame.StatusBars = {};
    if IsInGroup() then
        for i=1, GetNumGroupMembers() do
            local name = GetRaidRosterInfo(i);
            TCM:AddPlayerBar(name);
        end
        for i=1, number do
            TCM:AddBadGuyBar(i);
        end
        print(TCM:tablelength(TCM.BattleFrame.StatusBars));
    else
        TCM:Print("Not in group");
    end
end

function TCM:AddPlayerBar(name)
    TCM.BattleFrame.StatusBars[name] = CreateFrame("StatusBar", name, TCM.BattleFrame);
    TCM.BattleFrame.StatusBars[name]:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    TCM.BattleFrame.StatusBars[name]:GetStatusBarTexture():SetHorizTile(false);
    TCM.BattleFrame.StatusBars[name]:SetMinMaxValues(0, 6);
    TCM.BattleFrame.StatusBars[name]:SetWidth(100);
    TCM.BattleFrame.StatusBars[name]:SetHeight(10);
    TCM.BattleFrame.StatusBars[name]:SetPoint("TOP", TCM.BattleFrame, "CENTER", 0, (TCM:tablelength(TCM.BattleFrame.StatusBars)+1) * 10);
    TCM.BattleFrame.StatusBars[name]:SetStatusBarColor(0,1,0);
end

function TCM:AddBadGuyBar(number)
    local index = "BadGuy" .. number;
    TCM.BattleFrame.StatusBars[index] = CreateFrame("StatusBar", index, TCM.BattleFrame);
    TCM.BattleFrame.StatusBars[index]:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    TCM.BattleFrame.StatusBars[index]:GetStatusBarTexture():SetHorizTile(false);
    TCM.BattleFrame.StatusBars[index]:SetMinMaxValues(0, 100);
    TCM.BattleFrame.StatusBars[index]:SetWidth(100);
    TCM.BattleFrame.StatusBars[index]:SetHeight(10);
    TCM.BattleFrame.StatusBars[index]:SetPoint("TOP", TCM.BattleFrame, "CENTER", 0, (TCM:tablelength(TCM.BattleFrame.StatusBars)+1) * 10);
    TCM.BattleFrame.StatusBars[index]:SetStatusBarColor(1,0,0);
end

function TCM:UpdateUI()
    TCM:Print(TCM.BattleFrame:GetNumChildren());
    TCM:Print(TCM.BattleFrame:GetNumRegions());
end

function TCM:ConfgUI()

    -- Config Frame --
    TCM.ConfigScreen = AceGUI:Create("Frame");
    TCM.ConfigScreen:SetCallback("OnClose",function(widget)
        AceGUI:Release(widget);
    end);
    TCM.ConfigScreen:SetTitle("Event Config");
    TCM.ConfigScreen:SetLayout("List");

    -- Label for number of enemies --
    TCM.ConfigScreen.NumEnemyLabel = AceGUI:Create("Label");
    TCM.ConfigScreen.NumEnemyLabel:SetText("Number of enemies");
    TCM.ConfigScreen:AddChild(TCM.ConfigScreen.NumEnemyLabel);

    -- EditBox for number of enemies --
    TCM.ConfigScreen.EnemyNumEditBox = AceGUI:Create("EditBox");

    TCM.ConfigScreen:AddChild(TCM.ConfigScreen.EnemyNumEditBox);


    -- Submit button --
    TCM.ConfigScreen.SubmitBtn = AceGUI:Create("Button");
    TCM.ConfigScreen.SubmitBtn:SetText("Apply");
    TCM.ConfigScreen.SubmitBtn:SetCallback("OnClick", function(widget)
        --TCM:Print("Num enemies: " .. TCM.ConfigScreen.EnemyNumEditBox:GetText());
        TCM:LoadUI(tonumber(TCM.ConfigScreen.EnemyNumEditBox:GetText()));
    end);

    TCM.ConfigScreen:AddChild(TCM.ConfigScreen.SubmitBtn);


end

-- init functions --
function TCM:InitDB()
    if self.db then
        TCM:Print("DB already exists");
    else
        self.db = LibStub("AceDB-3.0"):New("TruesightsCombatModifierDB");
    end
end

function TCM:InitComms()
    
    TCM:RegisterComm("attack", "HandleAttackFunc");
    TCM:RegisterComm("heal", "HandleHealFunc");
    TCM:RegisterComm("begin", "HandleBeginFunc");
end

function TCM:InitBadGuys(number)
    self.db.char.BadGuys = {};
    for i=0,number do
        self.db.char.BadGuys[i] = {};
        self.db.char.BadGuys[i].health = 4;
    end
end
--Comm handlers --
function TCM:HandleHealFunc(prefix, message, distribution, sender)
    -- TCM:heal(tonumber(message));
    TCM:MessageReceived(prefix, message, distribution, sender);
end

function TCM:HandleAttackFunc(prefix, message, distribution, sender)
    if not sender == UnitName("player") then
        local success, from, damage, target = TCM:Deserialize(message);
        if success then
            if target == UnitName("player") then
                TCM:Print(from  .. " hit " .. target .. " for " .. damage .. " points of damage you are now at " .. self.db.char.Character.health);
                SendChatMessage(from  .. " hit you for " .. damage .. " points of damage you are now at " .. self.db.char.Character.health, "RAID");
                TCM:TakeDamage(tonumber(tonumber(damage)));
            end
        end
    end
end

function TCM:HandleBeginFunc(prefix, message, distribution, sender)
    TCM:begin();
    TCM:MessageReceived(prefix, message, distribution, sender);
end

function TCM:MessageReceived(prefix, message, distribution, sender)
    SendChatMessage("'" .. message .. "' recieved from '" .. sender .. "' via " .. distribution .. " prefixed with " .. prefix, "RAID");
    -- TCM:Print("'" .. message .. "' recieved from '" .. sender .. "' via " .. distribution .. " prefixed with " .. prefix);
end

-- combat actions --
function TCM:begin()
    self.db.char.Character = {};
    self.db.char.Character.maxhealth = 6;
    self.db.char.Character.health = 6;
    self.db.char.Character.heal = 20;
    self.db.char.Character.attack = 20;
end

function TCM:TakeDamage(amount)
    if(self.db.char.Character.health - amount <=0) then
        self.db.char.Character.health = 0;
    else
        self.db.char.Character.health = self.db.char.Character.health - amount;
    end
end


function TCM:Attack(target)
    local attack = math.random(self.db.char.Character.attack);
    if attack <= 2 then
        TCM:Print("Epic Fail. AKA, Take 2 damage from " .. target);
        TCM:TakeDamage(2);
        return 0;
    elseif attack <= 7 then
        TCM:Print("Fail. Take 1 damage from " .. target);
        TCM:TakeDamage(1);
        return 0;
    elseif attack <= 11 then
        TCM:Print("WHIFF! You dodged " .. target .. "'s incoming attack!");
        return 0;
    elseif attack <= 14 then
        TCM:Print("-small whack- .5 damage to " .. target);
        return 0.5;
    elseif attack <= 17 then
        TCM:Print("-WHACK- Hit that enemy! 1 damage to " .. target);
        return 1;
    elseif attack <= 19 then
        TCM:Print("-CRIT- A critical strike! 2 damage to " .. target);
        return 2;
    elseif attack == 20 then
        TCM:Print("-SUPA CRIT- 4 damage to " .. target);
        return 4;
    else
        TCM:Print("Something odd happened and you roll > 20 or < 1");
        return 0;
    end
end

function TCM:heal(heal)
    if(self.db.char.Character.health + heal >= self.db.char.Character.maxhealth)then
        self.db.char.Character.health = self.db.char.Character.maxhealth;
    else
        self.db.char.Character.health = self.db.char.Character.health + heal;
    end
    TCM:UpdateUI();
end

-- slash command handlers --
function TCM:BeginCmd()
    TCM:begin();
    if(UnitIsGroupLeader("player"))then
        TCM:ConfgUI();
        TCM:SendCommMessage("begin", "begin", "RAID");
    else
        TCM:Print("You aren't the leader");
    end
end

function TCM:HealCmd(target)
    if self.db.char.Character.health then
        local heal = math.random(self.db.char.Character.heal);
        TCM:heal(heal);
        TCM:Print("Heal: " .. heal);
        TCM:Print("Healh: " .. self.db.char.Character.health);
        
        TCM:SendCommMessage("heal", tostring(heal), "WHISPER", target);
    else
        TCM:Print("use must start a battle with /tcm begin first");
    end 
end

function TCM:AttackCmd(target)
    if self.db.char.Character.health then
        local player = UnitName("player");
        local damage = TCM:Attack(target);
        local targetPlayer = target;
        if damage > 0 then
            local data = TCM:Serialize(player, damage, targetPlayer);
            TCM:SendCommMessage("attack", data, "RAID");
        end
    else
        TCM:Print("use must start a battle with /tcm begin first");
    end
end

function TCM:SlashCmds(input)
    if(input == "attack")then
        TCM:AttackCmd(UnitName("target"));
    elseif(input == "heal")then
        TCM:HealCmd(UnitName("target"));
    elseif(input == "begin")then
        TCM:BeginCmd();
    elseif(input == "health")then
        SendChatMessage("Health: " .. self.db.char.Character.health, "RAID");
    else
        if(TCM.BtnFrame:IsShown())then
            TCM.BtnFrame:Hide();
        else
            TCM.BtnFrame:Show();
        end

    end
end
function TCM:tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end