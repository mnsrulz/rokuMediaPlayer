sub init()
    m.top.panelSize = "wide"
    m.top.tokenreceived = false
    m.mediaTitle = m.top.findNode("mediaTitle")
    m.mediaDesc = m.top.findNode("mediaDesc")
    m.linkButton = m.top.findNode("linkButton")
    m.linkButton.observeField("buttonSelected", "initOauthFlow")

    m.top.observeField("focusedChild", "onFocusChange")

    m.requestingToken = "0"
    m.top.linkButton = m.linkButton

    m.authDeviceUrl = m.global.appconfig.authDeviceUrl
    m.clientId = m.global.appconfig.clientId
    m.clientSecret = m.global.appconfig.clientSecret
    m.redirectUri = m.global.appconfig.redirectUri
    m.scope = m.global.appconfig.scope
    m.tokenUrl = m.global.appconfig.tokenUrl
    m.authCodeTimer = m.top.findNode("authCodeTimer")
    m.authCodeTimer.control = "stop"
    m.authCodeTimer.observeField("fire", "waitForTokenResponse")
end sub

sub onFocusChange()
    if m.top.focusedChild <> invalid
        m.linkButton.setFocus(true)
    end if
end sub

sub initOauthFlow()
    print "Calling initOauthFlow"
    m.requestingToken = "1"
    m.mediaTitle.text = "Initiating the sign in flow"
    m.LoadTask = CreateObject("roSGNode", "SimpleRequestTask")
    m.LoadTask.uri = m.global.appconfig.authDeviceUrl
    m.LoadTask.method = "POST"
    m.LoadTask.contentType = "application/x-www-form-urlencoded"
    m.LoadTask.body = "client_id=" + m.clientId + "&scope=" + m.scope

    m.LoadTask.observeField("content", "onOauthCodeReceived")
    m.LoadTask.control = "RUN"

end sub

sub onOauthCodeReceived()
    print "Calling onOauthCodeReceived"

    resultAsJson = ParseJSON(m.LoadTask.content)
    if resultAsJson <> invalid
        if resultAsJson.error = invalid
            m.mediaTitle.text = resultAsJson.user_code
            m.mediaDesc.text = resultAsJson.verification_url
            m.deviceCode = resultAsJson.device_code
            m.interval = resultAsJson.interval * 1000

            m.authCodeTimer.duration = resultAsJson.interval 'in seconds
            m.authCodeTimer.control = "start"

            ' Set some timer to avoid forever looping

            'waitForTokenResponse()

        else
            print "Invalid code response received"
        end if
    end if
end sub

sub waitForTokenResponse()
    print "Calling waitForTokenResponse"
    m.tokenTask = CreateObject("roSGNode", "SimpleRequestTask")
    m.tokenTask.uri = m.tokenUrl
    m.tokenTask.method = "POST"
    m.tokenTask.contentType = "application/x-www-form-urlencoded"
    ' m.tokenTask.body = "client_id=749655421455-vrtgrtk7vnkdgvoke83r37k4qkubg1ee.apps.googleusercontent.com&client_secret=JZhqOgcETRyXwUIMkQ5zNbZJ&device_code=" + m.deviceCode + "&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code"
    m.tokenTask.body = "code=" + m.deviceCode + "&client_id=" + m.clientId + "&client_secret=" + m.clientSecret + "&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code"
    'code=2ffccede45bf68b7821ebdd8093a84ba&client_id=186830069664-oruki5dktj5u046o7kmv7250pgot9auk.apps.googleusercontent.com&client_secret=H2BAoACh8hGtQW7G4ruGz0Xd&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code
    m.tokenTask.observeField("content", "onTokenResponseReceived")
    m.tokenTask.control = "RUN"
end sub

sub onTokenResponseReceived()
    print "Calling onTokenResponseReceived"
    resultAsJson = ParseJSON(m.tokenTask.content)
    if resultAsJson <> invalid
        if resultAsJson.error_code <> invalid
            ' sleep(m.interval)
            ' waitForTokenResponse()
            print "Error while oauth2: " + resultAsJson.error_code
        else
            m.authCodeTimer.control = "stop"
            m.mediaTitle.text = "Account linked successfully."
            m.top.accessToken = resultAsJson.access_token
            m.top.refreshToken = resultAsJson.refresh_token
            m.top.tokenreceived = true
            m.mediaDesc.text = "Success"
            m.requestingToken = "0"
        end if
    end if
end sub

sub fetchUserInfo()
    ' NOT IMPLEMENTED YET
    ' print "Calling waitForTokenResponse"
    ' m.fetchUserInfoTask = CreateObject("roSGNode", "SimpleRequestTask")
    ' m.fetchUserInfoTask.uri = "https://oauth2.googleapis.com/token"
    ' m.fetchUserInfoTask.method = "POST"
    ' m.fetchUserInfoTask.contentType = "application/x-www-form-urlencoded"
    ' m.fetchUserInfoTask.body = "client_id=749655421455-vrtgrtk7vnkdgvoke83r37k4qkubg1ee.apps.googleusercontent.com&client_secret=JZhqOgcETRyXwUIMkQ5zNbZJ&device_code=" + m.deviceCode + "&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code"
    ' m.fetchUserInfoTask.observeField("content", "onTokenResponseReceived")
    ' m.fetchUserInfoTask.control = "RUN"
end sub