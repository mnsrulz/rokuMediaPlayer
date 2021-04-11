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
    m.loadPlaylistTask = CreateObject("roSGNode", "AuthenticatedClient")
    requesturi = "https://mediacatalog.netlify.app/.netlify/functions/server/playlists?includeSystemDefined=true"
    m.loadPlaylistTask.uri = requesturi
    m.loadPlaylistTask.observeField("content", "onPlaylistLoadCompleted")
    m.loadPlaylistTask.control = "RUN"
end sub

sub onPlaylistLoadCompleted()
    print("onPlaylistLoadCompleted...")
    resultAsJson = ParseJSON(m.loadPlaylistTask.content)
    parsedContent = createObject("RoSGNode", "ContentNode")
    for each playlist in resultAsJson
        playlistItem = parsedContent.createChild("ContentNode")
        playlistItem.title = playlist.title
        playlistItem.ShortDescriptionLine1 = playlist.id
    end for
    m.top.observeField("createNextPanelIndex", "onCreateNextPanel")
    m.top.list.content = parsedContent
    m.top.list.setFocus(true)
end sub

sub onCreateNextPanel()
    currentSelectedPlaylistItem = m.top.list.content.getChild(m.top.createNextPanelIndex)
    m.gridPanel = createObject("RoSGNode", "PosterGridScreen")
    m.gridPanel.playlistId = currentSelectedPlaylistItem.ShortDescriptionLine1
    m.top.nextPanel = m.gridPanel
end sub
