
sub init()
    print "in SimpleTask init"
    m.top.functionName = "executeTask"
end sub

sub executeTask()
    m.top.params = buildHeader(m.top.params)
    req = HttpRequest(m.top.params)
    dataResponse = req.send()
    print "Response received for request"
    if dataResponse.GetResponseCode() = 401
        'retry with refresh token if needed
        retrywithrefreshaccesstoken()
        m.top.params = buildHeader(m.top.params)
        req2 = HttpRequest(m.top.params)
        dataResponse2 = req2.send()
        myresponsecode = dataResponse2.GetResponseCode()
        m.top.responseHeaders = dataResponse2.getResponseHeaders()
        m.top.content = dataResponse2.getString()
    else
        m.top.responseHeaders = dataResponse.getResponseHeaders()
        m.top.content = dataResponse.getString()
    end if
end sub

sub retrywithrefreshaccesstoken()
    clientId = m.global.appconfig.clientId
    clientSecret = m.global.appconfig.clientSecret
    refreshToken = m.global.refreshToken
    params1 = {
        url: "https://oauth2.googleapis.com/token",
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        data: "client_id=" + clientId + "&client_secret=" + clientSecret + "&refresh_token=" + refreshToken + "&grant_type=refresh_token"
    }
    req1 = HttpRequest(params1)
    dataResponse1 = req1.send()
    if dataResponse1.GetResponseCode() = 200
        refreshtokenresponse = dataResponse1.getString()
        resultAsJson = ParseJSON(refreshtokenresponse)
        m.global.accessToken = resultAsJson.access_token
    end if
end sub

function buildHeader(p as dynamic) as dynamic
    'check if there's any existing header
    p.headers = {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer " + m.global.accessToken
    }
    return p
end function