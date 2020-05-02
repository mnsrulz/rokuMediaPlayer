
sub init()
    m.Top.backgroundURI = " "
    m.top.backgroundColor = "#7B35AF"

    m.global.AddField("accessToken", "string", false)
    m.global.AddField("refreshToken", "string", false)
    m.global.AddField("appconfig", "roassociativearray", false)
    m.global.appconfig = {
        authDeviceUrl: "https://gdroku.herokuapp.com/device/code",
        tokenUrl: "https://gdroku.herokuapp.com/token",
        apiKey: "AIzaSyBIaGn0YuBEio6z4mZF0eOFp3e5dRi8rl4",
        clientId: "186830069664-oruki5dktj5u046o7kmv7250pgot9auk.apps.googleusercontent.com",
        clientSecret: "H2BAoACh8hGtQW7G4ruGz0Xd",
        redirectUri: "https://gdroku.herokuapp.com/auth/callback",
        scope: "email%20profile%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive.readonly"
    }


    oh = createObject("roSGNode", "OverHang")
    oh.showOptions = true
    oh.title = "Google Drive for Roku"
    oh.logoUri = ""
    oh.optionsAvailable = true

    m.top.appendChild(oh)
    m.Overhang = oh
    m.panelSet = createObject("roSGNode", "PanelSet")
    m.top.appendChild(m.panelSet)

    setpanels()
    setupVideo()
    loadAccounts()
end sub

sub setupVideo()
    m.video = createObject("roSGNode", "Video")
    m.video.visible = false
    m.global.AddField("videoNode", "node", false)
    m.global.AddField("lastFocusNode", "node", false) 'Use to set focus once video playback finishes up
    m.global.videoNode = m.video
    m.top.appendChild(m.video)
end sub

sub loadAccounts()
    ContentNode_object = createObject("RoSGNode", "ContentNode")
    m.accountsPanel.list.content = ContentNode_object
    ContentNode_child_object = ContentNode_object.createChild("ContentNode")
    ContentNode_child_object.title = "Add account"
    ContentNode_child_object.ShortDescriptionLine1 = ""
    existingTokens = readExistingToken()
    m.tokenNo = 0
    if existingTokens <> invalid
        for each tokenInfo in existingTokens
            addTokenToList(tokenInfo)
        end for
    end if
    m.accountsPanel.list.observeField("itemFocused", "onAccountFocusChange")
    m.accountsPanel.list.setFocus(true)
end sub

sub addTokenToList(tokenInfo)
    m.tokenNo = m.tokenNo + 1
    ContentNode_child_object2 = m.accountsPanel.list.content.createChild("ContentNode")
    ContentNode_child_object2.title = "token " + str(m.tokenNo)
    ContentNode_child_object2.ShortDescriptionLine1 = tokenInfo.accessToken
    ContentNode_child_object2.ShortDescriptionLine2 = tokenInfo.refreshToken
end sub

sub onAccountFocusChange()
    selectedAccount = m.accountsPanel.list.content.getChild(m.accountsPanel.list.itemFocused)
    if selectedAccount.title = "Add account"
        m.accountsPanel.nextPanel = m.signinpanel
        m.Overhang.optionsAvailable = false
    else
        m.folderviewpanel = createObject("RoSGNode", "folderView")
        m.global.accessToken = selectedAccount.ShortDescriptionLine1
        m.global.refreshToken = selectedAccount.ShortDescriptionLine2
        m.accountsPanel.nextPanel = m.folderviewpanel
        m.folderviewpanel.folderId = "LOADHOMESCREEN"
        m.Overhang.optionsAvailable = true
    end if
end sub

sub onAccessTokenReceived()
    if m.signinpanel.tokenreceived = true
        accessTokenObject = {
            "accessToken" : m.signinpanel.accessToken,
            "refreshToken" : m.signinpanel.refreshToken
        }
        tokenRegistry = readExistingToken()
        if tokenRegistry = invalid
            tokenRegistry = []
        end if
        tokenRegistry.push(accessTokenObject)
        persistTokens(tokenRegistry)
        addTokenToList(accessTokenObject)

        m.signinpanel.accessToken = ""
        m.signinpanel.refreshToken = ""

        m.accountsPanel.list.setFocus(true)
        m.accountsPanel.list.animateToItem = tokenRegistry.Count()
    end if
end sub

sub persistTokens(tokenRegistry)
    serialzedTokens = FormatJSON(tokenRegistry)
    registryWrite("GDRIVE_TOKENS", serialzedTokens)
end sub

function readExistingToken()
    tokenRegistry = registryRead("GDRIVE_TOKENS")
    if tokenRegistry = invalid
        return invalid
    else
        return ParseJSON(tokenRegistry)
    end if
end function

sub setpanels()
    m.signinpanel = createObject("RoSGNode", "oauth")
    m.signinpanel.observeField("tokenreceived", "onAccessTokenReceived")
    m.accountsPanel = m.panelSet.createChild("driveAccounts")
end sub

function registryRead(key, section = invalid)
    if section = invalid then
        section = "Default"
    end if
    sec = createObject("roRegistrySection", section)
    if sec.exists(key) then
        return sec.read(key)
    end if
    return invalid
end function

function registryWrite(key, val, section = invalid)
    if section = invalid then
        section = "Default"
    end if
    sec = createObject("roRegistrySection", section)
    if sec.write(key, val) then
        return sec.flush()
    end if
    return false
end function

function registryDelete(key, section = invalid)
    if section = invalid then
        section = "Default"
    end if
    sec = createObject("roRegistrySection", section)
    if sec.delete(key) then
        return sec.flush()
    end if
    return false
end function

function onKeyEvent(key as string, press as boolean) as boolean
    ' This event is an overhead, but we have live with it.
    if press then
        if key = "back"
            if (m.video.visible)
                m.video.control = "stop"
                m.video.visible = false
                m.global.lastFocusNode.setFocus(true)
                return true
            end if
        else if key = "options"
            if m.Overhang.optionsAvailable = true
                showdialog()
            end if
        end if
    end if
    return false
end function

sub showdialog()
    dialog = createObject("roSGNode", "Dialog")
    dialog.buttons = ["Delete token", "Exit"]
    dialog.observeField("buttonSelected", "onDialogButtonSelected")
    dialog.backgroundUri = ""
    dialog.title = "Action items"
    dialog.optionsDialog = true
    dialog.message = "Press * To Dismiss"
    m.top.dialog = dialog
end sub

sub onDialogButtonSelected()
    if m.top.dialog.buttonSelected = 0
        focusedChildIndex = m.accountsPanel.list.itemFocused
        'Need to implement revoke token functionality
        hasRemoved = m.accountsPanel.list.content.removeChildIndex(focusedChildIndex)
        if hasRemoved
            tokenRegistry = readExistingToken()
            tokenRegistry.Delete(focusedChildIndex - 1)
            persistTokens(tokenRegistry)
        end if
    end if
    m.top.dialog.close = true
end sub