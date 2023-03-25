package;

import classes.ProjectButton;
import classes.SideBar;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import haxe.Json;
import haxe.ds.StringMap;
import haxe.format.JsonPrinter;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import lime.utils.Resource;
import sys.FileSystem;
import sys.io.File;
import util.ProjectFileUtil;
import util.Util;
import zip.Zip;
import zip.ZipEntry;
import zip.ZipReader;
import zip.ZipWriter;

class PlayState extends FlxState
{
	var gridBG:FlxBackdrop;
	var sideBar:SideBar;
	var projectFilePath:String;

	public var canReload:Bool = true;

	public static var curSelected:ProjectFile;

	public static var _projects:Array<ProjectFile> = [];
	public static var _folderPath = '${Sys.getEnv("LocalAppData")}\\Packages\\Microsoft.MSPaint_8wekyb3d8bbwe\\LocalState\\Projects';

	var buttons:FlxTypedSpriteGroup<ProjectButton> = new FlxTypedSpriteGroup(10, 10);

	override public function create()
	{
		super.create();

		curSelected = null;
		_projects = [];

		FlxG.sound.soundTrayEnabled = false;
		FlxG.mouse.useSystemCursor = true;
		FlxG.autoPause = false;
		FlxG.camera.antialiasing = true;
		FlxG.watch.add(this, 'canReload');

		gridBG = new FlxBackdrop('assets/images/grid.png');
		gridBG.antialiasing = true;
		gridBG.scale.set(2, 2);
		add(gridBG);

		sideBar = new SideBar(400);
		sideBar.instance = this;
		add(sideBar);

		add(buttons);
		showFileDialog();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.screenX < 400)
		{
			if (buttons.y > 0 && FlxG.mouse.wheel > 0)
				return;

			buttons.y += (FlxG.mouse.wheel * 50);
		}

		if (FlxG.keys.justPressed.S)
		{
			for (button in buttons)
			{
				button.checkboxSelected = !button.checkboxSelected;
				button.checkBox.animation.play('check', true, !button.checkboxSelected);
			}
		}

		#if debug
		if (FlxG.keys.pressed.MINUS)
			FlxG.camera.zoom -= 0.01;

		if (FlxG.keys.pressed.PLUS)
			FlxG.camera.zoom += 0.01;

		if (FlxG.keys.pressed.BACKSPACE)
			FlxG.camera.zoom = 1;
		#end

