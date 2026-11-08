#!/bin/sh

SCRIPT_NAME="NK"
SCRIPT_VERSION="2611.1"
SCRIPT_YEAR="2024"
SCRIPT_CONFIG_FILE="/opt/etc/`echo "$SCRIPT_NAME" | tr '[:upper:]' '[:lower:]'`.conf"
SCRIPT_UPDATE_URL="https://raw.githubusercontent.com/rino-soft-lab/nk/refs/heads/main/nk.sh"
SCRIPT_SETTINGS=""
ACC_BG=$'\033[104m';ACC_CLR=$'\033[94m';DRK_CLR=$'\033[30m';ERR_BG=$'\033[101m';ERR_CLR=$'\033[91m';INAC_CLR=$'\033[90m';LGHT_CLR=$'\033[97m';OK_BG=$'\033[42m';OK_CLR=$'\033[92m';WARN_BG=$'\033[43m';WARN_CLR=$'\033[93m';RST_DFL=$'\033[0m'
PACKAGE_NAME="NFQWS2-keenetic"
PACKAGE_CONFIG_PATH="/opt/etc/nfqws2"
PACKAGE_CONFIG_FILE="$PACKAGE_CONFIG_PATH/nfqws2.conf"
PACKAGE_CONFIG_BACKUP="/tmp/backup_`basename -- "$PACKAGE_CONFIG_FILE"`"
UPDATE_VERSIONS="/tmp/`echo "$SCRIPT_NAME" | tr '[:upper:]' '[:lower:]'`.upd"

function space	#1-ориентация (h/v)	#2-размер	#3-заполняющий символ
	{	# 2611.1
	if [ "$1" = "v" ];then
		if [ -n "$3" ];then
			yes "$3" | head -n "$2"
		else
			yes " " | head -n "$2"
		fi
	else
		if [ -n "$3" ];then
			printf '%*s' "$2" "" | tr ' ' "$3"
		else
			printf '%*s' "$2" ""
		fi
	fi
	}

function textBlock	#1-текст	#2-выравнивание	#3-граница	#4-отступ
	{	# 2611.1
	if [ -n "$COLUNS" ];then
		local BOARDER="$3"
		local INDENT="$4"
		local WIDTH="$((COLUNS - BOARDER * 2 - INDENT * 2))"
		local SIZE="${#1}"
		if [ -n "$BOARDER" ];then
			local INDENT="`space "h" "$BOARDER"`"
		else
			local INDENT=""
		fi
		if ! [ "$SIZE" -gt "$WIDTH" ];then
			local SIZE="$((SIZE + BOARDER * 2))"
			echo -e "$SIZE\n$INDENT$1$INDENT"
		else
			local ROWS="1"
			while [ "$WIDTH" -lt "$(((SIZE + ROWS - 1) / ROWS))" ];do
				local ROWS="$((ROWS + 1))"
			done
			local SIZE="$(((SIZE + ROWS - 1) / ROWS))"
			local STRING=""
			local SPACE=""
			REPLY=""
			IFS=$' '
			for WORD in $1;do
				local WORD_SIZE="${#WORD}"
				local STRING_SIZE="${#STRING}"
				if [ "$((STRING_SIZE + WORD_SIZE + 1))" -gt "$SIZE" ];then
					if [ "$2" = "c" ];then
						local STRING="$INDENT`space "h" "$(((SIZE - STRING_SIZE) / 2))"`$STRING`space "h" "$(((SIZE - STRING_SIZE + 1) / 2))"`$INDENT"
					elif [ "$2" = "r" ];then
						local STRING="$INDENT`space "h" "$((SIZE - STRING_SIZE))"`$STRING$INDENT"
					else
						local STRING="$INDENT$STRING`space "h" "$((SIZE - STRING_SIZE))"`$INDENT"
					fi
					REPLY="$REPLY\n$STRING"
					local STRING="$WORD"
				else
					local STRING="$STRING$SPACE$WORD"
					local SPACE=" "
				fi
			done
			local STRING_SIZE="${#STRING}"
			if [ "$2" = "c" ];then
				local STRING="$INDENT`space "h" "$(((SIZE - STRING_SIZE) / 2))"`$STRING`space "h" "$(((SIZE - STRING_SIZE + 1) / 2))"`$INDENT"
			elif [ "$2" = "r" ];then
				local STRING="$INDENT`space "h" "$((SIZE - STRING_SIZE))"`$STRING$INDENT"
			else
				local STRING="$INDENT$STRING`space "h" "$((SIZE - STRING_SIZE))"`$INDENT"
			fi
			local SIZE="$((SIZE + BOARDER * 2))"
			echo -e "$SIZE\n$REPLY\n$STRING" | grep -v '^$'
		fi
	fi
	}

function headLine	#1-заголовок	#2-полоса под заголовком (/скрыть)	#3-экран пустых строк (добавить/)	#4-индикация (включена/)	#5-состояние (/альтернативное)	#6-основной текст	#7-основной цвет	#8-альтернативный текст	#9-альтернативный цвет
	{	# 2611.1
	COLUNS="`stty -a | awk -F"; " '{print $3}' | grep "columns" | awk -F" " '{print $2}'`"
	if [ -n "$3" ];then
		local ROWS="`stty -a | awk -F"; " '{print $2}' | grep "rows" | awk -F" " '{print $2}'`"
		echo "`space "v" "$ROWS" " "`"
	elif [ -n "$1" ];then
		clear
	fi
	if [ -n "$4" ];then
		if [ -z "$5" ];then
			local STATUS="$6"
			local COLOR="$7"
		else
			local STATUS="$8"
			local COLOR="$9"
		fi
		local TEXT="`textBlock "$1" "l" "1"`"
		local TEXT_SIZE="`echo "$TEXT" | sed -n '1p;q'`"
		local TEXT="`echo "$TEXT" | tail -n +2`"
		local STATUS="`textBlock "$STATUS" "r" "1"`"
		local STATUS_SIZE="`echo "$STATUS" | sed -n '1p;q'`"
		local STATUS="`echo "$STATUS" | tail -n +2`"
		local VARIABLE="$((COLUNS - TEXT_SIZE - STATUS_SIZE))"
		if [ "$VARIABLE" -gt "0" ];then
			echo -e "$TEXT" | awk -v BEGINING="$COLOR`space "h" "$(((COLUNS - TEXT_SIZE - STATUS_SIZE) / 2))"`" -v ENDING="`space "h" "$(((COLUNS - TEXT_SIZE - STATUS_SIZE + 1) / 2))"`$STATUS$RST_DFL" '{print BEGINING $0 ENDING}'
		else
			local VARIABLE="$((COLUNS - TEXT_SIZE))"
			echo -e "$TEXT" | awk -v BEGINING="$COLOR`space "h" "$(((COLUNS - TEXT_SIZE) / 2))"`" -v ENDING="`space "h" "$(((COLUNS - TEXT_SIZE + 1) / 2))"`$RST_DFL" '{print BEGINING $0 ENDING}'
			
			local VARIABLE="$((COLUNS - STATUS_SIZE))"
			echo -e "$STATUS" | awk -v BEGINING="$COLOR`space "h" "$VARIABLE"`" -v ENDING="$RST_DFL" '{print BEGINING $0 ENDING}'
		fi
	else
		local TEXT="`textBlock "$1" "c"`"
		local SIZE="`echo "$TEXT" | sed -n '1p;q'`"
		local TEXT="`echo "$TEXT" | tail -n +2`"
		echo -e "$TEXT" | awk -v BEGINING="$LGHT_CLR$ACC_BG`space "h" "$(((COLUNS - SIZE) / 2))"`" -v ENDING="`space "h" "$(((COLUNS - SIZE + 1) / 2))"`$RST_DFL" '{print BEGINING $0 ENDING}'
	fi
	if [ -n "$1" -a -z "$2" ];then
		echo ""
	fi
	}

function showMessage	#1-текст	#2-тип (e/o/w/)
	{	# 2611.1
	if [ "$2" = "e" ];then
		local COLOR="$DRK_CLR$ERR_BG"
	elif [ "$2" = "o" ];then
		local COLOR="$DRK_CLR$OK_BG"
	elif [ "$2" = "u" ];then
		local COLOR="\033[96m"
	elif [ "$2" = "w" ];then
		local COLOR="$DRK_CLR$WARN_BG"
	else
		local COLOR="$LGHT_CLR$ACC_BG"
	fi
	local TEXT="`textBlock "$1" "c" "2" "1"`"
	local SIZE="`echo "$TEXT" | sed -n '1p;q'`"
	local TEXT="`echo "$TEXT" | tail -n +2`"
	echo -e "`space "h" "$SIZE"`\n$TEXT\n`space "h" "$SIZE"`" | awk -v BEGINING="`space "h" "$(((COLUNS - SIZE) / 2))"`$COLOR" -v ENDING="$RST_DFL`space "h" "$(((COLUNS - SIZE + 1) / 2))"`" '{print BEGINING $0 ENDING}'
	}

function showCentered	#1-текст	#2-цвет
	{	# 2611.1
	local TEXT="`textBlock "$1" "c"`"
	local SIZE="`echo "$TEXT" | sed -n '1p;q'`"
	local TEXT="`echo "$TEXT" | tail -n +2`"
	echo -e "$TEXT" | awk -v BEGINING="`space "h" "$(((COLUNS - SIZE) / 2))"`$2" -v ENDING="$RST_DFL`space "h" "$(((COLUNS - SIZE + 1) / 2))"`" '{print BEGINING $0 ENDING}'
	}

function showRighted	#1-текст	#2-цвет
	{	# 2611.1
	local TEXT="`textBlock "$1" "r" "1"`"
	local SIZE="`echo "$TEXT" | sed -n '1p;q'`"
	local TEXT="`echo "$TEXT" | tail -n +2`"
	echo -e "$TEXT" | awk -v BEGINING="`space "h" "$((COLUNS - SIZE))"`$2" -v ENDING="$RST_DFL" '{print BEGINING $0 ENDING}'
	}

function showText	#1-текст	#2-цвет
	{	# 2611.1
	local TEXT=`echo "$1" | awk '{gsub(/^\\\t/,"____")}1'`
	local TEXT=`echo -e "$TEXT"`
	local STRING=""
	local SPACE=""
	IFS=$' '
	for WORD in $TEXT;do
			local WORD_SIZE="${#WORD}"
			local STRING_SIZE="${#STRING}"
			if [ "$((WORD_SIZE + STRING_SIZE + 1))" -gt "$COLUNS" ];then
				echo -e "$2$STRING$RST_DFL" | awk '{gsub(/^____/,"    ")}1'
				local STRING="$WORD"
			else
				local STRING="$STRING$SPACE$WORD"
				local SPACE=" "
			fi
	done
	echo -e "$2$STRING$RST_DFL" | awk '{gsub(/____/,"    ")}1'
	}

function halfColored	#1-обычный текст	№2-цветной текст	#3-цвет
	{	# 2611.1
	if [ -n "$3" ];then
		local COLOR="$3"
	else
		local COLOR="$ACC_CLR"
	fi
	printf "%s%s%s%s\n" "$1" "$COLOR" "$2" "$RST_DFL"
	}

