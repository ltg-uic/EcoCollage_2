extensions [mysql sql]

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
  
  ;; The next are used by Tia's code for the SQL extension and to identify the run information  
  db
  query
  runID
  studyID
  efficiencyList
  interventionMap
  maxWaterHeightList
  waterHeightList
  elevationGradient
  maximum-monetary-damage
  Good-neighbor-calibration-run?
  max-depth-water
  configure?

  configuration-run?
  data-visualized
  Flow-limit?
  Neighborhood-type

  good-neighbor-inflow-list
  outflow-list
  good-neighbor?
  bad-neighbor?
  max-water-in-pipes
    max-possible-GI-cost
    Sewer-calibration-run?
    Upstream-neighbor?
  ;; Formerlt sliders, switches, or choosers.
;  Sewer-calibration-run?
  Outlet-control-height
;  GI-placement
  Number-inlets
  Starting-soil-saturation
  Starting-fullness-GI-extra-storage
  Starting-fullness-of-sewers-percent
  Extreme-flood-definition
  Flood-definition
;  when-sewers-full
  activate-outlet?
  Sewer-intake-regulator?
  Vary-landscape?
  Repetitions-per-Iteration
  Blocks-vertical
;  Storm-type
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
;  GI-Budget
  public-install-budget-sentence
  private-install-budget-sentence
  public-maintenance-budget-sentence
  private-maintenance-budget-sentence
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
  cell-dimension-m            ;; The width of the dquare in m
  road-width-m                ;; the width of a road in meters
  
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
  global-cso-ft3
  
  potential-rain
  
  ;; Metrics!
  Cost-install-private-GI
  Cost-install-public-GI
  Cost-total-install
  Cost-private-maintenance
  Cost-public-maintenance
  Cost-total-maintenance
  Cost-private-property-damage
  Cost-public-property-damage
  Cost-stormwater-treatment

   
  
  Normalized-Cost-install-private-GI
  Normalized-Cost-install-public-GI
  Normalized-Cost-total-install
  Normalized-Cost-private-maintenance
  Normalized-Cost-public-maintenance
  Normalized-Cost-total-maintenance
  Normalized-Cost-private-property-damage
  Normalized-cost-public-property-damage
  Normalized-cost-stormwater-treatment
  
  
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
  
  
  global-standing-water
  greatest-depth-standing-water
  
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
  Normalized-global-inflow-ft3
  Normalized-global-sewer-ft3
  Normalized-global-standing-water-ft3
  Normalized-greatest-depth-standing-water-ft
  
  Normalized-global-rain-barrel-ft3
  Normalized-global-green-roof-ft3
  Normalized-global-green-alleys-ft3
  Normalized-global-swales-ft3
  Normalized-global-GI-total-ft3
  
  Normalized-global-GI-infiltration-ft3
  Normalized-global-GI-total

  
  
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
  
  remaining-private-install-budget
  remaining-public-install-budget
    
  maintenance-a-paver
  maintenance-a-swale
  maintenance-a-roof
  maintenance-a-barrel
  
  
  Private-Install-Budget-dollars
  Public-install-budget-dollars
  Private-maintenance-budget-dollars
  Public-maintenance-budget-dollars

  
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
  
  outlet-longitudinal-slope
]

patches-own [
  
  intersection?
  flood-depth-feet
  
  ;;; for the outlet and movement 
  max-flow-height
  max-flow-volume
  longitudinal-slope
  
  roughness
  mannings-coefficient
  
  velocity
  channel-width
  water-depth
  hydraulic-radius
  cross-sectional-area
  wetting-perimeter
  cover
  Public?
  Private?
  base-color
    
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
  storage-capacity            ;; the potential amount of water that can stay behind on a cell in storage rather than flowing. Constant.
  water-in-swale
  count-sewer-inlets                   ;; yes/no whether the cell contains a storm sewer. Constant.
  outflow?                    ;; yes/no whether the cell is the outflow cell.  Constant.
  inflow?
  height-in-sewer-basin       ;; height in mm of water in the sewer catchment basin, if the basin had the same dinemsions of the cells.
  
  
  Neighbor-Elevation-list ; A list of the patch's neighbors sorted by elevation (small to large)
  
    ;;; new
  GI?
  type-of-GI       ;; rain barrel, swale, permeable pavement, greenroof
  
  max-extra-GI-storage
  extra-GI-storage
  install-cost-here
  maintenance-cost-here
  
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
  
  highest-water-level
  
  depth-to-flood
  percent-damage-structure
  percent-damage-contents
  damage-in-dollars
  
]
;; Sets variables that belong to agents.  Empty because we use agents (turtles) as graphics to show green infrastructure, roads, sewers, and the outlet, and they have no variables of their own.
turtles-own [
]

;; Sets initial model conditions
to setup
  clear-all
  
  setup-globals ;; This sets up numerous global-level variables needed for other processes
  
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
  
  ;; setup the colors and icons that show green infrastructure, sewers, roads, and the outlet
  setup-colors
  setup-agents
  
  
  setup-flow-values ;; Values used in Manning's equations to determine flow volumes
  
  if record-movie? = true [
    ;let movietitle word date-and-time ".mov"
     movie-start (word (word "results" (remove "-" (remove " " (remove "." (remove ":" date-and-time)))) ".mov"))
  ]
  
  ifelse Normalization-calibration-run? = false and Good-neighbor-calibration-run? = false and Outflow-calibration-run? = false and Sewer-calibration-run? = false [
    ;; Not a calibration run, so use recorded value from the calibration run as the max damages
    file-open "maximum-damages.txt" ;; file-open (word (word "run" behaviorspace-run-number (remove "-" (remove " " (remove "." (remove ":" date-and-time)))) ".txt"))  
    set Maximum-monetary-damage precision file-read 2
;    type "max damages for normalilization = " print Maximum-monetary-damage
    file-close
    
    file-open "maximum-depth.txt"
    set max-depth-water precision file-read 2
    file-close
    
  ]
  
  [
    ;; This means it is a calibration run in some way, so use 1 for now; normalization of damages will not be used
    set Maximum-monetary-damage 1
    set max-depth-water 1
  ] 
  if Outflow-calibration-run? = true [
    if file-exists? "outflow-calibration-values.txt" [ 
      file-delete "outflow-calibration-values.txt" 
    ]
    file-open "outflow-calibration-values.txt" ;; file-open (word (word "run" behaviorspace-run-number (remove "-" (remove " " (remove "." (remove ":" date-and-time)))) ".txt"))  
  ]
  if Good-neighbor-calibration-run? = true [
    if file-exists? "good-neighbor-calibration-values.txt" [ 
      file-delete "good-neighbor-calibration-values.txt" 
    ]
    file-open "good-neighbor-calibration-values.txt" ;; file-open (word (word "run" behaviorspace-run-number (remove "-" (remove " " (remove "." (remove ":" date-and-time)))) ".txt"))  
  ]
  
  reset-ticks
end

to setup-globals 
  ;; This sets up numerous variables that are used in many processes, often by many processes.
  ;; This should be reorganized later to see if some can be moved to places where they would be better fits, but leave here for now to make sure thet are set before they are needed
  if Storm-duration = "1-hour" [ set storm-hours 1 ]
  if Storm-duration = "2-hour" [ set storm-hours 2 ]
  if Storm-duration = "3-hour" [ set storm-hours 3 ]
  if Storm-duration = "6-hour" [ set storm-hours 6 ]
  if Storm-duration = "12-hour" [ set storm-hours 12 ]
  if Storm-duration = "24-hour" [ set storm-hours 24 ]
  
  set configure? Outflow-calibration-run? OR Normalization-calibration-run? 
  if configure? = false [
   set configure? not MYSQL?
  ]
  
  set data-visualized "flooding definitions" ;"flooding definitions" ; "elevation"
  set Neighborhood-type "Blue Island - Import"
  set Flow-limit? "all-equilibrium"
  set Sewer-calibration-run? false
;  set Sewer-calibration-run? false
  ;;; Variables formerly sliders
  set Number-inlets 3
  set Starting-soil-saturation 0
  set Starting-fullness-GI-extra-storage 0
  set Extreme-flood-definition 6
  set Flood-definition 1
;  set when-sewers-full "no-CSO"
  set Sewer-intake-regulator? false
  set Good-neighbor-calibration-run? false
  set Repetitions-per-Iteration 1
  set Blocks-vertical 1
  ;  ifelse Sewer-calibration-run? = true [
  ;    set Storm-type "5-year"
  ;  ]
  ;  [
  ;    set Storm-type "100-year"
  ;  ]
  set efficiencyList ""
  set waterHeightList ""
  set maxWaterHeightList ""
  set elevationGradient ""
  set interventionMap ""
   
  ifelse Normalization-calibration-run? = false and Good-neighbor-calibration-run? = false and Outflow-calibration-run? = false and Sewer-calibration-run? = false [
    set configuration-run? false    
  ]
  [
    set configuration-run? true 
  ]
  
  set Starting-fullness-of-sewers-percent precision ( 1 - ( Initial-sewer-capacity / 100 ) ) 2
    
  if Neighbor-option = "No neighbor inflows" [
    set Upstream-neighbor? false
    set good-neighbor? false
    set bad-neighbor? false
  ]
  if Neighbor-option = "Fixed neighbor inflows (bad neighbors)" [
    set Upstream-neighbor? true
    set good-neighbor? false
    set bad-neighbor? true
  ]
  
  if Neighbor-option = "Neighbors install same GI as here, possible inflow reductions (good neighbors)" [
    set Upstream-neighbor? true
    set good-neighbor? true
    set bad-neighbor? false
  ]
  if Outflow-calibration-run? = true [
    set Upstream-neighbor? false
    set good-neighbor? false
    set bad-neighbor? true
  ]
  if Good-neighbor-calibration-run? = true [
   set Upstream-neighbor? true
   set good-neighbor? false
   set bad-neighbor? true
  ]
;  set storm-hours 24
  set percent-impervious 60
  set Vary-landscape? false
  set Slope-percent 0.08
  set %-landscape-swale 5
  set GI-concentrated-near-outlet 30
  set %-impermeable-rain-barrels 5
  set %-impermeable-green-roof 5
  set Green-Alleys? true
  set activate-sewers? true
  set curbs? true
  set activate-outlet? true
;  set GI-Budget 10000000
  set max-possible-GI-cost 51122645.16
  set Type-to-Place "Swales"
;  set GI-placement "Imported" ;;"User selected" "Sliders" "Imported"
  set Outlet-control-height 6 ;; in inches
  
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
  if Neighborhood-type = "Dixmoor" or Neighborhood-type = "Dixmoor - Import"[
    set world-dimensions-vertical ( ( Blocks-vertical * 19 ) + 1 ) ;; 17 lots vertical
    set world-dimensions-horizontal ( ( Blocks-vertical * 19 ) + 2 )
    set road-spacing-vertical 19
    set road-spacing-horizontal 10
  ]
  
    
    
  if Neighborhood-type =  "Morrill School - 13 x 7 6 blocks" or Neighborhood-type = "Morrill School - Import" [
    set world-dimensions-vertical ( ( Blocks-vertical * 2 * 14 ) + 1 ) ;; 17 lots vertical
    set world-dimensions-horizontal ( ( Blocks-vertical * 3 * 7 ) + 4 )
    set road-spacing-vertical 14
    set road-spacing-horizontal 8
  ]
  
  if Neighborhood-type =  "Blue Island - Import" [
    set world-dimensions-vertical 25
    set world-dimensions-horizontal 23
    set road-spacing-vertical 8
    set road-spacing-horizontal 10
  ]
  
  
  ;; Set the size of the landscape to match the dimensions on the world-dimensions slider
  resize-world 0 ( world-dimensions-horizontal - 1 ) 0 ( world-dimensions-vertical - 1 )
    
  set cubic-m-to-cubic-ft 35.3147

  set Private-Install-Budget-dollars Private-Install-Budget * 1000
  set Public-install-budget-dollars Public-install-budget * 1000
  set Private-maintenance-budget-dollars Private-maintenance-budget * 1000
  set Public-maintenance-budget-dollars Public-maintenance-budget * 1000


