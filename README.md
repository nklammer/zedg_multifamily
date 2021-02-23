# zedg-mixeduse-multifamily

This repository will be used to experiment with workflows that combine both BEopt (residential) and OpenStudio-standards (commercial) in a single structure for modeling mixed-use multifamily projects.

## Source Measures
The measures used for this workflow are contained in other NREL GitHub.com repositories. The OSW expects those repositories to be checked out next to this repository. Listed below are the repsitories and branches that this repository is dependent on.
- https://github.com/NREL/OpenStudio-measures (exterior_adiabatic branch)
- https://github.com/NREL/OpenStudio-BuildStock (multifamily-zedg branch)
- https://github.com/UnmetHours/openstudio-measures (master branch)
- https://github.com/NREL/openstudio-standards (master branch)
- If use case specific measures are needed, they may be added directly in this repository under a "measures" directory.

Use the [OpenStudio Command Line Interface](http://nrel.github.io/OpenStudio-user-documentation/reference/command_line_interface/) to run the workflows.

Run workflow: `openstudio run --workflow /path/to/workflow.osw`

Run workflow measures only: `openstudio run --measures_only --workflow /path/to/workflow.osw`

Custom standards is currently necessary, see branch in source measures section
Run with custom standards Gem: 
`openstudio --verbose --gem_path /Users/dgoldwas/.rbenv/versions/2.2.4/lib/ruby/gems/2.2.0/gems/openstudio-standards-0.2.10 run --workflow floorplan.osw`

## Workflows

- custom_example_multifamily: This is a 4 story, 20 unit per story multifamily building made using residential measures. A measure to populate the commecial first floor with loads and schedules is added at the end of the workflow. Configured to run for 1 month but can be updated using ResidentialSimulationControls to run for the full year.
- custom_example_testing: This is a smaller 3 story, 6 unit per story example for testing out code changes. It's setup to run for the full year, and takes about 20-25 minutes to run.

## Analyses
Development testing has been using an OSW file in the `workflows/json_test_chicago` directory. Instead of keeping a PAT projet in sync with that we are using a ruby script named `osw_2_osa_multizedg.rb`. This script creates an OSA file from the OSW file, sets up specified variables, and creates the necessary analysis zip file, with measures from across the repositories defined in the test OSW. Here are the steps to generate and run the OSA.
1. Checkout the repositories specified earlier in the readme file. They should sit next to this repository checkout.
2. change directory to the `analyses` directory and run `osw_2_osa_multizedg.rb`. There are two optional bool arguments that both default to true. The first determines if a new analysis json is generated, and the second if the zip file is generated. There may be times that you just want to re-generate one of the two.
3. To make using the metaCLI easier setup your computer so the command line in recognized. For example on mac add this line to your `.bash_profile`. 
 
    export PATH="/Applications/OpenStudio-2.9.0/ParametricAnalysisTool.app/Contents/Resources/OpenStudio-server/bin":$PATH
4. Call the command using call similar to this. 

    `openstudio_meta run_analysis --debug --verbose --ruby-lib-path="/Applications/OpenStudio-2.9.0/ParametricAnalysisTool.app/Contents/Resources/ruby" "custom_floorplan/custom_floorplan.json" "http://bball-130553.nrel.gov:8080/" -a doe`

## Geometry

Currently the geometry is being made using pre-made  custom floor plans using https://nrel.github.io/floorspace.js/. There are also measure in the workflow that can parametrically generate typical multifamily layouts.