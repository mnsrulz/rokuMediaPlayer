sub init()
    m.top.panelSize = "wide"
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.list = m.top.findNode("mediaSourceList")
    m.lstMediaSources = m.top.findNode("mediaSourceList")
    m.mediaTitle = m.top.findNode("mediaTitle")
    m.mediaDesc = m.top.findNode("mediaDesc")
    m.mediaFileName = m.top.findNode("mediaFileName")

    m.faketimer = m.top.findNode("fakeTimer")
    m.faketimer.control = "start"
    m.faketimer.ObserveField("fire", "onSetupFocusTaskCompleted")
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

sub onSetupFocusTaskCompleted()
    m.top.list.setFocus(true)
end sub

sub readmediaitem()
    currentitem = m.top.mediaItem
    if currentitem.StreamContentIDs.Count() > 0
        m.LoadMediaItemsTask = CreateObject("roSGNode", "SimpleTask")
        m.LoadMediaItemsTask.uri = currentitem.StreamContentIDs[0]
        m.LoadMediaItemsTask.observeField("content", "loadmediaitems")
        print "setting to execution of loading media items load task"
        m.LoadMediaItemsTask.control = "RUN"
    else
        ContentNode_object = createObject("RoSGNode", "ContentNode")
        for each categoryKey in currentitem.Streams
            ContentNode_child_object = ContentNode_object.createChild("ContentNode")
            ContentNode_child_object.title = categoryKey.contentid
            ContentNode_child_object.url = categoryKey.url
            ContentNode_child_object.ShortDescriptionLine1 = categoryKey.contentid.Split("|")[1]
            ContentNode_child_object.ShortDescriptionLine2 = categoryKey.contentid.Split("|")[2]
            print categoryKey.displayName
        end for
        m.top.list.content = ContentNode_object
        m.top.list.setFocus(true)
    end if
    m.top.list.observeField("itemFocused", "preloadmedia")
    m.top.list.observeField("itemSelected", "itemselected")
    m.global.videoNode.observeField("state", "controlvideoplay")

    m.mediaTitle.text = currentitem.shortdescriptionline1
    m.mediaDesc.text = currentitem.DESCRIPTION
    m.mediaFileName.text = ""
end sub

sub loadmediaitems()
    print "Loading media sources..."
    resultAsJson = ParseJSON(m.LoadMediaItemsTask.content)
    ContentNode_object = createObject("RoSGNode", "ContentNode")
    if resultAsJson <> invalid
        m.lstMediaSources.content = ContentNode_object
        for each mediaItem in resultAsJson.items
            ContentNode_child_object = ContentNode_object.createChild("ContentNode")
            ContentNode_child_object.title = mediaItem.title
            ContentNode_child_object.url = mediaItem.streamUrl
            ContentNode_child_object.ShortDescriptionLine1 = mediaItem.mimeType

            ContentNode_child_object.addFields({ hostname: mediaItem.hostName })

            if mediaItem.headers <> invalid
                ContentNode_child_object.addFields({ headers: mediaItem.headers })
            end if

        end for
    else
        m.lstMediaSources.content = ContentNode_object
        ContentNode_child_object = ContentNode_object.createChild("ContentNode")
        ContentNode_child_object.title = "Error... please try again"
    end if
    m.lstMediaSources.setFocus(true)
end sub


sub preloadmedia()
    print "Preloading media"
    selectedmediaitem = m.lstMediaSources.content.getChild(m.lstMediaSources.itemFocused)
    previousvideocontenturl = ""
    if m.global.videoNode.content <> invalid
        previousvideocontenturl = m.global.videoNode.content.url
    end if
    if selectedmediaitem <> invalid
        if previousvideocontenturl <> selectedmediaitem.url
            videoContent = createObject("RoSGNode", "ContentNode")
            videoContent.url = selectedmediaitem.url
            if selectedmediaitem.hostname <> invalid
                m.mediaFileName.text = selectedmediaitem.hostname + " | " + selectedmediaitem.title
            else
                m.mediaFileName.text = selectedmediaitem.title    
            end if
            
            httpAgent = CreateObject("roHttpAgent")

            if selectedmediaitem.headers <> invalid
                for each entry in selectedmediaitem.headers
                    httpAgent.AddHeader(entry, selectedmediaitem.headers[entry])
                end for
            end if

            if left(selectedmediaitem.url, 6) = "https:"
                httpAgent.SetCertificatesFile("common:/certs/ca-bundle.crt")
            end if
            m.global.videoNode.setHttpAgent(httpAgent)
            m.global.videoNode.content = videoContent
            m.global.videoNode.control = "prebuffer"
        end if
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

sub itemselected()
    m.global.videoNode.visible = true
    m.global.videoNode.setFocus(true)
    if (m.global.videoNode.content.STREAMFORMAT = "hls")
        m.global.videoNode.seek = 9999999999
    end if
    m.global.videoNode.control = "play"
    m.global.lastFocusNode = m.top.list
end sub

sub controlvideoplay()
    print m.global.videoNode.state
    if (m.global.videoNode.state = "finished") then
        m.global.videoNode.control = "stop"
        m.global.videoNode.visible = false
        m.top.list.setFocus(true)
    else if (m.global.videoNode.state = "buffering") then
        currentplayitem = m.global.video
    else if(m.global.videoNode.state = "error") then
        ' itemfocusednow = m.lstMediaSources.itemFocused
        ' selectedmediaitem = m.lstMediaSources.content.getChild(itemfocusednow)
        ' selectedmediaitem.title = "ERROR READING SOURCE"
        m.top.list.setFocus(true)
    end if
end sub


