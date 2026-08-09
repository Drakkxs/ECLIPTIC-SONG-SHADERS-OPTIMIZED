UpScale = 1 / 0.3;

NotesHit = 0
HasMadeStar = false
BFLastHit = false
StarCount = 0
LineCount = 0

LastBFStarX = {}
LastBFStarY = {}

LastDadStarX = {}
LastDadStarY = {}

IntencityLevels = {}
ILBF = {}
ILD = {}

function createConstellationGroups()
    runHaxeCode([[
        var bfStars = new flixel.group.FlxSpriteGroup();
        var dadStars = new flixel.group.FlxSpriteGroup();

        game.add(bfStars);
        game.add(dadStars);

        game.variables.set('bfConstellationGroup', bfStars);
        game.variables.set('dadConstellationGroup', dadStars);
    ]])
end

function onCreate()

    addHaxeLibrary('Character', 'objects')
    addHaxeLibrary('FlxSpriteGroup', 'flixel.group')

    makeLuaSprite('bg', nil, -10000, -10000)
    makeGraphic('bg', 1, 1, '000000')
    scaleObject('bg', 20000, 20000)
    setScrollFactor('bg', 1, 1)
    addLuaSprite('bg', false)
    createConstellationGroups()

    makeLuaSprite('darkness', '3-starfilled_darkness/Gradient', -4000, -200)
    scaleObject('darkness', 40, 6);
    setScrollFactor('darkness', 0, 0)
    addLuaSprite('darkness', true)

    makeLuaSprite('floor', '3-starfilled_darkness/LandGradient', -800, 1000)
    scaleObject('floor', 400, 3);
    setScrollFactor('floor', 0, 1)
    addLuaSprite('floor', false)

end
function rgbToColor(r, g, b)
    r = math.floor(r)
    g = math.floor(g)
    b = math.floor(b)

    return r * 0x10000 + g * 0x100 + b
end

function getCharacterColor(character)
    return rgbToColor(
        getProperty(character .. '.healthColorArray[0]'),
        getProperty(character .. '.healthColorArray[1]'),
        getProperty(character .. '.healthColorArray[2]')
    )
end

function findClosestStar(x, y, side)
    local closestX = nil
    local closestY = nil
    local closestDistance = nil

    if side == 'bf' then
        for i = 1, #LastBFStarX do
            if LastBFStarX[i] ~= nil and LastBFStarY[i] ~= nil then
                local distance = math.abs(x - LastBFStarX[i]) + math.abs(y - LastBFStarY[i])
                if closestX == nil or distance < closestDistance then
                    closestX = LastBFStarX[i]
                    closestY = LastBFStarY[i]
                    closestDistance = distance
                end
            end
        end

    else
        for i = 1, #LastDadStarX do
            if LastDadStarX[i] ~= nil and LastDadStarY[i] ~= nil then
                local distance = math.abs(x - LastDadStarX[i]) + math.abs(y - LastDadStarY[i])
                if closestX == nil or distance < closestDistance then
                    closestX = LastDadStarX[i]
                    closestY = LastDadStarY[i]
                    closestDistance = distance
                end
            end
        end
    end

    return closestX, closestY, closestDistance



end

function createStarLine(x1, y1, x2, y2, side)
    local tag = 'AEMStarLine' .. StarCount

    x1 = x1 + 64
    y1 = y1 + 64
    x2 = x2 + 64
    y2 = y2 + 64

    local dx = x2 - x1
    local dy = y2 - y1

    local distance = math.sqrt(dx * dx + dy * dy)
    local angle = math.deg(math.atan2(dy, dx))

    makeLuaSprite(tag, nil, x1, y1)
    makeGraphic(tag, 1, 1, 'FFFFFF')

    -- Scale FIRST
    scaleObject(tag, distance, 7, false)

    -- THEN set the rotation origin, after scaleObject/updateHitbox
    setProperty(tag .. '.origin.x', 0)
    setProperty(tag .. '.origin.y', 0.5)

    setProperty(tag .. '.angle', angle)
    setScrollFactor(tag, 0, 0)

    if side == 'bf' then
        setProperty(tag .. '.color', getCharacterColor('boyfriend'))
    else
        setProperty(tag .. '.color', getCharacterColor('dad'))
    end

    setProperty(tag .. '.alpha', 0.5)

    addLuaSprite(tag, false)
    LineCount = LineCount + 1
end

function spawnStar(x, y, side)
    StarCount = StarCount + 1

    local tag = 'AEMStar' .. StarCount


    makeLuaSprite(tag, '3-starfilled_darkness/Star', 0, 0)
--
    local width = getProperty(tag .. '.width')
    local height = getProperty(tag .. '.height')
