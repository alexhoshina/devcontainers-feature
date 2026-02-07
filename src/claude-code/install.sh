#!/bin/sh
set -e
. ./util.sh

# 1. 检查是否已安装
remote_user_has_command claude && {
    version=$(remote_user_run 'claude -v')
    echo "Claude Code $version is already installed"
    exit 0
}

# 2. 检查依赖
has_command curl || {
    echored "ERROR: This feature requires curl to be installed."
    exit 1
}

# 3. Alpine 兼容性处理
ensure_bash_on_alpine
if os_alpine ; then 
    apk add --no-cache libgcc libstdc++ ripgrep
fi

# 4. 安装 Claude Code
echo "Installing Claude Code..."
remote_user_run 'curl -fsSL https://claude.ai/install.sh | bash'
add_to_user_profiles 'export PATH="$HOME/.local/bin:$PATH"'

# 5. 配置 Onboarding (你的修改)
echo "Configuring Claude Code onboarding..."
# 使用 remote_user_run 确保以开发用户身份创建文件，避免权限问题
# 如果文件存在，> 会直接覆盖
remote_user_run 'echo "{\"hasCompletedOnboarding\": true}" > ~/.claude.json'

# 6. 验证
remote_user_has_command claude && {
    version=$(remote_user_run 'claude -v')
    echo "Claude Code $version installed successfully"
}