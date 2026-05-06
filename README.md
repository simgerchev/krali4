# krali4

An SSH wargame platform. Each game is a self-contained series of levels — connect via SSH, find a hidden password, unlock the next user, repeat.

## Games

### Thief

9 levels teaching fundamental Linux skills: reading files, handling unusual filenames, navigating directories, identifying file types.

```
ssh thief0@217.154.8.251 -p 30022
```

Password for the first user is `thief0`. No registration required.

| Level | Challenge |
|-------|-----------|
| 0 → 1 | Read a file in the home directory |
| 1 → 2 | Read a file with spaces in its name |
| 2 → 3 | Find a hidden file inside a directory |
| 3 → 4 | Identify the only human-readable file among many |
| 4 → 5 | Find a specific line among hundreds in a file |
| 5 → 6 | Decode a base64-encoded string |
| 6 → 7 | Locate a file by size across nested directories |
| 7 → 8 | Decompress a gzip file to read its contents |
| 8 → 9 | Find the unique line in a file full of duplicates |

Passwords are randomized on every server restart. Shared server — all players connect to the same machine.

## Stack

- **Frontend** — static HTML/CSS/JS served by nginx
- **Games** — Docker containers running OpenSSH, deployed on Kubernetes
- **Infra** — k8s NodePort for SSH access, nginx ingress for the frontend

## Running locally

```bash
docker compose up
```

Frontend at `http://localhost:3001`. SSH game at `localhost:2222`.

## Source

GitLab (primary): https://gitlab.com/simgerchev/krali4  
GitHub (mirror): https://github.com/simeongerchev/krali4
