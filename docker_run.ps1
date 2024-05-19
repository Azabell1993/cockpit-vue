# 색상 정의
$RED = "`e[0;31m"
$GREEN = "`e[0;32m"
$BLUE = "`e[0;34m"
$NC = "`e[0m" # No Color

# 실행 환경 설정
Write-Host "${GREEN}환경 설정 중입니다...${NC}"
$ENVIRONMENT = Read-Host "실행 환경을 선택하세요 (local/production)"
if ([string]::IsNullOrEmpty($ENVIRONMENT)) {
    $ENVIRONMENT = "local"
}
$env:ENVIRONMENT = $ENVIRONMENT
Write-Host "${GREEN}실행 환경: $ENVIRONMENT${NC}"

# Docker 설치 확인
Write-Host "${GREEN}Docker 설치 상태를 확인 중입니다...${NC}"
if (-not (Get-Command "docker" -ErrorAction SilentlyContinue)) {
    Write-Host "${BLUE}Docker가 설치되어 있지 않습니다. 설치를 진행합니다...${NC}"
    choco install docker-desktop -y
    if ($LASTEXITCODE -ne 0) {
        Write-Host "${RED}Docker 설치 실패!${NC}"
        exit 1
    }
    Write-Host "${GREEN}Docker 설치 완료!${NC}"
} else {
    Write-Host "${GREEN}Docker가 이미 설치되어 있습니다.${NC}"
}

# Docker Compose 설치 확인
Write-Host "${GREEN}Docker Compose 설치 상태를 확인 중입니다...${NC}"
if (-not (Get-Command "docker-compose" -ErrorAction SilentlyContinue)) {
    Write-Host "${BLUE}Docker Compose가 설치되어 있지 않습니다. 설치를 진행합니다...${NC}"
    choco install docker-compose -y
    if ($LASTEXITCODE -ne 0) {
        Write-Host "${RED}Docker Compose 설치 실패!${NC}"
        exit 1
    }
    Write-Host "${GREEN}Docker Compose 설치 완료!${NC}"
} else {
    Write-Host "${GREEN}Docker Compose가 이미 설치되어 있습니다.${NC}"
}

# Cockpit 서비스 설치 확인 (Windows에서는 설치 필요 없음)
# Write-Host "${GREEN}Cockpit 서비스 설치 상태를 확인 중입니다...${NC}"
# (Optional) Add Cockpit installation steps for Windows if applicable.

# 아스키 아트 출력
Write-Host "${BLUE}============================================================${NC}"
Write-Host "${BLUE}   ____  ____  ____  _  _  ____  ____  _  _  ____  _  _  ____ ${NC}"
Write-Host "${BLUE}  / ___)(_  _)( ___)( \/ )(_  _)( ___)( \( )(_  _)( \/ )(  _ \ ${NC}"
Write-Host "${BLUE}  \___ \  )(   )__)  \  /  _)(_  )__)  )  (   )(   \  /  )(_) )${NC}"
Write-Host "${BLUE}  (____/ (__) (____)  \/  (____)(____)(_)\\_) (__)   \/  (____/${NC}"
Write-Host "${BLUE}============================================================${NC}"

# 네트워크 연결 상태 확인
Write-Host "${GREEN}네트워크 연결 상태를 확인 중입니다...${NC}"
Test-Connection -ComputerName google.com -Count 1 -ErrorAction SilentlyContinue
if ($?) {
    Write-Host "${GREEN}네트워크 연결 상태 양호!${NC}"
} else {
    Write-Host "${RED}네트워크 연결 오류!${NC}"
    exit 1
}

Write-Host "${GREEN}Docker Cleaning...${NC}"
docker-compose down
docker system prune -a -f
Restart-Service docker
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}docker 서비스 재시작 실패!${NC}"
    exit 1
}
Write-Host "${GREEN}docker 서비스 재시작 완료!${NC}"

