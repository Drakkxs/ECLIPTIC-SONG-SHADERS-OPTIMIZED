BFAltAnim = false
DadAltAnim = false
Posing = false

SingAnims = {
    'singLEFT',
    'singDOWN',
    'singUP',
    'singRIGHT'
}

function setPoseMode(enabled)
    if posing == enabled then
        return
    end

    if enabled then
        runHaxeCode([[
            if (!game.variables.exists('AEMOriginalKeysArray')) {
                game.variables.set('AEMOriginalKeysArray', game.keysArray.copy());
            }

            game.keysArray = [
            'AEM_pose_left',
            'AEM_pose_down',
            'AEM_pose_up',
            'AEM_pose_right'
            ]
        ]])
    else
        runHaxeCode([[
            var original = game.variables.get('AEMOriginalKeysArray');

            if (original != null)
                game.keysArray = original.copy();
        ]])
    end
end

local poseInputs = {
    'left',
    'down',
    'up',
    'right'
}



function sendToAll(type, message)
    --sendMessageTo(getPlayerSelfSID(), tostring(type), tostring(message))
    local allPlayers = listPlayers()
    --table.insert(allPlayers, getPlayerSelfSID())
    for _, sid in pairs(allPlayers) do
        sendMessageTo(sid, type, message)
    end
end



function onUpdatePost(elapsed)
    --sendToAll('Test', 'Test')
    if keyboardJustPressed('R') then
        if playsAsBF() then
            sendToAll('BFAltAnim', not BFAltAnim)
        else
            sendToAll('DadAltAnim', not DadAltAnim)
        end
    end

    --if keyboardPressed('SHIFT') then
    --    if playsAsBF() then
    --        bf.stunned = true
    --    end
    --end
    
    --sendMessageTo(getPlayerSelfSID(), 'Test', 'Test')
end

function onCustomMessage(sid, message)
    if message[1] == 'BFAltAnim' then
        BFAltAnim = message[2]
    elseif message[1] == 'DadAltAnim' then
        DadAltAnim = message[2]
    end

    if message[1] == 'AEMPoseAnimboyfriend' then
        playAnim('boyfriend', message[2], true)
        return
    end
    if message[1] == 'AEMPoseAnimdad' then
        playAnim('dad', message[2], true)
        return
    end
end

--function onMessageNoteHit(sid, message)
--    local isOnBFSide = getPlayer(sid).bfSide
--end

local function contains(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true
        end
    end
    return false
end

function onMessageCharPlay(sid, message)
    local isOnBFSide = getPlayer(sid).bfSide




    local useAlt =
        (isOnBFSide and BFAltAnim) or
        (not isOnBFSide and DadAltAnim)

    if useAlt and contains(SingAnims, message[1]) then
        local altAnim = message[1] .. '-alt'
        -- Play our replacement animation
        if isOnBFSide then
            playAnim('boyfriend', altAnim, true)
        else
            playAnim('dad', altAnim, true)
        end

        -- Prevent Psych Online from immediately playing
        -- the original non-alt animation afterward
        return Function_Stop
    end

end



function onNoteHit(noteData)
    local useAlt

    

    if playsAsBF() then
        useAlt = BFAltAnim
    else
        useAlt = DadAltAnim
    end

    if not useAlt then
        return
    end

   

    local anim = SingAnims[noteData + 1] .. '-alt'

    local character

    if playsAsBF() then
        character = 'boyfriend'
    else
        character = 'dad'
    end

    playAnim(character, anim, true)
end

function goodNoteHit(id, noteData, noteType, isSustain)
    if (playsAsBF() and #listPlayers() == 1) or #listPlayers() > 1 then
        onNoteHit(noteData)
    end

end

function opponentNoteHit(id, noteData, noteType, isSustain)
    if (not playsAsBF() and #listPlayers() == 1) or #listPlayers() > 1 then
        onNoteHit(noteData)
    end
end


function playSelfPose(anim)
    local character = playsAsBF() and 'boyfriend' or 'dad'

    --if hasAnimation(character, anim) then
        playAnim(character, anim, true)

        
        sendToAll('AEMPoseAnim' .. character, anim)
    --end
end

function checkPoseInputs()
    for i = 1, 4 do
        if keyJustPressed(poseInputs[i]) then
            local anim = SingAnims[i]

            local useAlt

            
            if playsAsBF() then
                useAlt = BFAltAnim
            else
                useAlt = DadAltAnim
            end


            if useAlt then
                anim = anim .. '-alt'
            end

            playSelfPose(anim)
        end
    end
end

function onUpdate(elapsed)
    local shiftHeld = keyboardPressed('SHIFT')
    setPoseMode(shiftHeld)
    if shiftHeld then
        checkPoseInputs()
    end
end

function onDestroy()
    runHaxeCode([[
        var original = game.variables.get('AEMOriginalKeysArray');

        if (original != null)
        {
            game.keysArray = original.copy();
            game.variables.remove('AEMOriginalKeysArray');
        }
    ]])
end