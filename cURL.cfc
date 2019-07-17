component {

  public cUrl function init(required string target, struct options = {}) {
    variables.commandPath = 'curl';
    variables.target = arguments.target;
    variables.method = 'GET';
    variables.headers = {};
    variables.redirect = true;
    variables.multipart = false;
    variables.body = javaCast('null', 0);
    variables.fields = {};
    variables.encoding = 'utf-8';
    variables.userName = '';
    variables.password = '';
    variables.isJson = false;
    variables.headOnly = false;
    variables.timeout = javaCast('null', 0);
    variables.file = javaCast('null', 0);
    variables.output = javaCast('null', 0);

    variables.UrlEncoder = createObject('java', 'java.net.URLEncoder');
    variables.Runtime = createObject('java', 'java.lang.Runtime');

    variables.errorCodes = {
      1 = 'UNSUPPORTED_PROTOCOL',
      2 = 'FAILED_INIT',
      3 = 'URL_MALFORMAT',
      4 = 'NOT_BUILT_IN',
      5 = 'COULDNT_RESOLVE_PROXY',
      6 = 'COULDNT_RESOLVE_HOST',
      7 = 'COULDNT_CONNECT',
      8 = 'FTP_WEIRD_SERVER_REPLY',
      9 = 'REMOTE_ACCESS_DENIE',
      10 = 'FTP_ACCEPT_FAILED',
      11 = 'FTP_WEIRD_PASS_REPLY',
      12 = 'FTP_ACCEPT_TIMEOUT',
      13 = 'FTP_WEIRD_PASV_REPLY',
      14 = 'FTP_WEIRD_227_FORMAT',
      15 = 'FTP_CANT_GET_HOST',
      16 = 'HTTP2',
      17 = 'FTP_COULDNT_SET_TYPE',
      18 = 'PARTIAL_FILE',
      19 = 'FTP_COULDNT_RETR_FILE',
      21 = 'QUOTE_ERROR',
      22 = 'HTTP_RETURNED_ERROR',
      23 = 'WRITE_ERROR',
      25 = 'UPLOAD_FAILED',
      26 = 'READ_ERROR',
      27 = 'OUT_OF_MEMORY',
      28 = 'OPERATION_TIMEDOUT',
      30 = 'FTP_PORT_FAILED',
      31 = 'FTP_COULDNT_USE_REST',
      33 = 'RANGE_ERROR',
      34 = 'HTTP_POST_ERROR',
      35 = 'SSL_CONNECT_ERROR',
      36 = 'BAD_DOWNLOAD_RESUME',
      37 = 'FILE_COULDNT_READ_FILE',
      38 = 'LDAP_CANNOT_BIND',
      39 = 'LDAP_SEARCH_FAILED',
      41 = 'FUNCTION_NOT_FOUND',
      42 = 'ABORTED_BY_CALLBACK',
      43 = 'BAD_FUNCTION_ARGUMENT',
      45 = 'INTERFACE_FAILED',
      47 = 'TOO_MANY_REDIRECTS',
      48 = 'UNKNOWN_OPTION',
      49 = 'TELNET_OPTION_SYNTAX',
      51 = 'PEER_FAILED_VERIFICATION',
      52 = 'GOT_NOTHING',
      53 = 'SSL_ENGINE_NOTFOUND',
      54 = 'SSL_ENGINE_SETFAILED',
      55 = 'SEND_ERROR',
      56 = 'RECV_ERROR',
      58 = 'SSL_CERTPROBLEM',
      59 = 'SSL_CIPHER',
      60 = 'SSL_CACERT',
      61 = 'BAD_CONTENT_ENCODING',
      62 = 'LDAP_INVALID_URL',
      63 = 'FILESIZE_EXCEEDED',
      64 = 'USE_SSL_FAILED',
      65 = 'SEND_FAIL_REWIND',
      66 = 'SSL_ENGINE_INITFAILED',
      67 = 'LOGIN_DENIED',
      68 = 'TFTP_NOTFOUND',
      69 = 'TFTP_PERM',
      70 = 'REMOTE_DISK_FULL',
      71 = 'TFTP_ILLEGAL',
      72 = 'TFTP_UNKNOWNID',
      73 = 'REMOTE_FILE_EXISTS',
      74 = 'TFTP_NOSUCHUSER',
      75 = 'CONV_FAILED',
      76 = 'CONV_REQD',
      77 = 'SSL_CACERT_BADFILE',
      78 = 'REMOTE_FILE_NOT_FOUND',
      79 = 'SSH',
      80 = 'SSL_SHUTDOWN_FAILED',
      81 = 'AGAIN',
      82 = 'SSL_CRL_BADFILE',
      83 = 'SSL_ISSUER_ERROR',
      84 = 'FTP_PRET_FAILED',
      85 = 'RTSP_CSEQ_ERROR',
      86 = 'RTSP_SESSION_ERROR',
      87 = 'FTP_BAD_FILE_LIST',
      88 = 'CHUNK_FAILED',
      89 = 'NO_CONNECTION_AVAILABLE',
      90 = 'SSL_PINNEDPUBKEYNOTMATCH',
      91 = 'SSL_INVALIDCERTSTATUS',
      92 = 'HTTP2_STREAM',
      93 = 'RECURSIVE_API_CALL'
    };

    structAppend(variables, arguments.options);

    return this;
  }


  // Setters

  public function method(required string method) {
    if (method == 'HEAD') {
      this.head();
    } else {
      variables.method = uCase(arguments.method);
    }
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

  public function body(required string body) {
    variables.body = body;
    return this;
  }

  public function file(required string file) {
    variables.file = file;
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

  public function head(boolean on = true) {
    variables.headOnly = on;
    return this;
  }

  public function timeout(numeric timeout) {
    variables.timeout = timeout;
    return this;
  }

  public function output(string output) {
    variables.output = output;
    return this;
  }

  // ----

  public string function command() {
    return _fullCommand(variables.commandPath, _commandArgs());
  }

  public function exec(boolean all = false, boolean parse = true) {
    var args = _commandArgs();
    var p = "";
    var sTmpOutput = "";

    if (arguments.parse || isNull(cfexecute)) {
    	p = _exec(variables.commandPath, args);

	    if (p.exitValue() != 0) {
	      return _handleProcessError(p, variables.commandPath, args);
	    } else if (arguments.parse) {
	      var parsed = _parse();
	      return all ? parsed : (
	        arrayLen(parsed) > 0 ? parsed[arrayLen(parsed)] : javaCast('null', 0)
	      );
	    }
    } else {
    	cfexecute(name=variables.commandPath, arguments=arrayToList(args, ' '), variable="sTmpOutput");
    	return sTmpOutput;
    }
  }

  // ----

  private array function _commandArgs() {
    var targetUrl = variables.target;
    var c = [];

    // Output
    if (isNull(variables.output)) {
      // Headers and Content
      c.addAll(['-i', '--trace', '-']);
    } else {
      c.add('-o');
      c.add(variables.output);
    }

    // Follow redirect
    if(variables.redirect) {
      c.add('-L');
    }

    // Head
    if (variables.headOnly) {
      c.add('-I');
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

    // Timeout
    if(!isNull(variables.timeout)) {
      c.add('-m');
      c.add(variables.timeout);
    }

    // Form
    var k = '';
    if(variables.method == 'post' || variables.method == 'put') {
      if(!isNull(variables.body)) {
        c.add('--data');
        c.add(variables.body);
      } else if(!isNull(variables.file)) {
        c.add('-T');
        c.add(variables.file);
      } else if(variables.multipart) {
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
    var errorCode = process.exitValue();

    var message = [
      'cURL has fail.',
      'Command: `#fullCommand#`',
      'Exit code: `#errorCode#`',
      'Message: `#(isArray(error) ? error[1] : error)#`'
    ];

    if (!isNull(errorCode) && structKeyExists(variables.errorCodes, errorCode) && !isNull(variables.errorCodes[errorCode])) {
      message[4] = variables.errorCodes[errorCode];
    }

    throw(
      message = message[4],
      detail = arrayToList(message, ' - '),
      errorcode = errorCode
    );
  }

  private function _exec(required string name, required array args) {
    var runtime = Runtime.getRuntime();

    var cmd = [name];
    var p = "";
    cmd.addAll(args);

    p = runtime.exec(cmd);

    variables.threadInput = [];
    variables.threadError = [];

    var uuid = createUUID();
    var threads = {
      'input' = uuid & '_input',
      'error' = uuid & '_error'
    };

    thread name="#threads.input#" p="#p#" {
      var isr = createObject('java', 'java.io.InputStreamReader').init(p.getInputStream());
      var br = createObject('java', 'java.io.BufferedReader').init(isr);
      var line = br.readLine();
      while(!isNull(line)) {
        threadInput.add(line);
        line = br.readLine();
      }
    }

    thread name="#threads.error#" p="#p#" {
      var isr = createObject('java', 'java.io.InputStreamReader').init(p.getErrorStream());
      var br = createObject('java', 'java.io.BufferedReader').init(isr);
      var line = br.readLine();
      while(!isNull(line)) {
        threadError.add(line);
        line = br.readLine();
      }
    }

    p.waitFor();

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
    var k = "";
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
