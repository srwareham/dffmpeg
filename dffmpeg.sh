#!/usr/bin/env bash
# Written by Sean Wareham on September 18, 2016
# Script to be used with a docker container with ffmpeg as the entrypoint
# Script will act as a drop-in replacement for an ffmpeg binary.
# All operations ffmpeg would handle on the local system are passed off
# to a docker container which has the host's input and output directories mounted
# Allows for use of ffmpeg with limited-to-no overhead without any host system dependencies besides docker

# The name of the docker image which has ffmpeg as its entrypoint
dffmpeg_image_name=arch-ffmpeg
# The path inside the guest container that will be used as a mountpoint for the host's input (should never need modification)
guest_input_dir=/tmp/dffmpeg_in
# The path inside the guest container that will be used as a mountpoint for the host's output (should never need modification)
guest_output_dir=/tmp/dffmpeg_out

failure_encountered=False

# Loop through args to determine input and output paths
host_input_path_is_next=False
for var in "$@"
do
  host_output_path="$var"
  if [ "$host_input_path_is_next" == "True" ]
  then
    host_input_path="$var"
    host_input_path_is_next=False
  fi
  if [ "$var" == "-i" ]
  then
    host_input_path_is_next=True
  fi
done

# Build args for guest (replacing input/output paths with their guest equivalents
guest_args=()
for var in "$@"
do
  # TODO: consider first checking for nonempty??
  guest_arg="$var"
  if [ "$var" == "$host_input_path" ]
  then
    guest_arg="$guest_input_dir/$(basename "$host_input_path")"
  fi
  if [ "$var" == "$host_output_path" ]
  then
    guest_arg="$guest_output_dir/$(basename "$host_output_path")"
  fi
  guest_args+=("$guest_arg")
done


# Terminate with error if either host input path or host output dir are invalid

if [ ! -f "$host_input_path" ]
then
  echo "ERROR: input path \""$host_input_path"\" does not exist!"
  failure_encountered=True
fi
if [ ! -d "$(dirname "$host_output_path")" ]
then
  echo "ERROR: output directory \""$(dirname "$host_output_path")" does not exist!"
  failure_encountered=True
fi

if [ "$failure_encountered" == True ]
then
  exit 1
else
  docker run --rm -it -v "$(dirname "$(realpath "$host_input_path")")":"$guest_input_dir":ro -v "$(dirname "$(realpath "$host_output_path")")":"$guest_output_dir" -u $(id -u):$(id -g) "$dffmpeg_image_name" "${guest_args[@]}"
fi
