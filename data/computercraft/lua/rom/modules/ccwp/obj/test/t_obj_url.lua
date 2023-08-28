local T_URL = {}

local corelog = require "corelog"

local URL = require "obj_url"

local IObj = require "i_obj"
local ObjBase = require "obj_base"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_URL.T_All()
    -- initialisation
    T_URL.T_new()
    T_URL.T_GettersURI()
    T_URL.T_Setters()
    T_URL.T_SettersFromURI()
    T_URL.T_NewFromURI()

    -- IObj methods
    T_URL.T_IObj_All()

    -- specific methods
    T_URL.T_SameURLComponents()
    T_URL.T_baseCopy()
end

local scheme = "ccwprp"
local host = "enterprise_forestry"
local host2 = "enterprise_turtle"
local port = 1
local port2 = 5
local pathSegments = {
    "forests",
    "oak",
    "id=50:23012",
    "tree=4",
}
local path = "/"..pathSegments[1].."/"..pathSegments[2].."/"..pathSegments[3] -- == "/forests/oak/id=50:23012"
local path2 = "/"..pathSegments[1].."/"..pathSegments[2].."/"..pathSegments[3].."/"..pathSegments[4] -- == "/forests/oak/id=50:23012/tree=4"
local itemName1 = "minecraft:torch"
local itemCount1 = 5
local itemName2 = "minecraft:birch_log"
local itemCount2 = 3
local itemName3 = "minecraft:charcoal"
local itemCount3 = 7
local query = {[itemName1] = itemCount1, [itemName2] = itemCount2}
local query2 = {[itemName1] = itemCount1, [itemName3] = itemCount3}

local schemeURI = "ccwprp://"
local hostURI = host
local portURI = ":1"
local pathURI = "/"..pathSegments[1].."/"..pathSegments[2].."/"..pathSegments[3]
local queryURI = "?"..itemName2.."="..itemCount2.."&"..itemName1.."="..itemCount1
local expectedQueryURI = "?"..itemName1.."="..itemCount1.."&"..itemName2.."="..itemCount2

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local testClassName = "URL"
function T_URL.CreateTestObj()
    local testObj = URL:new({
        _host = host,
        _port = port,
        _path = path,
        _query = {[itemName1] = itemCount1, [itemName2] = itemCount2},
    })

    return testObj
end

function T_URL.T_URL_Serializing()
    -- new URL
    corelog.WriteToLog("* Test "..testClassName.." serialize")
    local obj = URL:new({
        _host = host,
        _port = port,
        _path = path,
        _query = query,
    })
    corelog.WriteToLog(" obj:getURI() = "..obj:getURI())

    corelog.WriteToLog(" obj type = "..type(obj))
    corelog.WriteToLog(" 1: obj = "..obj:getURI())
    corelog.WriteToLog(" 2: obj = "..textutils.serialize(obj))
end

function T_URL.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() and getter tests")
    local obj = URL:new({
        _host = host,
        _port = port,
        _path = path,
        _query = query,
    })

    -- test
    local testResult = obj:getScheme()
    local expectedResultStr = scheme
    assert(testResult == expectedResultStr, "getScheme() return(="..testResult..") different from expected(="..expectedResultStr..")")

    testResult = obj:getHost()
    expectedResultStr = host
    assert(testResult == expectedResultStr, "getHost() return(="..testResult..") different from expected(="..expectedResultStr..")")

    testResult = obj:getPort()
    local expectedResultNumber = port
    assert(testResult == expectedResultNumber, "getPort() return(="..testResult..") different from expected(="..expectedResultNumber..")")

    testResult = obj:getPath()
    expectedResultStr = path
    assert(testResult == expectedResultStr, "getPath() return(="..testResult..") different from expected(="..expectedResultStr..")")
    local iPathSegment = 1
    for pathSegment in obj:pathSegments_iter() do
        expectedResultStr = pathSegments[iPathSegment]
        assert(pathSegment == expectedResultStr, "pathSegment(="..pathSegment..") different from expected(="..expectedResultStr..")")
        iPathSegment = iPathSegment + 1
    end

    testResult = obj:getQuery()
    local expectedResultTable = query
    assert(testResult == expectedResultTable, "getQuery() return(="..textutils.serialize(testResult)..") different from expected(="..textutils.serialize(expectedResultTable)..")")

    -- test default
    obj = URL:new()
    assert(obj:getHost() == "", "gotten getHost(="..obj:getHost()..") not the same as expected(=``)")
    assert(type(obj:getPort()) == "nil", "gotten getPort(="..(obj:getPort() or "nil")..") not the same as expected(=nil)")
    assert(obj:getPath() == "", "gotten getPath(="..obj:getPath()..") not the same as expected(=``)")
    assert(obj:getQueryURI() == "", "gotten getQueryURI(="..obj:getQueryURI()..") not the same as expected(=``)")

    -- cleanup test
