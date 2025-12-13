#!/powershell
# Script pour appliquer automatiquement les corrections à GOOD

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Application des Corrections - GOOD" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$basePath = "C:\Users\ouali\Desktop\projectSSI\vulpy"

# ============= Correction 1: good/vulpy.py =============
Write-Host "📝 Correction 1: good/vulpy.py" -ForegroundColor Yellow
Write-Host "  Changing: debug=True → os.environ.get('FLASK_ENV')" -ForegroundColor Gray

$vulpyPath = "$basePath\good\vulpy.py"
$vulpyContent = Get-Content $vulpyPath -Raw

# Remplacer la ligne de debug
$vulpyContent = $vulpyContent -replace `
    'app\.run\(debug=True, host=''127\.0\.1\.1'', port=5001, extra_files=''csp\.txt''\)', `
    @"
# SECURITY FIX: Disable debug mode in production
# Debug mode exposes Werkzeug debugger allowing arbitrary code execution
if __name__ == '__main__':
    import os
    debug_mode = os.environ.get('FLASK_ENV') == 'development'
    app.run(debug=debug_mode, host='127.0.1.1', port=5001, extra_files='csp.txt')
"@

Set-Content -Path $vulpyPath -Value $vulpyContent
Write-Host "  ✓ good/vulpy.py corrigé" -ForegroundColor Green
Write-Host ""

# ============= Correction 2: good/vulpy-ssl.py =============
Write-Host "📝 Correction 2: good/vulpy-ssl.py" -ForegroundColor Yellow
Write-Host "  Changing: hardcoded /tmp → environment variables + secure paths" -ForegroundColor Gray

$vulpySslPath = "$basePath\good\vulpy-ssl.py"
$vulpySslContent = Get-Content $vulpySslPath -Raw

# Remplacer la ligne de debug SSL
$vulpySslContent = $vulpySslContent -replace `
    "app\.run\(debug=True, host='127\.0\.1\.1', ssl_context=\('/tmp/acme\.cert', '/tmp/acme\.key'\)\)", `
    @"
# SECURITY FIX #1: Disable debug mode in production
# Debug mode exposes Werkzeug debugger allowing arbitrary code execution
# SECURITY FIX #2: Use secure SSL certificate paths (not /tmp)
if __name__ == '__main__':
    import os
    debug_mode = os.environ.get('FLASK_ENV') == 'development'
    
    # Use environment variables for SSL paths instead of hardcoded /tmp
    cert_path = os.environ.get('SSL_CERT_PATH', '/etc/ssl/certs/server.crt')
    key_path = os.environ.get('SSL_KEY_PATH', '/etc/ssl/private/server.key')
    
    # Verify certificates exist before starting
    if not (os.path.exists(cert_path) and os.path.exists(key_path)):
        raise ValueError(f"SSL certificates not found at {cert_path} or {key_path}")
    
    app.run(
        debug=debug_mode,
        host='127.0.1.1',
        ssl_context=(cert_path, key_path)
    )
"@

Set-Content -Path $vulpySslPath -Value $vulpySslContent
Write-Host "  ✓ good/vulpy-ssl.py corrigé" -ForegroundColor Green
Write-Host ""

# ============= Commit les changements =============
Write-Host "📦 Commit des changements" -ForegroundColor Yellow
Push-Location $basePath

git add good/vulpy.py good/vulpy-ssl.py
git commit -m "PHASE 2 AFTER: Apply security corrections to GOOD"
git push origin master

Write-Host "  ✓ Changements committés et pushés" -ForegroundColor Green
Pop-Location

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "✅ Corrections appliquées avec succès!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Déclencher un nouveau build Jenkins" -ForegroundColor Gray
Write-Host "2. Attendre la fin du build" -ForegroundColor Gray
Write-Host "3. Télécharger les nouveaux rapports" -ForegroundColor Gray
Write-Host "4. Comparer avec la PHASE 1" -ForegroundColor Gray
Write-Host ""
