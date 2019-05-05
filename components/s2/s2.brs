
sub init()
    m.top.panelSize = "wide"
    m.top.focusable = true
    m.top.hasNextPanel = true
    ' m.top.leftPosition = 130
    m.top.createNextPanelOnItemFocus = false
    m.top.selectButtonMovesPanelForward = true
    m.top.optionsAvailable = false
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

sub showpostergrid()
    resultAsJson = ParseJSON(m.readPosterGridTask.content)
    parsedContent = createObject("roSGNode", "ContentNode")
    for each mediaItem in resultAsJson.items
        gridPoster = createObject("roSGNode", "ContentNode")
        gridPoster.imdbId = mediaItem.imdbInfo.id
        gridPoster.shortdescriptionline1 = mediaItem.imdbInfo.title
        gridPoster.Description = mediaItem.imdbInfo.plot
        sources = CreateObject("roArray", mediaItem.mediaSources.Count(), true)
        for each source in mediaItem.mediaSources
            sources.push({
                url : "http://apighost.herokuapp.com/api/gddirectstreamurl/" + source.id,
                bitrate : source.size
                quality : false
                contentid : source.source + "|" + source.mimeType
            })
        end for
        gridPoster.Streams = sources
        basePoster = Left(mediaItem.imdbInfo.poster, lastIndexOf(mediaItem.imdbInfo.poster, "@"))
        gridPoster.shortdescriptionline2 = mediaItem.mediaSources[0].id
        gridPoster.SDPosterUrl = basePoster + "._V1_UX182_CR0,0,182,268_AL_.jpg"
        gridPoster.HDPosterUrl = basePoster + "._V1_UX182_CR0,0,182,268_AL_.jpg"
        gridPoster.Url = basePoster + "._V1_UX388_CR0,0,388,512_AL_.jpg"
        parsedContent.appendChild(gridPoster)
    end for
    m.top.grid.content = parsedContent
end sub

function lastIndexOf(input as string, char as string) as integer
    newStr = ""
    len = len(input)
    for i = len to 1 step -1
        if Mid(input, i, 1) = char then
            return i
        end if
    end for
    return -1
end function