#!/bin/sh
has_command() {
    command -v "$1" > /dev/null 2>&1
}

echored() {
    echo -e "\033[0;31m$@\033[0m"
}

ensure_bash_on_alpine() {
    . /etc/os-release
    if [ "${ID}" = "alpine" ]; then
        apk add --no-cache bash
    fi
}

os_alpine() {
    . /etc/os-release
    [ "${ID}" = "alpine" ]
}

remote_user_run() {
    command_to_run="$1"
    USER_OPTION="${REMOTE_USER_NAME:-automatic}"
    _REMOTE_USER="${_REMOTE_USER:-${USER_OPTION}}"
    if [ "${_REMOTE_USER}" = "auto" ] || [ "${_REMOTE_USER}" = "automatic" ]; then
        _REMOTE_USER="$(id -un 1000 2>/dev/null || echo "vscode")"
    fi
    # 自动获取用户 Home 目录
    if [ -z "$_REMOTE_USER_HOME" ]; then
        _REMOTE_USER_HOME=$(eval echo "~$_REMOTE_USER")
    fi
    su - "${_REMOTE_USER}" -c "sh -lc '$command_to_run'"
}

remote_user_has_command() {
    remote_user_run "command -v \"$1\" > /dev/null 2>&1"
}

add_to_user_profiles() {
    # 确保 Home 目录变量已设置
    if [ -z "$_REMOTE_USER" ]; then
        _REMOTE_USER="$(id -un 1000 2>/dev/null || echo "vscode")"
    fi
    if [ -z "$_REMOTE_USER_HOME" ]; then
        _REMOTE_USER_HOME=$(eval echo "~$_REMOTE_USER")
    fi

    echo "$1" | tee -a \
        "$_REMOTE_USER_HOME/.profile" \
        "$_REMOTE_USER_HOME/.bashrc" \
        "$_REMOTE_USER_HOME/.zshrc" \
        > /dev/null
    
    [ "$(id -u)" -eq 0 ] && chown -R "$_REMOTE_USER:$_REMOTE_USER" "$_REMOTE_USER_HOME"
}