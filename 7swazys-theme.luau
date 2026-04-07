local stagesFolder = game:GetService("Workspace"):FindFirstChild("Stages")
local checkpointsFolder = game:GetService("Workspace"):FindFirstChild("Checkpoints")

local activeFolder = nil
local folderType = nil

if stagesFolder then
    activeFolder = stagesFolder
    folderType = "Stages"
elseif checkpointsFolder then
    activeFolder = checkpointsFolder
    folderType = "Checkpoints"
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()


local glassTheme = {
    TextColor = Color3.fromRGB(192, 224, 255),
    NotificationTextColor = Color3.fromRGB(192, 224, 255),
    
    Background = Color3.fromRGB(18, 25, 45),
    Topbar = Color3.fromRGB(12, 18, 34),
    Shadow = Color3.fromRGB(0, 0, 0),
    NotificationBackground = Color3.fromRGB(18, 25, 45),
    NotificationActionsBackground = Color3.fromRGB(12, 18, 34),
    
    TabBackground = Color3.fromRGB(0, 0, 0),
    TabStroke = Color3.fromRGB(38, 50, 74),
    TabBackgroundSelected = Color3.fromRGB(0, 0, 0),
    TabTextColor = Color3.fromRGB(140, 174, 224),
    SelectedTabTextColor = Color3.fromRGB(59, 130, 246),
    
    ElementBackground = Color3.fromRGB(12, 18, 34),
    ElementBackgroundHover = Color3.fromRGB(20, 30, 50),
    SecondaryElementBackground = Color3.fromRGB(12, 18, 34),
    ElementStroke = Color3.fromRGB(56, 189, 248),
    SecondaryElementStroke = Color3.fromRGB(38, 50, 74),
    
    SliderBackground = Color3.fromRGB(30, 41, 59),
    SliderProgress = Color3.fromRGB(37, 99, 235),
    SliderStroke = Color3.fromRGB(56, 189, 248),
    
    ToggleBackground = Color3.fromRGB(12, 18, 34),
    ToggleEnabled = Color3.fromRGB(59, 130, 246),
    ToggleDisabled = Color3.fromRGB(156, 163, 175),
    ToggleEnabledStroke = Color3.fromRGB(59, 130, 246),
    ToggleDisabledStroke = Color3.fromRGB(75, 85, 99),
    ToggleEnabledOuterStroke = Color3.fromRGB(56, 189, 248),
    ToggleDisabledOuterStroke = Color3.fromRGB(75, 85, 99),
    
    DropdownSelected = Color3.fromRGB(12, 18, 34),
    DropdownUnselected = Color3.fromRGB(12, 18, 34),
    InputBackground = Color3.fromRGB(15, 20, 34),
    InputStroke = Color3.fromRGB(56, 189, 248),
}

local Window = Rayfield:CreateWindow({
   Name = "Auto-Obby & Rebirth",
   LoadingTitle = "7swazys · Auto-Obby",
   LoadingSubtitle = "glass ui · by TDX",
   Theme = glassTheme,
   Transparency = 0.75,
   ToggleUIKeybind = "K",
   ConfigurationSaving = { 
      Enabled = true,
      FolderName = "7swazys",
      FileName = "AutoObbySettings"
   }
})

local Tab = Window:CreateTab("Main", 4483362458)

local RebirthSection = Tab:CreateSection("Rebirth Tools")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rebirthRemote = ReplicatedStorage:FindFirstChild("Rebirth") or ReplicatedStorage:WaitForChild("Rebirth", 5)

Tab:CreateButton({
   Name = "REBIRTH NOW",
   Info = "Manually fires the Rebirth remote event.",
   Callback = function()
       if rebirthRemote then
           rebirthRemote:FireServer()
           Rayfield:Notify({
               Title = "Rebirth",
               Content = "Manual Rebirth Remote Fired!",
               Duration = 2,
               Image = 4483362458,
           })
       else
           Rayfield:Notify({
               Title = "Error",
               Content = "Rebirth Remote not found in ReplicatedStorage.",
               Duration = 3,
               Image = 4483362458,
           })
       end
   end,
})

local autoRebirth = false
local rebirthInterval = 15

