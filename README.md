# cockpit-cloud-c 
  
## 프로젝트 설명   
이 프로젝트는 로컬 환경에서 Cockpit API 서버와 프론트엔드를 Docker 컨테이너로 실행하여 테스트하는 예제입니다. 백엔드 서버는 C와 Python으로 작성되었으며, 프론트엔드는 HTML과 JavaScript로 작성되었습니다. Docker Compose를 사용하여 각 서비스를 간편하게 관리할 수 있습니다.  
  
## 목적  
- 1. **HTTP 환경에서 동작**: SSL 인증서 없이 HTTP 환경에서 서버가 동작하도록 설정하였습니다.  
- 2. **포트 변경**: 기본적으로 443 포트를 사용하는 코드를 로컬 환경에서 사용할 수 있도록 적절한 포트 번호 (8080, 8081)로 변경하였습니다.  
- 3. **프론트엔드에서 백엔드 확인**: 프론트엔드 HTML 페이지에서 버튼을 클릭하여 백엔드 서버로부터 데이터를 받아와 표시할 수 있습니다.  
  
## 파일 구조  
```
cockpit-vue
├── container
│ ├── Dockerfile
│ ├── run.sh
│ └── src
│ ├── c
│ │ ├── cockpit-cloud.c
│ │ └── Makefile
│ └── py
│ └── server.py
├── docker-compose.yml
├── docker_run.sh
├── frontend
│ ├── Dockerfile
│ ├── nginx.conf
│ └── src
│ └── index.html
├── README.md
└── secrets
├── client.crt
├── client.key
├── myKey.pem
├── server.crt
└── server.key
```  
  
## 사용 방법  
  
1. **Docker Compose 실행**:
    ```bash
    ./docker_run.sh
    ```  
  
2. **프론트엔드 접속**:  
    - 웹 브라우저에서 `http://localhost:8080`으로 접속합니다.  
    - "Fetch Cockpit Data" 버튼을 클릭하여 백엔드 서버로부터 데이터를 가져옵니다.  
  
3. **백엔드 확인**:  
    - 백엔드 서버는 기본적으로 포트 8081에서 동작하며, HTTP로 통신합니다.  
    - 프론트엔드에서 데이터를 가져올 때 `http://localhost:8080` 경로를 사용합니다.  

  
## 주의사항  
  
- 이 프로젝트는 로컬 환경에서 테스트 목적으로 설정되었으며, 운영 환경에서는 적절한 SSL 인증서와 보안 설정을 적용해야 합니다.  
  

```
ubuntu@local:~/Desktop/cockpit-vue$ sudo ./docker_run.sh 
[sudo] password for ubuntu: 
환경 설정 중입니다...
실행 환경을 선택하세요 (local/production) [ default : local ]: 
실행 환경: local
Docker 설치 상태를 확인 중입니다...
Docker가 이미 설치되어 있습니다.
Docker Compose 설치 상태를 확인 중입니다...
Docker Compose가 이미 설치되어 있습니다.
Cockpit 서비스 설치 상태를 확인 중입니다...
Cockpit 서비스가 이미 설치되어 있습니다.
============================================================
   ____  ____  ____  _  _  ____  ____  _  _  ____  _  _  ____ 
  / ___)(_  _)( ___)( \/ )(_  _)( ___)( \( )(_  _)( \/ )(  _ \ 
  \___ \  )(   )__)  \  /  _)(_  )__)  )  (   )(   \  /  )(_) )
  (____/ (__) (____)  \/  (____)(____)(_)\_) (__)   \/  (____/
============================================================
네트워크 연결 상태를 확인 중입니다...
네트워크 연결 상태 양호!
Docker Cleaning...
WARNING! This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all images without at least one container associated to them
  - all build cache

Are you sure you want to continue? [y/N] y

Creating cockpit-vue_frontend_1 ... done
Creating cockpit-vue_cockpit_1  ... done
Docker Compose 실행 완료!
실행 중인 Docker 컨테이너 목록:
CONTAINER ID   IMAGE                 COMMAND               CREATED        STATUS                  PORTS                                       NAMES
a0f69657bb15   cockpit-vue_cockpit   "/container/run.sh"   1 second ago   Up Less than a second   0.0.0.0:8081->8080/tcp, :::8081->8080/tcp   cockpit-vue_cockpit_1
실행 중인 컨테이너의 포트 확인:
docker-pr 39014            root    4u  IPv4 128385      0t0  TCP *:8081 (LISTEN)
docker-pr 39020            root    4u  IPv6 129448      0t0  TCP *:8081 (LISTEN)
 실행 중인 컨테이너 확인
CONTAINER ID   IMAGE                  COMMAND                  CREATED         STATUS                    PORTS                                       NAMES
a0f69657bb15   cockpit-vue_cockpit    "/container/run.sh"      2 seconds ago   Up Less than a second     0.0.0.0:8081->8080/tcp, :::8081->8080/tcp   cockpit-vue_cockpit_1
097f47d867df   cockpit-vue_frontend   "/docker-entrypoint.…"   2 seconds ago   Exited (1) 1 second ago                                               cockpit-vue_frontend_1
 
================================================================
           모든 작업이 완료되었습니다!
================================================================

```   
  
```
ubuntu@local:~/Desktop/cockpit-vue$ sudo docker exec -it 107adbf66afb /bin/bash
root@107adbf66afb:/# ls /container/cockpit-cloud-connector
/container/cockpit-cloud-connector
root@107adbf66afb:/# ubuntu@local:~/Desktop/cockpit-vue$ sudo docker exec -it 107adbf66afb /bin/bash
root@107adbf66afb:/# ls /container/cockpit-cloud-connector
/container/cockpit-cloud-connector
```  
  
- Docker 이미지 다시 빌드  
수정된 내용을 반영하여 Docker 이미지를 다시 빌드합니다. 여기서는 cockpit-vue-cockpit 서비스 이미지를 다시 빌드합니다.  
```
# bash
sudo docker-compose build cockpit
```  
  
- 실행 중인 컨테이너 업데이트  
 실행 중인 컨테이너를 새로운 이미지로 교체합니다. 이때 중단 없이 서비스를 업데이트하기 위해 docker-compose up --no-deps --build 명령을 사용합니다.
```
# bash
sudo docker-compose up -d --no-deps --build cockpit
```   


# cockpit-vue
