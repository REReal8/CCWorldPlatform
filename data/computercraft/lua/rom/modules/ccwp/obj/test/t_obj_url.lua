local T_URL = {}

local corelog = require "corelog"

local URL = require "obj_url"

local IObj = require "i_obj"
local ObjBase = require "obj_base"

local T_Object = require "test.t_object"
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
local function createTestObj()
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
    corelog.WriteToLog("* Test URL serialize")
    local aURL = URL:new({
        _host = host,
        _port = port,
        _path = path,
        _query = query,
    })
    corelog.WriteToLog(" aURL:getURI() = "..aURL:getURI())

    corelog.WriteToLog(" aURL type = "..type(aURL))
    corelog.WriteToLog(" 1: aURL = "..aURL:getURI())
    corelog.WriteToLog(" 2: aURL = "..textutils.serialize(aURL))
end

function T_URL.T_new()
    -- prepare test
    corelog.WriteToLog("* URL:new() and getter tests")
    local url = URL:new({
        _host = host,
        _port = port,
        _path = path,
        _query = query,
    })

    -- test
    local testResult = url:getScheme()
    local expectedResultStr = scheme
    assert(testResult == expectedResultStr, "getScheme() return(="..testResult..") different from expected(="..expectedResultStr..")")

    testResult = url:getHost()
    expectedResultStr = host
    assert(testResult == expectedResultStr, "getHost() return(="..testResult..") different from expected(="..expectedResultStr..")")

    testResult = url:getPort()
    local expectedResultNumber = port
    assert(testResult == expectedResultNumber, "getPort() return(="..testResult..") different from expected(="..expectedResultNumber..")")

    testResult = url:getPath()
    expectedResultStr = path
    assert(testResult == expectedResultStr, "getPath() return(="..testResult..") different from expected(="..expectedResultStr..")")
    local iPathSegment = 1
    for pathSegment in url:pathSegments_iter() do
        expectedResultStr = pathSegments[iPathSegment]
        assert(pathSegment == expectedResultStr, "pathSegment(="..pathSegment..") different from expected(="..expectedResultStr..")")
        iPathSegment = iPathSegment + 1
    end

    testResult = url:getQuery()
    local expectedResultTable = query
    assert(testResult == expectedResultTable, "getQuery() return(="..textutils.serialize(testResult)..") different from expected(="..textutils.serialize(expectedResultTable)..")")

    -- test default
    url = URL:new()
    assert(url:getHost() == "", "gotten getHost(="..url:getHost()..") not the same as expected(=``)")
    assert(type(url:getPort()) == "nil", "gotten getPort(="..(url:getPort() or "nil")..") not the same as expected(=nil)")
    assert(url:getPath() == "", "gotten getPath(="..url:getPath()..") not the same as expected(=``)")
    assert(url:getQueryURI() == "", "gotten getQueryURI(="..url:getQueryURI()..") not the same as expected(=``)")

    -- cleanup test
end

function T_URL.T_GettersURI()
    -- prepare test
    corelog.WriteToLog("* URL URI getter tests")
    local url = URL:new({
        _host = host,
        _port = port,
        _path = path,
        _query = query,
    })

    -- test
    assert(url:getSchemeURI() == schemeURI, "getSchemeURI() return(="..url:getSchemeURI()..") different from expected(="..schemeURI..")")
    AssertWithURIs(url, hostURI, portURI, pathURI, queryURI)
    assert(url:getAuthorityURI() == hostURI..portURI, "getAuthorityURI() return(="..url:getAuthorityURI()..") different from expected(="..hostURI..portURI..")")

    -- cleanup test
end

function AssertWithURIs(aURL, aHostURI, aPortURI, aNPathURI, aQueryURI)
    -- test
    assert(aURL:getHostURI() == aHostURI, "getHostURI() return(="..aURL:getHostURI()..") different from expected(="..aHostURI..")")
    assert(aURL:getPortURI() == aPortURI, "getPortURI() return(="..aURL:getPortURI()..") different from expected(="..aPortURI..")")
    assert(aURL:getPathURI() == aNPathURI, "getPathURI() return(="..aURL:getPathURI()..") different from expected(="..aNPathURI..")")
    assert(aURL:getQueryURI() == aQueryURI, "getQueryURI() return(="..aURL:getQueryURI()..") different from expected(="..aQueryURI..")")
    local expectedResultStr = schemeURI..aHostURI..aPortURI..aNPathURI..aQueryURI
    assert(aURL:getURI() == expectedResultStr, "getURI() return(="..aURL:getURI()..") different from expected(="..expectedResultStr..")")
end

function T_URL.T_Setters()
    -- prepare test
    corelog.WriteToLog("* URL setter tests")
    local setterURL = URL:new()

    -- test
    setterURL:setHost(host)
    assert(setterURL:getHost() == host, "setHost() result(="..setterURL:getHost()..") different from expected(="..host..")")

    setterURL:setPort(port)
    assert(setterURL:getPort() == port, "setPort() result(="..setterURL:getPort()..") different from expected(="..port..")")

    setterURL:setPath(path)
    assert(setterURL:getPath() == path, "setPath() result(="..textutils.serialize(setterURL:getPath())..") different from expected(="..textutils.serialize(path)..")")

    setterURL:setQuery(query)
    assert(setterURL:getQuery() == query, "setHost() result(="..textutils.serialize(setterURL:getQuery())..") different from expected(="..textutils.serialize(query)..")")

    -- cleanup test
