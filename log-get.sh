#!/bin/bash
# logo-get.sh
# 从 logo.dev 获取 logo https://www.logo.dev/dashboard/api-keys
# 用法：bash logo-get.sh domains.txt
# 输出：result 目录下的 logo 图片和 logos.csv 文件
# 要求：安装 curl

# 配置  
API_TOKEN="[YOUR lgo.dev TOKEN]"
OUTPUT_DIR="result"
OUTPUT_CSV="$OUTPUT_DIR/logos.csv"
FAILED_LIST="$OUTPUT_DIR/failed.txt"

# 创建结果目录
mkdir -p "$OUTPUT_DIR"

# 写 CSV 头
echo "domain,logo_url" > "$OUTPUT_CSV"
# 清空失败列表
> "$FAILED_LIST"

while read -r line; do
  # 去掉 http(s):// 和路径，只取域名
  domain=$(echo "$line" | sed -E 's#https?://([^/]+).*#\1#')
  # 去掉 www. 前缀
  clean_domain=$(echo "$domain" | sed -E 's/^www\.//')
  
  # 跳过空行
  if [ -z "$clean_domain" ]; then
    continue
  fi

  echo "Fetching logo for: $clean_domain"
  
  # 拼接 logo url
  logo_url="https://img.logo.dev/${clean_domain}?token=${API_TOKEN}&retina=true"

  # 下载图片到 result 目录
  curl -s --fail "$logo_url" -o "${OUTPUT_DIR}/${clean_domain}.png"
  
  # 判断下载是否成功
  if [ $? -eq 0 ]; then
    echo "$clean_domain,$logo_url" >> "$OUTPUT_CSV"
  else
    echo "❌ Failed to download logo for: $clean_domain"
    echo "$clean_domain" >> "$FAILED_LIST"
  fi

done < domains.txt

echo "✅ Done!"
echo "Logos saved in: $OUTPUT_DIR"
echo "CSV file: $OUTPUT_CSV"
echo "Failed list: $FAILED_LIST"
