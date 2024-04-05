#!/bin/bash

# Check if the base directory is provided as a command-line argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <base_directory>"
    exit 1
fi

# Base directory containing all the folders
BASE_DIR="$1"

# Initialize a variable to count compatible files
compatible_files_count=0

# Loop through each folder in the base directory
for folder in "$BASE_DIR"/*; do
    # Exclude folders with "unmapped" in the name
    if [[ -d "$folder" && "$folder" != *unmapped* ]]; then
        # Identify the FASTA and BAM files
        fasta_file=$(find "$folder" -type f -name "*.fa")
        bam_file=$(find "$folder" -type f -name "*.bam" ! -name "*unmapped*")
        
        # Check if a valid BAM file is found
        if [ -n "$bam_file" ]; then
            # Increment the count of compatible files
            ((compatible_files_count++))

            # Generate the IGV batch file
            {
                echo "new"
                echo "genome $fasta_file"
                echo "load $bam_file"
                echo "snapshotDirectory $folder"
                echo "goto chr1:1-250000"
                snapshot_name=$(basename "$bam_file" .bam).png
                echo "snapshot $snapshot_name"
                echo "exit"
            } > igv_tmp_batch.config

            # Run IGV with the generated batch file
            ./IGV/igv.sh -b igv_tmp_batch.config

            # Clean up the temporary batch file (optional)
            rm igv_tmp_batch.config
        fi
    fi
done

# Check if script was run
if [ "$compatible_files_count" -gt 0 ]; then
    echo ""
    echo "Operation complete"
    echo "Processed $compatible_files_count sequences"
else
    echo "No sequence files found"
    echo "Usage: $0 <base_directory>"
    exit 1
fi
