# Weapon System

This resource integrates with **ox_inventory** without modifying any of its files.

## ox_inventory integration

* Weapons are tracked using the public client event `ox_inventory:currentWeapon`.
* When a sidearm is equipped the resource displays a holster prompt and waits for
  the player to confirm or cancel. Cancelling calls the `ox_inventory:disarm`
  event so the weapon is unequipped.
* Key mappings for `confirmHolster` and `cancelHolster` are registered at runtime
  using the settings from `MBT.HolsterControls`.

Because the integration relies solely on exports and events provided by
`ox_inventory`, updates to that resource no longer require manual patching.

