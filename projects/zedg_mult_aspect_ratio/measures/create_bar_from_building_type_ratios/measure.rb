# *******************************************************************************
# OpenStudio(R), Copyright (c) 2008-2019, Alliance for Sustainable Energy, LLC.
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# (1) Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# (2) Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# (3) Neither the name of the copyright holder nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission from the respective party.
#
# (4) Other than as required in clauses (1) and (2), distributions in any form
# of modifications or other derivative works may not use the "OpenStudio"
# trademark, "OS", "os", or any other confusingly similar designation without
# specific prior written permission from Alliance for Sustainable Energy, LLC.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER(S) AND ANY CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER(S), ANY CONTRIBUTORS, THE
# UNITED STATES GOVERNMENT, OR THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF
# THEIR EMPLOYEES, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# *******************************************************************************

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

require 'openstudio-standards'

begin
  # load OpenStudio measure libraries from common location
  require 'measure_resources/os_lib_helper_methods'
  require 'measure_resources/os_lib_geometry'
  require 'measure_resources/os_lib_model_generation'
  require 'measure_resources/os_lib_model_simplification'
rescue LoadError
  # common location unavailable, load from local resources
  require_relative 'resources/os_lib_helper_methods'
  require_relative 'resources/os_lib_geometry'
  require_relative 'resources/os_lib_model_generation'
  require_relative 'resources/os_lib_model_simplification'
end

