package classes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import openfl.display.BitmapData;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import util.ProjectFileUtil;
import util.Util;

class ProjectButton extends FlxTypedSpriteGroup<flixel.FlxSprite>
{
	public var instance:PlayState;
	public var project:ProjectFile;
	public var checkboxSelected:Bool;

	public var checkBox:FlxSprite;

	var thumb:FlxSprite;
	var bg:FlxUI9SliceSprite;
	var text:FlxText;
	var defaultColor:FlxColor;

	override public function new(x:Float = 0, y:Float = 0, MaxSize:Int = 0, project:ProjectFile)
	{
		super(x, y, MaxSize);
		this.project = project;

		defaultColor = Util.calculateAverageColor(ProjectFileUtil.getThumbnail(project));

		bg = new FlxUI9SliceSprite(0, 0, 'assets/images/button.png', new Rectangle(0, 0, 380, 100), [33, 33, (33 * 2), (33 * 2)]);
		bg.color = defaultColor;
		add(bg);

		thumb = new FlxSprite(bg.width / 13, 0).loadGraphic(ProjectFileUtil.getThumbnail(project));
		thumb.scale.set((294 / thumb.width) * 0.4, (165 / thumb.height) * 0.4);
		thumb.updateHitbox();
		thumb.y = (bg.height / 2) - (thumb.height / 2);
		add(thumb);

		text = new FlxText(thumb.x + thumb.width + .5, 0, 150,
			(StringTools.contains(project.Path.toLowerCase(), 'workingfolder') ? '(WF) ' + project.Name : project.Name));
		text.setFormat('assets/fonts/comic.ttf', 15, Util.getDarkerColor(defaultColor, 1.4), FlxTextAlign.CENTER);
		text.updateHitbox();
		text.y = (bg.height / 2) - (text.textField.height / 2);

		checkBox = new FlxSprite(bg.width);
		checkBox.frames = FlxAtlasFrames.fromSparrow('assets/images/checkbox.png', 'assets/images/checkbox.xml');
		checkBox.scale.set(0.3, 0.3);

		checkBox.animation.addByPrefix('check', 'boxAnim', 24, false);
		checkBox.animation.frameIndex = 1;
		checkBox.color = defaultColor;
		checkBox.updateHitbox();

		checkBox.y = (bg.height / 2) - (checkBox.height / 2) - (checkBox.height / 12.5);
		checkBox.x -= checkBox.width + 8;

		add(checkBox);

		add(text);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.overlaps(this))
		{
			bg.color = Util.getDarkerColor(defaultColor, 1.2);

			if (FlxG.mouse.overlaps(checkBox))
			{
				checkBox.color = Util.getDarkerColor(defaultColor, 1.2);

				if (FlxG.mouse.justPressed && instance.canInteract)
				{
					checkboxSelected = !checkboxSelected;
					checkBox.animation.play('check', true, !checkboxSelected);
				}
			}
			else
			{
				if (FlxG.mouse.justPressed && PlayState.curSelected != project)
					instance.selectProject(project);

				checkBox.color = defaultColor;
			}
		}
		else
		{
			bg.color = defaultColor;
		}
	}
}
