#!/usr/bin/env bash
# Run this script with Bash, located through the user's PATH.

# Sort files in a folder into subfolders based on their filename extensions.
# Commands to run the script:
#   ./sorter.sh                 # Sort ~/Downloads, then keep watching.
#   ./sorter.sh -o              # Sort once and exit.
#   ./sorter.sh -d /some/folder # Sort a specified folder.
#   ./sorter.sh -h              # Display help.

# Use my Downloads directory unless another directory is specified.
TARGET_DIR="$HOME/Downloads"
# Default to continuing to watch after the initial sort.
ONCE=false
# Wait this many seconds between folder scans in watch mode. To not nuke my cpu.
INTERVAL=5

# Make a function that prints the command-line usage information.
usage() {
    # The script's purpose.
    echo "Sort downloaded folder into subfolders by file type."
    # Print a blank line to separate the description from the options.
    echo ""
    # Show the accepted options, using $0 as the invoked script name.
    echo "Usage: $0 [-d directory] [-o] [-h]"
    # Explain that -d selects the directory to sort.
    echo "  -d  folder to sort (default: ~/Downloads)"
    # Explain that -o disables watch mode and exits after sorting once.
    echo "  -o  sort once and exit instead of watching"
    # Explain that -h prints this help text.
    echo "  -h  show this help"
}

# Read command-line options, treating -d as an option that requires a value.
while getopts "d:oh" opt; do
    # Choose the action corresponding to the option just parsed.
    case "$opt" in
        # Save the directory supplied after -d.
        d) TARGET_DIR="$OPTARG" ;;
        # Enable one-time mode when -o is supplied.
        o) ONCE=true ;;
        # Print help and exit successfully when -h is supplied.
        h) usage; exit 0 ;;
        # Print help and exit with an error for an invalid option.
        *) usage; exit 1 ;;
    # Finish handling the parsed option.
    esac
# Continue until getopts has processed all supplied options.
done

# Check whether the selected path is an existing directory.
if [ ! -d "$TARGET_DIR" ]; then
    # Report the invalid directory on standard error.
    echo "Error: folder not found: $TARGET_DIR" >&2
    # Stop because there is no folder to sort.
    exit 1
# Finish the directory validation conditional.
fi

# Map a filename extension to the name of its destination category folder.
get_file_type() {
    # Reserve a function-local variable for the extracted extension.
    local ext
    # Extract the text after the final dot and normalize it to lowercase.
    ext=$(echo "${1##*.}" | tr '[:upper:]' '[:lower:]')

    # Select a category by matching the normalized extension.
    case "$ext" in
        pdf) echo "PDFs" ;;
        doc|docx|dot|dotx|odt|rtf) echo "Word Documents" ;;
        xls|xlsx|xlsm|csv|ods) echo "Excel Spreadsheets" ;;
        ppt|pptx|pps|ppsx|odp) echo "PowerPoints" ;;
        txt|md|log) echo "Text Files" ;;
        jpg|jpeg|png|gif|bmp|webp|svg|tif|tiff|heic|ico|psd) echo "Pictures" ;;
        mp4|mkv|avi|mov|wmv|flv|webm) echo "Videos" ;;
        mp3|wav|flac|aac|ogg|m4a|wma) echo "Audio" ;;
        cia|3ds|cci|3dsx) echo "3DS Games" ;;
        nds|gba|gb|gbc|nes|sfc|smc|z64|n64|iso|nsp|xci) echo "ROMs" ;;
        zip|rar|7z|tar|gz|bz2|xz) echo "Archives" ;;
        exe|msi|dmg|pkg|deb|appimage) echo "Applications" ;;
        epub|mobi|azw3) echo "Ebooks" ;;
        py|js|ts|html|css|json|xml|java|c|cpp|h|cs|sh|bat) echo "Code" ;;
        *) echo "Other" ;;
    # Finish matching the extension.
    esac
}

# Return success only when a file's size remains unchanged for one second.
is_settled() {
    # Reserve local variables for the two file-size measurements.
    local size1 size2
    # Measure the file's byte count, returning false if it cannot be read.
    size1=$(wc -c < "$1" 2>/dev/null) || return 1
    # Wait a moment to give an in progress download time to change.
    sleep 1
    # Measure again, returning false if the file cannot be read.
    size2=$(wc -c < "$1" 2>/dev/null) || return 1
    # Succeed when both measurements match, indicating a stable size.
    [ "$size1" = "$size2" ]
# End the file-stability check function.
}

