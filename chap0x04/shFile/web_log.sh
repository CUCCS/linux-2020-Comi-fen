#!/usr/bin/env bash

# 获取web日志，如果存在，进行解压
if [[ ! -f "web_log.tsv.7z" ]];then
        wget https://c4pr1c3.github.io/LinuxSysAdmin/exp/chap0x04/web_log.tsv.7z
fi

if [[ ! -f "web_log.tsv" ]];then
        7za x web_log.tsv.7z
fi

# 帮助信息
function helpInfo {
cat<<EOF
		--------------wob_log.sh---------------
	
	TIPS:Before use, please make sure you've downloaded 7z tool
	     If not, you can use command "sudo apt install p7zip-full" to get it.
[OPTIONS]
	[-o host100] [-i ip100] [-u url100]
	[-r response] [-t response4xx] [-s url_host100]
[DESCRIPTION]
	-o,		top 100 hosts
	-i,		top 100 ip
	-u,		top 100 URLs
	-r,		total number and rates of response code
	-t,		top 10 URLs for 400 response code
	-s<url>,	top 100 hosts in specific URL
	-h,		help
EOF
}

# 统计访问来源主机TOP 100和对应出现总次数
function host100 {
	# 用awk抓取文件第一行以后的第一项host
	# sort -nr 按数值大小逆序
	# uniq -c 显示重复次数
	# head 显示100行
	echo "====== Top 100 hosts ======"
	cat web_log.tsv | awk -F "\t" '{if (NR > 1) {print $1} }' | sort | uniq -c | sort -nr | head -100
}

# 统计访问来源IP的TOP 100和对应次数
function ip100 {
	echo "====== Top 100 IP ======"
	cat web_log.tsv | awk -F "\t" '{if (NR > 1) {print $1} }' | grep -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort | uniq -c | sort -nr | head -100
}

# 统计最频繁被访问的100条URL
function url100 {
	echo "====== Top 100 URL ======"
	cat web_log.tsv | awk -F "\t" '{if (NR > 1) {print $5} }' | sort | uniq -c | sort -nr | head -100
}

# 统计不同响应状态码的出现次数和对应百分比
function response {
	echo "====== Numbers and Rates of Response Code ======"
	cat web_log.tsv | awk -F "\t" 'BEGIN{ans=0}{a[$6]++;ans++} END{for(i in a) {printf ("%-10s%-10d%10.3f\n",i,a[i],a[i]*100/ans)}}'
}

# 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
function response4xx {
	echo "====== Top 10 URL for 4xx code ======"
	echo "403:"
	cat web_log.tsv | awk -F "\t" '{ if ($6=="403") {print $5} }' | sort | uniq -c | sort -nr | head -10
	echo -e "\n404:"
	cat web_log.tsv | awk -F "\t" '{ if ($6=="404") {print $5} }' | sort | uniq -c | sort -nr | head -10
}

# 给定URL输出TOP 100访问来源主机
function url_host100 {
	URL="$1"
	echo "====== Top 100 hosts in specific URL ======"
	echo "The URL:$URL"
	cat web_log.tsv | awk -F "\t" '{ if ($5=="'$URL'") {print $1} }' | sort | uniq -c | sort -nr | head -100
}

if [[ $# -lt 1 ]];then
        echo "Please enter your command."
else
        while [[ $# -ne 0 ]];do
                case $1 in
                        "-o")
                                host100
                                shift
                                ;;
                        "-i")
                                ip100
                                shift
                                ;;
                        "-u")
                                url100
                                shift
                                ;;
                        "-r")
                                response
                                shift
                                ;;
                        "-t")
                                response4xx
                                shift
                                ;;
                        "-s")
                                url_host100 $2
                                shift 2
				;;
			"-h")
				helpInfo
				shift
				;;
                esac
        done
fi

