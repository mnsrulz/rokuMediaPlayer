' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' setting top interfaces
' setting observers
sub Init()
    m.background = m.top.findNode("background")
    m.oldBackground = m.top.findNode("oldBackground")
    m.oldbackgroundInterpolator = m.top.findNode("oldbackgroundInterpolator")
    m.shade = m.top.findNode("shade")
    m.fadeoutAnimation = m.top.findNode("fadeoutAnimation")
    m.fadeinAnimation = m.top.findNode("fadeinAnimation")
    m.backgroundColor = m.top.findNode("backgroundColor")

    m.background.observeField("bitmapWidth", "OnBackgroundLoaded")
    m.top.observeField("width", "OnSizeChange")
    m.top.observeField("height", "OnSizeChange")
end sub

' If background changes, start animation and populate fields
sub OnBackgroundUriChange()
    oldUrl = m.background.uri

    if m.top.uri <> ""
        m.shade.color = "0x000000"
        m.background.uri = m.top.uri
    else
        m.shade.color = "0x2e2e2e"
        m.background.uri = "pkg:/images/new-bg-fhd.jpg"
    end if

    if oldUrl <> "" then
        m.oldBackground.uri = oldUrl
        m.oldbackgroundInterpolator = [m.background.opacity, 0]
        m.fadeoutAnimation.control = "start"
    end if
end sub

' If Size changed, change parameters to childrens
sub OnSizeChange()
    size = m.top.size

    m.background.width = m.top.width
    m.oldBackground.width = m.top.width
    m.shade.width = m.top.width
    m.backgroundColor.width = m.top.width

    m.oldBackground.height = m.top.height
    m.background.height = m.top.height
    m.shade.height = m.top.height
    m.backgroundColor.height = m.top.height
end sub


' When Background image loaded, start animation
sub OnBackgroundLoaded()
    m.fadeinAnimation.control = "start"
end sub