package classes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import openfl.display.BitmapData;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import util.ProjectFileUtil;

class ProjectButton extends FlxTypedSpriteGroup<flixel.FlxSprite>
{
	public var defaultColor:FlxColor;
	public var project:ProjectFile;

	var bg:FlxUI9SliceSprite;

	public var checkboxSelected:Bool;
	public var checkBox:FlxSprite;

	var thumb:FlxSprite;
	var text:FlxText;

	override public function new(x:Float = 0, y:Float = 0, MaxSize:Int = 0, project:ProjectFile)
	{
		super(x, y, MaxSize);
		this.project = project;

		defaultColor = ProjectFileUtil.getProjectColor(project);

		bg = new FlxUI9SliceSprite(0, 0, Assets.getBitmapData('assets/images/roundedUi.png'), new Rectangle(0, 0, 380, 100), Util.sliceBounds);
		bg.color = defaultColor;
		add(bg);

		thumb = new FlxSprite(bg.width / 13, 0).loadGraphic(ProjectFileUtil.getThumbnail(project));
		thumb.scale.set((294 / thumb.width) * 0.4, (165 / thumb.height) * 0.4);
		thumb.updateHitbox();
		thumb.y = (bg.height / 2) - (thumb.height / 2);
		add(thumb);

		text = new FlxText(thumb.x + thumb.width + 5, 0, 155,
			(StringTools.contains(project.Path.toLowerCase(), 'workingfolder') ? '(WF) ' + project.Name : project.Name));
		text.setFormat(Util.curFont, 15, Util.contrastColor(defaultColor), FlxTextAlign.CENTER);
		text.updateHitbox();
		text.y = (bg.height / 2) - (text.height / 2);

		checkBox = new FlxSprite(bg.width);
		checkBox.frames = FlxAtlasFrames.fromSparrow(Assets.getBitmapData('assets/images/checkbox.png'), Assets.getText('assets/images/checkbox.xml'));
		checkBox.scale.set(0.3, 0.3);

		checkBox.animation.addByPrefix('check', 'boxAnim', 24, false);
		checkBox.animation.frameIndex = 0;
		checkBox.color = defaultColor;
		checkBox.updateHitbox();

		checkBox.y = (bg.height / 2) - (checkBox.height / 2);
		checkBox.x -= checkBox.width + 12;

		add(checkBox);

		add(text);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.overlaps(this))
		{
			bg.color = defaultColor.getDarkened(0.2);

			if (FlxG.mouse.overlaps(checkBox))
			{
				checkBox.color = defaultColor.getDarkened(0.2);

				if (FlxG.mouse.justReleased
					&& PlayState.instance.canInteract
					&& (PlayState.lastPressedTime < 0.2 && PlayState.lastMouseDelta.length < 5))
				{
					checkboxSelected = !checkboxSelected;
					checkBox.animation.play('check', true, !checkboxSelected);
				}
			}
			else
			{
				if (FlxG.mouse.justReleased
					&& PlayState.curSelected != project
					&& (PlayState.lastPressedTime < 0.2 && PlayState.lastMouseDelta.length < 5))
					PlayState.instance.selectProject(project);

				checkBox.color = defaultColor;
			}
		}
		else
		{
			bg.color = defaultColor;
			checkBox.color = defaultColor;
		}
	}
}
