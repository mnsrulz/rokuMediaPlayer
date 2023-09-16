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
    parsedContent = createObject("RoSGNode", "ContentNode")
    if m.loadPlaylistTask.responseCode = "200"
        resultAsJson = ParseJSON(m.loadPlaylistTask.content)
        for each playlist in resultAsJson
            playlistItem = parsedContent.createChild("ContentNode")
            playlistItem.title = playlist.title
            playlistItem.ShortDescriptionLine1 = playlist.id
        end for

        playlistItem = parsedContent.createChild("ContentNode")
        playlistItem.title = "Live TV"
        playlistItem.ShortDescriptionLine1 = "live"
        m.top.observeField("createNextPanelIndex", "onCreateNextPanel")
    else
        playlistItem = parsedContent.createChild("ContentNode")
        if m.loadPlaylistTask.responseCode = "401"
            playlistItem.title = "Unauthorized access. Please make the package with a valid token in it."
        else
            playlistItem.title = "Unable to load playlist. Response code received " + m.loadPlaylistTask.responseCode
        end if
    end if
    m.top.list.content = parsedContent
    m.top.list.setFocus(true)
end sub

sub onCreateNextPanel()
    currentSelectedPlaylistItem = m.top.list.content.getChild(m.top.createNextPanelIndex)
    if currentSelectedPlaylistItem.ShortDescriptionLine1 = "live"
        m.gridPanel = createObject("RoSGNode", "LiveTVScreen")
        m.gridPanel.playlistId = currentSelectedPlaylistItem.ShortDescriptionLine1
    else
        m.gridPanel = createObject("RoSGNode", "PosterGridScreen")
        m.gridPanel.playlistId = currentSelectedPlaylistItem.ShortDescriptionLine1
    end if
    m.top.nextPanel = m.gridPanel
end sub
