# cURL
Coldfusion component that use cURL command.

## Usage

```
req = new cURL('http://httpbin.org/get');
res = req.exec();
```

## Methods

- `.method(m)`: default `GET`
- `.header(name, value)`
- `.headers({ name = value, ... })`
- `.field(name, value)`
- `.fields(struct)`
- `.multipart(true|false)`: default `false`
- `.basicAuth(user, password)`
- `.command()`: show the command generated
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