function option	#1-индекс	#2-текст	#3-флаг (/блокировать)	#4-по умолчанию
	{	# 2611.1
	local COLOR="$ACC_CLR"
	if [ -n "$3" ];then
		local COLOR="$INAC_CLR"
		local GRAY="$INAC_CLR"
	fi
	if [ -n "$4" ];then
		local DEFAULT=" $ACC_CLRR(по умолчанию)"
	fi
	echo -e "\t$COLOR$1:$RST_DFL $GRAY$2$DEFAULT$RST_DFL"
	}

function optionList	#1-список
	{	# 2611.1
	echo "$1" | awk -v ACCENT="$ACC_CLR" -v ERROR="$ERR_CLR" -v RESTORE="$RST_DFL" -F"\t" '{printf "%s%s%s%s%s%s%s%s%s%s%s%s%s\n", "\t"ACCENT$1RESTORE$2ACCENT$3RESTORE$4ACCENT$5ERROR$6RESTORE}'
	}

function result	#1-текст	#2-по умолчанию
	{	# 2611.1
	if [ -n "$2" ];then
		local DEFAULT=" $ACC_CLR(по умолчанию)"
	fi
	if [ -n "$1" ];then
		echo -e "$ACC_CLR\t0:$RST_DFL $1$DEFAULT$RST_DFL"
	fi
	echo ""
	read -r -p "$ACC_CLRВаш выбор: $RST_DFL"
	echo ""
	}

function prefill	#1-текст запроса	#2-заполнение	#3-выходная переменная
	{	# 2611.1
	local PROMPT="$1"
	local VALUE="$2"
	local OUTVAR="$3"
	printf '%s%s%s%s' "$ACC_CLR" "$PROMPT" "$RST_DFL" "$VALUE"
	local OLD
	OLD=$(stty -g 2>/dev/null)
	if [ "$?" -ne "0" ];then
		return 1
	fi
	stty -icanon min 1 time 0 -echo
	while true;do
		local C
		C=$(dd bs=1 count=1 2>/dev/null | tr -d '\n')
		if [ -z "$C" ];then
			break
		fi
		local CODE
		CODE=$(printf '%d' "'$C")
		if [ "$CODE" -eq 27 ];then
			stty min 1 time 2
			local C2
			C2=$(dd bs=1 count=1 2>/dev/null)
			stty min 1 time 0
			if [ -z "$C2" ];then
				continue
			fi
			local C2_CODE
			C2_CODE=$(printf '%d' "'$C2")
			if [ "$C2_CODE" -ne 91 ];then
				continue
			fi
			local C3
			C3=$(dd bs=1 count=1 2>/dev/null)
			local C3_CODE
			C3_CODE=$(printf '%d' "'$C3")
			case "$C3_CODE" in
				68)	#Left
					continue
					;;
				67)	#Right
					continue
					;;
				72)	#Home
					VALUE=""
					printf '\r\033[K%s%s%s%s' "$ACC_CLR" "$PROMPT" "$RST_DFL" "$VALUE"
					continue
					;;
				70)	#End
					continue
					;;
				*)
					continue
					;;
			esac
		fi
		if [ "$CODE" -ge 194 ] && [ "$CODE" -lt 224 ];then
			local C2
			C2=$(dd bs=1 count=1 2>/dev/null)
			VALUE="${VALUE}${C}${C2}"
			printf '\r\033[K%s%s\033[0m%s' "$PROMPT" "$VALUE"
		elif [ "$CODE" -ge 224 ] && [ "$CODE" -lt 240 ];then
			local C2 C3
			C2=$(dd bs=1 count=1 2>/dev/null)
			C3=$(dd bs=1 count=1 2>/dev/null)
			VALUE="${VALUE}${C}${C2}${C3}"
			printf '\r\033[K%s%s%s%s' "$ACC_CLR" "$PROMPT" "$RST_DFL" "$VALUE"
		elif [ "$CODE" -ge 240 ] && [ "$CODE" -lt 248 ];then
			local C2 C3 C4
			C2=$(dd bs=1 count=1 2>/dev/null)
			C3=$(dd bs=1 count=1 2>/dev/null)
			C4=$(dd bs=1 count=1 2>/dev/null)
			VALUE="${VALUE}${C}${C2}${C3}${C4}"
			printf '\r\033[K%s%s%s%s' "$ACC_CLR" "$PROMPT" "$RST_DFL" "$VALUE"
		else
			case "$CODE" in
				10|13)
					break
					;;
				8|127)
					if [ -n "$VALUE" ];then
						local LAST
						LAST=$(expr substr "$VALUE" "${#VALUE}" 1)
						local VAL
						VAL=$(printf '%d' "'$LAST")
						while [ "$VAL" -ge 128 ] && [ "$VAL" -lt 192 ] && [ -n "$VALUE" ];do
							VALUE="${VALUE%?}"
							LAST=$(expr substr "$VALUE" "${#VALUE}" 1)
							if [ -n "$LAST" ];then
								VAL=$(printf '%d' "'$LAST")
							else
								break
							fi
						done
						VALUE="${VALUE%?}"
						printf '\r\033[K%s%s%s%s' "$ACC_CLR" "$PROMPT" "$RST_DFL" "$VALUE"
					fi
					;;
				21)	#Ctrl+U
					VALUE=""
					printf '\r\033[K%s%s%s%s' "$ACC_CLR" "$PROMPT" "$RST_DFL" "$VALUE"
					;;
				*)
					VALUE="${VALUE}${C}"
					printf '\r\033[K%s%s%s%s' "$ACC_CLR" "$PROMPT" "$RST_DFL" "$VALUE"
					;;
			esac
		fi
	done
	stty "$OLD" 2>/dev/null
	printf '\n'
	eval "$OUTVAR=\"$VALUE\""
	}

function multiEndong	#1-цифра	#2-слово
	{	# 2611.1
	local ONE="`echo "$1" | sed 's/.*\(.\)$/\1/'`"
	local TWO="`echo "$1" | sed 's/.*\(..\)$/\1/'`"
	if [ "$TWO" -gt "10" -a "$TWO" -lt "20" ];then
	echo "$1 $2ов"
elif [ "$ONE" = "1" ];then
	echo "$1 $2"
	elif [ "$ONE" = "2" -o "$ONE" = "3" -o "$ONE" = "4" ];then
		echo "$1 $2а"
	else
		echo "$1 символов"
	fi
	}

function pressAnyKey
	{	# 2611.1
	read -n 1 -r -p "$ACC_CLR(Чтобы продолжить - нажмите любую клавишу...)$RST_DFL" keypress
	echo ""
	}

function showContent	#1-файл/переменная	#2-заголовок
	{	# 2611.1
	headLine "$2" "hide" "space"
	if [ -f "$1" ];then
		cat "$1"
	else
		echo -e "$1"
	fi
	headLine
	echo ""
	pressAnyKey
	}

function directoryList	#1-папка
	{	# 2611.1
	if [ -d "$1" ];then
		find "$1" -maxdepth 1 -type d ! -name "." | sed 's|.*/||' | tail -n +2 | sort | awk '{print $0"\t/"}'
	fi
	}

function filesList	#1-папка	#2-фильтр (имя_файла.тип_файла)
	{	# 2611.1
	if [ -d "$1" ];then
		find "$1" -maxdepth 1 -type f -name "$2" | sed 's|.*/||' | sort
	fi
	}

function browse	#1-тип (d/f)	#2-содержимое /tmp (отображать/)	#3-имя файла/расширение файла	#4-описание	#5-альтернатива	#6-текущее значение	#7-выбранный путь
	{	# 2611.1
	if [ "$1" = "f" ];then
		if [ -n "$3" ];then
			local TYPE="*.$3"
		else
			local TYPE="*.*"
		fi
		local FILES="`filesList "$7" "$TYPE"`"
	else
		local FILES=""
	fi
	local LIST="`directoryList "$7"`"

	if [ -n "$LIST" -a -n "$FILES" ];then
		if [ "$1" = "d" ];then
			local LIST="`echo -e "Готово\n$LIST\n$FILES"`"
		else
			local LIST="`echo -e "$LIST\n$FILES"`"
		fi
	else
		if [ "$1" = "d" ];then
			local LIST="`echo -e "Готово\n$LIST$FILES"`"
		else
			local LIST="`echo -e "$LIST$FILES"`"
		fi
	fi
	if [ -n "$LIST" ];then
		local LIST="`echo "$LIST" | awk '{print NR":\t"$0}'`"
		if [ "$1" = "d" -a -n "$3" ];then
			echo -e "Текущий путь: $ACC_CLR$7$RST_DFL/$3"
		else
			halfColored "Текущий путь: " "$7"
		fi
		echo ""
		optionList "`echo "$LIST" | awk -F"\t" '{print $1"\t "$2"\t"$3}'`"
		result "Вернуться к началу" "d"
		if [ "$1" = "d" -a "$REPLY" = "1" ];then
			if [ -n "$3" ];then
				REPLY="$7/$3"
			else
				REPLY="$7"
			fi
		else
			REPLY=`echo "$LIST" | grep "^\$REPLY:"`
			if [ -n "$REPLY" ];then
				local SELECTED_PATH="`echo "$REPLY" | awk -F"\t" '{print $2}'`"
				if [ -f "$7/$SELECTED_PATH" ];then
					REPLY="$7/$SELECTED_PATH"
				else
					browse "$1" "$2" "$3" "" "$5" "$6" "$7/$SELECTED_PATH" "$2"
				fi
			else
				browsePath "$1" "$2" "$3" "" "$5" "$6"
			fi
		fi
	else
		showMessage "В папке нет объектов для выбора." "e"
		echo ""
		browsePath "$1" "$2" "$3" "" "$5" "$6"
	fi
	}
	
function browsePath	#1-тип (d/f)	#2-содержимое /tmp (отображать/)	#3-имя файла/расширение файла	#4-описание	#5-альтернатива	#6-текущее значение
	{	# 2611.1
	local LIST="`mount | grep /tmp/mnt | awk '{print $3}' | awk -F"/" '{print $4}'`"
	if [ -n "$LIST" ];then
		local LIST="`echo "$LIST" | awk 'NR>1 {printf "|"} {printf "%s", $0}'`"
		local LIST="`blkid | awk -F'"' '{print $2"\ttmp/mnt/"$4"\t/"}' | grep -a -E "$LIST" | sort`"
		if [ -n "$LIST" ];then
			local LIST="\n$LIST"
		fi
	fi
	if [ -n "$2" ];then
		local LIST="\nВременные файлы\ttmp\t/$LIST"
	fi
	if [ -n "$4" ];then
		showText "\t$4"
		echo ""
	fi
	local LIST="`echo -e "Системный раздел\topt\t/$LIST" | awk '{print NR":\t"$0}'`"
	optionList "`echo "$LIST" | awk -F"\t" '{print $1"\t "$2"\t"$4}'`"
	result "$5" "d"
	REPLY=`echo "$LIST" | grep -a "^\$REPLY:"`
	if [ -n "$REPLY" ];then
		local SELECTED_PATH=`echo "$REPLY" | awk -F"\t" '{print "/"$3}'`
		browse "$1" "$2" "$3" "" "$5" "$6" "$SELECTED_PATH" "$2"
	else
		REPLY="$6"
	fi
	}