--
    setProperty(tag .. '.x', x - width / 2)
    setProperty(tag .. '.y', y - height / 2)

    if side == 'bf' then
        if LastBFStarX ~= {} then
            local newX, newY = findClosestStar(x, y, 'bf')
            if newX ~= nil and newY ~= nil then
                createStarLine(
                    newX,
                    newY,
                    x,
                    y,
                    'bf'
                )
            end
        end

        table.insert(LastBFStarX, x)
        table.insert(LastBFStarY, y)


    else
        if LastDadStarX ~= {} then
            local newX, newY = findClosestStar(x, y, 'dad')
            if newX ~= nil and newY ~= nil then
                createStarLine(
                    newX,
                    newY,
                    x,
                    y,
                    'dad'
                )
            end
        end

        table.insert(LastDadStarX, x)
        table.insert(LastDadStarY, y)
    end


    --makeLuaSprite(tag, '3-starfilled_darkness/Star', x, y)

    scaleObject(tag, 2, 2)

    setScrollFactor(tag, 0, 0)

    setProperty(tag .. '.alpha', 0)
    local defaultAngle = math.random(-180,180)
    setProperty(tag .. '.angle', defaultAngle)

    local groupName

    if side == 'bf' then
        groupName = 'bfConstellationGroup'
    else
        groupName = 'dadConstellationGroup'
    end

    if side == 'bf' then
        setProperty(tag .. '.color', getCharacterColor('boyfriend'))
    else
        setProperty(tag .. '.color', getCharacterColor('dad'))
    end


    addLuaSprite(tag, false)

    runHaxeCode([[
        var star = game.getLuaObject("]] .. tag .. [[");
        var group = game.variables.get("]] .. groupName .. [[");

        if (star != null && group != null)
            group.add(star);
    ]])

    local randScale = math.random(0.7, 1)
    doTweenX(tag .. 'ScaleX', tag .. '.scale', randScale, 1, 'bounceOut')
    doTweenY(tag .. 'ScaleY', tag .. '.scale', randScale, 1, 'bounceOut')

    doTweenAlpha(tag .. 'Alpha', tag, 1, 0.5, 'quadOut')

    local spinAmount = math.random(-180,180)
    doTweenAngle(tag .. 'Angle', tag, defaultAngle + spinAmount, 1, 'bounceOut')

    return StarCount

end

