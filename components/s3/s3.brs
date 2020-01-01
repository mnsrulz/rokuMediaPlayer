
sub init()
    m.top.panelSize = "narrow"
    m.top.focusable = true
    m.top.hasNextPanel = true
    'm.top.leftPosition = 130
    m.top.createNextPanelOnItemFocus = false
    m.top.optionsAvailable = false
    m.top.goBackCount=2
    m.mediaTitle = m.top.findNode("mediaTitle")
    m.poster = m.top.findNode("mediaposter")
end sub

sub readmediaitem()
    currentitem = m.top.mediaItem
    m.poster.uri = currentitem.HDPosterUrl
    m.mediaTitle.text = currentitem.shortdescriptionline1
end sub

sub readPosterMode()
    if m.top.posterMode = "full" then
        m.poster.width="388"
        m.poster.height="512"
        m.mediaTitle.visible=false
    else
        m.poster.width="288"
        m.poster.height="428"
        m.mediaTitle.visible=true
    end if
end sub