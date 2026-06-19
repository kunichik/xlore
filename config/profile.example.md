---
# config/profile.md — your per-user setup. Created by first-run onboarding.
# Copy to profile.md and fill in, or run `xlore onboarding` and let the agent write it.
# This file lives ONLY in your private archive. It is never pushed to the public template.
---
# xlore profile

handle:        # your name/handle, stamped on contributions (e.g. alex)
machine:       # this machine's hostname (e.g. alex-mac)
tools:         # AI tools that maintain this archive (e.g. claude-code, windsurf, cursor)

# Posture
audience:      # personal | work-solo | work-shared   (work-shared ⇒ keep personal in a 2nd repo)
repo_private:  # MUST be: yes   (if no — stop and make the repo private before storing real data)
sync_mode:     # auto | semi-auto | manual   (default manual; conflicts/secrets always ask, every mode)

# What to track
projects:      # repos collect-raw.sh scans — keep tools/sources.conf in sync
  # - Documents/projects/my-app

namespaces:    # wiki namespaces you use beyond the defaults (projects/concepts/decisions)
  # - personal
  # - finance