function BeatStar()
    for i = 1, StarCount do
        local useTime = (60 / curBpm) * 0.8
        local tag = 'AEMStar' .. i
        local OGScaleX = getProperty(tag .. '.scale.x')
        local OGScaleY = getProperty(tag .. '.scale.y')
        local OGAngle = getProperty(tag .. '.angle')
        if OGScaleX == nil or OGScaleY == nil or OGAngle == nil then
            goto continue
        end
        local StarIntencity = math.min(getVar('AEM_INTENCITY'), 1)
        setProperty(tag .. '.scale.x', OGScaleX * (1.05 + StarIntencity))
        setProperty(tag .. '.scale.y', OGScaleY * (1.05 + StarIntencity))
        local angleOptions = {-StarIntencity * 20, StarIntencity * 20}
        setProperty(tag .. '.angle', OGAngle + angleOptions[math.random(#angleOptions)])
        doTweenX(tag .. 'ScaleX', tag .. '.scale', OGScaleX, useTime, 'quadOut')
        doTweenY(tag .. 'ScaleY', tag .. '.scale', OGScaleY, useTime, 'quadOut')
        doTweenAngle(tag .. 'Angle', tag, OGAngle , useTime, 'quadOut')

        tag = 'AEMStarLine' .. i
        OGScaleY = getProperty(tag .. '.scale.y')
        if OGScaleY ~= nil then
            setProperty(tag .. '.scale.y', OGScaleY * (1.05 + StarIntencity))
            doTweenY(tag .. 'ScaleY', tag .. '.scale', OGScaleY, useTime, 'quadOut')
        end
        ::continue::
    end

end

function RemoveStar(starID, side)
    if starID == nil then
        return
    end

    local starTag = 'AEMStar' .. starID
    local lineTag = 'AEMStarLine' .. starID

    cancelTween(starTag .. 'ScaleX')
    cancelTween(starTag .. 'ScaleY')
    cancelTween(starTag .. 'Alpha')
    cancelTween(starTag .. 'Angle')

    cancelTween(lineTag .. 'ScaleY')
    cancelTween(lineTag .. 'Alpha')

    runHaxeCode([[
        var star = game.getLuaObject("]] .. starTag .. [[");

        if (star != null)
        {
            var bfGroup = game.variables.get('bfConstellationGroup');
            var dadGroup = game.variables.get('dadConstellationGroup');

            if (bfGroup != null)
                bfGroup.remove(star);

            if (dadGroup != null)
                dadGroup.remove(star);
        }
    ]])

    removeLuaSprite(starTag, true)
    removeLuaSprite(lineTag, true)

    if side == 'bf' then
        table.remove(LastBFStarX)
        table.remove(LastBFStarY)
    else
        table.remove(LastDadStarX)
        table.remove(LastDadStarY)
    end

    StarCount = StarCount - 1
end

local function contains(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true
        end
    end
    return false
end

function onUpdate()
    local intensity = getVar('AEM_INTENCITY') or 0

    local StarIntencity = math.floor(
        math.min(math.max(intensity, 0), 1) * 10
    )

    -- CREATE stars for any newly reached levels
    for level = 1, StarIntencity do
        if ILBF[level] == nil then
            ILBF[level] = spawnStar(
                math.random(600, 2000),
                math.random(-500, 1000),
                'bf'
            )

            ILD[level] = spawnStar(
                math.random(-800, 600),
                math.random(-500, 1000),
                'dad'
            )
        end
    end

    for level = 10, StarIntencity + 1, -1 do
        if ILBF[level] ~= nil then
            RemoveStar(ILBF[level], 'bf')
            ILBF[level] = nil
        end

        if ILD[level] ~= nil then
            RemoveStar(ILD[level], 'dad')
            ILD[level] = nil
        end
    end

    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes', i, 'scale.x', getPropertyFromGroup('strumLineNotes', i, 'scale.x') + (0.75 - getPropertyFromGroup('strumLineNotes', i, 'scale.x')) / 5)
        setPropertyFromGroup('strumLineNotes', i, 'scale.y', getPropertyFromGroup('strumLineNotes', i, 'scale.y') + (0.75 - getPropertyFromGroup('strumLineNotes', i, 'scale.y')) / 5)
    end

end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    if not isSustainNote then
        NotesHit = NotesHit + 1
        HasMadeStar = false
        BFLastHit = true
    end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
    if not isSustainNote then
        NotesHit = NotesHit + 1
        HasMadeStar = false
        BFLastHit = false
    end
end

function onBeatHit()
    BeatStar()
    local StarIntencity = math.min(getVar('AEM_INTENCITY'), 1)
    local useTime = (60 / curBpm) * 0.8
    local randRot = {-StarIntencity * 45, StarIntencity * 45}
    local curRot = randRot[curBeat % 2 + 1]
    --setPropertyFromGroup('playerStrums', 0, 'angle', 0)
    --setPropertyFromGroup('playerStrums', 0, 'angle', 0)
    for i = 0, 7 do
        local beginningAngle = 0
        if i < 4 then
            beginningAngle = getPropertyFromGroup('opponentStrums', i, 'angle')
        else
            beginningAngle = getPropertyFromGroup('playerStrums', i - 4, 'angle')
        end
        --noteTweenDirection('noteDirectionStart' .. i, i, StarIntencity * 20, useTime, 'quadOut')
        setPropertyFromGroup('strumLineNotes', i, 'angle', beginningAngle + curRot)
        setPropertyFromGroup('strumLineNotes', i, 'scale.x', 0.75 + (StarIntencity * 0.75))
        setPropertyFromGroup('strumLineNotes', i, 'scale.y', 0.75 + (StarIntencity * 0.75))
        noteTweenAngle('noteAngle' .. i, i, 0, useTime, 'quadOut')
        --doTweenX('noteScaleX' .. i, 'note' .. i .. '.scale', 1, useTime, 'quadOut')
        --doTweenY('noteScaleY' .. i, 'note' .. i .. '.scale', 1, useTime, 'quadOut')
        --noteTweenDirection('noteDirectionEnd' .. i, i, 0, useTime, 'quadOut')
    end
    --noteTweenAngle('noteAngle0', 0, getPropertyFromGroup('opponentStrums', 1, 'angle') + randomRots[math.random(#randomRots)], useTime, 'quadOut')
    --noteTweenAngle('noteAngle1', 1, getPropertyFromGroup('opponentStrums', 1, 'angle') + randomRots[math.random(#randomRots)], useTime, 'quadOut')
    --noteTweenAngle('noteAngle2', 2, getPropertyFromGroup('opponentStrums', 2, 'angle') + randomRots[math.random(#randomRots)], useTime, 'quadOut')
    --noteTweenAngle('noteAngle3', 3, getPropertyFromGroup('opponentStrums', 3, 'angle') + randomRots[math.random(#randomRots)], useTime, 'quadOut')
    --noteTweenAngle('noteAngle4', 4, getPropertyFromGroup('playerStrums', 0, 'angle') + randomRots[math.random(#randomRots)], useTime, 'quadOut')
    --noteTweenAngle('noteAngle5', 5, getPropertyFromGroup('playerStrums', 1, 'angle') + randomRots[math.random(#randomRots)], useTime, 'quadOut')
    --noteTweenAngle('noteAngle6', 6, getPropertyFromGroup('playerStrums', 2, 'angle') + randomRots[math.random(#randomRots)], useTime, 'quadOut')
    --noteTweenAngle('noteAngle7', 7, getPropertyFromGroup('playerStrums', 3, 'angle') + randomRots[math.random(#randomRots)], useTime, 'quadOut')
end