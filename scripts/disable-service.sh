for s in `launchctl list | grep -oE '[a-zA-Z0-9._-]+$' | grep -v 'Label'`; do 
 printf "Disable: %s?" "$s"
 echo $s | pbcopy; read -r ans
 case "$ans" in
y|Y)

                sudo launchctl disable system/"$s" 2>/dev/null || echo "System disable failed for $s"
                launchctl disable user/$(id -u)/"$s" 2>/dev/null || echo "User disable failed for $s"

                ;;
*)
        echo "Skipped"
;;
esac
done

