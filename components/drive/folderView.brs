sub init()
    m.top.panelSize = "medium"
    m.top.focusable = true
    m.top.hasNextPanel = true
    m.top.createNextPanelOnItemFocus = true
    m.top.selectButtonMovesPanelForward = true
    m.top.optionsAvailable = false
    m.top.showSectionLabels = true

    ' m.top.grid = m.top.findNode("posterGridCategoryMedia")
    m.top.list = m.top.findNode("innerList")
    m.apikey = m.global.appconfig.apikey
end sub

sub displayFolderContent()
    print "read poster grid"
    if m.top.folderId <> "LOADHOMESCREEN" then
        m.readPosterGridTask = CreateObject("roSGNode", "DynamicRequestTask")
        query = ""
        if m.top.folderId = "starred" or m.top.folderId = "sharedWithMe" then
            query = m.top.folderId
        else
            query = "'" + m.top.folderId + "'%20in%20parents"
        end if
        '&key=" + m.apikey + "
        requesturi = "https://www.googleapis.com/drive/v3/files?fields=*&q=" + query + "&orderBy=name_natural&pageSize=1000&includeItemsFromAllDrives=true&supportsAllDrives=true"
        params = {
            url: requesturi,
            method: "GET",
        }
        m.readPosterGridTask.params = params

        m.readPosterGridTask.observeField("content", "showpostergrid")
        m.readPosterGridTask.control = "RUN"
    else
        ' If it's a home screen call then load shared drives first
        m.readPosterGridTask = CreateObject("roSGNode", "DynamicRequestTask")
        requesturi = "https://www.googleapis.com/drive/v3/drives"'?key=" + m.apikey
        params = {
            url: requesturi,
            method: "GET",
        }
        m.readPosterGridTask.params = params
        m.readPosterGridTask.observeField("content", "listSharedDrives")
        m.readPosterGridTask.control = "RUN"
    end if
end sub

sub listSharedDrives()
    parsedContent = createObject("roSGNode", "ContentNode")
    parsedContent.appendChild(createItem("ROOT", "root"))
    parsedContent.appendChild(createItem("STARRED", "starred"))
    parsedContent.appendChild(createItem("SHARED WITH ME", "sharedWithMe"))
    resultAsJson = ParseJSON(m.readPosterGridTask.content)
    if resultAsJson <> invalid
        for each mediaItem in resultAsJson.drives
            gridPoster = createObject("roSGNode", "ContentNode")
            gridPoster.id = mediaItem.id
            gridPoster.title = mediaItem.name
            gridPoster.Description = "application/vnd.google-apps.folder"
            parsedContent.appendChild(gridPoster)
        end for
    end if
    m.top.observeField("createNextPanelIndex", "showCurrentSelectedFolderInfo")
    m.top.list.content = parsedContent
end sub

function createItem(title, id)
    gridPoster = createObject("roSGNode", "ContentNode")
    gridPoster.id = id
    gridPoster.title = title
    gridPoster.Description = "application/vnd.google-apps.folder"
    return gridPoster
end function

sub showpostergrid()
    resultAsJson = ParseJSON(m.readPosterGridTask.content)
    if resultAsJson <> invalid
        parsedContent = createObject("roSGNode", "ContentNode")
        for each mediaItem in resultAsJson.files
            gridPoster = createObject("roSGNode", "ContentNode")
            gridPoster.id = mediaItem.id
            gridPoster.title = mediaItem.name
            gridPoster.HDLISTITEMICONURL = mediaItem.iconLink
            gridPoster.shortdescriptionline1 = mediaItem.name
            gridPoster.Description = mediaItem.mimeType
            gridPoster.SDPosterUrl = mediaItem.thumbnailLink
            gridPoster.HDPosterUrl = mediaItem.thumbnailLink
            parsedContent.appendChild(gridPoster)
        end for
        m.top.observeField("createNextPanelIndex", "showCurrentSelectedFolderInfo")
        m.top.list.content = parsedContent
    end if
end sub

sub showCurrentSelectedFolderInfo()
    ' currentSelectedMediaItem = m.gridPanel.grid.content.getChild(m.gridPanel.grid.itemFocused)
    currentSelectedMediaItem = m.top.list.content.getChild(m.top.createNextPanelIndex)
    if currentSelectedMediaItem.Description = "application/vnd.google-apps.folder"
        folderviewpanel = createObject("RoSGNode", "folderView")
        ' folderviewpanel.accessToken = m.top.accessToken
        ' folderviewpanel.refreshToken = m.top.refreshToken
        folderviewpanel.folderId = currentSelectedMediaItem.id
        m.top.nextPanel = folderviewpanel
    else
        fileViewPanel = createObject("RoSGNode", "fileView")
        ' fileViewPanel.accessToken = m.top.accessToken
        ' fileViewPanel.refreshToken = m.top.refreshToken
        fileViewPanel.fileId = currentSelectedMediaItem.id
        m.top.nextPanel = fileViewPanel
    end if
end sub