function selectInterface	#1-тип (a/i)	#2-IP-адреса в списке	#3-фильтр	#4-разделитель	#5-описание	#6-альтернатива	#7-текущее значение
	{	# 2611.1
	local IP_ADDR_SHOW=`ip addr show | awk -F" |/" '{gsub(/^ +/,"")}/inet /{print $(NF)"\t"$2}' | grep -v "^lo\|^ezcfg"`
	local SHOW_INTERFACE=`ndmc -c show interface | grep "^address: \|^description: \| address: \| description: "`
	IFS=$'\n'
	for LINE in $IP_ADDR_SHOW;do
		local IP="`echo "$LINE" | awk -F"\t" '{print $2}'`"
		local DESCRIPTION="`echo "$SHOW_INTERFACE" | grep -i -B 1 -A 0 "$IP" | head -n1 | awk -F": " '{print $2}'`"
		local IP_ADDR_SHOW="`echo "$IP_ADDR_SHOW" | sed -e "s/$IP/$IP\t$DESCRIPTION/g"`"
	done
	if [ -n "$3" ];then
		local IP_ADDR_SHOW="`echo "$IP_ADDR_SHOW" | grep -E "$3"`"
	fi
	local IP_ADDR_SHOW="`echo "$IP_ADDR_SHOW" | awk -F"\t" '{VARIABLE=($3 != "" ? $3 : $1);print NR":\t"$1"\t"$2"\t"VARIABLE}'`"
	if [ -n "$5" ];then
		showText "\t$5"
		echo ""
	fi
	if [ -n "$2" ];then
		optionList "`echo "$IP_ADDR_SHOW" | awk -F"\t" '{print $1"\t "$4"\t (\t"$3"\t)"}'`"
	else
		optionList "`echo "$IP_ADDR_SHOW" | awk -F"\t" '{print $1"\t "$4}'`"
	fi
	result "$6" "d"
	if [ -n "$REPLY" ];then
		if [ "$1" = "a" ];then
			local IP_ADDR_SHOW="`echo "$IP_ADDR_SHOW" | awk -F"\t" '{print $1"\t"$3}'`"
		else
			local IP_ADDR_SHOW="`echo "$IP_ADDR_SHOW" | awk -F"\t" '{print $1"\t"$2}'`"
		fi
		if [ -z "$4" ];then
			REPLY="`echo "$IP_ADDR_SHOW" | grep "^\$REPLY:" | awk -F"\t" '{print $2}'`"
		else
			REPLY="`echo " $REPLY:" | sed 's/ $//g;s/ /:|^/g;s/^:|//g'`"
			REPLY="`echo -e "$IP_ADDR_SHOW" | grep -E "$REPLY" | awk -F"\t" '{print $2}' | awk -v VARIABLE="$4" '{printf "%s%s", $0, VARIABLE}' | sed "s/\$4$//g"`"
		fi
	fi
	if [ -z "$REPLY" ];then
		REPLY="$7"
	fi
	}

function selectFromList	#1-список (вариант1 \n вариант2 ...)	#2-отображаемый список (опция1 \n опция2 ...)	#3-описание	#4-альтернатива	#5-текущее значение
	{	# 2611.1
	if [ -n "$2" ];then
		local LIST="$2"
	else
		local LIST="$1"
	fi
	local LIST="`echo -e "$LIST" | awk '{print NR":\t"$0}'`"
	if [ -n "$3" ];then
		showText "\t$3"
		echo ""
	fi
	optionList "`echo "$LIST" | awk -F"\t" '{print $1"\t "$2}'`"
	if [ -n "$2" ];then
		local LIST="$1"
		local LIST="`echo -e "$LIST" | awk '{print NR":\t"$0}'`"
	fi
	result "$4" "d"
	if [ -n "$REPLY" ];then
		REPLY="`echo "$LIST" | grep "^\$REPLY:" | awk -F"\t" '{print $2}'`"
	else
		REPLY="$5"
	fi
	}

function editValue	#1-тип (n/t)	#2-длинна строки/минимум	#3-допустимые символы/максимум	#4-описание	#5-запрос #6-текущее значение
	{	# 2611.1
	if [ -n "$5" ];then
	local TEXT="$5"
	else
		local TEXT="Введите значение"
	fi
	if [ -n "$4" ];then
		showText "\t$4"
		echo ""
	fi
	if [ -n "$6" ];then
		prefill "$TEXT: " "$6" REPLY
	else
		read -r -p "$ACC_CLR$TEXT: $RST_DFL"
	fi
	echo ""
	local STATUS1=""
	if [ "$1" = "t" -a -n "$2" ];then
		if [ "`echo ${#REPLY}`" -gt "$2" ];then
			local STATUS1="error"
		fi
	elif [ "$1" = "n" -a -n "$2" -a -n "$3" ];then
		if [ "$REPLY" -lt "$2" -o "$REPLY" -gt "$3" ];then
			local STATUS1="error"
		fi
	fi
	local STATUS2=""
	if [ "$1" = "t" -a -n "$3" ];then
		local STATUS2="`echo "$REPLY" | sed "s/[$3]//g"`"
	elif [ "$1" = "n" ];then
		local STATUS2="`echo "$REPLY" | sed 's/^-//g' | sed 's/[0-9]//g'`"
	fi
	if [ -n "$STATUS2" ];then
		REPLY=""
		if [ "$1" = "t" ];then
			showMessage "В строке есть недопустимые символы: $STATUS2" "e"
		elif [ "$1" = "n" ];then
			showMessage "В строке есть недопустимые символы: $STATUS2" "e"
		fi
		echo ""
		editValue "$1" "$2" "$3" "$4" "$5" "$6"
	elif [ -n "$STATUS1" ];then
		REPLY=""
		if [ "$1" = "t" ];then
			showMessage "Максимальная длинна строки `multiEndong "$1" "символ"`." "e"
		elif [ "$1" = "n" ];then
			showMessage "Число находится за пределами интервала $1-$2." "e"
		fi
		echo ""
		editValue "$1" "$2" "$3" "$4" "$5" "$6"
	fi
	}

function selectAction	#1-тип (a|A a/ai/d/f/i/ii//n/t)	#2-3-настройки элемента	#4-описание	#5-запрос/альтернатива	#6-текущее значение
	{	# 2611.1
	if [ "$1" = "a" ];then
		selectInterface "a" "" "$2" "$3" "$4" "$5" "$6"
	elif [ "$1" = "ai" ];then
		selectInterface "a" "ip" "$2" "$3" "$4" "$5" "$6"
	elif [ "$1" = "d" ];then
		browsePath "d" "$2" "$3" "$4" "$5" "$6"
	elif [ "$1" = "f" ];then
		browsePath "f" "$2" "$3" "$4" "$5" "$6"
	elif [ "$1" = "i" ];then
		selectInterface "i" "" "$2" "$3" "$4" "$5" "$6"
	elif [ "$1" = "ii" ];then
		selectInterface "i" "ip" "$2" "$3" "$4" "$5" "$6"
	elif [ "$1" = "l" ];then
		selectFromList "$2" "$3" "$4" "$5" "$6"
	elif [ "$1" = "n" ];then
		editValue "n" "$2" "$3" "$4" "$5" "$6"
	elif [ "$1" = "t" ];then
		editValue "t" "$2" "$3" "$4" "$5" "$6"
	fi
	}

function getLine	#1-номер строки	#2-текст
	{	# 2611.1
	echo -e "$2" | awk "NR==$1"
	#1-описание настройки
	#2-комментарий к первому параметру
	#3-запрос/альтернатива первого параметра
	#4-комментарий ко второму параметру
	#5-запрос/альтернатива второго параметра
	}

function showList	#1-список	#2-первый элемент (a|A a/ai/d/f/i/ii//n/t)	#3-разделитель	#4-второй элемент (a|A a/ai/d/f/i/ii//n/t) #5-тип списка (f/r/z)
	{	# 2611.1
	if [ -n "$5" ];then
		if [ "$5" = "f" ];then
			showText "\tВведите индекс элемента, который хотите отредактировать..."
		elif [ "$5" = "r" -o "$5" = "z" ];then
			showText "\tВведите индекс элемента, который хотите отредактировать, или воспользуйтесь дополнительными опциями..."
		fi
		echo ""
	fi
	if [ -n "$3" ];then
			if [ -n "$2" -a "`echo "$2" | tr '[:upper:]' '[:lower:]'`" = "$2"  -a -n "$4" -a "`echo "$4" | tr '[:upper:]' '[:lower:]'`" = "$4" ];then
				optionList "`echo -e "$1" | awk -F"\t" '{VARIABLE=($2 != "" && $3 != "" ? ($4 == "" ? $1" [\t"$2"\t] [\t"$3"\t]" : "\t\t\t\t\t"$1" ["$2"] ["$3"]") : ($4 == "" ? $1" \t\t[\t"$2$3"\t]" : "\t\t\t\t\t"$1" ["$2$3"]"));print VARIABLE}'`"
			elif [ -n "$4" -a "`echo "$4" | tr '[:upper:]' '[:lower:]'`" = "$4" ];then
				optionList "`echo -e "$1" | awk -F"\t" '{VARIABLE=($3 != "" ? ($4 == "" ? $1"\t "$2"\t [\t"$3"\t]" : "\t\t\t\t\t"$1" "$2" ["$3"]") : ($4 == "" ? $1"\t "$2 : "\t\t\t\t\t"$1" "$2));print VARIABLE}'`"
			elif [ -n "$2" -a "`echo "$2" | tr '[:upper:]' '[:lower:]'`" = "$2"  ];then
				optionList "`echo -e "$1" | awk -F"\t" '{VARIABLE=($3 != "" ? ($4 == "" ? $1" [\t"$2"\t]\t "$3 : "\t\t\t\t\t"$1" ["$2"] "$3) : ($4 == "" ? $1" [\t"$2"\t]" : "\t\t\t\t\t"$1" ["$2"]"));print VARIABLE}'`"
			else
				optionList "`echo -e "$1" | awk -F"\t" '{VARIABLE=($4 == "" ? $1"\t "$2" "$3 : "\t\t\t\t\t"$1" "$2" "$3);print VARIABLE}'`"
			fi
		else
			if [ -n "$2" -a "`echo "$2" | tr '[:upper:]' '[:lower:]'`" = "$2"  ];then
				optionList "`echo -e "$1" | awk -F"\t" '{VARIABLE=($3 == "" ? $1" [\t"$2"\t]" : "\t\t\t\t\t"$1" ["$2"]");print VARIABLE}'`"
			else
				optionList "`echo -e "$1" | awk -F"\t" '{VARIABLE=($3 == "" ? $1" \t"$2 : "\t\t\t\t\t"$1" "$2);print VARIABLE}'`"
			fi
		fi
	}

