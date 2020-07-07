#!/usr/bin/env bashOB

# 文件批处理脚本-2014世界杯运动员
# Group	Country	Rank Jersey Position  Age SelectionsClub Player Captain
# 分组 国家 等级 ？ 场上位置 年龄 俱乐部 名字 奖项

# 导入数据文件
if [[ ! -f "worldcupplayerinfo.tsv" ]];then
        wget https://c4pr1c3.github.io/LinuxSysAdmin/exp/chap0x04/worldcupplayerinfo.tsv
fi

# 帮助文档
function helpInfo {
cat << EOF
	-----------worldcup.sh----------
[OPTION]
	[-a ageSection] [-p posCount]
	[-n nameMaxMin] [-m ageMaxMin]
[DESCRIPTION]
	-a,	statistical result of age
	-p,	statistical result of position
	-n,	players of longest/shortest name
	-m,	oldest/youngest players

EOF
}

# 统计不同年龄区间范围（20以下，[20-30]，30以上）的球员数量和百分比
function ageSection {
	age=$(awk -F "\t" '{if (NR > 1) {print $6} }' worldcupplayerinfo.tsv ) # 以tab为分割,从第二行开始获取文本第六列，即年龄
	under20=0 # 20以下球员数量
	between=0 # [20-30]球员数量
	above30=0 # 30以上球员数量
	total=0	  # 球员总数

	for a in ${age[@]};do
		if [[ $a -lt 20 ]];then
			under20=$((under20+1))
		elif [[ $a -gt 30 ]];then
			above30=$((above20+1))
		else
			between=$((between+1))
		fi
		total=$((total+1))
	done

	# 计算百分比
	under20_rate=$(printf "%.2f" "$(echo "100*${under20}/$total" | bc -l)")
	between_rate=$(printf "%.2f" "$(echo "100*${between}/$total" | bc -l)")
	above30_rate=$(printf "%.2f" "$(echo "100*${above30}/$total" | bc -l)")

	# 显示结果
	echo "====== Statistical Age ======"
	echo "Age	Number	Rate"
	echo "<20	$under20	${under20_rate}%"
	echo "[20,30]	$between	${between_rate}%"
	echo ">30	$above30	${above30_rate}%"
	echo -e "\n"
}

# 统计不同场上球员数量、百分比
function posCount {
	pos=$(awk -F "\t" '{if (NR > 1) {print $5} }' worldcupplayerinfo.tsv ) # 获取第五列数据即球员位置
	declare -A dic # 使用字典统计,<位置，数量>
	total=0 # 球员总数

	for po in ${pos[@]};do
		if [[ ${dic[$po]} ]];then
			dic[$po]=$((dic[$po]+1))
		else
			dic[$po]=1
		fi
		total=$((total+1))
	done

	# 遍历输出字典内容，显示结果
	echo "====== Statistical Position ======"
	echo "Position	Number	Rate"
	for key in "${!dic[@]}";do
		rate=$(printf "%.2f" "$(echo "100*${dic[$key]}/$total" | bc -l)")
		echo "$key	${dic[$key]}	${rate}%"
	done
	echo -e "\n" 
}

# 名字最长/最短的球员（有同长度可能）
function nameMaxMim {
	OLD_IFS="$IFS"
        string=$(awk -F "\t" '{if (NR > 1) {print $9","} }' worldcupplayerinfo.tsv )
	IFS=","
	players=($string)
	IFS="$OLD_IFS"

	longest=0	# 初始化最长名字的长度
	shortest=100	# 初始化最短名字的长度

	# 找到最长和最短名字的长度
	for p in "${players[@]}";do
		if [[ ${#p} -gt $longest ]];then
			longest=${#p}
		fi
	
		if [[ ${#p} -lt $shortest ]];then
			shortest=${#p}
		fi
	done

	# 输出名字最长和最短的球员
	echo "====== Longest Name ======"
	for p in "${players[@]}";do
		if [[ ${#p} -eq $longest ]];then
			echo $p
		fi
	done
	echo "====== Shortest Name ======"
	for p in "${players[@]}";do
		if [[ ${#p} -eq $shortest ]];then
			echo $p
		fi
	done
}

# 年龄最大/最小的球员（有同名可能）
function ageMaxMim {
	age=$(awk -F "\t" '{if (NR > 1) {print $6} }' worldcupplayerinfo.tsv )
	max=0	# 初始化最大年龄
	min=100	# 初始化最小年龄

	# 获取最小和最大年龄
	for a in ${age[@]};do
		if [[ $a -gt $max ]];then
			max=$a
		fi

		if [[ $a -lt $min ]];then
			min=$a
		fi
	done

	# 输出年龄等于最大最小值的球员
	echo "====== Max Age ======"
	echo -e "Max age:$max\n"
	echo -e "players:\n"
	awk -F "\t" '$6=='$max' {print $9}' worldcupplayerinfo.tsv
	echo -e "\n====== Min Age ======"
	echo -e "Min age:$min\n"
	echo -e "players:\n"
	awk -F "\t" '$6=='$min' {print $9}' worldcupplayerinfo.tsv

}

if [[ $# -lt 1 ]];then
        echo "Please enter some arguments, or enter -h to get help."
else
        while [[ $# -ne 0 ]];do
                case $1 in
                        "-a")
                                ageSection
                                shift
                                ;;
                        "-p")
                                posCount
                                shift
                                ;;
                        "-n")
                                nameMaxMim
                                shift
                                ;;
                        "-m")
                                ageMaxMim
                                shift
                                ;;
                        "-h")
                                helpInfo
                                shift
                                ;;
                esac
        done
fi

