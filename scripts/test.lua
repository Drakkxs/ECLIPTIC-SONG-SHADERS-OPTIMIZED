AEM_ZoomIn = true
AEM_COLOR = 0
local xx = 0
local yy = 0
local xx2 = 0
local yy2 = 0
local ofs = 1000;
local tfs = 1;

local followchars = true;

local bfCombo = 0;
local dadCombo = 0;
local bfComboTimer = 0;
local dadComboTimer = 0;

local doubleCombo = 0;
local doubleComboTimer = 0;

local trailCooldown = 0
local TRAIL_SYNC_INTERVAL = 0.035
local TRAIL_LENGTH = 8
local TRAIL_DELAY_FRAMES = 2

local cur_char_color = 0
local char_color = 0

local charComboMultiplier = 1


local defaultCamZoom = 1;
local defaultHUDZoom = 1;

local frame = 0
local shaderName = 'outline'

-- Shared-combo visual scaling.
-- The background reaches its existing maximum at doubleCombo = 95:
-- min(doubleCombo / 100, 0.95).
local BACKGROUND_DIM_COMBO_DIVISOR = 100
local BACKGROUND_DIM_MAX_ALPHA = 0.95
local MAX_NOTE_CAMERA_ZOOM = 0.5

-- Scales note-hit camera zoom using the same capped progress as blackBG.
-- doubleCombo itself remains completely uncapped.
function getSharedComboCameraZoom()
    local dimProgress = math.min(
        doubleCombo / BACKGROUND_DIM_COMBO_DIVISOR,
        BACKGROUND_DIM_MAX_ALPHA
    )

    return MAX_NOTE_CAMERA_ZOOM * (dimProgress / BACKGROUND_DIM_MAX_ALPHA)
end


function onCreate()
    initLuaShader(shaderName)
    initLuaShader("glow")

    addHaxeLibrary('FlxSprite', 'flixel')
    addHaxeLibrary('FlxTween', 'flixel.tweens')
    addHaxeLibrary('FlxColor', 'flixel.util')
    addHaxeLibrary('FlxTrail', 'flixel.addons.effects')
    addHaxeLibrary('FlxTimer', 'flixel.util')
end

function onCreatePost()

    xx2 = getMidpointX('boyfriend') - 100 + getProperty("boyfriendCameraOffset[0]") - getProperty("boyfriend.cameraPosition[0]")
    yy2 = getMidpointY('boyfriend') - 100 + getProperty("boyfriendCameraOffset[1]") + getProperty("boyfriend.cameraPosition[1]")
    xx = getMidpointX('dad') + 150 + getProperty("opponentCameraOffset[0]") + getProperty("dad.cameraPosition[0]")
    yy = getMidpointY('dad') - 100 + getProperty("opponentCameraOffset[1]") + getProperty("dad.cameraPosition[1]")
    gfX = getMidpointX('gf') + getProperty("girlfriendCameraOffset[0]") + getProperty("gf.cameraPosition[0]")
    gfY = getMidpointY('gf') + getProperty("girlfriendCameraOffset[1]") + getProperty("gf.cameraPosition[1]")

    makeLuaText('myText', '¯\\_(ツ)_/¯', 1000, 400, 320)
    addLuaText('myText')

    defaultCamZoom = getProperty('camGame.zoom')
    defaultHUDZoom = getProperty('camHUD.zoom')

    makeLuaSprite('blackBG', nil, -10000, -10000)
    makeGraphic('blackBG', 1, 1, '000000')
    scaleObject('blackBG', 20000, 20000)
    setScrollFactor('blackBG', 1, 1)
    addLuaSprite('blackBG', false)

    local order = math.min(
        getObjectOrder('dadGroup'),
        getObjectOrder('boyfriendGroup'),
        getObjectOrder('gfGroup')
    )

    setObjectOrder('blackBG', order - 1)

    initCharacterTrails()
end

