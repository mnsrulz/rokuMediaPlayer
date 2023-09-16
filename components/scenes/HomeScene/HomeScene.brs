
sub init()
    m.top.backgroundURI = "pkg:/images/new-bg-fhd.jpg"
    m.overhang = m.top.findNode("overhang")
    m.panelSet = m.top.findNode("panelSet")
    m.video = m.top.findNode("video")

    m.global.AddField("videoNode", "node", false)
    m.global.AddField("lastFocusNode", "node", false) 'Use to set focus once video playback finishes up
    m.global.AddField("liveTvSelectedIndex", "integer", 0) 'Use to set focus once video playback finishes up
    m.global.videoNode = m.video

    m.global.AddField("panelsetNode", "node", false)
    m.global.AddField("isLiveTv", "boolean", false)

    m.global.panelsetNode = m.panelSet

    ' loadCategories()
    m.categoriespanel = m.panelSet.createChild("PlaylistScreen")
    m.top.setFocus(true)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ' This event is an overhead, but we have live with it.
    if press then
        if key = "back"
            if (m.video.visible)
                m.video.control = "stop"
                m.video.visible = false
                m.global.lastFocusNode.setFocus(true)
                m.global.isLiveTv = false
                return true
            end if
        end if

        '''event handlers during live tv playback to change channels by pressing of up/down keys
        if (m.global.isLiveTv)
            if key = "down"
                if(m.global.liveTvSelectedIndex + 1 >= m.global.lastFocusNode.content.getChildCount())  'last element cannot advance
                    return true
                end if
                m.global.liveTvSelectedIndex = m.global.liveTvSelectedIndex + 1
            else if key = "up"
                if(m.global.liveTvSelectedIndex = 0)    'first element cannot go back
                    return true
                end if
                m.global.liveTvSelectedIndex = m.global.liveTvSelectedIndex - 1
            else
                return false
            end if
            currentSelectedMediaItem = m.global.lastFocusNode.content.getChild(m.global.liveTvSelectedIndex)
            m.video.content.url = currentSelectedMediaItem.source
            m.video.control = "play"
            m.global.lastFocusNode.jumpToItem = m.global.liveTvSelectedIndex
            return true
        end if
    end if
    return false
end function


sub showcategorymedia()
    categorycontent = m.categoriespanel.list.content.getChild(m.categoriespanel.list.itemFocused)
    m.gridPanel.playlistId = categorycontent.ShortDescriptionLine1
    m.overhang.title = categorycontent.title
end sub

sub setpanels()
    m.categoriespanel = m.panelSet.createChild("PlaylistScreen")
    m.gridPanel = m.panelSet.createChild("PosterGridScreen")
    m.gridPanel.grid.observeField("itemFocused", "showCurrentSelectedMediaInfo")
end sub

sub showCurrentSelectedMediaInfo()
    currentSelectedMediaItem = m.gridPanel.grid.content.getChild(m.gridPanel.grid.itemFocused)

    m.posterPanel = createObject("RoSGNode", "MediaPosterScreen")
    m.posterPanel.mediaItem = currentSelectedMediaItem
    m.gridPanel.nextPanel = m.posterPanel
    m.posterPanel.observeField("focusedChild", "onFucusPosterPanel")
    print "selection changed"
end sub

sub onFucusPosterPanel()
    if not m.panelSet.isGoingBack
        m.posterPanel.posterMode = "full"
        mediaSourcesPanel = createObject("RoSGNode", "PlayableMediaListScreen")
        mediaSourcesPanel.video = m.video
        m.mediaSourcesPanel = mediaSourcesPanel
        m.panelSet.appendChild(mediaSourcesPanel)
        currentSelectedMediaItem = m.gridPanel.grid.content.getChild(m.gridPanel.grid.itemFocused)
        mediaSourcesPanel.mediaItem = currentSelectedMediaItem
        m.mediaSourcesPanel.setFocus(true)
    else
        m.posterPanel.posterMode = ""
    end if
end sub