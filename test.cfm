<cfscript>

function dumpError(string content) {
  writeOutput('<div style="border: 2px solid red; margin: 15px 0; padding:10px;">
    #content#
  </div>'
  );
}


writeOutput("<br/><h1>GET</h1>");
target = 'http://httpbin.org/get';
cURL = new cURL(target);
res = cURL.exec();
expected = deserializeJSON('{"args": {}, "headers": { "Accept": "*/*", "Host": "httpbin.org", "User-Agent": "curl/7.22.0 (x86_64-pc-linux-gnu) libcurl/7.22.0 OpenSSL/1.0.1 zlib/1.2.3.4 libidn/1.23 librtmp/2.3" }, "origin": "5.149.142.22", "url": "http://httpbin.org/get" }');
writeDump(res);
if(deserializeJSON(res.response.data).headers.Host != expected.headers.host) {
  dumpError('Error: not equal to <br/> #serializeJson(expected)#');
}



writeOutput("<br/><h1>GET with qs</h1>");
target = 'http://httpbin.org/get';
cURL = new cURL(target).field('abc', 'def');
res = cURL.exec();
expected = deserializeJSON('{"args": { "abc": "def" }, "headers": { "Accept": "*/*", "Host": "httpbin.org", "User-Agent": "curl/7.22.0 (x86_64-pc-linux-gnu) libcurl/7.22.0 OpenSSL/1.0.1 zlib/1.2.3.4 libidn/1.23 librtmp/2.3" }, "origin": "5.149.142.22", "url": "http://httpbin.org/get" }');
writeDump(res);
if(deserializeJSON(res.response.data).args.abc != expected.args.abc) {
  dumpError('Error: not equal to <br/> #serializeJson(expected)#');
}



writeOutput("<br/><h1>POST</h1>");
target = 'http://httpbin.org/post';
cURL = new cURL(target)
  .method('post')
  .field('abc', 'def')
  .field('azerty', 123)
;
res = cURL.exec();
expected = deserializeJSON('{"args": {}, "data": "", "files": {}, "form": { "abc": "def", "azerty": "123" }, "headers": { "Accept": "*/*", "Content-Length": "18", "Content-Type": "application/x-www-form-urlencoded", "Host": "httpbin.org", "User-Agent": "curl/7.22.0 (x86_64-pc-linux-gnu) libcurl/7.22.0 OpenSSL/1.0.1 zlib/1.2.3.4 libidn/1.23 librtmp/2.3" }, "json": null, "origin": "5.149.142.22", "url": "http://httpbin.org/post" }');
writeDump(res);
if(!structKeyExists(expected.form, 'abc') || !structKeyExists(expected.form, 'azerty')) {
  dumpError('Error: not equal to <br/> #expected#');
}



writeOutput("<br/><h1>POST (multipart)</h1>");
target = 'http://httpbin.org/post';
cURL = new cURL(target)
  .method('post')
  .multipart(true)
  .field('abc', 'def')
  .field('azerty', 123)
;
res = cURL.exec();
expected = deserializeJSON('{"args": {}, "data": "", "files": {}, "form": { "abc": "def", "azerty": "123" }, "headers": { "Accept": "*/*", "Content-Length": "239", "Content-Type": "multipart/form-data; boundary=----------------------------7cb7997bd60e", "Host": "httpbin.org", "User-Agent": "curl/7.22.0 (x86_64-pc-linux-gnu) libcurl/7.22.0 OpenSSL/1.0.1 zlib/1.2.3.4 libidn/1.23 librtmp/2.3" }, "json": null, "origin": "5.149.142.22", "url": "http://httpbin.org/post" }');
writeDump(res);
if(!structKeyExists(expected.form, 'abc') || !structKeyExists(expected.form, 'azerty')) {
  dumpError('Error: not equal to <br/> #expected#');
}



writeOutput("<br/><h1>POST (json)</h1>");
target = 'http://httpbin.org/post';
cURL = new cURL(target)
  .method('post')
  .json()
  .field('abc', 'def')
  .field('azerty', 123)
;
res = cURL.exec();
expected = deserializeJSON('{"args": {}, "data": "", "files": {}, "form": { "abc": "def", "azerty": "123" }, "headers": { "Accept": "*/*", "Content-Length": "239", "Content-Type": "multipart/form-data; boundary=----------------------------7cb7997bd60e", "Host": "httpbin.org", "User-Agent": "curl/7.22.0 (x86_64-pc-linux-gnu) libcurl/7.22.0 OpenSSL/1.0.1 zlib/1.2.3.4 libidn/1.23 librtmp/2.3" }, "json": null, "origin": "5.149.142.22", "url": "http://httpbin.org/post" }');
writeDump(res);
if(!structKeyExists(expected.form, 'abc') || !structKeyExists(expected.form, 'azerty')) {
  dumpError('Error: not equal to <br/> #expected#');
}
</cfscript>
