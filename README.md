# BlackArch Toolset Commands

A curated **80-package BlackArch security toolset** for Linux security learning, research, and authorized testing.

This repository is a personal command and tool reference. It focuses on a selected set of tools rather than trying to reproduce the complete BlackArch repository.

## ✨ What is included?

- **80 selected packages** from the current personal toolset
- Organized command examples in `HACKKOMUT.txt`
- Short tool descriptions and categories in `HACKTOOLS.txt`
- Package inventory in `blackarch.txt`
- One-shot installer in `install.sh`
- Historical notes in `ARŞİV/`
- Sanitized example domains, addresses, and credentials
- MIT licensed documentation

## 📁 Repository structure

```text
blackarch-toolset-commands/
├── README.md
├── LICENSE
├── HACKKOMUT.txt
├── HACKTOOLS.txt
├── blackarch.txt
├── install.sh
└── ARŞİV/
    ├── metasploit.txt
    └── win7sızma.txt
```

### File guide

| File | Purpose |
|---|---|
| `HACKKOMUT.txt` | Detailed command reference and practical examples |
| `HACKTOOLS.txt` | Tool descriptions, categories, and quick orientation |
| `blackarch.txt` | The exact package list used by this toolset |
| `install.sh` | Installs the packages listed in `blackarch.txt` |
| `ARŞİV/` | Older material kept for historical/reference purposes |

## 🚀 Installation

`install.sh` is designed for **Arch Linux systems where the BlackArch repository is already configured**.

Clone the repository, enter it, and run:

```bash
chmod +x install.sh
sudo ./install.sh
```

The installer uses `pacman` and installs only the packages belonging to this repository's existing toolset.

If a package cannot be found, check the BlackArch repository configuration and current package availability before troubleshooting the individual package.

## 🧭 Recommended workflow

If you are learning a tool for the first time:

1. Find the tool in `HACKTOOLS.txt`.
2. Read its short description and category.
3. Open its section in `HACKKOMUT.txt`.
4. Start with the tool's own help output:
   ```bash
   tool --help
   ```
5. Test it in your own lab or another explicitly authorized environment.

This separation keeps the repository easy to navigate:

```text
HACKTOOLS.txt
      ↓
What is this tool?
      ↓
HACKKOMUT.txt
      ↓
How do I use it?
      ↓
install.sh
      ↓
How do I install the toolset?
```

## 🎯 Scope

This is intentionally a **curated personal toolset**, not a complete BlackArch package catalogue.

BlackArch itself contains a much larger collection of security tools. This repository deliberately stays limited to the tools already selected for this project.

The goal is quality and usability of the existing toolset rather than continuously adding unrelated packages.

## 🔐 Safety and authorization

The tools documented here can perform active security testing and can affect systems or networks.

Use them only on:

- systems you own,
- your own laboratory environments, or
- systems for which you have explicit authorization.

Never use the examples as permission to test third-party infrastructure.

Examples in the repository are sanitized and use documentation/example values where possible. Never commit real passwords, API keys, session cookies, access tokens, private addresses, or other credentials.

## 🔄 Tool versions

BlackArch packages and upstream tools change over time.

A command that worked with one version may behave differently with another. When something does not work as expected:

```bash
tool --help
```

Then consult the tool's current upstream documentation.

## 📚 Official BlackArch resources

For BlackArch installation guidance, package information, and the complete tool catalogue, use the official BlackArch documentation and website.

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
