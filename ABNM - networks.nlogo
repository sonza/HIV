//comment delete later//

;; Modifications to model compared to Model assignment 1- PART E
;;Added Globals: 1) Num-Contacts-Distribution; 2) Contacts-mixing-matrix 3) Population-Age-Distribution 4) lower-bound-Age
;;Added turtle-own: 1) age 2) contacts by age
;; added procedures : 1) setUpGlobals 2) generateContactNetwork
;; modifcations to procedures:  UpdateInfectedContacts

extensions [matrix nw]
;Initilize global variables
Globals[

  NumSusceptible
  NumInfected
  NumDead
  NumRecovered
  NumNewInfected
  NumNewReported
  Num-Contacts-Distribution
  num-Contacts-By-Age
  Population-Age-Distribution
  lower-bound-Age
]

;Initialize breed-specific variables
breed [people person]

turtles-own[
  Incubation&Latent
  Incubation&Infectious
  Symtomatic&Infectious
  TimeSinceInfection
  Stage
  Alive?
  VaccineProtected
  InfectedContacts
  age
]


to setup ;; Initialize the population and individual characteristics
  ca
  setupGlobals


  ifelse Contact_Types = "Network"[
   generateSmallWorld ]
  [ifelse Contact_Types = "Mixing Matrix"
    [ generateContactNetwork]
    [generateRadiusNetwork]
  ]
  setupPeople
    reset-ticks
end

to setupGlobals
  set Num-Contacts-Distribution [4.69	13.84	14.37	14.14	11.47	11.22	9.05	11.29	12.31	8.37	8.99	7.17]
  set num-Contacts-By-Age  matrix:from-row-list [
    [	0.23	0.77	0.08	0.23	0.08	0.38	1.00	0.85	0.00	0.00	0.15	0.92	]
    [	0.00	7.76	1.06	0.19	0.09	0.24	0.96	1.18	0.77	0.24	0.16	0.65	]
    [	0.00	0.00	8.18	0.50	0.17	0.29	0.61	1.10	0.94	0.54	0.28	0.88	]
    [	0.00	0.00	0.00	8.29	0.37	0.35	0.42	0.93	1.09	0.65	0.37	0.66	]
    [	0.00	0.00	0.00	0.00	3.79	1.83	1.23	1.00	0.75	0.90	0.73	0.85	]
    [	0.00	0.00	0.00	0.00	0.00	1.05	2.13	1.38	1.05	0.58	1.05	1.72	]
    [	0.00	0.00	0.00	0.00	0.00	0.00	1.82	0.96	0.78	0.60	0.40	1.17	]
    [	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.52	1.18	0.74	0.62	1.12	]
    [	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	2.17	0.92	0.89	1.98	]
    [	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.88	0.76	1.28	]
    [	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	1.00	2.33	]
    [	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	2.29	]
  ]

  set Population-Age-Distribution [0.1	0.1	0.1	0.1	0.1	0.1	0.1	0.1	0.1	0.1	0.1	0.1]
  set lower-bound-Age [0	5	10	15	20	25	30	35	40	45	50	55 80]
  let i 0

  while [i < (length lower-bound-Age - 1 )][
    let j i
    while [j < length lower-bound-Age - 1 ][
      MATRIX:set num-Contacts-By-Age i j   (MATRIX:get num-Contacts-By-Age  i j * contactFactor)
      set j j + 1
    ]
    set i i + 1
  ]
end

to setupPeople
 ask people [
    set Incubation&Latent (Incubation&Latent.Min + random (Incubation&Latent.Max -  Incubation&Latent.Min)) ;;Why is this max-max?--fixed to Max-Min
    set Incubation&Infectious Incubation&Latent + Incubation&Infectious.Average
    set Symtomatic&Infectious Incubation&Infectious + (Symtomatic&Infectious.Min + random (Symtomatic&Infectious.Max - Symtomatic&Infectious.Min))

  ]


  ;Layout people in circle, which will be useful for verification: by setting immediate contact as the person to one's left
  ; also note that 'sort' will sort people according to their 'WHO' number which is a unique identifier
 ; layout-circle sort turtles 5

   ask n-of initial.infections people with [ who < initial.infections ] [
    set stage 1
    set color red
    set label stage
    set TimeSinceInfection 1
  ]

  ;;Select a propotion of people to be vaccinated (select among those not already infected)
  ask n-of (initial.vaccine.coverage * population.size * vaccine.effectiveness) people with [stage = 0][
    set stage 5
    set color yellow
    set label stage
    set VaccineProtected true
  ]

  UpdateStage
  UpdateColor

