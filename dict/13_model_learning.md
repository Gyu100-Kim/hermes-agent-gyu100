# 용어 사전 — 모델 학습·적응

[⬆ 사전 전체 목차로](README.md)

이 문서는 분류(Content Class) **모델 학습·적응** 에 속한 용어 10개를 다룹니다.

- 설명 속 링크를 누르면 해당 용어 항목으로 이동합니다.
- **하위 개념** = 이 용어보다 더 **일반적인** 개념(먼저 알아두면 좋은 바탕 개념), **상위 개념** = 이 용어를 더 **특수화**한 개념(구체화·사례)입니다.
- 각 항목 끝의 "이 용어를 참조하는 항목"으로 원래 보던 곳으로 되돌아갈 수 있습니다.

## 이 문서의 용어

- [사전학습](#pretraining)
- [파인튜닝 (FT)](#fine-tuning)
- [지시 튜닝](#instruction-tuning)
- [RLHF (인간 피드백 강화학습)](#rlhf)
- [PEFT (파라미터 효율 파인튜닝)](#peft)
- [LoRA](#lora)
- [지식 증류](#distillation)
- [양자화](#quantization)
- [오픈 웨이트 모델](#open-weights)
- [벤치마크 (평가)](#benchmark)

<a id="pretraining"></a>

### 사전학습

**영문**: Pre-training · **분류**: [모델 학습·적응](README.md#분류content-class)

방대한 일반 텍스트로 '다음 토큰 예측'을 학습시키는 [LLM](01_llm_basics.md#llm) 제작의 첫 단계. 언어·지식·추론의 기반 능력이 여기서 생깁니다. 이후 [파인튜닝](#fine-tuning)으로 용도에 맞게 다듬습니다.

> **예시**: GPT 계열의 'P'가 Pre-trained의 약자입니다. 수조 토큰의 웹 텍스트로 학습한 베이스 모델이 사전학습의 산출물입니다.

**하위 개념(더 일반)**: [LLM (대규모 언어 모델)](01_llm_basics.md#llm)

**상위 개념(더 특수)**: [파인튜닝 (FT)](#fine-tuning)

**관련 용어**: [파인튜닝 (FT)](#fine-tuning)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="fine-tuning"></a>

### 파인튜닝 (FT)

**영문**: Fine-Tuning · **분류**: [모델 학습·적응](README.md#분류content-class)

[사전학습](#pretraining)된 모델을 특정 목적의 데이터로 추가 학습시켜 동작을 바꾸는 것. 전체 파라미터를 갱신하는 full FT는 비용이 크기 때문에, 일부만 갱신하는 [PEFT](#peft)가 파인튜닝의 더 특수한(상위) 방법론으로 널리 쓰입니다.

> **예시**: 고객 상담 말투로 응답하도록 상담 대화 1만 건으로 추가 학습시키는 것이 파인튜닝입니다.

**하위 개념(더 일반)**: [사전학습](#pretraining)

**상위 개념(더 특수)**: [지식 증류](#distillation) · [지시 튜닝](#instruction-tuning) · [PEFT (파라미터 효율 파인튜닝)](#peft) · [RLHF (인간 피드백 강화학습)](#rlhf)

**관련 용어**: [PEFT (파라미터 효율 파인튜닝)](#peft) · [지시 튜닝](#instruction-tuning) · [RLHF (인간 피드백 강화학습)](#rlhf)

**이 용어를 참조하는 항목**: [사전학습](#pretraining)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="instruction-tuning"></a>

### 지시 튜닝

**영문**: Instruction Tuning · **분류**: [모델 학습·적응](README.md#분류content-class)

'지시 → 올바른 수행' 쌍으로 [파인튜닝](#fine-tuning)해, 모델이 명령을 따르는 조수처럼 행동하게 만드는 방법. 챗봇형 모델과 베이스 모델의 차이가 대부분 여기서 나옵니다.

> **예시**: "다음 글을 요약해줘" + 모범 요약 같은 데이터 수십만 건으로 학습시킵니다. Hermes가 쓰는 대화형 모델들은 모두 지시 튜닝을 거친 모델입니다.

**하위 개념(더 일반)**: [파인튜닝 (FT)](#fine-tuning)

**관련 용어**: [RLHF (인간 피드백 강화학습)](#rlhf) · [시스템 프롬프트](01_llm_basics.md#system-prompt)

**이 용어를 참조하는 항목**: [파인튜닝 (FT)](#fine-tuning) · [RLHF (인간 피드백 강화학습)](#rlhf)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="rlhf"></a>

### RLHF (인간 피드백 강화학습)

**영문**: RLHF · **분류**: [모델 학습·적응](README.md#분류content-class)

사람이 매긴 응답 선호도(A가 B보다 낫다)로 보상 모델을 만들고, 강화학습으로 모델이 선호되는 답을 내게 조정하는 [파인튜닝](#fine-tuning)의 상위 방법론. 유용성·무해성 정렬(alignment)의 표준 기법입니다.

> **예시**: ChatGPT(2022)가 RLHF로 정렬된 대표 사례입니다. 이후 DPO처럼 강화학습 없이 선호를 학습하는 더 특수한 변형들이 나왔습니다.

**하위 개념(더 일반)**: [파인튜닝 (FT)](#fine-tuning)

**관련 용어**: [지시 튜닝](#instruction-tuning)

**이 용어를 참조하는 항목**: [파인튜닝 (FT)](#fine-tuning) · [지시 튜닝](#instruction-tuning)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="peft"></a>

### PEFT (파라미터 효율 파인튜닝)

**영문**: Parameter-Efficient Fine-Tuning · **분류**: [모델 학습·적응](README.md#분류content-class)

모델 전체가 아니라 아주 적은 수의 파라미터만 학습해 [파인튜닝](#fine-tuning) 효과를 내는 방법론군. 메모리·비용을 수십 분의 1로 줄입니다. [LoRA](#lora)가 PEFT의 가장 대표적인 상위(더 특수한) 기법입니다.

> **예시**: 어댑터(Adapter), 프리픽스 튜닝(Prefix Tuning), [LoRA](#lora)가 모두 PEFT 계열입니다.

**하위 개념(더 일반)**: [파인튜닝 (FT)](#fine-tuning)

**상위 개념(더 특수)**: [LoRA](#lora)

**관련 용어**: [LoRA](#lora)

**이 용어를 참조하는 항목**: [파인튜닝 (FT)](#fine-tuning)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="lora"></a>

### LoRA

**영문**: Low-Rank Adaptation · **분류**: [모델 학습·적응](README.md#분류content-class)

원본 가중치는 얼려 두고, 저랭크(low-rank) 행렬 두 개(A×B)만 학습해 원본에 더하는 [PEFT](#peft) 기법(2021). 학습 파라미터가 전체의 1% 미만이라 소비자용 GPU에서도 파인튜닝이 가능해졌습니다.

> **예시**: 7B 모델 full FT에는 수백 GB 메모리가 필요하지만, LoRA는 수십 GB로 충분합니다. [양자화](#quantization)와 결합한 QLoRA는 더 특수한 상위 기법입니다.

**하위 개념(더 일반)**: [PEFT (파라미터 효율 파인튜닝)](#peft)

**관련 용어**: [양자화](#quantization)

**이 용어를 참조하는 항목**: [PEFT (파라미터 효율 파인튜닝)](#peft) · [양자화](#quantization)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="distillation"></a>

### 지식 증류

**영문**: Knowledge Distillation · **분류**: [모델 학습·적응](README.md#분류content-class)

큰 교사(teacher) 모델의 출력을 작은 학생(student) 모델이 흉내 내도록 학습시켜, 성능을 최대한 유지하며 크기를 줄이는 기법. 값싸고 빠른 [보조 모델](01_llm_basics.md#auxiliary-model)들이 흔히 이렇게 만들어집니다.

> **예시**: GPT-4급 모델의 답변으로 소형 모델을 학습시켜 요약 전용 경량 모델을 만드는 것이 증류입니다.

**하위 개념(더 일반)**: [파인튜닝 (FT)](#fine-tuning)

**관련 용어**: [보조 모델](01_llm_basics.md#auxiliary-model)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="quantization"></a>

### 양자화

**영문**: Quantization · **분류**: [모델 학습·적응](README.md#분류content-class)

가중치를 16비트 대신 8/4비트 정수로 표현해 모델 크기와 메모리를 줄이는 [추론](01_llm_basics.md#inference) 최적화. 약간의 품질 손실로 훨씬 작은 하드웨어에서 모델을 돌릴 수 있게 합니다.

> **예시**: 70B 모델(FP16, 약 140GB)을 4비트로 양자화하면 약 40GB로 줄어 단일 GPU에 올릴 수 있습니다.

**하위 개념(더 일반)**: [추론 (서빙)](01_llm_basics.md#inference)

**관련 용어**: [LoRA](#lora)

**이 용어를 참조하는 항목**: [추론 (서빙)](01_llm_basics.md#inference) · [LoRA](#lora)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="open-weights"></a>

### 오픈 웨이트 모델

**영문**: Open-Weights Model · **분류**: [모델 학습·적응](README.md#분류content-class)

가중치 파일이 공개되어 누구나 내려받아 자체 서버에서 돌릴 수 있는 모델. API로만 쓰는 폐쇄 모델과 달리 데이터가 외부로 나가지 않게 운영할 수 있습니다. Hermes는 [제공자](02_agent_core.md#provider) 추상화 덕분에 둘 다 같은 방식으로 사용합니다.

> **예시**: Llama, Qwen, 그리고 Hermes 프로젝트와 같은 Nous Research의 Hermes 모델 시리즈가 오픈 웨이트입니다.

**하위 개념(더 일반)**: [LLM (대규모 언어 모델)](01_llm_basics.md#llm)

**관련 용어**: [LLM 제공자](02_agent_core.md#provider) · [추론 (서빙)](01_llm_basics.md#inference)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="benchmark"></a>

### 벤치마크 (평가)

**영문**: Benchmark · **분류**: [모델 학습·적응](README.md#분류content-class)

모델·에이전트의 능력을 표준화된 문제 집합으로 측정하는 것. 에이전트 분야에서는 실제 GitHub 이슈를 고치게 하는 SWE-bench처럼 '작업 완수율'을 재는 벤치마크가 중요해졌습니다.

> **예시**: Hermes의 `batch_runner.py`·`mini_swe_runner.py` 같은 연구용 러너가 벤치마크 평가 실행에 쓰입니다.

**하위 개념(더 일반)**: [LLM (대규모 언어 모델)](01_llm_basics.md#llm)

**관련 용어**: [LLM 심판](02_agent_core.md#llm-as-judge) · [배치 러너](12_subsystems.md#batch-runner)

**이 용어를 참조하는 항목**: [트래젝토리 (실행 궤적)](12_subsystems.md#trajectory)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
