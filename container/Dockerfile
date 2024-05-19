# Build stage
FROM ubuntu:latest as builder

# 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    libglib2.0-dev \
    libmount-dev \
    libblkid-dev \
    pkg-config \
    make \
    gcc \
    libjson-glib-dev \
    libsoup2.4-dev \
    python3-venv

# Python 가상 환경 생성 및 활성화
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# pip 최신 버전으로 업그레이드
RUN pip install --upgrade pip

# 필요한 Python 패키지 설치
RUN pip install requests

# 소스 코드 복사 및 빌드
COPY ./src/c /tmp/src/c
WORKDIR /tmp/src/c
RUN make

# 실제 컨테이너
FROM ubuntu:latest

# 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    socat \
    strace \
    cockpit \
    python3-gi \
    python3-gi-cairo \
    gir1.2-gtk-3.0 \
    libjson-glib-dev \
    libsoup2.4-dev

# Python 가상 환경 복사
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 로그 디렉토리 생성 및 권한 설정
RUN mkdir -p /var/log/cockpit && chmod -R 777 /var/log/cockpit

# 빌드된 바이너리 복사
COPY --from=builder /tmp/src/c/cockpit-cloud-connector /container/cockpit-cloud-connector

# 스크립트 및 인증서 복사
COPY ./run.sh /container/run.sh
COPY ./src/py /container/src/py
COPY ./secrets /container/secrets

# 실행 권한 부여
RUN chmod +x /container/run.sh /container/cockpit-cloud-connector

# 로그 파일 권한 설정
RUN touch /var/log/cockpit/cockpit-cloud-connector.log && chmod 666 /var/log/cockpit/cockpit-cloud-connector.log

# 스크립트 실행
CMD ["/container/run.sh"]