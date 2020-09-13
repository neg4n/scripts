#!/bin/bash

exit_message() {
  local type
  type="${1}"
  case "${type}" in
  "command_not_found")
    echo -e "\nCommand not found."
    echo -e "\nAvailable commands: \n install <fontfile>\n remove <fontname>\n list\n"
    ;;
  "file_does_not_exist")
    echo -e "\nFile does not exist.\n"
    ;;
  "font_not_installed")
    echo -e "\nThis font is not installed.\n"
    ;;
  "file_not_supported")
    echo -e "\nThis file is not a font or it is not supported.\n"
    ;;
  "missing_argument")
    echo -e "\nToo few arguments provided.\n"
    ;;
  esac
  exit 1
}

file_check() {
  local filename
  filename="${1}"
  local resolved_path
  resolved_path="$(realpath "${filename}")"
  if [[ $(test -a "${resolved_path}" && echo "true") == "true" ]]; then
    font_path="${resolved_path}"
    if [[ "${font_path}" != *.ttf ]]; then
      exit_message "file_not_supported"
    fi
  else
    exit_message "file_does_not_exist"
  fi
}

if [[ "${1}" == "" ]]; then
  exit_message "command_not_found"
fi

if [[ $(test -d "${HOME}/.local/share/fonts" && echo "true") != "true" ]]; then
  mkdir -p "${HOME}/.local/share/fonts"
  echo "Created ~/.local/share/fonts directory"
fi

while [ "${1}" != "" ]; do
  case ${1} in
  "install")
    shift
    filename="${1}"
    resolved_path="$(realpath "${filename}")"
    if [[ $(test -a "${resolved_path}" && echo "true") == "true" ]]; then
      font_path="${resolved_path}"
      if [[ "${font_path}" != *.ttf ]]; then
        exit_message "file_not_supported"
      fi
    else
      exit_message "file_does_not_exist"
    fi
    IFS='/'
    read -r -a temp <<<"${font_path}"
    # Print each value of the array by using the loop
    font_name="${temp[${#temp[@]} - 1]}"
    cp "${font_path}" "${HOME}/.local/share/fonts/${font_name}"
    fc-cache -f -v | grep -m 1 -o "abc" | grep -o "123" &
    this_pid=$!
    i=1
    sp="/-\|"
    echo -ne "\nWorking x"
    while [ -d /proc/"$this_pid" ]; do
      printf "\b${sp:i++%${#sp}:1}"
      sleep 0.1
    done
    echo -e "\nSuccessfully installed ${font_name}\n"
    ;;
  "remove" | "uninstall")
    shift
    # file_check "${1}"
    font_name="${1}"
    if [[ $(test -z "${1}" && echo "true") == "true" ]]; then
      exit_message "missing_argument"
    fi
    for file in "${HOME}/.local/share/fonts"/*; do
      IFS='/'
      read -r -a temp <<<"${file}"
      installed_font_name="${temp[${#temp[@]} - 1]}"
      if [[ $(test "${installed_font_name}" = "${font_name}" && echo "true") == "true" ]]; then
        rm "${file}"
        fc-cache -f -v | grep -m 1 -o "abc" | grep -o "123" &
        this_pid=$!
        i=1
        sp="/-\|"
        echo -ne "\nWorking x"
        while [ -d /proc/"$this_pid" ]; do
          printf "\b${sp:i++%${#sp}:1}"
          sleep 0.1
        done
        echo -e "\nSuccessfully uninstalled ${font_name}\n"
        exit
      fi
    done
    exit_message "font_not_installed"
    ;;
  "list")
    fc-list
    exit
    ;;
  *)
    exit_message "command_not_found"
    ;;
  esac
  shift
done
