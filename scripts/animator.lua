BFAltAnim = false
DadAltAnim = false

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

    
    --sendMessageTo(getPlayerSelfSID(), 'Test', 'Test')
end

function onCustomMessage(sid, message)
    if message[1] == 'BFAltAnim' then
        BFAltAnim = message[2]
    elseif message[1] == 'DadAltAnim' then
        DadAltAnim = message[2]
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

    local anims = {
        'idle',
        'singUP',
        'singDOWN',
        'singLEFT',
        'singRIGHT'
    }


    local useAlt =
        (isOnBFSide and BFAltAnim) or
        (not isOnBFSide and DadAltAnim)

    if useAlt and contains(anims, message[1]) then
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

local singAnims = {
    'singLEFT',
    'singDOWN',
    'singUP',
    'singRIGHT'
}

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

   

    local anim = singAnims[noteData + 1] .. '-alt'

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
