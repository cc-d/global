CMD="git config --$1 user.$2 '$3'"
echo $CMD;
$CMD;
