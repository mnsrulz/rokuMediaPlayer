
sub init()
    m.top.functionName = "executeTask"
end sub

sub executeTask()
    method = m.top.method
    contentType = m.top.contentType
    _headers = {}
    if contentType <> ""
        _headers["Content-Type"] = contentType
    end if
    if method = "" then method = "GET"
    
    _headers["Authorization"] = "PUT YOUR AUTH TOKEN HERE"

    req = HttpRequest({
        url: m.top.uri,
        method: method,
        headers: _headers
    })
    dataResponse = req.send()
    m.top.content = dataResponse.getString()
end sub