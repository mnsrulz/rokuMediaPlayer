
sub init()
    m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
    m.top.Overhang.showOptions = true
    loadCategories()
end sub

sub loadCategories()
    m.LoadTask = CreateObject("roSGNode", "SimpleTask")
    m.LoadTask.uri = "http://mediacatalogadmin.herokuapp.com/api/playlist"
    m.LoadTask.observeField("content", "categoryLoaded")
    print "setting to execution of category load task"
    m.LoadTask.control = "RUN"
end sub

sub categoryLoaded()
    setpanels()
    print "content change"
    resultAsJson = ParseJSON(m.LoadTask.content)

    ContentNode_object = createObject("RoSGNode", "ContentNode")

    m.categoriespanel.list.content = ContentNode_object

    ContentNode_child_object = ContentNode_object.createChild("ContentNode")
    ContentNode_child_object.title = "Choose category"

    for each categoryKey in resultAsJson
        ContentNode_child_object = ContentNode_object.createChild("ContentNode")
        ContentNode_child_object.title = categoryKey.displayName
        print categoryKey.displayName
    end for

    'm.categorymedialist = m.top.panelSet.createChild("s2")
    m.categoriespanel.list.observeField("itemFocused", "showcategorymedia")

    m.categoriespanel.setFocus(true)
end sub

sub showcategorymedia()
    categorycontent = m.categoriespanel.list.content.getChild(m.categoriespanel.list.itemFocused)
    m.gridPanel.categoryKey = categorycontent.title
    m.gridPanel.overhangtext = categorycontent.title
end sub

sub setpanels()
    m.categoriespanel = m.top.panelSet.createChild("s1")
    m.gridPanel = m.top.panelSet.createChild("s2")
    m.listpanel3 = createObject("RoSGNode","s3")


    m.listpanel3.topcontainer = m.top
    m.listpanel3.gridPanel = m.gridPanel
    m.gridPanel.grid.observeField("itemFocused", "showCurrentSelectedMediaInfo")
    m.gridPanel.observeField("focusedChild", "slidepanels")
end sub

sub showCurrentSelectedMediaInfo()
    currentSelectedMediaItem = m.gridPanel.grid.content.getChild(m.gridPanel.grid.itemFocused)
    m.gridPanel.overhangtext = currentSelectedMediaItem.shortdescriptionline1
    m.listpanel3.videoUrl = "http://apighost.herokuapp.com/api/gddirectstreamurl/" + currentSelectedMediaItem.shortdescriptionline2
    print "selection changed"
    ''print currentSelectedMediaItem
end sub

sub slidepanels()
    if not m.top.panelSet.isGoingBack
        m.top.panelSet.appendChild(m.listpanel3)
        m.gridPanel.setFocus(true)
        'm.gridPanel.panelSize = "narrow"
    else
        m.gridPanel.setFocus(true)
    end if
end sub

