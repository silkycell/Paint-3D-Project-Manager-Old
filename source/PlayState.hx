package;

import classes.MessageBox;
import classes.ProjectButton;
import classes.SideBar;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import haxe.Json;
import haxe.Timer;
import haxe.ds.StringMap;
import haxe.format.JsonPrinter;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;
import util.Discord;
import util.ProjectFileUtil;
import util.Util;
import zip.Zip;
import zip.ZipEntry;
import zip.ZipReader;
import zip.ZipWriter;

using StringTools;

class PlayState extends FlxState
{
	public static var version:String = '0.1.4b';

	var gridBG:FlxBackdrop;
	var sideBar:SideBar;

	public var projectFilePath:String;
	public var canInteract:Bool = true;

	static var init:Bool;
	public static var curSelected:ProjectFile;

	public static var colorArray:Array<Null<FlxColor>> = [];
	public static var sizeArray:Array<Null<Float>> = [];
	public static var thumbnailPool:Map<ProjectFile, BitmapData> = [];

	public static var _projects:Array<ProjectFile> = [];
	public static var _folderPath = '${Sys.getEnv("LocalAppData")}\\Packages\\Microsoft.MSPaint_8wekyb3d8bbwe\\LocalState\\Projects';

	var buttons:FlxTypedSpriteGroup<ProjectButton> = new FlxTypedSpriteGroup(10, 10);

	var github:FlxSprite;

	var buttonsTargetY:Float = -15;
	var lastPresses:Array<FlxKey> = [];

	override public function create()
	{
		super.create();

		curSelected = null;
		_projects = [];

		FlxG.sound.soundTrayEnabled = FlxG.autoPause = false;
		FlxG.mouse.useSystemCursor = FlxG.camera.antialiasing = true;
		FlxG.watch.add(this, 'canInteract');

		if (FlxG.save.data.darkModeEnabled == null)
			FlxG.save.data.darkModeEnabled = false;

		if (!init)
			Discord.initialize();

		gridBG = new FlxBackdrop('assets/images/grid.png');
		gridBG.antialiasing = false;
		gridBG.scale.set(4, 4);
		add(gridBG);

		sideBar = new SideBar(400, 0, 0, this);
		add(sideBar);

		add(buttons);

		github = new FlxSprite().loadGraphic("assets/images/github.png");
		github.setGraphicSize(50);
		github.updateHitbox();
		github.antialiasing = true;
		github.y = 25;
		github.x = FlxG.width - github.width - 15;
		add(github);

		function doFirstLoad()
		{
			function loadData()
			{
				if (FlxG.save.data.projectFilePath != null)
				{
					loadJson(FlxG.save.data.projectFilePath);
				}
				else
				{
					if (!FileSystem.exists(_folderPath)) // this should never happen, i think
						showFileDialog();
					else
						loadJson(_folderPath + '\\Projects.json');
				}
			}

			#if !debug
			if (!init)
			{
				var http = new haxe.Http("https://raw.githubusercontent.com/FoxelTheFennic/Paint-3D-Project-Manager/main/version.txt");

				http.onData = function(data:String)
				{
					if (!StringTools.contains(data, version))
					{
						trace('version online: ' + data + ', your version: ' + version);
						openSubState(new MessageBox(FlxColor.GRAY,
							'Hold on,  you\'re on an outdated version!\nNow, updating isn\'t exactly *necessary*. But if I were you, i\'d update, cause there can be bugs! Bad ones! Evil ones, even!\nYour version: $version\n Current version: $data',
							'Update', 'Ignore', null, function()
						{
							FlxG.openURL("https://github.com/FoxelTheFennic/Paint-3D-Project-Manager/releases/latest");
							Sys.exit(0);
						}, function()
						{
							loadData();
						}));
					}
					else
					{
						loadData();
					}
				}

				http.onError = function(error)
				{
					loadData();
					trace('Http error: $error');
				}

				http.request();
			}
			else
				loadData();
			#else
			loadData();
			#end
		}

		if (FlxG.save.data.hasSeenReadMeNotif != true && !init)
		{
			FlxG.save.data.hasSeenReadMeNotif = true;
			openSubState(new MessageBox(FlxColor.GRAY,
				'Hello and welcome to P3D Project Manager!\nWould you like me to take you to the instructions/info page?', 'Yes', 'No', null, function()
			{
				FlxG.openURL("https://github.com/FoxelTheFennic/Paint-3D-Project-Manager/blob/main/README.md");
				doFirstLoad();
			}, function()
			{
				doFirstLoad();
			}));
		}
		else
			doFirstLoad();

		init = true;
	}

