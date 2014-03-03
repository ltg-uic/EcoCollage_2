 extensions [sql]

breed [ sewers sewer ]                ;; This creates icons for the sewers
breed [ GI a-GI ]                     ;; This creates icons for green infrastructure
breed [ outflow-cells outflow-cell ]  ;; This creates an icon for the outflow cell
breed [ inflow-cells inflow-dell ]
breed [ road-cells road-cell ]        ;; This creates icons to distinguish road cells
breed [ rain-barrels rain-barrel ]
breed [ swales swale ]
breed [ permeable-pavers permeable-paver ]
breed [ green-roofs green-roof ]


globals [
  
  ;; The next four are used by Tia's code for the SQL extension and to identify the run information  
  db
  query
  runID
  studyID
  imageName
  
  ;; Formerlt sliders, switches, or choosers.
  Outlet-control-height
  GI-placement
  Starting-soil-saturation
  Starting-fullness-GI-extra-storage
  Starting-fullness-of-sewers
  Extreme-flood-definition
  Flood-definition
  when-sewers-full
  activate-outlet?
  Sewer-intake-regulator?
  Vary-landscape?
  Repetitions-per-Iteration
  Blocks-vertical
  Storm-type
  storm-hours
  percent-impervious
  Slope-percent
  %-landscape-swale
  GI-concentrated-near-outlet
  %-impermeable-rain-barrels
  %-impermeable-green-roof
  Green-Alleys?
  activate-sewers?
  curbs?
  GI-Budget
  Type-to-Place
  
  pre-flow-water
  post-flow-water
  flow-error
  
  Water-near-outlet-now
  water-near-outlet-previous
  water-near-outlet-error
  
  ;; Constant = value will not change within a single model run.
  ;; Dynamic = value changes throughout the run.
  ;; Cell-specific units = the level of water, in mm, on a single cell, or essentially thei height of water specific to a dimensions of 1 cell. To convert the number in variable with the numerical value stored in it of n,
                     ;; assuming it is labeled as being in this type of unit, to volume, the equation would be ( ( cell-dimension ^ 2 ) * n )
  
  ;; setup variables. all constant.
  
  max-outflow
  
  stop-tick                   ;; The tick when the model will stop. Set to be two days after the end of the rain event.
  storm-length                ;; The length of the storm in minutes.
  cell-dimension              ;; length of one side of a cell in mm.  All cells are square, so either length or width could be represented by cell-dimension.

;  Repetitions-per-Iteration   ;; the number of subroutines per minute iteration. e.g, of this is set to 4, then each subroutine is 15 seconds. A subroutine is simple a full repetition of all the model processes.
  conversion-multiplier       ;; a multiplier that converts amounts in cell-specific variable amounts to m^3.

  ;; tracking of total amounts. all dynamic
  global-precipitation        ;; cumulative precipitation that has fallen across entire landscape in m^3
  global-infiltration         ;; cumulative infiltration from all types of cells across the entire landscape in m^3
  global-GI-infiltration      ;; cumulative infiltration in green infrastructure cells over the entire landscape in m^3
  global-Non-GI-infiltration  ;; cumulative infiltration in permeable cover cells over entire landscape in m^3
  global-evapotrans           ;; cumulative evapotranspiration across the entire landscape in m^3
  global-evapo                ;; cumulative evaporation across the entire landscape in m^3
  global-sewer                ;; cumulative intake by the sewers cross the entire landscape in m^3
  global-sewer-drain          ;; cumulative water that has been treated by sewage treatment plant in cell-specific units.
  global-CSO                  ;; cumulative volume of any CSOs. in cell-specific units.
  global-outflow              ;; cumulative water that has flowed from the outlet cell and left the landscape. in m^3
  global-inflow
  
  
  global-precipitation-ft3
  global-GI-infiltration-ft3
  global-Non-GI-infiltration-ft3
  global-sewer-ft3
  global-outflow-ft3
  global-evapo-ft3
  global-evapotrans-ft3
  non-GI-accumulated-water-ft3
  water-in-storage-ft3
  total-extra-storage-ft3
  global-inflow-ft3
  
  potential-rain
  
  ;; Metrics!
  Cost-install-private-GI
  Cost-install-public-GI
  Cost-total-install
  Cost-private-maintenance
  Cost-public-maintenance
  Cost-total-maintenance
  Cost-private-storm-damage
  Cost-public-storm-damage
  Costs-total-storm-damage
  Costs-total
  
  Normalized-Cost-install-private-GI
  Normalized-Cost-install-public-GI
  Normalized-Cost-total-install
  Normalized-Cost-private-maintenance
  Normalized-Cost-public-maintenance
  Normalized-Cost-total-maintenance
  Normalized-Cost-private-storm-damage
  Normalized-Cost-public-storm-damage
  Normalized-Costs-total-storm-damage
  Normalized-Costs-total

  time-to-lesser-flood
  time-to-greater-flood
  time-duration-lesser-flood
  time-duration-greater-flood
  time-to-dry

  Normalized-time-to-lesser-flood
  Normalized-time-to-greater-flood
  Normalized-time-duration-lesser-flood
  Normalized-time-duration-greater-flood
  Normalized-time-to-dry

  

  global-standing-water-ft3
  greatest-depth-standing-water-ft
  
  global-rain-barrel-ft3
  global-green-roof-ft3
  global-green-alleys-ft3
  global-swales-ft3
  global-GI-total-ft3
  
  global-efficiency-rain-barrels
  global-efficiency-green-roofs
  global-efficiency-green-alleys
  global-efficiency-swales
  global-efficiency-total

  Normalized-global-outflow-ft3
  Normalized-global-sewer-ft3
  Normalized-global-standing-water-ft3
  Normalized-greatest-depth-standing-water-ft
  
  Normalized-global-rain-barrel-ft3
  Normalized-global-green-roof-ft3
  Normalized-global-green-alleys-ft3
  Normalized-global-swales-ft3
  Normalized-global-GI-total-ft3
  
  global-rain-barrel
  global-green-roof
  global-green-alleys
  global-swales
  global-GI-total
  
  
  ;; landscape performance variables. all dynamic
  accumulated-water           ;; all accumulated water on the surface, including water in green infrastructure storage. in m^3
  non-GI-accumulated-water
;  above-0-accumulated-water   ;; total volume in m^3 of water accumulated on cell surfaces, excluding water in green infrastructure storage capacity
;  above-0-non-GI
  water-in-storage            ;; total volume in m^3 of water in swale above soil storage
  total-extra-storage
  average-water-height        ;; average water depth across landscape in mm
  average-water-height-roads  ;; average water depth on roads only in mm
  total-flooded   ;;; number flooded that iteration
  max-flooded                 ;; records the number of cells flooded (water-column > 1cm) at the point during the storm event when the flooding is at its greatest extent.
  
  impermeable-flooded
  impermeable-ever-flooded
  
  impermeable-extreme-flooded
  impermeable-ever-extreme-flooded
  
  road-extreme-flooded
  road-ever-extreme-flooded
  
  
  cumulative-margin-of-error  ;; global tracker that determines proportional difference between all water that has fallen and water with known outcomes.  Error is due to flow code.
  error-now
  
  ;; process variables
  total-rainfall              ;; the total amount of rain in mm that will fall during the storm event. constant.
  rainfall-rate               ;; in millimeters, the amount of rainfall that falls in one subroutine . Constant.
  daily-evaporation-rate      ;; the daily rate of evaporation, calibrated for Chicago at 4.66 mm per 24 hour period. constant
  evapo-rate                  ;; in millimeters per time period of a subroutine, the amount of water that evaporates after rainfall stops. constant.
  daily-evapotranspiration-rate ;; the daily rate of evapotranspiration. constant.
  evapotrans-rate             ;; in millimeters per time period of a subroutine, the amount of water that evapotranspirates. Constant.
  hydraulic-conductivity      ;; in millimeters per tipe period of the subroutine. used by Green-Ampt. Constant.
   
  ;; sewer variables
  water-in-pipes              ;; the total amount of water that has left the sewer intake cells' catchment basins but is still awaiting treatment by the virtual treatment plant.
                              ;; in the "cell-specific" units of measure. dynamic
  max-sewer-capacity          ;; the total amount of water, in cell-specific" units of measure, that the sewers can handle before they fill and lose some capacity to intake water unless CSOs are allowed.
                              ;; calibrated with 24-hour, 5-year storms as the baseline for what the sewer system is engineered to handle without flooding. constant.
  benchmark-storm             ;; used to set the max-sewer-capacity. the average amount of rain in mm that can fall on a patch without the sewers flooding.
  full-sewers?                ;; a yes/no variable about whether the water in the pipes has reached the maximum capacity they can handle
  sewer-basin-capacity        ;; the volume of water in m^3 a basin can hold.
  adjusted-sewer-basin-capacity     ;; height (or capacity) of a sewer basin in mm. volume the same, but the height adjusted to represent the height if the basin had the same dimensions as the cells. constant
  sewer-basin-height-below-pipe     ;; the amount of water that will never flow out of a sewer catchment basin through the pipe, ie the % of the basin that is below the outlet pipe. We calculate it is 62% of the sewer-basin-capacity. constant
  sewer-rate                  ;; the maximum potential rate at which water enters the sewer syetem. in mm per minute. constant
  base-sewer-rate             ;; the sewer-rate, but divided by the number of subroutines per minute. constant
  full-sewer-rate             ;; the rate at which water enters the sewer system if the sewer system is full (essentially meaning that intake is restricted to the water treatment rate at teh plant unless there are CSOs. constant.       
  used-sewer-rate             ;; the actual sewer intake rate that will be used at that iteration. It is either the base-sewer-rate or the full-sewer-rate. constant.
  sewer-drain-rate            ;; the amount of water treated by the sewage treatment plant each model iteration. 
                              ;; Sewer-drain-rate scales with the landscape so that larger landscapes have correspondingly higher treatment rates.
                              ;; in cell-specific units. Constant.
  ;;; permeable pavement
  paver-underdrain-depth      ;; in mm. depth below surface of the underdrain
  paver-underdrain-rate       ;; rate in mm per iteration. based on .5 inches per hour
  
  
  ;; Misc. Variables
  max-elevation               ;; the maximum elevation in the landscape. set to speed up the visualizations. constant.
  iteration-CSO               ;; the amount of CSO that happens during that iteration. in cell-specific units. dynamic
  
  total-on-outlet
  
  
  group-counter
  
  ;;; for the outlet
  peak-discharge-rate
  velocity-of-flow
  cross-sectional-area
  mannings-coefficient
  hydraulic-radius
  longitudal-slope
  wetting-perimeter
  
  gi-patches
  permeable-patches
  impermeable-patches
  
  sum-storage-capacity
  sum-infil-capacity
  
  tracked-cell
  max-height-tracked-cell
  
  list-roads-alleys
  list-non-roads-or-alleys
  
  rain-barrel-storage
  time
  
  ;; Costs
  cost-a-permeable-paver
  cost-a-green-roof
  cost-a-swale
  cost-a-rain-barrel
  remaining-budget
  formatted-remaining-budget
  formatted-Cost-of-GI
  formatted-cost-total-maintenance
  maintenance-a-paver
  maintenance-a-swale
  maintenance-a-roof
  maintenance-a-barrel
  
  
  GI-Budget-dollars
  Flood-definition-mm
  Extreme-flood-definition-mm
  Outlet-control-height-mm
  iteration-flow
  
  ;;; Max dry volume of GI in m^3
  volume-rain-barrels
  volume-green-roofs
  volume-green-alleys
  volume-swales
  volume-total-GI
  
  volume-rain-barrels-ft3
  volume-green-roofs-ft3
  volume-green-alleys-ft3
  volume-swales-ft3
  volume-total-GI-ft3
  
  volume-a-rain-barrel
  volume-a-green-roof
  volume-a-paver
  volume-a-swale
  
  volume-a-rain-barrel-ft3
  volume-a-green-roof-ft3
  volume-a-paver-ft3
  volume-a-swale-ft3
  
  cubic-m-to-cubic-ft
  
  inflow-limit-reached?
  
  Landscape-Elevation-list ;; List of the all the patches ordered by elevation (small to large)
  
  world-dimensions-vertical
  world-dimensions-horizontal
  road-spacing-vertical
  road-spacing-horizontal
]

patches-own [
  
  error-here
  water-column-change
  water-column-previous
  

  
  ;; Variables tracking water and water movement during an iteration before being reset. dynamic
  iteration-infiltration      ;; the amount of water in cell-specific units that infiltrated on a cell in a given iteration
  iteration-precipitation     ;; the amount of precipitation in cell-specific units that fell on a cell in given iteration
  iteration-evapotrans        ;; the amount of water in cell-specific units that evapotransporates in a cell in a given iteration
  iteration-evapo             ;; the amount of water in cell-specific units that evaporates in a cell in a given iteration
  iteration-sewers            ;; the amount of water in cell-specific units that leaves the system through the storm sewers in a cell in a given iteration.  Process only occurs in sewer cells.
  iteration-outflow           ;; the amount of water in cell-specific units that leaves the system though the outlet in a cell in a given iteration.  Process only occurs in outlet cell.
  iteration-inflow
  infiltration-amount         ;; the amount of water in cell-specific units that infiltrated on a cell in a given iteration
  
  ;; Variables for type of cell and cell soil properties. constant
  cover-type                  ;; type of surface on the cell, 1 = Green Infrastructure ; 2 = impermeable ; 3 = permeable .  Constant.
  storage-capacity            ;; the potential amount of water that can stay behind on a cell in storage rather than flowing. Constant.
  water-in-swale
  sewers?                     ;; yes/no whether the cell contains a storm sewer. Constant.
  road?                      ;; yes/no whether the cell is a road.  Constant.
  alley?
  outflow?                    ;; yes/no whether the cell is the outflow cell.  Constant.
  inflow?
  height-in-sewer-basin       ;; height in mm of water in the sewer catchment basin, if the basin had the same dinemsions of the cells.
  
  
  Neighbor-Elevation-list ; A list of the patch's neighbors sorted by elevation (small to large)
  
    ;;; new
  GI?
  type-of-GI       ;; rain barrel, swale, permeable pavement, greenroof
  
  max-extra-GI-storage
  extra-GI-storage
  
  
  ;;; rain barrel
  ;;; have a small volume to hold water on site. should be located next to impermeable cells
  ;;; volume rain barrels can have in m^3 or mm^3- decide later
  ;;; this can berain-barrel-storage capacity ;;; converted volume of rain barrels to height per 10x10 m cell
  
  
  ;;; swale
  ;; same as current default GI
  ;;; check storage capacity, however, since our storage capacity was based on   
  
  ;;; permeable pavement
  
  ;;; greenroof
  ;;; lookup storage capacities- it is small
  ;;; surface flow does not go over these cells, so they need a high elevation
  ;;; make sure that water will not flow out of greenroofs unless it is above the storage capacity- as it is now, this may be a problem since GI was desihned to allow flow between GI cells
  
  
  
  ;; Variables for surface flow
  water-column                ;; the height of surface water on a cell in millimeters. dynamic
  elevation                   ;; the height in mm of the non-water portion of a cell's elevation. e.g. the underlying elevation. Constant.
  
  ;; Variables for green-ampt infiltration model
  max-wet-depth                    ;; depth to which water can infiltratee in millimeters. Represents the depth to bedrock or the water table.  Set by slider, revised by storage capacity. Constant.
  initial-moisture-deficit         ;; hydrologic characteristic of a cell's soil, determined from a table, indicating initial moisture condition of a cell (Vol. of Air / Vol. of Voids, 
                                   ;; expressed as a fraction). Constant. 
  capillary-suction                ;; the suction at the wetting front, a measure of the pressure with which water moves into soil voids, Psi, based on soil type, from a table. Constant.
  saturated-hydraulic-conductivity ;; the hydraulic conductivity of the soil, a measure of the ease at which water can move between voids
                                   ;; stays constant for a given soil type at a specific temperature.  May need to be modified for cold soils. Constant.
  base-max-wet-depth          ;; in mm, the maximum depth to which the wetting front of infiltrated water can reach afterwhich infiltration is much slpwer.
  cumulative-infiltration-amount   ;; the amount of water that has infiltrated so far, in millimeters 
  max-infil-value                  ;; calculated value for the maximum amount of water that can be infiltrated given the moisture deficit and the the max wet depth. In millimeters. Constant.
  infiltration-rate                ;; maximum rate at which water could theoretically infiltrate into a given soil type given the amount of water that has already infiltrated.
                                   ;;   May be higher than the actual infiltration rate which is limited by the rainfall-rate.
  
  ;; Misc. Variables
  
                     ;; yes/no- whether the water-level on the cell is over 1cm or not.
  Distance-outlet            ;; variable used in some of the GI location rules. The distance from a cell to the outlet.
  impervious-neighbors       ;; variable for GI location rules. The count of upstream neighbors with impervious surface
  
  patch-flooded-level
  extreme-patch-flooded-level
  
  group
  patch-marker
  lot-number
  
  
  flooded?
  ever-flooded?
  extreme-flooded?
  ever-extreme-flooded?
  
]
;; Sets variables that belong to agents.  Empty because we use agents (turtles) as graphics to show green infrastructure, roads, sewers, and the outlet, and they have no variables of their own.
turtles-own [
]

;; Sets initial model conditions
to setup
  clear-all
  
  
  
  ;;; Variables formerly sliders
  set Starting-soil-saturation 0
  set Starting-fullness-GI-extra-storage 0
  set Starting-fullness-of-sewers 0
  set Extreme-flood-definition 6
  set Flood-definition 1
  set when-sewers-full "no-CSO"
  set Sewer-intake-regulator? false
  set Repetitions-per-Iteration 1
  set Blocks-vertical 1
  ifelse Sewer-calibration-run? = true [
    set Storm-type "5-year"
  ]
  [
    set Storm-type "100-year"
  ]
  set storm-hours 24
  set percent-impervious 60
  set Vary-landscape? false
  set Slope-percent 0.25
  set %-landscape-swale 5
  set GI-concentrated-near-outlet 30
  set %-impermeable-rain-barrels 5
  set %-impermeable-green-roof 5
  set Green-Alleys? true
  set activate-sewers? true
  set curbs? true
  set activate-outlet? true
  set GI-Budget 1000
  set Type-to-Place "Swales"
  set GI-placement "Imported" ;;"User selected" "Sliders" "Imported"
  set Outlet-control-height 6
  
  set-patch-size 15
  if Neighborhood-type = "Dense residential (e.g. Wicker Park)" or Neighborhood-type = "Bungalow belt" or Neighborhood-type = "Humboldt Park" or Neighborhood-type = "Albany Park" or Neighborhood-type = "Albany Park - Import" or Neighborhood-type = "Random"[
    set world-dimensions-vertical ( ( Blocks-vertical * 24 ) + 2 )
    set world-dimensions-horizontal ( ( Blocks-vertical * 24 ) + 2 )
    set road-spacing-vertical 24
    set road-spacing-horizontal 12
  ]
  if Neighborhood-type = "Palos Heights" or Neighborhood-type = "Palos Heights - Import" [
    set world-dimensions-vertical ( ( Blocks-vertical * 21 ) + 1 )
    set world-dimensions-horizontal ( ( Blocks-vertical * 18 ) + 1 )
    set road-spacing-vertical 21
    set road-spacing-horizontal 9
  ]
  if Neighborhood-type = "Blue Island" or Neighborhood-type = "Blue Island - Import"[
    set world-dimensions-vertical ( ( Blocks-vertical * 20 ) + 1 ) ;; 17 lots vertical
    set world-dimensions-horizontal ( ( Blocks-vertical * 19 ) + 2 )
    set road-spacing-vertical 20
    set road-spacing-horizontal 10
  ]
  if Neighborhood-type = "Dixmoor" or Neighborhood-type = "Dixmoor - Import"[
    set world-dimensions-vertical ( ( Blocks-vertical * 19 ) + 1 ) ;; 17 lots vertical
    set world-dimensions-horizontal ( ( Blocks-vertical * 19 ) + 2 )
    set road-spacing-vertical 19
    set road-spacing-horizontal 10
  ]
  
  ;; Set the size of the landscape to match the dimensions on the world-dimensions slider
  resize-world 0 ( world-dimensions-horizontal - 1 ) 0 ( world-dimensions-vertical - 1 )
    
  set cubic-m-to-cubic-ft 35.3147
  set GI-Budget-dollars GI-Budget * 1000 ;; slider was in thousands of dollars; this converts to dollars
  set Flood-definition-mm Flood-definition * 25.4 ;; convert inches to mm
  set Extreme-flood-definition-mm Extreme-flood-definition * 25.4 ;; convert to mm
  set Outlet-control-height-mm Outlet-control-height * 25.4 ;; convert inches to mm
  
  set time-to-lesser-flood 0
  set time-to-greater-flood 0
  set time-duration-lesser-flood 0
  set time-duration-greater-flood 0
  set time-to-dry 0

