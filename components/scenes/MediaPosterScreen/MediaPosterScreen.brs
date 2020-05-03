
sub init()
    m.top.panelSize = "narrow"
    m.top.focusable = true
    m.top.hasNextPanel = true
    'm.top.leftPosition = 130
    ' m.top.createNextPanelOnItemFocus = false
    m.top.optionsAvailable = false
    m.top.goBackCount = 2
    m.mediaTitle = m.top.findNode("mediaTitle")
    m.mediaDesc = m.top.findNode("mediaDesc")
    m.poster = m.top.findNode("mediaposter")
end sub

sub readmediaitem()
    currentitem = m.top.mediaItem
    m.poster.uri = currentitem.Url
    m.mediaTitle.text = currentitem.shortdescriptionline1
    m.mediaDesc.text = ""
    if Left(currentitem.id, 2) = "tt" then
        m.ReadMediaImdbInfoTask = CreateObject("roSGNode", "SimpleTask")
        m.ReadMediaImdbInfoTask.uri = "http://mediacatalogadmin.herokuapp.com/api/imdb/" + currentitem.id
        m.ReadMediaImdbInfoTask.observeField("content", "readImdbInfo")
        print "setting to execution of loading IMDB info task"
        m.ReadMediaImdbInfoTask.control = "RUN"
    end if

end sub

sub readImdbInfo()
    print "Imdb Info loaded..."
    resultAsJson = ParseJSON(m.ReadMediaImdbInfoTask.content)
    if resultAsJson <> invalid
        if resultAsJson.runtime <> invalid and resultAsJson.rating <> invalid
            m.mediaDesc.text = resultAsJson.runtime + " | " + "Imdb: " + resultAsJson.rating
        else if resultAsJson.runtime <> invalid
            m.mediaDesc.text = resultAsJson.runtime
        else if resultAsJson.rating <> invalid
            m.mediaDesc.text = "Imdb: " + resultAsJson.rating
        end if
    else
        print "Imdb info parse result failed"
    end if
end sub

sub readPosterMode()
    if m.top.posterMode = "full" then
        m.poster.width = "388"
        m.poster.height = "512"
        m.mediaTitle.visible = false
        m.mediaDesc.visible = false
    else
        m.poster.width = "288"
        m.poster.height = "428"
        m.mediaTitle.visible = true
        m.mediaDesc.visible = true
    end if
end sub