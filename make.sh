#!/bin/sh
yq '[.defaults["1"] * (.modes[] | select(.players==1))]+[.defaults["2"] * (.modes[] | select(.players==2))]' modes.yaml -jS >modes.json
