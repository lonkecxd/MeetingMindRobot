<h1 align="center">Meeting Mind Robot</h1>

<p align="center">

</p>

想看使用效果？请猛戳视频 🎥
<a href="showcase.mp4" target="_blank">
         <picture>
           <img alt="演示" src="docs/images/demo1.png" />
         </picture>
        </a>

---
## 功能清单 ✨

### 已实现 ✅

| 功能模块 | 描述 |
|---------|------|
| 通信协议 | 通过 WebSocket 实现数据交互 |
| 对话交互 | 支持唤醒对话、手动对话及实时打断。长时间无对话时自动休眠 |
| 意图识别 | 支持使用LLM意图识别、function call函数调用 |
| 工具调用 | 支持MCP工具调用，包括搜索，Rag，Dify Workflow等 |
| LLM 模块 | 支持灵活切换 LLM 模块，默认使用 ChatGLMLLM，也可选用阿里百炼、DeepSeek、Ollama 等接口 |
| TTS 模块 | 支持 EdgeTTS（默认）、火山引擎豆包 TTS 等多种 TTS 接口，满足语音合成需求 |
| 记忆功能 | 支持超长记忆、本地总结记忆、内存记忆 |
| 前端管理页面 | 提供Web管理界面，支持Agent管理、用户管理、系统配置等功能 |

### 正在开发 🚧
拟人化界面 🎥
<a href="showcase2.mp4" target="_blank">
         <picture>
           <img alt="拟人化界面" src="docs/images/demo1.png" />
         </picture>
        </a>
---

### LLM 语言模型

| 使用方式 | 支持平台 | 免费平台 |
|:---:|:---:|:---:|
| openai 接口调用 | 阿里百炼、火山引擎豆包、深度求索、智谱ChatGLM、Gemini | 智谱ChatGLM、Gemini |
| ollama 接口调用 | Ollama | - |
| dify 接口调用 | Dify | - |
| fastgpt 接口调用 | Fastgpt | - |
| coze 接口调用 | Coze | - |

实际上，任何支持 openai 接口调用的 LLM 均可接入使用。

---

### TTS 语音合成

| 使用方式 | 支持平台 | 免费平台 |
|:---:|:---:|:---:|
| 接口调用 | EdgeTTS、火山引擎豆包TTS、腾讯云、阿里云TTS、CosyVoiceSiliconflow、TTS302AI、CozeCnTTS、GizwitsTTS、ACGNTTS、OpenAITTS | EdgeTTS、CosyVoiceSiliconflow(部分) |
| 本地服务 | FishSpeech、GPT_SOVITS_V2、GPT_SOVITS_V3、MinimaxTTS | FishSpeech、GPT_SOVITS_V2、GPT_SOVITS_V3、MinimaxTTS |

---

### VAD 语音活动检测

| 类型  |   平台名称    | 使用方式 | 收费模式 | 备注 |
|:---:|:---------:|:----:|:----:|:--:|
| VAD | SileroVAD | 本地使用 |  免费  |    |

---

### ASR 语音识别

| 使用方式 | 支持平台 | 免费平台 |
|:---:|:---:|:---:|
| 本地使用 | FunASR、SherpaASR | FunASR、SherpaASR |
| 接口调用 | DoubaoASR | - |

---

### Memory 记忆存储

|   类型   |      平台名称       | 使用方式 |   收费模式    | 备注 |
|:------:|:---------------:|:----:|:---------:|:--:|
| Memory |     mem0ai      | 接口调用 | 1000次/月额度 |    |
| Memory | mem_local_short | 本地总结 |    免费     |    |

---

### Intent 意图识别

|   类型   |     平台名称      | 使用方式 |  收费模式   |          备注           |
|:------:|:-------------:|:----:|:-------:|:---------------------:|
| Intent |  intent_llm   | 接口调用 | 根据LLM收费 |    通过大模型识别意图，通用性强     |
| Intent | function_call | 接口调用 | 根据LLM收费 | 通过大模型函数调用完成意图，速度快，效果好 |

---
