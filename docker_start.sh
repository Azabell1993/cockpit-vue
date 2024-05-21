#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 실행 환경 설정
echo -e "${GREEN}환경 설정 중입니다...${NC}"
while true; do
    echo -e "${RED}[ default : local ]${NC}"
    read -p "실행 환경을 선택하세요 (local/production): " ENVIRONMENT
    ENVIRONMENT=${ENVIRONMENT:-local}  # 기본값은 local로 설정
    if [[ "$ENVIRONMENT" == "local" || "$ENVIRONMENT" == "production" ]]; then
        break
    else
        echo -e "${RED}잘못된 입력입니다. 'local' 또는 'production' 중 하나를 입력하세요.${NC}"
    fi
done
export ENVIRONMENT
echo -e "${GREEN}실행 환경: $ENVIRONMENT${NC}"

# Docker 설치 확인 및 설치
echo -e "${GREEN}Docker 설치 상태를 확인 중입니다...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${BLUE}Docker가 설치되어 있지 않습니다. 설치를 진행합니다...${NC}"
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    if [ $? -ne 0 ]; then
        echo -e "${RED}Docker 설치 실패!${NC}"
        exit 1
    fi
    echo -e "${GREEN}Docker 설치 완료!${NC}"
else
    echo -e "${GREEN}Docker가 이미 설치되어 있습니다.${NC}"
fi

# Docker Compose 설치 확인 및 설치
echo -e "${GREEN}Docker Compose 설치 상태를 확인 중입니다...${NC}"
if ! command -v docker-compose &> /dev/null; then
    echo -e "${BLUE}Docker Compose가 설치되어 있지 않습니다. 설치를 진행합니다...${NC}"
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    if [ $? -ne 0 ]; then
        echo -e "${RED}Docker Compose 설치 실패!${NC}"
        exit 1
    fi
    echo -e "${GREEN}Docker Compose 설치 완료!${NC}"
else
    echo -e "${GREEN}Docker Compose가 이미 설치되어 있습니다.${NC}"
fi

# Cockpit 서비스 설치 확인 및 설치
echo -e "${GREEN}Cockpit 서비스 설치 상태를 확인 중입니다...${NC}"
if ! dpkg -l | grep -q cockpit; then
    echo -e "${BLUE}Cockpit 서비스가 설치되어 있지 않습니다. 설치를 진행합니다...${NC}"
    sudo apt-get update
    sudo apt-get install -y cockpit
    if [ $? -ne 0 ]; then
        echo -e "${RED}Cockpit 서비스 설치 실패!${NC}"
        exit 1
    fi
    echo -e "${GREEN}Cockpit 서비스 설치 완료!${NC}"
else
    echo -e "${GREEN}Cockpit 서비스가 이미 설치되어 있습니다.${NC}"
fi

# 아스키 아트 출력
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}   ____  ____  ____  _  _  ____  ____  _  _  ____  _  _  ____ ${NC}"
echo -e "${BLUE}  / ___)(_  _)( ___)( \/ )(_  _)( ___)( \( )(_  _)( \/ )(  _ \\ ${NC}"
echo -e "${BLUE}  \\___ \\  )(   )__)  \\  /  _)(_  )__)  )  (   )(   \\  /  )(_) )${NC}"
echo -e "${BLUE}  (____/ (__) (____)  \\/  (____)(____)(_)\\_) (__)   \\/  (____/${NC}"
echo -e "${BLUE}============================================================${NC}"

# 네트워크 연결 상태 확인
echo -e "${GREEN}네트워크 연결 상태를 확인 중입니다...${NC}"
ping -c 1 google.com > /dev/null 2>& 1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}네트워크 연결 상태 양호!${NC}"
else
    echo -e "${RED}네트워크 연결 오류!${NC}"
    exit 1
fi

# Cockpit 서비스 재시작
echo -e "${GREEN}Cockpit 서비스를 재시작 중입니다...${NC}"
sudo systemctl restart cockpit
if [ $? -ne 0 ]; then
    echo -e "${RED}Cockpit 서비스 재시작 실패!${NC}"
    exit 1
fi
echo -e "${GREEN}Cockpit 서비스 재시작 완료!${NC}"

