# 배경기술 08. Chrome DevTools Protocol (CDP) 기반 브라우저 제어

## 이 문서에서 다루는 큰 맥락

에이전트가 실제 웹 브라우저를 조작하는 기반 기술인 **CDP**를 다룹니다.

### 소목차
- [1. 개념](#1-개념)
- [2. 히스토리](#2-히스토리)
- [3. 동향과 트레이드오프](#3-동향과-트레이드오프)
- [4. 이 저장소에서의 구현 연결](#4-이-저장소에서의-구현-연결)

---

## 1. 개념

- **CDP(Chrome DevTools Protocol)**: 크롬/크로미움 브라우저를 프로그램으로 제어·검사
  하기 위한 프로토콜. 브라우저가 여는 WebSocket 엔드포인트에 JSON 명령을 보내면
  탐색·클릭·DOM 읽기·스크린샷·네트워크 제어 등을 할 수 있습니다.
- 크롬 개발자도구(F12)가 바로 이 프로토콜 위에서 돕니다. Puppeteer, Playwright 같은
  자동화 라이브러리도 내부적으로 CDP(또는 유사 프로토콜)를 씁니다.

## 2. 히스토리

- 웹 자동화는 오래전 Selenium/WebDriver로 시작했지만, 무겁고 느린 면이 있었습니다.
- CDP가 공개되며 Puppeteer(2017)·Playwright 같은 고속·저수준 제어 도구가 등장했고,
  헤드리스(headless) 브라우저 자동화가 보편화됐습니다.
- LLM 에이전트 시대에는 "모델이 웹페이지를 보고 조작"하게 하려고, 접근성 트리
  (accessibility tree) 스냅샷을 모델에게 주고 좌표 대신 요소 참조로 상호작용하는
  방식이 자리잡았습니다.

## 3. 동향과 트레이드오프

- **접근성 트리 기반 조작**: 픽셀 좌표보다 안정적이라 널리 쓰입니다.
- **클라우드 브라우저**: Browserbase, Browser Use 등 원격 브라우저 서비스로 확장성과
  격리를 얻는 흐름.
- 트레이드오프: 저수준 CDP 직접 제어는 강력하지만 위험합니다(임의 명령으로 쿠키·
  스토리지 접근). 그래서 안전한 고수준 도구를 기본으로 두고, CDP 직결은 **탈출구
  (escape hatch)** 로 제한적으로 노출하는 것이 실무 패턴입니다.

## 4. 이 저장소에서의 구현 연결

[05_tools.md](../05_tools.md)의 브라우저 도구가 여기에 해당합니다.

- **고수준 브라우저 도구**: `tools/browser_tool.py`가 로컬 크로미움/Browserbase/
  Browser Use를 동일한 인터페이스로 노출하고, 접근성 트리(`ariaSnapshot`)와 ref
  선택자로 조작합니다([05] 참조).
- **저수준 CDP 탈출구**: `tools/browser_cdp_tool.py`가 단일 도구 `browser_cdp`로
  임의 CDP 명령을 전달합니다.
  <ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/tools/browser_cdp_tool.py" lines="2-16" />
  - CDP URL은 `/browser connect`(→ `BROWSER_CDP_URL`) 또는 `config.yaml`의
    `browser.cdp_url`, 또는 CDP 기반 클라우드 세션에서 옵니다(6-9행).
  - 네이티브 다이얼로그, iframe 범위 평가, 쿠키/네트워크 제어, 저수준 탭 관리 등
    고수준 도구가 못 다루는 경우의 **탈출구**입니다(11-14행).
- **안전 장치**: `_CDP_PRIVATE_PAGE_ALLOWED_METHODS`(31행~)처럼 차단된 페이지에서도
  페이지 본문/쿠키/DOM/스토리지를 읽지 않는 검사(inspection) 메서드만 허용해, 저수준
  힘을 신중히 통제합니다. 이는 3절의 "escape hatch는 제한적으로"라는 원칙의 실제
  구현입니다.
