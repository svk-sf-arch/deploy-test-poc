# Project summary

**Project:** demoDeployTest  
**Last updated:** 2026-11-07

## What this project is

A Salesforce DX project named demoDeployTest. Source API version is 66.0. The default package directory is `force-app`. The login URL is `https://login.salesforce.com`.

## Documentation

The `documentation` folder tracks work as it happens.

| File | Purpose |
| --- | --- |
| `ACTIONS.txt` | Running log of each action |
| `SUMMARY.txt` | Plain-text summary |
| `SUMMARY.md` | This markdown summary, kept for git |
| `DEPLOYMENT_PIPELINE.txt` | Full pipeline write-up, plain text |
| `DEPLOYMENT_PIPELINE.md` | Full pipeline write-up, markdown |
| `DEPLOYMENT_PIPELINE.html` | Full pipeline write-up, dark theme, prints to PDF |
| `DEPLOYMENT_PIPELINE.docx` | Full pipeline write-up, Word |

## Current status

A GitHub Actions workflow deploys changed Salesforce components to `TargetDemoOrg` whenever a pull request is merged into `main`. The Bedrock Request feature has been deployed through it, and all its Apex tests pass. See `DEPLOYMENT_PIPELINE.md` for details and open items.

## Action log

| Date | Action | Result |
| --- | --- | --- |
| 2026-11-07 | Reviewed the project layout. | Confirmed there was no documentation folder yet. Salesforce DX project, API version 66.0. |
| 2026-11-07 | Created the documentation folder and tracking files. | Added `ACTIONS.txt`, `SUMMARY.txt`, `SUMMARY.md`, and a contact details file. |
| 2026-11-07 | Removed the contact details file at the user's request. | Deleted the file and removed every reference to the contact. |
| 2026-11-07 | Built the manifest from one user's changes. | 53 components; later trimmed by hand. |
| 2026-11-07 | Fixed git identity and GitHub account; made `main` the default branch. | Everything now uses `svk-sf-arch`. |
| 2026-11-07 | Added the deploy-on-merge workflow, environment and secret. | PR #1 failed on Node 20; PR #2 (Node 24) succeeded. |
| 2026-11-07 | Merged the Bedrock Request feature (PR #3). | 12 components deployed; 4 of 4 tests pass. |
| 2026-11-07 | Documented the pipeline. | Added the four `DEPLOYMENT_PIPELINE` files. |