# secrets 디렉토리 처리
if [ -d "container/secrets" ]; then
    echo -e "${GREEN}기존의 secrets 디렉토리를 삭제 중입니다...${NC}"
    rm -rf container/secrets
    if [ $? -ne 0 ]; then
        echo -e "${RED}secrets 디렉토리 삭제 실패!${NC}"
        echo -e "${RED}반드시 sudo 권한으로 해주세요.${NC}"
        exit 1
    fi
    echo -e "${GREEN}기존의 secrets 디렉토리 삭제 완료!${NC}"
fi

echo -e "${GREEN}secrets 디렉토리를 생성 중입니다...${NC}"
mkdir -p container/secrets
if [ $? -ne 0 ]; then
    echo -e "${RED}secrets 디렉토리 생성 실패!${NC}"
    exit 1
fi

# secrets 디렉토리 생성 및 SSL 키/인증서 생성
echo -e "${GREEN}SSL 키와 인증서를 생성 중입니다...${NC}"

# 서버 키와 인증서 생성
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout container/secrets/server.key -out container/secrets/server.crt -subj "/CN=localhost"
if [ $? -ne 0 ]; then
    echo -e "${RED}서버 키와 인증서 생성 실패!${NC}"
    exit 1
fi

# 클라이언트 인증서 생성 (선택사항)
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout container/secrets/client.key -out container/secrets/client.crt -subj "/CN=localhost"
if [ $? -ne 0 ]; then
    echo -e "${RED}클라이언트 인증서 생성 실패!${NC}"
    exit 1
fi

# myKey.pem 생성
openssl req -new -newkey rsa:2048 -nodes -keyout container/secrets/myKey.pem -out container/secrets/myKey.pem -subj "/CN=localhost"
if [ $? -ne 0 ]; then
    echo -e "${RED}myKey.pem 생성 실패!${NC}"
    exit 1
fi

echo -e "${GREEN}SSL 키와 인증서, myKey.pem 생성 완료!${NC}"

# /container/run.sh 파일에 실행 권한 부여
echo -e "${GREEN}/container/run.sh 파일에 실행 권한을 부여 중입니다...${NC}"
sudo chmod +x container/run.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}/container/run.sh 파일에 실행 권한 부여 실패!${NC}"
    exit 1
fi
echo -e "${GREEN}/container/run.sh 파일에 실행 권한 부여 완료!${NC}"

##########################################################################################################################################
##########################################################################################################################################
# sudo docker-compose down
# sudo docker system prune -a
# sudo systemctl restart docker
# sudo docker-compose down
# sudo docker-compose up --build -d
##########################################################################################################################################
##########################################################################################################################################

echo -e "${GREEN}Docker Cleaning...${NC}"
sudo docker-compose down
sudo docker system prune -a
sudo systemctl restart docker
if [ $? -ne 0 ]; then
    echo -e "${RED}docker 서비스 재시작 실패!${NC}"
    exit 1
fi
echo -e "${GREEN}docker 서비스 재시작 완료!${NC}"

# Docker Compose를 사용하여 컨테이너 실행
echo -e "${GREEN}Docker Compose를 사용하여 컨테이너를 실행 중입니다...${NC}"
sudo docker-compose up --build -d
if [ $? -ne 0 ]; then
    echo -e "${RED}Docker Compose 실행 실패!${NC}"
    exit 1
fi
echo -e "${GREEN}Docker Compose 실행 완료!${NC}"

# 실행 중인 컨테이너 목록 확인
echo -e "${GREEN}실행 중인 Docker 컨테이너 목록:${NC}"
sudo docker ps
if [ $? -ne 0 ]; then
    echo -e "${RED}Docker 컨테이너 목록 확인 실패!${NC}"
    exit 1
fi

# 실행 중인 컨테이너의 포트 확인
echo -e "${GREEN}실행 중인 컨테이너의 포트 확인:${NC}"
sudo lsof -i -P -n | grep LISTEN | grep '8080\|8081'

echo -e "${GREEN} 실행 중인 컨테이너 확인"
sudo docker ps -a

echo " "
echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}           모든 작업이 완료되었습니다!${NC}"
echo -e "${BLUE}================================================================${NC}"