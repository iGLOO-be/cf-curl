component {

  /*
    Sources:
      https://github.com/apiaryio/curl-trace-parser/blob/4a94b80c7acb19242728e7b876a800d4f90d7617/src/parser.coffee
      https://github.com/apiaryio/http-string-parser/blob/ebb15b92d040aae1f79abd4bbe371ef68b040d68/src/parser.coffee
   */

  public function init() {
    variables.Pattern = createObject('java', 'java.util.regex.Pattern');
    variables.HttpParser = createObject('java', 'org.apache.commons.httpclient.HttpParser');
    variables.IOUtils = createObject('java', 'org.apache.commons.io.IOUtils');
    variables.encoding = 'utf-8';
  }

  public function parse(array traceLines) {
    // find ASCI bytes in raw lines
    // will contain array of arrays with direction and data
    // e.g [['<=', "47 45 54 20 2f 73 68 6f 70 70 69 6e 67 2d 63 61"]]
    var lastDir = '';
    var lastDirName = '';
    var lastSection = '';
    var calls = [];
    var i_req = 0;

    var dataPattern = '^(?:[a-z0-9]{4}:) ((?:[a-z0-9]{2} ){1,16})';
    var dirPattern = '^(=>|<=) (Recv|Send) ([a-z-A-Z-0-9]+)';

    var line = '';
    for(line in traceLines) {
      var dirMatch = _match(dirPattern, line);
      if(arrayLen(dirMatch)) {
        lastDir = trim(dirMatch[1]);
        lastSection = lCase(trim(dirMatch[2]));
        lastDirName = trim(dirMatch[3]);
        if( trim(dirMatch[2]) == 'Send' && lastDirName == 'header') {
          i_req++;
          calls[i_req] = [];
        }
      }

      var dataMatch = _match(dataPattern, line);
      if(arrayLen(dataMatch)) {
        data = trim(dataMatch[1]);

        var shouldIgnore = false;

        // Ignore SSL related lines
        if (lastDirName == 'ssl') shouldIgnore = true;

        // Ignore "send data", we don't care about it and it may cause out-of-memory!
        if (lastSection == 'Send' && lastDirName == 'data') shouldIgnore = true;

        if(!shouldIgnore && i_req > 0) {
          calls[i_req].add([lastDir, lastDirName, data]);
        }
      }
    }

    var converted = [];
    var asciiHexSets = [];
    for(asciiHexSets in calls) {
      converted.add(_convertASCIIsets(asciiHexSets));
    }

    var parsed = [];
    for(var i = 1; i <= arrayLen(converted); i++) {
      var r = {};
      var dirs = ['request', 'response'];
      var dir = '';
      for(dir in dirs) {
        if(structKeyExists(converted[i], dir)) {
          r[dir] = {};
          var section = '';
          for(section in converted[i][dir]) {
            var value = converted[i][dir][section];
            if(dir == 'response' && section == 'header') {
              // Remove "Continue" in case multipart
              value = reReplace(value, 'HTTP\/\d\.\d\s100[^(HTTP)]*', '');
              r[dir]['status'] = _parseStatusLine(value);
              r[dir][section] = _parseHeaders(value);
              r[dir]['cookies'] = _parseCookies(r[dir][section]);
            } else {
              r[dir][section] = value;
            }
          }
        }
      }
      parsed.add(r);
    }

    return parsed;
  }


  // ...

  private string function _dir(required string ident) {
    return ident == '=>' ? 'request' : 'response';
  }

  private array function _match(required string r, required string str, flags) {
    if(!isNull(flags)) {
      if(isSimpleValue(flags)) {
        flags = listToArray(flags);
      }
      var flagInt = 0;
      var flagName = '';
      for (flagName in flags)
        flagInt += Pattern[flagName];
      var p = Pattern.compile(r, javacast("int", flagInt));
    } else {
      var p = Pattern.compile(r);
    }
    var m = p.matcher(str);
    var i = 1;
    var res = [];

    if(m.find()) {
      var i = 1;
      while(i <= m.groupCount()) {
        res.add(m.group(i));
        i++;
      }
    }

    return res;
  }

  private struct function _parseStatusLine(required string headerLines) {
    var statusRE = '(HTTP/\d\.\d\s+(\d+)\s+[^\n]+)';
    return {
      'line' = reReplace(headerLines, statusRE & '.*', '\1'),
      'code' = reReplace(headerLines, statusRE & '.*', '\2')
    };
  }

  private array function _parseCookies(required struct headers) {
    var cookies = [];
    var aCookies = structKeyExists(arguments.headers,"set-cookie") ? arguments.headers["set-cookie"] : [];
    if (!isArray(aCookies)) {
        aCookies = [ aCookies ];
    }
    for(var c in aCookies) {
      cookies.add(_parseSingleCookie(c));
    }
    return cookies;
  }

  private struct function _parseSingleCookie( required string c) {
    var aData = listToArray(arguments.c,";");
    var stReturn = {};

    for (var i = 1; i <= arrayLen(aData); i++ ) {
      if(i EQ 1) {
        stReturn["name"] = listFirst(aData[i],"=");
        stReturn["value"] = listLast(aData[i],"=");
      } else {
        stReturn[listFirst(aData[i],"=")] = listLast(aData[i],"=");
      }
    }

    return stReturn;
  }

  private struct function _parseHeaders(required string headerLines) {
    var statusRE = '(HTTP/\d\.\d\s+(\d+)\s+[^\n]+)';
    var content = IOUtils.toInputStream(trim(reReplace(headerLines, statusRE, '')), variables.encoding);
    var headersArr = HttpParser.parseHeaders(content);
    var headers = {};
    var tmpName = "";
    var tmp = "";

    for (var i = 1; i <= arrayLen(headersArr); i++) {
      tmpName = headersArr[i].getName();
      if (structKeyExists(headers,tmpName) AND isArray(headers[tmpName])) {
        arrayAppend(headers[tmpName],headersArr[i].getValue());
      } else if (structKeyExists(headers,tmpName) AND isSimpleValue(headers[tmpName])) {
        tmp = headers[tmpName];
        headers[tmpName] = [ tmp, headersArr[i].getValue() ];
      } else {
        headers[tmpName] = headersArr[i].getValue();
      }
    }

    return headers;
  }

  private struct function _convertASCIIsets(required array asciiHexSets) {
    // split lines by spaces and make array of ASCII hex bytes
    var asciiHexBuffer = {request: {}, response: {}};
    var set = '';
    for(set in asciiHexSets) {
      var d = _dir(set[1]);
      var section = lCase(set[2]);
      var data = set[3];
      var byte = '';
      for(byte in listToArray(data, ' ')) {
        if(!structKeyExists(asciiHexBuffer[d], section)) {
          asciiHexBuffer[d][section] = [];
        }
        asciiHexBuffer[d][section].add(byte);
      }
    }

    // convert ASCII hex to ASCII integers codes
    var asciiIntBuffer = {request: {}, response: {}};
    var dir = '';
    for(dir in asciiHexBuffer) {
      var section = '';
      for(section in asciiHexBuffer[dir]) {
        if(!structKeyExists(asciiIntBuffer[dir], section)) {
          asciiIntBuffer[dir][section] = [];
        }
        var hexs = asciiHexBuffer[dir][section];
        var hex = '';
        for(hex in hexs) {
          asciiIntBuffer[dir][section].add(InputBaseN(hex, 16));
        }
      }
    }

    // convert ACII codes to charactes
    var stringBuffer = {request: {}, response: {}};
    for(dir in asciiIntBuffer) {
      var section = '';
      for(section in asciiIntBuffer[dir]) {
        if(!structKeyExists(stringBuffer[dir], section)) {
          stringBuffer[dir][section] = [];
        }
        var codes = asciiIntBuffer[dir][section];
        var code = '';
        for(code in codes) {
          stringBuffer[dir][section].add(chr(code));
        }
      }
    }

    // convert stringBuffer to output
    var output = {'request': {}, 'response': {}};
    for(dir in stringBuffer) {
      var isChunked = false;
      var sections = structKeyArray(stringBuffer[dir]);

      // headers first
      if(arrayFindNoCase(sections, 'header')) {
        var headers = arrayToList(stringBuffer[dir].header, '');
        if(arrayLen(_match('(transfer-encoding:\s*?chunked)', headers, 'CASE_INSENSITIVE'))) {
          isChunked = true;
        }
        output[dir]['header'] = headers;
        arrayDelete(sections,'header');
      }

      var section = '';
      for(section in stringBuffer[dir]) {
        var str = arrayToList(stringBuffer[dir][section], '');
        if(section == 'data') {
          if(isChunked) {
            var hexPattern = '(\r\n[0-9a-f]+\r\n)';
            str = reReplace(str, hexPattern, '', 'all');
            // Remove first value of data.
            str = reReplace(str, '^([0-9a-f]+\r\n)', '');
          }
        }
        output[dir][section] = str;
      }
    }

    return output;
  }

}
