#!/bin/bash

# colors for making things pretty
C_RED="\033[0;31m"
C_YELLOW="\033[0;33m"
C_BLUE="\033[0;34m"
C_END="\033[0;0m"

# helper functions
echo_run() {
  # NOTE: Cannot be used with functions that already have an "eval" inside of them
  printf "$C_RED Running Command: $C_END "
  printf "$C_YELLOW"
  echo "$@"
  printf "$C_END \n"
  eval "$@"
}

echo_no_run() {
  # NOTE: This does not run the command - you will still need to run the command
  printf "$C_RED Running Command: $C_END "
  printf "$C_YELLOW"
  echo "$@"
  printf "$C_END \n"
}

# Settings
C_RED="\033[0;31m"
C_YELLOW="\033[0;33m"
C_BLUE="\033[0;34m"
C_END="\033[0;0m"

docker_helper(){
  printf "$C_YELLOW Welcome to the Dose docker_helper help menu. $C_END \n\n"
  printf "Available functions: \n"

  # Docker-Machine Helpers
  printf "$C_YELLOW Docker-Machine Helpers $C_END \n"
  printf "\t * dh_create_machine {machine name} - Creates a docker-machine named {machine name} and necessary flags/settings \n"
  printf "\t\t example: $C_YELLOW dh_create_machine clowder $C_END - would create a docker-machine named \"clowder\" \n"

  printf "\t * dh_switch {machine name} - Switches to a different active machine \n"
  printf "\t\t example: $C_YELLOW dh_switch clowder $C_END - would activate the docker-machine named \"clowder\" \n"

  printf "\t * dh_ssh_m {machine name} - SSH into a specific docker-machine \n"
  printf "\t\t example: $C_YELLOW dh_ssh_m clowder $C_END - would ssh into the docker-machine named \"clowder\"  \n"

  # Misc. Utility Helpers
  printf "$C_YELLOW Misc. Utility & Cleanup Helpers $C_END \n"

  printf "\t * dh_ssh_c {container name} - SSH into a specific container on the active machine \n"

  printf "\t * dh_kill - Kill/Stop all running containers \n"
  printf "\t * dh_d_volumes - Destroy all docker volumes on your host system \n"
  printf "\t * dh_wipe - Stop all running containers and delete everything! (go back to when you had nothing local) \n"

  printf "\t * dh_sd_images {regex} - Search images and remove any found images match the regex passed in \n"
  printf "\t * dh_sd_running {regex} - Search & destroy running containers that match the regex passed in \n"
  printf "\t * dh_sd_project {project name} - Search & destroy docker project images and containers \n"

  printf "\t * dh_clean - Delete all stopped containers & untagged images \n"
  printf "\t * dh_clean_c - Delete all stopped containers \n"
  printf "\t * dh_clean_u - Delete all untagged images \n"
}

# help aliases
dh() { docker_helper; }
dh_help() { docker_helper; }

# Docker-Machine Helpers
dh_create_machine() {
docker-machine create --driver virtualbox --virtualbox-memory "2048" $1
}

dh_switch() {
eval $(docker-machine env $1)
}

dh_ssh_m() {
echo_run docker-machine ssh $1
}

# Misc. Utility Helpers
dh_sd_images() {
  printf "$C_RED Deleting images with tag: $1 $C_END \n"
  echo_no_run "docker images | grep $1 | awk '{print $3}' | xargs docker rmi"
  docker images | grep $1 | awk '{print $3}' | xargs docker rmi
}

dh_sd_running() {
  printf "$C_RED Stopping & Removing containers with tag: $1 $C_END \n"
  echo_no_run "docker ps | grep $1 | awk '{print $1}' | xargs docker kill"
  docker ps | grep $1 | awk '{print $1}' | xargs docker kill
  echo_no_run "docker ps -a | grep $1 | awk '{print $1}' | xargs docker rm"
  docker ps -a | grep $1 | awk '{print $1}' | xargs docker rm
}

dh_d_volumes() {
  printf "$C_RED Deleted all volumes on active docker-machine $C_END \n"
  echo_run "docker volume ls | awk '{if (NR!=1) {print $2}}' | xargs docker volume rm"
}

dh_kill() {
  printf "$C_RED Killing all running containers $C_END \n"
  echo_run "docker ps -q | xargs docker kill"
}

dh_clean_c(){
  printf "$C_RED Deleting stopped containers $C_END \n"
  echo_run "docker ps -a -q | xargs docker rm"
}

dh_clean_u(){
  printf "$C_RED Deleting untagged images $C_END \n"
  echo_run "docker images -q -f dangling=true | xargs docker rmi"
}

dh_ssh_c() {
docker exec -it $1 bash
}

# Combined funcs
dh_sd_project() {
dh_sd_running $1
dh_sd_images $1
}

dh_clean(){
# Delete all stopped containers and untagged images.
dh_clean_c
dh_clean_u
}

dh_wipe(){
printf "$C_RED Removing all images & containers on active docker-machine $C_END \n"
dh_kill
dh_clean_c
dh_clean_u
printf "$C_RED Deleting images $C_END \n"
echo_run "docker images -q | xargs docker rmi"
}
