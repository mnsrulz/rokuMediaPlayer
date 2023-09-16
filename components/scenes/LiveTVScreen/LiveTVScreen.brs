
sub init()
    m.top.panelSize = "wide"
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.createNextPanelOnItemFocus = false
    m.top.selectButtonMovesPanelForward = false
    m.top.grid = m.top.findNode("liveTVGrid")
end sub

sub readpostergrid()
    if m.top.playlistId <> "" then
        m.loadPlaylistMediaItemTask = CreateObject("roSGNode", "AuthenticatedClient")
        'requesturi = "https://mediacatalog.netlify.app/.netlify/functions/server/playlists/" + m.top.playlistId + "/items?pageSize=200"
        requesturi = "http://192.168.0.30:3005/liveTV"
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
        for each channel in resultAsJson.items
            gridPoster = createObject("roSGNode", "ContentNode")
            gridPoster.id = channel.id
            gridPoster.shortdescriptionline1 = channel.title
            if channel.logo <> invalid
                gridPoster.SDPosterUrl = channel.logo
                gridPoster.HDPosterUrl = channel.logo
                gridPoster.Url = channel.logo
            end if
            gridPoster.addFields({
                source: channel.source
            })
            parsedContent.appendChild(gridPoster)
        end for

        m.top.grid.observeField("itemSelected", "itemselected")
        m.top.grid.observeField("itemFocused", "onItemFocused")

        m.top.grid.content = parsedContent
        m.itemsCount = str(resultAsJson.count)
        setRightLabel(1)
    end if
end sub

sub setRightLabel(index)
    ''todo: put some guardrails here!!!
    currentSelectedChannel = m.top.grid.content.getChild(index - 1)
    m.top.rightLabel.text = currentSelectedChannel.shortdescriptionline1 + " - " + str(index) + " of " + str(m.top.grid.content.getChildCount())
end sub

sub onItemFocused()
    setRightLabel(m.top.grid.itemFocused + 1)
end sub

sub itemselected()
    currentSelectedChannel = m.top.grid.content.getChild(m.top.grid.itemFocused)
    videoContent = createObject("RoSGNode", "ContentNode")
    videoContent.url = currentSelectedChannel.source
    httpAgent = CreateObject("roHttpAgent")

    'if selectedmediaitem.headers <> invalid
    '    for each entry in selectedmediaitem.headers
    '        httpAgent.AddHeader(entry, selectedmediaitem.headers[entry])
    '    end for
    'end if

    httpAgent.AddHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36")

    if left(videoContent.url, 6) = "https:"
        httpAgent.SetCertificatesFile("common:/certs/ca-bundle.crt")
    end if
    m.global.videoNode.setHttpAgent(httpAgent)
    m.global.videoNode.content = videoContent

    m.global.lastFocusNode = m.top.grid
    m.global.liveTvSelectedIndex = m.top.grid.itemSelected


    m.global.videoNode.visible = true
    m.global.videoNode.enableUI = false
    m.global.videoNode.enableTrickPlay = false
    m.global.videoNode.setFocus(true)
    m.global.videoNode.seek = 9999999999 'to make it live
    m.global.videoNode.control = "play"
    m.global.isLiveTv = true
end sub