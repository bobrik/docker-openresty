# OpenResty

This is [OpenResty](https://openresty.org/) docker image on top of debian.
It is built on top of OpenResty branch that supports `balancer_by_lua`.

## Usage

There's not much sense in using this image directly. It is intended to be
used as a base image.

```
FROM bobrik/openresty

# COPY your nginx confs
```