;  set max-damage-cost 94305
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
  set cell-dimension 12405.4 ; in mm.
  set cell-dimension-m cell-dimension / 1000
  set road-width-m cell-dimension-m
  set storm-length ( storm-hours * 60 ) ;; converting the storm length from hours to minutes
  set stop-tick 2880 ; storm-length + 1440 ;; setting the maximum length of a simulation is the surface water does not dry first. max length is 2 days beyond the end of a storm.
  set conversion-multiplier ( ( cell-dimension ^ 2 ) / 1000000000 ) ;; used to convert from cell-specific units to m^3.
  
end

;; Sets amount of rain that will fall during a storm with a given statistical frequency and a given duration
to setup-storm-type
  
  if storm-type = "1-year" [
    if storm-hours = 1 [ set total-rainfall 29.972 ]
    if storm-hours = 2 [ set total-rainfall 35.56 ]
    if storm-hours = 3 [ set total-rainfall 37.846 ]
    if storm-hours = 6 [ set total-rainfall 45.212 ]
    if storm-hours = 12 [ set total-rainfall 52.324 ]
    if storm-hours = 24 [ set total-rainfall 61.722 ]
  ]
  
  if storm-type = "2-year" [
    if storm-hours = 1 [ set total-rainfall 36.576 ]
    if storm-hours = 2 [ set total-rainfall 43.18 ]
    if storm-hours = 3 [ set total-rainfall 46.228 ]
    if storm-hours = 6 [ set total-rainfall 55.372 ]
    if storm-hours = 12 [ set total-rainfall 63.754 ]
    if storm-hours = 24 [ set total-rainfall 74.93 ]
  ]

  if storm-type = "5-year"[
    if storm-hours = 1 [ set total-rainfall 45.72 ]
    if storm-hours = 2 [ set total-rainfall 54.61 ]
    if storm-hours = 3 [ set total-rainfall 58.928 ]
    if storm-hours = 6 [ set total-rainfall 71.12 ]
    if storm-hours = 12 [ set total-rainfall 81.28 ]
    if storm-hours = 24 [ set total-rainfall 95.758]
  ]
  
  if storm-type = "10-year" [
    if storm-hours = 1 [ set total-rainfall 52.832 ]
    if storm-hours = 2 [ set total-rainfall 63.246 ]
    if storm-hours = 3 [ set total-rainfall 68.58 ]
    if storm-hours = 6 [ set total-rainfall 84.328 ]
    if storm-hours = 12 [ set total-rainfall 96.012 ]
    if storm-hours = 24 [ set total-rainfall 113.03 ]
  ]
  
  if storm-type = "25-year" [
    if storm-hours = 1 [ set total-rainfall 62.484 ]
    if storm-hours = 2 [ set total-rainfall 75.438 ]
    if storm-hours = 3 [ set total-rainfall 82.042 ]
    if storm-hours = 6 [ set total-rainfall 103.632 ]
    if storm-hours = 12 [ set total-rainfall 117.348 ]
    if storm-hours = 24 [ set total-rainfall 138.176 ]
  ]
 
  if storm-type = "50-year" [
    if storm-hours = 1 [ set total-rainfall 70.104 ]
    if storm-hours = 2 [ set total-rainfall 85.344 ]
    if storm-hours = 3 [ set total-rainfall 92.964 ]
    if storm-hours = 6 [ set total-rainfall 120.142 ]
    if storm-hours = 12 [ set total-rainfall 135.382 ]
    if storm-hours = 24 [ set total-rainfall 159.512 ]
  ]
  
  if storm-type = "100-year" [
    if storm-hours = 1 [ set total-rainfall 78.232 ]
    if storm-hours = 2 [ set total-rainfall 95.758 ]
    if storm-hours = 3 [ set total-rainfall 104.648 ]
    if storm-hours = 6 [ set total-rainfall 137.922 ]
    if storm-hours = 12 [ set total-rainfall 154.94 ]
    if storm-hours = 24 [ set total-rainfall 182.88 ]
  ]

  if Sewer-calibration-run? [
    set total-rainfall 77.216 ;; 3.04" - per John Watson - 7/25/14. 2-year, 24-hour storm for NE Illinois, taken from ISWS Bulletin 70
  ]

end

to setup-costs
  ;; Costs
  ;; All costs are in dollars
  ;; For rain barrels, the cost is for one rain barrel. For all other types, the cost is calculated 
  ;; Costs are relative to the cell size
  let cell-area cell-dimension-m * cell-dimension-m
  set cost-a-permeable-paver precision ( cell-area * 114.33 ) 2
  set cost-a-green-roof precision ( cell-area * 123.55 ) 2
  set cost-a-swale precision ( cell-area * 84.12 ) 2
  set cost-a-rain-barrel 125
  set maintenance-a-paver precision ( cell-area * .25 ) 2
  set maintenance-a-roof precision ( cell-area * .74 ) 2 
  set maintenance-a-swale precision ( cell-area * 2.39 ) 2
  set maintenance-a-barrel 0
end

;; Defines landcover for all cells, sets up the cover specific variables
to setup-land-cover
  
  setup-elevation

  ;; sets up roads
  
  if Neighborhood-type =  "Morrill School - Import" [
    
    file-open "MorrillSchool2.txt"
    let cover-list file-read
    ( foreach sort patches cover-list
      [ ask ?1 [
        set cover ?2
      ] ] )
    file-close 
  ] 
  
  if Neighborhood-type =  "Blue Island - Import" [
    
    file-open "BlueIsland2.txt"
    let cover-list file-read
    ( foreach sort patches cover-list
      [ ask ?1 [
        set cover ?2
      ] ] )
    file-close 
  ]
     
    
  setup-roads
  
  ;; Create a single outflow cell in the lower left corner of the landscape
  ask patch (max-pxcor) (0) [
    set outflow? true
  ]
  if Upstream-neighbor? = true[
    if Number-inlets = 1 [
      ask patch 0 max-pycor [
        set inflow? true
      ]
    ]
    if Number-inlets = 3 [
      ask patch 0 max-pycor [
        set inflow? true
      ]
      ask patch 0 0 [
        set inflow? true
      ]
      ask patch max-pxcor max-pycor [
        set inflow? true
      ]
    ]
  ]
  ;; sets all cells to cover-type 2 first, which is the impermeable surface
    
    
  ;; determining which set of rules to use for GI placement based on the GI-Location chooser
  ;; the options can be divided into two basic classes.
  ;; the first class:
  
  ifelse Neighborhood-type = "Morrill School - Import" [
    ask patches with [ cover != "r" ] [
      
      
      ifelse ( pxcor > 8 and pxcor < 16 and pycor > 14 and pycor < 28 )
      ;or 
      [
        set public? true
        set private? false
      ]
      [
        ifelse cover = "a" [
          set public? true
          set private? false
        ]
        [
          set public? false
          set private? true
        ]
      ]
    ]
  ]
  [
    ask patches with [ cover != "r" ] [
      
      ifelse cover = "a" [
        set public? true
        set private? false
      ]
      [
        set public? false
        set private? true
      ]
      
    ]
  ]
  
  Setup-GI
  
  
  assign-cell-data
  
  ;; Now creating lists of patches sorted by elevation (small to large) for the overall landscape and of each patches neighbors.
  set Landscape-Elevation-list sort-on [ elevation ] patches
  ;  show Landscape-Elevation-list
  ask patches [
    set Neighbor-Elevation-list sort-on [ elevation ] neighbors4
    ;  print ""
    ;  show Neighbor-Elevation-list
  ]
  
  
      
  
end

