--Defining Discordia
local Discord = require("discordia")
local Client  = Discord.Client()
Discord.extensions()

--Defining modules
local CommandHandler = require("./Commands")

--Functions that lua needs but doesnt have
function wait(int)
	local startTime = os.time()
	local endTime   = startTime + int

	while (endTime ~= os.time()) do end
end

Client:on("ready", function()
	print(Client.user.fullname.." is logged in!")
end)

Client:on('messageCreate', function(Message)
	if string.sub(Message.content, 1, 1) ~= "*" then return end
	
	local Content = Message.content:sub(2)
    local Args = Content:split(" ")	

	local Command = string.lower(Args[1])
	table.remove(args,1)

	CommandHandler(Client, Message, Command, Args)
end)

Client:on('guildCreate', function(Guild)
	Guild.owner:send("This bot is only for Baker International. We have had to remove this bot from your server.")
	Guild:leave()
	print("Joined "..Guild.name..";\nLeft "..Guild.name)
end)


Client:run(process.env.TOKEN)

