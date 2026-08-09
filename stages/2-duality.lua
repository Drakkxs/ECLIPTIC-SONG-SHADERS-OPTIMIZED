UpScale = 1 / 0.3;
AEM_COLOR = 0
function onCreate()
    makeLuaSprite('bg', '2-duality/DualityBG', -250, -250)
    scaleObject('bg', UpScale, UpScale);
    setScrollFactor('bg', 1, 0)
    addLuaSprite('bg', false)

    makeLuaSprite('bg2', '2-duality/DualityBG2', -250, -250)
    scaleObject('bg2', UpScale, UpScale);
    setScrollFactor('bg2', 1, 0)
    addLuaSprite('bg2', false)

    makeAnimatedLuaSprite('split', '2-duality/DualitySplit', 435, -250)
    scaleObject('split', UpScale, UpScale);
    addAnimationByPrefix('split', 'idle', 'Split', 12, true)
    setScrollFactor('split', 1, 0)
    addLuaSprite('split', true)

    makeAnimatedLuaSprite('edge', '2-duality/DualityEdge', -250, -250)
    scaleObject('edge', UpScale, UpScale);
    addAnimationByPrefix('edge', 'idle', 'Split', 12, true)
    setScrollFactor('edge', 1, 0)
    addLuaSprite('edge', true)
end

function rgbToColor(r, g, b)
    return r * 0x10000 + g * 0x100 + b
end

function onCreatePost()
    local br = getProperty('boyfriend.healthColorArray[0]')
    local bg = getProperty('boyfriend.healthColorArray[1]')
    local bb = getProperty('boyfriend.healthColorArray[2]')
    local dr = getProperty('dad.healthColorArray[0]')
    local dg = getProperty('dad.healthColorArray[1]')
    local db = getProperty('dad.healthColorArray[2]')

    setProperty('bg.color', rgbToColor(br, bg, bb))
    setProperty('bg2.color', rgbToColor(dr, dg, db))
end

function onUpdate(elapsed)
    AEM_COLOR = getVar('AEM_COLOR')
    brightness = math.floor(AEM_COLOR * 255)
    setProperty('split.color', rgbToColor(brightness, brightness, brightness))


    doTweenZoom('AEMZoom', 'camGame', getProperty('defaultCamZoom'), 0.7, 'quartOut')
    setProperty('game.camZoom', 1.3)
    setPropertyFromClass('ClientPrefs', 'camZooms', false)
    setProperty('defaultCamZoom', 1.3)
end