to setup-elevation
  ;; create an underlying slope in the base elevation of cells that slopes downwards to the lower left (southwest) corner of the landscape
  ifelse Neighborhood-type != "Blue Island - Import" [
    ask patches [
      ;; Create an elevation multiplier, which is the distance from the outlet to create a smooth slope
      let elevation-multiplier distance patch (max-pxcor) (max-pycor)
      ;; adjusts the elevation of all cells based upon the slope-percent, set by a slider, and the elevation-multiplier.    
      set elevation 327 + ( elevation-multiplier * ( Slope-percent / 100 ) * cell-dimension  ) ;; 350 as base because 127 subtracted for roads and 200 subtracted for swales
    ]
  ]
  [
    file-open "BIElevation.txt"
    let elevation-list file-read
    ( foreach sort patches elevation-list
      [ ask ?1 [
        set elevation ?2
      ] ] )
    file-close 
    
  ]
  ask patches [
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
  
  if curbs? = true [
    
    ask patches [
      if cover = "r" [
        ;; roads
        

        ifelse all? neighbors4 [ cover = "r" ] [
          ;; Intersection
          set elevation elevation - 127 ;; 127 is 5" in mm
          set intersection? true
          
        ]
        [
          ;; not intersection
          set elevation elevation - 127 ;; 127 is 5" in mm
          set intersection? false
        ]
      ] 
    ]     
  ]
   
  set list-non-roads-or-alleys patches with [ cover = "p" or cover = "i" or cover = "b" ]
end

to Setup-GI
  
  ;; Setting GI to be false in all patches first.
  ask patches [
    set GI? false  
  ]
  
  set volume-a-rain-barrel 0.227125 ;; volume of  gallon rain barrel in cubic meters. this is fix regardless of cell size
  set volume-a-green-roof 25.4 * conversion-multiplier ;; Volume of water that can be stored in 4 inches of soil on a green roof - assuming 1 inch (25.4 mm) of water can be stored. converted to volume based on cell area
  set volume-a-paver 0.38 * 609.6 * conversion-multiplier ;; Volume of water that can be stored in soil of GI - initial-moisture-deficit * max-wet-depth
  set volume-a-swale (( 0.346 * 714.4 ) ) * conversion-multiplier ;; 82.28 ;; This is 622.8 mm max infil value of the engineered soil.

  set volume-a-rain-barrel-ft3 volume-a-rain-barrel * cubic-m-to-cubic-ft
  set volume-a-green-roof-ft3 volume-a-green-roof * cubic-m-to-cubic-ft
  set volume-a-paver-ft3 volume-a-paver * cubic-m-to-cubic-ft
  set volume-a-swale-ft3 volume-a-swale * cubic-m-to-cubic-ft
  
  let rain-barrel-volume-to-height-m volume-a-rain-barrel / ( cell-dimension-m * cell-dimension-m )
  ;show rain-barrel-volume-to-height-m
  set rain-barrel-storage rain-barrel-volume-to-height-m * 1000
  ;show rain-barrel-storage
  
  ;; 0 = swale, 1 = rain barrel, 2 = green roof 3 = permeable alley
  
  file-open GI-Import-scenario
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
    let pxcor-GI ( item ( ( GI-counter-here * 3 ) + 1) GI-list )
    let pycor-GI ( item ( ( GI-counter-here * 3 ) + 2 ) GI-list )
    ask patch pxcor-GI pycor-GI [
      let GI-type-here ( item ( GI-counter-here * 3 ) GI-list )
      ;          show GI-type-here
      ;; 0 Swale
      if GI-type-here = 0 and ( cover = "p" or cover = "i" ) [
        setup-GI-swale
      ]
      ;; 1 Rain barrel
      if GI-type-here = 1 and cover = "b" [
        setup-GI-rain-barrel
      ]
      ;; 2 Green roof
      if GI-type-here = 2 and cover = "b" [
        setup-GI-green-roof
      ]
      ;; 3 permeable paver
      if GI-type-here = 3 and ( cover = "i" or cover = "a" ) [
        setup-GI-permeable-paver
      ]
    ]
    set GI-counter-here GI-counter-here + 1
  ]
  
  

  
  set Cost-install-private-GI sum [ install-cost-here ] of patches with [ private? = true ]
  set Cost-install-public-GI sum [ install-cost-here ] of patches with [ public? = true ]
  set Cost-total-install precision ( Cost-install-private-GI + Cost-install-public-GI ) 2
  
  ;  set remaining-budget GI-Budget-dollars - Cost-total-install
  
  set remaining-private-install-budget Private-Install-Budget-dollars - Cost-install-private-GI
  let formatted-remaining-private-install-budget precision ( abs remaining-private-install-budget ) 2
  set formatted-remaining-private-install-budget ( commify formatted-remaining-private-install-budget )
  set formatted-remaining-private-install-budget ( word "$" formatted-remaining-private-install-budget )   
  if remaining-private-install-budget < 0 [
    set private-install-budget-sentence ( word "Over private installation budget by " formatted-remaining-private-install-budget "." )
  ]
  if remaining-private-install-budget = 0 [
    set private-install-budget-sentence "Private installation costs exactly on budget."
  ]
  if remaining-private-install-budget > 0 [  
    set private-install-budget-sentence ( word "Under private installation budget by " formatted-remaining-private-install-budget "." )
  ]
  
  set remaining-public-install-budget Public-install-budget-dollars - Cost-install-public-GI
  let formatted-remaining-public-install-budget precision ( abs remaining-public-install-budget ) 2
  set formatted-remaining-public-install-budget ( commify formatted-remaining-public-install-budget )
  set formatted-remaining-public-install-budget ( word "$" formatted-remaining-public-install-budget )   
  if remaining-public-install-budget < 0 [
    set public-install-budget-sentence ( word "Over public installation budget by " formatted-remaining-public-install-budget "." )
  ]
  if remaining-public-install-budget = 0 [
    set public-install-budget-sentence "Public installation costs exactly on budget."
  ]
  if remaining-public-install-budget > 0 [  
    set public-install-budget-sentence ( word "Under public installation budget by " formatted-remaining-public-install-budget "." )
  ]
  
  set Cost-private-maintenance sum [ maintenance-cost-here ] of patches with [ private? = true ]
  let remaining-private-maintenance-budget ( Private-maintenance-budget * 1000 ) - Cost-private-maintenance
  let formatted-remaining-private-maintenance-budget precision ( abs remaining-private-maintenance-budget ) 2
  set formatted-remaining-private-maintenance-budget ( commify formatted-remaining-private-maintenance-budget )
  set formatted-remaining-private-maintenance-budget ( word "$" formatted-remaining-private-maintenance-budget )   
  if remaining-private-maintenance-budget < 0 [
    set private-maintenance-budget-sentence ( word "Over private maintenance budget by " formatted-remaining-private-maintenance-budget "." )
  ]
  if remaining-private-maintenance-budget = 0 [
    set private-maintenance-budget-sentence "Private maintenance costs exactly on budget."
  ]
  if remaining-private-maintenance-budget > 0 [  
    set private-maintenance-budget-sentence ( word "Under private maintenance budget by " formatted-remaining-private-maintenance-budget "." )
  ]
  
  set Cost-public-maintenance sum [ maintenance-cost-here ] of patches with [ public? = true ]
  let remaining-public-maintenance-budget ( public-maintenance-budget * 1000 ) - Cost-public-maintenance
  let formatted-remaining-public-maintenance-budget precision ( abs remaining-public-maintenance-budget ) 2
  set formatted-remaining-public-maintenance-budget ( commify formatted-remaining-public-maintenance-budget )
  set formatted-remaining-public-maintenance-budget ( word "$" formatted-remaining-public-maintenance-budget )   
  if remaining-public-maintenance-budget < 0 [
    set public-maintenance-budget-sentence ( word "Over public maintenance budget by " formatted-remaining-public-maintenance-budget "." )
  ]
  if remaining-public-maintenance-budget = 0 [
    set public-maintenance-budget-sentence "Public maintenance costs exactly on budget."
  ]
  if remaining-public-maintenance-budget > 0 [  
    set public-maintenance-budget-sentence ( word "Under public maintenance budget by " formatted-remaining-public-maintenance-budget "." )
  ]
  
  set Cost-total-maintenance Cost-private-maintenance + Cost-public-maintenance
  
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
;  public-install-budget-sentence
;  private-install-budget-sentence
;  public-maintenance-budget-sentence
;  private-maintenance-budget-sentence

  let budget-sentence ( word private-install-budget-sentence " " public-install-budget-sentence " " private-maintenance-budget-sentence " " public-maintenance-budget-sentence )

  if Normalization-calibration-run? = false and Good-neighbor-calibration-run? = false and Sewer-calibration-run? = false and Outflow-calibration-run? = false [ user-message budget-sentence ]
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
  
  set install-cost-here cost-a-rain-barrel
  set maintenance-cost-here maintenance-a-barrel
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
  
  set install-cost-here cost-a-green-roof
  set maintenance-cost-here maintenance-a-roof
 
end

to setup-GI-permeable-paver
  set gi? true
  set type-of-GI "permeable paver"
  sprout-permeable-pavers 1 [
    set shape "paver"
    set color [ pcolor ] of myself
    set size .9
  ]
  if curbs? = true and cover = "a" [ set elevation elevation - 63.5 ] ;; 2.5"
  
  ;;; values set according to Zhang MIT thesis for permeable pavers on a bedding and subbase of sand
  set capillary-suction 90 
  set initial-moisture-deficit .38 
  set saturated-hydraulic-conductivity (  ( (  160.2 / 60 ) / Repetitions-per-Iteration )  )
  
  set storage-capacity 0
  set patch-flooded-level ( storage-capacity + Flood-definition-mm )
  set extreme-patch-flooded-level ( storage-capacity + Extreme-flood-definition-mm )
  set max-extra-GI-storage 0
  set extra-GI-storage 0
  set max-wet-depth 609.6
  set max-infil-value ( max-wet-depth * initial-moisture-deficit )
  
  set install-cost-here cost-a-permeable-paver
  set maintenance-cost-here maintenance-a-paver
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
  if any? neighbors4 with [ cover = "r" ] and curbs? = true 
    [ 
      set elevation elevation - 127
    ]
;  let min-neighbor-elevation elevation
;  if any? neighbors4 with [ gi? = false ] [ set min-neighbor-elevation min [ elevation ] of neighbors4 with [ gi? = false ] ]
;  ifelse min-neighbor-elevation < elevation [
;    set elevation min-neighbor-elevation - storage-capacity
;  ]
;  [
;    set elevation elevation - storage-capacity
;  ]
  set elevation elevation - storage-capacity
  set sum-storage-capacity sum-storage-capacity + storage-capacity
  
  set base-max-wet-depth 914.4
  set max-wet-depth ( base-max-wet-depth - storage-capacity )
  set max-infil-value ( max-wet-depth * initial-moisture-deficit )
  set roughness .24
  
  set install-cost-here cost-a-swale
  set maintenance-cost-here maintenance-a-swale
end

