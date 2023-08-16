local MethodExecutor = {}
local corelog = require "corelog"

local InputChecker = require "input_checker"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

function MethodExecutor.DoSyncService(...)
    -- get & check input from description
    local checkSuccess, moduleName, serviceName, serviceData = InputChecker.Check([[
        This function executes a sync service method of a module.

        Return value:
            results                     - (?) service function return value

        Parameters:
            moduleName                  + (string) name of module with the service
            serviceName                 + (string) name of service function to execute
            serviceData                 + (table) with argument to supply to service function
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MethodExecutor.DoSyncService: Invalid input") return {success = false} end

    -- call method
    local results = MethodExecutor.CallModuleMethod(moduleName, serviceName, { serviceData })
    if type(results) ~= "table" then corelog.Error("MethodExecutor.DoSyncService: service function return value not a table(type="..type(results)..")") return {success = false} end

    -- end
    return results
end

function MethodExecutor.DoSyncObjService(...)
    -- get & check input from description
    local checkSuccess, className, objData, serviceName, serviceData = InputChecker.Check([[
        This function executes a sync service method of an obj.

        Return value:
            results                     - (?) service function return value

        Parameters:
            className                   + (string) name of class with the service
            objData                     + (table) with obj data
            serviceName                 + (string) name of service function to execute
            serviceData                 + (table) with argument to supply to service function
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MethodExecutor.DoSyncObjService: Invalid input") return nil end

    -- call method
    return MethodExecutor.CallObjMethod(className, objData, serviceName, { serviceData })
end

function MethodExecutor.DoASyncService(...)
    -- get & check input from description
    local checkSuccess, moduleName, serviceName, serviceData, callback = InputChecker.Check([[
        This function executes an async service method of a module.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
            results                     - (?) service function return value

        Parameters:
            moduleName                  + (string) name of module with the service
            serviceName                 + (string) name of service function to execute
            serviceData                 + (table) with argument to supply to service function
            callback                    + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MethodExecutor.DoASyncService: Invalid input") return nil end

    -- call method
    return MethodExecutor.CallModuleMethod(moduleName, serviceName, { serviceData, callback })
end

function MethodExecutor.DoASyncObjService(...)
    -- get & check input from description
    local checkSuccess, className, objData, serviceName, serviceData, callback = InputChecker.Check([[
        This function executes an async service method of an obj.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
            results                     - (?) service function return value

        Parameters:
            className                   + (string) name of class with the service
            objData                     + (table) with obj data
            serviceName                 + (string) name of service function to execute
            serviceData                 + (table) with argument to supply to service function
            callback                    + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MethodExecutor.DoASyncObjService: Invalid input") return nil end

    -- call method
    return MethodExecutor.CallObjMethod(className, objData, serviceName, { serviceData, callback })
end

function MethodExecutor.GetModuleMethod(...)
    -- get & check input from description
    local checkSuccess, moduleName, methodName = InputChecker.Check([[
        This method gets a method based on a methodName and a module with the name moduleName.

        Return value:
            results                     - (?) function return value(s)

        Parameters:
            moduleName                  + (string) name of module to get method from
            methodName                  + (string) name of method to execute
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MethodExecutor.GetModuleMethod(...): Invalid input") return nil end

    -- get module
    local module = moduleRegistry:getModule(moduleName)
    if not module then corelog.Warning("MethodExecutor.GetModuleMethod(...): Module "..moduleName.." not found") return nil end

    -- get method
    local method = module[methodName]
    if not method then corelog.Warning("MethodExecutor.GetModuleMethod(...): Method "..methodName.." not found in module "..moduleName) return nil end

    -- end
    return method
end

function MethodExecutor.CallModuleMethod(...)
    -- get & check input from description
    local checkSuccess, moduleName, methodName, methodArguments = InputChecker.Check([[
        This method executes a method of a module based on a methodName and the methodArguments.

        Return value:
            results                     - (?) function return value(s)

        Parameters:
            moduleName                  + (string) name of module to execute on
            methodName                  + (string) name of method to execute
            methodArguments             + (table) with arguments to supply to the method
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MethodExecutor.CallModuleMethod(...): Invalid input") return nil end

    -- get module
    local module = moduleRegistry:getModule(moduleName)
    if not module then corelog.Warning("MethodExecutor.CallModuleMethod(...): Module "..moduleName.." not found") return nil end

    -- call method
    local results = MethodExecutor.CallMethod(module, methodName, methodArguments)

    -- end
    return results
end

function MethodExecutor.CallObjMethod(...)
    -- get & check input from description
    local checkSuccess, className, objFieldsTable, methodName, methodArguments = InputChecker.Check([[
        This method executes a method of an Obj based on it's className + objFieldsTable and the methodName + the methodArguments.

        Return value:
            results                     - (?) function return value(s)

        Parameters:
            className                   + (string) name of class to execute on
            objFieldsTable              + (table) with obj data
            methodName                  + (string) name of method to execute
            methodArguments             + (table) with arguments to supply to the method
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MethodExecutor.CallObjMethod(...): Invalid input") return nil end

    -- get obj
    local obj = objectFactory:create(className, objFieldsTable)
    if not obj then corelog.Warning("MethodExecutor.CallObjMethod(...): Object "..className.." not created for objFields "..textutils.serialise(objFieldsTable, {compact = true}) ) return nil end

    -- call instance method
    local results = MethodExecutor.CallInstanceMethod(obj, methodName, methodArguments)

    -- end
    return results
end

function MethodExecutor.CallInstanceMethod(...)
    -- get & check input from description
    local checkSuccess, object, methodName, methodArguments = InputChecker.Check([[
        This method executes an instance method of an object based on a methodName and the methodArguments.

        Return value:
            results                     - (?) function return value(s)

        Parameters:
            object                      + (table) object to execute on
            methodName                  + (string) name of method to execute
            methodArguments             + (table) with arguments to supply to the method
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MethodExecutor.CallInstanceMethod(...): Invalid input") return nil end

    -- get method
    local method = object[methodName]
    if not method then corelog.Warning("MethodExecutor.CallInstanceMethod(...): Method "..methodName.." not found in object "..textutils.serialise(object, {compact = true})) return nil end

    -- call method
    local results = method(object, table.unpack(methodArguments))

    -- end
    return results
end

function MethodExecutor.CallMethod(...)
    -- get & check input from description
    local checkSuccess, object, methodName, methodArguments = InputChecker.Check([[
        This method executes a method of an object based on a methodName and the methodArguments.

        Return value:
            results                     - (?) function return value(s)

        Parameters:
            object                      + (table) object to execute on
            methodName                  + (string) name of method to execute
            methodArguments             + (table) with arguments to supply to the method
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MethodExecutor.CallMethod(...): Invalid input") return nil end

    -- get method
    local method = object[methodName]
    if not method then corelog.Warning("MethodExecutor.CallMethod(...): Method "..methodName.." not found in object "..textutils.serialise(object, {compact = true})) return nil end

    -- call method
    local results = method(table.unpack(methodArguments))

    -- end
    return results
end

return MethodExecutor
