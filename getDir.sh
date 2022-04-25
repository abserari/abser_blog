#！ /bin/bash
tou=
function getDir() {
	for filename in $1/*
	do
	    if [ -d "$filename" ]
	    then
	        getDir $filename
	    else
	        if [[ "${filename##*.}" == 'md' ]]
	        then
	            echo $filename
	            sed -i '1i\--- \nlayout: category-post\ntitle:  "Welcome to blog!"\ndate:   2016-08-05 20:20:56 -0400\ncategories: writing\n---\n' "$filename"
	        fi
	    fi
	done
}

getDir ./_posts/