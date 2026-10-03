#! /bin/sh

podman run -d -p 3000:8080 -v $XDG_STATE_HOME/open-webui:/app/backend/data:Z --name open-webui ghcr.io/open-webui/open-webui:main