end

function T_URL.T_SettersFromURI()
    -- prepare test
    corelog.WriteToLog("* URL setter from URI tests")
    local uriSetterURL = URL:new()

    -- test
    uriSetterURL:setHostURI(hostURI)
    assert(uriSetterURL:getHostURI() == hostURI, "setHostURI() result(="..uriSetterURL:getHostURI()..") different from expected(="..hostURI..")")

    uriSetterURL:setPortURI(portURI)
    assert(uriSetterURL:getPortURI() == portURI, "setPortURI() result(="..uriSetterURL:getPortURI()..") different from expected(="..portURI..")")

    uriSetterURL:setPathURI(pathURI)
    assert(uriSetterURL:getPathURI() == pathURI, "setPathURI() result(="..uriSetterURL:getPathURI()..") different from expected(="..pathURI..")")

    uriSetterURL:setQueryURI(queryURI)
    local testResult = uriSetterURL:getQuery()
    assert(testResult[itemName1] == itemCount1, "testResult.itemName1 (="..testResult[itemName1]..") different from expected(="..itemCount1..")")
    assert(testResult[itemName2] == itemCount2, "testResult.itemName1 (="..testResult[itemName2]..") different from expected(="..itemCount2..")")

    -- cleanup test
end

function T_URL.T_NewFromURI()
    -- prepare test
    corelog.WriteToLog("* URL from URI tests (0)")

    -- test
    local newURI0=schemeURI..hostURI..portURI..pathURI..queryURI
    local fromURI_URL0 = URL:newFromURI(newURI0)
    AssertWithURIs(fromURI_URL0, hostURI, portURI, pathURI, expectedQueryURI)

    corelog.WriteToLog("* URL from URI tests (1: no host)")
    local newURI1=schemeURI..portURI..pathURI..queryURI
    local fromURI_URL1 = URL:newFromURI(newURI1, true)
    AssertWithURIs(fromURI_URL1, "", "", "", "") -- note: implies failure (error)

    corelog.WriteToLog("* URL from URI tests (2: no port)")
    local newURI2=schemeURI..hostURI..pathURI..queryURI
    local fromURI_URL2 = URL:newFromURI(newURI2)
    AssertWithURIs(fromURI_URL2, hostURI, "", pathURI, expectedQueryURI)

    corelog.WriteToLog("* URL from URI tests (3: no path)")
    local newURI3=schemeURI..hostURI..portURI..queryURI
    local fromURI_URL3 = URL:newFromURI(newURI3)
    AssertWithURIs(fromURI_URL3, hostURI, portURI, "", expectedQueryURI)

    corelog.WriteToLog("* URL from URI tests (4: no query)")
    local newURI4=schemeURI..hostURI..portURI..pathURI
    local fromURI_URL4 = URL:newFromURI(newURI4)
    AssertWithURIs(fromURI_URL4, hostURI, portURI, pathURI, "")

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
    local obj = createTestObj() assert(obj, "failed obtaining "..testClassName)
    local otherObj = createTestObj() assert(otherObj, "failed obtaining "..testClassName)

    -- test
    T_Object.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Object.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
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
    corelog.WriteToLog("* URL same components tests")
    -- same Host
    local aURL = URL:new({
        _host = host,
    })
    local aSameURL = URL:new({
        _host = host,
    })
    assert(aURL:sameHost(aSameURL), "hosts should be the same")
    local aDifferentURL = URL:new({
        _host = host2,
    })
    assert(not aURL:sameHost(aDifferentURL), "hosts should not be the same")

    -- same Authority
    aURL = URL:new({
        _host = host2,
        _port = port,
    })
    aSameURL = URL:new({
        _host = host2,
        _port = port,
    })
    assert(aURL:sameAuthority(aSameURL), "authority should be the same")
    aDifferentURL = URL:new({
        _host = host2,
        _port = port2,
    })
    assert(not aURL:sameAuthority(aDifferentURL), "authority should not be the same")

    -- same path
    aURL = URL:new({
        _path = path,
    })
    aSameURL = URL:new({
        _path = path,
    })
    assert(aURL:samePath(aSameURL), "path should be the same")
    aDifferentURL = URL:new({
        _path = path2,
    })
    assert(not aURL:samePath(aDifferentURL), "path should not be the same")

    -- same base
    aURL = URL:new({
        _host = host2,
        _port = port,
        _path = path,
    })
    aSameURL = URL:new({
        _host = host2,
        _port = port,
        _path = path,
    })
    assert(aURL:samePath(aSameURL), "base should be the same")
    aDifferentURL = URL:new({
        _host = host2,
        _port = port,
        _path = path2,
    })
    assert(not aURL:samePath(aDifferentURL), "base should not be the same")

    -- same query
    aURL = URL:new({
        _query = query,
    })
    aSameURL = URL:new({
        _query = query,
    })
    assert(aURL:sameQuery(aSameURL), "query should be the same")
    aDifferentURL = URL:new({
        _query = query2,
    })
    assert(not aURL:sameQuery(aDifferentURL), "query should not be the same")
end

function T_URL.T_baseCopy()
    -- prepare test
    corelog.WriteToLog("* URL:baseCopy() tests")
    local obj1 = URL:new({
        _host = host,
        _port = port,
        _path = path,
        _query = query,
    })

    -- test
    local baseCopy = obj1:baseCopy()
    AssertWithURIs(baseCopy, hostURI, portURI, pathURI, "")

    -- cleanup test
end

return T_URL