function animExists(character, anim)
    return getProperty(character .. '.animation.getByName("' .. anim .. '")') ~= nil
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    if not isSustainNote then 
        if bfComboTimer == 0 then
            bfCombo = bfCombo + charComboMultiplier
            doubleCombo = doubleCombo + 1
        end
        bfCombo = (bfCombo + bfComboTimer / 100) * charComboMultiplier
        doubleCombo = (doubleCombo + doubleComboTimer / 50 / 4) 
    end
    bfComboTimer = 150
    doubleComboTimer = 50
    if isSustainNote then return end
    if AEM_ZoomIn then
        triggerEvent('Add Camera Zoom', getSharedComboCameraZoom(), '0')
    end
    
    if noteData == 0 then -- Left
        setProperty('camGame.angle', -tfs)
    elseif noteData == 3 then -- Right
        setProperty('camGame.angle', tfs)
    end

    doTweenAngle('camReturn', 'camGame', 0, 0.15, 'quadOut')
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
    if not isSustainNote then 
        if dadComboTimer == 0 then
            dadCombo = dadCombo + charComboMultiplier
            doubleCombo = doubleCombo + 1
        end
        dadCombo = dadCombo + (dadComboTimer / 100) * charComboMultiplier
        doubleCombo = (doubleCombo + doubleComboTimer / 50 / 4)
    end
    dadComboTimer = 150
    doubleComboTimer = 50
    if isSustainNote then return end
    if AEM_ZoomIn then
        triggerEvent('Add Camera Zoom', getSharedComboCameraZoom(), '0')
    end
    if noteData == 0 then -- Left
        setProperty('camGame.angle', -tfs)
    elseif noteData == 3 then -- Right
        setProperty('camGame.angle', tfs)
    end

    doTweenAngle('camReturn', 'camGame', 0, 0.15, 'quadOut')
end

