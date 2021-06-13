
sub init()
    m.top.panelSize = "narrow"
    m.top.focusable = true
    m.top.hasNextPanel = true
    m.top.optionsAvailable = false
    m.top.goBackCount = 2
    m.mediaTitle = m.top.findNode("mediaTitle")
    m.mediaDesc = m.top.findNode("mediaDesc")
    m.poster = m.top.findNode("mediaposter")
    m.mathUtil = MathUtil()    
end sub

sub readmediaitem()
    currentitem = m.top.mediaItem
    if isNonEmptyString(currentitem.Url) then m.poster.uri = currentitem.Url
    m.mediaTitle.text = currentitem.title

    if m.mathUtil.isNumber(currentitem.year) then m.mediaTitle.text = m.mediaTitle.text + " (" + str(currentitem.year).trim() + ")"

    m.mediaDesc.text = ""
    if isNonEmptyString(currentitem.imdbId) and Left(currentitem.imdbId, 2) = "tt" then
        m.ReadMediaImdbInfoTask = CreateObject("roSGNode", "AuthenticatedClient")
        requesturi = "https://imdbinfoapi.netlify.app/.netlify/functions/imdbinfo/" + currentitem.imdbId
        m.ReadMediaImdbInfoTask.uri = requesturi
        m.ReadMediaImdbInfoTask.observeField("content", "readImdbInfo")
        m.ReadMediaImdbInfoTask.control = "RUN"
    end if
end sub

sub readImdbInfo()
    print "Imdb Info loaded..."
    resultAsJson = ParseJSON(m.ReadMediaImdbInfoTask.content)
    if resultAsJson <> invalid
        if isNonEmptyString(resultAsJson.duration) and isNonEmptyString(resultAsJson.rating)
            m.mediaDesc.text = resultAsJson.duration + " | " + "Imdb: " + resultAsJson.rating
        else if isNonEmptyString(resultAsJson.duration)
            m.mediaDesc.text = resultAsJson.duration
        else if isNonEmptyString(resultAsJson.rating)
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

function isNonEmptyString(value)
    strUtil = StringUtil()
    return strUtil.isString(value) and value <> ""
end function