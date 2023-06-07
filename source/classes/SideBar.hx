package classes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import lime.graphics.Image;
import lime.graphics.ImageFileFormat;
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
	var project:ProjectFile;

	var texts:FlxSpriteGroup = new FlxSpriteGroup();
	var infoText:FlxText;
	var infoText2:FlxText;

	var exportButton:SideBarButton;
	var importButton:SideBarButton;
	var deleteButton:SideBarButton;
	var browseButton:SideBarButton;
	var pathButton:SideBarButton;

	var thumb:Thumbnail;
	var bg:FlxUI9SliceSprite;
	var defaultColor:FlxColor;

	var defaultX:Float;

	var thumbHint:FlxText;

	override public function new(x:Float = 0, y:Float = 0, MaxSize:Int = 0)
	{
		super(x, y, MaxSize);

		defaultX = x;
		defaultColor = FlxColor.GRAY;

		bg = new FlxUI9SliceSprite(0, 0, 'assets/images/roundedUi.png', new Rectangle(0, 0, (FlxG.width - x) + 33, FlxG.height), Util.sliceBounds);
		bg.color = defaultColor;
		add(bg);

		thumb = new Thumbnail();
		thumb.thumbnail.updateHitbox();
		thumb.thumbnail.x = bg.width - thumb.thumbnail.width - 43;
		thumb.thumbnail.y = bg.height - thumb.thumbnail.height - 10;

		thumbHint = new FlxText(thumb.thumbnail.x, thumb.thumbnail.y, 350, 'Thumbnail:');
		thumbHint.setFormat('assets/fonts/comic.ttf', 25, FlxColor.WHITE, FlxTextAlign.CENTER);
		thumbHint.updateHitbox();
		thumbHint.y -= thumbHint.height + 1;
		thumbHint.x += (thumb.thumbnail.width / 2) - (thumbHint.width / 2);

		texts.add(thumbHint);

		infoText2 = new FlxText(bg.width, 10, 350);
		infoText2.setFormat('assets/fonts/comic.ttf', 18, FlxColor.WHITE, FlxTextAlign.CENTER);

		texts.add(infoText2);

		infoText = new FlxText(10, 10, 450);
		infoText.setFormat('assets/fonts/comic.ttf', 25, FlxColor.WHITE, FlxTextAlign.CENTER);

		texts.add(infoText);

		// Buttons
		exportButton = new SideBarButton(infoText.x, bg.height - 150 - infoText.x, 450, 150, 'Export', defaultColor);
		exportButton.callback = function() PlayState.instance.exportProjects();

		importButton = new SideBarButton(exportButton.x, bg.height - 320 - infoText.x, 450 / 2.1, 150, 'Import', defaultColor);
		importButton.callback = function() PlayState.instance.importProjects();

		deleteButton = new SideBarButton(exportButton.x + (exportButton.width / 2) + (exportButton.width / 23), importButton.y, 450 / 2.1, 150, 'Delete',
			defaultColor);
		deleteButton.callback = function() PlayState.instance.deleteProject();

		browseButton = new SideBarButton(importButton.x, importButton.y - 150 - 20, 450 / 2.1, 150, 'Change Projects.json', defaultColor, 30);
		browseButton.callback = function() PlayState.instance.showFileDialog();

		pathButton = new SideBarButton(deleteButton.x, importButton.y - 150 - 20, 450 / 2.1, 150, 'Appdata Path', defaultColor);
		pathButton.callback = function() Sys.command("explorer.exe "
			+ '${Sys.getEnv("LocalAppData")}\\Packages\\Microsoft.MSPaint_8wekyb3d8bbwe\\LocalState\\Projects');

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

		x = Util.lerp(x, defaultX, 0.2);
	}

	public function loadProject(project:ProjectFile)
	{
		this.project = project;
		infoText.text = "Name: "
			+ Util.ifEmptyCheck(project.Name)
			+ "\nPath: "
			+ Util.ifEmptyCheck(project.Path.substr(9))
			+ "\nSize: "
			+ FlxStringUtil.formatBytes(ProjectFileUtil.getProjectSize(project), 2)
			+ "\nLast Modified: "
			+ ProjectFileUtil.getProjectDate(project.DateTime);

		infoText.updateHitbox();

		Util.centerInRect(infoText, FlxRect.weak(exportButton.bg.x, 0, exportButton.bg.width, browseButton.bg.y));

		infoText2.text = "ID: " + Util.ifEmptyCheck(project.Id);

		if (StringTools.contains(project.Path.toLowerCase(), 'workingfolder'))
			infoText2.text += "\nSource ID: " + Util.ifEmptyCheck(project.SourceId) + "\nSourceFilePath: " + Util.ifEmptyCheck(project.SourceFilePath);

		infoText2.text += "\nProject Version " + Util.ifEmptyCheck(project.Version) + "\nIsRecovered: " + Util.ifEmptyCheck(project.IsRecovered)
			+ "\nIsPreviouslySaved: " + Util.ifEmptyCheck(project.IsPreviouslySaved) + "\nObject Count: "
			+ Util.ifEmptyCheck(ProjectFileUtil.getObjectCount(project));

		infoText2.updateHitbox();

		// I HATE HAXE AUTOFORMATIING WHAT IS THIS
		Util.centerInRect(infoText2,
			FlxRect.weak(exportButton.bg.x
				+ exportButton.bg.width, 20, FlxG.width
				- exportButton.bg.x
				+ exportButton.bg.width, thumb.thumbnail.y
				- 25));

		defaultColor = ProjectFileUtil.getCurrentColor(project);

		bg.color = defaultColor.getDarkened(0.4);

		for (e in [exportButton, importButton, deleteButton, browseButton, pathButton])
			e.defaultColor = defaultColor;

		updateTextColors();

		thumb.thumbnail.loadGraphic(ProjectFileUtil.getThumbnail(project));
		thumb.thumbnail.setGraphicSize(294, 165);
		thumb.thumbnail.updateHitbox();

		var tempRect:FlxRect = FlxRect.get(exportButton.bg.x + exportButton.bg.width, exportButton.bg.y, 425, 1);
		tempRect.bottom = FlxG.height - 75;

		// yeaah
		Util.centerInRect(thumb.thumbnail, tempRect);
		Util.centerInRect(thumb.greyOverlay, tempRect);
		Util.centerInRect(thumb.buttonBG, tempRect);

		tempRect.put();

		thumbHint.y = thumb.buttonBG.y - thumbHint.height - 5;
		thumbHint.x = thumb.buttonBG.x + ((thumb.buttonBG.width - thumbHint.width) / 2);

		thumb.updateColor();
	}

	public function updateTextColors()
	{
		for (b in texts.members)
			b.color = Util.contrastColor(bg.color);

		for (b in [exportButton, importButton, deleteButton, browseButton, pathButton])
			b.text.color = Util.contrastColor(b.defaultColor);
	}
}