function deleteFromList	#1-не пустой список (r)	#2-список	#3-настройка=
	{	# 2611.1
	showText "\tВведите один или несколько (разделяя пробелами) индексов элементов (из списка выше), которые нужно удалить из списка."
	echo ""
	if [ -n "$3" ];then
		showList "`echo "$2" | awk -v FS="$3" '{print NR":\t"$2}' `"
	else
		showList "$2"
	fi
	result "Отмена" "d"
	REPLY="`echo " $REPLY:" | sed 's/ $//g;s/ /:|^/g;s/^:|//g'`"
	if [ -n "`echo -e "$2" | grep -E "$REPLY"`" ];then
		local VARIABLE="`echo -e "$2" | grep -v -E "$REPLY" | cut -f2- | awk '!seen[$0]++' | awk '{print NR":\t"$0}'`"
		if [ -n "$VARIABLE" ];then
			REPLY="$VARIABLE"
		elif [ "$1" = "r" ];then
			showMessage "Список не может быть пустым." "e"
			echo ""
			deleteFromList "$1" "$2" "$3"
		fi
	else
		REPLY="`echo "$2" | cut -f2- | awk '!seen[$0]++' | awk '{print NR":\t"$0}'`"
	fi
	}

function addToList	#1-тип настройки (a/ai/d/f/i/ii/l/n/t/[f/r/z \t внешний разделитель \t первый элемент (a|A a/ai/d/f/i/ii//n/t) \t внутренний разделитель \t второй элемент (a|A a/ai/d/f/i/ii/l/n/t) \t разделитель при пустых элементах])	#2-список	#3-вывод (/с разделителем)	#4-5-6-7-настройки элементов	#8-текст
	{	# 2611.1
	if [ -n "$1" ];then
		local EMPTY="`echo -e "$1"`"
		local FIRST=$(printf '%s' "$EMPTY" | cut -f3)
		local INNER=$(printf '%s' "$EMPTY" | cut -f4)
		local SECOND=$(printf '%s' "$EMPTY" | cut -f5)
		local EMPTY=$(printf '%s' "$EMPTY" | cut -f6)
	fi
	local VARIABLE=""
	selectAction "`echo "$FIRST" | tr '[:upper:]' '[:lower:]'`" "$4" "$5" "`getLine "2" "$8"`" "`getLine "3" "$8"`"
	local VARIABLE="$REPLY"
	if [ -n "$FIRST" -a "`echo "$FIRST" | tr '[:lower:]' '[:upper:]'`" = "$FIRST" -a -z "$VARIABLE" ];then
		showMessage "Элемент не может быть пустым." "e"
		echo ""
		pressAnyKey
	else
		if [ -n "$SECOND" -a -n "$INNER" ];then
			selectAction "`echo "$SECOND" | tr '[:upper:]' '[:lower:]'`" "$6" "$7" "`getLine "2" "$8"`" "`getLine "3" "$8"`"
		else
			REPLY=""
		fi
		local LIST="`echo "$2" | cut -f2-`"
		if [ -n "$INNER" ];then
			if [ -n "$VARIABLE" -a -n "$REPLY" ];then
				if [ -n "$3" ];then
					local SEPARATOR="$INNER"
				else
					local SEPARATOR="\t"
				fi
				REPLY="`echo -e "$LIST\n$3$VARIABLE$SEPARATOR$REPLY" | awk '!seen[$0]++'`"
			else
				if [ -n "$3" ];then
					local SEPARATOR="$EMPTY"
				else
					local SEPARATOR=""
				fi
				REPLY="`echo -e "$LIST\n$3$VARIABLE$SEPARATOR$REPLY" | awk '!seen[$0]++'`"
			fi
		else
			REPLY="`echo -e "$LIST\n$3$VARIABLE" | awk '!seen[$0]++'`"
		fi
	fi
	REPLY="`echo "$REPLY" | awk '{print NR":\t"$0}'`"
	}

function editList	#1-тип настройки (a/ai/d/f/i/ii/l/n/t/[f/r/z \t внешний разделитель (№№ - не собирать список в строку) \t первый элемент (a|A a/ai/d/f/i/ii//n/t) \t внутренний разделитель \t второй элемент (a|A a/ai/d/f/i/ii/l/n/t) \t разделитель при пустых элементах])	#2-3-4-5-настройки элементов	#6-текст
	{	# 2611.1
	if [ -n "$1" ];then
		local EMPTY="`echo -e "$1"`"
		local MODE=$(printf '%s' "$EMPTY" | cut -f1)
		local OUTER=$(printf '%s' "$EMPTY" | cut -f2)
		local FIRST=$(printf '%s' "$EMPTY" | cut -f3)
		local INNER=$(printf '%s' "$EMPTY" | cut -f4)
		local SECOND=$(printf '%s' "$EMPTY" | cut -f5)
		local EMPTY=$(printf '%s' "$EMPTY" | cut -f6)
	fi
	if ! [ "$MODE" = "f" -a "`echo "$LIST" | wc -l`" = "1" ];then
		showList "$LIST" "$FIRST" "$INNER" "$SECOND" "$MODE"
		if [ "$MODE" = "r" -o "$MODE" = "z" ];then
			local VARIABLE="Дополнительно"
		else
			local VARIABLE="Далее"
		fi
		result "$VARIABLE" "d"
	else
		REPLY="1"
	fi
	if [ -n "$REPLY" ];then
		local LINE="`echo "$LIST" | grep "^\$REPLY:"`"
	else
		local LINE=""
	fi
	if [ -n "$LINE" ];then	
		if [ -n "$FIRST" -a "`echo "$FIRST" | tr '[:upper:]' '[:lower:]'`" = "$FIRST" ];then
			local VARIABLE="`echo "$LINE" | awk -F"\t" '{print $2}'`"
			selectAction "$FIRST" "$2" "$3" "`getLine "2" "$6"`" "`getLine "3" "$6"`" "$VARIABLE"
			local VARIABLE="$REPLY"
		else
			local VARIABLE="`echo "$LINE" | awk -F"\t" '{print $2}'`"
		fi
		if [ -n "$SECOND" -a "`echo "$SECOND" | tr '[:upper:]' '[:lower:]'`" = "$SECOND" ];then
			REPLY="`echo "$LINE" | awk -F"\t" '{print $3}'`"
			selectAction "$SECOND" "$4" "$5" "`getLine "4" "$6"`" "`getLine "5" "$6"`" "$REPLY"
		else
			REPLY="`echo "$LINE" | awk -F"\t" '{print $3}'`"
		fi
		if [ -n "$INNER" ];then
			local VARIABLE="`echo "$LINE" | awk -F"\t" '{print $1}'`\t$VARIABLE\t$REPLY"
		else
			local VARIABLE="`echo "$LINE" | awk -F"\t" '{print $1}'`\t$VARIABLE"
		fi
		local LINE=$(echo "$LINE" | sed 's:/:\\/:g')
		local VARIABLE=$(echo -e "$VARIABLE" | sed 's:/:\\/:g')
		local LIST=`echo "$LIST" | sed "s/^\$LINE$/$VARIABLE/g"`
		if ! [ "$MODE" = "f" -a "`echo "$LIST" | wc -l`" = "1" ];then
			editList "" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
		else
			REPLY="`echo "$LIST" | awk -v INNER="$INNER" -v EMPTY="$EMPTY" -F"\t" '{VARIABLE=($2 != "" && $3 != "" ? $2INNER$3 : $2EMPTY$3);print VARIABLE}' | awk -v OUTER="$OUTER" '{printf "%s%s", $0, OUTER}' | sed -e "s/\$OUTER$//g"`"
		fi
	else
		if [ "$MODE" = "r" -o "$MODE" = "z" ];then
			showText "\tЗдесь можно: удалять элементы, добавить новый, или завершить работу с этим списком..."
			echo ""
			option "1" "Удалить"
			option "2" "Добавить"
			result "Далее" "d"
		else
			REPLY=""
		fi
		if [ "$REPLY" = "1" ];then
			deleteFromList "$NODE" "$LIST"
			local LIST="$REPLY"
			editList "" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
		elif [ "$REPLY" = "2" ];then
			addToList "$1" "$LIST" "" "$2" "$3" "$4" "$5" "$6"
			local LIST="$REPLY"
			editList "" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
		else
			REPLY="`echo "$LIST" | awk -v INNER="$INNER" -v EMPTY="$EMPTY" -F"\t" '{VARIABLE=($2 != "" && $3 != "" ? $2INNER$3 : $2EMPTY$3);print VARIABLE}'`"
			if ! [ "$OUTER" = "№№" ];then
				REPLY="`echo "$REPLY" | awk -v OUTER="$OUTER" '{printf "%s%s", $0, OUTER}' | sed -e "s/\$OUTER$//g"`"
			fi
		fi
	fi
	}

function editSubList	#1-тип настройки (a/ai/d/f/i/ii/l/n/t/[f/r/z \t внешний разделитель \t первый элемент (a|A a/ai/d/f/i/ii//n/t) \t внутренний разделитель \t второй элемент (a|A a/ai/d/f/i/ii/l/n/t) \t разделитель при пустых элементах])	#2-3-4-5-настройки элементов	#6-текст
	{	# 2611.1
	local INNER="`echo -e "$1"`"
	local OUTER=$(printf '%s' "$INNER" | cut -f2)
	local INNER=$(printf '%s' "$INNER" | cut -f4)
	local LIST="`echo "$VARIABLE" | sed -e "s/\$OUTER/\\n/g"`"
	if [ -n "$INNER" ];then
		local LIST="`echo -e "$LIST" | awk -v FS="$INNER" '{print NR":\t"$1"\t"$2}'`"
	else
		local LIST="`echo -e "$LIST" | awk '{print NR":\t"$0}'`"
	fi
	editList "$1" "$2" "$3" "$4" "$5" "$6"
	}

