#!/bin/sh
#
# PURPOSE:
# ------------------------------------------------------------------------------
# The script will takes a foldername as argument which should not be empty. 
# If the directory contains the log files and these other files do not have the 
# correct naming format this script rename the validly-named files and then sort
# all the files in the directory into one of four subdirectories depending on
# their filename. The script also output what files (and their associated 
# category) are found.
#
# AUTHOR:
# ------------------------------------------------------------------------------
# Name : Ramandeep Kaur
# Student Id: 590658
#
# DATE:
# ------------------------------------------------------------------------------
# 21/04/2022
#
#

# Check the arguments provided are proper or not. 
# If not display usage information.
if [ "$#" -ne 1 ]; then
	echo "Usage: ./binarylog.sh dirname" >&2
	echo "    where dirname is a directory containing binary-named files" >&2
	exit 1
fi

# Check directory exist or not.
if [ -d $1  ]
then
	# Check directory is having read permission or not.
	if [ ! -r $1 ]
	then
		echo "Directory $1 does not readable!"
		exit 1
	fi

	# Check directory is having write permission or not.
	if [ ! -w $1 ]
	then
		echo "Directory $1 does not writable!"
		exit 1
	fi

	# Check directory is having execute permission or not.
	if [ ! -x $1 ]
	then
		echo "Directory $1 does not executable!"
		exit 1
	fi
else
	# Directory doesn't exists.
	echo "Directory $1 does not exists!"
	exit 1
fi

# Check directory contains files or not.
if [ ! "$(ls -A $1 )" ]; then
	echo "The directory $1 contains no files..."
	exit 1
fi

# Change the directory specified one.
cd $1

# List all the files.
for file in `ls`
do
	# Check regular file or not.
	if [[ -f "$file" ]]; then

		# Check te filename starts with word 'file' or not.
		if [[ "$file" == "file"* ]]; then
			# Find length if filename contains digits after 'file'
			# Otherwise returns 0 as length.
			isdigits=$(expr "$file" : "file[0-9]*$")

			# If $isdigits is 0, its having non-binary character
			# after 'file'
			if [ $isdigits -eq 0 ]; then
				echo Invalid - $file non-binary character after 'file'
				# Create a directory 'CATEGORY3' if not exists
				# Move the file to that directory.
				mkdir -p CATEGORY3
				mv $file CATEGORY3

			# If $isdigits is 12, having 8 bit binary charcater after 'file'
			elif [ $isdigits -eq 12 ]; then
				# Convert the binary digits to decimal number.
				# Index should start with five because the length of 
				# word 'file' is four in file name 'fileXXXXXXXX' 
				i=5

				# Values based on the digits position 
				val_array=(128 64 32 16 8 4 2 1)

				# Initial count is zero.	
				count=0

				# Parse the characters from 5th index to 12th.
				while (( i <= 12 ))
				do
					# Get one character in that index.
					char=$(expr substr "$file" $i 1)

					# Multiply with values based on poistion.
					# Add to the count variable .
					count=$((count+ char * val_array[$i-5]))

					(( i += 1 ))
				done

				echo Valid - $file [renamed to file$count]
				# Create a directory 'CATEGORY1' if not exists
				# Move the file to directory with name where binary 
				# digits coverted as decimal number.
				mkdir -p CATEGORY1
				mv $file CATEGORY1/file$count

			# If $isdigits is less than 12 then its does not have 8 bits.
			elif [ $isdigits -lt 12 ] && [ $isdigits -gt 0 ]; then
				echo invalid - $file does not have 8 bits
				# Create a directory 'CATEGORY3' if not exists.
				# Move the file to that directory.
				mkdir -p CATEGORY2
				mv $file CATEGORY2
			fi

		else
			echo Invalid - $file does not start with 'file'
			# Create a directory 'CATEGORY4' if not exists
			# Move the file to that directory.
			mkdir -p CATEGORY4
			mv $file CATEGORY4
		fi
	fi
done

# Change the directory where script executed.
cd -
