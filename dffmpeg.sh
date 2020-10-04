#!/usr/bin/env bash
# Written by Sean Wareham on September 18, 2016
# Script to be used with a docker container with ffmpeg as the entrypoint
# Script will act as a drop-in replacement for an ffmpeg binary.
# All operations ffmpeg would handle on the local system are passed off
# to a docker container which has the host's input and output directories mounted
# Allows for use of ffmpeg with limited-to-no overhead without any host system dependencies besides docker

# The name of the docker image which has ffmpeg as its entrypoint
dffmpeg_image_name=alpine-ffmpeg
# The path inside the guest container that will contain subdirectories
# used as mountpoints for the host's input (should never need modification)
guest_input_dir=/tmp/dffmpeg_in
# The path inside the guest container that will be used as a mountpoint for the host's output (should never need modification)
guest_output_dir=/tmp/dffmpeg_out

failure_encountered=False

if [ $# -eq 0 ]
then
  echo "ERROR: at least two inputs required! Must pass an input file (preceded by "-i") and an output path"
  failure_encountered=True
fi


# Loop through args to determine input and output paths
host_input_path_is_next=False
declare -A host_input_paths  # maps (host input path) -> (guest input dir)
for var in "$@"
do
  host_output_path="$var"
  if [ "$host_input_path_is_next" == "True" ]
  then
    host_input_paths[$var]="$guest_input_dir/$(cat /proc/sys/kernel/random/uuid)"
    host_input_path_is_next=False
  fi
  if [ "$var" == "-i" ]
  then
    host_input_path_is_next=True
  fi
done

# Build args for guest (replacing input/output paths with their guest equivalents
guest_args=()
# mount specs for input file directories
mount_args=()
for var in "$@"
do
  # TODO: consider first checking for nonempty??
  guest_arg="$var"
  if [ -n "${host_input_paths[$var]}" ]
  then
    guest_arg="${host_input_paths[$var]}/$(basename "$var")"
    mount_args+=(-v "$(dirname "$(realpath "$var")")":"${host_input_paths[$var]}":ro)
  fi
  if [ "$var" == "$host_output_path" ]
  then
    guest_arg="$guest_output_dir/$(basename "$host_output_path")"
  fi
  guest_args+=("$guest_arg")
done


# Terminate with error if any host input path or the host output dir are invalid

for var in "${!host_input_paths[@]}"
do
  if [ ! -f "$var" ]
  then
    echo "ERROR: input path \""$var"\" does not exist!"
    failure_encountered=True
  fi
done
if [ ! -d "$(dirname "$host_output_path")" ]
then
  echo "ERROR: output directory \""$(dirname "$host_output_path")" does not exist!"
  failure_encountered=True
fi

if [ "$failure_encountered" == True ]
then
  exit 1
else
  # Runs the docker container with ffmpeg as its entrypoint
  # Run configurations:
  # Mount the input volume as read only
  # Mount the output volume as rw (overwrites input ro if overlapping)
  # Executes ffmpeg with the same uid and gid as the caller
  # Passes all arguments to the guest container (while appropriately modifying input and output paths)
  docker run --rm -it "${mount_args[@]}" -v "$(dirname "$(realpath "$host_output_path")")":"$guest_output_dir" -u $(id -u):$(id -g) "$dffmpeg_image_name" "${guest_args[@]}"
fi
