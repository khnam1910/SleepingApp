# Tasks: Optimize Alarm Logic - Prioritization and Mutual Exclusion

- [x] **Step 1: Domain Utilities**
    - [x] Add `hasSameScheduleConfig` to `SleepMathUtils`.
    - [x] Add `isLaterBedTime` to `SleepMathUtils`.
- [x] **Step 2: Bloc Implementation**
    - [x] Update `_onToggleAlarmRequested` in `AlarmBloc` to disable conflicting alarms.
    - [x] Update `_onSaveAlarmRequested` in `AlarmBloc` to disable conflicting alarms when saving a new active one.
- [x] **Step 3: Verification**
    - [x] Verify automatic disabling of conflicting alarms on toggle.
    - [x] Verify prioritization of later bedtime when saving.
