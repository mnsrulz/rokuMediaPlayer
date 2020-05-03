
sub init()
    m.top.panelSize = "wide"
    m.top.focusable = true
    m.top.hasNextPanel = true
    m.top.createNextPanelOnItemFocus = true
    m.top.selectButtonMovesPanelForward = true
    m.top.grid = m.top.findNode("posterGridCategoryMedia")
end sub

sub readpostergrid()
    if m.top.categoryKey <> "" then
        print "read poster grid"
        m.readPosterGridTask = CreateObject("roSGNode", "SimpleTask")
        m.readPosterGridTask.uri = "http://mediacatalogadmin.herokuapp.com/api/playlist/" + m.top.categoryKey
        m.readPosterGridTask.observeField("content", "showpostergrid")
        m.readPosterGridTask.control = "RUN"
    else
        m.top.grid.content = createObject("roSGNode", "ContentNode")
    end if
end sub

function IsString(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifString") <> invalid
end function

function IsValid(value as dynamic) as boolean
    return Type(value) <> "<uninitialized>" and value <> invalid
end function

function IsArray(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifArray") <> invalid
end function

function JoinStrArr(strArray as object, sep = "" as string) as string
    joined = ""
    for each s in strArray:
        joined += sep + s
    next
    return joined.mid(len(sep))
end function

sub showpostergrid()
    resultAsJson = ParseJSON(m.readPosterGridTask.content)
    if resultAsJson <> invalid
        parsedContent = createObject("roSGNode", "ContentNode")
        for each mediaItem in resultAsJson.items
            gridPoster = createObject("roSGNode", "ContentNode")
            gridPoster.id = mediaItem.imdbInfo.id
            gridPoster.shortdescriptionline1 = mediaItem.imdbInfo.title
            gridPoster.Description = mediaItem.imdbInfo.plot
            if IsString(mediaItem.mediaSourceUrl)
                gridPoster.SDPosterUrl = mediaItem.imdbInfo.posterThumb
                gridPoster.HDPosterUrl = mediaItem.imdbInfo.posterThumb
                gridPoster.Url = mediaItem.imdbInfo.posterHD
                sources = CreateObject("roArray", 1, true)
                sources.push("http://mediacatalogadmin.herokuapp.com" + mediaItem.mediaSourceUrl)
                gridPoster.StreamContentIDs = sources
            else
                sources = CreateObject("roArray", mediaItem.mediaSources.Count(), true)
                for each source in mediaItem.mediaSources
                    streamUrl = "http://apighost.herokuapp.com/api/gddirectstreamurl/" + source.id
                    headerStrigify = ""
                    if (IsString(source.streamUrl) and source.streamUrl <> "")
                        streamUrl = source.streamUrl
                    end if
                    if (IsArray(source.headers))
                        headerStrigify = JoinStrArr(source.headers, ";")
                    end if
                    sources.push({
                        url : streamUrl,
                        bitrate : source.size
                        quality : false
                        contentid : source.source + "|" + source.mimeType + "|" + headerStrigify
                    })
                end for
                gridPoster.Streams = sources
                gridPoster.shortdescriptionline2 = mediaItem.mediaSources[0].id
                gridPoster.SDPosterUrl = mediaItem.imdbInfo.posterThumb
                gridPoster.HDPosterUrl = mediaItem.imdbInfo.posterThumb
                gridPoster.Url = mediaItem.imdbInfo.posterHD
            end if
            parsedContent.appendChild(gridPoster)
        end for
        m.top.observeField("createNextPanelIndex", "onCreateNextPanel")
        m.top.grid.content = parsedContent
    end if
end sub

function lastIndexOf(input as string, char as string) as integer
    newStr = ""
    _len = len(input)
    for i = _len to 1 step -1
        if Mid(input, i, 1) = char then
            return i
        end if
    end for
    return -1
end function

sub onCreateNextPanel()
    currentSelectedMediaItem = m.top.grid.content.getChild(m.top.createNextPanelIndex)
    m.posterPanel = createObject("RoSGNode", "MediaPosterScreen")
    m.posterPanel.mediaItem = currentSelectedMediaItem
    m.posterPanel.observeField("focusedChild", "onFucusPosterPanel")
    m.top.nextPanel = m.posterPanel

    'm.mediaSourcesPanel = m.global.panelSetNode.createChild("PlayableMediaListScreen")

    'm.posterPanel.posterMode = "full"
    ' m.mediaSourcesPanel = createObject("RoSGNode", "PlayableMediaListScreen")
    ' m.global.panelSetNode.appendChild(m.mediaSourcesPanel)

    'currentSelectedMediaItem = m.top.grid.content.getChild(m.top.grid.itemFocused)
    'mediaSourcesPanel.mediaItem = currentSelectedMediaItem
    'm.mediaSourcesPanel.list.setFocus(true)
end sub

sub onFucusPosterPanel()
    ' topmif = m.top
    ' m.mediaSourcesPanel = createObject("RoSGNode", "PlayableMediaListScreen")
    'mediaSourcesPanel.video = m.video
    'm.mediaSourcesPanel = mediaSourcesPanel
    'm.panelSet.appendChild(mediaSourcesPanel)

    ' currentSelectedMediaItem = m.gridPanel.grid.content.getChild(m.gridPanel.grid.itemFocused)
    ' mediaSourcesPanel.mediaItem = currentSelectedMediaItem
    ' m.mediaSourcesPanel.setFocus(true)

    ' currentSelectedMediaItem = m.top.grid.content.getChild(m.top.createNextPanelIndex)
    ' m.posterPanel = createObject("RoSGNode", "MediaPosterScreen")
    ' m.posterPanel.mediaItem = currentSelectedMediaItem
    ' m.posterPanel.observeField("focusedChild", "onFucusPosterPanel")

    ' currentSelectedMediaItem = m.top.grid.content.getChild(m.top.grid.itemFocused)
    ' m.mediaSourcesPanel.mediaItem = currentSelectedMediaItem
    ' m.mediaSourcesPanel.setFocus(true)
    ' m.posterPanel.nextPanel = m.mediaSourcesPanel

    print "onfocus called"
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