	public static var lastPressedTime:Float = 0;

	static var secretArray:Array<FlxKey> = [ZERO, FOUR, ONE, TWO];

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		lastPressedTime = (FlxG.mouse.pressed) ? lastPressedTime + elapsed : 0;

		// secret DARK MODE
		if (FlxG.keys.justPressed.ANY)
		{
			lastPresses.push(FlxG.keys.firstJustPressed());
			if (lastPresses.length >= secretArray.length)
			{
				while (lastPresses.length > secretArray.length)
					lastPresses.shift();

				var dookie:Bool = true;
				for (i => key in lastPresses)
				{
					if (key != secretArray[i])
					{
						dookie = false;
						break;
					}
				}

				if (dookie)
				{
					FlxG.save.data.darkModeEnabled = !FlxG.save.data.darkModeEnabled;
					FlxG.resetState();
				}
			}
		}

		if (FlxG.mouse.overlaps(github))
		{
			github.alpha = 1;
			github.scale.x = Util.lerp(github.scale.x, 0.12, 0.2);
			github.scale.y = Util.lerp(github.scale.y, 0.12, 0.2);
			github.angle = Util.lerp(github.angle, -5, 0.2);

			if (FlxG.mouse.justReleased)
				FlxG.openURL("https://github.com/FoxelTheFennic/Paint-3D-Project-Manager");
		}
		else
		{
			github.alpha = 0.5;
			github.scale.x = Util.lerp(github.scale.x, 0.098, 0.2);
			github.scale.y = Util.lerp(github.scale.y, 0.098, 0.2);
			github.angle = Util.lerp(github.angle, 0, 0.2);
		}

		buttonsTargetY = FlxMath.bound(buttonsTargetY, FlxG.height - buttons.height - 5, 15);

		if (canInteract)
		{
			if (FlxG.mouse.screenX < 400 && FlxG.mouse.justMoved && lastPressedTime >= 0.1)
				buttonsTargetY += FlxG.mouse.deltaScreenY * 1.2;

			buttonsTargetY += (FlxG.mouse.wheel * 150);
		}

		buttons.y = Util.lerp(buttons.y, buttonsTargetY, 0.2);

