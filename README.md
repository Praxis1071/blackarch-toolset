# BlackArch Toolset

A Turkish-to-English? No — a curated command reference for learning about, installing, and using selected security tools on BlackArch and Arch Linux.

## 📦 Contents

| File | Description |
|---|---|
| `HACKKOMUT.txt` | Tool usage commands, examples, and important notes |
| `HACKTOOLS.txt` | Brief descriptions and categories of the tools |
| `blackarch.txt` | Package list used during installation |
| `install.sh` | Installation script that installs the toolset automatically |
| `uninstall.sh` | Script that separately removes packages and the BlackArch repository configuration |
| `LICENSE` | MIT license |

## 🚀 Installation

This project is intended for Arch Linux- and BlackArch-based systems.

### 1. Clone the repository

```bash
git clone https://github.com/Praxis1071/blackarch-toolset.git
cd blackarch-toolset
```

### 2. Install the tools

```bash
chmod +x install.sh uninstall.sh
sudo ./install.sh
```

The `install.sh` script:

- Checks for `pacman` and the required helper commands.
- Checks whether the BlackArch repository is already configured on the system.
- If the BlackArch repository is missing, verifies the official `strap.sh` script before running it and asks for your confirmation.
- Installs the tools listed in the package list using `pacman`.
- Avoids unnecessarily reinstalling packages that are already installed.

**About system upgrades:** To avoid a partial upgrade on Arch Linux, the installation script runs `pacman -Syu` after obtaining your consent. This command may upgrade other updatable packages on your system, not just the toolset packages. Back up important data before proceeding, and carefully review the transaction summary shown by pacman. The script does not run `pacman -Sy` on its own; partial upgrades performed this way are unsupported on Arch Linux.

> **Note:** Before adding the BlackArch repository, review your system's existing packages and repository configuration.

## 🧹 Uninstallation

To remove the installed toolset:

```bash
chmod +x uninstall.sh
sudo ./uninstall.sh
```

The script asks about these two actions **separately**:

1. Removing the toolset packages.
2. Removing the BlackArch repository configuration.

The default answer to both prompts is **No**. Before removing the repository configuration, the script creates a timestamped backup of `/etc/pacman.conf`.

> **Warning:** The package-removal option uses `pacman -Rns`, which may also remove dependencies that are no longer required. Review the package list shown before proceeding.

## 🛠️ How to use the tools

When learning a tool, the recommended order is:

1. Read **`HACKTOOLS.txt`** to understand what the tool does.
2. Look for usage examples in **`HACKKOMUT.txt`**.
3. Check the tool's own help output:
   ```bash
   tool --help
   ```
4. Start with a safe test on your own system or in an isolated lab.

For example, for Nmap:

```bash
nmap --help
```

Command-line options can vary between tool versions, so the help output for the installed version should take precedence.

## 🔎 Tool coverage

The toolset includes selected tools from the following areas:

- 🌐 Network discovery and security
- 🕸️ Web application security
- 🔍 OSINT and reconnaissance
- 📡 Wireless network security
- 🧪 Fuzzing and security testing
- 🗂️ Metadata analysis and information gathering
- 🔐 Authentication and security auditing
- 🛠️ Utility and analysis tools

This project is **not the complete BlackArch tool catalog**. Its goal is to bring selected tools together in one place, with clear command examples.

## 📚 How to use the files

**If you're just getting started:**

`HACKTOOLS.txt` → learn what a tool does  
↓  
`HACKKOMUT.txt` → review basic commands  
↓  
`tool --help` → learn the available options  
↓  
Practice safely in your own lab

**If you want to install the tools:**

`blackarch.txt` → review the packages to be installed  
↓  
`install.sh` → run the automated installation

## 🔐 Authorized use

Some tools in this project can perform active scanning, traffic manipulation, load or stress testing, wireless attack simulation, or authentication testing.

Use these tools only on:

- systems you own,
- your own labs,
- CTF and training environments, or
- systems for which you have explicit authorization.

Do not scan, test, or modify traffic on systems or networks without authorization.

Do not use real passwords, API keys, tokens, cookies, or other secrets in examples.

## ⚠️ Keeping information up to date

BlackArch packages and upstream projects may change over time. If a command does not behave as expected, first check:

```bash
tool --help
```

Consulting the tool's current upstream documentation is also one of the most reliable ways to identify version-specific command-line changes.

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.
