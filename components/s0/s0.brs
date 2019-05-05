
sub init()
    m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
    

    oh = createObject("roSGNode", "OverHang")
    m.top.appendChild(oh)
    m.Overhang = oh

    ps =  createObject("roSGNode", "PanelSet")
    m.top.appendChild(ps)
    m.panelSet = ps

    oh.showOptions = true
    loadCategories()
    m.top.setFocus(true)
    initVideoPlayer()
end sub

sub initVideoPlayer()
    m.video = createObject("roSGNode", "Video")
    m.video.visible = false
    m.top.appendChild(m.video)
    m.video.observeField("state","controlvideoplay")
end sub

sub controlvideoplay()
    print m.video.state
    if (m.video.state = "finished") then
        m.video.control = "stop"
        'm.videolist.setFocus(true)
        m.video.visible = false
    else if(m.video.state = "error") then
        m.listpanel4.random = RND(999999)
    end if
end sub

function onKeyEvent(key as string,press as boolean) as boolean
    if press then
        if key = "back"
            if (m.video.state = "playing")
                m.video.control = "stop"
                'm.videolist.setFocus(true)
                m.video.visible = false
                m.listpanel4.random = RND(999999)
                ''m.listpanel4.setFocus(true)
                return true
            end if
        end if
    end if
    return false
end function

sub loadCategories()
    m.LoadTask = CreateObject("roSGNode", "SimpleTask")
    m.LoadTask.uri = "http://mediacatalogadmin.herokuapp.com/api/playlist"
    m.LoadTask.observeField("content", "categoryLoaded")
    print "setting to execution of category load task"
    m.LoadTask.control = "RUN"
end sub

sub categoryLoaded()
    setpanels()
    print "Loading categories..."
    resultAsJson = ParseJSON(m.LoadTask.content)

    ContentNode_object = createObject("RoSGNode", "ContentNode")

    m.categoriespanel.list.content = ContentNode_object

    ' ContentNode_child_object = ContentNode_object.createChild("ContentNode")
    ' ContentNode_child_object.title = "Choose category"

    for each categoryKey in resultAsJson
        ContentNode_child_object = ContentNode_object.createChild("ContentNode")
        ContentNode_child_object.title = categoryKey.displayName
        ContentNode_child_object.ShortDescriptionLine1 = categoryKey.id
        print categoryKey.displayName
    end for

    m.categoriespanel.list.observeField("itemFocused", "showcategorymedia")

    m.categoriespanel.setFocus(true)
end sub

sub showcategorymedia()
    categorycontent = m.categoriespanel.list.content.getChild(m.categoriespanel.list.itemFocused)
    m.gridPanel.categoryKey = categorycontent.ShortDescriptionLine1
    ' m.gridPanel.overhangtext = categorycontent.title
end sub

sub setpanels()
    m.categoriespanel = m.panelSet.createChild("s1")
    m.gridPanel = m.panelSet.createChild("s2")
    m.listpanel3 = createObject("RoSGNode","s3")
    m.listpanel4 = createObject("RoSGNode", "s4")
    m.listpanel4.video = m.video

    m.listpanel3.topcontainer = m.top
    m.listpanel3.gridPanel = m.gridPanel
    m.gridPanel.grid.observeField("itemFocused", "showCurrentSelectedMediaInfo")
    m.gridPanel.observeField("focusedChild", "slidepanels")
    m.listpanel3.observeField("focusedChild", "slidepanels1")
end sub

sub showCurrentSelectedMediaInfo()
    currentSelectedMediaItem = m.gridPanel.grid.content.getChild(m.gridPanel.grid.itemFocused)
    m.Overhang.title = currentSelectedMediaItem.shortdescriptionline1
    m.listpanel3.mediaItem = currentSelectedMediaItem
    print "selection changed"
end sub

sub slidepanels()
    if not m.panelSet.isGoingBack
        if m.panelSet.leftPanelIndex = 0 then
            m.panelSet.appendChild(m.listpanel3)
        end if
    else
        m.listpanel3.posterMode = "normal"
        m.gridPanel.setFocus(true)
    end if
end sub

sub slidepanels1()
    if not m.panelSet.isGoingBack
        if m.panelSet.leftPanelIndex = 1 then
            m.listpanel3.posterMode = "full"
            m.panelSet.appendChild(m.listpanel4)
            m.listpanel4.mediaItem = m.listpanel3.mediaItem
        end if
    end if
end sub