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
- `.multipart(true|false)`: default `false`
- `.command()`: show the command generated
- `.exec()`: execute the command and return the response parsed

## Result

The return of `.exec()` is a struct.

- `status`
- `statusCode`
- `headers`
- `content`
