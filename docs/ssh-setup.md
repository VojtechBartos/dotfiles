# SSH and Git Signing Setup with 1Password

This dotfiles repo configures SSH authentication and git commit signing through 1Password. The automated parts (agent socket, signing key, allowed signers) are handled by the dotfiles. The steps below cover what must be done manually in the 1Password app.

## Prerequisites

- 1Password 8+ installed
- A 1Password account with an SSH key (ED25519 recommended)

## Manual Steps

### 1. Enable the 1Password SSH Agent

1. Open **1Password** → **Settings** → **Developer**
2. Enable **Use the SSH agent**
3. Optionally enable **Ask to add new SSH keys** to auto-import keys

### 2. Enable Git Commit Signing

1. In the same **Developer** settings pane, enable **Sign Git commits with SSH**
2. This makes `op-ssh-sign` available at `/Applications/1Password.app/Contents/MacOS/op-ssh-sign`

### 3. Verify the Signing Key Exists

The dotfiles reference this key for git signing:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmxCbNxbL3lb6ieaECwjSz4wVM/biba8ZJ244MCEMik
```

It should appear as **"SSH ED25519 PostHog / signing"** in 1Password. If it doesn't exist, create or import an ED25519 SSH key in 1Password and update `git/gitconfig.symlink` and `git/gitconfig.allowed_signers.symlink` with the new public key.

## Verification

After running `script/bootstrap` and opening a new shell:

```bash
# SSH agent points to 1Password
echo $SSH_AUTH_SOCK
# Expected: ~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Keys are available
ssh-add -L

# Git signing works (1Password prompts for Touch ID)
git commit --allow-empty -m "test signing"
git log --show-signature -1

# Clean up test commit
git reset HEAD~1
```

## Troubleshooting

- **"Permission denied" on SSH**: Check that the SSH agent is enabled in 1Password Developer settings and restart your shell.
- **"error: Load key" on commit**: The `signingkey` in gitconfig must be the literal public key string, not a file path, when using `op-ssh-sign`.
- **Signature verification fails**: Ensure the public key in `git/gitconfig.allowed_signers.symlink` matches the key used for signing.
