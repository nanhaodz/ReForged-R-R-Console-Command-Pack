# ReForged-R-R-Console-Command-Pack
> *Research and record for all things ReForged!*

## Description
Add console commands to debug and test Forge-related content. Made for ReForged, a workshop item from Don't Starve Together.
Required items:
* [ReForged](https://steamcommunity.com/workshop/filedetails/?id=1938752683)
* TBA

## Documentation
| Command                    | Description                                             | Parameters                                  |
| -------------------------- | ------------------------------------------------------- | ------------------------------------------- |
| `c_rr_gethealth("prefab")` | Find the nearest prefab and print its health info.      | <ul><li>`prefab`: The prefab name</li></ul> |
| `c_rr_restore("prefab")`   | Find the nearest prefab and restore its health to full. | <ul><li>`prefab`: The prefab name</li></ul> |
| `c_stop_brain(inst)`       | Stop the brain of an object. Note: The brain will reactivate under certain circumstances (TBA). | <ul><li>`inst`: The object with a brain to stop</li></ul> |
| `c_rr_dummy(prefab, do_announce, maxhealth)` | Spawn a dummy and track its health loss. | <ul><li>`prefab`: The prefab of the mob to spawn</li><li>`do_announce`: Whether to print out the damage amount every time the dummy is attacked. Default: nil</li><li>`maxhealth`: The amount to overwrite the dummy's max health. Default: nil</li></ul> |
| `c_rr_dpsdummy(prefab, dur, maxhealth)`      | Spawn a dummy and track its health loss. | <ul><li>`prefab`: The prefab of the mob to spawn</li><li>`duration`: The duration of recording in seconds. Default: 30</li><li>`maxhealth`: The amount to overwrite the dummy's max health. Default: nil</li></ul> |
| `c_rr_damagehit(inst, perc, flat)`           | Hit the object for a precise amount of damage. | <ul><li>`inst`: The object to hit</li><li>`perc`: The percentage of object's max health to deal as damage (must be betwwen 0 and 1)</li><li>`flat`: The additional amount of flat damage. Default: 0</li></ul> |
| `c_rr_recorddistance(inst, duration)`        | Measure the distance travelled of an object over a time duration. | <ul><li>`inst`: The object to track</li><li>`duration`: The duration of time in seconds. Default: 5</li></ul> |
| `c_rr_scantable(table)`    | Print the content of a lua table.                       | <ul><li>`table`: The lua table</li></ul>    |