;; setting some variables that are more mechanistic in nature as they control other processes.
;  set decimal-places 20 ;; when the precision primitive is used, it will record variables to only 20 decinal places.
;  set Repetitions-per-Iteration 3 ;; means 20 second subroutines
  set cell-dimension 10000 ; in mm. equal to 10m
  set storm-length ( storm-hours * 60 ) ;; converting the storm length from hours to minutes
  set stop-tick ( storm-length + 1440 ) ;; setting the maximum length of a simulation is the surface water does not dry first. max length is 2 days beyond the end of a storm.
  set conversion-multiplier ( ( cell-dimension ^ 2 ) / 1000000000 ) ;; used to convert from cell-specific units to m^3.
  
  ;; set the storm-type using code below that considers the length and statistical frequency of a storm to determine total rainfall
  setup-storm-type
  ;; setting some process rates at daily rates
  set daily-evaporation-rate 3.5625 ;; mm per day
  set daily-evapotranspiration-rate 1.66 ;; mm per day
  ;; sets the rates that will actually be used by the code when opering in each subroutine, i.e. mm per 15 seconds
  set rainfall-rate ( ( total-rainfall  ) / ( storm-hours * 60 * Repetitions-per-Iteration ) )
  set evapo-rate (  ( ( ( daily-evaporation-rate  ) / ( 24 * 60 ) ) / Repetitions-per-Iteration ) )
  set evapotrans-rate (  ( ( ( daily-evapotranspiration-rate  ) / ( 24 * 60 ) ) / Repetitions-per-Iteration )  )  

  set inflow-limit-reached? false
  set potential-rain rainfall-rate * Repetitions-per-Iteration * storm-length * conversion-multiplier * ( count patches )

  ;; Setup costs of GI
  setup-costs

  ;; Creates land cover for landscape
  setup-land-cover
  ask patches [
    ;; Assume that starting conditions include no standing aboveground water 
    set water-column 0
    set flooded? false
  ]

  ;; setup the sewer locations
  setup-sewers
  
  ;; setup permeable paver drain info
  setup-paver-underdrain

  ;; setup soil conditions for infiltration
  setup-green-ampt
  
  ;; setup the icons that show green infrastructure, sewers, roads, and the outlet
  setup-agents
  
  
  setup-outlet-values
  
  if record-movie? = true [
    ;let movietitle word date-and-time ".mov"
     movie-start (word (word "results" (remove "-" (remove " " (remove "." (remove ":" date-and-time)))) ".mov"))
  ]
  
  reset-ticks
end

;; Sets amount of rain that will fall during a storm with a given statistical frequency and a given duration
to setup-storm-type
  
  if storm-type = "2-year" [
    if storm-hours = 1 [ set total-rainfall 33.9852 ]
    if storm-hours = 2 [ set total-rainfall 39.4716 ]
    if storm-hours = 3 [ set total-rainfall 42.3672]
    if storm-hours = 4 [ set total-rainfall 44.323]
    if storm-hours = 5 [ set total-rainfall 45.7708]
    if storm-hours = 6 [ set total-rainfall 46.9392]
    if storm-hours = 7 [ set total-rainfall 47.9044]
    if storm-hours = 8 [ set total-rainfall 48.7172]
    if storm-hours = 9 [ set total-rainfall 49.4538]
    if storm-hours = 10 [ set total-rainfall 50.0888]
    if storm-hours = 11 [ set total-rainfall 50.673]
    if storm-hours = 12 [ set total-rainfall 51.2064]
    if storm-hours = 13 [ set total-rainfall 51.689]
    if storm-hours = 14 [ set total-rainfall 52.1462]
    if storm-hours = 15 [ set total-rainfall 52.578]
    if storm-hours = 16 [ set total-rainfall 52.959]
    if storm-hours = 17 [ set total-rainfall 53.34]
    if storm-hours = 18 [ set total-rainfall 53.6702]
    if storm-hours = 19 [ set total-rainfall 54.0004]
    if storm-hours = 20 [ set total-rainfall 54.3052]
    if storm-hours = 21 [ set total-rainfall 54.61]
    if storm-hours = 22 [ set total-rainfall 54.8894]
    if storm-hours = 23 [ set total-rainfall 55.1688]
    if storm-hours = 24 [ set total-rainfall 55.4228]
  ]
  
  if storm-type = "5-year"[
    if storm-hours = 1 [ set total-rainfall 44.958]
    if storm-hours = 2 [ set total-rainfall 53.5686]
    if storm-hours = 3 [ set total-rainfall 58.0644]
    if storm-hours = 4 [ set total-rainfall 61.0616]
    if storm-hours = 5 [ set total-rainfall 63.2968]
    if storm-hours = 6 [ set total-rainfall 65.0494]
    if storm-hours = 7 [ set total-rainfall 66.5226]
    if storm-hours = 8 [ set total-rainfall 67.7672]
    if storm-hours = 9 [ set total-rainfall 68.834]
    if storm-hours = 10 [ set total-rainfall 69.7992]
    if storm-hours = 11 [ set total-rainfall 70.6882]
    if storm-hours = 12 [ set total-rainfall 71.3232]
    if storm-hours = 13 [ set total-rainfall 72.3138]
    if storm-hours = 14 [ set total-rainfall 72.898]
    if storm-hours = 15 [ set total-rainfall 73.533]
    if storm-hours = 16 [ set total-rainfall 73.9648]
    if storm-hours = 17 [ set total-rainfall 74.7014]
    if storm-hours = 18 [ set total-rainfall 75.057]
    if storm-hours = 19 [ set total-rainfall 75.7682]
    if storm-hours = 20 [ set total-rainfall 76.2]
    if storm-hours = 21 [ set total-rainfall 76.2762]
    if storm-hours = 22 [ set total-rainfall 77.1144]
    if storm-hours = 23 [ set total-rainfall 77.1144]
    if storm-hours = 24 [ set total-rainfall 77.6224]
  ]
  
  if storm-type = "10-year" [
    if storm-hours = 1 [ set total-rainfall 51.8414]
    if storm-hours = 2 [ set total-rainfall 62.5856]
    if storm-hours = 3 [ set total-rainfall 68.5546]
    if storm-hours = 4 [ set total-rainfall 72.6948]
    if storm-hours = 5 [ set total-rainfall 75.8698]
    if storm-hours = 6 [ set total-rainfall 78.486]
    if storm-hours = 7 [ set total-rainfall 80.6958]
    if storm-hours = 8 [ set total-rainfall 82.6008]
    if storm-hours = 9 [ set total-rainfall 84.3026]
    if storm-hours = 10 [ set total-rainfall 85.8266]
    if storm-hours = 11 [ set total-rainfall 87.1728]
    if storm-hours = 12 [ set total-rainfall 88.4936]
    if storm-hours = 13 [ set total-rainfall 89.8144]
    if storm-hours = 14 [ set total-rainfall 90.678]
    if storm-hours = 15 [ set total-rainfall 91.821]
    if storm-hours = 16 [ set total-rainfall 92.6592]
    if storm-hours = 17 [ set total-rainfall 93.7006]
    if storm-hours = 18 [ set total-rainfall 94.6404]
    if storm-hours = 19 [ set total-rainfall 95.5548]
    if storm-hours = 20 [ set total-rainfall 96.012]
    if storm-hours = 21 [ set total-rainfall 97.0788]
    if storm-hours = 22 [ set total-rainfall 97.79]
    if storm-hours = 23 [ set total-rainfall 98.1456]
    if storm-hours = 24 [ set total-rainfall 98.9838]
  ]
  
  if storm-type = "25-year" [
    if storm-hours = 1 [ set total-rainfall 60.5536]
    if storm-hours = 2 [ set total-rainfall 73.1012]
    if storm-hours = 3 [ set total-rainfall 80.0608]
    if storm-hours = 4 [ set total-rainfall 84.9122]
    if storm-hours = 5 [ set total-rainfall 88.6206]
    if storm-hours = 6 [ set total-rainfall 91.6686]
    if storm-hours = 7 [ set total-rainfall 94.234]
    if storm-hours = 8 [ set total-rainfall 96.4692]
    if storm-hours = 9 [ set total-rainfall 98.4504]
    if storm-hours = 10 [ set total-rainfall 100.2284]
    if storm-hours = 11 [ set total-rainfall 101.854]
    if storm-hours = 12 [ set total-rainfall 103.3526]
    if storm-hours = 13 [ set total-rainfall 104.7242]
    if storm-hours = 14 [ set total-rainfall 106.0196]
    if storm-hours = 15 [ set total-rainfall 107.2134]
    if storm-hours = 16 [ set total-rainfall 108.3564]
    if storm-hours = 17 [ set total-rainfall 109.4232]
    if storm-hours = 18 [ set total-rainfall 110.4392]
    if storm-hours = 19 [ set total-rainfall 111.4044]
    if storm-hours = 20 [ set total-rainfall 112.3188]
    if storm-hours = 21 [ set total-rainfall 113.1824]
    if storm-hours = 22 [ set total-rainfall 114.0206]
    if storm-hours = 23 [ set total-rainfall 114.8334]
    if storm-hours = 24 [ set total-rainfall 115.6208]
  ]
  
  if storm-type = "100-year" [
    if storm-hours = 1 [ set total-rainfall 75.9968]
    if storm-hours = 2 [ set total-rainfall 91.7702]
    if storm-hours = 3 [ set total-rainfall 100.5078]
    if storm-hours = 4 [ set total-rainfall 106.553]
    if storm-hours = 5 [ set total-rainfall 111.2266]
    if storm-hours = 6 [ set total-rainfall 115.0366]
    if storm-hours = 7 [ set total-rainfall 118.2878]
    if storm-hours = 8 [ set total-rainfall 121.0818]
    if storm-hours = 9 [ set total-rainfall 123.571]
    if storm-hours = 10 [ set total-rainfall 125.8062]
    if storm-hours = 11 [ set total-rainfall 127.8382]
    if storm-hours = 12 [ set total-rainfall 129.7178]
    if storm-hours = 13 [ set total-rainfall 131.445]
    if storm-hours = 14 [ set total-rainfall 133.0706]
    if storm-hours = 15 [ set total-rainfall 134.5692]
    if storm-hours = 16 [ set total-rainfall 135.9916]
    if storm-hours = 17 [ set total-rainfall 137.3378]
    if storm-hours = 18 [ set total-rainfall 138.6078]
    if storm-hours = 19 [ set total-rainfall 139.8016]
    if storm-hours = 20 [ set total-rainfall 140.97]
    if storm-hours = 21 [ set total-rainfall 142.0622]
    if storm-hours = 22 [ set total-rainfall 143.129]
    if storm-hours = 23 [ set total-rainfall 144.145]
    if storm-hours = 24 [ set total-rainfall 145.1102]
  ]
  
end

to setup-costs
  ;; Costs
  ;; All costs are in dollars
  ;; For rain barrels, the cost is for one rain barrel. For all other types, the cost is calculated 
  set cost-a-permeable-paver 5500; $5,447 rounded
  set cost-a-green-roof 125000 ;; $123,553 rounded
  set cost-a-swale 21000 ;; $21,132 rounded
  set cost-a-rain-barrel 125
  set maintenance-a-paver 250
  set maintenance-a-swale 200
  set maintenance-a-roof 900
  set maintenance-a-barrel 0
  if GI-placement = "User selected" [
    set remaining-budget GI-Budget-dollars
    set formatted-remaining-budget ( commify remaining-budget )
    set formatted-remaining-budget ( word "$" formatted-remaining-budget )
  ]
end

;; Defines landcover for all cells, sets up the cover specific variables
to setup-land-cover
  
  setup-elevation

  ;; sets up roads
  setup-roads
  
  ;; Create a single outflow cell in the lower left corner of the landscape
  ask patch 0 0 [
    set outflow? true
  ]
  if Upstream-bad-neighbor? [
    ask patch max-pxcor max-pycor [
      set inflow? true
    ]
  ]
  ;; sets all cells to cover-type 2 first, which is the impermeable surface
  ask patches [
    set cover-type 2
    set gi? false
  ] ;; impermeable
  
  setup-neighborhood-type
  
  ;; determining which set of rules to use for GI placement based on the GI-Location chooser
  ;; the options can be divided into two basic classes.
  ;; the first class:
  
  
  Setup-GI

  
  assign-cell-data
  
  ;; Now creating lists of patches sorted by elevation (small to large) for the overall landscape and of each patches neighbors.
  set Landscape-Elevation-list sort-on [ elevation ] patches
  ;  show Landscape-Elevation-list
  ask patches [
    set Neighbor-Elevation-list sort-on [ elevation ] neighbors
    ;  print ""
    ;  show Neighbor-Elevation-list
  ]
  
end

to setup-elevation
  ;; create an underlying slope in the base elevation of cells that slopes downwards to the lower left (southwest) corner of the landscape
  ask patches [
    ;; Create an elevation multiplier, which is the distance from the outlet to create a smooth slope
    let elevation-multiplier distance patch 0 0
    ;; adjusts the elevation of all cells based upon the slope-percent, set by a slider, and the elevation-multiplier.    
    set elevation 327 + ( elevation-multiplier * ( Slope-percent / 100 ) * cell-dimension  ) ;; 350 as base because 127 subtracted for roads and 200 subtracted for swales
    set outflow? false
    set flooded? false
    set ever-flooded? false
    set extreme-flooded? false
    set ever-extreme-flooded? false
  ]
  ;; Determining the maximum elevation. This is used by the model in some of the visualization options.
  set max-elevation max [ elevation ] of patches
  if Vary-landscape? = true [
    let height-differential ( [ elevation ] of patch 0 1 ) - ( [ elevation ] of patch 0 0 )
    ask patches [
      let elevation-randomizer random-normal 0 ( height-differential / 2 )
      set elevation elevation + elevation-randomizer + 200
    ] 
  ]
end

to setup-roads
  
  ;; Check if each cell is a road, based upon the road spacing slider
  ifelse Neighborhood-type = "Dense residential (e.g. Wicker Park)" or Neighborhood-type = "Bungalow belt" or Neighborhood-type = "Humboldt Park" or Neighborhood-type = "Albany Park"or Neighborhood-type = "Albany Park - Import"  or Neighborhood-type = "Random"[
    ;; Alleys and streets 2 wide 
    ;; Setting up roads
    ask patches [
      ifelse  pxcor mod ( road-spacing-horizontal ) = 0 or pycor mod (   road-spacing-vertical ) = 0  or ( pxcor - 1 ) mod ( road-spacing-horizontal ) = 0 or  ( pycor - 1 ) mod (   road-spacing-vertical ) = 0 [
        ;; Road cell
        set road? true
        if curbs? = true [ set elevation elevation - 127 ] ;; 127 is 5" in mm
        set pcolor grey
      ]
      ;; Not road
      [ set road? false ]   
      ;; Setting up alleys
      ifelse ( pxcor + 5 ) mod (   road-spacing-horizontal )  = 0 or ( pxcor + 5 ) mod (   road-spacing-horizontal ) = .5 [
        ifelse road? = false [
          ;; Alley
          set alley? true
          set pcolor 4       
        ]
        [ ;; Not alley
          set alley? false
        ]
      ]
      [
        set alley? false
        set pcolor grey
      ]
    ]
  ]
  [
    ;; Streets 1 wide
    if Neighborhood-type = "Blue Island" or Neighborhood-type = "Blue Island - Import"[
      ask patches [
        ifelse  pxcor mod ( road-spacing-horizontal ) = 0 or pycor mod (   road-spacing-vertical ) = 0   [
          ;; Road cell
          set road? true
          if curbs? = true [ set elevation elevation - 127 ]
          set pcolor grey
        ]
        ;; Not road
        [ set road? false ]
        ;; Alleys
        ifelse ( pxcor + 5 ) mod (   road-spacing-horizontal )  = 0 or ( pxcor + 5 ) mod (   road-spacing-horizontal ) = .5 [
          ifelse road? = false [
            ;; Alley
            set alley? true
            set pcolor 4       
          ]
          [ ;; Not alley
            set alley? false
          ]
        ]
        [
          set alley? false
          set pcolor grey
        ]
      ]
    ]
    if Neighborhood-type = "Dixmoor" or Neighborhood-type = "Dixmoor - Import" [
      ask patches [
        ifelse  pxcor mod ( road-spacing-horizontal ) = 0 or pycor mod (   road-spacing-vertical ) = 0   [
          ;; Road cell
          set road? true
          if curbs? = true [ set elevation elevation - 127 ]
          set pcolor grey
        ]
        ;; Not road
        [ set road? false ]
        ;; Alleys
        ifelse ( pxcor + 5 ) mod (   road-spacing-horizontal )  = 0 or ( pxcor + 5 ) mod (   road-spacing-horizontal ) = .5 [
          ifelse road? = false [
            ;; Alley
            set alley? true
            set pcolor 4       
          ]
          [ ;; Not alley
            set alley? false
          ]
        ]
        [
          set alley? false
          set pcolor grey
        ]
      ]
    ]
    if Neighborhood-type = "Palos Heights" or Neighborhood-type = "Palos Heights - Import" [
      ask patches [
        ifelse  pxcor mod ( road-spacing-horizontal ) = 0 or pycor mod (   road-spacing-vertical ) = 0   [
          ;; Road cell
          set road? true
          if curbs? = true [ set elevation elevation - 127 ]
          set pcolor grey
        ]
        ;; Not road
        [ set road? false ]
        ;; No Alleys
        set alley? false
        set pcolor grey
        
      ]
    ]
  ]
   
  set list-non-roads-or-alleys patches with [ alley? = false and road? = false ]
end

