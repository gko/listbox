#!/bin/bash

listbox() {
  while [[ $# -gt 0 ]]
  do
    key="$1"

    case $key in
      -h|--help)
        echo "choose from list of options"
        echo "Usage: listbox [options]"
        echo "Example:"
        echo "  listbox -t title -o \"option 1|option 2|option 3\" -r resultVariable -a '>'"
        echo "Options:"
        echo "  -h, --help                         help"
        echo "  -t, --title                        list title"
        echo "  -o, --options \"option 1|option 2\"  listbox options"
        echo "  -r, --result <var>                 result variable"
        echo "  -a, --arrow <symbol>               selected option symbol"
        return 0
        ;;
      -o|--options)
        local OIFS=$IFS;
        IFS="|";
        # check if zsh/bash
        if [ -n "$ZSH_VERSION" ]; then
          IFS=$'\n' opts=($(echo "$2" | tr "|" "\n"))
        else
          IFS="|" read -a opts <<< "$2";
        fi
        IFS=$OIFS;
        shift
        ;;
      -t|--title)
        local title="$2"
        shift
        ;;
      -r|--result)
        local __result="$2"
        shift
        ;;
      -a|--arrow)
        local arrow="$2"
        shift
        ;;
      *)
    esac
    shift
  done

  if [[ -z $arrow ]]; then
    arrow=">"
  fi

  local len=${#opts[@]}

  local choice=0
  local titleLen=${#title}

  if [[ -n "$title" ]]; then
    echo -e "\n  $title"
    printf "  "
    printf %"$titleLen"s | tr " " "-"
    echo ""
  fi

  draw() {
    local idx=0 
    for it in "${opts[@]}"
    do
      local str="";
      if [ $idx -eq $choice ]; then
        str+="$arrow "
      else
        str+="  "
      fi
      echo "$str$it"
      idx=$((idx+1))
    done
  }

  move() {
    for it in "${opts[@]}"
    do
      tput cuu1
    done
    tput el1
  }

  listen() {
    while true
    do
      key=$(bash -c "read -n 1 -s key; echo \$key")

      if [[ $key = q ]]; then
        break
      elif [[ $key = B ]]; then
        if [ $choice -lt $((len-1)) ]; then
          choice=$((choice+1))
          move
          draw
        fi
      elif [[ $key = A ]]; then
        if [ $choice -gt 0 ]; then
          choice=$((choice-1))
          move
          draw
        fi
      elif [[ $key = "" ]]; then
        # check if zsh/bash
        if [ -n "$ZSH_VERSION" ]; then
          choice=$((choice+1))
        fi

        if [[ -n $__result ]]; then
          eval "$__result=\"${opts[$choice]}\""
        else
          echo -e "\n${opts[$choice]}"
        fi
        break
      fi
    done
  }

  draw
  listen
}
