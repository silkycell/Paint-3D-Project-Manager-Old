package;

import classes.MessageBox;
import classes.ProjectButton;
import classes.SideBar;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import haxe.Json;
import haxe.Timer;
import haxe.ds.StringMap;
import haxe.format.JsonPrinter;
import lime.app.Promise;
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

	public var canInteract:Bool = true;

	public static var init:Bool;
	public static var curSelected:ProjectFile;

	public static var _projects:Array<ProjectFile> = [];
	public static var _folderPath = '${Sys.getEnv("LocalAppData")}\\Packages\\Microsoft.MSPaint_8wekyb3d8bbwe\\LocalState\\Projects';

	var buttons:FlxTypedSpriteGroup<ProjectButton> = new FlxTypedSpriteGroup(10, 10);

	var github:FlxSprite;

	override public function create()
	{
		super.create();

		curSelected = null;
		_projects = [];

		FlxG.sound.soundTrayEnabled = false;
		FlxG.mouse.useSystemCursor = true;
		FlxG.autoPause = false;
		FlxG.camera.antialiasing = true;
		FlxG.watch.add(this, 'canInteract');

		gridBG = new FlxBackdrop('assets/images/grid.png');
		gridBG.antialiasing = true;
		gridBG.scale.set(2, 2);
		add(gridBG);

		sideBar = new SideBar(400);
		sideBar.instance = this;
		add(sideBar);

		add(buttons);

		github = new FlxSprite().loadGraphic("assets/images/github.png");
		github.setGraphicSize(Std.int(50));
		github.updateHitbox();
		github.antialiasing = true;
		github.y = 10;
		github.x = FlxG.width - github.width - 5;
		add(github);

		if (FlxG.save.data.projectFilePath != null && !init)
			loadJson(FlxG.save.data.projectFilePath)
		else
			showFileDialog();

		init = true;
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

		if (FlxG.mouse.overlaps(github))
		{
			github.alpha = 1;
			github.scale.x = FlxMath.lerp(github.scale.x, 0.12, 0.2);
			github.scale.y = FlxMath.lerp(github.scale.y, 0.12, 0.2);
			github.angle = FlxMath.lerp(github.angle, -5, 0.2);

			if (FlxG.mouse.justPressed)
				FlxG.openURL("https://github.com/FoxelTheFennic/Paint-3D-Project-Manager");
		}
		else
		{
			github.alpha = 0.5;
			github.scale.x = FlxMath.lerp(github.scale.x, 0.098, 0.2);
			github.scale.y = FlxMath.lerp(github.scale.y, 0.098, 0.2);
			github.angle = FlxMath.lerp(github.angle, 0, 0.2);
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
		if (!canInteract)
			return;

		trace('Loading Project File...');
		canInteract = false;
		var fDial = new FileDialog();
		fDial.onSelect.add(function(file)
		{
			canInteract = true;
			loadJson(file);
		});

		fDial.onCancel.add(function()
		{
			trace('Project File Cancelled');
			canInteract = true;
		});
		fDial.browse(FileDialogType.OPEN, 'json', _folderPath + '\\Projects.json', 'Open your Paint 3D Projects.json file.');
	}

	function loadJson(file:String)
	{
		if (!canInteract)
			return;

		try
		{
			if (!FileSystem.exists(file))
				return;

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
			FlxG.save.data.projectFilePath = projectFilePath;

			if (!FileSystem.exists(_folderPath + '\\.Bak'))
				FileSystem.createDirectory(_folderPath + '\\.Bak');

			var repeat:Int = 0;
			while (FileSystem.exists(_folderPath + '\\.Bak\\Projects.json.bak' + repeat))
				repeat += 1;

			File.saveContent(_folderPath + '\\.Bak\\Projects.json.bak' + repeat, File.getContent(file));

			_projects = ProjectFileUtil.parseProjectJson(ProjectFileUtil.removeDuplicates(Json.parse(sys.io.File.getContent(file))));

			drawButtons(_projects);
		}
		catch (e)
		{
			canInteract = true;
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

		canInteract = true;
	}

	public function selectProject(project:ProjectFile)
	{
		curSelected = project;
		gridBG.color = Util.calculateAverageColor(ProjectFileUtil.getThumbnail(project));

		sideBar.x = FlxG.width;
		sideBar.loadProject(project);

		github.color = Util.getDarkerColor(Util.calculateAverageColor(ProjectFileUtil.getThumbnail(project)), 1.3);
	}

	public function exportProjects()
	{
		if (!canInteract)
			return;

		trace('Exporting Projects...');
		canInteract = false;

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

			var messageAppend:String = '';

			for (i in projectsToExport)
			{
				if (projectsToExport.indexOf(i) != projectsToExport.length - 1)
					messageAppend += i.Name + ', ';
				else
					messageAppend += i.Name;
			}

			var message;
			openSubState(new MessageBox(Util.calculateAverageColor(ProjectFileUtil.getThumbnail(curSelected)),
				"Are you sure you want to export these projects?\n" + messageAppend, 'Yes', 'No', null, function()
			{
				persistentUpdate = true;

				message = new MessageBox(Util.calculateAverageColor(ProjectFileUtil.getThumbnail(curSelected)),
					'Exporting...\n(P3DPM may freeze multiple times throughout this, please do not be alarmed!)', '', function() {});
				for (i in message.buttons)
				{
					i.x += 54934358; // juuust in case
					i.visible = false;
				}
				openSubState(message);

				var validFileCheck:String = '';
				Timer.delay(function() // Allows for screen to update
				{
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

						filteredFilename = filteredFilename.substring(0, 260);
						var projDir = filteredFilename + ' (' + FlxG.random.int(0, 99999999) + ')';

						for (i in FileSystem.readDirectory(ProjectFileUtil.getCheckpointFolder(project)))
							validFileCheck += projDir + '\\' + i + '\n';

						projectClone.Path = 'Projects\\' + projDir;
						projectClone.URI = 'ms-appdata:///local/Projects/' + projDir + '/Thumbnail.png';
						projectClone.SourceId = '';
						projectClone.SourceFilePath = '';

						projectClones.push(projectClone);

						for (file in FileSystem.readDirectory(ProjectFileUtil.getCheckpointFolder(project)))
							exportZip.addBytes(File.getBytes(ProjectFileUtil.getCheckpointFolder(project) + '\\' + file), projDir + '\\' + file, true);
					}

					exportZip.addString(validFileCheck, 'fileCheck.txt', true);

					exportZip.addString(JsonPrinter.print(projectClones, null, '	'), "exportProjects.json", true);

					var fDial = new FileDialog();
					fDial.save(exportZip.finalize(), 'p3d', _folderPath
						+ '\\'
						+ (projectsToExport.length == 1 ? filteredFilename : "Projects")
						+ '.p3d',
						'Save your exported projects.');

					fDial.onCancel.add(function()
					{
						closeSubState();
						persistentUpdate = false;
						canInteract = true;
						trace('Project Exporting Cancelled');
						Util.sendMsgBox('File saving either errored, or was cancelled.\nIs there any programs accessing the file you were trying to save it at?');
					});

					fDial.onSave.add(function(file:String)
					{
						closeSubState();
						persistentUpdate = false;
						trace('Project Exporting Completed!');
						canInteract = true;
					});
				}, 100);
			}, function()
			{
				canInteract = true;
				return;
			}, 0x36FFFFFF));
		}
		catch (e)
		{
			canInteract = true;
			Util.sendMsgBox("Error Exporting!\n\"" + e + "\"");
		}
	}

	public function importProjects()
	{
		if (!canInteract)
			return;

		canInteract = false;

		trace('Importing Projects...');
		var fDial = new FileDialog();
		fDial.browse(FileDialogType.OPEN, 'p3d', null, 'Open a Paint 3D Project file.');
		fDial.onSelect.add(function(file)
		{
			if (!['p3d'].contains(file.split('.')[file.split('.').length - 1].toLowerCase()))
			{
				openSubState(new MessageBox(Util.calculateAverageColor(ProjectFileUtil.getThumbnail(curSelected)), 'This is not a P3D file!', 'Ok', null,
					null, function()
				{
					canInteract = true;
				}));
				return;
			}

			persistentUpdate = true;
			var message = new MessageBox(Util.calculateAverageColor(ProjectFileUtil.getThumbnail(curSelected)),
				'Importing...\n(P3DPM may freeze multiple times throughout this, please do not be alarmed!)', '', function() {});
			for (i in message.buttons)
			{
				i.x += 54934358; // juuust in case
				i.visible = false;
			}
			openSubState(message);

			Timer.delay(function() // Ditto reason as export
			{
				var entries = new StringMap<ZipEntry>();

				var zip = new ZipReader(File.getBytes(file));
				var entry:ZipEntry;

				while ((entry = zip.getNextEntry()) != null)
					entries.set(entry.fileName, entry);

				for (entry in entries.keys())
					@await zipFiles(entry, entries);

				var missingFiles:Array<String> = [];
				if (FileSystem.exists(_folderPath + '\\zipExport\\fileCheck.txt'))
				{
					for (i in File.getContent(_folderPath + '\\zipExport\\fileCheck.txt').split('\n'))
					{
						@async
						function checkMissing()
						{
							if (!FileSystem.exists(_folderPath + '\\zipExport\\' + i))
								missingFiles.push(i);
						}

						@await checkMissing();
					}
				}

				var projectFile:Array<ProjectFile> = Json.parse(File.getContent(projectFilePath));

				function continueImporting()
				{
					for (entry in entries.keys())
						@await moveFiles(entry, entries);

					Util.deleteDirRecursively(_folderPath + '\\zipExport');

					var concatJson:Array<ProjectFile> = projectFile.concat(Json.parse(File.getContent(_folderPath + '\\exportProjects.json')));

					for (project in concatJson)
					{
						if (project.Id == '-1')
							concatJson.remove(project);
					}

					FileSystem.deleteDirectory(_folderPath + '\\zipExport');
					FileSystem.deleteFile(_folderPath + '\\exportProjects.json');
					File.saveContent(_folderPath + '\\Projects.json', Json.stringify(ProjectFileUtil.removeDuplicates(concatJson)));

					canInteract = true;
					trace('Finished Importing Projects!');

					closeSubState();
					persistentUpdate = false;
					openSubState(new MessageBox(Util.calculateAverageColor(ProjectFileUtil.getThumbnail(curSelected)), 'Importing Complete!', 'Ok', null,
						null, function()
					{
						loadJson(_folderPath + '\\Projects.json');
					}));
				}

				if (missingFiles.length > 0)
				{
					openSubState(new MessageBox(Util.calculateAverageColor(ProjectFileUtil.getThumbnail(curSelected)),
						'Woah there! This project has ' + missingFiles.length +
						' missing file(s)!\nYou can continue to finish the import, but it is recommended to ask for a new export of the project.',
						'Continue', 'Cancel', null, function()
					{
						continueImporting();
					}, function()
					{
						Util.deleteDirRecursively(_folderPath + '\\zipExport');

						canInteract = true;
						return;
					}));
				}
				else
				{
					continueImporting();
				}
			}, 100);
		});

		fDial.onCancel.add(function()
		{
			canInteract = true;
		});
	}

	@async
	function zipFiles(entry:String, entries:StringMap<ZipEntry>)
	{
		var entryPath:String = '';

		for (path in entry.split('\\'))
		{
			if (entry.split('\\').indexOf(path) == entry.split('\\').length - 1)
				break;

			entryPath += path;
		}
		entryPath = '\\' + entryPath;

		if (entryPath != '\\' && !FileSystem.exists(_folderPath + '\\zipExport' + entryPath))
			FileSystem.createDirectory(_folderPath + '\\zipExport' + entryPath);

		File.saveBytes(_folderPath + '\\zipExport\\' + entry, Zip.getBytes(entries.get(entry)));
	}

	@async
	function moveFiles(entry:String, entries:StringMap<ZipEntry>)
	{
		var entryPath:String = '';

		for (path in entry.split('\\'))
		{
			if (entry.split('\\').indexOf(path) == entry.split('\\').length - 1)
				break;

			entryPath += path;
		}
		entryPath = '\\' + entryPath;

		if (entryPath != '\\' && !FileSystem.exists(_folderPath + entryPath))
			FileSystem.createDirectory(_folderPath + entryPath);

		File.saveBytes(_folderPath + '\\' + entry, File.getBytes(_folderPath + '\\zipExport\\' + entry));
	}

	public function deleteProject()
	{
		if (!canInteract)
			return;

		canInteract = false;

		var projectsToDelete:Array<ProjectFile> = [];

		for (button in buttons)
		{
			if (button.checkboxSelected)
				projectsToDelete.push(button.project);
		}

		if (projectsToDelete.length == 0)
			projectsToDelete = [curSelected];

		var messageAppend:String = '';

		for (i in projectsToDelete)
		{
			if (projectsToDelete.indexOf(i) != projectsToDelete.length - 1)
				messageAppend += i.Name + ', ';
			else
				messageAppend += i.Name;
		}

		openSubState(new MessageBox(Util.calculateAverageColor(ProjectFileUtil.getThumbnail(curSelected)),
			'Are you sure you want to delete the following projects?\n' + messageAppend, 'Yes', 'No', null, function()
		{
			openSubState(new MessageBox(Util.calculateAverageColor(ProjectFileUtil.getThumbnail(curSelected)),
				'Are you *REALLY* sure? You will not be able to recover these projects unless you made a backup!', 'Yes', 'No', null, function()
			{
				for (project in projectsToDelete)
				{
					var dir = ProjectFileUtil.getCheckpointFolder(project);
					if (FileSystem.exists(dir))
					{
						for (file in FileSystem.readDirectory(ProjectFileUtil.getCheckpointFolder(project)))
							FileSystem.deleteFile(dir + '\\' + file);

						FileSystem.deleteDirectory(dir);
					}
					_projects.remove(project);
				}

				File.saveContent(_folderPath + '\\Projects.json', Json.stringify(ProjectFileUtil.removeDuplicates(_projects)));

				openSubState(new MessageBox(Util.calculateAverageColor(ProjectFileUtil.getThumbnail(curSelected)), 'Deletion Complete!', 'Ok', null, null,
					function()
					{
						canInteract = true;
						loadJson(_folderPath + '\\Projects.json');
					}));
			}, function()
			{
				canInteract = true;
				return;
			}));
		}, function()
		{
			canInteract = true;
			return;
		}));
	}
}
