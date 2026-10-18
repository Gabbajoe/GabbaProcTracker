# Tests, packaging and publication

## Local validation

```sh
bash tests/run_tests.sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
python3 tools/build_package.py --tag v0.1.0
```

Use `LUA=lua5.1 LUAC=luac5.1` to explicitly select WoW-compatible Lua.
The package builder uses an explicit runtime manifest, stable ZIP timestamps,
and produces `dist/GabbaProcTracker-<version>.zip` plus `.zip.sha256`.
The ZIP always contains one `GabbaProcTracker/` directory, even if the checkout
folder has another name. Git metadata, tests, tools, artwork sources and author
setup documents are not shipped to players. Runtime TGA icons are included.

CI runs on main pushes and pull requests: Lua 5.1 syntax checks, both locales,
tracking/export/minimap tests, Python release tests and a reproducible ZIP build.
The ZIP/checksum are downloadable as the `GabbaProcTracker-build` CI artifact.

## Release a new version

1. Set the version in `GabbaProcTracker.toc` and `Locale.lua` consistently.
2. Update `CHANGELOG.md` and `curseforge/CHANGELOG-<version>.md` (and catalog date/version).
3. Run local checks and commit/push to `main`; check CI.
4. Create an annotated tag: `git tag -a v<version> -m 'GabbaProcTracker <version>'`.
5. Push it: `git push origin v<version>`.

The Release workflow tests/builds the tagged source, verifies version/tag agreement,
and creates a GitHub release with ZIP, checksum and release notes. Plain versions
are Releases; `-dev.N`/`-alpha.N` become Alpha on CurseForge; `-beta.N`/`-rc.N`
become Beta. All suffixed versions become GitHub prereleases. The initial version
is 0.1.0. Do not move published version tags: publish a new version instead.

Rerunning a successful release retains existing GitHub assets and skips the
CurseForge upload. If the GitHub release was created but the CurseForge step failed,
check the CurseForge dashboard before using the manual upload workflow. Uploads
are not automatically retried because they could create duplicate files.

## CurseForge setup (one time)

The author supplied project ID **1752634**. Metadata and artwork are in
[PROJECT.md](curseforge/PROJECT.md), [DESCRIPTION.md](curseforge/DESCRIPTION.md)
and `curseforge/logo.png`. The public project URL/moderation status are not yet verified.

Under [repository Actions settings](https://github.com/Gabbajoe/GabbaProcTracker/settings/secrets/actions):

- **Variable** `CURSEFORGE_PROJECT_ID`: `1752634` (configured).
- **Secret** `CURSEFORGE_API_TOKEN`: an author upload token. Never commit it or paste it into an issue.

Author tokens: https://authors.curseforge.com/#/settings/api-tokens .
The current TOC includes `## X-Curse-Project-ID: 1752634`. Record the actual
public project URL once confirmed. The existing v0.1.0 tag and ZIP remain unchanged;
the project ID is passed separately to the uploader, so that release can still
be uploaded using the manual workflow. Future releases include the TOC metadata.

Run **Actions → Check CurseForge access**. This verifies token/API access and the
exact Classic Era client version lookup. It does not establish project ownership.
Once both settings exist, new tagged releases also upload to CurseForge. Until
then GitHub releases work and the workflow clearly reports the skipped upload.

For an already published tag, run **Upload existing release to CurseForge** with
that exact tag (e.g. `v0.1.0`). Check the dashboard for an existing file first.
The upload API resolves the client version from the TOC (currently 1.15.9), fails
on missing or ambiguous matches, and submits the ZIP. Moderation may remain pending.
Source descriptions/logo are prepared separately; the upload API does not create
the project or update its public project description.

Manual CLI alternative, with credentials set in the environment:

```sh
python3 tools/upload_curseforge.py --check
python3 tools/upload_curseforge.py --archive dist/GabbaProcTracker-0.1.0.zip \
  --notes curseforge/CHANGELOG-0.1.0.md --tag v0.1.0
```

## In-game validation

Automated mocks do not establish real-client behavior. Check login/reload,
minimap icon transparency, dragging and both clicks, `/gpt minimap`, both client
languages, a known proc in each area type, and export persistence after reload.
Counters and UUIDs are character-specific; installing an update must not replace
WTF/SavedVariables. No gameplay or visual test in a running client has been claimed.