		if (FlxG.keys.justPressed.R)
		{
			if (FlxG.keys.pressed.CONTROL)
			{
				openSubState(new MessageBox(getCurrentColor(curSelected),
					'Would you like to rebuild your Projects.json? (WARNING: THIS WILL ERASE ALL OF YOUR PROJECT NAMES, AND OTHER ISSUES MAY OCCOUR)', 'Yes',
					'No', null, function()
				{
					var newProjectJson:Array<ProjectFile> = [];

					for (folder in FileSystem.readDirectory(_folderPath))
					{
						if (folder.toLowerCase() == ".bak")
							continue;

						if (FileSystem.isDirectory(_folderPath + '\\' + folder))
						{
							var ereg:EReg = ~/\s*[(][^)]*[)]$/;
							newProjectJson.push({
								"Id": ProjectFileUtil.generateID(),
								"SourceId": "",
								"Name": ereg.replace(folder, ""),
								"URI": 'ms-appdata:///local/Projects/$folder/Thumbnail.png',
								"DateTime": 0,
								"Path": 'Projects\\$folder',
								"SourceFilePath": "",
								"Version": 0.21,
								"IsRecovered": false,
								"IsPreviouslySaved": true
							});
						}
					}

					File.saveContent(_folderPath + '\\Projects.json', Json.stringify(newProjectJson));
					loadJson(_folderPath + '\\Projects.json');
				}));
			}
			else
			{
				openSubState(new MessageBox(getCurrentColor(curSelected),
					'Would you like to remove all non linked folders?\n(If you found this by accident, i\'d reccomend cancelling)', 'Yes', 'No', null,
					function()
					{
						var safeFolders = [];
						for (project in _projects)
							safeFolders.push(ProjectFileUtil.getCheckpointFolder(project));

						safeFolders.push(_folderPath + '\\.Bak');

						for (file in FileSystem.readDirectory(_folderPath))
						{
							if (FileSystem.isDirectory(_folderPath + '\\' + file) && !safeFolders.contains(_folderPath + '\\' + file))
							{
								@await
								Util.deleteDirRecursively(_folderPath + '\\' + file);

								FileSystem.deleteDirectory(_folderPath + '\\' + file);
							}
						}
					}));
			}
		}

		#if debug
		if (FlxG.keys.pressed.MINUS)
			FlxG.camera.zoom -= 0.01;

		if (FlxG.keys.pressed.PLUS)
			FlxG.camera.zoom += 0.01;

		if (FlxG.keys.pressed.BACKSPACE)
			FlxG.camera.zoom = 1;

		if (FlxG.keys.justPressed.F5)
			FlxG.resetState();

		if (FlxG.keys.justPressed.S)
		{
			for (button in buttons)
			{
				button.checkboxSelected = !button.checkboxSelected;
				button.checkBox.animation.play('check', true, !button.checkboxSelected);
			}
		}
		#end

		gridBG.x += 12 * elapsed;
		gridBG.y += 12 * elapsed;
	}

	public function showFileDialog()
	{
		if (!canInteract)
			return;

		trace('Loading Projects.json File...');
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

	public static function getCurrentColor(cur:ProjectFile):FlxColor
	{
		if (FlxG.save.data.darkModeEnabled)
		{
			return 0x2F2D31;
		}

		if (colorArray[_projects.indexOf(cur)] == null)
			colorArray[_projects.indexOf(cur)] = Util.saturatedColor(ProjectFileUtil.getThumbnail(cur));
		return colorArray[_projects.indexOf(cur)];
	}

	public function loadJson(file:String)
	{
		if (!canInteract)
			return;

		Util.deleteDirRecursively(_folderPath + '\\zipExport');

		buttonsTargetY = -15;

		colorArray = [];
		sizeArray = [];

		for (i in thumbnailPool.keys())
			thumbnailPool.remove(i);

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
			FlxG.save.flush();

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
			Util.sendMsgBox("Error Parsing Json!\n\"" + e + "\"\n\"" + e.stack + "\"");
		}
	}

	function drawButtons(projects:Array<ProjectFile>)
	{
		for (button in buttons)
		{
			buttons.remove(button);
			button.destroy();
		}

		for (project in projects)
		{
			var index = projects.indexOf(project);
			var button = new ProjectButton(0, (110 * index), 0, project);
			button.instance = this;

			buttons.add(button);
		}

		sortButtons(buttons);
		selectProject(projects[0]);

		trace('Finished loading Project File!');

		canInteract = true;
	}

	public function sortButtons(buttons:FlxTypedSpriteGroup<ProjectButton>)
	{
		buttons.sort(ProjectFileUtil.sortDate, FlxSort.DESCENDING);

		for (button in buttons)
		{
			var index = buttons.members.indexOf(button);
			button.y = 110 * index;
		}
	}

	public function selectProject(project:ProjectFile)
	{
		curSelected = project;

		var daColor:FlxColor = getCurrentColor(project);
		gridBG.color = Util.getDarkerColor(daColor, 1.3);

		sideBar.x = FlxG.width;
		sideBar.loadProject(project);

		github.color = Util.contrastColor(daColor);

		switch (project.Id.toLowerCase()) // secrettts
		{
			case '{45eb3df0-671c-4070-8c06-3ef6b5431383}' | '{4666098b-23ba-48e7-b348-e66d0a292542}':
				FlxG.sound.play(Assets.getSound('embed/Trickery.ogg'), 0.15);
			case '{e5a8d381-909f-42f8-abfa-37dd2fe26d5a}':
				FlxG.sound.play(Assets.getSound('embed/Jumpman25.ogg'), 0.15);
			case '{f88f74da-6989-42e9-a18c-97ac87beb691}':
				var random = FlxG.random.int(0, 2);
				FlxG.sound.play(Assets.getSound('embed/PuffPuff_' + (random == 0 ? 'Ass' : (random == 1 ? 'Bark' : 'Piss')) + '.ogg'), 0.15);
		}
	}

	var exportTime:Int = 0;

	public function exportProjects()
	{
		if (!canInteract)
			return;

		trace('Exporting Projects...');
		canInteract = false;

		try
		{
			exportTime = 0;

			var projectsToExport:Array<ProjectFile> = [];
			var projectClones:Array<ProjectFile> = [];

			for (button in buttons)
			{
				if (button.checkboxSelected)
					projectsToExport.push(button.project);
			}

			if (projectsToExport.length == 0)
				projectsToExport = [curSelected];

			Discord.updatePresence('Exporting ' + (projectsToExport.length > 1 ? projectsToExport.length + ' Projects' : 'a Project'), null, null, null,
				'icon', Discord.versionInfo, 'export', 'Exporting');

			var messageAppend:String = '';

			for (i in projectsToExport)
			{
				if (projectsToExport.indexOf(i) != projectsToExport.length - 1)
					messageAppend += i.Name + ', ';
				else
					messageAppend += i.Name;
			}

			var message;
			openSubState(new MessageBox(getCurrentColor(curSelected), "Are you sure you want to export these projects?\n" + messageAppend, 'Yes', 'No', null,
				function()
				{
					persistentUpdate = true;
					exportTime = Std.int(Date.now().getTime() / 1000);
					Discord.updatePresence('Exporting ' + (projectsToExport.length > 1 ? projectsToExport.length + ' Projects' : 'a Project'), null,
						exportTime, null, 'icon', Discord.versionInfo, 'export', 'Exporting');

					message = new MessageBox(getCurrentColor(curSelected),
						'Exporting...\n(P3DPM may freeze multiple times throughout this, please do not be alarmed!)', '', '', null, null, null);
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
							var projectClone = Reflect.copy(project);
							filteredFilename = projectClone.Name;

							if (StringTools.contains(projectClone.Path.toLowerCase(), 'workingfolder'))
								projectClone.Name = '(WF) ' + projectClone.Name;

							for (letter in ProjectFileUtil.disallowedChars)
								filteredFilename.replace(letter, '_');

							filteredFilename.substring(0, 260);
							var projDir = filteredFilename + ' (' + FlxG.random.int(0, 99999999) + ')';

							for (i in FileSystem.readDirectory(ProjectFileUtil.getCheckpointFolder(project)))
								validFileCheck += projDir + '\\' + i + '\n';

							projectClone.Path = 'Projects\\' + projDir;
							projectClone.URI = 'ms-appdata:///local/Projects/' + projDir + '/Thumbnail.png';
							projectClone.SourceId = '';
							projectClone.SourceFilePath = '';

							projectClones.push(projectClone);

							var dir = FileSystem.readDirectory(ProjectFileUtil.getCheckpointFolder(project));
							for (file in dir)
							{
								Discord.updatePresence((dir.indexOf(file) + 1)
									+ ' files out of '
									+ (dir.length - 1),
									'Exporting '
									+ (projectsToExport.indexOf(project) + 1)
									+ ' out of '
									+ projectsToExport.length
									+ ' Projects ', exportTime,
									null, 'icon', Discord.versionInfo, 'export', 'Exporting');
								exportZip.addBytes(File.getBytes(ProjectFileUtil.getCheckpointFolder(project) + '\\' + file), projDir + '\\' + file, true);
							}
						}

						exportZip.addString(validFileCheck, 'fileCheck.txt', true);
						exportZip.addString(JsonPrinter.print(projectClones, null, '	'), "exportProjects.json", true);

						Discord.updatePresence('Saving ' + (projectsToExport.length > 1 ? projectsToExport.length + ' Projects' : 'a Project'), null, null,
							null, 'icon', Discord.versionInfo, 'export', 'Exporting');

						var fDial = new FileDialog();
						fDial.save(exportZip.finalize();
							, 'p3d',
							_folderPath
							+ '\\'
							+ (projectsToExport.length == 1 ? filteredFilename : "Projects")
							+ '.p3d', 'Save your exported projects.');

						fDial.onCancel.add(function()
						{
							Discord.updatePresenceDPO(Discord.defaultRich);
							message.closeAnim();
							persistentUpdate = false;
							canInteract = true;
							trace('Project Exporting Cancelled');
							Util.sendMsgBox('File saving either errored, or was cancelled.\nIs there any programs accessing the file you were trying to save it at?');
						});

						fDial.onSave.add(function(file:String)
						{
							Discord.updatePresenceDPO(Discord.defaultRich);
							message.closeAnim();
							persistentUpdate = false;
							trace('Project Exporting Completed!');
							canInteract = true;
						});
					}, 100);
				}, function()
			{
				Discord.updatePresenceDPO(Discord.defaultRich);
				canInteract = true;
				return;
			}, 0x36FFFFFF));
		}
		catch (e)
		{
			Discord.updatePresenceDPO(Discord.defaultRich);
			canInteract = true;
			Util.sendMsgBox("Error Exporting!\n\"" + e + "\"");
		}
	}

	var importTime:Int = 0;

	public function importProjects()
	{
		if (!canInteract)
			return;

		importTime = 0;
		canInteract = false;

		Discord.updatePresence('Importing Projects', null, null, null, 'icon', Discord.versionInfo, 'import', 'Importing');

		trace('Importing Projects...');
		var fDial = new FileDialog();
		fDial.browse(FileDialogType.OPEN, 'p3d', null, 'Open a Paint 3D Project file.');
		fDial.onSelect.add(function(file)
		{
			var splitFile:Array<String>;
			if (!['p3d'].contains((splitFile = file.split('.'))[splitFile.length - 1].toLowerCase()))
			{
				Discord.updatePresenceDPO(Discord.defaultRich);
				openSubState(new MessageBox(getCurrentColor(curSelected), 'This is not a P3D file!', 'Ok', null, null, function()
				{
					canInteract = true;
				}));
				return;
			}

			Util.deleteDirRecursively(_folderPath + '\\zipExport');

			importTime = Std.int(Date.now().getTime() / 1000);
			Discord.updatePresence('Importing Projects', null, importTime, null, 'icon', Discord.versionInfo, 'import', 'Importing');

			persistentUpdate = true;
			var message = new MessageBox(getCurrentColor(curSelected),
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

				var daBytes = File.getBytes(file);
				var zip = new ZipReader(daBytes);
				var entry:ZipEntry;

				while ((entry = zip.getNextEntry()) != null)
					entries.set(entry.fileName, entry);

				var loopTable = [];
				for (key in entries.keys())
					@await loopTable.push(key);

				for (entry in entries.keys())
					@await zipFiles(entry, entries, loopTable.indexOf(entry) + 1, loopTable.length);

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
						@await moveFiles(entry, entries, loopTable.indexOf(entry) + 1, loopTable.length);

					Util.deleteDirRecursively(_folderPath + '\\zipExport');

					var concatJson:Array<ProjectFile> = projectFile.concat(Json.parse(File.getContent(_folderPath + '\\exportProjects.json')));

					for (project in concatJson)
					{
						if (project.Id == '-1')
							concatJson.remove(project);
					}

					for (project in Util.getArrayDifference(ProjectFileUtil.removeDuplicates(concatJson), concatJson))
					{
						@await
						Util.deleteDirRecursively(ProjectFileUtil.getCheckpointFolder(project));

						FileSystem.deleteDirectory(ProjectFileUtil.getCheckpointFolder(project));
					}

					FileSystem.deleteDirectory(_folderPath + '\\zipExport');
					FileSystem.deleteFile(_folderPath + '\\exportProjects.json');
					File.saveContent(_folderPath + '\\Projects.json', Json.stringify(ProjectFileUtil.removeDuplicates(concatJson)));

					canInteract = true;
					trace('Finished Importing Projects!');

					Discord.updatePresenceDPO(Discord.defaultRich);
					message.closeAnim();
					persistentUpdate = false;
					openSubState(new MessageBox(getCurrentColor(curSelected), 'Importing Complete!', 'Ok', null, null, function()
					{
						// loadJson(_folderPath + '\\Projects.json');
						FlxG.resetState();
					}));
				}

				if (missingFiles.length > 0)
				{
					openSubState(new MessageBox(getCurrentColor(curSelected),
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
	function zipFiles(entry:String, entries:StringMap<ZipEntry>, cur:Int, max:Int)
	{
		Discord.updatePresence('$cur files out of $max', 'Importing Projects', importTime, null, 'icon', Discord.versionInfo, 'import', 'Importing');
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
	function moveFiles(entry:String, entries:StringMap<ZipEntry>, cur:Int, max:Int)
	{
		Discord.updatePresence('$cur files out of $max', 'Moving Projects', importTime, null, 'icon', Discord.versionInfo, 'import', 'Importing');
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

		openSubState(new MessageBox(getCurrentColor(curSelected), 'Are you sure you want to delete the following projects?\n' + messageAppend, 'Yes', 'No',
			null, function()
		{
			openSubState(new MessageBox(getCurrentColor(curSelected),
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

				// just using white for this one because otherwise it'll load a null color and it'll be pitch black
				openSubState(new MessageBox(0xEEEEEE, 'Deletion Complete!', 'Ok', null, null, function()
				{
					canInteract = true;
					FlxG.resetState();
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
