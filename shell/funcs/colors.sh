#!/bin/sh


colortext () {
    text="$1"
    color_name="$2"
    reset="$(tput sgr0)"

    case "$color_name" in
        black) color_code="$(tput setaf 0)" ;;
        red) color_code="$(tput setaf 1)" ;;
        green) color_code="$(tput setaf 2)" ;;
        yellow) color_code="$(tput setaf 3)" ;;
        blue) color_code="$(tput setaf 4)" ;;
        magenta) color_code="$(tput setaf 5)" ;;
        cyan) color_code="$(tput setaf 6)" ;;
        white) color_code="$(tput setaf 7)" ;;
        *) color_code="" ;;
    esac

    echo "${color_code}${text}${reset}"
}