class SideBarButton extends FlxSpriteGroup
{
	public var bg:FlxSprite;
	public var text:FlxText;
	public var defaultColor:FlxColor;
	public var callback:Void->Void;

	public function new(x:Float = 0, y:Float = 0, width:Float = 1, height:Float = 1, str:String = '', col:FlxColor = FlxColor.WHITE, fontSize:Int = 40)
	{
		super();
		bg = new FlxUI9SliceSprite(0, 0, 'assets/images/roundedUi.png', new Rectangle(0, 0, width, height), Util.sliceBounds);

		text = new FlxText(0, 0, width, str);
		text.setFormat('assets/fonts/comic.ttf', fontSize, FlxColor.WHITE, FlxTextAlign.CENTER);
		text.updateHitbox();
		Util.centerInRect(text, FlxRect.weak(bg.x, bg.y, bg.width, bg.height));

		add(bg);
		add(text);

		this.x = x;
		this.y = y;

		defaultColor = col;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.overlaps(this))
		{
			bg.color = defaultColor.getDarkened(0.24);

			if (FlxG.mouse.justReleased && PlayState.instance.canInteract)
				callback();
		}
		else
		{
			bg.color = defaultColor;
		}
	}
}

class Thumbnail extends FlxTypedSpriteGroup<FlxSprite>
{
	public var thumbnail:FlxSprite;

	public var greyOverlay:FlxSpriteGroup;
	public var buttonBG:FlxSprite;

	public function new(x:Float = 0, y:Float = 0, maxSize:Int = 0)
	{
		super(x, y, maxSize);

		buttonBG = new FlxUI9SliceSprite(0, 0, 'assets/images/roundedUi.png', new Rectangle(0, 0, 294 + 40, 165 + 40), Util.sliceBounds);
		updateColor();
		add(buttonBG);

		thumbnail = new FlxSprite().makeGraphic(1, 1);
		thumbnail.setGraphicSize(294, 165);
		thumbnail.updateHitbox();
		add(thumbnail);

		greyOverlay = new FlxSpriteGroup();
		greyOverlay.alpha = 0;
		add(greyOverlay);

		var grey = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		grey.setGraphicSize(294, 165);
		grey.updateHitbox();
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

		if (FlxG.mouse.overlaps(greyOverlay) && PlayState.instance.canInteract)
		{
			greyOverlay.alpha = 0.5;

			if (FlxG.mouse.justReleased)
			{
				PlayState.instance.canInteract = false;
				var fDial = new FileDialog();
				fDial.onSelect.add(function(file:String)
				{
					var newThumb = Image.fromFile(file);
					newThumb.resize(294, 165);
					File.saveBytes(ProjectFileUtil.getCheckpointFolder(PlayState.curSelected) + '\\Thumbnail.png', newThumb.encode(ImageFileFormat.PNG));

					PlayState.instance.canInteract = true;
					PlayState.instance.loadJson(PlayState.instance.projectFilePath);
				});
				fDial.onCancel.add(function()
				{
					PlayState.instance.canInteract = true;
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

	public inline function updateColor()
	{
		buttonBG.color = ProjectFileUtil.getCurrentColor(PlayState.curSelected);
	}
}
