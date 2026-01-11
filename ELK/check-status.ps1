# Check ELK Stack Status
Write-Host "=== Container Status ===" -ForegroundColor Cyan
docker compose ps

Write-Host "`n=== Elasticsearch Health ===" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9200/_cluster/health" -Headers @{Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("elastic:changeme"))} -UseBasicParsing
    $response.Content | ConvertFrom-Json | Format-List
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host "`n=== Kibana Status ===" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5601/api/status" -UseBasicParsing -TimeoutSec 5
    Write-Host "Kibana is responding!" -ForegroundColor Green
} catch {
    Write-Host "Kibana not responding: $_" -ForegroundColor Red
}

Write-Host "`n=== Recent Kibana Logs ===" -ForegroundColor Cyan
docker logs kibana --tail 30
