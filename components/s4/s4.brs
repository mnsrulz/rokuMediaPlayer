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

sub readmediaitem()
    ContentNode_object = createObject("RoSGNode", "ContentNode")
    m.list.content = ContentNode_object

    currentitem = m.top.mediaItem
    for each categoryKey in currentitem.Streams
        ContentNode_child_object = ContentNode_object.createChild("ContentNode")
        ContentNode_child_object.title = categoryKey.contentid
        ContentNode_child_object.url = categoryKey.url
        print categoryKey.displayName
    end for

    m.list.observeField("itemFocused", "preloadmedia")

    m.mediaTitle.text = currentitem.shortdescriptionline1
    m.mediaDesc.text = currentitem.DESCRIPTION

    m.LoadTask = CreateObject("roSGNode", "SimpleTask")
    m.LoadTask.uri = "http://mediacatalogadmin.herokuapp.com/api/playlist"
    m.LoadTask.observeField("content", "fakeEvent")
    print "setting to execution of category load task"
    m.LoadTask.control = "RUN"
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

sub preloadmedia()
    selectedmediaitem = m.list.content.getChild(m.list.itemFocused)

    videoContent = createObject("RoSGNode", "ContentNode")
    videoContent.url = selectedmediaitem.url
    ''videoContent.title = "Test Video"
    videoContent.streamformat = "mkv"   ''should be passed from top
    videoContent.enableUI = true

    m.top.video.content = videoContent
    m.top.video.control = "prebuffer"

end sub

' function onKeyEvent(key as string, press as boolean) as boolean
'     handled = false
'     if press then
'         if (key = "back") then
'             handled = false
'         else
'             if (key = "OK") then

'             end if
'             handled = true
'         end if
'     end if
'     return handled
' end function

function onKeyEvent(key as string,press as boolean) as boolean
    if press then
        if key = "back"
            if (m.top.video.state = "playing")
                m.top.video.control = "stop"
                'm.videolist.setFocus(true)
                m.top.video.visible = false
                return true
            end if
        else if (key = "OK") then
            m.top.video.visible=true
            m.top.video.setFocus(true)
            m.top.video.control = "play"
        end if
    end if
    return false
end function
