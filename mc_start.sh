#!/bin/bash
echo "Starting on $$"
PIPE_DIR=$(mktemp -dt bedrock_server-XXXXXXXXXX)
BEDROCK_SERVER_PIPE_OUT="$PIPE_DIR/bedrock_server-OUT"
BEDROCK_SERVER_PIPE_IN="$PIPE_DIR/bedrock_server-IN"
mkfifo $BEDROCK_SERVER_PIPE_OUT
mkfifo $BEDROCK_SERVER_PIPE_IN

function _rmpipe() {
	        rm -rf $PIPE_DIR
}

function _trap() {
	echo "SIGTERM"
	echo stop$'\n' >$BEDROCK_SERVER_PIPE_IN
	timeout -k 10 10 /bin/bash -c 'echo wait for "'"$BEDROCK_SERVER_PID"'" && tail --pid="'"$BEDROCK_SERVER_PID"'" -f /dev/null && echo "'"$BEDROCK_SERVER_PID terminated"'"'
	echo "bedrock-server pid ${BEDROCK_SERVER_PID} terminated."
}

trap _trap SIGTERM SIGINT TERM

echo "Start bedrock-server (stdin/stdout) ${BEDROCK_SERVER_PIPE_IN}/${BEDROCK_SERVER_PIPE_OUT}..."
./bedrock_server >$BEDROCK_SERVER_PIPE_OUT <$BEDROCK_SERVER_PIPE_IN  &
BEDROCK_SERVER_PID=$!
echo "Start ncat (stdin/stdout) ${BEDROCK_SERVER_PIPE_OUT}/${BEDROCK_SERVER_PIPE_IN}..."
ncat -vlk 49999 <$BEDROCK_SERVER_PIPE_OUT >$BEDROCK_SERVER_PIPE_IN  &
NCAT_PID=$!
echo "...bedrock-server started pid ${BEDROCK_SERVER_PID}"
echo "Start websocketd..."
./websocketd --devconsole --port=8080 "./websocketd.sh" &
WEBSOCKETD_PID=$!
echo "...websocketd started pid ${WEBSOCKETD_PID}"
echo "Wait for TERM INT"
wait $BEDROCK_SERVER_PID
echo "bedrock-server process terminated"
trap - SIGTERM SIGINT TERM
_rmpipe
echo "Terminate websocketd"
kill -TERM $WEBSOCKETD_PID
wait $WEBSOCKETD_PID
wait $BEDROCK_SERVER_PID
EXIT_STATUS=$?
echo "bedrock-server stopped. EXIT_STATUS: ${EXIT_STATUS}"

