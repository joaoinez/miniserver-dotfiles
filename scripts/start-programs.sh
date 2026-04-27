#!/bin/bash

/opt/homebrew/bin/orbctl start

/usr/local/bin/tailscale up

nohup /opt/homebrew/bin/glances -w &
