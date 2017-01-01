#!/bin/bash

listbox() {
  while [[ $# -gt 1 ]]
  do
    key="$1"

    case $key in
      -h|--help)
        echo "listbox -t title -o \"option 1|option 2|option 3\" -r resultVariable -a '>'"
        return 0
        shift
        ;;
      -o|--options)
        IFS='|' read -a opts <<< "$2"
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
    for idx in ${!opts[*]}
    do
      local str="";
      if [ $idx -eq $choice ]; then
        str+="$arrow "
      else
        str+="  "
      fi
      echo "$str${opts[$idx]}"
    done
  }

  move() {
    for it in ${!opts[*]}
    do
      tput cuu1
    done
    tput el1
  }

  listen() {
    while true
    do
      read -n 1 -s key

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
        if [[ -n $__result ]]; then
          eval "$__result=\"${opts[$choice]}\""
        else
          echo -e "\n ${opts[$choice]}"
        fi
        break
      fi
    done
  }

  draw
  listen
}
