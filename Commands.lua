local Commands = {}
local discordia = require('discordia')
local http = require('coro-http')

local Mention = function(message)
	return("<@"..message.author.id..">")
end

local stringifyArgs = function(args)
	return table.concat(args)
end

Commands["ping"] ={
	name = "ping",
	desc = "Pings the bot.",
	example = "ping",

	Execute = function(Client,Message,Command,Args)
		Message:reply("Hello! I am here, "..Mention(Message))
	end
}

Commands["getrank"] ={
	name = "getrank",
	desc = "Gets the player's rank.",
	example = "getrank AndrewHBaker",

	Execute = function(Client,Message,Command,Args)
		local name = Args[2]

		if name == nil then Message:reply("You never said who's rank you wanted...") end

		coroutine.wrap(function()
			local res, json = http.request("GET", "https://api.roblox.com/users/get-by-username?username="..name)
			local id = require("./json").decode(json)["Id"]

			if id == nil then return Message:reply(Args[2].." is not a player, or is spelt incorrectly.") end
			print(id)

			coroutine.wrap(function()
				local res, body = http.request("GET", "https://assetgame.roblox.com/Game/LuaWebService/HandleSocialRequest.ashx?method=GetGroupRole&playerid="..require("./json").decode(json)["Id"].."&groupid=3915183")
				Message:reply(body)
			end)()
			return
		end)()
	
	end
}

Commands["help"] ={
	name = "help",
	desc = "Gives you this message.",
	example = "help",

	Execute = function(Client,Message,Command,Args)
		local str = "__Help Commmand:__\n`Command Name` - `Command Example` - `Command Description`\n"

		for i,command in pairs(Commands) do
			str = str.."`"..command.name.."` - `"..command.example.."` - *"..command.desc.."*\n"
		end

		Message.author:send(str)
		Message:reply("I have sent you a list of commands.")
	end
}

Commands["order"] ={
	name = "order",
	desc = "Requests an order.",
	example = "order A large building.",

	Execute = function(Client,Message,Command,Args)
		local orderChannel = Client:getChannel('449999290992164874')

		local message = orderChannel:send("@here\n"..table.concat(Args, " ", 2).."\n~"..Mention(message))
		message:addReaction('✅') --tick
		message:addReaction('❎') --cross
				
	end
}

Commands["kick"] ={
	name = "kick",
	desc = "Kicks the mentioned user.",
	example = "kick @MatthewTBaker",

	Execute = function(Client,Message,Command,Args)
		local Subject = Message.mentionedUsers:iter()()
		Subject = Message.guild:getMember(Subject.id)

		if #Message.mentionedUsers > 1 then return Message:reply("You cannot kick more than one person at a time.") end
		if Subject.roles:iter()().position > Message.member.roles:iter()().position then return Message:reply("You do not have permission to kick someone higher than you.") end
		if not Message.member:hasPermission(0x00000002) then return Message:reply("You do not have the permissions to kick members.") end
		if Subject.bot then return Message:reply("You cannot kick a bot.") end

		Message:reply("<@"..Subject.id.."> has been kicked.")
		Subject:send("You have been kicked from Baker International's Discord server.")
		Subject:kick()
	end
}

Commands["ban"] ={
	name = "ban",
	desc = "Bans the mentioned user.",
	example = "ban @MatthewTBaker",

	Execute = function(Client,Message,Command,Args)
		local Subject = Message.mentionedUsers:iter()()
		Subject = Message.guild:getMember(Subject.id)

		if #Message.mentionedUsers > 1 then return Message:reply("You cannot ban more than one person at a time.") end
		if Subject.roles:iter()().position > Message.member.roles:iter()().position then return Message:reply("You do not have permission to ban someone higher than you.") end
		if not Message.member:hasPermission(0x00000004) then return Message:reply("You do not have the permissions to ban members.") end
		if Subject.bot then return Message:reply("You cannot ban a bot.") end

		Message:reply("<@"..Subject.id.."> has been banned.")
		Subject:send("You have been banned from Baker International's Discord server.")
		Subject:kick()
	end
}

return function(Client, Message, Command, Args)
	if not Commands[Command] then return end
	if Message.author.bot then return end

	Commands[Command].Execute(Client,Message,Command,Args)
end



--#ctl00_cphRoblox_GroupStatusPane_StatusTextField