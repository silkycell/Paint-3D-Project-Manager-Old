package classes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Timer;
import openfl.Assets;

class WalkingMan extends FlxSprite
{
	var dir:Bool = false;
	var instance:PlayState;
	var spd:Int = 0;
	var stepCount:Int = 0;

	public var size:Float = 0;

	var panicing:Bool = false;

	public function new(spd:Int, instance:PlayState)
	{
		super();

		dir = (FlxG.random.int(0, 1) == 0 ? false : true);

		if (dir)
			flipX = true;

		if (FlxG.random.int(1, 15) == 1)
			spd = 50;

		this.instance = instance;
		this.spd = spd;

		frames = FlxAtlasFrames.fromSparrow(Assets.getBitmapData('embed/walk.png'), Assets.getText('embed/walk.xml'));
		animation.addByPrefix('walk', 'walk', spd * 10, true);
		animation.play('walk');

		size = FlxG.random.float(0, 1.4);

		animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
		{
			if ([0, 14, 28, 38, 50, 61, 74, 83].contains(frameNumber))
			{
				FlxG.camera.shake(0.001 * size, 0.1);
				FlxG.sound.play(Assets.getSound('embed/footstep' + stepCount + '.ogg'));
				stepCount += 1;

				if (stepCount > 3)
					stepCount = 0;
			}
		}

		scale.set(size, size);

		updateHitbox();

		if (dir)
			x = 0 - width;
		else
			x = FlxG.width + width;

		y = FlxG.height - height + (height / 16);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (this != null && alive)
		{
			if (dir)
				x += spd;
			else
				x -= spd;

			if ((dir ? x > FlxG.width + (width + 10) : x < 0 - (width + 10)))
				kill();

			if (this != null && alive)
			{
				if (FlxG.mouse.overlaps(this) && FlxG.mouse.justPressed)
				{
					FlxG.camera.flash(FlxColor.ORANGE, 0.8, null, true);
					FlxG.camera.shake(0.1, 0.2, null, true);

					FlxTween.cancelTweensOf(FlxG.camera);
					FlxG.camera.zoom = 1.5;
					FlxG.camera.angle = FlxG.random.float(-25, 25);
					FlxTween.tween(FlxG.camera, {zoom: 1, angle: 0}, 0.9, {ease: FlxEase.quartOut});

					var explosion = new Explosion(x, y, this);
					instance.add(explosion);

					instance.murderFunny(x);

					kill();
				}
			}
		}
	}

	override public function kill()
	{
		instance.theMen.remove(this);
		Timer.delay(function()
		{
			if (this != null)
				destroy();
		}, 5000);
		super.kill();
	}

	public function panic(pos:Float)
	{
		if (panicing)
			return;

		panicing = true;

		if ((x > pos && !dir) || (pos > x && dir))
		{
			dir = !dir;
			flipX = !flipX;
		}

		var curFrame = animation.frameIndex;
		spd *= (3 * (Std.int(size) == 0 ? 1 : Std.int(size)));

		animation.addByPrefix('walkFast', 'walk', spd * 10, true);
		animation.play('walkFast');
		animation.frameIndex = curFrame;
	}
}
