package classes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import util.ProjectFileUtil;
import util.Util;

class SideBar extends FlxTypedSpriteGroup<flixel.FlxSprite>
{
	public var instance:PlayState;
	public var project:ProjectFile;

	var texts:FlxSpriteGroup = new FlxSpriteGroup();
	var infoText:FlxText;
	var infoText2:FlxText;

	var exportButton:FlxSpriteGroup = new FlxSpriteGroup();
	var exportButtonBG:FlxSprite;
	var exportButtonText:FlxText;

	var importButton:FlxSpriteGroup = new FlxSpriteGroup();
	var importButtonBG:FlxSprite;
	var importButtonText:FlxText;

	var browseButton:FlxSpriteGroup = new FlxSpriteGroup();
	var browseButtonBG:FlxSprite;
	var browseButtonText:FlxText;

	var pathButton:FlxSpriteGroup = new FlxSpriteGroup();
	var pathButtonBG:FlxSprite;
	var pathButtonText:FlxText;

	var thumb:FlxSprite;
	var bg:FlxUI9SliceSprite;
	var defaultColor:FlxColor;

	var defaultX:Float;

	override public function new(x:Float = 0, y:Float = 0, MaxSize:Int = 0)
	{
		super(x, y, MaxSize);

		defaultX = x;
		defaultColor = FlxColor.GRAY;

		bg = new FlxUI9SliceSprite(0, 0, 'assets/images/button.png', new Rectangle(0, 0, (FlxG.width - x) + 33, FlxG.height), [33, 33, (33 * 2), (33 * 2)]);
		bg.color = defaultColor;
		add(bg);

		thumb = new FlxSprite().makeGraphic(294, 165);
		thumb.updateHitbox();
		thumb.x = bg.width - thumb.width - 43;
		thumb.y = bg.height - thumb.height - 10;

		var thumbHint = new FlxText(thumb.x, thumb.y, thumb.width, 'Thumbnail:');
		thumbHint.setFormat('assets/fonts/comic.ttf', 25, FlxColor.WHITE, FlxTextAlign.CENTER);
		thumbHint.updateHitbox();
		thumbHint.y -= thumbHint.height + 1;
		thumbHint.x += (thumb.width / 2) - (thumbHint.width / 2);

		texts.add(thumbHint);

		infoText2 = new FlxText(bg.width, 10, 300, '');
		infoText2.setFormat('assets/fonts/comic.ttf', 20, FlxColor.WHITE, FlxTextAlign.CENTER);

		texts.add(infoText2);

		infoText = new FlxText(10, 10, 500, '');
		infoText.setFormat('assets/fonts/comic.ttf', 25, FlxColor.WHITE, FlxTextAlign.CENTER);

		texts.add(infoText);

		for (text in texts.members)
			text.color = Util.getDarkerColor(defaultColor, 1.4);

		// Export

		exportButtonBG = new FlxUI9SliceSprite(0, 0, 'assets/images/button.png', new Rectangle(0, 0, 450, 150), [33, 33, (33 * 2), (33 * 2)]);
		exportButtonBG.color = defaultColor;

		exportButtonText = new FlxText(0, 0, 0, 'Export');
		exportButtonText.setFormat('assets/fonts/comic.ttf', 40, FlxColor.WHITE, FlxTextAlign.CENTER);

		exportButtonText.updateHitbox();
		exportButtonText.x = (exportButtonBG.width / 2) - (exportButtonText.width / 2);
		exportButtonText.y = (exportButtonBG.height / 2) - (exportButtonText.textField.height / 2);

		exportButton.add(exportButtonBG);
		exportButton.add(exportButtonText);

		exportButton.x = infoText.x;
		exportButton.y = bg.height - exportButtonBG.height - infoText.x;

		// Import

		importButtonBG = new FlxUI9SliceSprite(0, 0, 'assets/images/button.png', new Rectangle(0, 0, 450, 150), [33, 33, (33 * 2), (33 * 2)]);
		importButtonBG.color = defaultColor;

		importButtonText = new FlxText(0, 0, 0, 'Import');
		importButtonText.setFormat('assets/fonts/comic.ttf', 40, FlxColor.WHITE, FlxTextAlign.CENTER);

		importButtonText.updateHitbox();
		importButtonText.x = (importButtonBG.width / 2) - (importButtonText.width / 2);
		importButtonText.y = (importButtonBG.height / 2) - (importButtonText.textField.height / 2);

		importButton.add(importButtonBG);
		importButton.add(importButtonText);

		importButton.x = exportButton.x;
		importButton.y = exportButton.y - importButtonBG.height - 20;

		// Browse

		browseButtonBG = new FlxUI9SliceSprite(0, 0, 'assets/images/button.png', new Rectangle(0, 0, 450 / 2.2, 150), [33, 33, (33 * 2), (33 * 2)]);
		browseButtonBG.color = defaultColor;

		browseButtonText = new FlxText(0, 0, 0, 'Browse');
		browseButtonText.setFormat('assets/fonts/comic.ttf', 40, FlxColor.WHITE, FlxTextAlign.CENTER);

		browseButtonText.updateHitbox();
		browseButtonText.x = (browseButtonBG.width / 2) - (browseButtonText.width / 2);
		browseButtonText.y = (browseButtonBG.height / 2) - (browseButtonText.textField.height / 2);

		browseButton.add(browseButtonBG);
		browseButton.add(browseButtonText);

		browseButton.x = importButton.x;
		browseButton.y = importButton.y - browseButtonBG.height - 20;

		// Path

		pathButtonBG = new FlxUI9SliceSprite(0, 0, 'assets/images/button.png', new Rectangle(0, 0, 450 / 2.2, 150), [33, 33, (33 * 2), (33 * 2)]);
		pathButtonBG.color = defaultColor;

		pathButtonText = new FlxText(0, 0, 450 / 2.2, 'Appdata Path');
		pathButtonText.setFormat('assets/fonts/comic.ttf', 40, FlxColor.WHITE, FlxTextAlign.CENTER);

		pathButtonText.updateHitbox();
		pathButtonText.x = (pathButtonBG.width / 2) - (pathButtonText.width / 2);
		pathButtonText.y = (pathButtonBG.height / 2) - (pathButtonText.textField.height / 2);

		pathButton.add(pathButtonBG);
		pathButton.add(pathButtonText);

		pathButton.x = importButton.x + (importButton.width / 2) + (importButton.width / 23);
		pathButton.y = importButton.y - pathButtonBG.height - 20;

		add(exportButton);
		add(importButton);
		add(browseButton);
		add(pathButton);

		add(thumb);
		add(texts);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		x = FlxMath.lerp(x, defaultX, 0.2);

		if (FlxG.mouse.overlaps(exportButton))
		{
			exportButtonBG.color = Util.getDarkerColor(defaultColor, 1.2);

			if (FlxG.mouse.justPressed)
				instance.exportProjects();
		}
		else
		{
			exportButtonBG.color = defaultColor;
		}

		if (FlxG.mouse.overlaps(importButton))
		{
			importButtonBG.color = Util.getDarkerColor(defaultColor, 1.2);

			if (FlxG.mouse.justPressed)
				instance.importProjects();
		}
		else
		{
			importButtonBG.color = defaultColor;
		}

		if (FlxG.mouse.overlaps(browseButton))
		{
			browseButtonBG.color = Util.getDarkerColor(defaultColor, 1.2);

			if (FlxG.mouse.justPressed && instance.canReload)
				FlxG.resetState();
		}
		else
		{
			browseButtonBG.color = defaultColor;
		}

		if (FlxG.mouse.overlaps(pathButton))
		{
			pathButtonBG.color = Util.getDarkerColor(defaultColor, 1.2);

			if (FlxG.mouse.justPressed)
				Sys.command("explorer.exe " + PlayState._folderPath);
		}
		else
		{
			pathButtonBG.color = defaultColor;
		}
	}

