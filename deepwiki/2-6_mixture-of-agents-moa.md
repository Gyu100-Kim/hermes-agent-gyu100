# Mixture-of-Agents (MoA)

<details>
<summary>Relevant source files</summary>

The following files were used as context for generating this wiki page:

- [agent/moa_loop.py](../agent/moa_loop.py)
- [apps/desktop/src/app/settings/model-settings.test.tsx](../apps/desktop/src/app/settings/model-settings.test.tsx)
- [apps/desktop/src/app/settings/model-settings.tsx](../apps/desktop/src/app/settings/model-settings.tsx)
- [apps/desktop/src/hermes.ts](../apps/desktop/src/hermes.ts)
- [apps/desktop/src/types/hermes.ts](../apps/desktop/src/types/hermes.ts)
- contributors/emails/sjq15251852316@gmail.com
- [hermes_cli/moa_cmd.py](../hermes_cli/moa_cmd.py)
- [hermes_cli/moa_config.py](../hermes_cli/moa_config.py)
- [hermes_cli/web_server.py](../hermes_cli/web_server.py)
- [tests/cli/test_moa_command.py](../tests/cli/test_moa_command.py)
- [tests/hermes_cli/test_gateway_runtime_health.py](../tests/hermes_cli/test_gateway_runtime_health.py)
- [tests/hermes_cli/test_moa_config.py](../tests/hermes_cli/test_moa_config.py)
- [tests/hermes_cli/test_web_server.py](../tests/hermes_cli/test_web_server.py)
- [tests/hermes_cli/test_web_server_messaging_profiles.py](../tests/hermes_cli/test_web_server_messaging_profiles.py)
- [tests/hermes_cli/test_web_server_profile_unification.py](../tests/hermes_cli/test_web_server_profile_unification.py)
- [tests/hermes_cli/test_whatsapp_onboarding.py](../tests/hermes_cli/test_whatsapp_onboarding.py)
- [tests/run_agent/test_moa_fanout_cadence.py](../tests/run_agent/test_moa_fanout_cadence.py)
- [tests/run_agent/test_moa_loop_mode.py](../tests/run_agent/test_moa_loop_mode.py)
- [web/src/lib/api.ts](../web/src/lib/api.ts)
- [web/src/pages/ChannelsPage.tsx](../web/src/pages/ChannelsPage.tsx)
- [web/src/pages/ModelsPage.tsx](../web/src/pages/ModelsPage.tsx)
- [website/docs/user-guide/features/mixture-of-agents.md](../website/docs/user-guide/features/mixture-of-agents.md)

</details>



The Mixture-of-Agents (MoA) system in Hermes is a virtual provider architecture that allows the agent to consult multiple "advisor" (reference) models before an "aggregator" model makes a final decision or executes a tool. Unlike standard model providers, MoA is an orchestration layer that manages parallel LLM fan-outs and guidance injection within the `AIAgent` conversation loop.

## Architecture & Virtual Provider Model