end



to do-layout
  layout-spring turtles with [ any? link-neighbors ] links 0.4 6 1
  display  ;; so we get smooth animation
end

to generateSmallWorld
  nw:generate-watts-strogatz people links population.size contacts_per_day / 2 rewire-probability [set TimeSinceInfection 0
    set Stage 0
    set Alive? true
    set VaccineProtected false
    set InfectedContacts 0
    set shape "person"
    set color green
    setxy  random-xcor random-ycor
    set size .25
    set size 1
    set label stage
    set age random 80]
end

to generateRadiusNetwork
 create-people population.size[
    set TimeSinceInfection 0
    set Stage 0
    set Alive? true
    set VaccineProtected false
    set InfectedContacts 0
    set shape "person"
    set color green
    setxy  random-xcor random-ycor
    set size .25
    set size 1
    set label stage
    set age random 80
  ]
end
to generateContactNetwork
 create-people population.size[
    set TimeSinceInfection 0
    set Stage 0
    set Alive? true
    set VaccineProtected false
    set InfectedContacts 0
    set shape "person"
    set color green
    setxy  random-xcor random-ycor
    set size .25
    set size 1
    set label stage
    set age random 80
  ]
  let i 0

  while [i < (length lower-bound-Age - 1 )][
    let j i

    while [j < length lower-bound-Age - 1 ][
      let number-contacts-to-create ((matrix:get num-Contacts-By-Age  i j ) * count people with [age >= item i lower-bound-Age and age <= item (i + 1) lower-bound-Age])

      repeat number-contacts-to-create[

        if i = j [set number-contacts-to-create number-contacts-to-create / 2]
         ask one-of people with [age >= item i lower-bound-Age and age <= item (i + 1) lower-bound-Age] [

          let id who
          let contactPerson one-of people  with [age >= item j lower-bound-Age and age <= item (j + 1) lower-bound-Age and who != id]
          if contactPerson != nobody [create-link-with contactPerson]
        ]

      ]
      set j j + 1
    ]
    set i i + 1
  ]
 layout-circle turtles max-pxcor - 1
  repeat 200 [ do-layout ]
end


to simulate

  let i count people with [stage = 1 or stage = 2 or stage = 3] ;stops if no one is infected anymore
  if i = 0 [
    stop
  ]
  let a count people with [Alive? = true] ;if no one is alive then stop
  if a = 0 [
    stop
  ]

  Procedure
  tick

end

to Procedure
  ifelse Contact_Types = "Network"[
    UpdateInfectedContactsNetwork]
  [ UpdateInfectedContactsRadius
  ]

  UpdateTimeSinceInfection
  InfectSusceptibles
  UpdateStage
  UpdateAlive?
  UpdateColor
  if Contact_Types = "Radius" and Move? = "Yes"[
    MovePeople

  ]

end



;;for verification purposes
;to UpdateInfectedContacts
;  ask people[
;    let id who
;    let n count people with [who = id - 1 and (stage = 2 or stage = 3)  ]
;    ;print n
;    set InfectedContacts n
;  ]
;end

to UpdateInfectedContactsNetwork
  ask people[
    set InfectedContacts count link-neighbors with [stage = 2 or stage = 3  and Alive? = true]
  ]
end

;Otherwise contacts can be updated using radius
to UpdateInfectedContactsRadius
  ask people[
    let n count people in-radius contact.radius with [(stage = 2 or stage = 3) and Alive? = true] ;counts people in 1 radius that are alive and infectious (not infectious after death???)
    set InfectedContacts n
  ]