end

function T_URL.T_GettersURI()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." URI getter tests")
    local obj = URL:new({
        _host = host,
        _port = port,
        _path = path,
        _query = query,
    })

    -- test
    assert(obj:getSchemeURI() == schemeURI, "getSchemeURI() return(="..obj:getSchemeURI()..") different from expected(="..schemeURI..")")
    AssertWithURIs(obj, hostURI, portURI, pathURI, queryURI)
    assert(obj:getAuthorityURI() == hostURI..portURI, "getAuthorityURI() return(="..obj:getAuthorityURI()..") different from expected(="..hostURI..portURI..")")

    -- cleanup test
end

function AssertWithURIs(obj, aHostURI, aPortURI, aNPathURI, aQueryURI)
    -- test
    assert(obj:getHostURI() == aHostURI, "getHostURI() return(="..obj:getHostURI()..") different from expected(="..aHostURI..")")
    assert(obj:getPortURI() == aPortURI, "getPortURI() return(="..obj:getPortURI()..") different from expected(="..aPortURI..")")
    assert(obj:getPathURI() == aNPathURI, "getPathURI() return(="..obj:getPathURI()..") different from expected(="..aNPathURI..")")
    assert(obj:getQueryURI() == aQueryURI, "getQueryURI() return(="..obj:getQueryURI()..") different from expected(="..aQueryURI..")")
    local expectedResultStr = schemeURI..aHostURI..aPortURI..aNPathURI..aQueryURI
    assert(obj:getURI() == expectedResultStr, "getURI() return(="..obj:getURI()..") different from expected(="..expectedResultStr..")")
end

function T_URL.T_Setters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." setter tests")
    local obj = URL:new()

    -- test
    obj:setHost(host)
    assert(obj:getHost() == host, "setHost() result(="..obj:getHost()..") different from expected(="..host..")")

    obj:setPort(port)
    assert(obj:getPort() == port, "setPort() result(="..obj:getPort()..") different from expected(="..port..")")

    obj:setPath(path)
    assert(obj:getPath() == path, "setPath() result(="..textutils.serialize(obj:getPath())..") different from expected(="..textutils.serialize(path)..")")

    obj:setQuery(query)
    assert(obj:getQuery() == query, "setHost() result(="..textutils.serialize(obj:getQuery())..") different from expected(="..textutils.serialize(query)..")")

    -- cleanup test
end

function T_URL.T_SettersFromURI()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." setter from URI tests")
    local obj = URL:new()

    -- test
    obj:setHostURI(hostURI)
    assert(obj:getHostURI() == hostURI, "setHostURI() result(="..obj:getHostURI()..") different from expected(="..hostURI..")")

    obj:setPortURI(portURI)
    assert(obj:getPortURI() == portURI, "setPortURI() result(="..obj:getPortURI()..") different from expected(="..portURI..")")

    obj:setPathURI(pathURI)
    assert(obj:getPathURI() == pathURI, "setPathURI() result(="..obj:getPathURI()..") different from expected(="..pathURI..")")

    obj:setQueryURI(queryURI)
    local testResult = obj:getQuery()
    assert(testResult[itemName1] == itemCount1, "testResult.itemName1 (="..testResult[itemName1]..") different from expected(="..itemCount1..")")
    assert(testResult[itemName2] == itemCount2, "testResult.itemName1 (="..testResult[itemName2]..") different from expected(="..itemCount2..")")

    -- cleanup test