to setup-neighborhood-type
  if Neighborhood-type = "Dense residential (e.g. Wicker Park)" or Neighborhood-type = "Bungalow belt" or Neighborhood-type = "Humboldt Park" or Neighborhood-type = "Albany Park" [
    ask patches with [ road? = false ] [
      set patch-marker pxcor mod (   road-spacing-horizontal )
    ]
    
    let lot-counter 1
    ;; 2 and 8 are starts of lots
    ;; 4 east and 3 east
    ask patches with [ patch-marker = 2 ] [
      set lot-number lot-counter
      ask patch-at 1 0 [ set lot-number lot-counter ]
      ask patch-at 2 0 [ set lot-number lot-counter ]
      ask patch-at 3 0 [ set lot-number lot-counter ]
      ask patch-at 4 0 [ set lot-number lot-counter ]
      set lot-counter lot-counter + 1
    ]
    ask patches with [ patch-marker = 11 ] [
      set lot-number lot-counter
      ask patch-at -1 0 [ set lot-number lot-counter ]
      ask patch-at -2 0 [ set lot-number lot-counter ]
      ask patch-at -3 0 [ set lot-number lot-counter ]
      set lot-counter lot-counter + 1
    ]
    let max-lot max [ lot-number ] of patches
    ; show max-lot
    
        
    if Neighborhood-type = "Albany Park" [
      let lot-counter2 1
      
      repeat max-lot [
        let chance-open random-float 1
        ifelse chance-open >= .98 [
          ;;; entire lot permeable
          ask patches with [ lot-number = lot-counter2 ] [
            set cover-type 3
          ]
          
        ]
        [
          ;;; some portion of lot paved
          let chance-front-yard random-float 1
          if chance-front-yard > 0 [
            ;;; patch bordering road will be permeable
            ask patches with [ lot-number = lot-counter2 and ( patch-marker = 2 or patch-marker = 11 ) ] [
              set cover-type 3
            ]
          ]
          let chance-back-yard random-float 1
          if chance-back-yard > .16 [
            ;;; there will be a permeable lawn of some kind, but first, check for carriage house
            let chance-carriage-house random-float 1
            ifelse chance-carriage-house > .068 [
              ;; there is carraige house, so the second to last cell 
              ask patches with [ lot-number = lot-counter2 and ( patch-marker = 5 or patch-marker = 9 ) ] [
                set cover-type 3
              ]
            ]
            [
              ;; no carriage house, so back two cells permeable
              ask patches with [ lot-number = lot-counter2 and ( patch-marker = 5 or patch-marker = 9 or patch-marker = 6 or patch-marker = 8) ] [
                set cover-type 3
              ]
            ]
          ]
        ]
        set lot-counter2 lot-counter2 + 1
      ]
    ]
    
    if Neighborhood-type = "Dense residential (e.g. Wicker Park)" [
      let lot-counter2 1
      
      repeat max-lot [
        let chance-open random-float 1
        ifelse chance-open >= .9 [
          ;;; entire lot permeable eg vacant lot
          ask patches with [ lot-number = lot-counter2 ] [
            set cover-type 3
          ]
          
        ]
        [
          ;;; some portion of lot paved
          let chance-no-front-yard random-float 1
          if chance-no-front-yard > .9 [
            ;;; patch bordering road will be permeable
            ask patches with [ lot-number = lot-counter2 and ( patch-marker = 2 or patch-marker = 11 ) ] [
              set cover-type 3
            ]
          ]
          let chance-back-yard random-float 1
          if chance-back-yard > .50 [
            ;;; there will be a permeable lawn of some kind, but first, check for carriage house
            let chance-no-carriage-house random-float 1
            ifelse chance-no-carriage-house > .1 [
              ;; there is carraige house, so the second to last cell 
              ask patches with [ lot-number = lot-counter2 and ( patch-marker = 5 or patch-marker = 9 ) ] [
                set cover-type 3
              ]
            ]
            [
              ;; no carriage house, so back two cells permeable
              ask patches with [ lot-number = lot-counter2 and ( patch-marker = 5 or patch-marker = 9 or patch-marker = 6 or patch-marker = 8) ] [
                set cover-type 3
              ]
            ]
          ]
        ]
        set lot-counter2 lot-counter2 + 1
      ]
    ]
    
    if Neighborhood-type = "Humboldt Park" [
      let lot-counter2 1
      repeat max-lot [
        let chance-open random-float 1
        ifelse chance-open >= .65 [
          ;;; entire lot permeable eg vacant lot
          ask patches with [ lot-number = lot-counter2 ] [
            set cover-type 3
          ]
          
        ]
        [
          ;;; some portion of lot paved
          let chance-no-front-yard random-float 1
          if chance-no-front-yard > .9 [
            ;;; patch bordering road will be permeable
            ask patches with [ lot-number = lot-counter2 and ( patch-marker = 2 or patch-marker = 11 ) ] [
              set cover-type 3
            ]
          ]
          let chance-back-yard random-float 1
          if chance-back-yard > .50 [
            ;;; there will be a permeable lawn of some kind, but first, check for carriage house
            let chance-no-carriage-house random-float 1
            ifelse chance-no-carriage-house > .4 [
              ;; there is carraige house, so the second to last cell 
              ask patches with [ lot-number = lot-counter2 and ( patch-marker = 5 or patch-marker = 9 ) ] [
                set cover-type 3
              ]
            ]
            [
              ;; no carriage house, so back two cells permeable
              ask patches with [ lot-number = lot-counter2 and ( patch-marker = 5 or patch-marker = 9 or patch-marker = 6 or patch-marker = 8) ] [
                set cover-type 3
              ]
            ]
          ]
        ]
        set lot-counter2 lot-counter2 + 1
      ]
    ]
    
    if Neighborhood-type = "Bungalow belt" [
      let lot-counter2 1
      
      repeat max-lot [
        let chance-open random-float 1
        ifelse chance-open >= .95 [
          ;;; entire lot permeable
          ask patches with [ lot-number = lot-counter2 ] [
            set cover-type 3
          ]
          
        ]
        [
          ;;; some portion of lot paved
          let chance-front-yard random-float 1
          if chance-front-yard > .1 [
            ;;; patch bordering road will be permeable
            ask patches with [ lot-number = lot-counter2 and ( patch-marker = 2 or patch-marker = 11 ) ] [
              set cover-type 3
            ]
          ]
          let chance-back-yard random-float 1
          if chance-back-yard > .1 [
            ;;; there will be a permeable lawn of some kind, but first, check for carriage house
            let chance-carriage-house random-float 1
            ifelse chance-carriage-house > .1 [
              ;; there is carraige house, so the second to last cell 
              ask patches with [ lot-number = lot-counter2 and ( patch-marker = 5 or patch-marker = 9 ) ] [
                set cover-type 3
              ]
            ]
            [
              ;; no carriage house, so back two cells permeable
              ask patches with [ lot-number = lot-counter2 and ( patch-marker = 5 or patch-marker = 9 or patch-marker = 6 or patch-marker = 8) ] [
                set cover-type 3
              ]
            ]
          ]
        ]
        set lot-counter2 lot-counter2 + 1
      ]
    ]
    
    
  ]
    
  if Neighborhood-type = "Palos Heights" [
    ask patches with [ road? = false ] [
      set patch-marker pxcor mod (   road-spacing-horizontal )
      set cover-type 3
;      set plabel patch-marker
    ]
        
    
    ask patches with [ road? = false ] [
      ;       or ( ( ( pxcor ) mod ( road-spacing-horizontal) ) = 0 and ( ( pycor - 11 ) mod ( road-spacing-vertical ) ) = 0 and cover-type != 1 and road? = true )
      if ( pycor ) mod road-spacing-vertical = 2
      or ( pycor ) mod road-spacing-vertical = 3
      or ( pycor ) mod road-spacing-vertical = 6
      or ( pycor ) mod road-spacing-vertical = 7
      or ( pycor ) mod road-spacing-vertical = 10
      or ( pycor ) mod road-spacing-vertical = 11
      or ( pycor ) mod road-spacing-vertical = 14
      or ( pycor ) mod road-spacing-vertical = 15
      or ( pycor ) mod road-spacing-vertical = 18
      or ( pycor ) mod road-spacing-vertical = 19
      [
        if patch-marker = 2 or patch-marker = 3 or patch-marker = 6 or patch-marker = 7 [
          let chance-house random-float 1
          if chance-house < .9 [
            set cover-type 2
          ]     
        ]
      ]
    ]
  ]
 
  ;; Random
  if Neighborhood-type = "Random" [
    set permeable-patches round ( ( ( count patches ) * ( 100 - percent-impervious ) ) / 100 )
    ask n-of permeable-patches list-non-roads-or-alleys ;; changing from impermeable to permeable
    [ set cover-type 3 ] ;; making permeable cells
  ]
  
  if Neighborhood-type = "Blue Island - Import" [
   file-open "BlueIsland.txt"
   let cover-list file-read
   ( foreach sort patches cover-list
     [ ask ?1 [
       set cover-type ?2
     ] ] )
   file-close 
  ]
  
  if Neighborhood-type = "Dixmoor - Import" [
   file-open "Dixmoor.txt"
   let cover-list file-read
   ( foreach sort patches cover-list
     [ ask ?1 [
       set cover-type ?2
     ] ] )
   file-close 
  ]
  
  if Neighborhood-type = "Albany Park - Import" [
    file-open "AlbanyPark.txt"
    let cover-list file-read
    ( foreach sort patches cover-list
      [ ask ?1 [
        set cover-type ?2
      ] ] )
    file-close 
  ]
  
  if Neighborhood-type = "Palos Heights - Import" [
    file-open "PalosHeights.txt"
    let cover-list file-read
    ( foreach sort patches cover-list
      [ ask ?1 [
        set cover-type ?2
      ] ] )
    file-close 
  ]
  
  if Neighborhood-type = "Blue Island" or Neighborhood-type = "Dixmoor" [
        ask patches with [ road? = false ] [
      set patch-marker pxcor mod (   road-spacing-horizontal )
;      set plabel patch-marker
    ]
    
    let lot-counter 1
    ;; 1 and 10 are starts of lots
    ;; 4 east and 3 west
    ask patches with [ patch-marker = 2 and all? neighbors4 [ road? = false ] ] [
      set lot-number lot-counter
      ask patch-at -1 0 [ set lot-number lot-counter ]
      ask patch-at 1 0 [ set lot-number lot-counter ]
      ask patch-at 2 0 [ set lot-number lot-counter ]
      set lot-counter lot-counter + 1
    ]
    ask patches with [ patch-marker = 8 and all? neighbors4 [ road? = false ] ] [
      set lot-number lot-counter
      ask patch-at 1 0 [ set lot-number lot-counter ]
      ask patch-at -1 0 [ set lot-number lot-counter ]
      ask patch-at -2 0 [ set lot-number lot-counter ]
      set lot-counter lot-counter + 1
    ]
    let max-lot max [ lot-number ] of patches
    let lot-counter2 1
    
;    ask patches [ set plabel lot-number ]
    
    if Neighborhood-type = "Blue Island" or Neighborhood-type = "Blue Island - Import"[
      
      ask patches with [ road? = false and alley? = false and any? neighbors4 with [ road? = true ] ] [ set cover-type 3 ]
      
      repeat max-lot [
        let chance-open random-float 1
        ifelse chance-open >= .96 [
          ;;; entire lot permeable
          ask patches with [ lot-number = lot-counter2 ] [
            set cover-type 3
          ]
          
        ]
        [
          ;;; some portion of lot paved
          let chance-front-yard random-float 1
          if chance-front-yard > 0 [
            ;;; patch bordering road will be permeable
            ask patches with [ lot-number = lot-counter2 and ( patch-marker = 1 or patch-marker = 9 ) ] [
              set cover-type 3
            ]
          ]
          let chance-back-yard random-float 1
          if chance-back-yard > .45 [
            ;;; there will be a permeable lawn of some kind, but first, check for carriage house
            let chance-carriage-house random-float 1
            ifelse chance-carriage-house > .2 [
              ;; there is carraige house, so the second to last cell 
              ask patches with [ lot-number = lot-counter2 and ( patch-marker = 3 or patch-marker = 7 ) ] [
                set cover-type 3
              ]
            ]
            [
              ;; no carriage house, so back two cells permeable
              ask patches with [ lot-number = lot-counter2 and ( patch-marker = 3 or patch-marker = 4 or patch-marker = 6 or patch-marker = 7) ] [
                set cover-type 3
              ]
            ]
          ]
        ]
        set lot-counter2 lot-counter2 + 1
      ] 
    ]
    if Neighborhood-type = "Dixmoor" or Neighborhood-type = "Dixmoor - Import" [
      ask patches with [ road? = false and alley? = false and any? neighbors4 with [ road? = true ] ] [ set cover-type 3 ]
      
      repeat max-lot [
        let chance-open random-float 1
        ifelse chance-open >= .82 [
          ;;; entire lot permeable
          ask patches with [ lot-number = lot-counter2 ] [
            set cover-type 3
          ]
          
        ]
        [
          ;;; some portion of lot paved
          let chance-front-yard random-float 1
          if chance-front-yard > 0 [
            ;;; patch bordering road will be permeable
            ask patches with [ lot-number = lot-counter2 and ( patch-marker = 1 or patch-marker = 9 ) ] [
              set cover-type 3
            ]
          ]
          let chance-back-yard random-float 1
          if chance-back-yard > .05 [
            ;;; there will be a permeable lawn of some kind, but first, check for carriage house
            let chance-carriage-house random-float 1
            ifelse chance-carriage-house > .7 [
              ;; there is carraige house, so the second to last cell 
              ask patches with [ lot-number = lot-counter2 and ( patch-marker = 3 or patch-marker = 7 ) ] [
                set cover-type 3
              ]
            ]
            [
              ;; no carriage house, so back two cells permeable
              ask patches with [ lot-number = lot-counter2 and ( patch-marker = 3 or patch-marker = 4 or patch-marker = 6 or patch-marker = 7) ] [
                set cover-type 3
              ]
            ]
          ]
        ]
        set lot-counter2 lot-counter2 + 1
      ] 
      
    ]
    
  ]
  
  ask patches with [ cover-type = 3 ] [
    ;; color permeable cells brown
    set pcolor brown
  ]
  
end


