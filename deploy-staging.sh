#!/bin/sh
rm -rf out
rm -rf gzip
docpad --env static generate
grunt deploy-staging