# Print an available destination path without overwriting an existing file.
unique_dest() {
    # Store the destination folder and original filename in local variables.
    local dir="$1" name="$2"
    # Construct the desired destination using the original filename.
    local dest="$dir/$name"
    # Use the original name immediately if no file already has that path.
    if [ ! -e "$dest" ]; then
        # Return the available path to the caller.
        echo "$dest"
        # Stop checking because the original path is available.
        return
    # Continue with a numbered name if the original path is taken.
    fi
    # Separate the filename stem and prepare an empty extension.
    local stem="${name%.*}" ext=""
    # Preserve the final extension when the filename contains a dot.
    [[ "$name" == *.* ]] && ext=".${name##*.}"
    # Start numbering duplicate filenames at 1.
    local n=1
    # Keep looking while the candidate numbered path already exists.
    while [ -e "$dir/$stem ($n)$ext" ]; do
        # Try the next number for the duplicate filename.
        n=$((n + 1))
    # Stop once an unused numbered path is found.
    done
    # Return the first available numbered destination path.
    echo "$dir/$stem ($n)$ext"
# End the unique destination function.
}

# Sort eligible files from the selected directory and count successful moves.
sort_folder() {
    # Initialize the moved-file counter and declare per-file working variables.
    local moved=0 file name category dest_dir dest

    # Visit each non-hidden top-level path in the selected directory.
    for file in "$TARGET_DIR"/*; do
        # Ignore anything that is not a regular file, including directories.
        [ -f "$file" ] || continue
        # Extract the filename without its parent directory.
        name=$(basename "$file")

        # Skip the sorter itself so it does not move while running.
        [ "$file" -ef "$0" ] && continue
        # Skip common temporary filename suffixes used for incomplete downloads.
        case "$name" in
            # Leave recognized partial downloads for a later scan.
            *.crdownload|*.part|*.tmp|*.download|*.partial|*.opdownload) continue ;;
        # Finish checking the filename for partial-download suffixes.
        esac
        # Leave files alone until their byte size appears stable.
        is_settled "$file" || continue

        # Choose the destination category based on the filename extension.
        category=$(get_file_type "$name")
        # Build the path to the selected category subfolder.
        dest_dir="$TARGET_DIR/$category"
        # Create the category subfolder if it does not already exist.
        mkdir -p "$dest_dir"
        # Select a destination name that will not overwrite an existing file.
        dest=$(unique_dest "$dest_dir" "$name")

        # Move the source file and handle success or failure.
        if mv -- "$file" "$dest"; then
            # Report the filename and category after a successful move.
            echo "$name  ->  $category/"
            # Increment the count of files moved during this scan.
            moved=$((moved + 1))
        # Handle a failed move without stopping the scan.
        else
            # Report the failed move on standard error.
            echo "Could not move $name" >&2
        # Finish the move-result conditional.
        fi
    # Continue until every top-level path has been considered.
    done
    # Publish this scan's moved-file count for the caller to display.
    SORTED_COUNT=$moved
# End the folder-sorting function.
}

# Announce which directory is about to be sorted.
echo "Sorting $TARGET_DIR"
# Perform the initial scan of the selected directory.
sort_folder
# Report how many files the initial scan moved.
echo "Scan complete. Moved $SORTED_COUNT file(s)."

# Check whether the user requested a one-time run.
if [ "$ONCE" = true ]; then
    # Confirm completion and exit instead of entering watch mode.
    echo "All done."
    exit 0
# Continue to watch when one-time mode was not requested.
fi

# Stop immediately if the initial scan found no files to move.
if [ "$SORTED_COUNT" -eq 0 ]; then
    # Tell the user that this scan found nothing to sort.
    echo "All done. No files were moved."
    # Exit successfully because the folder is idle.
    exit 0
# Continue into watch mode when the initial scan moved files.
fi

# Print a friendly message and exit cleanly when Ctrl+C is pressed.
trap 'echo; echo "Stopped."; exit 0' INT
# Tell the user the watch interval and how to stop the script.
echo "Watching for new files every ${INTERVAL}s. Press Ctrl+C to stop."
# Keep scanning until a scan moves no files.
while true; do
    # Wait for the configured interval before scanning again.
    sleep "$INTERVAL"
    # Sort any eligible files that appeared since the previous scan.
    sort_folder
    # Report the number of files moved during this scan.
    echo "Moved $SORTED_COUNT file(s) in this interval."
    # Check whether this scan found no files to move.
    if [ "$SORTED_COUNT" -eq 0 ]; then
        # Tell the user that sorting is complete.
        echo "All done. No files were moved."
        # Exit successfully because the folder is idle.
        exit 0
    # Continue scanning when this interval moved files.
    fi
# Repeat the scan after the configured delay.
done