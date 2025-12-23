# Gitleaks Pre-Commit Hook

Automated secret detection for git repositories using [gitleaks](https://github.com/gitleaks/gitleaks).

## Features

- Automatic gitleaks installation (Linux/macOS/Windows)
- OS and architecture auto-detection
- Enable/disable via `git config`
- Blocks commits containing secrets (tokens, passwords, API keys)

## Quick Install

Run this command in your project root:
```bash
curl -sSL https://raw.githubusercontent.com/Iamfittz/gitleaks-hook/main/install.sh | sh
```

## Manual Install

1. Install gitleaks manually: https://github.com/gitleaks/gitleaks#installing

2. Download pre-commit hook:
```bash
curl -sSL -o .git/hooks/pre-commit https://raw.githubusercontent.com/Iamfittz/gitleaks-hook/main/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

3. Enable hook:
```bash
git config hooks.gitleaks true
```

## Usage

### Enable/Disable
```bash
# Enable hook
git config hooks.gitleaks true

# Disable hook
git config hooks.gitleaks false
```

### Skip check (not recommended)
```bash
git commit --no-verify
```

## How it works

1. On every `git commit`, the pre-commit hook runs
2. Checks if hook is enabled via `git config hooks.gitleaks`
3. Runs `gitleaks detect --staged` on staged files
4. If secrets found → commit is rejected
5. If no secrets → commit proceeds

## Supported secrets

Gitleaks detects:
- API keys (AWS, GCP, Azure, etc.)
- Tokens (GitHub, GitLab, Slack, Telegram, etc.)
- Passwords and credentials
- Private keys (SSH, PGP)
- Database connection strings

## Example output

**Clean commit:**
```
[INFO] Running secrets scan...
[OK] No secrets detected. Commit allowed.
```

**Blocked commit:**
```
[INFO] Running secrets scan...
Secret detected: telegram-bot-token
File: config.py
Line: 15

[BLOCKED] Secrets detected! Commit rejected.
```

## License

MIT
```

---

### Итоговая структура репозитория

Проверь, что у тебя всё на месте:
```
gitleaks-hook/
├── install.sh          ← скрипт установки
├── hooks/
│   └── pre-commit      ← сам hook
└── README.md           ← документация