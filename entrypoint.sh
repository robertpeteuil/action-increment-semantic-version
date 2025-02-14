#!/bin/bash -l

# active bash options:
#   - stops the execution of the shell script whenever there are any errors from a command or pipeline (-e)
#   - option to treat unset variables as an error and exit immediately (-u)
#   - print each command before executing it (-x)
#   - sets the exit code of a pipeline to that of the rightmost command
#     to exit with a non-zero status, or to zero if all commands of the
#     pipeline exit successfully (-o pipefail)
set -euo pipefail

main() {

  prev_version="$1"; release_type="$2"

  if [[ "$prev_version" == "" ]]; then
    echo "could not read previous version"; exit 1
  fi

  possible_release_types="major minor feature patch bug alpha beta rc"

  if [[ ! ${possible_release_types[*]} =~ ${release_type} ]]; then
    echo "valid argument: [ ${possible_release_types[*]} ]"; exit 1
  fi

  major=0; minor=0; patch=0; pre=""; preversion=""; incerror=""

  # break down the version number into it's components
  regex="^([0-9]+).([0-9]+).([0-9]+)((-[a-z]+)(\.)?([0-9]+)?)?$"
  if [[ $prev_version =~ $regex ]]; then
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    patch="${BASH_REMATCH[3]}"
    pre="${BASH_REMATCH[5]}"
    presep="${BASH_REMATCH[6]}"
    preversion="${BASH_REMATCH[7]}"
    preout="$pre$presep$preversion"
  else
    echo "previous version '$prev_version' is not a semantic version"
    exit 1
  fi

  # increment version number based on given release type
  case "$release_type" in
    "major")
      ((++major)); minor=0; patch=0; preout="";;
    "minor" | "feature")
      ((++minor)); patch=0; preout="";;
    "patch" | "bug")
      ((++patch)); preout="";;
    "alpha")
      # is it allowed?
      if [[ "$pre" == "" || "$pre" == "-alpha" ]]; then
        # is it being promoted?
        if [[ "$pre" != "-alpha" ]]; then
          preversion=1
          presep="."
        # is it incrementing a pre without a count
        elif [[ -z "$preversion" ]]; then
          preversion=2
          presep="."
        # else its just incremented
        else
          ((++preversion))
        fi
        preout="-alpha$presep$preversion"
      else
        incerror="cannot increment $pre to -alpha"
      fi
      ;;
    "beta")
      # is it allowed?
      if [[ "$pre" == "" || "$pre" == "-alpha" || "$pre" == "-beta" ]]; then
        # is it being promoted from no pre?
        if [[ "$pre" == "" ]]; then
          preversion=1
          presep="."
        # promotion from alpha
        elif [[ "$pre" != "-beta" ]]; then
          # if pre-release lacks a count, add standard separator
          if [[ "$preversion" == "" ]]; then
            presep="."
          fi
          preversion=1
        # is it incrementing a pre without a count
        elif [[ -z "$preversion" ]]; then
          preversion=2
          presep="."
        # just incremented
        else
          ((++preversion))
        fi
        preout="-beta$presep$preversion"
      else
        incerror="cannot increment $pre to -beta"
      fi
      ;;
    "rc")
      # is it being promoted from no pre?
      if [[ "$pre" == "" ]]; then
        preversion=1
        presep="."
      # promotion from alpha, beta
      elif [[ "$pre" != "-rc" ]]; then
        # if pre-release lacks a count, add standard separator
        if [[ "$preversion" == "" ]]; then
          presep="."
        fi
        preversion=1
      # is it incrementing a pre without a count
      elif [[ -z "$preversion" ]]; then
        preversion=2
        presep="."
      # just incremented
      else
        ((++preversion))
      fi
      preout="-rc$presep$preversion"
      ;;
  esac

  next_version="${major}.${minor}.${patch}${preout}"
  if [[ -n "$incerror" ]]; then
    echo "error: $incerror, initial version returned as output"
  else
    echo "create $release_type-release version: $prev_version -> $next_version"
  fi

  echo "next-version=$next_version" >> $GITHUB_OUTPUT
}

main "$1" "$2"
