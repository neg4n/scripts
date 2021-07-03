#!/bin/bash

print_specific_date() {
  local format
  format="${1}"
  local date 
  date="${2}"

  echo -e " - \033[2m${format}\033[0m: \033[7m ${date} \033[0m"
}

echo
echo -e "Current date: "
print_specific_date "DD/MM/YYYY" "$(date +"%d-%m-%Y")"
print_specific_date "Universal" "$(date)"
echo