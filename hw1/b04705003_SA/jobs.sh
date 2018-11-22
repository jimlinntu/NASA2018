#!/usr/bin/env bash

# utility: join by
function join_by { local IFS="$1"; shift; echo "$*"; }
# usage
usage="$0: [OPTION...]
-l, --list\\tlisting all grades in descendant order of consuming resource 
(according to CPU usage first, then memory usage)
-m, --mem\\tprint the usage of memory (in KB)
-c, --cpu\\tprint the usage of CPU (in %%)
-h, --help\\tprint this help message"
# parse argument
# -o: means recognize short option, -l: means recognize long option
parsed=$(getopt -o lmch -l list,mem,cpu,help --name "$0" -- "$@" ) 
# if wrong option, then exit
if [[ $? -ne 0 ]]; then
	printf "%b\\n" "$usage"
	exit 2
fi

# set argument to $1 $2 ....
eval set -- "$parsed"

# loop over argument
while true; do
	case "$1" in
		-l|--list)
			l=true
			shift
			;;
		-m|--mem)
			m=true
			shift
			;;
		-c|--cpu)
			c=true
			shift
			;;
		-h|--help)
			h=true
			shift
			;;
		--)
			shift
			break
			;;
	esac
done
# if there is still extra agrument, exit
if [[ $# -gt 0 ]]; then
	printf "jobs.sh : Extra arguments -- %b\\nTry 'jobs.sh -h' for  more information\\n" "$1"
	exit 1
fi
# if help flag is on, exit
if [[ $h == true ]]; then
	# Note: escape % sign by %%
	printf "%b\\n" "$usage"
	exit 0
fi

# user need to at least 9 digit. (ex. b04705003)
ps_aux=$(ps axo user:9,pcpu,vsz | sed '1d' | tr -s ' ') # ps aux result, only leave USER, CPU and MEM columns
groups=( $'^b[0-9]{8}' $'^r[0-9]{8}' $'^d[0-9]{8}' others ) # group regex pattern
group_name=(b r d others)
dataframe=""
# create python pandas-like dataframe
for g in "${group_name[@]}"
do
	# if not others, then loop over every grade. (Seems inefficient, but I am tired to do more optimization... Orz)
	if [[ $g != others ]]; then
		# categorize each grade
		for grade in {0..99}
		do
			tmp_regex="$(printf "%b%02d" "$g" "$grade")" # ex. b00 ~ b99
			grade_rows="$(grep -E "^$tmp_regex" <<< "${ps_aux}")" # grep over rows
			# retreive column
			col="$(cut -d ' ' -f 2,3 <<< "${grade_rows}")" # retreive cpu and mem column
			# if it is empty, then continue.
			if [[ -z "$col" ]]; then
				continue
			fi
			# Sum over two column( CPU, MEM )
			dataframe+="$tmp_regex $(awk '{col1+=$1} {col2+=$2} END{print col1 " " col2}' <<< "${col}")\\n"
		done
	else
		tmp_regex="$( join_by '|' "${groups[@]:0:3}")" # ex. union regex of b, r, d pattern
		grade_rows="$(grep -E -v "$tmp_regex" <<< "${ps_aux}")" # grep over rows
		# retreive column
		col="$(cut -d ' ' -f 2,3 <<< "${grade_rows}")" # retreive cpu and mem column
		if [[ -z "$col" ]]; then
			continue
		fi
		# sum over column
		dataframe+="others $(awk '{col1+=$1} {col2+=$2} END{print col1 " " col2}' <<< "${col}")\\n"
	fi
done
# sort it (first sort field 2 and then field 3)
sorted=$(printf "%b" "$dataframe" | sort -n -r -t ' ' -k 2,2 -k 3,3)
retrieve_col=(1)
# if no -l or --list flag, then retrieve only the first row
if [[ -z $l ]]; then
	sorted="$(head -n 1 <<< "$sorted")"
fi

# if -m or --mem flag exist, then append mem column index
if [[ -n $m ]]; then
	retrieve_col+=(3)
fi

# if -c or --cpu flag exist, then append cpu column index
if [[ -n $c ]]; then
	retrieve_col+=(2)
fi
# retreive column by "retrieve_col" variable
sorted=$(cut -d ' ' -f "$(join_by ',' "${retrieve_col[@]}")" <<< "${sorted}")
# header
header="GROUP"
if [[ -n $c ]]; then
	header+=" CPU(%)"
fi
if [[ -n $m ]]; then
	header+=" MEM(KB)"
fi
# print result
echo -e "$header"
printf "%b\\n" "$sorted"