end

to UpdateTimeSinceInfection
  ask people with [TimeSinceInfection > 0][
    set TimeSinceInfection TimeSinceInfection + 1]
end


to InfectSusceptibles
  ask people with [stage = 0 ][ ;asks susceptible population
    if random-float 1 < 1 - (1 - transmission.risk) ^ (InfectedContacts) [
      set TimeSinceInfection 1
    ]
  ]
end


;a proportion (= mortality.rate) of people will die and rest will recover
to UpdateAlive?
  let numNewDeaths (mortality.rate * count people with [TimeSinceInfection = Symtomatic&Infectious + 1])
  ask n-of numNewDeaths people with [TimeSinceInfection = Symtomatic&Infectious + 1][
    set Alive? false
    die

  ]

end


to UpdateStage

  ask people with [TimeSinceInfection = 0 and VaccineProtected = false][
    set stage 0
  ]
  ask people with [TimeSinceInfection > 0][
    set stage 1
  ]
  ask people with [TimeSinceInfection > Incubation&Latent][
    set stage 2
  ]
  ask people with [TimeSinceInfection > Incubation&Infectious][
    set stage 3
  ]
  ask people with [TimeSinceInfection > Symtomatic&Infectious][
    set stage 4
  ]
  ask people with [TimeSinceInfection = 0 and VaccineProtected = true][
    set stage 5
  ]
end

to UpdateColor
  ask people with [stage = 1 or stage = 2 or stage = 3][
    set color red
  ]
  ask people with [stage = 4][
    set color blue
  ]
  ask people with [stage = 5][
    set color yellow
  ]
  ask people with [Alive? = false][
    set color black
  ]
  ask people [
    set label stage
  ]
end

to MovePeople
  ask people[
    setxy random-xcor random-ycor
  display]

end

;CREDITS FOR BELOW
; Copyright 2005 Uri Wilensky.
; See Info tab for full copyright and license.
to layout
  ;; the number 3 here is arbitrary; more repetitions slows down the
  ;; model, but too few gives poor layouts
  repeat 3 [
    ;; the more turtles we have to fit into the same amount of space,
    ;; the smaller the inputs to layout-spring we'll need to use
    let factor sqrt count turtles
    ;; numbers here are arbitrarily chosen for pleasing appearance
    layout-spring turtles links (1 / factor) (7 / factor) (1 / factor)
    display  ;; for smooth animation
  ]
  ;; don't bump the edges of the world
  let x-offset max [xcor] of turtles + min [xcor] of turtles
  let y-offset max [ycor] of turtles + min [ycor] of turtles
  ;; big jumps look funny, so only adjust a little each time
  set x-offset limit-magnitude x-offset 0.1
  set y-offset limit-magnitude y-offset 0.1
  ask turtles [ setxy (xcor - x-offset / 2) (ycor - y-offset / 2) ]
end
to-report limit-magnitude [number limit]
  if number > limit [ report limit ]
  if number < (- limit) [ report (- limit) ]
  report number
end
@#$#@#$#@
GRAPHICS-WINDOW
306
10
810
515
-1
-1
29.2
1
10
1
1
1
0
1
1
1
-8
8
0
16
0
0
1
ticks
30.0

BUTTON
61
10
124
43
setup
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
60
45
137
78
simulate
simulate
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
-2
151
153
211
transmission.risk
0.1
1
0
Number

INPUTBOX
-2
210
153
270
initial.vaccine.coverage
0.0
1
0
Number

INPUTBOX
-1
270
154
330
vaccine.effectiveness
1.0
1
0
Number

INPUTBOX
-2
90
153
150
population.size
100.0
1
0
Number

INPUTBOX
-3
329
152
389
mortality.rate
0.0
1
0
Number

MONITOR
839
100
994
145
NumDeaths
population.size - count turtles
0
1
11

MONITOR
840
10
987
55
NumSusceptible
count turtles with [stage = 0]
17
1
11

MONITOR
842
54
995
99
NumInfected
count turtles with [stage = 1 or stage = 2 or stage = 3]
17
1
11

