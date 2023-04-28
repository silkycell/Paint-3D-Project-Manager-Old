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
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import sys.io.File;
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

	var deleteButton:FlxSpriteGroup = new FlxSpriteGroup();
	var deleteButtonBG:FlxSprite;
	var deleteButtonText:FlxText;

	var browseButton:FlxSpriteGroup = new FlxSpriteGroup();
	var browseButtonBG:FlxSprite;
	var browseButtonText:FlxText;

	var pathButton:FlxSpriteGroup = new FlxSpriteGroup();
	var pathButtonBG:FlxSprite;
	var pathButtonText:FlxText;

	var thumb:Thumbnail;
	var bg:FlxUI9SliceSprite;
	var defaultColor:FlxColor;

	var defaultX:Float;

	override public function new(x:Float = 0, y:Float = 0, MaxSize:Int = 0, instance:PlayState)
	{
		super(x, y, MaxSize);

		this.instance = instance;

		defaultX = x;
		defaultColor = FlxColor.GRAY;

		bg = new FlxUI9SliceSprite(0, 0, 'assets/images/9slice/9sliceSmall.png', new Rectangle(0, 0, (FlxG.width - x) + 33, FlxG.height),
			Util.sliceSmallBounds);
		bg.color = defaultColor;
		add(bg);

		thumb = new Thumbnail(instance);
		thumb.thumbnail.updateHitbox();
		thumb.thumbnail.x = bg.width - thumb.thumbnail.width - 43;
		thumb.thumbnail.y = bg.height - thumb.thumbnail.height - 10;

		var thumbHint = new FlxText(thumb.thumbnail.x, thumb.thumbnail.y, thumb.thumbnail.width, 'Thumbnail:');
		thumbHint.setFormat('assets/fonts/comic.ttf', 25, FlxColor.WHITE, FlxTextAlign.CENTER);
		thumbHint.updateHitbox();
		thumbHint.y -= thumbHint.height + 1;
		thumbHint.x += (thumb.thumbnail.width / 2) - (thumbHint.width / 2);

		texts.add(thumbHint);

		infoText2 = new FlxText(bg.width, 10, 300, '');
		infoText2.setFormat('assets/fonts/comic.ttf', 20, FlxColor.WHITE, FlxTextAlign.CENTER);

		texts.add(infoText2);

		infoText = new FlxText(10, 10, 500, '');
		infoText.setFormat('assets/fonts/comic.ttf', 25, FlxColor.WHITE, FlxTextAlign.CENTER);

		texts.add(infoText);

		for (text in texts.members)
			text.color = Util.colorCheck(defaultColor, bg.color);

		// Export

		exportButtonBG = new FlxUI9SliceSprite(0, 0, 'assets/images/9slice/9sliceSmall.png', new Rectangle(0, 0, 450, 150), Util.sliceSmallBounds);
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

		importButtonBG = new FlxUI9SliceSprite(0, 0, 'assets/images/9slice/9sliceSmall.png', new Rectangle(0, 0, 450 / 2.2, 150), Util.sliceSmallBounds);
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

		// Delete

		deleteButtonBG = new FlxUI9SliceSprite(0, 0, 'assets/images/9slice/9sliceSmall.png', new Rectangle(0, 0, 450 / 2.2, 150), Util.sliceSmallBounds);
		deleteButtonBG.color = defaultColor;

		deleteButtonText = new FlxText(0, 0, 0, 'Delete');
		deleteButtonText.setFormat('assets/fonts/comic.ttf', 40, FlxColor.WHITE, FlxTextAlign.CENTER);

		deleteButtonText.updateHitbox();
		deleteButtonText.x = (deleteButtonBG.width / 2) - (deleteButtonText.width / 2);
		deleteButtonText.y = (deleteButtonBG.height / 2) - (deleteButtonText.textField.height / 2);

		deleteButton.add(deleteButtonBG);
		deleteButton.add(deleteButtonText);

		deleteButton.x = exportButton.x + (exportButton.width / 2) + (exportButton.width / 23);
		deleteButton.y = exportButton.y - deleteButtonBG.height - 20;

		// Browse

		browseButtonBG = new FlxUI9SliceSprite(0, 0, 'assets/images/9slice/9sliceSmall.png', new Rectangle(0, 0, 450 / 2.2, 150), Util.sliceSmallBounds);
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

		pathButtonBG = new FlxUI9SliceSprite(0, 0, 'assets/images/9slice/9sliceSmall.png', new Rectangle(0, 0, 450 / 2.2, 150), Util.sliceSmallBounds);
		pathButtonBG.color = defaultColor;

		pathButtonText = new FlxText(0, 0, 450 / 2.2, 'Appdata Path');
		pathButtonText.setFormat('assets/fonts/comic.ttf', 40, FlxColor.WHITE, FlxTextAlign.CENTER);

		pathButtonText.updateHitbox();
		pathButtonText.x = (pathButtonBG.width / 2) - (pathButtonText.width / 2);
		pathButtonText.y = (pathButtonBG.height / 2) - (pathButtonText.textField.height / 2);

		pathButton.add(pathButtonBG);
		pathButton.add(pathButtonText);

		pathButton.x = exportButton.x + (exportButton.width / 2) + (exportButton.width / 23);
		pathButton.y = importButton.y - pathButtonBG.height - 20;

		add(exportButton);
		add(importButton);
		add(deleteButton);
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

			if (FlxG.mouse.justPressed && instance.canInteract)
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
				Sys.command("explorer.exe " + '${Sys.getEnv("LocalAppData")}\\Packages\\Microsoft.MSPaint_8wekyb3d8bbwe\\LocalState\\Projects');
		}
		else
		{
			pathButtonBG.color = defaultColor;
		}

		if (FlxG.mouse.overlaps(deleteButton))
		{
			deleteButtonBG.color = Util.getDarkerColor(defaultColor, 1.2);

			if (FlxG.mouse.justPressed && instance.canInteract)
				instance.deleteProject();
		}
		else
		{
			deleteButtonBG.color = defaultColor;
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
			+ Util.getDirectorySize(ProjectFileUtil.getCheckpointFolder(project))
			+ 'MB';

		infoText2.text = "DateTime: " + Util.getProjectDate(project.DateTime) + "\nID: " + Util.ifEmptyCheck(project.Id) + "\nSourceId: "
			+ Util.ifEmptyCheck(project.SourceId) + "\nSourceFilePath: " + Util.ifEmptyCheck(project.SourceFilePath) + "\nVersion: "
			+ Util.ifEmptyCheck(project.Version) + "\nIsRecovered: " + Util.ifEmptyCheck(project.IsRecovered) + "\nIsPreviouslySaved: "
			+ Util.ifEmptyCheck(project.IsPreviouslySaved);

		infoText2.updateHitbox();
		infoText2.x = infoText.x + infoText.textField.width + 5;

		defaultColor = Util.calculateAverageColor(ProjectFileUtil.getThumbnail(project));

		bg.color = Util.getDarkerColor(defaultColor, 0.8);

		exportButtonBG.color = Util.colorCheck(Util.getDarkerColor(defaultColor, 1.3), defaultColor);
		exportButtonText.color = Util.colorCheck(Util.getDarkerColor(defaultColor, 0.8), exportButtonBG.color);

		importButtonBG.color = Util.colorCheck(Util.getDarkerColor(defaultColor, 1.3), defaultColor);
		importButtonText.color = Util.colorCheck(Util.getDarkerColor(defaultColor, 0.8), importButtonBG.color);

		deleteButtonBG.color = Util.colorCheck(Util.getDarkerColor(defaultColor, 1.3), defaultColor);
		deleteButtonText.color = Util.colorCheck(Util.getDarkerColor(defaultColor, 0.8), deleteButtonBG.color);

		browseButtonBG.color = Util.colorCheck(Util.getDarkerColor(defaultColor, 1.3), defaultColor);
		browseButtonText.color = Util.colorCheck(Util.getDarkerColor(defaultColor, 0.8), browseButtonBG.color);

		pathButtonBG.color = Util.colorCheck(Util.getDarkerColor(defaultColor, 1.3), defaultColor);
		pathButtonText.color = Util.colorCheck(Util.getDarkerColor(defaultColor, 0.8), pathButtonBG.color);

		for (text in texts.members)
			text.color = Util.colorCheck(Util.getDarkerColor(defaultColor, 1.2), bg.color);

		thumb.thumbnail.loadGraphic(ProjectFileUtil.getThumbnail(project));
		thumb.thumbnail.scale.set(294 / thumb.thumbnail.width, 165 / thumb.thumbnail.height);
		thumb.thumbnail.updateHitbox();
	}
}

