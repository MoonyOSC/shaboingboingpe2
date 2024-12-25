package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.display.FlxBackdrop;

import hxgamejolt.GameJolt;

import openfl.net.URLRequest;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

class GameJoltState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var HybridEngineLogo:FlxSprite;

	var UserName:PsychUIInputText;
	var Token:PsychUIInputText;

	var loginButton:PsychUIButton;
	var backButton:PsychUIButton;

	var untX = 180;
	var untY = 300;

	var xAga = 800;
	var yAga = 600;

	var sprite:FlxSprite;
	var userNameText:FlxText;
	var userNameBack:FlxSprite;

	var isWrongUser = true;

	function checkLogin() {
		if (isWrongUser == true) {
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
		} else {
			GameJolt.authUser(UserName.text, Token.text, {
			onSucceed: function(json:Dynamic):Void
			{
				FlxG.sound.play(Paths.sound('confirmMenu'), 1);

				ClientPrefs.data.gameJoltUsername = UserName.text;
				ClientPrefs.data.gameJoltToken = Token.text;
				ClientPrefs.data.skipGameJoltScreen = true;
				ClientPrefs.saveSettings();

				MusicBeatState.switchState(new TitleState());
			},
			onFail: function(message:String):Void
			{
				ClientPrefs.data.gameJoltUsername = null;
				ClientPrefs.data.gameJoltToken = null;
				ClientPrefs.saveSettings();
				FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			}
			});
		}
	}

	function checkUserExist(old:String, cur:String) {
		GameJolt.fetchUser(cur, [], {
			onSucceed: function(json:Dynamic):Void
			{
				trace(json);

				var loader:Loader = new Loader();
				var url:String = json.users[0].avatar_url;
				var urlPng:String = url.replace(".webp", ".png");

				var request:URLRequest = new URLRequest(urlPng.replace("/60", "/522"));
				
				loader.load(request);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event) {
					// sprite.loadGraphic(event.target.content);

					var bitmap:Bitmap = event.target.content;
					var bitmapData:BitmapData = bitmap.bitmapData;
					sprite.loadGraphic(bitmapData, true, false);
					sprite.scale.x = 347 / sprite.width;
					sprite.scale.y = 322 / sprite.height;
					sprite.updateHitbox();
					userNameText.text = json.users[0].username;

					isWrongUser = false;
					
				});
				trace(loader);
			},
			onFail: function(message:String):Void
			{
				trace("User Not Exist");
				sprite.loadGraphic(Paths.image("login/Placeholder"));
				userNameText.text = "Unknown";
				sprite.scale.set(1,1);
				sprite.updateHitbox();

				isWrongUser = true;
			}
		});
	}

	function createLoginStuffs() {

		var loginIcon = new FlxSprite(untX,untY);
		loginIcon.x -= 57;
		loginIcon.loadGraphic(Paths.image("login/Username"));
		add(loginIcon);

		UserName = new PsychUIInputText(untX, untY, 300, '', 41);
		UserName.textObj.setFormat(Paths.font('PhantomMuff.ttf'), 20, FlxColor.BLACK, LEFT);
		add(UserName);
		UserName.onChange = checkUserExist;

		untY += 75;

		var tokenIcon = new FlxSprite(untX,untY);
		tokenIcon.x -= 57;
		tokenIcon.loadGraphic(Paths.image("login/Token"));
		add(tokenIcon);

		Token = new PsychUIInputText(untX, untY, 300, '', 41);
		Token.textObj.setFormat(Paths.font('PhantomMuff.ttf'), 20, FlxColor.BLACK, LEFT);
		Token.passwordMask = true;
		add(Token);

		var loginButton:PsychUIButton = new PsychUIButton(xAga, yAga, 'Login', checkLogin, 20);
		loginButton.text.setFormat(Paths.font('PhantomMuff.ttf'), 20, FlxColor.BLACK, CENTER);
		loginButton.resize(350, 40);

		yAga += 50;

		var backButton:PsychUIButton = new PsychUIButton(xAga, yAga, 'Back To Menu', function()
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new TitleState());
			ClientPrefs.data.skipGameJoltScreen = true;
			ClientPrefs.saveSettings();
		}, 20);
		backButton.text.setFormat(Paths.font('PhantomMuff.ttf'), 20, FlxColor.BLACK, CENTER);
		backButton.resize(350, 40);

		add(loginButton);
		add(backButton);

		sprite = new FlxSprite(800,40);
		sprite.loadGraphic(Paths.image("login/Placeholder"));
		add(sprite);

		userNameBack = new FlxSprite(800,40);
		userNameBack.makeGraphic(347,50,FlxColor.fromRGB(30,30,30));
		add(userNameBack);
		userNameBack.y += 321;

		userNameText = new FlxText(800,50,347,"Unknown");
		userNameText.setFormat(Paths.font("PhantomMuff.ttf"), 25, FlxColor.fromRGB(255,255,255), CENTER);
		userNameText.y += 321;
		add(userNameText);

	
	}
	
	override function create()
	{
		super.create();

		FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(255,204,102));
		add(bg);

		var gridLoop = new FlxBackdrop(Paths.image('login/grid'));
		gridLoop.velocity.set(150,150);
		gridLoop.alpha = 0.3;
		add(gridLoop);

		var bgLeft:FlxSprite = new FlxSprite().makeGraphic(640, FlxG.height, FlxColor.fromRGB(15,15,15));
		add(bgLeft);

		var HybridEngineLogo:FlxSprite = new FlxSprite(100,20);
		HybridEngineLogo.loadGraphic(Paths.image("loading_screen/HybridEngineLogo"));
		add(HybridEngineLogo);

		HybridEngineLogo.scale.set(0.2,0.2);
		HybridEngineLogo.updateHitbox();

		var cursor = new FlxSprite();
		cursor.makeGraphic(15, 15, FlxColor.TRANSPARENT);
		cursor.loadGraphic(Paths.image("cursor/cursor-default"));
		FlxG.mouse.load(cursor.pixels);

		createLoginStuffs();

		

		// warnText = new FlxText(0, 0, FlxG.width,
		// 	"By connecting your Gamejolt account to the game, you can display your achievements on your profile.",
		// 	32);
		// warnText.setFormat(Paths.font("Phantomuff Difficult Font.ttf"), 32, FlxColor.WHITE, CENTER);
		// warnText.screenCenter(Y);
		// add(warnText);
	}

	override function update(elapsed:Float)
	{

		if(FlxG.mouse.justPressed) {
			FlxG.sound.play(Paths.sound('chartingSounds/ClickUp'), 1);
		}

		if (FlxG.mouse.justReleased) {
			FlxG.sound.play(Paths.sound('chartingSounds/ClickDown'), 1);
		}

		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT) {

			} else if (back) {

			}
		}
		super.update(elapsed);
	}
}
