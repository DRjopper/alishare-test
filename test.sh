#!/bin/bash

# 获取当前日期的缩写
DATE=$(date +'%y.%m.%d')

# 输入文件路径
INPUT_FILE="/etc/xiaoya/alishare_list.txt"

# 输出文件路径，包括日期缩写
OUTPUT_FILE="/etc/xiaoya/alishare_list_test($DATE).txt"

# 日志文件路径
LOG_FILE="/etc/xiaoya/test.log"

# 创建输出文件并清空内容
> "$OUTPUT_FILE"

# 读取输入文件的第一行并写入输出文件
head -n 1 "$INPUT_FILE" >> "$OUTPUT_FILE"

# 逐行处理输入文件，从第二行开始
tail -n +2 "$INPUT_FILE" | while IFS='    ' read -r a b c; do
  # 构建 curl 命令
  curl_command="curl -i -X POST --data-raw '{\"share_id\":\"$b\"}' 'https://api.aliyundrive.com/adrive/v3/share_link/get_share_by_anonymous?share_id=$b'"

  # 发送 curl 请求并将结果保存到临时文件
  tmp_output_file="/tmp/curl_output.txt"
  eval "$curl_command" > "$tmp_output_file"

  # 获取当前日期时间
  current_datetime=$(date +'%Y-%m-%d %H:%M:%S')

  # 检查是否成功
  if grep -q "HTTP/2 200" "$tmp_output_file"; then
    # 请求成功，将结果保存到输出文件，保持原格式
    echo -e "$a    $b    $c" >> "$OUTPUT_FILE"
  else
    # 请求失败，跳过该行并将错误信息写入日志，包括日期时间戳
    echo "[$current_datetime] Skipping entry with error: $a    $b    $c" | tee -a "$LOG_FILE"
  fi

  # 删除临时文件
  rm "$tmp_output_file"

  # 设置1秒的延迟
  sleep 1
done

# 读取输入文件的最后一行并写入输出文件
tail -n 1 "$INPUT_FILE" >> "$OUTPUT_FILE"