MoA is implemented as a "virtual provider" ([agent/moa_loop.py:3-7](../agent/moa_loop.py#L3-L7)). When the `provider` is set to `moa`, the `AIAgent` does not connect to a remote MoA API; instead, it uses a `MoAClient` facade that intercepts chat completion requests and orchestrates the MoA loop ([tests/run_agent/test_moa_loop_mode.py:44-48](../tests/run_agent/test_moa_loop_mode.py#L44-L48), [tests/run_agent/test_moa_loop_mode.py:75-82](../tests/run_agent/test_moa_loop_mode.py#L75-L82)).

### Data Flow: The MoA Turn

1.  **Reference Fan-out**: The system identifies the active MoA preset and calls all configured `reference_models` in parallel using a `ThreadPoolExecutor` ([agent/moa_loop.py:154-160](../agent/moa_loop.py#L154-L160)).
2.  **Guidance Assembly**: The outputs from these models are collected, optionally redacted for privacy, and formatted into a guidance block ([agent/moa_loop.py:221-224](../agent/moa_loop.py#L221-L224)).
3.  **Aggregator Invocation**: The `aggregator` model is called. It receives the original conversation context plus the injected guidance from the advisors ([website/docs/user-guide/features/mixture-of-agents.md:52-60](../website/docs/user-guide/features/mixture-of-agents.md#L52-L60)).
4.  **Tool Execution**: The aggregator acts as the "actor," emitting tool calls which are executed by the `AIAgent` normally ([agent/moa_loop.py:3-7](../agent/moa_loop.py#L3-L7)).

### Code Entity Map: MoA Virtualization
The following diagram illustrates how the `moa` provider string maps to internal runtime classes and configuration entities.

Title: MoA Runtime Entity Mapping
```mermaid
graph TD
    subgraph "Natural Language / CLI Space"
        "User Command"["/model review --provider moa"]
        "Preset Name"["'review'"]
    end

    subgraph "Code Entity Space (agent/)"
        "AIAgent"["AIAgent Class"]
        "MoAClient"["MoAClient (Facade)"]
        "MoALoop"["agent.moa_loop.py"]
        "MoAConfig"["hermes_cli.moa_config.py"]
    end

    subgraph "Configuration Space"
        "ConfigYAML"["config.yaml: moa.presets"]
    end

    "User Command" --> "AIAgent"
    "AIAgent" -- "resolve_runtime_provider" --> "MoAClient"
    "MoAClient" -- "orchestrates" --> "MoALoop"
    "MoALoop" -- "reads" --> "MoAConfig"
    "MoAConfig" -- "loads" --> "ConfigYAML"
    "MoALoop" -- "Parallel Call" --> "RefModels"["Reference Models (Advisors)"]
    "MoALoop" -- "Final Call" --> "Aggregator"["Aggregator Model (Actor)"]
```
Sources: [agent/moa_loop.py:1-22](../agent/moa_loop.py#L1-L22), [tests/run_agent/test_moa_loop_mode.py:75-82](../tests/run_agent/test_moa_loop_mode.py#L75-L82), [hermes_cli/moa_config.py:1-12](../hermes_cli/moa_config.py#L1-L12)

## Fan-out Cadence & Guidance Injection

MoA supports three distinct cadences for advisor invocation, configured via the `fanout` parameter ([hermes_cli/moa_config.py:104-115](../hermes_cli/moa_config.py#L104-L115)):

| Cadence | Description | Latency/Cost Impact |
| :--- | :--- | :--- |
| `user_turn` | Advisors run only once at the start of a user message. | Lowest; advice may become stale during long tool chains. |
| `per_iteration` | Advisors run before every aggregator call (every tool step). | Highest; advice is always fresh. |
| `every_n:N` | Advisors run at the start and then every N iterations. | Balanced; uses cached guidance for intermediate steps. |

### Guidance Injection Mechanism
Advisors are called without tool schemas to reduce context overhead and prevent them from attempting to call tools themselves ([website/docs/user-guide/features/mixture-of-agents.md:55-56](../website/docs/user-guide/features/mixture-of-agents.md#L55-L56)). Their output is injected into the aggregator's prompt as a specialized context block.

Sources: [hermes_cli/moa_config.py:104-136](../hermes_cli/moa_config.py#L104-L136), [website/docs/user-guide/features/mixture-of-agents.md:135-154](../website/docs/user-guide/features/mixture-of-agents.md#L135-L154)

## Usage Accounting & Privacy

MoA maintains strict accounting for the heterogeneous models involved in a single turn.

### Token & Cost Tracking
Because advisors may use different providers (e.g., OpenAI) than the aggregator (e.g., Anthropic), MoA uses `_RefAccounting` objects to track tokens and USD costs per model ([agent/moa_loop.py:163-171](../agent/moa_loop.py#L163-L171)). These are aggregated into the final session usage to ensure accurate billing and rate-limit tracking ([agent/moa_loop.py:168-171](../agent/moa_loop.py#L168-L171)).

### Privacy Filtering
The `moa.privacy_filter` setting controls the redaction of PII (emails, phone numbers) and secrets from advisor outputs ([agent/moa_loop.py:24-35](../agent/moa_loop.py#L24-L35)):
- `display`: Redacts text shown in the UI and saved traces.
- `full`: Additionally redacts text before it is passed to the aggregator ([hermes_cli/moa_config.py:139-152](../hermes_cli/moa_config.py#L139-L152)).

Sources: [agent/moa_loop.py:163-172](../agent/moa_loop.py#L163-L172), [agent/moa_loop.py:45-53](../agent/moa_loop.py#L45-L53), [hermes_cli/moa_config.py:139-162](../hermes_cli/moa_config.py#L139-L162)

## Configuration & Management

MoA configuration is managed through `config.yaml` or via the Web Dashboard/Desktop UI.

### Preset Structure
A preset defines the ensemble of models and their sampling parameters:
- `reference_models`: A list of slots containing `provider`, `model`, and optional `reasoning_effort` ([hermes_cli/moa_config.py:14-17](../hermes_cli/moa_config.py#L14-L17), [hermes_cli/moa_config.py:194-200](../hermes_cli/moa_config.py#L194-L200)).
- `aggregator`: The acting model slot ([hermes_cli/moa_config.py:19-22](../hermes_cli/moa_config.py#L19-L22)).
- `reference_max_tokens`: Caps advisor output length to reduce latency ([website/docs/user-guide/features/mixture-of-agents.md:103-110](../website/docs/user-guide/features/mixture-of-agents.md#L103-L110)).

### Management Interfaces
- **CLI**: `hermes moa configure` provides a terminal-based setup.
- **Web/Desktop**: The `ModelSettings` component in the dashboard allows visual editing of presets, validating that both provider and model are selected before saving ([apps/desktop/src/app/settings/model-settings.tsx:137-150](../apps/desktop/src/app/settings/model-settings.tsx#L137-L150)).

Title: MoA Configuration and UI Flow
```mermaid
graph LR
    subgraph "UI Layer"
        "Dashboard"["web/src/pages/ModelsPage.tsx"]
        "DesktopSettings"["apps/desktop/src/app/settings/model-settings.tsx"]
    end

    subgraph "API Layer (FastAPI)"
        "MoAEndpoints"["/api/model/moa"]
    end

    subgraph "Logic Layer"
        "MoAConfigUtil"["hermes_cli.moa_config.py"]
    end

    "Dashboard" -- "GET/POST" --> "MoAEndpoints"
    "DesktopSettings" -- "GET/POST" --> "MoAEndpoints"
    "MoAEndpoints" -- "calls" --> "MoAConfigUtil"
    "MoAConfigUtil" -- "writes" --> "ConfigYAML"["config.yaml"]
```
Sources: [apps/desktop/src/app/settings/model-settings.tsx:12-25](../apps/desktop/src/app/settings/model-settings.tsx#L12-L25), [web/src/pages/ModelsPage.tsx:52-65](../web/src/pages/ModelsPage.tsx#L52-L65), [hermes_cli/web_server.py:80-82](../hermes_cli/web_server.py#L80-L82)

---
