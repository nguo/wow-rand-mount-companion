# RandomMountAndCompanion

WoW Classic TBC addon to summon a random mount and companion in your bags. It assumes that you have the proper riding skill to use all the mounts that are soulbound to you in the bag. Chooses flying mounts if in a flyable zone, otherwise chooses a ground mount. It does not distinguish between slow and fast ground/flying mounts.

### Macros

#### To hook everything up in one macro:

```
/run rmcSetRandom(false)
/click rmcCompanionButton
/click [nomounted] rmcMountButton
/dismount [mounted]
```
If you're not mounted yet, the macro will summon a random companion and mount. This does mean the companion disappears once you fly away. If you are mounted, you'll be dismounted.

You can also use different macros for mount and companion.

#### For mount:
```
/run rmcSetRandom(false)
/click [nomounted] rmcMountButton
/dismount [mounted]
```

#### For companion:
```
/run rmcSetRandom(false)
/click rmcCompanionButton
```
