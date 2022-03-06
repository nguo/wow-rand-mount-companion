# RandomMountAndCompanion

WoW Classic TBC addon to summon a random mount and companion in your bags. It assumes that you have the proper riding skill to use all the mounts that are soulbound to you in the bag. Chooses flying mounts if in a flyable zone, otherwise chooses a ground mount. It does not distinguish between slow and fast ground/flying mounts.

To hook it up, add a macro like so:

```
/run rmcSetRandom(false)
/click [nomounted] rmcCompanionButton
/click [nomounted] rmcMountButton
/dismount [mounted]
```

If you're not mounted yet, the macro will summon a random companion and mount. If you are mounted, you'll be dismounted.