# Psqlconn
A small utility for easily connecting to postgres servers.

It works by parsing your ~/.pgpass file, and using the comments in that file as names for the servers.

### Usage

1. Put comments above the servers in your ~/.pgpass file
```
# awesome psql server, another name
some-host::my_user:super_secret_password
```
2. run `psqlconn` with one of your chosen names
```
psqlconn awesome psql server
```
or
```
psqlconn another name
```
