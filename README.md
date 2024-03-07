# Randolio: Car Heist

**ESX and QB supported with bridge**

Before boosting was ever a thing, we had the OG car heist.

Start the job and get a random vehicle, location and drop off. The vehicle will be tracked for police for 5 minutes with an updated blip every 5 seconds. Once the tracker is off and you're in the clear, take it to the drop off to get the delivery papers which you can turn into the guy at the start for a cash reward. 


**NOTE**: From the moment you request the job, you have 30 minutes (can be changed) to complete it otherwise the vehicle is useless and the heist is over.

## Items

For ox_inventory, add this to your items.lua:
```lua
["heist_papers"] = {
    label = "Vehicle Papers",
    weight = 0,
    stack = false,
    close = true,
    description = "Delivery documents.",
    client = {
        image = "heist_papers.png",
    }
},
```
For qb-inventory, add this to your items.lua
```lua
heist_papers = {
    name = 'heist_papers',
    label = 'Vehicle Papers',
    weight = 0,
    type = 'item',
    image = 'heist_papers.png',
    unique = true,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = 'Delivery documents.'
},
```

## Requirements

* [ox_lib](https://github.com/overextended/ox_lib/releases/tag/v3.16.2)

## Showcase

* [Showcase](https://streamable.com/1jqvax)