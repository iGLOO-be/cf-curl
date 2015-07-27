component {

  public cUrl function init(required string target) {
    variables.commandPath = 'curl';
    variables.target = arguments.target;
    variables.method = 'GET';
    variables.headers = {};
    variables.multipart = false;
    variables.fields = {};
    variables.encoding = 'utf-8';

    variables.UrlEncoder = createObject('java', 'java.net.URLEncoder');
    variables.IOUtils = createObject('java', 'org.apache.commons.io.IOUtils');
    variables.HttpParser = createObject('java', 'org.apache.commons.httpclient.HttpParser');
    variables.Runtime = createObject('java', 'java.lang.Runtime');

    return this;
  }


  // Setters

  public function method(required string method) {
    variables.method = uCase(arguments.method);
    return this;
  }

  public function header(required string name, required string value) {
    variables.headers[name] = value;
    return this;
  }

  public function headers(required struct h) {
    structAppend(variables.headers, h);
    return this;
  }

  public function field(required string key, required value) {
    variables.fields[key] = value;
    return this;
  }

  public function multipart(required boolean on) {
    variables.multipart = on;
    return this;
  }


  // ----

  public string function command() {
    return _fullCommand(variables.commandPath, _commandArgs());
  }

  public function exec() {
    var args = _commandArgs();
    var p = _exec(variables.commandPath, args);

    p.waitFor();

    if (p.exitValue() != 0) {
      return _handleProcessError(p, variables.commandPath, args);
    } else {
      var res = _parseResponse(p.getInputStream());
      return res;
    }
  }


  // ----

  private array function _commandArgs() {
    var c = ['-i']; // Headers and Content

    // Headers
    var h = '';
    for(h in variables.headers) {
      c.add('-H');
      c.add('#h#: #variables.headers[h]#');
    }

    // Method
    c.add('-X');
    c.add(variables.method);

    // Form
    var k = '';
    if(variables.multipart) {
      // multipart/form-data

      for(k in variables.fields) {
        c.add('--form');
        c.add('#k#=#variables.fields[k]#');
      }
    } else if (structCount(variables.fields)) {
      // application/x-www-form-urlencoded

      var f = [];
      for(k in variables.fields) {
        f.add(
          '#UrlEncoder.encode(k, variables.encoding)#' &
          '=' &
          '#UrlEncoder.encode(variables.fields[k], variables.encoding)#'
        );
      }
      c.add('--data');
      c.add('#arrayToList(f, '&')#');
    }

    // Target
    c.add(variables.target);

    return c;
  }

  private function _handleProcessError(required any process, required string command, required array args) {
    var error = process.getErrorStream();
    var fullCommand = _fullCommand(command, args);

    var message = [
      'cURL has fail.',
      'Command: `#fullCommand#`',
      'Exit code: `#process.exitValue()#`',
      'Message: `#IOUtils.toString(error)#`'
    ];

    throw(message = arrayToList(message, ' - '), detail = message[4]);
  }

  private function _exec(required string name, required array args) {
    var runtime = Runtime.getRuntime();

    var cmd = [name];
    cmd.addAll(args);

    var p = runtime.exec(cmd);
    return p;
  }

  private string function _fullCommand(required string name, array args = []) {
    var cmd = [name];
    for(var i = 1; i <= arrayLen(args); i++) {
      if(left(args[i],1) == '-') {
        cmd.add(args[i]);
      } else {
        cmd.add('"#args[i]#"');
      }
    }
    return arrayToList(cmd, ' ');
  }

  private struct function _parseResponse(required inStream) {
    var res = IOUtils.toString(inStream, variables.encoding);

    // Remove "Continue" in case multipart
    res = reReplace(res, 'HTTP\/\d\.\d\s100[^(HTTP)]*', '');

    var statusRE = '(HTTP/\d\.\d\s+(\d+)\s+[^\n]+)';
    var result = {
      'status' = reReplace(res, statusRE & '.*', '\1'),
      'statusCode' = reReplace(res, statusRE & '.*', '\2')
    };

    var modified = IOUtils.toInputStream(trim(reReplace(res, statusRE, '')));
    var headersArr = HttpParser.parseHeaders(modified, variables.encoding);
    var headers = {};
    for (var i = 1; i <= arrayLen(headersArr); i++) {
      headers[headersArr[i].getName()] = headersArr[i].getValue();
    }

    result['headers'] = headers;

    var body = [];
    do {
      var line = HttpParser.readLine(modified);
      if(!isNull(line)) {
        body.add(line);
      }
    } while(!isNull(line));

    result['content'] = arrayToList(body, '');

    return result;
  }

}
