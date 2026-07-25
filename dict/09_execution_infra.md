# 용어 사전 — 실행 환경·인프라

[⬆ 사전 전체 목차로](README.md)

이 문서는 **실행 환경·인프라** 범주의 용어 22개를 다룹니다. 설명 속 파란 링크를 누르면 해당 용어 항목으로 이동하며, 각 항목 끝의 "이 용어를 참조하는 항목"으로 되돌아올 수 있습니다.

## 이 문서의 용어

- [실행 환경](#execution-environment)
- [샌드박스 (격리)](#sandbox)
- [호출별 스폰 모델](#spawn-per-call)
- [세션 스냅샷 (셸 상태)](#session-snapshot)
- [컨테이너](#container)
- [리눅스 네임스페이스](#namespace)
- [cgroups](#cgroups)
- [컨테이너 이미지](#container-image)
- [Docker 백엔드](#docker-backend)
- [SSH 백엔드](#ssh-backend)
- [Modal 백엔드](#modal-backend)
- [Daytona 백엔드](#daytona-backend)
- [Singularity/Apptainer 백엔드](#singularity-backend)
- [루트리스 컨테이너](#rootless)
- [VM 격리](#vm-isolation)
- [서버리스 컴퓨트](#serverless)
- [원격 파일 동기화](#file-sync)
- [재현성](#reproducibility)
- [Nix / Flake](#nix)
- [의존성 정확 고정](#exact-pinning)
- [지연 설치 의존성](#lazy-deps)
- [CI/CD](#ci-cd)

<a id="execution-environment"></a>

### 실행 환경

**영문**: Execution Environment · **범주**: 실행 환경·인프라

[터미널 도구](03_tool_system.md#terminal-tool)의 명령이 실제로 실행되는 백엔드 추상화(`tools/environments/`). local, Docker, SSH, Modal, Daytona, Singularity 백엔드가 같은 인터페이스를 구현합니다.

**하위 개념**: [Daytona 백엔드](#daytona-backend) · [Docker 백엔드](#docker-backend) · [원격 파일 동기화](#file-sync) · [Modal 백엔드](#modal-backend) · [샌드박스 (격리)](#sandbox) · [Singularity/Apptainer 백엔드](#singularity-backend) · [호출별 스폰 모델](#spawn-per-call) · [SSH 백엔드](#ssh-backend)

**관련 용어**: [터미널 도구](03_tool_system.md#terminal-tool) · [호출별 스폰 모델](#spawn-per-call) · [샌드박스 (격리)](#sandbox)

**이 용어를 참조하는 항목**: [터미널 도구](03_tool_system.md#terminal-tool)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="sandbox"></a>

### 샌드박스 (격리)

**영문**: Sandbox / Isolation · **범주**: 실행 환경·인프라

에이전트가 실행하는 명령이 호스트 시스템을 해치지 못하게 가두는 것. 프로세스 격리 < [컨테이너](#container) < [VM](#vm-isolation) 순으로 격리 강도가 올라갑니다.

**상위 개념**: [실행 환경](#execution-environment)

**하위 개념**: [컨테이너](#container) · [VM 격리](#vm-isolation)

**관련 용어**: [컨테이너](#container) · [VM 격리](#vm-isolation) · [리눅스 네임스페이스](#namespace)

**이 용어를 참조하는 항목**: [Daytona 백엔드](#daytona-backend) · [실행 환경](#execution-environment)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="spawn-per-call"></a>

### 호출별 스폰 모델

**영문**: Spawn-per-Call · **범주**: 실행 환경·인프라

명령마다 새 `bash -c` 프로세스를 띄우는 Hermes의 통일 실행 모델. 상시 셸(long-lived shell)의 상태 꼬임 문제를 피하고, 상태는 [세션 스냅샷](#session-snapshot)으로 유지합니다.

**상위 개념**: [실행 환경](#execution-environment)

**하위 개념**: [세션 스냅샷 (셸 상태)](#session-snapshot)

**관련 용어**: [세션 스냅샷 (셸 상태)](#session-snapshot)

**이 용어를 참조하는 항목**: [실행 환경](#execution-environment)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="session-snapshot"></a>

### 세션 스냅샷 (셸 상태)

**영문**: Session Snapshot · **범주**: 실행 환경·인프라

초기화 시 환경변수·함수·별칭을 한 번 캡처해 두고 매 명령 앞에 다시 source하는 방식. [호출별 스폰](#spawn-per-call)에서도 셸 상태가 이어지는 것처럼 보이게 합니다. 작업 디렉토리는 stdout 마커나 임시 파일로 전달됩니다.

**상위 개념**: [호출별 스폰 모델](#spawn-per-call)

**이 용어를 참조하는 항목**: [호출별 스폰 모델](#spawn-per-call)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="container"></a>

### 컨테이너

**영문**: Container · **범주**: 실행 환경·인프라

호스트 커널을 공유하되 [네임스페이스](#namespace)로 시야를, [cgroups](#cgroups)로 자원을 격리한 프로세스 묶음. VM보다 가볍고 빠르게 시작됩니다.

**상위 개념**: [샌드박스 (격리)](#sandbox)

**하위 개념**: [cgroups](#cgroups) · [컨테이너 이미지](#container-image) · [Docker 백엔드](#docker-backend) · [리눅스 네임스페이스](#namespace) · [루트리스 컨테이너](#rootless) · [Singularity/Apptainer 백엔드](#singularity-backend)

**관련 용어**: [리눅스 네임스페이스](#namespace) · [cgroups](#cgroups) · [컨테이너 이미지](#container-image) · [Docker 백엔드](#docker-backend)

**이 용어를 참조하는 항목**: [샌드박스 (격리)](#sandbox) · [VM 격리](#vm-isolation)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="namespace"></a>

### 리눅스 네임스페이스

**영문**: Linux Namespaces · **범주**: 실행 환경·인프라

프로세스가 보는 시스템 자원(프로세스 목록, 네트워크, 파일시스템 마운트)을 분리하는 리눅스 커널 기능. [컨테이너](#container) 격리의 반쪽입니다.

**상위 개념**: [컨테이너](#container)

**이 용어를 참조하는 항목**: [cgroups](#cgroups) · [컨테이너](#container) · [샌드박스 (격리)](#sandbox)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="cgroups"></a>

### cgroups

**영문**: Control Groups · **범주**: 실행 환경·인프라

프로세스 그룹의 CPU·메모리·IO 사용량을 제한하는 리눅스 커널 기능. [네임스페이스](#namespace)가 '보이는 것'을 격리한다면 cgroups는 '쓸 수 있는 양'을 격리합니다.

**상위 개념**: [컨테이너](#container)

**이 용어를 참조하는 항목**: [컨테이너](#container)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="container-image"></a>

### 컨테이너 이미지

**영문**: Container Image · **범주**: 실행 환경·인프라

컨테이너의 파일시스템과 실행 설정을 담은 불변 패키지. 같은 이미지는 어디서든 같은 환경을 만들어 [재현성](#reproducibility)을 보장합니다.

**상위 개념**: [컨테이너](#container)

**관련 용어**: [재현성](#reproducibility)

**이 용어를 참조하는 항목**: [컨테이너](#container) · [재현성](#reproducibility)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="docker-backend"></a>

### Docker 백엔드

**영문**: Docker Backend · **범주**: 실행 환경·인프라

명령을 Docker 컨테이너 안에서 실행하는 백엔드(`tools/environments/docker.py`). 호스트와 격리된 일회용 작업 공간을 제공합니다.

**상위 개념**: [실행 환경](#execution-environment) · [컨테이너](#container)

**이 용어를 참조하는 항목**: [컨테이너](#container)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="ssh-backend"></a>

### SSH 백엔드

**영문**: SSH Backend · **범주**: 실행 환경·인프라

명령을 원격 서버에서 SSH로 실행하는 백엔드. 로컬에 없는 자원(GPU, 특정 OS)을 활용할 수 있습니다.

**상위 개념**: [실행 환경](#execution-environment)

**관련 용어**: [원격 파일 동기화](#file-sync)

**이 용어를 참조하는 항목**: [원격 파일 동기화](#file-sync)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="modal-backend"></a>

### Modal 백엔드

**영문**: Modal Backend · **범주**: 실행 환경·인프라

서버리스 컴퓨트 플랫폼 Modal에서 명령을 실행하는 백엔드. 필요할 때만 클라우드 샌드박스를 띄워 쓰고 반납합니다.

**상위 개념**: [실행 환경](#execution-environment) · [서버리스 컴퓨트](#serverless)

**이 용어를 참조하는 항목**: [서버리스 컴퓨트](#serverless)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="daytona-backend"></a>

### Daytona 백엔드

**영문**: Daytona Backend · **범주**: 실행 환경·인프라

에이전트 전용 샌드박스 서비스 Daytona에서 명령을 실행하는 백엔드.

**상위 개념**: [실행 환경](#execution-environment)

**관련 용어**: [샌드박스 (격리)](#sandbox)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="singularity-backend"></a>

### Singularity/Apptainer 백엔드

**영문**: Singularity Backend · **범주**: 실행 환경·인프라

HPC(고성능 컴퓨팅) 환경 표준인 Apptainer(구 Singularity) 컨테이너로 실행하는 백엔드. 관리자 권한 없이([루트리스](#rootless)) 동작하는 것이 특징입니다.

**상위 개념**: [실행 환경](#execution-environment) · [컨테이너](#container)

**관련 용어**: [루트리스 컨테이너](#rootless)

**이 용어를 참조하는 항목**: [루트리스 컨테이너](#rootless)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="rootless"></a>

### 루트리스 컨테이너

**영문**: Rootless Container · **범주**: 실행 환경·인프라

root 권한 없이 일반 사용자로 실행되는 컨테이너. 공유 클러스터처럼 관리자 권한을 못 받는 환경에서 필수입니다.

**상위 개념**: [컨테이너](#container)

**관련 용어**: [Singularity/Apptainer 백엔드](#singularity-backend)

**이 용어를 참조하는 항목**: [Singularity/Apptainer 백엔드](#singularity-backend)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="vm-isolation"></a>

### VM 격리

**영문**: VM Isolation · **범주**: 실행 환경·인프라

하이퍼바이저 위에 별도 커널까지 통째로 띄우는 가장 강한 격리. [컨테이너](#container)보다 무겁지만 커널 취약점 공격까지 막습니다(예: Firecracker 마이크로VM).

**상위 개념**: [샌드박스 (격리)](#sandbox)

**관련 용어**: [컨테이너](#container)

**이 용어를 참조하는 항목**: [샌드박스 (격리)](#sandbox)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="serverless"></a>

### 서버리스 컴퓨트

**영문**: Serverless Compute · **범주**: 실행 환경·인프라

서버를 상시 운영하지 않고 함수/작업 단위로 필요할 때만 실행 환경을 빌려 쓰는 모델. 쓴 만큼만 과금됩니다.

**하위 개념**: [Modal 백엔드](#modal-backend)

**관련 용어**: [Modal 백엔드](#modal-backend)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="file-sync"></a>

### 원격 파일 동기화

**영문**: Remote File Sync · **범주**: 실행 환경·인프라

로컬 파일 도구와 원격 실행 환경 사이에서 파일을 오가게 하는 계층(`tools/environments/file_sync.py`). 원격 백엔드에서도 파일 도구가 동작하게 합니다.

**상위 개념**: [실행 환경](#execution-environment)

**관련 용어**: [SSH 백엔드](#ssh-backend)

**이 용어를 참조하는 항목**: [SSH 백엔드](#ssh-backend)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="reproducibility"></a>

### 재현성

**영문**: Reproducibility · **범주**: 실행 환경·인프라

같은 입력에서 언제 어디서든 같은 환경·결과가 나오는 성질. [이미지](#container-image), [Nix](#nix), [의존성 고정](#exact-pinning)이 모두 이를 위한 수단입니다.

**하위 개념**: [의존성 정확 고정](#exact-pinning) · [Nix / Flake](#nix)

**관련 용어**: [컨테이너 이미지](#container-image) · [Nix / Flake](#nix) · [의존성 정확 고정](#exact-pinning)

**이 용어를 참조하는 항목**: [CI/CD](#ci-cd) · [컨테이너 이미지](#container-image)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="nix"></a>

### Nix / Flake

**영문**: Nix · **범주**: 실행 환경·인프라

패키지와 환경을 순수 함수처럼 선언해 완전히 재현 가능한 빌드를 만드는 도구. Hermes는 flake.nix로 Nix 패키징을 제공합니다.

**상위 개념**: [재현성](#reproducibility)

**이 용어를 참조하는 항목**: [재현성](#reproducibility)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="exact-pinning"></a>

### 의존성 정확 고정

**영문**: Exact Pinning · **범주**: 실행 환경·인프라

pyproject.toml에서 의존성 버전을 `==`로 정확히 고정하는 정책. '어제는 됐는데 오늘 안 되는' 문제를 차단합니다.

**상위 개념**: [재현성](#reproducibility)

**관련 용어**: [지연 설치 의존성](#lazy-deps)

**이 용어를 참조하는 항목**: [지연 설치 의존성](#lazy-deps) · [재현성](#reproducibility)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="lazy-deps"></a>

### 지연 설치 의존성

**영문**: Lazy Dependencies · **범주**: 실행 환경·인프라

무거운 선택적 의존성을 기본 설치에 포함하지 않고, 해당 기능을 처음 쓸 때 설치하는 전략. 기본 설치를 가볍게 유지합니다.

**관련 용어**: [의존성 정확 고정](#exact-pinning) · [풋프린트 사다리](11_design_principles.md#footprint-ladder)

**이 용어를 참조하는 항목**: [의존성 정확 고정](#exact-pinning)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="ci-cd"></a>

### CI/CD

**영문**: CI/CD · **범주**: 실행 환경·인프라

코드 변경마다 자동으로 테스트(CI)하고 릴리스를 자동화(CD)하는 파이프라인. GitHub Actions로 구현되어 있습니다.

**관련 용어**: [재현성](#reproducibility)

**이 용어를 참조하는 항목**: [컨벤셔널 커밋](11_design_principles.md#conventional-commits)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
