turtles-own  [ threshold1 threshold2]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup
  clear-all
  setup-nodes   
  setup-network 
  set-seed            
  reset-ticks
end ;;to setup

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go  ;this is the engine of the model, turtles are updated sequentially
 ;this stops the model when equilibrium is reached 
 if count turtles = count turtles with [color = green or color = blue]                                                           ;true if all agents are infected
    or
    ((count turtles with [ (color = red) and (count link-neighbors with [color = green] >= threshold1)]  = 0)      ;true if no further agents can be infected 
    and    
    (count turtles with [ (color = red) and (count link-neighbors with [color = blue] >= threshold2)]  = 0))      ;true if no further agents can be infected 
 
    [stop]
  
 ;this is the engine 
  ask turtles with [color = red  and (count link-neighbors with [color = green] >= threshold1)]    
         [set color green]
  if ticks > delay
         [ask turtles with [color = red  and (count link-neighbors with [color = blue] >= threshold2)]    
                 [set color blue]]
 
 tick
 end ;;to go

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup-nodes
  set-default-shape turtles "face happy"  
  crt number-of-nodes[ 
    setxy (random-xcor * 0.95) (random-ycor * 0.95)
    set color red
    set size 2
    set threshold1 threshold-value1
    set threshold2 threshold-value2
    set label threshold1
    set label threshold2
    set label-color black 
    ]
  ask patches [ set pcolor white ] 
end ;;to setup-nodes

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup-network
  let loop-step  999999
  let loop-step2 999999
  let num-links (average-node-degree * number-of-nodes) / 2
  
  layout-circle sort turtles 25
         if average-node-degree > 0 
            [ask turtles 
                     [         
                     set loop-step 1 
                     loop [
                          if   who < (number-of-nodes -(average-node-degree / 2))                                                  
                               [create-link-with turtle (who + loop-step) ]
                          if ((who >= (number-of-nodes -(average-node-degree / 2))) and ((who + loop-step) <  (number-of-nodes ))) 
                               [create-link-with turtle (who + loop-step) ]                          
                          if ((who >= (number-of-nodes -(average-node-degree / 2))) and ((who + loop-step) >= (number-of-nodes ))) 
                               [create-link-with turtle ((average-node-degree / 2 ) - loop-step) ]
                          set loop-step loop-step + 1
                          if loop-step > (average-node-degree / 2) [stop]
                          ]    ]]  
  sping-embedding
  if (MS_rewiring_iterations > 0) [Maslov_Sneppen_rewiring] 
  ask links [ set color black ]
end ;;setup-network

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to Maslov_Sneppen_rewiring
 let A-who 99999
 let B-who 99999
 let C-who 99999
 let D-who 99999
 let successful 0
   
 while [successful < MS_rewiring_iterations]
  [;;first step: pick two pairs that might be rewired 
    ask one-of turtles 
            [set A-who who
             ask one-of link-neighbors [set B-who who]    ]                     
    ask one-of turtles 
            [set C-who who
            ask one-of link-neighbors  [set D-who who]    ]
              
   ;;second step: rewire if there aren't links already
    if ((A-who != D-who) and  (B-who != C-who) and  (A-who != C-who) and  (B-who != D-who)    
    and not (is-link? link A-who D-who) and not (is-link? link B-who C-who)  )
      [ask turtle A-who [ ask link-with turtle B-who [ die ] ] 
       ask turtle A-who [ create-link-with turtle D-who ]
       ask turtle C-who [ ask link-with turtle D-who [ die ] ] 
       ask turtle B-who [ create-link-with turtle C-who ]
       set successful successful + 1
      ]
  ] ;;while
end ;;to Maslov_Sneppen_rewiring

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to sping-embedding
  repeat 150[   layout-spring turtles links 0.2 5 0 ]
end; to rewire-now

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to set-seed
 ask turtle 1 [set color green
               if infect-seed-neighbors [ask link-neighbors [set color green]]] 
 ask turtle (number-of-nodes / 2) [set color blue
               if infect-seed-neighbors [ask link-neighbors [set color blue]]] 
end ;;to set-seed
@#$#@#$#@
GRAPHICS-WINDOW
470
11
1362
730
45
35
9.7
1
10
1
1
1
0
0
0
1
-45
45
-35
35
1
1
1
ticks
30.0

BUTTON
247
173
342
213
NIL
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
351
173
446
213
NIL
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

SLIDER
21
43
216
76
number-of-nodes
number-of-nodes
10
500
500
5
1
NIL
HORIZONTAL

SLIDER
21
83
216
116
average-node-degree
average-node-degree
0
20
6
2
1
NIL
HORIZONTAL

TEXTBOX
60
12
220
34
Initialization
20
0.0
1

TEXTBOX
20
126
170
144
Maslov Sneppen rewiring
11
0.0
1

SLIDER
20
141
215
174
MS_rewiring_iterations
MS_rewiring_iterations
0
50
20
5
1
NIL
HORIZONTAL

SWITCH
19
182
216
215
infect-seed-neighbors
infect-seed-neighbors
0
1
-1000

SLIDER
250
45
443
78
threshold-value1
threshold-value1
1
6
2
1
1
NIL
HORIZONTAL

TEXTBOX
246
11
489
35
Adoption Parameters
20
0.0
1

PLOT
20
226
458
604
fraction adopted
ticks
percentage
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"p1" 1.0 0 -10899396 true "" "plot (count turtles with [color = green] / count turtles)"
"p2" 1.0 0 -13345367 true "" "plot (count turtles with [color = blue] / count turtles)"

SLIDER
248
86
444
119
threshold-value2
threshold-value2
1
6
1
1
1
NIL
HORIZONTAL

