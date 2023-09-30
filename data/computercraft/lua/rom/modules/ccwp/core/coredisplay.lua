-- define module
local coredisplay = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local coresystem	= require "coresystem"
local coredht		= require "coredht"
local corelog		= require "corelog"
local coreutils		= require "coreutils"
local coretask		= require "coretask"
local coremove		= require "coremove"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local MethodExecutor = require "method_executor"

-- declare display space
local db    = {
    x           = 0,
    y           = 0,
    update      = {}								-- list with all schreen updates
}
local screen    = {}

-- init function for the display
function coredisplay.Init()
	-- get current position
    db.x, db.y = term.getSize()

	-- direct even doen
	if db.defaultMainMenu == nil then
		db.defaultMainMenu = {
			clear   = true,
			intro   = "Choose your action",
			option  = {
				{key = "1", desc = "Exec code",  		func = ExecuteCode,	    		param = {step = 1}},
				{key = "2", desc = "General tests",		func = ExecuteTest,	    		param = {}},
				{key = "3", desc = "Core tests", 		func = ExecuteCoreTest,	    	param = {}},
				{key = "4", desc = "Role tests",		func = ExecuteRoleTest,			param = {}},
				{key = "5", desc = "obj tests",			func = ExecuteObjTest,			param = {}},
				{key = "6", desc = "mobj tests",		func = ExecuteMObjTest,			param = {}},
				{key = "7", desc = "Enterprise tests",	func = ExecuteEnterpriseTest,	param = {}},
				{key = "8", desc = "Load event",		func = LoadEvent,				param = {}},
				{key = "q", desc = "Quit",          	func = coresystem.DoQuit,		param = {}},
			},
			question	= "Make your choice",
		}

		-- alleen een turtle kan bewogen worden
		if turtle then coredisplay.MainMenuAddItem("m", "Move turtle", MoveTurtle) end
	end

    -- set default screen
    MainMenu(DefaultMainMenu())
end

-- setup function for the display
function coredisplay.Setup()
end

-- to know if the dislay is still being used
function Active()
    return db.mainmenu ~= nil
end

-- endless loop function for the display
function coredisplay.Run()
    -- is de dth al beschikbaar?
    while not coredht.IsReady() do

        -- gewoon ff wachten
        os.sleep(0.25)
    end

	-- only continue as long as there is a main menu defined
	while db.mainmenu ~= nil and coresystem.IsRunning() do
		-- get de next screen definition
		local nextScreenData = coredisplay.NextScreen()

		-- custom screen?
		if nextScreenData.custom	then nextScreenData.custom(nextScreenData)
									else DoScreen(nextScreenData)
		end
	end

	-- next line
	print("")
end