function editSetting	#1-тип настройки (a/ai/d/f/i/ii/l/n/t/[f/r/z \t внешний разделитель \t первый элемент (a|A a/ai/d/f/i/ii//n/t) \t внутренний разделитель \t второй элемент (a|A a/ai/d/f/i/ii/l/n/t) \t разделитель при пустых элементах])	#2-настройка=	#3-блокирующий символ	#4-ограничители	#5-6-7-8-настройки элементов	#9-текст
	{	# 2611.1
	if [ -n "$CONFIG" ];then
		if [ -n "$3" ];then
			local VARIABLE="^$2|^$3$2"
		else
			local VARIABLE="^$2"
		fi
		local CURENT="`echo -e "$CONFIG" | grep -E "$VARIABLE"`"
		local VARIABLE="`echo "$CURENT" | grep -E "^\$REPLY$"`"
		if [ -n "$VARIABLE" ];then
			local CURENT="$VARIABLE"
		else
			showText "\t`getLine "1" "$9"`"
			echo ""
		fi
		local NEW="$CURENT"
		if [ -n "$CURENT" ];then
			if [ "`echo -e "$CURENT" | wc -l`" = "1" ];then
				local VARIABLE=""
				if [ -n "$3" ];then
					local VARIABLE="^$3"
					if [ "`echo "$NEW" | grep -E "$VARIABLE" | wc -l`" = "0" ];then
						halfColored "Состояние: " "настройка активна" "$OK_CLR"
						echo ""
						showText "\tХотите её отключить?"
						local STATUS1=""
						local STATUS0="0"
					else
						halfColored "Состояние: " "настройка отключена" "$ERR_CLR"
						echo ""
						showText "\tХотите её задействовать?"
						local STATUS1="1"
						local STATUS0=""
					fi
					echo ""
					local VARIABLE="^$3"
					option "1" "Да" "" "$STATUS1"
					result "Нет" "$STATUS0"
					if ! [ "$REPLY" = "1" -o "$REPLY" = "0" ];then
						REPLY="$STATUS1$STATUS0"
					fi
					if [ "$REPLY" = "1" ];then
						if [ "`echo "$NEW" | grep -E "$VARIABLE" | wc -l`" = "0" ];then
							local NEW="$3$NEW"
							halfColored "Состояние: " "настройка отключена" "$ERR_CLR"
							echo ""
						else
							local NEW="`echo "$NEW" | awk -v VARIABLE="$3" '{sub("^" VARIABLE, ""); print }'`"
						fi
					fi
					if [ "`echo "$NEW" | grep -E "$VARIABLE" | wc -l`" = "0" ];then
						local VARIABLE=""
					else
						local VARIABLE="block"
					fi
				fi
				if [ -z "$VARIABLE" ];then
					local VARIABLE="`echo "$NEW" | awk -v FS="$2" '{print $2}'`"
					if [ -n "$4" ];then
						local VARIABLE="`echo "$VARIABLE" | sed -e "s/^${4//\\/\\\\}//" -e "s/${4//\\/\\\\}$//"`"
					fi
					halfColored "Текущее значение: " "$VARIABLE"
					echo ""
					if [ -n "`echo -e "$1" | grep $'\t'`" ];then
						editSubList "$1" "$5" "$6" "$7" "$8" "$9"
					else
						selectAction "$1" "$5" "$6" "`getLine "2" "$9"`" "`getLine "3" "$9"`" "$VARIABLE"
					fi
					if [ -n "$REPLY" -a -n "$VARIABLE" ];then
						local NEW="$2$4$REPLY$4"
					else
						local NEW="$CURENT"
					fi
				fi
			fi
			if ! [ "$CURENT" = "$NEW" ];then
				halfColored "Новое значение: " "$REPLY"
				echo ""
				option "1" "Готово" "" "d"
				result "Отмена"
				if ! [ "$REPLY" = "0" ];then
					local CURENT=$(echo "$CURENT" | sed 's:/:\\/:g')
					local NEW=$(echo "$NEW" | sed 's:/:\\/:g')
					CONFIG=`echo "$CONFIG" | sed "s/$CURENT/$NEW/g"`
				fi
			else
				showMessage "Вы оставили настройку без изменений."
				echo ""
				pressAnyKey
			fi
		else
			showMessage "Настройка не обнаружена." "e"
			echo ""
			pressAnyKey
		fi
	else
		showMessage "Не удалось загрузить конфигурацию." "e"
		echo ""
		pressAnyKey
	fi
	}

function multiSettings	#1-тип (тип списка [f/r/z] = тип настройки [a/ai/d/f/i/ii/l/n/t/(f/r/z \t внешний разделитель \t первый элемент [a|A a/ai/d/f/i/ii/l/n/t] \t внутренний разделитель \t второй элемент [a|A a/ai/d/f/i/ii/l/n/t] \t разделитель при пустых элементах)])	#2-настройка=	#3-блокирующий символ	#4-ограничители	#5-6-7-8-настройки элементов	#9-текст
	{	# 2611.1
	local MODE="`echo $1 | awk -F"=" '{print $1}'`"
	local SECOND="`echo -e "$1"`"
	local FIRST=$(printf '%s' "$SECOND" | cut -f3)
	local INNER=$(printf '%s' "$SECOND" | cut -f4)
	local SECOND=$(printf '%s' "$SECOND" | cut -f5)
	if [ -n "$CONFIG" ];then
		if [ -n "$3" ];then
			local VARIABLE="^$2|^$3$2"
		else
			local VARIABLE="^$2"
		fi
		local LIST="`echo -e "$CONFIG" | grep -E "$VARIABLE" | awk '{print NR":\t"$0}'`"
		if [ -n "$INNER" ];then
			local VARIABLE="`echo "$LIST" | awk -v FS="$2" '{print $1"\t"$2}' | awk -v FS="$INNER" '{print $1"\t"$2}' | awk -F"\t" '{print $1"\t"$3"\t"$4"\t"$2}'`"
		else
			local VARIABLE="`echo "$LIST" | awk -v FS="$2" '{print $1"\t"$2}' | awk -F"\t" '{print $1"\t"$3"\t"$2}'`"
		fi
		if [ -z "$STATUS0" ];then
			showText "\t`getLine "1" "$9"`"
			echo ""
			local STATUS0="block"
		fi
		showList "$VARIABLE" "$FIRST" "$INNER" "$SECOND" "$MODE"
		if [ "$MODE" = "r" -o "$MODE" = "z" ];then
			local VARIABLE="Дополнительно"
		else
			local VARIABLE="Готово"
		fi
		result "$VARIABLE" "d"
		REPLY="`echo "$LIST" | grep "^\$REPLY:" | awk -F"\t" '{print $2}'`"
		if [ -n "$REPLY" ];then
			editSetting "`echo "$1" | sed -e "s/^$MODE=//g"`" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
			multiSettings "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
		else
			showText "\tЗдесь можно: удалять элементы, добавить новый, или завершить работу с этим списком..."
			echo ""
			option "1" "Удалить"
			option "2" "Добавить"
			result "Готово" "d"
			if [ "$REPLY" = "1" -o "$REPLY" = "2" ];then
				if [ "$REPLY" = "1" ];then
					deleteFromList "$MODE" "$LIST" "$2"	
				elif [ "$REPLY" = "2" ];then
					addToList "$1" "$LIST" "$2" "$5" "$6" "$7" "$8" "$9"
				fi
				if [ -z "$REPLY" ];then
					REPLY="`echo "$2" | awk '{print NR":\t"$0}'`"
				fi
				if ! [ "$LIST" = "$REPLY" ];then
					local VARIABLE="`echo "$LIST" | head -n 1 | cut -f2-`"
					local BEGINING="`echo "$CONFIG" | awk -v VARIABLE="$VARIABLE" '$0 == VARIABLE { exit } 1'`"
					if [ -n "$BEGINING" -a -n "$REPLY" ];then
						REPLY="`echo -e "\n$REPLY" | cut -f2-`"
					fi
					local VARIABLE="`echo "$LIST" | tail -n 1 | cut -f2-`"
					local ENDING="`echo "$CONFIG" | awk -v VARIABLE="$VARIABLE" 'f; $0 == VARIABLE { f=1 }'`"
					if [ -n "$ENDING" ];then
						local ENDING="\n$ENDING"
					fi
					CONFIG="`echo -e "$BEGINING$REPLY$ENDING"`"
					#CONFIG="`echo -e "$CONFIG"`"
				fi
				multiSettings "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
			fi
		fi
	fi
	}

function getSetting	#1-настройка=	#2-блокирующий символ	#3-тип (b/v)	#4-ограничители
	{	# 2611.1
	if [ -f "$PACKAGE_CONFIG_FILE" ];then
		local CURENT="`cat "$PACKAGE_CONFIG_FILE"`"
		local CURENT=`echo -e "$CURENT"`
		if [ -n "$2" ];then
			local VARIABLE="^$1|^$2$1"
		else
			local VARIABLE="^$1"
		fi
		local CURENT="`echo "$CURENT" | grep -E "$VARIABLE"`"
		REPLY="`echo "$CURENT" | awk -v FS="$1" '{print $2}'`"
		if [ -n "$4" ];then
			REPLY="`echo "$REPLY" | sed -e "s/^${4//\\/\\\\}//" -e "s/${5//\\/\\\\}$//"`"
		fi
		if [ "$3" = "v" ];then
			echo "$REPLY"
		elif [ "$3" = "b" -a -n "$2" -a -n "`echo "$CURENT" | awk -F"=" '{print $1}' | grep -E "^$2"`" ];then
			echo "$2"
		fi
	fi
	}

function saveConfig	#1-файл конфигурации	#2-сохраняемые переменные
	{	# 2611.1
	if [ -n "$1" ];then
		local CONFIG_PATH="$1"
	else
		local CONFIG_PATH="$SCRIPT_CONFIG_FILE"
	fi
	if [ -n "$2" ];then
		local LIST="$2"
	else
		local LIST="$SCRIPT_SETTINGS"
	fi
	local SETTINGS=""
	IFS=$' '
	for VARIABLE in $LIST;do
		eval "local SETTINGS=\`echo \"\$SETTINGS\\n\$VARIABLE=\\\"\$$VARIABLE\\\"\"\`"
	done
	local SETTINGS="`echo -e "$SETTINGS" | grep -v '^$'`"
	echo "$SETTINGS" > "$CONFIG_PATH"
	if [ -n "$SETTINGS" ];then
		showMessage "Настройки сохранены." "o"
		echo ""
		pressAnyKey
	fi
	}

function loadConfig	#1-файл конфигурации	#2-ошибки (/игнорировать)
	{	# 2611.1
	if [ -n "$1" ];then
		local CONFIG_PATH="$1"
	else
		local CONFIG_PATH="$SCRIPT_CONFIG_FILE"
	fi
	if [ -f "$CONFIG_PATH" ];then
		source "$CONFIG_PATH"
	elif [ -z "$2" ];then
		showMessage "Файл конфигурации отсутствует." "e"
		exit
	fi
	}

function statusOPKG	#1-название пакета
	{	# 2611.1
	local PACLAGE="`echo "$1" | tr '[:upper:]' '[:lower:]'`"
	local PACKAGE=`opkg list-installed | grep "^\$PACLAGE "`
	if [ -n "$PACKAGE" ];then
		if [ -n "`echo "$PACKAGE" | awk -F" - " '{print $2}'`" ];then
			echo "`echo "$PACKAGE" | awk -F" - " '{print $2}'`"
		else
			echo "$PACKAGE"
		fi
	else
		echo ""
	fi
	}

function installOPKG	#1-название пакета	#2-подробности (/скрыть)
	{	# 2611.1
	local PACLAGE="`echo "$1" | tr '[:upper:]' '[:lower:]'`"
	if [ -z "`opkg list-installed | grep "\$PACLAGE "`" ];then
		echo "Установка $1..."
		LOG=$(opkg update 2>&1)
		LOG="$LOG\n$(opkg install $PACLAGE 2>&1)"
		echo ""
		if [ -z "`statusOPKG "$PACLAGE"`" ];then
			showMessage "Не удалось установить $1." "e"
			echo ""
			echo -e "$LOG"
			exit
		fi
	elif [ -z "$2" ];then
		echo "Пакет $1 уже установлен."
		echo ""
	fi
	}

function removeOPKG	#1-название пакета	#2-подробности (/скрыть)	#3-автоответ (n/y)
	{	# 2611.1
	local PACLAGE="`echo "$1" | tr '[:upper:]' '[:lower:]'`"
	if [ -z "$2" ];then
		echo "Удаление $1..."
		echo ""
	fi
	if [ "$3" = "n" ];then
		LOG=$(yes n | opkg remove $PACLAGE 2>&1)
	elif [ "$3" = "y" ];then
		LOG=$(yes | opkg remove $PACLAGE 2>&1)
	else
		LOG=$(opkg remove $PACLAGE 2>&1)
	fi
	if [ -n "`statusOPKG "$1"`" -a -z "$2" ];then
		showMessage "Не удалось удалить $1." "e"
		echo ""
		echo -e "$LOG"
		echo ""
		pressAnyKey
	fi
	}

function updateOPKG	#1-название пакета
	{	# 2611.1
	local PACKAGE="`echo "$1" | tr '[:upper:]' '[:lower:]'`"
	if [ -n "`opkg list-installed | grep "\$PACKAGE "`" ];then
		local CURENT="`statusOPKG "$PACKAGE"`"
		echo "Обновление $1..."
		LOG=$(opkg update 2>&1)
		LOG="$LOG\n$(opkg upgrade $PACKAGE 2>&1)"
		echo ""
		if [ "$CURENT" = "`statusOPKG "$PACKAGE"`" ];then
			showMessage "Не удалось обновить $1." "e"
			echo ""
			echo -e "$LOG"
			exit
		fi
	fi
	}

function copyRight
	{	# 2611.1
	if [ "`date +"%C%y"`" -gt "$SCRIPT_YEAR" ];then
		local NOW="-`date +"%C%y"`"
	else
		local NOW=""
	fi
	local COPYRIGHT="© $SCRIPT_YEAR$NOW rino Software Lab."
	local VARIABLE="$SCRIPT_NAME $SCRIPT_VERSION $COPYRIGHT "
	local VARIABLE="${#VARIABLE}"
	local VARIABLE="$((COLUNS - VARIABLE))"
	if [ "$VARIABLE" -gt "0" ];then
		local VARIABLE=" $SCRIPT_NAME $ACC_CLR$SCRIPT_VERSION$RST_DFL`space "h" "$VARIABLE"`$COPYRIGHT"
	else
		local VARIABLE="${#COPYRIGHT}"
		local VARIABLE="$((COLUNS - VARIABLE - 1))"
		local VARIABLE="`space "h" "$VARIABLE"`$COPYRIGHT"
		echo -e " $SCRIPT_NAME $ACC_CLR$SCRIPT_VERSION$RST_DFL"
	fi
	read -t 1 -n 1 -r -p "$VARIABLE" keypress
	echo ""
	}

function statusPackage	#1-скрыть сообщение
	{
	LOG=$(/opt/etc/init.d/S51nfqws2 status 2>&1)
	if ! [ "`echo "$LOG" | grep -c "Service NFQWS2 is running"`" -gt "0" ];then
		REPLY="dead"
	else
		REPLY=""
	fi
	}

function restartPackage
	{
	if [ -z "`statusPackage`" ];then
		echo "Перезапуск $PACKAGE_NAME..."
	else
		echo "Запуск $PACKAGE_NAME..."
	fi
	echo ""
	LOG=$(/opt/etc/init.d/S51nfqws2 restart 2>&1)
	if [ -z "`echo -e "$LOG" | grep "Started NFQWS2 service"`" ];then
		echo -e "$LOG"
		echo ""
		pressAnyKey
	fi
	}

function acceptChanges
	{
	statusPackage
	if [ -z "$REPLY" ];then
		showText "\tПрименить изменения?"
		echo ""
		option "1" "Да" "" "d"
		result "Нет"
		if ! [ "$REPLY" = "0" ];then
			restartPackage
		fi
	else
		pressAnyKey
	fi
	}

function settingsMenu
	{
	local VARIABLE="В главное меню"
	if [ -f "$PACKAGE_CONFIG_FILE" ];then
		REPLY="`cat "$PACKAGE_CONFIG_FILE"`"
		REPLY="`echo -e "$REPLY"`"
		if ! [ "$REPLY" = "$CONFIG" ];then
			REPLY="true"
			local VARIABLE="Готово"
		else
			REPLY=""
		fi
	else
		REPLY=""
	fi
	headLine "Настройки" "" "" "$REPLY" "" ":не сохранены" "$DRK_CLR$WARN_BG"
	if [ -n "$REPLY" ];then
		local STATUS0="$REPLY"
	else
		local STATUS0=""
	fi
	if [ -f "$PACKAGE_CONFIG_BACKUP" -a -z "$STATUS0" ];then
		local STATUS9=""
		local CHANGES="до `date -r "$PACKAGE_CONFIG_BACKUP" +'%Y.%m.%d %H:%M:%S'`"
	else
		local STATUS9="block"
		local CHANGES="изменений"
	fi
	option "1" "Интерфейсы"
	option "2" "Режим работы"
	option "3" "IPv6"
	option "4" "Порты"
	option "5" "Политика"
	option "6" "Лог"
	option "7" "Конфигурация"
	option "9" "Откат $CHANGES" "$STATUS9"
	result "$VARIABLE" "d"

	if [ "$REPLY" = "1" ];then
		editSetting "ii" "ISP_INTERFACE=" "" '"' "" " " "" "" "Здесь можно выбрать сетевые интерфейсы провайдеров, на которых будет осуществляться обработка пакетов...\nВведите индекс одного, или нескольких (разделяя их пробелами) сетевых интерфейсов...\nТекущeе значение"
		settingsMenu
	elif [ "$REPLY" = "2" ];then
		editSetting "l" "NFQWS_EXTRA_ARGS=" "" '"' "\$MODE_AUTO\n\$MODE_ALL\n\$MODE_LIST" "Авто\nВсё\nСписок" "" "" "Здесь можно выбрать один из трёх режимов работы (с доменами и IP-адресами): \"Авто\" - автоматическое определение заблокированных, \"Всё\" - обработка всего трафика (кроме доменов и IP-адресов из списков исключений), \"Список\" - обработка только доменов и IP-адресов из пользовательских списков...\nВыберите режим работы..."
		settingsMenu
	elif [ "$REPLY" = "3" ];then
		editSetting "l" "IPV6_ENABLED=" "" '' "1\n0" "Включить\nВыключить" "" "" "Здесь можно управлять функцией обработки IP-адресов версии 6...\nФункция обработки IPv6:"
		settingsMenu
	elif [ "$REPLY" = "4" ];then
		showCentered "Порты" "$ACC_CLR"
		echo ""
		option "1" "TCP-порты"
		option "2" "UDP-порты"
		result "Назад" "d"
		if [ "$REPLY" = "1" ];then
			editSetting "r\t,\tn" "TCP_PORTS=" "" '' "1" "65535" "" "" "Здесь можно указать TCP-порты, на которых будет осуществляться обработка...\nВведите порт...\nТекущее значение"
		elif [ "$REPLY" = "2" ];then
			editSetting "r\t,\tn" "UDP_PORTS=" "" '' "1" "65535" "" "" "Здесь можно указать UDP-порты, на которых будет осуществляться обработка...\nВведите порт...\nТекущее значение"
		fi
		settingsMenu
	elif [ "$REPLY" = "5" ];then
		showCentered "Политика" "$ACC_CLR"
		echo ""
		option "1" "Имя политики"
		option "2" "Режим инверсии"
		result "Назад" "d"
		if [ "$REPLY" = "1" ];then
			editSetting "t" "POLICY_NAME=" "" '"' "" "-_.,0-9A-Za-z" "" "" "Здесь можно указать имя политики доступа (Keenetic/Netcraze), с которой будет работать $PACKAGE_NAME...\nВведите имя политики...\nИмя"
		elif [ "$REPLY" = "2" ];then
			editSetting "l" "POLICY_EXCLUDE=" "" '' "1\n0" "Включить\nВыключить" "" "" "Здесь можно управлять функцией инверсивного режима политики доступа (если она включена - трафик устройств добавленных в политику обрабатываться не будет, если выключена - будет обрабатываться только трафик устройств из политики)...\nФункция инверсивного режима политики доступа:"
		fi
		settingsMenu
	elif [ "$REPLY" = "6" ];then
		showCentered "Лог" "$ACC_CLR"
		echo ""
		option "1" "Уровень логирования"
		option "2" "Расположение лога"
		result "Назад" "d"
		if [ "$REPLY" = "1" ];then
			editSetting "l" "LOG_LEVEL=" "" '' "1\n0" "Отладка\nВыключить" "" "" "Здесь можно управлять уровнем логирования\nВыберите уровень логирования..."
		elif [ "$REPLY" = "2" ];then
			editSetting "f\t=\tT\t@\td\t@" "LOG_DEBUG_PATH=" "" '"' "" "" "temp" "nfqws2-debug.log" "Здесь можно выбрать папку, в которой будет размещён файл лога...\n\n\nВыберите папку...\nОставить текущую"
		fi
		settingsMenu
	elif [ "$REPLY" = "7" ];then
		showContent "$CONFIG" "Конфигурация"
		settingsMenu
	elif [ "$REPLY" = "9" ];then
		if [ -z "$STATUS9" ];then
			showText "\tВы можете восстановить конфигурацию в прежнее состояние, текущие настройки будут безвозвратно удалены..."
			echo ""
			showText "\tВосстановить конфигурацию?"
			echo ""
			option "1" "Да" "" "d"
			result "Нет"
			if ! [ "$REPLY" = "0" ];then
				mv "$PACKAGE_CONFIG_BACKUP" "$PACKAGE_CONFIG_FILE"
				showMessage "Конфигурация восстановлена." "o"
				echo ""
				acceptChanges
			fi
		elif [ -n "$STATUS0" ];then
			showMessage "В конфигурации есть несохранённые изменения." "w"
			echo ""
			showText "\tЧтобы откатить конфигурацию до предыдущей версии - нужно выйти из редактора настроек, без сохранения изменений..."
			echo ""
			pressAnyKey
		else
			showMessage "Отсутствует резервная копия предыдущей конфигурации." "e"
			echo ""
			pressAnyKey
		fi
	else
		if [ -n "$STATUS0" ];then
			showText "\tСохранить конфигурацию?"
			echo ""
			option "1" "Да" "" "d"
			result "Нет"
			if ! [ "$REPLY" = "0" ];then
				mv "$PACKAGE_CONFIG_FILE" "$PACKAGE_CONFIG_BACKUP"
				touch "$PACKAGE_CONFIG_BACKUP"
				echo -e "$CONFIG" > "$PACKAGE_CONFIG_FILE"
				showMessage "Конфигурация сохранена." "o"
				echo ""
				acceptChanges
			fi
		fi
	fi
	}

function settings
	{
	if [ -f "$PACKAGE_CONFIG_FILE" ];then
		CONFIG="`cat "$PACKAGE_CONFIG_FILE"`"
		CONFIG=`echo -e "$CONFIG"`
		settingsMenu
	else
		showMessage "Файл конфигурации не обнаружен." "e"
		echo ""
		pressAnyKey
	fi
	}

function listsMenu
	{
	if [ "$LIST_CHANGES" = "0" ];then
		headLine "Списки"
		showText "\tВыберите список для просмотра или редактирования..."
		echo ""
	else
		showText "\tВыберите список для просмотра или редактирования..."
		echo ""
	fi
	local LIST="`filesList "$PACKAGE_CONFIG_PATH/lists" "*.list" | awk '{print NR": \t"$0}'`"
	optionList "$LIST"
	result "В главное меню" "d"
	REPLY=`echo "$LIST" | grep "^\$REPLY:" | awk -F"\t" '{print $2}'`
	if [ -n "$REPLY" ];then
		local LIST_FILE="$REPLY"
		local LIST="`cat "$PACKAGE_CONFIG_PATH/lists/$LIST_FILE" | awk '{print NR":\t"$0}'`"
		editList "z\t№№\tt"
		if ! [ "`echo "$LIST" | cut -f2-`" = "$REPLY" ];then
			local LIST="$REPLY"
			showText "\tВ список $LIST_FILE внесены изменения, хотите их сохранить?"
			echo ""
			option "1" "Да" "" "d"
			result "Нет"
			if ! [ "$REPLY" = "0" ];then
				echo -e "$LIST" > "$PACKAGE_CONFIG_PATH/lists/$LIST_FILE"
				showMessage "Список $LIST_FILE обновлен." "o"
				LIST_CHANGES="$((LIST_CHANGES + 1))"
				echo ""
			fi
		fi
		listsMenu
	else
		if [ "$LIST_CHANGES" -gt "0" ];then
			acceptChanges
		fi
	fi
	}

function installPackage	#1-название пакета	#2-параметр	#3-файл конфигурации
	{
	mkdir -p /opt/etc/opkg
	echo "$2" > "$3"
	installOPKG "$1"
	}

function getArch
	{
	local ARCH=`ndmc -c 'show version' | grep "arch: " | sed -e 's/^[^[:alpha:]]\+//' | awk -F": " '{print $2}'`
	if [ "$ARCH" = "mips" ];then
		local HEXDUMP1=`echo -n I | hexdump -o | awk '{ print substr($2,6,1); exit}'`
		local HEXDUMP2=`hexdump -s 5 -n 1 -C /opt/bin/busybox | awk -F" " '{print $2}'`
		if [ "$HEXDUMP1" = "1" -a "$HEXDUMP2" = "01" ];then
			local ARCH="$ARCH`echo 'el'`"
		fi
	fi
	REPLY="$ARCH"
	}

function selectArch
	{
	local STATUS1="" STATUS2="" STATUS3="" STATUS4=""
	getArch
	if [ "$REPLY" = "mipsel" ];then
		local STATUS1="1"
	elif [ "$REPLY" = "aarch64" ];then
		local STATUS2="2"
	elif [ "$REPLY" = "mips" ];then
		local STATUS3="3"
	else
		local STATUS4="4"
	fi
	showText "\tВыберите архитектуру ЦП вашего интернет-центра..."
	echo ""
	option "1" "mipsel" "" "$STATUS1"
	option "2" "aarch64" "" "$STATUS2"
	option "3" "mips" "" "$STATUS3"
	option "4" "Универсальная версия" "" "$STATUS4"
	result "Отмена"
	if [ -z "`echo "01234" | grep "$REPLY"`" -o -z "$REPLY" ];then
		REPLY="$STATUS1$STATUS2$STATUS3$STATUS4"
	fi
	if [ "$REPLY" = "1" ];then
		installPackage "$PACKAGE_NAME" "src/gz nfqws2-keenetic https://nfqws.github.io/nfqws2-keenetic/mipsel" "/opt/etc/opkg/nfqws2-keenetic.conf"
	elif [ "$REPLY" = "2" ];then
		installPackage "$PACKAGE_NAME" "src/gz nfqws2-keenetic https://nfqws.github.io/nfqws2-keenetic/aarch64" "/opt/etc/opkg/nfqws2-keenetic.conf"
	elif [ "$REPLY" = "3" ];then
		installPackage "$PACKAGE_NAME" "src/gz nfqws2-keenetic https://nfqws.github.io/nfqws2-keenetic/mips" "/opt/etc/opkg/nfqws2-keenetic.conf"
	elif [ "$REPLY" = "4" ];then
		installPackage "$PACKAGE_NAME" "src/gz nfqws2-keenetic https://nfqws.github.io/nfqws2-keenetic/all" "/opt/etc/opkg/nfqws2-keenetic.conf"
	fi
	}

function removePackage #1-команда удаления	#3-файл конфигурации	#3-пакет	#3-автоответчик (n/y/выключен)	#4-автоответ
	{
	showText "\tВы действительно хотите удалить $4?"
	echo ""
	option "1" "Да"
	result "Нет" "d"
	if [ "$REPLY" = "1" ];then
		if [ -n "$3" ];then
			showText "\tХотите сохранить профиль $4 (настройки, списки и т.п.), на этом устройстве?"
			echo ""
			option "1" "Да" "" "d"
			result "Нет"
			if ! [ "$REPLY" = "0" ];then
				removeOPKG "$1" "" "n"
			else
				removeOPKG "$1" "" "y"
			fi
		else
			removeOPKG "$1"
		fi
		if [ -f "$2" ];then
			rm -rf "$2"
			LOG=$(opkg update 2>&1)
		fi
	fi
	}

function oldVercion
	{
	showMessage "Установлен NFQWS-keenetic." "w"
	echo ""
	showText "\tНа этом устройстве уже установлен пакет NFQWS-keenetic. Для корректной работы $PACKAGE_NAME - нужно удалить старую версию (в процессе удаления, вы сможете сохранить свои настройки и списки)..."
	echo ""
	option "1" "Удалить"
	result "Отмена" "d"
	if [ "$REPLY" = "1" ];then
		removePackage "--autoremove NFQWS-keenetic" "/opt/etc/opkg/nfqws-keenetic.conf" "auto" "NFQWS-keenetic"
	fi
	if [ -z "`statusOPKG "NFQWS-keenetic"`" ];then
		packageMenu
	fi
	}

function getUpdateVersion	#1-пакеты (через пробел)
	{
	local UPDATE="/tmp/`echo "$SCRIPT_NAME" | tr '[:upper:]' '[:lower:]'`.upd"
	local LIST="`echo "$1" | tr '[:upper:]' '[:lower:]'`"
	REPLY=""
	IFS=$' '
	for PACKAGE in $LIST;do
		local URL="`cat /opt/etc/opkg/$PACKAGE.conf | awk -F" " '{print $3}'`"
		local AVAILABLE="`wget -q -O - "$URL" | sed  's/<[^>]*>//g' | grep "^\$PACKAGE.*\.ipk$" | awk -F"_" '{print $2}'`"
		if [ -n "$AVAILABLE" ];then
			REPLY="$REPLY\n$PACKAGE - $AVAILABLE"
		fi
	done
	echo -e "$REPLY" | grep -v '^$' | tee "$UPDATE_VERSIONS"
	touch "$UPDATE_VERSIONS"
	}

function checkForUpdate	#1-пакеты (через пробел)
	{
	if [ -f "$UPDATE_VERSIONS" ];then
		if ! [ "`date -r "$UPDATE_VERSIONS" +'%Y.%m.%d-%H'`" = "`date +'%Y.%m.%d-%H'`" ];then
			$0 -U  >/dev/null 2>&1 &
		fi
		local UPDATE="`cat "$UPDATE_VERSIONS"`"
		if [ -n "$UPDATE" ];then
			local LIST="`echo " $1" | tr '[:upper:]' '[:lower:]' | sed 's/ $//g;s/ /|^/g;s/^|//g'`"
			local LIST="`opkg list-installed | grep -E "$LIST"`"
			local SEPARATOP=": "
			REPLY=""
			IFS=$'\n'
			for PACKAGE in $LIST;do
				local CURENT="`echo "$PACKAGE" | awk -F" - " '{print $1}'`"
				local AVAILABLE="`echo "$UPDATE" | grep "^\$CURENT" | awk -F" - " '{print $2}'`"
				if ! [ -z "$AVAILABLE" -o "$AVAILABLE" = "`echo "$PACKAGE" | awk -F" - " '{print $2}'`" ];then
					REPLY="$REPLY$SEPARATOP`echo "$UPDATE" | grep "^\$CURENT"`"
					local SEPARATOP=", "
				fi
			done
			if [ -n "$REPLY" ];then
				if [ -n "`echo "$REPLY" | grep ","`" ];then
					REPLY="Доступны обновления$REPLY."
				else
					REPLY="Доступно обновление$REPLY."
				fi
			showMessage "`echo "$REPLY"`" "w"
				echo ""
			fi
		fi
	else
		$0 -U  >/dev/null 2>&1 &
	fi
	}

function packageMenu
	{
	if [ -n "`statusOPKG "NFQWS-keenetic"`" ];then
		oldVercion
		mainMenu
		exit
	elif [ -f "/opt/etc/opkg/nfqws-keenetic.conf" ];then
		rm -rf "/opt/etc/opkg/nfqws-keenetic.conf"
		LOG=$(opkg update 2>&1)
	fi
	local STATUS3="`checkForUpdate "$PACKAGE_NAME"`"
	local STATUS4="`checkForUpdate "nfqws-keenetic-web"`"
	if [ -n "$STATUS3" -a -n "$STATUS4" ];then
		local STATUS0="доступны обновления"
	else
		local STATUS0="доступно обновление"
	fi
	headLine "Управление пакетами" "" "" "$STATUS3$STATUS4" "" ":$STATUS0" "$DRK_CLR$WARN_BG"
	if [ -n "`statusOPKG "$PACKAGE_NAME"`" ];then
		local STATUS1="block"
		local STATUS5=""
	else
		local STATUS1=""
		local STATUS5="block"
	fi
	if [ -n "`statusOPKG "nfqws-keenetic-web"`" ];then
		local STATUS2="block"
		local STATUS6=""
	else
		local STATUS2=""
		local STATUS6="block"
	fi
	if [ -n "$STATUS3" -a -n "$STATUS1" ];then
		local STATUS3=""
	else
		local STATUS3="block"
	fi
	if [ -n "$STATUS4" -a -n "$STATUS2" ];then
		local STATUS4=""
	else
		local STATUS4="block"
	fi
	option "1" "Установка $PACKAGE_NAME" "$STATUS1"
	option "2" "Установка веб-интерфейса" "$STATUS2"
	option "3" "Обновление $PACKAGE_NAME" "$STATUS3"
	option "4" "Обновление веб-интерфейса" "$STATUS4"
	option "5" "Удаление $PACKAGE_NAME" "$STATUS5"
	option "6" "Удаление веб-интерфейса" "$STATUS6"
	option "7" "Информация о $PACKAGE_NAME" "$STATUS5"
	option "8" "Информация о веб-интерфейсе" "$STATUS6"
	option "9" "Удаление $SCRIPT_NAME"
	result "В главное меню" "d"
	if [ "$REPLY" = "1" ];then
		if [ -z "$STATUS1" ];then
			selectArch
		else
			showMessage "Пакет $PACKAGE_NAME уже установлен." "e"
			echo ""
			pressAnyKey
		fi
		packageMenu
	elif [ "$REPLY" = "2" ];then
		if [ -z "$STATUS2" ];then
			installPackage "NFQWS-keenetic-Web" "src/gz nfqws-keenetic-web https://nfqws.github.io/nfqws-keenetic-web/all" "/opt/etc/opkg/nfqws-keenetic-web.conf"
			if [ -n "`statusOPKG "NFQWS-keenetic-web"`" ];then
				showText "\tВеб-интерфейс установлен, и доступен по адресу:"
				showMessage "`echo "$LOG" | grep 'Web Interface installed:' | awk -F": " '{print $2}'`" "u"
				showText "Для входа в веб-интерфейс, используйте имя пользователя: root и пароль, с которым вы подключаетесь к entware (по умолчанию это: keenetic)..."
				echo ""
				pressAnyKey
			fi
		else
			showMessage "Веб-интерфейс уже установлен." "e"
			echo ""
			pressAnyKey
		fi
		packageMenu
	elif [ "$REPLY" = "3" ];then
		if [ -z "$STATUS5" ];then
			updateOPKG "$PACKAGE_NAME"
		else
			showMessage "Нет доступных обновлений $PACKAGE_NAME." "e"
			echo ""
			pressAnyKey
		fi
		packageMenu
	
	elif [ "$REPLY" = "4" ];then
		if [ -z "$STATUS5" ];then
			updateOPKG "NFQWS-keenetic-Web"
		else
			showMessage "Нет доступных обновлений веб-интерфейса." "e"
			echo ""
			pressAnyKey
		fi
		packageMenu
	
	elif [ "$REPLY" = "5" ];then
		if [ -z "$STATUS5" ];then
			removePackage "--autoremove $PACKAGE_NAME" "/opt/etc/opkg/nfqws2-keenetic.conf" "auto" "$PACKAGE_NAME"
		else
			showMessage "Пакет $PACKAGE_NAME не установлен." "e"
			echo ""
			pressAnyKey
		fi
		packageMenu
	elif [ "$REPLY" = "6" ];then
		if [ -z "$STATUS6" ];then
			removePackage "--autoremove NFQWS-keenetic-Web" "/opt/etc/opkg/nfqws-keenetic-web.conf" "" "веб-интерфейс"
		else
			showMessage "Веб-интерфейс не установлен." "e"
			echo ""
			pressAnyKey
		fi
		packageMenu
	elif [ "$REPLY" = "7" ];then
		if [ -z "$STATUS5" ];then
			showContent "`opkg info nfqws2-keenetic`" "Информация о $PACKAGE_NAME"
		else
			showMessage "Пакет $PACKAGE_NAME не установлен." "e"
			echo ""
			pressAnyKey
		fi
		packageMenu
	elif [ "$REPLY" = "8" ];then
		if [ -z "$STATUS6" ];then
			showContent "`opkg info nfqws-keenetic-web`" "Информация о веб-интерфейсе"
		else
			showMessage "Веб-интерфейс не установлен." "e"
			echo ""
			pressAnyKey
		fi
		packageMenu
	elif [ "$REPLY" = "9" ];then
		showText "\tвы действительно хотите удалить $SCRIPT_NAME?"
		echo ""
		option "1" "Да"
		result ""Нет "d"
		if [ "$REPLY" = "1" ];then
			if [ -f "$SCRIPT_CONFIG_FILE" ];then
				showText "\tУдалить настройки $SCRIPT_NAME?"
				echo ""
				option "1" "Да" "" "d"
				result "Нет" ""
				if ! [ "$REPLY" = "0" ];then
					rm -rf "$SCRIPT_CONFIG_FILE"
				fi
			fi
			headLine
			copyRight
			clear
			rm -rf "$0"
			exit
		fi
		packageMenu
	fi
	}

function stopPackage
	{
	echo "Остановка $PACKAGE_NAME..."
	echo ""
	LOG=$(/opt/etc/init.d/S51nfqws2 stop 2>&1)
	if [ -z "`echo -e "$LOG" | grep "Stopping NFQWS2 service"`" ];then
		echo -e "$LOG"
		echo ""
		pressAnyKey
	fi
	}

function mainMenu
	{
	if [ -n "`statusOPKG "$PACKAGE_NAME"`" ];then
		local STATUS0="`date +"%H:%M:%S"`"
		local STATUS1=""
		statusPackage
		local STATUS2="$REPLY"
		if [ -z "$REPLY" ];then
			local VARIABLE="Перезапуск"
		else
			local VARIABLE="Запуск"
		fi
	else
		local STATUS0=""
		local STATUS1="block"
		local VARIABLE="Запуск"
		local STATUS2="block"
	fi
	headLine "$SCRIPT_NAME для $PACKAGE_NAME" "$STATUS0" "" "$STATUS0" "$REPLY" ":служба запущена" "$DRK_CLR$OK_BG" ":служба остановлена" "$DRK_CLR$ERR_BG"
	if [ -n "$STATUS0" ];then
		showRighted "$STATUS0" "$ACC_CLR"
	fi
	local STATE0="`checkForUpdate "$PACKAGE_NAME nfqws-keenetic-web"`"
	if [ -n "$STATE0" ];then
		echo "$STATE0"
		echo ""
	fi
	option "1" "$VARIABLE службы" "$STATUS1"
	option "2" "Остановка службы" "$STATUS2"
	option "3" "Обновление статуса..." "$STATUS1"
	option "4" "Настройки" "$STATUS1"
	option "5" "Списки" "$STATUS1"
	option "9" "Управление пакетами"
	result "Выход" "d"
	if [ "$REPLY" = "1" ];then
		if [ -z "$STATUS1" ];then
			restartPackage
		else
			showMessage "Пакет $PACKAGE_NAME не установлен." "e"
			echo ""
			pressAnyKey
		fi
		mainMenu
		exit
	elif [ "$REPLY" = "2" ];then
		if [ -z "$STATUS2" ];then
			stopPackage
		else
			if [ -z "$STATUS1" ];then
				showMessage "Сервер уже остановлен." "e"
				echo ""
				pressAnyKey
			else
				showMessage "Пакет $PACKAGE_NAME не установлен." "e"
				echo ""
				pressAnyKey
			fi
		fi
		mainMenu
		exit
	elif [ "$REPLY" = "3" ];then
		if [ -n "$STATUS1" ];then
			showMessage "Пакет $PACKAGE_NAME не установлен." "e"
			echo ""
			pressAnyKey
		fi
		mainMenu
		exit
	elif [ "$REPLY" = "4" ];then
		if [ -z "$STATUS1" ];then
			settings
		else
			showMessage "Пакет $PACKAGE_NAME не установлен." "e"
			echo ""
			pressAnyKey
		fi
		mainMenu
		exit
	elif [ "$REPLY" = "5" ];then
		if [ -z "$STATUS1" ];then
			LIST_CHANGES="0"
			listsMenu
		else
			showMessage "Пакет $PACKAGE_NAME не установлен." "e"
			echo ""
			pressAnyKey
		fi
		mainMenu
		exit
	elif [ "$REPLY" = "9" ];then
		packageMenu
		mainMenu
		exit
	else
		if [ -z "$STATE0" ];then
			local STATE0="`checkForUpdate "$PACKAGE_NAME nfqws-keenetic-web"`"
			if [ -n "$STATE0" ];then
				echo "$STATE0"
				echo ""
				option "1" "Обновить"
				result "Выход" "d"
				if [ "$REPLY" = "1" ];then
					packageMenu
					mainMenu
				fi
			fi
		fi
		headLine
		copyRight
		clear
		exit
	fi
	}

echo;while [ -n "$1" ];do
case "$1" in

-s)	stopPackage
	logger "$SCRIPT_NAME: остановка $PACKAGE_NAME"
	exit
	;;

-S)	restartPackage
	logger "$SCRIPT_NAME: запуск/перезапуск $PACKAGE_NAME"
	exit
	;;

