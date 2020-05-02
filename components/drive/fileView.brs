sub init()
    m.top.panelSize = "medium"
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.list = m.top.findNode("mediaSourceList")
    m.mediaTitle = m.top.findNode("mediaTitle")
    m.mediaDesc = m.top.findNode("mediaDesc")
    m.mediaFileName = m.top.findNode("mediaFileName")

    m.video = m.global.videoNode

end sub

sub readmediaitem()
    ContentNode_object = createObject("RoSGNode", "ContentNode")
    headers = {
        "Content-Type": "application/x-www-form-urlencoded" ,
        "Authorization": "Bearer " + m.global.accessToken
    }
    m.readMediaItemTask = CreateObject("roSGNode", "DynamicRequestTask1")
    'requesturi = "https://content.googleapis.com/drive/v2/files/" + m.top.fileId + "?alt=media&source=downloadUrl"
    requesturi = "https://drive.google.com/get_video_info?docid=" + m.top.fileId
    params = {
        url: requesturi,
        method: "GET",
        headers: headers
    }
    m.readMediaItemTask.params = params
    m.readMediaItemTask.observeField("content", "loadmediaitems")
    m.readMediaItemTask.control = "RUN"

    ' m.top.list.observeField("itemFocused", "preloadmedia")    should not be working
    m.top.list.observeField("itemSelected", "itemselected")


    ' m.lstMediaSources.content = ContentNode_object

    ' currentitem = m.top.mediaItem
    ' if currentitem.StreamContentIDs.Count() > 0
    '     ContentNode_child_object = ContentNode_object.createChild("ContentNode")
    '     ContentNode_child_object.title = "Loading media items"
    '     ContentNode_child_object.url = ""
    '     ContentNode_child_object.ShortDescriptionLine1 = ""
    '     ContentNode_child_object.ShortDescriptionLine2 = ""
    '     ' urltowatch = currentitem.StreamContentIDs[0]
    '     m.LoadMediaItemsTask = CreateObject("roSGNode", "SimpleTask")
    '     m.LoadMediaItemsTask.uri = currentitem.StreamContentIDs[0]
    '     m.LoadMediaItemsTask.observeField("content", "loadmediaitems")
    '     print "setting to execution of loading media items load task"
    '     m.LoadMediaItemsTask.control = "RUN"
    ' else
    '     for each categoryKey in currentitem.Streams
    '         ContentNode_child_object = ContentNode_object.createChild("ContentNode")
    '         ContentNode_child_object.title = categoryKey.contentid
    '         ContentNode_child_object.url = categoryKey.url
    '         ContentNode_child_object.ShortDescriptionLine1 = categoryKey.contentid.Split("|")[1]
    '         ContentNode_child_object.ShortDescriptionLine2 = categoryKey.contentid.Split("|")[2]
    '         print categoryKey.displayName
    '     end for
    '     m.lstMediaSources.setFocus(true)
    ' end if
    ' m.lstMediaSources.observeField("itemFocused", "preloadmedia")
    ' m.lstMediaSources.observeField("itemSelected", "itemselected")
    ' m.top.video.observeField("state", "controlvideoplay")

    ' m.mediaTitle.text = currentitem.shortdescriptionline1
    ' m.mediaDesc.text = currentitem.DESCRIPTION
    ' m.mediaFileName.text = ""
end sub

sub loadmediaitems()
    ContentNode_object = createObject("RoSGNode", "ContentNode")
    m.top.list.content = ContentNode_object
    ContentNode_child_object = ContentNode_object.createChild("ContentNode")
    ContentNode_child_object.title = "Original Video"
    ContentNode_child_object.url = "https://www.googleapis.com/drive/v3/files/" + m.top.fileId + "?alt=media"
    ContentNode_child_object.AddField("UseBearerTokenHeader", "boolean", false)
    ContentNode_child_object.UseBearerTokenHeader = true

    returncontent = m.readMediaItemTask.content
    source = 0
    for each innerItem in returncontent.playableUrls
        ContentNode_child_object = ContentNode_object.createChild("ContentNode")
        source = source + 1
        ContentNode_child_object.title = innerItem.resolution
        ContentNode_child_object.url = innerItem.source
        'ContentNode_child_object.ShortDescriptionLine1 = returncontent.cookie

        cookiecoll = []
        for each cookval in returncontent.cookie
            ' "dom=drive.google.com;path=/;name=DRIVE_STREAM;val=3OcHKSSaSTc;"
            ' if cookval.path = "drive.google.com" and (cookval.name = "S" or cookval.name = "DRIVE_STREAM") then
            cookiecoll.push("dom=" + cookval.domain + ";path=" + cookval.path + ";name=" + cookval.name + ";val=" + cookval.value + ";")
            ' end if
        end for

        ContentNode_child_object.AddField("CookieHeader", "roarray", false)
        ContentNode_child_object.CookieHeader = cookiecoll
    end for
    print "Loading media sources..."
end sub

sub preloadmedia()
    print "Preloading media"
    selectedmediaitem = m.top.list.content.getChild(m.top.list.itemFocused)
    previousvideocontenturl = ""
    if m.top.video.content <> invalid
        previousvideocontenturl = m.top.video.content.url
    end if
    if selectedmediaitem <> invalid
        if previousvideocontenturl <> selectedmediaitem.url
            videoContent = createObject("RoSGNode", "ContentNode")
            videoContent.url = selectedmediaitem.url
            m.mediaFileName.text = selectedmediaitem.title
            videoContent.streamformat = "auto"'getMediaStreamFormat(selectedmediaitem.ShortDescriptionLine1) ''should be passed from top
            videoContent.HttpHeaders = getMediaStreamHeaders(selectedmediaitem.ShortDescriptionLine2)
            m.top.video.content = videoContent
            m.top.video.control = "prebuffer"
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

sub itemselected()
    selectedmediaitem = m.top.list.content.getChild(m.top.list.itemFocused)
    videoContent = createObject("RoSGNode", "ContentNode")
    videoContent.url = selectedmediaitem.url
    ' videoContent.streamformat = getMediaStreamFormat(selectedmediaitem.ShortDescriptionLine1) ''should be passed from top

    videoContent.streamformat = "mkv"
    if selectedmediaitem.UseBearerTokenHeader <> invalid and selectedmediaitem.UseBearerTokenHeader = true then
        headersasarray = []
        headersasarray.push("Authorization:Bearer " + m.global.accessToken)
        videoContent.HttpHeaders = headersasarray
    else if selectedmediaitem.CookieHeader <> invalid then
        videoContent.HttpCookies = selectedmediaitem.CookieHeader
        videoContent.streamformat = "mp4"
    end if


    m.video.observeField("state", "controlvideoplay")
    m.video.content = videoContent
    m.video.visible = true
    m.global.lastFocusNode = m.top.list
    m.video.setFocus(true)
    m.video.control = "play"
end sub

sub controlvideoplay()
    print m.video.state
    if (m.video.state = "finished") then
        m.video.control = "stop"
        m.video.visible = false
        m.top.list.setFocus(true)
    else if (m.video.state = "buffering") then
        currentplayitem = m.video

    else if(m.video.state = "error") then
        ' itemfocusednow = m.lstMediaSources.itemFocused
        ' selectedmediaitem = m.lstMediaSources.content.getChild(itemfocusednow)
        ' selectedmediaitem.title = "ERROR READING SOURCE"
        m.top.list.setFocus(true)
    end if
end sub


