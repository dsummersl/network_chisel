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
    evtnumtype = chisel.request_field("evt.num")
    evttype = chisel.request_field("evt.type")
    evtlatency = chisel.request_field("evt.latency")
    evtdirytype = chisel.request_field("evt.dir")
    rawtimetype = chisel.request_field("evt.rawtime")
    bytestype = chisel.request_field("evt.rawarg.res")
    datetimetype = chisel.request_field("evt.datetime")
    tidtype = chisel.request_field("thread.tid")
    argstype = chisel.request_field("evt.args")
    print("datetime" .."	".. "ts" .."	".. "milliseconds" .."	".. "client" .."	".. "server" .."	".. "bytes_wrote" .."	".. "bytes_read" .."	".. "write" .."	".. "read")
    return true
end

function on_event()
    tid = evt.field(tidtype)
    dir = evt.field(evtdirytype)
    etype = evt.field(evttype)

    if etype == "connect" and dir == "<" then
        fdnum = evt.field(fdnumtype)
        connects[tid .."-".. fdnum] = {}
        connects[tid .."-".. fdnum].evtnum = evt.field(evtnumtype)
        connects[tid .."-".. fdnum].connectlatency = evt.field(evtlatency)
        connects[tid .."-".. fdnum].start = evt.field(rawtimetype)
        connects[tid .."-".. fdnum].sip = evt.field(siptype) or "?"
        connects[tid .."-".. fdnum].cip = evt.field(ciptype) or "?"
        connects[tid .."-".. fdnum].sport = evt.field(sporttype) or "?"
        connects[tid .."-".. fdnum].cport = evt.field(cporttype) or "?"
        connects[tid .."-".. fdnum].write = ""
        connects[tid .."-".. fdnum].read = ""
        connects[tid .."-".. fdnum].bytes_read = 0
        connects[tid .."-".. fdnum].bytes_wrote = 0
    end

    if etype == "write" and dir == "<" then
        fdnum = evt.field(fdnumtype)
        data = connects[tid .."-".. fdnum]
        if data ~= nil then
            connects[tid .."-".. fdnum].write = string.sub(evt.field(argstype),0,100)
            connects[tid .."-".. fdnum].bytes_wrote = connects[tid .."-".. fdnum].bytes_wrote + evt.field(bytestype)
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
            connects[tid .."-".. fdnum].bytes_read = connects[tid .."-".. fdnum].bytes_read + evt.field(bytestype)
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
            -- to debug statements, this can be helful:
            -- print(tid .."-".. fdnum .." : ".. data.evtnum)
            print(evt.field(datetimetype) .."	".. math.floor(evt.field(rawtimetype) / 1000000) .."	".. math.floor(delta / 1000000) .."	".. data.cip ..":".. data.cport .."	".. data.sip ..":".. data.sport .."	".. data.bytes_wrote .."	".. data.bytes_read .."	".. data.write .."	".. data.read)
            connects[tid .."-".. fdnum] = nil
        end
    end
    return true
end
