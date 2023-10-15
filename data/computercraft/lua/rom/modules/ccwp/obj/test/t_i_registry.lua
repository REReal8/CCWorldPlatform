local T_IRegistry = {}
local corelog = require "corelog"

function T_IRegistry.pt_all(registryName, registry, key, thing, key2, thing2, thingName)
    -- IRegistry
    T_IRegistry.pt_register_isRegistered(registryName, registry, key, thing, thingName)
    T_IRegistry.pt_delist(registryName, registry, key, thing, thingName)
    T_IRegistry.pt_getRegistered(registryName, registry, key, thing, key2, thing2, thingName)
end

--    _____ _____            _     _
--   |_   _|  __ \          (_)   | |
--     | | | |__) |___  __ _ _ ___| |_ _ __ _   _
--     | | |  _  // _ \/ _` | / __| __| '__| | | |
--    _| |_| | \ \  __/ (_| | \__ \ |_| |  | |_| |
--   |_____|_|  \_\___|\__, |_|___/\__|_|   \__, |
--                      __/ |                __/ |
--                     |___/                |___/

function T_IRegistry.pt_register_isRegistered(registryName, registry, key, thing, thingName)
    -- prepare test
    assert(registryName, "no registryName provided")
    assert(registry, "no registry provided")
    assert(key, "no key provided")
    assert(thing, "no thing provided")
    assert(thingName, "no thingName provided")
    corelog.WriteToLog("* "..registryName..":register() and "..registryName..":isRegistered() tests")

    assert(not registry:isRegistered(key), thingName.." "..key.." already registered")

    -- test
    registry:register(key, thing)
    assert(registry:isRegistered(key), thingName.." "..key.." not registered")

    -- cleanup test
    registry:delist(key)
end

function T_IRegistry.pt_delist(registryName, registry, key, thing, thingName)
    -- prepare test
    assert(registryName, "no registryName provided")
    assert(registry, "no registry provided")
    assert(key, "no key provided")
    assert(thing, "no thing provided")
    assert(thingName, "no thingName provided")
    corelog.WriteToLog("* "..registryName..":delist() test")

    registry:register(key, thing)
    assert(registry:isRegistered(key), thingName.." "..key.." not registered")

    -- test
    registry:delist(key)
    assert(not registry:isRegistered(key), thingName.." not delisted")

    -- cleanup
end

function T_IRegistry.pt_getRegistered(registryName, registry, key, thing, key2, thing2, thingName)
    -- prepare test
    assert(registryName, "no registryName provided")
    assert(registry, "no registry provided")
    assert(key, "no key provided")
    assert(thing, "no thing provided")
    assert(key2, "no key2 provided")
    assert(thing2, "no thing2 provided")
    assert(thingName, "no thingName provided")
    corelog.WriteToLog("* "..registryName..":getRegistered() tests")

    assert(not registry:isRegistered(key), thingName.." "..key.." already registered")
    registry:register(key, thing)

    assert(not registry:isRegistered(key2), thingName.." "..key2.." already registered")
    registry:register(key2, thing2)

    -- test
    local retrievedThing1 = registry:getRegistered(key)
    assert(retrievedThing1 == thing, "Retrieved "..thingName.." 1 does not match original "..thingName.." 1")
    local retrievedThing2 = registry:getRegistered(key2)
    assert(retrievedThing2 == thing2, "Retrieved "..thingName.." 2 does not match original "..thingName.." 2")

    -- cleanup test
    registry:delist(key)
    registry:delist(key2)
end

return T_IRegistry
