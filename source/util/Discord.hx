package util;

import Sys.sleep;
import discord_rpc.DiscordRpc;

class Discord
{
	#if debug
	public static var versionInfo = 'Version ' + PlayState.version + ' (dev)';
	#else
	public static var versionInfo = 'Version ' + PlayState.version;
	#end

	public static var defaultRich = {
		details: 'Viewing projects',
		largeImageKey: 'icon',
		largeImageText: versionInfo
	};

	public function new()
	{
		DiscordRpc.start({
			clientID: "1089367947887267970",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
		}

		DiscordRpc.shutdown();
	}

	public static function initialize()
	{
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new Discord();
		});
		trace("Discord Client initialized");
	}

	static function onReady()
	{
		DiscordRpc.presence(defaultRich);
	}

	public static function updatePresence(state:String, ?details:String, ?startTimestamp:Int, ?endTimestamp:Int, ?largeImageKey:String,
			?largeImageText:String, ?smallImageKey:String, ?smallImageText:String)
	{
		DiscordRpc.presence({
			state: state,
			details: details,
			startTimestamp: startTimestamp,
			endTimestamp: endTimestamp,
			largeImageKey: largeImageKey,
			largeImageText: largeImageText,
			smallImageKey: smallImageKey,
			smallImageText: smallImageText
		});
	}

	public static function updatePresenceDPO(options:DiscordPresenceOptions)
	{
		DiscordRpc.presence(options);
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}
}
