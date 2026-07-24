# 배경기술 07. Honcho 변증법적(dialectic) 사용자 모델링

## 이 문서에서 다루는 큰 맥락

에이전트가 사용자를 **이해하고 개인화**하기 위한 사용자 모델링, 특히 Honcho의
변증법적(dialectic) 접근을 다룹니다.

### 소목차
- [1. 개념](#1-개념)
- [2. 히스토리와 배경](#2-히스토리와-배경)
- [3. 동향과 트레이드오프](#3-동향과-트레이드오프)
- [4. 이 저장소에서의 구현 연결](#4-이-저장소에서의-구현-연결)

---

## 1. 개념

- **사용자 모델링(user modeling)**: 대화 이력으로부터 "이 사용자는 누구이고 무엇을
  선호하는가"에 대한 표상을 만들어 응답을 개인화하는 것.
- **Honcho**: 에이전트에 장기 기억과 사용자 표상을 제공하는 오픈 프로젝트(Plastic
  Labs). 단순히 사실을 저장하는 것을 넘어, 사용자에 대한 **추론(inference)** 을
  뽑아내려 합니다.
- **변증법적(dialectic)**: "질문 ↔ 근거" 대화를 통해 결론을 다듬는 방식. Honcho에서는
  "사용자에 대한 자연어 질문"을 던지면, 축적된 대화 근거로부터 답(추론)을 합성해
  돌려줍니다. 즉 고정된 프로필 필드가 아니라 **질의 시점에 근거로부터 추론**합니다.

## 2. 히스토리와 배경

- 초기 개인화는 명시적 프로필 폼(이름/언어 등)에 의존했습니다. 대화에서 자연스럽게
  드러나는 미묘한 취향은 담기 어려웠습니다.
- 이후 대화 로그에서 사실/선호를 자동 추출·요약하는 메모리 시스템이 등장했고,
  Honcho는 여기서 한 걸음 더 나아가 "필요할 때 근거로부터 사용자에 대한 답을
  합성"하는 dialectic API를 제시했습니다.

## 3. 동향과 트레이드오프

- 장점: 정적 필드로는 못 담는 함축적 선호를 포착, 질의 기반이라 유연.
- 트레이드오프: 추론은 틀릴 수 있고(환각), 외부 서비스 의존 시 지연·프라이버시·비용
  고려가 필요합니다. 그래서 **기본 내장이 아니라 플러그인/옵트인**으로 두는 것이
  합리적입니다.

## 4. 이 저장소에서의 구현 연결

- Hermes의 메모리는 [09_self_improvement.md](../09_self_improvement.md)의
  `agent/memory_manager.py`가 오케스트레이션합니다. 기본은 `MEMORY.md`/`USER.md`
  파일 기반이고, **외부 provider는 한 번에 하나만** 허용됩니다(6-8행) — 스키마 비대와
  백엔드 충돌 방지.
- **Honcho는 플러그인으로 제공**됩니다: `plugins/memory/` 아래 provider로 붙습니다
  (`AGENTS.md`의 Project Structure가 `plugins/memory/ (honcho, mem0, supermemory, ...)`
  로 명시). 이는 Footprint Ladder의 "3번 service-gated / 4번 plugin" 위치와 일치합니다
  — 강력하지만 모두에게 필수는 아니므로 코어가 아니라 가장자리에 둡니다.
- 메모리 provider는 `MemoryProvider`(`agent/memory_provider.py`) 인터페이스를 구현하며,
  매니저가 시스템 프롬프트 주입(`build_system_prompt`)·턴 전 prefetch·턴 후 sync를
  표준 훅으로 호출합니다([09] 5절). Honcho 같은 dialectic provider도 이 훅 위에서
  "질의→추론"을 수행합니다.
- provider 컨텍스트는 egress 경계에서 살균됩니다(`context_engine.sanitize_memory_context`,
  [07_prompt_context.md](../07_prompt_context.md)) — 외부로 나가는 사용자 데이터의
  민감정보를 가립니다.

## 더 읽어보기 (공식 자료)

- Honcho 프로젝트: <https://honcho.dev/> (Plastic Labs)