# Cockpit 서비스 재시작 (Windows에서는 Cockpit 서비스가 없음)
# Write-Host "${GREEN}Cockpit 서비스를 재시작 중입니다...${NC}"
# Restart-Service cockpit
# if ($LASTEXITCODE -ne 0) {
#     Write-Host "${RED}Cockpit 서비스 재시작 실패!${NC}"
#     exit 1
# }
# Write-Host "${GREEN}Cockpit 서비스 재시작 완료!${NC}"

# secrets 디렉토리 처리
if (Test-Path "container\secrets") {
    Write-Host "${GREEN}기존의 secrets 디렉토리를 삭제 중입니다...${NC}"
    Remove-Item -Recurse -Force "container\secrets"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "${RED}secrets 디렉토리 삭제 실패!${NC}"
        exit 1
    }
    Write-Host "${GREEN}기존의 secrets 디렉토리 삭제 완료!${NC}"
}

Write-Host "${GREEN}secrets 디렉토리를 생성 중입니다...${NC}"
New-Item -ItemType Directory -Path "container\secrets"
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}secrets 디렉토리 생성 실패!${NC}"
    exit 1
}

# secrets 디렉토리 생성 및 SSL 키/인증서 생성
Write-Host "${GREEN}SSL 키와 인증서를 생성 중입니다...${NC}"

# 서버 키와 인증서 생성
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout container\secrets\server.key -out container\secrets\server.crt -subj "/CN=localhost"
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}서버 키와 인증서 생성 실패!${NC}"
    exit 1
}

# 클라이언트 인증서 생성 (선택사항)
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout container\secrets\client.key -out container\secrets\client.crt -subj "/CN=localhost"
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}클라이언트 인증서 생성 실패!${NC}"
    exit 1
}

# myKey.pem 생성
openssl req -new -newkey rsa:2048 -nodes -keyout container\secrets\myKey.pem -out container\secrets\myKey.pem -subj "/CN=localhost"
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}myKey.pem 생성 실패!${NC}"
    exit 1
}

Write-Host "${GREEN}SSL 키와 인증서, myKey.pem 생성 완료!${NC}"

# Docker 이미지를 빌드
Write-Host "${GREEN}Docker 이미지를 빌드 중입니다...${NC}"
docker build -t cockpit-cloud -f container\Dockerfile .\container
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Docker 이미지 빌드 실패!${NC}"
    exit 1
}
Write-Host "${GREEN}Docker 이미지 빌드 완료!${NC}"

# 기존의 컨테이너 삭제
Write-Host "${GREEN}기존의 Docker 컨테이너를 삭제 중입니다...${NC}"
docker rm -f cockpit-cloud-container
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}기존 Docker 컨테이너 삭제 실패!${NC}"
}
Write-Host "${GREEN}기존 Docker 컨테이너 삭제 완료!${NC}"

# /container/run.sh 파일에 실행 권한 부여
Write-Host "${GREEN}/container/run.sh 파일에 실행 권한을 부여 중입니다...${NC}"
Set-ItemProperty -Path container\run.sh -Name IsReadOnly -Value $false
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}/container/run.sh 파일에 실행 권한 부여 실패!${NC}"
    exit 1
}
Write-Host "${GREEN}/container/run.sh 파일에 실행 권한 부여 완료!${NC}"

# Docker Compose를 사용하여 컨테이너 실행
Write-Host "${GREEN}Docker Compose를 사용하여 컨테이너를 실행 중입니다...${NC}"
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Docker Compose 실행 실패!${NC}"
    exit 1
}
Write-Host "${GREEN}Docker Compose 실행 완료!${NC}"

# 실행 중인 컨테이너 목록 확인
Write-Host "${GREEN}실행 중인 Docker 컨테이너 목록:${NC}"
docker ps
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Docker 컨테이너 목록 확인 실패!${NC}"
    exit 1
}

# 실행 중인 컨테이너의 포트 확인
Write-Host "${GREEN}실행 중인 컨테이너의 포트 확인:${NC}"
netstat -an | Select-String -Pattern "8080|8081"

Write-Host "${GREEN} 실행 중인 컨테이너 확인"
docker ps -a

Write-Host " "
Write-Host "${BLUE}================================================================${NC}"
Write-Host "${BLUE}           모든 작업이 완료되었습니다!${NC}"
Write-Host "${BLUE