	public function loadProject(project:ProjectFile)
	{
		this.project = project;
		infoText.text = "Name: "
			+ Util.ifEmptyCheck(project.Name)
			+ "\nPath: "
			+ Util.ifEmptyCheck(project.Path.substr(9))
			+ "\nSize: "
			+ Util.getDirectorySize(ProjectFileUtil.getCheckpointFolder(project));

		infoText2.text = "DateTime: " + Util.ifEmptyCheck(project.DateTime) + "\nID: " + Util.ifEmptyCheck(project.Id) + "\nSourceId: "
			+ Util.ifEmptyCheck(project.SourceId) + "\nSourceFilePath: " + Util.ifEmptyCheck(project.SourceFilePath) + "\nVersion: "
			+ Util.ifEmptyCheck(project.Version) + "\nIsRecovered: " + Util.ifEmptyCheck(project.IsRecovered) + "\nIsPreviouslySaved: "
			+ Util.ifEmptyCheck(project.IsPreviouslySaved);

		infoText2.updateHitbox();
		infoText2.x = infoText.x + infoText.textField.width + 5;

		defaultColor = Util.calculateAverageColor(ProjectFileUtil.getThumbnail(project));

		bg.color = Util.getDarkerColor(defaultColor, 0.8);

		exportButtonBG.color = defaultColor;
		exportButtonText.color = Util.getDarkerColor(defaultColor, 1.4);

		importButtonBG.color = defaultColor;
		importButtonText.color = Util.getDarkerColor(defaultColor, 1.4);

		browseButtonBG.color = defaultColor;
		browseButtonText.color = Util.getDarkerColor(defaultColor, 1.4);

		pathButtonBG.color = defaultColor;
		pathButtonText.color = Util.getDarkerColor(defaultColor, 1.4);

		for (text in texts.members)
			text.color = Util.getDarkerColor(defaultColor, 1.4);

		thumb.loadGraphic(ProjectFileUtil.getThumbnail(project));
	}
}