to Setup-GI

  ;;; let's use 60 gallon barrels
  ;;; 60 gallons = 227,124,707 mm ^3
  let barrel-capacity 227124707
  let conversion-to-cell-size ( barrel-capacity / cell-dimension ) / cell-dimension
  set rain-barrel-storage conversion-to-cell-size
  ;; converted to mm per unit area
  set volume-a-rain-barrel 2.27125 * conversion-multiplier ;;0.227125 ;; volume of 60 gallon rain barrel in cubic meters
  set volume-a-green-roof 25.4 * conversion-multiplier ;;2.54 ;; Volume of water that can be stored in 4 inches of soil on a green roof - assuming 1 inch (25.4 mm) of water can be stored.
  set volume-a-paver 231.618 * conversion-multiplier ;; 23.1618 ;; Volume of water that can be stored in soil of GI - based on max infill value of 231.648 mm
  set volume-a-swale 822.8 * conversion-multiplier ;; 82.28 ;; This is the 200 mm of surface storage + 622.8 mm max infil value of the engineered soil.

  set volume-a-rain-barrel-ft3 volume-a-rain-barrel * cubic-m-to-cubic-ft
  set volume-a-green-roof-ft3 volume-a-green-roof * cubic-m-to-cubic-ft
  set volume-a-paver-ft3 volume-a-paver * cubic-m-to-cubic-ft
  set volume-a-swale-ft3 volume-a-swale * cubic-m-to-cubic-ft

  
  if GI-placement = "Sliders" or GI-placement = "Imported" [
    ;; GI SETUP
    ;; rain-barrel, swale, permeable paver, green roof  
    
    if GI-placement = "Sliders" [
      let permeable-cell-count count patches with [ cover-type = 3 ]
      let impermeable-cell-count count patches with [ cover-type = 2 and road? = false and alley? = false ]
      
      
      ;; Rain barrels
      let number-rain-barrels round ( impermeable-cell-count * ( %-impermeable-rain-barrels / 100 ) )
      ;; Preventing an error so that the code does not ask for more of the number of cells than there are candidate cells that meet the siting criteria
      if count patches with [ cover-type = 2 and gi? = false and road? = false and alley? = false ] < number-rain-barrels [ set number-rain-barrels count patches with [ cover-type = 2 and gi? = false and road? = false and alley? = false ] ]
      
      ask n-of number-rain-barrels patches with [ cover-type = 2 and gi? = false and road? = false and alley? = false ] [
        setup-GI-rain-barrel
      ]
      
      
      ;; Swales
      ;; Preventing an error so that the code does not ask for more of the number of cells than there are candidate cells that meet the siting criteria
      let number-swales round ( ( count patches ) * ( %-landscape-swale / 100 )  )
      if count patches with [ cover-type = 3 ] < number-swales [ set number-swales count patches with [ cover-type = 3 ] ]
      
      let close-swales round ( number-swales * ( GI-concentrated-near-outlet / 100 ) )
      let far-swales number-swales - close-swales
      
      ;; If there are swales concentrated around the outlet aka "downstream"
      if GI-concentrated-near-outlet > 0 [ ;; Set by slider. 
                                           ;; determining the distance to the outlet cell.
        ask patches with [ cover-type = 3 ] [
          set Distance-outlet distance patch 0 0
        ]
        ;; GI cells will only be located as near as possible to the outlet
        ;; sorting by distance and then assigning them as GI until the appropriate number of cells have been created.
        foreach sort-by [[Distance-outlet] of ?1 < [Distance-outlet] of ?2] patches with [ cover-type = 3 and gi? = false ] [
          ask ? [ if count patches with [ type-of-GI = "swale" ] < close-swales [
            setup-GI-swale
          ] ]
        ]
      ]
      
      ;;; Now for swales randomly distributed
      set far-swales far-swales + ( close-swales - ( count patches with [ type-of-GI = "swale" ] ) ) ;;; adjusting the number of far cells in case there were not enough cells bordering roads to be swales
      ask n-of far-swales patches with [ cover-type = 3 and gi? = false ] [
        setup-GI-swale
      ]
      
      
      ;; Green roofs
      let number-greenroofs round ( impermeable-cell-count * ( %-impermeable-green-roof / 100 ) )
      ;; Preventing an error so that the code does not ask for more of the number of cells than there are candidate cells that meet the siting criteria
      if count patches with [ cover-type = 2 and gi? = false and road? = false and alley? = false ] < number-greenroofs [ set number-greenroofs count patches with [ cover-type = 2 and gi? = false and road? = false and alley? = false ] ]
      ask n-of number-greenroofs patches with [ cover-type = 2 and gi? = false and road? = false and alley? = false ] [
        setup-GI-green-roof
      ]
      
      
      ;; Permeable pavers
      if Green-Alleys? = true [
        ask patches with [ alley? = true and gi? = false ] [
          setup-GI-permeable-paver
        ]
      ]
    ]
    
    if GI-placement = "Imported" [
      ;; 0 = swale, 1 = rain barrel, 2 = green roof 3 = permeable alley
      file-open "results.txt"
      let GI-list file-read
      file-close
      
      ;; reads in studyID and runID
      set studyID item 0 GI-list
      set runID item 1 GI-list
      
      set GI-list but-first GI-list
      set GI-list but-first GI-list
      
      let number-imported-GI ( length GI-list ) / 3
      let GI-counter-here 0
      repeat number-imported-GI [
        let pxcor-GI ( item ( ( GI-counter-here * 3 ) + 1 ) GI-list )
        let pycor-GI ( item ( ( GI-counter-here * 3 ) + 2 ) GI-list )
        ask patch pxcor-GI pycor-GI [
          let GI-type-here ( item ( GI-counter-here * 3 ) GI-list )
          ;; 0 Swale
          if GI-type-here = 0 and cover-type = 3 [
            setup-GI-swale
          ]
          ;; 1 Rain barrel
          if GI-type-here = 1 and cover-type = 2 and road? = false and alley? = false [
            setup-GI-rain-barrel
          ]
          ;; 2 Green roof
          if GI-type-here = 2 and cover-type = 2 and road? = false and alley? = false [
            setup-GI-green-roof
          ]
          ;; 3 permeable paver
          if GI-type-here = 3 and cover-type = 2 and road? = false and alley? = true [
            setup-GI-permeable-paver
          ]
        ]
        set GI-counter-here GI-counter-here + 1
      ]
            
    ]
    
    let total-cost-permeable-pavers cost-a-permeable-paver * ( count patches with [ type-of-GI = "permeable paver" ] )
    let total-cost-green-roofs cost-a-green-roof * ( count patches with [ type-of-GI = "green roof" ] )
    let total-cost-swales cost-a-swale * ( count patches with [ type-of-GI = "swale" ] )
    let total-cost-rain-barrels cost-a-rain-barrel * ( count patches with [ type-of-GI = "rain-barrel" ] )
    
    set Cost-install-private-GI total-cost-green-roofs + total-cost-swales + total-cost-rain-barrels
    set Cost-install-public-GI total-cost-permeable-pavers
    set Cost-total-install Cost-install-private-GI + Cost-install-public-GI
    
    set formatted-Cost-of-GI ( commify Cost-total-install )
    set formatted-Cost-of-GI ( word "$" formatted-Cost-of-GI )
    
    let maintenance-pavers maintenance-a-paver * ( count patches with [ type-of-GI = "permeable paver" ] )
    let maintenance-rooofs maintenance-a-roof * ( count patches with [ type-of-GI = "green roof" ] )
    let maintenance-swales maintenance-a-swale * ( count patches with [ type-of-GI = "swale" ] )
    let maintenance-barrels maintenance-a-barrel * ( count patches with [ type-of-GI = "rain-barrel" ] )
    set Cost-private-maintenance maintenance-rooofs + maintenance-swales + maintenance-barrels
    set Cost-public-maintenance maintenance-pavers
    set Cost-total-maintenance Cost-private-maintenance + Cost-public-maintenance
    set formatted-cost-total-maintenance ( commify Cost-total-maintenance )
    set formatted-cost-total-maintenance ( word "$" formatted-cost-total-maintenance )
    
    set volume-rain-barrels ( count patches with [ type-of-GI = "rain-barrel" ] ) * volume-a-rain-barrel
    set volume-green-roofs ( count patches with [ type-of-GI = "green roof" ] ) * volume-a-green-roof
    set volume-green-alleys ( count patches with [ type-of-GI = "permeable paver" ] ) * volume-a-paver
    set volume-swales ( count patches with [ type-of-GI = "swale" ] ) * volume-a-swale
    set volume-total-GI volume-rain-barrels + volume-green-roofs + volume-green-alleys + volume-swales
    
    set volume-rain-barrels-ft3 volume-rain-barrels * cubic-m-to-cubic-ft
    set volume-green-roofs-ft3 volume-green-roofs * cubic-m-to-cubic-ft
    set volume-green-alleys-ft3 volume-green-alleys * cubic-m-to-cubic-ft
    set volume-swales-ft3 volume-swales * cubic-m-to-cubic-ft
    set volume-total-GI-ft3 volume-total-GI * cubic-m-to-cubic-ft

;    let reverse-cost Cost-of-GI
;    set formatted-Cost-of-GI (word 
;    set time ( word "Day " day ", " hour ":" minute )
;     substring string position1 position2 
  ]
  
end
  
to-report commify [ n ] ;;; taken from http://groups.yahoo.com/neo/groups/netlogo-users/conversations/topics/2187
let str word "" n ;; ensure n is a string

;; if it's a float, only commify the integer portion
if member? "." str [
report word
commify substring str 0 position "." str
substring str position "." str ( length str ) ]

;; if it's less than length three, don't do anything
if length str <= 3 [
report str ]

;; otherwise, add a comma and commify everything
;; to the left of it
report ( word
( commify substring str 0 ( length str - 3 ) )
","
substring str ( length str - 3 ) length str )
end

to setup-GI-rain-barrel    
  set gi? true
  set type-of-GI "rain-barrel"
  sprout-rain-barrels 1 [
    set shape "barrel"
    set color 1
    set size .8
  ]
  set max-extra-GI-storage rain-barrel-storage ;; Max water the rain barrel can have in it
  set extra-GI-storage max-extra-GI-storage * ( Starting-fullness-GI-extra-storage / 100 ) ;; How much water is in the barrel at the start
end

to setup-GI-green-roof
  set gi? true
  set type-of-GI "green roof"
  sprout-green-roofs 1 [
    set shape "roof"
    set color lime
    set size .8
  ]
  set max-extra-GI-storage 25.4 ;;; 1 inch in mm. based on extensive green roof with 4" soil that can absorb 1" water. http://www1.eere.energy.gov/femp/pdfs/fta_green_roofs.pdf
  set extra-GI-storage max-extra-GI-storage * ( Starting-fullness-GI-extra-storage / 100 )
end

to setup-GI-permeable-paver
  set gi? true
  set type-of-GI "permeable paver"
  sprout-permeable-pavers 1 [
    set shape "paver"
    set color [ pcolor ] of myself
    set size .9
  ]
  if curbs? = true [ set elevation elevation - 63.5 ] ;; 2.5"
  
  ;;; values set according to Zhang MIT thesis for permeable pavers on a bedding and subbase of sand
  set capillary-suction 90 
  set initial-moisture-deficit .38 
  set saturated-hydraulic-conductivity (  ( (  160.2 / 60 ) / Repetitions-per-Iteration )  )
  
  set storage-capacity 0
  set patch-flooded-level ( storage-capacity + Flood-definition-mm )
  set extreme-patch-flooded-level ( storage-capacity + Extreme-flood-definition-mm )
  set max-extra-GI-storage 0
  set extra-GI-storage 0
end

to setup-GI-swale
  set gi? true
  set type-of-GI "swale"
  sprout-swales 1 [
    set shape "swale"
    set color brown
    set size .8
  ]
  ;; Highly infiltratable engineered soil
  set capillary-suction 49.5 
  set initial-moisture-deficit .346 
  set saturated-hydraulic-conductivity (  ( (  235.6 / 60 ) / Repetitions-per-Iteration )  )
  
  set storage-capacity 200 ;;;; 200mm or .2 m
  set patch-flooded-level ( storage-capacity + Flood-definition-mm )
  set extreme-patch-flooded-level ( storage-capacity + Extreme-flood-definition-mm )

  ;; If next to road and swales toggled, then lower the swale to simulate a curb cut.
  if any? neighbors with [ road? = true ] and curbs? = true 
    [ 
      set elevation elevation - 127
    ]
  let min-neighbor-elevation elevation
  if any? neighbors with [ gi? = false ] [ set min-neighbor-elevation min [ elevation ] of neighbors with [ gi? = false ] ]
  ifelse min-neighbor-elevation < elevation [
    set elevation min-neighbor-elevation - storage-capacity
  ]
  [
    set elevation elevation - storage-capacity
  ]
  set sum-storage-capacity sum-storage-capacity + storage-capacity
end

to assign-cell-data
  ;; Set storage capacity, soil characteristics, and elevation of land covers
  ask patches [
    
    ;; Impermeable surfaces - type 2
    if cover-type = 2 [
      if type-of-GI != "permeable paver" [ ;; Exclude permeable pavers
                                           ;; No infiltration
        set capillary-suction 0
        set initial-moisture-deficit 0
        set saturated-hydraulic-conductivity 0
        
        set storage-capacity 0
        set patch-flooded-level ( storage-capacity + Flood-definition-mm )
        set extreme-patch-flooded-level ( storage-capacity + Extreme-flood-definition-mm )
        if GI? = false [ ;; This excludes rain barrels and green roofs
          set max-extra-GI-storage 0
          set extra-GI-storage 0
        ]
      ]
    ]
    
    ;; Permeable ground - type 3
    if cover-type = 3 [
      if GI? = false [ ;; Excludes swales
                       ;;; Silty Clay Loam
        set capillary-suction 273
        set initial-moisture-deficit .105
        set saturated-hydraulic-conductivity (  ( ( 2 / 60 ) / Repetitions-per-Iteration )  )
        
        set storage-capacity 0
        set patch-flooded-level ( storage-capacity + Flood-definition-mm )
        set extreme-patch-flooded-level ( storage-capacity + Extreme-flood-definition-mm )
      ]
    ]
  ]
  
end


;; Calculate values for infiltration, which will not change between iterations.  Infiltration is calculated using the Green-Ampt Equation.
to setup-green-ampt
  
  ;; Designate cells that are green infrastructure (cover-type 1) and permeable cover (cover-type 3) as capable of infiltrating water and setup infiltration variables
  ask patches with [ initial-moisture-deficit > 0 ] [
    
    ifelse type-of-GI != "permeable paver"
    [ set base-max-wet-depth 2000 ] ;; depth to bedrock for permeable cells or swales
    [ set base-max-wet-depth 609.6 ] ;; 2 feet depth of engineered soil in permeable pavers
    
    ;; max-wet-depth is depth of subsurface water table or bedrock.  It is set via a slider.  Reduces this value by depth of storage capacity to create level bottom to water column 
    set max-wet-depth ( base-max-wet-depth - storage-capacity )
    ;; calculate the maximum amount of water that can infiltrate, using equation from Albrecht and Cartwright 1989
    set max-infil-value ( max-wet-depth * initial-moisture-deficit )
    
    ;; cumulative-infiltration-amount, the amount of water that has infiltrated so far, is set to zero (dry).  
    ;; The soil is not completely dry since initial-moisture-deficit, set from a table, takes into account existing water in the soil

    ; but now, not assuming it is dry but instead have it set by a slider
    set cumulative-infiltration-amount max-infil-value * Starting-soil-saturation
    
    
    
  ]
  
  set sum-infil-capacity ( sum [ max-infil-value ] of patches with [ type-of-GI = "swale" ] )
  
end

;; Create cells with sewer intakes and set the rate at which they drain water from the landscape
to setup-sewers
  
  ;; define which patches have sewers intakes based upon the sewer-spacing variable (set via slider).  
  ;; Storm sewers are created only on cells that are both impermeable and roads.  This redundancy makes it easier to define different rules for sewer intake placement.
  ;; with the complicated code that follows, they alternate the side of the road on which they are
  if Neighborhood-type = "Dense residential (e.g. Wicker Park)" or Neighborhood-type = "Bungalow belt" or Neighborhood-type = "Humboldt Park" or Neighborhood-type = "Albany Park" or Neighborhood-type = "Albany Park - Import" or Neighborhood-type = "Random"[
    ask patches [
      ifelse ( ( ( pxcor - 1 ) mod ( 12) ) = 0 and ( ( pycor - 1 ) mod ( 12 ) ) = 0 and cover-type != 1 and road? = true )
      or ( ( ( pxcor ) mod ( 12) ) = 0 and ( ( pycor - 7 ) mod ( 12 ) ) = 0 and cover-type != 1 and road? = true )
      or ( ( ( pxcor - 7 ) mod ( 12) ) = 0 and ( ( pycor ) mod ( 12 ) ) = 0 and cover-type != 1 and road? = true )
      [
        set sewers? true
      ]
      [ set sewers? false ]
    ]
  ]
  
  if Neighborhood-type = "Palos Heights" or Neighborhood-type = "Palos Heights - Import" [
    ask patches [
      ifelse ( ( ( pxcor ) mod ( road-spacing-horizontal  ) ) = 0 and ( ( pycor ) mod ( road-spacing-vertical  ) ) = 0 and cover-type != 1 and road? = true ) ;; road intersections
      or ( ( ( pxcor - 5 ) mod ( road-spacing-horizontal  ) ) = 0 and ( ( pycor ) mod ( road-spacing-vertical  ) ) = 0 and cover-type != 1 and road? = true ) ;; road intersections
      or ( ( ( pxcor ) mod ( road-spacing-horizontal) ) = 0 and ( ( pycor - 6 ) mod ( road-spacing-vertical ) ) = 0 and cover-type != 1 and road? = true )
      or ( ( ( pxcor ) mod ( road-spacing-horizontal) ) = 0 and ( ( pycor - 11 ) mod ( road-spacing-vertical ) ) = 0 and cover-type != 1 and road? = true )
      or ( ( ( pxcor ) mod ( road-spacing-horizontal) ) = 0 and ( ( pycor - 16 ) mod ( road-spacing-vertical ) ) = 0 and cover-type != 1 and road? = true )
      ;      or ( ( ( pxcor ) mod ( road-spacing-horizontal) ) = 0 and ( ( pycor - 6 ) mod ( road-spacing-vertical ) ) = 0 and cover-type != 1 and road? = true )
      [
        set sewers? true
      ]
      [ set sewers? false ]
    ]
  ]
  
  if Neighborhood-type = "Blue Island" or Neighborhood-type = "Blue Island - Import"[
    ask patches [
      ifelse ( ( ( pxcor ) mod ( road-spacing-horizontal  ) ) = 0 and ( ( pycor ) mod ( road-spacing-vertical  ) ) = 0 and cover-type != 1 and road? = true ) ;; road intersections
      or ( ( ( pxcor - 5 ) mod ( road-spacing-horizontal  ) ) = 0 and ( ( pycor ) mod ( road-spacing-vertical  ) ) = 0 and cover-type != 1 and road? = true ) ;; road intersections
      or ( ( ( pxcor ) mod ( road-spacing-horizontal) ) = 0 and ( ( pycor - 7 ) mod ( road-spacing-vertical ) ) = 0 and cover-type != 1 and road? = true )
      or ( ( ( pxcor ) mod ( road-spacing-horizontal) ) = 0 and ( ( pycor - 14 ) mod ( road-spacing-vertical ) ) = 0 and cover-type != 1 and road? = true )
      ;      or ( ( ( pxcor ) mod ( road-spacing-horizontal) ) = 0 and ( ( pycor - 16 ) mod ( road-spacing-vertical ) ) = 0 and cover-type != 1 and road? = true )
      ;      or ( ( ( pxcor ) mod ( road-spacing-horizontal) ) = 0 and ( ( pycor - 6 ) mod ( road-spacing-vertical ) ) = 0 and cover-type != 1 and road? = true )
      [
        set sewers? true
      ]
      [ set sewers? false ]
    ]
  ]
  
  if Neighborhood-type = "Dixmoor" or Neighborhood-type = "Dixmoor - Import"[
    ask patches [
      ifelse ( ( ( pxcor ) mod ( road-spacing-horizontal  ) ) = 0 and ( ( pycor ) mod ( road-spacing-vertical  ) ) = 0 and cover-type != 1 and road? = true ) ;; road intersections
      or ( ( ( pxcor - 5 ) mod ( road-spacing-horizontal  ) ) = 0 and ( ( pycor ) mod ( road-spacing-vertical  ) ) = 0 and cover-type != 1 and road? = true ) ;; road intersections
      or ( ( ( pxcor ) mod ( road-spacing-horizontal) ) = 0 and ( ( pycor - 10 ) mod ( road-spacing-vertical ) ) = 0 and cover-type != 1 and road? = true )
      [
        set sewers? true
      ]
      [ set sewers? false ]
    ]
  ]
    
  ifelse Sewer-intake-regulator? = false [
    ;; No regulators
    ;; determines the maximum potential sewer intake rate.
   
   ;; This is the converted value of .6 cf/s, which assumed 50% blockage of inlets that have a rate of 1.2 cf/s unblocked
    set base-sewer-rate  10.19405
  ]
  [
    ;;; Means ther are flow regulators, so rate is a lower fixed value equivilant to .15 cf/s
    
    set base-sewer-rate 2.548518 
  ]
  ;; determining the capacity of the sewer system
  ;; sets the amount of rain that will fall in a 5-year, 24-hour storm in order to calibrate overall sewer capacity
  ifelse Sewer-calibration-run? = false [
    ifelse Neighborhood-type = "Dixmoor - Import" or Neighborhood-type = "Palos Heights - Import" or Neighborhood-type = "Blue Island - Import" or Neighborhood-type = "Albany Park - Import" [

      if Neighborhood-type = "Albany Park - Import" [
        set benchmark-storm 56.39
      ]
      if Neighborhood-type = "Blue Island - Import" [
        set benchmark-storm 48.3
      ]
      if Neighborhood-type = "Dixmoor - Import" [
        set benchmark-storm 36.87
      ]
      if Neighborhood-type = "Palos Heights - Import" [
        set benchmark-storm 33.97
      ]
 
    ]
    
    [  
      set benchmark-storm 25 ;; in mm. see global variable section for explanation.
    ]
  ]
  [
   ;; Sewer calibration run. Setting the benchmark storm at an absurdly high amount so that the sewers never clog
    set benchmark-storm 10000 ;; 10 meters, or a biblical type flood, so the sewers will never fill.
    
  ]
  ;; multiply the above amount by the number of patches
  set max-sewer-capacity ( benchmark-storm * count patches )

  
  ;; determines the rate at which the sewer system drains (capacity renewed by a treatment plant)
  ;; adjust the rate that the sewer capacity renews (treatment rate) by the size of the landscape
  set sewer-drain-rate ( 0.0018563 * ( count patches ) )
  ;; Calculate the sewer intake rate for when the system is full (the intake rate is limited by the amount of water treated each time step)
  set full-sewer-rate ( sewer-drain-rate / ( count patches with [ sewers? = true ] ) )
  ;; the volume in cubic mmm of a catch basin
  set sewer-basin-capacity 9477000000
  set adjusted-sewer-basin-capacity ( sewer-basin-capacity / ( 10000 * 10000 ) )
  set sewer-basin-height-below-pipe ( adjusted-sewer-basin-capacity * .62)
  
 
  ;;; setting starting water in sewer system- pipes and basins
  set water-in-pipes max-sewer-capacity * Starting-fullness-of-sewers
  ask patches with [ sewers? = true ] [
    set height-in-sewer-basin adjusted-sewer-basin-capacity * Starting-fullness-of-sewers
  ]
  
end

to setup-paver-underdrain

  set paver-underdrain-depth 304.8       ;; in mm. equals 1 foot
  set paver-underdrain-rate (  ( ( 12.7 / 60 ) / Repetitions-per-Iteration )  ) ;; .5 inch per hour or 12.7 mm per hour
  
end

;; there aren't really any "agents." They are just a way to more easily see landscape features.
to setup-agents
  ;;Creates icons for sewers and sets their shape, color, and size
  ask patches with [ sewers? = true ] [
    sprout-sewers 1 [
      set shape "circle 2"
      set color 6
      set size .8
    ]
  ]
  ;; Creates icons for the outlet and sets its shape, color, and size
  ask patches with [ outflow? = true ] [
    sprout-outflow-cells 1 [
      set shape "triangle 2"
      set color red
      set size .8
    ]
  ]
  ask patches with [ inflow? = true ] [
    sprout-outflow-cells 1 [
      set shape "triangle 2"
      set color yellow
      set size .8
    ]
  ]
  ;; Creates icons for green infrastructure and sets their shape, color, and size
;  ask patches with [ cover-type = 1 ] [
;    sprout-GI 1 [
;      set shape "square 2"
;      set color green
;      set size .8
;    ]
;  ]
  ;; Creates icons for roads and sets their shape, color, and size
  ask patches with [ road? = true ] [
    sprout-road-cells 1 [
      set shape "dot"
      set size .4
      set color yellow
    ]
  ]
end


;; "Go" runs all of the operations of the model
to go
  
  ;; resets iteration trackers to 0
  ask patches [
    set iteration-infiltration 0
    set iteration-precipitation 0
    set iteration-evapotrans 0
    set iteration-evapo 0
    set iteration-sewers 0
    set iteration-outflow 0
    set iteration-inflow 0
  ]
  set iteration-CSO 0  
  
  ;; each iteratnion, or "tick," consists of as many repetitions as the value set via the repetitions-per-iteration variable
  repeat Repetitions-per-Iteration [
    ;; Rain continues until the number of ticks equals the storm duration in minutes (set via the storm-hours slider)
    if ticks < storm-length [ add-rain ]
    ;; Infiltrate water using the Green Ampt equation
    Green-Ampt
    ;; If sewers are on, water leaves through sewers
    if activate-sewers? [ sewer-processes ]
    ;; Water will evaporate only after the rain stops
    if ticks >= storm-length [ evaporate ]
    ;; Evapotranspiration occurs every tick, including during rain
    evapotranspiration
    ;; Surface flow occurs after water infiltrates, and leaves through sewers, evaporation, and evapotranspiration
    flow-surface
    
    ;; if the outlet is turned on, outlet releases water
    ;; RENAME THE BOUNDARY-CONDITIONS VARIABLE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if activate-outlet? [ flow-outlet ]
  ]
  ;; cells recalculate their total-height, which is the height to the top of the water column, including underlying elevation

  
  ;; Plot current values on graphs and update globals  
  do-plots-and-globals
  
  ;; Visualize processes using colors
  color-patches
  
  if record-movie? = true [
    if ticks mod 60 = 0 [ movie-grab-view ]
  ]
  ;; Add 1 to the number of ticks (iterations)
  tick
  let day ( floor ( ticks / 1440 ) ) 
  let hour ( floor ( ( ticks - (day * 1440) ) / 60 ) )
  let minute ( ticks mod 60 )
  if minute < 10 [ set minute word 0 minute ]
  set time ( word "Day " day ", " hour ":" minute )
  
  ;; if the rain has stopped and either 2 days have passed or there is no accumulated water, stop
  if ticks > storm-length and abs ( iteration-flow ) < .1 or ticks >= stop-tick [
    set imageName (word (word studyID "_" runID "_" (remove "-" (remove " " (remove "." (remove ":" date-and-time)))) ".png"))
    export-view imageName
    output-data  
    if record-movie? = true [ movie-close ]
    stop
  ]

end


;; Precipitation 
to add-rain
  ;; add rain at the rainfall rate to the water-column
  ask patches [

    ifelse max-extra-GI-storage > 0 [ ;; these are patches with GI that has an extra storage capacity (rain barrels and greenroofs)
      let potential-new-water-storage extra-GI-storage + rainfall-rate
      ifelse potential-new-water-storage > max-extra-GI-storage [ ;;; if the new amount is greater than the max, then only part or none of the new amount can go into storage
        let excess potential-new-water-storage - max-extra-GI-storage
        set extra-GI-storage max-extra-GI-storage
        set water-column water-column + excess
        ask turtles-here [ set color blue ]
      ]
      [ ;;; room for full amount
        set extra-GI-storage potential-new-water-storage
        ;;; no change to water column    
      ]
    ]
    [ ;;; these patches have no extra storage
      
      set water-column water-column + rainfall-rate
      ;;update the global iteration-precipitation with the rain-fall for a given iteration
      
    ]
    set iteration-precipitation iteration-precipitation + rainfall-rate
  ]
end


;; Evapotranspiration
to evapotranspiration
  
  ;; Water that has infiltrated into the soil of green infrastructure and permeable cells can evapotranspire
  ask patches with [ cover-type = 3 ] [
    
    ;; set the amount of water lost to evapotransporation.  Check if the water infiltrated so far minus the evapotransportation rate is bigger than zero,
    ;; then set the amount taken out to be simply the rate. Otherwise, the amount taken out will be everything infiltrated.
    ; if the amount of water taken out of infiltrated water is less than the total infiltrated so far
    if cumulative-infiltration-amount > 0 [
      ifelse  ( cumulative-infiltration-amount - evapotrans-rate )  > 0
        [
          ;; Set iteration-evapotrans to the amount of water that has been evapotranspirated so far this tick plus the evapotranspiration rate
          set iteration-evapotrans ( iteration-evapotrans + evapotrans-rate )
          ;; Set the cumulative amount of water infiltrated to the amount of water infiltrated so far minus the evapotranspiration rate
          set cumulative-infiltration-amount  ( cumulative-infiltration-amount - evapotrans-rate ) 
          
        ]
      ;; if subtracting brings the rate to zero or less
        [
          ;; if the infiltration-rate is greater than the amount of water infiltrated so far, set iteration evapotranspiration to the amount of water infiltrated so far plus
          ;; the amount of water infiltrated so far this tick
          set iteration-evapotrans ( iteration-evapotrans + ( cumulative-infiltration-amount ) ) 
          ;; reset cumulative-infiltration-amount to zero since all of the water was evapotranspirated
          set cumulative-infiltration-amount ( 0 )
          
        ]
    ]
  ]
  
end


;; Evaporate
to evaporate
  
  ;; only occurs after the end of the rain. all cells can evaporate surface water.
  ;; Determine whether the water column has more water than the evaporation rate, if so, evaporate water according to the evaporation rate.  If not, evaporate all water.
  ask patches [
    ;; Check whether the evaporation rate is smaller than the water column
    ifelse (  ( water-column - evapo-rate )  ) > 0 [
      ;; if there is more water in the water column than the per iteration evaporation rate, evaporate water according to the evaporation rate
      set iteration-evapo  ( iteration-evapo + evapo-rate ) 
      ;;  subtract the evaporation rate from the water column
      set water-column (  ( water-column - evapo-rate )  )
    ]
    [
      ;; if there is less water in the water column than the per iteration evaporation rate, evaporate all water from the water column  
      set iteration-evapo  ( iteration-evapo + water-column ) 
      ;; set the water column to 0
      set water-column ( 0 )
    ]
  ] 
  ask patches with [ type-of-GI = "green roof" ] [
    ifelse (  ( extra-GI-storage - evapo-rate )  ) > 0 [
      ;; if there is more water in the water column than the per iteration evaporation rate, evaporate water according to the evaporation rate
      set iteration-evapo  ( iteration-evapo + evapo-rate ) 
      ;;  subtract the evaporation rate from the water column
      set extra-GI-storage (  ( extra-GI-storage - evapo-rate )  )
    ]
    [
      ;; if there is less water in the water column than the per iteration evaporation rate, evaporate all water from the water column  
      set iteration-evapo  ( iteration-evapo + extra-GI-storage ) 
      ;; set the water column to 0
      set extra-GI-storage ( 0 )
    ]
  ]  
    
end

;; Run sewer processes
to sewer-processes
  
  ;; if the sewers are full and CSOs not allowed, revise the sewer intake rate to the treatment plant rate.
  ;; if not true, then set the sewer intake rate to be the regular sewer rate 
  ;; determines whether there is sewer capacity and whether "No-CSO" has been selected with the chooser
  ifelse water-in-pipes >= max-sewer-capacity and when-sewers-full = "no-CSO"
  [
    ;; if there is no sewer capacity left and CSOs are turned off, use the rate designated for full sewers
    set used-sewer-rate full-sewer-rate
    set full-sewers? true
  ]
  [
    ;; if either there is sewer capacity left or CSOs are allowed, or both, use the base sewer rate
    set used-sewer-rate base-sewer-rate
    set full-sewers? false
    
  ]
  
  ;; Patches with sewers discharge water into the storm sewer system (first, the catchment basins) at the rate defined above
  ask patches with [ sewers? = true and water-column > 0 ] [
    ;;if the catchment basins are not full, check to see how much water to take in
    if height-in-sewer-basin < adjusted-sewer-basin-capacity [
      let remaining-basin-height ( adjusted-sewer-basin-capacity - height-in-sewer-basin )
      ;; If there is more water in the water column than the sewer rate, move water from the water column into the sewers at the sewer rate
      let full-remove-amount 0
      
      ifelse ( water-column - used-sewer-rate ) > 0
        [ set full-remove-amount used-sewer-rate ]
        [ set full-remove-amount water-column ]

      ifelse full-remove-amount <= remaining-basin-height [
        set iteration-sewers (  ( iteration-sewers + full-remove-amount )  )
        ;; Move water, which is now in the sewers, from the water column
        set water-column (  ( water-column - full-remove-amount )  )
        set height-in-sewer-basin (  ( height-in-sewer-basin + full-remove-amount )  )
      ]
      [
        set iteration-sewers (  ( iteration-sewers + remaining-basin-height )  )
        ;; Move water, which is now in the sewers, from the water column
        set water-column (  ( water-column - remaining-basin-height )  )
        set height-in-sewer-basin (  ( height-in-sewer-basin + remaining-basin-height )  )
      ]
    ]
  ]
  
  ;; next, water moves from basins to the sewer system more generally.
  ask patches with [ sewers? = true and height-in-sewer-basin > 0 ] [
    if full-sewers? = false [
      let sewer-basin-height-above-pipe ( height-in-sewer-basin - sewer-basin-height-below-pipe )
      
      if sewer-basin-height-above-pipe > 0 [
        let remaining-pipe-space 0
        ifelse when-sewers-full = "no-CSO"
          [ set remaining-pipe-space ( max-sewer-capacity - water-in-pipes ) ]
          [ set remaining-pipe-space max-sewer-capacity ]
        
        let full-basin-remove-amount 0
        ifelse ( sewer-basin-height-above-pipe - used-sewer-rate ) > 0
          [ set full-basin-remove-amount used-sewer-rate ]
          [ set full-basin-remove-amount sewer-basin-height-above-pipe ]
        ifelse full-basin-remove-amount <= remaining-pipe-space
        [
          set water-in-pipes ( water-in-pipes + full-basin-remove-amount )
          set height-in-sewer-basin ( height-in-sewer-basin - full-basin-remove-amount )
        ]
        [
          set water-in-pipes ( water-in-pipes + remaining-pipe-space )
          set height-in-sewer-basin ( height-in-sewer-basin - remaining-pipe-space )
        ]
      ]
    ]
    
  ]
  
  ask patches with [ type-of-GI = "permeable paver" ] [
    if full-sewers? = false [
    let paver-storage-above-pipe ( cumulative-infiltration-amount - paver-underdrain-depth )
      
      if paver-storage-above-pipe > 0 [ ;; means that infiltrated water has reached the drain
        let remaining-pipe-space 0
        ifelse when-sewers-full = "no-CSO" ;;; determinign how much room leftover for water to be drained from the cell to the sewer system
          [ set remaining-pipe-space ( max-sewer-capacity - water-in-pipes ) ]  ;;; no CSOs allowed, so determine the space there
          [ set remaining-pipe-space max-sewer-capacity ] ;;; CSOs allowed
        
        let full-underdrain-remove-amount 0
        ifelse ( paver-storage-above-pipe - paver-underdrain-rate ) > 0 ;;; means that not all of the amount above the pipe goes to the sewers
          [ set full-underdrain-remove-amount paver-underdrain-rate ] ;;; amount equal to the rate goes to sewers
          [ set full-underdrain-remove-amount paver-storage-above-pipe ] ;;; less water there than what would be the ful rate, so alll the water above the pipe goes
        ifelse full-underdrain-remove-amount <= remaining-pipe-space ;;; now, is there room in the sewer system for the amount to drain?
        [ ;;; enough room for full amount to go
          set water-in-pipes ( water-in-pipes + full-underdrain-remove-amount )
          set height-in-sewer-basin ( cumulative-infiltration-amount - full-underdrain-remove-amount )
          set iteration-sewers (  ( iteration-sewers + full-underdrain-remove-amount )  )
        ]
        [ ;; not all the water goes because there is not enough room
          set water-in-pipes ( water-in-pipes + remaining-pipe-space )
          set cumulative-infiltration-amount ( cumulative-infiltration-amount - remaining-pipe-space )
          set iteration-sewers (  ( iteration-sewers + remaining-pipe-space )  )
        ]
      ]
    ]
  ]
  
  
  ;; next, drain water from the sewer system pipes by the treatment plant's rate.
  ifelse water-in-pipes - sewer-drain-rate > 0
  ;; if the drain does not take all of the water
  [
    set water-in-pipes ( water-in-pipes - sewer-drain-rate )
    set global-sewer-drain ( global-sewer-drain + sewer-drain-rate )
  ]
  ;; if the drains bring the global back down to 0
  [
    set global-sewer-drain ( global-sewer-drain + water-in-pipes )
    set water-in-pipes 0
  ]
  
  ;; if CSOs are allowed, drain the excess water from the sewer system and record it.
  if water-in-pipes  > max-sewer-capacity and when-sewers-full = "allow CSO" [
    set iteration-CSO ( iteration-CSO + ( water-in-pipes - max-sewer-capacity ) )
    set water-in-pipes max-sewer-capacity
  ]
end

;; Do outflow procedures
to flow-outlet
  ;; Applies to only outflow cell(s)
  ;; removes up to a very large amount of water, which for app practical purposes is all water
  let outflow-now 0
  ask patches with [ outflow? = true ] [
    let depth-above-outlet-height water-column - Outlet-control-height-mm
    if depth-above-outlet-height < 0 [ set depth-above-outlet-height 0 ]
    
    let water-depth depth-above-outlet-height / 1000 ;;; depth above outlet height in meters
    ;print " "
    ;type "water depth in mm at start of outflow = " print ( water-depth * 1000 )
    ;;; all calculations below in meters
    set cross-sectional-area water-depth * 10 ;;; depth * outlet width
    set wetting-perimeter 10 + water-depth + water-depth
    set hydraulic-radius cross-sectional-area / wetting-perimeter
    
    set velocity-of-flow ( 1 / mannings-coefficient ) * ( hydraulic-radius ^ ( 2 / 3)) * ( longitudal-slope ^ (1 / 2))
    ;;; above number in meters,
    
    set peak-discharge-rate velocity-of-flow * cross-sectional-area
    ;;; this is in cubic meters per second
    
    let max-water-reduction 0
    set max-water-reduction peak-discharge-rate
    
    set max-water-reduction max-water-reduction ^ (1 / 3) ;;; convert from cubic meters to meters    
    set max-water-reduction max-water-reduction * 60 ;;; convert to minutes
    set max-water-reduction max-water-reduction / Repetitions-per-Iteration ;;;; make appropriate time period
    set max-water-reduction max-water-reduction * 1000 ;;; changing back to mm
    
    ;type "maximum discharge in mm = " print max-water-reduction
    
    set total-on-outlet total-on-outlet + ( depth-above-outlet-height * conversion-multiplier )
;    show water-column
    ifelse depth-above-outlet-height - max-water-reduction >= 0 [
      ;; All potential amount goes out
      set outflow-now max-water-reduction
      set water-column water-column - max-water-reduction
    ]
    [ 
      ;; all amount above depth-above-outlet-height goes out
      set outflow-now depth-above-outlet-height
      set water-column water-column - depth-above-outlet-height
    ]
    
;    if water-column > max-water-reduction [
;    print " "
;    type "water column height in mm = " print water-column
;    type "peak discahrge rate in cubic meters a second = " print peak-discharge-rate
;    type "adjusted max rate for iteration length and in mm height = " print max-water-reduction
;    type "outflwo amount = " print outflow-amount
;    ]
    
    ;; adding the outflow to a tracker of total outflow
    let outflow-volume ( outflow-now * conversion-multiplier )
    set global-outflow ( global-outflow + outflow-volume )
    ;; Add outflow from this iteration to the tracker that measures outflow for the entire tick
    set iteration-outflow iteration-outflow + outflow-volume
  ]
  
  ;; Inflow
  
;    ( ( accumulated-water + global-infiltration + global-evapo + global-sewer + global-outflow + water-in-storage ) / ( global-precipitation + global-inflow )) - 1
  if Upstream-bad-neighbor? = true and activate-outlet? = true and inflow-limit-reached? = false [
    ask patches with [ inflow? = true ] [
      set iteration-inflow iteration-inflow + outflow-now
      set water-column water-column + outflow-now
    ]
    let inflow-volume ( outflow-now * conversion-multiplier )
    set global-inflow ( global-inflow + inflow-volume )
  ]
  
;  ask patches [ set plabel precision water-column 1 ]
end

to Green-Ampt
  
  ;; Ask permeable and green infrastructure patches that have water on them to reset infiltration values
  ask patches with [ initial-moisture-deficit > 0 ] [

    ;; reset infiltration-amount to zero
    set infiltration-amount 0
    ;; reset infiltration-rate to zero
    set infiltration-rate 0
    
    ;; if no water has yet infiltrated, infiltration rate = rainfall-rate.  If water has infiltrated, use green-ampt  
    ifelse cumulative-infiltration-amount = 0
      [
        ;; All of the water that falls the first time step will infiltrate
        set infiltration-rate rainfall-rate
        
      ]
      [
        ;;Check if there is remaining infiltration capacity. If true, then infil occurs. If not, the soil is saturated and accumulates.
        
        ifelse max-infil-value > cumulative-infiltration-amount
        ;; this condition is for when there is potential capacity to infiltrate
          [
            ;; Check whether the hydraulic conductivity is higher than the rainfall rate.           
            ifelse saturated-hydraulic-conductivity > rainfall-rate
              [
                ;; If hydraulic conductivity is higher than rainfall rate, the max infiltration rate is equal to the hydraulic conductivity.
                set infiltration-rate saturated-hydraulic-conductivity
              ]
              [
                ;; If hydraulic conductivity is lower than rainfall rate, the max infiltration rate is set using the Green Ampt equation. 
                set infiltration-rate  ( (saturated-hydraulic-conductivity) * ( 1 + ( ( initial-moisture-deficit * capillary-suction ) / cumulative-infiltration-amount ) ) ) 
              ]
          ]
        ;; If the maximum infiltration value has been reached (max-infil-value <= cumulative-infiltration-amount), there is no remaining capacity for infiltration
          [
            ;; The soil is saturated, so infiltration rate is set to zero
            set infiltration-rate 0
            ;; icons for saturated cells are recolored orange
            ;if type-of-GI = "permeable paver" [ set pcolor blue ]
            ask turtles-here [ set color blue ]
          ]
      ]

    ;; The actual infiltration amount is set based on the available water
    ;; Determine infiltration amount based on whatever is smaller, the rate or the surface water available
    ;; Check if the infiltration rate is less than the avaiable water
    ifelse infiltration-rate < water-column
    ;; setting the infiltration amount to be the smaller of infiltration-rate water-column
    ;; infiltration rate is smaller
      [
        ;; If the infiltration rate is smaller than the water column, set the infiltration amount at the infiltration rate
        set infiltration-amount infiltration-rate
      ]
    ;; if the water-column is smaller than the infiltration rate, set the infiltration amount at the water column
      [
        set infiltration-amount water-column
      ]
    ;; this condition ensures that the infiltration amount does not bring the cumulative infiltration amount to a value that is bigger than the max-infil-value
    ;; also, if true, it essentially means the cell is saturated
    ;; check whether the amount of water infiltrated this iteration will exceed the total water holding capacity in the soil
    if ( cumulative-infiltration-amount + infiltration-amount ) > max-infil-value [
      ;; If infiltrating the full amount of water this iteration will exceed the total water holding capacity in the soil, only infiltrate up to this capacity
      set infiltration-amount ( max-infil-value - cumulative-infiltration-amount )
      ;; set color of icons for saturated cells orange
      ;if type-of-GI = "permeable paver" [ set pcolor blue ]
    ]

  ]

  ;;update cumulative infiltration and the water column 
  ;; Ask permeable cells and green infrastructure cells that have water on them to round the infiltration amount to the decimal-places of decimal places
  ask patches with [ initial-moisture-deficit > 0 ] [
    
    set infiltration-amount (  infiltration-amount  )
    ;; Add the amount of water infiltrating this iteration to the cumulative amount of water infiltrated and round to the decimal-places of decimal places
    set cumulative-infiltration-amount (  ( cumulative-infiltration-amount + infiltration-amount )  )
     
    ;;Calculate the new depth of the water column by subracting the water that has infiltrated
    set water-column (  ( water-column - infiltration-amount )  )
    
    ;;update total amount of water infiltrated this iteration by adding the infiltration to the iteration infiltration tracker
    set iteration-infiltration  ( iteration-infiltration + infiltration-amount ) 
    
  ]
  
end


;; Do surface flow
to flow-surface
  set pre-flow-water sum [ water-column ] of patches
  set iteration-flow 0
  foreach Landscape-Elevation-list [
      ask ? [
        if water-column > 0 or any? neighbors with [ water-column > 0 ] [ 

          ;; Create temporary variables for flow code
          ;; baseline = the center cell/ cell that is comparing to its neighbors
          ;; defining the baseline values to which the neighbors will compare
          let baseline-water-column water-column ;; The baseline cell sets temporary water column variable
          let baseline-total-height water-column + elevation ;; The baseline cell sets temporary total height variable
          let central-patch self
          ;; creates a list of neighboring cells.  Each neighboring cell completes this code in series.  The order in which they complete it is random.
          foreach Neighbor-Elevation-list [
            ask ? [

              let neighbor-water-column [water-column] of self
              let neighbor-total-height [elevation + water-column] of self
              
              ;; flow will be the amount of water that will move to or from the baseline cell
              let flow 0
              
              ;; This is the equilibrium level between the two cells.
              let half-difference-height ( ( neighbor-total-height - baseline-total-height) / 2 )
              ;; Negative means outgoing water
              ;; Positive means incoming water
              
              if half-difference-height != 0 [
                ;; there are ultimately only 4 possibilities for flow calculations, but after going through a decision tree, only one will be used for each neighbor.
                ;; check to see if water is available to move
                ;; if neighbor-total-height is bigger than baseline total height, there will be inflow to center cell, if water is available               
                
                ifelse half-difference-height > 0
                
                ; flow is positive ( potential inflow ) because the neighbor is higher than the baseline cell.  Water will flow to baseline cell.
                [
                  ;; Check whether the neighbor's water column is higher than the equilibrium level
                  ifelse neighbor-water-column >= abs half-difference-height [
                    ;; If the height of water on the neighbor is higher than half the difference between the cell's heights, water will move to the equilibrium level from the neighbor cell
                    set flow precision half-difference-height 10
                  ]
                  [
                    ;; If the height of water on the neighbor cell is lower than the amount of water that would be needed achieve equilibrium, move all water
                    set flow precision neighbor-water-column 10
                  ]
                ] ;; Closes positive flow condition
                
                  ; flow is negative ( potential outflow ) because the neighbor is lower than the baseline cell.  Water will flow from baseline cell.
                [
                  ;; Check whether the baseline water column is higher than the equilibrium level
                  ifelse baseline-water-column >= abs half-difference-height [
                    ;; If the height of water on the baseline cell is higher than have the difference between the cell's heights, water will move to the equilibrium level from the baseline cell
                    set flow precision half-difference-height 10
                  ]
                  [
                    ;; If the height of water on the baseline cell is lower than the amount of water that would be needed achieve equilibrium, move all water
                    set flow precision (- baseline-water-column ) 10
                  ]
                ] ;; Closes negative flow condition
                
                set water-column precision ( water-column - flow ) 10 ;; This takes the flow from the neighbor
                ask central-patch [
                  set water-column precision ( water-column + flow ) 10 ;; This adds the flow to the central patch
                  set baseline-water-column water-column ;; Readjust the baseline water column of the central patch
                  set baseline-total-height water-column + elevation ;; Readjust the total height of teh central patch
                ]
              ] ;; closes if half-difference-height != 0 [
              
            if ticks >= storm-length [ set iteration-flow precision ( iteration-flow + abs ( flow ) ) 10 ]
              
            ]   ;; closes the ask ? (for neighbors)
          ]         ;;closes the sort loop for the neighbors
          if water-column < 0 [ print "error - surface water below 0"]
        ] ;; Closes the loop askig if there is water
      ] ;; closes ask ? of the list
    ] ;; closes  foreach elevation list...
    
  set post-flow-water sum [ water-column ] of patches
  if pre-flow-water > 0 [ set flow-error ( post-flow-water / pre-flow-water ) - 1 ]  
end


;; Sets the visualization choices
to color-patches
  ask patches with [ type-of-gi = "swale" ] [ if water-column > storage-capacity [ ask turtles-here [ set color blue ] ] ]
  ;; Shows the accumulated water on the surface, not including water in the green infrastructure storage.
  ;; This may result in more pronounced color differences but there may also be sudden changes as relative differences shift.
  if data-visualized = "accumulated water not including storage capacity-total water" [
    let max1 max [ ( water-column - storage-capacity ) ] of patches
    ask patches [      
      ifelse water-column > 0
        [
          ifelse max1 > 0
            [ set pcolor scale-color blue ( water-column - storage-capacity ) 500 0 ]
            [ set pcolor black ]
        ]
        [

          if cover-type = 2 [
             ifelse alley? = true [
               set pcolor 4 ]
             [ set pcolor grey ]
          ]
          if cover-type = 3 [ set pcolor brown ]
        ]
    ]
  ]        
  
  if data-visualized = "flooding definitions" [
    ask patches [
      ifelse flooded? = true [
        ifelse extreme-flooded? = true [
          set pcolor blue
        ]
        [set pcolor cyan
        ] 
      ]
      
      [
        ifelse ever-extreme-flooded? = true [

          if cover-type = 2 [
            if cover-type = 2 [
              ifelse alley? = true [
                set pcolor 2 ]
              [ set pcolor grey - 2]
            ]
          ]
          if cover-type = 3 [ set pcolor brown - 2 ] 
        ]
        [ 
          ifelse ever-flooded? = true [

            if cover-type = 2 [ set pcolor grey - 1]
            if cover-type = 2 [
              ifelse alley? = true [
                set pcolor 3 ]
              [ set pcolor grey - 1]
            ]
            if cover-type = 3 [ set pcolor brown - 1] 
          ] 
          [

            if cover-type = 2 [
              ifelse alley? = true [
                set pcolor 4 ]
              [ set pcolor grey ]
            ]
            if cover-type = 3 [ set pcolor brown ]
          ]
        ]
      ]
    ]
  ]
     
  
  ;; Same as above, except the colors are scaled relative to the highest water level on a cell in the landscape.
  if data-visualized = "accumulated water not including storage capacity-relative colors" [
    let max2 max [ ( water-column - storage-capacity ) ] of patches 
    ask patches [      
      ifelse water-column > 0
        [
          ifelse max2 > 0
            [ set pcolor scale-color blue ( water-column - storage-capacity ) max2 0 ]
            [set pcolor black ]
        ]
        [

          if cover-type = 2 [ set pcolor grey ]
          if cover-type = 3 [ set pcolor brown ]
        ]
    ]
  ]
  
  ;; shows the starting colors of the cover types.
  if data-visualized = "cover type"[
    ask patches [

      if cover-type = 2 [ set pcolor grey ]
      if cover-type = 3 [ set pcolor brown ]
    ]
  ]
  
  if data-visualized = "base"[
    ask patches [
      ifelse flooded?
      [
        ;;; flooded
        set pcolor blue
        
      ]
      [
        ;;; not flooded

        if cover-type = 2 [ set pcolor grey ]
        if cover-type = 3 [ set pcolor brown ]
      ]
    ]
  ]
  
  ;; Same as the option �Accumulated water not including storage capacity�
  ;; except it sums the underlying elevation and water column for each cell and displays that data.
  if data-visualized = "elevation and water" [
    ask patches [      
      set pcolor scale-color blue ( elevation + water-column ) ( total-rainfall + ( max-elevation ) ) 350
    ]
  ]
  
  ;; Shows only the underlying elevation, with white the highest and black the lowest.
  if data-visualized = "elevation"[
    ask patches [
      set pcolor scale-color brown ( elevation ) 0 ( max-elevation )      
    ]
  ]
  
  ;; A binary display of whether cells are flooded. Flooded cells (water columns over 1cm) are blue and unflooded cells are grey.
  if data-visualized = "flooded-cells" [
    ask patches [
      ifelse flooded? = true
        [ set pcolor blue ]
        [ set pcolor grey ]
    ]
  ]
  
  
end

to do-plots-and-globals

  ;;; Updating global variables
  
  ;; Summing the iteration amounts for all the cells for each process then updating the global trackers.
  let outflow-sum ( [ iteration-outflow ] of patch 0 0 )
  
  let infiltration-sum ( ( sum [ iteration-infiltration ] of patches ) * conversion-multiplier )
  set global-infiltration (  ( global-infiltration + infiltration-sum )  )
  
  let GI-infiltration-sum ( ( sum [ iteration-infiltration ] of patches with [ type-of-GI = "swale" or  type-of-GI = "permeable paver" ] ) * conversion-multiplier )
  set global-GI-infiltration global-GI-infiltration + GI-infiltration-sum
  
  ;; setting the amount of infiltration that was not from GI cells
  set global-Non-GI-infiltration global-infiltration - global-GI-infiltration
  
  let precipitation-sum ( ( sum [ iteration-precipitation ] of patches ) * conversion-multiplier )
  set global-precipitation (  ( global-precipitation + precipitation-sum )  )
  
  let evapotrans-sum ( ( sum [ iteration-evapotrans ] of patches ) * conversion-multiplier )
  set global-evapotrans (  ( global-evapotrans + evapotrans-sum )  )
  
  let evapo-sum ( ( sum [ iteration-evapo ] of patches ) * conversion-multiplier )
  set global-evapo (  ( global-evapo + evapo-sum )  )
  
  set accumulated-water (  ( sum [ water-column ] of patches * conversion-multiplier )  )
  
  let sewer-sum ( ( sum [ iteration-sewers ] of patches ) * conversion-multiplier )
  set global-sewer (  ( global-sewer + sewer-sum )  )
  
  set global-CSO ( global-CSO + ( iteration-CSO * conversion-multiplier ) )
  
  ;; setting the sum of the water above the so-called 0 elevation, ie water colum minus any water in teh storace capacity of GI cells.
  ;; this is a 2 part step. also checkign to see if cells are flooded. There are different ways to set and check if it is a GI cell, hence the need for two steps.
  ;; resetting the some relevent variables first

  
  ask patches with [ type-of-GI = "swale" ] [
    ;;are swales
    let height-above-storage water-column - storage-capacity
    ifelse height-above-storage > 0 [
      set water-in-swale storage-capacity
    ]
    [
      set water-in-swale water-column
    ]
  ]
  
  set water-in-storage sum [ water-in-swale ] of patches ;; Water in swales but not infiltrates and not the water above the top of the swale
  
  set accumulated-water sum [ water-column ] of patches
  
  set non-GI-accumulated-water accumulated-water - water-in-storage ;; Standing water - water-in-storage
  
  set water-in-storage water-in-storage * conversion-multiplier
  set accumulated-water accumulated-water * conversion-multiplier
  set non-GI-accumulated-water non-GI-accumulated-water * conversion-multiplier
  
  set global-rain-barrel ( sum [ extra-GI-storage ] of patches with [ type-of-GI = "rain-barrel" ] ) * conversion-multiplier
  set global-green-roof ( sum [ extra-GI-storage ] of patches with [ type-of-GI = "green roof" ] ) * conversion-multiplier
  set global-green-alleys ( sum [ cumulative-infiltration-amount ] of patches with [ type-of-GI = "permeable paver" ] ) * conversion-multiplier
  set global-swales ( ( sum [ cumulative-infiltration-amount ] of patches with [ type-of-GI = "swale" ] ) * conversion-multiplier ) + water-in-storage 
  set global-GI-total global-rain-barrel + global-green-roof + global-green-alleys + global-swales
  
  set global-rain-barrel-ft3 global-rain-barrel * cubic-m-to-cubic-ft
  set global-green-roof-ft3 global-green-roof * cubic-m-to-cubic-ft
  set global-green-alleys-ft3 global-green-alleys * cubic-m-to-cubic-ft
  set global-swales-ft3 global-swales * cubic-m-to-cubic-ft
  set global-GI-total-ft3 global-GI-total * cubic-m-to-cubic-ft
  
  set total-extra-storage ( global-rain-barrel + global-green-roof ) ;; green roofs and barrels
  ask patches [
    ifelse water-column >= patch-flooded-level [
      set flooded? true
      set ever-flooded? true
    ]
    [ set flooded? false ]

    ifelse water-column >= extreme-patch-flooded-level [
      set extreme-flooded? true
      set ever-extreme-flooded? true
    ]
    [
      set extreme-flooded? false
    ]
  ]
  
  ;;; GI fullness/efficiency
  if any? rain-barrels [ set global-efficiency-rain-barrels global-rain-barrel / volume-rain-barrels ]
  if any? green-roofs [ set global-efficiency-green-roofs global-green-roof / volume-green-roofs ]
  if any? permeable-pavers [ set global-efficiency-green-alleys global-green-alleys / volume-green-alleys ]
  if any? swales [ set global-efficiency-swales global-swales / volume-swales ]
  if any? patches with [ GI? = true ] [ set global-efficiency-total global-GI-total / volume-total-GI ]

  

  ;; setting the cumulative margin of error
  set cumulative-margin-of-error ( ( accumulated-water + global-infiltration + global-evapo + global-sewer + global-outflow + total-extra-storage ) / ( global-precipitation + global-inflow )) - 1

  
  if tracked-cell != 0  [
    ask tracked-cell [
      if water-column > max-height-tracked-cell [
        set max-height-tracked-cell water-column
      ]
    ]
  ]

  if Upstream-bad-neighbor? = true and activate-outlet? = true and inflow-limit-reached? = false [
    if global-inflow >= ( potential-rain - ( global-infiltration + global-evapo + global-sewer + total-extra-storage + water-in-storage ) ) [ ;; + water-in-storage
;      show ticks
      set inflow-limit-reached? true
    ]    
  ]

  set global-precipitation-ft3 global-precipitation * cubic-m-to-cubic-ft
  set global-GI-infiltration-ft3 global-GI-infiltration * cubic-m-to-cubic-ft
  set global-Non-GI-infiltration-ft3 global-Non-GI-infiltration * cubic-m-to-cubic-ft
  set global-sewer-ft3 global-sewer * cubic-m-to-cubic-ft
  set global-outflow-ft3 global-outflow * cubic-m-to-cubic-ft
  set global-evapo-ft3 global-evapo * cubic-m-to-cubic-ft
  set global-evapotrans-ft3 global-evapotrans * cubic-m-to-cubic-ft
  set non-GI-accumulated-water-ft3 non-GI-accumulated-water * cubic-m-to-cubic-ft
  set water-in-storage-ft3 water-in-storage * cubic-m-to-cubic-ft
  set total-extra-storage-ft3 total-extra-storage * cubic-m-to-cubic-ft
  set global-inflow-ft3 global-inflow * cubic-m-to-cubic-ft



  
  set-current-plot "Water Accounting"
  set-current-plot-pen "Rain"
  plot global-precipitation-ft3
  set-current-plot-pen "GI infiltration"
  plot global-GI-infiltration-ft3
  set-current-plot-pen "Permeable infiltration"
  plot global-Non-GI-infiltration-ft3
  set-current-plot-pen "Sewer Runoff"
  plot global-sewer-ft3
  set-current-plot-pen "Outlet Runoff"
  plot global-outflow-ft3
  set-current-plot-pen "Evaporation and Evapotranspiration"
  plot global-evapo-ft3 + global-evapotrans-ft3
  set-current-plot-pen "Standing Water"
  plot non-GI-accumulated-water-ft3
  set-current-plot-pen "Water in Swales"
  plot water-in-storage-ft3
  set-current-plot-pen "Water in barrels and roofs"
  plot total-extra-storage-ft3
  set-current-plot-pen "Inflow from Neighbors"
  plot global-inflow-ft3

  
  let non-road-impermeable count patches with [ cover-type = 2 and road? = false ]
  let road-count count patches with [ road? = true ]
  

  if time-to-lesser-flood = 0 and any? patches with [ flooded? = true ] [
    set time-to-lesser-flood ticks
  ]
  if time-to-greater-flood = 0 and any? patches with [ extreme-flooded? = true ] [
    set time-to-greater-flood ticks
  ]
  if time-to-lesser-flood != 0 and time-duration-lesser-flood = 0 and all? patches [ flooded? = false ] [
    set time-duration-lesser-flood ( ticks - time-to-lesser-flood )
  ]
  if time-to-greater-flood != 0 and time-duration-greater-flood = 0 and all? patches [ extreme-flooded? = false ] [
    set time-duration-greater-flood ( ticks - time-to-greater-flood )
  ]
  
  set-current-plot "Public Costs"
  set-current-plot-pen "Cumulative Sewer Runoff"
  plot global-sewer-ft3
  set-current-plot-pen "Cumulative Outlet Runoff"
  plot global-outflow-ft3
  
end

to setup-outlet-values
 
  set mannings-coefficient .013
  set longitudal-slope slope-percent * .01
  
end




To Select-patch-to-track
  if mouse-down? [
  
  ask turtles with [ shape = "circle 3" ] [ die ]
  
  set tracked-cell patch mouse-xcor mouse-ycor
  
  
  ask tracked-cell [
    sprout 1[
      set shape "circle 3"
      set color 15
      set size 2
    ]
  ]
    
    
  ]
  
end

to Place-GI
  if mouse-down? [
    
    let selected-cell patch mouse-xcor mouse-ycor
    if Type-to-Place = "Rain barrels" [
      ask selected-cell [ 
        if cover-type = 2 and road? = false and alley? = false and GI? = false[
          if remaining-budget - cost-a-rain-barrel > 0 [
            setup-GI-rain-barrel

            set remaining-budget remaining-budget - cost-a-rain-barrel
            set formatted-remaining-budget ( commify remaining-budget )
            set formatted-remaining-budget ( word "$" formatted-remaining-budget )
           
            set Cost-install-private-GI Cost-install-private-GI + cost-a-rain-barrel
            set Cost-total-install Cost-install-private-GI + Cost-install-public-GI
            set formatted-Cost-of-GI ( commify Cost-total-install )
            set formatted-Cost-of-GI ( word "$" formatted-Cost-of-GI )
            
            set Cost-private-maintenance Cost-private-maintenance + maintenance-a-barrel
            set Cost-total-maintenance Cost-private-maintenance + Cost-public-maintenance
            set formatted-Cost-total-maintenance ( commify Cost-total-maintenance )
            set formatted-Cost-total-maintenance ( word "$" formatted-Cost-total-maintenance )
            
            set volume-rain-barrels volume-rain-barrels + volume-a-rain-barrel
            set volume-total-GI volume-total-GI + volume-a-rain-barrel
            set volume-rain-barrels-ft3 volume-rain-barrels-ft3 + volume-a-rain-barrel-ft3
            set volume-total-GI-ft3 volume-total-GI-ft3 + volume-a-rain-barrel-ft3
          ] 
        ]
      ]
    ]
    if Type-to-Place = "Green roofs" [
      ask selected-cell [ 
        if cover-type = 2 and road? = false and alley? = false and GI? = false[
          if remaining-budget - cost-a-green-roof > 0 [
            setup-GI-green-roof
            set remaining-budget remaining-budget - cost-a-green-roof
            set formatted-remaining-budget ( commify remaining-budget )
            set formatted-remaining-budget ( word "$" formatted-remaining-budget )
            
            set Cost-install-private-GI Cost-install-private-GI + cost-a-green-roof
            set Cost-total-install Cost-install-private-GI + Cost-install-public-GI
            set formatted-Cost-of-GI ( commify Cost-total-install )
            set formatted-Cost-of-GI ( word "$" formatted-Cost-of-GI )
            
            set Cost-private-maintenance Cost-private-maintenance + maintenance-a-roof
            set Cost-total-maintenance Cost-private-maintenance + Cost-public-maintenance
            set formatted-Cost-total-maintenance ( commify Cost-total-maintenance )
            set formatted-Cost-total-maintenance ( word "$" formatted-Cost-total-maintenance )
            
            set volume-green-roofs volume-green-roofs + volume-a-green-roof
            set volume-total-GI volume-total-GI + volume-a-green-roof
            set volume-green-roofs-ft3 volume-green-roofs-ft3 + volume-a-green-roof-ft3
            set volume-total-GI-ft3 volume-total-GI-ft3 + volume-a-green-roof-ft3
          ] 
        ]
      ]
    ]
    if Type-to-Place = "Swales" [
      ask selected-cell [ 
        if remaining-budget - cost-a-swale > 0 [
          if cover-type = 3 and road? = false and alley? = false and GI? = false[
            setup-GI-swale
            set remaining-budget remaining-budget - cost-a-swale
            set formatted-remaining-budget ( commify remaining-budget )
            set formatted-remaining-budget ( word "$" formatted-remaining-budget )
            
            set Cost-install-private-GI Cost-install-private-GI + cost-a-swale
            set Cost-total-install Cost-install-private-GI + Cost-install-public-GI
            set formatted-Cost-of-GI ( commify Cost-total-install )
            set formatted-Cost-of-GI ( word "$" formatted-Cost-of-GI )
            
            set Cost-private-maintenance Cost-private-maintenance + maintenance-a-swale
            set Cost-total-maintenance Cost-private-maintenance + Cost-public-maintenance
            set formatted-Cost-total-maintenance ( commify Cost-total-maintenance )
            set formatted-Cost-total-maintenance ( word "$" formatted-Cost-total-maintenance )
            
            set volume-swales volume-swales + volume-a-swale
            set volume-total-GI volume-total-GI + volume-a-swale
            set volume-swales-ft3 volume-swales-ft3 + volume-a-swale-ft3
            set volume-total-GI-ft3 volume-total-GI-ft3 + volume-a-swale-ft3
          ]
        ]
      ]
    ]
    
    if Type-to-Place = "Green alleys" [
      ask selected-cell [ 
        if remaining-budget - cost-a-permeable-paver > 0 [
          if cover-type = 2 and alley? = true and GI? = false[
            setup-GI-permeable-paver
            set remaining-budget remaining-budget - cost-a-permeable-paver
            set formatted-remaining-budget ( commify remaining-budget )
            set formatted-remaining-budget ( word "$" formatted-remaining-budget )
            
            set Cost-install-public-GI Cost-install-public-GI + cost-a-permeable-paver
            set Cost-total-install Cost-install-private-GI + Cost-install-public-GI
            set formatted-Cost-of-GI ( commify Cost-total-install )
            set formatted-Cost-of-GI ( word "$" formatted-Cost-of-GI )
            
            set Cost-public-maintenance Cost-public-maintenance + maintenance-a-paver
            set Cost-total-maintenance Cost-private-maintenance + Cost-public-maintenance
            set formatted-Cost-total-maintenance ( commify Cost-total-maintenance )
            set formatted-Cost-total-maintenance ( word "$" formatted-Cost-total-maintenance )
            
            set volume-green-alleys volume-green-alleys + volume-a-paver
            set volume-total-GI volume-total-GI + volume-a-paver
            set volume-green-alleys-ft3 volume-green-alleys-ft3 + volume-a-paver-ft3
            set volume-total-GI-ft3 volume-total-GI-ft3 + volume-a-paver-ft3
          ]
        ]
      ]
    ]
  ]
  

end

to output-data
  
  ;;;;;;;;;;;;;
  ;;; Costs ;;;
  ;;;;;;;;;;;;;
  
  set Cost-private-storm-damage 0
  set Cost-public-storm-damage 0
  set Costs-total-storm-damage Cost-private-storm-damage + Cost-public-storm-damage
  set Costs-total Cost-total-install + Cost-total-maintenance + Costs-total-storm-damage
  
  ;; Normalized costs
  ifelse Costs-total > 0 [
    set Normalized-Cost-install-private-GI Cost-install-private-GI / Costs-total
    set Normalized-Cost-install-public-GI Cost-total-install / Costs-total
    set Normalized-Cost-total-install Cost-total-install / Costs-total
    set Normalized-Cost-private-maintenance Cost-private-maintenance / Costs-total
    set Normalized-Cost-public-maintenance Cost-public-maintenance / Costs-total
    set Normalized-Cost-total-maintenance Cost-total-maintenance / Costs-total
    set Normalized-Cost-private-storm-damage Cost-private-storm-damage / Costs-total
    set Normalized-Cost-public-storm-damage Cost-public-storm-damage / Costs-total
    set Normalized-Costs-total-storm-damage Costs-total-storm-damage / Costs-total
    set Normalized-Costs-total Costs-total / Costs-total
  ]
  [
    set Normalized-Cost-install-private-GI 0
    set Normalized-Cost-install-public-GI 0
    set Normalized-Cost-total-install 0
    set Normalized-Cost-private-maintenance 0
    set Normalized-Cost-public-maintenance 0
    set Normalized-Cost-total-maintenance 0
    set Normalized-Cost-private-storm-damage 0
    set Normalized-Cost-public-storm-damage 0
    set Normalized-Costs-total-storm-damage 0
    set Normalized-Costs-total 0
  ]
  
  ;;;;;;;;;;;;;
  ;;; Times ;;;
  ;;;;;;;;;;;;;
  
  set time-to-dry ticks - storm-length
  
  if time-to-lesser-flood != 0 and time-duration-lesser-flood = 0 [
    set time-duration-lesser-flood ( ticks - time-to-lesser-flood )
  ]
  if time-to-greater-flood != 0 and time-duration-greater-flood = 0 [
    set time-duration-greater-flood ( ticks - time-to-greater-flood )
  ]
  
  ;;; Normalized times
  set Normalized-time-to-lesser-flood time-to-lesser-flood / stop-tick
  set Normalized-time-to-greater-flood time-duration-lesser-flood / stop-tick
  set Normalized-time-duration-lesser-flood time-duration-lesser-flood / stop-tick
  set Normalized-time-duration-greater-flood time-duration-greater-flood / stop-tick
  set Normalized-time-to-dry time-to-dry / stop-tick

  ;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Amounts of Water ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;
  
;  set global-standing-water-ft3
;  set greatest-depth-standing-water-ft
  

  
;;; Normalized amoujnts of water
  set Normalized-global-outflow-ft3 global-outflow-ft3 / global-precipitation-ft3
  set Normalized-global-sewer-ft3 global-sewer-ft3 / global-precipitation-ft3
;  set Normalized-global-standing-water-ft3 global-standing-water-ft3
;  set Normalized-greatest-depth-standing-water-ft 
  

;;upload image to server
  
;;set db "jdbc:mysql://polarbear.evl.uic.edu:3306/ecocollage?user=evl&password='CAT.evl'"
  sql:configure "defaultconnection" [["host" "polarbear.evl.uic.edu"] ["port" 3306] ["user" "evl"] ["password" "CAT.evl"] ["database" "ecocollage"]]
  set query (word "INSERT INTO ecocollage.outFromSim (runID, studyID, privateInstall, publicInstall, "
    "privateMaintain, publicMaintain, privateDamage, publicDamage, timeToFlood, timeToLargeFlood,"
    "timeOfFlood, timeOfLargeFlood, timeToDry, waterInSewers, runOff, waterInAllGI, waterInRoofs,"
    "waterInRainBarrels, waterInSwales, privateInstallN, publicInstallN, privateMaintainN,"
    "publicMaintainN, privateDamageN, publicDamageN, timeToFloodN, timeToLargeFloodN, timeOfFloodN, "
    "timeOfLargeFloodN, timeToDryN, waterInSewersN, runOffN, waterInAllGIN, waterInRoofsN," 
    "waterInRainBarrelsN, waterInSwalesN, pathOfImage) VALUES ("runID", "studyID", "Cost-install-private-GI
    " , " Cost-install-public-GI", "Cost-private-maintenance", "Cost-public-maintenance", "
    Cost-private-storm-damage", "Cost-public-storm-damage", " time-to-lesser-flood", " 
    time-to-greater-flood", "time-duration-lesser-flood", "time-duration-greater-flood", "
    time-to-dry", "global-sewer-ft3", "global-outflow-ft3", "global-GI-total-ft3" , "
    global-green-roof-ft3" , "global-rain-barrel-ft3", "global-swales-ft3"," 
    Normalized-Cost-install-private-GI " , "Normalized-Cost-install-public-GI", "
    Normalized-Cost-private-maintenance", "Normalized-Cost-public-maintenance", " 
    Normalized-Cost-private-storm-damage", "Normalized-Cost-public-storm-damage", " 
    Normalized-time-to-lesser-flood", " Normalized-time-to-greater-flood", "
    Normalized-time-duration-lesser-flood", "Normalized-time-duration-greater-flood", "
    Normalized-time-to-dry", "Normalized-global-sewer-ft3", "Normalized-global-outflow-ft3", "
    Normalized-global-GI-total-ft3" , "Normalized-global-green-roof-ft3" , "
    Normalized-global-rain-barrel-ft3", "Normalized-global-swales-ft3", '" imageName"')" )
  show query
  sql:exec-update query []

  
end

to placement-done
  ;; Now creating lists of patches sorted by elevation (small to large) for the overall landscape and of each patches neighbors.
  set Landscape-Elevation-list sort-on [ elevation ] patches
  ;  show Landscape-Elevation-list
  ask patches [
    set Neighbor-Elevation-list sort-on [ elevation ] neighbors
    ;  print ""
    ;  show Neighbor-Elevation-list
  ]
end

to Neighborhood-View
  clear-all
  set-patch-size 1
  
  if Neighborhood-type = "Albany Park - Import" [
    set world-dimensions-vertical ( ( 24 ) + 2 ) * 15
    set world-dimensions-horizontal ( ( 24 ) + 2 ) * 15
    
    
    resize-world 0 ( world-dimensions-horizontal - 1 ) 0 ( world-dimensions-vertical - 1 )
    
    import-pcolors "AlbanyPark-crop2.jpg"
  ]
  
  if Neighborhood-type = "Blue Island - Import" [
    set world-dimensions-vertical ( ( 20 ) + 1 ) * 15 ;; 17 lots vertical
    set world-dimensions-horizontal ( ( 19 ) + 2 ) * 15
    
    
    resize-world 0 ( world-dimensions-horizontal - 1 ) 0 ( world-dimensions-vertical - 1 )
    
    import-pcolors "BlueIsland-crop2.jpg"
  ]
  
  if Neighborhood-type = "Dixmoor - Import" [
    set world-dimensions-vertical ( ( 19 ) + 1 ) * 15 ;; 17 lots vertical
    set world-dimensions-horizontal ( ( 19 ) + 2 ) * 15
    
    
    resize-world 0 ( world-dimensions-horizontal - 1 ) 0 ( world-dimensions-vertical - 1 )
    
    import-pcolors "Dixmoor-crop2.jpg"
  ]
  
  if Neighborhood-type = "Palos Heights - Import" [
    set world-dimensions-vertical ( ( 21 ) ) * 15
    set world-dimensions-horizontal ( ( 18 ) + 1 ) * 15
    
    
    resize-world 0 ( world-dimensions-horizontal - 1 ) 0 ( world-dimensions-vertical - 1 )
    
    import-pcolors "PalosHeights-crop2.jpg"
  ]
   
End
@#$#@#$#@
GRAPHICS-WINDOW
16
59
311
420
-1
-1
15.0
1
8
1
1
1
0
0
0
1
0
18
0
21
0
0
1
ticks
30.0

BUTTON
452
105
630
154
Setup of Landscape and Processes
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
453
158
631
207
Go until Stop Conditions Met
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
1126
854
1292
899
data-visualized
data-visualized
"none" "flooding definitions" "accumulated water not including storage capacity-total water" "accumulated water not including storage capacity-relative colors" "cover type" "elevation and water" "elevation" "flooded-cells" "base"
1

PLOT
15
670
528
905
Water Accounting
Time
Cubic Feet
0.0
10.0
0.0
3.0
true
true
"" ""
PENS
"Rain" 1.0 0 -11221820 true "" ""
"GI Infiltration" 1.0 0 -13840069 true "" ""
"Permeable Infiltration" 1.0 0 -6459832 true "" ""
"Sewer Runoff" 1.0 0 -7500403 true "" ""
"Outlet Runoff" 1.0 0 -2674135 true "" ""
"Evaporation and Evapotranspiration" 1.0 0 -1184463 true "" ""
"Standing Water" 1.0 0 -13345367 true "" ""
"Water in Swales" 1.0 0 -14835848 true "" ""
"Water in barrels and roofs" 1.0 0 -955883 true "" ""
"Inflow from Neighbors" 1.0 0 -2064490 true "" ""

TEXTBOX
19
10
410
30
Landscape Green Infrastructure Design Model (L-GrID)
16
0.0
1

TEXTBOX
21
28
405
59
This model is designed to compare different green infrastructure layout scenarios at the subwatershed scale.
11
0.0
1

PLOT
15
515
527
665
Public Costs
Time
Cubic Feet
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Cumulative Sewer Runoff" 1.0 0 -7500403 true "" ""
"Cumulative Outlet Runoff" 1.0 0 -2674135 true "" ""

MONITOR
1076
170
1198
215
Number of Rain Barrels
count patches with [ type-of-GI = \"rain-barrel\" ]
0
1
11

MONITOR
1076
240
1200
285
Number of Green Roofs
count patches with [ type-of-GI = \"green roof\" ]
17
1
11

CHOOSER
451
10
698
55
Neighborhood-type
Neighborhood-type
"Albany Park - Import" "Blue Island - Import" "Dixmoor - Import" "Palos Heights - Import"
3

MONITOR
453
211
604
256
Time in run (military time)
Time
17
1
11

TEXTBOX
930
59
1072
395
Private GI\n\nSwales\nCost per swale: $21,000. May be placed on permeable (brown) patches.\n\nRain Barrels\nCost per rain barrel: $125. May be placed on non-road, impermeable (grey) patches.\n\nGreen roofs\nCost per green roof: $125,000. May be placed on non-road, impermeable (grey) patches.\n\nPublic GI\n\nPermeable pavers\nCost per permeable paver patch: $5,500. May be placed on alleys (dark grey).
11
0.0
1

MONITOR
1075
99
1183
144
Number of Swales
count patches with [ type-of-GI = \"swale\" ]
17
1
11

MONITOR
1075
338
1234
383
Number of Green Alley Patches
count patches with [ type-of-GI = \"permeable paver\" ]
17
1
11

MONITOR
1103
438
1284
483
Total install cost of GI in landscape
formatted-Cost-of-GI
2
1
11

MONITOR
1104
487
1258
532
Annual maintenance cost
formatted-cost-total-maintenance
17
1
11

MONITOR
721
58
873
103
Time to 1" flood (minutes)
time-to-lesser-flood
0
1
11

MONITOR
721
108
874
153
Time to 6" flood (minutes)
time-to-greater-flood
0
1
11

MONITOR
721
159
874
204
Duration of 1" flood (minutes)
time-duration-lesser-flood
0
1
11

MONITOR
721
210
873
255
Duration of 6" flood (minutes)
time-duration-greater-flood
0
1
11

MONITOR
721
260
873
305
Time to equilibrium (minutes)
time-to-dry
17
1
11

MONITOR
606
529
725
574
Volume of rain barrels
volume-rain-barrels-ft3
2
1
11

MONITOR
606
574
725
619
Volume of green roofs
volume-green-roofs-ft3
2
1
11

MONITOR
606
663
725
708
Volume of green alleys
volume-green-alleys-ft3
2
1
11

MONITOR
606
618
725
663
Volume of swales
volume-swales-ft3
2
1
11

MONITOR
606
712
726
757
Total volume of GI
volume-total-GI-ft3
2
1
11

MONITOR
737
530
852
575
Volume in rain barrels
global-rain-barrel-ft3
2
1
11

MONITOR
737
574
852
619
Volume in green roofs
global-green-roof-ft3
2
1
11

MONITOR
737
662
852
707
Volume in green alleys
global-green-alleys-ft3
2
1
11

MONITOR
737
617
852
662
Volume in swales
global-swales-ft3
2
1
11

MONITOR
738
712
852
757
Total volume in GI
global-GI-total-ft3
2
1
11

MONITOR
866
529
975
574
Fullness rain barrels
global-efficiency-rain-barrels * 100
2
1
11

MONITOR
866
574
975
619
Fullness green roofs
global-efficiency-green-roofs * 100
2
1
11

MONITOR
866
663
975
708
Fullness green alleys
global-efficiency-green-alleys * 100
2
1
11

MONITOR
866
618
975
663
Fullness swales
global-efficiency-swales * 100
2
1
11

MONITOR
866
713
976
758
Fullness all GI
global-efficiency-total * 100
2
1
11

SWITCH
1102
811
1295
844
Upstream-bad-neighbor?
Upstream-bad-neighbor?
0
1
-1000

TEXTBOX
723
34
873
52
Flooding Times
13
0.0
1

MONITOR
1096
289
1265
334
Install cost of private GI (dollars)
Cost-install-private-GI
2
1
11

MONITOR
1102
388
1269
433
Install cost of private GI (dollars)
Cost-install-public-GI
2
1
11

TEXTBOX
1024
37
1174
55
Costs
13
0.0
1

TEXTBOX
691
322
841
340
Water Accounting
13
0.0
1

TEXTBOX
608
493
758
511
Green Infrastructure
11
0.0
1

MONITOR
604
349
797
394
Volume (ft^3) of outflow
global-outflow-ft3
2
1
11

MONITOR
604
393
797
438
Volume (ft^3) drained to sewers
global-sewer-ft3
2
1
11

TEXTBOX
607
511
716
530
Total Storage volume
11
0.0
1

TEXTBOX
738
512
844
530
Volume stored
11
0.0
1

TEXTBOX
868
511
951
529
Efficiency
11
0.0
1

BUTTON
1117
767
1289
800
View neighborhood image
Neighborhood-View
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
461
266
595
299
record-movie?
record-movie?
1
1
-1000

SWITCH
924
859
1104
892
Sewer-calibration-run?
Sewer-calibration-run?
1
1
-1000

@#$#@#$#@
To Discuss:


E-mail maps to Tia!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

change outlet height

- test how long it takes the mdoel to run with no inflow limit

Slope:
- Test model with smaller slopes and no slope


- damages - just do % based on water height, don't worry about $

-update extent of flooding tracker and normalize
-have monitor giving a budget update: how much over or under
-select 2 neighborhoods with biggest differences and code in maps (add Palos Heights)
-add creation of jpg at end of the run


Variables - 
- normalize costs by GI budget
- do separate cost normalizations
- swale efficency - just do soil, not water storage

1. Do we want variations on topography? 
2. End of run is 1 day after water stops max
3. Inflow limit
4. Do we care about the % of the landscape that is flooded or only time?
What about the maximum water depth or the maximum water volume that is on the surface?
5. Maintenence coded
6. GI values (storage, install and maintenance costs)
7. Normalization values




## ## LANDSCAPE GREEN INFRASTRUCTURE DESIGN MODEL

(Land-GrID)    
Version 1.0    
October 2010

Moira Zellner, Dean Massey, Lisa Cotner, Emily Minor, Miquel Gonzalez-Meler    
University of Illinois at Chicago

## ## MODEL BACKGROUND

Context    
In the US, there is a growing interest in the adoption of green infrastructure for stormwater management, and state and local governments are considering whether to adopt ordinances and legislation to promote them. This trend emerges from the increasing awareness that the growing area of paved surfaces due to urbanization has put increasing pressure on stormwater management facilities, resulting in higher frequency of combined sewer outflows, floods, and the exposure of residents and habitat to polluted water.     
Green infrastructure, particularly if applied at the site level, (e.g., bioswales, green roofs), would be an acceptable solution to this problem by reducing the amount of stormwater runoff where it is created, so that the landowner contributing to it bears the burden of mitigation.    
While green infrastructure looks like a promising approach for stormwater management, there are many unknowns in terms of how such infrastructure should be built and maintained, at what scale, who should be responsible for monitoring, and what are the appropriate techniques for specific conditions, particularly as urban settlements change over time. Green infrastructure may provide additional environmental benefits (e.g., wildlife habitat), but its effectiveness regarding stormwater management must be fully evaluated before making it required by law.

Modeling Context and Needs    
Numerous tools exist for planners and engineers to model stormwater runoff. The existing modeling tools range from simple site-specific, spreadsheet-based models that estimate runoff amounts (e.g. TR-55, L-THIA, Green Values Calculator), to data-intensive, watershed-scale models with multiple catchment areas that are capable of giving precise estimates of runoff and water quality (e.g. SWMM, AGNPS). With these tools, it is, however, difficult to draw insights about how building green infrastructure affects water outcomes on a regional scale.     
An ideal tool with which to investigate this problem would have a regional scale and be spatially explicit, that is, it would show spatial interactions in surface water flow. Seeing interactions in surface flow is essential to knowing how green infrastructure affects runoff and what the aggregate affects of the surface water flows are. The model needs to be highly customizable and stylized enough so that users can enter minimal new data but still get specific, relevant outputs, not reams of data that is extraneous and difficult to process.

New Model: L-GrID    
L-GrID is a cellular model created for the Illinois Environmental Protection Agency to fit the gaps in existing models and be a simple tool to investigate the effects of different landscape configurations on urban stormwater management on a regional scale. The model allows users to choose storm duration, landscape size, rules for the placement of green infrastructure, sewer configuration, and coverage ratios for different land cover types. After the configuration is set, the user can run simulations and compare the outcomes in terms of water volumes for infiltration, runoff, and accumulated water that remains on the surface.     
Using L-GrID, it is possible to run simulations not to generate specific estimates of runoff for a region, but to compare scenarios and produce generalized principles for green infrastructure design and implementation at the neighborhood or regional scale. These insights can inform the development of appropriate policy recommendations.
     
## ## LANDSCAPE LEGEND AND COVER TYPES

Green cells: Green infrastructure, hereafter GI. Stylized to represent the basic characteristics of some green infrastructure: a high capability to infiltrate water due to engineered soils and an ability to store water on their surface (storage capacity)

Brown cells: Permeable surfaces (lawns, dirt lots, undeveloped land). Moderate capacity to infiltrate water, cannot store water.

Grey cells: Impervious cover (e.g. parking lots, buildings). Cannot infiltrate or store water. Includes cells with sewers (the round, black circles) and roads (cells with yellow dots), and the outlet cell through which water can flow out of the landscape (red triangle)

## ## INTERFACE EXPLANATION

## ## LANDSCAPE SETUP

     
World Dimensions: This variable controls the number of cells on each side of the landscape. The default size of cells is 10m x 10m. Set to 100, the minimum value on the slider, it would result in a 100 x 100 cell grid or a world of 1km^2. The landscape view on the interface will readjust itself during setup to display the appropriate size. The model performed similarly with 1km^2 and 2km^2 areas, meaning it is not sensitive to scale at this range of values.

Road Spacing: This variable controls the size of the blocks. With it set to 12, the recommended starting setting, the program will create blocks that are 10 x 22 cells, or 100m x 220m. These are approximate dimensions of the city blocks in Chicago. When the slider is set to n, it will create rectangular blocks that are (n - 2) by ((n * 2) � 2) cells. Roads are two cells wide.
     
Activate Outlet: This switch turns the outlet cell (in the bottom corner) on or off. When it is on, all water that is on the cell after the surface flow happens leaves the landscape and is recorded as outflow. The outlet was added to simulate the landscape being a real watershed.
     
Slope Percent: The slope of the landscape is oriented toward the outlet cell. This chooser box allows the user to set the grade of the slope (as a percent). We chose .25% as a starting slope based on examinations of watersheds in northeastern Illinois.
     
Curbs: This switch turns curbs on or off. If curbs are on, the road cells are 150mm lower than the interior of blocks. If GI cells are next to road cells then they are also 150mm lower than the interior of blocks. If curbs are off, then roads and GI are all on the same elevation.    
2.2.2 Land Cover Configuration
     
Percent GI: This slider sets the percentage of the total number of cells that will be green infrastructure. This slider can go no higher than 50%.
     
Percent Impervious : This slider sets the percentage of the total number of cells (including roads) that will be impervious cover. We used 50% as an approximation of impervious cover in Cook County, excluding forest preserves.  Moving the slider from 50% would require recalibrating the sewers.    
The percentage of cells that are permeable are set by subtracting the values on the two sliders above from 100.    
We recommend using values around 50%, the level for which the sewers are calibrated. The slider only allows values from 45% to 55%.    
The sum of the percent GI and percent impervious sliders may be higher than 100%. 
     
GI Location: This chooser box allows the user to choose where the green infrastructure can be located. Options for GI layouts are:    
Anywhere: Completely random placement of GI. If green infrastructure cells are next to roads, the GI cells� elevations are reduced by 150 mm to simulate curb cuts that would allow water to flow from the road to the GI cells.    
Only next to roads: Randomly located on any cell that borders a road cell. They also have elevations reduced by 150mm.    
Not next to roads: GI cells are only located away from road cells in a random pattern.    
Upstream: Located as far away as possible from the outlet.    
Downstream: Located as close to the outlet as possible.    
2.2.3 Storm Setup
     
Storm Hours: The user can choose the storm duration from the slider. Longer durations reduce the intensity of rainfall. For simulations we used only 24-hour storms.
     
Storm Type: This chooser allows the user to select the magnitude of the storm event, from 2-, 5-, 10-, 25-, and 100-year storms. This selection, along with the storm hours, determines the rainfall rate. For example, a 1-hour, 100-year storm produces a total of 76mm of rain but a 24-hour, 100-year storm produces a total of 145mm of rain. Rainfall amounts are taken from the Chicago Stormwater Ordinance. Longer storm durations decrease the intensity but increase the total volume of rainfall.

## ## SEWER SETUP

     
Activate Sewers: This toggle switch turns the sewer intakes on or off. If it is turned off, the other sewer variables in this section are irrelevant.
     
When Sewers Full: This determines what happens if the sewers reach their capacity. Users can choose no-CSO, which disallows combined sewer overflows (CSOs) and causes the sewer intake to be severely reduced- possibly causing street flooding, or allowing CSOs, which makes it so that excess water in the sewer system flows out of the system (into another water body, which is not simulated by this model) and leave the sewer intake unrestricted by capacity.
     
Sewer Spacing: Sets how far apart the sewer cells are on the landscape. Every nth cell on a road will be a sewer intake cell, on alternating sides of the street.    
Sewer Disclaimers:    
For the sewer setup to work properly, make sure that the sewer spacing number is a divisor of the value on the road spacing slider.    
The sewers are calibrated for landscapes that are 50% impervious cover. We do not recommend using a coverage that is far from that percentage. Using other values would require recalibration of the amount of water that sewers can handle before they fill and their intake rate is reduced.    
We also calibrated sewers for landscapes that are at least 1km^2 in area. They may work properly for landscapes that are smaller, but below an unknown threshold, an unrealistic volume of water leaves through the outlet and a recalibration of sewer rates and capacity is advised.
     
## ## RUNNING THE MODEL

## ## BASICS

     
The very basic way to run this model is to:    
1. Select configurations for sliders, switches, and choosers. We recommend these settings to start with:    
outlet?	on    
sewers?	on    
Slope-percent .25%    
curbs? on    
percent-impervious 50%    
road-spacing 12    
sewer-spacing 6    
when-sewers-full No-CSO    
and then randomly choose settings for the options not listed in the table.

Next:    
2. Press the �setup landscape and processes� button.    
3. Press the �go until stop conditions met� button.

## ## SETUP OF LANDSCAPE AND PROCESSES

Prior to running the model, it is necessary to hit the setup button. This gets the model ready to run by setting up the landscape, land covers, and sewers. It also calculates initial values required for infiltration and sets the rates for rainfall, evaporation, and evapotranspiration. Here are some of the variables set during the setup:    
Evaporation 3.5625 mm/day    
Evapotranspiration 1.66 mm/day    
Sewer Catchment Basin Volume 9.477 m^3    
Sewer Intake Rate 0.00015534004 m^3 per m^2 per minute over the entire landscape    
Stormwater Treatment Rate .0000018563 m^3 per m^2 per minute over the entire landscape

## ## GO FOR 1 ITERATION ONLY

Causes the program to move through one complete iteration. Each iteration is 1 minute and during each, there are 3 subroutines in which all of the 7 major processes are done. This means, essentially, there are subroutines of 20 seconds.

## ## GO UNTIL STOP CONDITIONS MET

The model will run until one of two conditions is met. After the precipitation ends, the model will run until the surface water, not including any water in green infrastructure storage, is gone or for two additional days, whichever condition comes first.

## ## PROCESSES

There are seven basic processes that happen within the model. First, it rains, then water infiltrates into the soil, goes into sewer intakes, evaporates from the surface, evapotranspires from the soil, flows across the surface, and then flow out of an outlet drain. The processes affect each of the cover types differently. The model�s iterations are 1 minute in length and within that minute, all of the processes are repeated three times each, meaning that there are 20 second subroutines.
     
## ## RAIN

The volume and intensity of rain is based upon Chicago rainfall data.  Precipitation in this model is a steady-state process, meaning that during the storm, the amount of rain that falls remains.

## ## INFILTRATION

GI and permeable cells infiltrate water based on their soil type and how much water has previously infiltrated during a storm. The Green-Ampt formula is used to determine the infiltration amounts at each time step.  Refer to the information below for cover-specific variables that relate to infiltration. 

Green Infrastructure    
Soil type: loamy sand     
Storage Capacity 200 mm    
Capillary Suction 61.3 mm    
Initial Moisture Deficit 0.312    
Saturated Hydraulic Conductivity 59.8 mm/hr    
Maximum Infiltration Amount 561.6

Impervious    
Soil type: n/a    
Storage Capacity 0    
Capillary Suction n/a    
Initial Moisture Deficit n/a    
Saturated Hydraulic Conductivity n/a    
Maximum Infiltration Amount n/a

Permeable    
Soil type: silty clay loam    
Storage Capacity 0    
Capillary Suction 273 mm    
Initial Moisture Deficit 0.105    
Saturated Hydraulic Conductivity 2 mm/hr    
Maximum Infiltration Amount 210

Some sample values for other soil types are avaialble at: http://www.water-research.net/Waterlibrary/Stormwater/greenamp.pdf

## ## SEWERS

The intake rate is based on the cubic feet per second rate allowed for Chicago  and the number of sewer cells in the landscape. The sewers are calibrated to maintain a constant intake rate per hectare regardless of the sewer spacing, so if there are fewer sewers they will intake water at a faster rate. Sewer cells have a catchment basin where some water can be stored locally before entering the sewer system�s pipes on its way to a treatment plant. The total capacity of the system is set based on the amount of water that enters the sewers during a 24-hour, 5-year storm, with 0% GI and 50% impervious cover. Water is drained from the system based on the treatment capacity of the Stickney MWRD plant and the amount of land for which it treats water. 

## ## EVAPORATION

After the end of the storm, water can evaporate from any cell with surface water. The rate is based on pan evaporation rates from the Chicago area in June. 

## ## EVAPOTRANSPIRATION

Infiltrated water evapotranspires due to plants on GI and permeable cover cells. 

## ## SURFACE FLOW

Based upon the total heights of cells (elevation + water depth) and of their neighbors. Actual flow amounts are set based upon the amount available on the cells and the differences in water depths. 

## ## OUTFLOW

Any water on the outlet cell leaves the model and is recorded as outflow. 

## ## OUTPUTS

## ## VISUALS

     
Data Visualized: This allows the user to choose how the water levels on the cells are visualized.

None: No updates to the display from the setup or after it is selected during a run. It increases the speed of a simulation.

Accumulated water not including storage capacity: Shows the accumulated water on the surface, not including water in the green infrastructure storage. The color ramp ranges from white (very little water), to black (deep water). The actual values that the colors represent changes depending on the total amount of rain that will fall during the storm event, so comparisons across runs using only the color of patches may be misleading. Cells with no water revert to the color corresponding to their cover type.

Accumulated water not including storage capacity-relative colors: Same as above, except the colors are scaled relative to the highest water level on any cell in the landscape. This may result in more pronounced color differences but there may also be sudden changes as relative differences shift. Cells with no water revert to the color corresponding to their cover type.
     
Cover type: Reverts back to the starting setting where just the colors corresponding to the cover types are shown.
     
Elevation and water: Same as the option �accumulated water not including storage capacity� except it sums the underlying elevation and water column for each cell and visualizes that level.
     
Elevation: Shows only the underlying elevation of the terrain, with white the highest and black the lowest. This visualization will not change during a model run.
     
Flooded-cells: A binary display of whether cells are flooded. Flooded cells (water columns over 1cm) are blue and unflooded cells are grey. Water in green infrastructure storage capacity is not included in flooding.

## ## GRAPHS

The graphs are intended to help the user understand what happens to the water during the run.
     
Water Accounting by Time Step: Shows what happens to the water at each time step, with separate trackers for rain and each possible water outcome: infiltration into green infrastructure, infiltration into permeable land, and outflow into sewers or through outlet or as a combined sewer overflow.
     
Percentage of Patches Flooded: A tracker shows the percentage of cells at each time step that have more than 1cm of accumulated water, excluding water in GI storage.  

Average Depth of Accumulated Water on Each Cell: Shows the average depth of accumulated water on all cells and on road cells in millimeters. Does not include water in green infrastructure storage capacity.
     
Capacity of Infrastructures Used: Shows the cumulative percentage of GI storage capacity and sewers capacity that is currently being used. A line is automatically drawn at 100% to keep the scale of the graph consistent throughout the run.

## ## MONITORS

     
These monitors allow the user track what happens to the precipitation during a run. Only the major processes are listed (infiltration (broken down into volume infiltrated by GI and Non-GI cells), sewer intake, outflow, and then any remaining accumulated water on the surface). The surface flow procedure introduces rounding errors when calculating flow amounts, causing small discrepancies between the water entering the model through precipitation and the water accounted for through infiltration, outflow, sewers, storage, and surface water. The Cumulative Margin of Error tracker measures this error as a percentage of cumulative precipitation. A negative value means there was a net creation of extra water and a positive value means that water has disappeared from the model. It is unavoidable that there is some error, due to the fact that flow is only really an approximation. With landscapes at least 1km^2 in area, error should be under 10%.

## ## THINGS TO TRY

Experiment with different storm durations and magnitudes.    
Try all of the different GI placement options and see how they affect the results.    
Use different percentages of GI and impervious cover.    
Try turning on the "allow CSO" option under the "when-sewers-full" chooser
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

barrel
false
3
Circle -13840069 true false 75 135 150
Rectangle -13840069 true false 75 90 225 210
Circle -6459832 true true 75 15 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

circle 3
true
0
Circle -7500403 false true 30 30 240
Circle -7500403 false true 44 44 212

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

paver
false
0
Rectangle -7500403 true true 0 0 300 300
Rectangle -7500403 false true 60 15 60 300
Rectangle -10899396 true false 15 0 30 300
Rectangle -10899396 true false 90 0 105 300
Rectangle -10899396 true false 0 45 285 45
Rectangle -10899396 true false 0 270 300 285
Rectangle -10899396 true false 165 0 180 300
Rectangle -10899396 true false 240 0 255 300
Rectangle -10899396 true false 0 195 300 210
Rectangle -10899396 true false 0 120 300 135
Rectangle -10899396 true false 0 45 300 60

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

roof
false
6
Polygon -10899396 true false 150 285 285 225 285 75 150 135
Polygon -13840069 true true 150 135 15 75 150 15 285 75
Polygon -10899396 true false 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

swale
false
3
Rectangle -10899396 true false 0 0 300 300
Rectangle -6459832 true true 30 30 270 270

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="hybrid" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hybrid2" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="random" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;anywhere&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hybrid5" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="updown5" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="roads5" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="5anywhereroads" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;anywhere&quot;"/>
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="5updownhybrid" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="15anywhereroads" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;anywhere&quot;"/>
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="15updownhybrid" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="20anywhereroads" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;anywhere&quot;"/>
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="20updownhybrid" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="10updown" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="10curbs" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="10random" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;anywhere&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="3564" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;anywhere&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="5yr" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;anywhere&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="100yr" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;anywhere&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="1" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;anywhere&quot;"/>
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="30" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;anywhere&quot;"/>
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="50" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;anywhere&quot;"/>
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="new1-1" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;max impervious catchment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sc-100" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
      <value value="&quot;max impervious catchment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sc-300" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
      <value value="&quot;max impervious catchment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="300"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LandCover5-new" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;max impervious catchment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LandCover100-new" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;max impervious catchment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LandCover100-sens" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="100"/>
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;max impervious catchment&quot;"/>
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LandCover5-sens" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="100"/>
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;max impervious catchment&quot;"/>
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Scens-10" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Scens-15" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;max impervious catchment&quot;"/>
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Scens-20" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;max impervious catchment&quot;"/>
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;not next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="100Sensit" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="190"/>
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;max impervious catchment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="5Sensit" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="190"/>
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;max impervious catchment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="iaway10" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;not next to roads&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="iaway15" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;not next to roads&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="iaway20" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;not next to roads&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="new10" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="new15" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="new20" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="n10u" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;upstream&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="n15u" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;upstream&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="n20u" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;5-year&quot;"/>
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;upstream&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="n100-15" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="n100-20" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="new20--2" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;downstream&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="n100-10" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="new1015----h" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;only next to roads&quot;"/>
      <value value="&quot;upstream&quot;"/>
      <value value="&quot;downstream&quot;"/>
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="new1015----hybr" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>global-infiltration</metric>
    <metric>global-GI-infiltration</metric>
    <metric>global-Non-GI-infiltration</metric>
    <metric>global-evapo</metric>
    <metric>global-sewer</metric>
    <metric>global-outflow</metric>
    <metric>accumulated-water</metric>
    <metric>cumulative-margin-of-error</metric>
    <metric>max-flooded</metric>
    <metric>global-precipitation</metric>
    <metric>global-evapotrans</metric>
    <metric>global-sewer-drain</metric>
    <metric>average-water-height</metric>
    <metric>average-water-height-roads</metric>
    <metric>water-in-pipes</metric>
    <metric>above-0-accumulated-water</metric>
    <metric>water-in-storage</metric>
    <enumeratedValueSet variable="world-dimensions">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Storm-type">
      <value value="&quot;100-year&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curbs?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-impervious">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Slope-percent">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data-visualized">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storage-capacity-mm">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-GI">
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="storm-hours">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="road-spacing">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-sewers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sewer-spacing">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GI-Location">
      <value value="&quot;hybrid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="activate-outlet?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-sewers-full">
      <value value="&quot;no-CSO&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
