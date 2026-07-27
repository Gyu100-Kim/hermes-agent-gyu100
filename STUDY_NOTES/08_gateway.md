# 08. 게이트웨이 — 여러 메시징 플랫폼을 한 코어로 (1-C-6)

## 이 문서에서 다루는 큰 맥락

**게이트웨이 ([용어사전](../dict/07_gateway_interfaces.md#gateway))(gateway)** 는 Telegram·Discord·Slack 등 ~20개 메시징 플랫폼을 하나의
상시 실행 프로세스에서 받아, 모두 동일한 에이전트 코어([04](04_agent_loop.md))로
연결하는 서비스입니다. "코어는 하나, 얼굴은 여러 개"에서 가장 많은 얼굴을 만드는
부분입니다.

큰 흐름:
```
GatewayRunner (gateway/run.py)   ← 전체 생명주기 관리
  ├─ 플랫폼 어댑터들 (gateway/platforms/*)  ← 각 메신저 연결
  │     (플러그인 어댑터는 platform_registry.py로 자기등록)
  ├─ SessionManager (gateway/session.py)   ← "누가/어디서 보냈나" + 세션 재개
  └─ delivery (gateway/delivery.py)        ← 응답/cron 결과를 올바른 곳으로 전달
```

### 소목차
- [1. 게이트웨이가 푸는 문제](#1-게이트웨이가-푸는-문제)
- [2. GatewayRunner — 생명주기 관리자](#2-gatewayrunner--생명주기-관리자)
- [3. 세션 관리와 자동 이어가기(auto-continue)](#3-세션-관리와-자동-이어가기auto-continue)
- [4. 전달(delivery) 라우팅](#4-전달delivery-라우팅)
- [5. 플랫폼 어댑터와 자기등록 레지스트리](#5-플랫폼-어댑터와-자기등록-레지스트리)
- [6. 새 플랫폼 추가하기 — 플러그인 vs 코어](#6-새-플랫폼-추가하기--플러그인-vs-코어)

---

## 들어가기 전에 — 필요한 배경과 비유

**필요한 배경**: [04](04_agent_loop.md)의 대화 루프, 그리고 "텔레그램·디스코드 같은
메신저도 결국 서버 API로 메시지를 주고받는다"는 감각.

**비유**: 게이트웨이는 회사의 **대표전화 교환원**입니다. 텔레그램·디스코드·슬랙 등
어느 회선으로 전화가 와도(플랫폼 어댑터), 교환원이 "누구의 어떤 대화인지"를 확인해
(세션 관리) 같은 담당 비서(에이전트 코어)에게 연결하고, 답장을 다시 올바른 회선으로
돌려보냅니다(delivery 라우팅). 새 메신저 플랫폼 추가 = 새 회선 모듈 하나를 꽂는 일입니다.

**학습 목표**: 메시지 하나가 플랫폼 → 어댑터 → 세션 → 에이전트 → delivery → 플랫폼으로
왕복하는 경로를 그릴 수 있고, 새 플랫폼을 추가하려면 무엇을 구현해야 하는지 말할 수 있게 됩니다.

---

## 1. 게이트웨이가 푸는 문제

한 사람이 텔레그램, 디스코드, 슬랙에서 동시에 Hermes에게 말을 걸 수 있습니다.
게이트웨이는 다음을 동시에 해결해야 합니다:
- 여러 플랫폼의 서로 다른 API/이벤트를 **하나의 공통 형식**으로 정규화
- 각 대화의 **세션을 추적**하고 필요 시 이어가기/새로 시작
- 에이전트의 응답을 **원래 온 곳(또는 지정한 곳)** 으로 정확히 되돌려 보내기
- 인가(authorization), 슬래시 명령 ([용어사전](../dict/07_gateway_interfaces.md#slash-command)), cron 전달 등 부가 기능

`gateway/run.py`는 무려 24,000줄이 넘는 가장 큰 파일 중 하나입니다. `AGENTS.md`가
이 god-file을 믹스인으로 쪼개는 작업을 "원하는 일"로 명시합니다.

---

## 2. GatewayRunner — 생명주기 관리자

[`gateway/run.py` 1-14행](../gateway/run.py#L1-L14)
```
Gateway runner - entry point for messaging platform integrations.
- start_gateway(): Start all configured platform adapters
- GatewayRunner: Main class managing the gateway lifecycle
```
(`gateway/run.py` 1-14행)

`GatewayRunner`는 여러 믹스인을 상속해 관심사를 분리합니다.
[`gateway/run.py` 3249행](../gateway/run.py#L3249)
```python
class GatewayRunner(GatewayAuthorizationMixin, GatewayKanbanWatchersMixin, GatewaySlashCommandsMixin):
```
(`gateway/run.py` 3249행)

- `GatewayAuthorizationMixin` — 누가 이 봇에게 말을 걸 수 있는지 인가.
- `GatewayKanbanWatchersMixin` — kanban 보드 감시(멀티 에이전트 조율, [10](10_subsystems.md)).
- `GatewaySlashCommandsMixin` — `/stop` 등 슬래시 명령 처리.

또한 `run.py` 첫 import가 `hermes_bootstrap`(18-25행)인 것도 [03](03_entrypoints.md)의
CLI와 동일한 이유(Windows UTF-8 stdio, 부분 업데이트 복원)입니다. 종료 시
`atexit`로 PID 파일 제거와 런타임 락 해제를 등록합니다(23909-23910행).

---

## 3. 세션 관리와 자동 이어가기(auto-continue)

`gateway/session.py`가 "메시지가 어디서 왔고, 이걸 어느 대화에 붙일지"를 관리합니다.
[`gateway/session.py` 1-9행](../gateway/session.py#L1-L9)
```
Session management for the gateway.
- Session context tracking (where messages come from)
- Session storage (conversations persisted to disk)
- Reset policy evaluation (when to start fresh)
- Dynamic system prompt injection (agent knows its context)
```
(`gateway/session.py` 1-9행)

핵심 개념: **자동 이어가기 신선도 창(auto-continue freshness window)**.
[`gateway/session.py` 31-37행](../gateway/session.py#L31-L37)
```python
_AUTO_CONTINUE_FRESHNESS_SECS_DEFAULT = 60 * 60   # 1시간
```
(`gateway/session.py` 31-37행) — 게이트웨이가 재시작으로 중단됐을 때, 그 세션은
**마지막 `resume_pending` 시점으로부터 1시간 안에서만** 자동으로 이어집니다.
너무 오래된 세션을 자동 재개하면 사용자가 이미 잊은 옛 맥락으로 응답하는 혼란이
생기므로, 신선도 창으로 "최근 것만" 이어갑니다. 이 값은 `config.yaml`의
`agent.gateway_auto_continue_freshness`를 `run.py`가 환경변수
`HERMES_AUTO_CONTINUE_FRESHNESS`로 브리지해서 설정합니다(34-36행 주석).

> **연결:** 세션 자체는 [06](06_state.md)의 SQLite ([용어사전](../dict/06_state_retrieval.md#sqlite))에 저장됩니다. 게이트웨이는 그
> 위에서 "언제 이어가고 언제 새로 시작할지" 정책만 얹습니다.

---

## 4. 전달(delivery) 라우팅

`gateway/delivery.py`는 응답과 cron 작업 결과를 **어디로 보낼지** 결정합니다.
[`gateway/delivery.py` 1-9행](../gateway/delivery.py#L1-L9)
```
Delivery routing for cron job outputs and agent responses.
Routes messages based on:
- Explicit targets (e.g., "telegram:123456789")
- Platform home channels (e.g., "telegram" → home channel)
- Origin (back to where the job was created)
- Local (always saved to files)
```
(`gateway/delivery.py` 1-9행)

- **명시 타깃 > 홈 채널 > 발생 위치 > 로컬** 순서로 목적지를 정합니다.
- `MAX_PLATFORM_OUTPUT = 4000`(29행): 긴 출력을 자동 분할하지 않는 플랫폼을 위해
  게이트웨이 레벨에서 자르는 한도. Telegram의 하드 한도(4096)에 여유를 둔 값이며,
  자체 분할(`splits_long_messages`)을 지원하는 어댑터는 이 자르기를 우회합니다.
- `_SILENCE_NARRATION`(36행): 에이전트가 "(silent)" 같은 "침묵" 표현만 냈을 때를
  정규식으로 감지해, 굳이 빈 메시지를 플랫폼에 보내지 않도록 합니다.

---

## 5. 플랫폼 어댑터와 자기등록 레지스트리

각 플랫폼은 `gateway/platforms/` 아래 어댑터로 구현됩니다(signal, whatsapp,
whatsapp_cloud, weixin, webhook, api_server, bluebubbles, yuanbao, qqbot,
msgraph 등). Telegram/Discord/Slack 같은 대형 플랫폼과 다수의 플러그인 플랫폼은
**레지스트리를 통해 자기등록**됩니다.

[`gateway/platform_registry.py` 1-29행](../gateway/platform_registry.py#L1-L29)
(`gateway/platform_registry.py` 1-29행) — [05](05_tools.md)의 도구 레지스트리와
매우 닮은 패턴입니다: 어댑터가 `platform_registry.register(PlatformEntry(...))`로
자기 자신을 등록하면, 게이트웨이는 하드코딩된 if/elif 없이 이를 발견해 인스턴스화
합니다(4-10행). 플러그인 어댑터가 먼저 조회되고, 없으면 내장(built-in) 경로로
폴백합니다.

`PlatformEntry`(38행~)의 필드:
- `name`/`label` — config에서 쓰는 식별자 / 사람이 읽는 이름.
- `adapter_factory`(48-51행) — 클래스가 아니라 **팩토리 함수**. 플러그인이 커스텀
  초기화(추가 kwargs, try/except 래핑)를 할 수 있게 합니다.
- `check_fn`(53-54행) — 의존성이 준비됐는지.
- `validate_config`/`required_env`/`install_hint` — 설정 검증/필수 환경변수/설치 힌트.

---

## 6. 새 플랫폼 추가하기 — 플러그인 vs 코어

`gateway/platforms/ADDING_A_PLATFORM.md`가 두 경로를 안내합니다.
[`gateway/platforms/ADDING_A_PLATFORM.md` 1-16행](../gateway/platforms/ADDING_A_PLATFORM.md#L1-L16)

- **플러그인 경로(권장)**(5-15행): `~/.hermes/plugins/`(또는 `plugins/platforms/`)에
  `plugin.yaml` + `adapter.py`를 만들고, `BasePlatformAdapter`를 상속해
  `register(ctx)`에서 `ctx.register_platform()`으로 등록합니다. **코어 코드 변경이
  전혀 필요 없습니다(zero changes to core).** 플러그인 시스템이 어댑터 생성, 설정
  파싱, 인가, cron 전달, 메시지 전송 라우팅, 시스템 프롬프트 ([용어사전](../dict/01_llm_basics.md#system-prompt)) 힌트, 상태 표시를
  자동으로 처리합니다.
- **내장 경로(코어 기여자 전용)**(78행~): 코어에 직접 통합. 체크리스트가 길고,
  `AGENTS.md`의 "좁은 허리" 철학상 특별한 이유가 없으면 플러그인 경로를 씁니다.

문서에는 플랫폼별 UX 세부(LINE의 60초 단발성 응답 토큰, WhatsApp의 24시간 세션
창 등)를 다루는 서브클래싱 패턴(44-53행)과, 한 플랫폼이 두 전송 방식을 가질 때
행위 믹스인을 공유하는 패턴(WhatsApp Baileys vs Cloud API, 55-69행)까지
설명되어 있어, "가장자리에서 확장"이 실제로 어떻게 이뤄지는지 잘 보여줍니다.

---

## 정리 — 스스로 점검 질문

**핵심 요약**
- 게이트웨이는 여러 메신저 플랫폼을 하나의 에이전트 코어에 잇는 계층이다(`gateway/run.py`의 `GatewayRunner`).
- 플랫폼별 차이는 어댑터(`gateway/platforms/*`)가 흡수하고, 어댑터는 도구처럼 자기 등록된다.
- 세션 관리(session.py)는 "같은 사용자의 이어지는 대화"를 유지하고, delivery.py는 응답을 올바른 플랫폼·채팅방으로 라우팅한다.
- 새 플랫폼은 코어 수정 없이 어댑터 한 파일(+플러그인)로 추가할 수 있다(`ADDING_A_PLATFORM.md`).

**점검 질문**
1. 텔레그램 메시지 하나가 에이전트 응답으로 돌아오기까지의 경로를 순서대로 나열할 수 있는가?
2. 어댑터 패턴이 없다면(플랫폼별 if문으로 처리한다면) 무엇이 나빠질까?
3. 세션 자동 이어가기(auto-continue)는 어떤 사용자 경험 문제를 푸는가?
4. 새 플랫폼을 추가할 때 코어를 건드리지 않아도 되는 이유는? (힌트: 자기 등록 레지스트리)

다음 문서에서는 Hermes가 경험에서 스스로 배우는 **자기개선 루프**를 봅니다.
→ [09_self_improvement.md](09_self_improvement.md)