SLIDER
246
132
338
165
delay
delay
0
10
4
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model demonstrates the diffusion of something (e.g. a virus or an information) through a network.  

Each node represents an individual.

## HOW IT WORKS

Each time step (tick), each infected node (colored red) attempts to infect all of its neighbors.  Susceptible neighbors (colored green) will be infected with a probability given by the VIRUS-SPREAD-CHANCE slider.  This might correspond to the probability that someone on the susceptible system actually executes the infected email attachment.  
Resistant nodes (colored gray) cannot be infected.  This might correspond to up-to-date antivirus software and security patches that make a computer immune to this particular virus.

Infected nodes are not immediately aware that they are infected.  Only every so often (determined by the VIRUS-CHECK-FREQUENCY slider) do the nodes check whether they are infected by a virus.  This might correspond to a regularly scheduled virus-scan procedure, or simply a human noticing something fishy about how the computer is behaving.  When the virus has been detected, there is a probability that the virus will be removed (determined by the RECOVERY-CHANCE slider).

If a node does recover, there is some probability that it will become resistant to this virus in the future (given by the GAIN-RESISTANCE-CHANCE slider). 

When a node becomes resistant, the links between it and its neighbors are darkened, since they are no longer possible vectors for spreading the virus.

## HOW TO USE IT

Using the sliders, choose the NUMBER-OF-NODES and the AVERAGE-NODE-DEGREE (average number of links coming out of each node).

The network that is created is based on proximity (Euclidean distance) between nodes.  A node is randomly chosen and connected to the nearest node that it is not already connected to.  This process is repeated until the network has the correct number of links to give the specified average node degree.

The INITIAL-OUTBREAK-SIZE slider determines how many of the nodes will start the simulation infected with the virus.

Then press SETUP to create the network.  Press GO to run the model.  The model will stop running once the virus has completely died out.

The VIRUS-SPREAD-CHANCE, VIRUS-CHECK-FREQUENCY, RECOVERY-CHANCE, and GAIN-RESISTANCE-CHANCE sliders (discussed in "How it Works" above) can be adjusted before pressing GO, or while the model is running.

The NETWORK STATUS plot shows the number of nodes in each state (S, I, R) over time.

## THINGS TO NOTICE

At the end of the run, after the virus has died out, some nodes are still susceptible, while others have become immune.  What is the ratio of the number of immune nodes to the number of susceptible nodes?  How is this affected by changing the AVERAGE-NODE-DEGREE of the network?

## THINGS TO TRY

Set GAIN-RESISTANCE-CHANCE to 0%.  Under what conditions will the virus still die out?   How long does it take?  What conditions are required for the virus to live?  If the RECOVERY-CHANCE is bigger than 0, even if the VIRUS-SPREAD-CHANCE is high, do you think that if you could run the model forever, the virus could stay alive?

## EXTENDING THE MODEL

The real computer networks on which viruses spread are generally not based on spatial proximity, like the networks found in this model.  Real computer networks are more often found to exhibit a "scale-free" link-degree distribution, somewhat similar to networks created using the Preferential Attachment model.  Try experimenting with various alternative network structures, and see how the behavior of the virus differs.

Suppose the virus is spreading by emailing itself out to everyone in the computer's address book.  Since being in someone's address book is not a symmetric relationship, change this model to use directed links instead of undirected links.

Can you model multiple viruses at the same time?  How would they interact?  Sometimes if a computer has a piece of malware installed, it is more vulnerable to being infected by more malware.

Try making a model similar to this one, but where the virus has the ability to mutate itself.  Such self-modifying viruses are a considerable threat to computer security, since traditional methods of virus signature identification may not work against them.  In your model, nodes that become immune may be reinfected if the virus has mutated to become significantly different than the variant that originally infected the node.

## RELATED MODELS

Virus, Disease, Preferential Attachment, Diffusion on a Directed Network

## NETLOGO FEATURES

Links are used for modeling the network.  The LAYOUT-SPRING primitive is used to position the nodes and links such that the structure of the network is visually clear.

## CREDITS AND REFERENCES

To refer to this model in academic publications, please use:  Stonedahl, F. and Wilensky, U. (2008).  NetLogo Virus on a Network model.  http://ccl.northwestern.edu/netlogo/models/VirusonaNetwork.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

In other publications, please use:  Copyright 2008 Uri Wilensky.  All rights reserved.  See http://ccl.northwestern.edu/netlogo/models/VirusonaNetwork for terms of use.
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

ghost
false
0
Polygon -7500403 true true 30 165 13 164 -2 149 0 135 -2 119 0 105 15 75 30 75 58 104 43 119 43 134 58 134 73 134 88 104 73 44 78 14 103 -1 193 -1 223 29 208 89 208 119 238 134 253 119 240 105 238 89 240 75 255 60 270 60 283 74 300 90 298 104 298 119 300 135 285 135 285 150 268 164 238 179 208 164 208 194 238 209 253 224 268 239 268 269 238 299 178 299 148 284 103 269 58 284 43 299 58 269 103 254 148 254 193 254 163 239 118 209 88 179 73 179 58 164
Line -16777216 false 189 253 215 253
Circle -16777216 true false 102 30 30
Polygon -16777216 true false 165 105 135 105 120 120 105 105 135 75 165 75 195 105 180 120
Circle -16777216 true false 160 30 30

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
<experiments>
  <experiment name="experiment" repetitions="500" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <metric>count turtles with [color = green]</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infect-seed-neighbors">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="threshold-value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MS_rewiring_iterations">
      <value value="0"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
      <value value="100"/>
      <value value="1000"/>
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
