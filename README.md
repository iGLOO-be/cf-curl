# cURL
Coldfusion component that use cURL command.

Compatibility CF10+

## Usage

```
req = new cURL('http://httpbin.org/get');
res = req.exec();

res = new cURL('http://httpbin.org/get')
  .exec();
```

## Methods

- `.method(m)`: default `GET`
- `.header(name, value)`
- `.headers({ name = value, ... })`
- `.body(any)`
- `.file(path)`: file to attach.
- `.field(name, value)`
- `.fields(struct)`
- `.multipart(true|false)`: default `false`
- `.basicAuth(user, password)`
- `.json()`: add header `application/json` and serialize fields.
- `.head()`: head only.
- `.timeout(sec)`
- `.output(path)`
- `.insecure(true|false)`
- `.commandPath(command)`: custom command path
- `.addArg(string)`
- `.trace(true|false)`: default `true`
- `.useOutputTmpFile(true|false)`
- `.command()`: show the command generated.
- `.exec(true|false)`: execute the command and return the request and response parsed. Default `false`. If `true`, it return all calls.

## Result

Return of `.exec()`.

- request
  + sections: headers, ...
- response
  + header
  + data
  + status
    * code
    * line
