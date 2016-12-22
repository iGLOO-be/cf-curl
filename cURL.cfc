component {

  public cUrl function init(required string target) {
    variables.commandPath = 'curl';
    variables.target = arguments.target;
    variables.method = 'GET';
    variables.headers = {};
    variables.redirect = true;
    variables.multipart = false;
    variables.fields = {};
    variables.encoding = 'utf-8';
    variables.userName = '';
    variables.password = '';
    variables.isJson = false;

    variables.UrlEncoder = createObject('java', 'java.net.URLEncoder');
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

  public function field(required string name, required value) {
    variables.fields[name] = value;
    return this;
  }

  public function fields(required struct f) {
    for (var name in f) {
      if (!structKeyExists(f, name) || isNull(f[name])) {
        continue;
      }
      this.field(name, f[name]);
    }
    return this;
  }

  public function multipart(required boolean on) {
    variables.multipart = on;
    return this;
  }

  public function basicAuth(required string user, string password = '') {
    variables.userName = user;
    variables.password = password;
    return this;
  }

  public function redirect(required boolean on) {
    variables.redirect = on;
    return this;
  }

  public function json(boolean on = true) {
    variables.isJson = on;
    if (on) {
      this.header('Content-Type', 'application/json');
    }
    return this;
  }

  // ----

  public string function command() {
    return _fullCommand(variables.commandPath, _commandArgs());
  }

  public function exec(boolean all = false) {
    var args = _commandArgs();
    var p = _exec(variables.commandPath, args);

    if (p.exitValue() != 0) {
      return _handleProcessError(p, variables.commandPath, args);
    } else {
      var parsed = _parse();
      return all ? parsed : parsed[arrayLen(parsed)];
    }
  }


  // ----

  private array function _commandArgs() {
    var c = ['-i', '--trace', '-']; // Headers and Content
    var targetUrl = variables.target;

    // Follow redirect
    if(variables.redirect) {
      c.add('-L');
    }

    // Headers
    var h = '';
    for(h in variables.headers) {
      c.add('-H');
      c.add('#h#: #variables.headers[h]#');
    }

    // Basic access authentication
    if(len(variables.userName) && len(variables.password)) {
      c.add('-H');
      c.add('Authorization: Basic #_getBasicAuthHash()#');
    }

    // Method
    c.add('-X');
    c.add(variables.method);

    // Form
    var k = '';
    if(variables.method == 'post' || variables.method == 'put') {
      if(variables.multipart) {
        // multipart/form-data

        for(k in variables.fields) {
          c.add('--form');
          c.add('#k#=#variables.fields[k]#');
        }
      } else if (structCount(variables.fields)) {
        c.add('--data');

        if (variables.isJson) {
          // application/json
          c.add(serializeJSON(variables.fields));
        } else {
          // application/x-www-form-urlencoded
          c.add(_encodeFields(variables.fields));
        }
      }
    } else if(structCount(variables.fields)) {
      targetUrl &= '?' & _encodeFields(variables.fields);
    }

    // Target
    c.add(targetUrl);

    return c;
  }

  private function _handleProcessError(required any process, required string command, required array args) {
    var error = variables.threadError;
    var fullCommand = _fullCommand(command, args);

    var message = [
      'cURL has fail.',
      'Command: `#fullCommand#`',
      'Exit code: `#process.exitValue()#`',
      'Message: `#error#`'
    ];

    throw(message = arrayToList(message, ' - '), detail = message[4]);
  }

  private function _exec(required string name, required array args) {
    var runtime = Runtime.getRuntime();

    var cmd = [name];
    cmd.addAll(args);

    var p = runtime.exec(cmd);
    variables.threadInput = [];
    variables.threadError = [];

    var uuid = createUUID();
    var threads = {
      'input' = uuid & '_input',
      'error' = uuid & '_error'
    };

    var variables.processIsExited = false;

    thread name="#threads.input#" p="#p#" {
      var isr = createObject('java', 'java.io.InputStreamReader').init(p.getInputStream());
      var br = createObject('java', 'java.io.BufferedReader').init(isr);
      while(true) {
        var line = br.readLine();
        if(!isNull(line)) {
          threadInput.add(line);
          writeOutput(line);
        }
        else if( isExited ) {
          break;
        }
      }
    }

    thread name="#threads.error#" p="#p#" {
      var isr = createObject('java', 'java.io.InputStreamReader').init(p.getErrorStream());
      var br = createObject('java', 'java.io.BufferedReader').init(isr);
      while(true) {
        var line = br.readLine();
        if(!isNull(line)) {
          threadError.add(line);
        } else if( isExited ) {
          break;
        }
      }
    }

    p.waitFor();
    variables.isExited = true;

    threadJoin('#threads.input#');
    threadJoin('#threads.error#');

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

  private array function _parse() {
    return new Parser().parse(variables.threadInput);
  }

  private string function _getBasicAuthHash() {
    return toBase64(variables.userName & ':' & variables.password);
  }

  private string function _encodeFields(required struct flds) {
    var f = [];
    for(k in flds) {
      f.add(
        '#UrlEncoder.encode(k, variables.encoding)#' &
        '=' &
        '#UrlEncoder.encode(JavaCast('string', flds[k]), variables.encoding)#'
      );
    }
    return arrayToList(f, '&');
  }

}
