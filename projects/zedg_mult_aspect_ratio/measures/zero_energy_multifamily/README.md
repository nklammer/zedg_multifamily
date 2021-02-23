

###### (Automatically generated documentation)

# Zero Energy Multifamily

## Description
Takes a model with space and stub space types, and applies constructions, schedules, internal loads, hvac, and service water heating to match the Zero Energy Multifamily Design Guide recommendations.

## Modeler Description
This measure has optional arguments to apply recommendations from different sections of the Zero Energy Multifamily Design Guide.

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Add Constructions to Model
Construction Set will be appied to entire building
**Name:** add_constructions,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Add Space Type Loads to Model
Populate existing space types in model with internal loads.
**Name:** add_space_type_loads,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Add Elevators to Model
Elevators will be add directly to space in model vs. being applied to a space type.
**Name:** add_elevators,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Add Internal Mass to Model
Adds internal mass to each space.
**Name:** add_internal_mass,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Add Thermostats
Add Thermost to model based on Space Type Standards information of spaces assigned to thermal zones.
**Name:** add_thermostat,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Add Service Water Heating to Model
This will add both the supply and demand side of service water heating.
**Name:** add_swh,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Service Water Heating Source
The primary source of heating used by SWH systems in the model.
**Name:** swh_type,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Add HVAC System to Model

**Name:** add_hvac,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### HVAC System Type

**Name:** hvac_system_type,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Clean Model of non-geometry objects
Only removes objects of type that are selected to be added.
**Name:** remove_objects,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false




