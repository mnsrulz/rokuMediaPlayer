
sub init()
    m.top.panelSize = "narrow"
    m.top.focusable = true
    m.top.hasNextPanel = false
    'm.top.leftOnly = true
    m.top.createNextPanelOnItemFocus = false
    m.top.selectButtonMovesPanelForward = false

    m.top.optionsAvailable = false
    'm.top.overhangTitle = "Scene Graph Examples"
    m.video = m.top.findNode("vd")
    m.video.visible = false
    m.top.list = m.top.findNode("l3")
    m.okpressed=false
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press then
        if (key = "back") then
            if (m.okpressed) then
                unhidethings()
            end if
            handled = false
        else
            if (key = "OK") then
                m.okpressed = true
                ShowSpringboardScreen()
            end if
            handled = true
        end if
    end if
    return handled
end function

sub ShowSpringboardScreen()
    ' port = CreateObject("roMessagePort")
    ' springBoard = CreateObject("roSpringboardScreen")
    ' springBoard.SetMessagePort(port)
    ' ' Set up screen...

    ' springBoard.Show()
    ' while True
    '     message = wait(0, port)
    '     if message.isScreenClosed() then
    '         exit while
    '     else if message.isButtonPressed() then
    '         ' Process menu items...
    '     end if
    ' end while
    ' Returning destroys the 'springBoard' variable, which closes the
    ' springboard screen, and reveals the poster screen again.

    'm.top.topcontainer.overhang.visible = false
    ' m.top.topcontainer.panelset.visible = false

    'm.currentexample = createObject("roSGNode", "S4")

    ' m.top.topcontainer.appendChild(m.currentexample)

    ' m.currentexample.setFocus(true)

    playvideo()
end sub

sub unhidethings()
    m.top.gridPanel.visible=true
    m.top.list.visible=true
    m.video.visible=false
    m.top.inheritParentTransform = true
    m.top.panelSize = "narrow"
    m.top.topcontainer.overhang.visible=true
    m.video.control = "stop"
end sub

sub playvideo()
    m.top.gridPanel.visible=false
    m.top.list.visible=false
    m.video.visible=true
    m.top.inheritParentTransform = false
    m.top.translation=[0,0]
    m.video.width = 1920
    m.video.height = 1080
    'm.top.topcontainer.panelset.opacity = 0.0
    m.top.topcontainer.overhang.visible=false
    'm.top.topcontainer.panelset.translation = [0,0]
    videoContent = createObject("RoSGNode", "ContentNode")
    videoContent.url = m.top.videoUrl
    ''videoContent.title = "Test Video"
    videoContent.streamformat = "mkv"   ''should be passed from top
    videoContent.enableUI = true

    m.video.content = videoContent
    m.video.control = "play"
end sub