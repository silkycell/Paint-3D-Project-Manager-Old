package classes.preset;

import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import openfl.geom.Rectangle;
import util.Util;

class Big9Slice extends FlxTypedSpriteGroup<FlxSprite>
{
	public var bg:FlxUI9SliceSprite;

	var cone:FlxSprite;
	var sphere:FlxSprite;
	var cube:FlxSprite;
	var cylinder:FlxSprite;

	public function new(width, height, color, x = 0, y = 0)
	{
		super(x, y);

		cone = new FlxSprite().loadGraphic('assets/images/9slice/cone.png');
		cone.scale.set(0.8, 0.8);
		cone.updateHitbox();
		cone.color = color;
		add(cone);

		sphere = new FlxSprite().loadGraphic('assets/images/9slice/sphere.png');
		sphere.scale.set(0.8, 0.8);
		sphere.updateHitbox();
		sphere.color = color;
		add(sphere);

		cube = new FlxSprite().loadGraphic('assets/images/9slice/cube.png');
		cube.scale.set(0.8, 0.8);
		cube.updateHitbox();
		cube.color = color;
		add(cube);

		cylinder = new FlxSprite().loadGraphic('assets/images/9slice/cylinder.png');
		cylinder.scale.set(0.8, 0.8);
		cylinder.updateHitbox();
		cylinder.color = color;
		add(cylinder);

		bg = new FlxUI9SliceSprite(0, 0, 'assets/images/9slice/9sliceBig.png', new Rectangle(0, 0, width, height), Util.bigSliceBounds);
		bg.scale.set(0.8, 0.8);
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = color;
		add(bg);

		cone.setPosition(bg.x - (cone.width / 2.3), bg.y - (cone.height / 2.3));
		sphere.setPosition(bg.x + bg.width - (sphere.width / 1.4), bg.y - (sphere.height / 2.7));
		cube.setPosition(bg.x - (cube.width / 2.6), bg.y + bg.height - (cube.height / 2.3));
		cylinder.setPosition(bg.x + bg.width - (cylinder.width / 1.6), bg.y + bg.height - (cylinder.height / 1.4));
	}
}
