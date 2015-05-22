# Sysdig Network Chisel

A sysdig chisel that shows the length of a complete network call, along with
summary of write/read data.

The script generates TSV formatted output with the following columns:

 * datetime: A date timestamp.
 * ts: A timestamp.
 * milliseconds: The number of milliseconds from connect to close.
 * client: Client IP and port.
 * server: Server IP and port.
 * write: A concatenated selection of what was written.
 * read: A concatenated selection of what was read.

Example usage:

    sysdig -c network proc.name=apache

Example output:

```
datetime	ts	milliseconds	client	server	write	read
2015-05-20 13:48:21.949488812	1.4321441019495e+18	0	XXX.XXX.XXX.XXX:55775	XXX.XXX.XXX.XXX:0		
2015-05-20 13:48:21.949492205	1.4321441019495e+18	0	XXX.XXX.XXX.XXX:55775	XXX.XXX.XXX.XXX:0		
2015-05-20 13:48:21.951304165	1.4321441019513e+18	21	XXX.XXX.XXX.XXX:41369	162.208.21.162:80	res=720 data=GET /index.html	res=398 data=HTTP/1.1 200 OK..Connection: close..Access-Control-Allow-Origin: *..Expires: Tues, 01 J
2015-05-20 13:48:21.951322810	1.4321441019513e+18	21	XXX.XXX.XXX.XXX:41369	162.208.21.162:80	res=720 data=GET /index.html	res=398 data=HTTP/1.1 200 OK..Connection: close..Access-Control-Allow-Origin: *..Expires: Tues, 01 J
2015-05-20 13:48:21.952729904	1.4321441019527e+18	15	XXX.XXX.XXX.XXX:47431	54.204.1.127:80	res=157 data=GET /index.html	res=162 data=HTTP/1.1 204 No Content..Server: Cowboy..Content-Length: 0..Connection: keep-alive..X-P
```