end

function T_URL.T_NewFromURI()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." from URI tests (0)")

    -- test
    local newURI0=schemeURI..hostURI..portURI..pathURI..queryURI
    local obj = URL:newFromURI(newURI0)
    AssertWithURIs(obj, hostURI, portURI, pathURI, expectedQueryURI)

    corelog.WriteToLog("* URL from URI tests (1: no host)")
    local newURI1=schemeURI..portURI..pathURI..queryURI
    obj = URL:newFromURI(newURI1, true)
    AssertWithURIs(obj, "", "", "", "") -- note: implies failure (error)

    corelog.WriteToLog("* URL from URI tests (2: no port)")
    local newURI2=schemeURI..hostURI..pathURI..queryURI
    obj = URL:newFromURI(newURI2)
    AssertWithURIs(obj, hostURI, "", pathURI, expectedQueryURI)

    corelog.WriteToLog("* URL from URI tests (3: no path)")
    local newURI3=schemeURI..hostURI..portURI..queryURI
    obj = URL:newFromURI(newURI3)
    AssertWithURIs(obj, hostURI, portURI, "", expectedQueryURI)

    corelog.WriteToLog("* URL from URI tests (4: no query)")
    local newURI4=schemeURI..hostURI..portURI..pathURI
    obj = URL:newFromURI(newURI4)
    AssertWithURIs(obj, hostURI, portURI, pathURI, "")

    -- cleanup test
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_URL.T_IObj_All()
    -- prepare test
    local obj = T_URL.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_URL.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function T_URL.T_SameURLComponents()
    corelog.WriteToLog("* "..testClassName.." same components tests")
    -- same Host
    local obj = URL:new({
        _host = host,
    })
    local aSameObj = URL:new({
        _host = host,
    })
    assert(obj:sameHost(aSameObj), "hosts should be the same")
    local aDifferentObj = URL:new({
        _host = host2,
    })
    assert(not obj:sameHost(aDifferentObj), "hosts should not be the same")

    -- same Authority
    obj = URL:new({
        _host = host2,
        _port = port,
    })
    aSameObj = URL:new({
        _host = host2,
        _port = port,
    })
    assert(obj:sameAuthority(aSameObj), "authority should be the same")
    aDifferentObj = URL:new({
        _host = host2,
        _port = port2,
    })
    assert(not obj:sameAuthority(aDifferentObj), "authority should not be the same")

    -- same path
    obj = URL:new({
        _path = path,
    })
    aSameObj = URL:new({
        _path = path,
    })
    assert(obj:samePath(aSameObj), "path should be the same")
    aDifferentObj = URL:new({
        _path = path2,
    })
    assert(not obj:samePath(aDifferentObj), "path should not be the same")

    -- same base
    obj = URL:new({
        _host = host2,
        _port = port,
        _path = path,
    })
    aSameObj = URL:new({
        _host = host2,
        _port = port,
        _path = path,
    })
    assert(obj:samePath(aSameObj), "base should be the same")
    aDifferentObj = URL:new({
        _host = host2,
        _port = port,
        _path = path2,
    })
    assert(not obj:samePath(aDifferentObj), "base should not be the same")

    -- same query
    obj = URL:new({
        _query = query,
    })
    aSameObj = URL:new({
        _query = query,
    })
    assert(obj:sameQuery(aSameObj), "query should be the same")
    aDifferentObj = URL:new({
        _query = query2,
    })
    assert(not obj:sameQuery(aDifferentObj), "query should not be the same")
end

function T_URL.T_baseCopy()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":baseCopy() tests")
    local obj = URL:new({
        _host = host,
        _port = port,
        _path = path,
        _query = query,
    })

    -- test
    local baseCopy = obj:baseCopy()
    AssertWithURIs(baseCopy, hostURI, portURI, pathURI, "")

    -- cleanup test
end

return T_URL
