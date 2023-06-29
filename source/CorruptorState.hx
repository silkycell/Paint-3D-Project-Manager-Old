package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import haxe.io.Bytes;
import lime.ui.FileDialog;
import sys.io.File;

class CorruptorState extends FlxState
{
	var canInteract:Bool = true;
	var infoText:FlxText;

	override public function create()
	{
		var infoText;
		super.create();

		infoText = new FlxText(0, 0, 0, 'Press G to corrupt a file', 50);
		infoText.screenCenter();
		add(infoText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!canInteract)
			return;

		if (FlxG.keys.justPressed.G)
			doit();
	}

	var byteAmount:Int = 1000;

	function doit()
	{
		var fileBytes:Bytes;
		var fDial = new FileDialog();
		fDial.onSelect.add(function(file:String)
		{
			fileBytes = File.getBytes(file);
			File.saveBytes('$file.bak', fileBytes);
			// infoText.visible = false;
			for (i in 0...byteAmount)
				fileBytes.set(FlxG.random.int(21480, fileBytes.length - 21696), fileBytes.get(FlxG.random.int(21480, fileBytes.length - 21696)));

			fDial.save(fileBytes, 'bin', file);
		});
		fDial.browse(OPEN, 'bin', PlayState._folderPath, 'Please select a Resources_Surfaces_X.bin file.');
	}
}
