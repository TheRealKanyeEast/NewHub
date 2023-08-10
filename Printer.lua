local Workspace = game:GetService("Workspace");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Heartbeat = game:GetService("RunService").Heartbeat;
local RemoteEventPath = ReplicatedStorage:FindFirstChild("rbxts_include")["node_modules"]:FindFirstChild("@rbxts")["net"]["out"]._NetManaged;
local PlaceBlock = RemoteEventPath.CLIENT_BLOCK_PLACE_REQUEST;
local BlockHit = RemoteEventPath.CLIENT_BLOCK_HIT_REQUEST;

local library = {};

library.__index = library;

setmetatable(library, {
    __tostring = function()
        return "BlockPrinter";
    end
});

function library.new(first, last, block)
    return setmetatable({
        firstPos = first,
        lastPos = last,
        block = block,
        finish = false
    }, library);
end

function library:isBlocked(pos)
    local regParts = Workspace:FindPartsInRegion3(Region3.new(pos, pos), nil, math.huge);
    for _, v in pairs(regParts) do
        if v.Parent and v.Parent.Name == "Blocks" then
            return true
        end
    end
    return false;
end

function library:setFirst(first)
    self.firstPos = first;
end

function library:setLast(last)
    self.lastPos = last;
end

function library:setBlock(bvlock)
    self.block = bvlock;
end

function library:getBlock()
    return self.block;
end

function library:Print(teleportPlayer)
    local posMin = Vector3.new(math.min(self.firstPos.X, self.lastPos.X), math.min(self.firstPos.Y, self.lastPos.Y), math.min(self.firstPos.Z, self.lastPos.Z));
    local posMax = Vector3.new(math.max(self.firstPos.X, self.lastPos.X), math.max(self.firstPos.Y, self.lastPos.Y), math.max(self.firstPos.Z, self.lastPos.Z));
    for X = posMin.X, posMax.X, 3 do
        for Y = posMin.Y, posMax.Y, 3 do
            for Z = posMin.Z, posMax.Z, 3 do
                if self.finish then return end;
                local pos = Vector3.new(X, Y, Z);

                local mag = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - pos).magnitude;

                if mag > 24 then
                    teleportPlayer(pos);
                end

                if not self:isBlocked(pos) then
                    task.spawn(function()
                        PlaceBlock:InvokeServer({
                            ["upperSlab"] = false,
                            ["cframe"] = CFrame.new(pos),
                            ["QmadGjzayYoAekfqpllqlan"] = "\7\240\159\164\163\240\159\164\161\7\n\7\n\7\nnejzlhpBhskuqskhxjZoegLhCvb",
                            ["blockType"] = self.block
                        });
                    end)
                    Heartbeat:Wait();
                end
            end
        end
    end
end

function library:Shred(teleportPlayer)
    local posMin = Vector3.new(math.min(self.firstPos.X, self.lastPos.X), math.min(self.firstPos.Y, self.lastPos.Y), math.min(self.firstPos.Z, self.lastPos.Z));
    local posMax = Vector3.new(math.max(self.firstPos.X, self.lastPos.X), math.max(self.firstPos.Y, self.lastPos.Y), math.max(self.firstPos.Z, self.lastPos.Z));
    local reg = Region3.new(posMin, posMax);

    for _, v in pairs(Workspace:FindPartsInRegion3(reg, nil, math.huge)) do
        if self.finish then return end;

        if v.Name ~= "bedrock" and v.Parent and v.Parent.Name == "Blocks" and (not v:FindFirstChild("protal-to-spawn")) then
            repeat task.wait();
                if v ~= nil and v:IsDescendantOf(Workspace) then
                    local mag = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Position).magnitude;

                    if mag > 24 then
                        teleportPlayer(v.Position);
                    end
                    BlockHit:InvokeServer({
                        ["xJfikbvplSzbtyuOkbihsrifqttzttaspq"] = "\7\240\159\164\163\240\159\164\161\7\n\7\n\7\nnooZcLpu",
                        ["part"] = v,
                        ["block"] = v,
                        ["norm"] = v.Position
                    });
                end
                task.wait()
            until v == nil or (not v:IsDescendantOf(Workspace)) or self.finish == true;
        end
        --Heartbeat:Wait()
    end
end

return library;