to assign-cell-data
  ;; Set storage capacity, soil characteristics, and elevation of land covers
  ask patches [
    
    ;; Impermeable surfaces
    if cover = "r" or cover = "a" or cover = "i" or cover = "b" [
      if type-of-GI != "permeable paver" and type-of-GI != "swale" [ ;; Exclude permeable pavers
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
    
    ;; Permeable ground
    if cover = "p" [
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
    [ set base-max-wet-depth 914.4 ] ;; depth to bedrock for permeable cells or swales
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
  
  
  if Neighborhood-type = "Morrill School - Import" or  Neighborhood-type = "Morrill School - 13 x 7 6 blocks"
  [
    ask patches [
      ifelse ( ( ( pxcor ) mod ( road-spacing-horizontal  ) ) = 0 and ( ( pycor ) mod ( road-spacing-vertical  ) ) = 0 and cover = "r" ) ;; road intersections
      or ( ( ( pxcor - 4 ) mod ( road-spacing-horizontal  ) ) = 0 and ( ( pycor ) mod ( road-spacing-vertical  ) ) = 0 and cover = "r" ) 
      or ( ( ( pxcor ) mod ( road-spacing-horizontal) ) = 0 and ( ( pycor - 5 ) mod ( road-spacing-vertical ) ) = 0 and cover = "r" )
      or ( ( ( pxcor ) mod ( road-spacing-horizontal) ) = 0 and ( ( pycor - 9 ) mod ( road-spacing-vertical ) ) = 0 and cover = "r" )
      [
        set count-sewer-inlets 1
      ]
      [ set count-sewer-inlets 0 ] 
    ]
  ]
  
  if Neighborhood-type = "Blue Island - Import"
  [

    file-open "BI-Sewer-inlets.txt"
    let sewer-list file-read
    file-close
    ( foreach sort patches sewer-list
      [ ask ?1 [
        set count-sewer-inlets ?2
      ] ] )
    
    
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
    ifelse Neighborhood-type = "Dixmoor - Import" or Neighborhood-type = "Palos Heights - Import" or Neighborhood-type = "Albany Park - Import" [

      if Neighborhood-type = "Albany Park - Import" [
        set benchmark-storm 56.39
      ]
      if Neighborhood-type = "Dixmoor - Import" [
        set benchmark-storm 36.87
      ]
      if Neighborhood-type = "Palos Heights - Import" [
        set benchmark-storm 33.97
      ]
 
    ]
    
    [  
      set benchmark-storm 35.39 ;; in mm. see global variable section for explanation.
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
  set sewer-drain-rate ( 0.00468 * ( count patches ) ) / Repetitions-per-Iteration
  ;; Calculate the sewer intake rate for when the system is full (the intake rate is limited by the amount of water treated each time step)
  set full-sewer-rate ( sewer-drain-rate / ( count patches with [ count-sewer-inlets > 0 ] ) )
  ;; the volume in cubic mmm of a catch basin
  set sewer-basin-capacity 9477000000
  set adjusted-sewer-basin-capacity ( sewer-basin-capacity / ( 10000 * 10000 ) )
  set sewer-basin-height-below-pipe ( adjusted-sewer-basin-capacity * .62)
  
 
  ;;; setting starting water in sewer system- pipes and basins
  set water-in-pipes max-sewer-capacity * Starting-fullness-of-sewers-percent
  ask patches with [ count-sewer-inlets > 0 ] [
    set height-in-sewer-basin adjusted-sewer-basin-capacity * Starting-fullness-of-sewers-percent
  ]
  
end

to setup-paver-underdrain

  set paver-underdrain-depth 304.8       ;; in mm. equals 1 foot
  set paver-underdrain-rate (  ( ( 12.7 / 60 ) / Repetitions-per-Iteration )  ) ;; .5 inch per hour or 12.7 mm per hour
  
end

;; there aren't really any "agents." They are just a way to more easily see landscape features.
to setup-agents
  ;;Creates icons for sewers and sets their shape, color, and size
  ask patches with [ count-sewer-inlets > 0 ] [
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
  ask patches with [ cover = "r" ] [
    sprout-road-cells 1 [
      set shape "dot"
      set size .4
      set color yellow
    ]
  ]
end


;; "Go" runs all of the operations of the model
to go
  if ticks = 1 AND configure? = false [ exportMap ]
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
  set iteration-CSO 0 ;; this is a global, unlike the other ones since it relates to the greater sewer system's capcity, not that of any one patch sewer inlet
  
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
    if activate-outlet? [ flow-outlet-inlet ]
    
    ask patches [
      
      
      
      ;; Checking to see if the current water level is the level now
      let water-level-now water-column - storage-capacity
      if water-level-now < 0 [ set water-level-now 0 ]
      if water-level-now > highest-water-level [
        set highest-water-level water-level-now
      ]
      
      ;; Indicating flooding levels
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
    
    
    
  ]
  ;; cells recalculate their total-height, which is the height to the top of the water column, including underlying elevation

  ;if [ iteration-outflow ] of patch 22 0 = 0 and ticks > 1440 [ type ticks print " no outflow" ]
   
  ;; Plot current values on graphs and update globals  
  do-plots-and-globals
  
  if water-in-pipes > max-water-in-pipes [
    
    set max-water-in-pipes water-in-pipes
  ]
  
  ;; Visualize processes using colors
  color-patches
  ;ask patches [ set plabel precision water-column 0 ]
  
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
  
  ;;exports efficiency every 6 hours
  if ticks = 1 AND configure? = false [
    exportEfficiency
    exportWaterHeight
    ]
  if ticks mod 120 = 0 AND configure? = false[ 
    exportEfficiency 
    exportWaterHeight
  ]
;; if the rain has stopped and either 2 days have passed or there is no accumulated water, stop
  if ticks >= stop-tick [
    if Good-neighbor-calibration-run? = true or Outflow-calibration-run? = true [
      file-close
    ]
    ;;
    exportMaxWaterHeight

    
    output-data
    if Normalization-calibration-run? = true [
      if file-exists? "maximum-damages.txt" [ 
        file-delete "maximum-damages.txt" 
      ]
      set Maximum-monetary-damage precision Maximum-monetary-damage 2
      file-open "maximum-damages.txt"
      file-write Maximum-monetary-damage
      file-close

      
      if file-exists? "maximum-depth.txt" [ 
        file-delete "maximum-depth.txt" 
      ]
      set max-depth-water precision greatest-depth-standing-water-ft 2
      file-open "maximum-depth.txt"
      file-write greatest-depth-standing-water-ft
      file-close
    ]
    if record-movie? = true [ movie-close ]
    ;    export-view (word (word "Run" (remove "-" (remove " " (remove "." (remove ":" date-and-time)))) ".png")) ;; file-open (word (word "run" behaviorspace-run-number (remove "-" (remove " " (remove "." (remove ":" date-and-time)))) ".txt"))  
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
  ask patches with [ cover = "p" ] [
    
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
  ask patches with [ count-sewer-inlets > 0 and water-column > 0 ] [
    
    let sewer-inlet-amount used-sewer-rate
    
    if full-sewers? = false [
      ;; if the sewers are not full, then the maximum intake is multiplied by the number of inlets. if full, then the intake is limited to an amount per basin, NOT inlet
      set sewer-inlet-amount sewer-inlet-amount * count-sewer-inlets
    ]
       
    ;;if the catchment basins are not full, check to see how much water to take in
    if height-in-sewer-basin < adjusted-sewer-basin-capacity [
      let remaining-basin-height ( adjusted-sewer-basin-capacity - height-in-sewer-basin )
      ;; If there is more water in the water column than the sewer rate, move water from the water column into the sewers at the sewer rate
      let full-remove-amount 0
      
      ifelse ( water-column - sewer-inlet-amount ) > 0
        [ set full-remove-amount sewer-inlet-amount ]
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
  ask patches with [ count-sewer-inlets > 0 and height-in-sewer-basin > 0 ] [
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
to flow-outlet-inlet

  ;; Applies to only outflow cell(s)
  ;; removes up to a very large amount of water, which for app practical purposes is all water
  let outflow-now 0
  
  ask patches with [ outflow? = true ] [
    
    ;    show water-column
    let depth-above-outlet-height water-column - Outlet-control-height-mm
    if depth-above-outlet-height < 0 [ set depth-above-outlet-height 0 ]
    set mannings-coefficient roughness
    set water-depth depth-above-outlet-height / 1000
    set channel-width cell-dimension-m
    set longitudinal-slope outlet-longitudinal-slope
    set wetting-perimeter channel-width + water-depth + water-depth
    set cross-sectional-area water-depth * channel-width
    set hydraulic-radius cross-sectional-area / wetting-perimeter
    
    calculate-max-movement-height
    
    
    ;    show global-outflow
    ;    type "start water column = " print water-column
    
    ifelse depth-above-outlet-height - max-flow-height >= 0 [
      ;; All potential amount goes out
      set outflow-now max-flow-height
      set water-column precision ( water-column - max-flow-height ) 7
    ]
    [ 
      ;; all amount above depth-above-outlet-height goes out
      set outflow-now depth-above-outlet-height
      set water-column precision ( water-column - depth-above-outlet-height ) 7
    ]
    if Good-neighbor-calibration-run? = true or Outflow-calibration-run? = true [ file-write outflow-now ]
    ;; adding the outflow to a tracker of total outflow
    let outflow-volume ( outflow-now * conversion-multiplier )
    set global-outflow ( global-outflow + outflow-volume )
    ;; Add outflow from this iteration to the tracker that measures outflow for the entire tick
    set iteration-outflow iteration-outflow + outflow-volume
    
  ]
  ;; Inflow
  
  ;    ( ( accumulated-water + global-infiltration + global-evapo + global-sewer + global-outflow + water-in-storage ) / ( global-precipitation + global-inflow )) - 1
  if Upstream-neighbor? = true [ 
    
    ifelse bad-neighbor? = true [
      ;; reads from input file with values of the worst case scenario where there is no GI on neighbor's landscape
      let inflow-amount item ticks outflow-list
      ask patches with [ inflow? = true ] [
        set iteration-inflow iteration-inflow + inflow-amount
        set water-column water-column + inflow-amount
      ]
      let inflow-volume ( inflow-amount * Number-inlets * conversion-multiplier )
      set global-inflow ( global-inflow + inflow-volume )
      
      
    ]
    [
      ;; means that good neighbor will be true
      ;; inflow will correspond to outflow until a limit is reached
      
      
      if activate-outlet? = true [
        
        let baseline-outflow item ticks outflow-list
        let baseline-inflow item ticks good-neighbor-inflow-list
        
        
        let outflow-reduction 0

        
        let inflow-now 0
        
        ifelse baseline-inflow > 0 [
          ;; if somethign went out in the calibration run...
          ifelse baseline-inflow > outflow-now [
            ;; more went out previously, so there is a reduction this tick
            set outflow-reduction outflow-now / baseline-inflow
            set inflow-now precision ( baseline-inflow * outflow-reduction ) 8
            if inflow-now > baseline-outflow [ set inflow-now baseline-outflow ]
;            type "baseline outflow = " print baseline-outflow
;            type "outflow now = " print outflow-now
;            type "outflow-reduction = " print outflow-reduction
;            type "reduced-outflow-now = " print reduced-outflow-now
;            print ""
          ]
          [
            ;; no reduction in outflow, so inflow unchanged too
            set inflow-now baseline-outflow
          ]
          
        ]
        [
          ;; nothing went out now during the calibration run, so amount that goes in now would not be modified.
          set inflow-now baseline-outflow
        ]
        

        
        ask patches with [ inflow? = true ] [
          set iteration-inflow iteration-inflow + inflow-now
          set water-column water-column + inflow-now
        ]
        let inflow-volume ( inflow-now * Number-inlets * conversion-multiplier )
        set global-inflow ( global-inflow + inflow-volume )
        
        
      ]
      
    ]
    
    
    
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
  
  set iteration-flow 0
  
  foreach Landscape-Elevation-list [
    ask ? [
      if water-column > 0 or any? neighbors4 with [ water-column > 0 ] [
        
        ;; store values of the calling cell as "center-cell-"
        let center-cell-water-depth water-column
        let center-cell-elevation elevation
        let center-cell-total-height water-column + elevation
        let center-cell-cover cover
        let center-cell-patch self
        let center-cell-roughness roughness
        let center-cell-intersection? intersection?
        
        
        
        foreach Neighbor-Elevation-list [ ;; this list was set during the setup; it a list of all a cell's neighbors4 from lowest to highest.
          ask ? [
            
            ;; storing the total height of the neighbor
            let neighbor-total-height water-column + elevation
            let source-overflowing-curb? false
            
            ;; Check to make sure the heights are not identical - if so, there would be no flow.
            
            ifelse center-cell-total-height != neighbor-total-height [
              
              ;;  Setup Manning’s equation values
              
              ;; Determining direction of flow, water depth, and if there is water to flow
              ;;  If center cell’s total elevation is higher, water flows from center cell to neighbor
              ;;  If neighbor cell’s total elevation is higher, water flows from neighbor to center cell      
              ifelse center-cell-total-height > neighbor-total-height [
                ;;  Use center cell values for calculations (depth, cover, etc)
                set mannings-coefficient center-cell-roughness
                set water-depth precision ( center-cell-water-depth / 1000 ) 10
                if center-cell-cover = "r" and center-cell-intersection? = true and center-cell-water-depth > 25.4 [ set source-overflowing-curb? true ]
                if center-cell-cover = "r" and center-cell-intersection? = false and center-cell-water-depth > 127 [ set source-overflowing-curb? true ]
                
              ]
              
              [
                ;;  Use neighbor cell values for calculations (depth, cover, etc)               
                set mannings-coefficient roughness
                set water-depth precision ( water-column / 1000 ) 10
                if cover = "r" and intersection? = true and water-column > 25.4 [ set source-overflowing-curb? true ]
                if cover = "r" and intersection? = false and water-column > 127 [ set source-overflowing-curb? true ]
               
              ]
              
              ifelse water-depth > 0 [
                                
                ;;  Calculate slope
                let rise abs ( center-cell-total-height - neighbor-total-height )
                let run-length ( distance center-cell-patch ) * cell-dimension
                set longitudinal-slope precision ( rise / run-length ) 6
                                
                ;; Set channel width
                set channel-width ( distance center-cell-patch ) * cell-dimension-m
                            
                ;; Setting up other Manning's values
                set wetting-perimeter channel-width + water-depth + water-depth
                ;; cross sectional area - set to be whatever is smaller:
                ;; a) half of the difference in heads
                ;; b) the water depth of the cell from which water is flowing
                
                let difference-heads abs (center-cell-total-height - neighbor-total-height )
                let half-difference-heads difference-heads / 2
                
                ifelse water-depth < half-difference-heads [
                  set cross-sectional-area water-depth * channel-width
                ]
                [
                  set cross-sectional-area half-difference-heads * channel-width
                ]
                
                ;; Potential modification to manning's coefficient if water depth threshold
                ;; Setup of hydraulic radius
                
                ;; Checkign to see if it is flow between two roads
                ifelse center-cell-cover = "r" and cover = "r" and source-overflowing-curb? = true [
                  ;; Both cells roads and water over the curb
                  
                  ;; if true, halve the manning's coefficient
                  set mannings-coefficient mannings-coefficient / 2
                  
                  set hydraulic-radius cross-sectional-area / wetting-perimeter ;; set the regular way for roads
                ]
                [
                  ;; At least one of the cells is not a road
                  if water-depth > .0254 [ ;; ,0254 m is 1 inch
                                          ;; if true, halve the manning's coefficient
                    set mannings-coefficient mannings-coefficient / 2
                  ]
                  set hydraulic-radius water-depth ;; just water depth
                ]
                
                calculate-max-movement-height
                
                ;; Check to make sure no more water moves than is on the higher cell
                if max-flow-height > precision ( water-depth * 1000 ) 10 [
                  set max-flow-height precision ( water-depth * 1000 ) 10
                ]
                
                ;; Now, transfer the water and update the temporary center-cell-water-depth so the next neighbor will interact properly
                ;;  If center cell’s total elevation is higher, water flows from center cell to neighbor
                ;;  If neighbor cell’s total elevation is higher, water flows from neighbor to center cell  
                ;; First, set a local variable that will be usable to both - versions in m and mm
                let flow-m precision ( max-flow-height / 1000 ) 10
                let flow-mm precision max-flow-height 10
;                if flow-mm > 300 [
;                  print ticks
;                  print flow-mm > 300
;                  type "neighbor = " print self
;                  type "center cell = " show center-cell-patch
;                  ifelse center-cell-total-height > neighbor-total-height [
;                    print "center higher"
;                  ]
;                  [
;                    print "neighbor higher"
;                  ]
;                  type "neighbor water = " print water-column
;                  type "center water = " print  center-cell-water-depth
;                  print ""
;                ]


                if Flow-limit? != "none" [
                  
                  if Flow-limit? = "all-equilibrium"
                    [
                      ;; backwater flow limited
                      let equilibrium-level abs ( ( neighbor-total-height + center-cell-total-height) / 2 )
                      ifelse center-cell-total-height > neighbor-total-height [
                        ;; center higher
                        ;;  subtract the max-flow-height from the center and add to the neighbor
                        if precision ( center-cell-elevation + ( center-cell-water-depth - flow-mm ) ) 7 < equilibrium-level [
                          ;; if transfering the water leads to the center total height being less than the equilibrium, then limit the water to the equilibrium level
                          set flow-mm precision ( center-cell-total-height - equilibrium-level ) 7
                        ]
                        
                        
                      ]
                      [
                        ;; neighbor higher
                        ;;  subtract the max-flow-height from the neighbor and add to the center cell
                        if precision ( elevation + ( water-column - flow-mm ) ) 7 < equilibrium-level [
                          ;; if transfering the water leads to the center total height being less than the equilibrium, then limit the water to the equilibrium level
                          set flow-mm precision ( neighbor-total-height - equilibrium-level ) 7
                        ]
                        
                      ]
                    ]
                  if Flow-limit? = "backflow-equilibrium" [
                  
                    ;; backwater flow conditions
                    if ( center-cell-total-height > neighbor-total-height and center-cell-elevation < elevation ) ;; center overall higher but center lower elevation
                    or ( center-cell-total-height < neighbor-total-height and center-cell-elevation > elevation ) ;; neighbor overall higher but neighbor lower elevation
                    [
                     ;; backwater flow limited
                      let equilibrium-level abs ( ( neighbor-total-height + center-cell-total-height) / 2 )
                      ifelse center-cell-total-height > neighbor-total-height [
                        ;; center higher
                        ;;  subtract the max-flow-height from the center and add to the neighbor
                        if precision ( center-cell-elevation + ( center-cell-water-depth - flow-mm ) ) 7 < equilibrium-level [
                          ;; if transfering the water leads to the center total height being less than the equilibrium, then limit the water to the equilibrium level
;                          type "backwater flow limit reduced flow from " type 
;                          let flow-old flow-mm
                          set flow-mm precision ( center-cell-total-height - equilibrium-level ) 7
                        ]
                        
                        
                      ]
                      [
                        ;; neighbor higher
                        ;;  subtract the max-flow-height from the neighbor and add to the center cell
                        if precision ( elevation + ( water-column - flow-mm ) ) 7 < equilibrium-level [
                          ;; if transfering the water leads to the center total height being less than the equilibrium, then limit the water to the equilibrium level
                          set flow-mm precision ( neighbor-total-height - equilibrium-level ) 7
                        ]
                        
                      ]
                      
                    ]
                  
                  ]
                  
                ]
                
 ;               if ticks >= storm-length [ set iteration-flow precision ( iteration-flow + abs ( flow-mm ) ) 10 ]
                
                ifelse center-cell-total-height > neighbor-total-height [
                  ;;  subtract the max-flow-height from the center and add to the neighbor
                  ask center-cell-patch [
                    set water-column precision ( water-column - flow-mm ) 7
                    set center-cell-water-depth water-column
                    set center-cell-total-height center-cell-water-depth + center-cell-elevation
                    if water-column < 0 [
                      print "center was higher; this was the center"
                      type "water column less than 0 at " print self
                      type "water column = " print water-column
                      type "flow-mm = " print flow-mm
                    ]
                  ]
                  set water-column precision ( water-column + flow-mm ) 7
                  if water-column < 0 [
                    print "center was higher; this was the neighbor"
                    type "water column less than 0 at " print self
                    type "water column = " print water-column
                    type "flow-mm = " print flow-mm
                  ]
                ]
                [
                  ;;  subtract the max-flow-height from the neighbor and add to the center cell
                  set water-column precision ( water-column - flow-mm ) 7
                  if water-column < 0 [
                    print "neighbor was higher; this was the neighbor"
                    type "water column less than 0 at " print self
                    type "water column = " print water-column
                    type "flow-mm = " print flow-mm
                    type "water column before flow = " print ( water-column + flow-mm )
                  ]
                  ask center-cell-patch [
                    set water-column precision ( water-column + flow-mm ) 7
                    set center-cell-water-depth water-column
                    set center-cell-total-height center-cell-water-depth + center-cell-elevation
                    if water-column < 0 [
                      print "neighbor was higher; this was the center"
                      type "water column less than 0 at " print self
                      type "water column = " print water-column
                      type "flow-mm = " print flow-mm
                    ]
                  ]
                  
                ]
                
                
                                
                ask center-cell-patch [
                 if  center-cell-water-depth != water-column [
                   print ""
                   print "center-cell-water-depth not equal to water depth"
                   print self
                   print ""
                 ]
                ]
                
                                
              ]
              [
                       
              ] 
              
            ] ;; closes if center-cell-total-height != neighbor-total-height [
            
            [
              ;; the else, meaning that:
              ;; the total heights are  identical, so there is no flow
              
                            
            ]

          ] ;; closes  foreach Neighbor-Elevation-list [
        ] ;; closes ask ? [ (the neighbor elevation list)
        
      ] ;; closes if water-column > 0 or any? Neighbor-Elevation-list with [ water-column > 0 ] [
    ] ;; closes ask ? [ (landscape elevation list)
  ] ;; closes foreach Landscape-Elevation-list [
  
end


;; Sets the visualization choices
to color-patches 
  
  if data-visualized = "flooding definitions" [

      let max-depth-water-mm 1010.384 ;; maximum depth in mm with a 1-hour, 100-year storm, 0% initial sewer capacity, and babad neighbors
      ask patches [
        let water-here water-column - storage-capacity
        if water-here < 0 [ set water-here 0 ]
        if water-here > max-depth-water-mm [ set water-here max-depth-water-mm ]
        ifelse water-here >= patch-flooded-level
        ;; if the have over the patch-flooded-level threshold (1"), the patche's color will be scaled from white (lowest level of water) to dark blue (deepest level of water) in 10 bins
          [
            ifelse water-here < (max-depth-water-mm * .1) [
              set pcolor white
            ]
            [
              ifelse water-here < (max-depth-water-mm * .2) [
                set pcolor 89
              ]
              [
                ifelse water-here < (max-depth-water-mm * .3) [
                  set pcolor 88
                ]
                [
                  ifelse water-here < (max-depth-water-mm * .4) [
                    set pcolor 87
                  ]
                  [
                    ifelse water-here < (max-depth-water-mm * .5) [
                      set pcolor 97
                    ]
                    [
                      ifelse water-here < (max-depth-water-mm * .6) [
                        set pcolor 96
                      ]
                      [
                        ifelse water-here < (max-depth-water-mm * .7) [
                          set pcolor 95
                        ]
                        [
                          ifelse water-here < (max-depth-water-mm * .8) [
                            set pcolor 105
                          ]
                          [
                            ifelse water-here < (max-depth-water-mm * .9) [
                              set pcolor 104
                            ]
                            [
                              set pcolor 103
                            ]
                          ]
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
          [
            ifelse ever-extreme-flooded? = true [
              set pcolor base-color - 2
            ]
            [ 
              ifelse ever-flooded? = true [
                
                set pcolor base-color - 1
              ] 
              [
                set pcolor base-color
              ]
            ]
          ]
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
  
  
  ;;; One values about the greatest amount of water on the landscape - volume and depth
  if non-GI-accumulated-water > global-standing-water [ set global-standing-water non-GI-accumulated-water ] ;; Greatest volume of water in storage, excluding storage in swales
    
  set global-rain-barrel ( sum [ extra-GI-storage ] of patches with [ type-of-GI = "rain-barrel" ] ) * conversion-multiplier
  set global-green-roof ( sum [ extra-GI-storage ] of patches with [ type-of-GI = "green roof" ] ) * conversion-multiplier
  set global-green-alleys ( sum [ cumulative-infiltration-amount ] of patches with [ type-of-GI = "permeable paver" ] ) * conversion-multiplier
  set global-swales ( ( sum [ cumulative-infiltration-amount ] of patches with [ type-of-GI = "swale" ] ) * conversion-multiplier ) 
  set global-GI-total global-rain-barrel + global-green-roof + global-green-alleys + global-swales
  
  set global-rain-barrel-ft3 global-rain-barrel * cubic-m-to-cubic-ft
  set global-green-roof-ft3 global-green-roof * cubic-m-to-cubic-ft
  set global-green-alleys-ft3 global-green-alleys * cubic-m-to-cubic-ft
  set global-swales-ft3 global-swales * cubic-m-to-cubic-ft
  set global-GI-total-ft3 global-GI-total * cubic-m-to-cubic-ft
  
  set total-extra-storage ( global-rain-barrel + global-green-roof ) ;; green roofs and barrels

  
  let high-water-now max [ highest-water-level ] of patches
  if high-water-now > greatest-depth-standing-water [ set greatest-depth-standing-water high-water-now ]
  
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

  if Upstream-neighbor? = true and activate-outlet? = true and inflow-limit-reached? = false [
    if global-inflow >= ( ( potential-rain - ( global-infiltration + global-evapo + global-sewer + total-extra-storage + water-in-storage ) ) * number-inlets ) [ ;; + water-in-storage
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
  set global-cso-ft3 global-cso * cubic-m-to-cubic-ft


  
  set-current-plot "Cumulative Water Accounting"
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
  set-current-plot-pen "CSO"
  plot global-CSO-ft3


  set-current-plot "Water Accounting"
  set-current-plot-pen "Rain"
  plot ( sum [ iteration-precipitation ] of patches ) * conversion-multiplier * cubic-m-to-cubic-ft
  set-current-plot-pen "GI infiltration"
  plot ( sum [ iteration-infiltration ] of patches with [ type-of-GI = "swale" or  type-of-GI = "permeable paver" ] ) * conversion-multiplier * cubic-m-to-cubic-ft
  set-current-plot-pen "Permeable infiltration"
  plot ( sum [ iteration-infiltration ] of patches with [ gi? = false ] ) * conversion-multiplier * cubic-m-to-cubic-ft
  set-current-plot-pen "Sewer Runoff"
  plot ( sum [ iteration-sewers ] of patches ) * conversion-multiplier * cubic-m-to-cubic-ft
  set-current-plot-pen "Outlet Runoff"
  plot ( sum [ iteration-outflow ] of patches ) * conversion-multiplier * cubic-m-to-cubic-ft
  set-current-plot-pen "Evaporation and Evapotranspiration"
  plot ( sum [ iteration-evapotrans ] of patches + sum [ iteration-evapo ] of patches) * conversion-multiplier * cubic-m-to-cubic-ft
;  set-current-plot-pen "Standing Water"
;  plot non-GI-accumulated-water-ft3
;  set-current-plot-pen "Water in Swales"
;  plot water-in-storage-ft3
;  set-current-plot-pen "Water in barrels and roofs"
;  plot total-extra-storage-ft3
  set-current-plot-pen "Inflow from Neighbors"
  plot ( sum [ iteration-inflow ] of patches ) * conversion-multiplier * cubic-m-to-cubic-ft
  set-current-plot-pen "CSO"
  plot iteration-CSO * conversion-multiplier * cubic-m-to-cubic-ft
  
  
  
  let non-road-impermeable count patches with [ cover = "i" or cover = "b" ]
  let road-count count patches with [ cover = "r" ]
  

  if time-to-lesser-flood = 0 and any? patches with [ flooded? = true ] [
    set time-to-lesser-flood ticks
  ]
  if time-to-greater-flood = 0 and any? patches with [ extreme-flooded? = true ] [
    set time-to-greater-flood ticks
  ]
  if any? patches with [ flooded? = true ] [
    set time-duration-lesser-flood time-duration-lesser-flood + 1
  ]
  if any? patches with [ extreme-flooded? = true ] [
    set time-duration-greater-flood time-duration-greater-flood + 1
  ]
  
  set-current-plot "Public Costs"
  set-current-plot-pen "Cumulative Sewer Runoff"
  plot global-sewer-ft3
  set-current-plot-pen "Cumulative Outlet Runoff"
  plot global-outflow-ft3
  
end

to setup-flow-values
 
 ;; Values used in Manning's equations to determine flow volumes
  
  ;; Outlet slope
  set outlet-longitudinal-slope slope-percent * .01
  

  ask patches [
    ifelse cover = "r" [
      set roughness .0175 ;; smooth asphalt, just about the lowest n there is.
    ]
    [
      ;; non-road cells
      ifelse type-of-GI = "swale" [
        set roughness .24 ;; recommended value by Caltrans for bioswales http://www.dot.ca.gov/hq/LandArch/ec/stormwater/guidance/DG-BioSwale-Final02-011309.pdf
      ]
      [
        ;; non-GI and non-road
        ifelse cover = "i" or cover = "b" [
          ;; impervious or buildings
          set roughness .0175
        ]
        [
          ;; cover = "p"; permeable - yard, park, open space, undeveloped area
          set roughness .15
        ]      
      ]
    ]
  ]
  
  if Upstream-neighbor? = true and Good-neighbor-calibration-run? = false and Outflow-calibration-run? = false [
    ;; Inflows and not a calibration run, so inflows
    set outflow-list []
    file-open "outflow-calibration-values.txt"
     while [not file-at-end?][
       let value-now file-read
;       if empty? outflow-list [ set outflow-list value-now ]
       set outflow-list sentence outflow-list value-now
     ]
    file-close
    if good-neighbor? = true [
      ;; A good neighbor list is needed to compare outflows against
      set good-neighbor-inflow-list []
      file-open "good-neighbor-calibration-values.txt"
      while [not file-at-end?][
        let value-now file-read
        if empty? outflow-list [ set good-neighbor-inflow-list value-now ]
        set good-neighbor-inflow-list sentence good-neighbor-inflow-list value-now
      ]
      file-close
    ]
  ]
  
  
  if Good-neighbor-calibration-run? = true and Upstream-neighbor? = true [
    file-open "outflow-calibration-values.txt"
    set outflow-list []
    while [not file-at-end?][
      let value-now file-read
      if empty? outflow-list [ set outflow-list value-now ]
      set outflow-list sentence outflow-list value-now
    ]
    file-close
  ]
  
  
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
        if cover = "b" and GI? = false[
          if remaining-private-install-budget - cost-a-rain-barrel > 0 [
            setup-GI-rain-barrel

            set remaining-private-install-budget remaining-private-install-budget - cost-a-rain-barrel
           
           ifelse private? = true [
             set Cost-install-private-GI Cost-install-private-GI + cost-a-rain-barrel
             set Cost-private-maintenance Cost-private-maintenance + maintenance-a-barrel
           ]
           [
             set Cost-install-public-GI Cost-install-public-GI + cost-a-rain-barrel
             set Cost-public-maintenance Cost-public-maintenance + maintenance-a-barrel
           ]

            set Cost-total-install Cost-install-private-GI + Cost-install-public-GI          

            set Cost-total-maintenance Cost-private-maintenance + Cost-public-maintenance
            
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
        if cover = "b" and GI? = false[
          if remaining-private-install-budget - cost-a-green-roof > 0 [
            setup-GI-green-roof
            set remaining-private-install-budget remaining-private-install-budget - cost-a-green-roof

            ifelse private? = true [
              set Cost-install-private-GI Cost-install-private-GI + cost-a-green-roof
              set Cost-private-maintenance Cost-private-maintenance + maintenance-a-roof
            ]
            [
              set Cost-install-public-GI Cost-install-public-GI + cost-a-green-roof
              set Cost-public-maintenance Cost-public-maintenance + maintenance-a-roof
            ]
            
            set Cost-total-install Cost-install-private-GI + Cost-install-public-GI
            
            set Cost-total-maintenance Cost-private-maintenance + Cost-public-maintenance
            
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
        if remaining-private-install-budget - cost-a-swale > 0 [
          if ( cover = "p" or cover = "i" ) and GI? = false [
            setup-GI-swale
            set remaining-private-install-budget remaining-private-install-budget - cost-a-swale
            
            ifelse private? = true [
              set Cost-install-private-GI Cost-install-private-GI + cost-a-swale
              set Cost-private-maintenance Cost-private-maintenance + maintenance-a-swale
            ]
            [
              set Cost-install-public-GI Cost-install-public-GI + cost-a-swale
              set Cost-public-maintenance Cost-public-maintenance + maintenance-a-swale
            ]
            
            set Cost-total-install Cost-install-private-GI + Cost-install-public-GI
            
            set Cost-total-maintenance Cost-private-maintenance + Cost-public-maintenance
            
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
        if ( remaining-private-install-budget - cost-a-permeable-paver > 0 and private? = true ) or (remaining-public-install-budget - cost-a-permeable-paver > 0 and private? = false )
        [
          if ( cover = "a" or cover = "i" ) and GI? = false [
            setup-GI-permeable-paver
                        
            ifelse private? = true [
              set Cost-install-private-GI Cost-install-private-GI + cost-a-permeable-paver
              set Cost-private-maintenance Cost-private-maintenance + maintenance-a-paver
              set remaining-private-install-budget remaining-private-install-budget - cost-a-permeable-paver
            ]
            [
              set Cost-install-public-GI Cost-install-public-GI + cost-a-permeable-paver
              set Cost-public-maintenance Cost-public-maintenance + maintenance-a-paver
              set remaining-public-install-budget remaining-public-install-budget - cost-a-permeable-paver
            ]
            
            set Cost-total-install Cost-install-private-GI + Cost-install-public-GI
            
            set Cost-total-maintenance Cost-private-maintenance + Cost-public-maintenance
            
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

to calculate-private-damages
  
  ;; Building cells calculate their damage amount based on the depth to the flood
  ask patches with [ cover = "b" ] [
    ifelse highest-water-level >= patch-flooded-level [ ;; patch flooded level is 25.4 mm (1 inch) for now. The highest-water-level is the highest water level ever on that particular aptch
      ;; This assumes that the floor of ground level is two feet above the ground
      ;; Source is Economic Guidance Memorandum (EGM) 04-01, Generic Depth-Damage Relationships for Residential Structures with Basements, received from John Watson
      ;; For structure depth damage ; assumign 2 or more stories with basement, single family; Table 2 in the PD, page 7 of the PDF
      let flood-depth-inches highest-water-level / 25.4 ;; convert from mm to inches
      set flood-depth-inches precision flood-depth-inches 3
      
      let subtract-from-depth 0
      let damage-floor 0
      let damage-ceiling 0
      
      ifelse flood-depth-inches < 1 [
        ;; No damage since threshold not reached
        set percent-damage-structure 0
        set damage-in-dollars 0
      ]
      
      [
        ;; There is some damage
        ;; Buildings will recolor themselves from white (no damage) to deep red (highest level of damages)
        ifelse flood-depth-inches <= 6 [ ;; up to .5 feet
                                         ;; 1 < depth <= 6
          set percent-damage-structure ( ( flood-depth-inches - 1 ) / 5 ) * 10.2 ;; scaled between 1" and 5", excluding the first inch when there is no flood; then the damage is scaled from 0 to 10.2
          set pcolor 18
        ]
        [
          ifelse flood-depth-inches <= 18 [ ;; up to 1.5 feet
                                            ;; 6 < depth <= 18
            set percent-damage-structure ( ( ( flood-depth-inches - 6 ) / 12 ) * ( 13.9 - 10.2 ) ) + 10.2     ;; scaled between 0 and 12 inches, excuding the first 6" ; then the damage is scaled from 10.2 to 13.9
            set pcolor 17
          ]
          [
            ifelse flood-depth-inches <= 30 [ ;; up to 2.5 feet
                                              ;; 18 < depth <= 30
              set percent-damage-structure ( ( ( flood-depth-inches - 18 ) / 12 ) * ( 17.9 - 13.9 ) ) + 13.9     ;; scaled between 0 and 12 inches, excusing the first 18"
              set pcolor 16
              
            ]
            [
              ifelse flood-depth-inches <= 42 [ ;; up to 3.5 feet
                                                ;; 30 < depth <= 42
                set percent-damage-structure ( ( ( flood-depth-inches - 30 ) / 12 ) * ( 22.3 - 17.9 ) ) + 17.9     ;; scaled between 0 and 12 inches, excusing the first 30"
                set pcolor 15
              ]
              [
                ifelse flood-depth-inches <= 54 [ ;; up to 4.5 feet
                  set percent-damage-structure ( ( ( flood-depth-inches - 42 ) / 12 ) * ( 27 - 22.3 ) ) + 22.3     ;; scaled between 0 and 12 inches, excusing the first 42"
                  set pcolor 14
                ]
                [
                  ifelse flood-depth-inches <= 66 [ ;; up to 5.5 feet
                    set percent-damage-structure ( ( ( flood-depth-inches - 54 ) / 12 ) * ( 31.9 - 27 ) ) + 27     ;; scaled between 0 and 12 inches, excusing the first 54"
                    set pcolor 13
                  ]
                  [
                    ;; greater than 5.5 feet
                    set percent-damage-structure ( ( ( flood-depth-inches - 54 ) / 12 ) * ( 36.9 - 31.9 ) ) + 31.9     ;; scaled between 0 and 12 inches, excusing the first 30"
                    set pcolor 12
                  ]
                ]           
              ]
            ]
            
          ]
        ]
        set damage-in-dollars precision ( (percent-damage-structure / 100 ) * 87600 ) 2
        ;      show average-percent-damage
      ] ;; closes the else from the first < 1" loop
    ]
    [
      set percent-damage-structure 0
      set damage-in-dollars 0
    ]
  ]
end

to output-data
  
  ;;;;;;;;;;;;;
  ;;; Costs ;;;
  ;;;;;;;;;;;;;
  
  calculate-private-damages
  
  set Cost-private-property-damage sum [ damage-in-dollars ] of patches with [ private? = true and cover = "b" ]
  set Cost-public-property-damage sum [ damage-in-dollars ] of patches with [ public? = true and cover = "b" ]
  let sum-damages Cost-private-property-damage + Cost-public-property-damage
  
  if Normalization-calibration-run? = false and Good-neighbor-calibration-run? = false and Sewer-calibration-run? = false and Outflow-calibration-run? = false [
    ifelse Cost-total-install = 0 [
      user-message "No GI installed"
    ]
    [
      ifelse maximum-monetary-damage = 0 [
        user-message "There was no property damage before the green infrastructure was installed, so there was no decrease in damages"
      ]
      [
        let change-to-damages precision ( maximum-monetary-damage - sum-damages ) 2 ;; determine change (reduction) in damages due to the GI
        if change-to-damages < 0 [ set change-to-damages 0 ]
        let damage-change-word 0
        if change-to-damages = 0 [
          ;; GI had no effect on damages 
          set damage-change-word "GI had no effect on damages."
          user-message damage-change-word
        ]
        if change-to-damages > 0 [
          ;; GI decreased damages
          let damage-decreased-formatted ( commify change-to-damages )
          ifelse change-to-damages = maximum-monetary-damage [
            set damage-change-word (word "GI decreases damages by $" damage-decreased-formatted ", the full amount." )
          ]
          [
            set damage-change-word (word "GI decreases damages by $" damage-decreased-formatted "." )
          ]
          
          let storm-damage-sentence 0
          let damage-multiple precision ( Cost-total-install / change-to-damages ) 2
          set damage-multiple damage-multiple - 1
          if damage-multiple < 0 [ set damage-multiple 0 ]
          ifelse damage-multiple = 0 [
            ;; damamges fully recouped now
            set damage-change-word ( word damage-change-word " Installation costs fully recouped by damages avoided during this one storm." )
            
          ]
          [
            ;; damages avoided less than full, so calculate how many storms like this would lead to fully recouping costs via damages avoided
            
            set damage-change-word ( word damage-change-word "  " damage-multiple " more storms of this magnitude needed before full installation costs recouped." )
          ]
          
          user-message damage-change-word 
        ]
        
      ]
    ]
  ]
  
  
  let sewers-gallons global-sewer-ft3 * 7.48052 ;; 7.4 is number of gallons per cubic foot
  set Cost-stormwater-treatment sewers-gallons * 0.00024 ;; cost to treat one gallon based on the user charge ordinance of MWRD
  ;  set Costs-total-storm-damage Cost-private-storm-damage + Cost-public-storm-damage
  ;  set Costs-total Cost-total-install + Cost-total-maintenance + Costs-total-storm-damage
  
  ;; Normalized costs
  
  ifelse Private-Install-Budget-dollars > 0 [
    set Normalized-Cost-install-private-GI Cost-install-private-GI / Private-Install-Budget-dollars ]
  [ set Normalized-Cost-install-private-GI 0 ]
    
  ifelse Public-install-budget-dollars > 0 [
    set Normalized-Cost-install-public-GI Cost-install-public-GI / Public-install-budget-dollars ]
  [ set Normalized-Cost-install-public-GI 0 ]
  
  ifelse ( Private-Install-Budget-dollars + Public-install-budget-dollars ) > 0 [
    set Normalized-Cost-total-install Cost-total-install / ( Private-Install-Budget-dollars + Public-install-budget-dollars ) ]
  [ set Normalized-Cost-total-install 0 ]
  
  ifelse Private-maintenance-budget-dollars > 0 [
    set Normalized-Cost-private-maintenance Cost-private-maintenance / Private-maintenance-budget-dollars ]
  [ set Normalized-Cost-private-maintenance 0 ]
  
  ifelse Public-maintenance-budget-dollars > 0 [
    set Normalized-Cost-public-maintenance Cost-public-maintenance / Public-maintenance-budget-dollars ]
  [ set Normalized-Cost-public-maintenance 0 ]
  
  ifelse ( Private-maintenance-budget-dollars + Public-maintenance-budget-dollars ) > 0 [
    set Normalized-Cost-total-maintenance Cost-total-maintenance / ( Private-maintenance-budget-dollars + Public-maintenance-budget-dollars ) ]
  [ set Normalized-Cost-total-maintenance 0 ]
  
  ifelse Normalization-calibration-run? = false and Good-neighbor-calibration-run? = false and Sewer-calibration-run? = false [
    set Normalized-Cost-private-property-damage Cost-private-property-damage / maximum-monetary-damage
    if Normalized-Cost-private-property-damage > 1 [ set Normalized-Cost-private-property-damage 1 ]
    set Normalized-Cost-public-property-damage Cost-public-property-damage / maximum-monetary-damage
    if Normalized-Cost-public-property-damage > 1 [ set Normalized-Cost-public-property-damage 1 ]
    set Normalized-Cost-stormwater-treatment Cost-stormwater-treatment / maximum-monetary-damage
    if Normalized-Cost-stormwater-treatment > 1 [ set Normalized-Cost-stormwater-treatment 1 ]
  ]
  [
    set Normalized-Cost-private-property-damage 1
    set Normalized-Cost-public-property-damage 1
    set Normalized-Cost-stormwater-treatment 1
    ifelse Cost-private-property-damage > Cost-public-property-damage [
      set maximum-monetary-damage Cost-private-property-damage
    ]
    [
      set maximum-monetary-damage Cost-public-property-damage
    ]
  ]
  
  ;    set Normalized-Costs-total-storm-damage Costs-total-storm-damage / Costs-total
  ;    set Normalized-Costs-total Costs-total / Costs-total
  
  
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
  set Normalized-time-to-greater-flood time-to-greater-flood / stop-tick
  set Normalized-time-duration-lesser-flood time-duration-lesser-flood / stop-tick
  set Normalized-time-duration-greater-flood time-duration-greater-flood / stop-tick
;  set Normalized-time-to-dry time-to-dry / stop-tick

  ;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Amounts of Water ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;
  
  set global-standing-water-ft3 global-standing-water * cubic-m-to-cubic-ft
  
  set greatest-depth-standing-water-ft greatest-depth-standing-water / 304.8 ;; 304.8 mm in a foot
  
;;; Normalized amoujnts of water

  let normalization-denominator global-precipitation-ft3 + global-inflow-ft3

  set Normalized-global-outflow-ft3 global-outflow-ft3 / normalization-denominator
  
  ;; I was seeing what the cost of treatemet of the outflow, if it eventually ended up in the sewers.
;  let outflow-gallons global-outflow-ft3 * 7.48052 ;; 7.4 is number of gallons per cubic foot
;  set outflow-gallons outflow-gallons * 0.00024 ;; cost to treat one gallon based on the user charge ordinance of MWRD
;show outflow-gallons

  set Normalized-global-sewer-ft3 global-sewer-ft3 / normalization-denominator
  set Normalized-global-standing-water-ft3 global-standing-water-ft3 / normalization-denominator
  ifelse Normalization-calibration-run? = false and Good-neighbor-calibration-run? = false and Sewer-calibration-run? = false [
    set Normalized-greatest-depth-standing-water-ft greatest-depth-standing-water-ft / max-depth-water ;; 2 feet? does this make sense?
    if Normalized-greatest-depth-standing-water-ft > 1 [ set Normalized-greatest-depth-standing-water-ft 1 ]
  ]
  [
   ;; calibration run, so set to 1
    set Normalized-greatest-depth-standing-water-ft 1
  ]
  set Normalized-global-GI-total global-GI-total-ft3 / normalization-denominator
  set Normalized-global-GI-infiltration-ft3 global-GI-infiltration-ft3 / normalization-denominator
;  file-open "scoreExport.txt"
;  file-type Normalized-Cost-install-public-GI file-type " " file-type Normalized-Cost-install-private-GI file-type " " 
;;  file-type Normalized-Cost-public-storm-damage file-type " " file-type Normalized-Cost-private-storm-damage file-type " "
;  file-print Normalized-global-outflow-ft3
;  file-close
  
  set Normalized-global-inflow-ft3 global-inflow-ft3 / normalization-denominator
  
  set Normalized-global-inflow-ft3 global-inflow-ft3 / normalization-denominator
  
  if configure? = false [
  
  sql:configure "defaultconnection" [["host" "127.0.0.1"] ["port" 3306] ["user" "evl"] ["password" "CAT.evl"] ["database" "citeam"]]
  set query (word "INSERT INTO citeam.simOutput (studyID, trialID, map, publicCost, privateCost, publicDamages, "
    "privateDamages, publicMaintenanceCost, privateMaintenanceCost, standingWater, impactNeighbors, neighborsImpactMe, infiltration, efficiency, maxWaterHeights"
    ") VALUES (" studyID ", " runID ", '" interventionMap "', " Cost-install-public-GI ", " Cost-install-private-GI
    ", " Cost-public-property-damage ", " Cost-private-property-damage ", " Cost-public-maintenance ", " Cost-private-maintenance ", '" waterHeightList 
    "', " Normalized-global-outflow-ft3 ", " Normalized-global-inflow-ft3 ", " Normalized-global-GI-infiltration-ft3
    ", '" efficiencyList "', '" maxWaterHeightList "')") 
 
  let query2 (word "INSERT INTO citeam.simOutput_Normalized (studyID, trialID, publicCost, privateCost, publicDamages, "
    "privateDamages, publicMaintenanceCost, privateMaintenanceCost, standingWater, impactNeighbors, neighborsImpactMe, "
    "infiltration, efficiency, maxWaterHeight"
    ") VALUES (" studyID ", " runID ", " Normalized-Cost-install-public-GI ", " Normalized-Cost-install-private-GI ", " 
    Normalized-Cost-public-property-damage ", " Normalized-Cost-private-property-damage ", "
    Normalized-Cost-public-maintenance ", " Normalized-Cost-private-maintenance ", " Normalized-greatest-depth-standing-water-ft 
    ", " Normalized-global-outflow-ft3 ", " Normalized-global-inflow-ft3 ", " Normalized-global-GI-infiltration-ft3
    ", " Normalized-global-GI-total ", " greatest-depth-standing-water ")")

  show query
  show query2

  ;Cost-private-maintenance", " time-to-lesser-flood", " time-to-greater-flood", "time-duration-lesser-flood", "time-duration-greater-flood", "
  ;  time-to-dry", "global-sewer-ft3", "global-outflow-ft3", "global-GI-total-ft3" , "
  ;  global-green-roof-ft3" , "global-rain-barrel-ft3", "global-swales-ft3"," 

  sql:exec-update query []
  sql:exec-update query2 []
  ]
  ;;mysql:executeUpdate db query


;print Cost-install-private-GI
;print Cost-install-public-GI
;print Cost-private-maintenance
;print Cost-public-maintenance
;print Cost-private-property-damage
;print Cost-public-property-damage
;
;print Normalized-Cost-install-private-GI
;print Normalized-Cost-install-public-GI
;print Normalized-Cost-private-maintenance
;print Normalized-Cost-public-maintenance
;print Normalized-Cost-private-property-damage
;print Normalized-Cost-public-property-damage
;print Normalized-greatest-depth-standing-water-ft
;print Normalized-global-outflow-ft3
;print Normalized-global-inflow-ft3
;print Normalized-global-GI-infiltration-ft3
;
;print global-efficiency-rain-barrels
;print global-efficiency-swales
;print global-efficiency-green-alleys
;print global-efficiency-green-roofs
;print Normalized-global-GI-total



end

to exportMap
  ;file-open "outputFile.txt"
  ask rain-barrels[
    ;file-type pxcor file-type " " file-type pycor file-print " 0"
    set interventionMap (word interventionMap pxcor " " pycor " 0 \n")
  ]
  ask swales[
    ;file-type pxcor file-type " " file-type pycor file-print " 1"
    set interventionMap (word interventionMap pxcor " " pycor " 1 \n")
  ]
  ask permeable-pavers[
    ;file-type pxcor file-type " " file-type pycor file-print " 2"
    set interventionMap (word interventionMap pxcor " " pycor " 2 \n")
  ]
  ask green-roofs[
    ;file-type pxcor file-type " " file-type pycor file-print " 3"
    set interventionMap (word interventionMap pxcor " " pycor " 3 \n")
  ]
  ask sewers[
    ;file-type pxcor file-type " " file-type pycor file-print " 4"
    set interventionMap (word interventionMap pxcor " " pycor " 4 \n")
  ]
  ;file-close
end



to exportEfficiency
  
  ;file-open "efficiencyFile.txt"
 ; file-type "0 " file-type ticks / 60 file-type " " file-print precision (1 - global-efficiency-rain-barrels) 3
  ;file-type "1 " file-type ticks / 60 file-type " " file-print precision (1 - global-efficiency-swales) 3
  ;file-type "2 " file-type ticks / 60 file-type " " file-print precision (1 - global-efficiency-green-alleys) 3
  ;file-type "3 " file-type ticks / 60 file-type " " file-print precision (1 - global-efficiency-green-roofs) 3
  let roundedBarrels precision (1 - global-efficiency-rain-barrels) 3
  set efficiencyList word efficiencyList "0 "
  set efficiencyList word efficiencyList (ticks / 60 ) 
  set efficiencyList word efficiencyList " "
  set efficiencyList word efficiencyList roundedBarrels
  set efficiencyList word efficiencyList "\n"
  set efficiencyList word efficiencyList "1 "
  set efficiencyList word efficiencyList (ticks / 60 ) 
  set efficiencyList word efficiencyList " "
  set efficiencyList word efficiencyList precision (1 - global-efficiency-swales) 3
  set efficiencyList word efficiencyList "\n"
  set efficiencyList word efficiencyList "2 "
  set efficiencyList word efficiencyList (ticks / 60 ) 
  set efficiencyList word efficiencyList " "
  set efficiencyList word efficiencyList precision (1 - global-efficiency-green-alleys) 3
  set efficiencyList word efficiencyList "\n"
  set efficiencyList word efficiencyList "3 "
  set efficiencyList word efficiencyList (ticks / 60 ) 
  set efficiencyList word efficiencyList " "
  set efficiencyList word efficiencyList precision (1 - global-efficiency-green-roofs) 3
  set efficiencyList word efficiencyList "\n"
  ;;type efficiencyList
  ;;word currentTickValue " " precision (1 - global-efficiency-rain-barrels) 3 "\n"
  ;file-close
end

to exportWaterHeight
  ask patches[
    set waterHeightList (word waterHeightList ( ticks / 60 ) " " pxcor " " pycor " " (precision water-column 3) "\n")
  ]
end

;;exports the max water heights
to exportMaxWaterHeight
  ask patches[
   set maxWaterHeightList (word maxWaterHeightList 48 " " pxcor " " pycor " " (precision highest-water-level 3) "\n")
  ]
  
end  

;;exports elevation for map
to exportElevationGradient
  ask patches[
   set elevationGradient (word elevationGradient pxcor " " pycor " " (precision elevation 3) "\n") 
  ]
end



to placement-done
  ;; Now creating lists of patches sorted by elevation (small to large) for the overall landscape and of each patches neighbors.
  set Landscape-Elevation-list sort-on [ elevation ] patches
  ;  show Landscape-Elevation-list
  ask patches [
    let elevation-here elevation
    set Neighbor-Elevation-list sort-on [ elevation ] neighbors4 with [ elevation > elevation-here ]
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



to setup-colors
  ask patches [
    if cover = "r" [
      set base-color 5
    ] 
    
    if cover = "a" [
      set base-color 5
    ] 
    
    if cover = "i" [
      set base-color 7 
    ] 
    
    if cover = "b" [
      set base-color 3  
    ] 
    
    if cover = "p" [
      set base-color 57
    ] 
    
    set pcolor base-color
    
  ]
  
end

to calculate-max-movement-height
  ;; Note: water depth here is in meters, as is channel width. The end of this procedure will convert the resulting value back into mm

  
  ifelse cross-sectional-area > 0 [ ;; Ensuring there is not division by 0
    set velocity ( ( 1 / mannings-coefficient ) * cross-sectional-area * ( hydraulic-radius ^ ( 2 / 3)) * ( sqrt longitudinal-slope ) ) / cross-sectional-area
  ]
  [
    set velocity 0
  ]
  ;;; above velocity in meters per second; need to convert to the height in mm
  
  set velocity ( velocity * 60 ) / Repetitions-per-Iteration ;; convert to cubic meters per iteration
  
                                                             ;  type "velocity = " print velocity
                                                             ;  type "hyd. rad. = " print hydraulic-radius
                                                             ;  type "cross sect. = " print cross-sectional-area
                                                             ;  type "manning's = " print mannings-coefficient
                                                             ;  type "slope = " print longitudinal-slope
  set max-flow-volume velocity * cross-sectional-area
  
  let volume-to-height max-flow-volume / ( cell-dimension-m * cell-dimension-m ) ;;; convert from cubic meters to meters
  set max-flow-height precision ( volume-to-height * 1000 ) 10 ;;; changing back to mm
  
  
end



to export-GI
  let sample2 0
  file-open "sample1.txt"
  ask patches with [ gi? = true ] [
    
    
    if type-of-GI = "swale" [
      file-write 0
    ]
    if type-of-GI = "rain-barrel" [
      file-write 1
    ]
    if type-of-GI = "green roof" [
      file-write 2
    ]
    if type-of-GI = "permeable paver" [
      file-write 3
    ]
    file-write pxcor
    file-write pycor
  set sample2 sample2 + 1
  ]
  file-close
  print sample2
end
@#$#@#$#@
GRAPHICS-WINDOW
16
59
371
465
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
22
0
24
0
0
1
ticks
30.0

BUTTON
430
335
608
384
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
431
388
609
437
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

PLOT
15
670
527
905
Cumulative Water Accounting
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
"CSO" 1.0 0 -14737633 true "" ""

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
519
527
669
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
430
448
581
493
Time in run (military time)
Time
17
1
11

SWITCH
1133
223
1267
256
record-movie?
record-movie?
1
1
-1000

CHOOSER
1129
70
1267
115
Type-to-place
Type-to-place
"Green roofs" "Swales" "Green alleys" "Rain barrels"
1

BUTTON
1129
31
1308
64
Place Green Infrastructure
Place-GI
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
1131
119
1277
164
GI-Import-scenario
GI-Import-scenario
"Results.txt" "Blank.txt" "Trial1.txt" "BI-max-GI.txt" "BI-swales.txt" "BI-barrels.txt"
1

PLOT
15
906
527
1135
Water Accounting
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
"Rain" 1.0 0 -11221820 true "" ""
"GI Infiltration" 1.0 0 -13840069 true "" ""
"Permeable Infiltration" 1.0 0 -6459832 true "" ""
"Sewer Runoff" 1.0 0 -7500403 true "" ""
"Outlet Runoff" 1.0 0 -2674135 true "" ""
"Evaporation and Evapotranspiration" 1.0 0 -1184463 true "" ""
"Inflow from Neighbors" 1.0 0 -2064490 true "" ""
"CSO" 1.0 0 -14737633 true "" ""

SLIDER
424
52
658
85
Private-install-budget
Private-install-budget
0
1500
600
10
1
,000 dollars
HORIZONTAL

MONITOR
741
505
928
550
Installation cost of private GI ($)
Cost-install-private-GI
2
1
11

MONITOR
742
555
928
600
Installation cost of public GI ($)
Cost-install-public-GI
2
1
11

MONITOR
741
653
930
698
Maintenance cost of public GI ($)
Cost-public-maintenance
2
1
11

MONITOR
742
702
930
747
Private property damages ($)
Cost-private-property-damage
2
1
11

MONITOR
742
750
932
795
Public property damages ($)
Cost-public-property-damage
2
1
11

MONITOR
742
604
929
649
Maintenance cost of private GI ($)
Cost-private-maintenance
2
1
11

MONITOR
971
516
1114
561
Installation of private GI
Normalized-Cost-install-private-GI
2
1
11

MONITOR
972
565
1115
610
Installation of public GI
Normalized-Cost-install-public-GI
2
1
11

MONITOR
974
613
1115
658
Maintenance of private GI
Normalized-Cost-private-maintenance
2
1
11

MONITOR
974
660
1115
705
Maintenance of public GI
Normalized-Cost-public-maintenance
2
1
11

MONITOR
975
707
1116
752
Private property damage
Normalized-Cost-private-property-damage
2
1
11

MONITOR
975
757
1119
802
Public property damage
Normalized-Cost-public-property-damage
2
1
11

MONITOR
1131
514
1310
559
Greatest depth of standing water
Normalized-greatest-depth-standing-water-ft
2
1
11

MONITOR
1131
563
1287
608
Outflow
Normalized-global-outflow-ft3
2
1
11

MONITOR
1133
612
1288
657
Inflow
Normalized-global-inflow-ft3
2
1
11

MONITOR
1133
661
1288
706
GI infiltration
Normalized-global-GI-infiltration-ft3
2
1
11

MONITOR
1133
710
1289
755
Rain barrel efficiency
global-efficiency-rain-barrels
2
1
11

MONITOR
1134
757
1290
802
Bioswale efficiency
global-efficiency-swales
2
1
11

MONITOR
1136
804
1291
849
Permeable paver efficiency
global-efficiency-green-alleys
2
1
11

MONITOR
1137
851
1292
896
Water in all GI
Normalized-global-GI-total
2
1
11

CHOOSER
1131
171
1269
216
when-sewers-full
when-sewers-full
"no-CSO" "allow CSO"
0

CHOOSER
427
229
565
274
Storm-type
Storm-type
"1-year" "2-year" "5-year" "10-year" "25-year" "50-year" "100-year"
1

TEXTBOX
585
229
716
341
Sample Rainfall totals (24-hour only listed)\n1-year = 2.43 inches\n2-year = 2.95 inches\n5-year = 3.77 inches\n10-year = 4.45 inches\n100-year = 7.2 inches\n
11
0.0
1

CHOOSER
425
128
649
173
Neighbor-option
Neighbor-option
"No neighbor inflows" "Fixed neighbor inflows (bad neighbors)"
1

SLIDER
424
88
659
121
Public-install-budget
Public-install-budget
0
1000
70
10
1
,000 dollars
HORIZONTAL

SLIDER
673
53
914
86
Private-maintenance-budget
Private-maintenance-budget
0
100
50
1
1
,000 dollars
HORIZONTAL

SLIDER
673
89
914
122
Public-maintenance-budget
Public-maintenance-budget
0
50
12
1
1
,000 dollars
HORIZONTAL

TEXTBOX
799
478
949
496
Raw scores
11
0.0
1

TEXTBOX
1048
465
1198
483
Normalized values
11
0.0
1

TEXTBOX
974
485
1124
513
Normalized versions of values to left
11
0.0
1

TEXTBOX
1138
493
1288
511
Other normalized values
11
0.0
1

TEXTBOX
1146
10
1296
28
Backup features/settings
11
0.0
1

TEXTBOX
620
25
770
43
Primary settings
11
0.0
1

SLIDER
428
185
615
218
Initial-sewer-capacity
Initial-sewer-capacity
0
100
50
1
1
%
HORIZONTAL

SWITCH
916
355
1100
388
Outflow-calibration-run?
Outflow-calibration-run?
1
1
-1000

SWITCH
917
393
1113
426
Normalization-calibration-run?
Normalization-calibration-run?
1
1
-1000

TEXTBOX
1114
348
1295
390
Run only with no GI (Blank.txt). Overrides neighbor-option and has no inflows; records outflows.
11
0.0
1

CHOOSER
429
282
567
327
Storm-duration
Storm-duration
"1-hour" "2-hour" "3-hour" "6-hour" "12-hour" "24-hour"
5

SWITCH
994
317
1099
350
MYSQL?
MYSQL?
1
1
-1000

TEXTBOX
1112
314
1262
356
Only turn on when a server is available, otherwise will crash.
11
0.0
1

TEXTBOX
1123
394
1273
436
Must be run after outflow calibration; again, with no GI (Blank.txt)
11
0.0
1

@#$#@#$#@

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
NetLogo 5.0.5
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