MONITOR
840
146
993
191
NumRecovered
count turtles with [stage = 4]
17
1
11

MONITOR
841
277
996
322
NumVaccinated&Protected
count turtles with [stage = 5 and VaccineProtected = true]
17
1
11

MONITOR
840
189
993
234
NumNewInfected
count turtles with [ TimeSinceInfection = 1]
17
1
11

MONITOR
841
232
995
277
NumNewReported
count turtles with [timeSinceInfection = Incubation&Infectious + 1]
17
1
11

INPUTBOX
-3
388
152
448
initial.infections
1.0
1
0
Number

INPUTBOX
154
148
309
208
Incubation&Latent.Max
20.0
1
0
Number

INPUTBOX
153
90
308
150
Incubation&Latent.Min
20.0
1
0
Number

INPUTBOX
149
207
308
267
Incubation&Infectious.Average
20.0
1
0
Number

INPUTBOX
151
330
306
390
Symtomatic&Infectious.Max
10.0
1
0
Number

INPUTBOX
151
271
306
331
Symtomatic&Infectious.Min
20.0
1
0
Number

PLOT
1003
12
1428
271
Population Dynamics
Time
Population
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Susceptible" 1.0 0 -13840069 true "" "plot count turtles with [ stage = 0 ] "
"Infected" 1.0 0 -2674135 true "" "plot count turtles with [ stage = 1 or stage = 2 or stage = 3] "
"Recovered" 1.0 0 -14070903 true "" "plot count turtles with [ stage = 4] "
"Dead" 1.0 0 -16777216 true "" "plot count turtles with [Alive? = false]"
"Vaccinated&Protected" 1.0 0 -1184463 true "" "plot count turtles with [stage = 5 and VaccineProtected = true]"

PLOT
1005
277
1388
511
Infection Dynamics
Time
Population
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"New Infections" 1.0 0 -955883 true "" "plot count turtles with [TimeSinceInfection = 1]"
"New Reported" 1.0 0 -16710398 true "" "plot count turtles with [TimeSinceInfection = Incubation&Infectious + 1]"

MONITOR
856
377
948
422
Mortality Rate
(population.size - count turtles)  / (count turtles with [stage = 4] + population.size - count turtles )
1
1
11

MONITOR
858
431
979
476
CumulativeInfected
count turtles with [stage = 4] + population.size - count turtles
17
1
11

PLOT
1005
517
1399
667
Average Time With Infection
NIL
NIL
0.0
10.0
0.0
15.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [TimeSinceInfection] of turtles with [TimeSinceInfection = Symtomatic&Infectious]"

TEXTBOX
360
518
510
616
Stage legend\n0- Susceptible\n1- Incubation and latent\n2- Incubation and infectious\n3- Symtomatic and Infectious\n4– Recovered and immune\n5- Vaccinated and immune
11
0.0
1

TEXTBOX
512
521
662
619
Color legend:\ngreen- susceptible (stage 0) \nred-   infected (stages 1+2+3)\nblue-  recovered (stage 4) \nyellow-vaccineProtected (stage 5)\nblack- dead (Alive? False)
11
0.0
1

INPUTBOX
154
477
277
537
contactFactor
0.5
1
0
Number

BUTTON
-10
10
64
43
NIL
clear-all
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
4
478
156
523
Contact_Types
Contact_Types
"Radius" "Network" "MixingMatrix"
1

INPUTBOX
155
539
275
599
contact.radius
1.0
1
0
Number

CHOOSER
9
530
147
575
Move?
Move?
"Yes" "No"
0

INPUTBOX
20
618
175
678
contacts_per_day
4.0
1
0
Number

INPUTBOX
183
616
338
676
Rewire-Probability
0.5
1
0
Number

BUTTON
179
39
274
72
redo layout
layout
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
787
569
976
614
average contacts
mean [count my-links] of people
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Initialize Infection" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count towns with [color = red]</metric>
    <enumeratedValueSet variable="initial">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recoveryRate">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmissionRate">
      <value value="0.03"/>
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
