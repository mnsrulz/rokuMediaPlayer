
sub init()
    m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
    oh = createObject("roSGNode", "OverHang")
    m.top.appendChild(oh)
    m.Overhang = oh

    m.panelSet =  createObject("roSGNode", "PanelSet")
    m.top.appendChild(m.panelSet)

    oh.showOptions = true
    loadCategories()
    m.top.setFocus(true)
    initVideoPlayer()
end sub

sub initVideoPlayer()
    m.video = createObject("roSGNode", "Video")
    m.video.visible = false
    m.top.appendChild(m.video)
end sub

function onKeyEvent(key as string,press as boolean) as boolean
    ' This event is an overhead, but we have live with it. 
    if press then
        if key = "back"
            if (m.video.visible)
                m.video.control = "stop"
                m.video.visible = false
                m.mediaSourcesPanel.lastFocusNode.setFocus(true)
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
    m.Overhang.title = categorycontent.title
end sub

sub setpanels()
    m.categoriespanel = m.panelSet.createChild("PlaylistScreen")
    m.gridPanel = m.panelSet.createChild("PosterGridScreen")
    m.gridPanel.grid.observeField("itemFocused", "showCurrentSelectedMediaInfo")
end sub

sub showCurrentSelectedMediaInfo()
    currentSelectedMediaItem = m.gridPanel.grid.content.getChild(m.gridPanel.grid.itemFocused)
    
    m.posterPanel = createObject("RoSGNode","MediaPosterScreen")
    m.posterPanel.mediaItem = currentSelectedMediaItem
    m.gridPanel.nextPanel = m.posterPanel
    m.posterPanel.observeField("focusedChild", "onFucusPosterPanel")
    print "selection changed"
end sub

sub onFucusPosterPanel()
    if not m.panelSet.isGoingBack
        m.posterPanel.posterMode = "full"
        mediaSourcesPanel = createObject("RoSGNode", "PlayableMediaListScreen")
        mediaSourcesPanel.video = m.video
        m.mediaSourcesPanel = mediaSourcesPanel
        m.panelSet.appendChild(mediaSourcesPanel)
        currentSelectedMediaItem = m.gridPanel.grid.content.getChild(m.gridPanel.grid.itemFocused)
        mediaSourcesPanel.mediaItem = currentSelectedMediaItem
        m.mediaSourcesPanel.setFocus(true)
    else
        m.posterPanel.posterMode = ""
    end if
end sub