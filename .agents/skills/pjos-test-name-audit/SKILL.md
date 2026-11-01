---
name: pjos-test-name-audit
description: 'Audit all Spock test names in the project, propose improvements, apply only what the user approves, then re-run the affected tests. Use when the user says "audit test names", "check test names", "improve test names", or invokes /pjos-test-name-audit'
---

# Test Name Audit

**Goal:** Every test name in the project states its behavior clearly; no change is made before the user approves it; approved renames still pass.

**Your Role:** You audit the whole test suite and propose renames. You never apply a change before the user has seen and approved it.

## Step 1: Discover all tests

List every test file in the project — tracked and untracked, not only the files currently changed:

```bash
{ git ls-files src/test | grep -E 'src/test/.*(Spec|Test)\.(groovy|java)$'; git ls-files --others --exclude-standard | grep -E 'src/test/.*(Spec|Test)\.(groovy|java)$'; } | sort -u
```

Audit every file returned. If the project has no `src/test` layout, search the repository for `*Spec.*` and `*Test.*` files instead.

## Step 2: Validate names

For each spec check:

- **Class/file name** — `<Subject>Spec` (or `<Subject>Test`), matching the class under test. The file suffix must stay `Spec.groovy`/`Test.groovy` so the build's test include patterns still pick it up.
- **Feature methods** — Spock feature methods carry a behavior string: `def "should <behavior> when <condition>"`. It states the expected behavior, not the implementation.
- **Reject** — placeholder names (`test1`, `shouldWork`, `foo`), names that only restate the method under test (`testGetById`), duplicated or ambiguous strings within the same spec.

## Step 3: Propose and ask (no changes yet)

1. Build a rename plan: one entry per proposed change — file/class/method, old name → proposed name, and the reason.
2. Present the complete plan (compact list or table), plus a one-line count of specs that already pass ("no change").
3. End your message asking the user what to apply: **all**, **a subset** (they will name entries), or **none**. Stop and wait — do not modify any file in this turn.
4. Only the entries the user approves may be applied in Step 4. No approval → skip Step 4 and Step 5.

## Step 4: Apply the approved changes

- Apply only the approved entries — nothing else.
- A Spock feature-method rename is a string change only; a class rename means renaming the file too.
- Keep the `Spec`/`Test` suffix and the package. Never rename outside the build's test include patterns.
- Do not change assertions or behavior as part of a rename.

## Step 5: Verify (finish protocol)

Only if at least one change was applied:

1. Run the test-gate sentinel **with the project you audited as its argument**: `bash <sentinel-path> <project-dir>` (absolute path, or relative to the workspace). Try these sentinel paths and use the first that exists:
   - `.github/hooks/scripts/skill-sentinel.sh` (workspace root is ai-dev-kit)
   - `ai-dev-kit/.github/hooks/scripts/skill-sentinel.sh` (workspace root contains both repos)
   - `../ai-dev-kit/.github/hooks/scripts/skill-sentinel.sh` (current project is the target repo)
   Omit `<project-dir>` only when auditing the configured default project. If no sentinel path exists, skip to item 4.
2. The sentinel prints `test-gate target:` and `test-gate log: <path>` — read that log and report the `RESULT:` line plus any failures. The gate runs exactly the uncommitted changed tests of that target project, which are the approved renames.
3. If tests failed: fix them, run the sentinel again, re-read the log. Repeat at most 3 times, then report honestly what still fails.
4. No sentinel found → run the changed tests yourself with the project's build tool (e.g. `./mvnw test -Dtest='SpecA,SpecB'`).

## Report

End with: specs audited (count), approved changes applied (old → new), proposals the user rejected or that were left unchanged (with reason), and the final test result (or "no changes made" when nothing was approved).
