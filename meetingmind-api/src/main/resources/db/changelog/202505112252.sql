-- 初始化南大校庆AI模板数据
DELETE FROM `ai_agent_template` where agent_name = '南大校庆';
INSERT INTO `ai_agent_template` VALUES ('2206648b5cc5fde1b8aa335b6f8b4f53', '小智', '南大校庆', 'ASR_FunASR', 'VAD_SileroVAD', 'LLM_FastgptLLM', 'TTS_EdgeTTS', 'TTS_EdgeTTS0006', 'Memory_nomem', 'Intent_intent_llm', 
'系统提示词不在这里设置。
请登录FastGPT部署网站设置: https://zciidbfg.sealosbja.site/app/detail?appId=681e0299308718ef7c4e670b', 
'zh', '中文', 1,  NULL, NULL, NULL, NULL);
