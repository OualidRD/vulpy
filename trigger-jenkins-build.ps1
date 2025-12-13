# Script pour déclencher un build Jenkins
# Usage: .\trigger-jenkins-build.ps1

$JENKINS_URL = "http://localhost:8081"
$JENKINS_USER = "admin"
$JENKINS_TOKEN = "11dc2e82e0aea6fc2ae17f975ecd6f3b"  # Remplacer par votre token API
$JOB_NAME = "vulpy-security-pipeline"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Déclenchement du build Jenkins..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# URL du trigger
$BUILD_URL = "$JENKINS_URL/job/$JOB_NAME/build"

# Créer l'en-tête d'authentification
$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${JENKINS_USER}:${JENKINS_TOKEN}"))

try {
    # Déclencher le build
    $response = Invoke-WebRequest -Uri $BUILD_URL `
        -Method POST `
        -Headers @{"Authorization" = "Basic $auth"} `
        -UseBasicParsing
    
    Write-Host "✓ Build déclenché avec succès!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Consultez le statut du build ici:" -ForegroundColor Yellow
    Write-Host "$JENKINS_URL/job/$JOB_NAME" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host "✗ Erreur lors du déclenchement du build:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
