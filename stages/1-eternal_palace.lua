UpScale = 1 / 0.15;
BFTurn = false;
function onCreate()
    BFTurn = not mustHitSection;
    makeLuaSprite('sky', '1-eternal_palace/bg', -900, -100)
    scaleObject('sky', UpScale, UpScale);
    setScrollFactor('sky', 0, 1)
	addLuaSprite('sky', false)

    makeLuaSprite('pillars', '1-eternal_palace/FrontPillars', -480*2, -100)
    scaleObject('pillars', UpScale * 1.2, UpScale * 1.2);
    setScrollFactor('pillars', 1, 1)
    addLuaSprite('pillars', true)

    makeLuaSprite('backPillars', '1-eternal_palace/BackPillars', -120, -50)
    scaleObject('backPillars', UpScale / 1.1, UpScale / 1.1);
    setScrollFactor('backPillars', 0.4, 1)
    addLuaSprite('backPillars', false)

    makeLuaSprite('clockBack', '1-eternal_palace/BackClock', 300 + 10*UpScale, -100 + 10*UpScale)
    scaleObject('clockBack', UpScale, UpScale);
    setScrollFactor('clockBack', 0, 1)
    addLuaSprite('clockBack', false)

    makeLuaSprite('clockNumbers', '1-eternal_palace/Numbers', 300 + 11*UpScale, -100 + 11*UpScale)
    scaleObject('clockNumbers', UpScale, UpScale);
    setScrollFactor('clockNumbers', 0, 1)
    addLuaSprite('clockNumbers', false)

    makeLuaSprite('clockFrame', '1-eternal_palace/Clock', 300, -100)
    scaleObject('clockFrame', UpScale, UpScale);
    setScrollFactor('clockFrame', 0, 1)
    addLuaSprite('clockFrame', false)

    makeLuaSprite('minuteHand', '1-eternal_palace/MinuteHand', 300 + 67*UpScale, -100 + 23*UpScale)
    scaleObject('minuteHand', UpScale, UpScale);
    setScrollFactor('minuteHand', 0, 1)
    addLuaSprite('minuteHand', false)

    makeLuaSprite('hourHand', '1-eternal_palace/HourHand', 300 + 67*UpScale, -100 + 38*UpScale)
    scaleObject('hourHand', UpScale, UpScale);
    setScrollFactor('hourHand', 0, 1)
    addLuaSprite('hourHand', false)
    
    makeLuaSprite('midPillars', '1-eternal_palace/MidPillar', -2500, -100)
    scaleObject('midPillars', UpScale * 1.2, UpScale * 1.2);
    setScrollFactor('midPillars', 0,1)
    addLuaSprite('midPillars', true)

    

end

function onBeatHit()
    time_amount = getSongPosition() / songLength
end

function onUpdate(elapsed)
   AEM_ZoomIn = false
    if getSongPosition() / songLength >= 1 or getSongPosition() / songLength <= 0 then
        time_amount = getSongPosition() / songLength
    end
    doTweenAngle('minuteHandTween', 'minuteHand', time_amount * 360 * 12, 0.1, 'QuadOut')
    doTweenAngle('hourHandTween', 'hourHand', time_amount * 360, 0.1, 'QuadOut')

    if mustHitSection ~= BFTurn then
        BFTurn = mustHitSection;
        if BFTurn then
            doTweenX('AEM-midPillarTween', 'midPillars', 2500, 2.5, 'QuartOut')
        else
            doTweenX('AEM-midPillarTween', 'midPillars', -2500, 2.5, 'QuartOut')
        end 
    end
    if getProperty('midPillars.x') < 0 then
        setProperty('dad.alpha', 1)
    else
        setProperty('dad.alpha', 0)
    end
    if getProperty('midPillars.x') > 400 then
        setProperty('boyfriend.alpha', 1)
    else
        setProperty('boyfriend.alpha', 0)
    end
    if getProperty('midPillars.x') > 100 then
        setProperty('gf.alpha', 1)
    else
        setProperty('gf.alpha', 0)
    end
end