class Thumbnail extends FlxTypedSpriteGroup<FlxSprite>
{
	public var thumbnail:FlxSprite;

	var greyOverlay:FlxSpriteGroup;
	var instance:PlayState;

	public function new(instance:PlayState, x:Float = 0, y:Float = 0, maxSize:Int = 0)
	{
		super(x, y, maxSize);

		this.instance = instance;

		thumbnail = new FlxSprite().makeGraphic(294, 165);
		add(thumbnail);

		greyOverlay = new FlxSpriteGroup();
		greyOverlay.alpha = 0;
		add(greyOverlay);

		var grey = new FlxSprite().makeGraphic(294, 165, FlxColor.BLACK);
		greyOverlay.add(grey);

		var uploadIcon = new FlxSprite().loadGraphic("assets/images/upload.png");
		uploadIcon.scale.set(.6, .6);
		uploadIcon.updateHitbox();
		uploadIcon.x = (grey.width / 2) - (uploadIcon.width / 2);
		uploadIcon.y = (grey.height / 2) - (uploadIcon.height / 2);
		greyOverlay.add(uploadIcon);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.overlaps(greyOverlay) && instance.canInteract)
		{
			greyOverlay.alpha = 0.5;

			if (FlxG.mouse.justPressed)
			{
				instance.canInteract = false;
				var fDial = new FileDialog();
				fDial.onSelect.add(function(file:String)
				{
					File.saveBytes(ProjectFileUtil.getCheckpointFolder(PlayState.curSelected) + '\\Thumbnail.png', File.getBytes(file));

					instance.canInteract = true;
					instance.loadJson(instance.projectFilePath);
				});
				fDial.onCancel.add(function()
				{
					instance.canInteract = true;
				});
				fDial.browse(FileDialogType.OPEN, 'png', null, "Select a PNG file to replace this project's thumbnail.");
			}
		}
		else
		{
			greyOverlay.alpha = 0;
		}

		greyOverlay.setPosition(thumbnail.x, thumbnail.y);
	}
}
