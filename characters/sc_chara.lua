
local charaTag = nil
local asrielTag = 'AEMPhantomAsriel'
local asrielSide = AEMDustshiftSide

local lastAnim = nil
local asrielVisible = false

local DadOffset = {x = -700, y = -500}
local BFOffset = {x = -1100, y = -600}


function createAsriel()
    setVar('AEMAsrielSide', asrielSide)
    if asrielSide == "BF" then
        setVar('AEMAsrielOffsetX', BFOffset["x"])
        setVar('AEMAsrielOffsetY', BFOffset["y"])
    else
        setVar('AEMAsrielOffsetX', DadOffset["x"])
        setVar('AEMAsrielOffsetY', DadOffset["y"])
    end
    

    runHaxeCode([[
        var side:String = game.variables.get('AEMAsrielSide');
        var offsetX:Int = game.variables.get('AEMAsrielOffsetX');
        var offsetY:Int = game.variables.get('AEMAsrielOffsetY');

        var chara = side == 'BF'
            ? game.boyfriend
            : game.dad;

        if (chara == null)
            return;

        var name:String = side == 'BF'
            ? 'phantom_asriel-player'
            : 'phantom_asriel';

        var asriel = new Character(
            chara.x + offsetX,
            chara.y + offsetY,
            name,
            side == 'BF'
        );

        asriel.alpha = 0;

        if (side == 'BF')
            game.boyfriendGroup.add(asriel);
        else
            game.dadGroup.add(asriel);

        game.variables.set('AEMPhantomAsriel', asriel);
    ]])
end

function syncAsrielAnimation()
    setVar('AEMAsrielSide', asrielSide)

    runHaxeCode([[
        var side:String = game.variables.get('AEMAsrielSide');

        var chara = side == 'BF'
            ? game.boyfriend
            : game.dad;

        var asriel = game.variables.get('AEMPhantomAsriel');

        if (chara == null || asriel == null)
            return;

        var charaAnim:String = chara.getAnimationName();
        var asrielAnim:String = charaAnim;

        game.variables.set('AEMDebugCharaAnim', charaAnim);

        if (StringTools.endsWith(asrielAnim, '-alt'))
        {
            asrielAnim = asrielAnim.substr(0, asrielAnim.length - 4);
        }

        game.variables.set('AEMDebugAsrielTargetAnim', asrielAnim);

        if (
            asrielAnim == 'idle' ||
            asrielAnim == 'singLEFT' ||
            asrielAnim == 'singDOWN' ||
            asrielAnim == 'singUP' ||
            asrielAnim == 'singRIGHT'
        )
        {
            if (asriel.getAnimationName() != asrielAnim)
            {
                asriel.playAnim(asrielAnim, true);
            }
        }

        game.variables.set(
            'AEMDebugAsrielAnim',
            asriel.getAnimationName()
        );
    ]])
end


function shouldShowAsriel()
    if asrielSide == 'BF' then
        return BFAltAnim
    else
        return DadAltAnim
    end
end

function onCreatePost()
--    if playsAsBF() then
--        charaTag = 'boyfriend'
--        asrielSide = 'BF'
--    else
--        charaTag = 'dad'
--        asrielSide = 'Dad'
--    end

    createAsriel()
end

function updateAsrielFade()
    local shouldShow

    if asrielSide == 'BF' then
        shouldShow = getVar('AEM_BF_ALT') == true
    else
        shouldShow = getVar('AEM_DAD_ALT') == true
    end

    if shouldShow == asrielVisible then
        return
    end

    asrielVisible = shouldShow

    local cur_time_fade = 0.3 * math.sin(getSongPosition() / 500) + 0.6

    setVar('AEMAsrielTargetAlpha', shouldShow and cur_time_fade or 0)

    runHaxeCode([[
        var asriel = game.variables.get('AEMPhantomAsriel');
        var target:Float = game.variables.get('AEMAsrielTargetAlpha');

        if (asriel != null)
        {
            FlxTween.cancelTweensOf(asriel);

            FlxTween.tween(
                asriel,
                {alpha: target},
                0.5,
                {ease: FlxEase.quadOut}
            );
        }
    ]])
end

function onUpdatePost(elapsed)
    updateAsrielFade()
    syncAsrielAnimation()
end