-- gets or sets the next screen
function coredisplay.NextScreen(t)
	if t				then screen[#screen + 1] = t
	elseif #screen > 0	then return table.remove(screen)
						else return MainMenu()
	end
end

-- function to execute a screen from a screentable
function DoScreen(t)
	local success
	local response

	-- now print the screen
	if not t.dontclear then term.clear() term.setCursorPos(1,1) end

	-- print the intro
	if t.intro then print(t.intro) end

	-- print the list
	if t.option then

		-- weinig opties, dan de oude werkwijze?
		if #t.option < 11 then

			-- one big list
			for i=1,#t.option do print(t.option[i].key, t.option[i].desc) end
		else

			-- fixed for now
			local rightOffset	= 10

			-- might look nicer this way
			if #t.option > 10 and #t.option < 20 then rightOffset = 1 + math.floor(#t.option / 2) end

			-- we have max 10 lines
			for i=1,10 do
				local keyLeft	= ""
				local keyRight	= ""
				local textLeft	= ""
				local textRight	= ""

				-- left side is easy
				if t.option[i] and i <= rightOffset then
					keyLeft			= t.option[i].key
					textLeft		= t.option[i].desc
				end

				-- right side just as easy
				if t.option[i + rightOffset] then
					keyRight		= t.option[i + rightOffset].key
					textRight		= t.option[i + rightOffset].desc
				end

				-- print the damn line
				print(string.format("%-1.1s %-17.17s %-1.1s %-17.17s", keyLeft, textLeft, keyRight, textRight))
			end
		end

--[[ 		-- too many options?
		if #t.option < 11 then
			-- one big list
			for i=1,#t.option do print(t.option[i].key, t.option[i].desc) end
		else
			-- two coloums
			for i=1,#t.option do
				print(string.format("%-1.1s %-17.17s %-1.1s %-17.17s", t.option[i].key, t.option[i].desc, t.option[i].key, t.option[i].desc))
			end
		end
--]]
	end

	-- print the final question
	if t.question then write(t.question.." ") end

	-- print any messages
	coredisplay.UpdateToDisplay()

	-- wait for input...
	while not success do
		if t.option then
			-- wait for the key
			response = ReadChar()

			-- find the right function to run
			for i=1,#t.option do
				if not success and response == t.option[i].key then
					success = t.option[i].func(t.option[i].param, response)
				end
			end
		else
			success = t.func(t.param, ReadLine())
		end
	end

	-- run the function -- weird again, can never happen !!!
--    	if func then func(response, param) end
end

function IndexToKey(i) if i < 10 then return tostring(i) else return string.char(87 + i) end end

function ReadChar()
	-- just wait for a char event
	while true do
		local event, c = os.pullEvent()
		if event == "char" then return c end
	end
end

function ReadLine() return read() end

-- for executing custom code
function ExecuteCode(t, code)
	-- first screen?
	if t.step == 1 then
		coredisplay.NextScreen({
			clear       = true,
			func	    = ExecuteCode,
			intro       = "Please type your line of code below\n",
			param	    = {step = 2},
			question    = nil
		})
	else
		local f, err = loadstring(code)

		-- valid function?
		if f then
			-- executing the code as wordt
			coretask.AddWork(f)
			coredisplay.UpdateToDisplay("Your code is queued for execution")
		else
			coredisplay.UpdateToDisplay(err)
			return false
		end
	end

	-- done
	return true
end

function ExecuteTest(t)
	-- forward call with options
	local options	= {
		{key = "g", desc = "general", 			func = ExecuteTest, param = {filename = "t_main"}},
		{key = "x", desc = "Back to main menu", func = function () return true end }
	}
	return ExecuteXObjTest(t, "general", options, ExecuteTest)
end

function ExecuteCoreTest(t)
	-- forward call with options
	local options	= {
		{key = "m", desc = "coremove", 			func = ExecuteCoreTest, param = {filename = "t_coremove"}},
		{key = "d", desc = "coredht", 			func = ExecuteCoreTest, param = {filename = "t_coredht"}},
		{key = "i", desc = "coreinventory",		func = ExecuteCoreTest, param = {filename = "t_coreinventory"}},
		{key = "x", desc = "Back to main menu", func = function () return true end }
	}
	return ExecuteXObjTest(t, "core", options, ExecuteCoreTest)
end

function ExecuteRoleTest(t)
	-- forward call with options
	local options	= {
		{key = "a", desc = "alchemist", 		func = ExecuteRoleTest, param = {filename = "t_alchemist"}},
		{key = "b", desc = "builder", 			func = ExecuteRoleTest, param = {filename = "t_builder"}},
		{key = "x", desc = "Back to main menu", func = function () return true end }
	}
	return ExecuteXObjTest(t, "role", options, ExecuteRoleTest)
end

function ExecuteObjTest(t)
	-- forward call with options
	local options	= {
		{key = "m", desc = "ModuleRegistry", 	func = ExecuteObjTest, param = {filename = "T_ModuleRegistry"}},
		{key = "1", desc = "Class", 			func = ExecuteObjTest, param = {filename = "T_Class"}},
		{key = "f", desc = "ObjectFactory", 	func = ExecuteObjTest, param = {filename = "T_ObjectFactory"}},
		{key = "2", desc = "ObjBase", 			func = ExecuteObjTest, param = {filename = "T_ObjBase"}},
		{key = "a", desc = "ObjArray", 			func = ExecuteObjTest, param = {filename = "T_ObjArray"}},
		{key = "o", desc = "ObjTable", 			func = ExecuteObjTest, param = {filename = "T_ObjTable"}},
		{key = "d", desc = "CallDef", 			func = ExecuteObjTest, param = {filename = "T_CallDef"}},
		{key = "c", desc = "Callback", 			func = ExecuteObjTest, param = {filename = "T_Callback"}},
		{key = "t", desc = "TaskCall", 			func = ExecuteObjTest, param = {filename = "T_TaskCall"}},
		{key = "e", desc = "MethodExecutor", 	func = ExecuteObjTest, param = {filename = "T_MethodExecutor"}},
		{key = "u", desc = "URL", 				func = ExecuteObjTest, param = {filename = "T_URL"}},
		{key = "h", desc = "Host", 				func = ExecuteObjTest, param = {filename = "T_Host"}},
		{key = "l", desc = "Location",			func = ExecuteObjTest, param = {filename = "T_Location"}},
		{key = "b", desc = "Block",				func = ExecuteObjTest, param = {filename = "T_Block"}},
		{key = "p", desc = "CodeMap",			func = ExecuteObjTest, param = {filename = "T_CodeMap"}},
		{key = "r", desc = "LayerRectangle",	func = ExecuteObjTest, param = {filename = "T_LayerRectangle"}},
		{key = "i", desc = "Inventory",			func = ExecuteObjTest, param = {filename = "T_Inventory"}},
		{key = "g", desc = "ItemTable",			func = ExecuteObjTest, param = {filename = "T_ItemTable"}},
		{key = "q", desc = "WIPQueue",			func = ExecuteObjTest, param = {filename = "T_WIPQueue"}},
		{key = "w", desc = "WIPAdministrator",	func = ExecuteObjTest, param = {filename = "T_WIPAdministrator"}},
		{key = "x", desc = "Back to main menu", func = function () return true end }
	}
	return ExecuteXObjTest(t, "obj", options, ExecuteObjTest)
end

function ExecuteMObjTest(t)
	-- forward call with options
	local options	= {
		{key = "1", desc = "TestMObj",			func = ExecuteMObjTest, param = {filename = "T_TestMObj"}},
		{key = "b", desc = "BirchForest",		func = ExecuteMObjTest, param = {filename = "T_BirchForest"}},
		{key = "c", desc = "Chest",				func = ExecuteMObjTest, param = {filename = "T_Chest"}},
		{key = "f", desc = "Factory",			func = ExecuteMObjTest, param = {filename = "T_Factory"}},
		{key = "p", desc = "ProductionSpot",	func = ExecuteMObjTest, param = {filename = "T_ProductionSpot"}},
		{key = "s", desc = "Silo",				func = ExecuteMObjTest, param = {filename = "T_Silo"}},
		{key = "m", desc = "Mine",				func = ExecuteMObjTest, param = {filename = "T_Mine"}},
		{key = "h", desc = "Shop",				func = ExecuteMObjTest, param = {filename = "T_Shop"}},
		{key = "t", desc = "Turtle",			func = ExecuteMObjTest, param = {filename = "T_Turtle"}},
		{key = "u", desc = "Util Station",		func = ExecuteMObjTest, param = {filename = "T_UtilStation"}},
		{key = "x", desc = "Back to main menu", func = function () return true end }
	}
	return ExecuteXObjTest(t, "mobj", options, ExecuteMObjTest)
end

function ExecuteEnterpriseTest(t)
	-- forward call with options
	local options	= {
		{key = "1", desc = "enterprise_test",	func = ExecuteEnterpriseTest, param = {filename = "t_test"}},
		{key = "a", desc = "assignmentboard",	func = ExecuteEnterpriseTest, param = {filename = "t_assignmentboard"}},
		{key = "h", desc = "MObjHost",			func = ExecuteEnterpriseTest, param = {filename = "T_MObjHost"}},
		{key = "t", desc = "turtle", 			func = ExecuteEnterpriseTest, param = {filename = "t_turtle"}},
		{key = "p", desc = "projects", 			func = ExecuteEnterpriseTest, param = {filename = "t_projects"}},
		{key = "e", desc = "energy", 			func = ExecuteEnterpriseTest, param = {filename = "t_energy"}},
		{key = "c", desc = "chests", 			func = ExecuteEnterpriseTest, param = {filename = "t_chests"}},
		{key = "i", desc = "isp", 				func = ExecuteEnterpriseTest, param = {filename = "t_isp"}},
		{key = "b", desc = "construction", 		func = ExecuteEnterpriseTest, param = {filename = "t_construction"}},
		{key = "s", desc = "storage", 			func = ExecuteEnterpriseTest, param = {filename = "t_storage"}},
		{key = "m", desc = "manufacturing", 	func = ExecuteEnterpriseTest, param = {filename = "t_manufacturing"}},
		{key = "f", desc = "forestry", 			func = ExecuteEnterpriseTest, param = {filename = "t_forestry"}},
		{key = "o", desc = "shop", 				func = ExecuteEnterpriseTest, param = {filename = "t_shop"}},
		{key = "n", desc = "colonization", 		func = ExecuteEnterpriseTest, param = {filename = "t_colonization"}},
		{key = "u", desc = "utilities", 		func = ExecuteEnterpriseTest, param = {filename = "t_utilities"}},
		{key = "x", desc = "Back to main menu", func = function () return true end }
	}
	return ExecuteXObjTest(t, "enterprise", options, ExecuteEnterpriseTest)
end

function ExecuteXObjTest(t, menuName, menuOptions, ExecuteXObjTest)
	if type(t) == "table" and type(t.func) == "string" and type(t.filename) == "string" then
		-- execute function

		-- seems our user has made a choice
		local f = MethodExecutor.GetModuleMethod(t.filename, t.func)
    	if not f then corelog.Warning("coredisplay.ExecuteXObjTest(...): Function "..t.func.." not found in file "..t.filename) return false end

		-- executing the code as wordt
		coretask.AddWork(f)
		coredisplay.UpdateToDisplay(t.filename.."."..t.func.." is queued for execution")

		-- stay on the testing screen when executing an command
		return false

	elseif type(t) == "table" and type(t.filename) == "string" then
		-- test functions screen

		-- get file
		local file = moduleRegistry:getModule(t.filename)
    	if not file then corelog.Warning("coredisplay.ExecuteXObjTest(...): File "..t.filename.." not found") return false end

		-- variables
		local functions	= {}
		local options	= {}

		-- get all functions in test file / object
		for key, value in pairs(file) do
			-- add key if the value is a function and name starts with T_
			if type(value) == "function" and string.find(key, "T_") then table.insert(functions, key) end
		end

		-- order this shit
		table.sort(functions)

		-- create the list of options
		for i, name in ipairs(functions) do options[i] = {key = IndexToKey(i), desc = string.sub(name,3,-1), func = ExecuteXObjTest, param = {func = name, filename = t.filename}} end
		table.insert(options, {key = "x", desc = "Back to "..menuName.." test menu", func = ExecuteXObjTest, param = {}})

		-- this is the next screen
		coredisplay.NextScreen({
			clear       = true,
			intro       = "Choose a "..menuName.." test function",
			option      = options,
			question    = "Make your choice"
		})
	elseif type(t) ~= "table" or type(t.func) ~= "string" then
		-- test files screen

		-- this is the next screen
		coredisplay.NextScreen({
			clear       = true,
			intro       = "Choose a "..menuName.." test type",
			option      = menuOptions,
			question    = "Make your choice"
		})
	else
		corelog.WriteToLog("ExecuteXObjTest: should not happen")
	end

	-- done
	return true
end

-- for loading an event from file
function LoadEvent(t)
	-- first screen
	if t == nil or t.dir == nil then
		local list	= fs.list("/event/")
		local tmp	= {}

		-- create the list of options
		for i=1,#list do tmp[i] = {key = IndexToKey(i), desc = list[i], func = LoadEvent, param = {dir = list[i]}} end
		tmp[#tmp + 1] = {key = "x", desc = "Back to main menu", func = function () return true end}

		-- this is the next screen
		coredisplay.NextScreen({
			clear       = true,
			intro       = "Choose a protocol",
			option      = tmp,
			question    = "Make your choice"
		})

	-- second screen
	elseif t.dir and t.filename == nil then
		local list	= fs.list( "/event/"..t.dir.."/" )
		local tmp	= {}

		-- create the list of options
		print(#list)
		for i=1,#list do tmp[i] = {key = IndexToKey(i), desc = list[i], func = LoadEvent, param = {dir = t.dir, filename = list[i]}} end
		tmp[#tmp + 1] = {key = "x", desc = "Back to protocol selection", func = LoadEvent, param = {}}

		-- this is the next screen
		coredisplay.NextScreen({
			clear       = true,
			intro       = "Choose a file (protocol="..t.dir..")",
			option      = tmp,
			question    = "Make your choice"
		})
	elseif t.dir and t.filename then
		local envelope = coreutils.ReadTableFromFile("/event/"..t.dir.."/"..t.filename)
		os.queueEvent("modem_message", nil, envelope.to, envelope.from, textutils.serialize(envelope), envelope.distance)
	end

	-- always good!
	return true
end

-- screen to move the turtle around
function MoveTurtle( t )
	-- chech if this is a turtle
	if not turtle then coredisplay.UpdateToDisplay("Only available for turtles") return false end

	-- first screen?
	if t == nil or t.direction == nil then
		coredisplay.NextScreen({
			clear = true,
			intro = "Available actions",
			option = {
				{key = "w", desc = "Forward",		    func = MoveTurtle, param = {direction = "Forward"   }},
				{key = "s", desc = "Backward",		    func = MoveTurtle, param = {direction = "Backward"  }},
				{key = "a", desc = "Turn left",	        func = MoveTurtle, param = {direction = "Left"      }},
				{key = "d", desc = "Turn right",	    func = MoveTurtle, param = {direction = "Right"     }},
				{key = "e", desc = "Up",			    func = MoveTurtle, param = {direction = "Up"        }},
				{key = "q", desc = "Down",				func = MoveTurtle, param = {direction = "Down"      }},
				{key = "x", desc = "Back to main menu", func = function () return true end }
			},
			question = "Which direction?"
		})
		return true
	else
			if t.direction == "Forward"		then coretask.AddWork(function () coremove.Forward()	end)
		elseif t.direction == "Backward"	then coretask.AddWork(function () coremove.Backward()	end)
		elseif t.direction == "Left"		then coretask.AddWork(function () coremove.Left()		end)
		elseif t.direction == "Right"		then coretask.AddWork(function () coremove.Right()		end)
		elseif t.direction == "Up"			then coretask.AddWork(function () coremove.Up()			end)
		elseif t.direction == "Down"		then coretask.AddWork(function () coremove.Down()		end)
		end

        -- makes the previous screen stays loaded, so the human kan move the turtle again
		return false
	end
end

-- local function to update the display with messages for the user.
function coredisplay.UpdateToDisplay(update, alive)
	local now	= os.clock()
	alive       = alive or 5

	-- do we have a new update?
	if update then db.update[#db.update + 1] = {text = update, endTime = now + alive} end

	-- presever the current coordinates
	local x, y = term.getCursorPos()
	local c = #db.update

	-- write second update?
	if c > 1 then
		term.setCursorPos( 1, db.y - 0 )
		term.clearLine()
		term.write( db.update[c - 1].text )
	end

	-- write third update?
	if c > 0 then
		term.setCursorPos( 1, db.y - 1 )
		term.clearLine()
		term.write( db.update[c].text )
	end

	-- resotre cursor
	term.setCursorPos( x, y )
end

function coredisplay.MainMenuAddItem(key, desc, func, param)
	if type(key) ~= "string" and type(desc) ~= "string" and type(func) ~= "function" then
		return corelog.Warning("coredisplay.MainMenuAddItem(): New menu item ignored")
	end

	-- default value
	if type(param) ~= "table" then param = {} end

	-- before init.... not so nice
	if db.defaultMainMenu == nil then coredisplay.Init() end

	-- add the menu item
	local o = db.defaultMainMenu.option
	table.insert(o, #o, {key = string.sub(key, 1, 1), desc = desc, func = func, param = param})
end

-- function to get or set the main menu
function MainMenu(t)
	if t then db.mainmenu = t
	else return db.mainmenu
	end
end

-- a nice default main menu, very usefull
function DefaultMainMenu()
	return db.defaultMainMenu
end

return coredisplay
