sub init()
    print("initilizing video...")
    m.top.panelSize = "full"
    m.top.focusable = true
    m.top.hasNextPanel = false
    'm.top.leftOnly = true
    m.top.createNextPanelOnItemFocus = false
    m.top.selectButtonMovesPanelForward = true

    m.top.optionsAvailable = false
    'm.top.overhangTitle = "Scene Graph Examples"
    playvideo()
end sub

sub playvideo()
    videoContent = createObject("RoSGNode", "ContentNode")
    videoContent.url = "https://roku.s.cpl.delvenetworks.com/media/59021fabe3b645968e382ac726cd6c7b/60b4a471ffb74809beb2f7d5a15b3193/roku_ep_111_segment_1_final-cc_mix_033015-a7ec8a288c4bcec001c118181c668de321108861.m3u8"
    videoContent.title = "Test Video"
    videoContent.streamformat = "hls"

    m.video = m.top.findNode("exampleVideo")
    m.video.content = videoContent
    m.video.control = "play"
end sub