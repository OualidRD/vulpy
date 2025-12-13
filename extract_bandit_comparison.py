#!/usr/bin/env python3
"""
Script pour extraire et comparer les vulnérabilités de Bandit HTML
"""

import re
from html.parser import HTMLParser

def extract_vulnerabilities_from_html(filename):
    """Extraire les vulnérabilités d'un fichier HTML Bandit"""
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Chercher toutes les vulnérabilités
    pattern = r'<strong>([^<]+)</strong>.*?Test ID:\s*([B\d]+).*?Severity:\s*([A-Z]+).*?File:\s*([^<\n]+)'
    matches = re.findall(pattern, content, re.DOTALL)
    
    vulns = []
    for match in matches:
        title, test_id, severity, file_path = match
        vulns.append({
            'title': title.strip(),
            'test_id': test_id.strip(),
            'severity': severity.strip(),
            'file': file_path.strip()
        })
    
    return vulns

def main():
    print("="*80)
    print("EXTRACTION DES VULNÉRABILITÉS BANDIT")
    print("="*80)
    
    # Extraire de BAD
    print("\n📋 Extraction de bandit-bad.html...")
    bad_vulns = extract_vulnerabilities_from_html('bandit-bad.html')
    print(f"✓ {len(bad_vulns)} vulnérabilités trouvées dans BAD")
    
    # Extraire de GOOD
    print("\n📋 Extraction de bandit-good.html...")
    good_vulns = extract_vulnerabilities_from_html('bandit-good.html')
    print(f"✓ {len(good_vulns)} vulnérabilités trouvées dans GOOD")
    
    # Analyse
    print("\n" + "="*80)
    print("ANALYSE COMPARATIVE")
    print("="*80)
    
    # Sévérités
    bad_severity = {}
    for v in bad_vulns:
        sev = v['severity']
        bad_severity[sev] = bad_severity.get(sev, 0) + 1
    
    good_severity = {}
    for v in good_vulns:
        sev = v['severity']
        good_severity[sev] = good_severity.get(sev, 0) + 1
    
    print("\nDistribution par sévérité:")
    print(f"{'Sévérité':<15} {'BAD':<10} {'GOOD':<10}")
    print("-" * 35)
    all_severities = set(list(bad_severity.keys()) + list(good_severity.keys()))
    for sev in sorted(all_severities):
        bad_count = bad_severity.get(sev, 0)
        good_count = good_severity.get(sev, 0)
        print(f"{sev:<15} {bad_count:<10} {good_count:<10}")
    
    print(f"{'TOTAL':<15} {len(bad_vulns):<10} {len(good_vulns):<10}")
    
    # Tests ID
    print("\n" + "="*80)
    print("VULNÉRABILITÉS UNIQUES PAR TEST ID")
    print("="*80)
    
    bad_tests = {}
    for v in bad_vulns:
        test_id = v['test_id']
        bad_tests[test_id] = bad_tests.get(test_id, 0) + 1
    
    good_tests = {}
    for v in good_vulns:
        test_id = v['test_id']
        good_tests[test_id] = good_tests.get(test_id, 0) + 1
    
    print(f"{'Test ID':<10} {'Titre':<35} {'BAD':<5} {'GOOD':<5}")
    print("-" * 55)
    all_tests = set(list(bad_tests.keys()) + list(good_tests.keys()))
    for test_id in sorted(all_tests):
        bad_count = bad_tests.get(test_id, 0)
        good_count = good_tests.get(test_id, 0)
        # Trouver le titre
        title = ""
        for v in bad_vulns:
            if v['test_id'] == test_id:
                title = v['title'][:35]
                break
        print(f"{test_id:<10} {title:<35} {bad_count:<5} {good_count:<5}")
    
    # Fichiers affectés
    print("\n" + "="*80)
    print("FICHIERS AFFECTÉS")
    print("="*80)
    
    bad_files = set([v['file'] for v in bad_vulns])
    good_files = set([v['file'] for v in good_vulns])
    
    print(f"\nFichiers dans BAD ({len(bad_files)}):")
    for f in sorted(bad_files):
        count = sum(1 for v in bad_vulns if v['file'] == f)
        print(f"  - {f} ({count} vulnérabilités)")
    
    print(f"\nFichiers dans GOOD ({len(good_files)}):")
    for f in sorted(good_files):
        count = sum(1 for v in good_vulns if v['file'] == f)
        print(f"  - {f} ({count} vulnérabilités)")
    
    # Différences
    print(f"\nFichiers présents dans BAD mais PAS dans GOOD:")
    for f in bad_files - good_files:
        print(f"  ✗ {f}")
    
    print(f"\nFichiers présents dans GOOD mais PAS dans BAD:")
    for f in good_files - bad_files:
        print(f"  ✓ {f}")

if __name__ == '__main__':
    main()
