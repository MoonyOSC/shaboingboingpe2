function onCreate()
	makeLuaSprite('black', 'stages-erects/week1/black', -400, -990);
	scaleLuaSprite('black', 0.8, 0.8); 
	addLuaSprite('black', false);
	
	makeAnimatedLuaSprite('crowdanim', 'stages-erects/week1/crowd', 440, -40)
        addAnimationByPrefix('crowdanim', 'idle', 'Symbol 2 instance', 24, true)
        setScrollFactor('crowdanim', 0.33, 0.33)
        setGraphicSize('crowdanim', getProperty('crowdanim.width')*1.2, getProperty('crowdanim.height')*1.2, true)
        updateHitbox('crowdanim')
        addLuaSprite('crowdanim')
        
	function onBeatHit()
    playAnim('crowdanim', 'idle')
    end
    
    makeLuaSprite('stageback', 'stages-erects/week1/bg', -400, -990);
	scaleLuaSprite('stageback', 0.8, 0.8); 
	addLuaSprite('stageback', false);
	
	makeLuaSprite('server', 'stages-erects/week1/server', -400, -990);
	scaleLuaSprite('server', 0.8, 0.8); 
	addLuaSprite('server', false);
	
	makeLuaSprite('lights', 'stages-erects/week1/lights', -400, -900);
	scaleLuaSprite('lights', 0.8, 0.8); 
	addLuaSprite('lights', true);
    setScrollFactor("lights",0.9,0.9)

    triggerEvent("Set RTX Data",colors[rand][2])
	
	
end