Tab:CreateSlider({
   Name = "Auto Rebirth Speed",
   Info = "How often to auto rebirth",
   Range = {0.001, 60},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 15,
   Flag = "RebirthIntervalSlider",
   Callback = function(Value)
      rebirthInterval = Value
   end,
})

Tab:CreateToggle({
   Name = "Enable Auto Rebirth",
   CurrentValue = false,
   Flag = "AutoRebirth", 
   Callback = function(Value)
       autoRebirth = Value
       
       task.spawn(function()
           while autoRebirth do
               if rebirthRemote then
                   rebirthRemote:FireServer()
               end
               task.wait(rebirthInterval)
           end
       end)
   end,
})

local AutomationSection = Tab:CreateSection("Automation Settings")

local autoTeleport = false
local tpSpeed = 1 

local function getCurrentStage()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return 1 end
    
    local closestStage = 1
    local shortestDistance = math.huge
    
    if activeFolder then
        for _, cp in pairs(activeFolder:GetChildren()) do
            local stageNum = tonumber(cp.Name)
            if stageNum then
                local dist = (char.HumanoidRootPart.Position - cp.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestStage = stageNum
                end
            end
        end
    end
    return closestStage
end

Tab:CreateSlider({
   Name = "Teleport Speed",
   Info = "Lower = Faster | Higher = Safer",
   Range = {0.0001, 5},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 1,
   Flag = "TPSpeedSlider",
   Callback = function(Value)
      tpSpeed = Value
   end,
})

Tab:CreateToggle({
   Name = "Enable Auto-Teleport",
   CurrentValue = false,
   Flag = "AutoTP", 
   Callback = function(Value)
       autoTeleport = Value
       
       task.spawn(function()
           while autoTeleport do
               local current = getCurrentStage()
               local nextStage = tostring(current + 1)
               local target = activeFolder and activeFolder:FindFirstChild(nextStage)
               
               if target then
                   local char = game.Players.LocalPlayer.Character
                   if char and char:FindFirstChild("HumanoidRootPart") then
                       char.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                   end
               end
               task.wait(tpSpeed) 
           end
       end)
   end,
})

Tab:CreateSection("Manual Teleports")

if activeFolder then
    Tab:CreateParagraph({
        Title = "Detected Path",
        Content = "Using: Workspace." .. folderType
    })
    
    local stages = {}
    for _, child in pairs(activeFolder:GetChildren()) do
        table.insert(stages, child)
    end
    
    table.sort(stages, function(a, b) 
        local numA = tonumber(a.Name) or 0
        local numB = tonumber(b.Name) or 0
        return numA < numB
    end)
    
    if #stages > 0 then
        for _, stage in ipairs(stages) do
            Tab:CreateButton({
               Name = (folderType == "Stages" and "Stage " or "Checkpoint ") .. stage.Name,
               Callback = function()
                   local char = game.Players.LocalPlayer.Character
                   if char and char:FindFirstChild("HumanoidRootPart") then
                       char.HumanoidRootPart.CFrame = stage.CFrame + Vector3.new(0, 3, 0)
                   end
               end,
            })
        end
    else
        Tab:CreateParagraph({
            Title = "No Stages Found",
            Content = "No numbered stages found in Workspace." .. folderType
        })
    end
else
    Tab:CreateParagraph({
        Title = "No Folder Detected",
        Content = "Could not find Workspace.Stages or Workspace.Checkpoints"
    })
end

local CreditsTab = Window:CreateTab("Credits", 4483362458)

CreditsTab:CreateSection("Join for Updates")

CreditsTab:CreateButton({
   Name = "Copy Discord Invite",
   Info = "Click to copy discord.gg/QkAZwuEYgP",
   Callback = function()
       setclipboard("https://discord.gg/QkAZwuEYgP")
       Rayfield:Notify({
           Title = "Discord Copied!",
           Content = "Invite link copied to clipboard",
           Duration = 3,
           Image = 4483362458,
       })
   end,
})

CreditsTab:CreateParagraph({
   Title = "Discord Server",
   Content = "Join our Discord for script updates, support, and announcements!\n\nServer: discord.gg/QkAZwuEYgP"
})

Rayfield:Notify({
   Title = "7swazys · Glass UI",
   Content = "Auto-Obby & Rebirth loaded with custom theme",
   Duration = 3,
})
