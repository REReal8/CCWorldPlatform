local corejob = {}
local coresystem = require "coresystem"
local coredht = require "coredht"
local corelog = require "corelog"
local coreutils = require "coreutils"
local coretask = require "coretask"

local db = {
    dhtRoot     = "jobs",
    currentJob  = nil,
}

function corejob.Init()
end

function corejob.Setup()
    -- pas als de dht klaar is...
    coredht.DHTReadyFunction(DHTReadySetup)
end

function NewJob(jobData)
    -- parameters snel controleren (meteen definitie van de data)
    local enterpriseId  = jobData.enterpriseId  or GetCurrentEnterpriseId()         --> een turtle of computer is altijd in dienst van een enterprise!
    local location      = jobData.location      or nil                              --> nil-waarde voor locatie geeft aan dat locatie geen rol speelt bij de selectie
    local startTime     = jobData.startTime     or coreutils.UniversalTime()        --> tijd wanneer de job uitgevoerd moet worden, zal niet starten voor deze tijd
    local needTool      = jobData.needTool      or false                            --> needTool geeft aan dat de turtle zelf voor een tool moet zorgen
    local needTurtle    = jobData.needTurtle    or true

    -- jobId aanmaken
    local jobId             = coreutils.NewId()
    local enterpriseName    = coredht.GetData("enterprises", enterpriseId, "enterpriseName")

    -- opslaan job (job meta data and job internal data)
    coredht.SaveData({
        jobId           = jobId,
        enterpriseId    = enterpriseId,
        enterpriseName  = enterpriseName,
        startTime       = startTime,
        location        = location,
        needTool        = needTool,
        needTurtle      = needTurtle,
        status          = "open",
        applications    = {}
    }, db.dhtRoot, jobId)
end

function GetCurrentEnterpriseId()
    -- sneaky
    return coredht.GetData(db.dhtRoot, db.currentJob, "enterpriseId")
end

function GetJobEnterpriseId(jobId)
    -- sneaky
    return coredht.GetData(db.dhtRoot, jobId, "enterpriseId")
end

function corejob.Run()
    -- is de dth al beschikbaar?
    while not coredht.IsReady() do

        -- gewoon ff wachten
        os.sleep(0.25)
    end

    -- dit blijven we altijd doen
    while coresystem.IsRunning() do

        -- we zijn nu werkeloos
        local nextJob = nil

        -- volgende job zoeken
        local jobApplication = FindBestVacancy()

        -- hebben we een job waar we geschik voor zijn?
        if jobApplication then

            -- inschrijven
            ApplyToJob(jobApplication)

            -- ff wachten, wellicht hebben meer zich ingeschreven
            os.sleep(1.25)

            -- controle wie de job krijgt
            nextJob = JobSelectionProcedure(jobApplication)
        end

        -- hebben we iets?
        if nextJob  then DoJob(nextJob)     -- we gaan beginnen aan deze job
                    else os.sleep(0.25)     -- blijkbaar is er geen werk op dit moment
        end
    end
end

function DummyTask()
    -- handig zodat er altijd iets is, kost ook weer een pull event
    os.sleep(0.05)
end

--    _                 _    __                  _   _
--   | |               | |  / _|                | | (_)
--   | | ___   ___ __ _| | | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | |/ _ \ / __/ _` | | |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | (_) | (_| (_| | | | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_|\___/ \___\__,_|_| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--
--

function DHTReadySetup()
    -- bestaat de entry al in de dht?
    if not coredht.GetData(db.dhtRoot) then coredht.SaveData({}, db.dhtRoot ) end
end

function FindBestVacancy()
--    corelog.WriteToLog("Running FindBestVacancy")

    -- zoeken naar een job om op in te schrijven
    local jobs  = coredht.GetData(db.dhtRoot)
    local now   = coreutils.UniversalTime()

    -- kijken of we een lege lijst hebben gekregen?
    if not jobs or type(jobs) ~= "table" then return nil end

    -- op zoek naar de beste job
    for jobId, jobData in pairs(jobs) do

        -- ff status controleren, verdere controles later
        if jobData.status == "open" and jobData.startTime <= now then return jobId end
    end

    -- niks gevonden
    return nil
end

function ApplyToJob(jobId)
--    corelog.WriteToLog("Running ApplyToJob")

    -- alleen solliciteren indien de job open is
    if coredht.GetData(db.dhtRoot, jobId, "status") == "open" then

        -- wie zijn we?
        local me = os.getComputerID()

        -- onzelf (os.getComputerID()) toevoegen aan de lijst met inschrijvingen
        coredht.SaveData({
            time            = coreutils.UniversalTime(),
            dice            = math.random(),
            applicant       = me,
        }, db.dhtRoot, jobId, "applications", me)
    end
end

function JobSelectionProcedure(jobId)
--    corelog.WriteToLog("Running JobSelectionProcedure")

    -- data van de job ophalen
    local job = coredht.GetData(db.dhtRoot, jobId) if not job then return nil end

    -- see if this job is still open, better selection later
    if job.status == "open" then return job end

    -- dit lijkt mij wel iets voor ons!
    return nil
end

function TakeJob(jobId)
--    corelog.WriteToLog("Running TakeJob("..jobId..")")

    -- this computer is apparently executing this job
    db.currentJob   = jobId

    -- mark as staffed
    coredht.SaveData("staffed", db.dhtRoot, jobId, "status")
end

function DoJob(job)
    local taskId    = nil

    corelog.WriteToLog("corejob still working (Guido want's to know)")

    -- we have taken this job!
    TakeJob(job.jobId)

    -- task functie klaar maken
    local f, err = loadstring("return "..job.enterpriseName..".ProcessNextTask("..textutils.serialize(job.enterpriseId)..")")
    if f then taskId = f() else corelog.Error("corejob.DoJob(): loadstring gaf geen functie terug, wel een error: "..err) end

    -- loopje doen om inbox te lezen zolang de task nog bezig is
    local messagePresent    = true
    while messagePresent or not coretask.TaskComplete(taskId) do
        -- assume no message here
        messagePresent    = false

        -- hier ooit de inbox van deze enterprise verwerken
        local f, err = loadstring(job.enterpriseName..".ProcessNextMessage("..textutils.serialize(job.enterpriseId)..")")
        if f then messagePresent = f() else corelog.Error("corejob.DoJob(): loadstring gaf geen functie terug, wel een error: "..err) end

        -- ff wachten
        os.sleep(0.05)
    end

    -- klaar met de task
    local f, err = loadstring(job.enterpriseName..".TaskComplete("..textutils.serialize(job.enterpriseId)..")")
    if f then f() else corelog.Error("corejob.DoJob(): loadstring gaf geen functie terug, wel een error: "..err) end

    -- we have done all for this job that we needed to do
    QuitJob(job.jobId)
end

function QuitJob(jobId)
    -- no long a salary slave of this enterprise F*CK THEM
    db.currentJob   = nil

    -- easy
    coredht.SaveData(nil, db.dhtRoot, jobId)
end

return corejob
