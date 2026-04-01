---
description: Draft a pull request summary for the current branch
agent: general
---

You are tasked with drafting a comprehensive pull request summary for the current working branch.

## Branch and Commit Information

Current branch:
!`git branch --show-current`

Commits on this branch (compared to main):
!`git log main..HEAD --online`

Full commit details with changes:
!`git log main..HEAD --stat`

Code diff from main:
!`git diff main...HEAD`

## Task Requirements

1. **Extract Jira Ticket** (Read-Only): Parse the branch name to identify the Jira ticket ID (e.g., PROJ-123 from branch names like `feature/PROJ-123-description` or `PROJ-123-fix-bug`). If found, fetch the ticket details using acli for context only:
   - Run: `acli jira workitem get <ticket-id> --format=json`
   - Include a link to the ticket: `https://jira.atlassian.com/browse/<ticket-id>`
   - Use the ticket description and comments for context about motivation
   - **IMPORTANT**: This is READ-ONLY. NEVER update, modify, or transition Jira tickets.

2. **Analyze Changes**: Review ALL commits and code changes to understand:
   - What behavior changed (new features, bug fixes, refactors)
   - Workflow or process changes
   - API or interface changes
   - Configuration or infrastructure changes
   - Documentation updates

3. **Draft Summary**: Create a pull request summary with:
   - **High-level summary** (2-3 sentences) explaining the purpose and impact
   - **Jira Ticket** section with link (if found)
   - **Key Changes** section with 3-7 bullet points focusing on:
     - Behavioral changes (what the code does differently)
     - Workflow impacts (how users/developers interact with it)
     - Important implementation decisions
     - Breaking changes or migration notes
     - Documentation or configuration updates

4. **Preview and Confirm**: After drafting the summary:
   - Display the complete draft to the user
   - Ask the user to choose from these options:
     - **Make changes**: Allow the user to request modifications to the draft
     - **Edit PR description**: Update the existing pull request description with this content
     - **Add as comment**: Post the draft as a new comment on the pull request
     - **Cancel**: Do not make any changes
   - **CRITICAL**: Do NOT edit the pull request or add comments until the user explicitly confirms their choice

## What NOT to Include

- File statistics (lines added/removed, files changed) - these are shown in the PR diff
- Generic statements about code quality or test coverage
- Trivial formatting or whitespace changes
- Overly detailed line-by-line explanations

## Output Format

Display the draft in this format:

```
## Summary
[2-3 sentence high-level overview]

## Jira Ticket
- [PROJ-123](https://jira.atlassian.com/browse/PROJ-123): [Ticket title]

## Key Changes
- [Behavioral/workflow change 1]
- [Behavioral/workflow change 2]
- [Important implementation detail]
- [Documentation/config update]
```

Then present the user with clear options for what to do with the draft.

## Important Constraints

- **NO Jira Updates**: NEVER update, modify, transition, or change Jira tickets in any way. Only read ticket information for context.
- **User Confirmation Required**: NEVER edit the pull request description or add comments without explicit user confirmation.
- **Preview First**: Always show the complete draft to the user before offering action options.

Focus on helping reviewers understand the "why" and "what impact" rather than the "how many lines changed".
