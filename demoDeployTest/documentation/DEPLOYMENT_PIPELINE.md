# Salesforce delta deployment pipeline

**Project:** demoDeployTest (Salesforce DX, API 66.0)  
**Repository:** [svk-sf-arch/deploy-test-poc](https://github.com/svk-sf-arch/deploy-test-poc)  
**Date:** 2026-11-07  
**Status:** Working. The first feature merge deployed to the target org, and all Apex tests pass.

---

## 1. Summary

When a pull request is merged into `main`, a GitHub Actions workflow finds the Salesforce components that changed, builds a `package.xml` for only those components using sfdx-git-delta (sgd), validates the deployment against the target org (dry run), and then deploys it.

The first real run deployed the Bedrock Request feature (12 components) to the target org. Validation and deployment both succeeded. All 4 Apex tests pass and `BedrockRequestPriorityService` has 100% code coverage.

## 2. Orgs, repository and branches

| Item | Value |
| --- | --- |
| Source org alias | `deployDemoTest` |
| Source org URL | `https://storm-da46cde7144416.my.salesforce.com` |
| Target org alias | `TargetDemoOrg` |
| Target org URL | `https://trailsignup-ad38b27e4f5ccb.my.salesforce.com` (Enterprise Edition, not a sandbox) |
| GitHub repository | `svk-sf-arch/deploy-test-poc` |
| Default branch | `main` (changed from `sys/initial-commit`) |
| Pipeline branch (kept) | `sys/github-action-setup` |
| Feature branch | `feature/demo-deploy` |
| Salesforce project folder | `demoDeployTest/` (inside the repository root) |
| Workflow file | `.github/workflows/deploy-on-merge.yml` (repository root) |

## 3. What was done, in order

1. **Authorized the source org** as `deployDemoTest` with a web login. Use the `.my.salesforce.com` domain, not `.lightning.force.com`.
2. **Built a manifest of one user's work.** Listed every metadata type in the source org and kept the components created or last modified by user `005Ws00000BoCCYIA3` (Abhishek Kumar Raj). That matched about 29,600 components, mostly from the org template and managed packages. The final selection was the 53 components changed after the org was provisioned on 2026-06-16: the Bedrock Request feature, the standard Sales app, and 35 profiles. The manifest was later trimmed by hand to the core Bedrock components.
3. **Authorized the target org** as `TargetDemoOrg`.
4. **Set the git identity.** The global and repository identity is now `svk-sf-arch <skalsekar@salesforce.com>` (it was the Kraft Heinz identity).
5. **Fixed GitHub authentication.** The GitHub CLI and the macOS Keychain were signing in as `Sushil-Kalsekar_kraft`. `svk-sf-arch` is now the active GitHub CLI account. The Kraft account is still logged in but inactive.
6. **Created a `main` branch** from the initial commit, pushed it, and made it the repository's default branch.
7. **Wrote the GitHub Actions workflow** `deploy-on-merge.yml` (described in section 4).
8. **Created the GitHub environment `TargetDemoOrg`** and stored the target org's SFDX auth URL in it as the secret `TARGET_ORG_SFDX_AUTH_URL`.
9. **Merged [PR #1](https://github.com/svk-sf-arch/deploy-test-poc/pull/1)** (add workflow). Its run failed: the Salesforce CLI crashed on Node 20.
10. **Merged [PR #2](https://github.com/svk-sf-arch/deploy-test-poc/pull/2)** (Node 24). Its run succeeded and correctly reported nothing to deploy.
11. **Merged [PR #3](https://github.com/svk-sf-arch/deploy-test-poc/pull/3)** (Bedrock Request feature). Validation and deployment succeeded.
12. **Ran the Apex tests directly in the target org**, because the deployment reported 0 tests run. All 4 tests passed, with 100% coverage.

## 4. How the workflow works

**Trigger:** a pull request into `main` is closed *and* merged. Closing a pull request without merging does nothing.

| Step | What it does |
| --- | --- |
| Checkout | Checks out the merge commit with full git history (`fetch-depth: 0`). |
| Node.js | Installs Node 24. The current Salesforce CLI does not run on Node 20. |
| Install tools | Installs `@salesforce/cli` and the `sfdx-git-delta` plugin. |
| Authenticate | Logs in to the target org from the secret `TARGET_ORG_SFDX_AUTH_URL`, alias `targetOrg`. |
| Generate delta | `sf sgd source delta` compares the pull request's base commit with the merge commit, only under `demoDeployTest/force-app`. Output: `package.xml` (added/changed) and `destructiveChanges.xml` (deleted). |
| Decide test level | No Apex changed: `NoTestRun`. Changed classes ending in `Test`: `RunSpecifiedTests` with those classes. Other Apex changes: `RunLocalTests`. |
| Dry run | `sf project deploy start --dry-run` from `demoDeployTest`. Deleted components are included only if there are any. |
| Deploy | The same command without `--dry-run`. Runs only if the dry run passed. |
| Nothing to deploy | If no Salesforce files changed, logs that and stops. |
| Upload artifact | Saves the generated manifests as the `delta-manifests` artifact. |

**Other settings**

- Runs one at a time (`concurrency: deploy-target-org`), so two merges never deploy at the same time.
- Uses the GitHub environment `TargetDemoOrg`. You can add required reviewers there to approve each deployment.
- The comparison starts from the pull request's base commit, so components merged by other pull requests in the meantime may be deployed again. This is harmless and works for merge, squash and rebase merges.

## 5. Results

### Workflow runs

| Pull request | Run | Result | Notes |
| --- | --- | --- | --- |
| #1 Add delta deploy workflow | 42355228867 | Failed | Salesforce CLI crashed on Node 20 (`markAsUncloneable is not a function`). |
| #2 Update Node.js to 24 | 42355558930 | Succeeded | No Salesforce changes, so nothing was deployed. Confirmed install and login. |
| #3 Bedrock Request feature | 42355659177 | Succeeded | 12 components validated and deployed. |

### Feature deployment (PR #3)

| Item | Value |
| --- | --- |
| Components deployed | 12 |
| Components deleted | 0 |
| Test level chosen | `RunSpecifiedTests BedrockRequestPriorityServiceTest` |
| Dry run deploy ID | `0Afbm00000n7NdBCAU`, succeeded, 4m 47s |
| Deploy ID | `0Afbm00000n7OMLCA2`, succeeded, 1m 41s |

**Components:** `Bedrock_Request__c` (object); 6 fields (`Description__c`, `Priority__c`, `Request_Name__c`, `Request_Type__c`, `Reviewed_By_Automation__c`, `Status__c`); `BedrockRequestPriorityService` and `BedrockRequestPriorityServiceTest` (Apex); `Bedrock_Request_Priority_Review` (flow); `Bedrock_Request__c.All` (list view); `Bedrock_Request_User` (permission set).

### Apex tests (run directly in the target org)

| Test method | Result |
| --- | --- |
| `testHighPriorityRequiresReview` | Pass |
| `testCriticalPriorityRequiresReview` | Pass |
| `testMediumPriorityDoesNotRequireReview` | Pass |
| `testBulkPriorityEvaluation` | Pass |

`BedrockRequestPriorityService` coverage: 9 of 9 lines (100%).

## 6. Problems found and how they were fixed

| Problem | Cause | Fix |
| --- | --- | --- |
| Login with the Lightning URL fails | The CLI needs the My Domain login URL. | Use `https://<domain>.my.salesforce.com` as `--instance-url`. |
| `No file found at manifest/package.xml` | Command run from the repository root. | Run `sf` commands from `demoDeployTest/`. |
| `fatal: invalid reference: main` | No `main` branch existed. | Created and pushed `main`, then made it the default. |
| Commits and pushes used the Kraft identity | Global git config, GitHub CLI and Keychain were all set to Kraft. | Set the git identity to `svk-sf-arch`; switched the GitHub CLI account. |
| Secret upload returned 404 | The `TargetDemoOrg` environment did not exist. | Created the environment, then set the secret. |
| First workflow run crashed | Current Salesforce CLI needs a newer Node.js. | Changed `node-version` from 20 to 24 (PR #2). |
| Deployment reported 0 tests run | Salesforce counted no tests even though the run asked for one. | Ran the tests directly: all pass, 100% coverage. Still worth watching (see section 8). |

## 7. Everyday use

**Ship a change**

1. Create a branch from `main` and change files under `demoDeployTest/force-app`.
2. Push and open a pull request into `main`.
3. Merge it. The workflow validates and deploys only what changed.
4. Watch it on the **Actions** tab, or with `gh run watch`.

**Useful commands** (run `sf` commands from `demoDeployTest/`)

```bash
# Log in to an org
sf org login web --alias TargetDemoOrg --instance-url https://trailsignup-ad38b27e4f5ccb.my.salesforce.com

# Retrieve what the manifest lists
sf project retrieve start --manifest manifest/package.xml --target-org deployDemoTest

# Deploy by hand with the same manifest
sf project deploy start --manifest manifest/package.xml --target-org TargetDemoOrg --test-level RunSpecifiedTests --tests BedrockRequestPriorityServiceTest

# Refresh the GitHub secret (never shows the URL)
sf org auth show-sfdx-auth-url --target-org TargetDemoOrg --no-prompt --json \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['result']['sfdxAuthUrl'])" \
  | gh secret set TARGET_ORG_SFDX_AUTH_URL --env TargetDemoOrg --repo svk-sf-arch/deploy-test-poc

# Run the Apex tests in the target org
sf apex run test --class-names BedrockRequestPriorityServiceTest --target-org TargetDemoOrg --code-coverage --wait 10

# Watch workflow runs
gh run list --workflow deploy-on-merge.yml --repo svk-sf-arch/deploy-test-poc
gh run watch --repo svk-sf-arch/deploy-test-poc
```

## 8. Open items

1. **Revoke the exposed auth URLs.** Two SFDX auth URLs were pasted into chat: one for the Kraft Heinz UAT sandbox and one for the target org. Run `sf org logout` for each org and log in again, then refresh the GitHub secret with the command above.
2. **Deployment test count.** The deployment ran with `RunSpecifiedTests` but Salesforce recorded 0 tests. The tests pass when run directly. Check the next Apex deployment; if it still shows 0, look at the test-level handling in the workflow.
3. **Local leftover workflow file.** An untracked copy of `.github/` (still set to Node 20) sits in the working folder on `feature/demo-deploy`. Delete it before switching branches, or `git switch` will refuse.
4. **Local branches are behind.** Local `main` is 6 commits behind GitHub, and `sys/github-action-setup` has diverged by one commit. Pull both.
5. **Optional: approval gate.** Add required reviewers to the `TargetDemoOrg` environment if deployments should wait for approval.
6. **Optional: deletions.** The workflow deletes components in the target org when they are deleted in a pull request. Remove the `--post-destructive-changes` lines if that is not wanted.
