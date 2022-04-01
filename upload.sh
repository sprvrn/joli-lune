#upload on itch.io with butler

USER="username"
GAME="game"

cd build
input="buildinfo.txt"
i=0
while IFS= read -r line
do
	bld[$i]=$line
	i=`expr $i + 1`
done < "$input"

BUILD_VERSION=${bld[0]}
SIZE=`expr ${#bld[@]} - 1`

i=1

while [ $i -le $SIZE ]
do
	IFS=':'
	read -ra file <<< "${bld[i]}"

	butler push ${file[1]} $USER/$GAME:${file[0]} --userversion $BUILD_VERSION

	i=`expr $i + 1`
done
