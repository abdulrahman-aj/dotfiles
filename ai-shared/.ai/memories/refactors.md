# Refactoring

## Broken windows

When encountering bad or messy code adjacent to the current task, always log it — never silently ignore it. Append an entry to `REFACTORS.md` in the project root (create it if it doesn't exist). Entry format: file path and a brief description of the issue. Do not fix it unless it's in the direct change path.

## Naming

If touching code that has a poor name, rename it. Don't go out of scope to rename — log it in `REFACTORS.md` instead.

## Refactor first

Before adding a feature, refactor the surrounding code to make the change easy. Then make the easy change.
