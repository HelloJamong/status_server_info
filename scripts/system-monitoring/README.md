# System Status Monitoring Script

Linux 서버의 시스템 상태를 한눈에 확인할 수 있는 Bash 스크립트입니다.

## 기능

이 스크립트는 다음과 같은 시스템 정보를 컬러풀하게 표시합니다:

- **CPU 정보**: 모델명, 소켓/코어/vCore 수, 사용률
- **메모리 정보**: 총 메모리, 메모리 사용률, SWAP 사용률
- **디스크 사용량**: Root(/), Boot(/boot) 파티션 사용률
- **서버 가동 시간**: 마지막 재부팅 시간, 총 가동 시간

## 상태 표시 기준

각 리소스의 사용률에 따라 자동으로 상태가 표시됩니다:

- **GOOD** (녹색): 사용률 60% 미만
- **WARN** (노란색): 사용률 60~80%
- **ALERT** (빨간색): 사용률 80% 이상

## 설치 방법

### 1. 스크립트 다운로드 및 설치

```bash
# 스크립트를 /usr/local/bin에 복사
sudo cp sys_status.sh /usr/local/bin/sys_status.sh

# 실행 권한 부여
sudo chmod +x /usr/local/bin/sys_status.sh
```

### 2. SSH 로그인 시 자동 실행 설정

#### SSH 접속 시 즉시 동작하도록 설정하기

Linux에서는 사용자가 로그인할 때 특정 파일에 작성된 명령어를 자동으로 실행합니다. 이 기능을 활용하여 SSH 접속 시 서버 상태를 자동으로 표시할 수 있습니다.

**Step 1: 자동 실행 설정 파일 이해하기**

- `.bash_profile`: SSH로 직접 로그인할 때 실행됩니다
- `.bashrc`: 새로운 터미널을 열거나 `su -` 명령어로 사용자 전환 시 실행됩니다

**Step 2: root 계정에 자동 실행 설정**

아래 명령어는 `/root/.bash_profile` 파일의 **맨 끝에** `/usr/local/bin/sys_status.sh` 라는 텍스트를 **추가**합니다:

```bash
echo '/usr/local/bin/sys_status.sh' >> /root/.bash_profile
```

**명령어 설명:**
- `echo '...'`: 따옴표 안의 내용을 출력하는 명령어
- `>>`: 출력된 내용을 파일의 맨 끝에 추가 (기존 내용은 유지됨)
  - 주의: `>` 하나만 사용하면 파일 내용이 완전히 덮어써지므로 반드시 `>>` 두 개를 사용해야 합니다
- `/root/.bash_profile`: root 계정의 로그인 설정 파일

**Step 3: 일반 사용자 계정에도 적용 (선택사항)**

현재 로그인한 사용자 계정에도 적용하려면:

```bash
echo '/usr/local/bin/sys_status.sh' >> ~/.bash_profile
```

**Step 4: su - 명령어로 전환 시에도 동작하도록 설정 (권장)**

일반 사용자로 로그인 후 `su -` 명령어로 root로 전환할 때도 스크립트가 실행되도록 하려면 `.bashrc`에도 추가:

```bash
echo '/usr/local/bin/sys_status.sh' >> /root/.bashrc
```

**Step 5: 즉시 적용하기**

파일을 수정한 후 다시 로그인하지 않고 바로 적용하려면:

```bash
source /root/.bash_profile
# 또는
source /root/.bashrc
```

**Step 6: 설정 확인**

올바르게 추가되었는지 확인:

```bash
cat /root/.bash_profile | grep sys_status
```

성공적으로 추가되었다면 `/usr/local/bin/sys_status.sh` 라는 줄이 출력됩니다.

## 사용 방법

### 수동 실행

```bash
/usr/local/bin/sys_status.sh
```

또는 PATH에 추가되어 있다면:

```bash
sys_status.sh
```

### 자동 실행

SSH 로그인 시 자동으로 실행됩니다 (위의 설정 완료 후).

## 출력 예시

```
================= SYSTEM MONITORING STATUS =================

■ CPU INFO                [Intel(R) Xeon(R) CPU E5-2680 v4 @ 2.40GHz]
■ CPU USING(%) STATUS     (CPUs: 56 | Socket: 2 | Core: 14 | vCore: 56)
■ CPU STATUS              : [25% / 80%] (GOOD)

■ MEMORY USING STATUS     (MemTotal: 125 GiB | SwapTotal: 8 GiB)
■ MEM USING(%)            : [45% / 80%] (GOOD)
■ SWAP USING(%)           : [0% / 80%] (GOOD)

■ DISK USING STATUS
■ ROOT(/) USING(%)        : [38% / 80%] (GOOD)
■ BOOT(/boot) USING(%)    : [22% / 80%] (GOOD)

■ LAST REBOOT TIME        : 12 weeks
■ SERVER UPTIME           : 85 days 14 hours 32 mins
■ SERVER TIME             : 2025-11-25 14-30-15
============================================================
```

## 시스템 요구사항

- Linux OS (Rocky Linux 8, 9 환경에서 테스트 완료)
- Bash
- 기본 유틸리티: `bc`, `lscpu`, `df`, `free`, `top`, `awk`, `grep`

## 문제 해결

### 스크립트가 자동 실행되지 않는 경우

1. `.bash_profile`과 `.bashrc`의 차이:
   - `.bash_profile`: 로그인 셸에서만 실행 (SSH 접속 시)
   - `.bashrc`: 비로그인 셸에서 실행 (터미널 실행 시)

2. 설정 확인:
   ```bash
   cat /root/.bash_profile | grep sys_status
   ```

3. 즉시 적용:
   ```bash
   source /root/.bash_profile
   ```

### 권한 오류가 발생하는 경우

```bash
sudo chmod +x /usr/local/bin/sys_status.sh
```

### 필수 명령어 누락 시

```bash
# Debian/Ubuntu
sudo apt-get install bc

# RHEL/CentOS
sudo yum install bc
```