# start the measure
class CreateBarFromBuildingTypeRatios < OpenStudio::Measure::ModelMeasure
  # resource file modules
  include OsLib_HelperMethods
  include OsLib_Geometry
  include OsLib_ModelGeneration
  include OsLib_ModelSimplification

  # human readable name
  def name
    return 'Create Bar From Building Type Ratios'
  end

  # human readable description
  def description
    return 'Create a core and perimeter bar sliced by space type.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Space Type collections are made from one or more building types passed in with user arguments.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # Make an argument for the bldg_type_a
    bldg_type_a = OpenStudio::Measure::OSArgument.makeChoiceArgument('bldg_type_a', get_building_types, true)
    bldg_type_a.setDisplayName('Primary Building Type')
    bldg_type_a.setDefaultValue('SmallOffice')
    args << bldg_type_a

    # Make argument for bldg_type_a_num_units
    bldg_type_a_num_units = OpenStudio::Measure::OSArgument.makeIntegerArgument('bldg_type_a_num_units', true)
    bldg_type_a_num_units.setDisplayName('Primary Building Type Number of Units')
    bldg_type_a_num_units.setDefaultValue(1)
    args << bldg_type_a_num_units

    # Make an argument for the bldg_type_b
    bldg_type_b = OpenStudio::Measure::OSArgument.makeChoiceArgument('bldg_type_b', get_building_types, true)
    bldg_type_b.setDisplayName('Building Type B')
    bldg_type_b.setDefaultValue('SmallOffice')
    args << bldg_type_b

    # Make argument for bldg_type_b_fract_bldg_area
    bldg_type_b_fract_bldg_area = OpenStudio::Measure::OSArgument.makeDoubleArgument('bldg_type_b_fract_bldg_area', true)
    bldg_type_b_fract_bldg_area.setDisplayName('Building Type B Fraction of Building Floor Area')
    bldg_type_b_fract_bldg_area.setDefaultValue(0.0)
    args << bldg_type_b_fract_bldg_area

    # Make argument for bldg_type_b_num_units
    bldg_type_b_num_units = OpenStudio::Measure::OSArgument.makeIntegerArgument('bldg_type_b_num_units', true)
    bldg_type_b_num_units.setDisplayName('Building Type B Number of Units')
    bldg_type_b_num_units.setDefaultValue(1)
    args << bldg_type_b_num_units

    # Make an argument for the bldg_type_c
    bldg_type_c = OpenStudio::Measure::OSArgument.makeChoiceArgument('bldg_type_c', get_building_types, true)
    bldg_type_c.setDisplayName('Building Type C')
    bldg_type_c.setDefaultValue('SmallOffice')
    args << bldg_type_c

    # Make argument for bldg_type_c_fract_bldg_area
    bldg_type_c_fract_bldg_area = OpenStudio::Measure::OSArgument.makeDoubleArgument('bldg_type_c_fract_bldg_area', true)
    bldg_type_c_fract_bldg_area.setDisplayName('Building Type C Fraction of Building Floor Area')
    bldg_type_c_fract_bldg_area.setDefaultValue(0.0)
    args << bldg_type_c_fract_bldg_area

    # Make argument for bldg_type_c_num_units
    bldg_type_c_num_units = OpenStudio::Measure::OSArgument.makeIntegerArgument('bldg_type_c_num_units', true)
    bldg_type_c_num_units.setDisplayName('Building Type C Number of Units')
    bldg_type_c_num_units.setDefaultValue(1)
    args << bldg_type_c_num_units

    # Make an argument for the bldg_type_d
    bldg_type_d = OpenStudio::Measure::OSArgument.makeChoiceArgument('bldg_type_d', get_building_types, true)
    bldg_type_d.setDisplayName('Building Type D')
    bldg_type_d.setDefaultValue('SmallOffice')
    args << bldg_type_d

    # Make argument for bldg_type_d_fract_bldg_area
    bldg_type_d_fract_bldg_area = OpenStudio::Measure::OSArgument.makeDoubleArgument('bldg_type_d_fract_bldg_area', true)
    bldg_type_d_fract_bldg_area.setDisplayName('Building Type D Fraction of Building Floor Area')
    bldg_type_d_fract_bldg_area.setDefaultValue(0.0)
    args << bldg_type_d_fract_bldg_area

    # Make argument for bldg_type_d_num_units
    bldg_type_d_num_units = OpenStudio::Measure::OSArgument.makeIntegerArgument('bldg_type_d_num_units', true)
    bldg_type_d_num_units.setDisplayName('Building Type D Number of Units')
    bldg_type_d_num_units.setDefaultValue(1)
    args << bldg_type_d_num_units

    # Make argument for total_bldg_floor_area
    total_bldg_floor_area = OpenStudio::Measure::OSArgument.makeDoubleArgument('total_bldg_floor_area', true)
    total_bldg_floor_area.setDisplayName('Total Building Floor Area')
    total_bldg_floor_area.setUnits('ft^2')
    total_bldg_floor_area.setDefaultValue(10000.0)
    args << total_bldg_floor_area

    # Make argument for single_floor_area
    single_floor_area = OpenStudio::Measure::OSArgument.makeDoubleArgument('single_floor_area', true)
    single_floor_area.setDisplayName('Single Floor Area')
    single_floor_area.setDescription('Non-zero value will fix the single floor area, overriding a user entry for Total Building Floor Area')
    single_floor_area.setUnits('ft^2')
    single_floor_area.setDefaultValue(0.0)
    args << single_floor_area

    # Make argument for bar_width
    bar_width = OpenStudio::Measure::OSArgument.makeDoubleArgument('bar_width', true)
    bar_width.setDisplayName('Bar Width')
    bar_width.setDescription('Non-zero value will fix the building width, overriding user entry for Perimeter Multiplier. NS/EW Aspect Ratio may be limted based on target width.')
    bar_width.setUnits('ft')
    bar_width.setDefaultValue(0.0)
    args << bar_width

    # Make argument for floor_height
    floor_height = OpenStudio::Measure::OSArgument.makeDoubleArgument('floor_height', true)
    floor_height.setDisplayName('Typical Floor to FLoor Height')
    floor_height.setDescription('Selecting a typical floor height of 0 will trigger a smart building type default.')
    floor_height.setUnits('ft')
    floor_height.setDefaultValue(0.0)
    args << floor_height

    # add argument to enalbe/disable multi custom space height bar
    custom_height_bar = OpenStudio::Measure::OSArgument.makeBoolArgument('custom_height_bar', true)
    custom_height_bar.setDisplayName('Enable Custom Height Bar Application')
    custom_height_bar.setDescription('This is argument value is only relevant when smart default floor to floor height is used for a building type that has spaces with custom heights.')
    custom_height_bar.setDefaultValue(true)
    args << custom_height_bar

    # Make argument for num_stories_above_grade
    num_stories_above_grade = OpenStudio::Measure::OSArgument.makeDoubleArgument('num_stories_above_grade', true)
    num_stories_above_grade.setDisplayName('Number of Stories Above Grade')
    num_stories_above_grade.setDefaultValue(1.0)
    args << num_stories_above_grade

    # Make argument for num_stories_below_grade
    num_stories_below_grade = OpenStudio::Measure::OSArgument.makeIntegerArgument('num_stories_below_grade', true)
    num_stories_below_grade.setDisplayName('Number of Stories Below Grade')
    num_stories_below_grade.setDefaultValue(0)
    args << num_stories_below_grade

    # Make argument for building_rotation
    building_rotation = OpenStudio::Measure::OSArgument.makeDoubleArgument('building_rotation', true)
    building_rotation.setDisplayName('Building Rotation')
    building_rotation.setDescription('Set Building Rotation off of North (positive value is clockwise). Rotation applied after geometry generation. Values greater than +/- 45 will result in aspect ratio and party wall orientations that do not match cardinal directions of the inputs.')
    building_rotation.setUnits('Degrees')
    building_rotation.setDefaultValue(0.0)
    args << building_rotation

    # Make argument for template
    template = OpenStudio::Measure::OSArgument.makeChoiceArgument('template', get_templates, true)
    template.setDisplayName('Target Standard')
    template.setDefaultValue('90.1-2004')
    args << template

    # Make argument for ns_to_ew_ratio
    ns_to_ew_ratio = OpenStudio::Measure::OSArgument.makeDoubleArgument('ns_to_ew_ratio', true)
    ns_to_ew_ratio.setDisplayName('Ratio of North/South Facade Length Relative to East/West Facade Length.')
    ns_to_ew_ratio.setDescription('Selecting an aspect ratio of 0 will trigger a smart building type default. Aspect ratios less than one are not recommended for sliced bar geometry, instead rotate building and use a greater than 1 aspect ratio.')
    ns_to_ew_ratio.setDefaultValue(0.0)
    args << ns_to_ew_ratio

    # Make argument for perim_mult
    perim_mult = OpenStudio::Measure::OSArgument.makeDoubleArgument('perim_mult', true)
    perim_mult.setDisplayName('Perimeter Multiplier.')
    perim_mult.setDescription('Selecting a value of 0 will trigger a smart building type default. This represents a multiplier for the building perimeter relative to the perimeter of a rectangular building that meets the area and aspect ratio inputs. This should have a value of 1.0 or higher and is only applicable Multiple Space Types - Individual Stories Sliced division method.')
    perim_mult.setDefaultValue(1.0)
    args << perim_mult

    # Make argument for wwr (in future add lookup for smart default)
    wwr = OpenStudio::Measure::OSArgument.makeDoubleArgument('wwr', true)
    wwr.setDisplayName('Window to Wall Ratio.')
    wwr.setDescription('Selecting a window to wall ratio of 0 will trigger a smart building type default.')
    wwr.setDefaultValue(0.0)
    args << wwr

    # Make argument for party_wall_fraction
    party_wall_fraction = OpenStudio::Measure::OSArgument.makeDoubleArgument('party_wall_fraction', true)
    party_wall_fraction.setDisplayName('Fraction of Exterior Wall Area with Adjacent Structure')
    party_wall_fraction.setDescription('This will impact how many above grade exterior walls are modeled with adiabatic boundary condition.')
    party_wall_fraction.setDefaultValue(0.0)
    args << party_wall_fraction

    # party_wall_fraction was used where we wanted to represent some party walls but didn't know where they are, it ends up using methods to make whole surfaces adiabiatc by story and orientaiton to try to come close to requested fraction

    # Make argument for party_wall_stories_north
    party_wall_stories_north = OpenStudio::Measure::OSArgument.makeIntegerArgument('party_wall_stories_north', true)
    party_wall_stories_north.setDisplayName('Number of North facing stories with party wall')
    party_wall_stories_north.setDescription('This will impact how many above grade exterior north walls are modeled with adiabatic boundary condition. If this is less than the number of above grade stoes, upper flor will reamin exterior')
    party_wall_stories_north.setDefaultValue(0)
    args << party_wall_stories_north

    # Make argument for party_wall_stories_south
    party_wall_stories_south = OpenStudio::Measure::OSArgument.makeIntegerArgument('party_wall_stories_south', true)
    party_wall_stories_south.setDisplayName('Number of South facing stories with party wall')
    party_wall_stories_south.setDescription('This will impact how many above grade exterior south walls are modeled with adiabatic boundary condition. If this is less than the number of above grade stoes, upper flor will reamin exterior')
    party_wall_stories_south.setDefaultValue(0)
    args << party_wall_stories_south

    # Make argument for party_wall_stories_east
    party_wall_stories_east = OpenStudio::Measure::OSArgument.makeIntegerArgument('party_wall_stories_east', true)
    party_wall_stories_east.setDisplayName('Number of East facing stories with party wall')
    party_wall_stories_east.setDescription('This will impact how many above grade exterior east walls are modeled with adiabatic boundary condition. If this is less than the number of above grade stoes, upper flor will reamin exterior')
    party_wall_stories_east.setDefaultValue(0)
    args << party_wall_stories_east

    # Make argument for party_wall_stories_west
    party_wall_stories_west = OpenStudio::Measure::OSArgument.makeIntegerArgument('party_wall_stories_west', true)
    party_wall_stories_west.setDisplayName('Number of West facing stories with party wall')
    party_wall_stories_west.setDescription('This will impact how many above grade exterior west walls are modeled with adiabatic boundary condition. If this is less than the number of above grade stoes, upper flor will reamin exterior')
    party_wall_stories_west.setDefaultValue(0)
    args << party_wall_stories_west

    # make an argument for bottom_story_ground_exposed_floor
    bottom_story_ground_exposed_floor = OpenStudio::Measure::OSArgument.makeBoolArgument('bottom_story_ground_exposed_floor', true)
    bottom_story_ground_exposed_floor.setDisplayName('Is the Bottom Story Exposed to Ground?')
    bottom_story_ground_exposed_floor.setDescription("This should be true unless you are modeling a partial building which doesn't include the lowest story. The bottom story floor will have an adiabatic boundary condition when false.")
    bottom_story_ground_exposed_floor.setDefaultValue(true)
    args << bottom_story_ground_exposed_floor

    # make an argument for top_story_exterior_exposed_roof
    top_story_exterior_exposed_roof = OpenStudio::Measure::OSArgument.makeBoolArgument('top_story_exterior_exposed_roof', true)
    top_story_exterior_exposed_roof.setDisplayName('Is the Top Story an Exterior Roof?')
    top_story_exterior_exposed_roof.setDescription("This should be true unless you are modeling a partial building which doesn't include the highest story. The top story ceiling will have an adiabatic boundary condition when false.")
    top_story_exterior_exposed_roof.setDefaultValue(true)
    args << top_story_exterior_exposed_roof

    # Make argument for story_multiplier
    choices = OpenStudio::StringVector.new
    choices << 'None'
    choices << 'Basements Ground Mid Top'
    # choices << "Basements Ground Midx5 Top"
    story_multiplier = OpenStudio::Measure::OSArgument.makeChoiceArgument('story_multiplier', choices, true)
    story_multiplier.setDisplayName('Calculation Method for Story Multiplier')
    story_multiplier.setDefaultValue('Basements Ground Mid Top')
    args << story_multiplier

    # make an argument for bar sub-division approach
    choices = OpenStudio::StringVector.new
    choices << 'Multiple Space Types - Simple Sliced'
    choices << 'Multiple Space Types - Individual Stories Sliced'
    choices << 'Single Space Type - Core and Perimeter' # not useful for most use cases
    # choices << "Multiple Space Types - Individual Stories Sliced Keep Building Types Together"
    # choices << "Building Type Specific Smart Division"
    bar_division_method = OpenStudio::Measure::OSArgument.makeChoiceArgument('bar_division_method', choices, true)
    bar_division_method.setDisplayName('Division Method for Bar Space Types.')
    bar_division_method.setDescription('To use perimeter multiplier greater than 1 selected Multiple Space Types - Individual Stories Sliced.')
    bar_division_method.setDefaultValue('Multiple Space Types - Individual Stories Sliced')
    args << bar_division_method

    # make an argument for make_mid_story_surfaces_adiabatic (added to avoid issues with intersect and to lower surface count when using individual stories sliced)
    make_mid_story_surfaces_adiabatic = OpenStudio::Measure::OSArgument.makeBoolArgument('make_mid_story_surfaces_adiabatic', true)
    make_mid_story_surfaces_adiabatic.setDisplayName('Make Mid Story Floor Surfaces Adibatic')
    make_mid_story_surfaces_adiabatic.setDescription('If set to true, this will skip surface intersection and make mid story floors and celings adiabiatc, not just at multiplied gaps.')
    make_mid_story_surfaces_adiabatic.setDefaultValue(false)
    args << make_mid_story_surfaces_adiabatic

    # # Make argument for space_type_sort_logic
    # choices = OpenStudio::StringVector.new
    # choices << 'Size'
    # choices << 'Building Type > Size'
    # # choices << "Basements Ground Midx5 Top"
    # space_type_sort_logic = OpenStudio::Measure::OSArgument.makeChoiceArgument('space_type_sort_logic', choices, true)
    # space_type_sort_logic.setDisplayName('Choose Space Type sorting method')
    # space_type_sort_logic.setDefaultValue('Size')
    # args << space_type_sort_logic

    # make an argument for use_upstream_args
    use_upstream_args = OpenStudio::Measure::OSArgument.makeBoolArgument('use_upstream_args', true)
    use_upstream_args.setDisplayName('Use Upstream Argument Values')
    use_upstream_args.setDescription('When true this will look for arguments or registerValues in upstream measures that match arguments from this measure, and will use the value from the upstream measure in place of what is entered for this measure.')
    use_upstream_args.setDefaultValue(true)
    args << use_upstream_args

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # assign the user inputs to variables
    args = OsLib_HelperMethods.createRunVariables(runner, model, user_arguments, arguments(model))
    if !args then return false end

    # lookup and replace argument values from upstream measures
    if args['use_upstream_args'] == true
      args.each do |arg, value|
        next if arg == 'use_upstream_args' # this argument should not be changed
        value_from_osw = OsLib_HelperMethods.check_upstream_measure_for_arg(runner, arg)
        if !value_from_osw.empty?
          runner.registerInfo("Replacing argument named #{arg} from current measure with a value of #{value_from_osw[:value]} from #{value_from_osw[:measure_name]}.")
          new_val = value_from_osw[:value]
          # TODO: - make code to handle non strings more robust. check_upstream_measure_for_arg could pass back the argument type
          if arg == 'total_bldg_floor_area'
            args[arg] = new_val.to_f
          elsif arg == 'num_stories_above_grade'
            args[arg] = new_val.to_f
          elsif arg == 'zipcode'
            args[arg] = new_val.to_i
          else
            args[arg] = new_val
          end
        end
      end
    end

    # check expected values of double arguments
    fraction_args = ['bldg_type_b_fract_bldg_area',
                     'bldg_type_c_fract_bldg_area',
                     'bldg_type_d_fract_bldg_area',
                     'wwr', 'party_wall_fraction']
    fraction = OsLib_HelperMethods.checkDoubleAndIntegerArguments(runner, user_arguments, 'min' => 0.0, 'max' => 1.0, 'min_eq_bool' => true, 'max_eq_bool' => true, 'arg_array' => fraction_args)

    positive_args = ['total_bldg_floor_area']
    positive = OsLib_HelperMethods.checkDoubleAndIntegerArguments(runner, user_arguments, 'min' => 0.0, 'max' => nil, 'min_eq_bool' => false, 'max_eq_bool' => false, 'arg_array' => positive_args)

    one_or_greater_args = ['num_stories_above_grade']
    one_or_greater = OsLib_HelperMethods.checkDoubleAndIntegerArguments(runner, user_arguments, 'min' => 1.0, 'max' => nil, 'min_eq_bool' => true, 'max_eq_bool' => false, 'arg_array' => one_or_greater_args)

    non_neg_args = ['bldg_type_a_num_units',
                    'bldg_type_c_num_units',
                    'bldg_type_d_num_units',
                    'num_stories_below_grade',
                    'floor_height',
                    'ns_to_ew_ratio',
                    'party_wall_stories_north',
                    'party_wall_stories_south',
                    'party_wall_stories_east',
                    'party_wall_stories_west',
                    'single_floor_area',
                    'bar_width',]
    non_neg = OsLib_HelperMethods.checkDoubleAndIntegerArguments(runner, user_arguments, 'min' => 0.0, 'max' => nil, 'min_eq_bool' => true, 'max_eq_bool' => false, 'arg_array' => non_neg_args)

    # return false if any errors fail
    if !fraction then return false end
    if !positive then return false end
    if !one_or_greater then return false end
    if !non_neg then return false end

    # if aspect ratio, story height or wwr have argument value of 0 then use smart building type defaults
    building_form_defaults = building_form_defaults(args['bldg_type_a'])

    # store list of defaulted items
    defaulted_args = []

    if args['ns_to_ew_ratio'] == 0.0
      args['ns_to_ew_ratio'] = building_form_defaults[:aspect_ratio]
      runner.registerInfo("0.0 value for aspect ratio will be replaced with smart default for #{args['bldg_type_a']} of #{building_form_defaults[:aspect_ratio]}.")
    end

    if args['perim_mult'] == 0.0
      args['perim_mult'] = building_form_defaults[:perim_mult]
      runner.registerInfo("0.0 value for minimum perimeter multiplier will be replaced with smart default for #{args['bldg_type_a']} of #{building_form_defaults[:perim_mult]}.")
    elsif args['perim_mult'] < 1.0
      runner.registerError("Other than the smart default value of 0, the minimum perimeter multiplier should be equal to 1.0 or greater.")
      return false
    end

    if args['floor_height'] == 0.0
      args['floor_height'] = building_form_defaults[:typical_story]
      runner.registerInfo("0.0 value for floor height will be replaced with smart default for #{args['bldg_type_a']} of #{building_form_defaults[:typical_story]}.")
      defaulted_args << 'floor_height'
    end
    # because of this can't set wwr to 0.0. If that is desired then we can change this to check for 1.0 instead of 0.0
    if args['wwr'] == 0.0
      args['wwr'] = building_form_defaults[:wwr]
      runner.registerInfo("0.0 value for window to wall ratio will be replaced with smart default for #{args['bldg_type_a']} of #{building_form_defaults[:wwr]}.")
    end

    # check that sum of fractions for b,c, and d is less than 1.0 (so something is left for primary building type)
    bldg_type_a_fract_bldg_area = 1.0 - args['bldg_type_b_fract_bldg_area'] - args['bldg_type_c_fract_bldg_area'] - args['bldg_type_d_fract_bldg_area']
    if bldg_type_a_fract_bldg_area <= 0.0
      runner.registerError('Primary Building Type fraction of floor area must be greater than 0. Please lower one or more of the fractions for Building Type B-D.')
      return false
    end

    # Make the standard applier
    standard = Standard.build("#{args['template']}_#{args['bldg_type_a']}")

    # report initial condition of model
    runner.registerInitialCondition("The building started with #{model.getSpaces.size} spaces.")

    # determine of ns_ew needs to be mirrored
    mirror_ns_ew = false
    rotation = model.getBuilding.northAxis
    if rotation > 45.0 && rotation < 135.0
      mirror_ns_ew = true
    elsif rotation > 45.0 && rotation < 135.0
      mirror_ns_ew = true
    end

    # remove non-resource objects not removed by removing the building
    remove_non_resource_objects(runner, model)

    # rename building to infer template in downstream measure
    name_array = [args['template'], args['bldg_type_a']]
    if args['bldg_type_b_fract_bldg_area'] > 0 then name_array << args['bldg_type_b'] end
    if args['bldg_type_c_fract_bldg_area'] > 0 then name_array << args['bldg_type_c'] end
    if args['bldg_type_d_fract_bldg_area'] > 0 then name_array << args['bldg_type_d'] end
    model.getBuilding.setName(name_array.join('|').to_s)

    # hash to whole building type data
    building_type_hash = {}

    # gather data for bldg_type_a
    building_type_hash[args['bldg_type_a']] = {}
    building_type_hash[args['bldg_type_a']][:frac_bldg_area] = bldg_type_a_fract_bldg_area
    building_type_hash[args['bldg_type_a']][:num_units] = args['bldg_type_a_num_units']
    building_type_hash[args['bldg_type_a']][:space_types] = get_space_types_from_building_type(args['bldg_type_a'], args['template'], true)

    # gather data for bldg_type_b
    if args['bldg_type_b_fract_bldg_area'] > 0
      building_type_hash[args['bldg_type_b']] = {}
      building_type_hash[args['bldg_type_b']][:frac_bldg_area] = args['bldg_type_b_fract_bldg_area']
      building_type_hash[args['bldg_type_b']][:num_units] = args['bldg_type_b_num_units']
      building_type_hash[args['bldg_type_b']][:space_types] = get_space_types_from_building_type(args['bldg_type_b'], args['template'], true)
    end

    # gather data for bldg_type_c
    if args['bldg_type_c_fract_bldg_area'] > 0
      building_type_hash[args['bldg_type_c']] = {}
      building_type_hash[args['bldg_type_c']][:frac_bldg_area] = args['bldg_type_c_fract_bldg_area']
      building_type_hash[args['bldg_type_c']][:num_units] = args['bldg_type_c_num_units']
      building_type_hash[args['bldg_type_c']][:space_types] = get_space_types_from_building_type(args['bldg_type_c'], args['template'], true)
    end

    # gather data for bldg_type_d
    if args['bldg_type_d_fract_bldg_area'] > 0
      building_type_hash[args['bldg_type_d']] = {}
      building_type_hash[args['bldg_type_d']][:frac_bldg_area] = args['bldg_type_d_fract_bldg_area']
      building_type_hash[args['bldg_type_d']][:num_units] = args['bldg_type_d_num_units']
      building_type_hash[args['bldg_type_d']][:space_types] = get_space_types_from_building_type(args['bldg_type_d'], args['template'], true)
    end

    # creating space types for requested building types
    building_type_hash.each do |building_type, building_type_hash|
      runner.registerInfo("Creating Space Types for #{building_type}.")

      # mapping building_type name is needed for a few methods
      building_type = standard.model_get_lookup_name(building_type)

      # create space_type_map from array
      sum_of_ratios = 0.0
      building_type_hash[:space_types].each do |space_type_name, hash|
        next if hash[:space_type_gen] == false # space types like undeveloped and basement are skipped.

        # create space type
        space_type = OpenStudio::Model::SpaceType.new(model)
        space_type.setStandardsBuildingType(building_type)
        space_type.setStandardsSpaceType(space_type_name)
        space_type.setName("#{building_type} #{space_type_name}")

        # set color
        test = standard.space_type_apply_rendering_color(space_type) # this uses openstudio-standards
        if !test
          runner.registerWarning("Could not find color for #{args['template']} #{space_type.name}")
        end

        # extend hash to hold new space type object
        hash[:space_type] = space_type

        # add to sum_of_ratios counter for adjustment multiplier
        sum_of_ratios += hash[:ratio]
      end

      # store multiplier needed to adjust sum of ratios to equal 1.0
      building_type_hash[:ratio_adjustment_multiplier] = 1.0 / sum_of_ratios
    end

    # calculate length and with of bar
    total_bldg_floor_area_si = OpenStudio.convert(args['total_bldg_floor_area'], 'ft^2', 'm^2').get
    single_floor_area_si = OpenStudio.convert(args['single_floor_area'], 'ft^2', 'm^2').get

    # store number of stories
    num_stories = args['num_stories_below_grade'] + args['num_stories_above_grade']

    # handle user-assigned single floor plate size condition
    if args['single_floor_area'] > 0.0
      footprint_si = single_floor_area_si
      total_bldg_floor_area_si = footprint_si * num_stories.to_f
      runner.registerWarning('User-defined single floor area was used for calculation of total building floor area')
      # add warning if custom_height_bar is true and applicable building type is selected
      if args['custom_height_bar']
        runner.registerWarning("Cannot use custom height bar with single floor area method, will not create custom height bar.")
        args['custom_height_bar'] = false
      end
    else
      footprint_si = nil
    end

    # populate space_types_hash
    space_types_hash = {}
    multi_height_space_types_hash = {}
    custom_story_heights = []
    building_type_hash.each do |building_type, building_type_hash|
      building_type_hash[:space_types].each do |space_type_name, hash|
        next if hash[:space_type_gen] == false

        space_type = hash[:space_type]
        ratio_of_bldg_total = hash[:ratio] * building_type_hash[:ratio_adjustment_multiplier] * building_type_hash[:frac_bldg_area]
        final_floor_area = ratio_of_bldg_total * total_bldg_floor_area_si # I think I can just pass ratio but passing in area is cleaner

        # only add custom height space if 0 is used for floor_height
        if defaulted_args.include?('floor_height') && hash.key?(:story_height) && args['custom_height_bar']
          multi_height_space_types_hash[space_type] = { floor_area: final_floor_area, space_type: space_type, story_height: hash[:story_height] }
          custom_story_heights << hash[:story_height]
          if args['wwr'] == 0 && hash.key?(:wwr)
            multi_height_space_types_hash[space_type][:wwr] = hash[:wwr]
          end        else
          # only add wwr if 0 used for wwr arg and if space type has wwr as key
          space_types_hash[space_type] = { floor_area: final_floor_area, space_type: space_type }
          if args['wwr'] == 0 && hash.key?(:wwr)
            space_types_hash[space_type][:wwr] = hash[:wwr]
          end
        end
      end
    end

    # calcualte targets for testing
    target_areas = {} # used for checks
    target_areas_cust_height = 0.0
    space_types_hash.each do |k,v|
      target_areas[k] = v[:floor_area]
    end
    multi_height_space_types_hash.each do |k,v|
      target_areas[k] = v[:floor_area]
      target_areas_cust_height += v[:floor_area]
    end

    # gather inputs
    if footprint_si.nil?
      footprint_si = (total_bldg_floor_area_si - target_areas_cust_height) / num_stories.to_f
    end
    floor_height_si = OpenStudio.convert(args['floor_height'], 'ft', 'm').get
    min_allow_size = OpenStudio.convert(15.0,'ft','m').get
    bar_width_si = OpenStudio.convert(args['bar_width'],'ft','m').get
    if args['custom_height_bar']
      if bar_width_si > 0
        runner.registerInfo("Ignoring perimeter multiplier argument when non zero width argument is used")
        if footprint_si / bar_width_si >= min_allow_size
          width = bar_width_si
          length = footprint_si / width
        else
          length = min_allow_size
          width = footprint_si / length
          runner.registerWarning("User specified width results in a length that is too short, adjusting width to be narrower than specified.")
        end
      else
        width = Math.sqrt(footprint_si / args['ns_to_ew_ratio'])
        length = footprint_si / width
      end
      footprint_si_cust_height = target_areas_cust_height
      width_cust_height = Math.sqrt(footprint_si_cust_height / args['ns_to_ew_ratio'])
      length_cust_height = footprint_si_cust_height / width_cust_height
      if args['perim_mult'] > 1.0
        runner.registerWarning("Ignoring perimeter multiplier for bar that represents custom height spaces.")
      end
    else
      if bar_width_si > 0.0
        if footprint_si / width >= min_allow_size
          width = bar_width_si
          length = footprint_si / width
          runner.registerWarning("User specified width results in a length that is too short, adjusting width to be narrower than specified.")
        else
          length = min_allow_size
          width = footprint_si / length
        end
      else
        width = Math.sqrt(footprint_si / args['ns_to_ew_ratio'])
        length = footprint_si / width
      end
    end

    # check if dual bar is needed
    dual_bar = false
    if bar_width_si > 0.0 && args['bar_division_method'] == 'Multiple Space Types - Individual Stories Sliced'
      if length/width != args['ns_to_ew_ratio']

        if args['ns_to_ew_ratio'] >= 1.0 && args['ns_to_ew_ratio'] > length/width
          runner.registerWarning("Can't meet target aspect ratio of #{args['ns_to_ew_ratio']}, Lowering it to #{length/width} ")
          args['ns_to_ew_ratio'] = length/width
        elsif args['ns_to_ew_ratio'] < 1.0 && args['ns_to_ew_ratio'] > length/width
          runner.registerWarning("Can't meet target aspect ratio of #{args['ns_to_ew_ratio']}, Increasing it to #{length/width} ")
          args['ns_to_ew_ratio'] = length/width
        else
          # check if each bar would be longer then 15 feet, then set as dual bar and override perimeter multiplier
          length_alt1 = ((args['ns_to_ew_ratio'] * footprint_si) / width + 2 * args['ns_to_ew_ratio'] * width - 2 * width)/(1 + args['ns_to_ew_ratio'])
          length_alt2 = length - length_alt1
          if [length_alt1,length_alt2].min >= min_allow_size
            dual_bar = true
          else
            runner.registerInfo("Second bar would be below minimum length, will model as single bar")
            # swap length and width if single bar and aspect ratio less than 1
            if args['ns_to_ew_ratio'] < 1.0
              width = length
              length = bar_width_si
            end
          end
        end
      end
    elsif args['perim_mult'] > 1.0 && args['bar_division_method'] == 'Multiple Space Types - Individual Stories Sliced'
      runner.registerInfo("You selected a perimeter multiplier greater than 1.0 for a supported bar division method. This will result in two detached rectangular buildings if secondary bar meets minimum size requirements.")
      dual_bar = true
    elsif args['perim_mult'] > 1.0
      runner.registerWarning("You selected a perimeter multiplier greater than 1.0 but didn't select a bar division method that supports this. The value for this argument will be ignored by the measure")
    end

    # calculations for dual bar, which later will be setup to run create_bar twice
    if dual_bar
      min_perim = 2 * width + 2 * length
      target_area = footprint_si
      target_perim = min_perim * args['perim_mult']
      tol_testing = 0.00001
      dual_bar_calc_approach = nil # stretched, adiabatic_ends_bar_b, dual_bar
      runner.registerInfo("Minimum rectangle is #{OpenStudio.toNeatString(OpenStudio.convert(length, 'm', 'ft').get, 0, true)} ft x #{OpenStudio.toNeatString(OpenStudio.convert(width, 'm', 'ft').get, 0, true)} ft with an area of #{OpenStudio.toNeatString(OpenStudio.convert(length * width, 'm^2', 'ft^2').get, 0, true)} ft^2. Perimeter is #{OpenStudio.toNeatString(OpenStudio.convert(min_perim, 'm', 'ft').get, 0, true)} ft.")
      runner.registerInfo("Target dual bar perimeter is #{OpenStudio.toNeatString(OpenStudio.convert(target_perim, 'm', 'ft').get, 0, true)} ft.")

      # determine which of the three paths to hit target perimeter multiplier are possible
      # A use dual bar non adiabatic
      # B use dual bar adiabatic
      # C use stretched bar (requires model to miss ns/ew ratio)

      # custom quadratic equation to solve two bars with common width 2l^2 - p*l + 4a = 0
      if target_perim**2 - 32 * footprint_si > 0
        if bar_width_si > 0
          runner.registerInfo("Ignoring perimeter multiplier argument and using use specified bar width.")
          dual_double_end_width = bar_width_si
          dual_double_end_length = footprint_si / dual_double_end_width
        else
          dual_double_end_length = 0.25 * (target_perim + Math.sqrt(target_perim**2 - 32 * footprint_si))
          dual_double_end_width = footprint_si / dual_double_end_length
        end

        # now that stretched  bar is made, determine where to split it and rotate
        bar_a_length = (args['ns_to_ew_ratio'] * (dual_double_end_length + dual_double_end_width) - dual_double_end_width)/(1 + args['ns_to_ew_ratio'])
        bar_b_length = dual_double_end_length - bar_a_length
        area_a = bar_a_length * dual_double_end_width
        area_b = bar_b_length * dual_double_end_width
      else
        # this will throw it to adiabatic ends test
        bar_a_length = 0
        bar_b_length = 0
      end

      if bar_a_length >= min_allow_size && bar_b_length >= min_allow_size
        dual_bar_calc_approach = 'dual_bar'
      else
        # adiabatic bar input calcs
        if target_perim**2 - 16 * footprint_si > 0
          adiabatic_dual_double_end_length = 0.25 * (target_perim + Math.sqrt(target_perim**2 - 16 * footprint_si))
          adiabatic_dual_double_end_width = footprint_si / adiabatic_dual_double_end_length
          if (target_area - adiabatic_dual_double_end_length*adiabatic_dual_double_end_width).abs > tol_testing || (target_perim - (adiabatic_dual_double_end_length * 2 + adiabatic_dual_double_end_width * 2)).abs > tol_testing
            runner.registerWarning("*** Unexpected values for dual rectangle adiabatic ends bar b.")
          end
          # now that stretched  bar is made, determine where to split it and rotate
          adiabatic_bar_a_length = (args['ns_to_ew_ratio'] * (adiabatic_dual_double_end_length + adiabatic_dual_double_end_width))/(1 + args['ns_to_ew_ratio'])
          adiabatic_bar_b_length = adiabatic_dual_double_end_length - adiabatic_bar_a_length
          adiabatic_area_a = adiabatic_bar_a_length * adiabatic_dual_double_end_width
          adiabatic_area_b = adiabatic_bar_b_length * adiabatic_dual_double_end_width
        else
          # this will throw it stretched single bar
          adiabatic_bar_a_length = 0
          adiabatic_bar_b_length = 0
        end
        if adiabatic_bar_a_length >= min_allow_size && adiabatic_bar_b_length >= min_allow_size
          dual_bar_calc_approach = 'adiabatic_ends_bar_b'
        else
          dual_bar_calc_approach = 'stretched'
        end
      end

      # apply prescribed approach for stretched or dual bar
      if dual_bar_calc_approach == 'dual_bar'
        runner.registerInfo("Stretched  #{OpenStudio.toNeatString(OpenStudio.convert(dual_double_end_length, 'm', 'ft').get, 0, true)} ft x #{OpenStudio.toNeatString(OpenStudio.convert(dual_double_end_width, 'm', 'ft').get, 0, true)} ft rectangle has an area of #{OpenStudio.toNeatString(OpenStudio.convert(dual_double_end_length * dual_double_end_width, 'm^2', 'ft^2').get, 0, true)} ft^2. When split in two the perimeter will be #{OpenStudio.toNeatString(OpenStudio.convert(dual_double_end_length * 2 + dual_double_end_width * 4, 'm', 'ft').get, 0, true)} ft")
        if (target_area - dual_double_end_length*dual_double_end_width).abs > tol_testing || (target_perim - (dual_double_end_length * 2 + dual_double_end_width * 4)).abs > tol_testing
          runner.registerWarning("*** Unexpected values for dual rectangle.")
        end

        runner.registerInfo("For stretched split bar, to match target ns/ew aspect ratio #{OpenStudio.toNeatString(OpenStudio.convert(bar_a_length, 'm', 'ft').get, 0, true)} ft of bar should be horizontal, with #{OpenStudio.toNeatString(OpenStudio.convert(bar_b_length, 'm', 'ft').get, 0, true)} ft turned 90 degrees. Combined area is #{OpenStudio.toNeatString(OpenStudio.convert(area_a + area_b, 'm^2', 'ft^2').get, 0, true)} ft^2. Combined perimeter is #{OpenStudio.toNeatString(OpenStudio.convert(bar_a_length*2 + bar_b_length*2 + dual_double_end_width*4, 'm', 'ft').get, 0, true)} ft")
        if (target_area - (area_a + area_b)).abs > tol_testing || (target_perim - (bar_a_length*2 + bar_b_length*2 + dual_double_end_width*4)).abs > tol_testing
          runner.registerWarning("*** Unexpected values for rotated dual rectangle")
        end
      elsif dual_bar_calc_approach == 'adiabatic_ends_bar_b'
        runner.registerInfo("Can't hit target perimeter with two rectangles, need to make two ends adiabatic")

        runner.registerInfo("For dual bar with adiabatic ends on bar b, to reach target aspect ratio #{OpenStudio.toNeatString(OpenStudio.convert(adiabatic_bar_a_length, 'm', 'ft').get, 0, true)} ft of bar should be north/south, with #{OpenStudio.toNeatString(OpenStudio.convert(adiabatic_bar_b_length, 'm', 'ft').get, 0, true)} ft turned 90 degrees. Combined area is #{OpenStudio.toNeatString(OpenStudio.convert(adiabatic_area_a + adiabatic_area_b, 'm^2', 'ft^2').get, 0, true)} ft^2}. Combined perimeter is #{OpenStudio.toNeatString(OpenStudio.convert(adiabatic_bar_a_length*2 + adiabatic_bar_b_length*2 + adiabatic_dual_double_end_width*2, 'm', 'ft').get, 0, true)} ft")
        if (target_area - (adiabatic_area_a + adiabatic_area_b)).abs > tol_testing || (target_perim - (adiabatic_bar_a_length*2 + adiabatic_bar_b_length*2 + adiabatic_dual_double_end_width*2)).abs > tol_testing
          runner.registerWarning("*** Unexpected values for rotated dual rectangle adiabatic ends bar b")
        end
      else # stretched bar
        dual_bar = false

        stretched_length = 0.25 * (target_perim + Math.sqrt(target_perim**2 - 16 * footprint_si))
        stretched_width = footprint_si / stretched_length
        if (target_area - stretched_length*stretched_width).abs > tol_testing || (target_perim - (stretched_length + stretched_width)*2) > tol_testing
          runner.registerWarning("*** Unexpected values for single stretched")
        end

        width = stretched_width
        length = stretched_length
        runner.registerInfo("Creating a dual bar to match the target minimum perimeter multiplier at the given aspect ratio would result in a bar with edge shorter than #{OpenStudio.toNeatString(OpenStudio.convert(min_allow_size, 'm', 'ft').get, 0, true)} ft. Will create a single stretched bar instead that hits the target perimeter with a slightly different ns/ew aspect ratio.")
      end
    end

    bars = {}
    bars['primary'] = {}
    if dual_bar
      if mirror_ns_ew && dual_bar_calc_approach == 'dual_bar'
        bars['primary'][:length] = dual_double_end_width
        bars['primary'][:width] = bar_a_length
      elsif dual_bar_calc_approach == 'dual_bar'
        bars['primary'][:length] = bar_a_length
        bars['primary'][:width] = dual_double_end_width
      elsif mirror_ns_ew
        bars['primary'][:length] = adiabatic_dual_double_end_width
        bars['primary'][:width] = adiabatic_bar_a_length
      else
        bars['primary'][:length] = adiabatic_bar_a_length
        bars['primary'][:width] = adiabatic_dual_double_end_width
      end
    else
      if mirror_ns_ew
        bars['primary'][:length] = width
        bars['primary'][:width] = length
      else
        bars['primary'][:length] = length
        bars['primary'][:width] = width
      end
    end
    bars['primary'][:floor_height_si] = floor_height_si # can make use of this when breaking out multi-height spaces
    bars['primary'][:num_stories] = num_stories
    bars['primary'][:center_of_footprint] = OpenStudio::Point3d.new(0.0,0.0,0.0)
    bars['primary'][:space_types_hash] = space_types_hash
    bars['primary'][:args] = args

    # setup bar_hash and run create_bar
    v = bars['primary']
    bar_hash_setup_run(runner,model,v[:args],v[:length],v[:width],v[:floor_height_si],v[:center_of_footprint],v[:space_types_hash],v[:num_stories])

    # store offset value for multiple bars
    offset_val = num_stories.ceil * floor_height_si * 10.0 # would be nice to have this defined once in the measure.

    if dual_bar
      args2 = args.clone
      bars['secondary'] = {}
      if mirror_ns_ew && dual_bar_calc_approach == 'dual_bar'
        bars['secondary'][:length] = bar_b_length
        bars['secondary'][:width] = dual_double_end_width
      elsif dual_bar_calc_approach == 'dual_bar'
        bars['secondary'][:length] = dual_double_end_width
        bars['secondary'][:width] = bar_b_length
      elsif mirror_ns_ew
        bars['secondary'][:length] = adiabatic_bar_b_length
        bars['secondary'][:width] = adiabatic_dual_double_end_width
        args2['party_wall_stories_east'] = num_stories.ceil
        args2['party_wall_stories_west'] = num_stories.ceil
      else
        bars['secondary'][:length] = adiabatic_dual_double_end_width
        bars['secondary'][:width] = adiabatic_bar_b_length
        args2['party_wall_stories_south'] = num_stories.ceil
        args2['party_wall_stories_north'] = num_stories.ceil
      end
      bars['secondary'][:floor_height_si] = floor_height_si # can make use of this when breaking out multi-height spaces
      bars['secondary'][:num_stories] = num_stories
      bars['secondary'][:space_types_hash] = space_types_hash
      if dual_bar_calc_approach == 'adiabatic_ends_bar_b'
        # warn that combination of dual bar with low perimeter multiplier and use of party wall may result in discrepency between target and actual adiabatic walls
        if args['party_wall_fraction'] > 0 || args['party_wall_stories_north'] > 0 || args['party_wall_stories_south'] > 0 || args['party_wall_stories_east'] > 0 || args['party_wall_stories_west'] > 0
          runner.registerWarning('The combination of low perimeter multiplier and use of non zero party wall inputs may result in discrepency between target and actual adiabatic walls. This is due to the need to create adiabatic walls on secondary bar to maintian target building perimeter.')
        else
          runner.registerInfo('Adiabatic ends added to secondary bar because target perimeter multiplier could not be met with two full rectangular footprints.')
        end
        bars['secondary'][:center_of_footprint] = OpenStudio::Point3d.new(adiabatic_bar_a_length * 0.5 + adiabatic_dual_double_end_width * 0.5 + offset_val,adiabatic_bar_b_length * 0.5 + adiabatic_dual_double_end_width * 0.5 + offset_val,0.0)
      else
        bars['secondary'][:center_of_footprint] = OpenStudio::Point3d.new(bar_a_length * 0.5 + dual_double_end_width * 0.5 + offset_val,bar_b_length * 0.5 + dual_double_end_width * 0.5 + offset_val,0.0)
      end
      bars['secondary'][:args] = args2

      # setup bar_hash and run create_bar
      v = bars['secondary']
      bar_hash_setup_run(runner,model,v[:args],v[:length],v[:width],v[:floor_height_si],v[:center_of_footprint],v[:space_types_hash],v[:num_stories])

    end

    # future development (up against primary bar run intersection and surface matching after add all bars, avoid interior windows)
    # I could loop through each space type and give them unique height but for now will just take largest height and make bar of that height, which is fine for prototypes
    if multi_height_space_types_hash.size > 0
      args3 = args.clone
      bars['custom_height'] = {}
      if mirror_ns_ew
        bars['custom_height'][:length] = width_cust_height
        bars['custom_height'][:width] = length_cust_height
      else
        bars['custom_height'][:length] = length_cust_height
        bars['custom_height'][:width] = width_cust_height
      end
      if args['party_wall_stories_east'] + args['party_wall_stories_west'] + args['party_wall_stories_south'] + args['party_wall_stories_north'] > 0.0
        runner.registerWarning("Ignorning party wall inputs for custom height bar")
      end

      # disable party walls
      args3['party_wall_stories_east'] = 0
      args3['party_wall_stories_west'] = 0
      args3['party_wall_stories_south'] = 0
      args3['party_wall_stories_north'] = 0

      # setup stories
      args3['num_stories_below_grade'] = 0
      args3['num_stories_above_grade'] = 1

      bars['custom_height'][:floor_height_si] = floor_height_si # can make use of this when breaking out multi-height spaces
      bars['custom_height'][:num_stories] = num_stories
      # todo - validate location in more test cases
      bars['custom_height'][:center_of_footprint] = OpenStudio::Point3d.new(bars['primary'][:length] * -0.5 - width_cust_height * 0.5 - offset_val,0.0,0.0)
      bars['custom_height'][:floor_height_si] = OpenStudio.convert(custom_story_heights.max,'ft','m').get
      bars['custom_height'][:num_stories] = 1
      bars['custom_height'][:space_types_hash] = multi_height_space_types_hash
      bars['custom_height'][:args] = args3

      v = bars['custom_height']
      bar_hash_setup_run(runner,model,v[:args],v[:length],v[:width],v[:floor_height_si],v[:center_of_footprint],v[:space_types_hash],v[:num_stories])
    end

    # check expected floor areas against actual
    model.getSpaceTypes.sort.each do |space_type|
      next if !target_areas.key? space_type # space type in model not part of building type(s), maybe issue warning

      # convert to IP
      actual_ip = OpenStudio.convert(space_type.floorArea, 'm^2', 'ft^2').get
      target_ip = OpenStudio.convert(target_areas[space_type], 'm^2', 'ft^2').get

      if (space_type.floorArea - target_areas[space_type]).abs >= 1.0

        if !args['bar_division_method'].include? 'Single Space Type'
          runner.registerError("#{space_type.name} doesn't have the expected floor area (actual #{OpenStudio.toNeatString(actual_ip, 0, true)} ft^2, target #{OpenStudio.toNeatString(target_ip, 0, true)} ft^2)")
          return false
        else
          # will see this if use Single Space type division method on multi-use building or single building type without whole building space type
          runner.registerWarning("#{space_type.name} doesn't have the expected floor area (actual #{OpenStudio.toNeatString(actual_ip, 0, true)} ft^2, target #{OpenStudio.toNeatString(target_ip, 0, true)} ft^2)")
        end

      end
    end

    # check party wall fraction by looping through surfaces
    if args['party_wall_fraction'] > 0
      actual_ext_wall_area = model.getBuilding.exteriorWallArea
      actual_party_wall_area = 0.0
      model.getSurfaces.each do |surface|
        next if surface.outsideBoundaryCondition != 'Adiabatic'
        next if surface.surfaceType != 'Wall'
        actual_party_wall_area += surface.grossArea * surface.space.get.multiplier
      end
      actual_party_wall_fraction = actual_party_wall_area / (actual_party_wall_area + actual_ext_wall_area)
      runner.registerInfo("Target party wall fraction is #{args['party_wall_fraction']}. Realized fraction is #{actual_party_wall_fraction.round(2)}")
      runner.registerValue('party_wall_fraction_actual', actual_party_wall_fraction)
    end

    # check ns/ew aspect ratio (harder to check when party walls are added)
    wall_and_window_by_orientation = OsLib_Geometry.getExteriorWindowAndWllAreaByOrientation(model,model.getSpaces)
    wall_ns = (wall_and_window_by_orientation['northWall'] + wall_and_window_by_orientation['southWall'])
    wall_ew = wall_and_window_by_orientation['eastWall'] + wall_and_window_by_orientation['westWall']
    wall_ns_ip = OpenStudio.convert(wall_ns,'m^2','ft^2').get
    wall_ew_ip = OpenStudio.convert(wall_ew,'m^2','ft^2').get
    runner.registerValue('wall_area_ip',wall_ns_ip + wall_ew_ip,'ft^2')
    runner.registerValue('ns_wall_area_ip',wall_ns_ip,'ft^2')
    runner.registerValue('ew_wall_area_ip',wall_ew_ip,'ft^2')
    # for now using perimeter of ground floor and average story area (building area / num_stories)
    runner.registerValue('floor_area_to_perim_ratio',model.getBuilding.floorArea /  (OsLib_Geometry.calculate_perimeter(model) * num_stories))
    runner.registerValue('bar_width',OpenStudio.convert(bars['primary'][:width],'m','ft').get,'ft')

    if args['party_wall_fraction'] > 0 || args['party_wall_stories_north'] > 0 || args['party_wall_stories_south'] > 0 || args['party_wall_stories_east'] > 0 || args['party_wall_stories_west'] > 0
      runner.registerInfo("Target facade area by orientation not validated when party walls are applied")
    elsif args['num_stories_above_grade'] != args['num_stories_above_grade'].ceil
      runner.registerInfo("Target facade area by orientation not validated when partial top story is used")
    elsif dual_bar_calc_approach == 'stretched'
      runner.registerInfo("Target facade area by orientation not validated when single stretched bar has to be used to meet target minimum perimeter multiplier")
    elsif defaulted_args.include?('floor_height')  && args['custom_height_bar'] && multi_height_space_types_hash.size > 0
      runner.registerInfo("Target facade area by orientation not validated when a dedicated bar is added for space types with custom heights")
    elsif args['bar_width'] > 0
      runner.registerInfo("Target facade area by orientation not validated when a dedicated custom bar width is defined")
    else

      # adjust length versus width based on building rotation
      if mirror_ns_ew
        wall_target_ns_ip = 2 * OpenStudio.convert(width,'m','ft').get * args['perim_mult'] * args['num_stories_above_grade'] * args['floor_height']
        wall_target_ew_ip = 2 * OpenStudio.convert(length,'m','ft').get  * args['perim_mult'] * args['num_stories_above_grade'] * args['floor_height']
      else
        wall_target_ns_ip = 2 * OpenStudio.convert(length,'m','ft').get * args['perim_mult'] * args['num_stories_above_grade'] * args['floor_height']
        wall_target_ew_ip = 2 * OpenStudio.convert(width,'m','ft').get  * args['perim_mult'] * args['num_stories_above_grade'] * args['floor_height']
      end
      flag_error = false
      if (wall_target_ns_ip - wall_ns_ip).abs > 0.1
        runner.registerError("North/South walls don't have the expected area (actual #{OpenStudio.toNeatString(wall_ns_ip, 4, true)} ft^2, target #{OpenStudio.toNeatString(wall_target_ns_ip, 4, true)} ft^2)")
        flag_error = true
      end
      if (wall_target_ew_ip - wall_ew_ip).abs > 0.1
        runner.registerError("East/West walls don't have the expected area (actual #{OpenStudio.toNeatString(wall_ew_ip, 4, true)} ft^2, target #{OpenStudio.toNeatString(wall_target_ew_ip, 4, true)} ft^2)")
        flag_error = true
      end
      if flag_error
        return false
      end
    end

    # test for excessive exterior roof area (indication of problem with intersection and or surface matching)
    ext_roof_area = model.getBuilding.exteriorSurfaceArea - model.getBuilding.exteriorWallArea
    expected_roof_area = args['total_bldg_floor_area'] / (args['num_stories_above_grade'] + args['num_stories_below_grade']).to_f
    if ext_roof_area > expected_roof_area && single_floor_area_si == 0.0 # only test if using whole-building area input
      runner.registerError('Roof area larger than expected, may indicate problem with inter-floor surface intersection or matching.')
      return false
    end

    # set building rotation
    initial_rotation = model.getBuilding.northAxis
    if args['building_rotation'] != initial_rotation
      model.getBuilding.setNorthAxis(args['building_rotation'])
      runner.registerInfo("Set Building Rotation to #{model.getBuilding.northAxis}. Rotation altered after geometry generation is completed, as a result party wall orientation and aspect ratio may not reflect input values.")
    end

    # report final condition of model
    runner.registerFinalCondition("The building finished with #{model.getSpaces.size} spaces.")

    return true
  end

  def bar_hash_setup_run(runner,model,args,length,width,floor_height_si,center_of_footprint,space_types_hash,num_stories)
    # create envelope
    # populate bar_hash and create envelope with data from envelope_data_hash and user arguments
    bar_hash = {}
    bar_hash[:length] = length
    bar_hash[:width] = width
    bar_hash[:num_stories_below_grade] = args['num_stories_below_grade']
    bar_hash[:num_stories_above_grade] = args['num_stories_above_grade']
    bar_hash[:floor_height] = floor_height_si
    bar_hash[:center_of_footprint] = center_of_footprint
    bar_hash[:bar_division_method] = args['bar_division_method']
    bar_hash[:make_mid_story_surfaces_adiabatic] = args['make_mid_story_surfaces_adiabatic']
    bar_hash[:space_types] = space_types_hash
    bar_hash[:building_wwr_n] = args['wwr']
    bar_hash[:building_wwr_s] = args['wwr']
    bar_hash[:building_wwr_e] = args['wwr']
    bar_hash[:building_wwr_w] = args['wwr']

    # round up non integer stoires to next integer
    num_stories_round_up = num_stories.ceil
    runner.registerInfo("Making bar with length of #{OpenStudio.toNeatString(OpenStudio.convert(length, 'm', 'ft').get, 0, true)} ft and width of #{OpenStudio.toNeatString(OpenStudio.convert(width, 'm', 'ft').get, 0, true)} ft")

    # party_walls_array to be used by orientation specific or fractional party wall values
    party_walls_array = [] # this is an array of arrays, where each entry is effective building story with array of directions

    if args['party_wall_stories_north'] + args['party_wall_stories_south'] + args['party_wall_stories_east'] + args['party_wall_stories_west'] > 0

      # loop through effective number of stories add orientation specific party walls per user arguments
      num_stories_round_up.times do |i|
        test_value = i + 1 - bar_hash[:num_stories_below_grade]

        array = []
        if args['party_wall_stories_north'] >= test_value
          array << 'north'
        end
        if args['party_wall_stories_south'] >= test_value
          array << 'south'
        end
        if args['party_wall_stories_east'] >= test_value
          array << 'east'
        end
        if args['party_wall_stories_west'] >= test_value
          array << 'west'
        end

        # populate party_wall_array for this story
        party_walls_array << array
      end
    end

    # calculate party walls if using party_wall_fraction method
    if args['party_wall_fraction'] > 0 && !party_walls_array.empty?
      runner.registerWarning('Both orientation and fractional party wall values arguments were populated, will ignore fractional party wall input')
    elsif args['party_wall_fraction'] > 0

      # orientation of long and short side of building will vary based on building rotation

      # full story ext wall area
      typical_length_facade_area = length * floor_height_si
      typical_width_facade_area = width * floor_height_si

      # top story ext wall area, may be partial story
      partial_story_multiplier = (1.0 - args['num_stories_above_grade'].ceil + args['num_stories_above_grade'])
      area_multiplier = partial_story_multiplier
      edge_multiplier = Math.sqrt(area_multiplier)
      top_story_length = length * edge_multiplier
      top_story_width = width * edge_multiplier
      top_story_length_facade_area = top_story_length * floor_height_si
      top_story_width_facade_area = top_story_width * floor_height_si

      total_exterior_wall_area = 2 * (length + width) * (args['num_stories_above_grade'].ceil - 1.0) * floor_height_si + 2 * (top_story_length + top_story_width) * floor_height_si
      target_party_wall_area = total_exterior_wall_area * args['party_wall_fraction']

      width_counter = 0
      width_area = 0.0
      facade_area = typical_width_facade_area
      until (width_area + facade_area >= target_party_wall_area) || (width_counter == args['num_stories_above_grade'].ceil * 2)
        # update facade area for top story
        if width_counter == args['num_stories_above_grade'].ceil - 1 || width_counter == args['num_stories_above_grade'].ceil * 2 - 1
          facade_area = top_story_width_facade_area
        else
          facade_area = typical_width_facade_area
        end

        width_counter += 1
        width_area += facade_area

      end
      width_area_remainder = target_party_wall_area - width_area

      length_counter = 0
      length_area = 0.0
      facade_area = typical_length_facade_area
      until (length_area + facade_area >= target_party_wall_area) || (length_counter == args['num_stories_above_grade'].ceil * 2)
        # update facade area for top story
        if length_counter == args['num_stories_above_grade'].ceil - 1 || length_counter == args['num_stories_above_grade'].ceil * 2 - 1
          facade_area = top_story_length_facade_area
        else
          facade_area = typical_length_facade_area
        end

        length_counter += 1
        length_area += facade_area
      end
      length_area_remainder = target_party_wall_area - length_area

      # get rotation and best fit to adjust orientation for fraction party wall
      rotation = args['building_rotation'] % 360.0 # should result in value between 0 and 360
      card_dir_array = [0.0, 90.0, 180.0, 270.0, 360.0]
      # reverse array to properly handle 45, 135, 225, and 315
      best_fit = card_dir_array.reverse.min_by { |x| (x.to_f - rotation).abs }

      if ![90.0, 270.0].include? best_fit
        width_card_dir = ['east', 'west']
        length_card_dir = ['north', 'south']
      else # if rotation is closest to 90 or 270 then reverse which orientation is used for length and width
        width_card_dir = ['north', 'south']
        length_card_dir = ['east', 'west']
      end

      # if dont' find enough on short sides
      if width_area_remainder <= typical_length_facade_area

        num_stories_round_up.times do |i|
          if i + 1 <= args['num_stories_below_grade']
            party_walls_array << []
            next
          end
          if i + 1 - args['num_stories_below_grade'] <= width_counter
            if i + 1 - args['num_stories_below_grade'] <= width_counter - args['num_stories_above_grade']
              party_walls_array << width_card_dir
            else
              party_walls_array << [width_card_dir.first]
            end
          else
            party_walls_array << []
          end
        end

      else # use long sides instead

        num_stories_round_up.times do |i|
          if i + 1 <= args['num_stories_below_grade']
            party_walls_array << []
            next
          end
          if i + 1 - args['num_stories_below_grade'] <= length_counter
            if i + 1 - args['num_stories_below_grade'] <= length_counter - args['num_stories_above_grade']
              party_walls_array << length_card_dir
            else
              party_walls_array << [length_card_dir.first]
            end
          else
            party_walls_array << []
          end
        end

      end

      # TODO: - currently won't go past making two opposing sets of walls party walls. Info and registerValue are after create_bar in measure.rb

    end

    # populate bar hash with story information
    bar_hash[:stories] = {}
    num_stories_round_up.times do |i|
      if party_walls_array.empty?
        party_walls = []
      else
        party_walls = party_walls_array[i]
      end

      # add below_partial_story
      if num_stories.ceil > num_stories && i == num_stories_round_up - 2
        below_partial_story = true
      else
        below_partial_story = false
      end

      # bottom_story_ground_exposed_floor and top_story_exterior_exposed_roof already setup as bool
      bar_hash[:stories]["key #{i}"] = { story_party_walls: party_walls, story_min_multiplier: 1, story_included_in_building_area: true, below_partial_story: below_partial_story, bottom_story_ground_exposed_floor: args['bottom_story_ground_exposed_floor'], top_story_exterior_exposed_roof: args['top_story_exterior_exposed_roof'] }
    end

    # create bar
    create_bar(runner, model, bar_hash, args['story_multiplier'])

  end

end

# register the measure to be used by the application
CreateBarFromBuildingTypeRatios.new.registerWithApplication
