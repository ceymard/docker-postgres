#!/bin/bash
branch=$(git branch --show-current)
docker build --progress=plain --rm -t ceymard/postgres-convenient:$branch .
