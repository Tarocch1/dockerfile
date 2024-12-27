#!/usr/bin/env bash

set -Eeuo pipefail

# 添加用户
add_user() {
  # 配置文件路径
  local cfg="$1"
  local username="$2"
  local uid="$3"
  local groupname="$4"
  local gid="$5"
  local password="$6"

  # 如果用户组不存在则添加
  if ! getent group "$groupname" &>/dev/null; then
    echo "Group $groupname does not exist, creating group..."
    groupadd -o -g "$gid" "$groupname" > /dev/null || { echo "Failed to create group $groupname"; return 1; }
  else
    # 检查 gid 是否正确
    local current_gid
    current_gid=$(getent group "$groupname" | cut -d: -f3)
    if [[ "$current_gid" != "$gid" ]]; then
      echo "Group $groupname exists but GID differs, updating GID..."
      groupmod -o -g "$gid" "$groupname" > /dev/null || { echo "Failed to update GID for group $groupname"; return 1; }
    fi
  fi

  # 如果用户不存在则添加
  if ! id "$username" &>/dev/null; then
    echo "User $username does not exist, creating user..."
    useradd -o -M -N -r -d /tmp -s /sbin/nologin -g "$groupname" -u "$uid" -c "Samba User" "$username" || { echo "Failed to create user $username"; return 1; }
  else
    # 检查 uid 是否正确
    local current_uid
    current_uid=$(id -u "$username")
    if [[ "$current_uid" != "$uid" ]]; then
      echo "User $username exists but UID differs, updating UID..."
      usermod -o -u "$uid" "$username" > /dev/null || { echo "Failed to update UID for user $username"; return 1; }
    fi

    # 更新用户所在的组
    usermod -g "$groupname" "$username" > /dev/null || { echo "Failed to update group for user $username"; return 1; }
  fi

  # 检查用户是否是 Samba 用户
  if pdbedit -s "$cfg" -L | grep -q "^$username:"; then
    echo -e "$password\n$password" | smbpasswd -c "$cfg" -s "$username" > /dev/null || { echo "Failed to update Samba password for $username"; return 1; }
  else
    echo -e "$password\n$password" | smbpasswd -a -c "$cfg" -s "$username" > /dev/null || { echo "Failed to add Samba user $username"; return 1; }
    echo "User $username has been added to Samba and password set."
  fi

  return 0
}

# 默认用户组
group="smb"
# 默认共享地址
share="/storage"
# 配置文件路径
config="/etc/samba/smb.conf"
# 多用户配置文件路径
users="/etc/samba/users.conf"

mkdir -p "$share" || { echo "Failed to create directory $share"; exit 1; }

# 检查是否传入了配置文件
if [ -f "$config" ] && [ -s "$config" ]; then
  echo "Using provided configuration file: $config."
else
  config="/etc/samba/smb.tmp"
  template="/etc/samba/smb.default"

  # 删除之前的配置文件
  rm -f "$config"
  # 使用模版生成配置文件
  cp "$template" "$config"

  # 设置共享目录名称
  if [ -n "$NAME" ] && [[ "${NAME,,}" != "data" ]]; then
    sed -i "s/\[Data\]/\[$NAME\]/" "$config"
  fi

  # 处理只读配置
  if [[ "$RW" == [Ff0]* ]]; then
    sed -i "s/^\(\s*\)writable =.*/\1writable = no/" "$config"
    sed -i "s/^\(\s*\)read only =.*/\1read only = yes/" "$config"
  fi
fi

# 检查是否传入了多用户配置文件
if [ -f "$users" ] && [ -s "$users" ]; then
  while read -r line; do
    # 跳过注释
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

    username=$(echo "$line" | cut -d':' -f1)
    uid=$(echo "$line" | cut -d':' -f2)
    groupname=$(echo "$line" | cut -d':' -f3)
    gid=$(echo "$line" | cut -d':' -f4)
    password=$(echo "$line" | cut -d':' -f5)

    # 检查所有字段是否都存在
    if [[ -z "$username" || -z "$uid" || -z "$groupname" || -z "$gid" || -z "$password" ]]; then
      echo "Skipping incomplete line: $line"
      continue
    fi

    # 添加用户
    add_user "$config" "$username" "$uid" "$groupname" "$gid" "$password" || { echo "Failed to add user $username"; exit 1; }
  done < "$users"
else
  add_user "$config" "$USER" "$UID" "$group" "$GID" "$PASS" || { echo "Failed to add user $USER"; exit 1; }
fi

exec smbd --configfile="$config" --interactive --debug-stdout --debuglevel=$LOG_LEVEL --no-process-group
