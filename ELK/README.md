# ELK (Elastic Stack) 9.x + APM — Docker Compose

## 🔧 目的
建立一個用於本地測試的 Elastic Stack 9.x Compose 環境，包含：Elasticsearch、Kibana、APM Server、Logstash。

## 🚀 快速開始
1. 複製範例 env 並設定密碼：

```bash
cp .env.example .env
# 編輯 .env，將 ELASTIC_PASSWORD 設為安全的密碼
```

2. 啟動服務：

```bash
docker compose up -d
```

3. 開啟 Kibana： http://localhost:5601
   - **首次啟動**：請等待 2-3 分鐘讓 Kibana 完成初始化
   - **登入帳號**：`elastic`
   - **登入密碼**：`.env` 中的 `ELASTIC_PASSWORD` (預設為 `changeme`)
  - `kibana_system` 是 Kibana 用來連 Elasticsearch 的內部帳號，**不是**拿來登入 Kibana UI。
   - APM UI 在 Kibana 的 **Observability > APM** 頁面。

## 📡 測試 APM Server (簡易 curl 範例)
向 APM 送一個最簡單的事件：

1. 建立 `apm-test.json` 檔案：

```json
{"metadata":{"service":{"name":"demo-service","agent":{"name":"demo-agent","version":"1.0.0"}}}}
{"transaction":{"name":"test","duration":100,"trace_id":"01234567890123456789012345678901","id":"0123456789abcdef","type":"request","span_count":{"started":0,"dropped":0}}}
```

2. 使用 curl 發送請求：

```bash
curl.exe -v -X POST "http://localhost:8200/intake/v2/events" \
  -H "Content-Type: application/x-ndjson" \
  --data-binary @apm-test.json
```

（如 apm-server 設有 `secret_token`，請加上 `Authorization: Bearer <token>`）

## 🛡️ 安全性提醒
- 此範例為方便本地測試而簡化，**請勿**在生產環境使用預設密碼。
- 在生產應用中：使用安全的憑證、不要在 repo 中明文保存密碼、並限制網路存取。

## 🧩 可客製化項目
- 調整 `ES_JAVA_OPTS` 以配置 JVM
- 加入 Filebeat / Metricbeat container 來模擬和收集日誌/指標

---
如果你要我幫你：
- 把這個堆疊加上 Filebeat 範例配置，或
- 幫你示範用一個簡單的 Node/Python 應用送 APM 事件，
我可以接著做。 ✅
