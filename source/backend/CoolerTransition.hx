package objects;

import Song.SwagSong;
import PlayState;
import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import MusicBeatState;
import ClientPrefs;
import flixel.util.FlxTimer;
import MusicBeatSubstate;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class CoolerTransition extends MusicBeatSubstate
{
	public inline static final BACKGROUND_COLOR:FlxColor = 0xFF191628;
	private inline static final SHAKE_AMOUNT:Float = 12;

	private inline static final SPRITE_SCALING:Float = 1;
	private inline static final TWEEN_DURATION:Float = .6;

	public static var silent:Bool = false;
	private static var stopwatch:Float = 0;

	private var tweenArray:Array<FlxTween> = new Array();
	private var leTimer:FlxTimer;

	private var isTransIn:Bool = false;

	private var transitionGroup:FlxSpriteGroup;
	private var transitionCamera:FlxCamera;

	private var background:FlxBackdrop;

	
	var loadingNumber:Int = FlxG.random.int(0,21);

	public static var lastNumber:Int = 0;

	public function new(isTransIn:Bool)
	{
		super();
		this.isTransIn = isTransIn;

		transitionCamera = new FlxCamera();
		transitionCamera.bgColor = FlxColor.TRANSPARENT;

		transitionCamera.zoom = 1;
		FlxG.cameras.add(transitionCamera, false);

		var height:Int = FlxG.height;
		var width:Int = FlxG.width;

		transitionGroup = new FlxSpriteGroup();

		var transBottom:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logoshit'));

		var staticOverlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image('transition/static'), true, Std.int(width / 4), Std.int(height / 4));

		staticOverlay.animation.add('static', [0, 1, 2, 3], 24, true);
		staticOverlay.animation.play('static', true);

		staticOverlay.scrollFactor.set();
		background = new FlxBackdrop(Paths.image('transition/tile'), 1, 1, true, true);

		background.scrollFactor.set(1, 1);
		background.alpha = 0;


		transBottom.x += 99 * SPRITE_SCALING;
		transBottom.screenCenter(XY);
		transBottom.scale.set(3,3);


		if (isTransIn)
		{
			if (!silent)
				FlxG.sound.play(Paths.sound('transition/transitionOut'));
			silent = false;
			MusicBeatState.coolerTransition = false;

			var transBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('transition/loading/loading'+lastNumber));
			CustomFadeTransition.doTitleShit();

			if (PlayState.isStoryMode) {
				if (Paths.formatToSongPath(PlayState.SONG.song) == 'soundpad') {
					PlayState.videoStarted = true;
				}
			}

	
			transBottom.scale.set(1,1);

			transBG.scrollFactor.set();
			transBG.alpha = 1;

			background.alpha = .1;
			staticOverlay.alpha = .05;

			tweenArray.push(FlxTween.tween(transBG, {alpha: 0}, TWEEN_DURATION, {ease: FlxEase.quadIn}));
			tweenArray.push(FlxTween.tween(background, {alpha: 0}, TWEEN_DURATION,  {ease: FlxEase.quadIn}));
			tweenArray.push(FlxTween.tween(staticOverlay, {alpha: 0}, TWEEN_DURATION, {ease: FlxEase.quadIn}));

			tweenArray.push(FlxTween.tween(transBottom, {y: transBottom.y + height + transBottom.height}, TWEEN_DURATION, {ease: FlxEase.backIn}));

			leTimer = new FlxTimer().start(TWEEN_DURATION, function(tmr:FlxTimer)
			{
				close();
			});

			transBG.cameras = [transitionCamera];
			transitionGroup.add(transBG);
		}
		else
		{
			if (!silent)
				FlxG.sound.play(Paths.sound('transition/transitionIn'));

			var bgHeight:Int = Std.int(height / 2);

			var bgBottom:FlxSprite = new FlxSprite(0, 1080).loadGraphic(Paths.image('transition/loading/loading'+loadingNumber), true, Std.int(width), Std.int(height / 2));
			bgBottom.animation.add('static', [1], 24, true);
			bgBottom.animation.play('static', true);

			var bgTop:FlxSprite = new FlxSprite(0, -360).loadGraphic(Paths.image('transition/loading/loading'+loadingNumber), true, Std.int(width), Std.int(height / 2));
			bgTop.animation.add('static', [0], 24, true);
			bgTop.animation.play('static', true);

			lastNumber = loadingNumber;

			bgBottom.scrollFactor.set();
			bgTop.scrollFactor.set();

			var transBottomY:Float = transBottom.y;

			//transBottom.y += height + transBottom.height;
			staticOverlay.alpha = 0;

			transBottom.alpha = 0;
			transBottom.scale.set(3, 3);
	
			tweenArray.push(FlxTween.tween(transBottom, {'scale.y': 1, 'scale.x': 1}, TWEEN_DURATION, {
				ease: FlxEase.cubeIn,
				onComplete: function(twn:FlxTween)
				{
					tweenArray.push(FlxTween.tween(transBottom, {'scale.y': 1.1, 'scale.x': 1.1, alpha: 1}, TWEEN_DURATION / 2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							tweenArray.push(FlxTween.tween(transBottom, {'scale.y': 1, 'scale.x': 1}, TWEEN_DURATION / 2, {ease: FlxEase.sineIn}));
						}
					}));
				}
			}));

			tweenArray.push(FlxTween.tween(bgBottom, {y: height - (bgHeight)}, TWEEN_DURATION, {ease: FlxEase.cubeIn}));
			tweenArray.push(FlxTween.tween(bgTop, {y: bgHeight - (bgHeight * SPRITE_SCALING)}, TWEEN_DURATION, {ease: FlxEase.cubeIn}));

			tweenArray.push(FlxTween.tween(staticOverlay, {alpha: .05}, TWEEN_DURATION, {ease: FlxEase.quadIn}));
			// other shit
			for (nextCamera in FlxG.cameras.list)
			{
				if (nextCamera != transitionCamera)
					tweenArray.push(FlxTween.tween(nextCamera, {zoom: nextCamera.zoom + .15}, TWEEN_DURATION, {ease: FlxEase.cubeIn}));
			}
			tweenArray.push(FlxTween.tween(transitionCamera, {zoom: 1}, TWEEN_DURATION, {
				ease: FlxEase.cubeIn,
				onComplete: function(twn:FlxTween)
				{
					transitionCamera.bgColor = BACKGROUND_COLOR;
					new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
					{
						if (tmr.loopsLeft <= 0)
						{
							transitionCamera.scroll.set();
						}
						else
						{
							transitionCamera.scroll.set(FlxG.random.float(-SHAKE_AMOUNT, SHAKE_AMOUNT), FlxG.random.float(-SHAKE_AMOUNT, SHAKE_AMOUNT));
						}
					}, 15);

					tweenArray.push(FlxTween.tween(background, {alpha: .1}, TWEEN_DURATION, {ease: FlxEase.cubeOut}));
					tweenArray.push(FlxTween.tween(transitionCamera, {zoom: 1}, TWEEN_DURATION, {ease: FlxEase.backIn}));
				}
			}));
			leTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				if (CustomFadeTransition.finishCallback != null)
				{
					CustomFadeTransition.finishCallback();
					CustomFadeTransition.finishCallback = null;
				}
			});

			transitionGroup.add(bgBottom);
			transitionGroup.add(bgTop);
		}

		transitionGroup.add(background);
		transitionGroup.add(transBottom);
		transitionGroup.add(staticOverlay);

		transitionGroup.antialiasing = ClientPrefs.globalAntialiasing;
		transitionGroup.scale.x = transitionGroup.scale.y = SPRITE_SCALING;

		// transitionGroup.scrollFactor.set(1, 1);
		transitionGroup.cameras = [transitionCamera];

		staticOverlay.setGraphicSize(width, height);
		staticOverlay.updateHitbox();

		staticOverlay.screenCenter();
		CustomFadeTransition.nextCamera = null;

		add(transitionGroup);
	}

	override function update(elapsed:Float)
	{
		stopwatch = (stopwatch + elapsed) % 1;
		background.x = background.y = stopwatch * 180 * SPRITE_SCALING;

		super.update(elapsed);
	}

	override function destroy()
	{
		if (!isTransIn && CustomFadeTransition.finishCallback != null)
		{
			CustomFadeTransition.finishCallback();
			CustomFadeTransition.finishCallback = null;
		}
		if (leTimer != null)
		{
			leTimer.cancel();
			leTimer.destroy();

			leTimer = null;
		}
		if (tweenArray != null)
		{
			for (tween in tweenArray)
			{
				tween.cancel();
				tween.destroy();
			}
			tweenArray = null;
		}
		super.destroy();
	}
}