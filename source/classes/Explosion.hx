package classes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;

class Explosion extends FlxSprite
{
	public function new(x:Float, y:Float, parent:WalkingMan)
	{
		super(x, y);

		frames = FlxAtlasFrames.fromSparrow(Assets.getBitmapData('embed/explosion.png'), Assets.getText('embed/explosion.xml'));
		animation.addByPrefix('explode', 'explode', 40, false);
		animation.play('explode');
		FlxG.sound.play(Assets.getSound('embed/explosion.ogg'), 0.3);

		scale.set(parent.size * 2, parent.size * 2);

		updateHitbox();

		this.x += (parent.width / 2) - (width / 2);
		this.y += (parent.height / 2) - (height / 2);

		animation.finishCallback = function(name:String)
		{
			if (name == 'explode')
				destroy();
		}
	}
}