function onUpdate(elapsed)
    -- Only synchronize two numbers with Haxe at the old trail rate.
    -- The FlxTrail objects update and reuse their own fixed sprite arrays.
    trailCooldown = trailCooldown - elapsed

    if trailCooldown <= 0 then
        trailCooldown = TRAIL_SYNC_INTERVAL
        setVar('eclipticBFCombo', bfCombo)
        setVar('eclipticDadCombo', dadCombo)
    end

    frame = frame + 1
    --local strength = math.min(bfCombo / 100000, 0.002)
    --setSpriteShader('boyfriend', 'glow')
    --setShaderFloat('boyfriend', 'glowStrength', 10)
    --setShaderFloat('boyfriend', 'glowSize,', 10)
    --setShaderFloatArray('boyfriend', 'glowColor', {1,1,1,1})
    --strength = math.min(dadCombo / 100000, 0.002)
    --setSpriteShader('dad', shaderName)
    --setShaderFloat('dad', 'intensity', strength)

    makeLuaSprite('chromShader')
    setSpriteShader('chromShader', shaderName)
    setShaderFloat('chromShader', 'intensity', math.min(doubleCombo / 5000, 0.02))
    setShaderIntArray('chromShader', 'sides', {1,1,1})
    --setShaderFloat('chromShader', 'intensity', 0.2)
    runHaxeCode([[
        game.camGame.setFilters([
            new ShaderFilter(game.getLuaObject("chromShader").shader)
        ]);
        game.camHUD.setFilters([
            new ShaderFilter(game.getLuaObject("chromShader").shader)
        ]);
    ]])
    bfComboTimer = bfComboTimer - 1
    dadComboTimer = dadComboTimer - 1
    doubleComboTimer = doubleComboTimer - 1

    setProperty(
        'blackBG.alpha',
        math.min(doubleCombo / BACKGROUND_DIM_COMBO_DIVISOR, BACKGROUND_DIM_MAX_ALPHA)
    )
    char_color = math.max(math.min((doubleCombo / BACKGROUND_DIM_COMBO_DIVISOR - 0.9) * 10, 1), 0)
    cur_char_color = cur_char_color + (char_color - cur_char_color) * 0.1
    setVar('AEM_COLOR', cur_char_color)

    setVar('AEM_INTENCITY', doubleCombo / BACKGROUND_DIM_COMBO_DIVISOR)
    
    --cur_char_color = cur_char_color + 0.001

    if math.floor(bfComboTimer) <= 0 then
        bfCombo = bfCombo * 0.9
    end
    if math.floor(dadComboTimer) <= 0 then
        dadCombo = dadCombo * 0.9
    end
    if math.floor(doubleComboTimer) <= 0 then
        doubleCombo = doubleCombo * 0.9
    end
    xx2 = getMidpointX('boyfriend') - 100 + getProperty("boyfriendCameraOffset[0]") - getProperty("boyfriend.cameraPosition[0]")
	yy2 = getMidpointY('boyfriend') - 100 + getProperty("boyfriendCameraOffset[1]") + getProperty("boyfriend.cameraPosition[1]")
	xx = getMidpointX('dad') + 150 + getProperty("opponentCameraOffset[0]") + getProperty("dad.cameraPosition[0]")
	yy = getMidpointY('dad') - 100 + getProperty("opponentCameraOffset[1]") + getProperty("dad.cameraPosition[1]")
    ofs = math.min(500, doubleCombo + 100) / getProperty('camGame.zoom')
    tfs = math.min(5, doubleCombo / 100 + 1)


    --setTextString('myText', "O: " .. dadCombo .. ' | B: ' .. bfCombo .. ' | D: ' .. doubleCombo .. "\n Ot: " .. dadComboTimer .. ' | Bt: ' .. bfComboTimer .. ' | Dt: ' .. doubleComboTimer)
    setTextString('myText', "")
    if bfCombo < 0 then
        bfCombo = 0
    end
    if dadCombo < 0 then
        dadCombo = 0
    end

    if followchars == true then
        if mustHitSection == false then
            if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',xx-ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',xx+ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
                triggerEvent('Camera Follow Pos',xx-ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
                triggerEvent('Camera Follow Pos',xx+ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
                triggerEvent('Camera Follow Pos',xx,yy)
            end
			if getProperty('dad.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx,yy)
			end

        else

            if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',xx2,yy2+ofs)
            end
			if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx2,yy2)
			end
        end
    else
        triggerEvent('Camera Follow Pos','','')
    end
    
    runHaxeCode([[
        var charColor:Int = ]] .. cur_char_color .. [[;
        var colorChar = function(char, color:Int)
        {
            if (char == null)
                return;

            
            var rgb = [char.healthColorArray[0] * color, char.healthColorArray[1] * color, char.healthColorArray[2] * color];
            var invertedColor = 1 - color;
            char.setColorTransform(
                invertedColor, invertedColor, invertedColor, 1,
                rgb[0], rgb[1], rgb[2], 0
            );
        };
        colorChar(game.boyfriend, charColor);
        colorChar(game.dad, charColor);
    ]])

end

-- Creates two fixed-size trails once. FlxTrail internally reuses its sprites.

function initCharacterTrails()
    setVar('eclipticBFCombo', 0)
    setVar('eclipticDadCombo', 0)

    runHaxeCode([[
        var trailLength:Int = ]] .. TRAIL_LENGTH .. [[;
        var trailDelay:Int = ]] .. TRAIL_DELAY_FRAMES .. [[;
        var syncInterval:Float = ]] .. TRAIL_SYNC_INTERVAL .. [[;


        var bfTrail = new FlxTrail(
            game.boyfriend,
            null,
            trailLength,
            trailDelay,
            0.85,
            0.85 / trailLength
        );

        var dadTrail = new FlxTrail(
            game.dad,
            null,
            trailLength,
            trailDelay,
            0.85,
            0.85 / trailLength
        );

        bfTrail.active = true;
        bfTrail.visible = false;
        dadTrail.active = true;
        dadTrail.visible = false;

        game.insert(game.members.indexOf(game.boyfriendGroup), bfTrail);
        game.insert(game.members.indexOf(game.dadGroup), dadTrail);

        game.variables.set('eclipticBFTrail', bfTrail);
        game.variables.set('eclipticDadTrail', dadTrail);

        var bfWasEnabled:Bool = false;
        var dadWasEnabled:Bool = false;

        

        // Apply a true, flat HP-bar color instead of multiplying the character's
        // original texture colors. This only needs to run when a trail is created.
        var styleTrail = function(trail, char)
        {
            if (trail == null || char == null)
                return;

            var rgb = char.healthColorArray;

            for (member in trail.members)
            {
                if (member == null)
                    continue;

                // Zero RGB multipliers discard the sprite's original palette.
                // RGB offsets replace it with the character's HP-bar color while
                // retaining the source texture's transparency/antialiased edges.
                member.setColorTransform(
                    0, 0, 0, 1,
                    rgb[0], rgb[1], rgb[2], 0
                );
                member.antialiasing = char.antialiasing;
                member.blend = char.blend;
            }
        };

        styleTrail(bfTrail, game.boyfriend);
        styleTrail(dadTrail, game.dad);

        var updateTrail = function(trail, char, combo:Float, wasEnabled:Bool)
        {
            if (trail == null || char == null)
                return false;

            var baseAlpha:Float = Math.min(combo / 250, 1) * 0.85;
            var enabled:Bool = baseAlpha > 0.02 && char.visible && char.alpha > 0;

            trail.active = true;
            trail.visible = enabled;


            var count:Int = trail.members.length;
            var divisor:Float = count > 1 ? count - 1 : 1;

            for (i in 0...count)
            {
                var member = trail.members[i];
                if (member == null)
                    continue;
//
                // Exact linear ramp: newest = baseAlpha, oldest = fully transparent.
                member.alpha = baseAlpha * (1 - (i / divisor));
            }

            return true;
        };

        var trailTimer = new FlxTimer();
        trailTimer.start(syncInterval, function(timer)
        {
            // Rebuild automatically if a Change Character event replaced either target.
            if (game.boyfriend != null && bfTrail.target != game.boyfriend)
            {
                game.remove(bfTrail, true);
                bfTrail.destroy();
                bfTrail = new FlxTrail(game.boyfriend, null, trailLength, trailDelay, 0.85, 0.85 / trailLength);
                bfTrail.active = true;
                bfTrail.visible = false;
                game.insert(game.members.indexOf(game.boyfriendGroup), bfTrail);
                game.variables.set('eclipticBFTrail', bfTrail);
                styleTrail(bfTrail, game.boyfriend);
                bfWasEnabled = false;
            }
            if (game.dad != null && dadTrail.target != game.dad)
            {
                game.remove(dadTrail, true);
                dadTrail.destroy();
                dadTrail = new FlxTrail(game.dad, null, trailLength, trailDelay, 0.85, 0.85 / trailLength);
                dadTrail.active = true;
                dadTrail.visible = false;
                game.insert(game.members.indexOf(game.dadGroup), dadTrail);
                game.variables.set('eclipticDadTrail', dadTrail);
                styleTrail(dadTrail, game.dad);
                dadWasEnabled = false;
            }
            var bfComboValue:Dynamic = game.variables.get('eclipticBFCombo');
            var dadComboValue:Dynamic = game.variables.get('eclipticDadCombo');
            var bfValue:Float = bfComboValue == null ? 0 : bfComboValue;
            var dadValue:Float = dadComboValue == null ? 0 : dadComboValue;
            bfWasEnabled = updateTrail(bfTrail, game.boyfriend, bfValue, bfWasEnabled);
            dadWasEnabled = updateTrail(dadTrail, game.dad, dadValue, dadWasEnabled);
        }, 0);

        game.variables.set('eclipticTrailTimer', trailTimer);


    ]])
end

function onDestroy()
    runHaxeCode([[
        var timer = game.variables.get('eclipticTrailTimer');
        if (timer != null)
        {
            timer.cancel();
        }

        var bfTrail = game.variables.get('eclipticBFTrail');
        if (bfTrail != null)
        {
            game.remove(bfTrail, true);
            bfTrail.destroy();
        }

        var dadTrail = game.variables.get('eclipticDadTrail');
        if (dadTrail != null)
        {
            game.remove(dadTrail, true);
            dadTrail.destroy();
        }

        game.variables.remove('eclipticTrailTimer');
        game.variables.remove('eclipticBFTrail');
        game.variables.remove('eclipticDadTrail');
        game.variables.remove('eclipticBFCombo');
        game.variables.remove('eclipticDadCombo');
    ]])
end