		gridBG.x += 0.2;
		gridBG.y += 0.2;
	}

	function showFileDialog()
	{
		if (!canReload)
			return;

		trace('Loading Project File...');
		canReload = false;
		var fDial = new FileDialog();
		fDial.onSelect.add(function(file)
		{
			canReload = true;
			loadJson(file);
		});

		fDial.onCancel.add(function()
		{
			trace('Project File Cancelled');
			canReload = true;
		});
		fDial.browse(FileDialogType.OPEN, 'json', _folderPath + '\\Projects.json', 'Open your Paint 3D Projects.json file.');
	}

	function loadJson(file:String)
	{
		if (!canReload)
			return;

		try
		{
			var pathArray = file.split('\\');
			pathArray.pop();

			_folderPath = '';

			for (i in pathArray)
			{
				if (pathArray.indexOf(i) != pathArray.length - 1)
					_folderPath += i + "\\";
				else
					_folderPath += i;
			}

			projectFilePath = file;
			_projects = ProjectFileUtil.parseProjectJson(ProjectFileUtil.removeDuplicates(Json.parse(sys.io.File.getContent(file))));

			drawButtons(_projects);
		}
		catch (e)
		{
			canReload = true;
			Util.sendMsgBox("Error Parsing Json!\n\"" + e + "\"");
		}
	}

	function drawButtons(projects:Array<ProjectFile>)
	{
		for (button in buttons)
		{
			button.destroy();
			buttons.remove(button);
		}

		for (project in projects)
		{
			var index = projects.indexOf(project);
			var button = new ProjectButton(0, (110 * index), 0, project);
			button.instance = this;

			buttons.add(button);
		}

		selectProject(projects[0]);

		trace('Finished loading Project File!');

		canReload = true;
	}

	public function selectProject(project:ProjectFile)
	{
		curSelected = project;
		gridBG.color = Util.calculateAverageColor(ProjectFileUtil.getThumbnail(project));

		sideBar.x = FlxG.width;
		sideBar.loadProject(project);
	}

	public function exportProjects()
	{
		if (!canReload)
			return;

		trace('Exporting Projects...');
		canReload = false;

		try
		{
			var projectsToExport:Array<ProjectFile> = [];
			var projectClones:Array<ProjectFile> = [];

			for (button in buttons)
			{
				if (button.checkboxSelected)
					projectsToExport.push(button.project);
			}

			if (projectsToExport.length == 0)
				projectsToExport = [curSelected];

			var exportZip = new ZipWriter();
			var filteredFilename = '';

			for (project in projectsToExport)
			{
				filteredFilename = '';
				var projectClone = Reflect.copy(project);

				if (StringTools.contains(projectClone.Path.toLowerCase(), 'workingfolder'))
					projectClone.Name = '(WF) ' + projectClone.Name;

				for (letter in projectClone.Name.split(''))
				{
					if (ProjectFileUtil.disallowedChars.contains(letter))
						letter = '_';

					filteredFilename += letter;
				}

				var projDir = filteredFilename + ' (' + FlxG.random.int(0, 99999999) + ')';

				projectClone.Path = 'Projects\\' + projDir;
				projectClone.URI = 'ms-appdata:///local/Projects/' + projDir + '/Thumbnail.png';
				projectClone.SourceId = '';
				projectClone.SourceFilePath = '';

				projectClones.push(projectClone);

				for (file in FileSystem.readDirectory(ProjectFileUtil.getCheckpointFolder(project)))
					exportZip.addBytes(File.getBytes(ProjectFileUtil.getCheckpointFolder(project) + '\\' + file), projDir + '\\' + file, true);
			}

			exportZip.addString(JsonPrinter.print(projectClones, null, '	'), "exportProjects.json", true);

			var fDial = new FileDialog();
			fDial.save(exportZip.finalize(), 'p3d', _folderPath
				+ '\\'
				+ (projectsToExport.length == 1 ? filteredFilename : "Projects")
				+ '.p3d',
				'Save your exported projects.');

			fDial.onCancel.add(function()
			{
				canReload = true;
				trace('Project Exporting Cancelled');
				Util.sendMsgBox('File saving either errored, or was cancelled.\nIs there any programs accessing the file you were trying to save it at?');
			});

			fDial.onSave.add(function(file:String)
			{
				trace('Project Exporting Completed!');
				canReload = true;
			});
		}
		catch (e)
		{
			canReload = true;
			Util.sendMsgBox("Error Exporting!\n\"" + e + "\"");
		}
	}

	public function importProjects()
	{
		if (!canReload)
			return;

		trace('Importing Projects...');
		canReload = false;

		try
		{
			var fDial = new FileDialog();
			fDial.browse(FileDialogType.OPEN, 'p3d', null, 'Open a Paint 3D Project file.');
			fDial.onSelect.add(function(file)
			{
				// this is an array because i may add more support for file types later
				if (!['p3d'].contains(file.split('.')[file.split('.').length - 1].toLowerCase()))
				{
					Util.sendMsgBox('This is not a P3D file!');
					canReload = true;
					return;
				}

				var entries = new StringMap<ZipEntry>();

				var zip = new ZipReader(File.getBytes(file));
				var entry:ZipEntry;

				while ((entry = zip.getNextEntry()) != null)
					entries.set(entry.fileName, entry);

				if (entries.get('exportProject.json') == null)
				{
					Util.sendMsgBox('This is not a P3D file!\n(exportProject.json could not be found.)');
					canReload = true;
					return;
				}

				for (entry in entries.keys())
				{
					var entryPath:String = '';

					for (path in entry.split('\\'))
					{
						if (entry.split('\\').indexOf(path) == entry.split('\\').length - 1)
							break;

						entryPath += path;
					}
					entryPath = '\\' + entryPath;

					if (entryPath != '' && !FileSystem.exists(_folderPath + entryPath))
						FileSystem.createDirectory(_folderPath + entryPath);

					File.saveBytes(_folderPath + '\\' + entry, Zip.getBytes(entries.get(entry)));
				}

				var projectFile:Array<ProjectFile> = Json.parse(File.getContent(projectFilePath));
				var exportJson:Array<ProjectFile> = Json.parse(File.getContent(_folderPath + '\\exportProjects.json'));
				var concatJson:Array<ProjectFile> = projectFile.concat(exportJson);

				for (project in concatJson)
				{
					if (project.Id == '-1')
						concatJson.remove(project);
				}

				File.saveContent(_folderPath + '\\Projects.json', Json.stringify(ProjectFileUtil.removeDuplicates(concatJson)));
				FileSystem.deleteFile(_folderPath + '\\exportProjects.json');

				loadJson(_folderPath + '\\Projects.json');
				canReload = true;
				trace('Finished Importing Projects!');
			});

			fDial.onCancel.add(function()
			{
				canReload = true;
			});
		}
		catch (e)
		{
			canReload = true;
			Util.sendMsgBox("Error Importing!\n\"" + e + "\"");
		}
	}
}
