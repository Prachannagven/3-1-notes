for file in *; do
	if [[ -f "$file" && "$file" == *" "* ]] ; then
		new_name = "${file// /_}"
		mv -- "$file" "$new_name"
	fi
done
