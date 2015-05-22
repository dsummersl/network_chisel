description = "show request data a network connect/close"
short_description = "network time"
category = "network"

args = {}
connects = {}

function on_init()
    fdnumtype = chisel.request_field("fd.num")
    fdiptype = chisel.request_field("fd.ip")
    ciptype = chisel.request_field("fd.cip")
    siptype = chisel.request_field("fd.sip")
    cporttype = chisel.request_field("fd.cport")
    sporttype = chisel.request_field("fd.sport")
    evttype = chisel.request_field("evt.type")
    evtlatency = chisel.request_field("evt.latency")
    evtdirytype = chisel.request_field("evt.dir")
    rawtimetype = chisel.request_field("evt.rawtime")
    datetimetype = chisel.request_field("evt.datetime")
    tidtype = chisel.request_field("thread.tid")
    argstype = chisel.request_field("evt.args")
    print("datetime" .."	".. "ts" .."	".. "milliseconds" .."	".. "client" .."	".. "server" .."	".. "write" .."	".. "read")
    return true
end

function on_event()
    tid = evt.field(tidtype)
    dir = evt.field(evtdirytype)
    etype = evt.field(evttype)

    if etype == "connect" and dir == "<" then
        fdnum = evt.field(fdnumtype)
        connects[tid .."-".. fdnum] = {}
        connects[tid .."-".. fdnum].connectlatency = evt.field(evtlatency)
        connects[tid .."-".. fdnum].start = evt.field(rawtimetype)
        connects[tid .."-".. fdnum].sip = evt.field(siptype) or "?"
        connects[tid .."-".. fdnum].cip = evt.field(ciptype) or "?"
        connects[tid .."-".. fdnum].sport = evt.field(sporttype) or "?"
        connects[tid .."-".. fdnum].cport = evt.field(cporttype) or "?"
        connects[tid .."-".. fdnum].write = ""
        connects[tid .."-".. fdnum].read = ""
    end

    if etype == "write" and dir == "<" then
        fdnum = evt.field(fdnumtype)
        data = connects[tid .."-".. fdnum]
        if data ~= nil then
            connects[tid .."-".. fdnum].write = string.sub(evt.field(argstype),0,100)
        else
            -- Long running 'alive' transaction probably fall into this
            -- print("no id for ".. tid .."-".. fdnum)
        end
    end

    if etype == "read" and dir == "<" then
        fdnum = evt.field(fdnumtype)
        args = evt.field(argstype)
        data = connects[tid .."-".. fdnum]
        if data ~= nil then
            connects[tid .."-".. fdnum].read = string.sub(evt.field(argstype),0,100)
        else
            -- Long running 'alive' transaction probably fall into this
            -- print("no id for ".. tid .."-".. fdnum)
        end
    end

    if etype == "close" then
        fdnum = evt.field(fdnumtype)
        data = connects[tid .."-".. fdnum]
        if data ~= nil then
            delta = evt.field(rawtimetype) - data.start
            print(evt.field(datetimetype) .."	".. evt.field(rawtimetype) .."	".. math.floor(delta / 1000000) .."	".. data.cip ..":".. data.cport .."	".. data.sip ..":".. data.sport .."	".. data.write .."	".. data.read)
            data = nil
        end
    end
    return true
end
