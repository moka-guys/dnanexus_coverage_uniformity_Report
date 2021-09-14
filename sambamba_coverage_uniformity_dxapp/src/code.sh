#!/bin/bash
# sambamba_coverage_uniformity 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

# Exit at any point if there is any error and output each line as it is executed (for debugging)
set -e -x -o pipefail

echo $selected_project

main() {
    # SET VARIABLES
    # Store the API key. Grants the script access to DNAnexus resources    
    API_KEY=$(dx cat project-FQqXfYQ0Z0gqx7XG9Z2b4K43:mokaguys_nexus_auth_key)
    # Capture the project runfolder name. Names the multiqc HTML input and builds the output file path
    
    # Create folders for output coverage_summary_out -
    # path after output/coverage_summary_out is where in the DNA Nexus project the files will be saved.
    outdir=out/coverage_summary_out/coverage/uniformity_metrics 
    mkdir -p ${outdir}

    # Sambamba files for are stored at 'selected_multiqc:coverage/raw_output/''. Download the contents of this folder.
    dx download ${selected_project}:${input_directory}* --auth ${API_KEY}

    # Call the docker image. This image is saved as a compressed tarball on DNAnexus, bundled with the app.
    # Download the docker tarball - graemesmith_uniform_coverage.tar.gz
    dx download project-ByfFPz00jy1fk6PjpZ95F27J:file-FjYXPpQ0jy1y83b92fpvpkZK

    # Give all users access to docker.sock
    sudo chmod 666 /var/run/docker.sock

    # Load docker image from tarball
    docker load < graemesmith_uniform_coverage.tar.gz

    # Execute the dockerised R script - args described below:
    # -v /home/dnanexus:/home Bind the directory /home/dnanexus in the DNA Nexus instance to the /home folder in the docker app
    # This insures that all the files produced in the docker instance will be saved before the docker instance closes
    # --rm automatically remove the container when it finishes
    # graemesmith/uniform-coverage Rscript "/src/sambamba_exon_coverage.R" Run the R script with the following parameters:
    # "/home" = data_directory
    # /home/${outdir} = output_directory
    # ".sambamba_output.bed" = suffix_pattern
    docker run -v /home/dnanexus:/home --rm graemesmith/uniform-coverage Rscript "/src/sambamba_exon_coverage.R"  --input_directory "/home" --output_directory /home/${outdir} --suffix_pattern ${suffix_pattern} --group_by ${group_by} --plot_figures ${plot_figures} --simple_plot_only ${simple_plot_only} --no_jitter ${no_jitter}
    
    # Upload results to DNA nexus
    dx-upload-all-outputs
}
