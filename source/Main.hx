package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, PlayState, 60, 60, true));

		// prevent mem leak shit ig
		FlxG.signals.preStateCreate.add((s) ->
		{
			cpp.vm.Gc.run(true);
			FlxG.bitmap.clearCache();
		});
	}
}
