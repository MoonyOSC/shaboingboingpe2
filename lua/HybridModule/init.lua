local hm = {};

-- Vars

local timers = {};
local events = {};
local flxKeyInts = {
    {"A", 65},
    {"ALT", 18},
    {"B", 66},
    {"BACKSPACE", 8},
    {"BACKSLASH", 220},
    {"BREAK", 10},
    {"C", 66},
    {"CAPSLOCK", 20},
    {"COMMA", 188},
    {"CONTROL", 17},
    {"D", 68},
    {"DELETE", 46},
    {"DOWN", 40},
    {"E", 69},
    {"EIGHT", 56},
    {"END", 35},
    {"ENTER", 13},
    {"F", 70},
    {"F1", 112},
    {"F2", 113},
    {"F3", 114},
    {"F4", 115},
    {"F5", 116},
    {"F6", 117},
    {"F7", 118},
    {"F8", 119},
    {"F9", 120},
    {"F10", 121},
    {"F11", 122},
    {"F12", 123},
    {"FIVE", 53},
    {"FOUR", 52},
    {"G", 71},
    {"H", 72},
    {"HOME", 36},
    {"I", 73},
    {"INSERT", 45},
    {"J", 74},
    {"K", 75},
    {"L", 76},
    {"LBRACKET", 219},
    {"LEFT", 37},
    {"M", 77},
    {"MENU", 302},
    {"MINUS", 189},
    {"N", 78},
    {"NINE", 57},
    {"NUMPADEIGHT", 104},
    {"NUMPADFIVE", 101},
    {"NUMPADFOUR", 100},
    {"NUMPADMINUS", 109},
    {"NUMPADMULTIPLY", 106},
    {"NUMPADNINE", 105},
    {"NUMPADONE", 97},
    {"NUMPADPERIOD", 110},
    {"NUMPADPLUS", 107},
    {"NUMPADSEVEN", 103},
    {"NUMPADSIX", 102},
    {"NUMPADSLASH", 111},
    {"NUMPADTHREE", 99},
    {"NUMPADTWO", 98},
    {"NUMPADZERO", 96},
    {"O", 79},
    {"ONE", 49},
    {"P", 80},
    {"PAGEDOWN", 34},
    {"PAGEUP", 33},
    {"PERIOD", 190},
    {"PLUS", 187},
    {"PRINTSCREEN", 301},
    {"Q", 81},
    {"QUOTE", 222},
    {"R", 82},
    {"RBRACKET", 221},
    {"RIGHT", 39},
    {"S", 83},
    {"SCROLL_LOCK", 145},
    {"SEMICOLON", 186},
    {"SEVEN", 55},
    {"SHIFT", 16},
    {"SIX", 54},
    {"SLASH", 191},
    {"SPACE", 32},
    {"T", 84},
    {"TAB", 9},
    {"THREE", 51},
    {"TWO", 50},
    {"U", 85},
    {"UP", 38},
    {"V", 86},
    {"W", 87},
    {"X", 88},
    {"Y", 89},
    {"Z", 90},
    {"ZERO", 48}

}
local timeSinceLastBeat = 0;
-- Head

function hm.load()
    addLuaScript("lua/HybridModule/init.lua")
end

-- Tmp

function hm.randomSeed()
    return getRandomInt(1,43043302)..os.date();
end

-- Timers

function hm.setTimer(func,mili,lp)
   -- debugPrint("sa")
    local randSeed = getRandomInt(1,43043302)..os.date()
    table.insert(timers,{
        tag = randSeed,
        event = func,
    })
    runTimer(randSeed,mili/1000,lp)
    return randSeed;
end

function hm.setTimerSec(func,second,lp)
    -- debugPrint("sa")
     local randSeed = getRandomInt(1,43043302)..os.date()
     table.insert(timers,{
         tag = randSeed,
         event = func,
     })
     runTimer(randSeed,second,lp)
     return randSeed;
 end

function hm.killTimer(t)
    cancelTimer(t);
    for i,v in ipairs(timers) do
        if v.tag == t then
            table.remove(timers,i)
        end
    end
end

-- Mods

function hm.getModFolders(modName,folderName)
	return directoryFileList("mods/"..modName.."/"..folderName)
end

function hm.findModFolder(modName,folderName)
	return "mods/"..modName.."/"..folderName.."/"
end

function hm.findModPackTable(isOrginal,modName)
	if isOrginal == true then
		return getTextFromFile("mods/pack.json")
	else
		return getTextFromFile(""..modName.."/pack.json")
	end
end

-- Haxe

function hm.setClipBoard(dataStr)
    runHaxeCode("Clipboard.text = '"..dataStr.."';")
end

-- Objects

function hm.addClickAndHover(tag,onClick,onHover,onUnHover,camera)
	table.insert(events,{tag,onClick,onHover,onUnHover,isHover = false,camera = camera})
end

-- Music

function hm.LuaPlayMusic(musicfile,volme,loop,bpm,onBeatHitFunc,ignoreMods)
	playMusic(musicfile,volme,loop,ignoreMods)
	local curBeat = 0
	local seed = hm.setTimer(function ()
		onBeatHitFunc()
	end,hm.bpmtomili(bpm),0)
	return seed;
end

function hm.onBeatHit(bpm,elapsed,onBeatHitFunc)
    if framerate >= 200 then
        timeSinceLastBeat = timeSinceLastBeat + elapsed * 1040
    else
        timeSinceLastBeat = timeSinceLastBeat + elapsed * 1000 
    end
    if (timeSinceLastBeat >= hm.bpmtomili(bpm)) then
        timeSinceLastBeat = 0;
        onBeatHitFunc(); 
    end
end

function hm.cancelLuaMusic(tag)
	cancelTimer(tag);
	playMusic("")
	for i,v in ipairs(timers) do
		--debugPrint(v.seed)
		if v.seed == tag then
			table.remove(timers,i);
			break
		end
	end
end

function hm.bpmtomili(bpm)
	return 60/bpm * 1000
end

-- Keyboard

function hm.getKeyState()
	local ret = nil;
	local val = nil;
	for i,v in ipairs(flxKeyInts) do
		if keyboardJustPressed(v[1]) then
			val = v[2];
			ret = v[1];
			break
		end
	end
	return ret,val;
end

-- FnF funcs

function onCreate()
    addHaxeLibrary('Clipboard', 'lime.system')
end

function onUpdate()
    for i,v in ipairs(events) do
		if hm.getCursorHit(v[1],v.camera) then
			if mouseClicked("left") then
				v[2]()
			end
			if v.isHover == false then
				v[3]()
				v.isHover = true
			end
		else
			if v.isHover == true then
				v[4]()
				v.isHover = false
			end
		end
	end
end

function onTimerCompleted(t,l,ll)
    hm.onTimer(t,l,ll);
end

function hm.onTimer(t,l,ll)
    for i,v in ipairs(timers) do
        if v.tag == t then
            v.event(t,l,ll);
        end
    end
end

return hm;