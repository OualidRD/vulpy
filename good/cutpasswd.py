import os
import re
from pathlib import Path

password_file = os.getenv('PASSWORD_FILE', '/opt/passwords/darkweb2017-top10000.txt')
if not Path(password_file).exists():
    raise FileNotFoundError(f"Password file not found: {password_file}")

with open(password_file) as f:
    for password in f.readlines():

        password = password.strip()

        if len(password) < 12:
            continue

        if len(re.findall(r'[a-z]', password)) < 1:
            continue

        if len(re.findall(r'[A-Z]', password)) < 1:
            continue

        if len(re.findall(r'[0-9]', password)) < 1:
            continue

        print(password)

