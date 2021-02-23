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

# start the measure
class ZeroEnergyMultifamily < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    return 'Zero Energy Multifamily'
  end

  # human readable description
  def description
    return 'Takes a model with space and stub space types, and applies constructions, schedules, internal loads, hvac, and service water heating to match the Zero Energy Multifamily Design Guide recommendations.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'This measure has optional arguments to apply recommendations from different sections of the Zero Energy Multifamily Design Guide.'
  end

  def zero_energy_multifamily_add_hvac(model, runner, standard, system_type, zones)
    heated_and_cooled_zones = zones.select { |zone| standard.thermal_zone_heated?(zone) && standard.thermal_zone_cooled?(zone) }
    heated_zones = zones.select { |zone| standard.thermal_zone_heated?(zone) }
    cooled_zones = zones.select { |zone| standard.thermal_zone_cooled?(zone) }
    cooled_only_zones = zones.select { |zone| !standard.thermal_zone_heated?(zone) && standard.thermal_zone_cooled?(zone) }
    heated_only_zones = zones.select { |zone| standard.thermal_zone_heated?(zone) && !standard.thermal_zone_cooled?(zone) }
    system_zones = heated_and_cooled_zones + cooled_only_zones

    # ventilation systems added first so that the most controllable equipment is last in zone priority
    case system_type

    when 'Minisplit Heat Pumps with DOAS'
      standard.model_add_hvac_system(model, 'DOAS', 'Electricity', nil, 'Electricity', system_zones,
                                     air_loop_heating_type: 'DX',
                                     air_loop_cooling_type: 'DX')
      standard.model_add_hvac_system(model, 'Residential Minisplit Heat Pumps', nil, nil, nil, system_zones)

    when 'Minisplit Heat Pumps with ERVs'
      standard.model_add_hvac_system(model, 'ERVs', nil, nil, nil, system_zones)
      standard.model_add_hvac_system(model, 'Residential Minisplit Heat Pumps', nil, nil, nil, system_zones)

    when 'Four-pipe Fan Coils with central air-source heat pump with DOAS'
      standard.model_add_hvac_system(model, 'DOAS', 'AirSourceHeatPump', nil, 'Electricity', system_zones,
                                     hot_water_loop_type: 'LowTemperature',
                                     chilled_water_loop_cooling_type: 'AirCooled',
                                     air_loop_heating_type: 'Water',
                                     air_loop_cooling_type: 'Water')
      standard.model_add_hvac_system(model, 'Fan Coil', 'AirSourceHeatPump', nil, 'Electricity', system_zones,
                                     hot_water_loop_type: 'LowTemperature',
                                     chilled_water_loop_cooling_type: 'AirCooled',
                                     zone_equipment_ventilation: false)

    when 'Four-pipe Fan Coils with central air-source heat pump with ERVs'
      standard.model_add_hvac_system(model, 'ERVs', nil, nil, nil, system_zones)
      standard.model_add_hvac_system(model, 'Fan Coil', 'AirSourceHeatPump', nil, 'Electricity', system_zones,
                                     hot_water_loop_type: 'LowTemperature',
                                     chilled_water_loop_cooling_type: 'AirCooled',
                                     zone_equipment_ventilation: false)

    when 'Water Source Heat Pumps with Boiler and Fluid-cooler with DOAS'
      standard.model_add_hvac_system(model, 'DOAS', 'Electricity', nil, 'Electricity', system_zones,
                                     air_loop_heating_type: 'DX',
                                     air_loop_cooling_type: 'DX')
      standard.model_add_hvac_system(model, 'Water Source Heat Pumps', 'NaturalGas', nil, 'Electricity', system_zones,
                                     heat_pump_loop_cooling_type: 'EvaporativeFluidCooler',
                                     zone_equipment_ventilation: false)

    when 'Water Source Heat Pumps with Boiler and Fluid-cooler with ERVs'
      standard.model_add_hvac_system(model, 'ERVs', nil, nil, nil, system_zones)
      standard.model_add_hvac_system(model, 'Water Source Heat Pumps', 'NaturalGas', nil, 'Electricity', system_zones,
                                     heat_pump_loop_cooling_type: 'EvaporativeFluidCooler',
                                     zone_equipment_ventilation: false)

    else
      runner.registerError("HVAC System #{system_type} not recognized")
      return false
    end
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # make an argument for add_constructions
    add_constructions = OpenStudio::Measure::OSArgument.makeBoolArgument('add_constructions', true)
    add_constructions.setDisplayName('Add Constructions to Model')
    add_constructions.setDescription('Construction Set will be appied to entire building')
    add_constructions.setDefaultValue(true)
    args << add_constructions

    # make an argument for add_space_type_loads
    add_space_type_loads = OpenStudio::Measure::OSArgument.makeBoolArgument('add_space_type_loads', true)
    add_space_type_loads.setDisplayName('Add Space Type Loads to Model')
    add_space_type_loads.setDescription('Populate existing space types in model with internal loads.')
    add_space_type_loads.setDefaultValue(true)
    args << add_space_type_loads
    # make an argument for add_elevators
    add_elevators = OpenStudio::Measure::OSArgument.makeBoolArgument('add_elevators', true)
    add_elevators.setDisplayName('Add Elevators to Model')
    add_elevators.setDescription('Elevators will be add directly to space in model vs. being applied to a space type.')
    add_elevators.setDefaultValue(false)
    args << add_elevators

    # make an argument for add_internal_mass
    add_internal_mass = OpenStudio::Measure::OSArgument.makeBoolArgument('add_internal_mass', true)
    add_internal_mass.setDisplayName('Add Internal Mass to Model')
    add_internal_mass.setDescription('Adds internal mass to each space.')
    add_internal_mass.setDefaultValue(true)
    args << add_internal_mass

    # make an argument for add_thermostat
    add_thermostat = OpenStudio::Measure::OSArgument.makeBoolArgument('add_thermostat', true)
    add_thermostat.setDisplayName('Add Thermostats')
    add_thermostat.setDescription('Add Thermost to model based on Space Type Standards information of spaces assigned to thermal zones.')
    add_thermostat.setDefaultValue(true)
    args << add_thermostat

    # make an argument for add_swh
    add_swh = OpenStudio::Measure::OSArgument.makeBoolArgument('add_swh', true)
    add_swh.setDisplayName('Add Service Water Heating to Model')
    add_swh.setDescription('This will add both the supply and demand side of service water heating.')
    add_swh.setDefaultValue(true)
    args << add_swh

    swh_chs = OpenStudio::StringVector.new
    swh_chs << 'HeatPump'
    swh_type = OpenStudio::Measure::OSArgument.makeChoiceArgument('swh_type', swh_chs, true)
    swh_type.setDisplayName('Service Water Heating Source')
    swh_type.setDescription('The primary source of heating used by SWH systems in the model.')
    swh_type.setDefaultValue('HeatPump')
    args << swh_type

    # make an argument for add_hvac
    add_hvac = OpenStudio::Measure::OSArgument.makeBoolArgument('add_hvac', true)
    add_hvac.setDisplayName('Add HVAC System to Model')
    add_hvac.setDefaultValue(true)
    args << add_hvac

    # Make argument for system type
    hvac_chs = OpenStudio::StringVector.new
    hvac_chs << 'Minisplit Heat Pumps with DOAS'
    hvac_chs << 'Minisplit Heat Pumps with ERVs'
    hvac_chs << 'Four-pipe Fan Coils with central air-source heat pump with DOAS'
    hvac_chs << 'Four-pipe Fan Coils with central air-source heat pump with ERVs'
    hvac_chs << 'Water Source Heat Pumps with Boiler and Fluid-cooler with DOAS'
    hvac_chs << 'Water Source Heat Pumps with Boiler and Fluid-cooler with ERVs'
    hvac_system_type = OpenStudio::Measure::OSArgument.makeChoiceArgument('hvac_system_type', hvac_chs, true)
    hvac_system_type.setDisplayName('HVAC System Type')
    hvac_system_type.setDefaultValue('Minisplit Heat Pumps with DOAS')
    args << hvac_system_type

    # make an argument for remove_objects
    remove_objects = OpenStudio::Measure::OSArgument.makeBoolArgument('remove_objects', true)
    remove_objects.setDisplayName('Clean Model of non-geometry objects')
    remove_objects.setDescription('Only removes objects of type that are selected to be added.')
    remove_objects.setDefaultValue(true)
    args << remove_objects

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    unless runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign the user inputs to variables
    args = {}
    args['add_constructions'] = runner.getBoolArgumentValue('add_constructions', user_arguments)
    args['add_elevators'] = runner.getBoolArgumentValue('add_elevators', user_arguments)
    args['add_constructions'] = runner.getBoolArgumentValue('add_constructions', user_arguments)
    args['add_internal_mass'] = runner.getBoolArgumentValue('add_internal_mass', user_arguments)
    args['add_thermostat'] = runner.getBoolArgumentValue('add_thermostat', user_arguments)
    args['add_swh'] = runner.getBoolArgumentValue('add_swh', user_arguments)
    args['swh_type'] = runner.getStringArgumentValue('swh_type', user_arguments)
    args['add_hvac'] = runner.getBoolArgumentValue('add_hvac', user_arguments)
    args['hvac_system_type'] = runner.getStringArgumentValue('hvac_system_type', user_arguments)
    args['remove_objects'] = runner.getBoolArgumentValue('remove_objects', user_arguments)

    # report initial condition of model
    initial_objects = model.getModelObjects.size
    runner.registerInitialCondition("The building started with #{initial_objects} objects.")

    # open channel to log messages
    reset_log

    # Make the standard applier
    standard = Standard.build('NREL ZNE Ready 2017')

    # get climate zone for model
    climate_zone = standard.model_standards_climate_zone(model)
    if climate_zone.empty?
      runner.registerError('Climate zone could not be determined. Please set climate zone in the model.')
      log_messages_to_runner(runner, debug = true)
      return false
    else
      runner.registerInfo("Using climate zone #{climate_zone} from model")
    end

    # identify primary building type (used for construction, and ideally HVAC as well)
    building_types = {}
    model.getSpaceTypes.each do |space_type|
      # populate hash of building types
      if space_type.standardsBuildingType.is_initialized
        bldg_type = space_type.standardsBuildingType.get
        if !building_types.key?(bldg_type)
          building_types[bldg_type] = space_type.floorArea
        else
          building_types[bldg_type] += space_type.floorArea
        end
      else
        runner.registerWarning("Can't identify building type for #{space_type.name}")
      end
    end
    primary_bldg_type = building_types.key(building_types.values.max) # TODO: - this fails if no space types, or maybe just no space types with standards
    lookup_building_type = standard.model_get_lookup_name(primary_bldg_type) # Used for some lookups in the standards gem
    model.getBuilding.setStandardsBuildingType(primary_bldg_type)

    # make construction set and apply to building
    if args['add_constructions']
      runner.registerInfo("Template 'NREL ZNE Ready 2017' does not have construction properities defined; skipping add constructions.")
      # # remove default construction sets
      # model.getDefaultConstructionSets.each(&:remove) if args['remove_objects']
      #
      # # TODO: - allow building type and space type specific constructions set selection.
      # if ['SmallHotel', 'LargeHotel', 'MidriseApartment', 'HighriseApartment'].include?(primary_bldg_type)
      #   is_residential = 'Yes'
      # else
      #   is_residential = 'No'
      # end
      #
      # bldg_def_const_set = standard.model_add_construction_set(model, climate_zone, lookup_building_type, nil, is_residential)
      # if bldg_def_const_set.is_initialized
      #   bldg_def_const_set = bldg_def_const_set.get
      #   if is_residential then bldg_def_const_set.setName("Res #{bldg_def_const_set.name}") end
      #   model.getBuilding.setDefaultConstructionSet(bldg_def_const_set)
      #   runner.registerInfo("Adding default construction set named #{bldg_def_const_set.name}")
      # else
      #   runner.registerError("Could not create default construction set for the building type #{lookup_building_type} in climate zone #{climate_zone}.")
      #   log_messages_to_runner(runner, debug = true)
      #   return false
      # end
      #
      # # address any adiabatic surfaces that don't have hard assigned constructions
      # model.getSurfaces.each do |surface|
      #   next if surface.outsideBoundaryCondition != 'Adiabatic'
      #   next if surface.construction.is_initialized
      #   surface.setAdjacentSurface(surface)
      #   surface.setConstruction(surface.construction.get)
      #   surface.setOutsideBoundaryCondition('Adiabatic')
      # end
      #
      # # modify the infiltration rates
      # if args['remove_objects']
      #   model.getSpaceInfiltrationDesignFlowRates.each(&:remove)
      # end
      # standard.model_apply_infiltration_standard(model)
      # standard.model_modify_infiltration_coefficients(model, primary_bldg_type, climate_zone)
      #
      # # set ground temperatures from DOE prototype buildings
      # standard.model_add_ground_temperatures(model, primary_bldg_type, climate_zone)
    end

    # add internal loads to space types
    if args['add_space_type_loads']

      # remove internal loads
      if args['remove_objects']
        model.getSpaceLoads.each do |instance|
          next if instance.name.to_s.include?('Elevator') # most prototype building types model exterior elevators with name Elevator
          next if instance.to_InternalMass.is_initialized
          next if instance.to_WaterUseEquipment.is_initialized
          instance.remove
        end
        model.getDesignSpecificationOutdoorAirs.each(&:remove)
        model.getDefaultScheduleSets.each(&:remove)
      end

      model.getSpaceTypes.each do |space_type|
        # Don't add infiltration here; will be added later in the script
        unless standard.space_type_apply_internal_loads(space_type, true, true, true, true, true, false)
          runner.registerWarning("Could not add loads for #{space_type.name}. Not expected for #{args['template']}")
          next
        end

        # apply internal load schedules
        # the last bool test it to make thermostat schedules. They are now added in HVAC section instead of here
        standard.space_type_apply_internal_load_schedules(space_type, true, true, true, true, true, true, false)

        # extend space type name to include the args['template']. Consider this as well for load defs
        space_type.setName("#{space_type.name} - #{args['template']}")
        runner.registerInfo("Adding loads to space type named #{space_type.name}")
      end

      # warn if spaces in model without space type
      spaces_without_space_types = []
      model.getSpaces.each do |space|
        next if space.spaceType.is_initialized
        spaces_without_space_types << space
      end
      unless spaces_without_space_types.empty?
        runner.registerWarning("#{spaces_without_space_types.size} spaces do not have space types assigned, and wont' receive internal loads from standards space type lookups.")
      end
    end

    # add elevators (returns ElectricEquipment object)
    if args['add_elevators']

      # remove elevators as spaceLoads or exteriorLights
      model.getSpaceLoads.each do |instance|
        next unless instance.name.to_s.include?('Elevator') # most prototype building types model exterior elevators with name Elevator
        instance.remove
      end
      model.getExteriorLightss.each do |ext_light|
        next unless ext_light.name.to_s.include?('Fuel equipment') # some prototype building types model exterior elevators by this name
        ext_light.remove
      end

      elevators = standard.model_add_elevators(model)
      if elevators.nil?
        runner.registerInfo('No elevators added to the building.')
      else
        elevator_def = elevators.electricEquipmentDefinition
        design_level = elevator_def.designLevel.get
        runner.registerInfo("Adding #{elevators.multiplier.round(1)} elevators each with power of #{OpenStudio.toNeatString(design_level, 0, true)} (W), plus lights and fans.")
        elevator_def.setFractionLost(1.0)
        elevator_def.setFractionRadiant(0.0)
      end
    end

    # add internal mass
    if args['add_internal_mass']

      if args['remove_objects']
        model.getSpaceLoads.each do |instance|
          next unless instance.to_InternalMass.is_initialized
          instance.remove
        end
      end

      # add internal mass to conditioned spaces; needs to happen after thermostats are applied
      standard.model_add_internal_mass(model, primary_bldg_type)
    end

    # add thermostats
    if args['add_thermostat']

      # remove thermostats
      if args['remove_objects']
        model.getThermostatSetpointDualSetpoints.each(&:remove)
      end

      model.getSpaceTypes.each do |space_type|
        # create thermostat schedules
        # skip un-recognized space types
        next if standard.space_type_get_standards_data(space_type).empty?
        # the last bool test it to make thermostat schedules. They are added to the model but not assigned
        standard.space_type_apply_internal_load_schedules(space_type, false, false, false, false, false, false, true)

        # identify thermal thermostat and apply to zones (apply_internal_load_schedules names )
        model.getThermostatSetpointDualSetpoints.each do |thermostat|
          next if thermostat.name.to_s != "#{space_type.name} Thermostat"
          next unless thermostat.coolingSetpointTemperatureSchedule.is_initialized
          next unless thermostat.heatingSetpointTemperatureSchedule.is_initialized
          runner.registerInfo("Assigning #{thermostat.name} to thermal zones with #{space_type.name} assigned.")
          space_type.spaces.each do |space|
            next unless space.thermalZone.is_initialized
            space.thermalZone.get.setThermostatSetpointDualSetpoint(thermostat)
          end
        end
      end
    end

    # add service water heating demand and supply
    if args['add_swh']

      # remove water use equipment and water use connections
      if args['remove_objects']
        # TODO: - remove plant loops used for service water heating
        model.getWaterUseEquipments.each(&:remove)
        model.getWaterUseConnectionss.each(&:remove)
      end

      typical_swh = standard.model_add_typical_swh(model, water_heater_fuel: args['swh_type'])
      midrise_swh_loops = []
      stripmall_swh_loops = []
      typical_swh.each do |loop|
        if loop.name.get.include?('MidriseApartment')
          midrise_swh_loops << loop
        elsif loop.name.get.include?('RetailStripmall')
          stripmall_swh_loops << loop
        else
          water_use_connections = []
          loop.demandComponents.each do |component|
            next unless component.to_WaterUseConnections.is_initialized
            water_use_connections << component
          end
          runner.registerInfo("Adding #{loop.name} to the building. It has #{water_use_connections.size} water use connections.")
        end
      end
      unless midrise_swh_loops.empty?
        runner.registerInfo("Adding #{midrise_swh_loops.size} MidriseApartment service water heating loops.")
      end
      unless stripmall_swh_loops.empty?
        runner.registerInfo("Adding #{stripmall_swh_loops.size} RetailStripmall service water heating loops.")
      end
    end

    # add hvac system
    if args['add_hvac']

      # remove HVAC objects
      standard.model_remove_prm_hvac(model) if args['remove_objects']

      # Group the zones by occupancy type.  Only split out non-dominant groups if their total area exceeds the limit.
      sys_groups = standard.model_group_zones_by_type(model, OpenStudio.convert(20_000, 'ft^2', 'm^2').get)
      sys_groups.each do |sys_group|
        zero_energy_multifamily_add_hvac(model, runner, standard, args['hvac_system_type'], sys_group['zones'])
      end
    end

    # set unmet hours tolerance to 1 deg R
    unmet_hrs_tol_k = OpenStudio.convert(1.0, 'R', 'K').get
    tolerances = model.getOutputControlReportingTolerances
    tolerances.setToleranceforTimeHeatingSetpointNotMet(unmet_hrs_tol_k)
    tolerances.setToleranceforTimeCoolingSetpointNotMet(unmet_hrs_tol_k)

    # set hvac controls and efficiencies (this should be last model articulation element)
    if args['add_hvac']

      # set additional properties for building
      props = model.getBuilding.additionalProperties
      props.setFeature('hvac_system_type', args['hvac_system_type'])

      # Set the heating and cooling sizing parameters
      standard.model_apply_prm_sizing_parameters(model)

      # Perform a sizing run
      unless standard.model_run_sizing_run(model, "#{Dir.pwd}/SizingRun")
        log_messages_to_runner(runner, debug = true)
        return false
      end

      # Apply the HVAC efficiency standard
      standard.model_apply_hvac_efficiency_standard(model, climate_zone)
    end

    # remove everything but spaces, zones, and stub space types (extend as needed for additional objects, may make bool arg for this)
    if args['remove_objects']
      model.purgeUnusedResourceObjects
      objects_after_cleanup = initial_objects - model.getModelObjects.size
      if objects_after_cleanup > 0
        runner.registerInfo("Removing #{objects_after_cleanup} objects from model")
      end
    end

    # report final condition of model
    runner.registerFinalCondition("The building finished with #{model.getModelObjects.size} objects.")

    # log messages to info messages
    log_messages_to_runner(runner, debug = false)

    return true
  end
end

# register the measure to be used by the application
ZeroEnergyMultifamily.new.registerWithApplication
