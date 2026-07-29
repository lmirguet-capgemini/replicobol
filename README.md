# Replicobol

Replicobol is a local weekly timesheet application. It provides a static web frontend and a GNU Cobol backend exposed through CGI-style handlers.

The first version lets you:

- create projects with a client name, project name, and project code
- record time spent per project and week
- view a Monday-to-Friday weekly calendar
- keep local correction records when an existing timesheet entry changes

## Project Layout

```text
backend/cgi/                 GNU Cobol CGI handlers
backend/copybooks/           shared Cobol copybooks
backend/tests/contract/      shell contract tests for CGI handlers
data/                        local pipe-delimited data files
frontend/                    static HTML, CSS, and JavaScript
scripts/build.sh             compiles Cobol CGI handlers
scripts/test-backend.sh      runs backend contract tests
scripts/serve-local.sh       starts the local development server
specs/001-weekly-timesheet/  Spec Kit feature artifacts
```

## Prerequisites

- Linux or another Unix-like environment
- GNU Cobol 3.x with `cobc` available on `PATH`
- Python 3 for the local development server
- POSIX shell utilities

On Debian or Ubuntu, GNU Cobol can usually be installed with:

```sh
sudo apt install gnucobol python3
```

## Build And Compile

Compile the Cobol backend from the repository root:

```sh
./scripts/build.sh
```

This compiles these source files:

- `backend/cgi/projects.cob` to `backend/cgi/projects`
- `backend/cgi/timesheet.cob` to `backend/cgi/timesheet`
- `backend/cgi/calendar.cob` to `backend/cgi/calendar`

The generated CGI binaries are intentionally ignored by Git.

To compile a single handler manually, use the same options as the build script:

```sh
cobc -x -free -Wall -o backend/cgi/projects backend/cgi/projects.cob
```

## Test

Run the backend contract tests:

```sh
./scripts/test-backend.sh
```

The test script rebuilds the CGI handlers and runs every `backend/tests/contract/test_*.sh` script. These tests exercise project creation, validation errors, timesheet entry saves, correction history, weekly total limits, and calendar output.

The tests reset the local files under `data/`, so do not run them against data you want to preserve.

## Launch Locally

Start the local web server:

```sh
./scripts/serve-local.sh
```

Then open:

```text
http://127.0.0.1:8000/frontend/
```

To use another port:

```sh
PORT=8765 ./scripts/serve-local.sh
```

The local server serves static files from `frontend/` and maps `/cgi-bin/projects`, `/cgi-bin/timesheet`, and `/cgi-bin/calendar` to the compiled Cobol handlers in `backend/cgi/`.

## Data Files

Replicobol stores local readable data in pipe-delimited files:

- `data/projects.dat`
- `data/weekly-entries.dat`
- `data/weekly-entry-corrections.dat`

For deployment, make sure the process running the CGI handlers can read and write these files. Back them up before running tests or replacing the application directory.

## Deploy

Replicobol can be deployed anywhere that can serve static files and execute local CGI programs.

For a small private deployment, the simplest path is to run the bundled Python bridge on the host and put a reverse proxy such as Nginx or Apache in front of it for TLS and access control.

```sh
PORT=8000 ./scripts/serve-local.sh
```

Run that command from the repository root with a process supervisor such as systemd. Configure the reverse proxy to forward traffic to `http://127.0.0.1:8000/`. The application will then serve the frontend at `/frontend/` and backend routes at `/cgi-bin/`.

The bundled bridge is intentionally small and local-first. For an internet-facing deployment, add authentication, TLS, backups, and normal host hardening before exposing it beyond a trusted network.

### 1. Build On The Target Host

Install GNU Cobol and compile the handlers:

```sh
./scripts/build.sh
```

The target host must execute the generated binaries with the repository root as the working directory, because the current handlers read and write `data/*.dat` using relative paths.

### 2. Serve The Frontend

Serve `frontend/` as static web content. The JavaScript frontend calls relative backend endpoints under `/cgi-bin/`, so the frontend and CGI routes should be exposed from the same origin.

### 3. Expose The CGI Handlers

Configure the web server so these routes execute the matching binaries:

```text
/cgi-bin/projects   -> backend/cgi/projects
/cgi-bin/timesheet  -> backend/cgi/timesheet
/cgi-bin/calendar   -> backend/cgi/calendar
```

The CGI environment must provide the usual variables used by the handlers:

- `REQUEST_METHOD`
- `QUERY_STRING`
- `CONTENT_LENGTH`
- `CONTENT_TYPE`

For POST requests, the form-encoded body must be passed to the handler on standard input.

### 4. Configure File Permissions

The web server user needs:

- execute permission on `backend/cgi/projects`, `backend/cgi/timesheet`, and `backend/cgi/calendar`
- read permission on `frontend/` and `backend/cgi/`
- read and write permission on `data/`

### 5. Smoke Test The Deployment

After deployment, verify the backend directly:

```sh
curl 'https://your-host.example/cgi-bin/calendar?start_week=2026-07-27&week_count=2'
```

Then open the frontend URL, create a project, enter a weekly value, reload the page, and confirm the saved value is still visible.

## Development Notes

- The local server in `scripts/serve-local.sh` is intended for development and smoke testing.
- The backend returns JSON envelopes with either `{ "ok": true, "data": ... }` or `{ "ok": false, "error": ... }`.
- Timesheet entries are saved as latest visible values, while changed values append correction records for traceability.
- Blank cells are represented as blank values until a user saves a timesheet entry.