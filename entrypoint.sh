#!/bin/bash
#
# Starts the gui inside the docker container using the conda env
#


# Launch web gui
cd /stable-diffusion-webui
git stash
git pull
git stash pop

if [[ -z $WEBUI_ARGS ]]; then
    launch_message="entrypoint.sh: Launching..."
else
    launch_message="entrypoint.sh: Launching with arguments ${WEBUI_ARGS}"
fi

if [[ -z $WEBUI_RELAUNCH || $WEBUI_RELAUNCH == "true" ]]; then
    n=0
    while true; do

        echo $launch_message
        if (( $n > 0 )); then
            echo "Relaunch count: ${n}"
        fi
        python3 -u webui.py $WEBUI_ARGS
        echo "entrypoint.sh: Process is ending. Relaunching in 0.5s..."
        ((n++))
        sleep 0.5
    done
else
    echo $launch_message
    python3 -u webui.py $WEBUI_ARGS
fi
