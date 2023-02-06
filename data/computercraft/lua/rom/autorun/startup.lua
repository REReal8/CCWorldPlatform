
--for n in pairs(_G) do print(n) end
package.path = package.path..";/rom/modules/ccwp/?;/rom/modules/ccwp/core/?;/rom/modules/ccwp/obj/?;/rom/modules/ccwp/role/?;/rom/modules/ccwp/mobj/?;/rom/modules/ccwp/enterprise/?"

local core = require "core"

-- initialize core modules
core.Init()

-- setup core modules
core.Setup()

-- nu werkelijk aan de slag
core.Run()
