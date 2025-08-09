-- 添加: FishAudio语音合成 供应器
delete from `ai_model_provider` where id = 'SYSTEM_TTS_FishAudioTTS';
INSERT INTO `ai_model_provider` (`id`, `model_type`, `provider_code`, `name`, `fields`, `sort`, `creator`, `create_date`, `updater`, `update_date`) VALUES
('SYSTEM_TTS_FishAudioTTS', 'TTS', 'fishaudio', 'FishAudio语音合成', '[{"key":"api_key","label":"API Key","type":"string"},{"key":"format","label":"音频格式","type":"string"},{"key":"output_dir","label":"输出目录","type":"string"},{"key":"voice","label":"音色编码","type":"string"}]', 1, 1, NOW(), 1, NOW());
-- 添加: FishAudio语音合成 配置
delete from `ai_model_config` where id = 'TTS_FishAudioTTS';
INSERT INTO `ai_model_config` VALUES ('TTS_FishAudioTTS', 'TTS', 'TTS_FishAudioTTS', 'FishAudio语音合成', 1, 1, '{\"type\": \"fishaudio\", \"api_key\": \"\", \"format\": \"mp3\", \"output_dir\": \"tmp/\", \"voice\": \"5f07dc5cac6344f59d17f1b4855aa640\"}', NULL, NULL, 0, NULL, NULL, NULL, NULL);
-- 添加FishAudio语音合成音色
delete from `ai_tts_voice` where id = 'TTS_FishAudioTTS0001';
INSERT INTO `ai_tts_voice` VALUES ('TTS_FishAudioTTS0001', 'TTS_FishAudioTTS', '山田凉', '5f07dc5cac6344f59d17f1b4855aa640', '日文', 'https://platform.r2.fish.audio/task/bfa37d2fb2174cec81f167088f057b07.mp3', NULL, 1, NULL, NULL, NULL, NULL);

-- 初始化山田凉智能体模板数据
DELETE FROM `ai_agent_template` where agent_name = '山田凉';
INSERT INTO `ai_agent_template` VALUES ('7406648b5cc5fde1b8aa335b6f8b4f7h', '小智', '山田凉', 'ASR_FunASR', 'VAD_SileroVAD', 'LLM_ChatGLMLLM', 'TTS_FishAudioTTS', '山田凉', 'Memory_nomem', 'Intent_function_call', 
'[角色设定]
我是一个来自日本的女生, 叫做山田凉。（可自由设定）
[核心特征]
总是用日语回复, 仅回复日语。
[讲话腔调]
讲话超级可爱腔。', 'ja', '日文', 1,  NULL, NULL, NULL, NULL);
