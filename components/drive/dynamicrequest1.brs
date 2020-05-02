
sub init()
    print "in SimpleTask init"
    m.top.functionName = "executeTask"
end sub

sub executeTask()
    req = HttpRequest(m.top.params)
    dataResponse = req.send()
    print "Response received for request"
    _responseHeaders = dataResponse.getResponseHeaders()
    _responseBody = dataResponse.getString()

    'cookieValue = _responseHeaders["Set-Cookie"] 'not working
    cookieValue = req.getcookies("", "/")

    rxforstreamformat = CreateObject("roRegex", "&fmt_list=(.*?)&", "i")
    rx1 = CreateObject("roRegex", ",", "") ' split on comma
    rx2 = CreateObject("roRegex", "\|", "") ' split on pipe | sign
    rx3 = CreateObject("roRegex", "/", "") ' split on \ sign

    arrofstreamformatsmatch = rxforstreamformat.MatchAll(_responseBody)
    arraofstreamformats = {}
    if arrofstreamformatsmatch.count() > 0
        o = CreateObject("roUrlTransfer")
        encodedonestreamformat = arrofstreamformatsmatch[0][1]
        decodedonestreamformat = o.Unescape(encodedonestreamformat)
        commasplittedValues = rx1.Split(decodedonestreamformat)
        for each commasplittedValue in commasplittedValues
            urlarray123 = rx3.Split(commasplittedValue)
            anotherdecodedonekey = urlarray123[0]
            anotherdecodedonevalu = urlarray123[1]
            arraofstreamformats[anotherdecodedonekey] = anotherdecodedonevalu
        end for
    end if

    rx = CreateObject("roRegex", "&fmt_stream_map=(.*?)&", "i")
    arr = rx.MatchAll(_responseBody)

    playableUrls = []

    if arr.Count() > 0
        encodedone = arr[0][1]
        decodedone = o.Unescape(encodedone)

        splittedValues = rx1.Split(decodedone)
        for each splittedValueItem in splittedValues
            urlarray = rx2.Split(splittedValueItem)
            anotherdecodedone = urlarray[1]
            resolutionval = urlarray[0]
            resolution = arraofstreamformats[resolutionval]
            playableUrls.push({
                "resolution": resolution 
                "source": anotherdecodedone
            })
            print(anotherdecodedone)
        end for
    end if

    content = {
        playableUrls: playableUrls,
        cookie: cookieValue
    }
    m.top.content = content
end sub


