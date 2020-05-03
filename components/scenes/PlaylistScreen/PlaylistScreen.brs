sub init()
    m.top.panelSize = "narrow"
    m.top.focusable = true
    m.top.hasNextPanel = true
    m.top.leftOnly = true
    m.top.createNextPanelOnItemFocus = true
    m.top.selectButtonMovesPanelForward = true
    m.top.list = m.top.findNode("innerList")
    loadCategories()
    m.top.list.setFocus(true)
end sub

sub loadCategories()
    m.LoadTask = CreateObject("roSGNode", "SimpleTask")
    m.LoadTask.uri = "http://mediacatalogadmin.herokuapp.com/api/playlist"
    m.LoadTask.observeField("content", "onCategoryLoadCompleted")
    print "setting to execution of category load task"
    m.LoadTask.control = "RUN"
end sub

sub onCategoryLoadCompleted()
    resultAsJson = ParseJSON(m.LoadTask.content)
    parsedContent = createObject("RoSGNode", "ContentNode")
    for each categoryKey in resultAsJson
        playlistItem = parsedContent.createChild("ContentNode")
        playlistItem.title = categoryKey.displayName
        playlistItem.ShortDescriptionLine1 = categoryKey.id
    end for
    m.top.observeField("createNextPanelIndex", "onCreateNextPanel")
    m.top.list.content = parsedContent
    m.top.list.setFocus(true)
end sub

sub onCreateNextPanel()
    currentSelectedPlaylistItem = m.top.list.content.getChild(m.top.createNextPanelIndex)
    m.gridPanel = createObject("RoSGNode", "PosterGridScreen")
    m.gridPanel.categoryKey = currentSelectedPlaylistItem.ShortDescriptionLine1
    m.top.nextPanel = m.gridPanel
end sub
