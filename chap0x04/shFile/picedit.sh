#!/usr/bin/env bash

# 图片批处理脚本

# help
function help {
cat <<EOF
	           ----------------picedit.sh-----------------
	TIPS: Before use, please make sure you've installed ImageMagick,
	      If not, you can use command "sudo apt install imagemagick" to get it.
[OPTION]
	[-d directory] [-c quanlity_compress] [-r resolution_compress] 
	[-w watermark] [-p prefix] [-s suffix] [-t transformjpg] [-h help]
[DESCRIPTION] 
	-d <path>,	the directory path of images
	-c <quality>,	image quality compression in jpeg format
	-r <size>,	compress the resolution of jpeg/png/svg images while maintaining the original aspect ratio
	-w <text>,	add watermarks
	-p <prefix>,	add prefix to images' names
	-s <suffix>,	add suffix to images' names
	-t,		transform png/svg images into jpg images
	-h,		show help information

EOF
}

# 对jpeg图片进行质量压缩
function quality_compress {
	percentage=$2 # 图片压缩比例
	
	[ -d "pic_c" ] || mkdir "pic_c" # 建立处理后文件夹

	for img in "$1"*.jpg; do
#	for img in 'ls $1'; do
#		imgtype="${file##*.}" # 获得图片格式
#		if [[ $imgtype == "jpg" ]] || [[ $imgtype == "jpeg" ]];then
		fullname="$(basename "$img")"	#删除路径
		filename="${fullname%.*}"	#得到文件名
		convert "$img" -quality "$percentage" ./pic_c/"$filename".'jpg'
#		fi

	done

	echo "success in JPEG quality compressing."
}

# jpeg/png/svg保持宽高比并压缩分辨率
function resolution_compress {
	csize=$2 # 压缩比例
	[ -d "pic_r" ] || mkdir "pic_r" # 建立处理后文件夹

	for img in $(find "$1" -regex  '.*\.jpg\|.*\.svg\|.*\.png'); do
#	for img in 'ls $1';do
#		imgtype="${file##*.}" # 获得图片格式
#		if [[ $imgtype == "jepg" ]] || [[ $imgtype == "png" ]] || [[ $imgtype == "svg" ]];then
		fullname="$(basename "$img")"
                filename="${fullname%.*}"
 		imgtype="${fullname##*.}"
		convert "$img" -resize "$csize" ./pic_r/"$filename"."$imgtype"
#		fi
	done

	echo "success in resolution compressing."
}

# 批量添加自定义水印
function watermark {
	text=$2 # 自定义水印内容

	[ -d "pic_w" ] || mkdir "pic_w" # 建立处理后文件夹

	for img in $(find "$1" -regex  '.*\.jpg\|.*\.svg\|.*\.png'); do
	#for img in 'ls $1';do
#	imgtype=${file##*.} # 获得图片格式
#	if [[ $imgtype == "jpg" ]] || [[ $imgtype == "png" ]] || [[ $imgtype == "svg" ]];then
		fullname="$(basename "$img")"
		filename="${fullname%.*}"
		imgtype="${fullname##*.}"
		convert "$img" -fill red -pointsize 15 -draw "text 5,5 '$text'" ./pic_w/"$filename"."$imgtype"
#		fi
	done

	echo "success in adding watermark."
}

# 批量重命名（统一添加前缀/后缀）
function rename_pre {
	pre=$2 # 前缀名
	[ -d "pic_p" ] || mkdir "pic_p" # 建立处理后文件夹

	for img in "$1"*.*;do
		fullname="$(basename "$img")"
		filename="${fullname%.*}"
		typename="${fullname##*.}"
		cp "$img" ./pic_p/"$pre""$filename"."$typename"
	done

	echo "success in adding prefix."
}

function rename_suf {
	suf=$2 # 后缀名
	[ -d "pic_s" ] || mkdir "pic_s" # 建立处理后文件夹

	for img in "$1"*.*;do
		fullname="$(basename "$img")"
		filename="${fullname%.*}"
		typename="${fullname##*.}"
		cp "$img" ./pic_s/"$filename""$suf"."$typename"
	done

	echo "success in adding suffix."
}

# png/svg转换为jpg
function transformjpg {
	[ -d "pic_t" ] || mkdir "pic_t" # 建立处理后文件夹

	for img in $(find "$1" -regex '.*\.png\|.*\.svg');do
#		imgtype="${file##*.}" # 获得图片格式
#		if [[ $imgtype == "png" ]] || [[ $imgtype == "svg" ]];then
		fullname="$(basename "$img")"
		filename="${fullname%.*}"
		convert "$img" ./pic_t/"$filename"".jpg"
#		fi
	done

	echo "success in JPG transforming."
}

# main
path=""

if [[ "$#" -lt 1 ]]; then
	echo "Please enter some arguements, or enter -h to get help."
else
	while [[ "$#" -ne 0 ]]; do
		case "$1" in
			"-d")
				path="$2"
				shift 2
				;;
			"-c")
				if [[ "$2" != '' ]]; then
					quality_compress "$path" "$2"
					shift 2
				else
					echo "Please enter the quality you wanna compress."
				fi
				;;

			"-r")
				if [[ "$2" != '' ]]; then
					resolution_compress "$path" "$2"
					shift 2
				else
					echo "Please enter the resize rate."
				fi
				;;

			"-w")
				if [[ "$2" != '' ]]; then
					watermark "$path" "$2"
					shift 2
				else
					echo "Please enter the watermark."
				fi
				;;

			"-p")
				if [[ "$2" != '' ]]; then
					rename_pre "$path" "$2"
					shift 2
				else
					echo "Please enter the prefix."
				fi
				;;

			"-s")
				if [[ "$2" != '' ]]; then
					rename_suf "$path" "$2"
					shift 2
				else
					echo "Please enter the suffix."
				fi
				;;

			"-t")
				transformjpg "$path"
				shift
				;;

			"-h")
				help
				shift
				;;
		esac
	done
fi
