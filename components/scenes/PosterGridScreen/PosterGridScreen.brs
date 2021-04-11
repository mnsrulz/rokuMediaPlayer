
sub init()
    m.top.panelSize = "wide"
    m.top.focusable = true
    m.top.hasNextPanel = true
    m.top.createNextPanelOnItemFocus = true
    m.top.selectButtonMovesPanelForward = true
    m.top.grid = m.top.findNode("posterGridCategoryMedia")    
end sub

sub readpostergrid()
    if m.top.playlistId <> "" then
        m.loadPlaylistMediaItemTask = CreateObject("roSGNode", "AuthenticatedClient")
        requesturi = "https://mediacatalog.netlify.app/.netlify/functions/server/playlists/" + m.top.playlistId + "/items?pageSize=200"
        m.loadPlaylistMediaItemTask.uri = requesturi
        m.loadPlaylistMediaItemTask.observeField("content", "onPlaylistItemsLoadCompleted")
        m.loadPlaylistMediaItemTask.control = "RUN"
    else
        m.top.grid.content = createObject("roSGNode", "ContentNode")
    end if
end sub

sub onPlaylistItemsLoadCompleted()
    resultAsJson = ParseJSON(m.loadPlaylistMediaItemTask.content)
    if resultAsJson <> invalid
        parsedContent = createObject("roSGNode", "ContentNode")        
        for each mediaItem in resultAsJson.items
            gridPoster = createObject("roSGNode", "ContentNode")
            gridPoster.id = mediaItem.id
            gridPoster.shortdescriptionline1 = mediaItem.title
            gridPoster.Description = mediaItem.overview
            '"poster_sizes": ['  "w92","w154","w185","w342","w500","w780","original"'],
            gridPoster.SDPosterUrl = "https://image.tmdb.org/t/p/w342" + mediaItem.posterPath
            gridPoster.HDPosterUrl = "https://image.tmdb.org/t/p/w342" + mediaItem.posterPath
            gridPoster.Url = "https://image.tmdb.org/t/p/w500" + mediaItem.posterPath
            gridPoster.addFields({ 
                imdbId: mediaItem.imdbId, 
                posterPath: mediaItem.posterPath,
                title: mediaItem.title,
                year: mediaItem.year
            })
            parsedContent.appendChild(gridPoster)
        end for
        m.top.observeField("createNextPanelIndex", "onCreateNextPanel")
        m.top.grid.content = parsedContent
        m.itemsCount = str(resultAsJson.count)
        setRightLabel(1)
    end if
end sub

sub setRightLabel(index)
    m.top.rightLabel.text = str(index) + " of " + m.itemsCount
end sub

sub onCreateNextPanel()
    currentSelectedMediaItem = m.top.grid.content.getChild(m.top.createNextPanelIndex)
    m.posterPanel = createObject("RoSGNode", "MediaPosterScreen")
    m.posterPanel.mediaItem = currentSelectedMediaItem
    m.posterPanel.observeField("focusedChild", "onFucusPosterPanel")
    m.top.nextPanel = m.posterPanel
    setRightLabel(m.top.createNextPanelIndex + 1)
end sub

sub onFucusPosterPanel()
    if not m.global.panelSetNode.isGoingBack
        if m.posterPanel.hasFocus()
            m.posterPanel.posterMode = "full"
            mediaSourcesPanel = m.global.panelSetNode.createChild("PlayableMediaListScreen")
            currentSelectedMediaItem = m.top.grid.content.getChild(m.top.grid.itemFocused)
            mediaSourcesPanel.mediaItem = currentSelectedMediaItem
        end if
    else
        m.posterPanel.posterMode = ""
    end if
end sub