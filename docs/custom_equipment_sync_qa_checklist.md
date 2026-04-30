# Custom Equipment Sync QA Checklist

## Preconditions
- Firebase Auth and Firestore are configured.
- Firestore rules for `user_custom_equipment/{uid}` are deployed.
- Test with at least 2 accounts (`User A`, `User B`).
- If possible, test on 2 devices/sessions for same account.

## 1) Account isolation
1. Login as `User A`.
2. Create a custom weapon and custom armor from Build Simulator.
3. Verify both appear in equipment picker and can be equipped.
4. Logout.
5. Login as `User B`.
6. Open equipment picker and set source filter to `Player Created`.
7. Expected: no items from `User A` are visible.

## 2) Same-account cross-session sync
1. Login as `User A` on Device/Session 1 and Device/Session 2.
2. On Device/Session 1, create custom item `A1`.
3. On Device/Session 2, refresh/reopen Build Simulator.
4. Expected: `A1` appears and can be equipped.
5. On Device/Session 2, edit `A1` stats/name.
6. On Device/Session 1, refresh/reopen Build Simulator.
7. Expected: edited values appear.
8. On Device/Session 1, delete `A1`.
9. On Device/Session 2, refresh/reopen Build Simulator.
10. Expected: `A1` is removed.

## 3) Filter behavior
For each category that supports custom items (`Weapon`, `Armor`):
1. Open Equipment Library picker.
2. Set source filter to `All Sources`.
   - Expected: official + custom items appear.
3. Set source filter to `Player Created`.
   - Expected: only custom items appear.
4. Set source filter to `Official Only`.
   - Expected: only official items appear.
5. Verify `Custom` badge appears on player-created item cards.

## 4) Edit/Delete UI actions
1. Equip a custom item in supported slot.
2. Open selected item details panel.
3. Expected: `Edit` and `Delete` buttons are shown for custom items.
4. Click `Edit`, save changes.
   - Expected: stats/name update and item remains synced.
5. Click `Delete`, confirm.
   - Expected: item removed locally and from cloud after refresh.

## 5) Logout/Login behavior
1. Login as `User A` and ensure custom items are present.
2. Logout.
3. Expected: custom cache clears from UI for signed-out user.
4. Login again as `User A`.
5. Expected: custom items are loaded back from merge(local+cloud).

## 6) Basic failure handling (optional)
1. Simulate network interruption while creating/editing/deleting.
2. Expected: app does not crash; action may stay local until next successful sync.
3. Restore network and refresh.
4. Expected: cloud and local converge.
