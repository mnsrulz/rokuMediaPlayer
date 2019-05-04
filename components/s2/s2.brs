
sub init()
    m.top.panelSize = "wide"
    m.top.focusable = true
    m.top.hasNextPanel = true
    'm.top.leftOnly = true
    m.top.createNextPanelOnItemFocus = false
    m.top.selectButtonMovesPanelForward = true

    m.top.optionsAvailable = false
    
    m.top.grid = m.top.findNode("posterGridCategoryMedia")

end sub

sub readpostergrid()
    
    print "read poster grid"
    m.readPosterGridTask = CreateObject("roSGNode", "SimpleTask")
    m.readPosterGridTask.uri = "http://mediacatalogadmin.herokuapp.com/api/playlist/" + "4k"
    m.readPosterGridTask.observeField("content", "showpostergrid")
    m.readPosterGridTask.control = "RUN"
end sub

sub showpostergrid()
    resultAsJson = ParseJSON(m.readPosterGridTask.content)
    parsedContent = createObject("roSGNode", "ContentNode")
    counter = 1
    for each mediaItem in resultAsJson.items
        counter+= 1
        if counter<100 then
            gridPoster = createObject("roSGNode", "ContentNode")
            '@._V1_UX364_CR0,0,364,536_AL__QL50.jpg'
            gridPoster.imdbId = mediaItem.imdbInfo.id
            gridPoster.shortdescriptionline1 = mediaItem.imdbInfo.title
            gridPoster.shortdescriptionline2 = mediaItem.mediaSources[0].id
            gridPoster.hdgridposterurl = Left(mediaItem.imdbInfo.poster, Instr(1, mediaItem.imdbInfo.poster, "@")) + "._V1_UX182_CR0,0,182,268_AL_.jpg"
            parsedContent.appendChild(gridPoster)
        end if
    end for
    m.top.grid.content = parsedContent
end sub

sub setOverhangText()
    m.top.overhangTitle = m.top.overhangtext
end sub