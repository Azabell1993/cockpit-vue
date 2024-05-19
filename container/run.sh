#!/bin/bash

# 환경 변수 설정
ENVIRONMENT=${ENVIRONMENT:-local}  # 기본값은 local로 설정

# Python 서버의 IP 주소를 Docker Compose 환경 변수로부터 가져옴
PYTHON_SERVER_HOST=${PYTHON_SERVER_HOST:-localhost}
PYTHON_SERVER_PORT=${PYTHON_SERVER_PORT:-8081}

if [ "$ENVIRONMENT" == "production" ]; then
    # 운영 환경 변수
    CERT_FILE="/container/secrets/server.crt"
    KEY_FILE="/container/secrets/server.key"
    PEER_CERT_FILE="/container/secrets/server.crt"
    PORT=443

    # Python 서버 실행 (백그라운드)
    python3 /container/src/py/server.py --address 0.0.0.0 --port $PYTHON_SERVER_PORT &
    /container/cockpit-cloud-connector --cert "$CERT_FILE" --key "$KEY_FILE" --peer-cert "$PEER_CERT_FILE" server /tmp/server.sock --port $PORT
else
    # 로컬 환경 변수
    PORT=8080

    # Python 서버 실행 (백그라운드)
    python3 /container/src/py/server.py --address 0.0.0.0 --port $PYTHON_SERVER_PORT &
    /container/cockpit-cloud-connector server /tmp/server.sock --port $PORT --use-tls=false
fi
