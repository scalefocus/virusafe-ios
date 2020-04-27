# Git Branching Strategy

Most projects at ScaleFocus follow the [Gitflow](http://nvie.com/posts/a-successful-git-branching-model/) workflow. ViruSafe is not an exception. Gitflow is a branching model for Git, created by Vincent Driessen. It's a standardised approach that allows teams to separate feature development, release and support for emergency fixes. 

> **NB!  To help yourself using GitFlow, you can use the git-flow tool. On OSX systems, you can execute `brew install git-flow` in Terminal to install it**

## Branching Model

### Branch naming convention

`master` and `develop` are always named exactly that. For feature branches use a consistent naming convention to identify the work done in the branch.

1. `feature` : New feature
2. `bugfix` : Changes linked to a known issue
3. `hotfix` : Quick fixes to the codebase

Branch names should use dashes to separate words of the name and should avoid any uppercase letters.

* `feature/feature-name`
* `feature/feature-area/feature-name`
* `bugfix/description`
* `hotfix/description`

Other than that, choose names that are descriptive and concise. You don't need a branch name that is a novel because most branches should be relatively short-lived (hours to days, not weeks).

### Master branch

We consider `origin/master` to be the main branch where the source code of HEAD always reflects a production-ready state.

### Development branch

We consider `origin/develop` to be the main branch where the source code of HEAD always reflects a state with the latest delivered development changes for the next release. Some would call this the “integration branch”. This is also where any automatic nightly builds are built from.

> **NB! When code in the `develop` branch is stable and ready to release, all of the changes should be merged back into master and then tagged with a release number (See [Release branches](#release-branches)).**

### Feature branches

Develop new features for the upcoming or a distant future release.

* May branch off from: `develop`
* Must merge back into: `develop`
* Branch naming convention: anything except `master`, `develop`, `release/*`, or `hotfix/*` 

### Release Branches

Support preparation of a new production release (uses [Semantic Release](https://github.com/JeffersonLab/remoll/wiki/Semantic-Versioning-and-Branching-Model))

1. Create a release branch from the develop branch as you get close to your release or other milestones, such as the end of the sprint.
2. Give this branch a clear name associating it with a release, for example `release/1.0.0`.

* May branch off from: `develop`
* Must merge back into: `develop` and `master`
* Branch naming convention: `release/*`
* The `develop` branch is cleared to receive features for the next big release
* The key moment to branch off a new release branch from `develop` is when `develop` (almost) reflects the desired state of the new release.
* It is exactly at the start of a release branch that the upcoming release gets assigned a version number—not any earlier.

### Hotfix branches

* May branch off from: `master`
* Must merge back into: `develop` and `master`
* Branch naming convention: `hotfix/*`
* Like release branches, but they arise from the necessity to act immediately upon an undesired state of a live production version

### Key Stages Summary

1. The repo is created with only a `master` branch, by default.
2. A `develop` branch is created from `master`.
3. `feature/*` branches are created from `develop`.
4. When a feature is complete, it's merged into `develop` (via PR) and then removed.
5. To initiate a release, a `release/*` branch is created from `develop`.
6. When a release is complete, `release/*` is merged into `develop` and `master`, tagged, and then removed.
7. If an issue in `master` needs to be resolved, a `hotfix/*` branch is created from `master`.
8. When the hotfix release is complete, `hotfix/*` is merged into `develop` and `master`, tagged, and then removed.

## Commits

**Commit early, commit often!** Try to remember to push any pending commits to the remote repo at the end of every day so that all in-progress work is backed up.

Commit messages should be detailed and helpful - avoid anything that's not a complete sentence. You should aim to tell a story in the commit message (i.e. what was broken and how it was fixed). A good rule of thumb to follow is to begin commit messages with a verb so that the message completes the phrase "This commit...".

## Rebasing

In order to improve the readability of the history, before submitting your work try to squash and rebase your git commits.

1. Make sure you have the most up-to-date version of the branch you're rebasing on.
2. Rebase you local branch. (solve any confilcts)
3. Share your branch and create pull request.

> **NB! You should avoid rebase branch that is already shared.**

## Merging

All merges into `develop`, `release/*`, and `hotfix/*` should happen via pull requests. This ensures that all code gets reviewed at some point before it's shipped. This ensures that all code gets reviewed at some point before it's shipped. For more information, see [Code Review Standards](https://github.com/thoughtbot/guides/tree/master/code-review).

## Deleting Branches

Branches should be deleted after they've been merged into `develop` or `master`. This keeps the repository clean and makes it clear where active development is occurring.

## Updating branches

> **NB! Git always works on a local copy of a repository. As a result, whenever you do any operations that involve multiple branches (eg. merge) be sure to update both branches before performing the operation.**

### `git pull`

Git provides a single command to update your local branch with changes from a remote - `git pull`. Most of the time it does exactly what you want without any problems, but you should know that `git pull` is really `git fetch` followed by `git merge`. So when you pull from a remote, you're actually updating the remote tracking branch (eg. `origin/mybranch`) and then merging that into your local branch `mybranch`.

It's good to know that this happens under the hood. Some people prefer to do the `git fetch` and `git merge` operations separately. Most of the time `git pull` will do what you want and is an acceptable way to update your local branch with changes from remote.

### Protected Branches

GitHub recently added [Protected branches](https://github.com/blog/2051-protected-branches-and-required-status-checks). Protected branches:
- Can't be force pushed
- Can't be deleted
- Can't have changes merged into them until required status checks pass

`master` and `develop` branches should always be protected. These protected branches should never be directly committed to. They should only be updated through PR merges.

Projects that have continuous integration with a service such as **Jenkins** should have their `master` and `develop` (if applicable) branches protected by a status check requiring Jenkins builds to pass before changes can be merged.

## Sources

* <https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow | Gitflow Workflow | Atlassian Git Tutorial>