-u)	headLine "Обновление $SCRIPT_NAME"
	FILE_NAME="`echo "$SCRIPT_NAME" | tr '[:upper:]' '[:lower:]'`.sh"
	UPDATE_FILE="/opt/_update/$FILE_NAME"
	if [ -f "$UPDATE_FILE" ];then
		echo "Локальное обновление..."
	else
		echo "Проверка наличия обновлений..."
		UPDATE_FILE="/tmp/$FILE_NAME"
		installOPKG "ca-certificates" "skip"
		installOPKG "wget-ssl" "skip"
		removeOPKG "wget-nossl" "skip"
		wget -q -O "$UPDATE_FILE" "$SCRIPT_UPDATE_URL"
	fi
	echo ""
	if [ -f "$UPDATE_FILE" ];then
		UPDATE_VERSION="`cat "$UPDATE_FILE" | grep "^SCRIPT_VERSION=\|^VERSION=" | awk -F'"' '{print $2}'`"
		if [ -n "$UPDATE_VERSION" ];then
			if [ "$SCRIPT_VERSION" = "$UPDATE_VERSION" ];then
				showText "\tУстановлена актуальная версия $SCRIPT_NAME."
			else
				halfColored "Текущая версия: " "$SCRIPT_VERSION"
				halfColored "Версия обновления: " "$UPDATE_VERSION"
				echo ""
				showText "\tХотите выполнить обновление?"
				echo ""
				option "1" "Да"
				result "нет" "d"
				if [ "$REPLY" = "1" ];then
					mv "$UPDATE_FILE" "$0"
					chmod +x "$0"
					showMessage "Обновление завершено." "o"
				fi
			fi
			
		else
			showMessage "Файл обновления повреждён." "e"
		fi
		if [ -f "$UPDATE_FILE" ];then
			rm -rf "$UPDATE_FILE"
		fi
		if [ -n "`echo "$UPDATE_FILE" | grep "^/opt/_update/"`" ];then
			rm -rf "`dirname "$UPDATE_FILE"`"
		fi
	else
		showMessage "Не удалось загрузить файл обновления." "e"
	fi
	exit
	;;

-U)	getUpdateVersion "$PACKAGE_NAME nfqws-keenetic-web"
	exit
	;;

-v)	echo "$SCRIPT_VERSION"
	exit
	;;

*) 	echo "$SCRIPT_NAME: неверный ключ. Доступные ключи:"
	echo ""
	halfColored " -s: " "Остановка PACKAGE_NAME"
	halfColored " -S: " "Запуск/перезапуск $PACKAGE_NAME"
	halfColored " -u: " "Обновление $SCRIPT_NAME"
	halfColored " -U: " "Доступные версии пакетов (служебный)" "$ERR_CLR"
	halfColored " -v: " "Версия $SCRIPT_NAME"
	exit
	;;

esac;shift;done

TITLE="`getSetting "friendly_name=" "#" "v"`"
if ! [ -n "$TITLE" -a -z "`getSetting "friendly_name=" "#" "b"`" -a -n "`statusOPKG "$PACKAGE_NAME"`" ];then
	TITLE="$PACKAGE_NAME"
fi
loadConfig "" "skip"
mainMenu
