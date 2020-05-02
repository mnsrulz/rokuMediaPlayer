
sub init()
    print "in SimpleTask init"
    m.top.functionName = "executeTask"
end sub

sub executeTask()
    method = m.top.method
    contentType = m.top.contentType
    accessToken = m.top.accessToken
    _headers = {}
    if contentType <> ""
        _headers["Content-Type"] = contentType
    end if
    if accessToken <> ""
        _headers["Authorization"] = "Bearer " + accessToken
    end if
    
    req = HttpRequest({
        url: m.top.uri,
        method: method,
        headers: _headers,
        data: m.top.body
    })
    dataResponse = req.send()


    ' print "executing SimpleTask method"
    ' readInternet = createObject("roUrlTransfer")
    ' print "executing " + m.top.uri
    ' readInternet.setUrl(m.top.uri)
    ' readInternet.setHeaders({"Content-Type": contentType})
    ' readInternet.setRequest(method)

    ' if left(m.top.uri, 6) = "https:" then
    '     readInternet.setCertificatesFile("common:/certs/ca-bundle.crt")
    '     readInternet.addHeader("X-Roku-Reserved-Dev-Id", "")
    '     readInternet.initClientCertificates()
    ' end if


    ' result = readInternet.getToString()
    ' print "got result pritning it"
    ' resultAsJson = ParseJSON(result)
    ' m.top.content = result


    m.top.content = dataResponse.getString()
end sub
