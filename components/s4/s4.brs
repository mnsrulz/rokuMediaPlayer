sub init()
    m.top.panelSize = "wide"
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.leftPosition = 130
    m.top.createNextPanelOnItemFocus = false
    m.list = m.top.findNode("mediaSourceList")
    m.mediaTitle = m.top.findNode("mediaTitle")
    m.mediaDesc = m.top.findNode("mediaDesc")
end sub

function IsString(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifString") <> invalid
end function

function IsValid(value as dynamic) as boolean
    return Type(value) <> "<uninitialized>" and value <> invalid
end function

function IsArray(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifArray") <> invalid
end function


sub readmediaitem()
    ContentNode_object = createObject("RoSGNode", "ContentNode")
    m.list.content = ContentNode_object

    currentitem = m.top.mediaItem
    if IsString(currentitem.url)
        ContentNode_child_object = ContentNode_object.createChild("ContentNode")
        ContentNode_child_object.title = "Loading media items"
        ContentNode_child_object.url = ""
        ContentNode_child_object.ShortDescriptionLine1 = ""
        ContentNode_child_object.ShortDescriptionLine2 = ""

        m.LoadTask = CreateObject("roSGNode", "SimpleTask")
        m.LoadTask.uri = currentitem.url
        m.LoadTask.observeField("content", "loadmediaitems")
        print "setting to execution of loading media items load task"
        m.LoadTask.control = "RUN"
    else
        for each categoryKey in currentitem.Streams
            ContentNode_child_object = ContentNode_object.createChild("ContentNode")
            ContentNode_child_object.title = categoryKey.contentid
            ContentNode_child_object.url = categoryKey.url
            ContentNode_child_object.ShortDescriptionLine1 = categoryKey.contentid.Split("|")[1]
            ContentNode_child_object.ShortDescriptionLine2 = categoryKey.contentid.Split("|")[2]
            print categoryKey.displayName
        end for
        m.LoadTask = CreateObject("roSGNode", "SimpleTask")
        m.LoadTask.uri = "http://mediacatalogadmin.herokuapp.com/api/playlist"
        m.LoadTask.observeField("content", "fakeEvent")
        print "setting to execution of category load task"
        m.LoadTask.control = "RUN"
    end if
    m.list.observeField("itemFocused", "preloadmedia")
    m.mediaTitle.text = currentitem.shortdescriptionline1
    m.mediaDesc.text = currentitem.DESCRIPTION
end sub

sub readRandom()
    m.LoadTask = CreateObject("roSGNode", "SimpleTask")
    m.LoadTask.uri = "http://mediacatalogadmin.herokuapp.com/api/playlist"
    m.LoadTask.observeField("content", "fakeEvent")
    print "setting to execution of category load task"
    m.LoadTask.control = "RUN"
end sub

sub fakeEvent()
    m.list.setFocus(true)
end sub

sub loadmediaitems()
    print "Loading media sources..."
    resultAsJson = ParseJSON(m.LoadTask.content)
    ContentNode_object = createObject("RoSGNode", "ContentNode")
    if resultAsJson <> invalid
        m.list.content = ContentNode_object
        for each categoryKey in resultAsJson.items
            ContentNode_child_object = ContentNode_object.createChild("ContentNode")
            ContentNode_child_object.title = categoryKey.title
            ContentNode_child_object.url = categoryKey.streamUrl
            ContentNode_child_object.ShortDescriptionLine1 = categoryKey.title
            ContentNode_child_object.ShortDescriptionLine2 = categoryKey.title
            print categoryKey.title
        end for
    else
        m.list.content[0].title = "Error... please try again"
    end if
    m.list.setFocus(true)
end sub


sub preloadmedia()
    selectedmediaitem = m.list.content.getChild(m.list.itemFocused)
    if selectedmediaitem <> invalid
        videoContent = createObject("RoSGNode", "ContentNode")
        videoContent.url = selectedmediaitem.url
        m.mediaTitle.text = selectedmediaitem.title
        videoContent.streamformat = getMediaStreamFormat(selectedmediaitem.ShortDescriptionLine1) ''should be passed from top
        videoContent.HttpHeaders = getMediaStreamHeaders(selectedmediaitem.ShortDescriptionLine2)
        ' videoContent.enableUI = true

        m.top.video.content = videoContent
        m.top.video.control = "prebuffer"
    end if
end sub

function getMediaStreamFormat(value as string) as string
    if value = "video/x-matroska"
        return "mkv"
    else if value = "application/x-matroska" then
        return "mkv"
    else if value = "video/mp4" then
        return "mp4"
    else if value = "video/avi" then
        return "mkv"
    else if value = "video/x-m4v" then
        return "mp4"
    else if value = "hls" then
        return "hls"
    else
        return "mkv"
    end if
end function

function getMediaStreamHeaders(headers as string) as object
    headersasarray = []
    for each header in headers.Split(";")
        headersasarray.push(header)
    end for
    return headersasarray
end function

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "back"
            if (m.top.video.state = "playing")
                m.top.video.control = "stop"
                'm.videolist.setFocus(true)
                m.top.video.visible = false
                return true
            end if
        else if (key = "OK") then
            m.top.video.visible = true
            m.top.video.setFocus(true)
            if (m.top.video.content.STREAMFORMAT = "hls")
                m.top.video.seek = 9999999999
            end if
            m.top.video.control = "play"
        end if
    end if
    return false
end function
