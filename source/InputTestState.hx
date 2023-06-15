package;

import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIState;

class InputTestState extends FlxUIState
{
	override public function create()
	{
		super.create();

		var input = new FlxUIInputText(0, 0, 300, 'Search', 15);
		input.screenCenter();
		add(input);
	}
}
