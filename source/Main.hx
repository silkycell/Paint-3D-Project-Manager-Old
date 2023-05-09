package;

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
			cpp.vm.Gc.run(false);
			cpp.vm.Gc.run(true);
			cpp.vm.Gc.compact();
			cpp.vm.Gc.run(false);
			FlxG.bitmap.clearCache();
		});
	}
}
