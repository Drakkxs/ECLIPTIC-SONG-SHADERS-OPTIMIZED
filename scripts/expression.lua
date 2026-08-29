Posing = false

BFAltAnim = false

DadAltAnim = false

SingAnims = {
    'singLEFT',
    'singDOWN',
    'singUP',
    'singRIGHT'
}

local poseInputs = {
    'left',
    'down',
    'up',
    'right'
}

local function sideUsesAlt(side)
    if side == 'BF' then
        return BFAltAnim
    else
        return DadAltAnim
    end
end


function sendToAll(type, message)
    --sendMessageTo(getPlayerSelfSID(), tostring(type), tostring(message))
    local allPlayers = listPlayers()
    --table.insert(allPlayers, getPlayerSelfSID())
    for _, sid in pairs(allPlayers) do
        sendMessageTo(sid, type, message)
    end
end

local function contains(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true
        end
    end

    return false
end

function playSidePose(side, anim)
    local character = sideCharacter(side)

    playAnim(character, anim, true)

    setProperty(character .. '.specialAnim', true)
end

function applyIdleAlt(side)
    local enabled = sideUsesAlt(side)

    setVar('AEMIdleAltSide', side)
    setVar('AEMIdleAltEnabled', enabled)

    runHaxeCode([[
        var side:String = game.variables.get('AEMIdleAltSide');
        var enabled:Bool = game.variables.get('AEMIdleAltEnabled');

        var char = side == 'BF'
            ? game.boyfriend
            : game.dad;

        if (char == null)
            return;

        var suffix:String = '';

        if (enabled)
        {
            // Determine whether this is normally a dancing character.
            var normallyDances:Bool =
                char.animOffsets.exists('danceLeft') &&
                char.animOffsets.exists('danceRight');

            if (normallyDances)
            {
                // Only use alt dancing if BOTH halves exist.
                if (
                    char.animOffsets.exists('danceLeft-alt') &&
                    char.animOffsets.exists('danceRight-alt')
                )
                {
                    suffix = '-alt';
                }
            }
            else if (char.animOffsets.exists('idle-alt'))
            {
                suffix = '-alt';
            }
        }

        char.idleSuffix = suffix;
        char.recalculateDanceIdle();

        // Change immediately if we're currently idle,
        // but don't interrupt singing or a special/pantomime animation.
        var currentAnim:String = char.getAnimationName();

        if (
            !currentAnim.startsWith('sing') &&
            !char.specialAnim
        )
        {
            char.dance();
        }
    ]])
end

function setAltState(side, enabled, broadcast)
    if side == 'BF' then
        BFAltAnim = enabled
        setVar('AEM_BF_ALT', enabled)
    else
        DadAltAnim = enabled
        setVar('AEM_DAD_ALT', enabled)
    end

    applyIdleAlt(side)

    if broadcast then
        sendToAll(side .. 'AltAnim', enabled)
    end
end


function selfSide()
    return playsAsBF() and 'BF' or 'Dad'
end

function sideCharacter(side)
    return side == 'BF' and 'boyfriend' or 'dad'
end




function setPoseMode(enabled)
    if Posing == enabled then
        return
    end

    Posing = enabled

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

function onCustomMessage(sid, message)
    if message[1] == 'BFAltAnim' then
        setAltState('BF', message[2], false)
        return
    elseif message[1] == 'DadAltAnim' then
        setAltState('Dad', message[2], false)
        return
    end

    if message[1] == 'AEMPoseAnimBF' then
        if not playsAsBF() then
            playSidePose('BF', message[2])
        end
        return
    end

    if message[1] == 'AEMPoseAnimDad' then
        if playsAsBF() then
            playSidePose('Dad', message[2])
        end
        return
    end
end

function onMessageCharPlay(sid, message)
    local player = getPlayer(sid)

    if player == nil then
        return
    end

    local side = player.bfSide and 'BF' or 'Dad'

    if not sideUsesAlt(side) then
        return
    end

    if contains(SingAnims, message[1]) then
        local altAnim = message[1] .. '-alt'

        playAnim(
            sideCharacter(side),
            altAnim,
            true
        )
        return Function_Stop
    end
end

function checkPoseInputs()
    for i = 1, 4 do
        if keyJustPressed(poseInputs[i]) then
            local side = selfSide()
            local anim = SingAnims[i]

            if sideUsesAlt(side) then
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

    if keyboardJustPressed('R') then
        local side = selfSide()

        setAltState(
            side,
            not sideUsesAlt(side),
            true
        )
    end
end

function playSelfPose(anim)
    local side = selfSide()

    playSidePose(side, anim)

    sendToAll('AEMPoseAnim' .. side, anim)
end


function onNoteHit(noteData)
    local side = selfSide()

    if not sideUsesAlt(side) then
        return
    end

    local anim = SingAnims[noteData + 1] .. '-alt'

    playAnim(sideCharacter(side), anim, true)
end


function goodNoteHit(id, noteData, noteType, isSustain)
    if playsAsBF() then
        onNoteHit(noteData)
    end
end

function opponentNoteHit(id, noteData, noteType, isSustain)
    if not playsAsBF() then
        onNoteHit(noteData)
    end
end