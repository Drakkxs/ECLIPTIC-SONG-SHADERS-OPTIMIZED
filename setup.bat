@REM Configures git hooks to automatically package the mod into a release archive on commit
@echo off
setlocal
git config core.hooksPath .githooks
echo [SUCCESS] Mod packaging hooks configured.