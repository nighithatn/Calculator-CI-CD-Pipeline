# Python CI/CD Demo

A small Python calculator used to learn a real CI/CD workflow with **Pytest, Git/GitHub, GitHub Actions and Docker**.

## What the pipeline does

```
git push / pull request
        |
        v
  [Job 1: test]  ---> checkout -> setup Python -> install pytest -> run pytest
        |
   passes? ----- no ----> pipeline stops (red X), Docker is NOT built
        |
       yes
        v
  [Job 2: docker-build] -> docker build -> docker run
```

## Project structure

| File | Purpose |
|------|---------|
| `main.py` | Calculator with `add`, `subtract`, `multiply`, `divide` |
| `test_main.py` | Pytest tests that verify the functions |
| `requirements.txt` | Python dependencies (pytest) so CI can install them |
| `Dockerfile` | Instructions to package the app into an image |
| `.dockerignore` | Files kept out of the Docker image |
| `.gitignore` | Files kept out of Git/GitHub |
| `.github/workflows/ci-cd.yml` | GitHub Actions pipeline definition |

## Why each tool is used

- **Python**: the application language.
- **Pytest**: automatically checks the code is correct, so bugs are caught before release.
- **Git**: tracks every change to your code.
- **GitHub**: hosts the code and triggers the pipeline.
- **GitHub Actions**: runs the pipeline on GitHub's servers for every push/PR (this is the automation).
- **Docker**: packages the app and its environment so it runs the same on any machine.

## Step 1: Run locally (Windows, Command Prompt)

In VS Code open **Terminal > New Terminal**. If it opens PowerShell, click the dropdown arrow next to `+` and choose **Command Prompt**. The prompt should look like `C:\...\python-cicd-demo>`.

```bat
python --version
git --version
docker --version
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python main.py
pytest -v
```

After activation you should see `(venv)` at the start of the line. (The execution-policy error is a PowerShell issue and does not occur in Command Prompt.)

Expected: the demo prints results and pytest shows `5 passed`.

## Step 2: Run with Docker locally

Start Docker Desktop, then:

```bat
docker build -t python-cicd-demo .
docker run --rm python-cicd-demo
```

`--rm` deletes the container after it exits.

## Step 3: Push to GitHub

1. On github.com click **New repository**, name it `python-cicd-demo`, leave it empty (no README/.gitignore), click Create.
2. In your project folder:

```bat
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/python-cicd-demo.git
git push -u origin main
```

If Git asks who you are:

```bat
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

3. Open the repo's **Actions** tab. You should see the pipeline run with two green jobs: `test` then `docker-build`.

## Step 4: Failure test

1. Break the code in `main.py`:

```python
def add(a, b):
    return a - b   # intentional bug
```

2. Push it:

```bat
git add .
git commit -m "Introduce bug in add"
git push
```

3. In **Actions**: the `test` job fails (red X) and `docker-build` is **skipped**. That proves Docker only builds when tests pass. Click the failed run to see pytest's error (`assert -1 == 5`).
4. Fix it back to `return a + b`, then:

```bat
git add .
git commit -m "Fix add function"
git push
```

5. The pipeline turns green again.

## Bonus: Pull request flow

```bat
git checkout -b feature/test-pr
REM edit something small, then:
git add . && git commit -m "Small change" && git push -u origin feature/test-pr
```

Open a Pull Request on GitHub; the pipeline runs on the PR and shows its result before you merge.

## Workflow file explained

- `on:` triggers on push to `main` and pull requests to `main`.
- `jobs.test`: runs on a fresh Ubuntu machine (`runs-on`), checks out your code, installs Python and pytest, runs `pytest -v`. Any failing test fails the job.
- `jobs.docker-build`: `needs: test` means it waits for `test` and runs only if it succeeded.
- `uses:` runs a ready-made action; `run:` runs a shell command.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `python` not recognized | Reinstall Python and tick "Add to PATH" |
| `ModuleNotFoundError: main` | Run pytest from the project root folder |
| `pytest` not found | Activate venv, then `pip install -r requirements.txt` |
| Terminal shows `PS C:\...>` | That is PowerShell; switch to Command Prompt from the terminal dropdown |
| Docker "cannot connect to daemon" | Start Docker Desktop and wait until it is running |
| `git push` rejected / auth error | Sign in via the browser prompt, or use a Personal Access Token |
| No workflow in Actions tab | File must be exactly `.github/workflows/ci-cd.yml`, committed and pushed |
| Workflow doesn't trigger | Your branch must be `main` (check with `git branch`) |
| YAML error | Use spaces only (no tabs) and keep indentation exact |

## Next steps

Push the image to Docker Hub or GitHub Container Registry (a real "CD" step), or add more functions such as power or modulo.