sub init()
    m.top.panelSize = "narrow"
    m.top.focusable = true
    m.top.hasNextPanel = true
    m.top.leftOnly = true
    ''m.top.leftPosition = 130
    m.top.createNextPanelOnItemFocus = false
    m.top.selectButtonMovesPanelForward = true
    m.top.optionsAvailable = false
    m.top.list = m.top.findNode("categoriesLabelList")
end sub