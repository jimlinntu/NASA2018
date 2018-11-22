#!/usr/bin/env bash
winning_file=$1
receipt_file=$2
# read file
winning_file="$(cat "$1")"
receipt_file="$(cat "$2")"

# loop over receipt file
num_receipt=0
num_valid=0
num_win=0
total_money=0
winning_array=""
index=0
# loop over receipt_file
while IFS='' read -r line || [[ -n "$line" ]]; do
	#
	index=$((index + 1))
	# count total
	num_receipt=$((num_receipt + 1))
	# check if it is valid
	if [[ $line =~ ^[0-9]{8}$ || $line =~ ^[A-Za-z]{2}-[0-9]{8}$ || $line =~ ^[A-Za-z]{2}[0-9]{8}$ ]]; then
		num_valid=$((num_valid + 1))
		
		#check if win
		win_index=0 # winning prize index
		for win_number in ${winning_file}
		do
			win_index=$((win_index + 1))
			# match first prize first (if 3<= win_index <= 5)
			if [[ $win_index -ge 3  && $win_index -le 5 ]]; then 
				for (( i=8; i >= 3; i=i-1 )) 
				do
					# first match last length i number
					if [[ $line =~ ${win_number:$(( 8 - i  )):${i}}$ ]]; then
						#
						num_win=$((num_win + 1))
						winning_array+="${num_win}. $line (${index}) "
						case ${i} in
						8)
							total_money=$((total_money + 200000))
							winning_array+=" \$200000\\n"
							;;
						7)
							total_money=$((total_money + 40000))
							winning_array+=" \$40000\\n"
							;;
						6)
							total_money=$((total_money + 10000))
							winning_array+=" \$10000\\n"
							;;
						5)
							total_money=$((total_money + 4000))
							winning_array+=" \$4000\\n"
							;;
						4)
							total_money=$((total_money + 1000))
							winning_array+=" \$1000\\n"
							;;
						3)
							total_money=$((total_money + 200))
							winning_array+=" \$200\\n"
							;;
						esac
						# longest match
						break
					fi
				done
			# if win_index not in [3, 5], match other prize (prevent same last numbers as addtional prize)
			elif [[ $line =~ ${win_number}$ ]]; then
				# 
				num_win=$((num_win + 1))
				# append winning info
				winning_array+="${num_win}. $line (${index}) "
				# special prize
				if [[ $win_index -eq 1 ]]; then
					total_money=$((total_money + 10000000))
					# money
					winning_array+=" \$10000000\\n"
				# grand prize
				elif [[ $win_index -eq 2 ]]; then
					total_money=$((total_money + 2000000))
					# money
					winning_array+=" \$2000000\\n"
				# additional prize
				elif [[ $win_index -ge 6 && $win_index -le 8 ]]; then
					total_money=$((total_money + 200))
					# money 
					winning_array+=" \$200\\n"
				fi


			fi
		done
	fi
	
done <<< "${receipt_file}"

# print result
printf "The number of receipts: %s\\n" "${num_receipt}"
printf "The number of valid receipts: %s\\n" "${num_valid}"
printf "The number of winning lotteries: %s\\n" "${num_win}"
printf "The winning money: %s\\n" "${total_money}"
printf "Winning Lotteries:\\n%b" "${winning_array}"
