# Roblox Script: Raylight Interface

Raylight Interface is a client-side Roblox script that provides a Rayfield-inspired dark utility UI for R15 character controls, including sitting, spinning, dwarf and giant-dwarf scaling, flying, and infinite jumping.

## Install

1. Open the place in Roblox Studio.
2. Enable Explorer and Properties if they are not already visible.
3. Navigate to `StarterPlayer > StarterPlayerScripts`.
4. Insert a `LocalScript`.
5. Copy the contents of `StarterPlayer/StarterPlayerScripts/R15Utility.client.lua` into the LocalScript.
6. Test the script with an R15 character.

The script must run as a LocalScript in `StarterPlayerScripts` because it controls the local player's interface, input, movement, and character effects. Do not place it in `ServerScriptService`.

## Use

1. Start a play test in Roblox Studio.
2. Use the buttons in the Raylight Interface menu:
   - `Cute Sit` toggles the Humanoid sitting state.
   - `Spin` toggles continuous character rotation.
   - `Dwarf` applies smaller R15 body scale values.
   - `Giant Dwarf` applies larger R15 body scale values.
   - `Fly` toggles flight.
   - `Infinite Jump` allows jumping whenever jump input is requested.
   - `Reset Character Effects` disables active effects and restores saved body scales.
3. While flying, use:
   - `WASD` to move horizontally.
   - `Space` to rise.
   - `Left Ctrl` to descend.
4. Press `RightShift` to show or hide the menu.
5. Use an R15 avatar for the Dwarf and Giant Dwarf options.

These effects are intended for experiences you own or are authorized to develop. Client-side movement and character changes can be rejected or overridden by a server.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/d8d8a2c5-3e4d-4e62-9c79-6da6143c2c93?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=d8d8a2c5-3e4d-4e62-9c79-6da6143c2c93
